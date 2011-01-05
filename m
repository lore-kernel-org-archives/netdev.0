From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler
Date: Wed, 05 Jan 2011 07:02:25 +0100
Message-ID: <1294207345.3420.43.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44284 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab1AEGCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 01:02:30 -0500
Received: by wwa36 with SMTP id 36so15953938wwa.1
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 22:02:29 -0800 (PST)
In-Reply-To: <20110104162930.6fa672e3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 16:29 -0800, Stephen Hemminger a =C3=A9=
crit :
> This implements the CHOKe packet scheduler based on the existing
> Linux RED scheduler based on the algorithm described in the paper.
> Configuration is the same as RED; only the name changes.
>=20
> The core idea is:
>   For every packet arrival:
>   	Calculate Qave
> 	if (Qave < minth) {
> 	   Queue the new packet
> 	}
> 	Else {
> 	     Select randomly a packet from the queue for their flow id
> 	     Compare arriving packet with a randomly selected packet.
> 	     If they have the same flow id {
> 	     	Drop both the packets
> 	     }
> 	     Else {
> 	     	  if (Qave =E2=89=A5 maxth) {

you mean if (Qave is less than maxth) ?

> 		     Calculate the dropping probability pa
> 		     Drop the packet with probability pa
> 		  }
> 		  Else {
> 		     Drop the new packet
> 		  }
> 	     }
>        }
>=20
> This an early access version.
>=20

No ECN support at all ? even RED supports it :)

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>  net/sched/Kconfig     |   11 +
>  net/sched/Makefile    |    1=20
>  net/sched/sch_choke.c |  364 +++++++++++++++++++++++++++++++++++++++=
+++++++++++
>  3 files changed, 376 insertions(+)
>=20
> --- a/net/sched/Kconfig	2011-01-04 16:25:18.000000000 -0800
> +++ b/net/sched/Kconfig	2011-01-04 16:26:02.335973715 -0800
> @@ -205,6 +205,17 @@ config NET_SCH_DRR
> =20
>  	  If unsure, say N.
> =20
> +config NET_SCH_CHOKE
> +	tristate "CHOose and Keep responsive flow scheduler (CHOKE)"
> +	help
> +	  Say Y here if you want to use the CHOKe packet scheduler (CHOose
> +	  and Keep for responsive flows, CHOose and Kill for unresponsive
> +	  flows). This is a variation of RED which trys to penalize flows
> +	  that monopolize the queue.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called sch_choke.
> +
>  config NET_SCH_INGRESS
>  	tristate "Ingress Qdisc"
>  	depends on NET_CLS_ACT
> --- a/net/sched/Makefile	2011-01-04 16:25:18.000000000 -0800
> +++ b/net/sched/Makefile	2011-01-04 16:26:16.048938937 -0800
> @@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+=3D sch_mult
>  obj-$(CONFIG_NET_SCH_ATM)	+=3D sch_atm.o
>  obj-$(CONFIG_NET_SCH_NETEM)	+=3D sch_netem.o
>  obj-$(CONFIG_NET_SCH_DRR)	+=3D sch_drr.o
> +obj-$(CONFIG_NET_SCH_CHOKE)	+=3D sch_choke.o
>  obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
>  obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
>  obj-$(CONFIG_NET_CLS_FW)	+=3D cls_fw.o
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ b/net/sched/sch_choke.c	2011-01-04 16:25:33.913971468 -0800
> @@ -0,0 +1,364 @@
> +/*
> + * net/sched/sch_choke.c	CHOKE scheduler
> + *
> + * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/skbuff.h>
> +#include <linux/ipv6.h>
> +#include <linux/jhash.h>
> +#include <net/pkt_sched.h>
> +#include <net/ip.h>
> +#include <net/red.h>
> +#include <net/ipv6.h>
> +
> +/*	CHOKe stateless AQM for fair bandwidth allocation
> +        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +	Source:
> +	R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
> +	Active Queue Management Scheme for Approximating Fair Bandwidth All=
ocation",
> +	IEEE INFOCOM, 2000.
> +
> +	A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Spat=
ial
> +	Characteristics", IEEE/ACM Transactions on Networking, 2004
> +
> +	ADVANTAGE:
> +	- Penalizes unfair flows
> +	- Random drop provide gradual feedback
> +
> +	DRAWBACKS:
> +	- Small queue for single flow
> +	- Can be gamed by opening lots of connections
> +	- Hard to get correct paremeters (same problem as RED)

	Big packets are really unfair. Must disable TSO/GRO :)

> +
> + */
> +
> +struct choke_sched_data
> +{
> +	u32		  limit;
> +	unsigned char	  flags;
> +
> +	struct red_parms  parms;
> +	struct red_stats  stats;
> +};
> +
> +/* Select a packet at random from the list.
> + * Same caveats as skb_peek.
> + */
> +static struct sk_buff *skb_peek_random(struct sk_buff_head *list)
> +{
> +	struct sk_buff *skb =3D list->next;
> +	unsigned int idx =3D net_random() % list->qlen;
> +
> +	while (skb && idx-- > 0)
> +		skb =3D skb->next;

Ouch... A linked list (using in skb anchors) is not appropriate data
structure. Thats too many cache lines misses.

Maybe using a q->limit array of skb pointers ?

> +
> +	return skb;
> +}
> +
> +/* Given IP header and size find src/dst port pair */
> +static inline u32 get_ports(const void *hdr, size_t hdr_size, int of=
fset)
> +{
> +	return *(u32 *)(hdr + hdr_size + offset);
> +}
> +
> +
> +static bool same_flow(struct sk_buff *nskb, const struct sk_buff *os=
kb)
> +{
> +	if (nskb->protocol !=3D oskb->protocol)
> +		return false;
> +
> +	switch (nskb->protocol) {
> +	case htons(ETH_P_IP):
> +	{
> +		const struct iphdr *iph1, *iph2;
> +		int poff;
> +
> +		if (!pskb_network_may_pull(nskb, sizeof(*iph1)))
> +			return false;

Why isnt it necessary to also may_pull test oskb ?

> +
> +		iph1 =3D ip_hdr(nskb);
> +		iph2 =3D ip_hdr(oskb);
> +
> +		if (iph1->protocol !=3D iph2->protocol ||
> +		    iph1->daddr !=3D iph2->daddr ||
> +		    iph1->saddr !=3D iph2->saddr)
> +			return false;
> +
> +		/* Be hostile to new fragmented packets */
> +		if (iph1->frag_off & htons(IP_MF|IP_OFFSET))
> +			return true;
> +
> +		if (iph2->frag_off & htons(IP_MF|IP_OFFSET))
> +			return false;
> +
> +		poff =3D proto_ports_offset(iph1->protocol);
> +		if (poff >=3D 0 &&
> +		    pskb_network_may_pull(nskb, iph1->ihl * 4 + 4 + poff)) {
> +			iph1 =3D ip_hdr(nskb);
> +
> +			return get_ports(iph1, iph1->ihl * 4, poff)
> +				=3D=3D get_ports(iph2, iph2->ihl * 4, poff);
> +		}
> +
> +		return false;
> +	}
> +
> +	case htons(ETH_P_IPV6):
> +	{
> +		const struct ipv6hdr *iph1, *iph2;
> +		int poff;
> +
> +		if (!pskb_network_may_pull(nskb, sizeof(*iph1)))
> +			return false;

same here.

> +
> +		iph1 =3D ipv6_hdr(nskb);
> +		iph2 =3D ipv6_hdr(oskb);
> +
> +		if (iph1->nexthdr !=3D iph2->nexthdr ||
> +		    ipv6_addr_cmp(&iph1->daddr, &iph2->daddr) !=3D 0 ||
> +		    ipv6_addr_cmp(&iph1->saddr, &iph2->saddr) !=3D 0)
> +			return false;
> +
> +		poff =3D proto_ports_offset(iph1->nexthdr);
> +		if (poff >=3D 0 &&
> +		    pskb_network_may_pull(nskb, sizeof(*iph1) + 4 + poff)) {
> +			iph1 =3D ipv6_hdr(nskb);
> +
> +			return get_ports(iph1, sizeof(*iph1), poff)
> +				=3D=3D get_ports(iph2, sizeof(*iph2), poff);
> +		}
> +		return false;
> +	}
> +	default:
> +		return false;
> +	}
> +
> +}
> +
> +/*
> + * Decide what to do with new packet based on queue size.
> + * returns 1 if packet should be admitted
> + *         0 if packet should be dropped
> + */
> +static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	struct red_parms *p =3D &q->parms;
> +
> +	p->qavg =3D red_calc_qavg(p, skb_queue_len(&sch->q));
> +	if (red_is_idling(p))
> +		red_end_of_idle_period(p);
> +
> +	if (p->qavg <=3D p->qth_min)
> +		p->qcount =3D -1;
> +	else {
> +		struct sk_buff *oskb;
> +
> +		/* Draw a packet at random from queue */
> +		oskb =3D skb_peek_random(&sch->q);
> +
> +		/* Both packets from same flow? */
> +		if (same_flow(skb, oskb)) {
> +			/* Drop both packets */
> +			__skb_unlink(oskb, &sch->q);
> +			qdisc_drop(oskb, sch);
> +			goto congestion_drop;
> +		}
> +
> +		if (p->qavg > p->qth_max) {

ok, maybe CHOKe paper used : if (p->qavg >=3D p->qth_max)  ?

> +			p->qcount =3D -1;
> +
> +			sch->qstats.overlimits++;
> +			q->stats.forced_drop++;
> +			goto congestion_drop;
> +		}
> +
> +		if (++p->qcount) {
> +			if (red_mark_probability(p, p->qavg)) {
> +				p->qcount =3D 0;
> +				p->qR =3D red_random(p);
> +
> +				sch->qstats.overlimits++;
> +				q->stats.prob_drop++;
> +				goto congestion_drop;
> +			}
> +		} else
> +			p->qR =3D red_random(p);
> +	}
> +
> +	/* Admit new packet */
> +	if (likely(skb_queue_len(&sch->q) < q->limit))
> +		return qdisc_enqueue_tail(skb, sch);
> +
> +	q->stats.pdrop++;
> +	sch->qstats.drops++;
> +	kfree_skb(skb);
> +	return NET_XMIT_DROP;
> +
> + congestion_drop:
> +	qdisc_drop(skb, sch);
> +	return NET_XMIT_CN;
> +}
> +

