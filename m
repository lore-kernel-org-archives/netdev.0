From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Sun, 28 Mar 2004 00:55:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040328005533.A6117@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040326233514.B26347@electric-eye.fr.zoreil.com> <4064BB35.4050301@pobox.com> <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andreas Henriksson <andreas@fjortis.info>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Sat, Mar 27, 2004 at 11:28:51PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
[...]
> Sorry Jeff your patch does not fix my problem.
> I also verified that it happens this way:
> (1) rx skb is processed and freed
> (2) allocation failure for new skb
> (3) next rx intr occurs, cur_rx->skbuff still == NULL
> (4) oops

Your previous analysis made sense: the logic responsible for low memory
handling is broken in several ways.

Patch against2.6.5-rc2-mm3 below, without warranty 


--- drivers/net/fealnx.c	2004-03-28 00:44:27.000000000 +0100
+++ drivers/net/fealnx.c	2004-03-28 00:52:46.000000000 +0100
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
@@ -1380,33 +1382,22 @@ static int start_tx(struct sk_buff *skb,
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
@@ -1576,7 +1567,7 @@ static int netdev_rx(struct net_device *
 	struct netdev_private *np = dev->priv;
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
-	while (!(np->cur_rx->status & RXOWN)) {
+	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
 		s32 rx_status = np->cur_rx->status;
 
 		if (np->really_rx_count == 0)
@@ -1628,8 +1619,15 @@ static int netdev_rx(struct net_device *
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
@@ -1679,8 +1677,6 @@ static int netdev_rx(struct net_device *
 						 PCI_DMA_FROMDEVICE);
 				skb_put(skb = np->cur_rx->skbuff, pkt_len);
 				np->cur_rx->skbuff = NULL;
-				if (np->really_rx_count == RX_RING_SIZE)
-					np->lack_rxbuf = np->cur_rx;
 				--np->really_rx_count;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1689,25 +1685,7 @@ static int netdev_rx(struct net_device *
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
