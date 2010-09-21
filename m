From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next 2/3] sundance: Handle DMA mapping errors
Date: Tue, 21 Sep 2010 08:56:57 +0000
Message-ID: <20100921085657.GA20108@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:47078 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756478Ab0IUI46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 04:56:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for DMA mapping errors.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index ac32650..38d6ab2 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1018,6 +1018,12 @@ static void init_ring(struct net_device *dev)
 		np->rx_ring[i].frag[0].addr = cpu_to_le32(
 			dma_map_single(&np->pci_dev->dev, skb->data,
 				np->rx_buf_sz, DMA_FROM_DEVICE));
+		if (dma_mapping_error(&np->pci_dev->dev,
+					np->rx_ring[i].frag[0].addr)) {
+			dev_kfree_skb(skb);
+			np->rx_skbuff[i] = NULL;
+			break;
+		}
 		np->rx_ring[i].frag[0].length = cpu_to_le32(np->rx_buf_sz | LastFrag);
 	}
 	np->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
@@ -1070,6 +1076,9 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 	txdesc->status = cpu_to_le32 ((entry << 2) | DisableAlign);
 	txdesc->frag[0].addr = cpu_to_le32(dma_map_single(&np->pci_dev->dev,
 				skb->data, skb->len, DMA_TO_DEVICE));
+	if (dma_mapping_error(&np->pci_dev->dev,
+				txdesc->frag[0].addr))
+			goto drop_frame;
 	txdesc->frag[0].length = cpu_to_le32 (skb->len | LastFrag);
 
 	/* Increment cur_tx before tasklet_schedule() */
@@ -1091,6 +1100,12 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 			dev->name, np->cur_tx, entry);
 	}
 	return NETDEV_TX_OK;
+
+drop_frame:
+	dev_kfree_skb(skb);
+	np->tx_skbuff[entry] = NULL;
+	dev->stats.tx_dropped++;
+	return NETDEV_TX_OK;
 }
 
 /* Reset hardware tx and free all of tx buffers */
@@ -1398,6 +1413,12 @@ static void refill_rx (struct net_device *dev)
 			np->rx_ring[entry].frag[0].addr = cpu_to_le32(
 				dma_map_single(&np->pci_dev->dev, skb->data,
 					np->rx_buf_sz, DMA_FROM_DEVICE));
+			if (dma_mapping_error(&np->pci_dev->dev,
+				    np->rx_ring[entry].frag[0].addr)) {
+			    dev_kfree_skb_irq(skb);
+			    np->rx_skbuff[entry] = NULL;
+			    break;
+			}
 		}
 		/* Perhaps we need not reset this field. */
 		np->rx_ring[entry].frag[0].length =
-- 
1.7.2.2

