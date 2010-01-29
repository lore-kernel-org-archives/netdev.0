From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/13] tulip_core: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:17 -0800
Message-ID: <877c95d546d20450e77b5dc3a4f6191a87c676c7.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1578 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753872Ab0A2G7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:30 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where appropriate
Convert printks to pr_<level>
Change print formats with %d.dx to %0dx
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/tulip_core.c |  162 ++++++++++++++++++++--------------------
 1 files changed, 82 insertions(+), 80 deletions(-)

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index da4fc45..e1a5f03 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -41,7 +41,6 @@
 static char version[] __devinitdata =
 	"Linux Tulip driver version " DRV_VERSION " (" DRV_RELDATE ")\n";
 
-
 /* A few user-configurable values. */
 
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
@@ -326,7 +325,8 @@ static void tulip_up(struct net_device *dev)
 	udelay(100);
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: tulip_up(), irq==%d.\n", dev->name, dev->irq);
+		printk(KERN_DEBUG "%s: tulip_up(), irq==%d\n",
+		       dev->name, dev->irq);
 
 	iowrite32(tp->rx_ring_dma, ioaddr + CSR3);
 	iowrite32(tp->tx_ring_dma, ioaddr + CSR4);
@@ -387,8 +387,9 @@ static void tulip_up(struct net_device *dev)
 			(dev->if_port == 12 ? 0 : dev->if_port);
 		for (i = 0; i < tp->mtable->leafcount; i++)
 			if (tp->mtable->mleaf[i].media == looking_for) {
-				printk(KERN_INFO "%s: Using user-specified media %s.\n",
-					   dev->name, medianame[dev->if_port]);
+				dev_info(&dev->dev,
+					 "Using user-specified media %s\n",
+					 medianame[dev->if_port]);
 				goto media_picked;
 			}
 	}
@@ -396,8 +397,9 @@ static void tulip_up(struct net_device *dev)
 		int looking_for = tp->mtable->defaultmedia & MEDIA_MASK;
 		for (i = 0; i < tp->mtable->leafcount; i++)
 			if (tp->mtable->mleaf[i].media == looking_for) {
-				printk(KERN_INFO "%s: Using EEPROM-set media %s.\n",
-					   dev->name, medianame[looking_for]);
+				dev_info(&dev->dev,
+					 "Using EEPROM-set media %s\n",
+					 medianame[looking_for]);
 				goto media_picked;
 			}
 	}
@@ -424,9 +426,10 @@ media_picked:
 		if (tp->mii_cnt) {
 			tulip_select_media(dev, 1);
 			if (tulip_debug > 1)
-				printk(KERN_INFO "%s: Using MII transceiver %d, status "
-					   "%4.4x.\n",
-					   dev->name, tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
+				dev_info(&dev->dev,
+					 "Using MII transceiver %d, status %04x\n",
+					 tp->phys[0],
+					 tulip_mdio_read(dev, tp->phys[0], 1));
 			iowrite32(csr6_mask_defstate, ioaddr + CSR6);
 			tp->csr6 = csr6_mask_hdcap;
 			dev->if_port = 11;
@@ -490,9 +493,10 @@ media_picked:
 	iowrite32(0, ioaddr + CSR2);		/* Rx poll demand */
 
 	if (tulip_debug > 2) {
-		printk(KERN_DEBUG "%s: Done tulip_up(), CSR0 %8.8x, CSR5 %8.8x CSR6 %8.8x.\n",
-			   dev->name, ioread32(ioaddr + CSR0), ioread32(ioaddr + CSR5),
-			   ioread32(ioaddr + CSR6));
+		printk(KERN_DEBUG "%s: Done tulip_up(), CSR0 %08x, CSR5 %08x CSR6 %08x\n",
+		       dev->name, ioread32(ioaddr + CSR0),
+		       ioread32(ioaddr + CSR5),
+		       ioread32(ioaddr + CSR6));
 	}
 
 	/* Set the timer to switch to check for link beat and perhaps switch
@@ -540,27 +544,30 @@ static void tulip_tx_timeout(struct net_device *dev)
 	if (tulip_media_cap[dev->if_port] & MediaIsMII) {
 		/* Do nothing -- the media monitor should handle this. */
 		if (tulip_debug > 1)
-			printk(KERN_WARNING "%s: Transmit timeout using MII device.\n",
-				   dev->name);
+			dev_warn(&dev->dev,
+				 "Transmit timeout using MII device\n");
 	} else if (tp->chip_id == DC21140 || tp->chip_id == DC21142 ||
 		   tp->chip_id == MX98713 || tp->chip_id == COMPEX9881 ||
 		   tp->chip_id == DM910X) {
-		printk(KERN_WARNING "%s: 21140 transmit timed out, status %8.8x, "
-			   "SIA %8.8x %8.8x %8.8x %8.8x, resetting...\n",
-			   dev->name, ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR12),
-			   ioread32(ioaddr + CSR13), ioread32(ioaddr + CSR14), ioread32(ioaddr + CSR15));
+		dev_warn(&dev->dev,
+			 "21140 transmit timed out, status %08x, SIA %08x %08x %08x %08x, resetting...\n",
+			 ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR12),
+			 ioread32(ioaddr + CSR13), ioread32(ioaddr + CSR14),
+			 ioread32(ioaddr + CSR15));
 		tp->timeout_recovery = 1;
 		schedule_work(&tp->media_work);
 		goto out_unlock;
 	} else if (tp->chip_id == PNIC2) {
-		printk(KERN_WARNING "%s: PNIC2 transmit timed out, status %8.8x, "
-		       "CSR6/7 %8.8x / %8.8x CSR12 %8.8x, resetting...\n",
-		       dev->name, (int)ioread32(ioaddr + CSR5), (int)ioread32(ioaddr + CSR6),
-		       (int)ioread32(ioaddr + CSR7), (int)ioread32(ioaddr + CSR12));
+		dev_warn(&dev->dev,
+			 "PNIC2 transmit timed out, status %08x, CSR6/7 %08x / %08x CSR12 %08x, resetting...\n",
+			 (int)ioread32(ioaddr + CSR5),
+			 (int)ioread32(ioaddr + CSR6),
+			 (int)ioread32(ioaddr + CSR7),
+			 (int)ioread32(ioaddr + CSR12));
 	} else {
-		printk(KERN_WARNING "%s: Transmit timed out, status %8.8x, CSR12 "
-			   "%8.8x, resetting...\n",
-			   dev->name, ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR12));
+		dev_warn(&dev->dev,
+			 "Transmit timed out, status %08x, CSR12 %08x, resetting...\n",
+			 ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR12));
 		dev->if_port = 0;
 	}
 
@@ -570,26 +577,26 @@ static void tulip_tx_timeout(struct net_device *dev)
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			u8 *buf = (u8 *)(tp->rx_ring[i].buffer1);
 			int j;
-			printk(KERN_DEBUG "%2d: %8.8x %8.8x %8.8x %8.8x  "
-				   "%2.2x %2.2x %2.2x.\n",
-				   i, (unsigned int)tp->rx_ring[i].status,
-				   (unsigned int)tp->rx_ring[i].length,
-				   (unsigned int)tp->rx_ring[i].buffer1,
-				   (unsigned int)tp->rx_ring[i].buffer2,
-				   buf[0], buf[1], buf[2]);
+			printk(KERN_DEBUG
+			       "%2d: %08x %08x %08x %08x  %02x %02x %02x\n",
+			       i,
+			       (unsigned int)tp->rx_ring[i].status,
+			       (unsigned int)tp->rx_ring[i].length,
+			       (unsigned int)tp->rx_ring[i].buffer1,
+			       (unsigned int)tp->rx_ring[i].buffer2,
+			       buf[0], buf[1], buf[2]);
 			for (j = 0; buf[j] != 0xee && j < 1600; j++)
 				if (j < 100)
-					printk(KERN_CONT " %2.2x", buf[j]);
-			printk(KERN_CONT " j=%d.\n", j);
+					pr_cont(" %02x", buf[j]);
+			pr_cont(" j=%d\n", j);
 		}
-		printk(KERN_DEBUG "  Rx ring %8.8x: ", (int)tp->rx_ring);
+		printk(KERN_DEBUG "  Rx ring %08x: ", (int)tp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(KERN_CONT " %8.8x",
-			       (unsigned int)tp->rx_ring[i].status);
-		printk(KERN_DEBUG "  Tx ring %8.8x: ", (int)tp->tx_ring);
+			pr_cont(" %08x", (unsigned int)tp->rx_ring[i].status);
+		printk(KERN_DEBUG "  Tx ring %08x: ", (int)tp->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(KERN_CONT " %8.8x", (unsigned int)tp->tx_ring[i].status);
-		printk(KERN_CONT "\n");
+			pr_cont(" %08x", (unsigned int)tp->tx_ring[i].status);
+		pr_cont("\n");
 	}
 #endif
 
@@ -832,8 +839,9 @@ static int tulip_close (struct net_device *dev)
 	tulip_down (dev);
 
 	if (tulip_debug > 1)
-		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
-			dev->name, ioread32 (ioaddr + CSR5));
+		dev_printk(KERN_DEBUG, &dev->dev,
+			   "Shutting down ethercard, status was %02x\n",
+			   ioread32 (ioaddr + CSR5));
 
 	free_irq (dev->irq, dev);
 
@@ -1073,10 +1081,10 @@ static void set_rx_mode(struct net_device *dev)
 				filterbit &= 0x3f;
 				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 				if (tulip_debug > 2)
-					printk(KERN_INFO "%s: Added filter for %pM"
-					       "  %8.8x bit %d.\n",
-					       dev->name, mclist->dmi_addr,
-					       ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
+					dev_info(&dev->dev,
+						 "Added filter for %pM  %08x bit %d\n",
+						 mclist->dmi_addr,
+						 ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
 			}
 			if (mc_filter[0] == tp->mc_filter[0]  &&
 				mc_filter[1] == tp->mc_filter[1])
@@ -1288,9 +1296,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	unsigned int force_csr0 = 0;
 
 #ifndef MODULE
-	static int did_version;		/* Already printed version info. */
-	if (tulip_debug > 0  &&  did_version++ == 0)
-		printk (KERN_INFO "%s", version);
+	if (tulip_debug > 0)
+		printk_once(KERN_INFO "%s", version);
 #endif
 
 	board_idx++;
@@ -1301,7 +1308,7 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	 */
 
         if (pdev->subsystem_vendor == PCI_VENDOR_ID_LMC) {
-		printk (KERN_ERR PFX "skipping LMC card.\n");
+		pr_err(PFX "skipping LMC card\n");
 		return -ENODEV;
 	}
 
@@ -1317,15 +1324,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 		if (pdev->vendor == 0x1282 && pdev->device == 0x9100 &&
 		    pdev->revision < 0x30) {
-			printk(KERN_INFO PFX
-			       "skipping early DM9100 with Crc bug (use dmfe)\n");
+			pr_info(PFX "skipping early DM9100 with Crc bug (use dmfe)\n");
 			return -ENODEV;
 		}
 
 		dp = pci_device_to_OF_node(pdev);
 		if (!(dp && of_get_property(dp, "local-mac-address", NULL))) {
-			printk(KERN_INFO PFX
-			       "skipping DM910x expansion card (use dmfe)\n");
+			pr_info(PFX "skipping DM910x expansion card (use dmfe)\n");
 			return -ENODEV;
 		}
 	}
@@ -1372,9 +1377,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	i = pci_enable_device(pdev);
 	if (i) {
-		printk (KERN_ERR PFX
-			"Cannot enable tulip board #%d, aborting\n",
-			board_idx);
+		pr_err(PFX "Cannot enable tulip board #%d, aborting\n",
+		       board_idx);
 		return i;
 	}
 
@@ -1383,22 +1387,22 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	/* alloc_etherdev ensures aligned and zeroed private structures */
 	dev = alloc_etherdev (sizeof (*tp));
 	if (!dev) {
-		printk (KERN_ERR PFX "ether device alloc failed, aborting\n");
+		pr_err(PFX "ether device alloc failed, aborting\n");
 		return -ENOMEM;
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size) {
-		printk (KERN_ERR PFX "%s: I/O region (0x%llx@0x%llx) too small, "
-			"aborting\n", pci_name(pdev),
-			(unsigned long long)pci_resource_len (pdev, 0),
-			(unsigned long long)pci_resource_start (pdev, 0));
+		pr_err(PFX "%s: I/O region (0x%llx@0x%llx) too small, aborting\n",
+		       pci_name(pdev),
+		       (unsigned long long)pci_resource_len (pdev, 0),
+		       (unsigned long long)pci_resource_start (pdev, 0));
 		goto err_out_free_netdev;
 	}
 
 	/* grab all resources from both PIO and MMIO regions, as we
 	 * don't want anyone else messing around with our hardware */
-	if (pci_request_regions (pdev, "tulip"))
+	if (pci_request_regions (pdev, DRV_NAME))
 		goto err_out_free_netdev;
 
 	ioaddr =  pci_iomap(pdev, TULIP_BAR, tulip_tbl[chip_idx].io_size);
@@ -1611,8 +1615,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	if (dev->mem_start & MEDIA_MASK)
 		tp->default_port = dev->mem_start & MEDIA_MASK;
 	if (tp->default_port) {
-		printk(KERN_INFO "tulip%d: Transceiver selection forced to %s.\n",
-		       board_idx, medianame[tp->default_port & MEDIA_MASK]);
+		pr_info(DRV_NAME "%d: Transceiver selection forced to %s\n",
+			board_idx, medianame[tp->default_port & MEDIA_MASK]);
 		tp->medialock = 1;
 		if (tulip_media_cap[tp->default_port] & MediaAlwaysFD)
 			tp->full_duplex = 1;
@@ -1627,7 +1631,7 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	}
 
 	if (tp->flags & HAS_MEDIA_TABLE) {
-		sprintf(dev->name, "tulip%d", board_idx);	/* hack */
+		sprintf(dev->name, DRV_NAME "%d", board_idx);	/* hack */
 		tulip_parse_eeprom(dev);
 		strcpy(dev->name, "eth%d");			/* un-hack */
 	}
@@ -1663,20 +1667,18 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	if (register_netdev(dev))
 		goto err_out_free_ring;
 
-	printk(KERN_INFO "%s: %s rev %d at "
+	pci_set_drvdata(pdev, dev);
+
+	dev_info(&dev->dev,
 #ifdef CONFIG_TULIP_MMIO
-		"MMIO"
+		 "%s rev %d at MMIO %#llx,%s %pM, IRQ %d\n",
 #else
-		"Port"
+		 "%s rev %d at Port %#llx,%s %pM, IRQ %d\n",
 #endif
-		" %#llx,", dev->name, chip_name, pdev->revision,
-		(unsigned long long) pci_resource_start(pdev, TULIP_BAR));
-	pci_set_drvdata(pdev, dev);
-
-	if (eeprom_missing)
-		printk(" EEPROM not present,");
-	printk(" %pM", dev->dev_addr);
-	printk(", IRQ %d.\n", irq);
+		 chip_name, pdev->revision,
+		 (unsigned long long)pci_resource_start(pdev, TULIP_BAR),
+		 eeprom_missing ? " EEPROM not present," : "",
+		 dev->dev_addr, irq);
 
         if (tp->chip_id == PNIC2)
 		tp->link_change = pnic2_lnk_change;
@@ -1799,12 +1801,12 @@ static int tulip_resume(struct pci_dev *pdev)
 		return 0;
 
 	if ((retval = pci_enable_device(pdev))) {
-		printk (KERN_ERR "tulip: pci_enable_device failed in resume\n");
+		pr_err(PFX "pci_enable_device failed in resume\n");
 		return retval;
 	}
 
 	if ((retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
-		printk (KERN_ERR "tulip: request_irq failed in resume\n");
+		pr_err(PFX "request_irq failed in resume\n");
 		return retval;
 	}
 
@@ -1874,7 +1876,7 @@ static struct pci_driver tulip_driver = {
 static int __init tulip_init (void)
 {
 #ifdef MODULE
-	printk (KERN_INFO "%s", version);
+	pr_info("%s", version);
 #endif
 
 	/* copy module parms into globals */
-- 
1.6.6.rc0.57.gad7a

