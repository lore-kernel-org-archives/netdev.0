From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 1/2] bnx2x: Use pci_dev pm_cap
Date: Wed, 11 Sep 2013 11:22:39 -0700
Message-ID: <1378923760-16232-1-git-send-email-jdmason@kudzu.us>
Cc: Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35250 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab3IKSVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:21:24 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so9556403pdj.22
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:21:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the already existing pm_cap variable in struct pci_dev for
determining the power management offset.  This saves the driver from
having to keep track of an extra variable.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |    8 ++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |   10 +++++-----
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0c33802..70b6a05 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1542,7 +1542,6 @@ struct bnx2x {
 	 */
 	bool			fcoe_init;
 
-	int			pm_cap;
 	int			mrrs;
 
 	struct delayed_work	sp_task;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2361bf2..44a1261 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3000,16 +3000,16 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 	u16 pmcsr;
 
 	/* If there is no power capability, silently succeed */
-	if (!bp->pm_cap) {
+	if (!bp->pdev->pm_cap) {
 		BNX2X_DEV_INFO("No power capability. Breaking.\n");
 		return 0;
 	}
 
-	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmcsr);
+	pci_read_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL, &pmcsr);
 
 	switch (state) {
 	case PCI_D0:
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
+		pci_write_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL,
 				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
 				       PCI_PM_CTRL_PME_STATUS));
 
@@ -3033,7 +3033,7 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 		if (bp->wol)
 			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
 
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
+		pci_write_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_CTRL,
 				      pmcsr);
 
 		/* No more memory access after this point until
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 2612e3c..324de5f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1387,9 +1387,9 @@ static bool bnx2x_is_nvm_accessible(struct bnx2x *bp)
 	u16 pm = 0;
 	struct net_device *dev = pci_get_drvdata(bp->pdev);
 
-	if (bp->pm_cap)
+	if (bp->pdev->pm_cap)
 		rc = pci_read_config_word(bp->pdev,
-					  bp->pm_cap + PCI_PM_CTRL, &pm);
+					  bp->pdev->pm_cap + PCI_PM_CTRL, &pm);
 
 	if ((rc && !netif_running(dev)) ||
 	    (!rc && ((pm & PCI_PM_CTRL_STATE_MASK) != (__force u16)PCI_D0)))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 634a793..41d6f2d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8651,6 +8651,7 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode)
 	else if (bp->wol) {
 		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr = bp->dev->dev_addr;
+		struct pci_dev *pdev = bp->pdev;
 		u32 val;
 		u16 pmc;
 
@@ -8667,9 +8668,9 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode)
 		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
 
 		/* Enable the PME and clear the status */
-		pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmc);
+		pci_read_config_word(pdev, pdev->pm_cap + PCI_PM_CTRL, &pmc);
 		pmc |= PCI_PM_CTRL_PME_ENABLE | PCI_PM_CTRL_PME_STATUS;
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, pmc);
+		pci_write_config_word(pdev, pdev->pm_cap + PCI_PM_CTRL, pmc);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
 
@@ -10398,7 +10399,7 @@ static void bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		break;
 	}
 
-	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
+	pci_read_config_word(bp->pdev, bp->pdev->pm_cap + PCI_PM_PMC, &pmc);
 	bp->flags |= (pmc & PCI_PM_CAP_PME_D3cold) ? 0 : NO_WOL_FLAG;
 
 	BNX2X_DEV_INFO("%sWoL capable\n",
@@ -12140,8 +12141,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	}
 
 	if (IS_PF(bp)) {
-		bp->pm_cap = pdev->pm_cap;
-		if (bp->pm_cap == 0) {
+		if (!pdev->pm_cap) {
 			dev_err(&bp->pdev->dev,
 				"Cannot find power management capability, aborting\n");
 			rc = -EIO;
-- 
1.7.10.4
