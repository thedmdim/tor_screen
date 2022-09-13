FROM alpine:3.16

WORKDIR /root
COPY * ./

# switch repo to edge
RUN echo -e "http://dl-3.alpinelinux.org/alpine/edge/main\nhttp://dl-3.alpinelinux.org/alpine/edge/community" > /etc/apk/repositories

# install packages
RUN apk update && apk upgrade && \
	apk add --no-cache tor i2pd git make automake autoconf go python3 py-pip && \
	pip install -r requirements.txt && \
	git clone https://github.com/tinyproxy/tinyproxy.git && \
	cd tinyproxy && ./autogen.sh && make && make install && make clean && cd .. && rm -rf tinyproxy && \
	git clone --branch netstack --single-branch https://github.com/yggdrasil-network/yggdrasil-go.git && \
	cd yggdrasil-go && go build -o ../yggstack cmd/yggstack/main.go && go clean -cache && cd .. && rm -rf /yggdrasil-go && \
	apk del git make automake autoconf go

# set configs
COPY ./tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY ./yggdrasil.conf /etc/yggdrasil.conf
RUN cp /etc/tor/torrc.sample /etc/tor/torrc


# run overlays
COPY ./run.sh /opt/src/run.sh
RUN chmod 755 /opt/src/run.sh
CMD ["/opt/src/run.sh"]
