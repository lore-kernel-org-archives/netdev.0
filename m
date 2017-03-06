From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 1/5] ldmvsw: better use of link up and down on ldom vswitch
Date: Mon,  6 Mar 2017 15:15:28 -0800
Message-ID: <1488842132-512058-2-git-send-email-shannon.nelson@oracle.com>
References: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49063 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdCFXYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 18:24:00 -0500
In-Reply-To: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
see the LDC_EVENT_RESET.

Orabug: 25525312

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |   10 +++++++---
 drivers/net/ethernet/sun/sunvnet_common.c |   14 ++++++++++++++
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 89952de..c6f6d59 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -41,8 +41,8 @@
 static u8 vsw_port_hwaddr[ETH_ALEN] = {0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
 
 #define DRV_MODULE_NAME		"ldmvsw"
-#define DRV_MODULE_VERSION	"1.1"
-#define DRV_MODULE_RELDATE	"February 3, 2017"
+#define DRV_MODULE_VERSION	"1.2"
+#define DRV_MODULE_RELDATE	"March 4, 2017"
 
 static char version[] =
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
@@ -133,7 +133,6 @@ static void vsw_poll_controller(struct net_device *dev)
 #endif
 
 static const struct net_device_ops vsw_ops = {
-	.ndo_open		= sunvnet_open_common,
 	.ndo_stop		= sunvnet_close_common,
 	.ndo_set_rx_mode	= vsw_set_rx_mode,
 	.ndo_set_mac_address	= sunvnet_set_mac_addr_common,
@@ -365,6 +364,11 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
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
index fa2d11c..bba0691 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -747,6 +747,13 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 
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
@@ -766,6 +773,13 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
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
-- 
1.7.1
