From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] myri10ge: pci msi and express state save/restore
Date: Fri, 8 Dec 2006 08:52:31 -0800
Message-ID: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34687 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425640AbWLHQwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 11:52:46 -0500
To: Brice Goglin <brice@myri.com>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI MSI and express state are already saved and restored by the
current versions of pci_save_state/pci_restore_state.
Therefore it should no longer be necessary for the driver to do it.
This patch has not been tested on the hardware.

On suspend, handle pci_set_power_state errors, and on resume
handle failures in pci_resume_state().

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/myri10ge/myri10ge.c |   48 +++++++++-------------------------------
 1 file changed, 11 insertions(+), 37 deletions(-)

--- pci-x.orig/drivers/net/myri10ge/myri10ge.c
+++ pci-x/drivers/net/myri10ge/myri10ge.c
@@ -2481,34 +2481,6 @@ static void myri10ge_select_firmware(str
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
@@ -2530,10 +2502,10 @@ static int myri10ge_suspend(struct pci_d
 	}
 	myri10ge_dummy_rdma(mgp, 0);
 	free_irq(pdev->irq, mgp);
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	return 0;
+
+	return pci_set_power_state(pdev, pci_choose_state(pdev, state));
 }
 
 static int myri10ge_resume(struct pci_dev *pdev)
@@ -2555,12 +2527,14 @@ static int myri10ge_resume(struct pci_de
 		       mgp->dev->name);
 		return -EIO;
 	}
-	myri10ge_restore_state(mgp);
+	status = pci_restore_state(pdev);
+	if (status)
+		return status;
 
 	status = pci_enable_device(pdev);
-	if (status < 0) {
+	if (status) {
 		dev_err(&pdev->dev, "failed to enable device\n");
-		return -EIO;
+		return status;
 	}
 
 	pci_set_master(pdev);
@@ -2577,7 +2551,7 @@ static int myri10ge_resume(struct pci_de
 
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 
 	if (netif_running(netdev)) {
 		rtnl_lock();
@@ -2639,7 +2613,7 @@ static void myri10ge_watchdog(void *arg)
 		 * when the driver was loaded, or the last time the
 		 * nic was resumed from power saving mode.
 		 */
-		myri10ge_restore_state(mgp);
+		pci_restore_state(mgp->pdev);
 	} else {
 		/* if we get back -1's from our slot, perhaps somebody
 		 * powered off our card.  Don't try to reset it in
@@ -2880,7 +2854,7 @@ static int myri10ge_probe(struct pci_dev
 
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
-	myri10ge_save_state(mgp);
+	pci_save_state(pdev);
 
 	/* Setup the watchdog timer */
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
