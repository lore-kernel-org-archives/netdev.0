From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/7] 8139cp: trim ring_info
Date: Thu, 31 Aug 2006 22:48:20 +0200
Message-ID: <20060831204820.GA14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:62635 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964779AbWHaUwO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:52:14 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fat removal: the mapping address is available from the Rx/Tx descriptors.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |   33 ++++++++++++++++-----------------
 1 files changed, 16 insertions(+), 17 deletions(-)

3598b57be449a2ee9178e5c511bdb1a8aaccba20
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 1428bb7..8f5d779 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -316,7 +316,6 @@ struct cp_desc {
 
 struct ring_info {
 	struct sk_buff		*skb;
-	dma_addr_t		mapping;
 	u32			len;
 };
 
@@ -551,7 +550,7 @@ rx_status_loop:
 			break;
 
 		len = (status & 0x1fff) - 4;
-		mapping = cp->rx_skb[rx_tail].mapping;
+		mapping = le64_to_cpu(desc->addr);
 
 		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)) {
 			/* we don't support incoming fragmented frames.
@@ -595,10 +594,8 @@ rx_status_loop:
 
 		skb_put(skb, len);
 
-		mapping =
-		cp->rx_skb[rx_tail].mapping =
-			pci_map_single(cp->pdev, new_skb->data,
-				       buflen, PCI_DMA_FROMDEVICE);
+		mapping = pci_map_single(cp->pdev, new_skb->data, buflen,
+					 PCI_DMA_FROMDEVICE);
 		cp->rx_skb[rx_tail].skb = new_skb;
 
 		cp_rx_skb(cp, skb, desc);
@@ -717,18 +714,19 @@ static void cp_tx (struct cp_private *cp
 	unsigned tx_tail = cp->tx_tail;
 
 	while (tx_tail != tx_head) {
+		struct cp_desc *txd = cp->tx_ring + tx_tail;
 		struct sk_buff *skb;
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(cp->tx_ring[tx_tail].opts1);
+		status = le32_to_cpu(txd->opts1);
 		if (status & DescOwn)
 			break;
 
 		skb = cp->tx_skb[tx_tail].skb;
 		BUG_ON(!skb);
 
-		pci_unmap_single(cp->pdev, cp->tx_skb[tx_tail].mapping,
+		pci_unmap_single(cp->pdev, le64_to_cpu(txd->addr),
 				 cp->tx_skb[tx_tail].len, PCI_DMA_TODEVICE);
 
 		if (status & LastFrag) {
@@ -827,7 +825,6 @@ #endif
 		wmb();
 
 		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].mapping = mapping;
 		cp->tx_skb[entry].len = len;
 		entry = NEXT_TX(entry);
 	} else {
@@ -845,7 +842,6 @@ #endif
 		first_mapping = pci_map_single(cp->pdev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
 		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].mapping = first_mapping;
 		cp->tx_skb[entry].len = first_len;
 		entry = NEXT_TX(entry);
 
@@ -888,7 +884,6 @@ #endif
 			wmb();
 
 			cp->tx_skb[entry].skb = skb;
-			cp->tx_skb[entry].mapping = mapping;
 			cp->tx_skb[entry].len = len;
 			entry = NEXT_TX(entry);
 		}
@@ -1091,6 +1086,7 @@ static int cp_refill_rx (struct cp_priva
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
+		dma_addr_t mapping;
 
 		skb = dev_alloc_skb(cp->rx_buf_sz + RX_OFFSET);
 		if (!skb)
@@ -1099,12 +1095,12 @@ static int cp_refill_rx (struct cp_priva
 		skb->dev = cp->dev;
 		skb_reserve(skb, RX_OFFSET);
 
-		cp->rx_skb[i].mapping = pci_map_single(cp->pdev,
-			skb->data, cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+		mapping = pci_map_single(cp->pdev, skb->data, cp->rx_buf_sz,
+					 PCI_DMA_FROMDEVICE);
 		cp->rx_skb[i].skb = skb;
 
 		cp->rx_ring[i].opts2 = 0;
-		cp->rx_ring[i].addr = cpu_to_le64(cp->rx_skb[i].mapping);
+		cp->rx_ring[i].addr = cpu_to_le64(mapping);
 		if (i == (CP_RX_RING_SIZE - 1))
 			cp->rx_ring[i].opts1 =
 				cpu_to_le32(DescOwn | RingEnd | cp->rx_buf_sz);
@@ -1152,11 +1148,13 @@ static int cp_alloc_rings (struct cp_pri
 
 static void cp_clean_rings (struct cp_private *cp)
 {
+	struct cp_desc *desc;
 	unsigned i;
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		if (cp->rx_skb[i].skb) {
-			pci_unmap_single(cp->pdev, cp->rx_skb[i].mapping,
+			desc = cp->rx_ring + i;
+			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(cp->rx_skb[i].skb);
 		}
@@ -1166,9 +1164,10 @@ static void cp_clean_rings (struct cp_pr
 		if (cp->tx_skb[i].skb) {
 			struct sk_buff *skb = cp->tx_skb[i].skb;
 
-			pci_unmap_single(cp->pdev, cp->tx_skb[i].mapping,
+			desc = cp->tx_ring + i;
+			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
 				 	 cp->tx_skb[i].len, PCI_DMA_TODEVICE);
-			if (le32_to_cpu(cp->tx_ring[i].opts1) & LastFrag)
+			if (le32_to_cpu(desc->opts1) & LastFrag)
 				dev_kfree_skb(skb);
 			cp->net_stats.tx_dropped++;
 		}
-- 
1.3.1

