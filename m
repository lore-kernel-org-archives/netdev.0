From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/6 net-next] bnx2: Use kernel APIs for WoL and power
 state changes.
Date: Tue, 6 Aug 2013 15:50:08 -0700
Message-ID: <1375829412-26425-3-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
 <1375829412-26425-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4089 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756672Ab3HFW2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:14 -0400
In-Reply-To: <1375829412-26425-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple API changes with no functional changes.

Signed-off-by: Michael Chan <mchan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   36 +++++++++++++--------------------
 1 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 3baf8b5..ac72f80 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3911,21 +3911,12 @@ init_cpu_err:
 static int
 bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 {
-	u16 pmcsr;
-
-	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmcsr);
-
 	switch (state) {
 	case PCI_D0: {
 		u32 val;
 
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
-			(pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
-			PCI_PM_CTRL_PME_STATUS);
-
-		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
-			/* delay required during transition out of D3hot */
-			msleep(20);
+		pci_enable_wake(bp->pdev, PCI_D0, false);
+		pci_set_power_state(bp->pdev, PCI_D0);
 
 		val = BNX2_RD(bp, BNX2_EMAC_MODE);
 		val |= BNX2_EMAC_MODE_MPKT_RCVD | BNX2_EMAC_MODE_ACPI_RCVD;
@@ -4018,26 +4009,19 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 			bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg,
 				     1, 0);
 
-		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
+		pci_wake_from_d3(bp->pdev, bp->wol);
 		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
 		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1)) {
 
 			if (bp->wol)
-				pmcsr |= 3;
-		}
-		else {
-			pmcsr |= 3;
-		}
-		if (bp->wol) {
-			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
+				pci_set_power_state(bp->pdev, PCI_D3hot);
+		} else {
+			pci_set_power_state(bp->pdev, PCI_D3hot);
 		}
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
-				      pmcsr);
 
 		/* No more memory access after this point until
 		 * device is brought back to D0.
 		 */
-		udelay(50);
 		break;
 	}
 	default:
@@ -7081,6 +7065,9 @@ bnx2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	else {
 		bp->wol = 0;
 	}
+
+	device_set_wakeup_enable(&bp->pdev->dev, bp->wol);
+
 	return 0;
 }
 
@@ -8369,6 +8356,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->wol = 0;
 	}
 
+	if (bp->flags & BNX2_FLAG_NO_WOL)
+		device_set_wakeup_capable(&bp->pdev->dev, false);
+	else
+		device_set_wakeup_enable(&bp->pdev->dev, bp->wol);
+
 	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 		bp->tx_quick_cons_trip_int =
 			bp->tx_quick_cons_trip;
-- 
1.7.1
