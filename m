From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 09:18:19 +0100
Message-ID: <1229501899.13305.12.camel@nathan.suse.cz>
References: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39616 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750909AbYLQISX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 03:18:23 -0500
In-Reply-To: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu p=C3=AD=C5=A1e v St 17. 12. 2008 v 12:18 +1100:
> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >=20
> > I should have noticed this earlier... :-) The previous solution
> > to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
> > patterns, or even worse, a steep downward slope into packet
> > counting because each skb pcount would be truncated to pcount
> > of 2 and then the following fragments of the later portion would
> > restore the window again.
>=20
> How about just handling it, URG isn't that hard.  If anyone is
> bored you can do this for GRO as well.
>=20
> tcp: Add GSO support for urgent data
>=20
> When segmenting packets with urgent data we need to clear the
> urgent flag/pointer once we move past the end of the urgent data.
> This was not handled correctly in GSO or (presumably) in existing
> hardware.
>=20
> This patch adds a new GSO flag for TCP urgent data and also fixes
> its handling in GSO.

This would work, but:

  1. Currently this code path will never get run, because large
     offloads are avoided both for hardware TSO and software GSO.
     You'd also have to modify the conditionals that guard calls
     to tcp_mss_split_point().

  2. Is it worth the trouble?
     This slows down the software GSO slightly. I mean, urgent
     data should be quite rare, so it makes sense to treat
     non-urgent data as "fast path" and urgent data as "slow
     path". While Ilpo's approach only slows down the slow path,
     your patch slows down both.

     No, I don't have any numbers, no. ;)

Anyway, we have to keep the code that avoids large offloads with URG,
because many NICs are broken in this regard (at least all Intel NICs
I've seen so far), so why treat software GSO specially?

Petr Tesarik

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> Cheers,
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e26f549..4508c48 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -532,9 +532,11 @@ struct net_device
>  #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
>  #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
>  #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
> +#define NETIF_F_TSO_URG		(SKB_GSO_TCP_URG << NETIF_F_GSO_SHIFT)
> =20
>  	/* List of features with software fallbacks. */
> -#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_=
=46_TSO6)
> +#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
> +				 NETIF_F_TSO6 | NETIF_F_TSO_URG)
> =20
>=20
>  #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2725f4e..56e9179 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -188,6 +188,9 @@ enum {
>  	SKB_GSO_TCP_ECN =3D 1 << 3,
> =20
>  	SKB_GSO_TCPV6 =3D 1 << 4,
> +
> +	/* This indicates the tcp segment has URG set. */
> +	SKB_GSO_TCP_URG =3D 1 << 5,
>  };
> =20
>  #if BITS_PER_LONG > 32
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 1aa2dc9..33305f6 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1202,6 +1202,7 @@ static struct sk_buff *inet_gso_segment(struct =
sk_buff *skb, int features)
>  		       SKB_GSO_UDP |
>  		       SKB_GSO_DODGY |
>  		       SKB_GSO_TCP_ECN |
> +		       SKB_GSO_TCP_URG |
>  		       0)))
>  		goto out;
> =20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index c5aca0b..e6796a8 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2383,6 +2383,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb, int features)
>  	__be32 delta;
>  	unsigned int oldlen;
>  	unsigned int len;
> +	unsigned int urg_ptr;
> =20
>  	if (!pskb_may_pull(skb, sizeof(*th)))
>  		goto out;
> @@ -2408,6 +2409,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb, int features)
>  			       SKB_GSO_DODGY |
>  			       SKB_GSO_TCP_ECN |
>  			       SKB_GSO_TCPV6 |
> +			       SKB_GSO_TCP_URG |
>  			       0) ||
>  			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
>  			goto out;
> @@ -2429,6 +2431,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb, int features)
>  	skb =3D segs;
>  	th =3D tcp_hdr(skb);
>  	seq =3D ntohl(th->seq);
> +	urg_ptr =3D th->urg ? ntohs(th->urg_ptr) : 0;
> =20
>  	do {
>  		th->fin =3D th->psh =3D 0;
> @@ -2446,6 +2449,14 @@ struct sk_buff *tcp_tso_segment(struct sk_buff=
 *skb, int features)
> =20
>  		th->seq =3D htonl(seq);
>  		th->cwr =3D 0;
> +
> +		if (urg_ptr <=3D len)
> +			urg_ptr =3D 0;
> +		else
> +			urg_ptr -=3D len;
> +
> +		th->urg =3D !!urg_ptr;
> +		th->urg_ptr =3D htons(urg_ptr);
>  	} while (skb->next);
> =20
>  	delta =3D htonl(oldlen + (skb->tail - skb->transport_header) +
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index fe3b4bd..d4dc0fa 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -667,6 +667,7 @@ static int tcp_transmit_skb(struct sock *sk, stru=
ct sk_buff *skb, int clone_it,
>  		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
>  		th->urg_ptr		=3D htons(tp->snd_up - tcb->seq);
>  		th->urg			=3D 1;
> +		skb_shinfo(skb)->gso_type |=3D SKB_GSO_TCP_URG;
>  	}
> =20
>  	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location=
);
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 01edac8..c11d3d9 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -746,6 +746,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk=
_buff *skb, int features)
>  		       SKB_GSO_DODGY |
>  		       SKB_GSO_TCP_ECN |
>  		       SKB_GSO_TCPV6 |
> +		       SKB_GSO_TCP_URG |
>  		       0)))
>  		goto out;
> =20

