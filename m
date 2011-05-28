From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Sat, 28 May 2011 07:41:25 +0200
Message-ID: <1306561285.2533.9.camel@edumazet-laptop>
References: <20110525060609.GA32244@dev1756.snc6.facebook.com>
	 <1306305331.3305.22.camel@edumazet-laptop> <4DDEAA3C.7020502@fb.com>
	 <1306439246.2543.10.camel@edumazet-laptop> <4DDECA9B.8080206@fb.com>
	 <1306447292.2543.32.camel@edumazet-laptop> <4DDEEBC5.80804@fb.com>
	 <1306466831.2543.58.camel@edumazet-laptop> <4DDFE4D6.4010000@fb.com>
	 <1306526219.2533.3.camel@edumazet-laptop>
	 <20110527211419.GA6793@dev1756.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56349 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab1E1Flc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2011 01:41:32 -0400
In-Reply-To: <20110527211419.GA6793@dev1756.snc6.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 mai 2011 =C3=A0 14:14 -0700, Arun Sharma a =C3=A9crit :

> The attached works for me for x86_64. Cc'ing Ingo/Thomas for comment.
>=20
>  -Arun
>=20
> atomic: Refactor atomic_add_unless
>=20
> Commit 686a7e3 (inetpeer: fix race in unused_list manipulations)
> in net-2.6 added a atomic_add_unless_return() variant that tries
> to detect 0->1 transitions of an atomic reference count.
>=20
> This sounds like a generic functionality that could be expressed
> in terms of an __atomic_add_unless() that returned the old value
> instead of a bool.
>=20
> Signed-off-by: Arun Sharma <asharma@fb.com>
> ---
>  arch/x86/include/asm/atomic.h |   22 ++++++++++++++++++----
>  1 files changed, 18 insertions(+), 4 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/ato=
mic.h
> index 952a826..bbdbffe 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -221,15 +221,15 @@ static inline int atomic_xchg(atomic_t *v, int =
new)
>  }
> =20
>  /**
> - * atomic_add_unless - add unless the number is already a given valu=
e
> + * __atomic_add_unless - add unless the number is already a given va=
lue
>   * @v: pointer of type atomic_t
>   * @a: the amount to add to v...
>   * @u: ...unless v is equal to u.
>   *
>   * Atomically adds @a to @v, so long as @v was not already @u.
> - * Returns non-zero if @v was not @u, and zero otherwise.
> + * Returns the old value of v
>   */
> -static inline int atomic_add_unless(atomic_t *v, int a, int u)
> +static inline int __atomic_add_unless(atomic_t *v, int a, int u)
>  {
>  	int c, old;
>  	c =3D atomic_read(v);
> @@ -241,7 +241,21 @@ static inline int atomic_add_unless(atomic_t *v,=
 int a, int u)
>  			break;
>  		c =3D old;
>  	}
> -	return c !=3D (u);
> +	return c;
> +}
> +
> +/**
> + * atomic_add_unless - add unless the number is already a given valu=
e
> + * @v: pointer of type atomic_t
> + * @a: the amount to add to v...
> + * @u: ...unless v is equal to u.
> + *
> + * Atomically adds @a to @v, so long as @v was not already @u.
> + * Returns non-zero if @v was not @u, and zero otherwise.
> + */
> +static inline int atomic_add_unless(atomic_t *v, int a, int u)
> +{
> +	return __atomic_add_unless(v, a, u) !=3D u;
>  }
> =20
>  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)

As I said, atomic_add_unless() has several implementations in various
arches. You must take care of all, not only x86.



