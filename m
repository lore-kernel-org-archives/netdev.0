From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Mon, 17 Nov 2008 23:36:14 +0100
Message-ID: <4921F1DE.9080305@cosmosbay.com>
References: <200811172050.31308.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38132 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbYKQWg1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 17:36:27 -0500
In-Reply-To: <200811172050.31308.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell a =C3=A9crit :
> There's no reason for this to be dynamically allocated: we panic if
> allocation fails anyway.
>=20
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>=20

Well, since we dont have "per_cpu bss", this also grow the size of vmli=
nux file, with
a block of 4096 nul bytes.

Same thing for rt_hash_lock_init() : We dynamically allocate the rt_has=
h_locks,
while its size is usually quite small, and we could avoid the pointer.

Maybe with current machines/boot loaders, we dont care anymore, I dont =
know...

> diff -r 643c2cdfdb62 include/net/route.h
> --- a/include/net/route.h	Mon Nov 17 19:57:42 2008 +1030
> +++ b/include/net/route.h	Mon Nov 17 20:23:37 2008 +1030
> @@ -34,6 +34,7 @@
>  #include <linux/ip.h>
>  #include <linux/cache.h>
>  #include <linux/security.h>
> +#include <linux/percpu.h>
> =20
>  #ifndef __KERNEL__
>  #warning This file is not supposed to be used outside of kernel.
> @@ -105,7 +106,7 @@
>          unsigned int out_hlist_search;
>  };
> =20
> -extern struct ip_rt_acct *ip_rt_acct;
> +DECLARE_PER_CPU(struct ip_rt_acct[256], ip_rt_acct);
> =20
>  struct in_device;
>  extern int		ip_rt_init(void);
> diff -r 643c2cdfdb62 net/ipv4/ip_input.c
> --- a/net/ipv4/ip_input.c	Mon Nov 17 19:57:42 2008 +1030
> +++ b/net/ipv4/ip_input.c	Mon Nov 17 20:23:37 2008 +1030
> @@ -339,7 +339,7 @@
> =20
>  #ifdef CONFIG_NET_CLS_ROUTE
>  	if (unlikely(skb->dst->tclassid)) {
> -		struct ip_rt_acct *st =3D per_cpu_ptr(ip_rt_acct, smp_processor_id=
());
> +		struct ip_rt_acct *st =3D __get_cpu_var(ip_rt_acct);
>  		u32 idx =3D skb->dst->tclassid;
>  		st[idx&0xFF].o_packets++;
>  		st[idx&0xFF].o_bytes+=3Dskb->len;
> diff -r 643c2cdfdb62 net/ipv4/route.c
> --- a/net/ipv4/route.c	Mon Nov 17 19:57:42 2008 +1030
> +++ b/net/ipv4/route.c	Mon Nov 17 20:23:37 2008 +1030
> @@ -541,7 +541,7 @@
>  			unsigned int j;
>  			u32 *src;
> =20
> -			src =3D ((u32 *) per_cpu_ptr(ip_rt_acct, i)) + offset;
> +			src =3D ((u32 *)per_cpu(ip_rt_acct, i)) + offset;
>  			for (j =3D 0; j < length/4; j++)
>  				dst[j] +=3D src[j];
>  		}
> @@ -3237,7 +3237,7 @@
> =20
> =20
>  #ifdef CONFIG_NET_CLS_ROUTE
> -struct ip_rt_acct *ip_rt_acct __read_mostly;
> +DEFINE_PER_CPU(struct ip_rt_acct[256], ip_rt_acct);
>  #endif /* CONFIG_NET_CLS_ROUTE */
> =20
>  static __initdata unsigned long rhash_entries;
> @@ -3253,12 +3253,6 @@
>  int __init ip_rt_init(void)
>  {
>  	int rc =3D 0;
> -
> -#ifdef CONFIG_NET_CLS_ROUTE
> -	ip_rt_acct =3D __alloc_percpu(256 * sizeof(struct ip_rt_acct));
> -	if (!ip_rt_acct)
> -		panic("IP: failed to allocate ip_rt_acct\n");
> -#endif
> =20
>  	ipv4_dst_ops.kmem_cachep =3D
>  		kmem_cache_create("ip_dst_cache", sizeof(struct rtable), 0,
> =20
> =EF=BF=BD=EF=BF=BD=EF=BF=BD{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD+%=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=DD=B6=17=EF=BF=BD=EF=BF=BDw=EF=BF=BD=EF=BF=BD{.n=EF=BF=BD+=EF=
=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=EF=BF=BD=17=EF=BF=BD=EF=BF=
=BD=DC=A8}=EF=BF=BD=EF=BF=BD=EF=BF=BD=C6=A0z=EF=BF=BD&j:+v=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=BD=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD=
)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
z=EF=BF=BD=EF=BF=BDz=EF=BF=BD=DE=97=EF=BF=BD+=EF=BF=BD=EF=BF=BD=DD=A2j=EF=
=BF=BD=EF=BF=BDw=EF=BF=BD=EF=BF=BD=1Bf
>=20
>=20


