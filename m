From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 05/15] netvsc: optimize avail percent calculation
Date: Wed,  3 May 2017 16:01:07 -0700
Message-ID: <20170503230117.20070-6-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35594 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdECXBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:31 -0400
Received: by mail-pg0-f49.google.com with SMTP id o3so1961002pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:30 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only need to look at write space (not read space) when computing
percent available.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 385809512c9f..ee5f8c520977 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -598,14 +598,13 @@ void netvsc_device_remove(struct hv_device *device)
  * Get the percentage of available bytes to write in the ring.
  * The return value is in range from 0 to 100.
  */
-static inline u32 hv_ringbuf_avail_percent(
-		struct hv_ring_buffer_info *ring_info)
+static inline
+u32 hv_ringbuf_avail_percent(const struct vmbus_channel *channel)
 {
-	u32 avail_read, avail_write;
+	const struct hv_ring_buffer_info *ring_info = &channel->outbound;
+	u32 avail_write = hv_get_bytes_to_write(ring_info);
 
-	hv_get_ringbuffer_availbytes(ring_info, &avail_read, &avail_write);
-
-	return avail_write * 100 / ring_info->ring_datasize;
+	return (avail_write * 100) / ring_info->ring_datasize;
 }
 
 static inline void netvsc_free_send_slot(struct netvsc_device *net_device,
@@ -655,7 +654,7 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 		wake_up(&net_device->wait_drain);
 
 	if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
-	    (hv_ringbuf_avail_percent(&channel->outbound) > RING_AVAIL_PERCENT_HIWATER ||
+	    (hv_ringbuf_avail_percent(channel) > RING_AVAIL_PERCENT_HIWATER ||
 	     queue_sends < 1))
 		netif_tx_wake_queue(netdev_get_tx_queue(ndev, q_idx));
 }
@@ -764,7 +763,7 @@ static inline int netvsc_send_pkt(
 	u64 req_id;
 	int ret;
 	struct hv_page_buffer *pgbuf;
-	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
+	u32 ring_avail = hv_ringbuf_avail_percent(out_channel);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
 	if (skb != NULL) {
-- 
2.11.0
