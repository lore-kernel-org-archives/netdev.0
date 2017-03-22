From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/9] netvsc: handle offline mtu and channel change
Date: Wed, 22 Mar 2017 14:50:58 -0700
Message-ID: <20170322215105.1059-3-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34531 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdCVVvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:17 -0400
Received: by mail-pg0-f54.google.com with SMTP id 21so80032627pgg.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:16 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device is not up, then changing MTU (or number of channels)
should not re-enable the device.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 191372486a87..b3a7f508434b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -743,6 +743,7 @@ static int netvsc_set_channels(struct net_device *net,
 	struct hv_device *dev = net_device_ctx->device_ctx;
 	struct netvsc_device *nvdev = net_device_ctx->nvdev;
 	unsigned int count = channels->combined_count;
+	bool was_running;
 	int ret;
 
 	/* We do not support separate count for rx, tx, or other */
@@ -762,9 +763,12 @@ static int netvsc_set_channels(struct net_device *net,
 	if (count > nvdev->max_chn)
 		return -EINVAL;
 
-	ret = netvsc_close(net);
-	if (ret)
-		return ret;
+	was_running = netif_running(net);
+	if (was_running) {
+		ret = netvsc_close(net);
+		if (ret)
+			return ret;
+	}
 
 	net_device_ctx->start_remove = true;
 	rndis_filter_device_remove(dev, nvdev);
@@ -775,9 +779,11 @@ static int netvsc_set_channels(struct net_device *net,
 	else
 		netvsc_set_queues(net, dev, nvdev->num_chn);
 
-	netvsc_open(net);
 	net_device_ctx->start_remove = false;
 
+	if (was_running)
+		ret = netvsc_open(net);
+
 	/* We may have missed link change notifications */
 	schedule_delayed_work(&net_device_ctx->dwork, 0);
 
@@ -845,14 +851,18 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct netvsc_device *nvdev = ndevctx->nvdev;
 	struct hv_device *hdev = ndevctx->device_ctx;
 	struct netvsc_device_info device_info;
+	bool was_running;
 	int ret;
 
 	if (ndevctx->start_remove || !nvdev || nvdev->destroy)
 		return -ENODEV;
 
-	ret = netvsc_close(ndev);
-	if (ret)
-		goto out;
+	was_running = netif_running(ndev);
+	if (was_running) {
+		ret = netvsc_close(ndev);
+		if (ret)
+			return ret;
+	}
 
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
@@ -872,10 +882,11 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 	rndis_filter_device_add(hdev, &device_info);
 
-out:
-	netvsc_open(ndev);
 	ndevctx->start_remove = false;
 
+	if (was_running)
+		ret = netvsc_open(ndev);
+
 	/* We may have missed link change notifications */
 	schedule_delayed_work(&ndevctx->dwork, 0);
 
-- 
2.11.0
