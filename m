From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/13] tulip/de2104x.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:19 -0800
Message-ID: <289778d5a090f485da02cb33c0308e03a0c28115.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1583 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880Ab0A2G7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:30 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/de2104x.c |  138 +++++++++++++++++++++----------------------
 1 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 87ea39e..2933020 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -382,9 +382,9 @@ static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 		/* Ingore earlier buffers. */
 		if ((status & 0xffff) != 0x7fff) {
 			if (netif_msg_rx_err(de))
-				printk(KERN_WARNING "%s: Oversized Ethernet frame "
-					   "spanned multiple buffers, status %8.8x!\n",
-					   de->dev->name, status);
+				dev_warn(&de->dev->dev,
+					 "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
+					 status);
 			de->net_stats.rx_length_errors++;
 		}
 	} else if (status & RxError) {
@@ -487,7 +487,7 @@ rx_next:
 	}
 
 	if (!rx_work)
-		printk(KERN_WARNING "%s: rx work limit reached\n", de->dev->name);
+		dev_warn(&de->dev->dev, "rx work limit reached\n");
 
 	de->rx_tail = rx_tail;
 }
@@ -504,7 +504,8 @@ static irqreturn_t de_interrupt (int irq, void *dev_instance)
 
 	if (netif_msg_intr(de))
 		printk(KERN_DEBUG "%s: intr, status %08x mode %08x desc %u/%u/%u\n",
-		        dev->name, status, dr32(MacMode), de->rx_tail, de->tx_head, de->tx_tail);
+		       dev->name, status, dr32(MacMode),
+		       de->rx_tail, de->tx_head, de->tx_tail);
 
 	dw32(MacStatus, status);
 
@@ -529,8 +530,9 @@ static irqreturn_t de_interrupt (int irq, void *dev_instance)
 
 		pci_read_config_word(de->pdev, PCI_STATUS, &pci_status);
 		pci_write_config_word(de->pdev, PCI_STATUS, pci_status);
-		printk(KERN_ERR "%s: PCI bus error, status=%08x, PCI status=%04x\n",
-		       dev->name, status, pci_status);
+		dev_err(&de->dev->dev,
+			"PCI bus error, status=%08x, PCI status=%04x\n",
+			status, pci_status);
 	}
 
 	return IRQ_HANDLED;
@@ -582,7 +584,8 @@ static void de_tx (struct de_private *de)
 				de->net_stats.tx_packets++;
 				de->net_stats.tx_bytes += skb->len;
 				if (netif_msg_tx_done(de))
-					printk(KERN_DEBUG "%s: tx done, slot %d\n", de->dev->name, tx_tail);
+					printk(KERN_DEBUG "%s: tx done, slot %d\n",
+					       de->dev->name, tx_tail);
 			}
 			dev_kfree_skb_irq(skb);
 		}
@@ -870,7 +873,7 @@ static void de_stop_rxtx (struct de_private *de)
 		udelay(100);
 	}
 
-	printk(KERN_WARNING "%s: timeout expired stopping DMA\n", de->dev->name);
+	dev_warn(&de->dev->dev, "timeout expired stopping DMA\n");
 }
 
 static inline void de_start_rxtx (struct de_private *de)
@@ -905,8 +908,8 @@ static void de_link_up(struct de_private *de)
 	if (!netif_carrier_ok(de->dev)) {
 		netif_carrier_on(de->dev);
 		if (netif_msg_link(de))
-			printk(KERN_INFO "%s: link up, media %s\n",
-			       de->dev->name, media_name[de->media_type]);
+			dev_info(&de->dev->dev, "link up, media %s\n",
+				 media_name[de->media_type]);
 	}
 }
 
@@ -915,7 +918,7 @@ static void de_link_down(struct de_private *de)
 	if (netif_carrier_ok(de->dev)) {
 		netif_carrier_off(de->dev);
 		if (netif_msg_link(de))
-			printk(KERN_INFO "%s: link down\n", de->dev->name);
+			dev_info(&de->dev->dev, "link down\n");
 	}
 }
 
@@ -925,7 +928,8 @@ static void de_set_media (struct de_private *de)
 	u32 macmode = dr32(MacMode);
 
 	if (de_is_running(de))
-		printk(KERN_WARNING "%s: chip is running while changing media!\n", de->dev->name);
+		dev_warn(&de->dev->dev,
+			 "chip is running while changing media!\n");
 
 	if (de->de21040)
 		dw32(CSR11, FULL_DUPLEX_MAGIC);
@@ -945,15 +949,15 @@ static void de_set_media (struct de_private *de)
 		macmode &= ~FullDuplex;
 
 	if (netif_msg_link(de)) {
-		printk(KERN_INFO
-		       "%s: set link %s\n"
-		       "%s:    mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n"
-		       "%s:    set mode 0x%x, set sia 0x%x,0x%x,0x%x\n",
-		       de->dev->name, media_name[media],
-		       de->dev->name, dr32(MacMode), dr32(SIAStatus),
-		       dr32(CSR13), dr32(CSR14), dr32(CSR15),
-		       de->dev->name, macmode, de->media[media].csr13,
-		       de->media[media].csr14, de->media[media].csr15);
+		dev_info(&de->dev->dev, "set link %s\n", media_name[media]);
+		dev_info(&de->dev->dev, "mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n",
+			 dr32(MacMode), dr32(SIAStatus),
+			 dr32(CSR13), dr32(CSR14), dr32(CSR15));
+
+		dev_info(&de->dev->dev,
+			 "set mode 0x%x, set sia 0x%x,0x%x,0x%x\n",
+			 macmode, de->media[media].csr13,
+			 de->media[media].csr14, de->media[media].csr15);
 	}
 	if (macmode != dr32(MacMode))
 		dw32(MacMode, macmode);
@@ -992,9 +996,8 @@ static void de21040_media_timer (unsigned long data)
 			de_link_up(de);
 		else
 			if (netif_msg_timer(de))
-				printk(KERN_INFO "%s: %s link ok, status %x\n",
-				       dev->name, media_name[de->media_type],
-				       status);
+				dev_info(&dev->dev, "%s link ok, status %x\n",
+					 media_name[de->media_type], status);
 		return;
 	}
 
@@ -1022,8 +1025,8 @@ no_link_yet:
 	add_timer(&de->media_timer);
 
 	if (netif_msg_timer(de))
-		printk(KERN_INFO "%s: no link, trying media %s, status %x\n",
-		       dev->name, media_name[de->media_type], status);
+		dev_info(&dev->dev, "no link, trying media %s, status %x\n",
+			 media_name[de->media_type], status);
 }
 
 static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media)
@@ -1079,9 +1082,10 @@ static void de21041_media_timer (unsigned long data)
 			de_link_up(de);
 		else
 			if (netif_msg_timer(de))
-				printk(KERN_INFO "%s: %s link ok, mode %x status %x\n",
-				       dev->name, media_name[de->media_type],
-				       dr32(MacMode), status);
+				dev_info(&dev->dev,
+					 "%s link ok, mode %x status %x\n",
+					 media_name[de->media_type],
+					 dr32(MacMode), status);
 		return;
 	}
 
@@ -1150,8 +1154,8 @@ no_link_yet:
 	add_timer(&de->media_timer);
 
 	if (netif_msg_timer(de))
-		printk(KERN_INFO "%s: no link, trying media %s, status %x\n",
-		       dev->name, media_name[de->media_type], status);
+		dev_info(&dev->dev, "no link, trying media %s, status %x\n",
+			 media_name[de->media_type], status);
 }
 
 static void de_media_interrupt (struct de_private *de, u32 status)
@@ -1378,8 +1382,7 @@ static int de_open (struct net_device *dev)
 
 	rc = de_alloc_rings(de);
 	if (rc) {
-		printk(KERN_ERR "%s: ring allocation failure, err=%d\n",
-		       dev->name, rc);
+		dev_err(&dev->dev, "ring allocation failure, err=%d\n", rc);
 		return rc;
 	}
 
@@ -1387,15 +1390,14 @@ static int de_open (struct net_device *dev)
 
 	rc = request_irq(dev->irq, de_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
-		printk(KERN_ERR "%s: IRQ %d request failure, err=%d\n",
-		       dev->name, dev->irq, rc);
+		dev_err(&dev->dev, "IRQ %d request failure, err=%d\n",
+			dev->irq, rc);
 		goto err_out_free;
 	}
 
 	rc = de_init_hw(de);
 	if (rc) {
-		printk(KERN_ERR "%s: h/w init failure, err=%d\n",
-		       dev->name, rc);
+		dev_err(&dev->dev, "h/w init failure, err=%d\n", rc);
 		goto err_out_free_irq;
 	}
 
@@ -1666,8 +1668,8 @@ static int de_nway_reset(struct net_device *dev)
 	status = dr32(SIAStatus);
 	dw32(SIAStatus, (status & ~NWayState) | NWayRestart);
 	if (netif_msg_link(de))
-		printk(KERN_INFO "%s: link nway restart, status %x,%x\n",
-		       de->dev->name, status, dr32(SIAStatus));
+		dev_info(&de->dev->dev, "link nway restart, status %x,%x\n",
+			 status, dr32(SIAStatus));
 	return 0;
 }
 
@@ -1711,7 +1713,7 @@ static void __devinit de21040_get_mac_address (struct de_private *de)
 		de->dev->dev_addr[i] = value;
 		udelay(1);
 		if (boguscnt <= 0)
-			printk(KERN_WARNING PFX "timeout reading 21040 MAC address byte %u\n", i);
+			pr_warning(PFX "timeout reading 21040 MAC address byte %u\n", i);
 	}
 }
 
@@ -1830,9 +1832,8 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 	}
 
 	if (netif_msg_probe(de))
-		printk(KERN_INFO "de%d: SROM leaf offset %u, default media %s\n",
-		       de->board_idx, ofs,
-		       media_name[de->media_type]);
+		pr_info("de%d: SROM leaf offset %u, default media %s\n",
+		       de->board_idx, ofs, media_name[de->media_type]);
 
 	/* init SIA register values to defaults */
 	for (i = 0; i < DE_MAX_MEDIA; i++) {
@@ -1879,9 +1880,9 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 		de->media[idx].type = idx;
 
 		if (netif_msg_probe(de))
-			printk(KERN_INFO "de%d:   media block #%u: %s",
-			       de->board_idx, i,
-			       media_name[de->media[idx].type]);
+			pr_info("de%d:   media block #%u: %s",
+				de->board_idx, i,
+				media_name[de->media[idx].type]);
 
 		bufp += sizeof (ib->opts);
 
@@ -1893,13 +1894,13 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 				sizeof(ib->csr15);
 
 			if (netif_msg_probe(de))
-				printk(" (%x,%x,%x)\n",
-				       de->media[idx].csr13,
-				       de->media[idx].csr14,
-				       de->media[idx].csr15);
+				pr_cont(" (%x,%x,%x)\n",
+					de->media[idx].csr13,
+					de->media[idx].csr14,
+					de->media[idx].csr15);
 
 		} else if (netif_msg_probe(de))
-			printk("\n");
+			pr_cont("\n");
 
 		if (bufp > ((void *)&ee_data[DE_EEPROM_SIZE - 3]))
 			break;
@@ -2005,7 +2006,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	/* check for invalid IRQ value */
 	if (pdev->irq < 2) {
 		rc = -EIO;
-		printk(KERN_ERR PFX "invalid irq (%d) for pci dev %s\n",
+		pr_err(PFX "invalid irq (%d) for pci dev %s\n",
 		       pdev->irq, pci_name(pdev));
 		goto err_out_res;
 	}
@@ -2016,14 +2017,14 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	pciaddr = pci_resource_start(pdev, 1);
 	if (!pciaddr) {
 		rc = -EIO;
-		printk(KERN_ERR PFX "no MMIO resource for pci dev %s\n",
-		       pci_name(pdev));
+		pr_err(PFX "no MMIO resource for pci dev %s\n", pci_name(pdev));
 		goto err_out_res;
 	}
 	if (pci_resource_len(pdev, 1) < DE_REGS_SIZE) {
 		rc = -EIO;
-		printk(KERN_ERR PFX "MMIO resource (%llx) too small on pci dev %s\n",
-		       (unsigned long long)pci_resource_len(pdev, 1), pci_name(pdev));
+		pr_err(PFX "MMIO resource (%llx) too small on pci dev %s\n",
+		       (unsigned long long)pci_resource_len(pdev, 1),
+		       pci_name(pdev));
 		goto err_out_res;
 	}
 
@@ -2031,9 +2032,9 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	regs = ioremap_nocache(pciaddr, DE_REGS_SIZE);
 	if (!regs) {
 		rc = -EIO;
-		printk(KERN_ERR PFX "Cannot map PCI MMIO (%llx@%lx) on pci dev %s\n",
-			(unsigned long long)pci_resource_len(pdev, 1),
-			pciaddr, pci_name(pdev));
+		pr_err(PFX "Cannot map PCI MMIO (%llx@%lx) on pci dev %s\n",
+		       (unsigned long long)pci_resource_len(pdev, 1),
+		       pciaddr, pci_name(pdev));
 		goto err_out_res;
 	}
 	dev->base_addr = (unsigned long) regs;
@@ -2044,8 +2045,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	/* make sure hardware is not running */
 	rc = de_reset_mac(de);
 	if (rc) {
-		printk(KERN_ERR PFX "Cannot reset MAC, pci dev %s\n",
-		       pci_name(pdev));
+		pr_err(PFX "Cannot reset MAC, pci dev %s\n", pci_name(pdev));
 		goto err_out_iomap;
 	}
 
@@ -2065,12 +2065,11 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		goto err_out_iomap;
 
 	/* print info about board and interface just registered */
-	printk (KERN_INFO "%s: %s at 0x%lx, %pM, IRQ %d\n",
-		dev->name,
-		de->de21040 ? "21040" : "21041",
-		dev->base_addr,
-		dev->dev_addr,
-		dev->irq);
+	dev_info(&dev->dev, "%s at 0x%lx, %pM, IRQ %d\n",
+		 de->de21040 ? "21040" : "21041",
+		 dev->base_addr,
+		 dev->dev_addr,
+		 dev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
@@ -2158,8 +2157,7 @@ static int de_resume (struct pci_dev *pdev)
 	if (!netif_running(dev))
 		goto out_attach;
 	if ((retval = pci_enable_device(pdev))) {
-		printk (KERN_ERR "%s: pci_enable_device failed in resume\n",
-			dev->name);
+		dev_err(&dev->dev, "pci_enable_device failed in resume\n");
 		goto out;
 	}
 	de_init_hw(de);
-- 
1.6.6.rc0.57.gad7a

