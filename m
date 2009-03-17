From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 15/30] solos: Tidy up DMA handling a little. Still untested
Date: Tue, 17 Mar 2009 21:29:27 +0000
Message-ID: <1237325367.27681.344.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37663 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757763AbZCQV3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:33 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqo-0001vS-On
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:31 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   95 ++++++++++++++++++++++++++---------------------
 1 files changed, 53 insertions(+), 42 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 63c9ad0..acba08d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -68,6 +68,8 @@
 #define RX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2)
 #define TX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2 + BUF_SIZE)
 
+#define RX_DMA_SIZE	2048
+
 static int debug = 0;
 static int atmdebug = 0;
 static int firmware_upgrade = 0;
@@ -608,17 +610,11 @@ void solos_bh(unsigned long card_arg)
 
 			if (card->using_dma) {
 				skb = card->rx_skb[port];
-				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr, skb->len,
-						 PCI_DMA_FROMDEVICE);
-
-				card->rx_skb[port] = alloc_skb(2048, GFP_ATOMIC);
-				if (card->rx_skb[port]) {
-					SKB_CB(card->rx_skb[port])->dma_addr =
-						pci_map_single(card->dev, skb->data, skb->len,
-							       PCI_DMA_FROMDEVICE);
-					iowrite32(SKB_CB(card->rx_skb[port])->dma_addr,
-						  card->config_regs + RX_DMA_ADDR(port));
-				}
+				card->rx_skb[port] = NULL;
+
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+
 				header = (void *)skb->data;
 				size = le16_to_cpu(header->size);
 				skb_put(skb, size + sizeof(*header));
@@ -669,7 +665,7 @@ void solos_bh(unsigned long card_arg)
 
 			case PKT_STATUS:
 				process_status(card, port, skb);
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 				break;
 
 			case PKT_COMMAND:
@@ -681,12 +677,32 @@ void solos_bh(unsigned long card_arg)
 					if (net_ratelimit())
 						dev_warn(&card->dev->dev, "Dropping console response on port %d\n",
 							 port);
+					dev_kfree_skb_any(skb);
 				} else
 					skb_queue_tail(&card->cli_queue[port], skb);
 				spin_unlock(&card->cli_queue_lock);
 				break;
 			}
 		}
+		/* Allocate RX skbs for any ports which need them */
+		if (card->using_dma && card->atmdev[port] &&
+		    !card->rx_skb[port]) {
+			struct sk_buff *skb = alloc_skb(RX_DMA_SIZE, GFP_ATOMIC);
+			if (skb) {
+				SKB_CB(skb)->dma_addr =
+					pci_map_single(card->dev, skb->data,
+						       RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				iowrite32(SKB_CB(skb)->dma_addr,
+					  card->config_regs + RX_DMA_ADDR(port));
+				card->rx_skb[port] = skb;
+			} else {
+				if (net_ratelimit())
+					dev_warn(&card->dev->dev, "Failed to allocate RX skb");
+
+				/* We'll have to try again later */
+				tasklet_schedule(&card->tlet);
+			}
+		}
 	}
 	if (rx_done)
 		iowrite32(rx_done, card->config_regs + FLAGS_ADDR);
@@ -901,50 +917,45 @@ static int fpga_tx(struct solos_card *card)
 
 	for (port = 0; port < card->nr_ports; port++) {
 		if (card->atmdev[port] && !(tx_pending & (1 << port))) {
+			struct sk_buff *oldskb = card->tx_skb[port];
 
+			if (oldskb)
+				pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
+						 oldskb->len, PCI_DMA_TODEVICE);
+			
 			spin_lock(&card->tx_queue_lock);
 			skb = skb_dequeue(&card->tx_queue[port]);
 			spin_unlock(&card->tx_queue_lock);
 
-			if (!skb)
+			if (skb && !card->using_dma) {
+				memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
+				tx_started |= 1 << port; //Set TX full flag
+				oldskb = skb; /* We're done with this skb already */
+			} else if (skb && card->using_dma) {
+				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
+								       skb->len, PCI_DMA_TODEVICE);
+				iowrite32(SKB_CB(skb)->dma_addr,
+					  card->config_regs + TX_DMA_ADDR(port));
+			}
+
+			if (!oldskb)
 				continue;
 
+			/* Clean up and free oldskb now it's gone */
 			if (atmdebug) {
 				dev_info(&card->dev->dev, "Transmitted: port %d\n",
 					 port);
-				print_buffer(skb);
+				print_buffer(oldskb);
 			}
-			if (card->using_dma) {
-				if (card->tx_skb[port]) {
-					struct sk_buff *oldskb = card->tx_skb[port];
-
-					pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
-							 oldskb->len, PCI_DMA_TODEVICE);
-
-					vcc = SKB_CB(oldskb)->vcc;
-
-					if (vcc) {
-						atomic_inc(&vcc->stats->tx);
-						solos_pop(vcc, oldskb);
-					} else
-						dev_kfree_skb_irq(oldskb);
-				}
 
-				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
-							       skb->len, PCI_DMA_TODEVICE);
-				iowrite32(SKB_CB(skb)->dma_addr, card->config_regs + TX_DMA_ADDR(port));
-			} else {
-				memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
-				tx_started |= 1 << port; //Set TX full flag
+			vcc = SKB_CB(oldskb)->vcc;
 
-				vcc = SKB_CB(skb)->vcc;
+			if (vcc) {
+				atomic_inc(&vcc->stats->tx);
+				solos_pop(vcc, oldskb);
+			} else
+				dev_kfree_skb_irq(oldskb);
 
-				if (vcc) {
-					atomic_inc(&vcc->stats->tx);
-					solos_pop(vcc, skb);
-				} else
-					dev_kfree_skb_irq(skb);
-			}
 		}
 	}
 	if (tx_started)
-- 
1.6.0.6


