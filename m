From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Tue, 03 May 2005 01:01:19 +0200
Message-ID: <4276B13F.2040103@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070509060304040100030908"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070509060304040100030908
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Some network drivers call netif_stop_queue() when detecting loss of
carrier. This leads to packets being queued up at the qdisc level for
an unbound period of time. In order to prevent this effect, the core
networking stack will now seize to queue packets for any device, that
is operationally down (i.e. the queue is flushed and disabled).

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--------------070509060304040100030908
Content-Type: text/plain;
 name="carrier-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="carrier-4.patch"

diff -ru linux-2.6.12-rc3/net/core/dev.c linux-2.6.12-work/net/core/dev.c
--- linux-2.6.12-rc3/net/core/dev.c	2005-04-06 16:43:37.000000000 +0200
+++ linux-2.6.12-work/net/core/dev.c	2005-05-02 23:16:40.329156594 +0200
@@ -2203,14 +2203,10 @@
 	unsigned flags;
 
 	flags = (dev->flags & ~(IFF_PROMISC |
-				IFF_ALLMULTI |
-				IFF_RUNNING)) | 
+				IFF_ALLMULTI)) |
 		(dev->gflags & (IFF_PROMISC |
 				IFF_ALLMULTI));
 
-	if (netif_running(dev) && netif_carrier_ok(dev))
-		flags |= IFF_RUNNING;
-
 	return flags;
 }
 
diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-05-02 22:40:59.773471515 +0200
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/if.h>
 #include <net/sock.h>
+#include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -74,6 +75,12 @@
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
 		if (dev->flags & IFF_UP) {
+			if (netif_carrier_ok(dev)) {
+				WARN_ON(dev->qdisc_sleeping == &noop_qdisc);
+				dev_activate(dev);
+			} else
+				dev_deactivate(dev);
+
 			netdev_state_change(dev);
 		}
 
diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
--- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
+++ linux-2.6.12-work/net/sched/sch_generic.c	2005-05-02 23:07:49.367184929 +0200
@@ -514,6 +514,9 @@
 
 void dev_activate(struct net_device *dev)
 {
+	if (dev->flags & IFF_RUNNING)
+		return;
+
 	/* No queueing discipline is attached to device;
 	   create default one i.e. pfifo_fast for devices,
 	   which need queueing and noqueue_qdisc for
@@ -539,6 +542,11 @@
 		write_unlock_bh(&qdisc_tree_lock);
 	}
 
+	if (!netif_carrier_ok(dev))
+		/* Delay activation until next carrier-on event */
+		return;
+	dev->flags |= IFF_RUNNING;
+
 	spin_lock_bh(&dev->queue_lock);
 	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
 	if (dev->qdisc != &noqueue_qdisc) {
@@ -552,15 +560,18 @@
 {
 	struct Qdisc *qdisc;
 
-	spin_lock_bh(&dev->queue_lock);
-	qdisc = dev->qdisc;
-	dev->qdisc = &noop_qdisc;
+	if (dev->flags & IFF_RUNNING) {
+		spin_lock_bh(&dev->queue_lock);
+		qdisc = dev->qdisc;
+		dev->qdisc = &noop_qdisc;
 
-	qdisc_reset(qdisc);
+		qdisc_reset(qdisc);
 
-	spin_unlock_bh(&dev->queue_lock);
+		spin_unlock_bh(&dev->queue_lock);
 
-	dev_watchdog_down(dev);
+		dev_watchdog_down(dev);
+	}
+	dev->flags &= ~IFF_RUNNING;
 
 	while (test_bit(__LINK_STATE_SCHED, &dev->state))
 		yield();

--------------070509060304040100030908--
