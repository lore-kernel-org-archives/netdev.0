From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/3] netxen: add hardware LRO support
Date: Wed,  5 Aug 2009 10:34:09 -0700
Message-ID: <1249493649-26336-3-git-send-email-dhananjay@netxen.com>
References: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Narender Kumar <narender.kumar@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:31977 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1750711AbZHEReL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 13:34:11 -0400
In-Reply-To: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to handle aggregate packets from firmware.
Local TCP flows are automatically identified by firmware
based on the dest IP hash added by driver for local IP
addresses.

The packets are sent down on the jumbo rx ring.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   21 ++++++
 drivers/net/netxen/netxen_nic_ctx.c  |    2 +
 drivers/net/netxen/netxen_nic_init.c |  124 ++++++++++++++++++++++++++++------
 3 files changed, 125 insertions(+), 22 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index bb4aa4f..ae81f70 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -365,6 +365,7 @@ struct rcv_desc {
 #define NETXEN_NIC_RXPKT_DESC  0x04
 #define NETXEN_OLD_RXPKT_DESC  0x3f
 #define NETXEN_NIC_RESPONSE_DESC 0x05
+#define NETXEN_NIC_LRO_DESC  	0x12
 
 /* for status field in status_desc */
 #define STATUS_NEED_CKSUM	(1)
@@ -398,6 +399,24 @@ struct rcv_desc {
 #define netxen_get_sts_opcode(sts_data)	\
 	(((sts_data) >> 58) & 0x03F)
 
+#define netxen_get_lro_sts_refhandle(sts_data) 	\
+	((sts_data) & 0x0FFFF)
+#define netxen_get_lro_sts_length(sts_data)	\
+	(((sts_data) >> 16) & 0x0FFFF)
+#define netxen_get_lro_sts_l2_hdr_offset(sts_data)	\
+	(((sts_data) >> 32) & 0x0FF)
+#define netxen_get_lro_sts_l4_hdr_offset(sts_data)	\
+	(((sts_data) >> 40) & 0x0FF)
+#define netxen_get_lro_sts_timestamp(sts_data)	\
+	(((sts_data) >> 48) & 0x1)
+#define netxen_get_lro_sts_type(sts_data)	\
+	(((sts_data) >> 49) & 0x7)
+#define netxen_get_lro_sts_push_flag(sts_data)		\
+	(((sts_data) >> 52) & 0x1)
+#define netxen_get_lro_sts_seq_number(sts_data)		\
+	((sts_data) & 0x0FFFFFFFF)
+
+
 struct status_desc {
 	__le64 status_desc_data[2];
 } __attribute__ ((aligned(16)));
@@ -712,6 +731,7 @@ struct netxen_recv_context {
 #define NX_CAP0_LSO			NX_CAP_BIT(0, 6)
 #define NX_CAP0_JUMBO_CONTIGUOUS	NX_CAP_BIT(0, 7)
 #define NX_CAP0_LRO_CONTIGUOUS		NX_CAP_BIT(0, 8)
+#define NX_CAP0_HW_LRO			NX_CAP_BIT(0, 10)
 
 /*
  * Context state
@@ -969,6 +989,7 @@ typedef struct {
 #define NX_FW_CAPABILITY_PEXQ			(1 << 7)
 #define NX_FW_CAPABILITY_BDG			(1 << 8)
 #define NX_FW_CAPABILITY_FVLANTX		(1 << 9)
+#define NX_FW_CAPABILITY_HW_LRO			(1 << 10)
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9e04696..412d658 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -203,6 +203,8 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	cap = (NX_CAP0_LEGACY_CONTEXT | NX_CAP0_LEGACY_MN);
 	cap |= (NX_CAP0_JUMBO_CONTIGUOUS | NX_CAP0_LRO_CONTIGUOUS);
+	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
+		cap |= NX_CAP0_HW_LRO;
 
 	prq->capabilities[0] = cpu_to_le32(cap);
 	prq->host_int_crb_mode =
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 81253ab..5828287 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1242,20 +1242,31 @@ no_skb:
 
 static struct netxen_rx_buffer *
 netxen_process_rcv(struct netxen_adapter *adapter,
-		int ring, int index, int length, int cksum, int pkt_offset,
-		struct nx_host_sds_ring *sds_ring)
+		struct nx_host_sds_ring *sds_ring,
+		int ring, u64 sts_data0)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	struct nx_host_rds_ring *rds_ring = &recv_ctx->rds_rings[ring];
+	struct nx_host_rds_ring *rds_ring;
+	int index, length, cksum, pkt_offset;
 
-	if (unlikely(index > rds_ring->num_desc))
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = netxen_get_sts_refhandle(sts_data0);
+	if (unlikely(index >= rds_ring->num_desc))
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
 
+	length = netxen_get_sts_totallength(sts_data0);
+	cksum  = netxen_get_sts_status(sts_data0);
+	pkt_offset = netxen_get_sts_pkt_offset(sts_data0);
+
 	skb = netxen_process_rxbuf(adapter, rds_ring, index, cksum);
 	if (!skb)
 		return buffer;
@@ -1279,6 +1290,78 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 	return buffer;
 }
 
+#define TCP_HDR_SIZE            20
+#define TCP_TS_OPTION_SIZE      12
+#define TCP_TS_HDR_SIZE         (TCP_HDR_SIZE + TCP_TS_OPTION_SIZE)
+
+static struct netxen_rx_buffer *
+netxen_process_lro(struct netxen_adapter *adapter,
+		struct nx_host_sds_ring *sds_ring,
+		int ring, u64 sts_data0, u64 sts_data1)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct netxen_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct nx_host_rds_ring *rds_ring;
+	struct iphdr *iph;
+	struct tcphdr *th;
+	bool push, timestamp;
+	int l2_hdr_offset, l4_hdr_offset;
+	int index;
+	u16 lro_length, length, data_offset;
+	u32 seq_number;
+
+	if (unlikely(ring > adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = netxen_get_lro_sts_refhandle(sts_data0);
+	if (unlikely(index > rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	timestamp = netxen_get_lro_sts_timestamp(sts_data0);
+	lro_length = netxen_get_lro_sts_length(sts_data0);
+	l2_hdr_offset = netxen_get_lro_sts_l2_hdr_offset(sts_data0);
+	l4_hdr_offset = netxen_get_lro_sts_l4_hdr_offset(sts_data0);
+	push = netxen_get_lro_sts_push_flag(sts_data0);
+	seq_number = netxen_get_lro_sts_seq_number(sts_data1);
+
+	skb = netxen_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
+	if (!skb)
+		return buffer;
+
+	if (timestamp)
+		data_offset = l4_hdr_offset + TCP_TS_HDR_SIZE;
+	else
+		data_offset = l4_hdr_offset + TCP_HDR_SIZE;
+
+	skb_put(skb, lro_length + data_offset);
+
+	skb->truesize = (skb->len + sizeof(struct sk_buff) +
+			((unsigned long)skb->data - (unsigned long)skb->head));
+
+	skb_pull(skb, l2_hdr_offset);
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	iph = (struct iphdr *)skb->data;
+	th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+
+	length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+	iph->tot_len = htons(length);
+	iph->check = 0;
+	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+	th->psh = push;
+	th->seq = htonl(seq_number);
+
+	netif_receive_skb(skb);
+
+	return buffer;
+}
+
 #define netxen_merge_rx_buffers(list, head) \
 	do { list_splice_tail_init(list, head); } while (0);
 
@@ -1295,28 +1378,33 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 	u32 consumer = sds_ring->consumer;
 
 	int count = 0;
-	u64 sts_data;
-	int opcode, ring, index, length, cksum, pkt_offset, desc_cnt;
+	u64 sts_data0, sts_data1;
+	int opcode, ring = 0, desc_cnt;
 
 	while (count < max) {
 		desc = &sds_ring->desc_head[consumer];
-		sts_data = le64_to_cpu(desc->status_desc_data[0]);
+		sts_data0 = le64_to_cpu(desc->status_desc_data[0]);
 
-		if (!(sts_data & STATUS_OWNER_HOST))
+		if (!(sts_data0 & STATUS_OWNER_HOST))
 			break;
 
-		desc_cnt = netxen_get_sts_desc_cnt(sts_data);
-		ring   = netxen_get_sts_type(sts_data);
+		desc_cnt = netxen_get_sts_desc_cnt(sts_data0);
 
-		if (ring > RCV_RING_JUMBO)
-			goto skip;
-
-		opcode = netxen_get_sts_opcode(sts_data);
+		opcode = netxen_get_sts_opcode(sts_data0);
 
 		switch (opcode) {
 		case NETXEN_NIC_RXPKT_DESC:
 		case NETXEN_OLD_RXPKT_DESC:
 		case NETXEN_NIC_SYN_OFFLOAD:
+			ring = netxen_get_sts_type(sts_data0);
+			rxbuf = netxen_process_rcv(adapter, sds_ring,
+					ring, sts_data0);
+			break;
+		case NETXEN_NIC_LRO_DESC:
+			ring = netxen_get_lro_sts_type(sts_data0);
+			sts_data1 = le64_to_cpu(desc->status_desc_data[1]);
+			rxbuf = netxen_process_lro(adapter, sds_ring,
+					ring, sts_data0, sts_data1);
 			break;
 		case NETXEN_NIC_RESPONSE_DESC:
 			netxen_handle_fw_message(desc_cnt, consumer, sds_ring);
@@ -1326,14 +1414,6 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 
 		WARN_ON(desc_cnt > 1);
 
-		index  = netxen_get_sts_refhandle(sts_data);
-		length = netxen_get_sts_totallength(sts_data);
-		cksum  = netxen_get_sts_status(sts_data);
-		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
-
-		rxbuf = netxen_process_rcv(adapter, ring, index,
-				length, cksum, pkt_offset, sds_ring);
-
 		if (rxbuf)
 			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
 
-- 
1.6.0.2

