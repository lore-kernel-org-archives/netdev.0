From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses (with [PATCH])
Date: Thu, 1 Apr 2004 00:23:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401002325.A9022@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403311839.33202.vda@port.imtp.ilyichevsk.odessa.ua> <20040331192421.GA30048@scream.fjortis.info> <200403312238.46835.vda@port.imtp.ilyichevsk.odessa.ua> <406B2FB5.9080302@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Cc: netdev@oss.sgi.com, Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Andreas Henriksson <andreas@fjortis.info>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <406B2FB5.9080302@pobox.com>; from jgarzik@pobox.com on Wed, Mar 31, 2004 at 03:53:09PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff Garzik <jgarzik@pobox.com> :
> FYI to those involved, I sent the TX patch upstream.
> 
> When there is a minimal RX patch people are happy with, let me know... 
> further changes are fine, but I would like to split up the changes as 
> much as is reasonable.

Attached is the patch tested by Andreas which fixes single allocation
failures but will not protect against excessive work in irq handler nor
complete depletion of the Rx ring.

It applies on top of the Tx patch (as seen on bk-commit).

Earth-shattering, anyone ?

--
Ueimor

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fealnx-allocation-failure.patch"


Handle allocation failure with grace:
- defer instant allocation in netdev_rx() until the packet examination
  loop is finished. This removes code duplication between netdev_rx()
  and allocate_rx_buffers();
- protect netdev_rx() against wrap-around if it ends on an unallocated
  descriptor;
- always proceed to the next Rx descriptor in netdev_rx() so as to stay in
  sync with the chipset;
- positionning of the first dirty/unallocated Rx descriptor is of the sole
  responsibility of allocate_rx_buffers();
- unconditionnaly give the allocated descriptors to the chipset during
  reset_rx_descriptors().


 drivers/net/fealnx.c |   69 ++++++++++++++++-----------------------------------
 1 files changed, 22 insertions(+), 47 deletions(-)

diff -puN drivers/net/fealnx.c~fealnx-allocation-failure drivers/net/fealnx.c
--- linux-2.6.5-rc2/drivers/net/fealnx.c~fealnx-allocation-failure	2004-03-31 23:31:23.000000000 +0200
+++ linux-2.6.5-rc2-fr/drivers/net/fealnx.c	2004-03-31 23:50:36.000000000 +0200
@@ -1134,15 +1134,18 @@ static void allocate_rx_buffers(struct n
 		struct sk_buff *skb;
 
 		skb = dev_alloc_skb(np->rx_buf_sz);
-		np->lack_rxbuf->skbuff = skb;
 
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
@@ -1250,8 +1253,7 @@ static void init_ring(struct net_device 
 
 	/* initialize rx variables */
 	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
-	np->cur_rx = &np->rx_ring[0];
-	np->lack_rxbuf = NULL;
+	np->lack_rxbuf = np->cur_rx = np->rx_ring;
 	np->really_rx_count = 0;
 
 	/* initial rx descriptors. */
@@ -1303,8 +1305,6 @@ static void init_ring(struct net_device 
 	/* for the last tx descriptor */
 	np->tx_ring[i - 1].next_desc = np->tx_ring_dma;
 	np->tx_ring[i - 1].next_desc_logical = &np->tx_ring[0];
-
-	return;
 }
 
 
@@ -1381,32 +1381,22 @@ static int start_tx(struct sk_buff *skb,
 }
 
 
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
@@ -1580,7 +1570,7 @@ static int netdev_rx(struct net_device *
 	struct netdev_private *np = dev->priv;
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
-	while (!(np->cur_rx->status & RXOWN)) {
+	while (!(np->cur_rx->status & RXOWN) &&  np->cur_rx->skbuff) {
 		s32 rx_status = np->cur_rx->status;
 
 		if (np->really_rx_count == 0)
@@ -1632,8 +1622,12 @@ static int netdev_rx(struct net_device *
 					np->stats.rx_length_errors++;
 
 					/* free all rx descriptors related this long pkt */
-					for (i = 0; i < desno; ++i)
-						free_one_rx_descriptor(np);
+					for (i = 0; i < desno; i++) {
+						if (!np->cur_rx->skbuff)
+							break;
+						np->cur_rx->status = RXOWN;
+						np->cur_rx = np->cur_rx->next_desc_logical;
+					}
 					continue;
 				} else {	/* something error, need to reset this chip */
 					reset_rx_descriptors(dev);
@@ -1683,8 +1677,6 @@ static int netdev_rx(struct net_device *
 						 PCI_DMA_FROMDEVICE);
 				skb_put(skb = np->cur_rx->skbuff, pkt_len);
 				np->cur_rx->skbuff = NULL;
-				if (np->really_rx_count == RX_RING_SIZE)
-					np->lack_rxbuf = np->cur_rx;
 				--np->really_rx_count;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1694,24 +1686,7 @@ static int netdev_rx(struct net_device *
 			np->stats.rx_bytes += pkt_len;
 		}
 
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

_

--IJpNTDwzlM2Ie8A6--
