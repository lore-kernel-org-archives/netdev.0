From: shemminger@linux-foundation.org
Subject: [PATCH 3/5] sky2: use dev_err for error reports
Date: Fri, 26 Jan 2007 11:38:38 -0800
Message-ID: <20070126194004.223997000@linux-foundation.org>
References: <20070126193835.658962000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52094 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161237AbXAZTrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:47:55 -0500
Content-Disposition: inline; filename=sky2-dev-printk.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the standard dev_printk functions instead of printk directly for
error reports. Fix a bug where the initialization would return 0
if allocation of network device failed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   75 +++++++++++++++++++++--------------------------------
 1 file changed, 31 insertions(+), 44 deletions(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2007-01-26 11:27:29.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2007-01-26 11:27:40.000000000 -0800
@@ -2261,8 +2261,8 @@
 
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: pci hw error (0x%x)\n",
-			       pci_name(hw->pdev), pci_err);
+			dev_err(&hw->pdev->dev, "PCI hardware error (0x%x)\n",
+			        pci_err);
 
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write16(hw, PCI_STATUS,
@@ -2277,8 +2277,8 @@
 		pex_err = sky2_pci_read32(hw, PEX_UNC_ERR_STAT);
 
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: pci express error (0x%x)\n",
-			       pci_name(hw->pdev), pex_err);
+			dev_err(&hw->pdev->dev, "PCI Express error (0x%x)\n",
+				pex_err);
 
 		/* clear the interrupt */
 		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
@@ -2474,8 +2474,8 @@
 
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
 	if (hw->chip_id < CHIP_ID_YUKON_XL || hw->chip_id > CHIP_ID_YUKON_FE) {
-		printk(KERN_ERR PFX "%s: unsupported chip type 0x%x\n",
-		       pci_name(hw->pdev), hw->chip_id);
+		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
+			hw->chip_id);
 		return -EOPNOTSUPP;
 	}
 
@@ -2483,9 +2483,9 @@
 
 	/* This rev is really old, and requires untested workarounds */
 	if (hw->chip_id == CHIP_ID_YUKON_EC && hw->chip_rev == CHIP_REV_YU_EC_A1) {
-		printk(KERN_ERR PFX "%s: unsupported revision Yukon-%s (0x%x) rev %d\n",
-		       pci_name(hw->pdev), yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
-		       hw->chip_id, hw->chip_rev);
+		dev_err(&hw->pdev->dev, "unsupported revision Yukon-%s (0x%x) rev %d\n",
+			yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
+			hw->chip_id, hw->chip_rev);
 		return -EOPNOTSUPP;
 	}
 
@@ -3309,7 +3309,7 @@
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
 
 	if (!dev) {
-		printk(KERN_ERR "sky2 etherdev alloc failed");
+		dev_err(&hw->pdev->dev, "etherdev alloc failed");
 		return NULL;
 	}
 
@@ -3426,8 +3426,7 @@
 
 	err = request_irq(pdev->irq, sky2_test_intr, 0, DRV_NAME, hw);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
-		       pci_name(pdev), pdev->irq);
+		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
 		return err;
 	}
 
@@ -3438,9 +3437,8 @@
 
 	if (!hw->msi) {
 		/* MSI test failed, go back to INTx mode */
-		printk(KERN_INFO PFX "%s: No interrupt generated using MSI, "
-		       "switching to INTx mode.\n",
-		       pci_name(pdev));
+		dev_info(&pdev->dev, "No interrupt generated using MSI, "
+			 "switching to INTx mode.\n");
 
 		err = -EOPNOTSUPP;
 		sky2_write8(hw, B0_CTST, CS_CL_SW_IRQ);
@@ -3475,15 +3473,13 @@
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "%s cannot enable PCI device\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot enable PCI device\n");
 		goto err_out;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "%s cannot obtain PCI resources\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
 		goto err_out;
 	}
 
@@ -3494,16 +3490,14 @@
 		using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
 		if (err < 0) {
-			printk(KERN_ERR PFX "%s unable to obtain 64 bit DMA "
-			       "for consistent allocations\n", pci_name(pdev));
+			dev_err(&pdev->dev, "unable to obtain 64 bit DMA "
+				"for consistent allocations\n");
 			goto err_out_free_regions;
 		}
-
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
-			printk(KERN_ERR PFX "%s no usable DMA configuration\n",
-			       pci_name(pdev));
+			dev_err(&pdev->dev, "no usable DMA configuration\n");
 			goto err_out_free_regions;
 		}
 	}
@@ -3513,8 +3507,7 @@
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
-		printk(KERN_ERR PFX "%s: cannot allocate hardware struct\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot allocate hardware struct\n");
 		goto err_out_free_regions;
 	}
 
@@ -3522,8 +3515,7 @@
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
-		printk(KERN_ERR PFX "%s: cannot map device registers\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot map device registers\n");
 		goto err_out_free_hw;
 	}
 
@@ -3549,7 +3541,7 @@
 	if (err)
 		goto err_out_iounmap;
 
-	printk(KERN_INFO PFX "v%s addr 0x%llx irq %d Yukon-%s (0x%x) rev %d\n",
+	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-%s (0x%x) rev %d\n",
 	       DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
 	       pdev->irq, yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
 	       hw->chip_id, hw->chip_rev);
@@ -3572,16 +3564,14 @@
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot register net device\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot register net device\n");
 		goto err_out_free_netdev;
 	}
 
 	err = request_irq(pdev->irq,  sky2_intr, hw->msi ? 0 : IRQF_SHARED,
 			  dev->name, hw);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
-		       pci_name(pdev), pdev->irq);
+		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
 		goto err_out_unregister;
 	}
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
@@ -3592,18 +3582,15 @@
 		struct net_device *dev1;
 
 		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
-		if (!dev1) {
-			printk(KERN_WARNING PFX
-			       "allocation of second port failed\n");
-		}
-		else if (!(err = register_netdev(dev1)))
-			sky2_show_addr(dev1);
-		else {
-			printk(KERN_WARNING PFX
-			       "register of second port failed (%d)\n", err);
+		if (!dev1)
+			dev_warn(&pdev->dev, "allocation for second device failed\n");
+		else if ((err = register_netdev(dev1))) {
+			dev_warn(&pdev->dev,
+				 "register of second port failed (%d)\n", err);
 			hw->dev[1] = NULL;
 			free_netdev(dev1);
-		}
+		} else
+			sky2_show_addr(dev1);
 	}
 
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
@@ -3741,7 +3728,7 @@
 	sky2_idle_start(hw);
 	return 0;
 out:
-	printk(KERN_ERR PFX "%s: resume failed (%d)\n", pci_name(pdev), err);
+	dev_err(&pdev->dev, "resume failed (%d)\n", err);
 	pci_disable_device(pdev);
 	return err;
 }

--
Stephen Hemminger <shemminger@linux-foundation.org>

