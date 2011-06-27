From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 14/19] sky2: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:46:56 -0500
Message-ID: <1309196816-16198-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53528 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab1F0RrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:47:01 -0400
Received: by pzk9 with SMTP id 9so3105124pzk.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:47:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
better way of determining if the device is PCIE or not (as it uses the
same saved PCIE capability offset).

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/sky2.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d252cb1..e14b86e 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1449,7 +1449,7 @@ static void sky2_rx_start(struct sky2_port *sky2)
 	sky2_qset(hw, rxq);
 
 	/* On PCI express lowering the watermark gives better performance */
-	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
+	if (pci_is_pcie(hw->pdev))
 		sky2_write32(hw, Q_ADDR(rxq, Q_WM), BMU_WM_PEX);
 
 	/* These chips have no ram buffer?
@@ -3072,7 +3072,7 @@ static void sky2_reset(struct sky2_hw *hw)
 {
 	struct pci_dev *pdev = hw->pdev;
 	u16 status;
-	int i, cap;
+	int i;
 	u32 hwe_mask = Y2_HWE_ALL_MASK;
 
 	/* disable ASF */
@@ -3108,8 +3108,7 @@ static void sky2_reset(struct sky2_hw *hw)
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (cap) {
+	if (pci_is_pcie(pdev)) {
 		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
 			     0xfffffffful);
 
@@ -3171,11 +3170,11 @@ static void sky2_reset(struct sky2_hw *hw)
 
 		/* check if PSMv2 was running before */
 		reg = sky2_pci_read16(hw, PSM_CONFIG_REG3);
-		if (reg & PCI_EXP_LNKCTL_ASPMC) {
-			cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+		if (reg & PCI_EXP_LNKCTL_ASPMC)
 			/* restore the PCIe Link Control register */
-			sky2_pci_write16(hw, cap + PCI_EXP_LNKCTL, reg);
-		}
+			sky2_pci_write16(hw, pdev->pcie_cap + PCI_EXP_LNKCTL,
+					 reg);
+
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 		/* re-enable PEX PM in PEX PHY debug reg. 8 (clear bit 12) */
-- 
1.7.5.4

