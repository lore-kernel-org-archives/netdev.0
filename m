From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Thu, 06 Aug 2009 17:14:21 +0530
Message-ID: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, Krishna Kumar <krkumar2@in.ibm.com>,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:49428 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbZHFLpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 07:45:12 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id n76BifTZ025265
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 21:44:41 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n76BjBNV495762
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 21:45:11 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n76BjA1E021471
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 21:45:11 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

dev_queue_xmit enqueue's a skb and calls qdisc_run which
dequeue's the skb and xmits it. In most cases, the skb that
is enqueue'd is the same one that is dequeue'd (unless the
queue gets stopped or multiple cpu's write to the same queue
and ends in a race with qdisc_run). For default qdiscs, we
can remove the redundant enqueue/dequeue and simply xmit the
skb since the default qdisc is work-conserving.

The patch uses a new flag - TCQ_F_CAN_BYPASS to identify the
default fast queue. The controversial part of the patch is
incrementing qlen when a skb is requeued - this is to avoid
checks like the second line below:

+  } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
>>         !q->gso_skb &&
+          !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {

Results of a 2 hour testing for multiple netperf sessions (1,
2, 4, 8, 12 sessions on a 4 cpu system-X). The BW numbers are
aggregate Mb/s across iterations tested with this version on
System-X boxes with Chelsio 10gbps cards:

----------------------------------
Size |  ORG BW          NEW BW   |
----------------------------------
128K |  156964          159381   |
256K |  158650          162042   |
----------------------------------

Changes from ver1:

1. Move sch_direct_xmit declaration from sch_generic.h to
   pkt_sched.h
2. Update qdisc basic statistics for direct xmit path.
3. Set qlen to zero in qdisc_reset.
4. Changed some function names to more meaningful ones.

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/pkt_sched.h   |    3 +
 include/net/sch_generic.h |   15 +++++
 net/core/dev.c            |   48 +++++++++++++-----
 net/sched/sch_generic.c   |   93 ++++++++++++++++++++++--------------
 4 files changed, 108 insertions(+), 51 deletions(-)

diff -ruNp org2/include/net/pkt_sched.h new6/include/net/pkt_sched.h
--- org2/include/net/pkt_sched.h	2009-08-04 11:41:21.000000000 +0530
+++ new6/include/net/pkt_sched.h	2009-08-05 22:24:41.000000000 +0530
@@ -87,6 +87,9 @@ extern struct qdisc_rate_table *qdisc_ge
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 extern void qdisc_put_stab(struct qdisc_size_table *tab);
 extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
+extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+			   struct net_device *dev, struct netdev_queue *txq,
+			   spinlock_t *root_lock);
 
 extern void __qdisc_run(struct Qdisc *q);
 
diff -ruNp org2/include/net/sch_generic.h new6/include/net/sch_generic.h
--- org2/include/net/sch_generic.h	2009-03-24 08:54:16.000000000 +0530
+++ new6/include/net/sch_generic.h	2009-08-05 22:26:40.000000000 +0530
@@ -45,6 +45,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN		1
 #define TCQ_F_THROTTLED		2
 #define TCQ_F_INGRESS		4
+#define TCQ_F_CAN_BYPASS	8
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
@@ -182,6 +183,11 @@ struct qdisc_skb_cb {
 	char			data[];
 };
 
+static inline int qdisc_qlen(struct Qdisc *q)
+{
+	return q->q.qlen;
+}
+
 static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
 {
 	return (struct qdisc_skb_cb *)skb->cb;
@@ -387,13 +393,18 @@ static inline int qdisc_enqueue_root(str
 	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
+static inline void __qdisc_update_bstats(struct Qdisc *sch, unsigned int len)
+{
+	sch->bstats.bytes += len;
+	sch->bstats.packets++;
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog += qdisc_pkt_len(skb);
-	sch->bstats.bytes += qdisc_pkt_len(skb);
-	sch->bstats.packets++;
+	__qdisc_update_bstats(sch, qdisc_pkt_len(skb));
 
 	return NET_XMIT_SUCCESS;
 }
diff -ruNp org2/net/core/dev.c new6/net/core/dev.c
--- org2/net/core/dev.c	2009-07-27 09:08:24.000000000 +0530
+++ new6/net/core/dev.c	2009-08-06 11:34:21.000000000 +0530
@@ -1786,6 +1786,40 @@ static struct netdev_queue *dev_pick_tx(
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
+static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
+				 struct net_device *dev,
+				 struct netdev_queue *txq)
+{
+	spinlock_t *root_lock = qdisc_lock(q);
+	int rc;
+
+	spin_lock(root_lock);
+	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+		kfree_skb(skb);
+		rc = NET_XMIT_DROP;
+	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
+		   !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
+		/*
+		 * This is a work-conserving queue; there are no old skbs
+		 * waiting to be sent out; and the qdisc is not running -
+		 * xmit the skb directly.
+		 */
+		__qdisc_update_bstats(q, skb->len);
+		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
+			__qdisc_run(q);
+		else
+			clear_bit(__QDISC_STATE_RUNNING, &q->state);
+
+		rc = NET_XMIT_SUCCESS;
+	} else {
+		rc = qdisc_enqueue_root(skb, q);
+		qdisc_run(q);
+	}
+	spin_unlock(root_lock);
+
+	return rc;
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -1859,19 +1893,7 @@ gso:
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
-		spinlock_t *root_lock = qdisc_lock(q);
-
-		spin_lock(root_lock);
-
-		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
-			kfree_skb(skb);
-			rc = NET_XMIT_DROP;
-		} else {
-			rc = qdisc_enqueue_root(skb, q);
-			qdisc_run(q);
-		}
-		spin_unlock(root_lock);
-
+		rc = __dev_xmit_skb(skb, q, dev, txq);
 		goto out;
 	}
 
diff -ruNp org2/net/sched/sch_generic.c new6/net/sched/sch_generic.c
--- org2/net/sched/sch_generic.c	2009-05-25 07:48:07.000000000 +0530
+++ new6/net/sched/sch_generic.c	2009-08-05 22:24:41.000000000 +0530
@@ -37,15 +37,11 @@
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
 
-static inline int qdisc_qlen(struct Qdisc *q)
-{
-	return q->q.qlen;
-}
-
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	q->gso_skb = skb;
 	q->qstats.requeues++;
+	q->q.qlen++;	/* it's still part of the queue */
 	__netif_schedule(q);
 
 	return 0;
@@ -61,9 +57,11 @@ static inline struct sk_buff *dequeue_sk
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
+		if (!netif_tx_queue_stopped(txq) &&
+		    !netif_tx_queue_frozen(txq)) {
 			q->gso_skb = NULL;
-		else
+			q->q.qlen--;
+		} else
 			skb = NULL;
 	} else {
 		skb = q->dequeue(q);
@@ -103,44 +101,23 @@ static inline int handle_dev_cpu_collisi
 }
 
 /*
- * NOTE: Called under qdisc_lock(q) with locally disabled BH.
- *
- * __QDISC_STATE_RUNNING guarantees only one CPU can process
- * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
- * this queue.
- *
- *  netif_tx_lock serializes accesses to device driver.
- *
- *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
- *  if one is grabbed, another must be free.
- *
- * Note, that this procedure can be called by a watchdog timer
+ * Transmit one skb, and handle the return status as required. Holding the
+ * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
+ * function.
  *
  * Returns to the caller:
  *				0  - queue is empty or throttled.
  *				>0 - queue is not empty.
- *
  */
-static inline int qdisc_restart(struct Qdisc *q)
+int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+		    struct net_device *dev, struct netdev_queue *txq,
+		    spinlock_t *root_lock)
 {
-	struct netdev_queue *txq;
 	int ret = NETDEV_TX_BUSY;
-	struct net_device *dev;
-	spinlock_t *root_lock;
-	struct sk_buff *skb;
-
-	/* Dequeue packet */
-	if (unlikely((skb = dequeue_skb(q)) == NULL))
-		return 0;
-
-	root_lock = qdisc_lock(q);
 
 	/* And release qdisc */
 	spin_unlock(root_lock);
 
-	dev = qdisc_dev(q);
-	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_tx_queue_stopped(txq) &&
 	    !netif_tx_queue_frozen(txq))
@@ -177,6 +154,44 @@ static inline int qdisc_restart(struct Q
 	return ret;
 }
 
+/*
+ * NOTE: Called under qdisc_lock(q) with locally disabled BH.
+ *
+ * __QDISC_STATE_RUNNING guarantees only one CPU can process
+ * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
+ * this queue.
+ *
+ *  netif_tx_lock serializes accesses to device driver.
+ *
+ *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
+ *  if one is grabbed, another must be free.
+ *
+ * Note, that this procedure can be called by a watchdog timer
+ *
+ * Returns to the caller:
+ *				0  - queue is empty or throttled.
+ *				>0 - queue is not empty.
+ *
+ */
+static inline int qdisc_restart(struct Qdisc *q)
+{
+	struct netdev_queue *txq;
+	struct net_device *dev;
+	spinlock_t *root_lock;
+	struct sk_buff *skb;
+
+	/* Dequeue packet */
+	skb = dequeue_skb(q);
+	if (unlikely(!skb))
+		return 0;
+
+	root_lock = qdisc_lock(q);
+	dev = qdisc_dev(q);
+	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+
+	return sch_direct_xmit(skb, q, dev, txq, root_lock);
+}
+
 void __qdisc_run(struct Qdisc *q)
 {
 	unsigned long start_time = jiffies;
@@ -547,8 +562,11 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 
-	kfree_skb(qdisc->gso_skb);
-	qdisc->gso_skb = NULL;
+	if (qdisc->gso_skb) {
+		kfree_skb(qdisc->gso_skb);
+		qdisc->gso_skb = NULL;
+		qdisc->q.qlen = 0;
+	}
 }
 EXPORT_SYMBOL(qdisc_reset);
 
@@ -605,6 +623,9 @@ static void attach_one_default_qdisc(str
 			printk(KERN_INFO "%s: activation failed\n", dev->name);
 			return;
 		}
+
+		/* Can by-pass the queue discipline for default qdisc */
+		qdisc->flags |= TCQ_F_CAN_BYPASS;
 	} else {
 		qdisc =  &noqueue_qdisc;
 	}
