From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Mon, 10 Jan 2011 14:46:50 +0100
Message-ID: <1294667210.3491.7.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41023 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715Ab1AJNqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 08:46:55 -0500
Received: by wwa36 with SMTP id 36so670814wwa.1
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 05:46:54 -0800 (PST)
In-Reply-To: <20110106205549.0de56de1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 20:55 -0800, Stephen Hemminger a =C3=A9=
crit :

>=20
> The problem is that large tables of pointers in kernel require either
> contiguous allocation or some indirect table algorithm.
>=20

Here is a v3 version with an array based queue for O(1) peek_random
complexity.

Could you send the iproute2 patch so that I can test it ?

Thanks !


diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index e69de29..ea9db00 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -0,0 +1,388 @@
+/*
+ * net/sched/sch_choke.c	CHOKE scheduler
+ *
+ * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
+ * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/reciprocal_div.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <net/red.h>
+
+/*	CHOKe stateless AQM for fair bandwidth allocation
+        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
+   unresponsive flows) is a variant of RED that penalizes misbehaving =
flows but
+   maintains no flow state. The difference from RED is an additional s=
tep
+   during the enqueuing process. If average queue size is over the
+   low threshold (qmin), a packet is chosen at random from the queue.
+   If both the new and chosen packet are from the same flow, both
+   are dropped. Unlike RED, CHOKe is not a "classful" qdisc because it
+   needs to access packets in queue randomly.
+
+   Source:
+   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
+   Active Queue Management Scheme for Approximating Fair Bandwidth All=
ocation",
+   IEEE INFOCOM, 2000.
+
+   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Spat=
ial
+   Characteristics", IEEE/ACM Transactions on Networking, 2004
+
+ */
+
+struct choke_sched_data {
+	u32		 limit;
+	unsigned char	 flags;
+
+	struct red_parms parms;
+	struct red_stats stats;
+
+	unsigned int	 head;
+	unsigned int	 tail;
+	unsigned int	 holes;
+	unsigned int	 tab_mask; /* size - 1 */
+	struct sk_buff **tab;
+};
+
+static inline unsigned int choke_len(const struct choke_sched_data *q)
+{
+	return (q->tail - q->head) & q->tab_mask;
+}
+
+/* deliver a random number between 0 and N - 1 */
+static inline u32 random_N(unsigned int N)
+{
+	return reciprocal_divide(random32(), N);
+}
+
+/* Select a packet at random from the queue in O(1) */
+static struct sk_buff *choke_peek_random(struct choke_sched_data *q, u=
nsigned int *pidx)
+{
+	*pidx =3D (q->head + random_N(choke_len(q))) & q->tab_mask;
+	return q->tab[*pidx];
+}
+
+
+static inline int use_ecn(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_ECN;
+}
+
+static inline int use_harddrop(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_HARDDROP;
+}
+
+static inline void choke_zap_head_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->head] =3D=3D NULL) {
+		q->head =3D (q->head + 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+static inline void choke_zap_tail_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->tail - 1] =3D=3D NULL) {
+		q->tail =3D (q->tail - 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+static void choke_drop_by_idx(struct choke_sched_data *q, unsigned int=
 idx)
+{
+	q->tab[idx] =3D NULL;
+	q->holes++;
+	choke_zap_head_holes(q);
+	choke_zap_tail_holes(q);
+}
+
+
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct red_parms *p =3D &q->parms;
+
+	p->qavg =3D red_calc_qavg(p, choke_len(q) - q->holes);
+	if (red_is_idling(p))
+		red_end_of_idle_period(p);
+
+	if (p->qavg <=3D p->qth_min)
+		p->qcount =3D -1;
+	else {
+		struct sk_buff *oskb;
+		unsigned int idx;
+
+		/* Draw a packet at random from queue */
+		oskb =3D choke_peek_random(q, &idx);
+
+		/* Both packets from same flow ? */
+		if (oskb && skb_get_rxhash(oskb) =3D=3D skb_get_rxhash(skb)) {
+			/* Drop both packets */
+			choke_drop_by_idx(q, idx);
+			qdisc_drop(oskb, sch);
+			goto congestion_drop;
+		}
+
+		if (p->qavg > p->qth_max) {
+			p->qcount =3D -1;
+
+			sch->qstats.overlimits++;
+			if (use_harddrop(q) || !use_ecn(q) ||
+			    !INET_ECN_set_ce(skb)) {
+				q->stats.forced_drop++;
+				goto congestion_drop;
+			}
+
+			q->stats.forced_mark++;
+		}
+
+		if (++p->qcount) {
+			if (red_mark_probability(p, p->qavg)) {
+				p->qcount =3D 0;
+				p->qR =3D red_random(p);
+
+				sch->qstats.overlimits++;
+				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
+					q->stats.prob_drop++;
+					goto congestion_drop;
+				}
+
+				q->stats.prob_mark++;
+			}
+		} else
+			p->qR =3D red_random(p);
+	}
+
+	/* Admit new packet */
+	if (likely(choke_len(q) < q->limit)) {
+		q->tab[q->tail] =3D skb;
+		q->tail =3D (q->tail + 1) & q->tab_mask;
+		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
+		__qdisc_update_bstats(sch, qdisc_pkt_len(skb));
+		return NET_XMIT_SUCCESS;
+	}
+	q->stats.pdrop++;
+	sch->qstats.drops++;
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
+
+ congestion_drop:
+	qdisc_drop(skb, sch);
+	return NET_XMIT_CN;
+}
+
+static struct sk_buff *choke_dequeue(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	if (q->head =3D=3D q->tail) {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+		return NULL;
+	}
+	skb =3D q->tab[q->head];
+	q->tab[q->head] =3D NULL; /* not really needed */
+	q->head =3D (q->head + 1) & q->tab_mask;
+	choke_zap_head_holes(q);
+	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+
+	return skb;
+}
+
+static unsigned int choke_drop(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	unsigned int len;
+
+	len =3D qdisc_queue_drop(sch);
+
+	if (len > 0)
+		q->stats.other++;
+	else {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+	}
+
+	return len;
+}
+
+static void choke_reset(struct Qdisc* sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	red_restart(&q->parms);
+}
+
+static const struct nla_policy choke_policy[TCA_RED_MAX + 1] =3D {
+	[TCA_RED_PARMS]	=3D { .len =3D sizeof(struct tc_red_qopt) },
+	[TCA_RED_STAB]	=3D { .len =3D RED_STAB_SIZE },
+};
+
+
+static void choke_free(void *addr)
+{
+	if (addr) {
+		if (is_vmalloc_addr(addr))
+			vfree(addr);
+		else
+			kfree(addr);
+	}
+}
+
+static int choke_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *tb[TCA_RED_MAX + 1];
+	struct tc_red_qopt *ctl;
+	int err;
+	struct sk_buff **old =3D NULL;
+	unsigned int mask;
+
+	if (opt =3D=3D NULL)
+		return -EINVAL;
+
+	err =3D nla_parse_nested(tb, TCA_RED_MAX, opt, choke_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_RED_PARMS] =3D=3D NULL ||
+	    tb[TCA_RED_STAB] =3D=3D NULL)
+		return -EINVAL;
+
+	ctl =3D nla_data(tb[TCA_RED_PARMS]);
+
+	mask =3D roundup_pow_of_two(ctl->limit + 1) - 1;
+	if (mask !=3D q->tab_mask) {
+		struct sk_buff **ntab =3D kcalloc(mask + 1, sizeof(struct sk_buff *)=
,
+						GFP_KERNEL);
+		if (!ntab)
+			ntab =3D vzalloc((mask + 1) * sizeof(struct sk_buff *));
+		if (!ntab)
+			return -ENOMEM;
+		sch_tree_lock(sch);
+		old =3D q->tab;
+		if (old) {
+			unsigned int tail =3D 0;
+
+			while (q->head !=3D q->tail) {
+				ntab[tail++] =3D q->tab[q->head];
+				q->head =3D (q->head + 1) & q->tab_mask;
+			}
+			q->head =3D 0;
+			q->tail =3D tail;
+		}
+		q->tab_mask =3D mask;
+		q->holes =3D 0;
+	} else
+		sch_tree_lock(sch);
+	q->flags =3D ctl->flags;
+	q->limit =3D ctl->limit;
+
+	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]));
+
+	if (q->head =3D=3D q->tail)
+		red_end_of_idle_period(&q->parms);
+
+	sch_tree_unlock(sch);
+	choke_free(old);
+	return 0;
+}
+
+static int choke_init(struct Qdisc* sch, struct nlattr *opt)
+{
+	return choke_change(sch, opt);
+}
+
+static int choke_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *opts =3D NULL;
+	struct tc_red_qopt opt =3D {
+		.limit		=3D q->limit,
+		.flags		=3D q->flags,
+		.qth_min	=3D q->parms.qth_min >> q->parms.Wlog,
+		.qth_max	=3D q->parms.qth_max >> q->parms.Wlog,
+		.Wlog		=3D q->parms.Wlog,
+		.Plog		=3D q->parms.Plog,
+		.Scell_log	=3D q->parms.Scell_log,
+	};
+
+	sch->q.qlen =3D choke_len(q) - q->holes;
+	opts =3D nla_nest_start(skb, TCA_OPTIONS);
+	if (opts =3D=3D NULL)
+		goto nla_put_failure;
+
+	NLA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
+	return nla_nest_end(skb, opts);
+
+nla_put_failure:
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
+}
+
+static int choke_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct tc_red_xstats st =3D {
+		.early	=3D q->stats.prob_drop + q->stats.forced_drop,
+		.pdrop	=3D q->stats.pdrop,
+		.other	=3D q->stats.other,
+		.marked	=3D q->stats.prob_mark + q->stats.forced_mark,
+	};
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+
+static void choke_destroy(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	choke_free(q->tab);
+}
+
+static struct Qdisc_ops choke_qdisc_ops __read_mostly =3D {
+	.id		=3D	"choke",
+	.priv_size	=3D	sizeof(struct choke_sched_data),
+
+	.enqueue	=3D	choke_enqueue,
+	.dequeue	=3D	choke_dequeue,
+	.peek		=3D	qdisc_peek_head,
+	.drop		=3D	choke_drop,
+	.init		=3D	choke_init,
+	.destroy	=3D	choke_destroy,
+	.reset		=3D	choke_reset,
+	.change		=3D	choke_change,
+	.dump		=3D	choke_dump,
+	.dump_stats	=3D	choke_dump_stats,
+	.owner		=3D	THIS_MODULE,
+};
+
+static int __init choke_module_init(void)
+{
+	return register_qdisc(&choke_qdisc_ops);
+}
+
+static void __exit choke_module_exit(void)
+{
+	unregister_qdisc(&choke_qdisc_ops);
+}
+
+module_init(choke_module_init)
+module_exit(choke_module_exit)
+
+MODULE_LICENSE("GPL");


