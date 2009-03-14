From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 4/6] netxen: remove old lro code
Date: Fri, 13 Mar 2009 17:52:04 -0700
Message-ID: <1236991926-17892-5-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47269 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762939AbZCNAwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:14 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    3 -
 drivers/net/netxen/netxen_nic_init.c |   74 +++++++++++----------------------
 2 files changed, 25 insertions(+), 52 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f00efe8..56fad22 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -766,9 +766,6 @@ struct netxen_rx_buffer {
 	u64 dma;
 	u16 ref_handle;
 	u16 state;
-	u32 lro_expected_frags;
-	u32 lro_current_frags;
-	u32 lro_length;
 };
 
 /* Board types */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d722589..1b8f79f 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -820,66 +820,37 @@ static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
 
 no_skb:
 	buffer->state = NETXEN_BUFFER_FREE;
-	buffer->lro_current_frags = 0;
-	buffer->lro_expected_frags = 0;
 	list_add_tail(&buffer->list, &rds_ring->free_list);
 	return skb;
 }
 
-static void netxen_process_rcv(struct netxen_adapter *adapter,
-		struct status_desc *desc)
+static void
+netxen_process_rcv(struct netxen_adapter *adapter,
+		int ring, int index, int length, int cksum, int pkt_offset)
 {
 	struct net_device *netdev = adapter->netdev;
-	u64 sts_data = le64_to_cpu(desc->status_desc_data);
-	int index = netxen_get_sts_refhandle(sts_data);
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = netxen_get_sts_totallength(sts_data);
-	u32 desc_ctx;
-	u16 pkt_offset = 0, cksum;
-	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_rds_ring *rds_ring = &recv_ctx->rds_rings[ring];
 
-	desc_ctx = netxen_get_sts_type(sts_data);
-	if (unlikely(desc_ctx >= adapter->max_rds_rings))
-		return;
-
-	rds_ring = &recv_ctx->rds_rings[desc_ctx];
 	if (unlikely(index > rds_ring->num_desc))
 		return;
 
 	buffer = &rds_ring->rx_buf_arr[index];
-	if (desc_ctx == RCV_RING_LRO) {
-		buffer->lro_current_frags++;
-		if (netxen_get_sts_desc_lro_last_frag(desc)) {
-			buffer->lro_expected_frags =
-			    netxen_get_sts_desc_lro_cnt(desc);
-			buffer->lro_length = length;
-		}
-		if (buffer->lro_current_frags != buffer->lro_expected_frags) {
-			return;
-		}
-	}
-
-	cksum = netxen_get_sts_status(sts_data);
 
 	skb = netxen_process_rxbuf(adapter, rds_ring, index, cksum);
 	if (!skb)
 		return;
 
-	if (desc_ctx == RCV_RING_LRO) {
-		/* True length was only available on the last pkt */
-		skb_put(skb, buffer->lro_length);
-	} else {
-		if (length > rds_ring->skb_size)
-			skb_put(skb, rds_ring->skb_size);
-		else
-			skb_put(skb, length);
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
 
-		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
-		if (pkt_offset)
-			skb_pull(skb, pkt_offset);
-	}
+
+	if (pkt_offset)
+		skb_pull(skb, pkt_offset);
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
@@ -896,9 +867,9 @@ netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
 	struct status_desc *desc;
 	u32 consumer = recv_ctx->status_rx_consumer;
-	int count = 0, ring;
+	int count = 0;
 	u64 sts_data;
-	u16 opcode;
+	int opcode, ring, index, length, cksum, pkt_offset;
 
 	while (count < max) {
 		desc = &desc_head[consumer];
@@ -907,9 +878,19 @@ netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
 		if (!(sts_data & STATUS_OWNER_HOST))
 			break;
 
+		ring   = netxen_get_sts_type(sts_data);
+		if (ring > RCV_RING_JUMBO)
+			continue;
+
 		opcode = netxen_get_sts_opcode(sts_data);
 
-		netxen_process_rcv(adapter, desc);
+		index  = netxen_get_sts_refhandle(sts_data);
+		length = netxen_get_sts_totallength(sts_data);
+		cksum  = netxen_get_sts_status(sts_data);
+		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
+
+		netxen_process_rcv(adapter, ring, index,
+				length, cksum, pkt_offset);
 
 		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
 
@@ -1019,7 +1000,6 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 	producer = rds_ring->producer;
 	head = &rds_ring->free_list;
 
-	/* We can start writing rx descriptors into the phantom memory. */
 	while (!list_empty(head)) {
 
 		skb = dev_alloc_skb(rds_ring->skb_size);
@@ -1053,10 +1033,9 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
-	/* if we did allocate buffers, then write the count to Phantom */
+
 	if (count) {
 		rds_ring->producer = producer;
-			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 				rds_ring->crb_rcv_producer,
 				(producer-1) & (rds_ring->num_desc-1));
@@ -1099,7 +1078,6 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 
 	producer = rds_ring->producer;
 	head = &rds_ring->free_list;
-	/* We can start writing rx descriptors into the phantom memory. */
 	while (!list_empty(head)) {
 
 		skb = dev_alloc_skb(rds_ring->skb_size);
@@ -1134,10 +1112,8 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
-	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
 		rds_ring->producer = producer;
-			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 			rds_ring->crb_rcv_producer,
 				(producer - 1) & (rds_ring->num_desc - 1));
-- 
1.6.0.2

