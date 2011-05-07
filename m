From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/4] tulip: Convert printks to netdev_<level>
Date: Fri,  6 May 2011 19:08:43 -0700
Message-ID: <84a86a5b89eac3aec88427c8afd09591bd5b0cfc.1304733889.git.joe@perches.com>
References: <cover.1304733889.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>,
	Tobias Ringstrom <tori@unhappy.mine.nu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304733889.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current more descriptive logging styles.

Add pr_fmt and remove PFX where appropriate.
Use netif_<level>, netdev_<level>
Indent a few blocks in xircom_cb where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/de2104x.c     |  139 +++++++++++++++++---------------------
 drivers/net/tulip/dmfe.c        |    2 +-
 drivers/net/tulip/eeprom.c      |    4 +-
 drivers/net/tulip/tulip_core.c  |   25 +++----
 drivers/net/tulip/uli526x.c     |   42 +++++-------
 drivers/net/tulip/winbond-840.c |    6 +-
 drivers/net/tulip/xircom_cb.c   |  140 +++++++++++++++++++++------------------
 7 files changed, 174 insertions(+), 184 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 46d5a1b..62883a0 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -27,6 +27,8 @@
 
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME		"de2104x"
 #define DRV_VERSION		"0.7"
 #define DRV_RELDATE		"Mar 17, 2004"
@@ -73,8 +75,6 @@ static int rx_copybreak = 100;
 module_param (rx_copybreak, int, 0);
 MODULE_PARM_DESC (rx_copybreak, "de2104x Breakpoint at which Rx packets are copied");
 
-#define PFX			DRV_NAME ": "
-
 #define DE_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
 				 NETIF_MSG_PROBE 	| \
 				 NETIF_MSG_LINK		| \
@@ -377,18 +377,16 @@ static u16 t21041_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 			    u32 status, u32 len)
 {
-	if (netif_msg_rx_err (de))
-		printk (KERN_DEBUG
-			"%s: rx err, slot %d status 0x%x len %d\n",
-			de->dev->name, rx_tail, status, len);
+	netif_printk(de, rx_err, KERN_DEBUG, de->dev,
+		     "rx err, slot %d status 0x%x len %d\n",
+		     rx_tail, status, len);
 
 	if ((status & 0x38000300) != 0x0300) {
 		/* Ingore earlier buffers. */
 		if ((status & 0xffff) != 0x7fff) {
-			if (netif_msg_rx_err(de))
-				dev_warn(&de->dev->dev,
-					 "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
-					 status);
+			netif_warn(de, rx_err, de->dev,
+				   "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
+				   status);
 			de->net_stats.rx_length_errors++;
 		}
 	} else if (status & RxError) {
@@ -491,7 +489,7 @@ rx_next:
 	}
 
 	if (!rx_work)
-		dev_warn(&de->dev->dev, "rx work limit reached\n");
+		netdev_warn(de->dev, "rx work limit reached\n");
 
 	de->rx_tail = rx_tail;
 }
@@ -534,9 +532,9 @@ static irqreturn_t de_interrupt (int irq, void *dev_instance)
 
 		pci_read_config_word(de->pdev, PCI_STATUS, &pci_status);
 		pci_write_config_word(de->pdev, PCI_STATUS, pci_status);
-		dev_err(&de->dev->dev,
-			"PCI bus error, status=%08x, PCI status=%04x\n",
-			status, pci_status);
+		netdev_err(de->dev,
+			   "PCI bus error, status=%08x, PCI status=%04x\n",
+			   status, pci_status);
 	}
 
 	return IRQ_HANDLED;
@@ -873,7 +871,7 @@ static void de_stop_rxtx (struct de_private *de)
 		udelay(100);
 	}
 
-	dev_warn(&de->dev->dev, "timeout expired stopping DMA\n");
+	netdev_warn(de->dev, "timeout expired, stopping DMA\n");
 }
 
 static inline void de_start_rxtx (struct de_private *de)
@@ -907,9 +905,8 @@ static void de_link_up(struct de_private *de)
 {
 	if (!netif_carrier_ok(de->dev)) {
 		netif_carrier_on(de->dev);
-		if (netif_msg_link(de))
-			dev_info(&de->dev->dev, "link up, media %s\n",
-				 media_name[de->media_type]);
+		netif_info(de, link, de->dev, "link up, media %s\n",
+			   media_name[de->media_type]);
 	}
 }
 
@@ -917,8 +914,7 @@ static void de_link_down(struct de_private *de)
 {
 	if (netif_carrier_ok(de->dev)) {
 		netif_carrier_off(de->dev);
-		if (netif_msg_link(de))
-			dev_info(&de->dev->dev, "link down\n");
+		netif_info(de, link, de->dev, "link down\n");
 	}
 }
 
@@ -928,8 +924,7 @@ static void de_set_media (struct de_private *de)
 	u32 macmode = dr32(MacMode);
 
 	if (de_is_running(de))
-		dev_warn(&de->dev->dev,
-			 "chip is running while changing media!\n");
+		netdev_warn(de->dev, "chip is running while changing media!\n");
 
 	if (de->de21040)
 		dw32(CSR11, FULL_DUPLEX_MAGIC);
@@ -948,18 +943,13 @@ static void de_set_media (struct de_private *de)
 	else
 		macmode &= ~FullDuplex;
 
-	if (netif_msg_link(de))
-		dev_info(&de->dev->dev, "set link %s\n", media_name[media]);
-	if (netif_msg_hw(de)) {
-		dev_info(&de->dev->dev, "mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n",
-			 dr32(MacMode), dr32(SIAStatus),
-			 dr32(CSR13), dr32(CSR14), dr32(CSR15));
-
-		dev_info(&de->dev->dev,
-			 "set mode 0x%x, set sia 0x%x,0x%x,0x%x\n",
-			 macmode, de->media[media].csr13,
-			 de->media[media].csr14, de->media[media].csr15);
-	}
+	netif_info(de, link, de->dev, "set link %s\n", media_name[media]);
+	netif_info(de, hw, de->dev, "mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n",
+		   dr32(MacMode), dr32(SIAStatus),
+		   dr32(CSR13), dr32(CSR14), dr32(CSR15));
+	netif_info(de, hw, de->dev, "set mode 0x%x, set sia 0x%x,0x%x,0x%x\n",
+		   macmode, de->media[media].csr13,
+		   de->media[media].csr14, de->media[media].csr15);
 	if (macmode != dr32(MacMode))
 		dw32(MacMode, macmode);
 }
@@ -996,9 +986,8 @@ static void de21040_media_timer (unsigned long data)
 		if (!netif_carrier_ok(dev))
 			de_link_up(de);
 		else
-			if (netif_msg_timer(de))
-				dev_info(&dev->dev, "%s link ok, status %x\n",
-					 media_name[de->media_type], status);
+			netif_info(de, timer, dev, "%s link ok, status %x\n",
+				   media_name[de->media_type], status);
 		return;
 	}
 
@@ -1025,9 +1014,8 @@ no_link_yet:
 	de->media_timer.expires = jiffies + DE_TIMER_NO_LINK;
 	add_timer(&de->media_timer);
 
-	if (netif_msg_timer(de))
-		dev_info(&dev->dev, "no link, trying media %s, status %x\n",
-			 media_name[de->media_type], status);
+	netif_info(de, timer, dev, "no link, trying media %s, status %x\n",
+		   media_name[de->media_type], status);
 }
 
 static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media)
@@ -1085,11 +1073,10 @@ static void de21041_media_timer (unsigned long data)
 		if (!netif_carrier_ok(dev))
 			de_link_up(de);
 		else
-			if (netif_msg_timer(de))
-				dev_info(&dev->dev,
-					 "%s link ok, mode %x status %x\n",
-					 media_name[de->media_type],
-					 dr32(MacMode), status);
+			netif_info(de, timer, dev,
+				   "%s link ok, mode %x status %x\n",
+				   media_name[de->media_type],
+				   dr32(MacMode), status);
 		return;
 	}
 
@@ -1163,9 +1150,8 @@ no_link_yet:
 	de->media_timer.expires = jiffies + DE_TIMER_NO_LINK;
 	add_timer(&de->media_timer);
 
-	if (netif_msg_timer(de))
-		dev_info(&dev->dev, "no link, trying media %s, status %x\n",
-			 media_name[de->media_type], status);
+	netif_info(de, timer, dev, "no link, trying media %s, status %x\n",
+		   media_name[de->media_type], status);
 }
 
 static void de_media_interrupt (struct de_private *de, u32 status)
@@ -1401,14 +1387,13 @@ static int de_open (struct net_device *dev)
 	struct de_private *de = netdev_priv(dev);
 	int rc;
 
-	if (netif_msg_ifup(de))
-		printk(KERN_DEBUG "%s: enabling interface\n", dev->name);
+	netif_printk(de, ifup, KERN_DEBUG, dev, "enabling interface\n");
 
 	de->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 
 	rc = de_alloc_rings(de);
 	if (rc) {
-		dev_err(&dev->dev, "ring allocation failure, err=%d\n", rc);
+		netdev_err(dev, "ring allocation failure, err=%d\n", rc);
 		return rc;
 	}
 
@@ -1416,14 +1401,14 @@ static int de_open (struct net_device *dev)
 
 	rc = request_irq(dev->irq, de_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
-		dev_err(&dev->dev, "IRQ %d request failure, err=%d\n",
-			dev->irq, rc);
+		netdev_err(dev, "IRQ %d request failure, err=%d\n",
+			   dev->irq, rc);
 		goto err_out_free;
 	}
 
 	rc = de_init_hw(de);
 	if (rc) {
-		dev_err(&dev->dev, "h/w init failure, err=%d\n", rc);
+		netdev_err(dev, "h/w init failure, err=%d\n", rc);
 		goto err_out_free_irq;
 	}
 
@@ -1444,8 +1429,7 @@ static int de_close (struct net_device *dev)
 	struct de_private *de = netdev_priv(dev);
 	unsigned long flags;
 
-	if (netif_msg_ifdown(de))
-		printk(KERN_DEBUG "%s: disabling interface\n", dev->name);
+	netif_printk(de, ifdown, KERN_DEBUG, dev, "disabling interface\n");
 
 	del_timer_sync(&de->media_timer);
 
@@ -1466,9 +1450,10 @@ static void de_tx_timeout (struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
 
-	printk(KERN_DEBUG "%s: NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
-	       dev->name, dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
-	       de->rx_tail, de->tx_head, de->tx_tail);
+	netdev_printk(KERN_DEBUG, dev,
+		      "NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
+		      dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
+		      de->rx_tail, de->tx_head, de->tx_tail);
 
 	del_timer_sync(&de->media_timer);
 
@@ -1693,9 +1678,8 @@ static int de_nway_reset(struct net_device *dev)
 
 	status = dr32(SIAStatus);
 	dw32(SIAStatus, (status & ~NWayState) | NWayRestart);
-	if (netif_msg_link(de))
-		dev_info(&de->dev->dev, "link nway restart, status %x,%x\n",
-			 status, dr32(SIAStatus));
+	netif_info(de, link, dev, "link nway restart, status %x,%x\n",
+		   status, dr32(SIAStatus));
 	return 0;
 }
 
@@ -1740,7 +1724,8 @@ static void __devinit de21040_get_mac_address (struct de_private *de)
 		de->dev->dev_addr[i] = value;
 		udelay(1);
 		if (boguscnt <= 0)
-			pr_warning(PFX "timeout reading 21040 MAC address byte %u\n", i);
+			pr_warn("timeout reading 21040 MAC address byte %u\n",
+				i);
 	}
 }
 
@@ -1926,8 +1911,10 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 					de->media[idx].csr14,
 					de->media[idx].csr15);
 
-		} else if (netif_msg_probe(de))
-			pr_cont("\n");
+		} else {
+			if (netif_msg_probe(de))
+				pr_cont("\n");
+		}
 
 		if (bufp > ((void *)&ee_data[DE_EEPROM_SIZE - 3]))
 			break;
@@ -2038,7 +2025,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	/* check for invalid IRQ value */
 	if (pdev->irq < 2) {
 		rc = -EIO;
-		pr_err(PFX "invalid irq (%d) for pci dev %s\n",
+		pr_err("invalid irq (%d) for pci dev %s\n",
 		       pdev->irq, pci_name(pdev));
 		goto err_out_res;
 	}
@@ -2049,12 +2036,12 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	pciaddr = pci_resource_start(pdev, 1);
 	if (!pciaddr) {
 		rc = -EIO;
-		pr_err(PFX "no MMIO resource for pci dev %s\n", pci_name(pdev));
+		pr_err("no MMIO resource for pci dev %s\n", pci_name(pdev));
 		goto err_out_res;
 	}
 	if (pci_resource_len(pdev, 1) < DE_REGS_SIZE) {
 		rc = -EIO;
-		pr_err(PFX "MMIO resource (%llx) too small on pci dev %s\n",
+		pr_err("MMIO resource (%llx) too small on pci dev %s\n",
 		       (unsigned long long)pci_resource_len(pdev, 1),
 		       pci_name(pdev));
 		goto err_out_res;
@@ -2064,7 +2051,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	regs = ioremap_nocache(pciaddr, DE_REGS_SIZE);
 	if (!regs) {
 		rc = -EIO;
-		pr_err(PFX "Cannot map PCI MMIO (%llx@%lx) on pci dev %s\n",
+		pr_err("Cannot map PCI MMIO (%llx@%lx) on pci dev %s\n",
 		       (unsigned long long)pci_resource_len(pdev, 1),
 		       pciaddr, pci_name(pdev));
 		goto err_out_res;
@@ -2077,7 +2064,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	/* make sure hardware is not running */
 	rc = de_reset_mac(de);
 	if (rc) {
-		pr_err(PFX "Cannot reset MAC, pci dev %s\n", pci_name(pdev));
+		pr_err("Cannot reset MAC, pci dev %s\n", pci_name(pdev));
 		goto err_out_iomap;
 	}
 
@@ -2097,11 +2084,11 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		goto err_out_iomap;
 
 	/* print info about board and interface just registered */
-	dev_info(&dev->dev, "%s at 0x%lx, %pM, IRQ %d\n",
-		 de->de21040 ? "21040" : "21041",
-		 dev->base_addr,
-		 dev->dev_addr,
-		 dev->irq);
+	netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
+		    de->de21040 ? "21040" : "21041",
+		    dev->base_addr,
+		    dev->dev_addr,
+		    dev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
@@ -2189,7 +2176,7 @@ static int de_resume (struct pci_dev *pdev)
 	if (!netif_running(dev))
 		goto out_attach;
 	if ((retval = pci_enable_device(pdev))) {
-		dev_err(&dev->dev, "pci_enable_device failed in resume\n");
+		netdev_err(dev, "pci_enable_device failed in resume\n");
 		goto out;
 	}
 	pci_set_master(pdev);
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index fb07f48..96e8541 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -406,7 +406,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		pr_warning("32-bit PCI DMA not available\n");
+		pr_warn("32-bit PCI DMA not available\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 296486b..fa5eee9 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -222,8 +222,8 @@ subsequent_board:
 	        /* there is no phy information, don't even try to build mtable */
 	        if (count == 0) {
 			if (tulip_debug > 0)
-				pr_warning("%s: no phy info, aborting mtable build\n",
-					   dev->name);
+				pr_warn("%s: no phy info, aborting mtable build\n",
+					dev->name);
 		        return;
 		}
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 5c01e26..f46898a 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -12,6 +12,7 @@
 	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
+#define pr_fmt(fmt) "tulip: " fmt
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
@@ -119,8 +120,6 @@ module_param(csr0, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 
-#define PFX DRV_NAME ": "
-
 #ifdef TULIP_DEBUG
 int tulip_debug = TULIP_DEBUG;
 #else
@@ -1340,13 +1339,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	 */
 
         if (pdev->subsystem_vendor == PCI_VENDOR_ID_LMC) {
-		pr_err(PFX "skipping LMC card\n");
+		pr_err("skipping LMC card\n");
 		return -ENODEV;
 	} else if (pdev->subsystem_vendor == PCI_VENDOR_ID_SBE &&
 		   (pdev->subsystem_device == PCI_SUBDEVICE_ID_SBE_T3E3 ||
 		    pdev->subsystem_device == PCI_SUBDEVICE_ID_SBE_2T3E3_P0 ||
 		    pdev->subsystem_device == PCI_SUBDEVICE_ID_SBE_2T3E3_P1)) {
-		pr_err(PFX "skipping SBE T3E3 port\n");
+		pr_err("skipping SBE T3E3 port\n");
 		return -ENODEV;
 	}
 
@@ -1362,13 +1361,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 		if (pdev->vendor == 0x1282 && pdev->device == 0x9100 &&
 		    pdev->revision < 0x30) {
-			pr_info(PFX "skipping early DM9100 with Crc bug (use dmfe)\n");
+			pr_info("skipping early DM9100 with Crc bug (use dmfe)\n");
 			return -ENODEV;
 		}
 
 		dp = pci_device_to_OF_node(pdev);
 		if (!(dp && of_get_property(dp, "local-mac-address", NULL))) {
-			pr_info(PFX "skipping DM910x expansion card (use dmfe)\n");
+			pr_info("skipping DM910x expansion card (use dmfe)\n");
 			return -ENODEV;
 		}
 	}
@@ -1415,16 +1414,14 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	i = pci_enable_device(pdev);
 	if (i) {
-		pr_err(PFX "Cannot enable tulip board #%d, aborting\n",
-		       board_idx);
+		pr_err("Cannot enable tulip board #%d, aborting\n", board_idx);
 		return i;
 	}
 
 	/* The chip will fail to enter a low-power state later unless
 	 * first explicitly commanded into D0 */
 	if (pci_set_power_state(pdev, PCI_D0)) {
-		printk (KERN_NOTICE PFX
-			"Failed to set power state to D0\n");
+		pr_notice("Failed to set power state to D0\n");
 	}
 
 	irq = pdev->irq;
@@ -1432,13 +1429,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	/* alloc_etherdev ensures aligned and zeroed private structures */
 	dev = alloc_etherdev (sizeof (*tp));
 	if (!dev) {
-		pr_err(PFX "ether device alloc failed, aborting\n");
+		pr_err("ether device alloc failed, aborting\n");
 		return -ENOMEM;
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size) {
-		pr_err(PFX "%s: I/O region (0x%llx@0x%llx) too small, aborting\n",
+		pr_err("%s: I/O region (0x%llx@0x%llx) too small, aborting\n",
 		       pci_name(pdev),
 		       (unsigned long long)pci_resource_len (pdev, 0),
 		       (unsigned long long)pci_resource_start (pdev, 0));
@@ -1905,12 +1902,12 @@ static int tulip_resume(struct pci_dev *pdev)
 		return 0;
 
 	if ((retval = pci_enable_device(pdev))) {
-		pr_err(PFX "pci_enable_device failed in resume\n");
+		pr_err("pci_enable_device failed in resume\n");
 		return retval;
 	}
 
 	if ((retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
-		pr_err(PFX "request_irq failed in resume\n");
+		pr_err("request_irq failed in resume\n");
 		return retval;
 	}
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index a4375c4..92c00ee 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -292,7 +292,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		pr_warning("32-bit PCI DMA not available\n");
+		pr_warn("32-bit PCI DMA not available\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
@@ -390,9 +390,9 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	if (err)
 		goto err_out_res;
 
-	dev_info(&dev->dev, "ULi M%04lx at pci%s, %pM, irq %d\n",
-		 ent->driver_data >> 16, pci_name(pdev),
-		 dev->dev_addr, dev->irq);
+	netdev_info(dev, "ULi M%04lx at pci%s, %pM, irq %d\n",
+		    ent->driver_data >> 16, pci_name(pdev),
+		    dev->dev_addr, dev->irq);
 
 	pci_set_master(pdev);
 
@@ -524,7 +524,7 @@ static void uli526x_init(struct net_device *dev)
 		}
 	}
 	if(phy_tmp == 32)
-		pr_warning("Can not find the phy address!!!");
+		pr_warn("Can not find the phy address!!!\n");
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
@@ -590,7 +590,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
-		pr_err("big packet = %d\n", (u16)skb->len);
+		netdev_err(dev, "big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -600,7 +600,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_packet_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
-		pr_err("No Tx resource %ld\n", db->tx_packet_cnt);
+		netdev_err(dev, "No Tx resource %ld\n", db->tx_packet_cnt);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1024,7 +1024,6 @@ static void uli526x_timer(unsigned long data)
 	struct net_device *dev = (struct net_device *) data;
 	struct uli526x_board_info *db = netdev_priv(dev);
  	unsigned long flags;
-	u8 TmpSpeed=10;
 
 	//ULI526X_DBUG(0, "uli526x_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
@@ -1070,7 +1069,7 @@ static void uli526x_timer(unsigned long data)
 		/* Link Failed */
 		ULI526X_DBUG(0, "Link Failed", tmp_cr12);
 		netif_carrier_off(dev);
-		pr_info("%s NIC Link is Down\n",dev->name);
+		netdev_info(dev, "NIC Link is Down\n");
 		db->link_failed = 1;
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
@@ -1096,18 +1095,13 @@ static void uli526x_timer(unsigned long data)
 
 			if(db->link_failed==0)
 			{
-				if(db->op_mode==ULI526X_100MHF || db->op_mode==ULI526X_100MFD)
-				{
-					TmpSpeed = 100;
-				}
-				if(db->op_mode==ULI526X_10MFD || db->op_mode==ULI526X_100MFD)
-				{
-					pr_info("%s NIC Link is Up %d Mbps Full duplex\n",dev->name,TmpSpeed);
-				}
-				else
-				{
-					pr_info("%s NIC Link is Up %d Mbps Half duplex\n",dev->name,TmpSpeed);
-				}
+				netdev_info(dev, "NIC Link is Up %d Mbps %s duplex\n",
+					    (db->op_mode == ULI526X_100MHF ||
+					     db->op_mode == ULI526X_100MFD)
+					    ? 100 : 10,
+					    (db->op_mode == ULI526X_10MFD ||
+					     db->op_mode == ULI526X_100MFD)
+					    ? "Full" : "Half");
 				netif_carrier_on(dev);
 			}
 			/* SHOW_MEDIA_TYPE(db->op_mode); */
@@ -1116,7 +1110,7 @@ static void uli526x_timer(unsigned long data)
 		{
 			if(db->init==1)
 			{
-				pr_info("%s NIC Link is Down\n",dev->name);
+				netdev_info(dev, "NIC Link is Down\n");
 				netif_carrier_off(dev);
 			}
 		}
@@ -1242,7 +1236,7 @@ static int uli526x_resume(struct pci_dev *pdev)
 
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err) {
-		dev_warn(&dev->dev, "Could not put device into D0\n");
+		netdev_warn(dev, "Could not put device into D0\n");
 		return err;
 	}
 
@@ -1443,7 +1437,7 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		update_cr6(db->cr6_data, dev->base_addr);
 		dev->trans_start = jiffies;
 	} else
-		pr_err("No Tx resource - Send_filter_frame!\n");
+		netdev_err(dev, "No Tx resource - Send_filter_frame!\n");
 }
 
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index f0b2310..939c96e 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -44,6 +44,8 @@
 	* Wake-On-LAN
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"winbond-840"
 #define DRV_VERSION	"1.01-e"
 #define DRV_RELDATE	"Sep-11-2006"
@@ -375,8 +377,8 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	irq = pdev->irq;
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		pr_warning("Winbond-840: Device %s disabled due to DMA limitations\n",
-			   pci_name(pdev));
+		pr_warn("Device %s disabled due to DMA limitations\n",
+			pci_name(pdev));
 		return -EIO;
 	}
 	dev = alloc_etherdev(sizeof(*np));
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 4436865..abfe2e3 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -272,8 +272,8 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 		goto reg_fail;
 	}
 
-	dev_info(&dev->dev, "Xircom cardbus revision %i at irq %i\n",
-		 pdev->revision, pdev->irq);
+	netdev_info(dev, "Xircom cardbus revision %i at irq %i\n",
+		    pdev->revision, pdev->irq);
 	/* start the transmitter to get a heartbeat */
 	/* TODO: send 2 dummy packets here */
 	transceiver_voodoo(private);
@@ -350,7 +350,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 		int newlink;
 		printk(KERN_DEBUG "xircom_cb: Link status has changed\n");
 		newlink = link_status(card);
-		dev_info(&dev->dev, "Link is %i mbit\n", newlink);
+		netdev_info(dev, "Link is %d mbit\n", newlink);
 		if (newlink)
 			netif_carrier_on(dev);
 		else
@@ -447,8 +447,8 @@ static int xircom_open(struct net_device *dev)
 	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
 	func_enter();
-	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i\n",
-		dev->name, dev->irq);
+	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n",
+		    dev->irq);
 	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		func_exit();
@@ -761,7 +761,7 @@ static void activate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Receiver failed to deactivate\n");
+			netdev_err(card->dev, "Receiver failed to deactivate\n");
 	}
 
 	/* enable the receiver */
@@ -778,7 +778,8 @@ static void activate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Receiver failed to re-activate\n");
+			netdev_err(card->dev,
+				   "Receiver failed to re-activate\n");
 	}
 
 	func_exit();
@@ -809,7 +810,7 @@ static void deactivate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Receiver failed to deactivate\n");
+			netdev_err(card->dev, "Receiver failed to deactivate\n");
 	}
 
 
@@ -852,7 +853,8 @@ static void activate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Transmitter failed to deactivate\n");
+			netdev_err(card->dev,
+				   "Transmitter failed to deactivate\n");
 	}
 
 	/* enable the transmitter */
@@ -869,7 +871,8 @@ static void activate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Transmitter failed to re-activate\n");
+			netdev_err(card->dev,
+				   "Transmitter failed to re-activate\n");
 	}
 
 	func_exit();
@@ -900,7 +903,8 @@ static void deactivate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			pr_err("Transmitter failed to deactivate\n");
+			netdev_err(card->dev,
+				   "Transmitter failed to deactivate\n");
 	}
 
 
@@ -1160,80 +1164,86 @@ static void xircom_up(struct xircom_private *card)
 }
 
 /* Bufferoffset is in BYTES */
-static void investigate_read_descriptor(struct net_device *dev,struct xircom_private *card, int descnr, unsigned int bufferoffset)
+static void
+investigate_read_descriptor(struct net_device *dev, struct xircom_private *card,
+			    int descnr, unsigned int bufferoffset)
 {
-		int status;
+	int status;
 
-		func_enter();
-		status = le32_to_cpu(card->rx_buffer[4*descnr]);
-
-		if ((status > 0)) {	/* packet received */
+	func_enter();
 
-			/* TODO: discard error packets */
+	status = le32_to_cpu(card->rx_buffer[4*descnr]);
+	if (status > 0) {		/* packet received */
 
-			short pkt_len = ((status >> 16) & 0x7ff) - 4;	/* minus 4, we don't want the CRC */
-			struct sk_buff *skb;
+		/* TODO: discard error packets */
 
-			if (pkt_len > 1518) {
-				pr_err("Packet length %i is bogus\n", pkt_len);
-				pkt_len = 1518;
-			}
+		short pkt_len = ((status >> 16) & 0x7ff) - 4;
+					/* minus 4, we don't want the CRC */
+		struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 2);
-			if (skb == NULL) {
-				dev->stats.rx_dropped++;
-				goto out;
-			}
-			skb_reserve(skb, 2);
-			skb_copy_to_linear_data(skb, (unsigned char*)&card->rx_buffer[bufferoffset / 4], pkt_len);
-			skb_put(skb, pkt_len);
-			skb->protocol = eth_type_trans(skb, dev);
-			netif_rx(skb);
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += pkt_len;
-
-		      out:
-			/* give the buffer back to the card */
-			card->rx_buffer[4*descnr] =  cpu_to_le32(0x80000000);
-			trigger_receive(card);
+		if (pkt_len > 1518) {
+			netdev_err(dev, "Packet length %i is bogus\n", pkt_len);
+			pkt_len = 1518;
 		}
 
-		func_exit();
+		skb = dev_alloc_skb(pkt_len + 2);
+		if (skb == NULL) {
+			dev->stats.rx_dropped++;
+			goto out;
+		}
+		skb_reserve(skb, 2);
+		skb_copy_to_linear_data(skb,
+					&card->rx_buffer[bufferoffset / 4],
+					pkt_len);
+		skb_put(skb, pkt_len);
+		skb->protocol = eth_type_trans(skb, dev);
+		netif_rx(skb);
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
+
+out:
+		/* give the buffer back to the card */
+		card->rx_buffer[4*descnr] =  cpu_to_le32(0x80000000);
+		trigger_receive(card);
+	}
 
+	func_exit();
 }
 
 
 /* Bufferoffset is in BYTES */
-static void investigate_write_descriptor(struct net_device *dev, struct xircom_private *card, int descnr, unsigned int bufferoffset)
+static void
+investigate_write_descriptor(struct net_device *dev,
+			     struct xircom_private *card,
+			     int descnr, unsigned int bufferoffset)
 {
-		int status;
+	int status;
 
-		func_enter();
+	func_enter();
 
-		status = le32_to_cpu(card->tx_buffer[4*descnr]);
+	status = le32_to_cpu(card->tx_buffer[4*descnr]);
 #if 0
-		if (status & 0x8000) {	/* Major error */
-			pr_err("Major transmit error status %x\n", status);
-			card->tx_buffer[4*descnr] = 0;
-			netif_wake_queue (dev);
-		}
+	if (status & 0x8000) {	/* Major error */
+		netdev_err(dev, "Major transmit error status %x\n", status);
+		card->tx_buffer[4*descnr] = 0;
+		netif_wake_queue(dev);
+	}
 #endif
-		if (status > 0) {	/* bit 31 is 0 when done */
-			if (card->tx_skb[descnr]!=NULL) {
-				dev->stats.tx_bytes += card->tx_skb[descnr]->len;
-				dev_kfree_skb_irq(card->tx_skb[descnr]);
-			}
-			card->tx_skb[descnr] = NULL;
-			/* Bit 8 in the status field is 1 if there was a collision */
-			if (status&(1<<8))
-				dev->stats.collisions++;
-			card->tx_buffer[4*descnr] = 0; /* descriptor is free again */
-			netif_wake_queue (dev);
-			dev->stats.tx_packets++;
+	if (status > 0) {	/* bit 31 is 0 when done */
+		if (card->tx_skb[descnr] != NULL) {
+			dev->stats.tx_bytes += card->tx_skb[descnr]->len;
+			dev_kfree_skb_irq(card->tx_skb[descnr]);
 		}
+		card->tx_skb[descnr] = NULL;
+		/* Bit 8 in the status field is 1 if there was a collision */
+		if (status&(1<<8))
+			dev->stats.collisions++;
+		card->tx_buffer[4*descnr] = 0; /* descriptor is free again */
+		netif_wake_queue(dev);
+		dev->stats.tx_packets++;
+	}
 
-		func_exit();
-
+	func_exit();
 }
 
 
-- 
1.7.5.rc3.dirty
