From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: [PATCH] qdisc_restart - readability changes (plus couple of
	optimizations)
Date: Mon, 11 Jun 2007 16:33:25 +0530
Message-ID: <1181559805.30181.22.camel@k50wks273871wss.in.ibm.com>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org, krkumar2@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:60426 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbXFKLDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 07:03:15 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5BB4fYS8020212
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 21:04:41 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BB6gVR209634
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 21:06:43 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BB33td024559
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 21:03:04 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I am sorry to miss out during Jamal's original effort to make
qdisc_restart more readable, but I feel some more changes could
help in that direction. Plus there were some useful comments
in the original code which I updated (hopefully correctly) and
put back - it does seem useful for a new reader.

Other changes :

- netif_queue_stopped need not be called inside qdisc_restart as
  it has been called already in qdisc_run() before the first skb
  is sent, and in __qdisc_run() after each intermediate skb is 
  sent (note : we are the only sender, so the queue cannot get
  stopped while the tx lock was got in the ~LLTX case).

- BUG_ON((int) q->q.qlen < 0) was a relic from old times when -1
  meant more packets are available, and __qdisc_run used to loop
  when qdisc_restart() returned -1. During those days, it was
  necessary to make sure that qlen is never less than zero, since
  __qdisc_run would get into an infinite loop if no packets are on
  the queue and this bug in qdisc was there (and worse - no more
  skbs could ever get queue'd as we hold the queue lock too). With
  Herbert's recent change to return values, this check is not
  required and hopefully Herbert can validate this change. If at
  all the check is required, it should be added to skb_dequeue (in
  failure case), and not to qdisc_qlen.

- Convert to use neater switch/case code.

- "if (ret == NETDEV_TX_LOCKED && lockless)" can be changed to
  remove the lockless check, since driver will return
  NETDEV_TX_LOCKED only if lockless is true and driver has to do the
  locking. In the original code, this hack was fixing a driver bug
  where the driver was also getting tx lock despite ~LLTX being set.
  But that is anyway handled in the current code where
  netif_tx_unlock() is called, plus removing this check will catch
  these driver bugs instead of hiding the problem.

- Changed some names, like try_get_tx_pkt to dev_dequeue (as that is
  the work being done and easier to understand) and similarly
  do_dev_requeue to dev_requeue, merged handle_dev_cpu_collision and
  tx_islocked to dev_handle_collision (handle_dev_cpu_collision is a
  small routine with only one caller, so no need to have two separate
  routines thereby getting rid of two unnecessary macros), etc.

- Removed an XXX comment as it should never fail (I suspect this was
  related to batch skb WIP, Jamal ?). Converted some functions to
  original coding style of having return values and the function name
  on same line, eg prio2list.

I ran a 50 process netperf2 (both TCP & UDP) without issues.

Please provide your comments/feedback (cc'ing the original reviewers
also, as per Jamal's mail from May 25th).

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-06-11 13:12:11.000000000 +0530
+++ new/net/sched/sch_generic.c	2007-06-11 15:37:48.000000000 +0530
@@ -34,9 +34,6 @@
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
-#define SCHED_TX_DROP -2
-#define SCHED_TX_QUEUE -3
-
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
@@ -64,45 +61,27 @@ void qdisc_unlock_tree(struct net_device
 
 static inline int qdisc_qlen(struct Qdisc *q)
 {
-	BUG_ON((int) q->q.qlen < 0);
 	return q->q.qlen;
 }
 
-static inline int handle_dev_cpu_collision(struct net_device *dev)
-{
-	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "Dead loop on netdevice %s, fix it urgently!\n",
-			       dev->name);
-		return SCHED_TX_DROP;
-	}
-	__get_cpu_var(netdev_rx_stat).cpu_collision++;
-	return SCHED_TX_QUEUE;
-}
-
-static inline int
-do_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+static inline int requeue_skb(struct sk_buff *skb, struct net_device *dev,
+			      struct Qdisc *q)
 {
-
 	if (unlikely(skb->next))
 		dev->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
-	/* XXX: Could netif_schedule fail? Or is the fact we are
-	 * requeueing imply the hardware path is closed
-	 * and even if we fail, some interupt will wake us
-	 */
+
 	netif_schedule(dev);
 	return 0;
 }
 
-static inline struct sk_buff *
-try_get_tx_pkt(struct net_device *dev, struct Qdisc *q)
+static inline struct sk_buff *dequeue_skb(struct net_device *dev,
+					  struct Qdisc *q)
 {
-	struct sk_buff *skb = dev->gso_skb;
+	struct sk_buff *skb;
 
-	if (skb)
+	if ((skb = dev->gso_skb))
 		dev->gso_skb = NULL;
 	else
 		skb = q->dequeue(q);
@@ -110,92 +89,111 @@ try_get_tx_pkt(struct net_device *dev, s
 	return skb;
 }
 
-static inline int
-tx_islocked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+static inline int handle_dev_cpu_collision(struct sk_buff *skb,
+					   struct net_device *dev,
+					   struct Qdisc *q)
 {
-	int ret = handle_dev_cpu_collision(dev);
+	int ret;
 
-	if (ret == SCHED_TX_DROP) {
+	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
+		/*
+		 * Same CPU holding the lock. It may be a transient
+		 * configuration error, when hard_start_xmit() recurses. We
+		 * detect it by checking xmit owner and drop the packet when
+		 * deadloop is detected. Return OK to try the next skb.
+		 */
 		kfree_skb(skb);
-		return qdisc_qlen(q);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "Dead loop on netdevice %s, "
+			       "fix it urgently!\n", dev->name);
+		ret = qdisc_qlen(q);
+	} else {
+		/*
+		 * Another cpu is holding lock, requeue & delay xmits for
+		 * some time.
+		 */
+		__get_cpu_var(netdev_rx_stat).cpu_collision++;
+		ret = requeue_skb(skb, dev, q);
 	}
 
-	return do_dev_requeue(skb, dev, q);
+	return ret;
 }
 
-
 /*
-   NOTE: Called under dev->queue_lock with locally disabled BH.
-
-   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
-   can enter this region at a time.
-
-   dev->queue_lock serializes queue accesses for this device
-   AND dev->qdisc pointer itself.
-
-   netif_tx_lock serializes accesses to device driver.
-
-   dev->queue_lock and netif_tx_lock are mutually exclusive,
-   if one is grabbed, another must be free.
-
-   Multiple CPUs may contend for the two locks.
-
-   Note, that this procedure can be called by a watchdog timer
-
-   Returns to the caller:
-   Returns:  0  - queue is empty or throttled.
-	    >0  - queue is not empty.
-
-*/
-
+ * NOTE: Called under dev->queue_lock with locally disabled BH.
+ *
+ * __LINK_STATE_QDISC_RUNNING guarantees only one CPU can process this
+ * device at a time. dev->queue_lock serializes queue accesses for
+ * this device AND dev->qdisc pointer itself.
+ * 
+ *  netif_tx_lock serializes accesses to device driver.
+ *
+ *  dev->queue_lock and netif_tx_lock are mutually exclusive,
+ *  if one is grabbed, another must be free.
+ *
+ * Note, that this procedure can be called by a watchdog timer
+ *
+ * Returns to the caller:
+ *				0  - queue is empty or throttled.
+ *				>0 - queue is not empty.
+ *
+ */
 static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
-	unsigned lockless = (dev->features & NETIF_F_LLTX);
 	struct sk_buff *skb;
+	unsigned lockless;
 	int ret;
 
-	skb = try_get_tx_pkt(dev, q);
-	if (skb == NULL)
+	/* Dequeue packet */
+	if (unlikely((skb = dequeue_skb(dev, q)) == NULL))
 		return 0;
 
-	/* we have a packet to send */
-	if (!lockless) {
-		if (!netif_tx_trylock(dev))
-			return tx_islocked(skb, dev, q);
+	/*
+	 * When the driver has LLTX set, it does its own locking in
+	 * start_xmit. These checks are worth it because even uncongested
+	 * locks can be quite expensive. The driver can do a trylock, as
+	 * is being done here; in case of lock contention it should return
+	 * NETDEV_TX_LOCKED and the packet will be requeued.
+	 */
+	lockless = (dev->features & NETIF_F_LLTX);
+
+	if (!lockless && !netif_tx_trylock(dev)) {
+		/* Another CPU grabbed the driver tx lock */
+		return handle_dev_cpu_collision(skb, dev, q);
 	}
-	/* all clear .. */
+
+	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	ret = NETDEV_TX_BUSY;
-	if (!netif_queue_stopped(dev))
-		/* churn baby churn .. */
-		ret = dev_hard_start_xmit(skb, dev);
+	ret = dev_hard_start_xmit(skb, dev);
 
 	if (!lockless)
 		netif_tx_unlock(dev);
 
 	spin_lock(&dev->queue_lock);
-
-	/* we need to refresh q because it may be invalid since
-	 * we dropped  dev->queue_lock earlier ...
-	 * So dont try to be clever grasshopper
-	 */
 	q = dev->qdisc;
-	/* most likely result, packet went ok */
-	if (ret == NETDEV_TX_OK)
-		return qdisc_qlen(q);
-	/* only for lockless drivers .. */
-	if (ret == NETDEV_TX_LOCKED && lockless)
-		return tx_islocked(skb, dev, q);
 
-	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
-		printk(KERN_WARNING " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
+	switch (ret) {
+	case NETDEV_TX_OK:
+		/* Driver sent out skb successfully */
+		ret = qdisc_qlen(q);
+		break;
+
+	case NETDEV_TX_LOCKED:
+		/* Driver try lock failed */
+		ret = handle_dev_cpu_collision(skb, dev, q);
+		break;
+
+	default:
+		/* Driver returned NETDEV_TX_BUSY - requeue skb */
+		ret = requeue_skb(skb, dev, q);
+		break;
+	}
 
-	return do_dev_requeue(skb, dev, q);
+	return ret;
 }
 
-
 void __qdisc_run(struct net_device *dev)
 {
 	do {


