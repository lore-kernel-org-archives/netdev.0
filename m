From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Sun, 01 Nov 2009 19:03:40 +0100
Message-ID: <4AEDCD7C.2010403@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48786 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbZKASDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 13:03:42 -0500
In-Reply-To: <4AED86AD.6010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Since October 4th, I've repeatedly asked publicly for assistance with=
 these
> Linux-specific memory locking constructs and cryptography.  I've also=
 sent
> private messages.  No help has been forthcoming.  None.  Nada.
>=20
> At this point, I've spent weeks re-spinning code that I'd understood =
was
> approved a year ago.  The whole project should have been finished by =
now!

Your messages on netdev are two weeks old, not one year, and came durin=
g
LKS. Many developpers were busy in Japan.

>=20
> So, I'll try a larger audience.  Could somebody take a look at my usa=
ge of
> read and write locking?
>=20
> NB, I'm trying to port some 15-year-old fairly simple and straightfor=
ward
> (single cpu) code from the KA9Q cooperative multitasking platform.
>=20
> I've examined existing code used for syncookies and TCP MD5 authentic=
ators.
> Neither meets my needs, as this secret is updated every few minutes. =
 Both
> have very different approaches.  They are rarely used.  My code will =
be
> used on the order of tens of thousands of connections per second.
>=20
> Moreover, it seems to my naive eye that the syncookie per cpu code si=
mply
> doesn't work properly.  The workspace is allocated per cpu, but the c=
pu
> could change during the extensive SHA1 computations.  Bug?
>=20
> Therefore, I'm approaching this as simply as possible.  I'm particula=
rly
> concerned about the initialization and cache state of memory pointers=
=2E
>=20
> Does the locking handle this?  Or is there more to be done?
>=20

This patch looks fine, but I dont see how this new function is used.

Some points :

1) We are working hard to remove rwlocks from network stack, so please =
dont
add a new one. You probably can use a seqlock or RCU, or a server handl=
ing=20
10.000 connections request per second on many NIC will hit this rwlock.

2)=20

	} else if (unlikely(time_after(jiffy, tcp_secret_primary->expires))) {
		get_random_bytes(secrets, sizeof(secrets));

		write_lock(&tcp_secret_locker);

It would be better to first get the lock, then get random_bytes, in ord=
er
not wasting entropy.


3) If you change secret ever 600 seconds, it might be better to use a t=
imer
so that you dont have to check expiration and this logic at each SYN pa=
cket.
(Disociate the lookup (read-only, done many time per second) from the u=
pdates
(trigerred by a timer every 600 secs))

(Not counting you'll probably need to use a similar lookup algo for the=
 ACK
packet coming from client)




