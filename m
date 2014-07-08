From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] hyperv: Add netpoll support
Date: Tue,  8 Jul 2014 11:32:27 +0200
Message-ID: <1404811947-5174-1-git-send-email-richard@nod.at>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: kys@microsoft.com, haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to have at least a netconsole to debug kernel issues on
Windows Azure this patch implements netpoll support.
Sending packets is easy, netvsc_start_xmit() does already everything
needed.
To receive we need to trigger the channel callback which is usally
called via tasklet_schedule().

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/hyperv/netvsc_drv.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4fd71b7..367b71e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -736,6 +736,17 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void netvsc_poll_controller(struct net_device *net)
+{
+	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct hv_device *dev = net_device_ctx->device_ctx;
+
+	local_bh_disable();
+	netvsc_channel_cb(dev->channel);
+	local_bh_enable();
+}
+#endif
 
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo	= netvsc_get_drvinfo,
@@ -751,6 +762,9 @@ static const struct net_device_ops device_ops = {
 	.ndo_validate_addr =		eth_validate_addr,
 	.ndo_set_mac_address =		netvsc_set_mac_addr,
 	.ndo_select_queue =		netvsc_select_queue,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller =		netvsc_poll_controller,
+#endif
 };
 
 /*
-- 
2.0.1
