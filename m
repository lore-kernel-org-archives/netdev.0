From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V5 07/22] qlcnic: update driver resource allocation routines
Date: Thu,  1 Nov 2012 21:06:39 -0400
Message-ID: <1351818414-25197-8-git-send-email-sony.chacko@qlogic.com>
References: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43774 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1762479Ab2KBB0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 21:26:11 -0400
In-Reply-To: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Updated driver resource allocation routines

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |   71 ++++++++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |   38 +----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   18 ++----
 3 files changed, 50 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 66e13c7..a7af815 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -455,37 +455,43 @@ qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 {
 	void *addr;
-	int err;
-	int ring;
+	int err, ring;
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_tx_ring *tx_ring;
+	__le32 *ptr;
 
 	struct pci_dev *pdev = adapter->pdev;
 
 	recv_ctx = adapter->recv_ctx;
-	tx_ring = adapter->tx_ring;
 
-	tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
-		sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
-	if (tx_ring->hw_consumer == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
-		return -ENOMEM;
-	}
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		ptr = (__le32 *)dma_alloc_coherent(&pdev->dev, sizeof(u32),
+						   &tx_ring->hw_cons_phys_addr,
+						   GFP_KERNEL);
+
+		if (ptr == NULL) {
+			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
+			return -ENOMEM;
+		}
+		tx_ring->hw_consumer = ptr;
+		/* cmd desc ring */
+		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
+					  &tx_ring->phys_addr,
+					  GFP_KERNEL);
 
-	/* cmd desc ring */
-	addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
-			&tx_ring->phys_addr, GFP_KERNEL);
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				"failed to allocate tx desc ring\n");
+			err = -ENOMEM;
+			goto err_out_free;
+		}
 
-	if (addr == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
-		err = -ENOMEM;
-		goto err_out_free;
+		tx_ring->desc_head = addr;
 	}
 
-	tx_ring->desc_head = addr;
-
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		addr = dma_alloc_coherent(&adapter->pdev->dev,
@@ -582,20 +588,23 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 
 	recv_ctx = adapter->recv_ctx;
 
-	tx_ring = adapter->tx_ring;
-	if (tx_ring->hw_consumer != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				sizeof(u32),
-				tx_ring->hw_consumer,
-				tx_ring->hw_cons_phys_addr);
-		tx_ring->hw_consumer = NULL;
-	}
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		if (tx_ring->hw_consumer != NULL) {
+			dma_free_coherent(&adapter->pdev->dev, sizeof(u32),
+					  tx_ring->hw_consumer,
+					  tx_ring->hw_cons_phys_addr);
+
+			tx_ring->hw_consumer = NULL;
+		}
 
-	if (tx_ring->desc_head != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				TX_DESC_RINGSIZE(tx_ring),
-				tx_ring->desc_head, tx_ring->phys_addr);
-		tx_ring->desc_head = NULL;
+		if (tx_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					  TX_DESC_RINGSIZE(tx_ring),
+					  tx_ring->desc_head,
+					  tx_ring->phys_addr);
+			tx_ring->desc_head = NULL;
+		}
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index b498160..70d8cff 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -163,13 +163,12 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
 	recv_ctx = adapter->recv_ctx;
 
 	if (recv_ctx->rds_rings == NULL)
-		goto skip_rds;
+		return;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -177,16 +176,6 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 		rds_ring->rx_buf_arr = NULL;
 	}
 	kfree(recv_ctx->rds_rings);
-
-skip_rds:
-	if (adapter->tx_ring == NULL)
-		return;
-
-	tx_ring = adapter->tx_ring;
-	vfree(tx_ring->cmd_buf_arr);
-	tx_ring->cmd_buf_arr = NULL;
-	kfree(adapter->tx_ring);
-	adapter->tx_ring = NULL;
 }
 
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
@@ -194,31 +183,11 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_rx_buffer *rx_buf;
 	int ring, i, size;
 
-	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
 
-	size = sizeof(struct qlcnic_host_tx_ring);
-	tx_ring = kzalloc(size, GFP_KERNEL);
-	if (tx_ring == NULL) {
-		dev_err(&netdev->dev, "failed to allocate tx ring struct\n");
-		return -ENOMEM;
-	}
-	adapter->tx_ring = tx_ring;
-
-	tx_ring->num_desc = adapter->num_txd;
-	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
-
-	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
-	if (cmd_buf_arr == NULL) {
-		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
-		goto err_out;
-	}
-	tx_ring->cmd_buf_arr = cmd_buf_arr;
-
 	recv_ctx = adapter->recv_ctx;
 
 	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
@@ -253,10 +222,11 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 		}
 		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
-			dev_err(&netdev->dev, "Failed to allocate "
-				"rx buffer ring %d\n", ring);
+			dev_err(&netdev->dev,
+				"Failed to allocate rx buffer ring %d\n", ring);
 			goto err_out;
 		}
+
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3cf0f16..316e119 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1311,21 +1311,11 @@ out:
 static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 {
 	int err = 0;
-	adapter->ahw = kzalloc(sizeof(struct qlcnic_hardware_context),
-				GFP_KERNEL);
-	if (!adapter->ahw) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to allocate recv ctx resources for adapter\n");
-		err = -ENOMEM;
-		goto err_out;
-	}
 	adapter->recv_ctx = kzalloc(sizeof(struct qlcnic_recv_context),
 				GFP_KERNEL);
 	if (!adapter->recv_ctx) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to allocate recv ctx resources for adapter\n");
-		kfree(adapter->ahw);
-		adapter->ahw = NULL;
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1333,6 +1323,8 @@ static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 	adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
 	adapter->ahw->coal.rx_time_us = QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
 	adapter->ahw->coal.rx_packets = QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	/* clear stats */
+	memset(&adapter->stats, 0, sizeof(adapter->stats));
 err_out:
 	return err;
 }
@@ -1346,8 +1338,8 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 		vfree(adapter->ahw->fw_dump.tmpl_hdr);
 		adapter->ahw->fw_dump.tmpl_hdr = NULL;
 	}
-	kfree(adapter->ahw);
-	adapter->ahw = NULL;
+
+	adapter->ahw->fw_dump.tmpl_hdr = NULL;
 }
 
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
@@ -1367,6 +1359,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 
 	adapter->max_sds_rings = 1;
 	adapter->ahw->diag_test = test;
+	adapter->ahw->linkup = 0;
 
 	ret = qlcnic_attach(adapter);
 	if (ret) {
@@ -1631,6 +1624,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->dev_rst_time = jiffies;
 	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
+	adapter->max_drv_tx_rings = 1;
 
 	rwlock_init(&adapter->ahw->crb_lock);
 	mutex_init(&adapter->ahw->mem_lock);
-- 
1.7.1
