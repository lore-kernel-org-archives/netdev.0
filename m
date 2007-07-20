From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 05/10] sch_generic.c changes.
Date: Fri, 20 Jul 2007 12:02:49 +0530
Message-ID: <20070720063249.26341.125.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, kaber@trash.net, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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

net/sched/sch_generic.c changes to support batching. Adds a batch
aware function (get_skb) to get skbs to send.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 sch_generic.c |   94 +++++++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 71 insertions(+), 23 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-07-20 07:49:28.000000000 +0530
+++ new/net/sched/sch_generic.c	2007-07-20 08:30:22.000000000 +0530
@@ -9,6 +9,11 @@
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *              Jamal Hadi Salim, <hadi@cyberus.ca> 990601
  *              - Ingress support
+ *
+ * New functionality:
+ *		Krishna Kumar, <krkumar2@in.ibm.com>, July 2007
+ *		- Support for sending multiple skbs to devices that support
+ *		  new api - dev->hard_start_xmit_batch()
  */
 
 #include <linux/bitops.h>
@@ -59,10 +64,12 @@ static inline int qdisc_qlen(struct Qdis
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
@@ -91,18 +98,23 @@ static inline int handle_dev_cpu_collisi
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
-		 * some time.
+		 * Another cpu is holding lock. Requeue skb and delay xmits
+		 * for some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
 		ret = dev_requeue_skb(skb, dev, q);
@@ -112,6 +124,39 @@ static inline int handle_dev_cpu_collisi
 }
 
 /*
+ * Algorithm to get skb(s) is:
+ *	- Non batching drivers, or if the batch list is empty and there is 1
+ *	  skb in the queue - dequeue skb and put it in *skbp to tell the
+ *	  caller to use the regular API.
+ *	- Batching drivers where the batch list already contains atleast one
+ *	  skb or if there are multiple skbs in the queue: keep dequeue'ing
+ *	  skb's upto a limit and set *skbp to NULL to tell the caller to use
+ *	  the new API.
+ *
+ * Returns:
+ *	1 - atleast one skb is to be sent out, *skbp contains skb or NULL
+ *	    (in case >1 skbs present in blist for batching)
+ *	0 - no skbs to be sent.
+ */
+static inline int get_skb(struct net_device *dev, struct Qdisc *q,
+			  struct sk_buff_head *blist,
+			  struct sk_buff **skbp)
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
@@ -130,27 +175,28 @@ static inline int handle_dev_cpu_collisi
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct net_device *dev)
+static inline int qdisc_restart(struct net_device *dev,
+				struct sk_buff_head *blist)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	unsigned lockless;
+	unsigned getlock;		/* whether we need to get lock or not */
 	int ret;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
+	if (unlikely(!get_skb(dev, q, blist, &skb)))
 		return 0;
 
 	/*
 	 * When the driver has LLTX set, it does its own locking in
-	 * start_xmit. These checks are worth it because even uncongested
+	 * start_xmit. These checks are worth it because even uncontested
 	 * locks can be quite expensive. The driver can do a trylock, as
 	 * is being done here; in case of lock contention it should return
 	 * NETDEV_TX_LOCKED and the packet will be requeued.
 	 */
-	lockless = (dev->features & NETIF_F_LLTX);
+	getlock = !(dev->features & NETIF_F_LLTX);
 
-	if (!lockless && !netif_tx_trylock(dev)) {
+	if (getlock && !netif_tx_trylock(dev)) {
 		/* Another CPU grabbed the driver tx lock */
 		return handle_dev_cpu_collision(skb, dev, q);
 	}
@@ -158,9 +204,12 @@ static inline int qdisc_restart(struct n
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	ret = dev_hard_start_xmit(skb, dev);
+	if (likely(skb))
+		ret = dev_hard_start_xmit(skb, dev);
+	else
+		ret = dev->hard_start_xmit_batch(dev);
 
-	if (!lockless)
+	if (getlock)
 		netif_tx_unlock(dev);
 
 	spin_lock(&dev->queue_lock);
@@ -168,7 +217,7 @@ static inline int qdisc_restart(struct n
 
 	switch (ret) {
 	case NETDEV_TX_OK:
-		/* Driver sent out skb successfully */
+		/* Driver sent out skb (or entire skb_blist) successfully */
 		ret = qdisc_qlen(q);
 		break;
 
@@ -179,10 +228,9 @@ static inline int qdisc_restart(struct n
 
 	default:
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
-		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
-			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
+		if (unlikely(ret != NETDEV_TX_BUSY) && net_ratelimit())
+			printk(KERN_WARNING " %s: BUG. code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
-
 		ret = dev_requeue_skb(skb, dev, q);
 		break;
 	}
@@ -190,10 +238,10 @@ static inline int qdisc_restart(struct n
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
 
