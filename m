From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/3] netxen: refactor netxen_recv_context struct
Date: Tue, 28 Apr 2009 18:29:10 -0700
Message-ID: <1240968551-13186-2-git-send-email-dhananjay@netxen.com>
References: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33178 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755943AbZD2B3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 21:29:16 -0400
In-Reply-To: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o move related fields into netxen_recv_context struct.
o allocate rx buffer and descriptor rings dynamically.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   10 +++---
 drivers/net/netxen/netxen_nic_ctx.c  |   49 ++++++++++++++++++---------------
 drivers/net/netxen/netxen_nic_hw.c   |    2 +-
 drivers/net/netxen/netxen_nic_init.c |   46 +++++++++++++++++++++++++-------
 drivers/net/netxen/netxen_nic_main.c |    4 +-
 5 files changed, 71 insertions(+), 40 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ebd6c2e..16f5e22 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -775,8 +775,11 @@ struct netxen_recv_context {
 	u16 context_id;
 	u16 virt_port;
 
-	struct nx_host_rds_ring rds_rings[NUM_RCV_DESC_RINGS];
+	struct nx_host_rds_ring *rds_rings;
 	struct nx_host_sds_ring *sds_rings;
+
+	struct netxen_ring_ctx *hwctx;
+	dma_addr_t phys_addr;
 };
 
 /* New HW context creation */
@@ -1258,11 +1261,8 @@ struct netxen_adapter {
 	struct netxen_adapter_stats stats;
 
 	struct netxen_recv_context recv_ctx;
-	struct nx_host_tx_ring tx_ring;
+	struct nx_host_tx_ring *tx_ring;
 
-	/* Context interface shared between card and host */
-	struct netxen_ring_ctx *ctx_desc;
-	dma_addr_t ctx_desc_phys_addr;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index fd82adf..4754f5c 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -323,7 +323,8 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	int	err = 0;
 	u64	offset, phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	rq_size = SIZEOF_HOSTRQ_TX(nx_hostrq_tx_ctx_t);
 	rq_addr = pci_alloc_consistent(adapter->pdev,
@@ -358,7 +359,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 
 	prq->dummy_dma_addr = cpu_to_le64(adapter->dummy_dma.phys_addr);
 
-	offset = adapter->ctx_desc_phys_addr+sizeof(struct netxen_ring_ctx);
+	offset = recv_ctx->phys_addr + sizeof(struct netxen_ring_ctx);
 	prq->cmd_cons_dma_addr = cpu_to_le64(offset);
 
 	prq_cds = &prq->cds_ring;
@@ -541,14 +542,16 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	struct nx_host_tx_ring *tx_ring;
 	int ring;
 	int port = adapter->portnum;
-	struct netxen_ring_ctx *hwctx = adapter->ctx_desc;
+	struct netxen_ring_ctx *hwctx;
 	u32 signature;
 
-	tx_ring = &adapter->tx_ring;
+	tx_ring = adapter->tx_ring;
+	recv_ctx = &adapter->recv_ctx;
+	hwctx = recv_ctx->hwctx;
+
 	hwctx->cmd_ring_addr = cpu_to_le64(tx_ring->phys_addr);
 	hwctx->cmd_ring_size = cpu_to_le32(tx_ring->num_desc);
 
-	recv_ctx = &adapter->recv_ctx;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -576,9 +579,9 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 		NETXEN_CTX_SIGNATURE_V2 : NETXEN_CTX_SIGNATURE;
 
 	NXWR32(adapter, CRB_CTX_ADDR_REG_LO(port),
-			lower32(adapter->ctx_desc_phys_addr));
+			lower32(recv_ctx->phys_addr));
 	NXWR32(adapter, CRB_CTX_ADDR_REG_HI(port),
-			upper32(adapter->ctx_desc_phys_addr));
+			upper32(recv_ctx->phys_addr));
 	NXWR32(adapter, CRB_CTX_SIGNATURE_REG(port),
 			signature | port);
 	return 0;
@@ -592,25 +595,28 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring;
 
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 	int port = adapter->portnum;
 
+	recv_ctx = &adapter->recv_ctx;
+	tx_ring = adapter->tx_ring;
+
 	addr = pci_alloc_consistent(pdev,
 			sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
-			&adapter->ctx_desc_phys_addr);
-
+			&recv_ctx->phys_addr);
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "failed to allocate hw context\n");
 		return -ENOMEM;
 	}
+
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
-	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
-	adapter->ctx_desc->ctx_id = cpu_to_le32(port);
-	adapter->ctx_desc->cmd_consumer_offset =
-		cpu_to_le64(adapter->ctx_desc_phys_addr +
+	recv_ctx->hwctx = (struct netxen_ring_ctx *)addr;
+	recv_ctx->hwctx->ctx_id = cpu_to_le32(port);
+	recv_ctx->hwctx->cmd_consumer_offset =
+		cpu_to_le64(recv_ctx->phys_addr +
 			sizeof(struct netxen_ring_ctx));
 	tx_ring->hw_consumer =
 		(__le32 *)(((char *)addr) + sizeof(struct netxen_ring_ctx));
@@ -627,8 +633,6 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
 
-	recv_ctx = &adapter->recv_ctx;
-
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		addr = pci_alloc_consistent(adapter->pdev,
@@ -713,16 +717,18 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 		netxen_api_unlock(adapter);
 	}
 
-	if (adapter->ctx_desc != NULL) {
+	recv_ctx = &adapter->recv_ctx;
+
+	if (recv_ctx->hwctx != NULL) {
 		pci_free_consistent(adapter->pdev,
 				sizeof(struct netxen_ring_ctx) +
 				sizeof(uint32_t),
-				adapter->ctx_desc,
-				adapter->ctx_desc_phys_addr);
-		adapter->ctx_desc = NULL;
+				recv_ctx->hwctx,
+				recv_ctx->phys_addr);
+		recv_ctx->hwctx = NULL;
 	}
 
-	tx_ring = &adapter->tx_ring;
+	tx_ring = adapter->tx_ring;
 	if (tx_ring->desc_head != NULL) {
 		pci_free_consistent(adapter->pdev,
 				TX_DESC_RINGSIZE(tx_ring),
@@ -730,7 +736,6 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 		tx_ring->desc_head = NULL;
 	}
 
-	recv_ctx = &adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 3bb2b8c..db53d9c 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -521,7 +521,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	i = 0;
 
-	tx_ring = &adapter->tx_ring;
+	tx_ring = adapter->tx_ring;
 	netif_tx_lock_bh(adapter->netdev);
 
 	producer = tx_ring->producer;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 8893a97..363ef70 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -137,7 +137,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	struct netxen_cmd_buffer *cmd_buf;
 	struct netxen_skb_frag *buffrag;
 	int i, j;
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	cmd_buf = tx_ring->cmd_buf_arr;
 	for (i = 0; i < tx_ring->num_desc; i++) {
@@ -172,6 +172,10 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 	int ring;
 
 	recv_ctx = &adapter->recv_ctx;
+
+	if (recv_ctx->rds_rings == NULL)
+		goto skip_rds;
+
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		if (rds_ring->rx_buf_arr) {
@@ -179,11 +183,15 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 			rds_ring->rx_buf_arr = NULL;
 		}
 	}
+	kfree(recv_ctx->rds_rings);
+
+skip_rds:
+	if (adapter->tx_ring == NULL)
+		return;
 
-	tx_ring = &adapter->tx_ring;
+	tx_ring = adapter->tx_ring;
 	if (tx_ring->cmd_buf_arr)
 		vfree(tx_ring->cmd_buf_arr);
-	return;
 }
 
 int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
@@ -191,17 +199,26 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring;
 	struct netxen_rx_buffer *rx_buf;
-	int ring, i, num_rx_bufs;
+	int ring, i, size;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
+	size = sizeof(struct nx_host_tx_ring);
+	tx_ring = kzalloc(size, GFP_KERNEL);
+	if (tx_ring == NULL) {
+		dev_err(&pdev->dev, "%s: failed to allocate tx ring struct\n",
+		       netdev->name);
+		return -ENOMEM;
+	}
+	adapter->tx_ring = tx_ring;
+
 	tx_ring->num_desc = adapter->num_txd;
-	cmd_buf_arr =
-		(struct netxen_cmd_buffer *)vmalloc(TX_BUFF_RINGSIZE(tx_ring));
+
+	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate cmd buffer ring\n",
 		       netdev->name);
@@ -211,6 +228,16 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
+
+	size = adapter->max_rds_rings * sizeof (struct nx_host_rds_ring);
+	rds_ring = kzalloc(size, GFP_KERNEL);
+	if (rds_ring == NULL) {
+		dev_err(&pdev->dev, "%s: failed to allocate rds ring struct\n",
+		       netdev->name);
+		return -ENOMEM;
+	}
+	recv_ctx->rds_rings = rds_ring;
+
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		switch (ring) {
@@ -262,9 +289,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 		 * Now go through all of them, set reference handles
 		 * and put them in the queues.
 		 */
-		num_rx_bufs = rds_ring->num_desc;
 		rx_buf = rds_ring->rx_buf_arr;
-		for (i = 0; i < num_rx_bufs; i++) {
+		for (i = 0; i < rds_ring->num_desc; i++) {
 			list_add_tail(&rx_buf->list,
 					&rds_ring->free_list);
 			rx_buf->ref_handle = i;
@@ -1064,7 +1090,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_skb_frag *frag;
 	int done = 0;
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	if (!spin_trylock(&adapter->tx_clean_lock))
 		return 1;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8331580..07959fe 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -857,7 +857,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->fw_major < 4) {
-		tx_ring = &adapter->tx_ring;
+		tx_ring = adapter->tx_ring;
 		tx_ring->crb_cmd_producer = crb_cmd_producer[adapter->portnum];
 		tx_ring->crb_cmd_consumer = crb_cmd_consumer[adapter->portnum];
 
@@ -1315,7 +1315,7 @@ static int
 netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
+	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 	unsigned int first_seg_len = skb->len - skb->data_len;
 	struct netxen_cmd_buffer *pbuf;
 	struct netxen_skb_frag *buffrag;
-- 
1.6.0.2

