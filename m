From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netvsc: use napi_consume_skb
Date: Fri,  7 Apr 2017 14:41:19 -0400
Message-ID: <20170407184119.17123-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: dave@davemloft.net, kys@microsoft.com, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35215 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754489AbdDGSlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:41:24 -0400
Received: by mail-it0-f41.google.com with SMTP id y18so124546869itc.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 11:41:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows using deferred skb freeing and with NAPI. And get buffer
recycling.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index e998e2f7a619..0b4df3f59ecf 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -601,7 +601,8 @@ static inline void netvsc_free_send_slot(struct netvsc_device *net_device,
 static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 				    struct vmbus_channel *incoming_channel,
 				    struct hv_device *device,
-				    const struct vmpacket_descriptor *desc)
+				    const struct vmpacket_descriptor *desc,
+				    int budget)
 {
 	struct sk_buff *skb = (struct sk_buff *)(unsigned long)desc->trans_id;
 	struct net_device *ndev = hv_get_drvdata(device);
@@ -628,7 +629,7 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 		tx_stats->bytes += packet->total_bytes;
 		u64_stats_update_end(&tx_stats->syncp);
 
-		dev_consume_skb_any(skb);
+		napi_consume_skb(skb, budget);
 	}
 
 	queue_sends =
@@ -646,7 +647,8 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 static void netvsc_send_completion(struct netvsc_device *net_device,
 				   struct vmbus_channel *incoming_channel,
 				   struct hv_device *device,
-				   const struct vmpacket_descriptor *desc)
+				   const struct vmpacket_descriptor *desc,
+				   int budget)
 {
 	struct nvsp_message *nvsp_packet = hv_pkt_data(desc);
 	struct net_device *ndev = hv_get_drvdata(device);
@@ -664,7 +666,7 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 
 	case NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE:
 		netvsc_send_tx_complete(net_device, incoming_channel,
-					device, desc);
+					device, desc, budget);
 		break;
 
 	default:
@@ -1174,14 +1176,16 @@ static int netvsc_process_raw_pkt(struct hv_device *device,
 				  struct vmbus_channel *channel,
 				  struct netvsc_device *net_device,
 				  struct net_device *ndev,
-				  const struct vmpacket_descriptor *desc)
+				  const struct vmpacket_descriptor *desc,
+				  int budget)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct nvsp_message *nvmsg = hv_pkt_data(desc);
 
 	switch (desc->type) {
 	case VM_PKT_COMP:
-		netvsc_send_completion(net_device, channel, device, desc);
+		netvsc_send_completion(net_device, channel, device,
+				       desc, budget);
 		break;
 
 	case VM_PKT_DATA_USING_XFER_PAGES:
@@ -1230,7 +1234,7 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 
 	while (nvchan->desc && work_done < budget) {
 		work_done += netvsc_process_raw_pkt(device, channel, net_device,
-						    ndev, nvchan->desc);
+						    ndev, nvchan->desc, budget);
 		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
 	}
 
-- 
2.11.0
