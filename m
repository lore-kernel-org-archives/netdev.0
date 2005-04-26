From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: [PATCH] net: Disable queueing when carrier is lost
Date: Tue, 26 Apr 2005 23:53:16 +0200
Message-ID: <426EB84C.90307@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060208070608070201020509"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060208070608070201020509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

A while back we had a very long thread about the queueing behavior of
netdevices in a loss-of-carrier situation. This thread had the poetic
subject: [patch 4/10] s390: network driver.

The executive summary:

Certain network drivers call netif_stop_queue() when they detect a loss
of carrier. This has some unfortunate effects on the current networking
stack, since packets are now being queued up at the qdisc level for an
unbound period of time:
  *) the socket send buffer may be exhausted, preventing transmission
     to all devices (from this particular socket)
  *) resources are held "indefinitely": memory, socket/dst/module refcounts
  *) when carrier is re-established stale packets are sent out on the
     network, which could have undesirable effects

The best solution seems to be to simply disable the queueing at the qdisc
layer when this situation arises. That approach has been implemented in
the patch below. Hasso Tepper <hasso@estpak.ee> reports succesfull testing
of the patch with Quagga.

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>

--------------060208070608070201020509
Content-Type: text/plain;
 name="carrier.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="carrier.patch"

diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-04-26 22:19:22.939393488 +0200
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/if.h>
 #include <net/sock.h>
+#include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -74,6 +75,9 @@
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
 		if (dev->flags & IFF_UP) {
+			if (netif_carrier_ok(dev) &&
+			    dev->qdisc_sleeping != &noop_qdisc)
+				dev_activate(dev);
 			netdev_state_change(dev);
 		}
 
diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
--- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
+++ linux-2.6.12-work/net/sched/sch_generic.c	2005-04-26 22:19:22.939393488 +0200
@@ -185,6 +185,7 @@
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
+	int check_carrier = 0;
 
 	spin_lock(&dev->xmit_lock);
 	if (dev->qdisc != &noop_qdisc) {
@@ -198,10 +199,23 @@
 			}
 			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
 				dev_hold(dev);
-		}
+		} else
+			check_carrier = 1;
 	}
 	spin_unlock(&dev->xmit_lock);
 
+	if (check_carrier) {
+		spin_lock(&dev->queue_lock);
+		if (!netif_carrier_ok(dev) && netif_queue_stopped(dev)) {
+			struct Qdisc *qdisc;
+
+			qdisc = dev->qdisc;
+			dev->qdisc = &noop_qdisc;
+			qdisc_reset(qdisc);
+		}
+		spin_unlock(&dev->queue_lock);
+	}
+
 	dev_put(dev);
 }
 

--------------060208070608070201020509--
