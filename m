From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3]: tg3: Use SKB DMA helper functions for TX.
Date: Thu, 11 Sep 2008 05:03:11 -0700 (PDT)
Message-ID: <20080911.050311.57379088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752698AbYIKMDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 08:03:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 102DEC8C181
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 05:03:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tg3: Use SKB DMA helper functions for TX.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |   88 ++++++++++++++++++----------------------------------
 drivers/net/tg3.h |    1 -
 2 files changed, 31 insertions(+), 58 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 71d2c5c..355e8bc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3861,10 +3861,7 @@ static void tg3_tx(struct tg3 *tp)
 			return;
 		}
 
-		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(ri, mapping),
-				 skb_headlen(skb),
-				 PCI_DMA_TODEVICE);
+		skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
 
 		ri->skb = NULL;
 
@@ -3874,12 +3871,6 @@ static void tg3_tx(struct tg3 *tp)
 			ri = &tp->tx_buffers[sw_idx];
 			if (unlikely(ri->skb != NULL || sw_idx == hw_idx))
 				tx_bug = 1;
-
-			pci_unmap_page(tp->pdev,
-				       pci_unmap_addr(ri, mapping),
-				       skb_shinfo(skb)->frags[i].size,
-				       PCI_DMA_TODEVICE);
-
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
@@ -4633,12 +4624,13 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 	} else {
 		/* New SKB is guaranteed to be linear. */
 		entry = *start;
-		new_addr = pci_map_single(tp->pdev, new_skb->data, new_skb->len,
-					  PCI_DMA_TODEVICE);
+		ret = skb_dma_map(&tp->pdev->dev, new_skb, DMA_TO_DEVICE);
+		new_addr = skb_shinfo(new_skb)->dma_maps[0];
+
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
 		 */
-		if (tg3_4g_overflow_test(new_addr, new_skb->len)) {
+		if (ret || tg3_4g_overflow_test(new_addr, new_skb->len)) {
 			ret = -1;
 			dev_kfree_skb(new_skb);
 			new_skb = NULL;
@@ -4652,18 +4644,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 	/* Now clean up the sw ring entries. */
 	i = 0;
 	while (entry != last_plus_one) {
-		int len;
-
-		if (i == 0)
-			len = skb_headlen(skb);
-		else
-			len = skb_shinfo(skb)->frags[i-1].size;
-		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(&tp->tx_buffers[entry], mapping),
-				 len, PCI_DMA_TODEVICE);
 		if (i == 0) {
 			tp->tx_buffers[entry].skb = new_skb;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, new_addr);
 		} else {
 			tp->tx_buffers[entry].skb = NULL;
 		}
@@ -4671,6 +4653,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 		i++;
 	}
 
+	skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
 	return ret;
@@ -4705,8 +4688,9 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
 	u32 len, entry, base_flags, mss;
+	struct skb_shared_info *sp;
+	dma_addr_t mapping;
 
 	len = skb_headlen(skb);
 
@@ -4765,11 +4749,16 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
 
-	/* Queue skb data, a.k.a. the main skb fragment. */
-	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (skb_dma_map(&tp->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_kfree_skb(skb);
+		goto out_unlock;
+	}
+
+	sp = skb_shinfo(skb);
+
+	mapping = sp->dma_maps[0];
 
 	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
@@ -4785,13 +4774,8 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
-
+			mapping = sp->dma_maps[i + 1];
 			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 			tg3_set_txd(tp, entry, mapping, len,
 				    base_flags, (i == last) | (mss << 1));
@@ -4859,9 +4843,10 @@ tg3_tso_bug_end:
 static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
 	u32 len, entry, base_flags, mss;
+	struct skb_shared_info *sp;
 	int would_hit_hwbug;
+	dma_addr_t mapping;
 
 	len = skb_headlen(skb);
 
@@ -4942,11 +4927,16 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
 
-	/* Queue skb data, a.k.a. the main skb fragment. */
-	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (skb_dma_map(&tp->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_kfree_skb(skb);
+		goto out_unlock;
+	}
+
+	sp = skb_shinfo(skb);
+
+	mapping = sp->dma_maps[0];
 
 	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 	would_hit_hwbug = 0;
 
@@ -4969,13 +4959,9 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+			mapping = sp->dma_maps[i + 1];
 
 			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 			if (tg3_4g_overflow_test(mapping, len))
 				would_hit_hwbug = 1;
@@ -5128,7 +5114,6 @@ static void tg3_free_rings(struct tg3 *tp)
 	for (i = 0; i < TG3_TX_RING_SIZE; ) {
 		struct tx_ring_info *txp;
 		struct sk_buff *skb;
-		int j;
 
 		txp = &tp->tx_buffers[i];
 		skb = txp->skb;
@@ -5138,22 +5123,11 @@ static void tg3_free_rings(struct tg3 *tp)
 			continue;
 		}
 
-		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(txp, mapping),
-				 skb_headlen(skb),
-				 PCI_DMA_TODEVICE);
-		txp->skb = NULL;
+		skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
 
-		i++;
+		txp->skb = NULL;
 
-		for (j = 0; j < skb_shinfo(skb)->nr_frags; j++) {
-			txp = &tp->tx_buffers[i & (TG3_TX_RING_SIZE - 1)];
-			pci_unmap_page(tp->pdev,
-				       pci_unmap_addr(txp, mapping),
-				       skb_shinfo(skb)->frags[j].size,
-				       PCI_DMA_TODEVICE);
-			i++;
-		}
+		i += skb_shinfo(skb)->nr_frags + 1;
 
 		dev_kfree_skb_any(skb);
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f5b8cab..6c7b5e3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2197,7 +2197,6 @@ struct ring_info {
 
 struct tx_ring_info {
 	struct sk_buff			*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
 	u32				prev_vlan_tag;
 };
 
-- 
1.5.6.5.GIT

