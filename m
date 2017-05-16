From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] liquidio: use pcie_flr instead of duplicating it
Date: Tue, 16 May 2017 16:21:46 +0200
Message-ID: <20170516142146.21739-1-hch@lst.de>
Cc: netdev@vger.kernel.org
To: felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        derek.chickles@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50558 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbdEPOVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 10:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 34c77821fad9..d51c8d8d9a35 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -879,8 +879,6 @@ liquidio_vf_probe(struct pci_dev *pdev,
  */
 static void octeon_pci_flr(struct octeon_device *oct)
 {
-	u16 status;
-
 	pci_save_state(oct->pci_dev);
 
 	pci_cfg_access_lock(oct->pci_dev);
@@ -889,20 +887,7 @@ static void octeon_pci_flr(struct octeon_device *oct)
 	pci_write_config_word(oct->pci_dev, PCI_COMMAND,
 			      PCI_COMMAND_INTX_DISABLE);
 
-	/* Wait for Transaction Pending bit clean */
-	msleep(100);
-	pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA, &status);
-	if (status & PCI_EXP_DEVSTA_TRPND) {
-		dev_info(&oct->pci_dev->dev, "Function reset incomplete after 100ms, sleeping for 5 seconds\n");
-		ssleep(5);
-		pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA,
-					  &status);
-		if (status & PCI_EXP_DEVSTA_TRPND)
-			dev_info(&oct->pci_dev->dev, "Function reset still incomplete after 5s, reset anyway\n");
-	}
-	pcie_capability_set_word(oct->pci_dev, PCI_EXP_DEVCTL,
-				 PCI_EXP_DEVCTL_BCR_FLR);
-	mdelay(100);
+	pcie_flr(oct->pci_dev);
 
 	pci_cfg_access_unlock(oct->pci_dev);
 
-- 
2.11.0
