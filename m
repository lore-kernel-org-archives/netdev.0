From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 12/18] netvsc: don't pass void * to internal device_add
Date: Tue, 24 Jan 2017 13:06:09 -0800
Message-ID: <20170124210615.18628-13-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33880 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750840AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f54.google.com with SMTP id 14so57792318pgg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:31 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the caller's/callee's know that the format of the device_add
parameter is a netvsc_device_info struct.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 5 +++--
 drivers/net/hyperv/netvsc.c       | 6 +++---
 drivers/net/hyperv/rndis_filter.c | 5 ++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4b91e37c85ca..28cbd6a2ecf8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -178,7 +178,8 @@ struct rndis_device {
 /* Interface */
 struct rndis_message;
 struct netvsc_device;
-int netvsc_device_add(struct hv_device *device, void *additional_info);
+int netvsc_device_add(struct hv_device *device,
+		      const struct netvsc_device_info *info);
 void netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
@@ -196,7 +197,7 @@ void netvsc_channel_cb(void *context);
 int rndis_filter_open(struct netvsc_device *nvdev);
 int rndis_filter_close(struct netvsc_device *nvdev);
 int rndis_filter_device_add(struct hv_device *dev,
-			void *additional_info);
+			    struct netvsc_device_info *info);
 void rndis_filter_device_remove(struct hv_device *dev);
 int rndis_filter_set_rss_param(struct rndis_device *rdev,
 			       const u8 *key, int num_queue);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 80eecb4f9456..359e7ef7040b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1283,11 +1283,11 @@ void netvsc_channel_cb(void *context)
  * netvsc_device_add - Callback when the device belonging to this
  * driver is added
  */
-int netvsc_device_add(struct hv_device *device, void *additional_info)
+int netvsc_device_add(struct hv_device *device,
+		      const struct netvsc_device_info *device_info)
 {
 	int i, ret = 0;
-	int ring_size =
-	((struct netvsc_device_info *)additional_info)->ring_size;
+	int ring_size = device_info->ring_size;
 	struct netvsc_device *net_device;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index decce4f8fda8..e3b29f35366c 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1005,13 +1005,12 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 }
 
 int rndis_filter_device_add(struct hv_device *dev,
-			    void *additional_info)
+			    struct netvsc_device_info *device_info)
 {
 	struct net_device *net = hv_get_drvdata(dev);
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct netvsc_device *net_device;
 	struct rndis_device *rndis_device;
-	struct netvsc_device_info *device_info = additional_info;
 	struct ndis_offload hwcaps;
 	struct ndis_offload_params offloads;
 	struct nvsp_message *init_packet;
@@ -1035,7 +1034,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	 * NOTE! Once the channel is created, we may get a receive callback
 	 * (RndisFilterOnReceive()) before this call is completed
 	 */
-	ret = netvsc_device_add(dev, additional_info);
+	ret = netvsc_device_add(dev, device_info);
 	if (ret != 0) {
 		kfree(rndis_device);
 		return ret;
-- 
2.11.0
