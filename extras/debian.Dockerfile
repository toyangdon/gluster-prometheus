# Build stage
FROM golang:1.12-stretch as build-env

RUN mkdir -p /go/src/github.com/gluster/gluster-prometheus/

WORKDIR /go/src/github.com/gluster/gluster-prometheus/

RUN set -ex && \
        export DEBIAN_FRONTEND=noninteractive; \
         apt-get install -y --no-install-recommends bash curl make git

COPY . .

#ENV GOPROXY=https://proxy.golang.com.cn,direct
#RUN go get github.com/golang/dep/cmd/dep
RUN mkdir -p /go/bin
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN scripts/install-reqs.sh
RUN PREFIX=/app make
RUN PREFIX=/app make install

# Create small image for running
FROM centos

ARG GLUSTER_VERSION=7

# Install gluster cli for gluster-exporter
RUN yum install centos-release-gluster7 -y 
RUN yum install glusterfs-server -y

WORKDIR /app

COPY --from=build-env /app /app/

ENTRYPOINT ["/app/sbin/gluster-exporter"]
