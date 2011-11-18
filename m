From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 17:39:38 +0100
Message-ID: <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111117190925.GA23214@elliptictech.com>
	 <20111118162709.GA8342@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Timo Teras <timo.teras@iki.fi>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55132 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975Ab1KRQjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 11:39:44 -0500
Received: by fagn18 with SMTP id n18so4507092fag.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 08:39:43 -0800 (PST)
In-Reply-To: <20111118162709.GA8342@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 novembre 2011 =C3=A0 11:27 -0500, Nick Bowler a =C3=A9cr=
it :
> On 2011-11-17 14:09 -0500, Nick Bowler wrote:
> > One of the tests we do with IPsec involves sending and receiving UD=
P
> > datagrams of all sizes from 1 to N bytes, where N is much larger th=
an
> > the MTU.  In this particular instance, the MTU is 1500 bytes and N =
is
> > 10000 bytes.  This test works fine with IPv4, but I'm getting an
> > occasional oops on Linus' master with IPv6 (output at end of email)=
=2E  We
> > also run the same test where N is less than the MTU, and it does no=
t
> > trigger this issue.  The resulting fallout seems to eventually lock=
 up
> > the box (although it continues to work for a little while afterward=
s).
> >=20
> > The issue appears timing related, and it doesn't always occur.  Thi=
s
> > probably also explains why I've not seen this issue before now, as =
we
> > recently upgraded all our lab systems to machines from this century
> > (with newfangled dual core processors).  This also makes it somewha=
t
> > hard to reproduce, but I can trigger it pretty reliably by running =
'yes'
> > in an ssh session (which doesn't use IPsec) while running the test:
> > it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
> > appears to be irrelevant.
> >=20
> > I built a relatively old kernel (2.6.34) and could not reproduce th=
e
> > issue there, so I ran a git bisect.  It pointed to the following, w=
hich
> > (unsurprisingly) no longer reverts cleanly.
> >=20
> > Let me know if you need any more info.  I'll see if I can reproduce=
 the
> > issue with a smaller test case...
>=20
> OK, here's a somewhat straigthforward way to reproduce it that I've
> found.  It uses a short test program called "udp_burst" which simply
> transmits a bunch of UDP datagrams at all sizes between 1 and 10000,
> included at the end of this mail.
>=20
>  * Build the test program
>=20
>     % gcc -o udp_burst udp_burst.c
>=20
>  * Setup transport mode IPv6 SAs between two hosts so that they can
>    communicate using IPsec.  Choose your favourite cipher suite.
>    In this example, my two hosts are "fec0::3/64" and "fec0::2/64": I
>    will be crashing the former.
>=20
>    It can be reproduced with just one host transmitting to the bit
>    bucket, but it seems to go much faster with two.
>=20
>  * Create some constant non-IPsec network traffic on the machine to b=
e
>    crashed (for example, log in via SSH and run "yes").
> =20
>  * On the machine to be crashed, run
>=20
>     % while :; do ./udp_burst remote; done
>=20
>    where remote is the other host (fec0::2 in my case).
> =20
>  * Wait a few seconds and watch the fireworks.
>=20
> % cat >udp_burst.c <<'EOF'
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <errno.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netdb.h>
>=20
> #define MAX_DGRAM_SIZE 10000
>=20
> static char buf[MAX_DGRAM_SIZE];
>=20
> int main(int argc, char **argv)
> {
> 	char *addr =3D NULL, *port =3D "9000";
> 	struct addrinfo *info, hints =3D {
> 		.ai_family   =3D AF_UNSPEC,
> 		.ai_socktype =3D SOCK_DGRAM,
> 		.ai_flags    =3D AI_PASSIVE,
> 	};
> 	int i, rc, sock;
>=20
> 	if (argc > 1)
> 		addr =3D argv[1];
> 	if (argc > 2)
> 		port =3D argv[2];
> 	if (!addr) {
> 		fprintf(stderr, "usage: %s addr [port]\n", argv[0]);
> 		return EXIT_FAILURE;
> 	}
>=20
> 	rc =3D getaddrinfo(addr, port, &hints, &info);
> 	if (rc !=3D 0) {
> 		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rc));
> 		return EXIT_FAILURE;
> 	}
>=20
> 	sock =3D socket(info->ai_family, info->ai_socktype, info->ai_protoco=
l);
> 	if (sock =3D=3D -1) {
> 		perror("socket");
> 		return EXIT_FAILURE;
> 	}
>=20
> 	if (connect(sock, info->ai_addr, info->ai_addrlen) =3D=3D -1) {
> 		perror("connect");
> 		return EXIT_FAILURE;
> 	}
>=20
> 	for (i =3D 0; i < MAX_DGRAM_SIZE; i++) {
> 		if (send(sock, buf, i+1, MSG_DONTWAIT) =3D=3D -1) {
> 			if (errno !=3D EAGAIN && errno !=3D ECONNREFUSED) {
> 				perror("send");
> 			}
> 		}
> 	}
>=20
> 	return 0;
> }
> EOF
>=20

Please note commit 80c802f307 added a known bug, fixed in commit
0b150932197b (xfrm: avoid possible oopse in xfrm_alloc_dst)

Given commit 80c802f307 complexity, we can assume other bugs are to be
fixed as well.

Unfortunately, Timo seems unresponsive.
