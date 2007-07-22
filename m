From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 07/12 -Rev2] Change qdisc_run & qdisc_restart
	API, callers
Date: Sun, 22 Jul 2007 14:36:02 +0530
Message-ID: <20070722090602.7787.50560.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	hadi@cyberus.ca, kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/include/net/pkt_sched.h rev2/include/net/pkt_sched.h
--- org/include/net/pkt_sched.h	2007-07-20 07:49:28.000000000 +0530
+++ rev2/include/net/pkt_sched.h	2007-07-20 16:09:45.000000000 +0530
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
diff -ruNp org/net/sched/sch_generic.c rev2/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/net/sched/sch_generic.c	2007-07-22 12:11:10.000000000 +0530
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
@@ -91,18 +93,23 @@ static inline int handle_dev_cpu_collisi
 		/*
 		 * Same CPU holding the lock. It may be a transient
 		 * configuration error, when hard_start_xmit() recurses. We
-		 * detect it by checking xmit owner and drop the packet when
-		 * deadloop is detected. Return OK to try the next skb.
+		 * detect it by checking xmit owner and drop skb (or all
+		 * skbs in batching case) when deadloop is detected. Return
+		 * OK to try the next skb.
 		 */
-		kfree_skb(skb);
+		if (likely(skb))
+			kfree_skb(skb);
+		else if (!skb_queue_empty(&dev->skb_blist))
+			skb_queue_purge(&dev->skb_blist);
+
 		if (net_ratelimit())
 			printk(KERN_WARNING "Dead loop on netdevice %s, "
 			       "fix it urgently!\n", dev->name);
 		ret = qdisc_qlen(q);
 	} else {
 		/*
-		 * Another cpu is holding lock, requeue & delay xmits for
-		 * some time.
+		 * Another cpu is holding lock. Requeue skb and delay xmits
+		 * for some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
 		ret = dev_requeue_skb(skb, dev, q);
@@ -112,6 +119,38 @@ static inline int handle_dev_cpu_collisi
 }
 
 /*
+ * Algorithm to get skb(s) is:
+ *	- Non batching drivers, or if the batch list is empty and there is
+ *	  atmost one skb in the queue - dequeue skb and put it in *skbp to
+ *	  tell the caller to use the single xmit API.
+ *	- Batching drivers where the batch list already contains atleast one
+ *	  skb or if there are multiple skbs in the queue: keep dequeue'ing
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
+	if (likely(!blist) || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1)) {
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
 
@@ -179,8 +222,8 @@ static inline int qdisc_restart(struct n
 
 	default:
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
-		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
-			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
+		if (unlikely(ret != NETDEV_TX_BUSY) && net_ratelimit())
+			printk(KERN_WARNING " %s: BUG. code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
 		ret = dev_requeue_skb(skb, dev, q);
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
 
@@ -567,6 +610,13 @@ void dev_deactivate(struct net_device *d
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
+
+	if (BATCHING_ON(dev)) {
+		/* Free skbs on batch list */
+		if (!skb_queue_empty(&dev->skb_blist))
+			skb_queue_purge(&dev->skb_blist);
+	}
+
 	spin_unlock_bh(&dev->queue_lock);
 
 	kfree_skb(skb);
diff -ruNp org/net/core/dev.c rev2/net/core/dev.c
--- org/net/core/dev.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/net/core/dev.c	2007-07-21 23:08:33.000000000 +0530
@@ -1647,7 +1647,7 @@ gso:
 			/* reset queue_mapping to zero */
 			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
-			qdisc_run(dev);
+			qdisc_run(dev, NULL);
 			spin_unlock(&dev->queue_lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
@@ -1844,7 +1844,12 @@ static void net_tx_action(struct softirq
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
 			if (spin_trylock(&dev->queue_lock)) {
-				qdisc_run(dev);
+				/*
+				 * Try to send out all skbs if batching is
+				 * enabled.
+				 */
+				qdisc_run(dev, BATCHING_ON(dev) ?
+					       &dev->skb_blist : NULL);
 				spin_unlock(&dev->queue_lock);
 			} else {
 				netif_schedule(dev);
