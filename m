From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] igb: Add support for pci-e Advanced Error Reporting
Date: Wed, 26 Nov 2008 16:04:41 -0800
Message-ID: <20081127000441.22613.99805.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:45244 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753248AbYK0AE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:04:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add the calls necessary to enable advanced error reporting for igb on
systems with AER enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0919a2f..ea4ef18 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -42,6 +42,7 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
+#include <linux/aer.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
@@ -1049,6 +1050,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_pci_reg;
 
+	pci_enable_pcie_error_reporting(pdev);
+
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -1379,6 +1382,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
+	pci_disable_pcie_error_reporting(pdev);
+
 	pci_disable_device(pdev);
 }
 
@@ -4474,27 +4479,33 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	pci_ers_result_t result;
 	int err;
 
 	if (adapter->need_ioport)
 		err = pci_enable_device(pdev);
 	else
 		err = pci_enable_device_mem(pdev);
+
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
-		return PCI_ERS_RESULT_DISCONNECT;
-	}
-	pci_set_master(pdev);
-	pci_restore_state(pdev);
+		result = PCI_ERS_RESULT_DISCONNECT;
+	} else {
+		pci_set_master(pdev);
+		pci_restore_state(pdev);
 
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	igb_reset(adapter);
-	wr32(E1000_WUS, ~0);
+		igb_reset(adapter);
+		wr32(E1000_WUS, ~0);
+		result = PCI_ERS_RESULT_RECOVERED;
+	}
 
-	return PCI_ERS_RESULT_RECOVERED;
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	return result;
 }
 
 /**
@@ -4522,7 +4533,6 @@ static void igb_io_resume(struct pci_dev *pdev)
 	/* let the f/w know that the h/w is now under the control of the
 	 * driver. */
 	igb_get_hw_control(adapter);
-
 }
 
 /* igb_main.c */

