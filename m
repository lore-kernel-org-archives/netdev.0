From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: fix premature termination of FIN_WAIT2 time-wait sockets
Date: Mon, 24 Aug 2009 23:47:05 +0300
Message-ID: <200908242347.05367.opurdila@ixiacom.com>
References: <200908150339.12730.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_JxvkKNihaMXYXIz"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11591 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753252AbZHXUtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 16:49:22 -0400
In-Reply-To: <200908150339.12730.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_JxvkKNihaMXYXIz
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit

On Saturday 15 August 2009 03:39:12 Octavian Purdila wrote:

> NOTE: this issue has been found, fixed and tested on an ancient 2.6.7
> kernel. This patch is a blind port of that fix, since unfortunately there
> is no easy way for me to reproduce the original issue with a newer kernel.
> But the issue still seems to be there.

Update: I was able to reproduce the issue on a 2.6.30 debian kernel with the 
attached test. It took me about 10 runs of 2-5 mins each to reproduce it 
(multiple runs to keep the capture file reasonable in terms of size).

tavi

--Boundary-00=_JxvkKNihaMXYXIz
Content-Type: text/x-csrc;
  charset="UTF-8";
  name="finwait2.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="finwait2.c"

#define _GNU_SOURCE
#include <sys/syscall.h>
#include <sched.h>
#include <stdlib.h>
#include <string.h>
#include <error.h>
#include <argp.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <sys/fcntl.h>
#include <sys/wait.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <net/if.h>
#include <signal.h>
#include <sys/socket.h>
#include <netpacket/packet.h>
#include <assert.h>
#include <netinet/tcp.h>
#include <linux/unistd.h>

static char doc[] = "";
static char args_doc[] = "";
static struct argp_option options[] = {
	{"server", 's', "host", 0, "server address"},
	{"port", 'p', "int", 0, "port to connect"},
	{"connections", 'c', "int", 0, "how many connections to open"},
	{0},
};

struct cl_args {
	unsigned short port, connections;
	uint32_t server;
};

struct cl_args cla = {
	.port=5555, 
	.connections=2500,
};


static error_t parse_opt(int key, char *arg, struct argp_state *state)
{
	struct cl_args *cla = state->input;
	switch (key) {
	case 's':
	{
		struct hostent *hostinfo =gethostbyname(arg);
		if (!hostinfo) {
			fprintf(stderr, "unknown host %s\n", arg);
			return -1;
		}
		cla->server=ntohl(((struct in_addr*)hostinfo->h_addr)->s_addr);
		break;
	}
	case 'p':
	{
		int port = atoi(arg);
		if (port <=0 || port > 65535) {
			fprintf(stderr, "invalid port: %d\n", cla->port);
			return -1;
		}
		cla->port=port;
		break;
	}
	case 'c':
	{
		cla->connections=atoi(arg);
		break;
	}
	case ARGP_KEY_ARG:
		break;
	default:
		return ARGP_ERR_UNKNOWN;
	}
	return 0;
}
static struct argp argp = { options, parse_opt, args_doc, doc };

static inline int is_client(void)
{
	if (cla.server != INADDR_ANY)
		return 1;
	return 0;
}

#define FAIL(x) \
	do {								\
		if (x) {						\
			fprintf(stderr, "%s:%d: error: %s\n", __func__, __LINE__, \
				strerror(errno));			\
			exit(1);					\
		}							\
	} while (0)

static void run_client(void)
{
	int i, socks[cla.connections];
	struct sockaddr_in name = {
		.sin_port = htons (cla.port),
		.sin_addr = { htonl(cla.server) },
		.sin_family = AF_INET
	};

	for(i=0; i < cla.connections; i++) {
		FAIL((socks[i] = socket(PF_INET, SOCK_STREAM, 0)) < 0);
		FAIL(connect(socks[i], (struct sockaddr*)&name, sizeof(name)) < 0);
	}

	/* wait server to close */
	sleep(1);

	for(i=0; i < cla.connections; i++)
		close(socks[i]);
}

static void run_server(int lsock)
{
	int i, socks[cla.connections];

	for(i = 0; i < cla.connections; i++)
		FAIL((socks[i] = accept(lsock, NULL, NULL)) < 0);

	for(i = 0; i < cla.connections; i++)
		close(socks[i]);

	sleep(1);
}

int main(int argc, char **argv)
{
	int lsock;

	if (argp_parse(&argp, argc, argv, 0, 0, &cla) < 0)
		return -1;

	FAIL(system("echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse") != 0);

	setpriority(PRIO_PROCESS, getpid(), -20);

	while (1) {
		static int count;
		if (is_client())
			run_client();
		else {
			if (!count) {
				struct sockaddr_in name = {
					.sin_port = htons (cla.port),
					.sin_family = AF_INET
				};
				
				FAIL((lsock = socket(PF_INET, SOCK_STREAM, 0)) < 0);
				FAIL(bind(lsock, (struct sockaddr *) &name, sizeof (name)) < 0);
				FAIL(listen(lsock, cla.connections) < 0);
			}
			run_server(lsock);
		}
		printf("iteration %d\n", ++count);
	}
	
	return 0;
}

--Boundary-00=_JxvkKNihaMXYXIz--
