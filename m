From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/10 Rev4] [sched] Modify qdisc_run to support batching
Date: Wed, 22 Aug 2007 13:59:36 +0530
Message-ID: <20070822082936.11964.25.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:49938 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbXHVI2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:28:07 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8TSBm031181
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:29:28 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8S6hg464236
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8S3wa025719
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:06 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify qdisc_run() to support batching. Modify callers of qdisc_run to
use batching, modify qdisc_restart to implement batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    2 +
 include/net/pkt_sched.h   |    6 +--
 net/core/dev.c            |   44 +++++++++++++++++++++++++++-
 net/sched/sch_generic.c   |   70 ++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 105 insertions(+), 17 deletions(-)

diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
--- org/include/net/pkt_sched.h	2007-08-20 14:26:36.000000000 +0530
+++ new/include/net/pkt_sched.h	2007-08-22 09:23:57.000000000 +0530
@@ -80,13 +80,13 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct net_device *dev);
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
--- org/include/linux/netdevice.h	2007-08-20 14:26:36.000000000 +0530
+++ new/include/linux/netdevice.h	2007-08-22 08:42:10.000000000 +0530
@@ -892,6 +896,8 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_add_skb_to_blist(struct sk_buff *skb,
+					     struct net_device *dev);
 
 extern void		dev_init(void);
 
diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-08-20 14:26:37.000000000 +0530
+++ new/net/sched/sch_generic.c	2007-08-22 08:49:55.000000000 +0530
@@ -59,10 +59,12 @@ static inline int qdisc_qlen(struct Qdis
 static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 				  struct Qdisc *q)
 {
-	if (unlikely(skb->next))
-		dev->gso_skb = skb;
-	else
-		q->ops->requeue(skb, q);
+	if (likely(skb)) {
+		if (unlikely(skb->next))
+			dev->gso_skb = skb;
+		else
+			q->ops->requeue(skb, q);
+	}
 
 	netif_schedule(dev);
 	return 0;
@@ -91,10 +93,15 @@ static inline int handle_dev_cpu_collisi
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
@@ -112,6 +119,38 @@ static inline int handle_dev_cpu_collisi
 }
 
 /*
+ * Algorithm to get skb(s) is:
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
+	if (likely(!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1))) {
+		return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
+	} else {
+		struct sk_buff *skb;
+		int max = dev->tx_queue_len - skb_queue_len(blist);
+
+		while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
+			max -= dev_add_skb_to_blist(skb, dev);
+
+		*skbp = NULL;
+		return 1;	/* there is atleast one skb in skb_blist */
+	}
+}
+
+/*
  * NOTE: Called under dev->queue_lock with locally disabled BH.
  *
  * __LINK_STATE_QDISC_RUNNING guarantees only one CPU can process this
@@ -130,7 +169,8 @@ static inline int handle_dev_cpu_collisi
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct net_device *dev)
+static inline int qdisc_restart(struct net_device *dev,
+				struct sk_buff_head *blist)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
@@ -138,7 +178,7 @@ static inline int qdisc_restart(struct n
 	int ret;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
+	if (unlikely(!get_skb(dev, q, blist, &skb)))
 		return 0;
 
 	/*
@@ -168,7 +208,7 @@ static inline int qdisc_restart(struct n
 
 	switch (ret) {
 	case NETDEV_TX_OK:
-		/* Driver sent out skb successfully */
+		/* Driver sent out skb (or entire skb_blist) successfully */
 		ret = qdisc_qlen(q);
 		break;
 
@@ -190,10 +230,10 @@ static inline int qdisc_restart(struct n
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
 
@@ -563,6 +603,12 @@ void dev_deactivate(struct net_device *d
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
--- org/net/core/dev.c	2007-08-20 14:26:37.000000000 +0530
+++ new/net/core/dev.c	2007-08-22 10:49:22.000000000 +0530
@@ -1466,6 +1466,45 @@ static int dev_gso_segment(struct sk_buf
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
+			kfree(skb);
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
@@ -1620,7 +1659,7 @@ gso:
 			/* reset queue_mapping to zero */
 			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
-			qdisc_run(dev);
+			qdisc_run(dev, NULL);
 			spin_unlock(&dev->queue_lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
@@ -1818,7 +1857,8 @@ static void net_tx_action(struct softirq
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
 			if (spin_trylock(&dev->queue_lock)) {
-				qdisc_run(dev);
+				/* Send all skbs if driver supports batching */
+				qdisc_run(dev, dev->skb_blist);
 				spin_unlock(&dev->queue_lock);
 			} else {
 				netif_schedule(dev);
