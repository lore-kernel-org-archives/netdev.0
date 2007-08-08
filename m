From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 1/3] 8139cp, 8139too: use generic DMA
Date: Wed, 8 Aug 2007 02:44:40 -0400
Message-ID: <20070808064440.GA16595@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764685AbXHHGoy@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit f09934422b162e0eb7a8fd3b4b25ffc92e31541a
Author: Jeff Garzik <jeff@garzik.org>
Date:   Wed Aug 8 02:16:04 2007 -0400

    [netdrvr] 8139cp, 8139too: convert to generic DMA
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/8139cp.c  |   31 +++++++++++++++++--------------
 drivers/net/8139too.c |   20 ++++++++++----------
 2 files changed, 27 insertions(+), 24 deletions(-)

f09934422b162e0eb7a8fd3b4b25ffc92e31541a
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a79f28c..0664701 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -560,7 +560,7 @@ rx_status_loop:
 
 		skb_reserve(new_skb, RX_OFFSET);
 
-		pci_unmap_single(cp->pdev, mapping,
+		dma_unmap_single(&cp->pdev->dev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
 
 		/* Handle checksum offloading for incoming packets. */
@@ -571,7 +571,7 @@ rx_status_loop:
 
 		skb_put(skb, len);
 
-		mapping = pci_map_single(cp->pdev, new_skb->data, buflen,
+		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
 					 PCI_DMA_FROMDEVICE);
 		cp->rx_skb[rx_tail] = new_skb;
 
@@ -704,7 +704,7 @@ static void cp_tx (struct cp_private *cp)
 		skb = cp->tx_skb[tx_tail];
 		BUG_ON(!skb);
 
-		pci_unmap_single(cp->pdev, le64_to_cpu(txd->addr),
+		dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
 				 le32_to_cpu(txd->opts1) & 0xffff,
 				 PCI_DMA_TODEVICE);
 
@@ -782,7 +782,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		dma_addr_t mapping;
 
 		len = skb->len;
-		mapping = pci_map_single(cp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
 		CP_VLAN_TX_TAG(txd, vlan_tag);
 		txd->addr = cpu_to_le64(mapping);
 		wmb();
@@ -818,7 +818,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		 */
 		first_eor = eor;
 		first_len = skb_headlen(skb);
-		first_mapping = pci_map_single(cp->pdev, skb->data,
+		first_mapping = dma_map_single(&cp->pdev->dev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
 		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
@@ -830,7 +830,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 			dma_addr_t mapping;
 
 			len = this_frag->size;
-			mapping = pci_map_single(cp->pdev,
+			mapping = dma_map_single(&cp->pdev->dev,
 						 ((void *) page_address(this_frag->page) +
 						  this_frag->page_offset),
 						 len, PCI_DMA_TODEVICE);
@@ -1069,8 +1069,8 @@ static int cp_refill_rx (struct cp_private *cp)
 
 		skb_reserve(skb, RX_OFFSET);
 
-		mapping = pci_map_single(cp->pdev, skb->data, cp->rx_buf_sz,
-					 PCI_DMA_FROMDEVICE);
+		mapping = dma_map_single(&cp->pdev->dev, skb->data,
+					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		cp->rx_skb[i] = skb;
 
 		cp->rx_ring[i].opts2 = 0;
@@ -1110,7 +1110,8 @@ static int cp_alloc_rings (struct cp_private *cp)
 {
 	void *mem;
 
-	mem = pci_alloc_consistent(cp->pdev, CP_RING_BYTES, &cp->ring_dma);
+	mem = dma_alloc_coherent(&cp->pdev->dev, CP_RING_BYTES,
+				 &cp->ring_dma, GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
@@ -1128,7 +1129,7 @@ static void cp_clean_rings (struct cp_private *cp)
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		if (cp->rx_skb[i]) {
 			desc = cp->rx_ring + i;
-			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
+			dma_unmap_single(&cp->pdev->dev,le64_to_cpu(desc->addr),
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(cp->rx_skb[i]);
 		}
@@ -1139,7 +1140,7 @@ static void cp_clean_rings (struct cp_private *cp)
 			struct sk_buff *skb = cp->tx_skb[i];
 
 			desc = cp->tx_ring + i;
-			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
+			dma_unmap_single(&cp->pdev->dev,le64_to_cpu(desc->addr),
 					 le32_to_cpu(desc->opts1) & 0xffff,
 					 PCI_DMA_TODEVICE);
 			if (le32_to_cpu(desc->opts1) & LastFrag)
@@ -1158,7 +1159,8 @@ static void cp_clean_rings (struct cp_private *cp)
 static void cp_free_rings (struct cp_private *cp)
 {
 	cp_clean_rings(cp);
-	pci_free_consistent(cp->pdev, CP_RING_BYTES, cp->rx_ring, cp->ring_dma);
+	dma_free_coherent(&cp->pdev->dev, CP_RING_BYTES, cp->rx_ring,
+			  cp->ring_dma);
 	cp->rx_ring = NULL;
 	cp->tx_ring = NULL;
 }
@@ -1517,7 +1519,8 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 	dma_addr_t dma;
 	int i;
 
-	nic_stats = pci_alloc_consistent(cp->pdev, sizeof(*nic_stats), &dma);
+	nic_stats = dma_alloc_coherent(&cp->pdev->dev, sizeof(*nic_stats),
+				       &dma, GFP_KERNEL);
 	if (!nic_stats)
 		return;
 
@@ -1552,7 +1555,7 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 	tmp_stats[i++] = cp->cp_stats.rx_frags;
 	BUG_ON(i != CP_NUM_STATS);
 
-	pci_free_consistent(cp->pdev, sizeof(*nic_stats), nic_stats, dma);
+	dma_free_coherent(&cp->pdev->dev, sizeof(*nic_stats), nic_stats, dma);
 }
 
 static const struct ethtool_ops cp_ethtool_ops = {
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index f4e4298..0198f74 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1314,18 +1314,18 @@ static int rtl8139_open (struct net_device *dev)
 	if (retval)
 		return retval;
 
-	tp->tx_bufs = pci_alloc_consistent(tp->pci_dev, TX_BUF_TOT_LEN,
-					   &tp->tx_bufs_dma);
-	tp->rx_ring = pci_alloc_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
-					   &tp->rx_ring_dma);
+	tp->tx_bufs = dma_alloc_coherent(&tp->pci_dev->dev, TX_BUF_TOT_LEN,
+					   &tp->tx_bufs_dma, GFP_KERNEL);
+	tp->rx_ring = dma_alloc_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
+					   &tp->rx_ring_dma, GFP_KERNEL);
 	if (tp->tx_bufs == NULL || tp->rx_ring == NULL) {
 		free_irq(dev->irq, dev);
 
 		if (tp->tx_bufs)
-			pci_free_consistent(tp->pci_dev, TX_BUF_TOT_LEN,
+			dma_free_coherent(&tp->pci_dev->dev, TX_BUF_TOT_LEN,
 					    tp->tx_bufs, tp->tx_bufs_dma);
 		if (tp->rx_ring)
-			pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
+			dma_free_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
 					    tp->rx_ring, tp->rx_ring_dma);
 
 		return -ENOMEM;
@@ -2248,10 +2248,10 @@ static int rtl8139_close (struct net_device *dev)
 
 	rtl8139_tx_clear (tp);
 
-	pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
-			    tp->rx_ring, tp->rx_ring_dma);
-	pci_free_consistent(tp->pci_dev, TX_BUF_TOT_LEN,
-			    tp->tx_bufs, tp->tx_bufs_dma);
+	dma_free_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
+			  tp->rx_ring, tp->rx_ring_dma);
+	dma_free_coherent(&tp->pci_dev->dev, TX_BUF_TOT_LEN,
+			  tp->tx_bufs, tp->tx_bufs_dma);
 	tp->rx_ring = NULL;
 	tp->tx_bufs = NULL;
 
