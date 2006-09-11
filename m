From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/3] pcnet32: reorganize interrupt, tx, and rx processing
Date: Mon, 11 Sep 2006 10:46:02 -0700
Message-ID: <20060911174602.GA3968@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52098 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751320AbWIKRpT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 13:45:19 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8BHjG4L017147
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:45:16 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BHjFDS268664
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 11:45:15 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BHjF8l012277
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 11:45:15 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reorganize code to facilitate NAPI changes.
Tested ia32 and ppc64.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.orig	Fri Sep  8 14:02:12 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Mon Sep 11 09:07:13 2006
@@ -299,7 +299,6 @@ static int pcnet32_probe1(unsigned long,
 static int pcnet32_open(struct net_device *);
 static int pcnet32_init_ring(struct net_device *);
 static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
-static int pcnet32_rx(struct net_device *);
 static void pcnet32_tx_timeout(struct net_device *dev);
 static irqreturn_t pcnet32_interrupt(int, void *, struct pt_regs *);
 static int pcnet32_close(struct net_device *);
@@ -1125,6 +1124,235 @@ static int pcnet32_suspend(struct net_de
 	return 1;
 }
 
+static int pcnet32_rx_entry(struct net_device *dev,
+			    struct pcnet32_private *lp,
+			    struct pcnet32_rx_head *rxp,
+			    int entry)
+{
+	int status = (short)le16_to_cpu(rxp->status) >> 8;
+	int rx_in_place = 0;
+	struct sk_buff *skb;
+	short pkt_len;
+
+	if (status != 0x03) {	/* There was an error. */
+		/*
+		 * There is a tricky error noted by John Murphy,
+		 * <murf@perftech.com> to Russ Nelson: Even with full-sized
+		 * buffers it's possible for a jabber packet to use two
+		 * buffers, with only the last correctly noting the error.
+		 */
+		if (status & 0x01)	/* Only count a general error at the */
+			lp->stats.rx_errors++;	/* end of a packet. */
+		if (status & 0x20)
+			lp->stats.rx_frame_errors++;
+		if (status & 0x10)
+			lp->stats.rx_over_errors++;
+		if (status & 0x08)
+			lp->stats.rx_crc_errors++;
+		if (status & 0x04)
+			lp->stats.rx_fifo_errors++;
+		return 1;
+	}
+
+	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
+
+	/* Discard oversize frames. */
+	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR "%s: Impossible packet size %d!\n",
+			       dev->name, pkt_len);
+		lp->stats.rx_errors++;
+		return 1;
+	}
+	if (pkt_len < 60) {
+		if (netif_msg_rx_err(lp))
+			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
+		lp->stats.rx_errors++;
+		return 1;
+	}
+
+	if (pkt_len > rx_copybreak) {
+		struct sk_buff *newskb;
+
+		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
+			skb_reserve(newskb, 2);
+			skb = lp->rx_skbuff[entry];
+			pci_unmap_single(lp->pci_dev,
+					 lp->rx_dma_addr[entry],
+					 PKT_BUF_SZ - 2,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, pkt_len);
+			lp->rx_skbuff[entry] = newskb;
+			newskb->dev = dev;
+			lp->rx_dma_addr[entry] =
+			    pci_map_single(lp->pci_dev,
+					   newskb->data,
+					   PKT_BUF_SZ - 2,
+					   PCI_DMA_FROMDEVICE);
+			rxp->base = le32_to_cpu(lp->rx_dma_addr[entry]);
+			rx_in_place = 1;
+		} else
+			skb = NULL;
+	} else {
+		skb = dev_alloc_skb(pkt_len + 2);
+	}
+
+	if (skb == NULL) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR
+			       "%s: Memory squeeze, dropping packet.\n",
+			       dev->name);
+		lp->stats.rx_dropped++;
+		return 1;
+	}
+	skb->dev = dev;
+	if (!rx_in_place) {
+		skb_reserve(skb, 2);	/* 16 byte align */
+		skb_put(skb, pkt_len);	/* Make room */
+		pci_dma_sync_single_for_cpu(lp->pci_dev,
+					    lp->rx_dma_addr[entry],
+					    PKT_BUF_SZ - 2,
+					    PCI_DMA_FROMDEVICE);
+		eth_copy_and_sum(skb,
+				 (unsigned char *)(lp->rx_skbuff[entry]->data),
+				 pkt_len, 0);
+		pci_dma_sync_single_for_device(lp->pci_dev,
+					       lp->rx_dma_addr[entry],
+					       PKT_BUF_SZ - 2,
+					       PCI_DMA_FROMDEVICE);
+	}
+	lp->stats.rx_bytes += skb->len;
+	lp->stats.rx_packets++;
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_rx(skb);
+	dev->last_rx = jiffies;
+	return 1;
+}
+
+static int pcnet32_rx(struct net_device *dev, int quota)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int entry = lp->cur_rx & lp->rx_mod_mask;
+	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
+	int npackets = 0;
+
+	/* If we own the next entry, it's a new packet. Send it up. */
+	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+		npackets += pcnet32_rx_entry(dev, lp, rxp, entry);
+		/*
+		 * The docs say that the buffer length isn't touched, but Andrew
+		 * Boyd of QNX reports that some revs of the 79C965 clear it.
+		 */
+		rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		wmb();	/* Make sure owner changes after others are visible */
+		rxp->status = le16_to_cpu(0x8000);
+		entry = (++lp->cur_rx) & lp->rx_mod_mask;
+		rxp = &lp->rx_ring[entry];
+	}
+
+	return npackets;
+}
+
+static int pcnet32_tx(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned int dirty_tx = lp->dirty_tx;
+	int delta;
+	int must_restart = 0;
+
+	while (dirty_tx != lp->cur_tx) {
+		int entry = dirty_tx & lp->tx_mod_mask;
+		int status = (short)le16_to_cpu(lp->tx_ring[entry].status);
+
+		if (status < 0)
+			break;	/* It still hasn't been Txed */
+
+		lp->tx_ring[entry].base = 0;
+
+		if (status & 0x4000) {
+			/* There was an major error, log it. */
+			int err_status =
+			    le32_to_cpu(lp->tx_ring[entry].
+					misc);
+			lp->stats.tx_errors++;
+			if (netif_msg_tx_err(lp))
+				printk(KERN_ERR
+				       "%s: Tx error status=%04x err_status=%08x\n",
+				       dev->name, status,
+				       err_status);
+			if (err_status & 0x04000000)
+				lp->stats.tx_aborted_errors++;
+			if (err_status & 0x08000000)
+				lp->stats.tx_carrier_errors++;
+			if (err_status & 0x10000000)
+				lp->stats.tx_window_errors++;
+#ifndef DO_DXSUFLO
+			if (err_status & 0x40000000) {
+				lp->stats.tx_fifo_errors++;
+				/* Ackk!  On FIFO errors the Tx unit is turned off! */
+				/* Remove this verbosity later! */
+				if (netif_msg_tx_err(lp))
+					printk(KERN_ERR
+					       "%s: Tx FIFO error!\n",
+						dev->name);
+				must_restart = 1;
+			}
+#else
+			if (err_status & 0x40000000) {
+				lp->stats.tx_fifo_errors++;
+				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
+					/* Ackk!  On FIFO errors the Tx unit is turned off! */
+					/* Remove this verbosity later! */
+					if (netif_msg_tx_err(lp))
+						printk(KERN_ERR
+						       "%s: Tx FIFO error!\n",
+						       dev->name);
+					must_restart = 1;
+				}
+			}
+#endif
+		} else {
+			if (status & 0x1800)
+				lp->stats.collisions++;
+			lp->stats.tx_packets++;
+		}
+
+		/* We must free the original skb */
+		if (lp->tx_skbuff[entry]) {
+			pci_unmap_single(lp->pci_dev,
+					 lp->tx_dma_addr[entry],
+					 lp->tx_skbuff[entry]->
+					 len, PCI_DMA_TODEVICE);
+			dev_kfree_skb_any(lp->tx_skbuff[entry]);
+			lp->tx_skbuff[entry] = NULL;
+			lp->tx_dma_addr[entry] = 0;
+		}
+		dirty_tx++;
+	}
+
+	delta = (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask + lp->tx_ring_size);
+	if (delta > lp->tx_ring_size) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR
+			       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+			       dev->name, dirty_tx, lp->cur_tx,
+			       lp->tx_full);
+		dirty_tx += lp->tx_ring_size;
+		delta -= lp->tx_ring_size;
+	}
+
+	if (lp->tx_full &&
+	    netif_queue_stopped(dev) &&
+	    delta < lp->tx_ring_size - 2) {
+		/* The ring is no longer full, clear tbusy. */
+		lp->tx_full = 0;
+		netif_wake_queue(dev);
+	}
+	lp->dirty_tx = dirty_tx;
+
+	return must_restart;
+}
+
 #define PCNET32_REGS_PER_PHY	32
 #define PCNET32_MAX_PHYS	32
 static int pcnet32_get_regs_len(struct net_device *dev)
@@ -1661,6 +1889,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
+	dev->weight = lp->rx_ring_size / 2;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = pcnet32_poll_controller;
@@ -2262,9 +2491,9 @@ pcnet32_interrupt(int irq, void *dev_id,
 	struct net_device *dev = dev_id;
 	struct pcnet32_private *lp;
 	unsigned long ioaddr;
-	u16 csr0, rap;
 	int boguscnt = max_interrupt_work;
-	int must_restart;
+	u16 csr0;
+	irqreturn_t rc = IRQ_HANDLED;
 
 	if (!dev) {
 		if (pcnet32_debug & NETIF_MSG_INTR)
@@ -2278,141 +2507,33 @@ pcnet32_interrupt(int irq, void *dev_id,
 
 	spin_lock(&lp->lock);
 
-	rap = lp->a.read_rap(ioaddr);
-	while ((csr0 = lp->a.read_csr(ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
-		if (csr0 == 0xffff) {
-			break;	/* PCMCIA remove happened */
-		}
+	csr0 = lp->a.read_csr(ioaddr, CSR0);
+	if (csr0 == 0xffff) {
+		rc = IRQ_NONE;
+	} else while (csr0 & 0x8f00 && --boguscnt >= 0) {
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		lp->a.write_csr(ioaddr, 0, csr0 & ~0x004f);
-
-		must_restart = 0;
+		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
 		if (netif_msg_intr(lp))
 			printk(KERN_DEBUG
 			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
-			       dev->name, csr0, lp->a.read_csr(ioaddr, 0));
-
-		if (csr0 & 0x0400)	/* Rx interrupt */
-			pcnet32_rx(dev);
-
-		if (csr0 & 0x0200) {	/* Tx-done interrupt */
-			unsigned int dirty_tx = lp->dirty_tx;
-			int delta;
-
-			while (dirty_tx != lp->cur_tx) {
-				int entry = dirty_tx & lp->tx_mod_mask;
-				int status =
-				    (short)le16_to_cpu(lp->tx_ring[entry].
-						       status);
-
-				if (status < 0)
-					break;	/* It still hasn't been Txed */
-
-				lp->tx_ring[entry].base = 0;
-
-				if (status & 0x4000) {
-					/* There was an major error, log it. */
-					int err_status =
-					    le32_to_cpu(lp->tx_ring[entry].
-							misc);
-					lp->stats.tx_errors++;
-					if (netif_msg_tx_err(lp))
-						printk(KERN_ERR
-						       "%s: Tx error status=%04x err_status=%08x\n",
-						       dev->name, status,
-						       err_status);
-					if (err_status & 0x04000000)
-						lp->stats.tx_aborted_errors++;
-					if (err_status & 0x08000000)
-						lp->stats.tx_carrier_errors++;
-					if (err_status & 0x10000000)
-						lp->stats.tx_window_errors++;
-#ifndef DO_DXSUFLO
-					if (err_status & 0x40000000) {
-						lp->stats.tx_fifo_errors++;
-						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						/* Remove this verbosity later! */
-						if (netif_msg_tx_err(lp))
-							printk(KERN_ERR
-							       "%s: Tx FIFO error! CSR0=%4.4x\n",
-							       dev->name, csr0);
-						must_restart = 1;
-					}
-#else
-					if (err_status & 0x40000000) {
-						lp->stats.tx_fifo_errors++;
-						if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
-							/* Ackk!  On FIFO errors the Tx unit is turned off! */
-							/* Remove this verbosity later! */
-							if (netif_msg_tx_err
-							    (lp))
-								printk(KERN_ERR
-								       "%s: Tx FIFO error! CSR0=%4.4x\n",
-								       dev->
-								       name,
-								       csr0);
-							must_restart = 1;
-						}
-					}
-#endif
-				} else {
-					if (status & 0x1800)
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
-				}
-
-				/* We must free the original skb */
-				if (lp->tx_skbuff[entry]) {
-					pci_unmap_single(lp->pci_dev,
-							 lp->tx_dma_addr[entry],
-							 lp->tx_skbuff[entry]->
-							 len, PCI_DMA_TODEVICE);
-					dev_kfree_skb_irq(lp->tx_skbuff[entry]);
-					lp->tx_skbuff[entry] = NULL;
-					lp->tx_dma_addr[entry] = 0;
-				}
-				dirty_tx++;
-			}
-
-			delta =
-			    (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask +
-						       lp->tx_ring_size);
-			if (delta > lp->tx_ring_size) {
-				if (netif_msg_drv(lp))
-					printk(KERN_ERR
-					       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-					       dev->name, dirty_tx, lp->cur_tx,
-					       lp->tx_full);
-				dirty_tx += lp->tx_ring_size;
-				delta -= lp->tx_ring_size;
-			}
-
-			if (lp->tx_full &&
-			    netif_queue_stopped(dev) &&
-			    delta < lp->tx_ring_size - 2) {
-				/* The ring is no longer full, clear tbusy. */
-				lp->tx_full = 0;
-				netif_wake_queue(dev);
-			}
-			lp->dirty_tx = dirty_tx;
-		}
+			       dev->name, csr0, lp->a.read_csr(ioaddr, CSR0));
 
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
 			lp->stats.tx_errors++;	/* Tx babble. */
 		if (csr0 & 0x1000) {
 			/*
-			 * this happens when our receive ring is full. This shouldn't
-			 * be a problem as we will see normal rx interrupts for the frames
-			 * in the receive ring. But there are some PCI chipsets (I can
-			 * reproduce this on SP3G with Intel saturn chipset) which have
-			 * sometimes problems and will fill up the receive ring with
-			 * error descriptors. In this situation we don't get a rx
-			 * interrupt, but a missed frame interrupt sooner or later.
-			 * So we try to clean up our receive ring here.
+			 * This happens when our receive ring is full. This
+			 * shouldn't be a problem as we will see normal rx
+			 * interrupts for the frames in the receive ring. But
+			 * there are some PCI chipsets (I can reproduce this
+			 * on SP3G with Intel saturn chipset) which have
+			 * sometimes problems and will fill up the receive
+			 * ring with error descriptors. In this situation we
+			 * don't get a rx interrupt, but a missed frame
+			 * interrupt sooner or later.
 			 */
-			pcnet32_rx(dev);
 			lp->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
@@ -2422,183 +2543,27 @@ pcnet32_interrupt(int irq, void *dev_id,
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-
-		if (must_restart) {
+		pcnet32_rx(dev, dev->weight);
+		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, 4, 0x0915);
-			pcnet32_restart(dev, 0x0002);
+			lp->a.write_csr(ioaddr, CSR4, 0x0915);
+			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
+		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
-	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, 0, 0x0040);
-	lp->a.write_rap(ioaddr, rap);
+	/*Set interrupt enable. */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
 
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock(&lp->lock);
 
-	return IRQ_HANDLED;
-}
-
-static int pcnet32_rx(struct net_device *dev)
-{
-	struct pcnet32_private *lp = dev->priv;
-	int entry = lp->cur_rx & lp->rx_mod_mask;
-	int boguscnt = lp->rx_ring_size / 2;
-
-	/* If we own the next entry, it's a new packet. Send it up. */
-	while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
-		int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
-
-		if (status != 0x03) {	/* There was an error. */
-			/*
-			 * There is a tricky error noted by John Murphy,
-			 * <murf@perftech.com> to Russ Nelson: Even with full-sized
-			 * buffers it's possible for a jabber packet to use two
-			 * buffers, with only the last correctly noting the error.
-			 */
-			if (status & 0x01)	/* Only count a general error at the */
-				lp->stats.rx_errors++;	/* end of a packet. */
-			if (status & 0x20)
-				lp->stats.rx_frame_errors++;
-			if (status & 0x10)
-				lp->stats.rx_over_errors++;
-			if (status & 0x08)
-				lp->stats.rx_crc_errors++;
-			if (status & 0x04)
-				lp->stats.rx_fifo_errors++;
-			lp->rx_ring[entry].status &= le16_to_cpu(0x03ff);
-		} else {
-			/* Malloc up new buffer, compatible with net-2e. */
-			short pkt_len =
-			    (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)
-			    - 4;
-			struct sk_buff *skb;
-
-			/* Discard oversize frames. */
-			if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
-				if (netif_msg_drv(lp))
-					printk(KERN_ERR
-					       "%s: Impossible packet size %d!\n",
-					       dev->name, pkt_len);
-				lp->stats.rx_errors++;
-			} else if (pkt_len < 60) {
-				if (netif_msg_rx_err(lp))
-					printk(KERN_ERR "%s: Runt packet!\n",
-					       dev->name);
-				lp->stats.rx_errors++;
-			} else {
-				int rx_in_place = 0;
-
-				if (pkt_len > rx_copybreak) {
-					struct sk_buff *newskb;
-
-					if ((newskb =
-					     dev_alloc_skb(PKT_BUF_SZ))) {
-						skb_reserve(newskb, 2);
-						skb = lp->rx_skbuff[entry];
-						pci_unmap_single(lp->pci_dev,
-								 lp->
-								 rx_dma_addr
-								 [entry],
-								 PKT_BUF_SZ - 2,
-								 PCI_DMA_FROMDEVICE);
-						skb_put(skb, pkt_len);
-						lp->rx_skbuff[entry] = newskb;
-						newskb->dev = dev;
-						lp->rx_dma_addr[entry] =
-						    pci_map_single(lp->pci_dev,
-								   newskb->data,
-								   PKT_BUF_SZ -
-								   2,
-								   PCI_DMA_FROMDEVICE);
-						lp->rx_ring[entry].base =
-						    le32_to_cpu(lp->
-								rx_dma_addr
-								[entry]);
-						rx_in_place = 1;
-					} else
-						skb = NULL;
-				} else {
-					skb = dev_alloc_skb(pkt_len + 2);
-				}
-
-				if (skb == NULL) {
-					int i;
-					if (netif_msg_drv(lp))
-						printk(KERN_ERR
-						       "%s: Memory squeeze, deferring packet.\n",
-						       dev->name);
-					for (i = 0; i < lp->rx_ring_size; i++)
-						if ((short)
-						    le16_to_cpu(lp->
-								rx_ring[(entry +
-									 i)
-									& lp->
-									rx_mod_mask].
-								status) < 0)
-							break;
-
-					if (i > lp->rx_ring_size - 2) {
-						lp->stats.rx_dropped++;
-						lp->rx_ring[entry].status |=
-						    le16_to_cpu(0x8000);
-						wmb();	/* Make sure adapter sees owner change */
-						lp->cur_rx++;
-					}
-					break;
-				}
-				skb->dev = dev;
-				if (!rx_in_place) {
-					skb_reserve(skb, 2);	/* 16 byte align */
-					skb_put(skb, pkt_len);	/* Make room */
-					pci_dma_sync_single_for_cpu(lp->pci_dev,
-								    lp->
-								    rx_dma_addr
-								    [entry],
-								    PKT_BUF_SZ -
-								    2,
-								    PCI_DMA_FROMDEVICE);
-					eth_copy_and_sum(skb,
-							 (unsigned char *)(lp->
-									   rx_skbuff
-									   [entry]->
-									   data),
-							 pkt_len, 0);
-					pci_dma_sync_single_for_device(lp->
-								       pci_dev,
-								       lp->
-								       rx_dma_addr
-								       [entry],
-								       PKT_BUF_SZ
-								       - 2,
-								       PCI_DMA_FROMDEVICE);
-				}
-				lp->stats.rx_bytes += skb->len;
-				skb->protocol = eth_type_trans(skb, dev);
-				netif_rx(skb);
-				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-			}
-		}
-		/*
-		 * The docs say that the buffer length isn't touched, but Andrew Boyd
-		 * of QNX reports that some revs of the 79C965 clear it.
-		 */
-		lp->rx_ring[entry].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
-		wmb();		/* Make sure owner changes after all others are visible */
-		lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
-		entry = (++lp->cur_rx) & lp->rx_mod_mask;
-		if (--boguscnt <= 0)
-			break;	/* don't stay in loop forever */
-	}
-
-	return 0;
+	return rc;
 }
 
 static int pcnet32_close(struct net_device *dev)
-- 
Don Fry
brazilnut@us.ibm.com
