From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] skge: use dev_printk
Date: Fri, 02 Feb 2007 08:22:52 -0800
Message-ID: <20070202162419.151564000@linux-foundation.org>
References: <20070202162250.980620000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56914 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945977AbXBBQ2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 11:28:47 -0500
Content-Disposition: inline; filename=skge-dev-printk.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_printk related macros for PCI related errors and warnings

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -2395,7 +2395,7 @@ static int skge_up(struct net_device *de
 	BUG_ON(skge->dma & 7);
 
 	if ((u64)skge->dma >> 32 != ((u64) skge->dma + skge->mem_size) >> 32) {
-		printk(KERN_ERR PFX "pci_alloc_consistent region crosses 4G boundary\n");
+		dev_err(&hw->pdev->dev, "pci_alloc_consistent region crosses 4G boundary\n");
 		err = -EINVAL;
 		goto free_pci_mem;
 	}
@@ -3004,6 +3004,7 @@ static void skge_mac_intr(struct skge_hw
 /* Handle device specific framing and timeout interrupts */
 static void skge_error_irq(struct skge_hw *hw)
 {
+	struct pci_dev *pdev = hw->pdev;
 	u32 hwstatus = skge_read32(hw, B0_HWE_ISRC);
 
 	if (hw->chip_id == CHIP_ID_GENESIS) {
@@ -3019,12 +3020,12 @@ static void skge_error_irq(struct skge_h
 	}
 
 	if (hwstatus & IS_RAM_RD_PAR) {
-		printk(KERN_ERR PFX "Ram read data parity error\n");
+		dev_err(&pdev->dev, "Ram read data parity error\n");
 		skge_write16(hw, B3_RI_CTRL, RI_CLR_RD_PERR);
 	}
 
 	if (hwstatus & IS_RAM_WR_PAR) {
-		printk(KERN_ERR PFX "Ram write data parity error\n");
+		dev_err(&pdev->dev, "Ram write data parity error\n");
 		skge_write16(hw, B3_RI_CTRL, RI_CLR_WR_PERR);
 	}
 
@@ -3035,38 +3036,38 @@ static void skge_error_irq(struct skge_h
 		skge_mac_parity(hw, 1);
 
 	if (hwstatus & IS_R1_PAR_ERR) {
-		printk(KERN_ERR PFX "%s: receive queue parity error\n",
-		       hw->dev[0]->name);
+		dev_err(&pdev->dev, "%s: receive queue parity error\n",
+			hw->dev[0]->name);
 		skge_write32(hw, B0_R1_CSR, CSR_IRQ_CL_P);
 	}
 
 	if (hwstatus & IS_R2_PAR_ERR) {
-		printk(KERN_ERR PFX "%s: receive queue parity error\n",
-		       hw->dev[1]->name);
+		dev_err(&pdev->dev, "%s: receive queue parity error\n",
+			hw->dev[1]->name);
 		skge_write32(hw, B0_R2_CSR, CSR_IRQ_CL_P);
 	}
 
 	if (hwstatus & (IS_IRQ_MST_ERR|IS_IRQ_STAT)) {
 		u16 pci_status, pci_cmd;
 
-		pci_read_config_word(hw->pdev, PCI_COMMAND, &pci_cmd);
-		pci_read_config_word(hw->pdev, PCI_STATUS, &pci_status);
+		pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
+		pci_read_config_word(pdev, PCI_STATUS, &pci_status);
 
-		printk(KERN_ERR PFX "%s: PCI error cmd=%#x status=%#x\n",
-			       pci_name(hw->pdev), pci_cmd, pci_status);
+		dev_err(&pdev->dev, "PCI error cmd=%#x status=%#x\n",
+			pci_cmd, pci_status);
 
 		/* Write the error bits back to clear them. */
 		pci_status &= PCI_STATUS_ERROR_BITS;
 		skge_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
-		pci_write_config_word(hw->pdev, PCI_COMMAND,
+		pci_write_config_word(pdev, PCI_COMMAND,
 				      pci_cmd | PCI_COMMAND_SERR | PCI_COMMAND_PARITY);
-		pci_write_config_word(hw->pdev, PCI_STATUS, pci_status);
+		pci_write_config_word(pdev, PCI_STATUS, pci_status);
 		skge_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 		/* if error still set then just ignore it */
 		hwstatus = skge_read32(hw, B0_HWE_ISRC);
 		if (hwstatus & IS_IRQ_STAT) {
-			printk(KERN_INFO PFX "unable to clear error (so ignoring them)\n");
+			dev_warn(&hw->pdev->dev, "unable to clear error (so ignoring them)\n");
 			hw->intr_mask &= ~IS_HW_ERR;
 		}
 	}
@@ -3280,8 +3281,8 @@ static int skge_reset(struct skge_hw *hw
 			hw->phy_addr = PHY_ADDR_BCOM;
 			break;
 		default:
-			printk(KERN_ERR PFX "%s: unsupported phy type 0x%x\n",
-			       pci_name(hw->pdev), hw->phy_type);
+			dev_err(&hw->pdev->dev, "unsupported phy type 0x%x\n",
+			       hw->phy_type);
 			return -EOPNOTSUPP;
 		}
 		break;
@@ -3296,8 +3297,8 @@ static int skge_reset(struct skge_hw *hw
 		break;
 
 	default:
-		printk(KERN_ERR PFX "%s: unsupported chip type 0x%x\n",
-		       pci_name(hw->pdev), hw->chip_id);
+		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
+		       hw->chip_id);
 		return -EOPNOTSUPP;
 	}
 
@@ -3337,7 +3338,7 @@ static int skge_reset(struct skge_hw *hw
 		/* avoid boards with stuck Hardware error bits */
 		if ((skge_read32(hw, B0_ISRC) & IS_HW_ERR) &&
 		    (skge_read32(hw, B0_HWE_ISRC) & IS_IRQ_SENSOR)) {
-			printk(KERN_WARNING PFX "stuck hardware sensor bit\n");
+			dev_warn(&hw->pdev->dev, "stuck hardware sensor bit\n");
 			hw->intr_mask &= ~IS_HW_ERR;
 		}
 
@@ -3411,7 +3412,7 @@ static struct net_device *skge_devinit(s
 	struct net_device *dev = alloc_etherdev(sizeof(*skge));
 
 	if (!dev) {
-		printk(KERN_ERR "skge etherdev alloc failed");
+		dev_err(&hw->pdev->dev, "etherdev alloc failed\n");
 		return NULL;
 	}
 
@@ -3499,15 +3500,13 @@ static int __devinit skge_probe(struct p
 
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
 		goto err_out_disable_pdev;
 	}
 
@@ -3522,8 +3521,7 @@ static int __devinit skge_probe(struct p
 	}
 
 	if (err) {
-		printk(KERN_ERR PFX "%s no usable DMA configuration\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "no usable DMA configuration\n");
 		goto err_out_free_regions;
 	}
 
@@ -3541,8 +3539,7 @@ static int __devinit skge_probe(struct p
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
-		printk(KERN_ERR PFX "%s: cannot allocate hardware struct\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot allocate hardware struct\n");
 		goto err_out_free_regions;
 	}
 
@@ -3553,8 +3550,7 @@ static int __devinit skge_probe(struct p
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
-		printk(KERN_ERR PFX "%s: cannot map device registers\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot map device registers\n");
 		goto err_out_free_hw;
 	}
 
@@ -3571,21 +3567,18 @@ static int __devinit skge_probe(struct p
 		goto err_out_led_off;
 
 	/* Some motherboards are broken and has zero in ROM. */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING PFX "%s: bad (zero?) ethernet address in rom\n",
-		       pci_name(pdev));
-	}
+	if (!is_valid_ether_addr(dev->dev_addr))
+		dev_warn(&pdev->dev, "bad (zero?) ethernet address in rom\n");
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot register net device\n",
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "cannot register net device\n");
 		goto err_out_free_netdev;
 	}
 
 	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
+		dev_err(&pdev->dev, "%s: cannot assign irq %d\n",
 		       dev->name, pdev->irq);
 		goto err_out_unregister;
 	}
@@ -3596,7 +3589,7 @@ static int __devinit skge_probe(struct p
 			skge_show_addr(dev1);
 		else {
 			/* Failure to register second port need not be fatal */
-			printk(KERN_WARNING PFX "register of second port failed\n");
+			dev_warn(&pdev->dev, "register of second port failed\n");
 			hw->dev[1] = NULL;
 			free_netdev(dev1);
 		}

-- 

