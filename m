From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 13/18] netvsc: simplify rndis_filter_remove
Date: Tue, 24 Jan 2017 13:06:10 -0800
Message-ID: <20170124210615.18628-14-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33884 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so57792452pgg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:32 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All caller's already have pointer to netvsc_device so pass it.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  3 ++-
 drivers/net/hyperv/netvsc_drv.c   |  8 ++++----
 drivers/net/hyperv/rndis_filter.c | 12 ++++++------
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 28cbd6a2ecf8..757205c9cb93 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -198,7 +198,8 @@ int rndis_filter_open(struct netvsc_device *nvdev);
 int rndis_filter_close(struct netvsc_device *nvdev);
 int rndis_filter_device_add(struct hv_device *dev,
 			    struct netvsc_device_info *info);
-void rndis_filter_device_remove(struct hv_device *dev);
+void rndis_filter_device_remove(struct hv_device *dev,
+				struct netvsc_device *nvdev);
 int rndis_filter_set_rss_param(struct rndis_device *rdev,
 			       const u8 *key, int num_queue);
 int rndis_filter_receive(struct net_device *ndev,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4bc1fdbc8cd7..11755783c2f6 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -780,7 +780,7 @@ static int netvsc_set_channels(struct net_device *net,
 		return ret;
 
 	net_device_ctx->start_remove = true;
-	rndis_filter_device_remove(dev);
+	rndis_filter_device_remove(dev, nvdev);
 
 	ret = netvsc_set_queues(net, dev, count);
 	if (ret == 0)
@@ -865,7 +865,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 		goto out;
 
 	ndevctx->start_remove = true;
-	rndis_filter_device_remove(hdev);
+	rndis_filter_device_remove(hdev, nvdev);
 
 	ndev->mtu = mtu;
 
@@ -1493,7 +1493,7 @@ static int netvsc_probe(struct hv_device *dev,
 	ret = register_netdev(net);
 	if (ret != 0) {
 		pr_err("Unable to register netdev.\n");
-		rndis_filter_device_remove(dev);
+		rndis_filter_device_remove(dev, nvdev);
 		netvsc_free_netdev(net);
 	}
 
@@ -1533,7 +1533,7 @@ static int netvsc_remove(struct hv_device *dev)
 	 * Call to the vsc driver to let it know that the device is being
 	 * removed
 	 */
-	rndis_filter_device_remove(dev);
+	rndis_filter_device_remove(dev, ndev_ctx->nvdev);
 
 	hv_set_drvdata(dev, NULL);
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index e3b29f35366c..70b099a731a9 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1053,7 +1053,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	/* Send the rndis initialization message */
 	ret = rndis_filter_init_device(rndis_device);
 	if (ret != 0) {
-		rndis_filter_device_remove(dev);
+		rndis_filter_device_remove(dev, net_device);
 		return ret;
 	}
 
@@ -1068,7 +1068,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	/* Get the mac address */
 	ret = rndis_filter_query_device_mac(rndis_device);
 	if (ret != 0) {
-		rndis_filter_device_remove(dev);
+		rndis_filter_device_remove(dev, net_device);
 		return ret;
 	}
 
@@ -1077,7 +1077,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	/* Find HW offload capabilities */
 	ret = rndis_query_hwcaps(rndis_device, &hwcaps);
 	if (ret != 0) {
-		rndis_filter_device_remove(dev);
+		rndis_filter_device_remove(dev, net_device);
 		return ret;
 	}
 
@@ -1233,13 +1233,13 @@ int rndis_filter_device_add(struct hv_device *dev,
 	return 0; /* return 0 because primary channel can be used alone */
 
 err_dev_remv:
-	rndis_filter_device_remove(dev);
+	rndis_filter_device_remove(dev, net_device);
 	return ret;
 }
 
-void rndis_filter_device_remove(struct hv_device *dev)
+void rndis_filter_device_remove(struct hv_device *dev,
+				struct netvsc_device *net_dev)
 {
-	struct netvsc_device *net_dev = hv_device_to_netvsc_device(dev);
 	struct rndis_device *rndis_dev = net_dev->extension;
 
 	/* If not all subchannel offers are complete, wait for them until
-- 
2.11.0
