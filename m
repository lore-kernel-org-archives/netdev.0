From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: Implement PCIe AER support
Date: Mon, 01 Dec 2008 16:41:15 -0800
Message-ID: <20081202004115.12058.64881.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:60835 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYLBAld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 19:41:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch implements the PCIe Advanced Error Reporting callbacks in
ixgbe.  The 82598 hardware supports AER, so we enable it.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   26 ++++++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

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
index e014a73..e9cb430 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4021,6 +4021,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
+	pci_enable_pcie_error_reporting(pdev);
+
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -4296,6 +4298,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
+	pci_disable_pcie_error_reporting(pdev);
+
 	pci_disable_device(pdev);
 }
 
@@ -4333,21 +4337,27 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	pci_ers_result_t result;
 
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
+	pci_cleanup_aer_uncorrect_error_status(pdev);
 
-	return PCI_ERS_RESULT_RECOVERED;
+	return result;
 }
 
 /**

