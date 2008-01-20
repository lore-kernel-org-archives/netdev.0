From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 05/05]: Consolidate class ops for pseudo classful qdisc
Date: Sun, 20 Jan 2008 19:28:56 +0100 (MET)
Message-ID: <20080120182855.10972.24622.sendpatchset@localhost.localdomain>
References: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710AbYATS25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:57 -0500
In-Reply-To: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e97ba18f7a8f9342fa06d0f5606a186b18e1d7f8
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:06 2008 +0100

    [NET_SCHED]: Consolidate class ops for pseudo classful qdisc
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index decc339..ca6e4de 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -351,4 +351,10 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
 }
 #endif
 
+struct pc_sched_data {
+	struct Qdisc	*qdisc;
+};
+
+extern const struct Qdisc_class_ops pseudo_classful_ops;
+
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index f5ab54b..63882c5 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -43,6 +43,9 @@ if NET_SCHED
 
 comment "Queueing/Scheduling"
 
+config NET_SCH_PC
+	tristate
+
 config NET_SCH_CBQ
 	tristate "Class Based Queueing (CBQ)"
 	---help---
@@ -141,6 +144,7 @@ config NET_SCH_SFQ
 
 config NET_SCH_TEQL
 	tristate "True Link Equalizer (TEQL)"
+	select NET_SCH_PC
 	---help---
 	  Say Y here if you want to use the True Link Equalizer (TLE) packet
 	  scheduling algorithm. This queueing discipline allows the combination
@@ -153,6 +157,7 @@ config NET_SCH_TEQL
 
 config NET_SCH_TBF
 	tristate "Token Bucket Filter (TBF)"
+	select NET_SCH_PC
 	---help---
 	  Say Y here if you want to use the Token Bucket Filter (TBF) packet
 	  scheduling algorithm.
@@ -186,6 +191,7 @@ config NET_SCH_DSMARK
 
 config NET_SCH_NETEM
 	tristate "Network emulator (NETEM)"
+	select NET_SCH_PC
 	---help---
 	  Say Y if you want to emulate network delay, loss, and packet
 	  re-ordering. This is often useful to simulate networks when
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 81ecbe8..593bb3a 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
+obj-$(CONFIG_NET_SCH_PC)	+= sch_pseudo_classful.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f6c24fd..2444a97 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -52,7 +52,8 @@
 */
 
 struct netem_sched_data {
-	struct Qdisc	*qdisc;
+	struct pc_sched_data class;
+
 	struct qdisc_watchdog watchdog;
 
 	psched_tdiff_t latency;
@@ -218,7 +219,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		now = psched_get_time();
 		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = qdisc_enqueue(skb, q->qdisc);
+		ret = qdisc_enqueue(skb, q->class.qdisc);
 	} else {
 		/*
 		 * Do re-ordering by putting one out of N packets at the front
@@ -226,7 +227,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = qdisc_requeue(skb, q->qdisc);
+		ret = qdisc_requeue(skb, q->class.qdisc);
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -246,7 +247,7 @@ static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	ret = qdisc_requeue(skb, q->qdisc);
+	ret = qdisc_requeue(skb, q->class.qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
@@ -260,7 +261,7 @@ static unsigned int netem_drop(struct Qdisc* sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
 
-	len = qdisc_drop(q->qdisc);
+	len = qdisc_drop(q->class.qdisc);
 	if (len > 0) {
 		sch->q.qlen--;
 		sch->qstats.drops++;
@@ -277,7 +278,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
-	skb = qdisc_dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->class.qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
@@ -290,11 +291,11 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 
-		if (unlikely(qdisc_requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
+		if (unlikely(qdisc_requeue(skb, q->class.qdisc) != NET_XMIT_SUCCESS)) {
+			qdisc_tree_decrease_qlen(q->class.qdisc, 1);
 			sch->qstats.drops++;
 			printk(KERN_ERR "netem: %s could not requeue\n",
-			       q->qdisc->ops->id);
+			       q->class.qdisc->ops->id);
 		}
 
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
@@ -307,7 +308,7 @@ static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	qdisc_reset(q->qdisc);
+	qdisc_reset(q->class.qdisc);
 	sch->q.qlen = 0;
 	qdisc_watchdog_cancel(&q->watchdog);
 }
@@ -394,7 +395,7 @@ static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 		return -EINVAL;
 
 	qopt = RTA_DATA(opt);
-	ret = fifo_set_limit(q->qdisc, qopt->limit);
+	ret = fifo_set_limit(q->class.qdisc, qopt->limit);
 	if (ret) {
 		pr_debug("netem: can't set fifo limit\n");
 		return ret;
@@ -547,9 +548,9 @@ static int netem_init(struct Qdisc *sch, struct rtattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
-	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
-				     TC_H_MAKE(sch->handle, 1));
-	if (!q->qdisc) {
+	q->class.qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
+					   TC_H_MAKE(sch->handle, 1));
+	if (!q->class.qdisc) {
 		pr_debug("netem: qdisc create failed\n");
 		return -ENOMEM;
 	}
@@ -557,7 +558,7 @@ static int netem_init(struct Qdisc *sch, struct rtattr *opt)
 	ret = netem_change(sch, opt);
 	if (ret) {
 		pr_debug("netem: change failed\n");
-		qdisc_destroy(q->qdisc);
+		qdisc_destroy(q->class.qdisc);
 	}
 	return ret;
 }
@@ -567,7 +568,7 @@ static void netem_destroy(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-	qdisc_destroy(q->qdisc);
+	qdisc_destroy(q->class.qdisc);
 	kfree(q->delay_dist);
 }
 
@@ -611,95 +612,9 @@ rtattr_failure:
 	return -1;
 }
 
-static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
-			  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-
-	if (cl != 1) 	/* only one class */
-		return -ENOENT;
-
-	tcm->tcm_handle |= TC_H_MIN(1);
-	tcm->tcm_info = q->qdisc->handle;
-
-	return 0;
-}
-
-static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-
-	if (new == NULL)
-		new = &noop_qdisc;
-
-	sch_tree_lock(sch);
-	*old = xchg(&q->qdisc, new);
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
-	sch_tree_unlock(sch);
-
-	return 0;
-}
-
-static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	return q->qdisc;
-}
-
-static unsigned long netem_get(struct Qdisc *sch, u32 classid)
-{
-	return 1;
-}
-
-static void netem_put(struct Qdisc *sch, unsigned long arg)
-{
-}
-
-static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int netem_delete(struct Qdisc *sch, unsigned long arg)
-{
-	return -ENOSYS;
-}
-
-static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
-{
-	if (!walker->stop) {
-		if (walker->count >= walker->skip)
-			if (walker->fn(sch, 1, walker) < 0) {
-				walker->stop = 1;
-				return;
-			}
-		walker->count++;
-	}
-}
-
-static struct tcf_proto **netem_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
-static const struct Qdisc_class_ops netem_class_ops = {
-	.graft		=	netem_graft,
-	.leaf		=	netem_leaf,
-	.get		=	netem_get,
-	.put		=	netem_put,
-	.change		=	netem_change_class,
-	.delete		=	netem_delete,
-	.walk		=	netem_walk,
-	.tcf_chain	=	netem_find_tcf,
-	.dump		=	netem_dump_class,
-};
-
 static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.id		=	"netem",
-	.cl_ops		=	&netem_class_ops,
+	.cl_ops		=	&pseudo_classful_ops,
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
diff --git a/net/sched/sch_pseudo_classful.c b/net/sched/sch_pseudo_classful.c
new file mode 100644
index 0000000..5b9fba5
--- /dev/null
+++ b/net/sched/sch_pseudo_classful.c
@@ -0,0 +1,101 @@
+/*
+ * Copyright (c) 2007 Patrick McHardy, <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <net/sch_generic.h>
+#include <net/pkt_sched.h>
+
+static int sch_pc_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+			struct Qdisc **old)
+{
+	struct pc_sched_data *q = qdisc_priv(sch);
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static int sch_pc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			       struct rtattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
+}
+
+static struct Qdisc *sch_pc_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	return ((struct pc_sched_data *)qdisc_priv(sch))->qdisc;
+}
+
+static unsigned long sch_pc_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void sch_pc_put(struct Qdisc *sch, unsigned long arg)
+{
+	return;
+}
+
+static int sch_pc_delete(struct Qdisc *sch, unsigned long arg)
+{
+	return -ENOSYS;
+}
+
+static struct tcf_proto **sch_pc_tcf_chain(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
+static int sch_pc_dump_class(struct Qdisc *sch, unsigned long cl,
+			     struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct pc_sched_data *q = qdisc_priv(sch);
+
+	if (cl != 1)
+		return -ENOENT;
+
+	tcm->tcm_handle |= TC_H_MIN(1);
+	tcm->tcm_info = q->qdisc->handle;
+	return 0;
+}
+
+static void sch_pc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+const struct Qdisc_class_ops pseudo_classful_ops = {
+	.graft		= sch_pc_graft,
+	.leaf		= sch_pc_leaf,
+	.get		= sch_pc_get,
+	.put		= sch_pc_put,
+	.change		= sch_pc_change_class,
+	.delete		= sch_pc_delete,
+	.walk		= sch_pc_walk,
+	.tcf_chain	= sch_pc_tcf_chain,
+	.dump		= sch_pc_dump_class,
+};
+EXPORT_SYMBOL(pseudo_classful_ops);
+
+MODULE_LICENSE("GPL");
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 076f1ef..fc61675 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -38,11 +38,12 @@
 
 struct red_sched_data
 {
+	struct pc_sched_data	class;
+
 	u32			limit;		/* HARD maximal queue length */
 	unsigned char		flags;
 	struct red_parms	parms;
 	struct red_stats	stats;
-	struct Qdisc		*qdisc;
 };
 
 static inline int red_use_ecn(struct red_sched_data *q)
@@ -58,7 +59,7 @@ static inline int red_use_harddrop(struct red_sched_data *q)
 static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
+	struct Qdisc *child = q->class.qdisc;
 	int ret;
 
 	q->parms.qavg = red_calc_qavg(&q->parms, child->qstats.backlog);
@@ -111,7 +112,7 @@ congestion_drop:
 static int red_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
+	struct Qdisc *child = q->class.qdisc;
 	int ret;
 
 	if (red_is_idling(&q->parms))
@@ -129,7 +130,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
+	struct Qdisc *child = q->class.qdisc;
 
 	skb = qdisc_dequeue(child);
 	if (skb)
@@ -143,7 +144,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 static unsigned int red_drop(struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
+	struct Qdisc *child = q->class.qdisc;
 	unsigned int len;
 
 	len = qdisc_drop(child);
@@ -164,7 +165,7 @@ static void red_reset(struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
-	qdisc_reset(q->qdisc);
+	qdisc_reset(q->class.qdisc);
 	sch->q.qlen = 0;
 	red_restart(&q->parms);
 }
@@ -172,7 +173,7 @@ static void red_reset(struct Qdisc* sch)
 static void red_destroy(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	qdisc_destroy(q->qdisc);
+	qdisc_destroy(q->class.qdisc);
 }
 
 static int red_change(struct Qdisc *sch, struct rtattr *opt)
@@ -203,8 +204,9 @@ static int red_change(struct Qdisc *sch, struct rtattr *opt)
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
 	if (child) {
-		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
-		qdisc_destroy(xchg(&q->qdisc, child));
+		qdisc_tree_decrease_qlen(q->class.qdisc,
+					 q->class.qdisc->q.qlen);
+		qdisc_destroy(xchg(&q->class.qdisc, child));
 	}
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
@@ -222,7 +224,7 @@ static int red_init(struct Qdisc* sch, struct rtattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
-	q->qdisc = &noop_qdisc;
+	q->class.qdisc = &noop_qdisc;
 	return red_change(sch, opt);
 }
 
@@ -261,94 +263,10 @@ static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
 
-static int red_dump_class(struct Qdisc *sch, unsigned long cl,
-			  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	struct red_sched_data *q = qdisc_priv(sch);
-
-	if (cl != 1)
-		return -ENOENT;
-	tcm->tcm_handle |= TC_H_MIN(1);
-	tcm->tcm_info = q->qdisc->handle;
-	return 0;
-}
-
-static int red_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
-{
-	struct red_sched_data *q = qdisc_priv(sch);
-
-	if (new == NULL)
-		new = &noop_qdisc;
-
-	sch_tree_lock(sch);
-	*old = xchg(&q->qdisc, new);
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
-	sch_tree_unlock(sch);
-	return 0;
-}
-
-static struct Qdisc *red_leaf(struct Qdisc *sch, unsigned long arg)
-{
-	struct red_sched_data *q = qdisc_priv(sch);
-	return q->qdisc;
-}
-
-static unsigned long red_get(struct Qdisc *sch, u32 classid)
-{
-	return 1;
-}
-
-static void red_put(struct Qdisc *sch, unsigned long arg)
-{
-	return;
-}
-
-static int red_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int red_delete(struct Qdisc *sch, unsigned long cl)
-{
-	return -ENOSYS;
-}
-
-static void red_walk(struct Qdisc *sch, struct qdisc_walker *walker)
-{
-	if (!walker->stop) {
-		if (walker->count >= walker->skip)
-			if (walker->fn(sch, 1, walker) < 0) {
-				walker->stop = 1;
-				return;
-			}
-		walker->count++;
-	}
-}
-
-static struct tcf_proto **red_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
-static const struct Qdisc_class_ops red_class_ops = {
-	.graft		=	red_graft,
-	.leaf		=	red_leaf,
-	.get		=	red_get,
-	.put		=	red_put,
-	.change		=	red_change_class,
-	.delete		=	red_delete,
-	.walk		=	red_walk,
-	.tcf_chain	=	red_find_tcf,
-	.dump		=	red_dump_class,
-};
-
 static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.id		=	"red",
 	.priv_size	=	sizeof(struct red_sched_data),
-	.cl_ops		=	&red_class_ops,
+	.cl_ops		=	&pseudo_classful_ops,
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
 	.requeue	=	red_requeue,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 5fd4dff..6590ce3 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -99,6 +99,8 @@
 
 struct tbf_sched_data
 {
+	struct pc_sched_data	class;
+
 /* Parameters */
 	u32		limit;		/* Maximal length of backlog: bytes */
 	u32		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
@@ -111,7 +113,6 @@ struct tbf_sched_data
 	long	tokens;			/* Current number of B tokens */
 	long	ptokens;		/* Current number of P tokens */
 	psched_time_t	t_c;		/* Time check-point */
-	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
@@ -133,7 +134,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return NET_XMIT_DROP;
 	}
 
-	ret = qdisc_enqueue(skb, q->qdisc);
+	ret = qdisc_enqueue(skb, q->class.qdisc);
 	if (ret != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return ret;
@@ -150,7 +151,7 @@ static int tbf_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	ret = qdisc_requeue(skb, q->qdisc);
+	ret = qdisc_requeue(skb, q->class.qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
@@ -164,7 +165,7 @@ static unsigned int tbf_drop(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
 
-	len = qdisc_drop(q->qdisc);
+	len = qdisc_drop(q->class.qdisc);
 	if (len > 0) {
 		sch->q.qlen--;
 		sch->qstats.drops++;
@@ -177,7 +178,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = qdisc_dequeue(q->qdisc);
+	skb = qdisc_dequeue(q->class.qdisc);
 
 	if (skb) {
 		psched_time_t now;
@@ -222,9 +223,9 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+		if (q->class.qdisc->ops->requeue(skb, q->class.qdisc) != NET_XMIT_SUCCESS) {
 			/* When requeue fails skb is dropped */
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
+			qdisc_tree_decrease_qlen(q->class.qdisc, 1);
 			sch->qstats.drops++;
 		}
 
@@ -237,7 +238,7 @@ static void tbf_reset(struct Qdisc* sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
-	qdisc_reset(q->qdisc);
+	qdisc_reset(q->class.qdisc);
 	sch->q.qlen = 0;
 	q->t_c = psched_get_time();
 	q->tokens = q->buffer;
@@ -295,8 +296,8 @@ static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
 
 	sch_tree_lock(sch);
 	if (child) {
-		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
-		qdisc_destroy(xchg(&q->qdisc, child));
+		qdisc_tree_decrease_qlen(q->class.qdisc, q->class.qdisc->q.qlen);
+		qdisc_destroy(xchg(&q->class.qdisc, child));
 	}
 	q->limit = qopt->limit;
 	q->mtu = qopt->mtu;
@@ -325,7 +326,7 @@ static int tbf_init(struct Qdisc* sch, struct rtattr *opt)
 
 	q->t_c = psched_get_time();
 	qdisc_watchdog_init(&q->watchdog, sch);
-	q->qdisc = &noop_qdisc;
+	q->class.qdisc = &noop_qdisc;
 
 	return tbf_change(sch, opt);
 }
@@ -341,7 +342,7 @@ static void tbf_destroy(struct Qdisc *sch)
 	if (q->R_tab)
 		qdisc_put_rtab(q->R_tab);
 
-	qdisc_destroy(q->qdisc);
+	qdisc_destroy(q->class.qdisc);
 }
 
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -372,96 +373,8 @@ rtattr_failure:
 	return -1;
 }
 
-static int tbf_dump_class(struct Qdisc *sch, unsigned long cl,
-			  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	struct tbf_sched_data *q = qdisc_priv(sch);
-
-	if (cl != 1) 	/* only one class */
-		return -ENOENT;
-
-	tcm->tcm_handle |= TC_H_MIN(1);
-	tcm->tcm_info = q->qdisc->handle;
-
-	return 0;
-}
-
-static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
-{
-	struct tbf_sched_data *q = qdisc_priv(sch);
-
-	if (new == NULL)
-		new = &noop_qdisc;
-
-	sch_tree_lock(sch);
-	*old = xchg(&q->qdisc, new);
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
-	sch_tree_unlock(sch);
-
-	return 0;
-}
-
-static struct Qdisc *tbf_leaf(struct Qdisc *sch, unsigned long arg)
-{
-	struct tbf_sched_data *q = qdisc_priv(sch);
-	return q->qdisc;
-}
-
-static unsigned long tbf_get(struct Qdisc *sch, u32 classid)
-{
-	return 1;
-}
-
-static void tbf_put(struct Qdisc *sch, unsigned long arg)
-{
-}
-
-static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int tbf_delete(struct Qdisc *sch, unsigned long arg)
-{
-	return -ENOSYS;
-}
-
-static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
-{
-	if (!walker->stop) {
-		if (walker->count >= walker->skip)
-			if (walker->fn(sch, 1, walker) < 0) {
-				walker->stop = 1;
-				return;
-			}
-		walker->count++;
-	}
-}
-
-static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
-static const struct Qdisc_class_ops tbf_class_ops =
-{
-	.graft		=	tbf_graft,
-	.leaf		=	tbf_leaf,
-	.get		=	tbf_get,
-	.put		=	tbf_put,
-	.change		=	tbf_change_class,
-	.delete		=	tbf_delete,
-	.walk		=	tbf_walk,
-	.tcf_chain	=	tbf_find_tcf,
-	.dump		=	tbf_dump_class,
-};
-
 static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
-	.next		=	NULL,
-	.cl_ops		=	&tbf_class_ops,
+	.cl_ops		=	&pseudo_classful_ops,
 	.id		=	"tbf",
 	.priv_size	=	sizeof(struct tbf_sched_data),
 	.enqueue	=	tbf_enqueue,
