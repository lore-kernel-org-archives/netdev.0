From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: fix coherent dma mask setting
Date: Sun,  2 Aug 2009 00:36:16 -0700
Message-ID: <1249198576-11389-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Dhananjay Phadke <dhananjay@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-98-207-116-189.hsd1.ca.comcast.net ([98.207.116.189]:43343
	"EHLO ibmt43.home" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752101AbZHBHoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 03:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change default dma mask for NX3031 to 39 bit with ability
to update it to 64-bit (if firmware indicates support). Old
code was restricting it under 4GB (32-bit), sometimes causing
failure to allocate descriptor rings on heavily populated
system. NX2031 based NICs will still get 32-bit coherent mask.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   37 +++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 637ac8b..3cd8cfc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -221,7 +221,7 @@ netxen_napi_disable(struct netxen_adapter *adapter)
 	}
 }
 
-static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
+static int nx_set_dma_mask(struct netxen_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	uint64_t mask, cmask;
@@ -229,19 +229,17 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 	adapter->pci_using_dac = 0;
 
 	mask = DMA_BIT_MASK(32);
-	/*
-	 * Consistent DMA mask is set to 32 bit because it cannot be set to
-	 * 35 bits. For P3 also leave it at 32 bits for now. Only the rings
-	 * come off this pool.
-	 */
 	cmask = DMA_BIT_MASK(32);
 
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 #ifndef CONFIG_IA64
-	if (revision_id >= NX_P3_B0)
-		mask = DMA_BIT_MASK(39);
-	else if (revision_id == NX_P2_C1)
 		mask = DMA_BIT_MASK(35);
 #endif
+	} else {
+		mask = DMA_BIT_MASK(39);
+		cmask = mask;
+	}
+
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
 		pci_set_consistent_dma_mask(pdev, cmask) == 0) {
 		adapter->pci_using_dac = 1;
@@ -256,7 +254,7 @@ static int
 nx_update_dma_mask(struct netxen_adapter *adapter)
 {
 	int change, shift, err;
-	uint64_t mask, old_mask;
+	uint64_t mask, old_mask, old_cmask;
 	struct pci_dev *pdev = adapter->pdev;
 
 	change = 0;
@@ -272,14 +270,29 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 
 	if (change) {
 		old_mask = pdev->dma_mask;
+		old_cmask = pdev->dev.coherent_dma_mask;
+
 		mask = (1ULL<<(32+shift)) - 1;
 
 		err = pci_set_dma_mask(pdev, mask);
 		if (err)
-			return pci_set_dma_mask(pdev, old_mask);
+			goto err_out;
+
+		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+
+			err = pci_set_consistent_dma_mask(pdev, mask);
+			if (err)
+				goto err_out;
+		}
+		dev_info(&pdev->dev, "using %d-bit dma mask\n", 32+shift);
 	}
 
 	return 0;
+
+err_out:
+	pci_set_dma_mask(pdev, old_mask);
+	pci_set_consistent_dma_mask(pdev, old_cmask);
+	return err;
 }
 
 static void netxen_check_options(struct netxen_adapter *adapter)
@@ -1006,7 +1019,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	revision_id = pdev->revision;
 	adapter->ahw.revision_id = revision_id;
 
-	err = nx_set_dma_mask(adapter, revision_id);
+	err = nx_set_dma_mask(adapter);
 	if (err)
 		goto err_out_free_netdev;
 
-- 
1.6.0.2

