From: sixiao@microsoft.com
Subject: [PATCH net-next,v2,1/1] hv_netvsc: introduce netif-msg into netvsc module
Date: Fri, 24 Apr 2015 11:34:48 -0700
Message-ID: <1429900488-7302-1-git-send-email-sixiao@microsoft.com>
Cc: Simon Xiao <sixiao@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>

1. Introduce netif-msg to netvsc to control debug logging output
and keep msg_enable in netvsc_device_context so that it is
kept persistently.
2. Only call dump_rndis_message() when NETIF_MSG_RX_ERR or above
is specified in netvsc module debug param.
In non-debug mode, in current code, dump_rndis_message() will not
dump anything but it still initialize some local variables and
process the switch logic which is unnecessary, especially in
high network throughput situation.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 12 ++++++++++++
 drivers/net/hyperv/netvsc.c       |  3 +++
 drivers/net/hyperv/netvsc_drv.c   | 20 ++++++++++++++------
 drivers/net/hyperv/rndis_filter.c |  3 ++-
 4 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a10b316..e55c8f4 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -612,6 +612,15 @@ struct multi_send_data {
 	u32 count; /* counter of batched packets */
 };
 
+/* The context of the netvsc device  */
+struct net_device_context {
+	/* point back to our device context */
+	struct hv_device *device_ctx;
+	struct delayed_work dwork;
+	struct work_struct work;
+	u32 msg_enable; /* debug level */
+};
+
 /* Per netvsc device */
 struct netvsc_device {
 	struct hv_device *dev;
@@ -667,6 +676,9 @@ struct netvsc_device {
 	struct multi_send_data msd[NR_CPUS];
 	u32 max_pkt; /* max number of pkt in one send, e.g. 8 */
 	u32 pkt_align; /* alignment bytes, e.g. 8 */
+
+	/* The net device context */
+	struct net_device_context *nd_ctx;
 };
 
 /* NdisInitialize message */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2e8ad06..c651d4d 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1197,6 +1197,9 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	 */
 	ndev = net_device->ndev;
 
+	/* Add netvsc_device context to netvsc_device */
+	net_device->nd_ctx = netdev_priv(ndev);
+
 	/* Initialize the NetVSC channel extension */
 	init_completion(&net_device->channel_init_wait);
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a3a9d38..a9609d2 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -40,18 +40,21 @@
 
 #include "hyperv_net.h"
 
-struct net_device_context {
-	/* point back to our device context */
-	struct hv_device *device_ctx;
-	struct delayed_work dwork;
-	struct work_struct work;
-};
 
 #define RING_SIZE_MIN 64
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
+				NETIF_MSG_LINK | NETIF_MSG_IFUP |
+				NETIF_MSG_IFDOWN | NETIF_MSG_RX_ERR |
+				NETIF_MSG_TX_ERR;
+
+static int debug = -1;
+module_param(debug, int, S_IRUGO);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 static void do_set_multicast(struct work_struct *w)
 {
 	struct net_device_context *ndevctx =
@@ -888,6 +891,11 @@ static int netvsc_probe(struct hv_device *dev,
 
 	net_device_ctx = netdev_priv(net);
 	net_device_ctx->device_ctx = dev;
+	net_device_ctx->msg_enable = netif_msg_init(debug, default_msg);
+	if (netif_msg_probe(net_device_ctx))
+		netdev_dbg(net, "netvsc msg_enable: %d",
+			   net_device_ctx->msg_enable);
+
 	hv_set_drvdata(dev, net);
 	INIT_DELAYED_WORK(&net_device_ctx->dwork, netvsc_link_change);
 	INIT_WORK(&net_device_ctx->work, do_set_multicast);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0d92efe..9118cea 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -429,7 +429,8 @@ int rndis_filter_receive(struct hv_device *dev,
 
 	rndis_msg = pkt->data;
 
-	dump_rndis_message(dev, rndis_msg);
+	if (netif_msg_rx_err(net_dev->nd_ctx))
+		dump_rndis_message(dev, rndis_msg);
 
 	switch (rndis_msg->ndis_msg_type) {
 	case RNDIS_MSG_PACKET:
-- 
1.8.5.2
