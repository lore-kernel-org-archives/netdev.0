From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net,2/2] hyperv: Fix RNDIS send_completion code path
Date: Fri,  5 Apr 2013 14:44:40 -0700
Message-ID: <1365198280-23270-2-git-send-email-haiyangz@microsoft.com>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some cases, the VM_PKT_COMP message can arrive later than RNDIS completion
message, which will free the packet memory. This may cause panic due to access
to freed memory in netvsc_send_completion().

This patch fixes this problem by removing rndis_filter_send_request_completion()
from the code path. The function was a no-op.

Reported-by: Long Li <longli@microsoft.com>
Tested-by: Long Li <longli@microsoft.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc.c       |   17 ++++++++++++-----
 drivers/net/hyperv/rndis_filter.c |   14 +-------------
 2 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 1cd7748..f5f0f09 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -470,8 +470,10 @@ static void netvsc_send_completion(struct hv_device *device,
 			packet->trans_id;
 
 		/* Notify the layer above us */
-		nvsc_packet->completion.send.send_completion(
-			nvsc_packet->completion.send.send_completion_ctx);
+		if (nvsc_packet)
+			nvsc_packet->completion.send.send_completion(
+				nvsc_packet->completion.send.
+				send_completion_ctx);
 
 		num_outstanding_sends =
 			atomic_dec_return(&net_device->num_outstanding_sends);
@@ -498,6 +500,7 @@ int netvsc_send(struct hv_device *device,
 	int ret = 0;
 	struct nvsp_message sendMessage;
 	struct net_device *ndev;
+	u64 req_id;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -518,20 +521,24 @@ int netvsc_send(struct hv_device *device,
 		0xFFFFFFFF;
 	sendMessage.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
 
+	if (packet->completion.send.send_completion)
+		req_id = (u64)packet;
+	else
+		req_id = 0;
+
 	if (packet->page_buf_cnt) {
 		ret = vmbus_sendpacket_pagebuffer(device->channel,
 						  packet->page_buf,
 						  packet->page_buf_cnt,
 						  &sendMessage,
 						  sizeof(struct nvsp_message),
-						  (unsigned long)packet);
+						  req_id);
 	} else {
 		ret = vmbus_sendpacket(device->channel, &sendMessage,
 				sizeof(struct nvsp_message),
-				(unsigned long)packet,
+				req_id,
 				VM_PKT_DATA_INBAND,
 				VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
-
 	}
 
 	if (ret == 0) {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 2b657d4..0775f0a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -61,9 +61,6 @@ struct rndis_request {
 
 static void rndis_filter_send_completion(void *ctx);
 
-static void rndis_filter_send_request_completion(void *ctx);
-
-
 
 static struct rndis_device *get_rndis_device(void)
 {
@@ -241,10 +238,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 			packet->page_buf[0].len;
 	}
 
-	packet->completion.send.send_completion_ctx = req;/* packet; */
-	packet->completion.send.send_completion =
-		rndis_filter_send_request_completion;
-	packet->completion.send.send_completion_tid = (unsigned long)dev;
+	packet->completion.send.send_completion = NULL;
 
 	ret = netvsc_send(dev->net_dev->dev, packet);
 	return ret;
@@ -999,9 +993,3 @@ static void rndis_filter_send_completion(void *ctx)
 	/* Pass it back to the original handler */
 	filter_pkt->completion(filter_pkt->completion_ctx);
 }
-
-
-static void rndis_filter_send_request_completion(void *ctx)
-{
-	/* Noop */
-}
-- 
1.7.4.1
