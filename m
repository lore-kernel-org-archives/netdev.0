From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 07/19] cxgb3: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:42:49 -0500
Message-ID: <1309196569-15926-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40635 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab1F0Rmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:42:54 -0400
Received: by pvg12 with SMTP id 12so2991260pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:42:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/cxgb3/common.h |    1 -
 drivers/net/cxgb3/t3_hw.c  |   11 ++++-------
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 056ee8c..df01b63 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -367,7 +367,6 @@ struct vpd_params {
 
 struct pci_params {
 	unsigned int vpd_cap_addr;
-	unsigned int pcie_cap_addr;
 	unsigned short speed;
 	unsigned char width;
 	unsigned char variant;
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index c688421..44ac2f4 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3290,22 +3290,20 @@ static void config_pcie(struct adapter *adap)
 	unsigned int fst_trn_rx, fst_trn_tx, acklat, rpllmt;
 
 	pci_read_config_word(adap->pdev,
-			     adap->params.pci.pcie_cap_addr + PCI_EXP_DEVCTL,
+			     adap->pdev->pcie_cap + PCI_EXP_DEVCTL,
 			     &val);
 	pldsize = (val & PCI_EXP_DEVCTL_PAYLOAD) >> 5;
 
 	pci_read_config_word(adap->pdev, 0x2, &devid);
 	if (devid == 0x37) {
 		pci_write_config_word(adap->pdev,
-				      adap->params.pci.pcie_cap_addr +
-				      PCI_EXP_DEVCTL,
+				      adap->pdev->pcie_cap + PCI_EXP_DEVCTL,
 				      val & ~PCI_EXP_DEVCTL_READRQ &
 				      ~PCI_EXP_DEVCTL_PAYLOAD);
 		pldsize = 0;
 	}
 
-	pci_read_config_word(adap->pdev,
-			     adap->params.pci.pcie_cap_addr + PCI_EXP_LNKCTL,
+	pci_read_config_word(adap->pdev, adap->pdev->pcie_cap + PCI_EXP_LNKCTL,
 			     &val);
 
 	fst_trn_tx = G_NUMFSTTRNSEQ(t3_read_reg(adap, A_PCIE_PEX_CTRL0));
@@ -3429,12 +3427,11 @@ static void get_pci_mode(struct adapter *adapter, struct pci_params *p)
 	static unsigned short speed_map[] = { 33, 66, 100, 133 };
 	u32 pci_mode, pcie_cap;
 
-	pcie_cap = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	pcie_cap = pci_pcie_cap(adapter->pdev);
 	if (pcie_cap) {
 		u16 val;
 
 		p->variant = PCI_VARIANT_PCIE;
-		p->pcie_cap_addr = pcie_cap;
 		pci_read_config_word(adapter->pdev, pcie_cap + PCI_EXP_LNKSTA,
 					&val);
 		p->width = (val >> 4) & 0x3f;
-- 
1.7.5.4

