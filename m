From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 09/15] netvsc: optimize netvsc_send_pkt
Date: Wed,  3 May 2017 16:01:11 -0700
Message-ID: <20170503230117.20070-10-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33868 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbdECXBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:30 -0400
Received: by mail-pg0-f50.google.com with SMTP id v1so1976988pgv.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:30 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hand optimize netvsc_send_pkt by adding likely/unlikely.
Also don't print pointer in warning message, instead dump info.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 59ca5fd6797d..d9bd1a2db4db 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -751,9 +751,9 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	return msg_size;
 }
 
-static inline int netvsc_send_pkt(
+static int netvsc_send_pkt(
 	struct hv_device *device,
-	struct hv_netvsc_packet *packet,
+	const struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device,
 	struct hv_page_buffer **pb,
 	struct sk_buff *skb)
@@ -766,7 +766,6 @@ static inline int netvsc_send_pkt(
 	struct netdev_queue *txq = netdev_get_tx_queue(ndev, packet->q_idx);
 	u64 req_id;
 	int ret;
-	struct hv_page_buffer *pgbuf;
 	u32 ring_avail = hv_ringbuf_avail_percent(out_channel);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
@@ -788,10 +787,12 @@ static inline int netvsc_send_pkt(
 
 	req_id = (ulong)skb;
 
-	if (out_channel->rescind)
+	if (unlikely(out_channel->rescind))
 		return -ENODEV;
 
 	if (packet->page_buf_cnt) {
+		struct hv_page_buffer *pgbuf;
+
 		pgbuf = packet->cp_partial ? (*pb) +
 			packet->rmsg_pgcnt : (*pb);
 		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
@@ -809,20 +810,23 @@ static inline int netvsc_send_pkt(
 					   VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
 	}
 
-	if (ret == 0) {
-		atomic_inc_return(&nvchan->queue_sends);
+	if (likely(ret == 0)) {
+		atomic_inc(&nvchan->queue_sends);
 
 		if (ring_avail < RING_AVAIL_PERCENT_LOWATER)
 			netif_tx_stop_queue(txq);
-	} else if (ret == -EAGAIN) {
+	} else if (likely(ret == -EAGAIN)) {
 		netif_tx_stop_queue(txq);
 		if (atomic_read(&nvchan->queue_sends) < 1) {
 			netif_tx_wake_queue(txq);
 			ret = -ENOSPC;
 		}
 	} else {
-		netdev_err(ndev, "Unable to send packet %p ret %d\n",
-			   packet, ret);
+		if (net_ratelimit())
+			netdev_warn(ndev,
+				    "Unable to send packet qid %u index %d len %u (%d)\n",
+				    packet->q_idx, packet->send_buf_index,
+				    packet->total_data_buflen, ret);
 	}
 
 	return ret;
-- 
2.11.0
