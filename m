From: jamal <hadi@cyberus.ca>
Subject: take 2 WAS (RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 15:29:33 -0400
Message-ID: <1178911773.4126.26.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LuI3b9+MuogbsgZndIpJ"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:24182 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617AbXEKT3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 15:29:36 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1157045wra
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 12:29:35 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LuI3b9+MuogbsgZndIpJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2007-11-05 at 11:46 -0700, Waskiewicz Jr, Peter P wrote:

> Clippers are standing by.  :)

Nothing as nice as time off to code away;->

Ok, booting fine to me; 
if you receive this email, it must have worked. OTOH, if you didnt
receive this it probably failed ;->
(as the presenter said "if you cant hear me in the far corner please
raise your hand").

clip away ...

cheers,
jamal



--=-LuI3b9+MuogbsgZndIpJ
Content-Disposition: attachment; filename=rfc-qrestart-take2
Content-Type: text/x-patch; name=rfc-qrestart-take2; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f671cd2..718d6fd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -83,6 +83,9 @@ struct wireless_dev;
 #define NETDEV_TX_OK 0		/* driver took care of packet */
 #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
 #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
+#define NETDEV_TX_DROP -2	/* request caller to drop packet */
+#define NETDEV_TX_QUEUE -3	/* request caller to requeue packet */
+
 
 /*
  *	Compute the worst case header length according to the protocols
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f28bb2d..9898523 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -59,7 +59,79 @@ void qdisc_unlock_tree(struct net_device *dev)
 	spin_unlock_bh(&dev->queue_lock);
 }
 
-/*
+static inline int qdisc_qlen(struct Qdisc *q)
+{
+	BUG_ON((int) q->q.qlen < 0);
+	return q->q.qlen;
+}
+
+static inline int handle_dev_cpu_collision(struct net_device *dev)
+{
+	if (dev->xmit_lock_owner == smp_processor_id()) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG
+			       "Dead loop on netdevice %s, fix it urgently!\n",
+			       dev->name);
+		return NETDEV_TX_DROP;
+	}
+	/* XXX: This maintains original code, but i think we should
+	 * update cpu_collision always
+	*/
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return NETDEV_TX_QUEUE;
+}
+
+static inline int
+handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+{
+
+	if (unlikely(q == &noop_qdisc))
+		kfree_skb(skb);
+	else if (skb->next)
+		dev->gso_skb = skb;
+	else
+		q->ops->requeue(skb, q);
+	/* XXX: Could netif_schedule fail? Or is that fact we are
+	 * requeueing imply the hardware path is closed
+	 * and even if we fail, some interupt will wake us
+	*/
+	netif_schedule(dev);
+	return 0;
+}
+
+static struct sk_buff *
+try_get_tx_pkt(struct net_device *dev, struct Qdisc *q)
+{
+	struct sk_buff *skb = NULL;
+
+	if (skb = dev->gso_skb) 
+		dev->gso_skb = NULL;
+	else 
+		skb = q->dequeue(q);
+
+	return skb;
+}
+
+static inline int
+handle_tx_locked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+{
+	int ret = handle_dev_cpu_collision(dev);
+
+	if (ret == NETDEV_TX_DROP) {
+		kfree_skb(skb);
+		return qdisc_qlen(q);
+	}
+
+	return handle_dev_requeue(skb, dev, q);
+}
+
+
+/* 
+   NOTE: Called under dev->queue_lock with locally disabled BH.
+
+   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
+   can enter this region at a time.
+
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
 
@@ -67,114 +139,68 @@ void qdisc_unlock_tree(struct net_device *dev)
 
    dev->queue_lock and netif_tx_lock are mutually exclusive,
    if one is grabbed, another must be free.
- */
 
+   Multiple CPUs may contend for the two locks.
 
-/* Kick device.
+   Note, that this procedure can be called by a watchdog timer, so that
+   we do not check dev->tbusy flag here.
 
+   Returns to the caller:  
    Returns:  0  - queue is empty or throttled.
 	    >0  - queue is not empty.
-
-   NOTE: Called under dev->queue_lock with locally disabled BH.
 */
 
-static inline int qdisc_restart(struct net_device *dev)
+int 
+qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
 	struct sk_buff *skb;
+	int ret;
 
-	/* Dequeue packet */
-	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
-		unsigned nolock = (dev->features & NETIF_F_LLTX);
-
-		dev->gso_skb = NULL;
+	skb = try_get_tx_pkt(dev, q);
+	if (skb == NULL)
+		return qdisc_qlen(q);
 
-		/*
-		 * When the driver has LLTX set it does its own locking
-		 * in start_xmit. No need to add additional overhead by
-		 * locking again. These checks are worth it because
-		 * even uncongested locks can be quite expensive.
-		 * The driver can do trylock like here too, in case
-		 * of lock congestion it should return -1 and the packet
-		 * will be requeued.
-		 */
-		if (!nolock) {
-			if (!netif_tx_trylock(dev)) {
-			collision:
-				/* So, someone grabbed the driver. */
-
-				/* It may be transient configuration error,
-				   when hard_start_xmit() recurses. We detect
-				   it by checking xmit owner and drop the
-				   packet when deadloop is detected.
-				*/
-				if (dev->xmit_lock_owner == smp_processor_id()) {
-					kfree_skb(skb);
-					if (net_ratelimit())
-						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
-					goto out;
-				}
-				__get_cpu_var(netdev_rx_stat).cpu_collision++;
-				goto requeue;
-			}
-		}
-
-		{
-			/* And release queue */
-			spin_unlock(&dev->queue_lock);
-
-			if (!netif_queue_stopped(dev)) {
-				int ret;
-
-				ret = dev_hard_start_xmit(skb, dev);
-				if (ret == NETDEV_TX_OK) {
-					if (!nolock) {
-						netif_tx_unlock(dev);
-					}
-					spin_lock(&dev->queue_lock);
-					q = dev->qdisc;
-					goto out;
-				}
-				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
-					q = dev->qdisc;
-					goto collision;
-				}
-			}
-
-			/* NETDEV_TX_BUSY - we need to requeue */
-			/* Release the driver */
-			if (!nolock) {
-				netif_tx_unlock(dev);
-			}
-			spin_lock(&dev->queue_lock);
-			q = dev->qdisc;
-		}
-
-		/* Device kicked us out :(
-		   This is possible in three cases:
-
-		   0. driver is locked
-		   1. fastroute is enabled
-		   2. device cannot determine busy state
-		      before start of transmission (f.e. dialout)
-		   3. device is buggy (ppp)
-		 */
-
-requeue:
-		if (unlikely(q == &noop_qdisc))
-			kfree_skb(skb);
-		else if (skb->next)
-			dev->gso_skb = skb;
-		else
-			q->ops->requeue(skb, q);
-		netif_schedule(dev);
-		return 0;
+	/* we have a packet to send */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return handle_tx_locked(skb, dev, q);
+	}
+		
+	/* all clear .. */
+	spin_unlock(&dev->queue_lock);
+
+	ret = NETDEV_TX_BUSY;
+	if (!netif_queue_stopped(dev))
+		/* churn baby churn .. */
+		ret = dev_hard_start_xmit(skb, dev);
+
+	if (!lockless)  
+		netif_tx_unlock(dev);
+
+	spin_lock(&dev->queue_lock);
+
+	/* we need to refresh q because it may be invalid since we droped 
+	 * dev->queue_lock earlier ...
+	 * So dont try to be clever grasshopper
+	*/
+	q = dev->qdisc;
+	/* most likely result, packet went ok */
+	if (ret == NETDEV_TX_OK)
+		return qdisc_qlen(q);
+	/* only for lockless drivers .. */
+	if (ret == NETDEV_TX_LOCKED && lockless) 
+		return handle_tx_locked(skb, dev, q);
+
+	if (unlikely (ret != NETDEV_TX_BUSY)) { 
+		/* XXX: Do we need a ratelimit? or put a 
+		 * BUG_ON((int) ret != NETDEV_TX_BUSY) ?
+		 **/
+		printk("BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
 	}
 
-out:
-	BUG_ON((int) q->q.qlen < 0);
-	return q->q.qlen;
+	return handle_dev_requeue(skb, dev, q);
 }
 
 void __qdisc_run(struct net_device *dev)

--=-LuI3b9+MuogbsgZndIpJ--

