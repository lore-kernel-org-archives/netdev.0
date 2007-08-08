From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to support batching
Date: Wed, 08 Aug 2007 15:01:45 +0530
Message-ID: <20070808093145.15396.91711.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	rick.jones2@hp.com, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	hadi@cyberus.ca, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, xma@us.ibm.com
To: johnpol@2ka.mipt.ru, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:32851 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054AbXHHJcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:32:45 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l789Z3Fj129764
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:35:15 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l789UcFa516098
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:39 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l789UZYi002648
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:38 +1000
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify qdisc_run() to support batching. Modify callers of qdisc_run to
use batching, modify qdisc_restart to implement batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/pkt_sched.h |    6 +--
 net/core/dev.c          |    5 +--
 net/sched/sch_generic.c |   77 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 69 insertions(+), 19 deletions(-)

diff -ruNp ORG/include/net/pkt_sched.h NEW/include/net/pkt_sched.h
--- ORG/include/net/pkt_sched.h	2007-07-17 08:48:37.000000000 +0530
+++ NEW/include/net/pkt_sched.h	2007-08-07 13:11:19.000000000 +0530
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
diff -ruNp ORG/net/sched/sch_generic.c NEW/net/sched/sch_generic.c
--- ORG/net/sched/sch_generic.c	2007-07-12 08:55:20.000000000 +0530
+++ NEW/net/sched/sch_generic.c	2007-08-07 13:11:19.000000000 +0530
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
@@ -91,17 +93,22 @@ static inline int handle_dev_cpu_collisi
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
 		ret = qdisc_qlen(q);
 	} else {
 		/*
-		 * Another cpu is holding lock, requeue & delay xmits for
+		 * Another cpu is holding lock, requeue skb & delay xmits for
 		 * some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
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
+		int max = dev->tx_queue_len - skb_queue_len(blist);
+		struct sk_buff *skb;
+
+		while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
+			max -= dev_add_skb_to_blist(skb, dev);
+
+		*skbp = NULL;
+		return 1;	/* we have atleast one skb in blist */
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
@@ -158,7 +198,10 @@ static inline int qdisc_restart(struct n
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	ret = dev_hard_start_xmit(skb, dev);
+	if (likely(skb))
+		ret = dev_hard_start_xmit(skb, dev);
+	else
+		ret = dev->hard_start_xmit_batch(dev);
 
 	if (!lockless)
 		netif_tx_unlock(dev);
@@ -168,7 +211,7 @@ static inline int qdisc_restart(struct n
 
 	switch (ret) {
 	case NETDEV_TX_OK:
-		/* Driver sent out skb successfully */
+		/* Driver sent out skb (or entire skb_blist) successfully */
 		ret = qdisc_qlen(q);
 		break;
 
@@ -190,10 +233,10 @@ static inline int qdisc_restart(struct n
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
 
@@ -563,6 +606,12 @@ void dev_deactivate(struct net_device *d
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
diff -ruNp ORG/net/core/dev.c NEW/net/core/dev.c
--- ORG/net/core/dev.c	2007-08-06 08:25:40.000000000 +0530
+++ NEW/net/core/dev.c	2007-08-07 13:11:19.000000000 +0530
@@ -1699,7 +1699,7 @@ gso:
 			/* reset queue_mapping to zero */
 			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
-			qdisc_run(dev);
+			qdisc_run(dev, NULL);
 			spin_unlock(&dev->queue_lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
@@ -1896,7 +1896,8 @@ static void net_tx_action(struct softirq
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
 			if (spin_trylock(&dev->queue_lock)) {
-				qdisc_run(dev);
+				/* Send all skbs if driver supports batching */
+				qdisc_run(dev, dev->skb_blist);
 				spin_unlock(&dev->queue_lock);
 			} else {
 				netif_schedule(dev);
