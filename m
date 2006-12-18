From: Brice Goglin <brice@myri.com>
Subject: [PATCH 4/5] myri10ge: no need to save MSI and PCIe state in the driver
Date: Mon, 18 Dec 2006 11:52:02 +0100
Message-ID: <458672D2.3050505@myri.com>
References: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41358 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753841AbWLRLVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:41 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <45867228.1090406@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI MSI and express state are already saved and restored by the
current versions of pci_save_state/pci_restore_state.
Therefore it is no longer necessary for the driver to do it.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/myri10ge/myri10ge.c |   47 +++++++---------------------------------
 1 file changed, 9 insertions(+), 38 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-12-18 10:28:30.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-12-18 10:32:05.000000000 +0100
@@ -199,8 +199,6 @@
 	unsigned long serial_number;
 	int vendor_specific_offset;
 	int fw_multicast_support;
-	u32 devctl;
-	u16 msi_flags;
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;
@@ -2520,34 +2518,6 @@
 	}
 }
 
-static void myri10ge_save_state(struct myri10ge_priv *mgp)
-{
-	struct pci_dev *pdev = mgp->pdev;
-	int cap;
-
-	pci_save_state(pdev);
-	/* now save PCIe and MSI state that Linux will not
-	 * save for us */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	pci_read_config_dword(pdev, cap + PCI_EXP_DEVCTL, &mgp->devctl);
-	cap = pci_find_capability(pdev, PCI_CAP_ID_MSI);
-	pci_read_config_word(pdev, cap + PCI_MSI_FLAGS, &mgp->msi_flags);
-}
-
-static void myri10ge_restore_state(struct myri10ge_priv *mgp)
-{
-	struct pci_dev *pdev = mgp->pdev;
-	int cap;
-
-	/* restore PCIe and MSI state that linux will not */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	pci_write_config_dword(pdev, cap + PCI_CAP_ID_EXP, mgp->devctl);
-	cap = pci_find_capability(pdev, PCI_CAP_ID_MSI);
-	pci_write_config_word(pdev, cap + PCI_MSI_FLAGS, mgp->msi_flags);
-
-	pci_restore_state(pdev);
-}
-
 #ifdef CONFIG_PM
 
 static int myri10ge_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -2568,7 +2538,7 @@
 		rtnl_unlock();
 	}
 	myri10ge_dummy_rdma(mgp, 0);
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	return 0;
@@ -2593,7 +2563,8 @@
 		       mgp->dev->name);
 		return -EIO;
 	}
-	myri10ge_restore_state(mgp);
+
+	pci_restore_state(pdev);
 
 	status = pci_enable_device(pdev);
 	if (status < 0) {
@@ -2608,7 +2579,7 @@
 
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 
 	if (netif_running(netdev)) {
 		rtnl_lock();
@@ -2674,10 +2645,10 @@
 		 * when the driver was loaded, or the last time the
 		 * nic was resumed from power saving mode.
 		 */
-		myri10ge_restore_state(mgp);
+		pci_restore_state(mgp->pdev);
 
 		/* save state again for accounting reasons */
-		myri10ge_save_state(mgp);
+		pci_save_state(mgp->pdev);
 
 	} else {
 		/* if we get back -1's from our slot, perhaps somebody
@@ -2917,7 +2888,7 @@
 
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 
 	/* Setup the watchdog timer */
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
@@ -2937,7 +2908,7 @@
 	return 0;
 
 abort_with_state:
-	myri10ge_restore_state(mgp);
+	pci_restore_state(pdev);
 
 abort_with_firmware:
 	myri10ge_dummy_rdma(mgp, 0);
@@ -2992,7 +2963,7 @@
 	myri10ge_dummy_rdma(mgp, 0);
 
 	/* avoid a memory leak */
-	myri10ge_restore_state(mgp);
+	pci_restore_state(pdev);
 
 	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,


