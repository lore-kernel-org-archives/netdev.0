From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.5 2/4] pcnet32 all printk under netif_msg
Date: Mon, 5 Apr 2004 14:26:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404052126.i35LQWc10992@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patch to 2.6.5.

All printk's are now done under netif_msg debug level tests.

--- linux-2.6.5/drivers/net/add.pcnet32.c	Mon Apr  5 11:40:57 2004
+++ linux-2.6.5/drivers/net/pcnet32.c	Mon Apr  5 13:37:56 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.28"
-#define DRV_RELDATE	"02.20.2004"
+#define DRV_VERSION	"1.29"
+#define DRV_RELDATE	"04.06.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -484,11 +484,11 @@
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void pcnet32_poll_controller(struct net_device *dev)
-{ 
+{
 	disable_irq(dev->irq);
 	pcnet32_interrupt(0, dev, NULL);
 	enable_irq(dev->irq);
-} 
+}
 #endif
 
 
@@ -611,7 +611,7 @@
 	    test->flags |= ETH_TEST_FL_FAILED;
 	} else if (netif_msg_hw(lp))
 	    printk(KERN_DEBUG "%s: Loopback test passed.\n", dev->name);
-    } else
+    } else if (netif_msg_hw(lp))
 	printk(KERN_DEBUG "%s: No tests to run (specify 'Offline' on ethtool).",	    dev->name);
 } /* end pcnet32_ethtool_test */
 
@@ -793,23 +793,27 @@
 
     err = pci_enable_device(pdev);
     if (err < 0) {
-	printk(KERN_ERR PFX "failed to enable device -- err=%d\n", err);
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "failed to enable device -- err=%d\n", err);
 	return err;
     }
     pci_set_master(pdev);
 
     ioaddr = pci_resource_start (pdev, 0);
     if (!ioaddr) {
-	printk (KERN_ERR PFX "card has no PCI IO resources, aborting\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk (KERN_ERR PFX "card has no PCI IO resources, aborting\n");
 	return -ENODEV;
     }
 
     if (!pci_dma_supported(pdev, PCNET32_DMA_MASK)) {
-	printk(KERN_ERR PFX "architecture does not support 32bit PCI busmaster DMA\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "architecture does not support 32bit PCI busmaster DMA\n");
 	return -ENODEV;
     }
     if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_pci") == NULL) {
-	printk(KERN_ERR PFX "io address range already allocated\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "io address range already allocated\n");
 	return -EBUSY;
     }
 
@@ -847,14 +851,15 @@
 	if (pcnet32_dwio_read_csr(ioaddr, 0) == 4 && pcnet32_dwio_check(ioaddr)) {
 	    a = &pcnet32_dwio;
 	} else
-		goto err_release_region;
+	    goto err_release_region;
     }
 
     chip_version = a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr,89) << 16);
-    if (pcnet32_debug & NETIF_MSG_PROBE)
+    if ((pcnet32_debug & NETIF_MSG_PROBE) && (pcnet32_debug & NETIF_MSG_HW))
 	printk(KERN_INFO "  PCnet chip version is %#x.\n", chip_version);
     if ((chip_version & 0xfff) != 0x003) {
-	printk(KERN_INFO PFX "Unsupported chip version.\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_INFO PFX "Unsupported chip version.\n");
 	goto err_release_region;
     }
 
@@ -914,8 +919,9 @@
 	fdx = 1; mii = 1;
 	break;
     default:
-	printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
-		chip_version);
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
+		    chip_version);
 	goto err_release_region;
     }
 
@@ -935,13 +941,15 @@
 
     dev = alloc_etherdev(0);
     if (!dev) {
-	printk(KERN_ERR PFX "Memory allocation failed.\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "Memory allocation failed.\n");
 	ret = -ENOMEM;
 	goto err_release_region;
     }
     SET_NETDEV_DEV(dev, &pdev->dev);
 
-    printk(KERN_INFO PFX "%s at %#3lx,", chipname, ioaddr);
+    if (pcnet32_debug & NETIF_MSG_PROBE)
+	printk(KERN_INFO PFX "%s at %#3lx,", chipname, ioaddr);
 
     /* In most chips, after a chip reset, the ethernet address is read from the
      * station address PROM at the base address and programmed into the
@@ -970,8 +978,10 @@
 	if (!is_valid_ether_addr(dev->dev_addr)
 	    && is_valid_ether_addr(promaddr)) {
 #endif
-	    printk(" warning: CSR address invalid,\n");
-	    printk(KERN_INFO "    using instead PROM address of");
+	    if (pcnet32_debug & NETIF_MSG_PROBE) {
+		printk(" warning: CSR address invalid,\n");
+		printk(KERN_INFO "    using instead PROM address of");
+	    }
 	    memcpy(dev->dev_addr, promaddr, 6);
 	}
     }
@@ -980,36 +990,40 @@
     if (!is_valid_ether_addr(dev->dev_addr))
 	memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
-    for (i = 0; i < 6; i++)
-	printk(" %2.2x", dev->dev_addr[i] );
-
-    if (((chip_version + 1) & 0xfffe) == 0x2624) { /* Version 0x2623 - 0x2624 */
-	i = a->read_csr(ioaddr, 80) & 0x0C00;  /* Check tx_start_pt */
-	printk("\n" KERN_INFO "    tx_start_pt(0x%04x):",i);
-	switch(i>>10) {
-	    case 0: printk("  20 bytes,"); break;
-	    case 1: printk("  64 bytes,"); break;
-	    case 2: printk(" 128 bytes,"); break;
-	    case 3: printk("~220 bytes,"); break;
+    if (pcnet32_debug & NETIF_MSG_PROBE) {
+	for (i = 0; i < 6; i++)
+	    printk(" %2.2x", dev->dev_addr[i] );
+
+	/* Version 0x2623 and 0x2624 */
+	if (((chip_version + 1) & 0xfffe) == 0x2624) {
+	    i = a->read_csr(ioaddr, 80) & 0x0C00;  /* Check tx_start_pt */
+	    printk("\n" KERN_INFO "    tx_start_pt(0x%04x):",i);
+	    switch(i>>10) {
+		case 0: printk("  20 bytes,"); break;
+		case 1: printk("  64 bytes,"); break;
+		case 2: printk(" 128 bytes,"); break;
+		case 3: printk("~220 bytes,"); break;
+	    }
+	    i = a->read_bcr(ioaddr, 18);  /* Check Burst/Bus control */
+	    printk(" BCR18(%x):",i&0xffff);
+	    if (i & (1<<5)) printk("BurstWrEn ");
+	    if (i & (1<<6)) printk("BurstRdEn ");
+	    if (i & (1<<7)) printk("DWordIO ");
+	    if (i & (1<<11)) printk("NoUFlow ");
+	    i = a->read_bcr(ioaddr, 25);
+	    printk("\n" KERN_INFO "    SRAMSIZE=0x%04x,",i<<8);
+	    i = a->read_bcr(ioaddr, 26);
+	    printk(" SRAM_BND=0x%04x,",i<<8);
+	    i = a->read_bcr(ioaddr, 27);
+	    if (i & (1<<14)) printk("LowLatRx");
 	}
-	i = a->read_bcr(ioaddr, 18);  /* Check Burst/Bus control */
-	printk(" BCR18(%x):",i&0xffff);
-	if (i & (1<<5)) printk("BurstWrEn ");
-	if (i & (1<<6)) printk("BurstRdEn ");
-	if (i & (1<<7)) printk("DWordIO ");
-	if (i & (1<<11)) printk("NoUFlow ");
-	i = a->read_bcr(ioaddr, 25);
-	printk("\n" KERN_INFO "    SRAMSIZE=0x%04x,",i<<8);
-	i = a->read_bcr(ioaddr, 26);
-	printk(" SRAM_BND=0x%04x,",i<<8);
-	i = a->read_bcr(ioaddr, 27);
-	if (i & (1<<14)) printk("LowLatRx");
     }
 
     dev->base_addr = ioaddr;
     /* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
     if ((lp = pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
-	printk(KERN_ERR PFX "Consistent memory allocation failed.\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "Consistent memory allocation failed.\n");
 	ret = -ENOMEM;
 	goto err_free_netdev;
     }
@@ -1045,7 +1059,8 @@
 	lp->options |= PCNET32_PORT_FD;
 
     if (!a) {
-	printk(KERN_ERR PFX "No access methods\n");
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(KERN_ERR PFX "No access methods\n");
 	ret = -ENODEV;
 	goto err_free_consistent;
     }
@@ -1079,9 +1094,10 @@
 	dev->irq = irq_line;
     }
 
-    if (dev->irq >= 2)
-	printk(" assigned IRQ %d.\n", dev->irq);
-    else {
+    if (dev->irq >= 2) {
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(" assigned IRQ %d.\n", dev->irq);
+    } else {
 	unsigned long irq_mask = probe_irq_on();
 
 	/*
@@ -1095,11 +1111,13 @@
 
 	dev->irq = probe_irq_off (irq_mask);
 	if (!dev->irq) {
-	    printk(", failed to detect IRQ line.\n");
+	    if (pcnet32_debug & NETIF_MSG_PROBE)
+		printk(", failed to detect IRQ line.\n");
 	    ret = -ENODEV;
 	    goto err_free_consistent;
 	}
-	printk(", probed IRQ %d.\n", dev->irq);
+	if (pcnet32_debug & NETIF_MSG_PROBE)
+	    printk(", probed IRQ %d.\n", dev->irq);
     }
 
     /* Set the mii phy_id so that we can query the link state */
@@ -1123,7 +1141,7 @@
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
     dev->poll_controller = pcnet32_poll_controller;
-#endif    
+#endif
 
     /* Fill in the generic fields of the device structure. */
     if (register_netdev(dev))
@@ -1136,7 +1154,8 @@
 	pcnet32_dev = dev;
     }
 
-    printk(KERN_INFO "%s: registered as %s\n",dev->name, lp->name);
+    if (pcnet32_debug & NETIF_MSG_PROBE)
+	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
     return 0;
 
@@ -1265,7 +1284,7 @@
 
     /* If we have mii, print the link status and start the watchdog */
     if (lp->mii) {
-	mii_check_media (&lp->mii_if, 1, 1);
+	mii_check_media (&lp->mii_if, netif_msg_link(lp), 1);
 	mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
     }
 
@@ -1358,8 +1377,9 @@
 	if (rx_skbuff == NULL) {
 	    if (!(rx_skbuff = lp->rx_skbuff[i] = dev_alloc_skb (PKT_BUF_SZ))) {
 		/* there is not much, we can do at this point */
-		printk(KERN_ERR "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
-			dev->name);
+		if (pcnet32_debug & NETIF_MSG_DRV)
+		    printk(KERN_ERR "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
+			    dev->name);
 		return -1;
 	    }
 	    skb_reserve (rx_skbuff, 2);
@@ -1421,8 +1441,9 @@
 
     spin_lock_irqsave(&lp->lock, flags);
     /* Transmitter timeout, serious problems. */
-    printk(KERN_ERR "%s: transmit timed out, status %4.4x, resetting.\n",
-	   dev->name, lp->a.read_csr(ioaddr, 0));
+    if (pcnet32_debug & NETIF_MSG_DRV)
+	printk(KERN_ERR "%s: transmit timed out, status %4.4x, resetting.\n",
+		dev->name, lp->a.read_csr(ioaddr, 0));
     lp->a.write_csr (ioaddr, 0, 0x0004);
     lp->stats.tx_errors++;
     if (netif_msg_tx_err(lp)) {
@@ -1530,7 +1551,8 @@
     int must_restart;
 
     if (!dev) {
-	printk (KERN_DEBUG "%s(): irq %d for unknown device\n",
+	if (pcnet32_debug & NETIF_MSG_INTR)
+	    printk (KERN_DEBUG "%s(): irq %d for unknown device\n",
 		__FUNCTION__, irq);
 	return IRQ_NONE;
     }
@@ -1582,8 +1604,9 @@
 			lp->stats.tx_fifo_errors++;
 			/* Ackk!  On FIFO errors the Tx unit is turned off! */
 			/* Remove this verbosity later! */
-			printk(KERN_ERR "%s: Tx FIFO error! CSR0=%4.4x\n",
-			       dev->name, csr0);
+			if (netif_msg_tx_err(lp))
+			    printk(KERN_ERR "%s: Tx FIFO error! CSR0=%4.4x\n",
+				    dev->name, csr0);
 			must_restart = 1;
 		    }
 #else
@@ -1592,8 +1615,9 @@
 			if (! lp->dxsuflo) {  /* If controller doesn't recover ... */
 			    /* Ackk!  On FIFO errors the Tx unit is turned off! */
 			    /* Remove this verbosity later! */
-			    printk(KERN_ERR "%s: Tx FIFO error! CSR0=%4.4x\n",
-				   dev->name, csr0);
+			    if (netif_msg_tx_err(lp))
+				printk(KERN_ERR "%s: Tx FIFO error! CSR0=%4.4x\n",
+					dev->name, csr0);
 			    must_restart = 1;
 			}
 		    }
@@ -1617,8 +1641,9 @@
 
 	    delta = (lp->cur_tx - dirty_tx) & (TX_RING_MOD_MASK + TX_RING_SIZE);
 	    if (delta >= TX_RING_SIZE) {
-		printk(KERN_ERR "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-			dev->name, dirty_tx, lp->cur_tx, lp->tx_full);
+		if (netif_msg_drv(lp))
+		    printk(KERN_ERR "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+			    dev->name, dirty_tx, lp->cur_tx, lp->tx_full);
 		dirty_tx += TX_RING_SIZE;
 		delta -= TX_RING_SIZE;
 	    }
@@ -1650,8 +1675,9 @@
 	    lp->stats.rx_errors++; /* Missed a Rx frame. */
 	}
 	if (csr0 & 0x0800) {
-	    printk(KERN_ERR "%s: Bus master arbitration failure, status %4.4x.\n",
-		   dev->name, csr0);
+	    if (netif_msg_drv(lp))
+		printk(KERN_ERR "%s: Bus master arbitration failure, status %4.4x.\n",
+			dev->name, csr0);
 	    /* unlike for the lance, there is no restart needed */
 	}
 
@@ -1668,7 +1694,7 @@
 
     if (netif_msg_intr(lp))
 	printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-	       dev->name, lp->a.read_csr (ioaddr, 0));
+		dev->name, lp->a.read_csr (ioaddr, 0));
 
     spin_unlock(&lp->lock);
 
@@ -1705,7 +1731,8 @@
 	    struct sk_buff *skb;
 
 	    if (pkt_len < 60) {
-		printk(KERN_ERR "%s: Runt packet!\n",dev->name);
+		if (netif_msg_rx_err(lp))
+		    printk(KERN_ERR "%s: Runt packet!\n", dev->name);
 		lp->stats.rx_errors++;
 	    } else {
 		int rx_in_place = 0;
@@ -1734,8 +1761,9 @@
 
 		if (skb == NULL) {
 		    int i;
-		    printk(KERN_ERR "%s: Memory squeeze, deferring packet.\n",
-			    dev->name);
+		    if (netif_msg_drv(lp))
+			printk(KERN_ERR "%s: Memory squeeze, deferring packet.\n",
+				dev->name);
 		    for (i = 0; i < RX_RING_SIZE; i++)
 			if ((short)le16_to_cpu(lp->rx_ring[(entry+i)
 				    & RX_RING_MOD_MASK].status) < 0)
@@ -1904,7 +1932,8 @@
     spin_lock_irqsave(&lp->lock, flags);
     if (dev->flags&IFF_PROMISC) {
 	/* Log any net taps. */
-	printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
+	if (netif_msg_hw(lp))
+	    printk(KERN_INFO "%s: Promiscuous mode enabled.\n", dev->name);
 	lp->init_block.mode = le16_to_cpu(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) << 7);
     } else {
 	lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
@@ -1979,7 +2008,7 @@
     /* Print the link status if it has changed */
     if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);
-	mii_check_media (&lp->mii_if, 1, 0);
+	mii_check_media (&lp->mii_if, netif_msg_link(lp), 0);
 	spin_unlock_irqrestore(&lp->lock, flags);
     }
 
@@ -2027,6 +2056,8 @@
 MODULE_DESCRIPTION("Driver for PCnet32 and PCnetPCI based ethercards");
 MODULE_LICENSE("GPL");
 
+#define PCNET32_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
+
 /* An additional parameter that may be passed in... */
 static int debug = -1;
 static int tx_start_pt = -1;
@@ -2036,8 +2067,7 @@
 {
     printk(KERN_INFO "%s", version);
 
-    if (debug >= 0 && debug < (sizeof(int) - 1))
-	pcnet32_debug = 1 << debug;
+    pcnet32_debug = netif_msg_init(debug, PCNET32_MSG_DEFAULT);
 
     if ((tx_start_pt >= 0) && (tx_start_pt <= 3))
 	tx_start = tx_start_pt;
@@ -2050,7 +2080,7 @@
     if (pcnet32vlb)
 	pcnet32_probe_vlbus();
 
-    if (cards_found)
+    if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
 	printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
 
     return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
@@ -2079,7 +2109,6 @@
 
 /*
  * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -Wall -Wstrict-prototypes -O6 -m486 -c pcnet32.c"
  *  c-indent-level: 4
  *  tab-width: 8
  * End:

-- 
Don Fry
brazilnut@us.ibm.com
