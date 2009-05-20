From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFC 0/2] New socket API: recvmmsg
Date: Wed, 20 May 2009 20:06:42 -0300
Message-ID: <20090520230642.GA5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: netdev@vger.kernel.org, Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57069 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbZETXGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 19:06:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

	The following two patches, that I cooked today and haven't
properly benchmarked, implements a new socket syscall, recvmmsg, that
stands for receive multiple messages, in one call.

	I implemented the attached program as a test case and to show
it in action, and lightly tested it using two clients (netcat) sending
big files from a machine with a 100 mbit/s NIC and another with a 1
Gbit/s NIC to a server with the patched kernel, output:

$ ./recvmmsg 5001 128
nr_datagrams received: 19
    4352 bytes received from doppio.ghostprotocols.net in 17 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    256 bytes received from doppio.ghostprotocols.net in 1 datagrams
nr_datagrams received: 14
    2816 bytes received from doppio.ghostprotocols.net in 11 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    512 bytes received from doppio.ghostprotocols.net in 2 datagrams
nr_datagrams received: 19
    2304 bytes received from doppio.ghostprotocols.net in 9 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    2304 bytes received from doppio.ghostprotocols.net in 9 datagrams
nr_datagrams received: 14
    2816 bytes received from doppio.ghostprotocols.net in 11 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams
    512 bytes received from doppio.ghostprotocols.net in 2 datagrams
nr_datagrams received: 19
    4608 bytes received from doppio.ghostprotocols.net in 18 datagrams
    256 bytes received from filo.ghostprotocols.net in 1 datagrams

filo is the machine with a 100 mbit/s NIC, obviously :-)

	There are some things I probably will change, like perhaps
pushing it deeper from socket to sock level, but I'd like to hear about
the general feeling about at least the userspace interface.

Best Regards,

- Arnaldo

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="recvmmsg.c"

#include <stdlib.h>
#include <syscall.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <poll.h>
#include <string.h>

struct mmsghdr {
	struct msghdr	msg_hdr;
	unsigned	msg_len;
};

#if defined(__x86_64__) || defined(__i386__)
#include "linux-2.6-tip/arch/x86/include/asm/unistd.h"
#endif

static inline int recvmmsg(int fd, struct mmsghdr *mmsg,
			   unsigned vlen, unsigned flags)
{
	return syscall(__NR_recvmmsg, fd, mmsg, vlen, flags);
}

static void print_stats_peer(struct mmsghdr *datagram, int count, int bytes)
{
	char peer[1024];
	int err = getnameinfo(datagram->msg_hdr.msg_name,
			      datagram->msg_hdr.msg_namelen,
			      peer, sizeof(peer), NULL, 0, 0);
	if (err != 0) {
		fprintf(stderr, "error using getnameinfo: %s\n",
			gai_strerror(err));
			return;
		}
	printf("    %d bytes received from %s in %d datagrams\n",
	       bytes, peer, count);
}

int main(int argc, char *argv[])
{
	struct addrinfo *host;
	struct addrinfo hints = {
		.ai_family   = AF_INET,
		.ai_socktype = SOCK_DGRAM,
		.ai_protocol = IPPROTO_UDP,
		.ai_flags    = AI_PASSIVE,
	};
	const char *port = "5001";
	int batch_size = 8;
	int err, fd;
	int i;

	if (argc > 1)
		port = argv[1];

	if (argc > 2)
		batch_size = atoi(argv[2]);

	char buf[batch_size][256];
	struct iovec iovec[batch_size][1];
	struct sockaddr addr[batch_size];
	struct mmsghdr datagrams[batch_size];

	err = getaddrinfo(NULL, port, &hints, &host);
	if (err != 0) {
		fprintf(stderr, "error using getaddrinfo: %s\n",
			gai_strerror(err));
		goto out;
	}
	
	fd = socket(host->ai_family, host->ai_socktype, host->ai_protocol);
	if (fd < 0) {
		perror("socket: ");
		goto out_freeaddrinfo;
	}

	if (bind(fd, host->ai_addr, host->ai_addrlen) < 0) {
		perror("bind: ");
		goto out_close_server;
	}

	for (i = 0; i < batch_size; ++i) {
		iovec[i][0].iov_base = buf[i];
		iovec[i][0].iov_len  = sizeof(buf[i]);
		datagrams[i].msg_hdr.msg_iov	 = iovec[i];
		datagrams[i].msg_hdr.msg_iovlen	 = 1;
		datagrams[i].msg_hdr.msg_name	 = &addr[i];
		datagrams[i].msg_hdr.msg_namelen = sizeof(addr[i]);
	}

	struct pollfd pfds[1] = {
		[0] = {
			.fd = fd,
			.events = POLLIN,
		},
	};

	while (1) {
		if (poll(pfds, 1, -1) < 0) {
			perror("poll: ");
			return EXIT_FAILURE;
		}

		int nr_datagrams = recvmmsg(fd, datagrams, batch_size,
					    MSG_DONTWAIT);

		if (nr_datagrams == 0) {
			perror("recvmmsg: ");
			return EXIT_FAILURE;
		}

		printf("nr_datagrams received: %d\n", nr_datagrams);
		int peer_count = 1;
		int peer_bytes = datagrams[0].msg_len;
		for (i = 1; i < nr_datagrams; ++i) {
			if (memcmp(datagrams[i - 1].msg_hdr.msg_name,
				   datagrams[i].msg_hdr.msg_name,
				   datagrams[i].msg_hdr.msg_namelen) == 0) {
				++peer_count;
				peer_bytes += datagrams[i].msg_len;
				continue;
			}
			
			print_stats_peer(&datagrams[i - 1],
					 peer_count, peer_bytes);
			peer_bytes = datagrams[i].msg_len;
			peer_count = 1;
		}

		print_stats_peer(&datagrams[nr_datagrams - 1],
				 peer_count, peer_bytes);
	}
out_close_server:
	close(fd);
out_freeaddrinfo:
	freeaddrinfo(host);
out:
	return err;
}

--vtzGhvizbBRQ85DL--
