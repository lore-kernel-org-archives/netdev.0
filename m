From: Jon Mason <jdmason@kudzu.us>
Subject: [RFC 1/3] ksz884x: Use pci_set_power_state() for setting PM states
Date: Mon, 24 Feb 2014 15:34:03 -0700
Message-ID: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
Cc: Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:37386 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbaBXWeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 17:34:18 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so7176243pab.3
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 14:34:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing infrastructure of pci_set_power_state() instead of
setting the relevant bits via PCI config read/write in the driver.
Also, use pci_pme_active() to set the PCI_PM_CTRL_PME_ENABLE bit in PCI
PM control register.  pci_set_power_state() and pci_pme_active() perform
the same operations as the driver did before, so there should be no
functional change.  That being said, this has not been tested.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Tristram Ha <Tristram.Ha@micrel.com>
---
 drivers/net/ethernet/micrel/ksz884x.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ce84dc2..d658231 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -3524,17 +3524,17 @@ static void hw_cfg_wol_pme(struct ksz_hw *hw, int set)
 {
 	struct dev_info *hw_priv = container_of(hw, struct dev_info, hw);
 	struct pci_dev *pdev = hw_priv->pdev;
-	u16 data;
 
 	if (!pdev->pm_cap)
 		return;
-	pci_read_config_word(pdev, pdev->pm_cap + PCI_PM_CTRL, &data);
-	data &= ~PCI_PM_CTRL_STATE_MASK;
-	if (set)
-		data |= PCI_PM_CTRL_PME_ENABLE | PCI_D3hot;
-	else
-		data &= ~PCI_PM_CTRL_PME_ENABLE;
-	pci_write_config_word(pdev, pdev->pm_cap + PCI_PM_CTRL, data);
+
+	if (set) {
+		pci_pme_active(pdev, true);
+		pci_set_power_state(pdev, PCI_D3hot);
+	} else {
+		pci_pme_active(pdev, false);
+		pci_set_power_state(pdev, PCI_D0);
+	}
 }
 
 /**
-- 
1.8.3.2
