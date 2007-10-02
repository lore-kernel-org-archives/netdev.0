From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Mon, 1 Oct 2007 21:23:00 -0700
Message-ID: <20071002042300.GC5480@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org> <20071002022059.GE7037@bitmover.com> <20071001.205050.66151815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Cc: lm@bitmover.com, torvalds@linux-foundation.org,
	wscott@bitmover.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:42461 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750766AbXJBEXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 00:23:00 -0400
Content-Disposition: inline
In-Reply-To: <20071001.205050.66151815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 01, 2007 at 08:50:50PM -0700, David Miller wrote:
> From: lm@bitmover.com (Larry McVoy)
> Date: Mon, 1 Oct 2007 19:20:59 -0700
> 
> > A short summary is "can someone please post a test program that sources
> > and sinks data at the wire speed?"  because apparently I'm too old and
> > clueless to write such a thing.
> 
> You're not showing us your test program so there is no way we
> can help you out.

Attached.  Drop it into an lmbench tree and build it.

> My initial inclination, even without that critical information,
> is to ask whether you are setting any socket options in way?

The only one I was playing with was SO_RCVBUF/SO_SNDBUF and I tried
disabling that and I tried playing with the read/write size.  Didn't
help.

> In particular, SO_RCVLOWAT can have a large effect here, if you're
> setting it to something, that would explain why dd is doing better.  A
> lot of people link to "helper libraries" with interfaces to setup
> sockets with all sorts of socket option settings by default, try not
> using such things if possible.

Agreed.  That was my first thought as well, I must have been doing 
something that messed up the defaults.  But you did get the strace
output, there wasn't anything weird there.

> You also shouldn't dork at all with the receive and send buffer sizes.
> They are adjusted dynamically by the kernel as the window grows.  But
> if you set them to specific values, this dynamic logic is turned off.

Yeah, dorking with those is left over from the bad old days of '95
when lmbench was first shipped.  But I turned that all off and no
difference.

So feel free to show me where I'm an idiot in the code, but if you
can't, then what would rock would be a little send.c / recv.c that
demonstrated filling the pipe.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com

--yrj/dFKFPuw6o+aM
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="bytes_tcp.c"

/*
 * bytes_tcp.c - simple TCP bandwidth source/sink
 *
 *	server usage:	bytes_tcp -s
 *	client usage:	bytes_tcp hostname [msgsize]
 *
 * Copyright (c) 1994 Larry McVoy.  
 * Copyright (c) 2002 Carl Staelin.  Distributed under the FSF GPL with
 * additional restriction that results may published only if
 * (1) the benchmark is unmodified, and
 * (2) the version in the sccsid below is included in the report.
 * Support for this development by Sun Microsystems is gratefully acknowledged.
 */
char	*id = "$Id$\n";
#include "bench.h"
#define	XFER	(1024*1024)

int	server_main(int ac, char **av);
int	client_main(int ac, char **av);
void	source(int data);

void
transfer(int get, int server, char *buf)
{
	int	c;

	while ((get > 0) && (c = read(server, buf, XFER)) > 0) {
		get -= c;
	}
	if (c < 0) {
		perror("bytes_tcp: transfer: read failed");
		exit(4);
	}
}

/* ARGSUSED */
int
client_main(int ac, char **av)
{
	int	server;
	int	get = 256 << 20;
	char	buf[XFER];
	char*	usage = "usage: %s -remotehost OR %s remotehost [msgsize]\n";

	if (ac != 2 && ac != 3) {
		(void)fprintf(stderr, usage, av[0], av[0]);
		exit(0);
	}
	if (ac == 3) get = bytes(av[2]);
	server = tcp_connect(av[1], TCP_DATA+1, SOCKOPT_READ|SOCKOPT_REUSE);
	if (server < 0) {
		perror("bytes_tcp: could not open socket to server");
		exit(2);
	}
	transfer(get, server, buf);
	close(server);
	exit(0);
	/*NOTREACHED*/
}

void
child()
{
	wait(0);
	signal(SIGCHLD, child);
}

/* ARGSUSED */
int
server_main(int ac, char **av)
{
	int	data, newdata;

	signal(SIGCHLD, child);
	data = tcp_server(TCP_DATA+1, SOCKOPT_READ|SOCKOPT_WRITE|SOCKOPT_REUSE);
	for ( ;; ) {
		newdata = tcp_accept(data, SOCKOPT_WRITE|SOCKOPT_READ);
		switch (fork()) {
		    case -1:
			perror("fork");
			break;
		    case 0:
			source(newdata);
			exit(0);
		    default:
			close(newdata);
			break;
		}
	}
}

void
source(int data)
{
	char	buf[XFER];

	while (write(data, buf, sizeof(buf)) > 0);
}


int
main(int ac, char **av)
{
	char*	usage = "Usage: %s -s OR %s -serverhost OR %s serverhost [msgsize]\n";
	if (ac < 2 || 3 < ac) {
		fprintf(stderr, usage, av[0], av[0], av[0]);
		exit(1);
	}
	if (ac == 2 && !strcmp(av[1], "-s")) {
		if (fork() == 0) server_main(ac, av);
		exit(0);
	} else {
		client_main(ac, av);
	}
	return(0);
}

--yrj/dFKFPuw6o+aM
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="lib_tcp.c"

/*
 * tcp_lib.c - routines for managing TCP connections.
 *
 * Positive port/program numbers are RPC ports, negative ones are TCP ports.
 *
 * Copyright (c) 1994-1996 Larry McVoy.
 */
#define		_LIB /* bench.h needs this */
#include	"bench.h"

/*
 * Get a TCP socket, bind it, figure out the port,
 * and advertise the port as program "prog".
 *
 * XXX - it would be nice if you could advertise ascii strings.
 */
int
tcp_server(int prog, int rdwr)
{
	int	sock;
	struct	sockaddr_in s;

#ifdef	LIBTCP_VERBOSE
	fprintf(stderr, "tcp_server(%u, %u)\n", prog, rdwr);
#endif
	if ((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
		perror("socket");
		exit(1);
	}
	sock_optimize(sock, rdwr);
	bzero((void*)&s, sizeof(s));
	s.sin_family = AF_INET;
	if (prog < 0) {
		s.sin_port = htons(-prog);
	}
	if (bind(sock, (struct sockaddr*)&s, sizeof(s)) < 0) {
		perror("bind");
		exit(2);
	}
	if (listen(sock, 100) < 0) {
		perror("listen");
		exit(4);
	}
	if (prog > 0) {
#ifdef	LIBTCP_VERBOSE
		fprintf(stderr, "Server port %d\n", sockport(sock));
#endif
		(void)pmap_unset((u_long)prog, (u_long)1);
		if (!pmap_set((u_long)prog, (u_long)1, (u_long)IPPROTO_TCP,
		    (unsigned short)sockport(sock))) {
			perror("pmap_set");
			exit(5);
		}
	}
	return (sock);
}

/*
 * Unadvertise the socket
 */
int
tcp_done(int prog)
{
	if (prog > 0) {
		pmap_unset((u_long)prog, (u_long)1);
	}
	return (0);
}

/*
 * Accept a connection and return it
 */
int
tcp_accept(int sock, int rdwr)
{
	struct	sockaddr_in s;
	int	newsock, namelen;

	namelen = sizeof(s);
	bzero((void*)&s, namelen);

retry:
	if ((newsock = accept(sock, (struct sockaddr*)&s, &namelen)) < 0) {
		if (errno == EINTR)
			goto retry;
		perror("accept");
		exit(6);
	}
#ifdef	LIBTCP_VERBOSE
	fprintf(stderr, "Server newsock port %d\n", sockport(newsock));
#endif
	sock_optimize(newsock, rdwr);
	return (newsock);
}

/*
 * Connect to the TCP socket advertised as "prog" on "host" and
 * return the connected socket.
 *
 * Hacked Thu Oct 27 1994 to cache pmap_getport calls.  This saves
 * about 4000 usecs in loopback lat_connect calls.  I suppose we
 * should time gethostbyname() & pmap_getprot(), huh?
 */
int
tcp_connect(char *host, int prog, int rdwr)
{
	static	struct hostent *h;
	static	struct sockaddr_in s;
	static	u_short	save_port;
	static	u_long save_prog;
	static	char *save_host;
	int	sock;
	static	int tries = 0;

	if ((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
		perror("socket");
		exit(1);
	}
	if (rdwr & SOCKOPT_PID) {
		static	unsigned short port;
		struct sockaddr_in sin;

		if (!port) {
			port = (unsigned short)(getpid() << 4);
			if (port < 1024) {
				port += 1024;
			}
		}
		do {
			port++;
			bzero((void*)&sin, sizeof(sin));
			sin.sin_family = AF_INET;
			sin.sin_port = htons(port);
		} while (bind(sock, (struct sockaddr*)&sin, sizeof(sin)) == -1);
	}
#ifdef	LIBTCP_VERBOSE
	else {
		struct sockaddr_in sin;

		bzero((void*)&sin, sizeof(sin));
		sin.sin_family = AF_INET;
		if (bind(sock, (struct sockaddr*)&sin, sizeof(sin)) < 0) {
			perror("bind");
			exit(2);
		}
	}
	fprintf(stderr, "Client port %d\n", sockport(sock));
#endif
	sock_optimize(sock, rdwr);
	if (!h || host != save_host || prog != save_prog) {
		save_host = host;	/* XXX - counting on them not
					 * changing it - benchmark only.
					 */
		save_prog = prog;
		if (!(h = gethostbyname(host))) {
			perror(host);
			exit(2);
		}
		bzero((void *) &s, sizeof(s));
		s.sin_family = AF_INET;
		bcopy((void*)h->h_addr, (void *)&s.sin_addr, h->h_length);
		if (prog > 0) {
			save_port = pmap_getport(&s, prog,
			    (u_long)1, IPPROTO_TCP);
			if (!save_port) {
				perror("lib TCP: No port found");
				exit(3);
			}
#ifdef	LIBTCP_VERBOSE
			fprintf(stderr, "Server port %d\n", save_port);
#endif
			s.sin_port = htons(save_port);
		} else {
			s.sin_port = htons(-prog);
		}
	}
	if (connect(sock, (struct sockaddr*)&s, sizeof(s)) < 0) {
		if (errno == ECONNRESET || errno == ECONNREFUSED) {
			close(sock);
			if (++tries > 10) return(-1);
			return (tcp_connect(host, prog, rdwr));
		}
		perror("connect");
		exit(4);
	}
	tries = 0;
	return (sock);
}

#define	LIBTCP_VERBOSE
void
sock_optimize(int sock, int flags)
{
	return;
	if (flags & SOCKOPT_READ) {
		int	sockbuf = SOCKBUF;

		while (setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &sockbuf,
		    sizeof(int))) {
			sockbuf >>= 1;
		}
#ifdef	LIBTCP_VERBOSE
		fprintf(stderr, "sockopt %d: RCV: %dK\n", sock, sockbuf>>10);
#endif
	}
	if (flags & SOCKOPT_WRITE) {
		int	sockbuf = SOCKBUF;

		while (setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &sockbuf,
		    sizeof(int))) {
			sockbuf >>= 1;
		}
#ifdef	LIBTCP_VERBOSE
		fprintf(stderr, "sockopt %d: SND: %dK\n", sock, sockbuf>>10);
#endif
	}
	if (flags & SOCKOPT_REUSE) {
		int	val = 1;
		if (setsockopt(sock, SOL_SOCKET,
		    SO_REUSEADDR, &val, sizeof(val)) == -1) {
			perror("SO_REUSEADDR");
		}
	}
}

int
sockport(int s)
{
	int	namelen;
	struct sockaddr_in sin;

	namelen = sizeof(sin);
	if (getsockname(s, (struct sockaddr *)&sin, &namelen) < 0) {
		perror("getsockname");
		return(-1);
	}
	return ((int)ntohs(sin.sin_port));
}

--yrj/dFKFPuw6o+aM--
