From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 1/8] bnx2x: Properly release allocated MSI-X/MSI vectors
Date: Wed, 17 Feb 2010 14:03:27 +0200
Message-ID: <1266408207.25691.842.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2044 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756817Ab0BQMMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: Properly release allocated MSI-X/MSI vectors if ifup failed
due to lack of memory.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x_main.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6d85590..d7aef84 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6938,19 +6938,21 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 	}
 }
 
-static void bnx2x_free_irq(struct bnx2x *bp)
+static void bnx2x_free_irq(struct bnx2x *bp, bool disable_only)
 {
 	if (bp->flags & USING_MSIX_FLAG) {
-		bnx2x_free_msix_irqs(bp);
+		if (!disable_only)
+			bnx2x_free_msix_irqs(bp);
 		pci_disable_msix(bp->pdev);
 		bp->flags &= ~USING_MSIX_FLAG;
 
 	} else if (bp->flags & USING_MSI_FLAG) {
-		free_irq(bp->pdev->irq, bp->dev);
+		if (!disable_only)
+			free_irq(bp->pdev->irq, bp->dev);
 		pci_disable_msi(bp->pdev);
 		bp->flags &= ~USING_MSI_FLAG;
 
-	} else
+	} else if (!disable_only)
 		free_irq(bp->pdev->irq, bp->dev);
 }
 
@@ -7443,8 +7445,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	rc = bnx2x_set_num_queues(bp);
 
-	if (bnx2x_alloc_mem(bp))
+	if (bnx2x_alloc_mem(bp)) {
+		bnx2x_free_irq(bp, true);
 		return -ENOMEM;
+	}
 
 	for_each_queue(bp, i)
 		bnx2x_fp(bp, i, disable_tpa) =
@@ -7459,7 +7463,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bp->flags & USING_MSIX_FLAG) {
 		rc = bnx2x_req_msix_irqs(bp);
 		if (rc) {
-			pci_disable_msix(bp->pdev);
+			bnx2x_free_irq(bp, true);
 			goto load_error1;
 		}
 	} else {
@@ -7471,8 +7475,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		rc = bnx2x_req_irq(bp);
 		if (rc) {
 			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
-			if (bp->flags & USING_MSI_FLAG)
-				pci_disable_msi(bp->pdev);
+			bnx2x_free_irq(bp, true);
 			goto load_error1;
 		}
 		if (bp->flags & USING_MSI_FLAG) {
@@ -7664,7 +7667,7 @@ load_error3:
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 load_error2:
 	/* Release IRQs */
-	bnx2x_free_irq(bp);
+	bnx2x_free_irq(bp, false);
 load_error1:
 	bnx2x_napi_disable(bp);
 	for_each_queue(bp, i)
@@ -7855,7 +7858,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
 	/* Release IRQs */
-	bnx2x_free_irq(bp);
+	bnx2x_free_irq(bp, false);
 
 	/* Wait until tx fastpath tasks complete */
 	for_each_queue(bp, i) {
@@ -12299,7 +12302,7 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
 
 	/* Release IRQs */
-	bnx2x_free_irq(bp);
+	bnx2x_free_irq(bp, false);
 
 	if (CHIP_IS_E1(bp)) {
 		struct mac_configuration_cmd *config =
-- 
1.6.3.3




