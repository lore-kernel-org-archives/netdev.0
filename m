From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/6] netxen: sanitize variable names
Date: Fri, 13 Mar 2009 17:52:03 -0700
Message-ID: <1236991926-17892-4-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47273 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762941AbZCNAwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:15 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o remove max_ prefix from ring sizes, since they don't really
  represent max possible sizes.
o cleanup naming of rx ring types (normal, jumbo, lro).
o simplify logic to choose rx ring size, gig ports get half
  rx ring of 10 gig ports.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   47 +++++++-------------
 drivers/net/netxen/netxen_nic_ctx.c     |   16 +++---
 drivers/net/netxen/netxen_nic_ethtool.c |    6 +-
 drivers/net/netxen/netxen_nic_hw.c      |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |   54 +++++++++-------------
 drivers/net/netxen/netxen_nic_main.c    |   73 +++++--------------------------
 6 files changed, 62 insertions(+), 136 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 75cb30f..f00efe8 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -79,15 +79,15 @@
 #define PHAN_VENDOR_ID 0x4040
 
 #define RCV_DESC_RINGSIZE	\
-	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
+	(sizeof(struct rcv_desc) * adapter->num_rxd)
 #define STATUS_DESC_RINGSIZE	\
-	(sizeof(struct status_desc)* adapter->max_rx_desc_count)
+	(sizeof(struct status_desc) * adapter->num_rxd)
 #define LRO_DESC_RINGSIZE	\
-	(sizeof(rcvDesc_t) * adapter->max_lro_rx_desc_count)
+	(sizeof(rcvDesc_t) * adapter->num_lro_rxd)
 #define TX_RINGSIZE	\
-	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
+	(sizeof(struct netxen_cmd_buffer) * adapter->num_txd)
 #define RCV_BUFFSIZE	\
-	(sizeof(struct netxen_rx_buffer) * rds_ring->max_rx_desc_count)
+	(sizeof(struct netxen_rx_buffer) * rds_ring->num_desc)
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_RCV_PRODUCER_OFFSET	0
@@ -190,20 +190,9 @@
 
 #define NUM_RCV_DESC_RINGS	3	/* No of Rcv Descriptor contexts */
 
-/* descriptor types */
-#define RCV_DESC_NORMAL		0x01
-#define RCV_DESC_JUMBO		0x02
-#define RCV_DESC_LRO		0x04
-#define RCV_DESC_NORMAL_CTXID	0
-#define RCV_DESC_JUMBO_CTXID	1
-#define RCV_DESC_LRO_CTXID	2
-
-#define RCV_DESC_TYPE(ID) \
-	((ID == RCV_DESC_JUMBO_CTXID)	\
-		? RCV_DESC_JUMBO	\
-		: ((ID == RCV_DESC_LRO_CTXID)	\
-			? RCV_DESC_LRO :	\
-			(RCV_DESC_NORMAL)))
+#define RCV_RING_NORMAL	0
+#define RCV_RING_JUMBO	1
+#define RCV_RING_LRO	2
 
 #define MAX_CMD_DESCRIPTORS		4096
 #define MAX_RCV_DESCRIPTORS		16384
@@ -815,8 +804,6 @@ struct netxen_hardware_context {
 	int pci_func;
 };
 
-#define RCV_RING_LRO	RCV_DESC_LRO
-
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */
 #define ETHERNET_FCS_SIZE		4
 
@@ -842,16 +829,16 @@ struct netxen_adapter_stats {
  * be one Rcv Descriptor for normal packets, one for jumbo and may be others.
  */
 struct nx_host_rds_ring {
-	u32 flags;
 	u32 producer;
-	dma_addr_t phys_addr;
 	u32 crb_rcv_producer;	/* reg offset */
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
-	u32 max_rx_desc_count;
-	u32 dma_size;
-	u32 skb_size;
 	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
 	struct list_head free_list;
+	u32 num_desc;
+	u32 dma_size;
+	u32 skb_size;
+	u32 flags;
+	dma_addr_t phys_addr;
 };
 
 /*
@@ -1244,10 +1231,10 @@ struct netxen_adapter {
 	u32 crb_addr_cmd_producer;
 	u32 crb_addr_cmd_consumer;
 
-	u32 max_tx_desc_count;
-	u32 max_rx_desc_count;
-	u32 max_jumbo_rx_desc_count;
-	u32 max_lro_rx_desc_count;
+	u32 num_txd;
+	u32 num_rxd;
+	u32 num_jumbo_rxd;
+	u32 num_lro_rxd;
 
 	int max_rds_rings;
 
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index d125dca..2e66335 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -231,7 +231,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
-		prq_rds[i].ring_size = cpu_to_le32(rds_ring->max_rx_desc_count);
+		prq_rds[i].ring_size = cpu_to_le32(rds_ring->num_desc);
 		prq_rds[i].ring_kind = cpu_to_le32(i);
 		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
 	}
@@ -241,7 +241,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	prq_sds[0].host_phys_addr =
 		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-	prq_sds[0].ring_size = cpu_to_le32(adapter->max_rx_desc_count);
+	prq_sds[0].ring_size = cpu_to_le32(adapter->num_rxd);
 	/* only one msix vector for now */
 	prq_sds[0].msi_index = cpu_to_le16(0);
 
@@ -362,7 +362,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	prq_cds->host_phys_addr =
 		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
 
-	prq_cds->ring_size = cpu_to_le32(adapter->max_tx_desc_count);
+	prq_cds->ring_size = cpu_to_le32(adapter->num_txd);
 
 	phys_addr = rq_phys_addr;
 	err = netxen_issue_cmd(adapter,
@@ -494,7 +494,7 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	adapter->ctx_desc->cmd_ring_addr =
 		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
 	adapter->ctx_desc->cmd_ring_size =
-		cpu_to_le32(adapter->max_tx_desc_count);
+		cpu_to_le32(adapter->num_txd);
 
 	recv_ctx = &adapter->recv_ctx;
 
@@ -504,12 +504,12 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
 			cpu_to_le64(rds_ring->phys_addr);
 		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-			cpu_to_le32(rds_ring->max_rx_desc_count);
+			cpu_to_le32(rds_ring->num_desc);
 	}
 	adapter->ctx_desc->sts_ring_addr =
 		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
 	adapter->ctx_desc->sts_ring_size =
-		cpu_to_le32(adapter->max_rx_desc_count);
+		cpu_to_le32(adapter->num_rxd);
 
 	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
 			lower32(adapter->ctx_desc_phys_addr));
@@ -562,7 +562,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	/* cmd desc ring */
 	addr = pci_alloc_consistent(adapter->pdev,
 			sizeof(struct cmd_desc_type0) *
-			adapter->max_tx_desc_count,
+			adapter->num_txd,
 			&hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
@@ -669,7 +669,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 	if (adapter->ahw.cmd_desc_head != NULL) {
 		pci_free_consistent(adapter->pdev,
 				sizeof(struct cmd_desc_type0) *
-				adapter->max_tx_desc_count,
+				adapter->num_txd,
 				adapter->ahw.cmd_desc_head,
 				adapter->ahw.cmd_desc_phys_addr);
 		adapter->ahw.cmd_desc_head = NULL;
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 8b4bdfd..a677ff8 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -477,10 +477,10 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 	ring->rx_pending = 0;
 	ring->rx_jumbo_pending = 0;
 	ring->rx_pending += adapter->recv_ctx.
-		rds_rings[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
+		rds_rings[RCV_RING_NORMAL].num_desc;
 	ring->rx_jumbo_pending += adapter->recv_ctx.
-		rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
-	ring->tx_pending = adapter->max_tx_desc_count;
+		rds_rings[RCV_RING_JUMBO].num_desc;
+	ring->tx_pending = adapter->num_txd;
 
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c8faa53..cea7300 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -515,7 +515,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
 
 		producer = get_next_index(producer,
-				adapter->max_tx_desc_count);
+				adapter->num_txd);
 		i++;
 
 	} while (i != nr_elements);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 120b480..d722589 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -153,7 +153,7 @@ void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
-		for (i = 0; i < rds_ring->max_rx_desc_count; ++i) {
+		for (i = 0; i < rds_ring->num_desc; ++i) {
 			rx_buf = &(rds_ring->rx_buf_arr[i]);
 			if (rx_buf->state == NETXEN_BUFFER_FREE)
 				continue;
@@ -174,7 +174,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	int i, j;
 
 	cmd_buf = adapter->cmd_buf_arr;
-	for (i = 0; i < adapter->max_tx_desc_count; i++) {
+	for (i = 0; i < adapter->num_txd; i++) {
 		buffrag = cmd_buf->frag_array;
 		if (buffrag->dma) {
 			pci_unmap_single(adapter->pdev, buffrag->dma,
@@ -190,7 +190,6 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 				buffrag->dma = 0ULL;
 			}
 		}
-		/* Free the skb we received in netxen_nic_xmit_frame */
 		if (cmd_buf->skb) {
 			dev_kfree_skb_any(cmd_buf->skb);
 			cmd_buf->skb = NULL;
@@ -241,11 +240,9 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
-		switch (RCV_DESC_TYPE(ring)) {
-		case RCV_DESC_NORMAL:
-			rds_ring->max_rx_desc_count =
-				adapter->max_rx_desc_count;
-			rds_ring->flags = RCV_DESC_NORMAL;
+		switch (ring) {
+		case RCV_RING_NORMAL:
+			rds_ring->num_desc = adapter->num_rxd;
 			if (adapter->ahw.cut_through) {
 				rds_ring->dma_size =
 					NX_CT_DEFAULT_RX_BUF_LEN;
@@ -258,10 +255,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			}
 			break;
 
-		case RCV_DESC_JUMBO:
-			rds_ring->max_rx_desc_count =
-				adapter->max_jumbo_rx_desc_count;
-			rds_ring->flags = RCV_DESC_JUMBO;
+		case RCV_RING_JUMBO:
+			rds_ring->num_desc = adapter->num_jumbo_rxd;
 			if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 				rds_ring->dma_size =
 					NX_P3_RX_JUMBO_BUF_MAX_LEN;
@@ -273,9 +268,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			break;
 
 		case RCV_RING_LRO:
-			rds_ring->max_rx_desc_count =
-				adapter->max_lro_rx_desc_count;
-			rds_ring->flags = RCV_DESC_LRO;
+			rds_ring->num_desc = adapter->num_lro_rxd;
 			rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
 			rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
 			break;
@@ -296,7 +289,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 		 * Now go through all of them, set reference handles
 		 * and put them in the queues.
 		 */
-		num_rx_bufs = rds_ring->max_rx_desc_count;
+		num_rx_bufs = rds_ring->num_desc;
 		rx_buf = rds_ring->rx_buf_arr;
 		for (i = 0; i < num_rx_bufs; i++) {
 			list_add_tail(&rx_buf->list,
@@ -848,16 +841,15 @@ static void netxen_process_rcv(struct netxen_adapter *adapter,
 	struct nx_host_rds_ring *rds_ring;
 
 	desc_ctx = netxen_get_sts_type(sts_data);
-	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
+	if (unlikely(desc_ctx >= adapter->max_rds_rings))
 		return;
-	}
 
 	rds_ring = &recv_ctx->rds_rings[desc_ctx];
-	if (unlikely(index > rds_ring->max_rx_desc_count)) {
+	if (unlikely(index > rds_ring->num_desc))
 		return;
-	}
+
 	buffer = &rds_ring->rx_buf_arr[index];
-	if (desc_ctx == RCV_DESC_LRO_CTXID) {
+	if (desc_ctx == RCV_RING_LRO) {
 		buffer->lro_current_frags++;
 		if (netxen_get_sts_desc_lro_last_frag(desc)) {
 			buffer->lro_expected_frags =
@@ -875,7 +867,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter,
 	if (!skb)
 		return;
 
-	if (desc_ctx == RCV_DESC_LRO_CTXID) {
+	if (desc_ctx == RCV_RING_LRO) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
 	} else {
@@ -921,8 +913,7 @@ netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
 
 		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
 
-		consumer = get_next_index(consumer,
-				adapter->max_rx_desc_count);
+		consumer = get_next_index(consumer, adapter->num_rxd);
 		count++;
 	}
 
@@ -973,7 +964,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 		}
 
 		last_consumer = get_next_index(last_consumer,
-					       adapter->max_tx_desc_count);
+					       adapter->num_txd);
 		if (++count >= MAX_STATUS_HANDLE)
 			break;
 	}
@@ -1060,7 +1051,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 
-		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
+		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
@@ -1068,7 +1059,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 				rds_ring->crb_rcv_producer,
-				(producer-1) & (rds_ring->max_rx_desc_count-1));
+				(producer-1) & (rds_ring->num_desc-1));
 
 		if (adapter->fw_major < 4) {
 			/*
@@ -1079,9 +1070,8 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 			netxen_set_msg_peg_id(msg, NETXEN_RCV_PEG_DB_ID);
 			netxen_set_msg_privid(msg);
 			netxen_set_msg_count(msg,
-					     ((producer -
-					       1) & (rds_ring->
-						     max_rx_desc_count - 1)));
+					     ((producer - 1) &
+					      (rds_ring->num_desc - 1)));
 			netxen_set_msg_ctxid(msg, adapter->portnum);
 			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
 			writel(msg,
@@ -1141,7 +1131,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 
-		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
+		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
 	/* if we did allocate buffers, then write the count to Phantom */
@@ -1150,7 +1140,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 			rds_ring->crb_rcv_producer,
-				(producer-1) & (rds_ring->max_rx_desc_count-1));
+				(producer - 1) & (rds_ring->num_desc - 1));
 			wmb();
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 555b459..00eaeee 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -212,62 +212,19 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 
 static void netxen_check_options(struct netxen_adapter *adapter)
 {
-	switch (adapter->ahw.board_type) {
-	case NETXEN_BRDTYPE_P3_HMEZ:
-	case NETXEN_BRDTYPE_P3_XG_LOM:
-	case NETXEN_BRDTYPE_P3_10G_CX4:
-	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
-	case NETXEN_BRDTYPE_P3_IMEZ:
-	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
-	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
-	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
-	case NETXEN_BRDTYPE_P3_10G_XFP:
-	case NETXEN_BRDTYPE_P3_10000_BASE_T:
-		adapter->msix_supported = !!use_msi_x;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
-		break;
-
-	case NETXEN_BRDTYPE_P2_SB31_10G:
-	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
-	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
-		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
-		break;
+	if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
+		adapter->num_rxd = MAX_RCV_DESCRIPTORS_10G;
+	else if (adapter->ahw.port_type == NETXEN_NIC_GBE)
+		adapter->num_rxd = MAX_RCV_DESCRIPTORS_1G;
 
-	case NETXEN_BRDTYPE_P3_REF_QG:
-	case NETXEN_BRDTYPE_P3_4_GB:
-	case NETXEN_BRDTYPE_P3_4_GB_MM:
-		adapter->msix_supported = !!use_msi_x;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
-		break;
-
-	case NETXEN_BRDTYPE_P2_SB35_4G:
-	case NETXEN_BRDTYPE_P2_SB31_2G:
-		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
-		break;
-
-	case NETXEN_BRDTYPE_P3_10G_TP:
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		adapter->msix_supported = !!use_msi_x;
-		if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
-			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
-		else
-			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
-		break;
-
-	default:
+	else
 		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
-
-		printk(KERN_WARNING "Unknown board type(0x%x)\n",
-				adapter->ahw.board_type);
-		break;
-	}
 
-	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS_HOST;
-	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
-	adapter->max_lro_rx_desc_count = MAX_LRO_RCV_DESCRIPTORS;
+	adapter->num_txd = MAX_CMD_DESCRIPTORS_HOST;
+	adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS;
+	adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
 
 	adapter->max_possible_rss_rings = 1;
 	return;
@@ -983,12 +940,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	/*
-	 * This call will setup various max rx/tx counts.
-	 * It must be done before any buffer/ring allocations.
-	 */
-	netxen_check_options(adapter);
-
 	err = netxen_start_firmware(adapter);
 	if (err)
 		goto err_out_iounmap;
@@ -1008,9 +959,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			adapter->physical_port = i;
 	}
 
-	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
-
-	netxen_set_msix_bit(pdev, 0);
+	netxen_check_options(adapter);
 
 	netxen_setup_intr(adapter);
 
@@ -1307,7 +1256,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	u32 producer, consumer;
 	int frag_count, no_of_desc;
-	u32 num_txd = adapter->max_tx_desc_count;
+	u32 num_txd = adapter->num_txd;
 	bool is_tso = false;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
-- 
1.6.0.2

