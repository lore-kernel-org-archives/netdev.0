From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT v2 PATCH] ixgbe: Implement PCIe AER support
Date: Tue, 09 Dec 2008 18:44:23 -0800
Message-ID: <20081210024423.27657.32266.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:34688 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754062AbYLJCol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 21:44:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch implements the PCIe Advanced Error Reporting callbacks in
ixgbe.  The 82598 hardware supports AER, so we enable it.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   41 ++++++++++++++++++++++++++++++++--------
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 6cbf26e..e112008 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -32,6 +32,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/inet_lro.h>
+#include <linux/aer.h>
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a7aa892..d6f666a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4020,6 +4020,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
+	err = pci_enable_pcie_error_reporting(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+		                    "0x%x\n", err);
+		/* non-fatal, continue */
+	}
+
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -4257,6 +4264,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int err;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	/* clear the module not found bit to make sure the worker won't
@@ -4295,6 +4303,11 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
+	err = pci_disable_pcie_error_reporting(pdev);
+	if (err)
+		dev_err(&pdev->dev,
+		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+
 	pci_disable_device(pdev);
 }
 
@@ -4332,21 +4345,33 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	pci_ers_result_t result;
+	int err;
 
 	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR,
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
 
-	ixgbe_reset(adapter);
+		ixgbe_reset(adapter);
+
+		result = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	err = pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (err) {
+		dev_err(&pdev->dev,
+		  "pci_cleanup_aer_uncorrect_error_status failed 0x%0x\n", err);
+		/* non-fatal, continue */
+	}
 
-	return PCI_ERS_RESULT_RECOVERED;
+	return result;
 }
 
 /**

