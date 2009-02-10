From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/4] e1000e: add aer support
Date: Tue, 10 Feb 2009 14:51:20 -0800
Message-ID: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49695 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757469AbZBJWvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:51:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

most if not all of the devices supported by e1000e support
AER (Advanced Error Reporting) so we attempt to register
with the OS that we know how to reset ourselves after
a fatal error.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   39 ++++++++++++++++++++++++++++++---------
 1 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c425b19..00e19e9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -44,6 +44,7 @@
 #include <linux/cpu.h>
 #include <linux/smp.h>
 #include <linux/pm_qos_params.h>
+#include <linux/aer.h>
 
 #include "e1000.h"
 
@@ -4521,6 +4522,14 @@ static int e1000_resume(struct pci_dev *pdev)
 		return err;
 	}
 
+	/* AER (Advanced Error Reporting) hooks */
+	err = pci_enable_pcie_error_reporting(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+		                    "0x%x\n", err);
+		/* non-fatal, continue */
+	}
+
 	pci_set_master(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
@@ -4615,24 +4624,29 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	int err;
+	pci_ers_result_t result;
 
 	e1000e_disable_l1aspm(pdev);
 	err = pci_enable_device_mem(pdev);
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
 
-	e1000e_reset(adapter);
-	ew32(WUS, ~0);
+		e1000e_reset(adapter);
+		ew32(WUS, ~0);
+		result = PCI_ERS_RESULT_RECOVERED;
+	}
 
-	return PCI_ERS_RESULT_RECOVERED;
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	return result;
 }
 
 /**
@@ -5063,6 +5077,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int err;
 
 	/*
 	 * flush_scheduled work may reschedule our watchdog task, so
@@ -5097,6 +5112,12 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
+	/* AER disable */
+	err = pci_disable_pcie_error_reporting(pdev);
+	if (err)
+		dev_err(&pdev->dev,
+		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+
 	pci_disable_device(pdev);
 }
 

