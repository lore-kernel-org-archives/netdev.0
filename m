From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] igb: fixup AER with proper error handling
Date: Thu, 11 Dec 2008 15:08:30 -0800
Message-ID: <20081211230830.1649.11762.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:33502
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757467AbYLKXIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 18:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on Peter Waskiewicz patch for ixgbe.  Add error handling based on
Hemminger's recommendation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/igb/igb_main.c |   20 +++++++++++++++++---
 1 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index dad742f..25df7c9 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1050,7 +1050,12 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_pci_reg;
 
-	pci_enable_pcie_error_reporting(pdev);
+	err = pci_enable_pcie_error_reporting(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+		        "0x%x\n", err);
+		/* non-fatal, continue */
+	}
 
 	pci_set_master(pdev);
 	pci_save_state(pdev);
@@ -1343,6 +1348,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 #ifdef CONFIG_IGB_DCA
 	struct e1000_hw *hw = &adapter->hw;
 #endif
+	int err;
 
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */
@@ -1382,7 +1388,10 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	pci_disable_pcie_error_reporting(pdev);
+	err = pci_disable_pcie_error_reporting(pdev);
+	if (err)
+		dev_err(&pdev->dev,
+		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
 
 	pci_disable_device(pdev);
 }
@@ -4495,7 +4504,12 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 		result = PCI_ERS_RESULT_RECOVERED;
 	}
 
-	pci_cleanup_aer_uncorrect_error_status(pdev);
+	err = pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_cleanup_aer_uncorrect_error_status "
+		        "failed 0x%0x\n", err);
+		/* non-fatal, continue */
+	}
 
 	return result;
 }

