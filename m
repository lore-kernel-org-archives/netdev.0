From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/13] tulip/winbond-840.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:28 -0800
Message-ID: <19e7fe844ffaf7e795f0db456e4897950e22b063.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1597 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab0A2G7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:32 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx
Convert %d.%d.%d.%d to %pI4

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/winbond-840.c |  177 ++++++++++++++++++++-------------------
 1 files changed, 90 insertions(+), 87 deletions(-)

diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 23395e1..9fb89af 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -376,8 +376,8 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	irq = pdev->irq;
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_WARNING "Winbond-840: Device %s disabled due to DMA limitations.\n",
-		       pci_name(pdev));
+		pr_warning("Winbond-840: Device %s disabled due to DMA limitations\n",
+			   pci_name(pdev));
 		return -EIO;
 	}
 	dev = alloc_etherdev(sizeof(*np));
@@ -422,8 +422,9 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 		if (option & 0x200)
 			np->mii_if.full_duplex = 1;
 		if (option & 15)
-			printk(KERN_INFO "%s: ignoring user supplied media type %d",
-				dev->name, option & 15);
+			dev_info(&dev->dev,
+				 "ignoring user supplied media type %d",
+				 option & 15);
 	}
 	if (find_cnt < MAX_UNITS  &&  full_duplex[find_cnt] > 0)
 		np->mii_if.full_duplex = 1;
@@ -440,9 +441,8 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	if (i)
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at %p, %pM, IRQ %d.\n",
-	       dev->name, pci_id_tbl[chip_idx].name, ioaddr,
-	       dev->dev_addr, irq);
+	dev_info(&dev->dev, "%s at %p, %pM, IRQ %d\n",
+		 pci_id_tbl[chip_idx].name, ioaddr, dev->dev_addr, irq);
 
 	if (np->drv_flags & CanHaveMII) {
 		int phy, phy_idx = 0;
@@ -453,16 +453,17 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 				np->mii_if.advertising = mdio_read(dev, phy, MII_ADVERTISE);
 				np->mii = (mdio_read(dev, phy, MII_PHYSID1) << 16)+
 						mdio_read(dev, phy, MII_PHYSID2);
-				printk(KERN_INFO "%s: MII PHY %8.8xh found at address %d, status "
-					   "0x%4.4x advertising %4.4x.\n",
-					   dev->name, np->mii, phy, mii_status, np->mii_if.advertising);
+				dev_info(&dev->dev,
+					 "MII PHY %08xh found at address %d, status 0x%04x advertising %04x\n",
+					 np->mii, phy, mii_status,
+					 np->mii_if.advertising);
 			}
 		}
 		np->mii_cnt = phy_idx;
 		np->mii_if.phy_id = np->phys[0];
 		if (phy_idx == 0) {
-				printk(KERN_WARNING "%s: MII PHY not found -- this device may "
-					   "not operate correctly.\n", dev->name);
+			dev_warn(&dev->dev,
+				 "MII PHY not found -- this device may not operate correctly\n");
 		}
 	}
 
@@ -644,8 +645,8 @@ static int netdev_open(struct net_device *dev)
 		goto out_err;
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: w89c840_open() irq %d.\n",
-			   dev->name, dev->irq);
+		printk(KERN_DEBUG "%s: w89c840_open() irq %d\n",
+		       dev->name, dev->irq);
 
 	if((i=alloc_ringdesc(dev)))
 		goto out_err;
@@ -657,7 +658,7 @@ static int netdev_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Done netdev_open().\n", dev->name);
+		printk(KERN_DEBUG "%s: Done netdev_open()\n", dev->name);
 
 	/* Set the timer to check for link beat. */
 	init_timer(&np->timer);
@@ -688,16 +689,18 @@ static int update_link(struct net_device *dev)
 	if (!(mii_reg & 0x4)) {
 		if (netif_carrier_ok(dev)) {
 			if (debug)
-				printk(KERN_INFO "%s: MII #%d reports no link. Disabling watchdog.\n",
-					dev->name, np->phys[0]);
+				dev_info(&dev->dev,
+					 "MII #%d reports no link. Disabling watchdog\n",
+					 np->phys[0]);
 			netif_carrier_off(dev);
 		}
 		return np->csr6;
 	}
 	if (!netif_carrier_ok(dev)) {
 		if (debug)
-			printk(KERN_INFO "%s: MII #%d link is back. Enabling watchdog.\n",
-				dev->name, np->phys[0]);
+			dev_info(&dev->dev,
+				 "MII #%d link is back. Enabling watchdog\n",
+				 np->phys[0]);
 		netif_carrier_on(dev);
 	}
 
@@ -729,9 +732,10 @@ static int update_link(struct net_device *dev)
 	if (fasteth)
 		result |= 0x20000000;
 	if (result != np->csr6 && debug)
-		printk(KERN_INFO "%s: Setting %dMBit-%s-duplex based on MII#%d\n",
-				 dev->name, fasteth ? 100 : 10,
-			   	duplex ? "full" : "half", np->phys[0]);
+		dev_info(&dev->dev,
+			 "Setting %dMBit-%s-duplex based on MII#%d\n",
+			 fasteth ? 100 : 10, duplex ? "full" : "half",
+			 np->phys[0]);
 	return result;
 }
 
@@ -763,8 +767,8 @@ static inline void update_csr6(struct net_device *dev, int new)
 
 		limit--;
 		if(!limit) {
-			printk(KERN_INFO "%s: couldn't stop rxtx, IntrStatus %xh.\n",
-					dev->name, csr5);
+			dev_info(&dev->dev,
+				 "couldn't stop rxtx, IntrStatus %xh\n", csr5);
 			break;
 		}
 		udelay(1);
@@ -783,10 +787,9 @@ static void netdev_timer(unsigned long data)
 	void __iomem *ioaddr = np->base_addr;
 
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Media selection timer tick, status %8.8x "
-			   "config %8.8x.\n",
-			   dev->name, ioread32(ioaddr + IntrStatus),
-			   ioread32(ioaddr + NetworkConfig));
+		printk(KERN_DEBUG "%s: Media selection timer tick, status %08x config %08x\n",
+		       dev->name, ioread32(ioaddr + IntrStatus),
+		       ioread32(ioaddr + NetworkConfig));
 	spin_lock_irq(&np->lock);
 	update_csr6(dev, update_link(dev));
 	spin_unlock_irq(&np->lock);
@@ -899,8 +902,8 @@ static void init_registers(struct net_device *dev)
 	/* When not a module we can work around broken '486 PCI boards. */
 	if (boot_cpu_data.x86 <= 4) {
 		i |= 0x4800;
-		printk(KERN_INFO "%s: This is a 386/486 PCI system, setting cache "
-			   "alignment to 8 longwords.\n", dev->name);
+		dev_info(&dev->dev,
+			 "This is a 386/486 PCI system, setting cache alignment to 8 longwords\n");
 	} else {
 		i |= 0xE000;
 	}
@@ -931,22 +934,23 @@ static void tx_timeout(struct net_device *dev)
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base_addr;
 
-	printk(KERN_WARNING "%s: Transmit timed out, status %8.8x,"
-		   " resetting...\n", dev->name, ioread32(ioaddr + IntrStatus));
+	dev_warn(&dev->dev, "Transmit timed out, status %08x, resetting...\n",
+		 ioread32(ioaddr + IntrStatus));
 
 	{
 		int i;
 		printk(KERN_DEBUG "  Rx ring %p: ", np->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(" %8.8x", (unsigned int)np->rx_ring[i].status);
-		printk(KERN_DEBUG"  Tx ring %p: ", np->tx_ring);
+			printk(KERN_CONT " %08x", (unsigned int)np->rx_ring[i].status);
+		printk(KERN_CONT "\n");
+		printk(KERN_DEBUG "  Tx ring %p: ", np->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(" %8.8x", np->tx_ring[i].status);
-		printk("\n");
+			printk(KERN_CONT " %08x", np->tx_ring[i].status);
+		printk(KERN_CONT "\n");
 	}
-	printk(KERN_DEBUG "Tx cur %d Tx dirty %d Tx Full %d, q bytes %d.\n",
-				np->cur_tx, np->dirty_tx, np->tx_full, np->tx_q_bytes);
-	printk(KERN_DEBUG "Tx Descriptor addr %xh.\n",ioread32(ioaddr+0x4C));
+	printk(KERN_DEBUG "Tx cur %d Tx dirty %d Tx Full %d, q bytes %d\n",
+	       np->cur_tx, np->dirty_tx, np->tx_full, np->tx_q_bytes);
+	printk(KERN_DEBUG "Tx Descriptor addr %xh\n", ioread32(ioaddr+0x4C));
 
 	disable_irq(dev->irq);
 	spin_lock_irq(&np->lock);
@@ -1055,8 +1059,8 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
-			   dev->name, np->cur_tx, entry);
+		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d\n",
+		       dev->name, np->cur_tx, entry);
 	}
 	return NETDEV_TX_OK;
 }
@@ -1073,8 +1077,8 @@ static void netdev_tx_done(struct net_device *dev)
 		if (tx_status & 0x8000) { 	/* There was an error, log it. */
 #ifndef final_version
 			if (debug > 1)
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-					   dev->name, tx_status);
+				printk(KERN_DEBUG "%s: Transmit error, Tx status %08x\n",
+				       dev->name, tx_status);
 #endif
 			np->stats.tx_errors++;
 			if (tx_status & 0x0104) np->stats.tx_aborted_errors++;
@@ -1086,8 +1090,8 @@ static void netdev_tx_done(struct net_device *dev)
 		} else {
 #ifndef final_version
 			if (debug > 3)
-				printk(KERN_DEBUG "%s: Transmit slot %d ok, Tx status %8.8x.\n",
-					   dev->name, entry, tx_status);
+				printk(KERN_DEBUG "%s: Transmit slot %d ok, Tx status %08x\n",
+				       dev->name, entry, tx_status);
 #endif
 			np->stats.tx_bytes += np->tx_skbuff[entry]->len;
 			np->stats.collisions += (tx_status >> 3) & 15;
@@ -1130,8 +1134,8 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 		iowrite32(intr_status & 0x001ffff, ioaddr + IntrStatus);
 
 		if (debug > 4)
-			printk(KERN_DEBUG "%s: Interrupt, status %4.4x.\n",
-				   dev->name, intr_status);
+			printk(KERN_DEBUG "%s: Interrupt, status %04x\n",
+			       dev->name, intr_status);
 
 		if ((intr_status & (NormalIntr|AbnormalIntr)) == 0)
 			break;
@@ -1156,8 +1160,9 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 			netdev_error(dev, intr_status);
 
 		if (--work_limit < 0) {
-			printk(KERN_WARNING "%s: Too much work at interrupt, "
-				   "status=0x%4.4x.\n", dev->name, intr_status);
+			dev_warn(&dev->dev,
+				 "Too much work at interrupt, status=0x%04x\n",
+				 intr_status);
 			/* Set the timer to re-enable the other interrupts after
 			   10*82usec ticks. */
 			spin_lock(&np->lock);
@@ -1171,8 +1176,8 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 	} while (1);
 
 	if (debug > 3)
-		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
-			   dev->name, ioread32(ioaddr + IntrStatus));
+		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x\n",
+		       dev->name, ioread32(ioaddr + IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -1185,8 +1190,8 @@ static int netdev_rx(struct net_device *dev)
 	int work_limit = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 
 	if (debug > 4) {
-		printk(KERN_DEBUG " In netdev_rx(), entry %d status %4.4x.\n",
-			   entry, np->rx_ring[entry].status);
+		printk(KERN_DEBUG " In netdev_rx(), entry %d status %04x\n",
+		       entry, np->rx_ring[entry].status);
 	}
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
@@ -1195,24 +1200,24 @@ static int netdev_rx(struct net_device *dev)
 		s32 status = desc->status;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "  netdev_rx() status was %8.8x.\n",
-				   status);
+			printk(KERN_DEBUG "  netdev_rx() status was %08x\n",
+			       status);
 		if (status < 0)
 			break;
 		if ((status & 0x38008300) != 0x0300) {
 			if ((status & 0x38000300) != 0x0300) {
 				/* Ingore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
-					printk(KERN_WARNING "%s: Oversized Ethernet frame spanned "
-						   "multiple buffers, entry %#x status %4.4x!\n",
-						   dev->name, np->cur_rx, status);
+					dev_warn(&dev->dev,
+						 "Oversized Ethernet frame spanned multiple buffers, entry %#x status %04x!\n",
+						 np->cur_rx, status);
 					np->stats.rx_length_errors++;
 				}
 			} else if (status & 0x8000) {
 				/* There was a fatal error. */
 				if (debug > 2)
-					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
-						   dev->name, status);
+					printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
+					       dev->name, status);
 				np->stats.rx_errors++; /* end of a packet.*/
 				if (status & 0x0890) np->stats.rx_length_errors++;
 				if (status & 0x004C) np->stats.rx_frame_errors++;
@@ -1225,8 +1230,8 @@ static int netdev_rx(struct net_device *dev)
 
 #ifndef final_version
 			if (debug > 4)
-				printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d"
-					   " status %x.\n", pkt_len, status);
+				printk(KERN_DEBUG "  netdev_rx() normal Rx pkt length %d status %x\n",
+				       pkt_len, status);
 #endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
@@ -1251,11 +1256,10 @@ static int netdev_rx(struct net_device *dev)
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
 			if (debug > 5)
-				printk(KERN_DEBUG "  Rx data %pM %pM"
-				       " %2.2x%2.2x %d.%d.%d.%d.\n",
+				printk(KERN_DEBUG "  Rx data %pM %pM %02x%02x %pI4\n",
 				       &skb->data[0], &skb->data[6],
 				       skb->data[12], skb->data[13],
-				       skb->data[14], skb->data[15], skb->data[16], skb->data[17]);
+				       &skb->data[14]);
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
@@ -1293,8 +1297,8 @@ static void netdev_error(struct net_device *dev, int intr_status)
 	void __iomem *ioaddr = np->base_addr;
 
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Abnormal event, %8.8x.\n",
-			   dev->name, intr_status);
+		printk(KERN_DEBUG "%s: Abnormal event, %08x\n",
+		       dev->name, intr_status);
 	if (intr_status == 0xffffffff)
 		return;
 	spin_lock(&np->lock);
@@ -1314,8 +1318,8 @@ static void netdev_error(struct net_device *dev, int intr_status)
 		 	new = 127; /* load full packet before starting */
 		new = (np->csr6 & ~(0x7F << 14)) | (new<<14);
 #endif
-		printk(KERN_DEBUG "%s: Tx underflow, new csr6 %8.8x.\n",
-			   dev->name, new);
+		printk(KERN_DEBUG "%s: Tx underflow, new csr6 %08x\n",
+		       dev->name, new);
 		update_csr6(dev, new);
 	}
 	if (intr_status & RxDied) {		/* Missed a Rx frame. */
@@ -1487,11 +1491,13 @@ static int netdev_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if (debug > 1) {
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %8.8x "
-			   "Config %8.8x.\n", dev->name, ioread32(ioaddr + IntrStatus),
-			   ioread32(ioaddr + NetworkConfig));
-		printk(KERN_DEBUG "%s: Queue pointers were Tx %d / %d,  Rx %d / %d.\n",
-			   dev->name, np->cur_tx, np->dirty_tx, np->cur_rx, np->dirty_rx);
+		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %08x Config %08x\n",
+		       dev->name, ioread32(ioaddr + IntrStatus),
+		       ioread32(ioaddr + NetworkConfig));
+		printk(KERN_DEBUG "%s: Queue pointers were Tx %d / %d,  Rx %d / %d\n",
+		       dev->name,
+		       np->cur_tx, np->dirty_tx,
+		       np->cur_rx, np->dirty_rx);
 	}
 
  	/* Stop the chip's Tx and Rx processes. */
@@ -1512,18 +1518,16 @@ static int netdev_close(struct net_device *dev)
 	if (debug > 2) {
 		int i;
 
-		printk(KERN_DEBUG"  Tx ring at %8.8x:\n",
-			   (int)np->tx_ring);
+		printk(KERN_DEBUG"  Tx ring at %08x:\n", (int)np->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(KERN_DEBUG " #%d desc. %4.4x %4.4x %8.8x.\n",
-				   i, np->tx_ring[i].length,
-				   np->tx_ring[i].status, np->tx_ring[i].buffer1);
-		printk(KERN_DEBUG "  Rx ring %8.8x:\n",
-			   (int)np->rx_ring);
+			printk(KERN_DEBUG " #%d desc. %04x %04x %08x\n",
+			       i, np->tx_ring[i].length,
+			       np->tx_ring[i].status, np->tx_ring[i].buffer1);
+		printk(KERN_DEBUG "  Rx ring %08x:\n", (int)np->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++) {
-			printk(KERN_DEBUG " #%d desc. %4.4x %4.4x %8.8x\n",
-				   i, np->rx_ring[i].length,
-				   np->rx_ring[i].status, np->rx_ring[i].buffer1);
+			printk(KERN_DEBUG " #%d desc. %04x %04x %08x\n",
+			       i, np->rx_ring[i].length,
+			       np->rx_ring[i].status, np->rx_ring[i].buffer1);
 		}
 	}
 #endif /* __i386__ debugging only */
@@ -1622,9 +1626,8 @@ static int w840_resume (struct pci_dev *pdev)
 		goto out; /* device not suspended */
 	if (netif_running(dev)) {
 		if ((retval = pci_enable_device(pdev))) {
-			printk (KERN_ERR
-				"%s: pci_enable_device failed in resume\n",
-				dev->name);
+			dev_err(&dev->dev,
+				"pci_enable_device failed in resume\n");
 			goto out;
 		}
 		spin_lock_irq(&np->lock);
-- 
1.6.6.rc0.57.gad7a

