From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 net-next 3/3] sunvnet: Schedule maybe_tx_wakeup() as a
 tasklet from ldc_rx path
Date: Wed, 13 Aug 2014 10:29:41 -0400
Message-ID: <20140813142941.GD16865@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37823 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaHMO3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:29:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At the tail of vnet_event(), if we hit the maybe_tx_wakeup()
condition, we try to take the netif_tx_lock() in the
recv-interrupt-context and can deadlock with dev_watchdog().
vnet_event() should schedule maybe_tx_wakeup() as a tasklet
to avoid this deadlock

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: incorporated comments from David Miller

 drivers/net/ethernet/sun/sunvnet.c | 12 ++++++++++--
 drivers/net/ethernet/sun/sunvnet.h |  4 ++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d813bfb..c0356de 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -475,8 +475,9 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-static void maybe_tx_wakeup(struct vnet *vp)
+static void maybe_tx_wakeup(unsigned long param)
 {
+	struct vnet *vp = (struct vnet *)param;
 	struct net_device *dev = vp->dev;
 
 	netif_tx_lock(dev);
@@ -573,8 +574,13 @@ static void vnet_event(void *arg, int event)
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
 
@@ -1046,6 +1052,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	vp = netdev_priv(dev);
 
 	spin_lock_init(&vp->lock);
+	tasklet_init(&vp->vnet_tx_wakeup, maybe_tx_wakeup, (unsigned long)vp);
 	vp->dev = dev;
 
 	INIT_LIST_HEAD(&vp->port_list);
@@ -1105,6 +1112,7 @@ static void vnet_cleanup(void)
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
