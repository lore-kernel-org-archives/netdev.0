From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V5 1/1] hv_netvsc: Use the xmit_more skb flag to optimize signaling the host
Date: Sun, 10 May 2015 21:08:14 -0700
Message-ID: <1431317294-16442-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on the information given to this driver (via the xmit_more skb flag),
we can defer signaling the host if more packets are on the way. This will help
make the host more efficient since it can potentially process a larger batch of
packets. Implement this optimization.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	v2: Fixed up indentation based on feedback from David Miller.
	v3,v4: If the queue could be stopped, deal with that condition: Eric Dumazet <eric.dumazet@gmail.com>
	v5: Fixed up indentation based on feedback from David Miller.

 drivers/net/hyperv/netvsc.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index ea091bc..7fdf3e8 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -743,6 +743,8 @@ static inline int netvsc_send_pkt(
 	u64 req_id;
 	int ret;
 	struct hv_page_buffer *pgbuf;
+	u32 vmbus_flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
+	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
 	if (packet->is_data_pkt) {
@@ -769,30 +771,41 @@ static inline int netvsc_send_pkt(
 	if (out_channel->rescind)
 		return -ENODEV;
 
+	/*
+	 * It is possible that once we successfully place this packet
+	 * on the ringbuffer, we may stop the queue. In that case, we want
+	 * to notify the host independent of the xmit_more flag. We don't
+	 * need to be precise here; in the worst case we may signal the host
+	 * unnecessarily.
+	 */
+	if (ring_avail < (RING_AVAIL_PERCENT_LOWATER + 1))
+		packet->xmit_more = false;
+
 	if (packet->page_buf_cnt) {
 		pgbuf = packet->cp_partial ? packet->page_buf +
 			packet->rmsg_pgcnt : packet->page_buf;
-		ret = vmbus_sendpacket_pagebuffer(out_channel,
-						  pgbuf,
-						  packet->page_buf_cnt,
-						  &nvmsg,
-						  sizeof(struct nvsp_message),
-						  req_id);
+		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
+						      pgbuf,
+						      packet->page_buf_cnt,
+						      &nvmsg,
+						      sizeof(struct
+							     nvsp_message),
+						      req_id,
+						      vmbus_flags,
+						      !packet->xmit_more);
 	} else {
-		ret = vmbus_sendpacket(
-				out_channel, &nvmsg,
-				sizeof(struct nvsp_message),
-				req_id,
-				VM_PKT_DATA_INBAND,
-				VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+		ret = vmbus_sendpacket_ctl(out_channel, &nvmsg,
+					   sizeof(struct nvsp_message),
+					   req_id,
+					   VM_PKT_DATA_INBAND,
+					   vmbus_flags, !packet->xmit_more);
 	}
 
 	if (ret == 0) {
 		atomic_inc(&net_device->num_outstanding_sends);
 		atomic_inc(&net_device->queue_sends[q_idx]);
 
-		if (hv_ringbuf_avail_percent(&out_channel->outbound) <
-			RING_AVAIL_PERCENT_LOWATER) {
+		if (ring_avail < RING_AVAIL_PERCENT_LOWATER) {
 			netif_tx_stop_queue(netdev_get_tx_queue(
 					    ndev, q_idx));
 
-- 
1.7.4.1
