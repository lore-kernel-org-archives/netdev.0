From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/10 REV5] [sched] Modify qdisc_run to support batching
Date: Fri, 14 Sep 2007 14:31:56 +0530
Message-ID: <20070914090156.17589.61701.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, randy.dunlap@oracle.com,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:44153 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbXINI74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:59:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E8xumq016433
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:56 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E8xubZ689544
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:56 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E8xrZ3022321
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:55 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify qdisc_run() to support batching. Modify callers of qdisc_run to
use batching, modify qdisc_restart to implement batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    2 
 include/net/pkt_sched.h   |   17 +++++--
 net/core/dev.c            |   45 ++++++++++++++++++
 net/sched/sch_generic.c   |  109 ++++++++++++++++++++++++++++++++++++----------
 4 files changed, 145 insertions(+), 28 deletions(-)

diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
--- org/include/net/pkt_sched.h	2007-09-13 09:11:09.000000000 +0530
+++ new/include/net/pkt_sched.h	2007-09-14 10:25:36.000000000 +0530
@@ -80,13 +80,24 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct net_device *dev);
+static inline void qdisc_block(struct net_device *dev)
+{
+	while (test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+		yield();
+}
+
+static inline void qdisc_unblock(struct net_device *dev)
+{
+	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+}
+
+extern void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist);
 
-static inline void qdisc_run(struct net_device *dev)
+static inline void qdisc_run(struct net_device *dev, struct sk_buff_head *blist)
 {
 	if (!netif_queue_stopped(dev) &&
 	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
-		__qdisc_run(dev);
+		__qdisc_run(dev, blist);
 }
 
 extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-09-13 09:11:09.000000000 +0530
+++ new/include/linux/netdevice.h	2007-09-14 10:26:21.000000000 +0530
@@ -1013,6 +1013,8 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_add_skb_to_blist(struct sk_buff *skb,
+					     struct net_device *dev);
 
 extern int		netdev_budget;
 
diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-09-13 09:11:10.000000000 +0530
+++ new/net/sched/sch_generic.c	2007-09-14 10:25:36.000000000 +0530
@@ -59,26 +59,30 @@ static inline int qdisc_qlen(struct Qdis
 static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 				  struct Qdisc *q)
 {
-	if (unlikely(skb->next))
-		dev->gso_skb = skb;
-	else
-		q->ops->requeue(skb, q);
+	if (skb) {
+		if (unlikely(skb->next))
+			dev->gso_skb = skb;
+		else
+			q->ops->requeue(skb, q);
+	}
 
 	netif_schedule(dev);
 	return 0;
 }
 
-static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
-					      struct Qdisc *q)
+static inline int dev_requeue_skb_wrapper(struct sk_buff *skb,
+					  struct net_device *dev,
+					  struct Qdisc *q)
 {
-	struct sk_buff *skb;
-
-	if ((skb = dev->gso_skb))
-		dev->gso_skb = NULL;
-	else
-		skb = q->dequeue(q);
+	if (dev->skb_blist) {
+		/*
+		 * In case of tx full, batching drivers would have put all
+		 * skbs into skb_blist so there is no skb to requeue.
+		 */
+		skb = NULL;
+	}
 
-	return skb;
+	return dev_requeue_skb(skb, dev, q);
 }
 
 static inline int handle_dev_cpu_collision(struct sk_buff *skb,
@@ -91,10 +95,15 @@ static inline int handle_dev_cpu_collisi
 		/*
 		 * Same CPU holding the lock. It may be a transient
 		 * configuration error, when hard_start_xmit() recurses. We
-		 * detect it by checking xmit owner and drop the packet when
-		 * deadloop is detected. Return OK to try the next skb.
+		 * detect it by checking xmit owner and drop the packet (or
+		 * all packets in batching case) when deadloop is detected.
+		 * Return OK to try the next skb.
 		 */
-		kfree_skb(skb);
+		if (likely(skb))
+			kfree_skb(skb);
+		else if (!skb_queue_empty(dev->skb_blist))
+			skb_queue_purge(dev->skb_blist);
+
 		if (net_ratelimit())
 			printk(KERN_WARNING "Dead loop on netdevice %s, "
 			       "fix it urgently!\n", dev->name);
@@ -111,6 +120,53 @@ static inline int handle_dev_cpu_collisi
 	return ret;
 }
 
+#define DEQUEUE_SKB(q)		(q->dequeue(q))
+
+static inline struct sk_buff *get_gso_skb(struct net_device *dev)
+{
+	struct sk_buff *skb;
+
+	if ((skb = dev->gso_skb))
+		dev->gso_skb = NULL;
+
+	return skb;
+}
+
+/*
+ * Algorithm to get skb(s) is:
+ *	- If gso skb present, return it.
+ *	- Non batching drivers, or if the batch list is empty and there is
+ *	  1 skb in the queue - dequeue skb and put it in *skbp to tell the
+ *	  caller to use the single xmit API.
+ *	- Batching drivers where the batch list already contains atleast one
+ *	  skb, or if there are multiple skbs in the queue: keep dequeue'ing
+ *	  skb's upto a limit and set *skbp to NULL to tell the caller to use
+ *	  the multiple xmit API.
+ *
+ * Returns:
+ *	1 - atleast one skb is to be sent out, *skbp contains skb or NULL
+ *	    (in case >1 skbs present in blist for batching)
+ *	0 - no skbs to be sent.
+ */
+static inline int get_skb(struct net_device *dev, struct Qdisc *q,
+			  struct sk_buff_head *blist, struct sk_buff **skbp)
+{
+	if ((*skbp = get_gso_skb(dev)) != NULL)
+		return 1;
+
+	if (!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1)) {
+		return likely((*skbp = DEQUEUE_SKB(q)) != NULL);
+	} else {
+		struct sk_buff *skb;
+		int max = dev->tx_queue_len - skb_queue_len(blist);
+
+		while (max > 0 && (skb = DEQUEUE_SKB(q)) != NULL)
+			max -= dev_add_skb_to_blist(skb, dev);
+
+		return 1;	/* there is atleast one skb in skb_blist */
+	}
+}
+
 /*
  * NOTE: Called under dev->queue_lock with locally disabled BH.
  *
@@ -130,7 +186,8 @@ static inline int handle_dev_cpu_collisi
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct net_device *dev)
+static inline int qdisc_restart(struct net_device *dev,
+				struct sk_buff_head *blist)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
@@ -138,7 +195,7 @@ static inline int qdisc_restart(struct n
 	int ret;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
+	if (unlikely(get_skb(dev, q, blist, &skb) == 0))
 		return 0;
 
 	/*
@@ -168,7 +225,7 @@ static inline int qdisc_restart(struct n
 
 	switch (ret) {
 	case NETDEV_TX_OK:
-		/* Driver sent out skb successfully */
+		/* Driver sent out skb (or entire skb_blist) successfully */
 		ret = qdisc_qlen(q);
 		break;
 
@@ -183,21 +240,21 @@ static inline int qdisc_restart(struct n
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skb_wrapper(skb, dev, q);
 		break;
 	}
 
 	return ret;
 }
 
-void __qdisc_run(struct net_device *dev)
+void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist)
 {
 	do {
-		if (!qdisc_restart(dev))
+		if (!qdisc_restart(dev, blist))
 			break;
 	} while (!netif_queue_stopped(dev));
 
-	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+	qdisc_unblock(dev);
 }
 
 static void dev_watchdog(unsigned long arg)
@@ -575,6 +632,12 @@ void dev_deactivate(struct net_device *d
 	qdisc = dev->qdisc;
 	dev->qdisc = &noop_qdisc;
 
+	if (dev->skb_blist) {
+		/* Release skbs on batch list */
+		if (!skb_queue_empty(dev->skb_blist))
+			skb_queue_purge(dev->skb_blist);
+	}
+
 	qdisc_reset(qdisc);
 
 	skb = dev->gso_skb;
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2007-09-14 10:24:27.000000000 +0530
+++ new/net/core/dev.c	2007-09-14 10:25:36.000000000 +0530
@@ -1542,6 +1542,46 @@ static int dev_gso_segment(struct sk_buf
 	return 0;
 }
 
+/*
+ * Add skb (skbs in case segmentation is required) to dev->skb_blist. No one
+ * can add to this list simultaneously since we are holding QDISC RUNNING
+ * bit. Also list is safe from simultaneous deletes too since skbs are
+ * dequeued only when the driver is invoked.
+ *
+ * Returns count of successful skb(s) added to skb_blist.
+ */
+int dev_add_skb_to_blist(struct sk_buff *skb, struct net_device *dev)
+{
+	if (!list_empty(&ptype_all))
+		dev_queue_xmit_nit(skb, dev);
+
+	if (netif_needs_gso(dev, skb)) {
+		if (unlikely(dev_gso_segment(skb))) {
+			kfree_skb(skb);
+			return 0;
+		}
+
+		if (skb->next) {
+			int count = 0;
+
+			do {
+				struct sk_buff *nskb = skb->next;
+
+				skb->next = nskb->next;
+				__skb_queue_tail(dev->skb_blist, nskb);
+				count++;
+			} while (skb->next);
+
+			/* Reset destructor for kfree_skb to work */
+			skb->destructor = DEV_GSO_CB(skb)->destructor;
+			kfree_skb(skb);
+			return count;
+		}
+	}
+	__skb_queue_tail(dev->skb_blist, skb);
+	return 1;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(skb)) {
@@ -1697,7 +1737,7 @@ gso:
 			/* reset queue_mapping to zero */
 			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
-			qdisc_run(dev);
+			qdisc_run(dev, NULL);
 			spin_unlock(&dev->queue_lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
@@ -1895,7 +1935,8 @@ static void net_tx_action(struct softirq
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
 			if (spin_trylock(&dev->queue_lock)) {
-				qdisc_run(dev);
+				/* Send all skbs if driver supports batching */
+				qdisc_run(dev, dev->skb_blist);
 				spin_unlock(&dev->queue_lock);
 			} else {
 				netif_schedule(dev);
