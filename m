From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 4/5] pcnet32:  break receive routine into two pieces.
Date: Wed, 13 Sep 2006 10:16:38 -0700
Message-ID: <20060913171638.GA12761@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:32665 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750806AbWIMRPv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 13:15:51 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHFpKV020550
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:51 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHFoeT200380
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:15:51 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHFogS028956
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:15:50 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Breaking the receive frame processing into two routines for greater clarity.  

Tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.move	Tue Sep 12 11:37:43 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Tue Sep 12 14:21:18 2006
@@ -1124,161 +1124,140 @@ static int pcnet32_suspend(struct net_de
 	return 1;
 }
 
+/*
+ * process one receive descriptor entry
+ */
 
-static int pcnet32_rx(struct net_device *dev)
+static void pcnet32_rx_entry(struct net_device *dev,
+			     struct pcnet32_private *lp,
+			     struct pcnet32_rx_head *rxp,
+			     int entry)
 {
-	struct pcnet32_private *lp = dev->priv;
-	int entry = lp->cur_rx & lp->rx_mod_mask;
-	int boguscnt = lp->rx_ring_size / 2;
+	int status = (short)le16_to_cpu(rxp->status) >> 8;
+	int rx_in_place = 0;
+	struct sk_buff *skb;
+	short pkt_len;
 
-	/* If we own the next entry, it's a new packet. Send it up. */
-	while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
-		int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
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
+		return;
+	}
 
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
+	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
 
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
+	/* Discard oversize frames. */
+	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR "%s: Impossible packet size %d!\n",
+			       dev->name, pkt_len);
+		lp->stats.rx_errors++;
+		return;
+	}
+	if (pkt_len < 60) {
+		if (netif_msg_rx_err(lp))
+			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
+		lp->stats.rx_errors++;
+		return;
+	}
 
-				if (pkt_len > rx_copybreak) {
-					struct sk_buff *newskb;
+	if (pkt_len > rx_copybreak) {
+		struct sk_buff *newskb;
 
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
+					    pci_map_single(lp->pci_dev,
+							   newskb->data,
+							   PKT_BUF_SZ - 2,
+							   PCI_DMA_FROMDEVICE);
+			rxp->base = le32_to_cpu(lp->rx_dma_addr[entry]);
+			rx_in_place = 1;
+		} else
+			skb = NULL;
+	} else {
+		skb = dev_alloc_skb(pkt_len + 2);
+	}
 
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
+	if (skb == NULL) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR
+			       "%s: Memory squeeze, dropping packet.\n",
+			       dev->name);
+		lp->stats.rx_dropped++;
+		return;
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
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_rx(skb);
+	dev->last_rx = jiffies;
+	lp->stats.rx_packets++;
+	return;
+}
+
+
+static void pcnet32_rx(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int entry = lp->cur_rx & lp->rx_mod_mask;
+	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
+	int npackets = 0;
+	int boguscnt = lp->rx_ring_size / 2;
+
+	/* If we own the next entry, it's a new packet. Send it up. */
+	while (boguscnt > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+		pcnet32_rx_entry(dev, lp, rxp, entry);
+		npackets += 1;
 		/*
-		 * The docs say that the buffer length isn't touched, but Andrew Boyd
-		 * of QNX reports that some revs of the 79C965 clear it.
+		 * The docs say that the buffer length isn't touched, but Andrew
+		 * Boyd of QNX reports that some revs of the 79C965 clear it.
 		 */
-		lp->rx_ring[entry].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
-		wmb();		/* Make sure owner changes after all others are visible */
-		lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
+		rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		wmb();	/* Make sure owner changes after others are visible */
+		rxp->status = le16_to_cpu(0x8000);
 		entry = (++lp->cur_rx) & lp->rx_mod_mask;
-		if (--boguscnt <= 0)
-			break;	/* don't stay in loop forever */
+		rxp = &lp->rx_ring[entry];
 	}
 
-	return 0;
+	return;
 }
 
 static int pcnet32_tx(struct net_device *dev, u16 csr0)
@@ -1298,7 +1277,7 @@ static int pcnet32_tx(struct net_device 
 		lp->tx_ring[entry].base = 0;
 
 		if (status & 0x4000) {
-			/* There was an major error, log it. */
+			/* There was a major error, log it. */
 			int err_status = le32_to_cpu(lp->tx_ring[entry].misc);
 			lp->stats.tx_errors++;
 			if (netif_msg_tx_err(lp))
@@ -1329,8 +1308,7 @@ static int pcnet32_tx(struct net_device 
 				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
 					/* Ackk!  On FIFO errors the Tx unit is turned off! */
 					/* Remove this verbosity later! */
-					if (netif_msg_tx_err
-					    (lp))
+					if (netif_msg_tx_err(lp))
 						printk(KERN_ERR
 						       "%s: Tx FIFO error! CSR0=%4.4x\n",
 						       dev->name, csr0);
@@ -1350,16 +1328,14 @@ static int pcnet32_tx(struct net_device 
 					 lp->tx_dma_addr[entry],
 					 lp->tx_skbuff[entry]->
 					 len, PCI_DMA_TODEVICE);
-			dev_kfree_skb_irq(lp->tx_skbuff[entry]);
+			dev_kfree_skb_any(lp->tx_skbuff[entry]);
 			lp->tx_skbuff[entry] = NULL;
 			lp->tx_dma_addr[entry] = 0;
 		}
 		dirty_tx++;
 	}
 
-	delta =
-	    (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask +
-				       lp->tx_ring_size);
+	delta = (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask + lp->tx_ring_size);
 	if (delta > lp->tx_ring_size) {
 		if (netif_msg_drv(lp))
 			printk(KERN_ERR
@@ -2535,19 +2511,20 @@ pcnet32_interrupt(int irq, void *dev_id,
 
 	spin_lock(&lp->lock);
 
-	while ((csr0 = lp->a.read_csr(ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
+	csr0 = lp->a.read_csr(ioaddr, CSR0);
+	while ((csr0 & 0x8f00) && --boguscnt >= 0) {
 		if (csr0 == 0xffff) {
 			break;	/* PCMCIA remove happened */
 		}
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		lp->a.write_csr(ioaddr, 0, csr0 & ~0x004f);
+		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
 		must_restart = 0;
 
 		if (netif_msg_intr(lp))
 			printk(KERN_DEBUG
 			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
-			       dev->name, csr0, lp->a.read_csr(ioaddr, 0));
+			       dev->name, csr0, lp->a.read_csr(ioaddr, CSR0));
 
 		if (csr0 & 0x0400)	/* Rx interrupt */
 			pcnet32_rx(dev);
@@ -2561,14 +2538,16 @@ pcnet32_interrupt(int irq, void *dev_id,
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
+			 * interrupts for the frames in the receive ring.  But
+			 * there are some PCI chipsets (I can reproduce this
+			 * on SP3G with Intel saturn chipset) which have
+			 * sometimes problems and will fill up the receive
+			 * ring with error descriptors.  In this situation we
+			 * don't get a rx interrupt, but a missed frame
+			 * interrupt sooner or later.  So we try to clean up
+			 * our receive ring here.
 			 */
 			pcnet32_rx(dev);
 			lp->stats.rx_errors++;	/* Missed a Rx frame. */
@@ -2588,6 +2567,7 @@ pcnet32_interrupt(int irq, void *dev_id,
 			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
+		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
 	/* Set interrupt enable. */
-- 
Don Fry
brazilnut@us.ibm.com
