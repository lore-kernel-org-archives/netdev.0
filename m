From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 15/15] drivers/net/yellowfin.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:02:02 -0800
Message-ID: <bc88729f2b8e7da71f2f3e2c760444a0f855b3a8.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Convert formats like %8.8 to %08
Remove periods from formats
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/yellowfin.c |  162 +++++++++++++++++++++++------------------------
 1 files changed, 78 insertions(+), 84 deletions(-)

diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 5c88024..e4aab4d 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -23,12 +23,12 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"yellowfin"
 #define DRV_VERSION	"2.1"
 #define DRV_RELDATE	"Sep 11, 2006"
 
-#define PFX DRV_NAME ": "
-
 /* The user-configurable values.
    These may be modified when a driver module is loaded.*/
 
@@ -399,7 +399,7 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(*np));
 	if (!dev) {
-		printk (KERN_ERR PFX "cannot allocate ethernet device\n");
+		pr_err("cannot allocate ethernet device\n");
 		return -ENOMEM;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -487,10 +487,10 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 	if (i)
 		goto err_out_unmap_status;
 
-	printk(KERN_INFO "%s: %s type %8x at %p, %pM, IRQ %d.\n",
-		   dev->name, pci_id_tbl[chip_idx].name,
-		   ioread32(ioaddr + ChipRev), ioaddr,
-		   dev->dev_addr, irq);
+	netdev_info(dev, "%s type %8x at %p, %pM, IRQ %d\n",
+		    pci_id_tbl[chip_idx].name,
+		    ioread32(ioaddr + ChipRev), ioaddr,
+		    dev->dev_addr, irq);
 
 	if (np->drv_flags & HasMII) {
 		int phy, phy_idx = 0;
@@ -499,9 +499,8 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 			if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 				np->phys[phy_idx++] = phy;
 				np->advertising = mdio_read(ioaddr, phy, 4);
-				printk(KERN_INFO "%s: MII PHY found at address %d, status "
-					   "0x%4.4x advertising %4.4x.\n",
-					   dev->name, phy, mii_status, np->advertising);
+				netdev_info(dev, "MII PHY found at address %d, status 0x%04x advertising %04x\n",
+					    phy, mii_status, np->advertising);
 			}
 		}
 		np->mii_cnt = phy_idx;
@@ -584,8 +583,8 @@ static int yellowfin_open(struct net_device *dev)
 		return ret;
 
 	if (yellowfin_debug > 1)
-		printk(KERN_DEBUG "%s: yellowfin_open() irq %d.\n",
-			   dev->name, dev->irq);
+		netdev_printk(KERN_DEBUG, dev, "%s() irq %d\n",
+			      __func__, dev->irq);
 
 	ret = yellowfin_init_ring(dev);
 	if (ret) {
@@ -642,8 +641,7 @@ static int yellowfin_open(struct net_device *dev)
 	iowrite32(0x80008000, ioaddr + TxCtrl);
 
 	if (yellowfin_debug > 2) {
-		printk(KERN_DEBUG "%s: Done yellowfin_open().\n",
-			   dev->name);
+		netdev_printk(KERN_DEBUG, dev, "Done %s()\n", __func__);
 	}
 
 	/* Set the timer to check for link beat. */
@@ -664,8 +662,8 @@ static void yellowfin_timer(unsigned long data)
 	int next_tick = 60*HZ;
 
 	if (yellowfin_debug > 3) {
-		printk(KERN_DEBUG "%s: Yellowfin timer tick, status %8.8x.\n",
-			   dev->name, ioread16(ioaddr + IntrStatus));
+		netdev_printk(KERN_DEBUG, dev, "Yellowfin timer tick, status %08x\n",
+			      ioread16(ioaddr + IntrStatus));
 	}
 
 	if (yp->mii_cnt) {
@@ -673,9 +671,8 @@ static void yellowfin_timer(unsigned long data)
 		int lpa = mdio_read(ioaddr, yp->phys[0], MII_LPA);
 		int negotiated = lpa & yp->advertising;
 		if (yellowfin_debug > 1)
-			printk(KERN_DEBUG "%s: MII #%d status register is %4.4x, "
-				   "link partner capability %4.4x.\n",
-				   dev->name, yp->phys[0], bmsr, lpa);
+			netdev_printk(KERN_DEBUG, dev, "MII #%d status register is %04x, link partner capability %04x\n",
+				      yp->phys[0], bmsr, lpa);
 
 		yp->full_duplex = mii_duplex(yp->duplex_lock, negotiated);
 
@@ -696,25 +693,24 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 	struct yellowfin_private *yp = netdev_priv(dev);
 	void __iomem *ioaddr = yp->base;
 
-	printk(KERN_WARNING "%s: Yellowfin transmit timed out at %d/%d Tx "
-		   "status %4.4x, Rx status %4.4x, resetting...\n",
-		   dev->name, yp->cur_tx, yp->dirty_tx,
-		   ioread32(ioaddr + TxStatus), ioread32(ioaddr + RxStatus));
+	netdev_warn(dev, "Yellowfin transmit timed out at %d/%d Tx status %04x, Rx status %04x, resetting...\n",
+		    yp->cur_tx, yp->dirty_tx,
+		    ioread32(ioaddr + TxStatus),
+		    ioread32(ioaddr + RxStatus));
 
 	/* Note: these should be KERN_DEBUG. */
 	if (yellowfin_debug) {
 		int i;
-		printk(KERN_WARNING "  Rx ring %p: ", yp->rx_ring);
+		pr_warning("  Rx ring %p: ", yp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(KERN_CONT " %8.8x",
-			       yp->rx_ring[i].result_status);
-		printk(KERN_CONT "\n");
-		printk(KERN_WARNING"  Tx ring %p: ", yp->tx_ring);
+			pr_cont(" %08x", yp->rx_ring[i].result_status);
+		pr_cont("\n");
+		pr_warning("  Tx ring %p: ", yp->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(KERN_CONT " %4.4x /%8.8x",
+			pr_cont(" %04x /%08x",
 			       yp->tx_status[i].tx_errs,
 			       yp->tx_ring[i].result_status);
-		printk(KERN_CONT "\n");
+		pr_cont("\n");
 	}
 
 	/* If the hardware is found to hang regularly, we will update the code
@@ -891,8 +887,8 @@ static netdev_tx_t yellowfin_start_xmit(struct sk_buff *skb,
 		yp->tx_full = 1;
 
 	if (yellowfin_debug > 4) {
-		printk(KERN_DEBUG "%s: Yellowfin transmit frame #%d queued in slot %d.\n",
-			   dev->name, yp->cur_tx, entry);
+		netdev_printk(KERN_DEBUG, dev, "Yellowfin transmit frame #%d queued in slot %d\n",
+			      yp->cur_tx, entry);
 	}
 	return NETDEV_TX_OK;
 }
@@ -916,8 +912,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 		u16 intr_status = ioread16(ioaddr + IntrClear);
 
 		if (yellowfin_debug > 4)
-			printk(KERN_DEBUG "%s: Yellowfin interrupt, status %4.4x.\n",
-				   dev->name, intr_status);
+			netdev_printk(KERN_DEBUG, dev, "Yellowfin interrupt, status %04x\n",
+				      intr_status);
 
 		if (intr_status == 0)
 			break;
@@ -963,13 +959,12 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 
 #ifndef final_version
 				if (yellowfin_debug > 5)
-					printk(KERN_DEBUG "%s: Tx queue %d check, Tx status "
-						   "%4.4x %4.4x %4.4x %4.4x.\n",
-						   dev->name, entry,
-						   yp->tx_status[entry].tx_cnt,
-						   yp->tx_status[entry].tx_errs,
-						   yp->tx_status[entry].total_tx_cnt,
-						   yp->tx_status[entry].paused);
+					netdev_printk(KERN_DEBUG, dev, "Tx queue %d check, Tx status %04x %04x %04x %04x\n",
+						      entry,
+						      yp->tx_status[entry].tx_cnt,
+						      yp->tx_status[entry].tx_errs,
+						      yp->tx_status[entry].total_tx_cnt,
+						      yp->tx_status[entry].paused);
 #endif
 				if (tx_errs == 0)
 					break;	/* It still hasn't been Txed */
@@ -978,8 +973,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 					/* There was an major error, log it. */
 #ifndef final_version
 					if (yellowfin_debug > 1)
-						printk(KERN_DEBUG "%s: Transmit error, Tx status %4.4x.\n",
-							   dev->name, tx_errs);
+						netdev_printk(KERN_DEBUG, dev, "Transmit error, Tx status %04x\n",
+							      tx_errs);
 #endif
 					dev->stats.tx_errors++;
 					if (tx_errs & 0xF800) dev->stats.tx_aborted_errors++;
@@ -989,8 +984,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 				} else {
 #ifndef final_version
 					if (yellowfin_debug > 4)
-						printk(KERN_DEBUG "%s: Normal transmit, Tx status %4.4x.\n",
-							   dev->name, tx_errs);
+						netdev_printk(KERN_DEBUG, dev, "Normal transmit, Tx status %04x\n",
+							      tx_errs);
 #endif
 					dev->stats.tx_bytes += skb->len;
 					dev->stats.collisions += tx_errs & 15;
@@ -1008,8 +1003,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 
 #ifndef final_version
 			if (yp->cur_tx - dirty_tx > TX_RING_SIZE) {
-				printk(KERN_ERR "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-					   dev->name, dirty_tx, yp->cur_tx, yp->tx_full);
+				netdev_err(dev, "Out-of-sync dirty pointer, %d vs. %d, full=%d\n",
+					   dirty_tx, yp->cur_tx, yp->tx_full);
 				dirty_tx += TX_RING_SIZE;
 			}
 #endif
@@ -1031,16 +1026,15 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 			yellowfin_error(dev, intr_status);
 
 		if (--boguscnt < 0) {
-			printk(KERN_WARNING "%s: Too much work at interrupt, "
-				   "status=0x%4.4x.\n",
-				   dev->name, intr_status);
+			netdev_warn(dev, "Too much work at interrupt, status=%#04x\n",
+				    intr_status);
 			break;
 		}
 	} while (1);
 
 	if (yellowfin_debug > 3)
-		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
-			   dev->name, ioread16(ioaddr + IntrStatus));
+		netdev_printk(KERN_DEBUG, dev, "exiting interrupt, status=%#04x\n",
+			      ioread16(ioaddr + IntrStatus));
 
 	spin_unlock (&yp->lock);
 	return IRQ_RETVAL(handled);
@@ -1055,9 +1049,9 @@ static int yellowfin_rx(struct net_device *dev)
 	int boguscnt = yp->dirty_rx + RX_RING_SIZE - yp->cur_rx;
 
 	if (yellowfin_debug > 4) {
-		printk(KERN_DEBUG " In yellowfin_rx(), entry %d status %8.8x.\n",
+		printk(KERN_DEBUG " In yellowfin_rx(), entry %d status %08x\n",
 			   entry, yp->rx_ring[entry].result_status);
-		printk(KERN_DEBUG "   #%d desc. %8.8x %8.8x %8.8x.\n",
+		printk(KERN_DEBUG "   #%d desc. %08x %08x %08x\n",
 			   entry, yp->rx_ring[entry].dbdma_cmd, yp->rx_ring[entry].addr,
 			   yp->rx_ring[entry].result_status);
 	}
@@ -1081,20 +1075,20 @@ static int yellowfin_rx(struct net_device *dev)
 			le32_to_cpu(desc->result_status)) & 0xffff;
 		frame_status = get_unaligned_le16(&(buf_addr[data_size - 2]));
 		if (yellowfin_debug > 4)
-			printk(KERN_DEBUG "  yellowfin_rx() status was %4.4x.\n",
-				   frame_status);
+			printk(KERN_DEBUG "  %s() status was %04x\n",
+			       __func__, frame_status);
 		if (--boguscnt < 0)
 			break;
 		if ( ! (desc_status & RX_EOP)) {
 			if (data_size != 0)
-				printk(KERN_WARNING "%s: Oversized Ethernet frame spanned multiple buffers,"
-					   " status %4.4x, data_size %d!\n", dev->name, desc_status, data_size);
+				netdev_warn(dev, "Oversized Ethernet frame spanned multiple buffers, status %04x, data_size %d!\n",
+					    desc_status, data_size);
 			dev->stats.rx_length_errors++;
 		} else if ((yp->drv_flags & IsGigabit)  &&  (frame_status & 0x0038)) {
 			/* There was a error. */
 			if (yellowfin_debug > 3)
-				printk(KERN_DEBUG "  yellowfin_rx() Rx error was %4.4x.\n",
-					   frame_status);
+				printk(KERN_DEBUG "  %s() Rx error was %04x\n",
+				       __func__, frame_status);
 			dev->stats.rx_errors++;
 			if (frame_status & 0x0060) dev->stats.rx_length_errors++;
 			if (frame_status & 0x0008) dev->stats.rx_frame_errors++;
@@ -1118,8 +1112,8 @@ static int yellowfin_rx(struct net_device *dev)
 				entry*sizeof(struct yellowfin_desc)),
 				"\377\377\377\377\377\377", 6) != 0) {
 			if (bogus_rx++ == 0)
-				printk(KERN_WARNING "%s: Bad frame to %pM\n",
-					   dev->name, buf_addr);
+				netdev_warn(dev, "Bad frame to %pM\n",
+					    buf_addr);
 #endif
 		} else {
 			struct sk_buff *skb;
@@ -1129,9 +1123,8 @@ static int yellowfin_rx(struct net_device *dev)
 
 #ifndef final_version
 			if (yellowfin_debug > 4)
-				printk(KERN_DEBUG "  yellowfin_rx() normal Rx pkt length %d"
-					   " of %d, bogus_cnt %d.\n",
-					   pkt_len, data_size, boguscnt);
+				printk(KERN_DEBUG "  %s() normal Rx pkt length %d of %d, bogus_cnt %d\n",
+				       __func__, pkt_len, data_size, boguscnt);
 #endif
 			/* Check if the packet is long enough to just pass up the skbuff
 			   without copying to a properly sized skbuff. */
@@ -1191,8 +1184,7 @@ static int yellowfin_rx(struct net_device *dev)
 
 static void yellowfin_error(struct net_device *dev, int intr_status)
 {
-	printk(KERN_ERR "%s: Something Wicked happened! %4.4x.\n",
-		   dev->name, intr_status);
+	netdev_err(dev, "Something Wicked happened! %04x\n", intr_status);
 	/* Hmmmmm, it's not clear what to do here. */
 	if (intr_status & (IntrTxPCIErr | IntrTxPCIFault))
 		dev->stats.tx_errors++;
@@ -1209,13 +1201,13 @@ static int yellowfin_close(struct net_device *dev)
 	netif_stop_queue (dev);
 
 	if (yellowfin_debug > 1) {
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was Tx %4.4x "
-			   "Rx %4.4x Int %2.2x.\n",
-			   dev->name, ioread16(ioaddr + TxStatus),
-			   ioread16(ioaddr + RxStatus),
-			   ioread16(ioaddr + IntrStatus));
-		printk(KERN_DEBUG "%s: Queue pointers were Tx %d / %d,  Rx %d / %d.\n",
-			   dev->name, yp->cur_tx, yp->dirty_tx, yp->cur_rx, yp->dirty_rx);
+		netdev_printk(KERN_DEBUG, dev, "Shutting down ethercard, status was Tx %04x Rx %04x Int %02x\n",
+			      ioread16(ioaddr + TxStatus),
+			      ioread16(ioaddr + RxStatus),
+			      ioread16(ioaddr + IntrStatus));
+		netdev_printk(KERN_DEBUG, dev, "Queue pointers were Tx %d / %d,  Rx %d / %d\n",
+			      yp->cur_tx, yp->dirty_tx,
+			      yp->cur_rx, yp->dirty_rx);
 	}
 
 	/* Disable interrupts by clearing the interrupt mask. */
@@ -1229,33 +1221,35 @@ static int yellowfin_close(struct net_device *dev)
 
 #if defined(__i386__)
 	if (yellowfin_debug > 2) {
-		printk(KERN_DEBUG"  Tx ring at %8.8llx:\n",
+		printk(KERN_DEBUG "  Tx ring at %08llx:\n",
 				(unsigned long long)yp->tx_ring_dma);
 		for (i = 0; i < TX_RING_SIZE*2; i++)
-			printk(KERN_DEBUG " %c #%d desc. %8.8x %8.8x %8.8x %8.8x.\n",
+			printk(KERN_DEBUG " %c #%d desc. %08x %08x %08x %08x\n",
 				   ioread32(ioaddr + TxPtr) == (long)&yp->tx_ring[i] ? '>' : ' ',
 				   i, yp->tx_ring[i].dbdma_cmd, yp->tx_ring[i].addr,
 				   yp->tx_ring[i].branch_addr, yp->tx_ring[i].result_status);
 		printk(KERN_DEBUG "  Tx status %p:\n", yp->tx_status);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(KERN_DEBUG "   #%d status %4.4x %4.4x %4.4x %4.4x.\n",
+			printk(KERN_DEBUG "   #%d status %04x %04x %04x %04x\n",
 				   i, yp->tx_status[i].tx_cnt, yp->tx_status[i].tx_errs,
 				   yp->tx_status[i].total_tx_cnt, yp->tx_status[i].paused);
 
-		printk(KERN_DEBUG "  Rx ring %8.8llx:\n",
+		printk(KERN_DEBUG "  Rx ring %08llx:\n",
 				(unsigned long long)yp->rx_ring_dma);
 		for (i = 0; i < RX_RING_SIZE; i++) {
-			printk(KERN_DEBUG " %c #%d desc. %8.8x %8.8x %8.8x\n",
+			printk(KERN_DEBUG " %c #%d desc. %08x %08x %08x\n",
 				   ioread32(ioaddr + RxPtr) == (long)&yp->rx_ring[i] ? '>' : ' ',
 				   i, yp->rx_ring[i].dbdma_cmd, yp->rx_ring[i].addr,
 				   yp->rx_ring[i].result_status);
 			if (yellowfin_debug > 6) {
 				if (get_unaligned((u8*)yp->rx_ring[i].addr) != 0x69) {
 					int j;
+
+					printk(KERN_DEBUG);
 					for (j = 0; j < 0x50; j++)
-						printk(" %4.4x",
-							   get_unaligned(((u16*)yp->rx_ring[i].addr) + j));
-					printk("\n");
+						pr_cont(" %04x",
+							get_unaligned(((u16*)yp->rx_ring[i].addr) + j));
+					pr_cont("\n");
 				}
 			}
 		}
@@ -1281,8 +1275,8 @@ static int yellowfin_close(struct net_device *dev)
 
 #ifdef YF_PROTOTYPE			/* Support for prototype hardware errata. */
 	if (yellowfin_debug > 0) {
-		printk(KERN_DEBUG "%s: Received %d frames that we should not have.\n",
-			   dev->name, bogus_rx);
+		netdev_printk(KERN_DEBUG, dev, "Received %d frames that we should not have\n",
+			      bogus_rx);
 	}
 #endif
 
-- 
1.7.0.14.g7e948
