From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH 5/5] net: Encapsulate inner code of __sk_dst_reset
Date: Thu, 15 Oct 2009 11:53:30 +0200
Message-ID: <4AD6F11A.90908@gmail.com>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain> <20091015055758.30145.77495.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54586 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756718AbZJOJyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:54:15 -0400
In-Reply-To: <20091015055758.30145.77495.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Reuse code by adding ___sk_dst_reset() which is called by
> __sk_dst_reset() and __sk_dst_check(). This new API is also
> called from IPv6 to hide the internals of __sk_dst_reset
> and the setting of sk_tx_queue_mapping.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  include/net/sock.h               |   13 +++++++++----
>  net/core/sock.c                  |    4 +---
>  net/ipv6/inet6_connection_sock.c |    4 +---
>  3 files changed, 11 insertions(+), 10 deletions(-)
>=20
> diff -ruNp org/include/net/sock.h new/include/net/sock.h
> --- org/include/net/sock.h	2009-10-14 18:00:17.000000000 +0530
> +++ new/include/net/sock.h	2009-10-14 18:00:30.000000000 +0530
> @@ -1186,17 +1186,22 @@ sk_dst_set(struct sock *sk, struct dst_e
>  }
> =20
>  static inline void
> -__sk_dst_reset(struct sock *sk)
> +___sk_dst_reset(struct sock *sk, struct dst_entry *old_dst)
>  {
> -	struct dst_entry *old_dst;
> -
>  	sk_record_tx_queue(sk, -1);
> -	old_dst =3D sk->sk_dst_cache;
>  	sk->sk_dst_cache =3D NULL;
>  	dst_release(old_dst);
>  }
> =20
>  static inline void
> +__sk_dst_reset(struct sock *sk)
> +{
> +	struct dst_entry *old_dst =3D sk->sk_dst_cache;
> +
> +	___sk_dst_reset(sk, old_dst);
> +}
> +
> +static inline void
>  sk_dst_reset(struct sock *sk)
>  {
>  	write_lock(&sk->sk_dst_lock);
> diff -ruNp org/net/core/sock.c new/net/core/sock.c
> --- org/net/core/sock.c	2009-10-14 18:00:22.000000000 +0530
> +++ new/net/core/sock.c	2009-10-14 18:00:30.000000000 +0530
> @@ -364,9 +364,7 @@ struct dst_entry *__sk_dst_check(struct=20
>  	struct dst_entry *dst =3D sk->sk_dst_cache;
> =20
>  	if (dst && dst->obsolete && dst->ops->check(dst, cookie) =3D=3D NUL=
L) {
> -		sk_record_tx_queue(sk, -1);
> -		sk->sk_dst_cache =3D NULL;
> -		dst_release(dst);
> +		___sk_dst_reset(sk, dst);
>  		return NULL;
>  	}
> =20
> diff -ruNp org/net/ipv6/inet6_connection_sock.c new/net/ipv6/inet6_co=
nnection_sock.c
> --- org/net/ipv6/inet6_connection_sock.c	2009-10-14 18:00:17.00000000=
0 +0530
> +++ new/net/ipv6/inet6_connection_sock.c	2009-10-14 18:00:30.00000000=
0 +0530
> @@ -168,9 +168,7 @@ struct dst_entry *__inet6_csk_dst_check(
>  	if (dst) {
>  		struct rt6_info *rt =3D (struct rt6_info *)dst;
>  		if (rt->rt6i_flow_cache_genid !=3D atomic_read(&flow_cache_genid))=
 {
> -			sk_record_tx_queue(sk, -1);
> -			sk->sk_dst_cache =3D NULL;
> -			dst_release(dst);
> +			___sk_dst_reset(sk, dst);
>  			dst =3D NULL;
>  		}
>  	}
>=20
>=20

Encapsulation seems un-necessary to me, since only use cases are
___sk_dst_reset(sk, sk->sk_dst_cache)


static inline void __sk_dst_reset(struct sock *sk)
{
	struct dst_entry *old_dst =3D sk->sk_dst_cache;

	sk_record_tx_queue(sk, -1);
  	sk->sk_dst_cache =3D NULL;
 	dst_release(old_dst);
}

