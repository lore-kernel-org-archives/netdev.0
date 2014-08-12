From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a tasklet
 from ldc_rx path
Date: Tue, 12 Aug 2014 10:35:31 -0400
Message-ID: <20140812143531.GJ2404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26914 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbaHLOfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 10:35:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch must be applied after
"[PATCH net-next 2/3] sunvnet: Do not spin in an infinite loop when vio_ldc_send() returns EAGAIN"

At the tail of vnet_event(), if we hit the maybe_tx_wakeup()
condition, we try to take the netif_tx_lock() in the
recv-interrupt-context and can deadlock with dev_watchdog().
Two changes to fix this:

- The contents of maybe_tx_wakeup() should be moved into
  vnet_tx_timeout
- vnet_event() should kick off a tasklet that triggers
  netif_wake_queue()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

---
 drivers/net/ethernet/sun/sunvnet.c | 52 +++++++++++++++++++++++---------------
 drivers/net/ethernet/sun/sunvnet.h |  4 +++
 2 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 39c39bf..c75a638 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -32,6 +32,8 @@ MODULE_DESCRIPTION("Sun LDOM virtual network driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+static void vnet_tx_timeout(struct net_device *dev);
+
 /* Heuristic for the number of times to exponentially backoff and
  * retry sending an LDC trigger when EAGAIN is encountered
  */
@@ -489,28 +491,13 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-static void maybe_tx_wakeup(struct vnet *vp)
+static void maybe_tx_wakeup(unsigned long param)
 {
+	struct vnet *vp = (struct vnet *)param;
 	struct net_device *dev = vp->dev;
 
 	netif_tx_lock(dev);
-	if (likely(netif_queue_stopped(dev))) {
-		struct vnet_port *port;
-		int wake = 1;
-
-		list_for_each_entry(port, &vp->port_list, list) {
-			struct vio_dring_state *dr;
-
-			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
-			if (vnet_tx_dring_avail(dr) <
-			    VNET_TX_WAKEUP_THRESH(dr)) {
-				wake = 0;
-				break;
-			}
-		}
-		if (wake)
-			netif_wake_queue(dev);
-	}
+	vnet_tx_timeout(dev);
 	netif_tx_unlock(dev);
 }
 
@@ -587,8 +574,13 @@ static void vnet_event(void *arg, int event)
 			break;
 	}
 	spin_unlock(&vio->lock);
+	/* Kick off a tasklet to wake the queue.  We cannot call
+	 * maybe_tx_wakeup directly here because we could deadlock on
+	 * netif_tx_lock() with dev_watchdog()
+	 */
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
-		maybe_tx_wakeup(port->vp);
+		tasklet_schedule(&port->vp->vnet_tx_wakeup);
+
 	local_irq_restore(flags);
 }
 
@@ -764,7 +756,25 @@ out_dropped:
 
 static void vnet_tx_timeout(struct net_device *dev)
 {
-	/* XXX Implement me XXX */
+	struct vnet *vp = netdev_priv(dev);
+
+	if (likely(netif_queue_stopped(dev))) {
+		struct vnet_port *port;
+		int wake = 1;
+
+		list_for_each_entry(port, &vp->port_list, list) {
+			struct vio_dring_state *dr;
+
+			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+			if (vnet_tx_dring_avail(dr) <
+			    VNET_TX_WAKEUP_THRESH(dr)) {
+				wake = 0;
+				break;
+			}
+		}
+		if (wake)
+			netif_wake_queue(dev);
+	}
 }
 
 static int vnet_open(struct net_device *dev)
@@ -1071,6 +1081,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	vp = netdev_priv(dev);
 
 	spin_lock_init(&vp->lock);
+	tasklet_init(&vp->vnet_tx_wakeup, maybe_tx_wakeup, (unsigned long)vp);
 	vp->dev = dev;
 
 	INIT_LIST_HEAD(&vp->port_list);
@@ -1130,6 +1141,7 @@ static void vnet_cleanup(void)
 		vp = list_first_entry(&vnet_list, struct vnet, list);
 		list_del(&vp->list);
 		dev = vp->dev;
+		tasklet_kill(&vp->vnet_tx_wakeup);
 		/* vio_unregister_driver() should have cleaned up port_list */
 		BUG_ON(!list_empty(&vp->port_list));
 		unregister_netdev(dev);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index d347a5b..0e872aa 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -1,6 +1,8 @@
 #ifndef _SUNVNET_H
 #define _SUNVNET_H
 
+#include <linux/interrupt.h>
+
 #define DESC_NCOOKIES(entry_size)	\
 	((entry_size) - sizeof(struct vio_net_desc))
 
@@ -78,6 +80,8 @@ struct vnet {
 
 	struct list_head	list;
 	u64			local_mac;
+
+	struct tasklet_struct	vnet_tx_wakeup;
 };
 
 #endif /* _SUNVNET_H */
-- 
1.8.4.2
