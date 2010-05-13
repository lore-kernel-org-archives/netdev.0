From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/9] qlcnic: cleanup dma mask setting
Date: Thu, 13 May 2010 06:07:45 -0700
Message-ID: <1273756070-7205-5-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:36543 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758606Ab0EMNHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:54 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device support 64 bit dma mask.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_main.c |   93 ++++++++++----------------------------
 2 files changed, 24 insertions(+), 70 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index cfedcbd..189453f 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -924,7 +924,6 @@ struct qlcnic_adapter {
 	u8 driver_mismatch;
 	u8 msix_supported;
 	u8 rx_csum;
-	u8 pci_using_dac;
 	u8 portnum;
 	u8 physical_port;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 4652c7b..f10ea32 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -242,66 +242,6 @@ static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
 	return;
 }
 
-static int qlcnic_set_dma_mask(struct qlcnic_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-	u64 mask, cmask;
-
-	adapter->pci_using_dac = 0;
-
-	mask = DMA_BIT_MASK(39);
-	cmask = mask;
-
-	if (pci_set_dma_mask(pdev, mask) == 0 &&
-			pci_set_consistent_dma_mask(pdev, cmask) == 0) {
-		adapter->pci_using_dac = 1;
-		return 0;
-	}
-
-	return -EIO;
-}
-
-/* Update addressable range if firmware supports it */
-static int
-qlcnic_update_dma_mask(struct qlcnic_adapter *adapter)
-{
-	int change, shift, err;
-	u64 mask, old_mask, old_cmask;
-	struct pci_dev *pdev = adapter->pdev;
-
-	change = 0;
-
-	shift = QLCRD32(adapter, CRB_DMA_SHIFT);
-	if (shift > 32)
-		return 0;
-
-	if (shift > 9)
-		change = 1;
-
-	if (change) {
-		old_mask = pdev->dma_mask;
-		old_cmask = pdev->dev.coherent_dma_mask;
-
-		mask = DMA_BIT_MASK(32+shift);
-
-		err = pci_set_dma_mask(pdev, mask);
-		if (err)
-			goto err_out;
-
-		err = pci_set_consistent_dma_mask(pdev, mask);
-		if (err)
-			goto err_out;
-		dev_info(&pdev->dev, "using %d-bit dma mask\n", 32+shift);
-	}
-
-	return 0;
-
-err_out:
-	pci_set_dma_mask(pdev, old_mask);
-	pci_set_consistent_dma_mask(pdev, old_cmask);
-	return err;
-}
-
 static void qlcnic_set_port_mode(struct qlcnic_adapter *adapter)
 {
 	u32 val, data;
@@ -645,10 +585,6 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int val, err, first_boot;
 
-	err = qlcnic_set_dma_mask(adapter);
-	if (err)
-		return err;
-
 	err = qlcnic_can_start_firmware(adapter);
 	if (err < 0)
 		return err;
@@ -699,8 +635,6 @@ wait_init:
 
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 
-	qlcnic_update_dma_mask(adapter);
-
 	qlcnic_check_options(adapter);
 
 	adapter->need_fw_reset = 0;
@@ -1026,7 +960,7 @@ qlcnic_reset_context(struct qlcnic_adapter *adapter)
 
 static int
 qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
-		struct net_device *netdev)
+		struct net_device *netdev, u8 pci_using_dac)
 {
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1049,7 +983,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 	netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 
-	if (adapter->pci_using_dac) {
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
@@ -1079,6 +1013,22 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
+static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
+{
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+			!pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
+		*pci_using_dac = 1;
+	else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) &&
+			!pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))
+		*pci_using_dac = 0;
+	else {
+		dev_err(&pdev->dev, "Unable to set DMA mask, aborting\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1087,6 +1037,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
+	uint8_t pci_using_dac;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1097,6 +1048,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_disable_pdev;
 	}
 
+	err = qlcnic_set_dma_mask(pdev, &pci_using_dac);
+	if (err)
+		goto err_out_disable_pdev;
+
 	err = pci_request_regions(pdev, qlcnic_driver_name);
 	if (err)
 		goto err_out_disable_pdev;
@@ -1154,7 +1109,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	qlcnic_setup_intr(adapter);
 
-	err = qlcnic_setup_netdev(adapter, netdev);
+	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
 		goto err_out_disable_msi;
 
-- 
1.6.0.2

