From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive
 connections
Date: Mon, 04 May 2015 06:53:19 -0700
Message-ID: <1430747599.3711.170.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	 <20150501201417.GB6113@akamai.com>
	 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150501202908.GC6113@akamai.com>
	 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgNAkiUOkjsE96E1DN_zwJAjJGLWME7-XGnFDszic7p7C=g7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkiUOkjsE96E1DN_zwJAjJGLWME7-XGnFDszic7p7C=g7g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-04 at 08:47 +0200, Michael Kerrisk (man-pages) wrote:
> Eric,
> 
> On 4 May 2015 at 06:34, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >
> > This patch allows a server application to get the TCP SYN headers for
> > its passive connections.  This is useful if the server is doing
> > fingerprinting of clients based on SYN packet contents.
> >
> > Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.
> >
> > The first is used on a socket to enable saving the SYN headers
> > for child connections. This can be set before or after the listen()
> > call.
> >
> > The latter is used to retrieve the SYN headers for passive connections,
> > if the parent listener has enabled TCP_SAVE_SYN.
> >
> > TCP_SAVED_SYN is read once, it frees the saved SYN headers.
> >
> > The data returned in TCP_SAVED_SYN are network (IPv4/IPv6) and TCP
> > headers.
> 
> This description is a little thin, so I'm unclear on one or two
> points. TCP_SAVE_SYN is clearly applied to the listening socket. But
> what about TCP_SAVED_SYN? Is that applied to the connected socket
> returned by accept()?
> 
> The highly similar naming of these two seems unfortunate. At the very
> least, it makes for easy confusion in conversations about the two
> options. It would be better to have names that were more distinct.
> Perhaps the latter could be TCP_CONN_SYN or TCP_CONN_SAVED_SYN, for
> example?
> 
> Thanks,


TCP_CONN_SYN is rather confusing, because of the analogy with connect().

Maybe I can send the test Neal wrote 3 years ago, part of our automated
non regression tests we run here.

Let me know if you need more information, thanks !

/*
 * Copyright 2012 Google Inc. All Rights Reserved.
 * Author: ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org (Neal Cardwell)
 *
 * A basic test for the TCP_SAVE_SYN and TCP_SAVED_SYN socket options.
 */

#include <assert.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

#ifndef TCP_SAVE_SYN
#define TCP_SAVE_SYN    27
#endif

#ifndef TCP_SAVED_SYN
#define TCP_SAVED_SYN   28
#endif

typedef char bool;
typedef enum bool_t {
	false = 0,
	true = 1,
} bool_t;

static void fail(const char *msg)
{
	fprintf(stderr, "%s\n", msg);
	exit(1);
}

static void fail_perror(const char *msg)
{
	perror(msg);
	exit(1);
}

/*
 * Once every ~5000 connections, connect fails with ENOBUFS. This is
 * not even in the manpage, and seem to be transient. For now, just retry.
 */
static void connect_reliably(int fd, struct sockaddr *daddr, int dlen)
{
	int ret, max_runs = 5;

	do {
		ret = connect(fd, daddr, dlen);
	} while (ret == -1 && errno == ENOBUFS && --max_runs);

	if (ret)
		fail_perror("reliable connect");
}

/* Get and validate the saved SYN. */
static void read_saved_syn(int fd, int address_family)
{
	unsigned char syn[500];
	socklen_t syn_len = sizeof(syn);

	memset(syn, 0, sizeof(syn));

	/* Read the saved SYN. */
	if (getsockopt(fd, IPPROTO_TCP, TCP_SAVED_SYN, syn, &syn_len) != 0)
		fail_perror("first getsockopt TCP_SAVED_SYN failed");

	/* Check the length and first byte of the SYN. */
	if (address_family == AF_INET) {
		assert(syn_len == 60);
		assert(syn[0] >> 4 == 0x4);	/* IPv4 */
	} else if (address_family == AF_INET6) {
		assert(syn_len == 80);
		assert(syn[0] >> 4 == 0x6);	/* IPv6 */
	} else {
		assert(!"bad address family");
	}

	/* Check the last few bytes of the SYN, which will be TCP options. */
	assert(syn[syn_len-4] == 0x01);  /* TCP option: kind = NOP */
	assert(syn[syn_len-3] == 0x03);  /* TCP option: kind = window scale */
	assert(syn[syn_len-2] == 0x03);  /* TCP option: length = 3 */
	assert(syn[syn_len-1] == 0x06 || syn[syn_len-1] == 0x07);  /* TCP option: window scale = 6 or 7 */

	/* If we try TCP_SAVED_SYN again it should succeed with 0 length. */
	if (getsockopt(fd, IPPROTO_TCP, TCP_SAVED_SYN, syn, &syn_len) != 0)
		fail("repeated getsockopt TCP_SAVED_SYN failed");
	assert(syn_len == 0);
}

/* Open server and client socket and test TCP_SAVE_SYN and TCP_SAVED_SYN. */
static void do_test(struct sockaddr *srv_addr, uint16_t *srv_port, int srv_len,
		    struct sockaddr *cli_addr, uint16_t *cli_port, int cli_len,
		    bool get_saved_syn)
{
	int fd_listen = -1, fd_accept = -1, fd_connect = -1;
	int one = 1;

	fd_listen = socket(srv_addr->sa_family, SOCK_STREAM, 0);
	if (fd_listen == -1)
		fail_perror("open fd_listen");

	if (setsockopt(fd_listen, SOL_SOCKET, SO_REUSEADDR,
		       &one, sizeof(one)) < 0)
		fail_perror("setsockopt SO_REUSEADDR");

	if (bind(fd_listen, srv_addr, srv_len))
		fail_perror("bind fd_listen");

	if (getsockname(fd_listen, srv_addr, (socklen_t *)&srv_len))
		fail_perror("getsockname fd_listen");

	*cli_port = *srv_port;

	if (setsockopt(fd_listen, IPPROTO_TCP, TCP_SAVE_SYN,
		       &one, sizeof(one)) < 0)
		fail_perror("setsockopt TCP_SAVE_SYN");

	if (listen(fd_listen, 1))
		fail_perror("listen fd_listen");

	fd_connect = socket(cli_addr->sa_family, SOCK_STREAM, 0);
	if (fd_connect == -1)
		fail_perror("open fd_connect");

	connect_reliably(fd_connect, cli_addr, cli_len);

	fd_accept = accept(fd_listen, NULL, 0);
	if (fd_accept == -1)
		fail_perror("accept fd_listen");

	if (get_saved_syn) {
		read_saved_syn(fd_accept, cli_addr->sa_family);
	}

	if (close(fd_listen))
		fail_perror("close fd_listen");

	if (close(fd_accept))
		fail_perror("close fd_accept");

	if (close(fd_connect))
		fail_perror("close fd_connect");
}


static void test_ipv4(bool get_saved_syn)
{
	struct sockaddr_in srv_addr = {
		.sin_family		= AF_INET,
		.sin_addr.s_addr	= INADDR_ANY,
		.sin_port		= 0,
	};
	struct sockaddr_in cli_addr = {
		.sin_family		= AF_INET,
		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
	};

	printf("   testing IPv4 ...\n");
	do_test((struct sockaddr *)&srv_addr, &srv_addr.sin_port,
		sizeof(srv_addr),
		(struct sockaddr *)&cli_addr, &cli_addr.sin_port,
		sizeof(cli_addr),
		get_saved_syn);
}

static void test_ipv6(bool get_saved_syn)
{
	struct sockaddr_in6 srv_addr = {
		.sin6_family		= AF_INET6,
		.sin6_addr		= IN6ADDR_ANY_INIT,
		.sin6_port		= 0,
	};
	struct sockaddr_in6 cli_addr = {
		.sin6_family		= AF_INET6,
		.sin6_addr		= IN6ADDR_LOOPBACK_INIT,
	};

	printf("   testing IPv6 ...\n");
	do_test((struct sockaddr *)&srv_addr, &srv_addr.sin6_port,
		sizeof(srv_addr),
		(struct sockaddr *)&cli_addr, &cli_addr.sin6_port,
		sizeof(cli_addr),
		get_saved_syn);
}

static void test_ipv4_mapped_ipv6(bool get_saved_syn)
{
	struct sockaddr_in6 srv_addr = {
		.sin6_family		= AF_INET6,
		.sin6_addr		= IN6ADDR_ANY_INIT,
		.sin6_port		= 0,
	};
	struct sockaddr_in cli_addr = {
		.sin_family		= AF_INET,
		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
	};

	printf("   testing IPv4-mapped-IPv6 (srv=AF_INET6, cli=AF_INET)...\n");
	do_test((struct sockaddr *)&srv_addr, &srv_addr.sin6_port,
		sizeof(srv_addr),
		(struct sockaddr *)&cli_addr, &cli_addr.sin_port,
		sizeof(cli_addr),
		get_saved_syn);
}

static void test_all_address_families(bool get_saved_syn)
{
	test_ipv4(get_saved_syn);
	test_ipv6(get_saved_syn);
	test_ipv4_mapped_ipv6(get_saved_syn);
}

static void run_all_tests(void)
{
	bool get_saved_syn;

	/* Test normal behavior, when we ask the kernel to record the
	 * SYN and then read it using the TCP_SAVED_SYN getsockopt().
	 */
	printf("test: reading the saved SYN...\n");
	get_saved_syn = true;
	test_all_address_families(get_saved_syn);

	/* Test behavior when we ask the kernel to record the SYN and
	 * then never actually use the TCP_SAVED_SYN getsockopt() to
	 * extract the saved SYN.
	 */
	printf("test: not reading the saved SYN...\n");
	get_saved_syn = false;
	test_all_address_families(get_saved_syn);
}

static int usage(const char *executable_path)
{
	fprintf(stderr, "usage: %s\n", executable_path);
	return 1;
}

int main(int argc, char **argv)
{
	if (getuid() != 0 || getgid() != 0)
		fail("must run as root\n");

	if (argc != 1)
		return usage(argv[0]);

	system("sysctl net.ipv4.tcp_timestamps=1");
	system("sysctl net.ipv4.tcp_sack=1");
	system("sysctl net.ipv4.tcp_window_scaling=1");

	run_all_tests();

	printf("OK. All tests passed.\n");
	return 0;
}
