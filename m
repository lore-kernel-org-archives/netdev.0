From: Andreas Henriksson <andreas@fjortis.info>
Subject: Re: fealnx oopses
Date: Mon, 29 Mar 2004 19:01:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329170143.GA28822@scream.fjortis.info>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua> <20040328005533.A6117@electric-eye.fr.zoreil.com> <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua> <20040328232707.GA17524@scream.fjortis.info> <20040329013834.B24996@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Henriksson <andreas@fjortis.info>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040329013834.B24996@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, Mar 29, 2004 at 01:38:34AM +0200, Francois Romieu wrote:
>
> Oops, I forgot to initialize np->lack_rxbuf correctly.
> 
> If you have some time to spend, you can change in netdev_rx:
>                                 pci_unmap_single(np->pci_dev,
>                                                  np->cur_rx->buffer,
>                                                  np->rx_buf_sz,
>                                                  PCI_DMA_FROMDEVICE);
>                                 skb_put(skb = np->cur_rx->skbuff, pkt_len);
>                                 np->cur_rx->skbuff = NULL;
>                                 --np->really_rx_count;
> into:
>                                 pci_unmap_single(np->pci_dev,
>                                                  np->cur_rx->buffer,
>                                                  np->rx_buf_sz,
>                                                  PCI_DMA_FROMDEVICE);
>                                 skb_put(skb = np->cur_rx->skbuff, pkt_len);
>                                 np->cur_rx->skbuff = NULL;
> 				if (!np->lack_rxbuf)                 <<<
> 					np->lack_rxbuf = np->cur_rx; <<<
>                                 np->cur_rx->skbuff = NULL;
>                                 --np->really_rx_count;
> 

I tried this one:

> It may be simpler/safer to turn (init_ring):
>         np->lack_rxbuf = NULL;
> into
>         np->lack_rxbuf = np->rx_ring;
> 
> I'll check the whole thing tomorrow. It's time to sleep now.
> 

And everything seems to work better then ever before.. :)

I transfered 2 GB of data over my lan and didn't even get a single "transmit
timed out" or anything. 

I've attached a patch with is what I'm using at the moment that includes
both Jeff's and Francois changes below if anyone else wants to test it...
(Also available at
http://fjortis.info/pub/panic/fealnx/fealnx-jgarzik-fromieu.patch ... )


> Thanks for your report.

Thanks for your patch and useful suggestions.. :)

> 
> --
> Ueimor


Regards,
Andreas Henriksson





--- org-fealnx.c	2004-03-28 18:30:37.000000000 +0200
+++ fealnx.c	2004-03-29 18:27:20.000000000 +0200
@@ -1134,15 +1134,17 @@ static void allocate_rx_buffers(struct n
 		struct sk_buff *skb;
 
 		skb = dev_alloc_skb(np->rx_buf_sz);
-		np->lack_rxbuf->skbuff = skb;
-
 		if (skb == NULL)
 			break;	/* Better luck next round. */
 
+		while (np->lack_rxbuf->skbuff)
+			np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
+		np->lack_rxbuf->skbuff = skb;
+
 		skb->dev = dev;	/* Mark as being used by this device. */
 		np->lack_rxbuf->buffer = pci_map_single(np->pci_dev, skb->tail,
 			np->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
+		np->lack_rxbuf->status = RXOWN;
 		++np->really_rx_count;
 	}
 }
@@ -1251,7 +1253,7 @@ static void init_ring(struct net_device 
 	/* initialize rx variables */
 	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 	np->cur_rx = &np->rx_ring[0];
-	np->lack_rxbuf = NULL;
+	np->lack_rxbuf = np->rx_ring;
 	np->really_rx_count = 0;
 
 	/* initial rx descriptors. */
@@ -1303,14 +1305,15 @@ static void init_ring(struct net_device 
 	/* for the last tx descriptor */
 	np->tx_ring[i - 1].next_desc = np->tx_ring_dma;
 	np->tx_ring[i - 1].next_desc_logical = &np->tx_ring[0];
-
-	return;
 }
 
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = dev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&np->lock, flags);
 
 	np->cur_tx_copy->skbuff = skb;
 
@@ -1340,7 +1343,7 @@ static int start_tx(struct sk_buff *skb,
 		np->cur_tx_copy->control |= (BPT << TBSShift);	/* buffer size */
 
 		/* for the last descriptor */
-		next = (struct fealnx *) np->cur_tx_copy.next_desc_logical;
+		next = np->cur_tx_copy.next_desc_logical;
 		next->skbuff = skb;
 		next->control = TXIC | TXLD | CRCEnable | PADEnable;
 		next->control |= (skb->len << PKTSShift);	/* pkt size */
@@ -1377,36 +1380,26 @@ static int start_tx(struct sk_buff *skb,
 	writel(0, dev->base_addr + TXPDR);
 	dev->trans_start = jiffies;
 
+	spin_unlock_irqrestore(&np->lock, flags);
 	return 0;
 }
 
-
-void free_one_rx_descriptor(struct netdev_private *np)
-{
-	if (np->really_rx_count == RX_RING_SIZE)
-		np->cur_rx->status = RXOWN;
-	else {
-		np->lack_rxbuf->skbuff = np->cur_rx->skbuff;
-		np->lack_rxbuf->buffer = np->cur_rx->buffer;
-		np->lack_rxbuf->status = RXOWN;
-		++np->really_rx_count;
-		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
-	}
-	np->cur_rx = np->cur_rx->next_desc_logical;
-}
-
-
 void reset_rx_descriptors(struct net_device *dev)
 {
 	struct netdev_private *np = dev->priv;
+	struct fealnx_desc *cur = np->cur_rx;
+	int i;
 
 	stop_nic_rx(dev->base_addr, np->crvalue);
 
-	while (!(np->cur_rx->status & RXOWN))
-		free_one_rx_descriptor(np);
-
 	allocate_rx_buffers(dev);
 
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (cur->skbuff)
+			cur->status = RXOWN;
+		cur = cur->next_desc_logical;
+	}
+
 	writel(np->rx_ring_dma + (np->cur_rx - np->rx_ring),
 		dev->base_addr + RXLBA);
 	writel(np->crvalue, dev->base_addr + TCRRCR);
@@ -1423,6 +1416,8 @@ static irqreturn_t intr_handler(int irq,
 	unsigned int num_tx = 0;
 	int handled = 0;
 
+	spin_lock(&np->lock);
+
 	writel(0, dev->base_addr + IMR);
 
 	ioaddr = dev->base_addr;
@@ -1565,6 +1560,8 @@ static irqreturn_t intr_handler(int irq,
 
 	writel(np->imrvalue, ioaddr + IMR);
 
+	spin_unlock(&np->lock);
+
 	return IRQ_RETVAL(handled);
 }
 
@@ -1576,7 +1573,7 @@ static int netdev_rx(struct net_device *
 	struct netdev_private *np = dev->priv;
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
-	while (!(np->cur_rx->status & RXOWN)) {
+	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
 		s32 rx_status = np->cur_rx->status;
 
 		if (np->really_rx_count == 0)
@@ -1628,8 +1625,15 @@ static int netdev_rx(struct net_device *
 					np->stats.rx_length_errors++;
 
 					/* free all rx descriptors related this long pkt */
-					for (i = 0; i < desno; ++i)
-						free_one_rx_descriptor(np);
+					for (i = 0; i < desno; ++i) {
+						if (!np->cur_rx->skbuff) {
+							printk(KERN_DEBUG
+								"%s: I'm scared\n", dev->name);
+							break;
+						}
+						np->cur_rx->status = RXOWN;
+						np->cur_rx = np->cur_rx->next_desc_logical;
+					}
 					continue;
 				} else {	/* something error, need to reset this chip */
 					reset_rx_descriptors(dev);
@@ -1679,8 +1683,6 @@ static int netdev_rx(struct net_device *
 						 PCI_DMA_FROMDEVICE);
 				skb_put(skb = np->cur_rx->skbuff, pkt_len);
 				np->cur_rx->skbuff = NULL;
-				if (np->really_rx_count == RX_RING_SIZE)
-					np->lack_rxbuf = np->cur_rx;
 				--np->really_rx_count;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1689,25 +1691,7 @@ static int netdev_rx(struct net_device *
 			np->stats.rx_packets++;
 			np->stats.rx_bytes += pkt_len;
 		}
-
-		if (np->cur_rx->skbuff == NULL) {
-			struct sk_buff *skb;
-
-			skb = dev_alloc_skb(np->rx_buf_sz);
-
-			if (skb != NULL) {
-				skb->dev = dev;	/* Mark as being used by this device. */
-				np->cur_rx->buffer = pci_map_single(np->pci_dev,
-								    skb->tail,
-								    np->rx_buf_sz,
-								    PCI_DMA_FROMDEVICE);
-				np->cur_rx->skbuff = skb;
-				++np->really_rx_count;
-			}
-		}
-
-		if (np->cur_rx->skbuff != NULL)
-			free_one_rx_descriptor(np);
+		np->cur_rx = np->cur_rx->next_desc_logical;
 	}			/* end of while loop */
 
 	/*  allocate skb for rx buffers */
