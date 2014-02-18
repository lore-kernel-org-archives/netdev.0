From: Don Fry <pcnet32@frontier.com>
Subject: [PATCH net-next 2/2] pcnet32: add missing check for
 pci_dma_mapping_error
Date: Mon, 17 Feb 2014 20:57:59 -0800
Message-ID: <1392699479.4020.28.camel@Linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter01.roch.ny.frontiernet.net ([66.133.183.226]:56078 "EHLO
	filter01.roch.ny.frontiernet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbaBRFG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 00:06:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pci_map_single calls never checked for error. Add error checking
as requested by someone last year.  Tested on 79c972.

Signed-off-by: Don Fry <pcnet32@frontier.com>
---
 drivers/net/ethernet/amd/pcnet32.c |  108 +++++++++++++++++++++++++++---------
 1 files changed, 81 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 25cd04a..2ae00ed 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -565,8 +565,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	if (!new_dma_addr_list)
 		goto free_new_rx_ring;
 
-	new_skb_list = kcalloc(entries, sizeof(struct sk_buff *),
-			       GFP_ATOMIC);
+	new_skb_list = kcalloc(entries, sizeof(struct sk_buff *), GFP_ATOMIC);
 	if (!new_skb_list)
 		goto free_new_lists;
 
@@ -593,6 +592,13 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 		new_dma_addr_list[new] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
 					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(lp->pci_dev,
+					  new_dma_addr_list[new])) {
+			netif_err(lp, drv, dev, "%s dma mapping failed\n",
+				  __func__);
+			dev_kfree_skb(new_skb_list[new]);
+			goto free_all_new;
+		}
 		new_rx_ring[new].base = cpu_to_le32(new_dma_addr_list[new]);
 		new_rx_ring[new].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		new_rx_ring[new].status = cpu_to_le16(0x8000);
@@ -600,8 +606,12 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	/* and free any unneeded buffers */
 	for (; new < lp->rx_ring_size; new++) {
 		if (lp->rx_skbuff[new]) {
-			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[new],
-					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (!pci_dma_mapping_error(lp->pci_dev,
+						   lp->rx_dma_addr[new]))
+				pci_unmap_single(lp->pci_dev,
+						 lp->rx_dma_addr[new],
+						 PKT_BUF_SIZE,
+						 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(lp->rx_skbuff[new]);
 		}
 	}
@@ -625,8 +635,12 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 free_all_new:
 	while (--new >= lp->rx_ring_size) {
 		if (new_skb_list[new]) {
-			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
-					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (!pci_dma_mapping_error(lp->pci_dev,
+						   new_dma_addr_list[new]))
+				pci_unmap_single(lp->pci_dev,
+						 new_dma_addr_list[new],
+						 PKT_BUF_SIZE,
+						 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(new_skb_list[new]);
 		}
 	}
@@ -650,8 +664,12 @@ static void pcnet32_purge_rx_ring(struct net_device *dev)
 		lp->rx_ring[i].status = 0;	/* CPU owns buffer */
 		wmb();		/* Make sure adapter sees owner change */
 		if (lp->rx_skbuff[i]) {
-			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
-					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (!pci_dma_mapping_error(lp->pci_dev,
+						   lp->rx_dma_addr[i]))
+				pci_unmap_single(lp->pci_dev,
+						 lp->rx_dma_addr[i],
+						 PKT_BUF_SIZE,
+						 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(lp->rx_skbuff[i]);
 		}
 		lp->rx_skbuff[i] = NULL;
@@ -930,6 +948,12 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 		lp->tx_dma_addr[x] =
 			pci_map_single(lp->pci_dev, skb->data, skb->len,
 				       PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(lp->pci_dev, lp->tx_dma_addr[x])) {
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "DMA mapping error at line: %d!\n",
+				     __LINE__);
+			goto clean_up;
+		}
 		lp->tx_ring[x].base = cpu_to_le32(lp->tx_dma_addr[x]);
 		wmb();	/* Make sure owner changes after all others are visible */
 		lp->tx_ring[x].status = cpu_to_le16(status);
@@ -1142,24 +1166,36 @@ static void pcnet32_rx_entry(struct net_device *dev,
 
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
+		dma_addr_t new_dma_addr;
 
 		newskb = netdev_alloc_skb(dev, PKT_BUF_SKB);
+		/*
+		 * map the new buffer, if mapping fails, drop the packet and
+		 * reuse the old buffer
+		 */
 		if (newskb) {
 			skb_reserve(newskb, NET_IP_ALIGN);
-			skb = lp->rx_skbuff[entry];
-			pci_unmap_single(lp->pci_dev,
-					 lp->rx_dma_addr[entry],
-					 PKT_BUF_SIZE,
-					 PCI_DMA_FROMDEVICE);
-			skb_put(skb, pkt_len);
-			lp->rx_skbuff[entry] = newskb;
-			lp->rx_dma_addr[entry] =
-					    pci_map_single(lp->pci_dev,
-							   newskb->data,
-							   PKT_BUF_SIZE,
-							   PCI_DMA_FROMDEVICE);
-			rxp->base = cpu_to_le32(lp->rx_dma_addr[entry]);
-			rx_in_place = 1;
+			new_dma_addr = pci_map_single(lp->pci_dev,
+						      newskb->data,
+						      PKT_BUF_SIZE,
+						      PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(lp->pci_dev, new_dma_addr)) {
+				netif_err(lp, rx_err, dev,
+					  "DMA mapping error.\n");
+				dev_kfree_skb(newskb);
+				skb = NULL;
+			} else {
+				skb = lp->rx_skbuff[entry];
+				pci_unmap_single(lp->pci_dev,
+						 lp->rx_dma_addr[entry],
+						 PKT_BUF_SIZE,
+						 PCI_DMA_FROMDEVICE);
+				skb_put(skb, pkt_len);
+				lp->rx_skbuff[entry] = newskb;
+				lp->rx_dma_addr[entry] = new_dma_addr;
+				rxp->base = cpu_to_le32(new_dma_addr);
+				rx_in_place = 1;
+			}
 		} else
 			skb = NULL;
 	} else
@@ -2229,9 +2265,12 @@ static void pcnet32_purge_tx_ring(struct net_device *dev)
 		lp->tx_ring[i].status = 0;	/* CPU owns buffer */
 		wmb();		/* Make sure adapter sees owner change */
 		if (lp->tx_skbuff[i]) {
-			pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
-					 lp->tx_skbuff[i]->len,
-					 PCI_DMA_TODEVICE);
+			if (!pci_dma_mapping_error(lp->pci_dev,
+						   lp->tx_dma_addr[i]))
+				pci_unmap_single(lp->pci_dev,
+						 lp->tx_dma_addr[i],
+						 lp->tx_skbuff[i]->len,
+						 PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(lp->tx_skbuff[i]);
 		}
 		lp->tx_skbuff[i] = NULL;
@@ -2264,10 +2303,19 @@ static int pcnet32_init_ring(struct net_device *dev)
 		}
 
 		rmb();
-		if (lp->rx_dma_addr[i] == 0)
+		if (lp->rx_dma_addr[i] == 0) {
 			lp->rx_dma_addr[i] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
 					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(lp->pci_dev,
+						  lp->rx_dma_addr[i])) {
+				/* there is not much we can do at this point */
+				netif_err(lp, drv, dev,
+					  "%s pci dma mapping error\n",
+					  __func__);
+				return -1;
+			}
+		}
 		lp->rx_ring[i].base = cpu_to_le32(lp->rx_dma_addr[i]);
 		lp->rx_ring[i].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		wmb();		/* Make sure owner changes after all others are visible */
@@ -2397,9 +2445,14 @@ static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
 
 	lp->tx_ring[entry].misc = 0x00000000;
 
-	lp->tx_skbuff[entry] = skb;
 	lp->tx_dma_addr[entry] =
 	    pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(lp->pci_dev, lp->tx_dma_addr[entry])) {
+		dev_kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		goto drop_packet;
+	}
+	lp->tx_skbuff[entry] = skb;
 	lp->tx_ring[entry].base = cpu_to_le32(lp->tx_dma_addr[entry]);
 	wmb();			/* Make sure owner changes after all others are visible */
 	lp->tx_ring[entry].status = cpu_to_le16(status);
@@ -2414,6 +2467,7 @@ static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
 		lp->tx_full = 1;
 		netif_stop_queue(dev);
 	}
+drop_packet:
 	spin_unlock_irqrestore(&lp->lock, flags);
 	return NETDEV_TX_OK;
 }
-- 
1.7.2.3
