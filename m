From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 8/8 2.4.26-bk1] pcnet32 timer to free tx skbs for 79C971/972
Date: Tue, 20 Apr 2004 13:19:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404202019.i3KKJwU13709@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch uses an on-chip timer to free completed transmit skb's for the
79C971 and 972 versions which currently will leave completed transmit
skb's on the transmit ring until new transmit traffic occurs.

--- linux-2.4.26-bk1/drivers/net/dump.pcnet32.c	Tue Apr 20 12:54:49 2004
+++ linux-2.4.26-bk1/drivers/net/pcnet32.c	Tue Apr 20 12:54:57 2004
@@ -237,6 +237,8 @@
  *	   Thomas Munck Steenholdt <tmus@tmus.dk> non-mii ioctl corrections.
  * v1.29   6 Apr 2004 Jim Lewis <jklewis@us.ibm.com> added physical
  *	   identification code (blink led's) and register dump.
+ *	   Don Fry added timer for 971/972 so skbufs don't remain on tx ring
+ *	   forever.
  */
 
 
@@ -1104,6 +1106,13 @@
 	ltint = 1;
     }
 
+    if (ltint) {
+	/* Enable timer to prevent skbuffs from remaining on the tx ring
+	 * forever if no other tx being done.  Set timer period to about
+	 * 122 ms */
+	a->write_bcr(ioaddr, 31, 0x253b);
+    }
+
     dev = alloc_etherdev(0);
     if (!dev) {
 	if (pcnet32_debug & NETIF_MSG_PROBE)
@@ -1450,6 +1459,11 @@
     lp->a.write_csr (ioaddr, 4, 0x0915);
     lp->a.write_csr (ioaddr, 0, 0x0001);
 
+    if (lp->ltint) {
+	/* start the software timer */
+	lp->a.write_csr(ioaddr, 7, 0x0400);	/* set STINTE */
+    }
+
     netif_start_queue(dev);
 
     /* If we have mii, print the link status and start the watchdog */
@@ -1651,13 +1665,13 @@
     int entry;
     unsigned long flags;
 
+    spin_lock_irqsave(&lp->lock, flags);
+
     if (netif_msg_tx_queued(lp)) {
 	printk(KERN_DEBUG "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
 	       dev->name, lp->a.read_csr(ioaddr, 0));
     }
 
-    spin_lock_irqsave(&lp->lock, flags);
-
     /* Default status -- will not enable Successful-TxDone
      * interrupt when that option is available to us.
      */
@@ -1718,7 +1732,7 @@
     struct net_device *dev = dev_id;
     struct pcnet32_private *lp;
     unsigned long ioaddr;
-    u16 csr0,rap;
+    u16 csr0, csr7, rap;
     int boguscnt =  max_interrupt_work;
     int must_restart;
 
@@ -1735,13 +1749,19 @@
     spin_lock(&lp->lock);
 
     rap = lp->a.read_rap(ioaddr);
-    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
+    csr0 = lp->a.read_csr (ioaddr, 0);
+    csr7 = lp->ltint ? lp->a.read_csr(ioaddr, 7) : 0;
+
+    while ((csr0 & 0x8600 || csr7 & 0x0800) && --boguscnt >= 0) {
 	if (csr0 == 0xffff) {
 	    break;			/* PCMCIA remove happened */
 	}
 	/* Acknowledge all of the current interrupt sources ASAP. */
 	lp->a.write_csr (ioaddr, 0, csr0 & ~0x004f);
 
+	if (csr7 & 0x0800)
+	    lp->a.write_csr(ioaddr, 7, csr7);
+
 	must_restart = 0;
 
 	if (netif_msg_intr(lp))
@@ -1751,7 +1771,7 @@
 	if (csr0 & 0x0400)		/* Rx interrupt */
 	    pcnet32_rx(dev);
 
-	if (csr0 & 0x0200) {		/* Tx-done interrupt */
+	if (csr0 & 0x0200 || csr7 & 0x0800) {	/* Tx-done or Timer interrupt */
 	    unsigned int dirty_tx = lp->dirty_tx;
 	    int delta;
 
@@ -1858,6 +1878,9 @@
 	    lp->a.write_csr (ioaddr, 0, 0x0004);
 	    pcnet32_restart(dev, 0x0002);
 	}
+
+	csr0 = lp->a.read_csr (ioaddr, 0);
+	csr7 = lp->ltint ? lp->a.read_csr(ioaddr, 7) : 0;
     }
 
     /* Clear any other interrupt, and set interrupt enable. */
@@ -1942,6 +1965,7 @@
 		    if (i > RX_RING_SIZE -2) {
 			lp->stats.rx_dropped++;
 			lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
+			wmb();	/* Make sure adapter sees owner change */
 			lp->cur_rx++;
 		    }
 		    break;
@@ -2001,6 +2025,10 @@
     /* We stop the PCNET32 here -- it occasionally polls memory if we don't. */
     lp->a.write_csr (ioaddr, 0, 0x0004);
 
+    if (lp->ltint) {	/* Disable timer interrupts */
+	lp->a.write_csr(ioaddr, 7, 0x0000);
+    }
+
     /*
      * Switch back to 16bit mode to avoid problems with dumb
      * DOS packet driver after a warm reboot
@@ -2011,9 +2039,12 @@
 
     free_irq(dev->irq, dev);
 
+    spin_lock_irqsave(&lp->lock, flags);
+
     /* free all allocated skbuffs */
     for (i = 0; i < RX_RING_SIZE; i++) {
 	lp->rx_ring[i].status = 0;
+	wmb();		/* Make sure adapter sees owner change */
 	if (lp->rx_skbuff[i]) {
 	    pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
 		    PCI_DMA_FROMDEVICE);
@@ -2024,6 +2055,8 @@
     }
 
     for (i = 0; i < TX_RING_SIZE; i++) {
+	lp->tx_ring[i].status = 0;	/* CPU owns buffer */
+	wmb();		/* Make sure adapter sees owner change */
 	if (lp->tx_skbuff[i]) {
 	    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
 		    lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
@@ -2033,6 +2066,8 @@
 	lp->tx_dma_addr[i] = 0;
     }
 
+    spin_unlock_irqrestore(&lp->lock, flags);
+
     return 0;
 }
 

-- 
Don Fry
brazilnut@us.ibm.com
