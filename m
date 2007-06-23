From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Sat, 23 Jun 2007 14:36:33 -0700
Message-ID: <20070623213633.18241.24627.stgit@localhost.localdomain>
References: <20070623213614.18241.45511.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbXFWVgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 17:36:35 -0400
In-Reply-To: <20070623213614.18241.45511.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated: This patch applies on top of Patrick McHardy's RTNETLINK
nested compat attribute patches.  These are required to preserve
ABI for iproute2 when working with the multiqueue qdiscs.

Add the new sch_rr qdisc for multiqueue network device support.
Allow sch_prio and sch_rr to be compiled with or without multiqueue hardware
support.

sch_rr is part of sch_prio, and is referenced from MODULE_ALIAS.  This
was done since sch_prio and sch_rr only differ in their dequeue routine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/pkt_sched.h |    4 +-
 net/sched/Kconfig         |   30 +++++++++++++
 net/sched/sch_generic.c   |    3 +
 net/sched/sch_prio.c      |  106 ++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 129 insertions(+), 14 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 09808b7..ec3a9a5 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -103,8 +103,8 @@ struct tc_prio_qopt
 
 enum
 {
-	TCA_PRIO_UNPSEC,
-	TCA_PRIO_TEST,
+	TCA_PRIO_UNSPEC,
+	TCA_PRIO_MQ,
 	__TCA_PRIO_MAX
 };
 
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..7f14fa6 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -102,8 +102,16 @@ config NET_SCH_ATM
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_atm.
 
+config NET_SCH_BANDS
+        bool "Multi Band Queueing (PRIO and RR)"
+        ---help---
+          Say Y here if you want to use n-band multiqueue packet
+          schedulers.  These include a priority-based scheduler and
+	   a round-robin scheduler.
+
 config NET_SCH_PRIO
 	tristate "Multi Band Priority Queueing (PRIO)"
+	depends on NET_SCH_BANDS
 	---help---
 	  Say Y here if you want to use an n-band priority queue packet
 	  scheduler.
@@ -111,6 +119,28 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
+config NET_SCH_RR
+	tristate "Multi Band Round Robin Queuing (RR)"
+	depends on NET_SCH_BANDS
+	select NET_SCH_PRIO
+	---help---
+	  Say Y here if you want to use an n-band round robin packet
+	  scheduler.
+
+	  The module uses sch_prio for its framework and is aliased as
+	  sch_rr, so it will load sch_prio, although it is referred
+	  to using sch_rr.
+
+config NET_SCH_BANDS_MQ
+	bool "Multiple hardware queue support"
+	depends on NET_SCH_BANDS
+	---help---
+	  Say Y here if you want to allow the PRIO and RR qdiscs to assign
+	  flows to multiple hardware queues on an ethernet device.  This
+	  will still work on devices with 1 queue.
+
+	  Most people will say N here.
+
 config NET_SCH_RED
 	tristate "Random Early Detection (RED)"
 	---help---
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9461e8a..203d5c4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -168,7 +168,8 @@ static inline int qdisc_restart(struct net_device *dev)
 	spin_unlock(&dev->queue_lock);
 
 	ret = NETDEV_TX_BUSY;
-	if (!netif_queue_stopped(dev))
+	if (!netif_queue_stopped(dev) &&
+	    !netif_subqueue_stopped(dev, skb->queue_mapping))
 		/* churn baby churn .. */
 		ret = dev_hard_start_xmit(skb, dev);
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 40a13e8..8a716f0 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -40,9 +40,11 @@
 struct prio_sched_data
 {
 	int bands;
+	int curband; /* for round-robin */
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	unsigned char mq;
 };
 
 
@@ -70,14 +72,28 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
+			if (q->mq)
+				skb->queue_mapping = 
+						q->prio2band[band&TC_PRIO_MAX];
+			else
+				skb->queue_mapping = 0;
 			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
-	if (band >= q->bands)
+	if (band >= q->bands) {
+		if (q->mq)
+			skb->queue_mapping = q->prio2band[0];
+		else
+			skb->queue_mapping = 0;
 		return q->queues[q->prio2band[0]];
+	}
 
+	if (q->mq)
+		skb->queue_mapping = band;
+	else
+		skb->queue_mapping = 0;
 	return q->queues[band];
 }
 
@@ -144,17 +160,57 @@ prio_dequeue(struct Qdisc* sch)
 	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		qdisc = q->queues[prio];
-		skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			sch->q.qlen--;
-			return skb;
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
+			qdisc = q->queues[prio];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
 		}
 	}
 	return NULL;
 
 }
 
+static struct sk_buff *rr_dequeue(struct Qdisc* sch)
+{
+	struct sk_buff *skb;
+	struct prio_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	int bandcount;
+
+	/* Only take one pass through the queues.  If nothing is available,
+	 * return nothing.
+	 */
+	for (bandcount = 0; bandcount < q->bands; bandcount++) {
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.  If the queue is stopped, try the
+		 * next queue.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, (q->mq ? q->curband : 0))) {
+			qdisc = q->queues[q->curband];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				q->curband++;
+				if (q->curband >= q->bands)
+					q->curband = 0;
+				return skb;
+			}
+		}
+		q->curband++;
+		if (q->curband >= q->bands)
+			q->curband = 0;
+	}
+	return NULL;
+}
+
 static unsigned int prio_drop(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -202,7 +258,7 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	struct rtattr *tb[TCA_PRIO_MAX];
 	int i;
 
-	if (rtattr_parse_nested_compat(tb, TCA_PRIO_MAX, opt, (void *)&qopt,
+	if (rtattr_parse_nested_compat(tb, TCA_PRIO_MAX, opt, qopt,
 				       sizeof(*qopt)))
 		return -EINVAL;
 	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
@@ -213,8 +269,14 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 			return -EINVAL;
 	}
 
-	if (tb[TCA_PRIO_TEST-1])
-		printk("TCA_PRIO_TEST: %u\n", *(u32 *)RTA_DATA(tb[TCA_PRIO_TEST-1]));
+	/* If we're multiqueue, make sure the number of incoming bands
+	 * matches the number of queues on the device we're associating with.
+	 */
+	if (tb[TCA_PRIO_MQ - 1])
+		q->mq = *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ - 1]);
+
+	if (q->mq && (qopt->bands != sch->dev->egress_subqueue_count))
+		return -EINVAL;
 
 	sch_tree_lock(sch);
 	q->bands = qopt->bands;
@@ -280,7 +342,7 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
 
 	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-	RTA_PUT_U32(skb, TCA_PRIO_TEST, 321);
+	RTA_PUT_U8(skb, TCA_PRIO_MQ, q->mq);
 	RTA_NEST_COMPAT_END(skb, nest);
 	return skb->len;
 
@@ -452,17 +514,39 @@ static struct Qdisc_ops prio_qdisc_ops = {
 	.owner		=	THIS_MODULE,
 };
 
+static struct Qdisc_ops rr_qdisc_ops = {
+	.next		=	NULL,
+	.cl_ops		=	&prio_class_ops,
+	.id		=	"rr",
+	.priv_size	=	sizeof(struct prio_sched_data),
+	.enqueue	=	prio_enqueue,
+	.dequeue	=	rr_dequeue,
+	.requeue	=	prio_requeue,
+	.drop		=	prio_drop,
+	.init		=	prio_init,
+	.reset		=	prio_reset,
+	.destroy	=	prio_destroy,
+	.change		=	prio_tune,
+	.dump		=	prio_dump,
+	.owner		=	THIS_MODULE,
+};
+
 static int __init prio_module_init(void)
 {
-	return register_qdisc(&prio_qdisc_ops);
+	register_qdisc(&prio_qdisc_ops);
+	register_qdisc(&rr_qdisc_ops);
+
+	return 0;
 }
 
 static void __exit prio_module_exit(void)
 {
 	unregister_qdisc(&prio_qdisc_ops);
+	unregister_qdisc(&rr_qdisc_ops);
 }
 
 module_init(prio_module_init)
 module_exit(prio_module_exit)
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("sch_rr");
