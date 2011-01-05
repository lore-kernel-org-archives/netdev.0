From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Wed, 5 Jan 2011 11:21:04 -0800
Message-ID: <20110105112104.64ad3c86@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45039 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab1AETVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 14:21:08 -0500
In-Reply-To: <1294248332.10633.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the CHOKe packet scheduler based on the existing
Linux RED scheduler based on the algorithm described in the paper.

The core idea is:
  For every packet arrival:
  	Calculate Qave
	if (Qave < minth) 
	     Queue the new packet
	else 
	     Select randomly a packet from the queue 
	     if (both packets from same flow)
	     then Drop both the packets
	     else if (Qave > maxth)
	          Drop packet
	     else
	       	  Admit packet with probability p (same as RED)

See also:
  Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a stateless active
   queue management scheme for approximating fair bandwidth allocation", 
  Proceeding of INFOCOM'2000, March 2000. 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
New in this version:
	- use skb hash values for flow matching
	- reciprocal_divide optimization
	- optional ECN support (same as RED)

 net/sched/Kconfig     |   11 +
 net/sched/Makefile    |    1 
 net/sched/sch_choke.c |  364 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 376 insertions(+)

--- a/net/sched/Kconfig	2011-01-04 16:25:18.000000000 -0800
+++ b/net/sched/Kconfig	2011-01-05 09:01:33.280032462 -0800
@@ -205,6 +205,17 @@ config NET_SCH_DRR
 
 	  If unsure, say N.
 
+config NET_SCH_CHOKE
+	tristate "CHOose and Keep responsive flow scheduler (CHOKE)"
+	help
+	  Say Y here if you want to use the CHOKe packet scheduler (CHOose
+	  and Keep for responsive flows, CHOose and Kill for unresponsive
+	  flows). This is a variation of RED which trys to penalize flows
+	  that monopolize the queue.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_choke.
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
--- a/net/sched/Makefile	2011-01-04 16:25:18.000000000 -0800
+++ b/net/sched/Makefile	2011-01-05 09:01:33.284032598 -0800
@@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+= sch_mult
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_SCH_DRR)	+= sch_drr.o
+obj-$(CONFIG_NET_SCH_CHOKE)	+= sch_choke.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+= cls_fw.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/sched/sch_choke.c	2011-01-05 11:18:14.422320985 -0800
@@ -0,0 +1,307 @@
+/*
+ * net/sched/sch_choke.c	CHOKE scheduler
+ *
+ * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
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
+   are dropped. Unlike RED, CHOKe is not a "classful" qdisc because it
+   needs to access packets in queue randomly.
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
+struct choke_sched_data
+{
+	u32		  limit;
+	unsigned char	  flags;
+
+	struct red_parms  parms;
+	struct red_stats  stats;
+};
+
+
+/* deliver a random number between 0 and N - 1 */
+static inline u32 random_N(unsigned int N)
+{
+	return reciprocal_divide(random(), N);
+}
+
+/* Select a packet at random from the list.
+ * Same caveats as skb_peek.
+ */
+static struct sk_buff *skb_peek_random(struct sk_buff_head *list)
+{
+	struct sk_buff *skb = list->next;
+	unsigned int idx = random_N(list->qlen);
+
+	while (skb && idx-- > 0)
+		skb = skb->next;
+
+	return skb;
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
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct red_parms *p = &q->parms;
+
+	p->qavg = red_calc_qavg(p, skb_queue_len(&sch->q));
+	if (red_is_idling(p))
+		red_end_of_idle_period(p);
+
+	if (p->qavg <= p->qth_min)
+		p->qcount = -1;
+	else {
+		struct sk_buff *oskb;
+
+		/* Draw a packet at random from queue */
+		oskb = skb_peek_random(&sch->q);
+
+		/* Both packets from same flow?
+		 * Assumes skb_get_rxhash already set hash on oskb->rxhash
+		 * prior to queuing
+		 */
+		if (oskb->rxhash == skb_get_rxhash(skb)) {
+			/* Drop both packets */
+			__skb_unlink(oskb, &sch->q);
+			qdisc_drop(oskb, sch);
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
+	if (likely(skb_queue_len(&sch->q) < q->limit))
+		return qdisc_enqueue_tail(skb, sch);
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
+static struct sk_buff *choke_dequeue(struct Qdisc* sch)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	skb = qdisc_dequeue_head(sch);
+	if (!skb) {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+	}
+
+	return skb;
+}
+
+static unsigned int choke_drop(struct Qdisc* sch)
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
+static int choke_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct choke_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_RED_MAX + 1];
+	struct tc_red_qopt *ctl;
+	int err;
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
+	sch_tree_lock(sch);
+	q->flags = ctl->flags;
+	q->limit = ctl->limit;
+
+	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]));
+
+	if (skb_queue_empty(&sch->q))
+		red_end_of_idle_period(&q->parms);
+
+	sch_tree_unlock(sch);
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
+static struct Qdisc_ops choke_qdisc_ops __read_mostly = {
+	.id		=	"choke",
+	.priv_size	=	sizeof(struct choke_sched_data),
+
+	.enqueue	=	choke_enqueue,
+	.dequeue	=	choke_dequeue,
+	.peek		=	qdisc_peek_head,
+	.drop		=	choke_drop,
+	.init		=	choke_init,
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
