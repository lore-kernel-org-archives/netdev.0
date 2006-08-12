From: jamal <hadi@cyberus.ca>
Subject: [RFC][NET::SCHED]: cleanup qdisc_restart
Date: Sat, 12 Aug 2006 14:43:06 -0400
Message-ID: <1155408186.5091.46.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fTcqtc2KoKlP8kQBH1Lw"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:45764 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932467AbWHLSnM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 14:43:12 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GByS2-0001Ad-Jt
	for netdev@vger.kernel.org; Sat, 12 Aug 2006 14:43:14 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fTcqtc2KoKlP8kQBH1Lw
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Folks,

I am not a big readability officianado, but this piece of code has
become a victim of hairy activities over the last few years. So while i
was furiously chasing Herbert's qdisc_is_running changes[1] i made a
small cleanup just so that i could absorb what was going on.

The patch included is a small side effect of that effort (theres a lot
of WIP as well which is not part of this patch that may never see the
light of day).

Actually the patch itself may be slightly unreadable, so i have attached
how qdisc_restart looks after the patch.

I am not yet asking for inclusion, but if people are fine with it i will
run some performance tests to make sure we at least get the same numbers
as before and submit for 2.6.19. I have tested the code with a lot of
other stuff but not its the version i am attaching. It does compile
however ;->

Also if i am missing some piece of the translation please comment.
Alexey, I know you havent looked at this creation of yours in years and
a few changes have happened since, so please if you have time stare and
comment.

cheers,
jamal

[1] I wanted to check the qdisc is running change before 2.6.18 came
out. I have to say I have failed to find any issues with it. There are
some theoretical issues but i cant practically create them. Maybe we can
chat over a drink.

--=-fTcqtc2KoKlP8kQBH1Lw
Content-Disposition: attachment; filename=clean_qd-p1
Content-Type: text/x-patch; name=clean_qd-p1; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75f02d8..49278c8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -75,8 +75,11 @@ #define MAX_ADDR_LEN	32		/* Largest hard
 
 /* Driver transmit return codes */
 #define NETDEV_TX_OK 0		/* driver took care of packet */
-#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
-#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
+#define NETDEV_TX_BUSY -1	/* driver tx path was busy*/
+#define NETDEV_TX_LOCKED -2	/* driver tx lock was already taken */
+#define NETDEV_TX_DROP -3      /* request caller to drop packet */
+#define NETDEV_TX_QUEUE -4     /* request caller to requeue packet */
+
 
 /*
  *	Compute the worst case header length according to the protocols
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0834c2e..0e86927 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -67,7 +67,64 @@ void qdisc_unlock_tree(struct net_device
 	write_unlock_bh(&qdisc_tree_lock);
 }
 
+static inline int 
+handle_dev_cpu_collision(struct net_device *dev)
+{
+	if (dev->xmit_lock_owner == smp_processor_id()) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
+		return NETDEV_TX_DROP;
+	}
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return NETDEV_TX_QUEUE;
+}
+
+static inline int 
+handle_dev_requeue(struct sk_buff *skb, struct net_device *dev,
+		   struct Qdisc *q)
+{
+	if (skb->next)
+		dev->gso_skb = skb;
+	else
+		q->ops->requeue(skb, q);
+	netif_schedule(dev);
+	return 1;
+}
+
+static inline int 
+try_get_tx_pkt(struct sk_buff **skb, struct net_device *dev,
+		struct Qdisc *q)
+{
+	if (((*skb = dev->gso_skb)) || ((*skb = q->dequeue(q)))) {
+
+		dev->gso_skb = NULL;
+		return -1;
+	}
+
+	BUG_ON((int) q->q.qlen < 0);
+	return q->q.qlen;
+}
+
+static inline int 
+handle_tx_locked(struct sk_buff *skb, struct net_device *dev,
+		 struct Qdisc *q)
+{
+	int ret = handle_dev_cpu_collision(dev);
+
+	if (ret == NETDEV_TX_DROP) {
+		kfree_skb(skb);
+		return -1;
+	}
+
+	return handle_dev_requeue(skb,dev,q);
+}
+
 /* 
+   NOTE: Called under dev->queue_lock with locally disabled BH.
+
+   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
+   can enter this region at a time.
+
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
 
@@ -75,111 +132,63 @@ void qdisc_unlock_tree(struct net_device
 
    dev->queue_lock and netif_tx_lock are mutually exclusive,
    if one is grabbed, another must be free.
- */
 
+   Multiple CPUs may contend for the two locks.
 
-/* Kick device.
    Note, that this procedure can be called by a watchdog timer, so that
    we do not check dev->tbusy flag here.
 
-   Returns:  0  - queue is empty.
-            >0  - queue is not empty, but throttled.
-	    <0  - queue is not empty. Device is throttled, if dev->tbusy != 0.
-
-   NOTE: Called under dev->queue_lock with locally disabled BH.
+   Returns to the caller:  
+   	0  - queue is empty.
+       >0  - queue is not empty: tx lock access or queue throttle
+       <0  - Theres room to receive more if !netif_queue_stopped.
+             (It is upon the caller to check for netif_queue_stopped
+	      before invoking this routine)
 */
 
-static inline int qdisc_restart(struct net_device *dev)
+int 
+qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
-	struct sk_buff *skb;
-
-	/* Dequeue packet */
-	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
-		unsigned nolock = (dev->features & NETIF_F_LLTX);
-
-		dev->gso_skb = NULL;
-
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
-					return -1;
-				}
-				__get_cpu_var(netdev_rx_stat).cpu_collision++;
-				goto requeue;
-			}
-		}
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
+	struct sk_buff *skb = NULL;
+	int ret;
+
+	ret = try_get_tx_pkt(&skb, dev, q);
+	if (ret >= 0)
+		return ret;
+
+	/* we have a packet to send */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return handle_tx_locked(skb,dev,q);
+	}
 		
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
-					return -1;
-				}
-				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
-					goto collision; 
-				}
-			}
+	/* all clear .. */
+	spin_unlock(&dev->queue_lock);
 
-			/* NETDEV_TX_BUSY - we need to requeue */
-			/* Release the driver */
-			if (!nolock) { 
-				netif_tx_unlock(dev);
-			} 
-			spin_lock(&dev->queue_lock);
-			q = dev->qdisc;
-		}
+	/* churn baby churn .. */
+	ret = dev_hard_start_xmit(skb, dev);
 
-		/* Device kicked us out :(
-		   This is possible in three cases:
+	if (!lockless)  
+		netif_tx_unlock(dev);
 
-		   0. driver is locked
-		   1. fastroute is enabled
-		   2. device cannot determine busy state
-		      before start of transmission (f.e. dialout)
-		   3. device is buggy (ppp)
-		 */
+	spin_lock(&dev->queue_lock);
 
-requeue:
-		if (skb->next)
-			dev->gso_skb = skb;
-		else
-			q->ops->requeue(skb, q);
-		netif_schedule(dev);
-		return 1;
+	/* most likely result, packet went ok */
+	if (ret == NETDEV_TX_OK)
+		return -1;
+	/* only for lockless drivers .. */
+	if (ret == NETDEV_TX_LOCKED && lockless) {
+		return handle_tx_locked(skb,dev,q);
 	}
-	BUG_ON((int) q->q.qlen < 0);
-	return q->q.qlen;
+
+	if (unlikely (ret != NETDEV_TX_BUSY)) { 
+		/* XXX: Do we need a ratelimit? */
+		printk("BUG %s code %d qlen %d\n",dev->name,ret,q->q.qlen);
+	}
+
+	return handle_dev_requeue(skb,dev,q);
 }
 
 void __qdisc_run(struct net_device *dev)

--=-fTcqtc2KoKlP8kQBH1Lw
Content-Disposition: attachment; filename=qr-code
Content-Type: text/plain; name=qr-code; charset=UTF-8
Content-Transfer-Encoding: 7bit

/* 
   NOTE: Called under dev->queue_lock with locally disabled BH.

   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
   can enter this region at a time.

   dev->queue_lock serializes queue accesses for this device
   AND dev->qdisc pointer itself.

   netif_tx_lock serializes accesses to device driver.

   dev->queue_lock and netif_tx_lock are mutually exclusive,
   if one is grabbed, another must be free.

   Multiple CPUs may contend for the two locks.

   Note, that this procedure can be called by a watchdog timer, so that
   we do not check dev->tbusy flag here.

   Returns to the caller:  
   	0  - queue is empty.
       >0  - queue is not empty: tx lock access or queue throttle
       <0  - Theres room to receive more if !netif_queue_stopped.
             (It is upon the caller to check for netif_queue_stopped
	      before invoking this routine)
*/

int 
qdisc_restart(struct net_device *dev)
{
	struct Qdisc *q = dev->qdisc;
	unsigned lockless = (dev->features & NETIF_F_LLTX);
	struct sk_buff *skb = NULL;
	int ret;

	ret = try_get_tx_pkt(&skb, dev, q);
	if (ret >= 0)
		return ret;

	/* we have a packet to send */
	if (!lockless) {
		if (!netif_tx_trylock(dev))
			return handle_tx_locked(skb,dev,q);
	}
		
	/* all clear .. */
	spin_unlock(&dev->queue_lock);

	/* churn baby churn .. */
	ret = dev_hard_start_xmit(skb, dev);

	if (!lockless)  
		netif_tx_unlock(dev);

	spin_lock(&dev->queue_lock);

	/* most likely result, packet went ok */
	if (ret == NETDEV_TX_OK)
		return -1;
	/* only for lockless drivers .. */
	if (ret == NETDEV_TX_LOCKED && lockless) {
		return handle_tx_locked(skb,dev,q);
	}

	if (unlikely (ret != NETDEV_TX_BUSY)) { 
		/* XXX: Do we need a ratelimit? */
		printk("BUG %s code %d qlen %d\n",dev->name,ret,q->q.qlen);
	}

	return handle_dev_requeue(skb,dev,q);
}

--=-fTcqtc2KoKlP8kQBH1Lw--

