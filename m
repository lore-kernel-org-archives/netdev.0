From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] sky2: handle dma mapping errors
Date: Tue, 03 Feb 2009 13:27:28 -0800
Message-ID: <20090203212756.025692980@vyatta.com>
References: <20090203212726.983207890@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:48590 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbZBCV3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 16:29:25 -0500
Content-Disposition: inline; filename=sky2-dma-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On non-x86 platforms it is possible to run out of DMA mapping resources.
The driver was ignoring this and could cause corruptions.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/sky2.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 56 insertions(+), 8 deletions(-)

--- a/drivers/net/sky2.c	2009-02-03 08:08:14.287767868 -0800
+++ b/drivers/net/sky2.c	2009-02-03 08:08:38.063805252 -0800
@@ -1068,13 +1068,16 @@ static void sky2_rx_submit(struct sky2_p
 }
 
 
-static void sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
+static int sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 			    unsigned size)
 {
 	struct sk_buff *skb = re->skb;
 	int i;
 
 	re->data_addr = pci_map_single(pdev, skb->data, size, PCI_DMA_FROMDEVICE);
+	if (unlikely(pci_dma_mapping_error(pdev, re->data_addr)))
+		return -EIO;
+
 	pci_unmap_len_set(re, data_size, size);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
@@ -1083,6 +1086,7 @@ static void sky2_rx_map_skb(struct pci_d
 						skb_shinfo(skb)->frags[i].page_offset,
 						skb_shinfo(skb)->frags[i].size,
 						PCI_DMA_FROMDEVICE);
+	return 0;
 }
 
 static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
@@ -1354,7 +1358,12 @@ static int sky2_rx_start(struct sky2_por
 		if (!re->skb)
 			goto nomem;
 
-		sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size);
+		if (sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size)) {
+			dev_kfree_skb(re->skb);
+			re->skb = NULL;
+			goto nomem;
+		}
+
 		sky2_rx_submit(sky2, re);
 	}
 
@@ -1547,7 +1556,7 @@ static int sky2_xmit_frame(struct sk_buf
 	struct sky2_hw *hw = sky2->hw;
 	struct sky2_tx_le *le = NULL;
 	struct tx_ring_info *re;
-	unsigned i, len;
+	unsigned i, len, first_slot;
 	dma_addr_t mapping;
 	u16 mss;
 	u8 ctrl;
@@ -1555,13 +1564,17 @@ static int sky2_xmit_frame(struct sk_buf
  	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
   		return NETDEV_TX_BUSY;
 
-	if (unlikely(netif_msg_tx_queued(sky2)))
-		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
-		       dev->name, sky2->tx_prod, skb->len);
-
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
+	if (pci_dma_mapping_error(hw->pdev, mapping))
+		goto mapping_error;
+
+	first_slot = sky2->tx_prod;
+	if (unlikely(netif_msg_tx_queued(sky2)))
+		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
+		       dev->name, first_slot, skb->len);
+
 	/* Send high bits if needed */
 	if (sizeof(dma_addr_t) > sizeof(u32)) {
 		le = get_tx_le(sky2);
@@ -1648,6 +1661,9 @@ static int sky2_xmit_frame(struct sk_buf
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
 
+		if (pci_dma_mapping_error(hw->pdev, mapping))
+			goto mapping_unwind;
+
 		if (sizeof(dma_addr_t) > sizeof(u32)) {
 			le = get_tx_le(sky2);
 			le->addr = cpu_to_le32(upper_32_bits(mapping));
@@ -1676,6 +1692,34 @@ static int sky2_xmit_frame(struct sk_buf
 
 	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
+
+mapping_unwind:
+	for (i = first_slot; i != sky2->tx_prod; i = RING_NEXT(i, TX_RING_SIZE)) {
+		le = sky2->tx_le + i;
+		re = sky2->tx_ring + i;
+
+		switch(le->opcode & ~HW_OWNER) {
+		case OP_LARGESEND:
+		case OP_PACKET:
+			pci_unmap_single(hw->pdev,
+					 pci_unmap_addr(re, mapaddr),
+					 pci_unmap_len(re, maplen),
+					 PCI_DMA_TODEVICE);
+			break;
+		case OP_BUFFER:
+			pci_unmap_page(hw->pdev, pci_unmap_addr(re, mapaddr),
+				       pci_unmap_len(re, maplen),
+				       PCI_DMA_TODEVICE);
+			break;
+		}
+	}
+
+	sky2->tx_prod = first_slot;
+mapping_error:
+	if (net_ratelimit())
+		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -2191,7 +2235,11 @@ static struct sk_buff *receive_new(struc
 
 	prefetch(skb->data);
 	re->skb = nskb;
-	sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space);
+	if (sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space)) {
+		dev_kfree_skb(nskb);
+		re->skb = skb;
+		return NULL;
+	}
 
 	if (skb_shinfo(skb)->nr_frags)
 		skb_put_frags(skb, hdr_space, length);

-- 

