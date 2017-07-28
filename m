From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3 4/7] netvsc: remove unnecessary indirection of page_buffer
Date: Fri, 28 Jul 2017 08:59:44 -0700
Message-ID: <20170728155947.10062-5-sthemmin@microsoft.com>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36814 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdG1P7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:59:55 -0400
Received: by mail-pg0-f44.google.com with SMTP id 125so112865954pgi.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:59:55 -0700 (PDT)
In-Reply-To: <20170728155947.10062-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal API was passing struct hv_page_buffer **
when only simple struct hv_page_buffer * was necessary
for passing an array.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  2 +-
 drivers/net/hyperv/netvsc.c       | 21 ++++++++++-----------
 drivers/net/hyperv/netvsc_drv.c   | 10 ++++------
 drivers/net/hyperv/rndis_filter.c |  4 ++--
 4 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index fb62ea632914..9ca3ed692d73 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -190,7 +190,7 @@ void netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct net_device_context *ndc,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
-		struct hv_page_buffer **page_buffer,
+		struct hv_page_buffer *page_buffer,
 		struct sk_buff *skb);
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				struct rndis_message *resp);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f0c15e782ce0..d3c0b19f6d34 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -697,7 +697,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 				   u32 pend_size,
 				   struct hv_netvsc_packet *packet,
 				   struct rndis_message *rndis_msg,
-				   struct hv_page_buffer **pb,
+				   struct hv_page_buffer *pb,
 				   struct sk_buff *skb)
 {
 	char *start = net_device->send_buf;
@@ -718,9 +718,9 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	}
 
 	for (i = 0; i < page_count; i++) {
-		char *src = phys_to_virt((*pb)[i].pfn << PAGE_SHIFT);
-		u32 offset = (*pb)[i].offset;
-		u32 len = (*pb)[i].len;
+		char *src = phys_to_virt(pb[i].pfn << PAGE_SHIFT);
+		u32 offset = pb[i].offset;
+		u32 len = pb[i].len;
 
 		memcpy(dest, (src + offset), len);
 		msg_size += len;
@@ -739,7 +739,7 @@ static inline int netvsc_send_pkt(
 	struct hv_device *device,
 	struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device,
-	struct hv_page_buffer **pb,
+	struct hv_page_buffer *pb,
 	struct sk_buff *skb)
 {
 	struct nvsp_message nvmsg;
@@ -750,7 +750,6 @@ static inline int netvsc_send_pkt(
 	struct netdev_queue *txq = netdev_get_tx_queue(ndev, packet->q_idx);
 	u64 req_id;
 	int ret;
-	struct hv_page_buffer *pgbuf;
 	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
@@ -776,11 +775,11 @@ static inline int netvsc_send_pkt(
 		return -ENODEV;
 
 	if (packet->page_buf_cnt) {
-		pgbuf = packet->cp_partial ? (*pb) +
-			packet->rmsg_pgcnt : (*pb);
+		if (packet->cp_partial)
+			pb += packet->rmsg_pgcnt;
+
 		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
-						      pgbuf,
-						      packet->page_buf_cnt,
+						      pb, packet->page_buf_cnt,
 						      &nvmsg,
 						      sizeof(struct nvsp_message),
 						      req_id,
@@ -830,7 +829,7 @@ static inline void move_pkt_msd(struct hv_netvsc_packet **msd_send,
 int netvsc_send(struct net_device_context *ndev_ctx,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
-		struct hv_page_buffer **pb,
+		struct hv_page_buffer *pb,
 		struct sk_buff *skb)
 {
 	struct netvsc_device *net_device
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a04f2efbbc25..8ff4cbf582cc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -282,9 +282,8 @@ static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
 
 static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
 			   struct hv_netvsc_packet *packet,
-			   struct hv_page_buffer **page_buf)
+			   struct hv_page_buffer *pb)
 {
-	struct hv_page_buffer *pb = *page_buf;
 	u32 slots_used = 0;
 	char *data = skb->data;
 	int frags = skb_shinfo(skb)->nr_frags;
@@ -359,8 +358,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	u32 rndis_msg_size;
 	struct rndis_per_packet_info *ppi;
 	u32 hash;
-	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
-	struct hv_page_buffer *pb = page_buf;
+	struct hv_page_buffer pb[MAX_PAGE_BUFFER_COUNT];
 
 	/* We can only transmit MAX_PAGE_BUFFER_COUNT number
 	 * of pages in a single packet. If skb is scattered around
@@ -503,12 +501,12 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->total_data_buflen = rndis_msg->msg_len;
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
-					       skb, packet, &pb);
+					       skb, packet, pb);
 
 	/* timestamp packet in software */
 	skb_tx_timestamp(skb);
 
-	ret = netvsc_send(net_device_ctx, packet, rndis_msg, &pb, skb);
+	ret = netvsc_send(net_device_ctx, packet, rndis_msg, pb, skb);
 	if (likely(ret == 0))
 		return NETDEV_TX_OK;
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index bf21ea92c743..d80e9e3f433e 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -214,11 +214,11 @@ static void dump_rndis_message(struct hv_device *hv_dev,
 static int rndis_filter_send_request(struct rndis_device *dev,
 				  struct rndis_request *req)
 {
-	int ret;
 	struct hv_netvsc_packet *packet;
 	struct hv_page_buffer page_buf[2];
 	struct hv_page_buffer *pb = page_buf;
 	struct net_device_context *net_device_ctx = netdev_priv(dev->ndev);
+	int ret;
 
 	/* Setup the packet to send it */
 	packet = &req->pkt;
@@ -245,7 +245,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	}
 
 	rcu_read_lock_bh();
-	ret = netvsc_send(net_device_ctx, packet, NULL, &pb, NULL);
+	ret = netvsc_send(net_device_ctx, packet, NULL, pb, NULL);
 	rcu_read_unlock_bh();
 
 	return ret;
-- 
2.11.0
