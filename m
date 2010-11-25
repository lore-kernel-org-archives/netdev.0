From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 08:14:02 +0100
Message-ID: <1290669242.2798.110.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	 <1290666501.2798.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43603 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab0KYHOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 02:14:08 -0500
In-Reply-To: <1290666501.2798.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 07:28 +0100, Eric Dumazet a =C3=A9crit=
 :

>=20
> Since you obviously read recent mails on this subject yesterday, why
> dont you Cc netdev ?
>=20
> There is a very easy way to protect against this actually.
>=20
> A patch was posted yesterday, and need some adjustements.
>=20
>=20
> diff --git a/net/unix/garbage.c b/net/unix/garbage.c
> index c8df6fd..40df93d 100644
> --- a/net/unix/garbage.c
> +++ b/net/unix/garbage.c
> @@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_s=
ock *u)
>  }
> =20
>  static bool gc_in_progress =3D false;
> +#define UNIX_INFLIGHT_TRIGGER_GC 2000
> =20
>  void wait_for_unix_gc(void)
>  {
> +	/*
> +	 * If number of inflight sockets is insane,
> +	 * force a garbage collect right now.
> +	 */
> +	if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_GC && !gc_in_progress=
)
> +		unix_gc();
>  	wait_event(unix_gc_wait, gc_in_progress =3D=3D false);
>  }
> =20
>=20

Hmm... it seems its another problem, chains are very long so we hit a
NMI watchdog.

I guess we should limit to a very small number, like 64, or rewrite the
garbage collector to a better algo.



