From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 4/5] netxen: cleanup superfluous multi-context code
Date: Mon,  9 Mar 2009 11:50:55 -0700
Message-ID: <1236624656-2082-4-git-send-email-dhananjay@netxen.com>
References: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43663 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754201AbZCISvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:51:04 -0400
In-Reply-To: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAX_RCV_CTX was set to 1, there's only rx context per
PCI function.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    7 +-
 drivers/net/netxen/netxen_nic_ctx.c     |  130 +++++++++----------
 drivers/net/netxen/netxen_nic_ethtool.c |   11 +-
 drivers/net/netxen/netxen_nic_hdr.h     |    6 -
 drivers/net/netxen/netxen_nic_init.c    |  213 +++++++++++++++----------------
 drivers/net/netxen/netxen_nic_main.c    |   30 +----
 6 files changed, 178 insertions(+), 219 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1e9bd1d..2bb27d2 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1280,7 +1280,7 @@ struct netxen_adapter {
 	 * Receive instances. These can be either one per port,
 	 * or one per peg, etc.
 	 */
-	struct netxen_recv_context recv_ctx[MAX_RCV_CTX];
+	struct netxen_recv_context recv_ctx;
 
 	int is_up;
 	struct netxen_dummy_dma dummy_dma;
@@ -1464,10 +1464,9 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
 int netxen_init_firmware(struct netxen_adapter *adapter);
 void netxen_nic_clear_stats(struct netxen_adapter *adapter);
 void netxen_watchdog_task(struct work_struct *work);
-void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
-			    u32 ringid);
+void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid);
 int netxen_process_cmd_ring(struct netxen_adapter *adapter);
-u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
+int netxen_process_rcv_ring(struct netxen_adapter *adapter, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 3e43706..d125dca 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -141,7 +141,7 @@ int
 nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu)
 {
 	u32 rcode = NX_RCODE_SUCCESS;
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	if (recv_ctx->state == NX_HOST_CTX_STATE_ACTIVE)
 		rcode = netxen_issue_cmd(adapter,
@@ -179,7 +179,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	int err;
 
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	/* only one sds ring for now */
 	nrds_rings = adapter->max_rds_rings;
@@ -292,7 +292,7 @@ out_free_rq:
 static void
 nx_fw_cmd_destroy_rx_ctx(struct netxen_adapter *adapter)
 {
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	if (netxen_issue_cmd(adapter,
 			adapter->ahw.pci_func,
@@ -488,7 +488,7 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
-	int ctx, ring;
+	int ring;
 	int func_id = adapter->portnum;
 
 	adapter->ctx_desc->cmd_ring_addr =
@@ -496,22 +496,20 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	adapter->ctx_desc->cmd_ring_size =
 		cpu_to_le32(adapter->max_tx_desc_count);
 
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		recv_ctx = &adapter->recv_ctx[ctx];
+	recv_ctx = &adapter->recv_ctx;
 
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			rds_ring = &recv_ctx->rds_rings[ring];
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
 
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
-				cpu_to_le64(rds_ring->phys_addr);
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-				cpu_to_le32(rds_ring->max_rx_desc_count);
-		}
-		adapter->ctx_desc->sts_ring_addr =
-			cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-		adapter->ctx_desc->sts_ring_size =
-			cpu_to_le32(adapter->max_rx_desc_count);
+		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
+			cpu_to_le64(rds_ring->phys_addr);
+		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
+			cpu_to_le32(rds_ring->max_rx_desc_count);
 	}
+	adapter->ctx_desc->sts_ring_addr =
+		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
+	adapter->ctx_desc->sts_ring_size =
+		cpu_to_le32(adapter->max_rx_desc_count);
 
 	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
 			lower32(adapter->ctx_desc_phys_addr));
@@ -533,7 +531,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	u32 state = 0;
 	void *addr;
 	int err = 0;
-	int ctx, ring;
+	int ring;
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 
@@ -575,48 +573,46 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
 
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			/* rx desc ring */
-			rds_ring = &recv_ctx->rds_rings[ring];
-			addr = pci_alloc_consistent(adapter->pdev,
-					RCV_DESC_RINGSIZE,
-					&rds_ring->phys_addr);
-			if (addr == NULL) {
-				printk(KERN_ERR "%s failed to allocate rx "
-					"desc ring[%d]\n",
-					netxen_nic_driver_name, ring);
-				err = -ENOMEM;
-				goto err_out_free;
-			}
-			rds_ring->desc_head = (struct rcv_desc *)addr;
-
-			if (adapter->fw_major < 4)
-				rds_ring->crb_rcv_producer =
-					recv_crb_registers[adapter->portnum].
-					crb_rcv_producer[ring];
-		}
+	recv_ctx = &adapter->recv_ctx;
 
-		/* status desc ring */
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		/* rx desc ring */
+		rds_ring = &recv_ctx->rds_rings[ring];
 		addr = pci_alloc_consistent(adapter->pdev,
-				STATUS_DESC_RINGSIZE,
-				&recv_ctx->rcv_status_desc_phys_addr);
+				RCV_DESC_RINGSIZE,
+				&rds_ring->phys_addr);
 		if (addr == NULL) {
-			printk(KERN_ERR "%s failed to allocate sts desc ring\n",
-					netxen_nic_driver_name);
+			printk(KERN_ERR "%s failed to allocate rx "
+				"desc ring[%d]\n",
+				netxen_nic_driver_name, ring);
 			err = -ENOMEM;
 			goto err_out_free;
 		}
-		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
+		rds_ring->desc_head = (struct rcv_desc *)addr;
 
 		if (adapter->fw_major < 4)
-			recv_ctx->crb_sts_consumer =
+			rds_ring->crb_rcv_producer =
 				recv_crb_registers[adapter->portnum].
-				crb_sts_consumer;
+				crb_rcv_producer[ring];
 	}
 
+	/* status desc ring */
+	addr = pci_alloc_consistent(adapter->pdev,
+			STATUS_DESC_RINGSIZE,
+			&recv_ctx->rcv_status_desc_phys_addr);
+	if (addr == NULL) {
+		printk(KERN_ERR "%s failed to allocate sts desc ring\n",
+				netxen_nic_driver_name);
+		err = -ENOMEM;
+		goto err_out_free;
+	}
+	recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
+
+	if (adapter->fw_major < 4)
+		recv_ctx->crb_sts_consumer =
+			recv_crb_registers[adapter->portnum].
+			crb_sts_consumer;
+
 	if (adapter->fw_major >= 4) {
 		adapter->intr_scheme = INTR_SCHEME_PERPORT;
 		adapter->msi_mode = MSI_MODE_MULTIFUNC;
@@ -654,7 +650,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
-	int ctx, ring;
+	int ring;
 
 	if (adapter->fw_major >= 4) {
 		nx_fw_cmd_destroy_tx_ctx(adapter);
@@ -679,27 +675,25 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 		adapter->ahw.cmd_desc_head = NULL;
 	}
 
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			rds_ring = &recv_ctx->rds_rings[ring];
-
-			if (rds_ring->desc_head != NULL) {
-				pci_free_consistent(adapter->pdev,
-						RCV_DESC_RINGSIZE,
-						rds_ring->desc_head,
-						rds_ring->phys_addr);
-				rds_ring->desc_head = NULL;
-			}
-		}
+	recv_ctx = &adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
 
-		if (recv_ctx->rcv_status_desc_head != NULL) {
+		if (rds_ring->desc_head != NULL) {
 			pci_free_consistent(adapter->pdev,
-					STATUS_DESC_RINGSIZE,
-					recv_ctx->rcv_status_desc_head,
-					recv_ctx->rcv_status_desc_phys_addr);
-			recv_ctx->rcv_status_desc_head = NULL;
+					RCV_DESC_RINGSIZE,
+					rds_ring->desc_head,
+					rds_ring->phys_addr);
+			rds_ring->desc_head = NULL;
 		}
 	}
+
+	if (recv_ctx->rcv_status_desc_head != NULL) {
+		pci_free_consistent(adapter->pdev,
+				STATUS_DESC_RINGSIZE,
+				recv_ctx->rcv_status_desc_head,
+				recv_ctx->rcv_status_desc_phys_addr);
+		recv_ctx->rcv_status_desc_head = NULL;
+	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6b25121..f811880 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -474,16 +474,13 @@ static void
 netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	int i;
 
 	ring->rx_pending = 0;
 	ring->rx_jumbo_pending = 0;
-	for (i = 0; i < MAX_RCV_CTX; ++i) {
-		ring->rx_pending += adapter->recv_ctx[i].
-		    rds_rings[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
-		ring->rx_jumbo_pending += adapter->recv_ctx[i].
-		    rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
-	}
+	ring->rx_pending += adapter->recv_ctx.
+		rds_rings[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
+	ring->rx_jumbo_pending += adapter->recv_ctx.
+		rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
 	ring->tx_pending = adapter->max_tx_desc_count;
 
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index e589d4b..016c621 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -363,12 +363,6 @@ enum {
 #define NETXEN_HW_CRB_HUB_AGT_ADR_LPC	\
 	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_LPC_CRB_AGT_ADR)
 
-/*
- * MAX_RCV_CTX : The number of receive contexts that are available on
- * the phantom.
- */
-#define MAX_RCV_CTX			1
-
 #define NETXEN_SRE_INT_STATUS		(NETXEN_CRB_SRE + 0x00034)
 #define NETXEN_SRE_PBI_ACTIVE_STATUS	(NETXEN_CRB_SRE + 0x01014)
 #define NETXEN_SRE_L1RE_CTL		(NETXEN_CRB_SRE + 0x03000)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 72aba63..bd5e0d6 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -49,8 +49,8 @@ static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 
 #define NETXEN_NIC_XDMA_RESET 0x8000ff
 
-static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
-					uint32_t ctx, uint32_t ringid);
+static void
+netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid);
 
 static void crb_addr_transform_setup(void)
 {
@@ -148,23 +148,21 @@ void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct netxen_rx_buffer *rx_buf;
-	int i, ctxid, ring;
-
-	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
-		recv_ctx = &adapter->recv_ctx[ctxid];
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			rds_ring = &recv_ctx->rds_rings[ring];
-			for (i = 0; i < rds_ring->max_rx_desc_count; ++i) {
-				rx_buf = &(rds_ring->rx_buf_arr[i]);
-				if (rx_buf->state == NETXEN_BUFFER_FREE)
-					continue;
-				pci_unmap_single(adapter->pdev,
-						rx_buf->dma,
-						rds_ring->dma_size,
-						PCI_DMA_FROMDEVICE);
-				if (rx_buf->skb != NULL)
-					dev_kfree_skb_any(rx_buf->skb);
-			}
+	int i, ring;
+
+	recv_ctx = &adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		for (i = 0; i < rds_ring->max_rx_desc_count; ++i) {
+			rx_buf = &(rds_ring->rx_buf_arr[i]);
+			if (rx_buf->state == NETXEN_BUFFER_FREE)
+				continue;
+			pci_unmap_single(adapter->pdev,
+					rx_buf->dma,
+					rds_ring->dma_size,
+					PCI_DMA_FROMDEVICE);
+			if (rx_buf->skb != NULL)
+				dev_kfree_skb_any(rx_buf->skb);
 		}
 	}
 }
@@ -205,18 +203,17 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
-	int ctx, ring;
-
-	for (ctx = 0; ctx < MAX_RCV_CTX; ctx++) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			rds_ring = &recv_ctx->rds_rings[ring];
-			if (rds_ring->rx_buf_arr) {
-				vfree(rds_ring->rx_buf_arr);
-				rds_ring->rx_buf_arr = NULL;
-			}
+	int ring;
+
+	recv_ctx = &adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		if (rds_ring->rx_buf_arr) {
+			vfree(rds_ring->rx_buf_arr);
+			rds_ring->rx_buf_arr = NULL;
 		}
 	}
+
 	if (adapter->cmd_buf_arr)
 		vfree(adapter->cmd_buf_arr);
 	return;
@@ -227,7 +224,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct netxen_rx_buffer *rx_buf;
-	int ctx, ring, i, num_rx_bufs;
+	int ring, i, num_rx_bufs;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
@@ -241,74 +238,72 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	memset(cmd_buf_arr, 0, TX_RINGSIZE);
 	adapter->cmd_buf_arr = cmd_buf_arr;
 
-	for (ctx = 0; ctx < MAX_RCV_CTX; ctx++) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-			rds_ring = &recv_ctx->rds_rings[ring];
-			switch (RCV_DESC_TYPE(ring)) {
-			case RCV_DESC_NORMAL:
-				rds_ring->max_rx_desc_count =
-					adapter->max_rx_desc_count;
-				rds_ring->flags = RCV_DESC_NORMAL;
-				if (adapter->ahw.cut_through) {
-					rds_ring->dma_size =
-						NX_CT_DEFAULT_RX_BUF_LEN;
-					rds_ring->skb_size =
-						NX_CT_DEFAULT_RX_BUF_LEN;
-				} else {
-					rds_ring->dma_size = RX_DMA_MAP_LEN;
-					rds_ring->skb_size =
-						MAX_RX_BUFFER_LENGTH;
-				}
-				break;
-
-			case RCV_DESC_JUMBO:
-				rds_ring->max_rx_desc_count =
-					adapter->max_jumbo_rx_desc_count;
-				rds_ring->flags = RCV_DESC_JUMBO;
-				if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-					rds_ring->dma_size =
-						NX_P3_RX_JUMBO_BUF_MAX_LEN;
-				else
-					rds_ring->dma_size =
-						NX_P2_RX_JUMBO_BUF_MAX_LEN;
+	recv_ctx = &adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		switch (RCV_DESC_TYPE(ring)) {
+		case RCV_DESC_NORMAL:
+			rds_ring->max_rx_desc_count =
+				adapter->max_rx_desc_count;
+			rds_ring->flags = RCV_DESC_NORMAL;
+			if (adapter->ahw.cut_through) {
+				rds_ring->dma_size =
+					NX_CT_DEFAULT_RX_BUF_LEN;
 				rds_ring->skb_size =
-					rds_ring->dma_size + NET_IP_ALIGN;
-				break;
+					NX_CT_DEFAULT_RX_BUF_LEN;
+			} else {
+				rds_ring->dma_size = RX_DMA_MAP_LEN;
+				rds_ring->skb_size =
+					MAX_RX_BUFFER_LENGTH;
+			}
+			break;
 
-			case RCV_RING_LRO:
-				rds_ring->max_rx_desc_count =
-					adapter->max_lro_rx_desc_count;
-				rds_ring->flags = RCV_DESC_LRO;
-				rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
-				rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
-				break;
+		case RCV_DESC_JUMBO:
+			rds_ring->max_rx_desc_count =
+				adapter->max_jumbo_rx_desc_count;
+			rds_ring->flags = RCV_DESC_JUMBO;
+			if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+				rds_ring->dma_size =
+					NX_P3_RX_JUMBO_BUF_MAX_LEN;
+			else
+				rds_ring->dma_size =
+					NX_P2_RX_JUMBO_BUF_MAX_LEN;
+			rds_ring->skb_size =
+				rds_ring->dma_size + NET_IP_ALIGN;
+			break;
 
-			}
-			rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
-				vmalloc(RCV_BUFFSIZE);
-			if (rds_ring->rx_buf_arr == NULL) {
-				printk(KERN_ERR "%s: Failed to allocate "
-					"rx buffer ring %d\n",
-					netdev->name, ring);
-				/* free whatever was already allocated */
-				goto err_out;
-			}
-			memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
-			INIT_LIST_HEAD(&rds_ring->free_list);
-			/*
-			 * Now go through all of them, set reference handles
-			 * and put them in the queues.
-			 */
-			num_rx_bufs = rds_ring->max_rx_desc_count;
-			rx_buf = rds_ring->rx_buf_arr;
-			for (i = 0; i < num_rx_bufs; i++) {
-				list_add_tail(&rx_buf->list,
-						&rds_ring->free_list);
-				rx_buf->ref_handle = i;
-				rx_buf->state = NETXEN_BUFFER_FREE;
-				rx_buf++;
-			}
+		case RCV_RING_LRO:
+			rds_ring->max_rx_desc_count =
+				adapter->max_lro_rx_desc_count;
+			rds_ring->flags = RCV_DESC_LRO;
+			rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
+			rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
+			break;
+
+		}
+		rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
+			vmalloc(RCV_BUFFSIZE);
+		if (rds_ring->rx_buf_arr == NULL) {
+			printk(KERN_ERR "%s: Failed to allocate "
+				"rx buffer ring %d\n",
+				netdev->name, ring);
+			/* free whatever was already allocated */
+			goto err_out;
+		}
+		memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
+		INIT_LIST_HEAD(&rds_ring->free_list);
+		/*
+		 * Now go through all of them, set reference handles
+		 * and put them in the queues.
+		 */
+		num_rx_bufs = rds_ring->max_rx_desc_count;
+		rx_buf = rds_ring->rx_buf_arr;
+		for (i = 0; i < num_rx_bufs; i++) {
+			list_add_tail(&rx_buf->list,
+					&rds_ring->free_list);
+			rx_buf->ref_handle = i;
+			rx_buf->state = NETXEN_BUFFER_FREE;
+			rx_buf++;
 		}
 	}
 
@@ -838,13 +833,13 @@ no_skb:
 	return skb;
 }
 
-static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
+static void netxen_process_rcv(struct netxen_adapter *adapter,
 		struct status_desc *desc)
 {
 	struct net_device *netdev = adapter->netdev;
 	u64 sts_data = le64_to_cpu(desc->status_desc_data);
 	int index = netxen_get_sts_refhandle(sts_data);
-	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
 	u32 length = netxen_get_sts_totallength(sts_data);
@@ -902,10 +897,10 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	adapter->stats.rxbytes += length;
 }
 
-/* Process Receive status ring */
-u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
+int
+netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
 {
-	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
 	struct status_desc *desc;
 	u32 consumer = recv_ctx->status_rx_consumer;
@@ -922,7 +917,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 
 		opcode = netxen_get_sts_opcode(sts_data);
 
-		netxen_process_rcv(adapter, ctxid, desc);
+		netxen_process_rcv(adapter, desc);
 
 		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
 
@@ -932,7 +927,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++)
-		netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
+		netxen_post_rx_buffers_nodb(adapter, ring);
 
 	if (count) {
 		recv_ctx->status_rx_consumer = consumer;
@@ -1013,14 +1008,12 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	return (done);
 }
 
-/*
- * netxen_post_rx_buffers puts buffer in the Phantom memory
- */
-void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
+void
+netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct sk_buff *skb;
-	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct nx_host_rds_ring *rds_ring = NULL;
 	uint producer;
 	struct rcv_desc *pdesc;
@@ -1098,12 +1091,12 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	}
 }
 
-static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
-					uint32_t ctx, uint32_t ringid)
+static void
+netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct sk_buff *skb;
-	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct nx_host_rds_ring *rds_ring = NULL;
 	u32 producer;
 	struct rcv_desc *pdesc;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 084c0ed..e81a998 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -787,7 +787,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	int err, ctx, ring;
+	int err, ring;
 
 	err = netxen_init_firmware(adapter);
 	if (err != 0) {
@@ -826,10 +826,8 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		netxen_nic_update_cmd_consumer(adapter, 0);
 	}
 
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		for (ring = 0; ring < adapter->max_rds_rings; ring++)
-			netxen_post_rx_buffers(adapter, ctx, ring);
-	}
+	for (ring = 0; ring < adapter->max_rds_rings; ring++)
+		netxen_post_rx_buffers(adapter, ring);
 
 	err = netxen_nic_request_irq(adapter);
 	if (err) {
@@ -1637,30 +1635,14 @@ static irqreturn_t netxen_msix_intr(int irq, void *data)
 
 static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
-	struct netxen_adapter *adapter = container_of(napi, struct netxen_adapter, napi);
+	struct netxen_adapter *adapter =
+		container_of(napi, struct netxen_adapter, napi);
 	int tx_complete;
-	int ctx;
 	int work_done;
 
 	tx_complete = netxen_process_cmd_ring(adapter);
 
-	work_done = 0;
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		/*
-		 * Fairness issue. This will give undue weight to the
-		 * receive context 0.
-		 */
-
-		/*
-		 * To avoid starvation, we give each of our receivers,
-		 * a fraction of the quota. Sometimes, it might happen that we
-		 * have enough quota to process every packet, but since all the
-		 * packets are on one context, it gets only half of the quota,
-		 * and ends up not processing it.
-		 */
-		work_done += netxen_process_rcv_ring(adapter, ctx,
-						     budget / MAX_RCV_CTX);
-	}
+	work_done = netxen_process_rcv_ring(adapter, budget);
 
 	if ((work_done < budget) && tx_complete) {
 		napi_complete(&adapter->napi);
-- 
1.6.0.2

