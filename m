From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2 2.4.27] pcnet32: recover after rx hang.
Date: Mon, 9 Aug 2004 16:15:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809231539.GC13717@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a receive hang that occasionally occurs after a Tx
FIFO underrun.  The receive dma remains in a hung state sometimes.  The
transmit operations continue to occur, but no receive activity.

This was reproduced on several ppc64 systems and the fix has been
verified there.  The patch has been tested as well on an ia32 system,
which did not experience the hang because it did not have fifo underruns,
which is a preqrequisite for the hang.  The memory barriers decreased the
frequency of occurrence.  The final change to reset the chip instead of
just stopping it eliminated the last hangs.

Signed-off by: brazilnut@us.ibm.com

--- linux-2.4.27/drivers/net/large.pcnet32.c	Mon Aug  9 15:41:31 2004
+++ linux-2.4.27/drivers/net/pcnet32.c	Mon Aug  9 15:41:42 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30d"
-#define DRV_RELDATE	"06.01.2004"
+#define DRV_VERSION	"1.30e"
+#define DRV_RELDATE	"06.11.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -246,6 +246,7 @@ static int full_duplex[MAX_UNITS];
  *	   assisted by Bruce Penrod <bmpenrod@endruntechnologies.com>.
  * v1.30c  25 May 2004 Don Fry added netif_wake_queue after pcnet32_restart.
  * v1.30d  01 Jun 2004 Don Fry discard oversize rx packets.
+ * v1.30e  11 Jun 2004 Don Fry recover after fifo error and rx hang.
  */
 
 
@@ -1531,13 +1532,15 @@ pcnet32_purge_tx_ring(struct net_device 
     int i;
 
     for (i = 0; i < TX_RING_SIZE; i++) {
+	lp->tx_ring[i].status = 0;	/* CPU owns buffer */
+	wmb();	/* Make sure adapter sees owner change */
 	if (lp->tx_skbuff[i]) {
 	    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
 		    lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
 	    dev_kfree_skb_any(lp->tx_skbuff[i]);
-	    lp->tx_skbuff[i] = NULL;
-	    lp->tx_dma_addr[i] = 0;
 	}
+	lp->tx_skbuff[i] = NULL;
+	lp->tx_dma_addr[i] = 0;
     }
 }
 
@@ -1566,21 +1569,23 @@ pcnet32_init_ring(struct net_device *dev
 	    skb_reserve (rx_skbuff, 2);
 	}
 
+	rmb();
 	if (lp->rx_dma_addr[i] == 0)
 	    lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev, rx_skbuff->tail,
 		    PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 	lp->rx_ring[i].base = (u32)le32_to_cpu(lp->rx_dma_addr[i]);
 	lp->rx_ring[i].buf_length = le16_to_cpu(2-PKT_BUF_SZ);
+	wmb();	/* Make sure owner changes after all others are visible */
 	lp->rx_ring[i].status = le16_to_cpu(0x8000);
     }
     /* The Tx buffer address is filled in as needed, but we do need to clear
      * the upper ownership bit. */
     for (i = 0; i < TX_RING_SIZE; i++) {
+	lp->tx_ring[i].status = 0;	/* CPU owns buffer */
+	wmb();	/* Make sure adapter sees owner change */
 	lp->tx_ring[i].base = 0;
-	lp->tx_ring[i].status = 0;
 	lp->tx_dma_addr[i] = 0;
     }
-    wmb(); /* Make sure all changes are visible */
 
     lp->init_block.tlen_rlen = le16_to_cpu(TX_RING_LEN_BITS | RX_RING_LEN_BITS);
     for (i = 0; i < 6; i++)
@@ -1589,9 +1594,14 @@ pcnet32_init_ring(struct net_device *dev
 	    offsetof(struct pcnet32_private, rx_ring));
     lp->init_block.tx_ring = (u32)le32_to_cpu(lp->dma_addr +
 	    offsetof(struct pcnet32_private, tx_ring));
+    wmb();	/* Make sure all changes are visible */
     return 0;
 }
 
+/* the pcnet32 has been issued a stop or reset.  Wait for the stop bit
+ * then flush the pending transmit operations, re-initialize the ring,
+ * and tell the chip to initialize.
+ */
 static void
 pcnet32_restart(struct net_device *dev, unsigned int csr0_bits)
 {
@@ -1599,6 +1609,15 @@ pcnet32_restart(struct net_device *dev, 
     unsigned long ioaddr = dev->base_addr;
     int i;
 
+    /* wait for stop */
+    for (i=0; i<100; i++)
+	if (lp->a.read_csr(ioaddr, 0) & 0x0004)
+	   break;
+
+    if (i >= 100 && netif_msg_drv(lp))
+	printk(KERN_ERR "%s: pcnet32_restart timed out waiting for stop.\n",
+		dev->name);
+
     pcnet32_purge_tx_ring(dev);
     if (pcnet32_init_ring(dev))
 	return;
@@ -1735,7 +1754,7 @@ pcnet32_interrupt(int irq, void *dev_id,
     spin_lock(&lp->lock);
 
     rap = lp->a.read_rap(ioaddr);
-    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
+    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
 	if (csr0 == 0xffff) {
 	    break;			/* PCMCIA remove happened */
 	}
@@ -1857,15 +1876,16 @@ pcnet32_interrupt(int irq, void *dev_id,
 	}
 
 	if (must_restart) {
-	    /* stop the chip to clear the error condition, then restart */
-	    lp->a.write_csr (ioaddr, 0, 0x0004);
+	    /* reset the chip to clear the error condition, then restart */
+	    lp->a.reset(ioaddr);
+	    lp->a.write_csr(ioaddr, 4, 0x0915);
 	    pcnet32_restart(dev, 0x0002);
 	    netif_wake_queue(dev);
 	}
     }
 
-    /* Clear any other interrupt, and set interrupt enable. */
-    lp->a.write_csr (ioaddr, 0, 0x7940);
+    /* Set interrupt enable. */
+    lp->a.write_csr (ioaddr, 0, 0x0040);
     lp->a.write_rap (ioaddr,rap);
 
     if (netif_msg_intr(lp))

-- 
Don Fry
brazilnut@us.ibm.com
