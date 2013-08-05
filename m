From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] skge: add dma_mapping check
Date: Sun, 4 Aug 2013 17:22:34 -0700
Message-ID: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:39303 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab3HEAWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 20:22:39 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so2647624pbb.20
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 17:22:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This old driver never checked for DMA mapping errors.
Causing splats with the new DMA mapping checks:
	WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
	skge 0000:01:09.0: DMA-API: device driver failed to check map

Add checks and unwind code.

Reported-by: poma <pomidorabelisima@gmail.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/marvell/skge.c	2013-08-04 11:03:20.842978549 -0700
+++ b/drivers/net/ethernet/marvell/skge.c	2013-08-04 17:08:19.256002544 -0700
@@ -931,15 +931,18 @@ static int skge_ring_alloc(struct skge_r
 }
 
 /* Allocate and setup a new buffer for receiving */
-static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
+static int skge_rx_setup(struct skge_port *skge, struct skge_element *e,
 			  struct sk_buff *skb, unsigned int bufsize)
 {
 	struct skge_rx_desc *rd = e->desc;
-	u64 map;
+	dma_addr_t map;
 
 	map = pci_map_single(skge->hw->pdev, skb->data, bufsize,
 			     PCI_DMA_FROMDEVICE);
 
+	if (pci_dma_mapping_error(skge->hw->pdev, map))
+		return -1;
+
 	rd->dma_lo = map;
 	rd->dma_hi = map >> 32;
 	e->skb = skb;
@@ -953,6 +956,7 @@ static void skge_rx_setup(struct skge_po
 	rd->control = BMU_OWN | BMU_STF | BMU_IRQ_EOF | BMU_TCP_CHECK | bufsize;
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, bufsize);
+	return 0;
 }
 
 /* Resume receiving using existing skb,
@@ -1014,7 +1018,10 @@ static int skge_rx_fill(struct net_devic
 			return -ENOMEM;
 
 		skb_reserve(skb, NET_IP_ALIGN);
-		skge_rx_setup(skge, e, skb, skge->rx_buf_size);
+		if (skge_rx_setup(skge, e, skb, skge->rx_buf_size) < 0) {
+			dev_kfree_skb(skb);
+			return -EIO;
+		}
 	} while ((e = e->next) != ring->start);
 
 	ring->to_clean = ring->start;
@@ -2729,7 +2736,7 @@ static netdev_tx_t skge_xmit_frame(struc
 	struct skge_tx_desc *td;
 	int i;
 	u32 control, len;
-	u64 map;
+	dma_addr_t map;
 
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
@@ -2743,6 +2750,9 @@ static netdev_tx_t skge_xmit_frame(struc
 	e->skb = skb;
 	len = skb_headlen(skb);
 	map = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(hw->pdev, map))
+		goto mapping_error;
+
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, len);
 
@@ -2778,6 +2788,8 @@ static netdev_tx_t skge_xmit_frame(struc
 
 			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
 					       skb_frag_size(frag), DMA_TO_DEVICE);
+			if (dma_mapping_error(&hw->pdev->dev, map))
+				goto mapping_unwind;
 
 			e = e->next;
 			e->skb = skb;
@@ -2815,6 +2827,26 @@ static netdev_tx_t skge_xmit_frame(struc
 	}
 
 	return NETDEV_TX_OK;
+
+mapping_unwind:
+	e = skge->tx_ring.to_use;
+	pci_unmap_single(hw->pdev,
+			 dma_unmap_addr(e, mapaddr),
+			 dma_unmap_len(e, maplen),
+			 PCI_DMA_TODEVICE);
+	while (i-- > 0) {
+		e = e->next;
+		pci_unmap_page(hw->pdev,
+			       dma_unmap_addr(e, mapaddr),
+			       dma_unmap_len(e, maplen),
+			       PCI_DMA_TODEVICE);
+	}
+
+mapping_error:
+	if (net_ratelimit())
+		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 
@@ -3058,13 +3090,17 @@ static struct sk_buff *skge_rx_get(struc
 		if (!nskb)
 			goto resubmit;
 
+		if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
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
