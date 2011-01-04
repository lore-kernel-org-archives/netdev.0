From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Tue, 04 Jan 2011 19:29:24 +0100
Message-ID: <1294165764.3579.135.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <20110103095842.7677130d@nehalam>
	 <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
	 <1294153329.3579.99.camel@edumazet-laptop>
	 <1294165215.3579.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45684 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab1ADS33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 13:29:29 -0500
Received: by wwa36 with SMTP id 36so15452403wwa.1
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 10:29:28 -0800 (PST)
In-Reply-To: <1294165215.3579.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 19:20 +0100, Eric Dumazet a =C3=A9crit =
:

> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index d54ac94..4f958e3 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -24,6 +24,8 @@
>  #include <net/ip.h>
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +#include <linux/moduleparam.h>
> =20
>=20
>  /*	Stochastic Fairness Queuing algorithm.
> @@ -86,6 +88,10 @@
>  /* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
>  typedef unsigned char sfq_index;
> =20
> +static int red_delay; /* default : no RED handling */
> +module_param(red_delay, int, 0);
> +MODULE_PARM_DESC(red_delay, "mark/drop packets if they stay in queue=
 longer than red_delay ticks");
> +
>  /*
>   * We dont use pointers to save space.
>   * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] arr=
ay
> @@ -391,6 +397,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
> =20
>  	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
>  	slot_queue_add(slot, skb);
> +	qdisc_skb_cb(skb)->timestamp =3D jiffies;
>  	sfq_inc(q, x);
>  	if (slot->qlen =3D=3D 1) {		/* The flow is new */
>  		if (q->tail =3D=3D NULL) {	/* It is the first flow */
> @@ -402,11 +409,8 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *s=
ch)
>  		q->tail =3D slot;
>  		slot->allot =3D q->scaled_quantum;
>  	}
> -	if (++sch->q.qlen <=3D q->limit) {
> -		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
> -		sch->bstats.packets++;
> +	if (++sch->q.qlen <=3D q->limit)
>  		return NET_XMIT_SUCCESS;
> -	}
> =20
>  	sfq_drop(sch);
>  	return NET_XMIT_CN;
> @@ -432,6 +436,7 @@ sfq_dequeue(struct Qdisc *sch)
>  	sfq_index a, next_a;
>  	struct sfq_slot *slot;
> =20
> +restart:
>  	/* No active slots */
>  	if (q->tail =3D=3D NULL)
>  		return NULL;
> @@ -455,12 +460,36 @@ next_slot:
>  		next_a =3D slot->next;
>  		if (a =3D=3D next_a) {
>  			q->tail =3D NULL; /* no more active slots */
> +			/* last packet queued, dont even try to apply RED */

And of course I should do "goto end;" to properly do accounting,
or maybe do the RED thing after all ;)

>  			return skb;
>  		}
>  		q->tail->next =3D next_a;
>  	} else {
>  		slot->allot -=3D SFQ_ALLOT_SIZE(qdisc_pkt_len(skb));
>  	}
> +	if (red_delay) {
> +		long delay =3D jiffies - qdisc_skb_cb(skb)->timestamp;
> +
> +		if (delay >=3D red_delay) {
> +			long Px =3D delay * (0xFFFFFF / 100); /* 1 percent per jiffy */
> +			if ((net_random() & 0xFFFFFF) < Px) {
> +				if (INET_ECN_set_ce(skb)) {
> +					/* no ecnmark counter yet :) */
> +					sch->qstats.overlimits++;
> +				} else {
> +					/* penalize this flow : we drop the=20
> +					 * packet while we changed slot->allot
> +					 */
> +					kfree_skb(skb);
> +					/* no early_drop counter yet :) */
> +					sch->qstats.drops++;
> +					goto restart;
> +				}
> +			}
> +		}
> +	}

end:

> +	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
> +	sch->bstats.packets++;
>  	return skb;
>  }
> =20
>=20


