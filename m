From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2 net-next] bnx2: Enable AER on PCIE devices only
Date: Thu, 7 Oct 2010 16:42:53 -0700
Message-ID: <1286494973-5115-2-git-send-email-mchan@broadcom.com>
References: <1286494973-5115-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4289 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461Ab0JHAkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 20:40:18 -0400
In-Reply-To: <1286494973-5115-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent unnecessary error message.  pci_save_state() is also moved to
the end of ->probe() so that all PCI config, including AER state, will be
saved.

Update version to 2.0.18.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 56f3dfe..ae894bc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -59,8 +59,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.0.17"
-#define DRV_MODULE_RELDATE	"July 18, 2010"
+#define DRV_MODULE_VERSION	"2.0.18"
+#define DRV_MODULE_RELDATE	"Oct 7, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.0.15.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.0.17.fw"
@@ -7915,16 +7915,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_disable;
 	}
 
-	/* AER (Advanced Error Reporting) hooks */
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-				    "0x%x\n", err);
-		/* non-fatal, continue */
-	}
-
 	pci_set_master(pdev);
-	pci_save_state(pdev);
 
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
@@ -7979,6 +7970,15 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->flags |= BNX2_FLAG_PCIE;
 		if (CHIP_REV(bp) == CHIP_REV_Ax)
 			bp->flags |= BNX2_FLAG_JUMBO_BROKEN;
+
+		/* AER (Advanced Error Reporting) hooks */
+		err = pci_enable_pcie_error_reporting(pdev);
+		if (err) {
+			dev_err(&pdev->dev, "pci_enable_pcie_error_reporting "
+					    "failed 0x%x\n", err);
+			/* non-fatal, continue */
+		}
+
 	} else {
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
 		if (bp->pcix_cap == 0) {
@@ -8235,16 +8235,20 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2_timer;
 
+	pci_save_state(pdev);
+
 	return 0;
 
 err_out_unmap:
+	if (bp->flags & BNX2_FLAG_PCIE)
+		pci_disable_pcie_error_reporting(pdev);
+
 	if (bp->regview) {
 		iounmap(bp->regview);
 		bp->regview = NULL;
 	}
 
 err_out_release:
-	pci_disable_pcie_error_reporting(pdev);
 	pci_release_regions(pdev);
 
 err_out_disable:
@@ -8434,9 +8438,10 @@ bnx2_remove_one(struct pci_dev *pdev)
 
 	kfree(bp->temp_stats_blk);
 
-	free_netdev(dev);
+	if (bp->flags & BNX2_FLAG_PCIE)
+		pci_disable_pcie_error_reporting(pdev);
 
-	pci_disable_pcie_error_reporting(pdev);
+	free_netdev(dev);
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
@@ -8550,6 +8555,9 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 	}
 	rtnl_unlock();
 
+	if (!(bp->flags & BNX2_FLAG_PCIE))
+		return result;
+
 	err = pci_cleanup_aer_uncorrect_error_status(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
-- 
1.6.4.GIT


