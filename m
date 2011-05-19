From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4] rps: Add flag to skb to indicate rxhash is on L4
 tuple
Date: Thu, 19 May 2011 22:26:54 +0200
Message-ID: <1305836814.3156.21.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1105190827240.12799@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50087 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933727Ab1ESU07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:26:59 -0400
Received: by wwa36 with SMTP id 36so3292214wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:26:58 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105190827240.12799@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:39 -0700, Tom Herbert a =C3=A9crit :
> The l4_rxhash flag was added to the skb structure to indicate
> that the rxhash value was computed over the 4 tuple for the
> packet which includes the port information in the encapsulated
> transport packet.  This is used by the stack to preserve the
> rxhash value in __skb_rx_tunnel.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/skbuff.h |    5 +++--
>  include/net/dst.h      |    9 ++++++++-
>  include/net/sock.h     |   14 +++++++++++---
>  net/core/dev.c         |   17 +++++++++++------
>  net/core/skbuff.c      |    1 +
>  net/ipv4/tcp_ipv4.c    |    4 ++--
>  net/ipv4/udp.c         |    4 ++--
>  7 files changed, 38 insertions(+), 16 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 79aafbb..4fab336 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -397,6 +397,7 @@ struct sk_buff {
>  	__u8			ndisc_nodetype:2;
>  #endif
>  	__u8			ooo_okay:1;
> +	__u8			l4_rxhash:1;
>  	kmemcheck_bitfield_end(flags2);
> =20
>  	/* 0/13 bit hole */
> @@ -555,11 +556,11 @@ extern unsigned int   skb_find_text(struct sk_b=
uff *skb, unsigned int from,
>  				    unsigned int to, struct ts_config *config,
>  				    struct ts_state *state);
> =20
> -extern __u32 __skb_get_rxhash(struct sk_buff *skb);
> +extern void __skb_get_rxhash(struct sk_buff *skb);
>  static inline __u32 skb_get_rxhash(struct sk_buff *skb)
>  {
>  	if (!skb->rxhash)
> -		skb->rxhash =3D __skb_get_rxhash(skb);
> +		__skb_get_rxhash(skb);
> =20
>  	return skb->rxhash;
>  }
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 07a0402..17ff602 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -307,7 +307,14 @@ static inline void skb_dst_force(struct sk_buff =
*skb)
>  static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_d=
evice *dev)
>  {
>  	skb->dev =3D dev;
> -	skb->rxhash =3D 0;
> +
> +	/*
> +	 * Clear rxhash so that we can reculate the hash for the

typo ?

> +	 * encapsulated packet, unless we have already determine the hash
> +	 * over the L4 4-tuple.
> +	 */
> +	if (!skb->l4_rxhash)
> +		skb->rxhash =3D 0;
>  	skb_set_queue_mapping(skb, 0);
>  	skb_dst_drop(skb);
>  	nf_reset(skb);
> diff --git a/include/net/sock.h b/include/net/sock.h
> index f2046e4..e670c41 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -685,16 +685,24 @@ static inline void sock_rps_reset_flow(const st=
ruct sock *sk)
>  #endif
>  }
> =20
> -static inline void sock_rps_save_rxhash(struct sock *sk, u32 rxhash)
> +static inline void sock_rps_save_rxhash(struct sock *sk, struct sk_b=
uff *skb)

const struct sk_buff *skb ?

>  {
>  #ifdef CONFIG_RPS
> -	if (unlikely(sk->sk_rxhash !=3D rxhash)) {
> +	if (unlikely(sk->sk_rxhash !=3D skb->rxhash)) {
>  		sock_rps_reset_flow(sk);
> -		sk->sk_rxhash =3D rxhash;
> +		sk->sk_rxhash =3D skb->rxhash;
>  	}
>  #endif
>  }
> =20
> +static inline void sock_rps_reset_rxhash(struct sock *sk)
> +{
> +#ifdef CONFIG_RPS
> +	sock_rps_reset_flow(sk);
> +	sk->sk_rxhash =3D 0;
> +#endif
> +}
> +
>  #define sk_wait_event(__sk, __timeo, __condition)			\
>  	({	int __rc;						\
>  		release_sock(__sk);					\
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a40eea9..37ddece 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2014,8 +2014,10 @@ static inline void skb_orphan_try(struct sk_bu=
ff *skb)
>  		/* skb_tx_hash() wont be able to get sk.
>  		 * We copy sk_hash into skb->rxhash
>  		 */
> -		if (!skb->rxhash)
> +		if (!skb->rxhash) {
>  			skb->rxhash =3D sk->sk_hash;
> +			skb->l4_rxhash =3D 1;

Why do you set l4_rxhash here ?

> +		}
>  		skb_orphan(skb);
>  	}
>  }
> @@ -2499,12 +2501,13 @@ static inline void ____napi_schedule(struct s=
oftnet_data *sd,
> =20
>  /*
>   * __skb_get_rxhash: calculate a flow hash based on src/dst addresse=
s
> - * and src/dst port numbers. Returns a non-zero hash number on succe=
ss
> - * and 0 on failure.
> + * and src/dst port numbers.  Sets rxhash in skb to non-zero hash va=
lue
> + * on success, zero indicates no valid hash.  Also, sets l4_rxhash i=
n skb
> + * if hash is a canonical 4-tuple hash over transport ports.
>   */
> -__u32 __skb_get_rxhash(struct sk_buff *skb)
> +void __skb_get_rxhash(struct sk_buff *skb)
>  {
> -	int nhoff, hash =3D 0, poff;
> +	int nhoff, hash =3D 0, l4hash =3D 0, poff;
>  	const struct ipv6hdr *ip6;
>  	const struct iphdr *ip;
>  	u8 ip_proto;
> @@ -2554,6 +2557,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
>  			ports.v32 =3D * (__force u32 *) (skb->data + nhoff);
>  			if (ports.v16[1] < ports.v16[0])
>  				swap(ports.v16[0], ports.v16[1]);
> +			l4hash =3D 1;

maybe directly set skb->l4_rxhash =3D 1 here ?

	=09
>  		}
>  	}
> =20
> @@ -2566,7 +2570,8 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
>  		hash =3D 1;
> =20
>  done:
> -	return hash;
> +	skb->rxhash =3D hash;
> +	skb->l4_rxhash =3D l4hash;

and remove this line.  (gcc is pretty expensive here for a one bit
field)


Thanks


