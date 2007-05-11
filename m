From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH net-2.6] [IPV6]: Restore semantics of Routing Header processing.
Date: Fri, 11 May 2007 15:06:54 -0400
Message-ID: <4644BECE.70508@hp.com>
References: <20070512.011718.121506964.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:40761 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbXEKTH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 15:07:26 -0400
In-Reply-To: <20070512.011718.121506964.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji-san

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> The "fix" for emerging security threats was overkill and it broke
> basic semantic of IPv6 routing header processing.  We should assume
> RT0 (or even RT2, depends on configuration) as "unknown" RH type so
> that we
> - silently ignore the routing header if segleft =3D=3D 0,
> - or, send ICMPv6 Parameter Problem message back to the sender,
>   otherwise.

Aren't we jumping the gun a little here...

Things still are not exactly clear in the IPv6 working group.
Especially the whole segleft =3D=3D 0 thing is another item that
we might have to fix eventually.

-vlad


>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/exthdrs.c |   47 ++++++++++++++++--------------------------=
-----
>  1 files changed, 16 insertions(+), 31 deletions(-)
>=20
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index 14be0b9..05e9bb5 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -371,22 +371,13 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp=
)
>  	struct rt0_hdr *rthdr;
>  	int accept_source_route =3D ipv6_devconf.accept_source_route;
> =20
> -	if (accept_source_route < 0 ||
> -	    ((idev =3D in6_dev_get(skb->dev)) =3D=3D NULL)) {
> -		kfree_skb(skb);
> -		return -1;
> -	}
> -	if (idev->cnf.accept_source_route < 0) {
> +	idev =3D in6_dev_get(skb->dev);
> +	if (idev) {
> +		if (accept_source_route > idev->cnf.accept_source_route)
> +			accept_source_route =3D idev->cnf.accept_source_route;
>  		in6_dev_put(idev);
> -		kfree_skb(skb);
> -		return -1;
>  	}
> =20
> -	if (accept_source_route > idev->cnf.accept_source_route)
> -		accept_source_route =3D idev->cnf.accept_source_route;
> -
> -	in6_dev_put(idev);
> -
>  	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
>  	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
>  				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
> @@ -398,24 +389,6 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
> =20
>  	hdr =3D (struct ipv6_rt_hdr *)skb_transport_header(skb);
> =20
> -	switch (hdr->type) {
> -#ifdef CONFIG_IPV6_MIP6
> -	case IPV6_SRCRT_TYPE_2:
> -		break;
> -#endif
> -	case IPV6_SRCRT_TYPE_0:
> -		if (accept_source_route > 0)
> -			break;
> -		kfree_skb(skb);
> -		return -1;
> -	default:
> -		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
> -				 IPSTATS_MIB_INHDRERRORS);
> -		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
> -				  (&hdr->type) - skb_network_header(skb));
> -		return -1;
> -	}
> -
>  	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
>  	    skb->pkt_type !=3D PACKET_HOST) {
>  		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
> @@ -454,6 +427,8 @@ looped_back:
> =20
>  	switch (hdr->type) {
>  	case IPV6_SRCRT_TYPE_0:
> +		if (accept_source_route <=3D 0)
> +			goto unknown_rh;
>  		if (hdr->hdrlen & 0x01) {
>  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
>  					 IPSTATS_MIB_INHDRERRORS);
> @@ -465,6 +440,8 @@ looped_back:
>  		break;
>  #ifdef CONFIG_IPV6_MIP6
>  	case IPV6_SRCRT_TYPE_2:
> +		if (accept_source_route < 0)
> +			goto unknown_rh;
>  		/* Silently discard invalid RTH type 2 */
>  		if (hdr->hdrlen !=3D 2 || hdr->segments_left !=3D 1) {
>  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
> @@ -474,6 +451,8 @@ looped_back:
>  		}
>  		break;
>  #endif
> +	default:
> +		goto unknown_rh;
>  	}
> =20
>  	/*
> @@ -577,6 +556,12 @@ looped_back:
>  	skb_push(skb, skb->data - skb_network_header(skb));
>  	dst_input(skb);
>  	return -1;
> +
> +unknown_rh:
> +	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
> +	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
> +			  (&hdr->type) - skb_network_header(skb));
> +	return -1;
>  }
> =20
>  static struct inet6_protocol rthdr_protocol =3D {

