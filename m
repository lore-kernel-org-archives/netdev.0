From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.26-rc2] pcnet32 fix hang/crash with loopback test
Date: Wed, 7 Apr 2004 15:51:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404072251.i37MpZ219567@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If the pcnet32 interface is not up, running the loopback test may hang or
crash the system.  This patch provided by Jim Lewis fixes that problem.
Tested on ia32 and ppc systems.

--- linux-2.4.26-rc2/drivers/net/orig.pcnet32.c	Wed Apr  7 15:21:05 2004
+++ linux-2.4.26-rc2/drivers/net/pcnet32.c	Wed Apr  7 15:36:56 2004
@@ -351,6 +351,7 @@
 static void pcnet32_interrupt(int, void *, struct pt_regs *);
 static int  pcnet32_close(struct net_device *);
 static struct net_device_stats *pcnet32_get_stats(struct net_device *);
+static void pcnet32_load_multicast(struct net_device *dev);
 static void pcnet32_set_multicast_list(struct net_device *);
 static int  pcnet32_ioctl(struct net_device *, struct ifreq *, int);
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num);
@@ -607,32 +608,40 @@
     struct pcnet32_access *a = &lp->a;	/* access to registers */
     ulong ioaddr = dev->base_addr;	/* card base I/O address */
     struct sk_buff *skb;		/* sk buff */
-    int x, y, i;			/* counters */
+    int x, i;				/* counters */
     int numbuffs = 4;			/* number of TX/RX buffers and descs */
     u16 status = 0x8300;		/* TX ring status */
+    u16 teststatus;			/* test of ring status */
     int rc;				/* return code */
     int size;				/* size of packets */
     unsigned char *packet;		/* source packet data */
     static int data_len = 60;		/* length of source packets */
     unsigned long flags;
+    unsigned long ticks;
 
     *data1 = 1;			/* status of test, default to fail */
     rc = 1;			/* default to fail */
 
+    if (netif_running(dev))
+	pcnet32_close(dev);
+
     spin_lock_irqsave(&lp->lock, flags);
-    lp->a.write_csr(ioaddr, 0, 0x7904);
 
-    netif_stop_queue(dev);
+    /* Reset the PCNET32 */
+    lp->a.reset (ioaddr);
+
+    /* switch pcnet32 to 32bit mode */
+    lp->a.write_bcr (ioaddr, 20, 2);
+
+    lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
+    lp->init_block.filter[0] = 0;
+    lp->init_block.filter[1] = 0;
 
     /* purge & init rings but don't actually restart */
     pcnet32_restart(dev, 0x0000);
 
     lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
 
-    x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
-    x = x | 0x00000002;
-    a->write_bcr(ioaddr, 32, x);
-
     /* Initialize Transmit buffers. */
     size = data_len + 15;
     for (x=0; x<numbuffs; x++) {
@@ -646,19 +655,21 @@
 	    skb_put(skb, size);		/* create space for data */
 	    lp->tx_skbuff[x] = skb;
 	    lp->tx_ring[x].length = le16_to_cpu(-skb->len);
-	    lp->tx_ring[x].misc = 0x00000000;
+	    lp->tx_ring[x].misc = 0;
 
-	    /* put DA and SA into the skb */
-	    for (i=0; i<12; i++)
-		*packet++ = 0xff;
+            /* put DA and SA into the skb */
+	    for (i=0; i<6; i++)
+		*packet++ = dev->dev_addr[i];
+	    for (i=0; i<6; i++)
+		*packet++ = dev->dev_addr[i]; 
 	    /* type */
 	    *packet++ = 0x08;
 	    *packet++ = 0x06;
 	    /* packet number */
 	    *packet++ = x;
 	    /* fill packet with data */
-	    for (y=0; y<data_len; y++)
-		*packet++ = y;
+	    for (i=0; i<data_len; i++)
+		*packet++ = i;
 
 	    lp->tx_dma_addr[x] = pci_map_single(lp->pci_dev, skb->data,
 		    skb->len, PCI_DMA_TODEVICE);
@@ -668,20 +679,41 @@
 	}
     }
 
-    lp->a.write_csr(ioaddr, 0, 0x0002);	/* Set STRT bit */
-    spin_unlock_irqrestore(&lp->lock, flags);
+    x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
+    x = x | 0x0002;
+    a->write_bcr(ioaddr, 32, x);
 
-    mdelay(50);				/* wait a bit */
+    lp->a.write_csr (ioaddr, 15, 0x0044);	/* set int loopback in CSR15 */
 
-    spin_lock_irqsave(&lp->lock, flags);
-    lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
+    teststatus = le16_to_cpu(0x8000);
+    lp->a.write_csr(ioaddr, 0, 0x0002);		/* Set STRT bit */
 
+    /* Check status of descriptors */
+    for (x=0; x<numbuffs; x++) {
+	ticks = 0;
+	rmb();
+	while ((lp->rx_ring[x].status & teststatus) && (ticks < 200)) {
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	    mdelay(1);
+	    spin_lock_irqsave(&lp->lock, flags);
+	    rmb();
+	    ticks++;
+	}
+	if (ticks == 200) {
+	    if (netif_msg_hw(lp))
+		printk("%s: Desc %d failed to reset!\n",dev->name,x);
+	    break;
+	}
+    }
+
+    lp->a.write_csr(ioaddr, 0, 0x0004);		/* Set STOP bit */
+    wmb();
     if (netif_msg_hw(lp) && netif_msg_pktdata(lp)) {
 	printk(KERN_DEBUG "%s: RX loopback packets:\n", dev->name);
 
 	for (x=0; x<numbuffs; x++) {
 	    printk(KERN_DEBUG "%s: Packet %d:\n", dev->name, x);
-	    skb=lp->rx_skbuff[x];
+	    skb = lp->rx_skbuff[x];
 	    for (i=0; i<size; i++) {
 		printk("%02x ", *(skb->data+i));
 	    }
@@ -714,17 +746,17 @@
     a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
 
     x = a->read_bcr(ioaddr, 32);		/* reset internal loopback */
-    x = x & ~0x00000002;
+    x = x & ~0x0002;
     a->write_bcr(ioaddr, 32, x);
 
-    pcnet32_restart(dev, 0x0042);		/* resume normal operation */
-
-    netif_wake_queue(dev);
-
-    /* Clear interrupts, and set interrupt enable. */
-    lp->a.write_csr(ioaddr, 0, 0x7940);
     spin_unlock_irqrestore(&lp->lock, flags);
 
+    if (netif_running(dev)) {
+	pcnet32_open(dev);
+    } else {
+	lp->a.write_bcr (ioaddr, 20, 4);	/* return to 16bit mode */
+    }
+
     return(rc);
 } /* end pcnet32_loopback_test  */
 
@@ -955,7 +987,7 @@
 	memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
     for (i = 0; i < 6; i++)
-	printk(" %2.2x", dev->dev_addr[i] );
+	printk(" %2.2x", dev->dev_addr[i]);
 
     if (((chip_version + 1) & 0xfffe) == 0x2624) { /* Version 0x2623 or 0x2624 */
 	i = a->read_csr(ioaddr, 80) & 0x0C00;  /* Check tx_start_pt */
@@ -1113,6 +1145,7 @@
     u16 val;
     int i;
     int rc;
+    unsigned long flags;
 
     if (dev->irq == 0 ||
 	request_irq(dev->irq, &pcnet32_interrupt,
@@ -1120,6 +1153,7 @@
 	return -EAGAIN;
     }
 
+    spin_lock_irqsave(&lp->lock, flags);
     /* Check for a valid station address */
     if (!is_valid_ether_addr(dev->dev_addr)) {
 	rc = -EINVAL;
@@ -1196,8 +1230,8 @@
     }
    
     lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
-    lp->init_block.filter[0] = 0x00000000;
-    lp->init_block.filter[1] = 0x00000000;
+    pcnet32_load_multicast(dev);
+
     if (pcnet32_init_ring(dev)) {
 	rc = -ENOMEM;
 	goto err_free_ring;
@@ -1227,6 +1261,7 @@
 	       dev->name, i, (u32) (lp->dma_addr + offsetof(struct pcnet32_private, init_block)),
 	       lp->a.read_csr(ioaddr, 0));
 
+    spin_unlock_irqrestore(&lp->lock, flags);
 
     MOD_INC_USE_COUNT;
     
@@ -1251,6 +1286,7 @@
     lp->a.write_bcr (ioaddr, 20, 4);
 
 err_free_irq:
+    spin_unlock_irqrestore(&lp->lock, flags);
     free_irq(dev->irq, dev);
     return rc;
 }
@@ -1720,9 +1756,12 @@
     unsigned long ioaddr = dev->base_addr;
     struct pcnet32_private *lp = dev->priv;
     int i;
+    unsigned long flags;
 
     netif_stop_queue(dev);
 
+    spin_lock_irqsave(&lp->lock, flags);
+
     lp->stats.rx_missed_errors = lp->a.read_csr (ioaddr, 112);
 
     if (netif_msg_ifdown(lp))
@@ -1738,6 +1777,8 @@
      */
     lp->a.write_bcr (ioaddr, 20, 4);
 
+    spin_unlock_irqrestore(&lp->lock, flags);
+
     free_irq(dev->irq, dev);
     
     /* free all allocated skbuffs */

-- 
Don Fry
brazilnut@us.ibm.com
