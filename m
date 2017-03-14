From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 1/5] ldmvsw: better use of link up and down on ldom vswitch
Date: Tue, 14 Mar 2017 10:24:39 -0700
Message-ID: <1489512283-422140-2-git-send-email-shannon.nelson@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When an ldom VM is bound, the network vswitch infrastructure is set up for
it, but was being forced 'UP' by the userland switch configuration script.
When 'UP' but not actually connected to a running VM, the ipv6 neighbor
probes fail (not a horrible thing) and start cluttering up the kernel logs.
Funny thing: these are debug messages that never actually show up, but
we do see the net_ratelimited messages that say N callbacks were
suppressed.

This patch defers the netif_carrier_on() until an actual link has been
established with the VM, as indicated by receiving an LDC_EVENT_UP from
the underlying LDC protocol.  Similarly, we take the link down when we
see the LDC_EVENT_RESET.  Now when we see the ndo_open(), we reset the
link to get things talking again.

Orabug: 25525312

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |   27 +++++++++++++++++++++++----
 drivers/net/ethernet/sun/sunvnet_common.c |   20 +++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet_common.h |    1 +
 3 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 89952de..121927b 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -1,6 +1,6 @@
 /* ldmvsw.c: Sun4v LDOM Virtual Switch Driver.
  *
- * Copyright (C) 2016 Oracle. All rights reserved.
+ * Copyright (C) 2016-2017 Oracle. All rights reserved.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -41,8 +41,8 @@
 static u8 vsw_port_hwaddr[ETH_ALEN] = {0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
 
 #define DRV_MODULE_NAME		"ldmvsw"
-#define DRV_MODULE_VERSION	"1.1"
-#define DRV_MODULE_RELDATE	"February 3, 2017"
+#define DRV_MODULE_VERSION	"1.2"
+#define DRV_MODULE_RELDATE	"March 4, 2017"
 
 static char version[] =
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
@@ -123,6 +123,20 @@ static void vsw_set_rx_mode(struct net_device *dev)
 	return sunvnet_set_rx_mode_common(dev, port->vp);
 }
 
+int ldmvsw_open(struct net_device *dev)
+{
+	struct vnet_port *port = netdev_priv(dev);
+	struct vio_driver_state *vio = &port->vio;
+
+	/* reset the channel */
+	vio_link_state_change(vio, LDC_EVENT_RESET);
+	vnet_port_reset(port);
+	vio_port_up(vio);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ldmvsw_open);
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void vsw_poll_controller(struct net_device *dev)
 {
@@ -133,7 +147,7 @@ static void vsw_poll_controller(struct net_device *dev)
 #endif
 
 static const struct net_device_ops vsw_ops = {
-	.ndo_open		= sunvnet_open_common,
+	.ndo_open		= ldmvsw_open,
 	.ndo_stop		= sunvnet_close_common,
 	.ndo_set_rx_mode	= vsw_set_rx_mode,
 	.ndo_set_mac_address	= sunvnet_set_mac_addr_common,
@@ -365,6 +379,11 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	napi_enable(&port->napi);
 	vio_port_up(&port->vio);
 
+	/* assure no carrier until we receive an LDC_EVENT_UP,
+	 * even if the vsw config script tries to force us up
+	 */
+	netif_carrier_off(dev);
+
 	netdev_info(dev, "LDOM vsw-port %pM\n", dev->dev_addr);
 
 	pr_info("%s: PORT ( remote-mac %pM%s )\n", dev->name,
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index fa2d11c..1a65892 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1,7 +1,7 @@
 /* sunvnet.c: Sun LDOM Virtual Network Driver.
  *
  * Copyright (C) 2007, 2008 David S. Miller <davem@davemloft.net>
- * Copyright (C) 2016 Oracle. All rights reserved.
+ * Copyright (C) 2016-2017 Oracle. All rights reserved.
  */
 
 #include <linux/module.h>
@@ -43,7 +43,6 @@
 MODULE_VERSION("1.1");
 
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
-static void vnet_port_reset(struct vnet_port *port);
 
 static inline u32 vnet_tx_dring_avail(struct vio_dring_state *dr)
 {
@@ -747,6 +746,13 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 
 	/* RESET takes precedent over any other event */
 	if (port->rx_event & LDC_EVENT_RESET) {
+		/* a link went down */
+
+		if (port->vsw == 1) {
+			netif_tx_stop_all_queues(dev);
+			netif_carrier_off(dev);
+		}
+
 		vio_link_state_change(vio, LDC_EVENT_RESET);
 		vnet_port_reset(port);
 		vio_port_up(vio);
@@ -766,6 +772,13 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 	}
 
 	if (port->rx_event & LDC_EVENT_UP) {
+		/* a link came up */
+
+		if (port->vsw == 1) {
+			netif_carrier_on(port->dev);
+			netif_tx_start_all_queues(port->dev);
+		}
+
 		vio_link_state_change(vio, LDC_EVENT_UP);
 		port->rx_event = 0;
 		return 0;
@@ -1631,7 +1644,7 @@ void sunvnet_port_free_tx_bufs_common(struct vnet_port *port)
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_free_tx_bufs_common);
 
-static void vnet_port_reset(struct vnet_port *port)
+void vnet_port_reset(struct vnet_port *port)
 {
 	del_timer(&port->clean_timer);
 	sunvnet_port_free_tx_bufs_common(port);
@@ -1639,6 +1652,7 @@ static void vnet_port_reset(struct vnet_port *port)
 	port->tso = (port->vsw == 0);  /* no tso in vsw, misbehaves in bridge */
 	port->tsolen = 0;
 }
+EXPORT_SYMBOL_GPL(vnet_port_reset);
 
 static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 {
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index ce5c824..b21ef47 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -139,6 +139,7 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 void sunvnet_handshake_complete_common(struct vio_driver_state *vio);
 int sunvnet_poll_common(struct napi_struct *napi, int budget);
 void sunvnet_port_free_tx_bufs_common(struct vnet_port *port);
+void vnet_port_reset(struct vnet_port *port);
 bool sunvnet_port_is_up_common(struct vnet_port *vnet);
 void sunvnet_port_add_txq_common(struct vnet_port *port);
 void sunvnet_port_rm_txq_common(struct vnet_port *port);
-- 
1.7.1
