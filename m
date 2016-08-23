From: sthemmin@exchange.microsoft.com
Subject: [PATCH 10/14] hv_netvsc: refactor completion function
Date: Tue, 23 Aug 2016 12:29:42 -0700
Message-ID: <1471980586-18263-11-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:41164
        "EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753671AbcHWRy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:54:28 -0400
In-Reply-To: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Break the different cases, code is cleaner if broken up

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |  107 +++++++++++++++++++++++--------------------
 1 files changed, 58 insertions(+), 49 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 27eb507..830aae2 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -696,69 +696,78 @@ static inline void netvsc_free_send_slot(struct netvsc_device *net_device,
 	sync_change_bit(index, net_device->send_section_map);
 }
 
+static void netvsc_send_tx_complete(struct netvsc_device *net_device,
+				    struct vmbus_channel *incoming_channel,
+				    struct hv_device *device,
+				    struct vmpacket_descriptor *packet)
+{
+	struct sk_buff *skb = (struct sk_buff *)(unsigned long)packet->trans_id;
+	struct net_device *ndev = hv_get_drvdata(device);
+	struct net_device_context *net_device_ctx = netdev_priv(ndev);
+	struct vmbus_channel *channel = device->channel;
+	int num_outstanding_sends;
+	u16 q_idx = 0;
+	int queue_sends;
+
+	/* Notify the layer above us */
+	if (likely(skb)) {
+		struct hv_netvsc_packet *nvsc_packet
+			= (struct hv_netvsc_packet *)skb->cb;
+		u32 send_index = nvsc_packet->send_buf_index;
+
+		if (send_index != NETVSC_INVALID_INDEX)
+			netvsc_free_send_slot(net_device, send_index);
+		q_idx = nvsc_packet->q_idx;
+		channel = incoming_channel;
+
+		dev_kfree_skb_any(skb);
+	}
+
+	num_outstanding_sends =
+		atomic_dec_return(&net_device->num_outstanding_sends);
+	queue_sends = atomic_dec_return(&net_device->queue_sends[q_idx]);
+
+	if (net_device->destroy && num_outstanding_sends == 0)
+		wake_up(&net_device->wait_drain);
+
+	if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
+	    !net_device_ctx->start_remove &&
+	    (hv_ringbuf_avail_percent(&channel->outbound) > RING_AVAIL_PERCENT_HIWATER ||
+	     queue_sends < 1))
+		netif_tx_wake_queue(netdev_get_tx_queue(ndev, q_idx));
+}
+
 static void netvsc_send_completion(struct netvsc_device *net_device,
 				   struct vmbus_channel *incoming_channel,
 				   struct hv_device *device,
 				   struct vmpacket_descriptor *packet)
 {
 	struct nvsp_message *nvsp_packet;
-	struct hv_netvsc_packet *nvsc_packet;
 	struct net_device *ndev = hv_get_drvdata(device);
-	struct net_device_context *net_device_ctx = netdev_priv(ndev);
-	u32 send_index;
-	struct sk_buff *skb;
 
 	nvsp_packet = (struct nvsp_message *)((unsigned long)packet +
-			(packet->offset8 << 3));
+					      (packet->offset8 << 3));
 
-	if ((nvsp_packet->hdr.msg_type == NVSP_MSG_TYPE_INIT_COMPLETE) ||
-	    (nvsp_packet->hdr.msg_type ==
-	     NVSP_MSG1_TYPE_SEND_RECV_BUF_COMPLETE) ||
-	    (nvsp_packet->hdr.msg_type ==
-	     NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE) ||
-	    (nvsp_packet->hdr.msg_type ==
-	     NVSP_MSG5_TYPE_SUBCHANNEL)) {
+	switch (nvsp_packet->hdr.msg_type) {
+	case NVSP_MSG_TYPE_INIT_COMPLETE:
+	case NVSP_MSG1_TYPE_SEND_RECV_BUF_COMPLETE:
+	case NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE:
+	case NVSP_MSG5_TYPE_SUBCHANNEL:
 		/* Copy the response back */
 		memcpy(&net_device->channel_init_pkt, nvsp_packet,
 		       sizeof(struct nvsp_message));
 		complete(&net_device->channel_init_wait);
-	} else if (nvsp_packet->hdr.msg_type ==
-		   NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE) {
-		int num_outstanding_sends;
-		u16 q_idx = 0;
-		struct vmbus_channel *channel = device->channel;
-		int queue_sends;
-
-		/* Get the send context */
-		skb = (struct sk_buff *)(unsigned long)packet->trans_id;
-
-		/* Notify the layer above us */
-		if (skb) {
-			nvsc_packet = (struct hv_netvsc_packet *) skb->cb;
-			send_index = nvsc_packet->send_buf_index;
-			if (send_index != NETVSC_INVALID_INDEX)
-				netvsc_free_send_slot(net_device, send_index);
-			q_idx = nvsc_packet->q_idx;
-			channel = incoming_channel;
-			dev_kfree_skb_any(skb);
-		}
-
-		num_outstanding_sends =
-			atomic_dec_return(&net_device->num_outstanding_sends);
-		queue_sends = atomic_dec_return(&net_device->
-						queue_sends[q_idx]);
+		break;
 
-		if (net_device->destroy && num_outstanding_sends == 0)
-			wake_up(&net_device->wait_drain);
+	case NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE:
+		netvsc_send_tx_complete(net_device, incoming_channel,
+					device, packet);
+		break;
 
-		if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
-		    !net_device_ctx->start_remove &&
-		    (hv_ringbuf_avail_percent(&channel->outbound) >
-		     RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))
-			netif_tx_wake_queue(netdev_get_tx_queue(ndev, q_idx));
-	} else {
-		netdev_err(ndev, "Unknown send completion packet type- "
-			   "%d received!!\n", nvsp_packet->hdr.msg_type);
+	default:
+		netdev_err(ndev,
+			   "Unknown send completion type %d received!!\n",
+			   nvsp_packet->hdr.msg_type);
 	}
 }
 
-- 
1.7.4.1
