From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] sched: CHOKe packet scheduler (v0.6)
Date: Wed, 12 Jan 2011 08:13:48 +0100
Message-ID: <1294816428.3447.106.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam> <1294704031.4148.2.camel@edumazet-laptop>
	 <20110110171047.0796b6fb@nehalam> <1294726715.4148.8.camel@edumazet-laptop>
	 <1294727650.4148.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:47364 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836Ab1ALHNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 02:13:54 -0500
Received: by wwi17 with SMTP id 17so3573465wwi.1
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 23:13:53 -0800 (PST)
In-Reply-To: <1294727650.4148.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, here is my v0.6 version :

- Added sanity checks before kcalloc()/kzalloc()
- Added a __GFP_NOWARN to kcalloc()
- Added call to qdisc_bstats_update() after commit bfe0d0298f2a67d94d5
(net_sched: factorize qdisc stats handling)

TODO :
- Added a stat specific update to track CHOKe probabilistic dual-drops
  I temporarily use requeues counter to make sure our code works

qdisc choke 11: parent 1:11 limit 70000b min 10000b max 30000b ewma 1 Plog 16 Scell_log 11
 Sent 236155665 bytes 429432 pkt (dropped 1644435, overlimits 1251933 requeues 196251) 
 rate 38800Kbit 8820pps backlog 124438905b 30001p requeues 196251 
  marked 0 early 1251933 pdrop 0 other 0


Thanks !

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index e69de29..1c62292 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -0,0 +1,540 @@
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
+        =================================================
+
+   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
+   unresponsive flows) is a variant of RED that penalizes misbehaving flows but
+   maintains no flow state. The difference from RED is an additional step
+   during the enqueuing process. If average queue size is over the
+   low threshold (qmin), a packet is chosen at random from the queue.
+   If both the new and chosen packet are from the same flow, both
+   are dropped. Unlike RED, CHOKe is not really a "classful" qdisc because it
+   needs to access packets in queue randomly. It has a minimal class
+   interface to allow overriding the builtin flow classifier with
+   filters.
+
+   Source:
+   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
+   Active Queue Management Scheme for Approximating Fair Bandwidth Allocation",
+   IEEE INFOCOM, 2000.
+
+   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Spatial
+   Characteristics", IEEE/ACM Transactions on Networking, 2004
+
+ */
+
+struct choke_sched_data {
+/* Parameters */
+	u32		 limit;
+	unsigned char	 flags;
+
+	struct red_parms parms;
+	struct red_stats stats;
+
+/* Variables */
+	struct tcf_proto *filter_list;
+	unsigned int	 head;
+	unsigned int	 tail;
+	unsigned int	 holes;
+	unsigned int	 tab_mask; /* size - 1 */
+
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
+
+/* Select a packet at random from the queue in O(1) and handle holes */
+static struct sk_buff *choke_peek_random(struct choke_sched_data *q,
+					 unsigned int *pidx)
+{
+	struct sk_buff *skb;
+	int retrys = 3;
+
+	do {
+		*pidx = (q->head + random_N(choke_len(q))) & q->tab_mask;
+		skb = q->tab[*pidx];
+		if (skb)
+			return skb;
+	} while (--retrys > 0);
+
+	/* queue is has lots of holes use the head which is known to exist */
+	return q->tab[*pidx = q->head];
+}
+
+/* Is ECN parameter configured */
+static inline int use_ecn(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_ECN;
+}
+
+/* Should packets over max just be dropped (versus marked) */
+static inline int use_harddrop(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_HARDDROP;
+}
+
+/* Move head pointer forward to skip over holes */
+static void choke_zap_head_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->head] == NULL) {
+		q->head = (q->head + 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+/* Move tail pointer backwards to reuse holes */
+static void choke_zap_tail_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->tail - 1] == NULL) {
+		q->tail = (q->tail - 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+/* Drop packet from queue array by creating a "hole" */
+static void choke_drop_by_idx(struct choke_sched_data *q, unsigned int idx)
+{
+	q->tab[idx] = NULL;
+	q->holes++;
+
+	if (idx == q->head)
+		choke_zap_head_holes(q);
+	if (idx == q->tail)
+		choke_zap_tail_holes(q);
+}
+
+/* Classify flow using either:
+   1. pre-existing classification result in skb
+   2. fast internal classification
+   3. use TC filter based classification
+*/
+static inline unsigned int choke_classify(struct sk_buff *skb,
+					  struct Qdisc *sch, int *qerr)
+
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+
+	if (TC_H_MAJ(skb->priority) == sch->handle &&
+	    TC_H_MIN(skb->priority) > 0)
+		return TC_H_MIN(skb->priority);
+
+	if (!q->filter_list)
+		return skb_get_rxhash(skb);
+
+	result = tc_classify(skb, q->filter_list, &res);
+	if (result >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return 0;
+		}
+#endif
+		return TC_H_MIN(res.classid);
+	}
+
+	return 0;
+}
+
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct red_parms *p = &q->parms;
+	unsigned int hash;
+	int uninitialized_var(ret);
+
+	hash = choke_classify(skb, sch, &ret);
+	if (unlikely(!hash)) {
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+
+	/* XXX add hash to qdisc_skb_cb? */
+	*(unsigned int *)(qdisc_skb_cb(skb)->data) = hash;
+
+	/* Compute average queue usage (see RED) */
+	p->qavg = red_calc_qavg(p, choke_len(q) - q->holes);
+	if (red_is_idling(p))
+		red_end_of_idle_period(p);
+
+	/* Is queue small? */
+	if (p->qavg <= p->qth_min)
+		p->qcount = -1;
+	else {
+		struct sk_buff *oskb;
+		unsigned int idx;
+
+		/* Draw a packet at random from queue */
+		oskb = choke_peek_random(q, &idx);
+
+		/* Both packets from same flow ? */
+		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) == hash) {
+			/* Drop both packets */
+			choke_drop_by_idx(q, idx);
+			qdisc_drop(oskb, sch);
+			sch->qstats.requeues++;
+			goto congestion_drop;
+		}
+
+		if (p->qavg > p->qth_max) {
+			p->qcount = -1;
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
+				p->qcount = 0;
+				p->qR = red_random(p);
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
+			p->qR = red_random(p);
+	}
+
+	/* Admit new packet */
+	if (likely(choke_len(q) < q->limit)) {
+		q->tab[q->tail] = skb;
+		q->tail = (q->tail + 1) & q->tab_mask;
+
+		sch->qstats.backlog += qdisc_pkt_len(skb);
+		qdisc_bstats_update(sch, skb);
+		sch->q.qlen = choke_len(q) - q->holes;
+		return NET_XMIT_SUCCESS;
+	}
+
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
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	if (q->head == q->tail) {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+		return NULL;
+	}
+	skb = q->tab[q->head];
+	q->tab[q->head] = NULL; /* not really needed */
+	q->head = (q->head + 1) & q->tab_mask;
+	choke_zap_head_holes(q);
+	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->q.qlen = choke_len(q) - q->holes;
+
+	return skb;
+}
+
+static unsigned int choke_drop(struct Qdisc *sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	unsigned int len;
+
+	len = qdisc_queue_drop(sch);
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
+	struct choke_sched_data *q = qdisc_priv(sch);
+
+	red_restart(&q->parms);
+}
+
+static const struct nla_policy choke_policy[TCA_RED_MAX + 1] = {
+	[TCA_RED_PARMS]	= { .len = sizeof(struct tc_red_qopt) },
+	[TCA_RED_STAB]	= { .len = RED_STAB_SIZE },
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
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_RED_MAX + 1];
+	struct tc_red_qopt *ctl;
+	int err;
+	struct sk_buff **old = NULL;
+	unsigned int mask;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_RED_MAX, opt, choke_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_RED_PARMS] == NULL ||
+	    tb[TCA_RED_STAB] == NULL)
+		return -EINVAL;
+
+	ctl = nla_data(tb[TCA_RED_PARMS]);
+
+	mask = roundup_pow_of_two(ctl->limit + 1) - 1;
+	/* limit queue size to one MB */
+	if (mask + 1 > (1U << 20) / sizeof(struct sk_buff *))
+		return -EINVAL;
+	if (mask != q->tab_mask) {
+		struct sk_buff **ntab = kcalloc(mask + 1, sizeof(struct sk_buff *),
+						GFP_KERNEL | __GFP_NOWARN);
+		if (!ntab)
+			ntab = vzalloc((mask + 1) * sizeof(struct sk_buff *));
+		if (!ntab)
+			return -ENOMEM;
+		sch_tree_lock(sch);
+		old = q->tab;
+		if (old) {
+			unsigned int tail = 0;
+
+			while (q->head != q->tail) {
+				ntab[tail++] = q->tab[q->head];
+				q->head = (q->head + 1) & q->tab_mask;
+			}
+			q->head = 0;
+			q->tail = tail;
+		}
+		q->tab_mask = mask;
+		q->tab = ntab;
+		q->holes = 0;
+	} else
+		sch_tree_lock(sch);
+	q->flags = ctl->flags;
+	q->limit = ctl->limit;
+
+	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]));
+
+	if (q->head == q->tail)
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
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct nlattr *opts = NULL;
+	struct tc_red_qopt opt = {
+		.limit		= q->limit,
+		.flags		= q->flags,
+		.qth_min	= q->parms.qth_min >> q->parms.Wlog,
+		.qth_max	= q->parms.qth_max >> q->parms.Wlog,
+		.Wlog		= q->parms.Wlog,
+		.Plog		= q->parms.Plog,
+		.Scell_log	= q->parms.Scell_log,
+	};
+
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
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
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct tc_red_xstats st = {
+		.early	= q->stats.prob_drop + q->stats.forced_drop,
+		.pdrop	= q->stats.pdrop,
+		.other	= q->stats.other,
+		.marked	= q->stats.prob_mark + q->stats.forced_mark,
+	};
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+
+static void choke_destroy(struct Qdisc *sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	choke_free(q->tab);
+}
+
+static struct Qdisc *choke_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	return NULL;
+}
+
+static unsigned long choke_get(struct Qdisc *sch, u32 classid)
+{
+	return 0;
+}
+
+static void choke_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
+static unsigned long choke_bind(struct Qdisc *sch, unsigned long parent,
+				u32 classid)
+{
+	return 0;
+}
+
+static struct tcf_proto **choke_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static int choke_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	return 0;
+}
+
+static void choke_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	if (!arg->stop) {
+		if (arg->fn(sch, 1, arg) < 0) {
+			arg->stop = 1;
+			return;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops choke_class_ops = {
+	.leaf		=	choke_leaf,
+	.get		=	choke_get,
+	.put		=	choke_put,
+	.tcf_chain	=	choke_find_tcf,
+	.bind_tcf	=	choke_bind,
+	.unbind_tcf	=	choke_put,
+	.dump		=	choke_dump_class,
+	.walk		=	choke_walk,
+};
+
+static struct sk_buff *choke_peek_head(struct Qdisc *sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+
+	return (q->head != q->tail) ? q->tab[q->head] : NULL;
+}
+
+static struct Qdisc_ops choke_qdisc_ops __read_mostly = {
+	.id		=	"choke",
+	.priv_size	=	sizeof(struct choke_sched_data),
+
+	.enqueue	=	choke_enqueue,
+	.dequeue	=	choke_dequeue,
+	.peek		=	choke_peek_head,
+	.drop		=	choke_drop,
+	.init		=	choke_init,
+	.destroy	=	choke_destroy,
+	.reset		=	choke_reset,
+	.change		=	choke_change,
+	.dump		=	choke_dump,
+	.dump_stats	=	choke_dump_stats,
+	.owner		=	THIS_MODULE,
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


