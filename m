From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.10)
Date: Thu, 20 Jan 2011 19:19:49 +0100
Message-ID: <1295547589.2825.497.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
	 <1295077542.3977.20.camel@edumazet-laptop>
	 <20110117092532.7d5f5a5b@nehalam>
	 <1295286851.3335.36.camel@edumazet-laptop>
	 <20110118110634.7386c757@nehalam> <1295379257.9097.9.camel@edumazet-laptop>
	 <20110120093838.43f9f9b1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55765 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab1ATSTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 13:19:54 -0500
Received: by wyb28 with SMTP id 28so904709wyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 10:19:53 -0800 (PST)
In-Reply-To: <20110120093838.43f9f9b1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 09:38 -0800, Stephen Hemminger a =C3=A9=
crit :

=2E..

Hi Stephen

I am contemplating choke_linearize_header() (yet another hash
function... oh well...) and say :

Instead of this boolean return, just use skb_get_rxhash(). It performs
what you want, and return 32bits of information, instead of one bit.

(if result (rxhash) is zero, it means you can drop packet because it is
not linearized)

So choke_match_flow() can be faster if rxhash differs (no cache miss on
skb->data on an old skb)
(Do the full check only if rxhash is equal on skb1 / skb2)

More over, the skb_get_rxhash() call is _really_ needed only if CHOKe
triggers :
if (p->qavg <=3D p->qth_min)
	we dont have to compute rxhash at all.

> +/* Make sure network and transport headers can be dereferenced */
> +static bool choke_linearize_header(struct sk_buff *skb)
> +{
> +	int nhoff, poff;
> +	struct ipv6hdr *ip6;
> +	struct iphdr *ip;
> +	u8 ip_proto;
> +	u32 ihl;
> +
> +	nhoff =3D skb_network_offset(skb);
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
> +			return false;
> +
> +		ip =3D (struct iphdr *) (skb->data + nhoff);
> +		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
> +			return false;
> +
> +		ip_proto =3D ip->protocol;
> +		ihl =3D ip->ihl;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
> +			return false;
> +
> +		ip6 =3D (struct ipv6hdr *) (skb->data + nhoff);
> +		ip_proto =3D ip6->nexthdr;
> +		ihl =3D (40 >> 2);
> +		break;
> +	default:
> +		return true;
> +	}
> +
> +	poff =3D proto_ports_offset(ip_proto);
> +	if (poff >=3D 0) {
> +		nhoff +=3D ihl * 4 + poff;
> +		if (!pskb_may_pull(skb, nhoff + 4))
> +			return false;
> +	}
> +
> +	return true;
> +}
> +


> +/*
> + * Compare flow of two packets
> + *  Returns true only if source and destination address and port mat=
ch.
> + *          false for special cases
> + */
> +static bool choke_match_flow(const struct sk_buff *skb1,
> +			     const struct sk_buff *skb2)
> +{
> +	int off1, off2, poff;
> +
> +	if (skb1->protocol !=3D skb2->protocol)
> +		return false;
> +
> +	off1 =3D skb_network_offset(skb1);
> +	off2 =3D skb_network_offset(skb2);
> +
> +	switch (skb1->protocol) {
> +	case __constant_htons(ETH_P_IP): {
> +		const struct iphdr *ip1, *ip2;
> +
> +		ip1 =3D (struct iphdr *) (skb1->data + off1);
> +		ip2 =3D (struct iphdr *) (skb2->data + off2);
> +
> +		if (ip1->protocol !=3D ip2->protocol ||
> +		    ip1->saddr !=3D ip2->saddr || ip1->daddr !=3D ip2->daddr)
> +			return false;
> +
> +		if (ip1->frag_off & htons(IP_MF | IP_OFFSET) ||
> +		    ip2->frag_off & htons(IP_MF | IP_OFFSET))
> +			return ip1->id =3D=3D ip2->id;
> +
> +		poff =3D proto_ports_offset(ip1->protocol);
> +		if (poff < 0)
> +			return true;
> +		else {
> +			const u32 *ports1, *ports2;
> +
> +			ports1 =3D (__force u32 *) (skb1->data + off1
> +						  + ip1->ihl * 4 + poff);
> +			ports2 =3D (__force u32 *) (skb2->data + off2
> +						  + ip2->ihl * 4 + poff);
> +
> +			return *ports1 =3D=3D *ports2;
> +		}
> +		break;
> +	}
> +
> +	case __constant_htons(ETH_P_IPV6): {
> +		const struct ipv6hdr *ip1, *ip2;
> +
> +		ip1 =3D (struct ipv6hdr *) (skb1->data + off1);
> +		ip2 =3D (struct ipv6hdr *) (skb2->data + off2);
> +
> +		return (ip1->nexthdr =3D=3D ip2->nexthdr &&
> +			ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) =3D=3D 0 &&
> +			ipv6_addr_cmp(&ip1->daddr, &ip2->daddr) =3D=3D 0);

Hmm, we also need to check ports, you might just move the check from
case __constant_htons(ETH_P_IP) after the switch(skb1->protocol)


> +	}
> +
> +	default: /* Maybe compare MAC header here? */
> +		return false;
> +	}
> +	/* not reached */
> +}
> +

If you want, I can send a diff on your v0.10, just tell me !

Thanks !


