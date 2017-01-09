From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/3] xgbe: switch to pci_irq_alloc_vectors
Date: Mon,  9 Jan 2017 21:37:39 +0100
Message-ID: <1483994260-19797-3-git-send-email-hch@lst.de>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1483994260-19797-1-git-send-email-hch@lst.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added xgbe drivers uses the deprecated pci_enable_msi_exact
and pci_enable_msix_range interfaces.  Switch it to use
pci_irq_alloc_vectors instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c | 47 +++++++++++++-------------------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |  1 -
 2 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
index e76b7f6..be2690e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
@@ -133,12 +133,13 @@ static int xgbe_config_msi(struct xgbe_prv_data *pdata)
 			 pdata->tx_ring_count);
 	msi_count = roundup_pow_of_two(msi_count);
 
-	ret = pci_enable_msi_exact(pdata->pcidev, msi_count);
+	ret = pci_alloc_irq_vectors(pdata->pcidev, msi_count, msi_count,
+			PCI_IRQ_MSI);
 	if (ret < 0) {
 		dev_info(pdata->dev, "MSI request for %u interrupts failed\n",
 			 msi_count);
 
-		ret = pci_enable_msi(pdata->pcidev);
+		ret = pci_alloc_irq_vectors(pdata->pcidev, 1, 1, PCI_IRQ_MSI);
 		if (ret < 0) {
 			dev_info(pdata->dev, "MSI enablement failed\n");
 			return ret;
@@ -149,25 +150,26 @@ static int xgbe_config_msi(struct xgbe_prv_data *pdata)
 
 	pdata->irq_count = msi_count;
 
-	pdata->dev_irq = pdata->pcidev->irq;
+	pdata->dev_irq = pci_irq_vector(pdata->pcidev, 0);
 
 	if (msi_count > 1) {
-		pdata->ecc_irq = pdata->pcidev->irq + 1;
-		pdata->i2c_irq = pdata->pcidev->irq + 2;
-		pdata->an_irq = pdata->pcidev->irq + 3;
+		pdata->ecc_irq = pci_irq_vector(pdata->pcidev, 1);
+		pdata->i2c_irq = pci_irq_vector(pdata->pcidev, 2);
+		pdata->an_irq = pci_irq_vector(pdata->pcidev, 3);
 
 		for (i = XGBE_MSIX_BASE_COUNT, j = 0;
 		     (i < msi_count) && (j < XGBE_MAX_DMA_CHANNELS);
 		     i++, j++)
-			pdata->channel_irq[j] = pdata->pcidev->irq + i;
+			pdata->channel_irq[j] =
+				pci_irq_vector(pdata->pcidev, i);
 		pdata->channel_irq_count = j;
 
 		pdata->per_channel_irq = 1;
 		pdata->channel_irq_mode = XGBE_IRQ_MODE_LEVEL;
 	} else {
-		pdata->ecc_irq = pdata->pcidev->irq;
-		pdata->i2c_irq = pdata->pcidev->irq;
-		pdata->an_irq = pdata->pcidev->irq;
+		pdata->ecc_irq = pci_irq_vector(pdata->pcidev, 0);
+		pdata->i2c_irq = pci_irq_vector(pdata->pcidev, 0);
+		pdata->an_irq = pci_irq_vector(pdata->pcidev, 0);
 	}
 
 	if (netif_msg_probe(pdata))
@@ -186,33 +188,22 @@ static int xgbe_config_msix(struct xgbe_prv_data *pdata)
 	msix_count += max(pdata->rx_ring_count,
 			  pdata->tx_ring_count);
 
-	pdata->msix_entries = devm_kcalloc(pdata->dev, msix_count,
-					   sizeof(struct msix_entry),
-					   GFP_KERNEL);
-	if (!pdata->msix_entries)
-		return -ENOMEM;
-
-	for (i = 0; i < msix_count; i++)
-		pdata->msix_entries[i].entry = i;
-
-	ret = pci_enable_msix_range(pdata->pcidev, pdata->msix_entries,
-				    XGBE_MSIX_MIN_COUNT, msix_count);
+	ret = pci_alloc_irq_vectors(pdata->pcidev, XGBE_MSIX_MIN_COUNT,
+			msix_count, PCI_IRQ_MSIX);
 	if (ret < 0) {
 		dev_info(pdata->dev, "MSI-X enablement failed\n");
-		devm_kfree(pdata->dev, pdata->msix_entries);
-		pdata->msix_entries = NULL;
 		return ret;
 	}
 
 	pdata->irq_count = ret;
 
-	pdata->dev_irq = pdata->msix_entries[0].vector;
-	pdata->ecc_irq = pdata->msix_entries[1].vector;
-	pdata->i2c_irq = pdata->msix_entries[2].vector;
-	pdata->an_irq = pdata->msix_entries[3].vector;
+	pdata->dev_irq = pci_irq_vector(pdata->pcidev, 0);
+	pdata->ecc_irq = pci_irq_vector(pdata->pcidev, 1);
+	pdata->i2c_irq = pci_irq_vector(pdata->pcidev, 2);
+	pdata->an_irq = pci_irq_vector(pdata->pcidev, 3);
 
 	for (i = XGBE_MSIX_BASE_COUNT, j = 0; i < ret; i++, j++)
-		pdata->channel_irq[j] = pdata->msix_entries[i].vector;
+		pdata->channel_irq[j] = pci_irq_vector(pdata->pcidev, i);
 	pdata->channel_irq_count = j;
 
 	pdata->per_channel_irq = 1;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index f52a9bd..3bcb6f5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -980,7 +980,6 @@ struct xgbe_prv_data {
 	unsigned int desc_ded_count;
 	unsigned int desc_sec_count;
 
-	struct msix_entry *msix_entries;
 	int dev_irq;
 	int ecc_irq;
 	int i2c_irq;
-- 
2.1.4
