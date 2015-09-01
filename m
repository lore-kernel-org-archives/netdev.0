From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] net: qdisc: add op to run filters/actions before enqueue
Date: Tue,  1 Sep 2015 18:34:22 +0200
Message-ID: <a18f0baba2668f0bbc15a45036713dcaa4bb09b0.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49534 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbbIAQea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:34:30 -0400
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Add a new ->preclassify() op to allow multiqueue queuing disciplines
to call tc_classify() or perform other work before dev_pick_tx().

This helps, for example, with mqprio queueing discipline that has
offload support by most popular 10G NICs, where the txq effectively
picks the qdisc.

Once traffic is being directed to a specific queue then hardware TX
rings may be tuned to support this traffic type. mqprio already
gives the ability to do this via skb->priority where the ->preclassify()
provides more control over packet steering, it can classify the skb
and set the priority, for example, from an eBPF classifier (or action).

Also this allows traffic classifiers to be run without holding the
qdisc lock and gives one place to attach filters when mqprio is
in use. ->preclassify() could also be added to other mq qdiscs later
on: f.e. most classful qdiscs first check major/minor numbers of
skb->priority before actually consulting a more complex classifier.

For mqprio case today, a filter has to be attached to each txq qdisc
to have all traffic hit the filter. Since ->preclassify() is currently
only used by mqprio, the __dev_queue_xmit() fast path is guarded by
a generic, hidden Kconfig option (NET_CLS_PRECLASSIFY) that is only
selected by mqprio, otherwise it defaults to off. Also, the Qdisc
structure size will stay the same, we move __parent, used by cbq only
into a write-mostly hole. If actions are enabled, __parent is written
on every enqueue, and only read, rewritten in reshape_fail() phase.
Therefore, this place in the read-mostly cacheline could be used by
preclassify, which is written only once.

Joint work with Daniel Borkmann.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/net/sch_generic.h | 16 +++++++++++-----
 net/core/dev.c            | 17 +++++++++++++++++
 net/sched/Kconfig         |  5 +++++
 net/sched/sch_generic.c   |  1 +
 net/sched/sch_mqprio.c    | 35 +++++++++++++++++++++++++++++++++++
 5 files changed, 69 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 444faa8..e65767d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -69,13 +69,11 @@ struct Qdisc {
 	u32			parent;
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
+	int			(*preclassify)(struct sk_buff *skb,
+					       struct Qdisc *q);
 
 	void			*u32_node;
 
-	/* This field is deprecated, but it is still used by CBQ
-	 * and it will live until better solution will be invented.
-	 */
-	struct Qdisc		*__parent;
 	struct netdev_queue	*dev_queue;
 
 	struct gnet_stats_rate_est64	rate_est;
@@ -93,6 +91,14 @@ struct Qdisc {
 	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
+
+	/* This field is deprecated, but it is still used by CBQ
+	 * and it will live until better solution will be invented.
+	 * If actions are enabled, it's modified on every enqueue,
+	 * and only rw-accessed in slow-path (cbq_reshape_fail).
+	 */
+	struct Qdisc		*__parent;
+
 	int			padded;
 	atomic_t		refcnt;
 
@@ -184,6 +190,7 @@ struct Qdisc_ops {
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
+	int			(*preclassify)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
@@ -199,7 +206,6 @@ struct Qdisc_ops {
 	struct module		*owner;
 };
 
-
 struct tcf_result {
 	unsigned long	class;
 	u32		classid;
diff --git a/net/core/dev.c b/net/core/dev.c
index 877c848..b768bca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3052,6 +3052,23 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	rcu_read_lock_bh();
 
 	skb_update_prio(skb);
+#ifdef CONFIG_NET_CLS_PRECLASSIFY
+	q = rcu_dereference_bh(dev->qdisc);
+	if (q && q->preclassify) {
+		switch (q->preclassify(skb, q)) {
+		default:
+			break;
+#ifdef CONFIG_NET_CLS_ACT
+		case TC_ACT_SHOT:
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			kfree_skb(skb);
+			rc = NET_XMIT_SUCCESS;
+			goto out;
+#endif
+		}
+	}
+#endif
 
 	/* If device/qdisc don't need skb->dst, release it right now while
 	 * its hot in this cpu cache.
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index daa3343..c235756 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -219,6 +219,7 @@ config NET_SCH_DRR
 
 config NET_SCH_MQPRIO
 	tristate "Multi-queue priority scheduler (MQPRIO)"
+	select NET_CLS_PRECLASSIFY
 	help
 	  Say Y here if you want to use the Multi-queue Priority scheduler.
 	  This scheduler allows QOS to be offloaded on NICs that have support
@@ -351,6 +352,10 @@ comment "Classification"
 config NET_CLS
 	bool
 
+config NET_CLS_PRECLASSIFY
+	bool
+	default n
+
 config NET_CLS_BASIC
 	tristate "Elementary classification (BASIC)"
 	select NET_CLS
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cb5d4ad..ef27ea2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -605,6 +605,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
+	sch->preclassify = ops->preclassify;
 	sch->dev_queue = dev_queue;
 	dev_hold(dev);
 	atomic_set(&sch->refcnt, 1);
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 3811a74..7e251cc 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -20,6 +20,7 @@
 #include <net/sch_generic.h>
 
 struct mqprio_sched {
+	struct tcf_proto __rcu *filter_list;
 	struct Qdisc		**qdiscs;
 	int hw_owned;
 };
@@ -28,9 +29,13 @@ static void mqprio_destroy(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
+	struct tcf_proto *filter_list;
 	unsigned int ntx;
 
 	if (priv->qdiscs) {
+		filter_list = rtnl_dereference(priv->filter_list);
+		tcf_destroy_chain(&filter_list);
+
 		for (ntx = 0;
 		     ntx < dev->num_tx_queues && priv->qdiscs[ntx];
 		     ntx++)
@@ -391,12 +396,41 @@ static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
+static struct tcf_proto __rcu **mqprio_find_tcf(struct Qdisc *sch,
+						unsigned long cl)
+{
+	struct mqprio_sched *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+
+	return &q->filter_list;
+}
+
+static unsigned long mqprio_bind(struct Qdisc *sch, unsigned long parent,
+				 u32 classid)
+{
+	return 0;
+}
+
+static int mqprio_classify(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct mqprio_sched *q = qdisc_priv(sch);
+	struct tcf_proto *fl = rcu_dereference_bh(q->filter_list);
+	struct tcf_result res;
+
+	return tc_classify(skb, fl, &res, false);
+}
+
 static const struct Qdisc_class_ops mqprio_class_ops = {
 	.graft		= mqprio_graft,
 	.leaf		= mqprio_leaf,
 	.get		= mqprio_get,
 	.put		= mqprio_put,
 	.walk		= mqprio_walk,
+	.tcf_chain	= mqprio_find_tcf,
+	.bind_tcf	= mqprio_bind,
+	.unbind_tcf	= mqprio_put,
 	.dump		= mqprio_dump_class,
 	.dump_stats	= mqprio_dump_class_stats,
 };
@@ -407,6 +441,7 @@ static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
 	.priv_size	= sizeof(struct mqprio_sched),
 	.init		= mqprio_init,
 	.destroy	= mqprio_destroy,
+	.preclassify	= mqprio_classify,
 	.attach		= mqprio_attach,
 	.dump		= mqprio_dump,
 	.owner		= THIS_MODULE,
-- 
1.9.3
