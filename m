From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net,v2] hyperv: Fix the carrier status setting
Date: Mon, 10 Feb 2014 10:15:29 -0800
Message-ID: <1392056129-29398-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:34069
	"EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293AbaBJRYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 12:24:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch, the "cat /sys/class/net/ethN/operstate" shows
"unknown", and "ethtool ethN" shows "Link detected: yes", when VM
boots up with or without vNIC connected.

This patch fixed the problem.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7756118..18916f7 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -88,8 +88,12 @@ static int netvsc_open(struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct hv_device *device_obj = net_device_ctx->device_ctx;
+	struct netvsc_device *nvdev;
+	struct rndis_device *rdev;
 	int ret = 0;
 
+	netif_carrier_off(net);
+
 	/* Open up the device */
 	ret = rndis_filter_open(device_obj);
 	if (ret != 0) {
@@ -99,6 +103,11 @@ static int netvsc_open(struct net_device *net)
 
 	netif_start_queue(net);
 
+	nvdev = hv_get_drvdata(device_obj);
+	rdev = nvdev->extension;
+	if (!rdev->link_state)
+		netif_carrier_on(net);
+
 	return ret;
 }
 
@@ -229,15 +238,17 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 	struct net_device *net;
 	struct net_device_context *ndev_ctx;
 	struct netvsc_device *net_device;
+	struct rndis_device *rdev;
 
 	net_device = hv_get_drvdata(device_obj);
+	rdev = net_device->extension;
+
+	rdev->link_state = status != 1;
+
 	net = net_device->ndev;
 
-	if (!net) {
-		netdev_err(net, "got link status but net device "
-				"not initialized yet\n");
+	if (!net || net->reg_state != NETREG_REGISTERED)
 		return;
-	}
 
 	if (status == 1) {
 		netif_carrier_on(net);
@@ -414,9 +425,6 @@ static int netvsc_probe(struct hv_device *dev,
 	if (!net)
 		return -ENOMEM;
 
-	/* Set initial state */
-	netif_carrier_off(net);
-
 	net_device_ctx = netdev_priv(net);
 	net_device_ctx->device_ctx = dev;
 	hv_set_drvdata(dev, net);
@@ -443,8 +451,6 @@ static int netvsc_probe(struct hv_device *dev,
 	}
 	memcpy(net->dev_addr, device_info.mac_adr, ETH_ALEN);
 
-	netif_carrier_on(net);
-
 	ret = register_netdev(net);
 	if (ret != 0) {
 		pr_err("Unable to register netdev.\n");
-- 
1.7.4.1
