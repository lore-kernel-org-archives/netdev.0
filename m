From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH net-next 1/1] bnx2: Add PCI Advanced Error Reporting
 support.
Date: Sun, 22 Aug 2010 20:45:53 -0700
Message-ID: <1282535153-18291-2-git-send-email-benli@broadcom.com>
References: <1282535153-18291-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John Feeney" <jfeeney@redhat.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: "	netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2816 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab0HWDqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 23:46:07 -0400
In-Reply-To: <1282535153-18291-1-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Feeney <jfeeney@redhat.com>

Signed-off-by: John Feeney <jfeeney@redhat.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   44 ++++++++++++++++++++++++++++++++++----------
 1 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e6a803f..a0e02aa 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -49,6 +49,7 @@
 #include <linux/cache.h>
 #include <linux/firmware.h>
 #include <linux/log2.h>
+#include <linux/aer.h>
 
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
@@ -7890,6 +7891,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	int rc, i, j;
 	u32 reg;
 	u64 dma_mask, persist_dma_mask;
+	int err;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp = netdev_priv(dev);
@@ -7925,6 +7927,14 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_disable;
 	}
 
+	/* AER (Advanced Error Reporting) hooks */
+	err = pci_enable_pcie_error_reporting(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+				    "0x%x\n", err);
+		/* non-fatal, continue */
+	}
+
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -8246,6 +8256,7 @@ err_out_unmap:
 	}
 
 err_out_release:
+	pci_disable_pcie_error_reporting(pdev);
 	pci_release_regions(pdev);
 
 err_out_disable:
@@ -8436,6 +8447,9 @@ bnx2_remove_one(struct pci_dev *pdev)
 	kfree(bp->temp_stats_blk);
 
 	free_netdev(dev);
+
+	pci_disable_pcie_error_reporting(pdev);
+
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -8527,25 +8541,35 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
+	pci_ers_result_t result;
+	int err;
 
 	rtnl_lock();
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset\n");
-		rtnl_unlock();
-		return PCI_ERS_RESULT_DISCONNECT;
+		result = PCI_ERS_RESULT_DISCONNECT;
+	} else {
+		pci_set_master(pdev);
+		pci_restore_state(pdev);
+		pci_save_state(pdev);
+
+		if (netif_running(dev)) {
+			bnx2_set_power_state(bp, PCI_D0);
+			bnx2_init_nic(bp, 1);
+		}
+		result = PCI_ERS_RESULT_RECOVERED;
 	}
-	pci_set_master(pdev);
-	pci_restore_state(pdev);
-	pci_save_state(pdev);
+	rtnl_unlock();
 
-	if (netif_running(dev)) {
-		bnx2_set_power_state(bp, PCI_D0);
-		bnx2_init_nic(bp, 1);
+	err = pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"pci_cleanup_aer_uncorrect_error_status failed 0x%0x\n",
+			 err); /* non-fatal, continue */
 	}
 
-	rtnl_unlock();
-	return PCI_ERS_RESULT_RECOVERED;
+	return result;
 }
 
 /**
-- 
1.6.1.2


