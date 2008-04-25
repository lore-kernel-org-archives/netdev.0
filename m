From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Fri, 25 Apr 2008 14:52:30 +0200
Message-ID: <20080425125230.GA12343@alice>
References: <20080424142727.GA24025@alice> <20080424211320.GA13695@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34580 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754740AbYDYMwg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 08:52:36 -0400
Content-Disposition: inline
In-Reply-To: <20080424211320.GA13695@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Hi.
>=20
> On Thu, Apr 24, 2008 at 04:27:27PM +0200, Eric Sesterhenn (snakebyte@=
gmx.de) wrote:
> > i found some local ivp6 network fuzzing tools from the bsd folks
> > today and wanted to add them to my testmachine. When
> > trying one of them (running with user privs) it gave me slab corrup=
tion errors.
> > Running http://clem1.be/lf6/tcp6fuzz.c 1 to 5 times
> > always results in errors, strangely using the same seed twice
> > in a row doesnt trigger the warnings again.
> >=20
> > If there is any more info i can provide please let me know.
>=20
> $ wget http://clem1.be/lf6/tcp6fuzz.c
> --01:09:26--  http://clem1.be/lf6/tcp6fuzz.c
>            =3D> `tcp6fuzz.c'
>  Resolving clem1.be... 88.169.180.107
>  Connecting to clem1.be|88.169.180.107|:80... failed: Connection refu=
sed.
>=20
> Please post your source here (google can not find it either), if it i=
s
> that easily reproducible, you can be sure, bug will be fixed in a few
> moments.
>=20
> > [   57.810370] sock_set_timeout: `tcp6fuzz' (pid 3721) tries to set=
 negative timeout
> > [  215.102729] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [  215.102786] BUG skbuff_head_cache: Invalid object pointer 0xccd2=
b520
> > [  215.102810] ----------------------------------------------------=
-------------------------
> > [  215.102816]=20
> > [  215.102840] INFO: Slab 0xc119c560 used=3D10 fp=3D0x00000000 flag=
s=3D0x40000083
> > [  215.102868] Pid: 0, comm: swapper Not tainted 2.6.25-03562-g3dc5=
063 #23
> > [  215.102880]  [<c0177b57>] slab_err+0x47/0x50
> > [  215.102978]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
> > [  215.102994]  [<c0177c92>] ? check_slab+0x52/0x80
> > [  215.103010]  [<c0179405>] __slab_free+0x1d5/0x2d0
> > [  215.103024]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
> > [  215.103039]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
> > [  215.103063]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
> > [  215.103078]  [<c05d91dc>] __kfree_skb+0x3c/0x90
> > [  215.103090]  [<c05d9249>] kfree_skb+0x19/0x30
> > [  215.103103]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
>=20
> So far can you run kernel with debug turned on and provide output of
> gdb ./vmlinux
> l *(tcp_v6_do_rcv+0x33b)

l *(tcp_v6_do_rcv+0x33b)
Using host libthread_db library "/lib/tls/i686/cmov/libthread_db.so.1".
(gdb) l *(tcp_v6_do_rcv+0x33b)
0xc0671e3b is in tcp_v6_do_rcv (net/ipv6/tcp_ipv6.c:1670).
1665    reset:
1666            tcp_v6_send_reset(sk, skb);
1667    discard:
1668            if (opt_skb)
1669                    __kfree_skb(opt_skb);
1670            kfree_skb(skb);
1671            return 0;
1672    csum_err:
1673            TCP_INC_STATS_BH(TCP_MIB_INERRS);
1674            goto discard;


Here is the programm itself...

Greetings, Eric

=20
/*
 * TCP/IPV6 socket fuzzer.
 *
 * Copyright (C) 2006, Cl=C3=A9ment Lecigne
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <sys/uio.h>

void usage(char *);
void randsoopt(int);
void fs(char *, size_t);
void fc(uint32_t, uint32_t, uint32_t, size_t, char *);
unsigned int randaddr(void);

/*
 * boucle until we hit a valid socket option
 */
void randsoopt(int sock)
{
	unsigned int optval;
	int optlen, optname, level, ret, on =3D rand() % 2;

	do
	{
		switch (rand() % 4)
		{
			case 0:
				level =3D IPPROTO_IPV6;
				break;
			case 1:
				level =3D SOL_SOCKET;
				break;
			case 2:
				level =3D IPPROTO_TCP;
				break;
			case 3:
				level =3D rand() & 0xFF;
				break;
		}
	=09
		if (rand() % 8)
		{
			optlen =3D rand() & 0xffff;
			optval =3D randaddr();
		}
		else
		{
		/*=20
			* In some cases, kernel excepts that
			* optlen =3D=3D sizeof (int) and that's
			* the first bound checking.
			*/
			optlen =3D sizeof (int);
			optval =3D (unsigned int)&on;
		}
	=09
		if (rand() % 8)
			optname =3D rand() % 80;
		else
			optname =3D rand();
#if 0
		/*
		* anti well know mbufs exhaustion. (FreeBSD)
		*/
		if (optname =3D=3D 25 || optname =3D=3D IPV6_IPSEC_POLICY ||=20
				optname =3D=3D IPV6_FW_ADD || optname =3D=3D IPV6_FW_FLUSH
				|| optname =3D=3D IPV6_FW_DEL || optname =3D=3D IPV6_FW_ZERO)
			continue;
#endif

		ret =3D setsockopt(sock, level, optname, (void *)optval, optlen);
	}while(ret =3D=3D -1);
}

/*
* server fuzzage.
*/
void fs(char *port, size_t ms)
{
	int so, ac, one =3D 1;
	struct addrinfo *res, hints;
	struct sockaddr_in6 from;
	socklen_t fromlen;
	char *buf;

	struct msghdr m;
	struct cmsghdr *c =3D NULL;
	struct iovec io;

=09
	buf =3D malloc(ms);
	if (buf =3D=3D NULL)
	{
		perror(" - malloc");
		return;
	}

	fromlen =3D sizeof from;
=09
	memset(&hints, 0, sizeof hints);
	hints.ai_family =3D AF_INET6;
	hints.ai_socktype =3D SOCK_STREAM;
	hints.ai_protocol =3D IPPROTO_TCP;

	getaddrinfo("::1", port, &hints, &res);

	m.msg_name =3D res->ai_addr;
	m.msg_namelen =3D res->ai_addrlen;
	m.msg_iov =3D &io;

	so =3D socket(res->ai_family, res->ai_socktype, res->ai_protocol);
	if (so =3D=3D -1){
		perror("sock");
		exit(EXIT_FAILURE);
	}
=09
	randsoopt(so);

	if (bind(so, res->ai_addr, res->ai_addrlen) < 0){
		perror("bind");
		exit(EXIT_FAILURE);
	}
=09
	if (listen(so, 0) < 0){
		perror("listen");
		exit(EXIT_FAILURE);
	}
	=09
	while(1)
	{
		randsoopt(so);
		ac =3D accept(so, (struct sockaddr *)&from, &fromlen);
		if (ac =3D=3D -1){
			perror("accept");
			continue;	/* warn but continue */
		}
	=09
		randsoopt(ac);

		/* make ac non-blockant */
		ioctl(ac, FIONBIO, &one);

		/* different receiving ways */
		switch(rand() % 3)
		{
			case 0: /* basic read */
				read(ac, buf, rand() % ms);
				break;
			case 1: /* recvfrom */
				recvfrom(ac, buf, rand() % ms, 0,=20
						(struct sockaddr *)&from, &fromlen);
				break;
			case 2: /* recvmsg */
				m.msg_iovlen =3D (rand() % 2) ? rand() : 1;
				m.msg_controllen =3D (rand() % 2) ? CMSG_LEN(rand() % ms) : 0;
				if (m.msg_controllen)
				{
					c =3D (struct cmsghdr *)malloc(m.msg_controllen);
					m.msg_control =3D c;
					c->cmsg_level =3D (rand() % 2) ? IPPROTO_IPV6 : rand();
					c->cmsg_type =3D (rand() % 2) ? rand() % 255 : rand();
					c->cmsg_len =3D (rand() % 2) ? m.msg_controllen : rand();

				}
				else
				{
					m.msg_control =3D (rand() % 5) ? NULL : (void*)randaddr();
				}
				m.msg_flags =3D rand();
				io.iov_len =3D (rand() % 2) ? rand() : rand() % ms;
				recvmsg(ac, &m, (rand() % 2) ? 0 : rand());
				break;
		}
		close(ac);=20
	}
	free(buf);
	freeaddrinfo(res);
}                                 =20
			=09
/*
* client fuzzage.
*/
void fc(uint32_t count, uint32_t occ, uint32_t opts, size_t ms, char *p=
ort)
{
	int so, j, cc, one =3D 1;
	uint32_t try;
	u_int32_t i, a;
	struct addrinfo *res, hints;
	char *buf;

	struct msghdr m;
	struct cmsghdr *c =3D NULL;
	struct iovec io;

	/* XXX: wait server */
	usleep(500);

	buf =3D malloc(ms);
	if (buf =3D=3D NULL)
	{
		perror(" - malloc");
		return;
	}

	signal(SIGPIPE, SIG_IGN);
=09
	memset(&hints, 0, sizeof(hints));
	hints.ai_family =3D AF_INET6;
	hints.ai_socktype =3D SOCK_STREAM;
	hints.ai_protocol =3D IPPROTO_TCP;
	getaddrinfo("::1", port, &hints, &res);

	m.msg_name =3D res->ai_addr;
	m.msg_namelen =3D res->ai_addrlen;
	m.msg_iov =3D &io;

	for (i =3D 0; i < occ; i++)
	{
		printf("%d\n", i);
		try =3D 0;
		do{
			so =3D socket(res->ai_family, res->ai_socktype, res->ai_protocol);
			try++;
		}while(so =3D=3D -1 && count !=3D try);
	=09
		/* make socket non-blockant */
		ioctl(so, FIONBIO, &one);
	=09
		try =3D 0;
		do{
			cc =3D connect(so, res->ai_addr, res->ai_addrlen);
			try++;
		}while(cc =3D=3D -1 && count !=3D try);

		randsoopt(so);=20

		for (a =3D 0; a < opts; a++)
		{
			try =3D 0;
			do
			{
				switch(rand() % 3)
				{
				case 0:=20
					cc =3D write(so, buf, rand() % ms);
					break;
				case 1:
					cc =3D sendto(so, buf, rand() % ms, MSG_DONTWAIT,
							(struct sockaddr *)&res->ai_addr, res->ai_addrlen);
					break;
				case 2:
					m.msg_iovlen =3D (rand() % 2) ? rand() : 1;
					m.msg_controllen =3D (rand() % 2) ? CMSG_LEN(rand() % ms) : 0;
					m.msg_flags =3D MSG_DONTWAIT;
					if (m.msg_controllen)
					{
						c =3D (struct cmsghdr *)malloc(m.msg_controllen);
						m.msg_control =3D c;
						c->cmsg_level =3D (rand() % 2) ? IPPROTO_IPV6 : rand();
						c->cmsg_type =3D (rand() % 2) ? rand() % 255 : rand();
						c->cmsg_len =3D (rand() % 2) ? m.msg_controllen : rand();
					}
					else
					{
						m.msg_control =3D (rand() % 5) ? NULL : (void*)randaddr();
						m.msg_controllen =3D (rand() % 2) ? rand() : 0;
					}                   =20
					io.iov_len =3D (rand() % 2) ? rand() : rand() % ms;
					cc =3D sendmsg (so, &m, MSG_DONTWAIT);
				}
				if (c !=3D NULL)
				{
					free(c);
					c =3D NULL;
				}
				try++;
			}while(cc =3D=3D -1 && count !=3D try);
		}
		close(so);
	}
	free(buf);
	freeaddrinfo(res);
	return;
}

/*
* return a random address
*/
unsigned int randaddr(void)
{
	int stack;
	char *p =3D malloc(1);
	unsigned int heap =3D (unsigned int)p;
	free(p);
	switch (rand() % 4)
	{
		case 0:
			return (heap + (rand() & 0xFFF));
		case 1:
			return ((unsigned int)&stack + (rand() & 0xFFF));
		case 2:
			return (0xc0000000 + (rand() & 0xFFFF));
		case 3:
			return (rand());
	}
	return (0);
}
					=09
/*=20
* usage
*/
void usage(char *prog)
{
	printf("usage: %s [-r seed] [-c sendto-timeout] [-m maxsize]\n"
		"          [-o maxsetsockopt] [-n occ] [-p tcp-port]\n", prog);
	exit(1);
}

int main(int ac, char **av)
{
	int32_t occ, count, opts;
	u_int32_t seed;
	size_t maxsize;
	char c;
	pid_t pid;
	char *port =3D "5000";
=09
	/* default values */
	seed =3D getpid();
	count =3D 50;
	occ =3D 100;
	maxsize =3D 4096;
	opts =3D 10;
=09
	while ((c =3D getopt(ac, av, "r:n:c:p:m:o:")) !=3D EOF)
	{
		switch (c)
		{
			case 'r':
				seed =3D atoi(optarg);
				break;
			case 'n':
				occ =3D atoi(optarg);
				break;
			case 'c':
				count =3D atoi(optarg);
				break;
			case 'p':
				port =3D optarg;
				break;
			case 'm':
				maxsize =3D atoi(optarg);
				break;
			case 'o':
				opts =3D atoi(optarg);
				break;
			default:
				usage(av[0]);
				break;
		}
	}

	printf(" + using seed : %d\n", seed);
	srand(seed);

	puts(" + forking.");

	pid =3D fork();
	switch (pid)
	{
		case -1:
			perror(" - fork");
			exit(EXIT_FAILURE);
		case 0:
			/* client fuzzer */
			fs(port, maxsize);
			break;
		default:
			/* server */
			fc(count, occ, opts, maxsize, port);
			break;
	}

	/* client finished, kill the serv */
	kill(pid, SIGKILL);
=09
	puts(" + fuzzing finished, your kernel is alive.");
	exit(EXIT_SUCCESS);
}
