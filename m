From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Implement partial copy into send buffer
Date: Mon, 13 Apr 2015 16:34:35 -0700
Message-ID: <1428968075-9950-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:54565
	"EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbbDMWQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 18:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If remaining space in a send buffer slot is too small for the whole message,
we only copy the RNDIS header and PPI data into send buffer, so we can batch
one more packet each time. It reduces the vmbus per-message overhead.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    5 ++++
 drivers/net/hyperv/netvsc.c     |   50 ++++++++++++++++++++++++++------------
 drivers/net/hyperv/netvsc_drv.c |   10 +++++--
 3 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f0b8b3e..a10b316 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -132,6 +132,8 @@ struct hv_netvsc_packet {
 
 	bool is_data_pkt;
 	bool xmit_more; /* from skb */
+	bool cp_partial; /* partial copy into send buffer */
+
 	u16 vlan_tci;
 
 	u16 q_idx;
@@ -146,6 +148,9 @@ struct hv_netvsc_packet {
 	/* This points to the memory after page_buf */
 	struct rndis_message *rndis_msg;
 
+	u32 rmsg_size; /* RNDIS header and PPI size */
+	u32 rmsg_pgcnt; /* page count of RNDIS header and PPI */
+
 	u32 total_data_buflen;
 	/* Points to the send/receive buffer where the ethernet frame is */
 	void *data;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4d4d497..2e8ad06 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -703,15 +703,18 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	u32 msg_size = 0;
 	u32 padding = 0;
 	u32 remain = packet->total_data_buflen % net_device->pkt_align;
+	u32 page_count = packet->cp_partial ? packet->rmsg_pgcnt :
+		packet->page_buf_cnt;
 
 	/* Add padding */
-	if (packet->is_data_pkt && packet->xmit_more && remain) {
+	if (packet->is_data_pkt && packet->xmit_more && remain &&
+	    !packet->cp_partial) {
 		padding = net_device->pkt_align - remain;
 		packet->rndis_msg->msg_len += padding;
 		packet->total_data_buflen += padding;
 	}
 
-	for (i = 0; i < packet->page_buf_cnt; i++) {
+	for (i = 0; i < page_count; i++) {
 		char *src = phys_to_virt(packet->page_buf[i].pfn << PAGE_SHIFT);
 		u32 offset = packet->page_buf[i].offset;
 		u32 len = packet->page_buf[i].len;
@@ -739,6 +742,7 @@ static inline int netvsc_send_pkt(
 	struct net_device *ndev = net_device->ndev;
 	u64 req_id;
 	int ret;
+	struct hv_page_buffer *pgbuf;
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
 	if (packet->is_data_pkt) {
@@ -766,8 +770,10 @@ static inline int netvsc_send_pkt(
 		return -ENODEV;
 
 	if (packet->page_buf_cnt) {
+		pgbuf = packet->cp_partial ? packet->page_buf +
+			packet->rmsg_pgcnt : packet->page_buf;
 		ret = vmbus_sendpacket_pagebuffer(out_channel,
-						  packet->page_buf,
+						  pgbuf,
 						  packet->page_buf_cnt,
 						  &nvmsg,
 						  sizeof(struct nvsp_message),
@@ -824,6 +830,7 @@ int netvsc_send(struct hv_device *device,
 	unsigned long flag;
 	struct multi_send_data *msdp;
 	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
+	bool try_batch;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -837,6 +844,7 @@ int netvsc_send(struct hv_device *device,
 	}
 	packet->channel = out_channel;
 	packet->send_buf_index = NETVSC_INVALID_INDEX;
+	packet->cp_partial = false;
 
 	msdp = &net_device->msd[q_idx];
 
@@ -845,12 +853,18 @@ int netvsc_send(struct hv_device *device,
 	if (msdp->pkt)
 		msd_len = msdp->pkt->total_data_buflen;
 
-	if (packet->is_data_pkt && msd_len > 0 &&
-	    msdp->count < net_device->max_pkt &&
-	    msd_len + pktlen + net_device->pkt_align <
+	try_batch = packet->is_data_pkt && msd_len > 0 && msdp->count <
+		    net_device->max_pkt;
+
+	if (try_batch && msd_len + pktlen + net_device->pkt_align <
 	    net_device->send_section_size) {
 		section_index = msdp->pkt->send_buf_index;
 
+	} else if (try_batch && msd_len + packet->rmsg_size <
+		   net_device->send_section_size) {
+		section_index = msdp->pkt->send_buf_index;
+		packet->cp_partial = true;
+
 	} else if (packet->is_data_pkt && pktlen + net_device->pkt_align <
 		   net_device->send_section_size) {
 		section_index = netvsc_get_next_send_section(net_device);
@@ -866,22 +880,26 @@ int netvsc_send(struct hv_device *device,
 		netvsc_copy_to_send_buf(net_device,
 					section_index, msd_len,
 					packet);
-		if (!packet->part_of_skb) {
-			skb = (struct sk_buff *)
-				(unsigned long)
-				packet->send_completion_tid;
-
-			packet->send_completion_tid = 0;
-		}
 
-		packet->page_buf_cnt = 0;
 		packet->send_buf_index = section_index;
-		packet->total_data_buflen += msd_len;
+
+		if (packet->cp_partial) {
+			packet->page_buf_cnt -= packet->rmsg_pgcnt;
+			packet->total_data_buflen = msd_len + packet->rmsg_size;
+		} else {
+			packet->page_buf_cnt = 0;
+			packet->total_data_buflen += msd_len;
+			if (!packet->part_of_skb) {
+				skb = (struct sk_buff *)(unsigned long)packet->
+				       send_completion_tid;
+				packet->send_completion_tid = 0;
+			}
+		}
 
 		if (msdp->pkt)
 			netvsc_xmit_completion(msdp->pkt);
 
-		if (packet->xmit_more) {
+		if (packet->xmit_more && !packet->cp_partial) {
 			msdp->pkt = packet;
 			msdp->count++;
 		} else {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4487167..a3a9d38 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -277,15 +277,16 @@ static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
 }
 
 static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
-			   struct hv_page_buffer *pb)
+			   struct hv_netvsc_packet *packet)
 {
+	struct hv_page_buffer *pb = packet->page_buf;
 	u32 slots_used = 0;
 	char *data = skb->data;
 	int frags = skb_shinfo(skb)->nr_frags;
 	int i;
 
 	/* The packet is laid out thus:
-	 * 1. hdr
+	 * 1. hdr: RNDIS header and PPI
 	 * 2. skb linear data
 	 * 3. skb fragment data
 	 */
@@ -294,6 +295,9 @@ static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
 					offset_in_page(hdr),
 					len, &pb[slots_used]);
 
+	packet->rmsg_size = len;
+	packet->rmsg_pgcnt = slots_used;
+
 	slots_used += fill_pg_buf(virt_to_page(data),
 				offset_in_page(data),
 				skb_headlen(skb), &pb[slots_used]);
@@ -578,7 +582,7 @@ do_send:
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->total_data_buflen = rndis_msg->msg_len;
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
-					skb, &page_buf[0]);
+					       skb, packet);
 
 	ret = netvsc_send(net_device_ctx->device_ctx, packet);
 
-- 
1.7.4.1
