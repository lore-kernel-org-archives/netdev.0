From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.7)
Date: Thu, 13 Jan 2011 19:00:21 +0100
Message-ID: <1294941621.3570.419.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44274 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670Ab1AMSGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 13:06:35 -0500
Received: by wwa36 with SMTP id 36so2076300wwa.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 10:06:32 -0800 (PST)
In-Reply-To: <20110113092706.154748c2@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 09:27 -0800, Stephen Hemminger a =C3=A9=
crit :
> This implements the CHOKe packet scheduler based on the existing
> Linux RED scheduler based on the algorithm described in the paper.
>=20
> The core idea is:
>   For every packet arrival:
>   	Calculate Qave
> 	if (Qave < minth)=20
> 	     Queue the new packet
> 	else=20
> 	     Select randomly a packet from the queue=20
> 	     if (both packets from same flow)
> 	     then Drop both the packets
> 	     else if (Qave > maxth)
> 	          Drop packet
> 	     else
> 	       	  Admit packet with proability p (same as RED)
>=20
> See also:
>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statele=
ss active
>    queue management scheme for approximating fair bandwidth allocatio=
n",=20
>   Proceeding of INFOCOM'2000, March 2000.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> Patch versions
> 0.3 (Eric) uses table for queue.
> 0.4 allows classification with TC filters
>     fixes crash when peek_random() finds a hole
> 0.5 (Eric) that fixes qlen with holes and peek
> 0.7 change to use separate params / stats than RED
>     account for drops in backlog
>=20
> Almost ready, still need to make sure API (netlink) is right
>=20
>=20
>  net/sched/Kconfig     |   11 +
>  net/sched/Makefile    |    1=20
>  net/sched/sch_choke.c |  536 +++++++++++++++++++++++++++++++++++++++=
+++++++++++
>  3 files changed, 548 insertions(+)
>=20
> --- a/net/sched/Kconfig	2011-01-12 17:44:05.747500044 -0800
> +++ b/net/sched/Kconfig	2011-01-12 17:44:53.167735188 -0800
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
> --- a/net/sched/Makefile	2011-01-12 17:44:05.767500135 -0800
> +++ b/net/sched/Makefile	2011-01-12 17:44:53.167735188 -0800
> @@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+=3D sch_mult
>  obj-$(CONFIG_NET_SCH_ATM)	+=3D sch_atm.o
>  obj-$(CONFIG_NET_SCH_NETEM)	+=3D sch_netem.o
>  obj-$(CONFIG_NET_SCH_DRR)	+=3D sch_drr.o
> +obj-$(CONFIG_NET_SCH_CHOKE)	+=3D sch_choke.o
>  obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
>  obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
>  obj-$(CONFIG_NET_CLS_FW)	+=3D cls_fw.o
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ b/net/sched/sch_choke.c	2011-01-12 17:45:07.227806180 -0800
> @@ -0,0 +1,556 @@
> +/*
> + * net/sched/sch_choke.c	CHOKE scheduler
> + *
> + * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
> + * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
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
> +#include <linux/reciprocal_div.h>
> +#include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +#include <net/red.h>
> +
> +/*	CHOKe stateless AQM for fair bandwidth allocation
> +        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
> +   unresponsive flows) is a variant of RED that penalizes misbehavin=
g flows but
> +   maintains no flow state. The difference from RED is an additional=
 step
> +   during the enqueuing process. If average queue size is over the
> +   low threshold (qmin), a packet is chosen at random from the queue=
=2E
> +   If both the new and chosen packet are from the same flow, both
> +   are dropped. Unlike RED, CHOKe is not really a "classful" qdisc b=
ecause it
> +   needs to access packets in queue randomly. It has a minimal class
> +   interface to allow overriding the builtin flow classifier with
> +   filters.
> +
> +   Source:
> +   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
> +   Active Queue Management Scheme for Approximating Fair Bandwidth A=
llocation",
> +   IEEE INFOCOM, 2000.
> +
> +   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Sp=
atial
> +   Characteristics", IEEE/ACM Transactions on Networking, 2004
> +
> + */
> +
> +/* Upper bound on size of sk_buff table */
> +#define CHOKE_MAX_QUEUE	(128*1024 - 1)
> +
> +struct choke_sched_data {
> +/* Parameters */
> +	u32		 limit;
> +	unsigned char	 flags;
> +
> +	struct red_parms parms;
> +
> +/* Variables */
> +	struct tcf_proto *filter_list;
> +	struct {
> +		u32	prob_drop;	/* Early probability drops */
> +		u32	prob_mark;	/* Early probability marks */
> +		u32	forced_drop;	/* Forced drops, qavg > max_thresh */
> +		u32	forced_mark;	/* Forced marks, qavg > max_thresh */
> +		u32	pdrop;          /* Drops due to queue limits */
> +		u32	other;          /* Drops due to drop() calls */
> +		u32	matched;	/* Drops to flow match */
> +	} stats;
> +
> +	unsigned int	 head;
> +	unsigned int	 tail;
> +	unsigned int	 holes;
> +	unsigned int	 tab_mask; /* size - 1 */
> +
> +	struct sk_buff **tab;
> +};
> +
> +static inline unsigned int choke_len(const struct choke_sched_data *=
q)
> +{
> +	return (q->tail - q->head) & q->tab_mask;
> +}
> +
> +/* deliver a random number between 0 and N - 1 */
> +static inline u32 random_N(unsigned int N)
> +{
> +	return reciprocal_divide(random32(), N);
> +}
> +
> +/* Select a packet at random from the queue in O(1) and handle holes=
 */
> +static struct sk_buff *choke_peek_random(struct choke_sched_data *q,
> +					 unsigned int *pidx)
> +{
> +	struct sk_buff *skb;
> +	int retrys =3D 3;
> +
> +	do {
> +		*pidx =3D (q->head + random_N(choke_len(q))) & q->tab_mask;
> +		skb =3D q->tab[*pidx];
> +		if (skb)
> +			return skb;
> +	} while (--retrys > 0);
> +
> +	/* queue is has lots of holes use the head which is known to exist =
*/
> +	return q->tab[*pidx =3D q->head];
> +}
> +
> +/* Is ECN parameter configured */
> +static inline int use_ecn(const struct choke_sched_data *q)
> +{
> +	return q->flags & TC_RED_ECN;
> +}
> +
> +/* Should packets over max just be dropped (versus marked) */
> +static inline int use_harddrop(const struct choke_sched_data *q)
> +{
> +	return q->flags & TC_RED_HARDDROP;
> +}
> +
> +/* Move head pointer forward to skip over holes */
> +static void choke_zap_head_holes(struct choke_sched_data *q)
> +{
> +	while (q->holes && q->tab[q->head] =3D=3D NULL) {
> +		q->head =3D (q->head + 1) & q->tab_mask;
> +		q->holes--;
> +	}
> +}
> +
> +/* Move tail pointer backwards to reuse holes */
> +static void choke_zap_tail_holes(struct choke_sched_data *q)
> +{
> +	while (q->holes && q->tab[q->tail - 1] =3D=3D NULL) {
> +		q->tail =3D (q->tail - 1) & q->tab_mask;
> +		q->holes--;
> +	}
> +}
> +
> +/* Drop packet from queue array by creating a "hole" */
> +static void choke_drop_by_idx(struct choke_sched_data *q, unsigned i=
nt idx)
> +{
> +	q->tab[idx] =3D NULL;
> +	q->holes++;
> +
> +	if (idx =3D=3D q->head)
> +		choke_zap_head_holes(q);
> +	if (idx =3D=3D q->tail)
> +		choke_zap_tail_holes(q);
> +}
> +
> +/* Classify flow using either:
> +   1. pre-existing classification result in skb
> +   2. fast internal classification
> +   3. use TC filter based classification
> +*/
> +static inline unsigned int choke_classify(struct sk_buff *skb,
> +					  struct Qdisc *sch, int *qerr)
> +
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	struct tcf_result res;
> +	int result;
> +
> +	*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
> +
> +	if (TC_H_MAJ(skb->priority) =3D=3D sch->handle &&
> +	    TC_H_MIN(skb->priority) > 0)
> +		return TC_H_MIN(skb->priority);
> +
> +	if (!q->filter_list)
> +		return skb_get_rxhash(skb);
> +
> +	result =3D tc_classify(skb, q->filter_list, &res);
> +	if (result >=3D 0) {
> +#ifdef CONFIG_NET_CLS_ACT
> +		switch (result) {
> +		case TC_ACT_STOLEN:
> +		case TC_ACT_QUEUED:
> +			*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
> +		case TC_ACT_SHOT:
> +			return 0;
> +		}
> +#endif
> +		return TC_H_MIN(res.classid);
> +	}
> +
> +	return 0;
> +}
> +
> +static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	struct red_parms *p =3D &q->parms;
> +	unsigned int hash;
> +	int uninitialized_var(ret);
> +
> +	hash =3D choke_classify(skb, sch, &ret);
> +	if (!hash) {
> +		/* Packet was eaten by filter */
> +		if (ret & __NET_XMIT_BYPASS)
> +			sch->qstats.drops++;
> +		kfree_skb(skb);
> +		return ret;
> +	}
> +
> +	/* Maybe add hash as field in struct qdisc_skb_cb? */
> +	*(unsigned int *)(qdisc_skb_cb(skb)->data) =3D hash;
> +
> +	/* Compute average queue usage (see RED) */
> +	p->qavg =3D red_calc_qavg(p, choke_len(q) - q->holes);
> +	if (red_is_idling(p))
> +		red_end_of_idle_period(p);
> +
> +	/* Is queue small? */
> +	if (p->qavg <=3D p->qth_min)
> +		p->qcount =3D -1;
> +	else {
> +		struct sk_buff *oskb;
> +		unsigned int idx;
> +
> +		/* Draw a packet at random from queue */
> +		oskb =3D choke_peek_random(q, &idx);
> +
> +		/* Both packets from same flow ? */
> +		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) =3D=3D hash) {
> +			/* Drop both packets */
> +			q->stats.matched++;
> +			choke_drop_by_idx(q, idx);
> +			qdisc_drop(oskb, sch);

I feel we should add : sch->q.qlen--;

> +			goto congestion_drop;
> +		}
> +
> +		/* Queue is large, always mark/drop */
> +		if (p->qavg > p->qth_max) {
> +			p->qcount =3D -1;
> +
> +			sch->qstats.overlimits++;
> +			if (use_harddrop(q) || !use_ecn(q) ||
> +			    !INET_ECN_set_ce(skb)) {
> +				q->stats.forced_drop++;
> +				goto congestion_drop;
> +			}
> +
> +			q->stats.forced_mark++;
> +		} else if (++p->qcount) {
> +			if (red_mark_probability(p, p->qavg)) {
> +				p->qcount =3D 0;
> +				p->qR =3D red_random(p);
> +
> +				sch->qstats.overlimits++;
> +				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
> +					q->stats.prob_drop++;
> +					goto congestion_drop;
> +				}
> +
> +				q->stats.prob_mark++;
> +			}
> +		} else
> +			p->qR =3D red_random(p);
> +	}
> +
> +	/* Admit new packet */
> +	if (likely(choke_len(q) < q->limit)) {
> +
> +		q->tab[q->tail] =3D skb;
> +		q->tail =3D (q->tail + 1) & q->tab_mask;
> +
> +		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> +		qdisc_update_bstats(sch, skb);
> +		sch->q.qlen =3D choke_len(q) - q->holes;
	or : sch->q.qlen++;

(If sch->q.qlen is up2date in respect of above comment)

> +		return NET_XMIT_SUCCESS;
> +	}
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
> +static struct sk_buff *choke_dequeue(struct Qdisc *sch)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	struct sk_buff *skb;
> +
> +	if (q->head =3D=3D q->tail) {
> +		if (!red_is_idling(&q->parms))
> +			red_start_of_idle_period(&q->parms);
> +		return NULL;
> +	}
> +	skb =3D q->tab[q->head];
> +	q->tab[q->head] =3D NULL; /* not really needed */
> +	q->head =3D (q->head + 1) & q->tab_mask;
> +	choke_zap_head_holes(q);
> +	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
> +	sch->q.qlen =3D choke_len(q) - q->holes;

	sch->q.qlen--;

> +
> +	return skb;
> +}
> +
> +static unsigned int choke_drop(struct Qdisc *sch)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +	unsigned int len;
> +
> +	len =3D qdisc_queue_drop(sch);
> +	if (len > 0)
> +		q->stats.other++;
> +	else {
> +		if (!red_is_idling(&q->parms))
> +			red_start_of_idle_period(&q->parms);
> +	}
> +
> +	return len;
> +}
> +
> +static void choke_reset(struct Qdisc* sch)
> +{
> +	struct choke_sched_data *q =3D qdisc_priv(sch);
> +
> +	red_restart(&q->parms);
> +}
> +
> +static const struct nla_policy choke_policy[TCA_CHOKE_MAX + 1] =3D {
> +	[TCA_CHOKE_PARMS]	=3D { .len =3D sizeof(struct tc_red_qopt) },
> +	[TCA_CHOKE_STAB]	=3D { .len =3D 256 },

RED_STAB_SIZE ?


Thanks !


