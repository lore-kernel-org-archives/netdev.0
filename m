From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: use after free bug in socket code
Date: Mon, 13 Jul 2009 19:46:51 +0200
Message-ID: <4A5B730B.8090902@hartkopp.net>
References: <19028.16049.907160.45293@ipc1.ka-ro>	<20090709154533.GA27413@gondor.apana.org.au> <19035.23045.386506.297464@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: =?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:24818 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbZGMRrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 13:47:00 -0400
In-Reply-To: <19035.23045.386506.297464@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lothar Wa=DFmann wrote:
> Herbert Xu writes:
>> Lothar Wa=DFmann <LW@karo-electronics.de> wrote:
>>> So, could you point me to the place where the reference count of th=
e
>>> socket object is being incremented when a struct sock is associated
>>> with it?
>> It's implicit.  Anyway, you should remodel your release function
>> on a working protocol.
>>
> OK. I checked the release functions of the can raw and bcm protocols
> and found that they obviously are the culprits since they lack the
> call to sock_orphan that other network protocol drivers have:
>=20
> diff -ur linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
> --- linux-2.6.30/net/can/bcm.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.30-karo/net/can/bcm.c	2009-07-12 20:12:38.000000000 +02=
00
> @@ -1469,6 +1469,9 @@
>  		bo->ifindex =3D 0;
>  	}
> =20
> +	sock_orphan(sk);
> +	sock->sk =3D NULL;
> +
>  	release_sock(sk);
>  	sock_put(sk);
> =20
> diff -ur linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
> --- linux-2.6.30/net/can/raw.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.30-karo/net/can/raw.c	2009-07-12 20:12:29.000000000 +02=
00
> @@ -306,6 +306,9 @@
>  	ro->bound   =3D 0;
>  	ro->count   =3D 0;
> =20
> +	sock_orphan(sk);
> +	sock->sk =3D NULL;
> +
>  	release_sock(sk);
>  	sock_put(sk);
> =20
>=20
>=20
> Could someone of the CAN-Folks comment on this?

Hello Lothar,

unfortunately i did not get any answer from Urs so far, who originally =
created
these lines of code.

But from what i was able to get from browsing similar code in the Kerne=
l that
at least sock_orphan() is called in the appropriate socket release func=
tions,
which is indeed not done by the mentioned PF_CAN protocols right now.

I assume you already tested this patch (at least with CAN_RAW) successf=
ully,
right?

If so, i would have no objections to add my Acked-by to these changes.

Would you like to prepare a proper patch and post it on netdev?

Thanks for digging that issue!

Best regards,
Oliver

ps. This code section was stable for more than three years now. Can you=
 tell
me, how you kicked your system to run into this problem?


