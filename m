From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bug in select(2) regarding non-blocking connect(2) completion?
Date: Sat, 07 May 2011 14:12:38 +0200
Message-ID: <1304770358.2821.1139.camel@edumazet-laptop>
References: <20110507105152.GA13459@jensen.inet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, karls@inet.no,
	netdev <netdev@vger.kernel.org>
To: Michael Shuldman <michaels@inet.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60647 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab1EGMMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 08:12:43 -0400
In-Reply-To: <20110507105152.GA13459@jensen.inet.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 12:51 +0200, Michael Shuldman a =C3=A9crit=
 :
> Hello, I am occasionally encountering what I belive is a bug in the
> kernel.
>=20
> Below is a strace that I believe shows how the bug manifests itself,
> with my comments.
>=20
>=20
> # first select.  All fd's in the write set ([15 17 ... 51 55]) are=20
> # non-blocking sockets that have had a connect(2) previously issued o=
n
> # them, and which have yet to finish connecting as far as we know
> # at the time we call select(2).

We dont see the return from connect() : maybe the error was already
returned there.

Only EINPROGRESS is valid here (or fd should be closed right now)

> 03:55:31.808548 select(58, [4 8 11 12 13 14 16 18 19 20 21 22 23 24 2=
6 27 30 31
> 32 33 34 35 36 37 39 40 41 43 44 46 48 49 50 52 53 54 57], [15 17 25 =
29 45 47 51
>  55], [11 12 13 14 16 18 19 20 21 22 23 24 26 27 30 31 32 33 34 35 36=
 37 39 40 4
> 1 43 44 46 48 49 50 52 53 54 57], {1, 0}) =3D 3 (in [16 26], out [51]=
, left {1, 0}
> )
>=20
> # As indicated by the results returned by the above select(2), fd 51 =
should
> # have finished the connect attempt, but when we try to find out whet=
her=20
> # the connect(2) succeeded or failed, the results are conflicting.
>=20

If connect() attempt is rejected by remote peer, then select() says you=
r
fd is 'writeable', in the sense you have the definitive answer to your
non blocking connect().

> 03:55:31.808622 getpeername(51, 0x7fff5d2eaa8c, [0]) =3D -1 ENOTCONN =
(Transport en
> dpoint is not connected)

This means end point is non connected : other peer sent RST or no answe=
r
to SYN packets.


> 03:55:31.808900 getsockopt(51, SOL_SOCKET, SO_ERROR, [0], [4]) =3D 0
>=20

Hmm, interesting... Are you sure a previous call was not already done
(since this clears the error) ?

> # getpeername(2) failing on a socket that has finished connecting sho=
uld=20
> # indicate that the connect(2) failed.  Yet when we try to fetch the
> # SO_ERROR of the socket, it says no error is currently set.
> # We then loop around with select(2) again, and again the same thing
> # happens:
>=20
> 03:55:31.809259 select(58, [4 8 11 12 13 14 16 18 19 20 21 22 23 24 2=
6 27 30 31
> 32 33 34 35 36 37 39 40 41 43 44 46 48 49 50 52 53 54 57], [15 17 25 =
29 45 47 51
>  55], [11 12 13 14 16 18 19 20 21 22 23 24 26 27 30 31 32 33 34 35 36=
 37 39 40 4
> 1 43 44 46 48 49 50 52 53 54 57], {1, 0}) =3D 3 (in [16 26], out [51]=
, left {1, 0}
> )
> 03:55:31.809329 getpeername(51, 0x7fff5d2eaa8c, [0]) =3D -1 ENOTCONN =
(Transport en
> dpoint is not connected)
> 03:55:31.809640 getsockopt(51, SOL_SOCKET, SO_ERROR, [0], [4]) =3D 0
>=20

Well, if you missed the original error report, all next getpeername()
and SO_ERROR will do the same, and select() says fd is ready for 'write=
'

> ...
>=20
> # finally, getsockopt(2) returns that the connect(2) failed.
> 03:55:32.521146 getpeername(51, 0x7fff5d2eaa8c, [0]) =3D -1 ENOTCONN =
(Transport en
> dpoint is not connected)
> 03:55:32.521614 getsockopt(51, SOL_SOCKET, SO_ERROR, [101], [4]) =3D =
0
>=20
> In other words, select(2) says the socket has finished connecting,
> getpeername(2) neither confirms nor denies this (it can only confirm
> if the connect finished successfully).  getsockopt(2) and SO_ERROR
> however says there is no error on the socket, which coupled
> with getpeername(2) failing, indicates that the connect(2) has
> not yet finished
>=20
>=20
>=20
> This does not happen all the time.  E.g., I watched the system for
> an hour yesterday, as things were staring up and the number of
> concurrent tcp clients gradually increased from zero to around 700,
> with no observable problems.  However after a while, the problem
> starts occurring, related to an increasing number of clients or
> something else, I do not know.
>=20
> Currently the system has a little over 3,000 clients and the problem
> occurs now and then, sometimes several times a minute, while sometime=
s
> it can take dozens of minutes between each time.  At the moment,
> the last time the problem was detected was 40 minutes ago.
>=20
> The software the above strace is related to is a proxy server, and
> if there are 3000 clients (incoming TCP sessions), there would
> normally be 3000 outgoing TCP sessions also. =20
>=20
> uname -a on the system in question reports=20
> 2.6.18-238.9.1.el5 #1 SMP Tue Apr 12 18:10:13 EDT 2011 x86_64 x86_64
> x86_64 GNU/Linux
>=20
> Thankful for any hints or pointers related to this problem.
> With kind regards,
>=20

Make sure you dont miss an error in connect() system call.



