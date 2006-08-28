From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] skge: use ethX for irq assigments
Date: Mon, 28 Aug 2006 16:19:38 -0700
Message-ID: <20060828232038.481808299@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32390 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964891AbWH1Xai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:30:38 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-eth-name.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The user level irq balance daemon uses "eth" as a way to distinquish
ethernet devices. Also, by using device name it is possible to distinquish
different boards.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -3343,23 +3343,16 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_hw;
 	}
 
-	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, DRV_NAME, hw);
-	if (err) {
-		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
-		       pci_name(pdev), pdev->irq);
-		goto err_out_iounmap;
-	}
-	pci_set_drvdata(pdev, hw);
-
 	err = skge_reset(hw);
 	if (err)
-		goto err_out_free_irq;
+		goto err_out_iounmap;
 
 	printk(KERN_INFO PFX DRV_VERSION " addr 0x%llx irq %d chip %s rev %d\n",
 	       (unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
 	       skge_board_name(hw), hw->chip_rev);
 
-	if ((dev = skge_devinit(hw, 0, using_dac)) == NULL)
+	dev = skge_devinit(hw, 0, using_dac);
+	if (!dev)
 		goto err_out_led_off;
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
@@ -3369,7 +3362,6 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_netdev;
 	}
 
-
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "%s: cannot register net device\n",
@@ -3377,6 +3369,12 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_netdev;
 	}
 
+	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
+	if (err) {
+		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
+		       dev->name, pdev->irq);
+		goto err_out_unregister;
+	}
 	skge_show_addr(dev);
 
 	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {
@@ -3389,15 +3387,16 @@ static int __devinit skge_probe(struct p
 			free_netdev(dev1);
 		}
 	}
+	pci_set_drvdata(pdev, hw);
 
 	return 0;
 
+err_out_unregister:
+	unregister_netdev(dev);
 err_out_free_netdev:
 	free_netdev(dev);
 err_out_led_off:
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
-err_out_free_irq:
-	free_irq(pdev->irq, hw);
 err_out_iounmap:
 	iounmap(hw->regs);
 err_out_free_hw:

--
Stephen Hemminger <shemminger@osdl.org>

