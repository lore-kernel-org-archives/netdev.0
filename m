From: Stephen Hemminger <shemminger@vyatta.com>
Subject: PATCH] Revert "skge: check for PCI dma mapping errors"
Date: Mon, 6 Feb 2012 17:04:23 -0800
Message-ID: <20120206170423.77492bb5@nehalam.linuxnetplumber.net>
References: <1327662357.4461.5.camel@penelope>
	<20120127091831.49ba7e68@nehalam.linuxnetplumber.net>
	<1327688328.8784.2.camel@penelope>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alban Browaeys <prahal@yahoo.com>, netdev@vger.kernel.org,
	Guillaume Chazarain <guichaz@gmail.com>,
	Nick Bowler <nbowler@elliptictech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59661 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756226Ab2BGBE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 20:04:26 -0500
In-Reply-To: <1327688328.8784.2.camel@penelope>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by several people...

The code in rx_clean was panic'ing so revert 
commit d0249e44432aa0ffcf710b64449b8eaa3722547e.
Will redo DMA mapping checks as new patches for a later release.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/marvell/skge.c |   71 ++++++----------------------------
 1 files changed, 13 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index edb9bda..33947ac 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -931,20 +931,17 @@ static int skge_ring_alloc(struct skge_ring *ring, void *vaddr, u32 base)
 }
 
 /* Allocate and setup a new buffer for receiving */
-static int skge_rx_setup(struct pci_dev *pdev,
-			 struct skge_element *e,
-			 struct sk_buff *skb, unsigned int bufsize)
+static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
+			  struct sk_buff *skb, unsigned int bufsize)
 {
 	struct skge_rx_desc *rd = e->desc;
-	dma_addr_t map;
+	u64 map;
 
-	map = pci_map_single(pdev, skb->data, bufsize,
+	map = pci_map_single(skge->hw->pdev, skb->data, bufsize,
 			     PCI_DMA_FROMDEVICE);
-	if (pci_dma_mapping_error(pdev, map))
-		goto mapping_error;
 
-	rd->dma_lo = lower_32_bits(map);
-	rd->dma_hi = upper_32_bits(map);
+	rd->dma_lo = map;
+	rd->dma_hi = map >> 32;
 	e->skb = skb;
 	rd->csum1_start = ETH_HLEN;
 	rd->csum2_start = ETH_HLEN;
@@ -956,13 +953,6 @@ static int skge_rx_setup(struct pci_dev *pdev,
 	rd->control = BMU_OWN | BMU_STF | BMU_IRQ_EOF | BMU_TCP_CHECK | bufsize;
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, bufsize);
-	return 0;
-
-mapping_error:
-	if (net_ratelimit())
-		dev_warn(&pdev->dev, "%s: rx mapping error\n",
-			 skb->dev->name);
-	return -EIO;
 }
 
 /* Resume receiving using existing skb,
@@ -1024,11 +1014,7 @@ static int skge_rx_fill(struct net_device *dev)
 			return -ENOMEM;
 
 		skb_reserve(skb, NET_IP_ALIGN);
-		if (skge_rx_setup(skge->hw->pdev, e, skb, skge->rx_buf_size)) {
-			kfree_skb(skb);
-			return -ENOMEM;
-		}
-
+		skge_rx_setup(skge, e, skb, skge->rx_buf_size);
 	} while ((e = e->next) != ring->start);
 
 	ring->to_clean = ring->start;
@@ -2743,7 +2729,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 	struct skge_tx_desc *td;
 	int i;
 	u32 control, len;
-	dma_addr_t map;
+	u64 map;
 
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
@@ -2757,14 +2743,11 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 	e->skb = skb;
 	len = skb_headlen(skb);
 	map = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(hw->pdev, map))
-		goto mapping_error;
-
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, len);
 
-	td->dma_lo = lower_32_bits(map);
-	td->dma_hi = upper_32_bits(map);
+	td->dma_lo = map;
+	td->dma_hi = map >> 32;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const int offset = skb_checksum_start_offset(skb);
@@ -2795,16 +2778,14 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 
 			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
 					       skb_frag_size(frag), DMA_TO_DEVICE);
-			if (dma_mapping_error(&hw->pdev->dev, map))
-				goto mapping_unwind;
 
 			e = e->next;
 			e->skb = skb;
 			tf = e->desc;
 			BUG_ON(tf->control & BMU_OWN);
 
-			tf->dma_lo = lower_32_bits(map);
-			tf->dma_hi = upper_32_bits(map);
+			tf->dma_lo = map;
+			tf->dma_hi = (u64) map >> 32;
 			dma_unmap_addr_set(e, mapaddr, map);
 			dma_unmap_len_set(e, maplen, skb_frag_size(frag));
 
@@ -2834,28 +2815,6 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 	}
 
 	return NETDEV_TX_OK;
-
-mapping_unwind:
-	/* unroll any pages that were already mapped.  */
-	if (e != skge->tx_ring.to_use) {
-		struct skge_element *u;
-
-		for (u = skge->tx_ring.to_use->next; u != e; u = u->next)
-			pci_unmap_page(hw->pdev, dma_unmap_addr(u, mapaddr),
-				       dma_unmap_len(u, maplen),
-				       PCI_DMA_TODEVICE);
-		e = skge->tx_ring.to_use;
-	}
-	/* undo the mapping for the skb header */
-	pci_unmap_single(hw->pdev, dma_unmap_addr(e, mapaddr),
-			 dma_unmap_len(e, maplen),
-			 PCI_DMA_TODEVICE);
-mapping_error:
-	/* mapping error causes error message and packet to be discarded. */
-	if (net_ratelimit())
-		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
-	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
 }
 
 
@@ -3099,17 +3058,13 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 		if (!nskb)
 			goto resubmit;
 
-		if (unlikely(skge_rx_setup(skge->hw->pdev, e, nskb, skge->rx_buf_size))) {
-			dev_kfree_skb(nskb);
-			goto resubmit;
-		}
-
 		pci_unmap_single(skge->hw->pdev,
 				 dma_unmap_addr(e, mapaddr),
 				 dma_unmap_len(e, maplen),
 				 PCI_DMA_FROMDEVICE);
 		skb = e->skb;
 		prefetch(skb->data);
+		skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
 	}
 
 	skb_put(skb, len);
-- 
1.7.8.3
