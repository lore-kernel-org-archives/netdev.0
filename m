From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Do less atomic count changes in dev_queue_xmit
Date: Sat, 4 Sep 2004 15:54:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040904135439.GA23934@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Do a single local_bh_disable and a single local_bh_enable instead of changing
the atomic count all the time in dev_queue_xmit.

Should mostly benefit preemptible kernels, but others see some
small improvements too.


diff -u linux-2.6.8/net/core/dev.c-o linux-2.6.8/net/core/dev.c
--- linux-2.6.8/net/core/dev.c-o	2004-09-04 13:10:47.000000000 +0000
+++ linux-2.6.8/net/core/dev.c	2004-09-04 13:47:16.765722813 +0000
@@ -1249,14 +1249,14 @@
 	return 0;
 }
 
-#define HARD_TX_LOCK_BH(dev, cpu) {			\
+#define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		spin_lock_bh(&dev->xmit_lock);		\
 		dev->xmit_lock_owner = cpu;		\
 	}						\
 }
 
-#define HARD_TX_UNLOCK_BH(dev) {			\
+#define HARD_TX_UNLOCK(dev) {				\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		dev->xmit_lock_owner = -1;		\
 		spin_unlock_bh(&dev->xmit_lock);	\
@@ -1313,7 +1313,12 @@
 	      	if (skb_checksum_help(&skb, 0))
 	      		goto out_kfree_skb;
 
-	rcu_read_lock();
+
+	/* Disable soft irqs for various locks below. Also 
+	 * stops preemption for RCU. 
+	 */
+	local_bh_disable(); 
+
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
 	 * rcu structure - it may be accessed without acquiring 
@@ -1332,18 +1337,16 @@
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
 
 	/* The device has no queue. Common case for software devices:
 	   loopback, all the sorts of tunnels...
@@ -1358,12 +1361,11 @@
 	   Either shot noqueue qdisc, it is even simpler 8)
 	 */
 	if (dev->flags & IFF_UP) {
-		int cpu = get_cpu();
+		int cpu = smp_processor_id(); /* ok because BHs are off */
 
 		if (dev->xmit_lock_owner != cpu) {
 
-			HARD_TX_LOCK_BH(dev, cpu);
-			put_cpu();
+			HARD_TX_LOCK(dev, cpu);
 
 			if (!netif_queue_stopped(dev)) {
 				if (netdev_nit)
@@ -1371,17 +1373,16 @@
 
 				rc = 0;
 				if (!dev->hard_start_xmit(skb, dev)) {
-					HARD_TX_UNLOCK_BH(dev);
+					HARD_TX_UNLOCK(dev);
 					goto out;
 				}
 			}
-			HARD_TX_UNLOCK_BH(dev);
+			HARD_TX_UNLOCK(dev);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
 			goto out_enetdown;
 		} else {
-			put_cpu();
 			/* Recursion is detected! It is possible,
 			 * unfortunately */
 			if (net_ratelimit())
@@ -1394,6 +1395,7 @@
 out_kfree_skb:
 	kfree_skb(skb);
 out:
+	local_bh_enable();
 	return rc;
 }
 
