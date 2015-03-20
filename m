From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 3/3] be2net: use PCI MMIO read instead of config read for errors
Date: Fri, 20 Mar 2015 06:28:25 -0400
Message-ID: <1426847305-23008-4-git-send-email-sathya.perla@emulex.com>
References: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:49488 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbbCTKZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:25:22 -0400
In-Reply-To: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

When an EEH error occurs, the device/slot is disconnected. This condition
is more reliably detected (i.e., returns all ones) with an MMIO read rather
than a config read -- especially on power platforms.

Hence, this patch fixes EEH error detection by replacing config reads with
MMIO reads for reading the error registers. The error registers in
Skyhawk-R/BE2/BE3 are accessible both via the config space and the
PCICFG (BAR0) memory space.

Reported-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 33 +++++++++++++++++++----------
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 92eb0c8..27b9fe9 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -424,6 +424,7 @@ struct be_adapter {
 
 	u8 __iomem *csr;	/* CSR BAR used only for BE2/3 */
 	u8 __iomem *db;		/* Door Bell */
+	u8 __iomem *pcicfg;	/* On SH,BEx only. Shadow of PCI config space */
 
 	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
 	struct be_dma_mem mbox_mem;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index eb2bed9..e6b790f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2823,14 +2823,12 @@ void be_detect_error(struct be_adapter *adapter)
 			}
 		}
 	} else {
-		pci_read_config_dword(adapter->pdev,
-				      PCICFG_UE_STATUS_LOW, &ue_lo);
-		pci_read_config_dword(adapter->pdev,
-				      PCICFG_UE_STATUS_HIGH, &ue_hi);
-		pci_read_config_dword(adapter->pdev,
-				      PCICFG_UE_STATUS_LOW_MASK, &ue_lo_mask);
-		pci_read_config_dword(adapter->pdev,
-				      PCICFG_UE_STATUS_HI_MASK, &ue_hi_mask);
+		ue_lo = ioread32(adapter->pcicfg + PCICFG_UE_STATUS_LOW);
+		ue_hi = ioread32(adapter->pcicfg + PCICFG_UE_STATUS_HIGH);
+		ue_lo_mask = ioread32(adapter->pcicfg +
+				      PCICFG_UE_STATUS_LOW_MASK);
+		ue_hi_mask = ioread32(adapter->pcicfg +
+				      PCICFG_UE_STATUS_HI_MASK);
 
 		ue_lo = (ue_lo & ~ue_lo_mask);
 		ue_hi = (ue_hi & ~ue_hi_mask);
@@ -4874,24 +4872,37 @@ static int be_roce_map_pci_bars(struct be_adapter *adapter)
 
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	u8 __iomem *addr;
 
 	if (BEx_chip(adapter) && be_physfn(adapter)) {
-		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
+		adapter->csr = pci_iomap(pdev, 2, 0);
 		if (!adapter->csr)
 			return -ENOMEM;
 	}
 
-	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
+	addr = pci_iomap(pdev, db_bar(adapter), 0);
 	if (!addr)
 		goto pci_map_err;
 	adapter->db = addr;
 
+	if (skyhawk_chip(adapter) || BEx_chip(adapter)) {
+		if (be_physfn(adapter)) {
+			/* PCICFG is the 2nd BAR in BE2 */
+			addr = pci_iomap(pdev, BE2_chip(adapter) ? 1 : 0, 0);
+			if (!addr)
+				goto pci_map_err;
+			adapter->pcicfg = addr;
+		} else {
+			adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
+		}
+	}
+
 	be_roce_map_pci_bars(adapter);
 	return 0;
 
 pci_map_err:
-	dev_err(&adapter->pdev->dev, "Error in mapping PCI BARs\n");
+	dev_err(&pdev->dev, "Error in mapping PCI BARs\n");
 	be_unmap_pci_bars(adapter);
 	return -ENOMEM;
 }
-- 
2.2.0
