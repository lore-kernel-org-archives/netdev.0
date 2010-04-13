From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] tg3: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:09 +0900
Message-ID: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38862 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333Ab0DMAdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   42 +++++++++++++++++++++---------------------
 drivers/net/tg3.h |    2 +-
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 460a0c2..46cf84c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4379,7 +4379,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		}
 
 		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(ri, mapping),
+				 dma_unmap_addr(ri, mapping),
 				 skb_headlen(skb),
 				 PCI_DMA_TODEVICE);
 
@@ -4393,7 +4393,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 				tx_bug = 1;
 
 			pci_unmap_page(tp->pdev,
-				       pci_unmap_addr(ri, mapping),
+				       dma_unmap_addr(ri, mapping),
 				       skb_shinfo(skb)->frags[i].size,
 				       PCI_DMA_TODEVICE);
 			sw_idx = NEXT_TX(sw_idx);
@@ -4431,7 +4431,7 @@ static void tg3_rx_skb_free(struct tg3 *tp, struct ring_info *ri, u32 map_sz)
 	if (!ri->skb)
 		return;
 
-	pci_unmap_single(tp->pdev, pci_unmap_addr(ri, mapping),
+	pci_unmap_single(tp->pdev, dma_unmap_addr(ri, mapping),
 			 map_sz, PCI_DMA_FROMDEVICE);
 	dev_kfree_skb_any(ri->skb);
 	ri->skb = NULL;
@@ -4497,7 +4497,7 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	}
 
 	map->skb = skb;
-	pci_unmap_addr_set(map, mapping, mapping);
+	dma_unmap_addr_set(map, mapping, mapping);
 
 	desc->addr_hi = ((u64)mapping >> 32);
 	desc->addr_lo = ((u64)mapping & 0xffffffff);
@@ -4542,8 +4542,8 @@ static void tg3_recycle_rx(struct tg3_napi *tnapi,
 	}
 
 	dest_map->skb = src_map->skb;
-	pci_unmap_addr_set(dest_map, mapping,
-			   pci_unmap_addr(src_map, mapping));
+	dma_unmap_addr_set(dest_map, mapping,
+			   dma_unmap_addr(src_map, mapping));
 	dest_desc->addr_hi = src_desc->addr_hi;
 	dest_desc->addr_lo = src_desc->addr_lo;
 
@@ -4611,13 +4611,13 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 		if (opaque_key == RXD_OPAQUE_RING_STD) {
 			ri = &tp->prodring[0].rx_std_buffers[desc_idx];
-			dma_addr = pci_unmap_addr(ri, mapping);
+			dma_addr = dma_unmap_addr(ri, mapping);
 			skb = ri->skb;
 			post_ptr = &std_prod_idx;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
 			ri = &tp->prodring[0].rx_jmb_buffers[desc_idx];
-			dma_addr = pci_unmap_addr(ri, mapping);
+			dma_addr = dma_unmap_addr(ri, mapping);
 			skb = ri->skb;
 			post_ptr = &jmb_prod_idx;
 		} else
@@ -5439,12 +5439,12 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 			len = skb_shinfo(skb)->frags[i-1].size;
 
 		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(&tnapi->tx_buffers[entry],
+				 dma_unmap_addr(&tnapi->tx_buffers[entry],
 						mapping),
 				 len, PCI_DMA_TODEVICE);
 		if (i == 0) {
 			tnapi->tx_buffers[entry].skb = new_skb;
-			pci_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
+			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
 					   new_addr);
 		} else {
 			tnapi->tx_buffers[entry].skb = NULL;
@@ -5574,7 +5574,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	}
 
 	tnapi->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
+	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
 
 	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
 	    !mss && skb->len > ETH_DATA_LEN)
@@ -5600,7 +5600,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 				goto dma_error;
 
 			tnapi->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
+			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
 					   mapping);
 
 			tg3_set_txd(tnapi, entry, mapping, len,
@@ -5630,7 +5630,7 @@ dma_error:
 	entry = tnapi->tx_prod;
 	tnapi->tx_buffers[entry].skb = NULL;
 	pci_unmap_single(tp->pdev,
-			 pci_unmap_addr(&tnapi->tx_buffers[entry], mapping),
+			 dma_unmap_addr(&tnapi->tx_buffers[entry], mapping),
 			 skb_headlen(skb),
 			 PCI_DMA_TODEVICE);
 	for (i = 0; i <= last; i++) {
@@ -5638,7 +5638,7 @@ dma_error:
 		entry = NEXT_TX(entry);
 
 		pci_unmap_page(tp->pdev,
-			       pci_unmap_addr(&tnapi->tx_buffers[entry],
+			       dma_unmap_addr(&tnapi->tx_buffers[entry],
 					      mapping),
 			       frag->size, PCI_DMA_TODEVICE);
 	}
@@ -5800,7 +5800,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 	}
 
 	tnapi->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
+	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
 
 	would_hit_hwbug = 0;
 
@@ -5836,7 +5836,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 					       len, PCI_DMA_TODEVICE);
 
 			tnapi->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
+			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
 					   mapping);
 			if (pci_dma_mapping_error(tp->pdev, mapping))
 				goto dma_error;
@@ -5901,7 +5901,7 @@ dma_error:
 	entry = tnapi->tx_prod;
 	tnapi->tx_buffers[entry].skb = NULL;
 	pci_unmap_single(tp->pdev,
-			 pci_unmap_addr(&tnapi->tx_buffers[entry], mapping),
+			 dma_unmap_addr(&tnapi->tx_buffers[entry], mapping),
 			 skb_headlen(skb),
 			 PCI_DMA_TODEVICE);
 	for (i = 0; i <= last; i++) {
@@ -5909,7 +5909,7 @@ dma_error:
 		entry = NEXT_TX(entry);
 
 		pci_unmap_page(tp->pdev,
-			       pci_unmap_addr(&tnapi->tx_buffers[entry],
+			       dma_unmap_addr(&tnapi->tx_buffers[entry],
 					      mapping),
 			       frag->size, PCI_DMA_TODEVICE);
 	}
@@ -6194,7 +6194,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			}
 
 			pci_unmap_single(tp->pdev,
-					 pci_unmap_addr(txp, mapping),
+					 dma_unmap_addr(txp, mapping),
 					 skb_headlen(skb),
 					 PCI_DMA_TODEVICE);
 			txp->skb = NULL;
@@ -6204,7 +6204,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			for (k = 0; k < skb_shinfo(skb)->nr_frags; k++) {
 				txp = &tnapi->tx_buffers[i & (TG3_TX_RING_SIZE - 1)];
 				pci_unmap_page(tp->pdev,
-					       pci_unmap_addr(txp, mapping),
+					       dma_unmap_addr(txp, mapping),
 					       skb_shinfo(skb)->frags[k].size,
 					       PCI_DMA_TODEVICE);
 				i++;
@@ -10686,7 +10686,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	rx_skb = tpr->rx_std_buffers[desc_idx].skb;
 
-	map = pci_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
+	map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
 	pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len, PCI_DMA_FROMDEVICE);
 
 	for (i = 14; i < tx_len; i++) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5d7f72a..3f149f3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2512,7 +2512,7 @@ struct tg3_hw_stats {
  */
 struct ring_info {
 	struct sk_buff			*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 struct tg3_config_info {
-- 
1.6.5

