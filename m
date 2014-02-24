From: Jon Mason <jdmason@kudzu.us>
Subject: [RFC 3/3] bnx2x: Use pci_set_power_state() for setting PM states
Date: Mon, 24 Feb 2014 15:34:05 -0700
Message-ID: <1393281245-3951-3-git-send-email-jdmason@kudzu.us>
References: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
Cc: Ariel Elior <ariele@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:61650 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbaBXWel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 17:34:41 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so6900915pde.13
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 14:34:41 -0800 (PST)
In-Reply-To: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing infrastructure of pci_set_power_state() instead of
setting the relevant bits via PCI config read/write in the driver.
Also, use the d3_delay field to specify how long to msleep after putting
the device in the appropriate power management state.  Finally, use
pci_pme_active() to set the PCI_PM_CTRL_PME_ENABLE bit in PCI PM control
register.  pci_set_power_state() and pci_pme_active() perform the same
operations as the driver did before, so there should be no functional
change.  That being said, this has not been tested.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 21 ++++-----------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  3 +++
 2 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 66c0df7..3fee183 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3054,25 +3054,16 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 
 int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 {
-	u16 pmcsr;
-
 	/* If there is no power capability, silently succeed */
 	if (!bp->pdev->pm_cap) {
 		BNX2X_DEV_INFO("No power capability. Breaking.\n");
 		return 0;
 	}
 
-	pci_read_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL, &pmcsr);
-
 	switch (state) {
 	case PCI_D0:
-		pci_write_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL,
-				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
-				       PCI_PM_CTRL_PME_STATUS));
-
-		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
-			/* delay required during transition out of D3hot */
-			msleep(20);
+		pci_set_power_state(bp->pdev, PCI_D0);
+		pci_pme_active(bp->pdev, false);
 		break;
 
 	case PCI_D3hot:
@@ -3084,14 +3075,10 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 		if (CHIP_REV_IS_SLOW(bp))
 			return 0;
 
-		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
-		pmcsr |= 3;
-
 		if (bp->wol)
-			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
+			pci_pme_active(bp->pdev, true);
 
-		pci_write_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL,
-				      pmcsr);
+		pci_set_power_state(bp->pdev, PCI_D3hot);
 
 		/* No more memory access after this point until
 		* device is brought back to D0.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7d43822..19f4b0a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12898,6 +12898,9 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 
+	/* delay required during transition out of D3hot */
+	pdev->d3_delay = 20;
+
 	rc = bnx2x_init_dev(bp, pdev, dev, ent->driver_data);
 	if (rc < 0) {
 		free_netdev(dev);
-- 
1.8.3.2
