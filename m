From: Stephen Hemminger <shemminger@vyatta.com>
Subject: TCP MD5 connections get stuck with IPV6 mapped listener
Date: Wed, 15 Jul 2009 12:11:19 -0700
Message-ID: <20090715121119.12fc69e5@s6510>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/iqYCEl_6bPv2/dAAxd/BpD8"
Cc: netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45398 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247AbZGOTLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 15:11:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/iqYCEl_6bPv2/dAAxd/BpD8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

While investigating some TCP MD5 issues, with BGP, broke things
up into a simple test program found that
if server is listening on IPV6 for TCP with MD5 key
and client connects with IPV4 MD5 key, the connection gets stuck after
the initial SYN-SENT, SYN-ACK.

The computed value on the SYN-ACK for MD5 is incorrect, so looks like
some issue in tcp_v6_syn_recv_sock path

Note: key with IPV4mapped
IPV6 address (ie. expects incoming IPV4 client).

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
18:40:04.030651 IP localhost.2030 > localhost.2020: S 1832536952:1832536952(0) win 32792 <nop,nop,md5:can't check - c32795a5d779fd628bbb64da9e859338,mss 16396,nop,nop,sackOK,nop,wscale 6>
18:40:04.030701 IP localhost.2020 > localhost.2030: S 1841519788:1841519788(0) ack 1832536953 win 32792 <nop,nop,md5:can't check - bc0f025d8fa81bf45afe656b21fef9ca,mss 16396,nop,nop,sackOK,nop,wscale 6>
18:40:07.026693 IP localhost.2030 > localhost.2020: S 1832536952:1832536952(0) win 32792 <nop,nop,md5:can't check - c32795a5d779fd628bbb64da9e859338,mss 16396,nop,nop,sackOK,nop,wscale 6>
18:40:07.026739 IP localhost.2020 > localhost.2030: S 1841519788:1841519788(0) ack 1832536953 win 32792 <nop,nop,md5:can't check - bc0f025d8fa81bf45afe656b21fef9ca,mss 16396,nop,nop,sackOK,nop,wscale 6>
18:40:08.226682 IP localhost.2020 > localhost.2030: S 1841519788:1841519788(0) ack 1832536953 win 32792 <nop,nop,md5:can't check - bc0f025d8fa81bf45afe656b21fef9ca,mss 16396,nop,nop,sackOK,nop,wscale 6>


To reproduce:
 $ server -6 2020 127.0.0.1 2030 testkey &
 $ client -4 localhost 2020 127.0.0.1 2030 testkey


...
--MP_/iqYCEl_6bPv2/dAAxd/BpD8
Content-Type: text/x-c++src; name=client.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=client.c

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#define BUF_SIZE 500

static int local_bind(int sock, int family, const char *host,
		      unsigned short port)
{
	int s;

	if (family == AF_INET) {
		struct sockaddr_in sin = {
			.sin_family = AF_INET,
			.sin_port = htons(port),
		};

		s = inet_pton(AF_INET, host, &sin.sin_addr);
		if (s <= 0) {
			if (s == 0)
				fprintf(stderr,
					"%s: not in valid ipv4 format\n", host);
			else
				perror("inet_pton");
			exit(EXIT_FAILURE);
		}

		return bind(sock, (struct sockaddr *)&sin, sizeof(sin));
	} else if (family == AF_INET6) {
		struct sockaddr_in6 sin6 = {
			.sin6_family = AF_INET6,
			.sin6_port = htons(port),
		};

		s = inet_pton(AF_INET6, host, &sin6.sin6_addr);
		if (s <= 0) {
			if (s == 0)
				fprintf(stderr,
					"%s: not in valid ipv6 format\n", host);
			else
				perror("inet_pton");
			exit(EXIT_FAILURE);
		}

		return bind(sock, (struct sockaddr *)&sin6, sizeof(sin6));
	} else {
		fprintf(stderr, "Unknown family: %d\n", family);
	}
	return 0;
}

static void md5set(int sock, struct sockaddr *sa, socklen_t salen,
		   const char *password)
{
	struct tcp_md5sig md5sig;

	memset(&md5sig, 0, sizeof(md5sig));
	memcpy(&md5sig.tcpm_addr, sa, salen);
	memcpy(md5sig.tcpm_key, password, md5sig.tcpm_keylen =
	       strlen(password));

	if (setsockopt(sock, IPPROTO_TCP, TCP_MD5SIG, &md5sig, sizeof md5sig) <
	    0)
		perror("setsockopt (TCP_MD5SIG)");
}

static void usage(void)
{
	fprintf(stderr,
		"Usage: client [-6|-4] host port [lhost lport passwd]\n");
	exit(EXIT_FAILURE);
}


int main(int argc, char *argv[])
{
	struct addrinfo *result, *rp;
	int sfd, s;
	ssize_t nread;
	char buf[BUF_SIZE];
	struct addrinfo hints = {
		.ai_socktype = SOCK_STREAM,
	};

	if (argc > 1 && argv[1][0] == '-') {
		if (strcmp(argv[1], "-4") == 0) {
			hints.ai_family = AF_INET;
		} else if (strcmp(argv[1], "-6") == 0) {
			hints.ai_family = AF_INET6;
		} else
			usage();
		--argc, ++argv;
	}

	if (argc < 3)
		usage();

	/* Obtain address(es) matching host/port */
	s = getaddrinfo(argv[1], argv[2], &hints, &result);
	if (s != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
		exit(EXIT_FAILURE);
	}

	/* getaddrinfo() returns a list of address structures.
	   Try each address until we successfully connect(2).
	   If socket(2) (or connect(2)) fails, we (close the socket
	   and) try the next address. */

	for (rp = result; rp != NULL; rp = rp->ai_next) {
		sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (sfd == -1) {
			perror("socket");
			continue;
		}

		if (argc > 3) {
			local_bind(sfd, rp->ai_family, argv[3], atoi(argv[4]));
			md5set(sfd, rp->ai_addr, rp->ai_addrlen, argv[5]);
		}

		printf("connecting to %s..",
		       inet_ntop(rp->ai_family, rp->ai_addr, buf, sizeof(buf)));
		fflush(stdout);

		if (connect(sfd, rp->ai_addr, rp->ai_addrlen) != -1)
			break;	/* Success */

		perror("connect");
		close(sfd);
	}

	if (rp == NULL) {	/* No address succeeded */
		fprintf(stderr, "Could not connect\n");
		exit(EXIT_FAILURE);
	}

	freeaddrinfo(result);	/* No longer needed */

	printf("connected\n");
	while ((nread = read(0, buf, sizeof(buf))) > 0) {
		if (write(sfd, buf, nread) < 0)
			break;
		nread = read(sfd, buf, sizeof(buf));
		if (nread <= 0)
			break;
		if (write(1, buf, nread) != nread)
			break;
	}

	exit(EXIT_SUCCESS);
}

--MP_/iqYCEl_6bPv2/dAAxd/BpD8
Content-Type: text/x-c++src; name=server.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=server.c

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

void md5_set(int sock, int family,
	     const char *host, unsigned short port, const char *password)
{
	struct tcp_md5sig md5sig;
	int s;
	memset(&md5sig, 0, sizeof(md5sig));

	if (family == AF_INET6) {
		struct sockaddr_in6 sin6 = {
			.sin6_family = family,
			.sin6_port = htons(port),
		};

		if (strchr(host, ':') == NULL) {
			/* convert V4 address to mapped */
			sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
			s = inet_pton(AF_INET, host,
				      &sin6.sin6_addr.s6_addr32[3]);
			if (s == 0)
				fprintf(stderr, "%s: not in IPV4 format\n",
					host);
		} else {
			s = inet_pton(AF_INET6, host, &sin6.sin6_addr);
			if (s == 0)
				fprintf(stderr, "%s: not in IPV6 format\n",
					host);
		}
		memcpy(&md5sig.tcpm_addr, &sin6, sizeof(sin6));
	} else {
		struct sockaddr_in sin = {
			.sin_family = family,
			.sin_port = htons(port),
		};

		s = inet_pton(AF_INET, host, &sin.sin_addr);
		if (s == 0)
			fprintf(stderr, "%s: not in IPV4 format\n", host);
		memcpy(&md5sig.tcpm_addr, &sin, sizeof(sin));
	}

	if (s <= 0)
		exit(EXIT_FAILURE);

	memcpy(md5sig.tcpm_key, password, md5sig.tcpm_keylen =
	       strlen(password));
	if (setsockopt(sock, IPPROTO_TCP, TCP_MD5SIG, &md5sig, sizeof(md5sig)) <
	    0)
		perror("setsockopt (TCP_MD5SIG)");
}

static void usage(void)
{
	fprintf(stderr, "Usage: server port [host port passwd]\n");
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	struct addrinfo *result, *rp;
	int sfd, s, cc;
	static struct addrinfo hints = {
		.ai_family = AF_UNSPEC,
		.ai_flags = AI_PASSIVE,
		.ai_socktype = SOCK_STREAM,
	};
	char buf[BUFSIZ];

	if (argc > 1 && argv[1][0] == '-') {
		if (strcmp(argv[1], "-4") == 0) {
			hints.ai_family = AF_INET;
		} else if (strcmp(argv[1], "-6") == 0) {
			hints.ai_family = AF_INET6;
		} else
			usage();
		--argc, ++argv;
	}
	if (argc < 2)
		usage();

	s = getaddrinfo(NULL, argv[1], &hints, &result);
	if (s != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
		exit(EXIT_FAILURE);
	}

	for (rp = result; rp != NULL; rp = rp->ai_next) {
		sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (sfd == -1) {
			perror("socket");
			continue;
		}

		if (bind(sfd, rp->ai_addr, rp->ai_addrlen) == 0)
			break;	/* Success */

		perror("bind");
		close(sfd);
	}

	if (rp == NULL) {	/* No address succeeded */
		fprintf(stderr, "Could not bind\n");
		exit(EXIT_FAILURE);
	}
	if (listen(sfd, 5) < 0)
		perror("listen");

	if (argc > 2)
		md5_set(sfd, rp->ai_family, argv[2], atoi(argv[3]), argv[4]);
	freeaddrinfo(result);	/* No longer needed */

	for (;;) {
		struct sockaddr_storage peer_addr;
		socklen_t peer_addr_len = sizeof(peer_addr);
		char host[NI_MAXHOST], service[NI_MAXSERV];

		int afd =
		    accept(sfd, (struct sockaddr *)&peer_addr, &peer_addr_len);
		if (afd < 0) {
			perror("accept");
			return 1;
		}

		s = getnameinfo((struct sockaddr *)&peer_addr,
				peer_addr_len, host, NI_MAXHOST,
				service, NI_MAXSERV, NI_NUMERICSERV);
		if (s == 0)
			printf("Connect from %s:%s\n", host, service);
		else
			fprintf(stderr, "getnameinfo: %s\n", gai_strerror(s));

		if (fork() == 0) {
			close(sfd);
			while ((cc = read(afd, buf, sizeof(buf))) > 0)
				if (write(afd, buf, cc) != cc)
					break;
			if (cc < 0)
				perror("read");
			else
				printf("eof\n");
			exit(0);
		}
		close(afd);
	}
}

--MP_/iqYCEl_6bPv2/dAAxd/BpD8--
