From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 14:26:47 -0700
Message-ID: <20070621212647.31066.61074.stgit@localhost.localdomain>
References: <20070621212629.31066.92148.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	kaber@trash.net, hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39067 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551AbXFUV0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 17:26:48 -0400
In-Reply-To: <20070621212629.31066.92148.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the new sch_rr qdisc for multiqueue network device support.
Allow sch_prio to be compiled with or without multiqueue hardware
support.

sch_rr is part of sch_prio, and is referenced from MODULE_ALIAS.  This
was done since sch_prio and sch_rr only differ in their dequeue routine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/sched/Kconfig       |   32 ++++++++++++
 net/sched/sch_generic.c |    3 +
 net/sched/sch_prio.c    |  123 ++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 150 insertions(+), 8 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..ca0b352 100644
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
@@ -111,6 +119,30 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
+config NET_SCH_PRIO_MQ
+	bool "Multiple hardware queue support for PRIO"
+	depends on NET_SCH_PRIO
+	---help---
+	  Say Y here if you want to allow the PRIO qdisc to assign
+	  flows to multiple hardware queues on an ethernet device.  This
+	  will still work on devices with 1 queue.
+
+	  Consider this scheduler for devices that do not use
+	  hardware-based scheduling policies.  Otherwise, use NET_SCH_RR.
+
+	  Most people will say N here.
+
+config NET_SCH_RR
+	bool "Multi Band Round Robin Queuing (RR)"
+	depends on NET_SCH_BANDS && NET_SCH_PRIO
+	---help---
+	  Say Y here if you want to use an n-band round robin packet
+	  scheduler.
+
+	  The module uses sch_prio for its framework and is aliased as
+	  sch_rr, so it will load sch_prio, although it is referred
+	  to using sch_rr.
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
index 6d7542c..4eb3ba5 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -9,6 +9,8 @@
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  * Fixes:       19990609: J Hadi Salim <hadi@nortelnetworks.com>:
  *              Init --  EINVAL when opt undefined
+ * Additions:	Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
+ *		Added round-robin scheduling for selection at load-time
  */
 
 #include <linux/module.h>
@@ -40,9 +42,13 @@
 struct prio_sched_data
 {
 	int bands;
+#ifdef CONFIG_NET_SCH_RR
+	int curband; /* for round-robin */
+#endif
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	u16 band2queue[TC_PRIO_MAX + 1];
 };
 
 
@@ -70,14 +76,19 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
+			skb->queue_mapping =
+				q->band2queue[q->prio2band[band&TC_PRIO_MAX]];
 			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
-	if (band >= q->bands)
+	if (band >= q->bands) {
+ 		skb->queue_mapping = q->band2queue[q->prio2band[0]];
 		return q->queues[q->prio2band[0]];
+	}
 
+ 	skb->queue_mapping = q->band2queue[band];
 	return q->queues[band];
 }
 
@@ -144,17 +155,59 @@ prio_dequeue(struct Qdisc* sch)
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
+		if (!netif_subqueue_stopped(sch->dev, q->band2queue[prio])) {
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
 
+#ifdef CONFIG_NET_SCH_RR
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
+		if (!netif_subqueue_stopped(sch->dev, q->band2queue[q->curband])) {
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
+#endif
+
 static unsigned int prio_drop(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -200,6 +253,7 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt = RTA_DATA(opt);
 	int i;
+	int queue;
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
@@ -211,6 +265,22 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 			return -EINVAL;
 	}
 
+	/* If we're prio multiqueue or are using round-robin, make
+	 * sure the number of incoming bands matches the number of
+	 * queues on the device we're associating with.
+	 */
+#ifdef CONFIG_NET_SCH_RR
+	if (strcmp("rr", sch->ops->id) == 0)
+		if (qopt->bands != sch->dev->egress_subqueue_count)
+			return -EINVAL;
+#endif
+
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+	if (strcmp("prio", sch->ops->id) == 0)
+		if (qopt->bands != sch->dev->egress_subqueue_count)
+			return -EINVAL;
+#endif
+
 	sch_tree_lock(sch);
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
@@ -242,6 +312,18 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 			}
 		}
 	}
+
+	/* setup queue to band mapping */
+	for (i = 0, queue = 0; i < q->bands; i++, queue++)
+		q->band2queue[i] = queue;
+
+#ifndef CONFIG_NET_SCH_PRIO_MQ
+	/* for non-mq prio */
+	if (strcmp("prio", sch->ops->id) == 0)
+		for (i = 0; i < q->bands; i++)
+			q->band2queue[i] = 0;
+#endif
+
 	return 0;
 }
 
@@ -443,17 +525,44 @@ static struct Qdisc_ops prio_qdisc_ops = {
 	.owner		=	THIS_MODULE,
 };
 
+#ifdef CONFIG_NET_SCH_RR
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
+#endif
+
 static int __init prio_module_init(void)
 {
-	return register_qdisc(&prio_qdisc_ops);
+	register_qdisc(&prio_qdisc_ops);
+#ifdef CONFIG_NET_SCH_RR
+	register_qdisc(&rr_qdisc_ops);
+#endif
+	return 0;
 }
 
 static void __exit prio_module_exit(void)
 {
 	unregister_qdisc(&prio_qdisc_ops);
+#ifdef CONFIG_NET_SCH_RR
+	unregister_qdisc(&rr_qdisc_ops);
+#endif
 }
 
 module_init(prio_module_init)
 module_exit(prio_module_exit)
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("sch_rr");
