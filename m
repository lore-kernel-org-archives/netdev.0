From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Sat, 20 Mar 2004 15:21:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040320152109.A31118@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

People are welcome to report how the following patch behaves on their
hardware. It does not seem too bad here but it probably is still a bit rough.
A split version of the patch will follow tomorrow. This one definitely aims
at brave and/or bored testers.

The driver lacks ethtool support. Badly. :o/

--- linux-2.6.4/drivers/net/epic100.c	2004-03-20 14:52:08.000000000 +0100
+++ linux-2.6.4/drivers/net/epic100.c	2004-03-20 14:52:13.000000000 +0100
@@ -96,9 +96,9 @@ static int rx_copybreak;
    Making the Tx ring too large decreases the effectiveness of channel
    bonding and packet priority.
    There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
+#define TX_RING_SIZE	256
 #define TX_QUEUE_LEN	10		/* Limit ring entries actually used.  */
-#define RX_RING_SIZE	32
+#define RX_RING_SIZE	256
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct epic_tx_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct epic_rx_desc)
 
@@ -292,6 +292,10 @@ enum CommandBits {
 	StopTxDMA=0x20, StopRxDMA=0x40, RestartTx=0x80,
 };
 
+#define EpicNapiEvent	(TxEmpty | TxDone | \
+			 RxDone | RxStarted | RxEarlyWarn | RxOverflow | RxFull)
+#define EpicNormalEvent	(0x0000ffffUL & ~EpicNapiEvent)
+
 static u16 media2miictl[16] = {
 	0, 0x0C00, 0x0C00, 0x2000,  0x0100, 0x2100, 0, 0,
 	0, 0, 0, 0,  0, 0, 0, 0 };
@@ -330,9 +334,11 @@ struct epic_private {
 
 	/* Ring pointers. */
 	spinlock_t lock;				/* Group with Tx control cache line. */
+	spinlock_t napi_lock;
 	unsigned int cur_tx, dirty_tx;
 
 	unsigned int cur_rx, dirty_rx;
+	u32 irq_mask;
 	unsigned int rx_buf_sz;				/* Based on MTU+slack. */
 
 	struct pci_dev *pci_dev;			/* PCI bus location. */
@@ -359,7 +365,8 @@ static void epic_timer(unsigned long dat
 static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int epic_rx(struct net_device *dev);
+static int epic_rx(struct net_device *dev, int budget);
+static int epic_poll(struct net_device *dev, int *budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static struct ethtool_ops netdev_ethtool_ops;
@@ -378,7 +385,7 @@ static int __devinit epic_init_one (stru
 	int irq;
 	struct net_device *dev;
 	struct epic_private *ep;
-	int i, option = 0, duplex = 0;
+	int i, ret, option = 0, duplex = 0;
 	void *ring_space;
 	dma_addr_t ring_dma;
 
@@ -392,29 +399,33 @@ static int __devinit epic_init_one (stru
 	
 	card_idx++;
 	
-	i = pci_enable_device(pdev);
-	if (i)
-		return i;
+	ret = pci_enable_device(pdev);
+	if (ret)
+		goto out;
 	irq = pdev->irq;
 
 	if (pci_resource_len(pdev, 0) < pci_id_tbl[chip_idx].io_size) {
 		printk (KERN_ERR "card %d: no PCI region space\n", card_idx);
-		return -ENODEV;
+		ret = -ENODEV;
+		goto err_out_disable;
 	}
 	
 	pci_set_master(pdev);
 
+	ret = pci_request_regions(pdev, DRV_NAME);
+	if (ret < 0)
+		goto err_out_disable;
+
+	ret = -ENOMEM;
+
 	dev = alloc_etherdev(sizeof (*ep));
 	if (!dev) {
 		printk (KERN_ERR "card %d: no memory for eth device\n", card_idx);
-		return -ENOMEM;
+		goto err_out_free_res;
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_request_regions(pdev, DRV_NAME))
-		goto err_out_free_netdev;
-
 #ifdef USE_IO_OPS
 	ioaddr = pci_resource_start (pdev, 0);
 #else
@@ -422,7 +433,7 @@ static int __devinit epic_init_one (stru
 	ioaddr = (long) ioremap (ioaddr, pci_resource_len (pdev, 1));
 	if (!ioaddr) {
 		printk (KERN_ERR DRV_NAME " %d: ioremap failed\n", card_idx);
-		goto err_out_free_res;
+		goto err_out_free_netdev;
 	}
 #endif
 
@@ -489,6 +500,9 @@ static int __devinit epic_init_one (stru
 	ep->pci_dev = pdev;
 	ep->chip_id = chip_idx;
 	ep->chip_flags = pci_id_tbl[chip_idx].drv_flags;
+	ep->irq_mask = 
+		(ep->chip_flags & TYPE2_INTR ?  PCIBusErr175 : PCIBusErr170)
+		 | CntFull | TxUnderrun | EpicNapiEvent;
 
 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later, but
@@ -543,10 +557,12 @@ static int __devinit epic_init_one (stru
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
+	dev->poll = epic_poll;
+	dev->weight = 64;
 
-	i = register_netdev(dev);
-	if (i)
-		goto err_out_unmap_tx;
+	ret = register_netdev(dev);
+	if (ret < 0)
+		goto err_out_unmap_rx;
 
 	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ",
 		   dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq);
@@ -554,19 +570,24 @@ static int __devinit epic_init_one (stru
 		printk("%2.2x:", dev->dev_addr[i]);
 	printk("%2.2x.\n", dev->dev_addr[i]);
 
-	return 0;
+out:
+	return ret;
 
+err_out_unmap_rx:
+	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
 err_out_unmap_tx:
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 err_out_iounmap:
 #ifndef USE_IO_OPS
 	iounmap(ioaddr);
-err_out_free_res:
-#endif
-	pci_release_regions(pdev);
 err_out_free_netdev:
+#endif
 	free_netdev(dev);
-	return -ENODEV;
+err_out_free_res:
+	pci_release_regions(pdev);
+err_out_disable:
+	pci_disable_device(pdev);
+	goto out;
 }
 
 /* Serial EEPROM section. */
@@ -592,6 +613,36 @@ err_out_free_netdev:
 #define EE_READ256_CMD	(6 << 8)
 #define EE_ERASE_CMD	(7 << 6)
 
+static void epic_disable_int(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	outl(0x00000000, ioaddr + INTMASK);
+}
+
+static inline void __epic_pci_commit(long ioaddr)
+{
+#ifndef USE_IO_OPS
+	inl(ioaddr + INTMASK);
+#endif
+}
+
+static void epic_napi_irq_off(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	outl(ep->irq_mask & ~EpicNapiEvent, ioaddr + INTMASK);
+	__epic_pci_commit(ioaddr);
+}
+
+static void epic_napi_irq_on(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	/* No need to commit possible posted write */
+	outl(ep->irq_mask | EpicNapiEvent, ioaddr + INTMASK);
+}
+
 static int __devinit read_eeprom(long ioaddr, int location)
 {
 	int i;
@@ -753,8 +804,7 @@ static int epic_open(struct net_device *
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
 		 | CntFull | TxUnderrun | TxDone | TxEmpty
-		 | RxError | RxOverflow | RxFull | RxHeader | RxDone,
-		 ioaddr + INTMASK);
+		 | RxError | EpicNapiEvent, ioaddr + INTMASK);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: epic_open() ioaddr %lx IRQ %d status %4.4x "
@@ -795,7 +845,7 @@ static void epic_pause(struct net_device
 	}
 
 	/* Remove the packets on the Rx queue. */
-	epic_rx(dev);
+	epic_rx(dev, RX_RING_SIZE);
 }
 
 static void epic_restart(struct net_device *dev)
@@ -842,7 +892,7 @@ static void epic_restart(struct net_devi
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
 		 | CntFull | TxUnderrun | TxDone | TxEmpty
-		 | RxError | RxOverflow | RxFull | RxHeader | RxDone,
+		 | RxError | EpicNapiEvent,
 		 ioaddr + INTMASK);
 	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
 		   " interrupt %4.4x.\n",
@@ -929,7 +979,8 @@ static void epic_init_ring(struct net_de
 	int i;
 
 	ep->tx_full = 0;
-	ep->lock = (spinlock_t) SPIN_LOCK_UNLOCKED;
+	spin_lock_init(&ep->lock);
+	spin_lock_init(&ep->napi_lock);
 	ep->dirty_tx = ep->cur_tx = 0;
 	ep->cur_rx = ep->dirty_rx = 0;
 	ep->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
@@ -1029,6 +1080,77 @@ static int epic_start_xmit(struct sk_buf
 	return 0;
 }
 
+static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
+			  int status)
+{
+	struct net_device_stats *stats = &ep->stats;
+
+#ifndef final_version
+	/* There was an major error, log it. */
+	if (debug > 1)
+		printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+		       dev->name, status);
+#endif
+	stats->tx_errors++;
+	if (status & 0x1050)
+		stats->tx_aborted_errors++;
+	if (status & 0x0008)
+		stats->tx_carrier_errors++;
+	if (status & 0x0040)
+		stats->tx_window_errors++;
+	if (status & 0x0010)
+		stats->tx_fifo_errors++;
+}
+
+static void epic_tx(struct net_device *dev, struct epic_private *ep)
+{
+	unsigned int dirty_tx, cur_tx;
+
+	/*
+	 * Note: if this lock becomes a problem we can narrow the locked
+	 * region at the cost of occasionally grabbing the lock more times.
+	 */
+	cur_tx = ep->cur_tx;
+	for (dirty_tx = ep->dirty_tx; cur_tx - dirty_tx > 0; dirty_tx++) {
+		struct sk_buff *skb;
+		int entry = dirty_tx % TX_RING_SIZE;
+		int txstatus = le32_to_cpu(ep->tx_ring[entry].txstatus);
+
+		if (txstatus & DescOwn)
+			break;	/* It still hasn't been Txed */
+
+		if (likely(txstatus & 0x0001)) {
+			ep->stats.collisions += (txstatus >> 8) & 15;
+			ep->stats.tx_packets++;
+			ep->stats.tx_bytes += ep->tx_skbuff[entry]->len;
+		} else
+			epic_tx_error(dev, ep, txstatus);
+
+		/* Free the original skb. */
+		skb = ep->tx_skbuff[entry];
+		pci_unmap_single(ep->pci_dev, ep->tx_ring[entry].bufaddr, 
+				 skb->len, PCI_DMA_TODEVICE);
+		dev_kfree_skb_irq(skb);
+		ep->tx_skbuff[entry] = 0;
+	}
+
+#ifndef final_version
+	if (cur_tx - dirty_tx > TX_RING_SIZE) {
+		printk(KERN_WARNING
+		       "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+		       dev->name, dirty_tx, cur_tx, ep->tx_full);
+		dirty_tx += TX_RING_SIZE;
+	}
+#endif
+	ep->dirty_tx = dirty_tx;
+	if (ep->tx_full && cur_tx - dirty_tx < TX_QUEUE_LEN - 4) {
+		/* The ring is no longer full, allow new TX entries. */
+		ep->tx_full = 0;
+		netif_wake_queue(dev);
+	}
+}
+
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t epic_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
@@ -1042,7 +1164,7 @@ static irqreturn_t epic_interrupt(int ir
 	do {
 		status = inl(ioaddr + INTSTAT);
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		outl(status & 0x00007fff, ioaddr + INTSTAT);
+		outl(status & EpicNormalEvent, ioaddr + INTSTAT);
 
 		if (debug > 4)
 			printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
@@ -1053,73 +1175,18 @@ static irqreturn_t epic_interrupt(int ir
 			break;
 		handled = 1;
 
-		if (status & (RxDone | RxStarted | RxEarlyWarn | RxOverflow))
-			epic_rx(dev);
-
-		if (status & (TxEmpty | TxDone)) {
-			unsigned int dirty_tx, cur_tx;
-
-			/* Note: if this lock becomes a problem we can narrow the locked
-			   region at the cost of occasionally grabbing the lock more
-			   times. */
-			spin_lock(&ep->lock);
-			cur_tx = ep->cur_tx;
-			dirty_tx = ep->dirty_tx;
-			for (; cur_tx - dirty_tx > 0; dirty_tx++) {
-				struct sk_buff *skb;
-				int entry = dirty_tx % TX_RING_SIZE;
-				int txstatus = le32_to_cpu(ep->tx_ring[entry].txstatus);
-
-				if (txstatus & DescOwn)
-					break;			/* It still hasn't been Txed */
-
-				if ( ! (txstatus & 0x0001)) {
-					/* There was an major error, log it. */
-#ifndef final_version
-					if (debug > 1)
-						printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-							   dev->name, txstatus);
-#endif
-					ep->stats.tx_errors++;
-					if (txstatus & 0x1050) ep->stats.tx_aborted_errors++;
-					if (txstatus & 0x0008) ep->stats.tx_carrier_errors++;
-					if (txstatus & 0x0040) ep->stats.tx_window_errors++;
-					if (txstatus & 0x0010) ep->stats.tx_fifo_errors++;
-				} else {
-					ep->stats.collisions += (txstatus >> 8) & 15;
-					ep->stats.tx_packets++;
-					ep->stats.tx_bytes += ep->tx_skbuff[entry]->len;
-				}
-
-				/* Free the original skb. */
-				skb = ep->tx_skbuff[entry];
-				pci_unmap_single(ep->pci_dev, ep->tx_ring[entry].bufaddr, 
-						 skb->len, PCI_DMA_TODEVICE);
-				dev_kfree_skb_irq(skb);
-				ep->tx_skbuff[entry] = 0;
+		if (status & EpicNapiEvent) {
+			spin_lock(&ep->napi_lock);
+			if (netif_rx_schedule_prep(dev)) {
+				epic_napi_irq_off(dev, ep);
+				__netif_rx_schedule(dev);
 			}
-
-#ifndef final_version
-			if (cur_tx - dirty_tx > TX_RING_SIZE) {
-				printk(KERN_WARNING "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-					   dev->name, dirty_tx, cur_tx, ep->tx_full);
-				dirty_tx += TX_RING_SIZE;
-			}
-#endif
-			ep->dirty_tx = dirty_tx;
-			if (ep->tx_full
-				&& cur_tx - dirty_tx < TX_QUEUE_LEN - 4) {
-				/* The ring is no longer full, allow new TX entries. */
-				ep->tx_full = 0;
-				spin_unlock(&ep->lock);
-				netif_wake_queue(dev);
-			} else
-				spin_unlock(&ep->lock);
+			spin_unlock(&ep->napi_lock);
 		}
 
 		/* Check uncommon events all at once. */
-		if (status & (CntFull | TxUnderrun | RxOverflow | RxFull |
-					  PCIBusErr170 | PCIBusErr175)) {
+		if (status &
+		    (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
 			if (status == 0xffffffff) /* Chip failed or removed (CardBus). */
 				break;
 			/* Always update the error counts to avoid overhead later. */
@@ -1133,11 +1200,6 @@ static irqreturn_t epic_interrupt(int ir
 				/* Restart the transmit process. */
 				outl(RestartTx, ioaddr + COMMAND);
 			}
-			if (status & RxOverflow) {		/* Missed a Rx frame. */
-				ep->stats.rx_errors++;
-			}
-			if (status & (RxOverflow | RxFull))
-				outw(RxQueued, ioaddr + COMMAND);
 			if (status & PCIBusErr170) {
 				printk(KERN_ERR "%s: PCI Bus Error!  EPIC status %4.4x.\n",
 					   dev->name, status);
@@ -1147,6 +1209,8 @@ static irqreturn_t epic_interrupt(int ir
 			/* Clear all error sources. */
 			outl(status & 0x7f18, ioaddr + INTSTAT);
 		}
+		if (!(status & EpicNormalEvent))
+			break;
 		if (--boguscnt < 0) {
 			printk(KERN_ERR "%s: Too much work at interrupt, "
 				   "IntrStatus=0x%8.8x.\n",
@@ -1164,7 +1228,7 @@ static irqreturn_t epic_interrupt(int ir
 	return IRQ_RETVAL(handled);
 }
 
-static int epic_rx(struct net_device *dev)
+static int epic_rx(struct net_device *dev, int budget)
 {
 	struct epic_private *ep = dev->priv;
 	int entry = ep->cur_rx % RX_RING_SIZE;
@@ -1174,6 +1238,10 @@ static int epic_rx(struct net_device *de
 	if (debug > 4)
 		printk(KERN_DEBUG " In epic_rx(), entry %d %8.8x.\n", entry,
 			   ep->rx_ring[entry].rxstatus);
+
+	if (rx_work_limit > budget)
+		rx_work_limit = budget;
+
 	/* If we own the next entry, it's a new packet. Send it up. */
 	while ((ep->rx_ring[entry].rxstatus & cpu_to_le32(DescOwn)) == 0) {
 		int status = le32_to_cpu(ep->rx_ring[entry].rxstatus);
@@ -1228,7 +1296,7 @@ static int epic_rx(struct net_device *de
 				ep->rx_skbuff[entry] = NULL;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			dev->last_rx = jiffies;
 			ep->stats.rx_packets++;
 			ep->stats.rx_bytes += pkt_len;
@@ -1256,6 +1324,60 @@ static int epic_rx(struct net_device *de
 	return work_done;
 }
 
+static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+	int status;
+
+	status = inl(ioaddr + INTSTAT);
+
+	if (status == 0xffffffff)
+		return;
+	if (status & RxOverflow) 	/* Missed a Rx frame. */
+		ep->stats.rx_errors++;
+	if (status & (RxOverflow | RxFull))
+		outw(RxQueued, ioaddr + COMMAND);
+}
+
+static int epic_poll(struct net_device *dev, int *budget)
+{
+	struct epic_private *ep = dev->priv;
+	int work_done, orig_budget;
+	long ioaddr = dev->base_addr;
+
+	epic_tx(dev, ep);
+
+	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
+
+rx_action:
+	outl(EpicNapiEvent, ioaddr + INTSTAT);
+
+	work_done = epic_rx(dev, *budget);
+
+	epic_rx_err(dev, ep);
+
+	*budget -= work_done;
+	dev->quota -= work_done;
+
+	if (work_done < orig_budget) {
+		unsigned long flags;
+		int status;
+
+		spin_lock_irqsave(&ep->napi_lock, flags);
+		epic_napi_irq_on(dev, ep);
+		__netif_rx_complete(dev);
+		spin_unlock_irqrestore(&ep->napi_lock, flags);
+
+		status = inl(ioaddr + INTSTAT);
+		if (status & EpicNapiEvent) {
+			epic_napi_irq_off(dev, ep);
+			goto rx_action;
+		}
+	}
+
+	return (work_done >= orig_budget);
+}
+
 static int epic_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
@@ -1270,9 +1392,13 @@ static int epic_close(struct net_device 
 			   dev->name, (int)inl(ioaddr + INTSTAT));
 
 	del_timer_sync(&ep->timer);
-	epic_pause(dev);
+
+	epic_disable_int(dev, ep);
+
 	free_irq(dev->irq, dev);
 
+	epic_pause(dev);
+
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		skb = ep->rx_skbuff[i];
@@ -1470,6 +1596,7 @@ static void __devexit epic_remove_one (s
 #endif
 	pci_release_regions(pdev);
 	free_netdev(dev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	/* pci_power_off(pdev, -1); */
 }
