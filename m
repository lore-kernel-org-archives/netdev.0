From: Andi Kleen <ak@suse.de>
Subject: [PATCH] NETIF_F_LLTX for devices 2
Date: Tue, 7 Sep 2004 14:05:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907120532.GB25051@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


New version of the NETIF_F_LLTX for network devices patch. 

This allows network drivers to set the NETIF_F_LLTX flag
and then do their own locking in start_queue_xmit. 
This lowers locking overhead in this critical path. 

The drivers can use try lock if they want and return -1
when the lock wasn't grabbed. In this case the packet
will be requeued. For better compatibility this is only
done for drivers with LLTX set, others don't give a special
meaning to -1.

Most of the modern drivers who have a lock around hard_start_xmit
can just set this flag. It may be a good idea to convert the spin
lock there to a try lock. The only thing that should be audited
is that they do enough locking in the set_multicast_list function
too, and not also rely on xmit_lock here.

Now doesn't move any code around and does things with gotos instead.

The loop printk is also still there even for NETIF_F_LLTX

For drivers that don't set the new flag nothing changes.

Please consider applying.

-Andi


diff -u linux-2.6.8/net/core/pktgen.c-LLTX linux-2.6.8/net/core/pktgen.c
--- linux-2.6.8/net/core/pktgen.c-LLTX	2004-09-04 12:47:05.000000000 +0000
+++ linux-2.6.8/net/core/pktgen.c	2004-09-04 14:07:12.000000000 +0000
@@ -634,7 +634,8 @@
 
 		nr_frags = skb_shinfo(skb)->nr_frags;
 		   
-		spin_lock_bh(&odev->xmit_lock);
+		if (!(odev->features & NETIF_F_LLTX))
+			spin_lock_bh(&odev->xmit_lock);
 		if (!netif_queue_stopped(odev)) {
 
 			atomic_inc(&skb->users);
@@ -659,8 +660,8 @@
 			last_ok = 0;
 		}
 		
-
-		spin_unlock_bh(&odev->xmit_lock);
+		if (!(odev->features & NETIF_F_LLTX))
+			spin_unlock_bh(&odev->xmit_lock);
 
 		if (info->ipg) {
 			/* Try not to busy-spin if we have larger sleep times.
diff -u linux-2.6.8/net/sched/sch_generic.c-LLTX linux-2.6.8/net/sched/sch_generic.c
--- linux-2.6.8/net/sched/sch_generic.c-LLTX	2004-09-04 12:47:05.000000000 +0000
+++ linux-2.6.8/net/sched/sch_generic.c	2004-09-07 11:58:45.595363313 +0000
@@ -97,46 +97,73 @@
 
 	/* Dequeue packet */
 	if ((skb = q->dequeue(q)) != NULL) {
-		if (spin_trylock(&dev->xmit_lock)) {
+		unsigned nolock = (dev->features & NETIF_F_LLTX);
+		/*
+		 * When the driver has LLTX set it does its own locking
+		 * in start_xmit. No need to add additional overhead by
+		 * locking again. These checks are worth it because
+		 * even uncongested locks can be quite expensive.
+		 * The driver can do trylock like here too, in case
+		 * of lock congestion it should return -1 and the packet
+		 * will be requeued.
+		 */
+		if (!nolock) {
+			if (!spin_trylock(&dev->xmit_lock)) {
+			collision:
+				/* So, someone grabbed the driver. */
+				
+				/* It may be transient configuration error,
+				   when hard_start_xmit() recurses. We detect
+				   it by checking xmit owner and drop the
+				   packet when deadloop is detected.
+				*/
+				if (dev->xmit_lock_owner == smp_processor_id()) {
+					kfree_skb(skb);
+					if (net_ratelimit())
+						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
+					return -1;
+				}
+				__get_cpu_var(netdev_rx_stat).cpu_collision++;
+				goto requeue;
+			}
 			/* Remember that the driver is grabbed by us. */
 			dev->xmit_lock_owner = smp_processor_id();
-
+		}
+		
+		{
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
 			if (!netif_queue_stopped(dev)) {
+				int ret;
 				if (netdev_nit)
 					dev_queue_xmit_nit(skb, dev);
 
-				if (dev->hard_start_xmit(skb, dev) == 0) {
-					dev->xmit_lock_owner = -1;
-					spin_unlock(&dev->xmit_lock);
-
+				/* hard_start_xmit returns: 
+				   0  device not ready
+				   1  everything ok
+				   -1 didn't get device lock (for LLTX)
+				*/ 
+				ret = dev->hard_start_xmit(skb, dev);
+				if (ret == 0) { 
+					if (!nolock) {
+						dev->xmit_lock_owner = -1;
+						spin_unlock(&dev->xmit_lock);
+					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
+				if (ret == -1 && nolock)
+					goto collision; 
 			}
 
 			/* Release the driver */
-			dev->xmit_lock_owner = -1;
-			spin_unlock(&dev->xmit_lock);
+			if (!nolock) { 
+				dev->xmit_lock_owner = -1;
+				spin_unlock(&dev->xmit_lock);
+			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
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
-				return -1;
-			}
-			__get_cpu_var(netdev_rx_stat).cpu_collision++;
 		}
 
 		/* Device kicked us out :(
@@ -149,6 +176,7 @@
 		   3. device is buggy (ppp)
 		 */
 
+	requeue:
 		q->ops->requeue(skb, q);
 		netif_schedule(dev);
 		return 1;
