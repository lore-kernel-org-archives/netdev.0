From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.9)
Date: Tue, 18 Jan 2011 20:34:17 +0100
Message-ID: <1295379257.9097.9.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
	 <1295077542.3977.20.camel@edumazet-laptop>
	 <20110117092532.7d5f5a5b@nehalam>
	 <1295286851.3335.36.camel@edumazet-laptop>
	 <20110118110634.7386c757@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64081 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab1ARTft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 14:35:49 -0500
Received: by wyb28 with SMTP id 28so6490640wyb.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 11:35:46 -0800 (PST)
In-Reply-To: <20110118110634.7386c757@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 janvier 2011 =C3=A0 11:06 -0800, Stephen Hemminger a =C3=A9=
crit :

> +static bool choke_match_flow(struct sk_buff *skb1, struct sk_buff *s=
kb2)
> +{
> +	int off1, off2, poff;
> +	u8 ip_proto;
> +	u32 ihl;
> +
> +	if (skb1->protocol !=3D skb2->protocol)
> +		return false;
> +
> +	off1 =3D skb_network_offset(skb1);
> +	off2 =3D skb_network_offset(skb2);

> +
> +	switch (skb1->protocol) {
> +	case __constant_htons(ETH_P_IP): {
> +		struct iphdr *ip1, *ip2;
> +
> +		if (!pskb_may_pull(skb1, sizeof(struct iphdr) + off1))
> +			return false;
> +
	pskb_network_may_pull() might be cleaner


> +		ip1 =3D (struct iphdr *) (skb1->data + off1);
	ip1 =3D ip_hdr(skb);

> +		if (ip1->frag_off & htons(IP_MF | IP_OFFSET))
> +			return false;	/* don't compare fragments */
> +

Hmm, we should compare fragments if possible.

saddr/daddr are available, not the ports.

> +		if (!pskb_may_pull(skb2, sizeof(struct iphdr) + off2))
> +			return false;
> +
> +		ip2 =3D (struct iphdr *) (skb2->data + off2);
> +		if (ip2->frag_off & htons(IP_MF | IP_OFFSET))
> +			return false;
> +
> +		if (ip1->protocol !=3D ip2->protocol ||
> +		    ip1->saddr !=3D ip2->saddr || ip1->daddr !=3D ip2->daddr)
> +			return false;
> +


	What happens if ip1->ihl !=3D ip2->ihl  here ?

Here I would add the fragment test :

	if ((ip1->frag_off | ip2->frag_off)) & htons(IP_MF | IP_OFFSET))
		return true;

> +		ip_proto =3D ip1->protocol;
> +		ihl =3D ip1->ihl;
> +		break;
> +	}
> +
> +	case __constant_htons(ETH_P_IPV6): {
> +		struct ipv6hdr *ip1, *ip2;
> +
> +		if (!pskb_may_pull(skb1, sizeof(struct ipv6hdr *) + off1))
> +			return false;

ouch... sizeof(sizeof(struct ipv6hdr *) is not what you want but
sizeof(struct ipv6hdr) is.

So just use :

	pskb_network_may_pull(skb1, sizeof(*ip1))
> +
> +		if (!pskb_may_pull(skb2, sizeof(struct ipv6hdr *) + off2))
> +			return false;
> +
> +		ip1 =3D (struct ipv6hdr *) (skb1->data + off1);
	ip1 =3D ipv6_hdr(skb1);
> +		ip2 =3D (struct ipv6hdr *) (skb2->data + off2);
> +
> +		if (ip1->nexthdr !=3D ip2->nexthdr ||
> +		    ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) !=3D 0 ||
> +		    ipv6_addr_cmp(&ip1->daddr, &ip2->daddr))
> +			return false;
> +
> +		ihl =3D (40 >> 2);
> +		ip_proto =3D ip1->nexthdr;
> +		break;
> +	}
> +
> +	default:
> +		return false;
> +	}
> +



