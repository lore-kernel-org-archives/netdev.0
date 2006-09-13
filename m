From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 3/5] pcnet32:  move/create receive and transmit routines
Date: Wed, 13 Sep 2006 10:16:21 -0700
Message-ID: <20060913171621.GA12756@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:61649 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750802AbWIMRPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 13:15:35 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHFXJW001760
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHFXAs080232
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:33 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHFXh6004715
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:33 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the receive routine and create the transmit routine.

Tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.magic	Tue Sep 12 10:25:20 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Tue Sep 12 11:37:43 2006
@@ -299,7 +299,6 @@ static int pcnet32_probe1(unsigned long,
 static int pcnet32_open(struct net_device *);
 static int pcnet32_init_ring(struct net_device *);
 static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
-static int pcnet32_rx(struct net_device *);
 static void pcnet32_tx_timeout(struct net_device *dev);
 static irqreturn_t pcnet32_interrupt(int, void *, struct pt_regs *);
 static int pcnet32_close(struct net_device *);
@@ -1125,6 +1124,264 @@ static int pcnet32_suspend(struct net_de
 	return 1;
 }
 
+
+static int pcnet32_rx(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int entry = lp->cur_rx & lp->rx_mod_mask;
+	int boguscnt = lp->rx_ring_size / 2;
+
+	/* If we own the next entry, it's a new packet. Send it up. */
+	while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
+		int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
+
+		if (status != 0x03) {	/* There was an error. */
+			/*
+			 * There is a tricky error noted by John Murphy,
+			 * <murf@perftech.com> to Russ Nelson: Even with full-sized
+			 * buffers it's possible for a jabber packet to use two
+			 * buffers, with only the last correctly noting the error.
+			 */
+			if (status & 0x01)	/* Only count a general error at the */
+				lp->stats.rx_errors++;	/* end of a packet. */
+			if (status & 0x20)
+				lp->stats.rx_frame_errors++;
+			if (status & 0x10)
+				lp->stats.rx_over_errors++;
+			if (status & 0x08)
+				lp->stats.rx_crc_errors++;
+			if (status & 0x04)
+				lp->stats.rx_fifo_errors++;
+			lp->rx_ring[entry].status &= le16_to_cpu(0x03ff);
+		} else {
+			/* Malloc up new buffer, compatible with net-2e. */
+			short pkt_len =
+			    (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)
+			    - 4;
+			struct sk_buff *skb;
+
+			/* Discard oversize frames. */
+			if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+				if (netif_msg_drv(lp))
+					printk(KERN_ERR
+					       "%s: Impossible packet size %d!\n",
+					       dev->name, pkt_len);
+				lp->stats.rx_errors++;
+			} else if (pkt_len < 60) {
+				if (netif_msg_rx_err(lp))
+					printk(KERN_ERR "%s: Runt packet!\n",
+					       dev->name);
+				lp->stats.rx_errors++;
+			} else {
+				int rx_in_place = 0;
+
+				if (pkt_len > rx_copybreak) {
+					struct sk_buff *newskb;
+
+					if ((newskb =
+					     dev_alloc_skb(PKT_BUF_SZ))) {
+						skb_reserve(newskb, 2);
+						skb = lp->rx_skbuff[entry];
+						pci_unmap_single(lp->pci_dev,
+								 lp->
+								 rx_dma_addr
+								 [entry],
+								 PKT_BUF_SZ - 2,
+								 PCI_DMA_FROMDEVICE);
+						skb_put(skb, pkt_len);
+						lp->rx_skbuff[entry] = newskb;
+						newskb->dev = dev;
+						lp->rx_dma_addr[entry] =
+						    pci_map_single(lp->pci_dev,
+								   newskb->data,
+								   PKT_BUF_SZ -
+								   2,
+								   PCI_DMA_FROMDEVICE);
+						lp->rx_ring[entry].base =
+						    le32_to_cpu(lp->
+								rx_dma_addr
+								[entry]);
+						rx_in_place = 1;
+					} else
+						skb = NULL;
+				} else {
+					skb = dev_alloc_skb(pkt_len + 2);
+				}
+
+				if (skb == NULL) {
+					int i;
+					if (netif_msg_drv(lp))
+						printk(KERN_ERR
+						       "%s: Memory squeeze, deferring packet.\n",
+						       dev->name);
+					for (i = 0; i < lp->rx_ring_size; i++)
+						if ((short)
+						    le16_to_cpu(lp->
+								rx_ring[(entry +
+									 i)
+									& lp->
+									rx_mod_mask].
+								status) < 0)
+							break;
+
+					if (i > lp->rx_ring_size - 2) {
+						lp->stats.rx_dropped++;
+						lp->rx_ring[entry].status |=
+						    le16_to_cpu(0x8000);
+						wmb();	/* Make sure adapter sees owner change */
+						lp->cur_rx++;
+					}
+					break;
+				}
+				skb->dev = dev;
+				if (!rx_in_place) {
+					skb_reserve(skb, 2);	/* 16 byte align */
+					skb_put(skb, pkt_len);	/* Make room */
+					pci_dma_sync_single_for_cpu(lp->pci_dev,
+								    lp->
+								    rx_dma_addr
+								    [entry],
+								    PKT_BUF_SZ -
+								    2,
+								    PCI_DMA_FROMDEVICE);
+					eth_copy_and_sum(skb,
+							 (unsigned char *)(lp->
+									   rx_skbuff
+									   [entry]->
+									   data),
+							 pkt_len, 0);
+					pci_dma_sync_single_for_device(lp->
+								       pci_dev,
+								       lp->
+								       rx_dma_addr
+								       [entry],
+								       PKT_BUF_SZ
+								       - 2,
+								       PCI_DMA_FROMDEVICE);
+				}
+				lp->stats.rx_bytes += skb->len;
+				skb->protocol = eth_type_trans(skb, dev);
+				netif_rx(skb);
+				dev->last_rx = jiffies;
+				lp->stats.rx_packets++;
+			}
+		}
+		/*
+		 * The docs say that the buffer length isn't touched, but Andrew Boyd
+		 * of QNX reports that some revs of the 79C965 clear it.
+		 */
+		lp->rx_ring[entry].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		wmb();		/* Make sure owner changes after all others are visible */
+		lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
+		entry = (++lp->cur_rx) & lp->rx_mod_mask;
+		if (--boguscnt <= 0)
+			break;	/* don't stay in loop forever */
+	}
+
+	return 0;
+}
+
+static int pcnet32_tx(struct net_device *dev, u16 csr0)
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
+			int err_status = le32_to_cpu(lp->tx_ring[entry].misc);
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
+					       "%s: Tx FIFO error! CSR0=%4.4x\n",
+					       dev->name, csr0);
+				must_restart = 1;
+			}
+#else
+			if (err_status & 0x40000000) {
+				lp->stats.tx_fifo_errors++;
+				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
+					/* Ackk!  On FIFO errors the Tx unit is turned off! */
+					/* Remove this verbosity later! */
+					if (netif_msg_tx_err
+					    (lp))
+						printk(KERN_ERR
+						       "%s: Tx FIFO error! CSR0=%4.4x\n",
+						       dev->name, csr0);
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
+			dev_kfree_skb_irq(lp->tx_skbuff[entry]);
+			lp->tx_skbuff[entry] = NULL;
+			lp->tx_dma_addr[entry] = 0;
+		}
+		dirty_tx++;
+	}
+
+	delta =
+	    (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask +
+				       lp->tx_ring_size);
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
@@ -2296,105 +2553,7 @@ pcnet32_interrupt(int irq, void *dev_id,
 			pcnet32_rx(dev);
 
 		if (csr0 & 0x0200) {	/* Tx-done interrupt */
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
+			must_restart = pcnet32_tx(dev, csr0);
 		}
 
 		/* Log misc errors. */
@@ -2443,162 +2602,6 @@ pcnet32_interrupt(int irq, void *dev_id,
 	return IRQ_HANDLED;
 }
 
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
-}
-
 static int pcnet32_close(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-- 
Don Fry
brazilnut@us.ibm.com
