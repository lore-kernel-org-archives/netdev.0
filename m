From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Extend lock less TX to real devices
Date: Tue, 31 Aug 2004 14:38:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m38ybvjxdv.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        akepner@sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch extends the recently added NETIF_F_LLTX to real devices.
A lot of modern network drivers have a single big lock around their 
hard_start_xmit, and it doesn't make sense to take the xmit lock too.
They also have enough locking to handle setting of multicast lists
properly.

Now they can set NETIF_F_LLTX and get one lock less.  For drivers
that don't set this flag nothing changes.

I added support for trylocking instead of spinning like sch_generic
does - for that the driver has to return -1, then the packet is requeued.
The check for a local device deadlock is lost for this case, 
but that doesn't seem to be a big loss (I've never seen this printk 
ever get triggered)

The patch looks bigger than it really is because i moved some code
around and converted the macros into inlines. 

I also did an additional micro optimization: on a preemptive kernel
dev_queue_xmit would change the local atomic count several times
in the hot path. This patch changes it to disable preemption only once,
to hopefully make it a bit faster.

I changed the lltx handling to not change xmit_lock_owner.
Without a lock it is not safe anyways and it will prevent
another cache line from bouncing.

With only this patch nothing changes because no driver uses
the new flag yet.

-Andi

diff -u linux-2.6.8-work/net/core/dev.c-o linux-2.6.8-work/net/core/dev.c
--- linux-2.6.8-work/net/core/dev.c-o	2004-08-05 04:31:12.000000000 +0200
+++ linux-2.6.8-work/net/core/dev.c	2004-08-31 13:25:35.000000000 +0200
@@ -1255,19 +1255,24 @@
 	return 0;
 }
 
-#define HARD_TX_LOCK_BH(dev, cpu) {			\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		spin_lock_bh(&dev->xmit_lock);		\
-		dev->xmit_lock_owner = cpu;		\
-	}						\
-}
+/* Preemption must be off here. A driver setting LLTX has to 
+   use interrupt safe locking. */
 
-#define HARD_TX_UNLOCK_BH(dev) {			\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		dev->xmit_lock_owner = -1;		\
-		spin_unlock_bh(&dev->xmit_lock);	\
-	}						\
-}
+static inline int hard_tx_lock(struct net_device *dev) 
+{ 
+	if (dev->features & NETIF_F_LLTX)
+		return 1; 
+	spin_lock(&dev->xmit_lock);
+	dev->xmit_lock_owner = smp_processor_id(); 
+} 
+
+static inline void hard_tx_unlock(struct net_device *dev) 
+{ 
+	if (dev->features & NETIF_F_LLTX) 
+		return; 
+	dev->xmit_lock_owner = -1;
+	spin_unlock(&dev->xmit_lock);	
+} 
 
 static inline void qdisc_run(struct net_device *dev)
 {
@@ -1319,7 +1324,15 @@
 	      	if (skb_checksum_help(&skb, 0))
 	      		goto out_kfree_skb;
 
-	rcu_read_lock();
+	/* 
+	 * Various locks need a _bh disable and there are CPU local
+	 * data structures too. Instead of changing the preempt count
+	 * with each lock just grab it here once for the whole
+	 * function. This also gives the require atomicity for the RCU
+	 * use below.
+	 */ 
+	local_bh_disable();
+
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
 	 * rcu structure - it may be accessed without acquiring 
@@ -1339,18 +1352,17 @@
 #endif
 	if (q->enqueue) {
 		/* Grab device queue */
-		spin_lock_bh(&dev->queue_lock);
+		spin_lock(&dev->queue_lock);
 
 		rc = q->enqueue(skb, q);
 
 		qdisc_run(dev);
 
-		spin_unlock_bh(&dev->queue_lock);
-		rcu_read_unlock();
+		spin_unlock(&dev->queue_lock);
 		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
 		goto out;
 	}
-	rcu_read_unlock();
+
 
 	/* The device has no queue. Common case for software devices:
 	   loopback, all the sorts of tunnels...
@@ -1363,32 +1375,27 @@
 
 	   Check this and shot the lock. It is not prone from deadlocks.
 	   Either shot noqueue qdisc, it is even simpler 8)
+
+	   BHs are still disabled here
 	 */
 	if (dev->flags & IFF_UP) {
-		int cpu = get_cpu();
-
-		if (dev->xmit_lock_owner != cpu) {
-
-			HARD_TX_LOCK_BH(dev, cpu);
-			put_cpu();
-
+		if (hard_tx_lock(dev)) { 
 			if (!netif_queue_stopped(dev)) {
 				if (netdev_nit)
 					dev_queue_xmit_nit(skb, dev);
 
 				rc = 0;
 				if (!dev->hard_start_xmit(skb, dev)) {
-					HARD_TX_UNLOCK_BH(dev);
+					hard_tx_unlock(dev);
 					goto out;
 				}
 			}
-			HARD_TX_UNLOCK_BH(dev);
+			hard_tx_unlock(dev);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
 			goto out_enetdown;
 		} else {
-			put_cpu();
 			/* Recursion is detected! It is possible,
 			 * unfortunately */
 			if (net_ratelimit())
@@ -1401,6 +1408,7 @@
 out_kfree_skb:
 	kfree_skb(skb);
 out:
+	local_bh_enable();
 	return rc;
 }
 
diff -u linux-2.6.8-work/net/core/pktgen.c-o linux-2.6.8-work/net/core/pktgen.c
--- linux-2.6.8-work/net/core/pktgen.c-o	2004-08-05 04:31:12.000000000 +0200
+++ linux-2.6.8-work/net/core/pktgen.c	2004-08-15 17:51:22.000000000 +0200
@@ -629,8 +629,9 @@
 		}
 
 		nr_frags = skb_shinfo(skb)->nr_frags;
-		   
-		spin_lock_bh(&odev->xmit_lock);
+
+		if (!(odev->features & NETIF_F_LLTX))
+			spin_lock_bh(&odev->xmit_lock);
 		if (!netif_queue_stopped(odev)) {
 
 			atomic_inc(&skb->users);
@@ -655,8 +656,8 @@
 			last_ok = 0;
 		}
 		
-
-		spin_unlock_bh(&odev->xmit_lock);
+		if (!(odev->features & NETIF_F_LLTX))
+			spin_unlock_bh(&odev->xmit_lock);
 
 		if (info->ipg) {
 			/* Try not to busy-spin if we have larger sleep times.
diff -u linux-2.6.8-work/net/sched/sch_generic.c-o linux-2.6.8-work/net/sched/sch_generic.c
--- linux-2.6.8-work/net/sched/sch_generic.c-o	2004-08-13 03:44:03.000000000 +0200
+++ linux-2.6.8-work/net/sched/sch_generic.c	2004-08-31 13:13:36.000000000 +0200
@@ -68,6 +68,34 @@
 	write_unlock_bh(&qdisc_tree_lock);
 }
 
+static int qdisc_coll(struct net_device *dev, struct sk_buff *skb)
+{
+	/* So, someone grabbed the driver. */
+	
+	/* It may be transient configuration error,
+	   when hard_start_xmit() recurses. We detect
+	   it by checking xmit owner and drop the
+	   packet when deadloop is detected.
+	*/
+	if (dev->xmit_lock_owner == smp_processor_id()) {
+		kfree_skb(skb);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
+		return -1;
+	}
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return 0;
+}
+
+static inline void qdisc_unlock_driver(struct net_device *dev)
+{
+	if (!(dev->features & NETIF_F_LLTX)) { 
+		dev->xmit_lock_owner = -1;
+		spin_unlock(&dev->xmit_lock);
+	}
+	spin_lock(&dev->queue_lock);
+}
+
 /* 
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
@@ -97,50 +125,49 @@
 
 	/* Dequeue packet */
 	if ((skb = q->dequeue(q)) != NULL) {
-		if (spin_trylock(&dev->xmit_lock)) {
+		/* 
+		 * When the driver has LLTX set it does its own locking 
+		 * in start_xmit. No need to add additional overhead by
+		 * locking again. These checks are worth it because
+		 * even uncongested locks can be quite expensive.
+		 */
+		if ((dev->features & NETIF_F_LLTX) == 0) { 
+			if (!spin_trylock(&dev->xmit_lock)) {
+				if (qdisc_coll(dev, skb) < 0) 
+					return -1;
+				goto out; 
+				
+			}
 			/* Remember that the driver is grabbed by us. */
 			dev->xmit_lock_owner = smp_processor_id();
-
-			/* And release queue */
-			spin_unlock(&dev->queue_lock);
-
-			if (!netif_queue_stopped(dev)) {
-				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
-
-				if (dev->hard_start_xmit(skb, dev) == 0) {
-					dev->xmit_lock_owner = -1;
-					spin_unlock(&dev->xmit_lock);
-
-					spin_lock(&dev->queue_lock);
-					return -1;
+		}
+		
+		/* And release queue */
+		spin_unlock(&dev->queue_lock);
+		
+		if (!netif_queue_stopped(dev)) {
+			int ret;
+
+			if (netdev_nit)
+				dev_queue_xmit_nit(skb, dev);
+			
+			ret = dev->hard_start_xmit(skb, dev);
+			if (ret <= 0) { 
+				qdisc_unlock_driver(dev);
+				/* requeue in case of lock collision */
+				if (ret < 0) {
+					__get_cpu_var(netdev_rx_stat).cpu_collision++;
+					goto out; 
 				}
-			}
-
-			/* Release the driver */
-			dev->xmit_lock_owner = -1;
-			spin_unlock(&dev->xmit_lock);
-			spin_lock(&dev->queue_lock);
-			q = dev->qdisc;
-		} else {
-			/* So, someone grabbed the driver. */
-
-			/* It may be transient configuration error,
-			   when hard_start_xmit() recurses. We detect
-			   it by checking xmit owner and drop the
-			   packet when deadloop is detected.
-			 */
-			if (dev->xmit_lock_owner == smp_processor_id()) {
-				kfree_skb(skb);
-				if (net_ratelimit())
-					printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
 				return -1;
 			}
-			__get_cpu_var(netdev_rx_stat).cpu_collision++;
 		}
 
+		qdisc_unlock_driver(dev);
+		q = dev->qdisc;
+
 		/* Device kicked us out :(
-		   This is possible in three cases:
+		   This is possible in four cases:
 
 		   0. driver is locked
 		   1. fastroute is enabled
@@ -149,6 +176,7 @@
 		   3. device is buggy (ppp)
 		 */
 
+	out:
 		q->ops->requeue(skb, q);
 		netif_schedule(dev);
 		return 1;
