From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] qlcnic: dma address align check
Date: Tue, 26 Oct 2010 02:38:02 -0700
Message-ID: <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56392 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755093Ab0JZJiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 05:38:04 -0400
In-Reply-To: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device requires tx_hw_cosnumer to be 64 byte aligned.
Tx desc size is 64 byte, alloc tx_hw_consumer with tx desc.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 1cdc05d..21c9c28 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -418,18 +418,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 	tx_ring = adapter->tx_ring;
 
-	tx_ring->hw_consumer = (__le32 *)pci_alloc_consistent(pdev, sizeof(u32),
-						&tx_ring->hw_cons_phys_addr);
-	if (tx_ring->hw_consumer == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
-		return -ENOMEM;
-	}
-	*(tx_ring->hw_consumer) = 0;
-
 	/* cmd desc ring */
-	addr = pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring),
-			&tx_ring->phys_addr);
-
+	addr = pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring) +
+			sizeof(u32), &tx_ring->phys_addr);
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
 		err = -ENOMEM;
@@ -437,6 +428,17 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	}
 
 	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
+	tx_ring->hw_consumer = (__le32 *)(((char *)addr) +
+					TX_DESC_RINGSIZE(tx_ring));
+	tx_ring->hw_cons_phys_addr = (dma_addr_t)(((char *)tx_ring->phys_addr) +
+					TX_DESC_RINGSIZE(tx_ring));
+	if (tx_ring->hw_cons_phys_addr & 0x3F) {
+		dev_err(&pdev->dev, "Device requires 64 byte aligned dma addr"
+			". dma_addr=%p\n", (void *)tx_ring->hw_cons_phys_addr);
+		err = -ENOMEM;
+		goto err_out_free;
+	}
+	*(tx_ring->hw_consumer) = 0;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -516,19 +518,12 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 
 	tx_ring = adapter->tx_ring;
-	if (tx_ring->hw_consumer != NULL) {
-		pci_free_consistent(adapter->pdev,
-				sizeof(u32),
-				tx_ring->hw_consumer,
-				tx_ring->hw_cons_phys_addr);
-		tx_ring->hw_consumer = NULL;
-	}
-
 	if (tx_ring->desc_head != NULL) {
 		pci_free_consistent(adapter->pdev,
-				TX_DESC_RINGSIZE(tx_ring),
+				TX_DESC_RINGSIZE(tx_ring) + sizeof(u32),
 				tx_ring->desc_head, tx_ring->phys_addr);
 		tx_ring->desc_head = NULL;
+		tx_ring->hw_consumer = NULL;
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-- 
1.6.0.2

