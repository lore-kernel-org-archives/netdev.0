From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] sky2: msi enhancements.
Date: Fri, 01 Dec 2006 14:29:37 -0800
Message-ID: <20061201223220.887515687@osdl.org>
References: <20061201222931.730523290@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:30137 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162132AbWLAWev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:34:51 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-msi2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If using Message Signaled Interrupts (MSI) then the IRQ will never
be shared. Don't call pci_disable_msi() unless using MSI.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/sky2.c |   17 ++++++++++-------
 drivers/net/sky2.h |    2 +-
 2 files changed, 11 insertions(+), 8 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-12-01 14:23:33.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.c	2006-12-01 14:23:36.000000000 -0800
@@ -3311,7 +3311,7 @@
 		return IRQ_NONE;
 
 	if (status & Y2_IS_IRQ_SW) {
-		hw->msi_detected = 1;
+		hw->msi = 1;
 		wake_up(&hw->msi_wait);
 		sky2_write8(hw, B0_CTST, CS_CL_SW_IRQ);
 	}
@@ -3330,7 +3330,7 @@
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
-	err = request_irq(pdev->irq, sky2_test_intr, IRQF_SHARED, DRV_NAME, hw);
+	err = request_irq(pdev->irq, sky2_test_intr, 0, DRV_NAME, hw);
 	if (err) {
 		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
 		       pci_name(pdev), pdev->irq);
@@ -3340,9 +3340,9 @@
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
 	sky2_read8(hw, B0_CTST);
 
-	wait_event_timeout(hw->msi_wait, hw->msi_detected, HZ/10);
+	wait_event_timeout(hw->msi_wait, hw->msi, HZ/10);
 
-	if (!hw->msi_detected) {
+	if (!hw->msi) {
 		/* MSI test failed, go back to INTx mode */
 		printk(KERN_INFO PFX "%s: No interrupt generated using MSI, "
 		       "switching to INTx mode.\n",
@@ -3475,7 +3475,8 @@
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq,  sky2_intr, IRQF_SHARED, dev->name, hw);
+	err = request_irq(pdev->irq,  sky2_intr, hw->msi ? 0 : IRQF_SHARED,
+			  dev->name, hw);
 	if (err) {
 		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
 		       pci_name(pdev), pdev->irq);
@@ -3505,7 +3506,8 @@
 	return 0;
 
 err_out_unregister:
-	pci_disable_msi(pdev);
+	if (hw->msi)
+		pci_disable_msi(pdev);
 	unregister_netdev(dev);
 err_out_free_netdev:
 	free_netdev(dev);
@@ -3548,7 +3550,8 @@
 	sky2_read8(hw, B0_CTST);
 
 	free_irq(pdev->irq, hw);
-	pci_disable_msi(pdev);
+	if (hw->msi)
+		pci_disable_msi(pdev);
 	pci_free_consistent(pdev, STATUS_LE_BYTES, hw->st_le, hw->st_dma);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
--- netdev-2.6.orig/drivers/net/sky2.h	2006-12-01 14:23:30.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.h	2006-12-01 14:23:36.000000000 -0800
@@ -1900,7 +1900,7 @@
 	dma_addr_t   	     st_dma;
 
 	struct timer_list    idle_timer;
-	int		     msi_detected;
+	int		     msi;
 	wait_queue_head_t    msi_wait;
 };
 

--
Stephen Hemminger <shemminger@osdl.org>

