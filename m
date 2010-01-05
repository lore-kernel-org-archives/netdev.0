From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 15:45:26 +0100
Message-ID: <4B435086.8030306@gmail.com>
References: <4B4317AD.1040302@free.fr> <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi> <4B4348A7.4090509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49017 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060Ab0AEOpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 09:45:40 -0500
In-Reply-To: <4B4348A7.4090509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 15:11, Eric Dumazet a =E9crit :

> Nothing... really... we can round the value, and we indeed round it i=
n 2.6.32
>=20
> defer value is given in second by user, and converted to number of re=
transmits by kernel.
>=20
> Program assumption is wrong.

BTW, previous kernels were rounding too :

1 -> 3
2 -> 3
3 -> 3
4 -> 6
5 -> 6
6 -> 6
7 -> 12
8 -> 12
9 -> 12
10 -> 12
11 -> 12
12 -> 12
13 -> 24
14 -> 24
15 -> 24
16 -> 24
17 -> 24
18 -> 24
19 -> 24

New kernel (or other sysctl settings, I didnot check) :

1 -> 3
2 -> 3
3 -> 3
4 -> 9
5 -> 9
6 -> 9
7 -> 9
8 -> 9
9 -> 9
10 -> 21
11 -> 21
12 -> 21
13 -> 21
14 -> 21
15 -> 21
16 -> 21
17 -> 21
18 -> 21
19 -> 21

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

int main(int argc, char *argv[])
{
   int i, val1 =3D 12, val2;
   socklen_t len =3D sizeof(val2);
   int fd;
     fd =3D socket(PF_INET, SOCK_STREAM, 0);
   if (fd < 0) {
       perror("socket");
       return -1;
   }
   for (i =3D 1; i < 20 ; i++) {
     val1 =3D i;
     if (setsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val1, sizeof(val1))=
) {
       perror("setsockopt");
       return -1;
     }
     if (getsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val2, &len)) {
       perror("getsockopt");
       return -1;
     }
   printf("%d -> %d\n", i, val2);
   }
   return 0;
}

