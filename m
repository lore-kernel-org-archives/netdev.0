From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] skge: check for PCI dma mapping errors
Date: Thu, 19 Jan 2012 16:37:18 -0800
Message-ID: <20120119163718.35bedfcc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49252 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978Ab2ATApW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 19:45:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should check for mapping errors.
Machines with limited DMA maps may return an error when a PCI map is
requested (not an issue on standard x86). 

Also use upper/lower 32 bits macros for clarity.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/skge.c	2012-01-19 15:34:07.522680153 -0800
+++ b/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:12:19.267767503 -0800
@@ -931,17 +931,20 @@ static int skge_ring_alloc(struct skge_r
 }
 
 /* Allocate and setup a new buffer for receiving */
-static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
-			  struct sk_buff *skb, unsigned int bufsize)
+static int skge_rx_setup(struct pci_dev *pdev,
+			 struct skge_element *e,
+			 struct sk_buff *skb, unsigned int bufsize)
 {
 	struct skge_rx_desc *rd = e->desc;
-	u64 map;
+	dma_addr_t map;
 
-	map = pci_map_single(skge->hw->pdev, skb->data, bufsize,
+	map = pci_map_single(pdev, skb->data, bufsize,
 			     PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(pdev, map))
+		goto mapping_error;
 
-	rd->dma_lo = map;
-	rd->dma_hi = map >> 32;
+	rd->dma_lo = lower_32_bits(map);
+	rd->dma_hi = upper_32_bits(map);
 	e->skb = skb;
 	rd->csum1_start = ETH_HLEN;
 	rd->csum2_start = ETH_HLEN;
@@ -953,6 +956,13 @@ static void skge_rx_setup(struct skge_po
 	rd->control = BMU_OWN | BMU_STF | BMU_IRQ_EOF | BMU_TCP_CHECK | bufsize;
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, bufsize);
+	return 0;
+
+mapping_error:
+	if (net_ratelimit())
+		dev_warn(&pdev->dev, "%s: rx mapping error\n",
+			 skb->dev->name);
+	return -EIO;
 }
 
 /* Resume receiving using existing skb,
@@ -1014,7 +1024,11 @@ static int skge_rx_fill(struct net_devic
 			return -ENOMEM;
 
 		skb_reserve(skb, NET_IP_ALIGN);
-		skge_rx_setup(skge, e, skb, skge->rx_buf_size);
+		if (skge_rx_setup(skge->hw->pdev, e, skb, skge->rx_buf_size)) {
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+
 	} while ((e = e->next) != ring->start);
 
 	ring->to_clean = ring->start;
@@ -2729,7 +2743,7 @@ static netdev_tx_t skge_xmit_frame(struc
 	struct skge_tx_desc *td;
 	int i;
 	u32 control, len;
-	u64 map;
+	dma_addr_t map;
 
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
@@ -2743,11 +2757,14 @@ static netdev_tx_t skge_xmit_frame(struc
 	e->skb = skb;
 	len = skb_headlen(skb);
 	map = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(hw->pdev, map))
+		goto mapping_error;
+
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, len);
 
-	td->dma_lo = map;
-	td->dma_hi = map >> 32;
+	td->dma_lo = lower_32_bits(map);
+	td->dma_hi = upper_32_bits(map);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const int offset = skb_checksum_start_offset(skb);
@@ -2778,14 +2795,16 @@ static netdev_tx_t skge_xmit_frame(struc
 
 			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
 					       skb_frag_size(frag), DMA_TO_DEVICE);
+			if (dma_mapping_error(&hw->pdev->dev, map))
+				goto mapping_unwind;
 
 			e = e->next;
 			e->skb = skb;
 			tf = e->desc;
 			BUG_ON(tf->control & BMU_OWN);
 
-			tf->dma_lo = map;
-			tf->dma_hi = (u64) map >> 32;
+			tf->dma_lo = lower_32_bits(map);
+			tf->dma_hi = upper_32_bits(map);
 			dma_unmap_addr_set(e, mapaddr, map);
 			dma_unmap_len_set(e, maplen, skb_frag_size(frag));
 
@@ -2813,6 +2832,28 @@ static netdev_tx_t skge_xmit_frame(struc
 	}
 
 	return NETDEV_TX_OK;
+
+mapping_unwind:
+	/* unroll any pages that were already mapped.  */
+	if (e != skge->tx_ring.to_use) {
+		struct skge_element *u;
+
+		for (u = skge->tx_ring.to_use->next; u != e; u = u->next)
+			pci_unmap_page(hw->pdev, dma_unmap_addr(u, mapaddr),
+				       dma_unmap_len(u, maplen),
+				       PCI_DMA_TODEVICE);
+		e = skge->tx_ring.to_use;
+	}
+	/* undo the mapping for the skb header */
+	pci_unmap_single(hw->pdev, dma_unmap_addr(e, mapaddr),
+			 dma_unmap_len(e, maplen),
+			 PCI_DMA_TODEVICE);
+mapping_error:
+	/* mapping error causes error message and packet to be discarded. */
+	if (net_ratelimit())
+		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 
@@ -3060,13 +3101,17 @@ static struct sk_buff *skge_rx_get(struc
 		if (!nskb)
 			goto resubmit;
 
+		if (unlikely(skge_rx_setup(skge->hw->pdev, e, nskb, skge->rx_buf_size))) {
+			dev_kfree_skb(nskb);
+			goto resubmit;
+		}
+
 		pci_unmap_single(skge->hw->pdev,
 				 dma_unmap_addr(e, mapaddr),
 				 dma_unmap_len(e, maplen),
 				 PCI_DMA_FROMDEVICE);
 		skb = e->skb;
 		prefetch(skb->data);
-		skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
 	}
 
 	skb_put(skb, len);
