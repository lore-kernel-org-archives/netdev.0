From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] skge: cleanup suspend/resume code
Date: Mon, 28 Aug 2006 16:19:35 -0700
Message-ID: <20060828232037.850476637@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13191 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964897AbWH1Xct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:32:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-suspend.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code for suspend/resume needs several fixes. The hardware lock
should be setup in probe only, not in resume. Interrupts should be
disabled during suspend, etc.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -3106,7 +3106,6 @@ static int skge_reset(struct skge_hw *hw
 	else
 		hw->ram_size = t8 * 4096;
 
-	spin_lock_init(&hw->hw_lock);
 	hw->intr_mask = IS_HW_ERR | IS_EXT_REG | IS_PORT_1;
 	if (hw->ports > 1)
 		hw->intr_mask |= IS_PORT_2;
@@ -3332,6 +3331,7 @@ static int __devinit skge_probe(struct p
 	hw->pdev = pdev;
 	mutex_init(&hw->phy_mutex);
 	INIT_WORK(&hw->phy_work, skge_extirq, hw);
+	spin_lock_init(&hw->hw_lock);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -3449,26 +3449,25 @@ static int skge_suspend(struct pci_dev *
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
-	for (i = 0; i < 2; i++) {
+	pci_save_state(pdev);
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
-		if (dev) {
+		if (netif_running(dev)) {
 			struct skge_port *skge = netdev_priv(dev);
-			if (netif_running(dev)) {
-				netif_carrier_off(dev);
-				if (skge->wol)
-					netif_stop_queue(dev);
-				else
-					skge_down(dev);
-			}
-			netif_device_detach(dev);
+
+			netif_carrier_off(dev);
+			if (skge->wol)
+				netif_stop_queue(dev);
+			else
+				skge_down(dev);
 			wol |= skge->wol;
 		}
+		netif_device_detach(dev);
 	}
 
-	pci_save_state(pdev);
+	skge_write32(hw, B0_IMSK, 0);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
@@ -3477,23 +3476,33 @@ static int skge_suspend(struct pci_dev *
 static int skge_resume(struct pci_dev *pdev)
 {
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
-	int i;
+	int i, err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	skge_reset(hw);
+	err = skge_reset(hw);
+	if (err)
+		goto out;
 
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
-		if (dev) {
-			netif_device_attach(dev);
-			if (netif_running(dev) && skge_up(dev))
+
+		netif_device_attach(dev);
+		if (netif_running(dev)) {
+			err = skge_up(dev);
+
+			if (err) {
+				printk(KERN_ERR PFX "%s: could not up: %d\n",
+				       dev->name, err);
 				dev_close(dev);
+				goto out;
+			}
 		}
 	}
-	return 0;
+out:
+	return err;
 }
 #endif
 

--
Stephen Hemminger <shemminger@osdl.org>

