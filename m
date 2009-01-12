From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 10/13] netxen: misc code cleanup
Date: Mon, 12 Jan 2009 11:23:08 -0800
Message-ID: <1231788191-23794-11-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56012 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756041AbZALTew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Remove unused macros.
o Use consistent naming for ring.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   57 +++++++++---------------------
 drivers/net/netxen/netxen_nic_ctx.c     |   16 ++++----
 drivers/net/netxen/netxen_nic_ethtool.c |   11 ++++--
 drivers/net/netxen/netxen_nic_hw.c      |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |   51 +++++++++++++--------------
 drivers/net/netxen/netxen_nic_main.c    |   22 ++++++------
 6 files changed, 68 insertions(+), 91 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2e40099..42bf202 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -78,15 +78,15 @@
 #define PHAN_VENDOR_ID 0x4040
 
 #define RCV_DESC_RINGSIZE	\
-	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
+	(sizeof(struct rcv_desc) * adapter->rx_desc_count)
 #define STATUS_DESC_RINGSIZE	\
-	(sizeof(struct status_desc)* adapter->max_rx_desc_count)
+	(sizeof(struct status_desc)* adapter->rx_desc_count)
 #define LRO_DESC_RINGSIZE	\
-	(sizeof(rcvDesc_t) * adapter->max_lro_rx_desc_count)
+	(sizeof(rcvDesc_t) * adapter->lro_rx_desc_count)
 #define TX_RINGSIZE	\
-	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
+	(sizeof(struct netxen_cmd_buffer) * adapter->tx_desc_count)
 #define RCV_BUFFSIZE	\
-	(sizeof(struct netxen_rx_buffer) * rds_ring->max_rx_desc_count)
+	(sizeof(struct netxen_rx_buffer) * rds_ring->rx_desc_count)
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_NETDEV_STATUS		0x1
@@ -190,37 +190,16 @@
 
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
-
-#define MAX_CMD_DESCRIPTORS		4096
+#define RCV_RING_NORMAL		0
+#define RCV_RING_JUMBO		1
+#define RCV_RING_LRO		2
+
 #define MAX_RCV_DESCRIPTORS		16384
-#define MAX_CMD_DESCRIPTORS_HOST	(MAX_CMD_DESCRIPTORS / 4)
-#define MAX_RCV_DESCRIPTORS_1G		(MAX_RCV_DESCRIPTORS / 4)
+#define MAX_CMD_DESCRIPTORS_HOST	1024
+#define MAX_RCV_DESCRIPTORS_1G		4096
 #define MAX_RCV_DESCRIPTORS_10G		8192
 #define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		64
-#define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
-#define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
-#define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
-#define MAX_RCVSTATUS_DESC	MAX_RCV_DESCRIPTORS
-#define MAX_EPG_DESCRIPTORS	(MAX_CMD_DESCRIPTORS * 8)
-#define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS + \
-				 MAX_LRO_RCV_DESCRIPTORS)
-#define MIN_TX_COUNT	4096
-#define MIN_RX_COUNT	4096
 #define NETXEN_CTX_SIGNATURE	0xdee0
 #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
 #define MAX_FRAME_SIZE	0x10000	/* 64K MAX size for LSO */
@@ -832,8 +811,6 @@ struct netxen_hardware_context {
 	int pci_func;
 };
 
-#define RCV_RING_LRO	RCV_DESC_LRO
-
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */
 #define ETHERNET_FCS_SIZE		4
 
@@ -862,9 +839,9 @@ struct nx_host_rds_ring {
 	u32 flags;
 	u32 producer;
 	dma_addr_t phys_addr;
-	u32 crb_rcv_producer;	/* reg offset */
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
-	u32 max_rx_desc_count;
+	u32 crb_rcv_producer;	/* reg offset */
+	u32 rx_desc_count;
 	u32 dma_size;
 	u32 skb_size;
 	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
@@ -1263,10 +1240,10 @@ struct netxen_adapter {
 	u32 crb_addr_cmd_producer;
 	u32 crb_addr_cmd_consumer;
 
-	u32 max_tx_desc_count;
-	u32 max_rx_desc_count;
-	u32 max_jumbo_rx_desc_count;
-	u32 max_lro_rx_desc_count;
+	u32 tx_desc_count;
+	u32 rx_desc_count;
+	u32 jumbo_rx_desc_count;
+	u32 lro_rx_desc_count;
 
 	int max_rds_rings;
 
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 765d79e..f112816 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -239,7 +239,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
-		prq_rds[i].ring_size = cpu_to_le32(rds_ring->max_rx_desc_count);
+		prq_rds[i].ring_size = cpu_to_le32(rds_ring->rx_desc_count);
 		prq_rds[i].ring_kind = cpu_to_le32(i);
 		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
 	}
@@ -249,7 +249,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	prq_sds[0].host_phys_addr =
 		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-	prq_sds[0].ring_size = cpu_to_le32(adapter->max_rx_desc_count);
+	prq_sds[0].ring_size = cpu_to_le32(adapter->rx_desc_count);
 	/* only one msix vector for now */
 	prq_sds[0].msi_index = cpu_to_le16(0);
 
@@ -370,7 +370,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	prq_cds->host_phys_addr =
 		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
 
-	prq_cds->ring_size = cpu_to_le32(adapter->max_tx_desc_count);
+	prq_cds->ring_size = cpu_to_le32(adapter->tx_desc_count);
 
 	phys_addr = rq_phys_addr;
 	err = netxen_issue_cmd(adapter,
@@ -502,7 +502,7 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	adapter->ctx_desc->cmd_ring_addr =
 		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
 	adapter->ctx_desc->cmd_ring_size =
-		cpu_to_le32(adapter->max_tx_desc_count);
+		cpu_to_le32(adapter->tx_desc_count);
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 		recv_ctx = &adapter->recv_ctx[ctx];
@@ -513,12 +513,12 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
 				cpu_to_le64(rds_ring->phys_addr);
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-				cpu_to_le32(rds_ring->max_rx_desc_count);
+				cpu_to_le32(rds_ring->rx_desc_count);
 		}
 		adapter->ctx_desc->sts_ring_addr =
 			cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
 		adapter->ctx_desc->sts_ring_size =
-			cpu_to_le32(adapter->max_rx_desc_count);
+			cpu_to_le32(adapter->rx_desc_count);
 	}
 
 	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
@@ -572,7 +572,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	/* cmd desc ring */
 	addr = pci_alloc_consistent(adapter->pdev,
 			sizeof(struct cmd_desc_type0) *
-			adapter->max_tx_desc_count,
+			adapter->tx_desc_count,
 			&hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
@@ -681,7 +681,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 	if (adapter->ahw.cmd_desc_head != NULL) {
 		pci_free_consistent(adapter->pdev,
 				sizeof(struct cmd_desc_type0) *
-				adapter->max_tx_desc_count,
+				adapter->tx_desc_count,
 				adapter->ahw.cmd_desc_head,
 				adapter->ahw.cmd_desc_phys_addr);
 		adapter->ahw.cmd_desc_head = NULL;
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index b403f82..daaa655 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -555,13 +555,16 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 	ring->rx_jumbo_pending = 0;
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
 		ring->rx_pending += adapter->recv_ctx[i].
-		    rds_rings[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
+		    rds_rings[RCV_RING_NORMAL].rx_desc_count;
 		ring->rx_jumbo_pending += adapter->recv_ctx[i].
-		    rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
+		    rds_rings[RCV_RING_JUMBO].rx_desc_count;
 	}
-	ring->tx_pending = adapter->max_tx_desc_count;
+	ring->tx_pending = adapter->tx_desc_count;
 
-	ring->rx_max_pending = MAX_RCV_DESCRIPTORS;
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
+	else
+		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_10G;
 	ring->tx_max_pending = MAX_CMD_DESCRIPTORS_HOST;
 	ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS;
 	ring->rx_mini_max_pending = 0;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index e8c7005..6ad189f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -518,7 +518,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
 
 		producer = get_next_index(producer,
-				adapter->max_tx_desc_count);
+				adapter->tx_desc_count);
 		i++;
 
 	} while (i != nr_elements);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 476e1a2..6e6d38e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -164,7 +164,7 @@ void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 		recv_ctx = &adapter->recv_ctx[ctxid];
 		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 			rds_ring = &recv_ctx->rds_rings[ring];
-			for (i = 0; i < rds_ring->max_rx_desc_count; ++i) {
+			for (i = 0; i < rds_ring->rx_desc_count; ++i) {
 				rx_buf = &(rds_ring->rx_buf_arr[i]);
 				if (rx_buf->state == NETXEN_BUFFER_FREE)
 					continue;
@@ -186,7 +186,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	int i, j;
 
 	cmd_buf = adapter->cmd_buf_arr;
-	for (i = 0; i < adapter->max_tx_desc_count; i++) {
+	for (i = 0; i < adapter->tx_desc_count; i++) {
 		buffrag = cmd_buf->frag_array;
 		if (buffrag->dma) {
 			pci_unmap_single(adapter->pdev, buffrag->dma,
@@ -255,11 +255,10 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 		recv_ctx = &adapter->recv_ctx[ctx];
 		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 			rds_ring = &recv_ctx->rds_rings[ring];
-			switch (RCV_DESC_TYPE(ring)) {
-			case RCV_DESC_NORMAL:
-				rds_ring->max_rx_desc_count =
-					adapter->max_rx_desc_count;
-				rds_ring->flags = RCV_DESC_NORMAL;
+			switch (ring) {
+			case RCV_RING_NORMAL:
+				rds_ring->rx_desc_count =
+					adapter->rx_desc_count;
 				if (adapter->ahw.cut_through) {
 					rds_ring->dma_size =
 						NX_CT_DEFAULT_RX_BUF_LEN;
@@ -272,10 +271,9 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				}
 				break;
 
-			case RCV_DESC_JUMBO:
-				rds_ring->max_rx_desc_count =
-					adapter->max_jumbo_rx_desc_count;
-				rds_ring->flags = RCV_DESC_JUMBO;
+			case RCV_RING_JUMBO:
+				rds_ring->rx_desc_count =
+					adapter->jumbo_rx_desc_count;
 				if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 					rds_ring->dma_size =
 						NX_P3_RX_JUMBO_BUF_MAX_LEN;
@@ -287,9 +285,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				break;
 
 			case RCV_RING_LRO:
-				rds_ring->max_rx_desc_count =
-					adapter->max_lro_rx_desc_count;
-				rds_ring->flags = RCV_DESC_LRO;
+				rds_ring->rx_desc_count =
+					adapter->lro_rx_desc_count;
 				rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
 				rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
 				break;
@@ -310,7 +307,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			 * Now go through all of them, set reference handles
 			 * and put them in the queues.
 			 */
-			num_rx_bufs = rds_ring->max_rx_desc_count;
+			num_rx_bufs = rds_ring->rx_desc_count;
 			rx_buf = rds_ring->rx_buf_arr;
 			for (i = 0; i < num_rx_bufs; i++) {
 				list_add_tail(&rx_buf->list,
@@ -1222,13 +1219,13 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	}
 
 	rds_ring = &recv_ctx->rds_rings[desc_ctx];
-	if (unlikely(index > rds_ring->max_rx_desc_count)) {
+	if (unlikely(index > rds_ring->rx_desc_count)) {
 		DPRINTK(ERR, "Got a buffer index:%x Max is %x\n",
-			index, rds_ring->max_rx_desc_count);
+			index, rds_ring->rx_desc_count);
 		return;
 	}
 	buffer = &rds_ring->rx_buf_arr[index];
-	if (desc_ctx == RCV_DESC_LRO_CTXID) {
+	if (desc_ctx == RCV_RING_LRO) {
 		buffer->lro_current_frags++;
 		if (netxen_get_sts_desc_lro_last_frag(desc)) {
 			buffer->lro_expected_frags =
@@ -1254,7 +1251,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	if (!skb)
 		return;
 
-	if (desc_ctx == RCV_DESC_LRO_CTXID) {
+	if (desc_ctx == RCV_RING_LRO) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
 	} else {
@@ -1319,7 +1316,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		if (opcode == NETXEN_NIC_RXPKT_DESC) {
 			if (desc->nr_frags) {
 				consumer = get_next_index(consumer,
-						adapter->max_rx_desc_count);
+						adapter->rx_desc_count);
 				frag_desc = &desc_head[consumer];
 				netxen_set_sts_owner(frag_desc,
 						STATUS_OWNER_PHANTOM);
@@ -1331,7 +1328,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 
 		consumer = get_next_index(consumer,
-				adapter->max_rx_desc_count);
+				adapter->rx_desc_count);
 		count++;
 	}
 	for (ring = 0; ring < adapter->max_rds_rings; ring++)
@@ -1383,7 +1380,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 		}
 
 		last_consumer = get_next_index(last_consumer,
-					       adapter->max_tx_desc_count);
+					       adapter->tx_desc_count);
 		if (++count >= MAX_STATUS_HANDLE)
 			break;
 	}
@@ -1471,7 +1468,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 
-		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
+		producer = get_next_index(producer, rds_ring->rx_desc_count);
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
@@ -1479,7 +1476,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 				rds_ring->crb_rcv_producer,
-				(producer-1) & (rds_ring->max_rx_desc_count-1));
+				(producer-1) & (rds_ring->rx_desc_count-1));
 
 		if (adapter->fw_major < 4) {
 			/*
@@ -1492,7 +1489,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 			netxen_set_msg_count(msg,
 					     ((producer -
 					       1) & (rds_ring->
-						     max_rx_desc_count - 1)));
+						     rx_desc_count - 1)));
 			netxen_set_msg_ctxid(msg, adapter->portnum);
 			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
 			writel(msg,
@@ -1552,7 +1549,7 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 
-		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
+		producer = get_next_index(producer, rds_ring->rx_desc_count);
 	}
 
 	/* if we did allocate buffers, then write the count to Phantom */
@@ -1561,7 +1558,7 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 			rds_ring->crb_rcv_producer,
-				(producer-1) & (rds_ring->max_rx_desc_count-1));
+				(producer-1) & (rds_ring->rx_desc_count-1));
 			wmb();
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 038798d..f413494 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -228,7 +228,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
 		adapter->msix_supported = !!use_msi_x;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+		adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		break;
 
 	case NETXEN_BRDTYPE_P2_SB31_10G:
@@ -236,42 +236,42 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+		adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		break;
 
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
 		adapter->msix_supported = !!use_msi_x;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+		adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 		break;
 
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 	case NETXEN_BRDTYPE_P2_SB31_2G:
 		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+		adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 		break;
 
 	case NETXEN_BRDTYPE_P3_10G_TROOPER:
 		adapter->msix_supported = !!use_msi_x;
 		if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
-			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+			adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		else
-			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+			adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 		break;
 
 	default:
 		adapter->msix_supported = 0;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+		adapter->rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 
 		printk(KERN_WARNING "Unknown board type(0x%x)\n",
 				adapter->ahw.boardcfg.board_type);
 		break;
 	}
 
-	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS_HOST;
-	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
-	adapter->max_lro_rx_desc_count = MAX_LRO_RCV_DESCRIPTORS;
+	adapter->tx_desc_count = MAX_CMD_DESCRIPTORS_HOST;
+	adapter->jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
+	adapter->lro_rx_desc_count = MAX_LRO_RCV_DESCRIPTORS;
 
 	adapter->max_possible_rss_rings = 1;
 	return;
@@ -1227,7 +1227,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	u32 producer, consumer;
 	int frag_count, no_of_desc;
-	u32 num_txd = adapter->max_tx_desc_count;
+	u32 num_txd = adapter->tx_desc_count;
 	bool is_tso = false;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
-- 
1.6.0.2

