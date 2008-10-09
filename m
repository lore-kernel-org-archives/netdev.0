From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2: Handle DMA mapping errors.
Date: Thu,  9 Oct 2008 10:16:07 -0700
Message-ID: <1223572568-1298-5-git-send-email-mchan@broadcom.com>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3306 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbYJIRKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 13:10:52 -0400
In-Reply-To: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before, the driver would not care about the return codes from pci_map_*
functions.  This could be potentially dangerous if a mapping failed.
Now, we will check all pci_map_* calls.  On the transmit side, we switch
to use the new function skb_dma_map().  On the receive side, we add
pci_dma_mapping_error().

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |  114 ++++++++++++++++++++++++++++------------------------
 drivers/net/bnx2.h |    8 +++-
 2 files changed, 67 insertions(+), 55 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f147204..a95ca4f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2476,6 +2476,11 @@ bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 		return -ENOMEM;
 	mapping = pci_map_page(bp->pdev, page, 0, PAGE_SIZE,
 			       PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(bp->pdev, mapping)) {
+		__free_page(page);
+		return -EIO;
+	}
+
 	rx_pg->page = page;
 	pci_unmap_addr_set(rx_pg, mapping, mapping);
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
@@ -2518,6 +2523,10 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 
 	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
 		PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(bp->pdev, mapping)) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
 
 	rx_buf->skb = skb;
 	pci_unmap_addr_set(rx_buf, mapping, mapping);
@@ -2592,7 +2601,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	sw_cons = txr->tx_cons;
 
 	while (sw_cons != hw_cons) {
-		struct sw_bd *tx_buf;
+		struct sw_tx_bd *tx_buf;
 		struct sk_buff *skb;
 		int i, last;
 
@@ -2617,21 +2626,13 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			}
 		}
 
-		pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
-			skb_headlen(skb), PCI_DMA_TODEVICE);
+		skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
 
 		tx_buf->skb = NULL;
 		last = skb_shinfo(skb)->nr_frags;
 
 		for (i = 0; i < last; i++) {
 			sw_cons = NEXT_TX_BD(sw_cons);
-
-			pci_unmap_page(bp->pdev,
-				pci_unmap_addr(
-					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
-				       	mapping),
-				skb_shinfo(skb)->frags[i].size,
-				PCI_DMA_TODEVICE);
 		}
 
 		sw_cons = NEXT_TX_BD(sw_cons);
@@ -2672,11 +2673,31 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 {
 	struct sw_pg *cons_rx_pg, *prod_rx_pg;
 	struct rx_bd *cons_bd, *prod_bd;
-	dma_addr_t mapping;
 	int i;
-	u16 hw_prod = rxr->rx_pg_prod, prod;
+	u16 hw_prod, prod;
 	u16 cons = rxr->rx_pg_cons;
 
+	cons_rx_pg = &rxr->rx_pg_ring[cons];
+
+	/* The caller was unable to allocate a new page to replace the
+	 * last one in the frags array, so we need to recycle that page
+	 * and then free the skb.
+	 */
+	if (skb) {
+		struct page *page;
+		struct skb_shared_info *shinfo;
+
+		shinfo = skb_shinfo(skb);
+		shinfo->nr_frags--;
+		page = shinfo->frags[shinfo->nr_frags].page;
+		shinfo->frags[shinfo->nr_frags].page = NULL;
+
+		cons_rx_pg->page = page;
+		dev_kfree_skb(skb);
+	}
+
+	hw_prod = rxr->rx_pg_prod;
+
 	for (i = 0; i < count; i++) {
 		prod = RX_PG_RING_IDX(hw_prod);
 
@@ -2685,20 +2706,6 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 		cons_bd = &rxr->rx_pg_desc_ring[RX_RING(cons)][RX_IDX(cons)];
 		prod_bd = &rxr->rx_pg_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 
-		if (i == 0 && skb) {
-			struct page *page;
-			struct skb_shared_info *shinfo;
-
-			shinfo = skb_shinfo(skb);
-			shinfo->nr_frags--;
-			page = shinfo->frags[shinfo->nr_frags].page;
-			shinfo->frags[shinfo->nr_frags].page = NULL;
-			mapping = pci_map_page(bp->pdev, page, 0, PAGE_SIZE,
-					       PCI_DMA_FROMDEVICE);
-			cons_rx_pg->page = page;
-			pci_unmap_addr_set(cons_rx_pg, mapping, mapping);
-			dev_kfree_skb(skb);
-		}
 		if (prod != cons) {
 			prod_rx_pg->page = cons_rx_pg->page;
 			cons_rx_pg->page = NULL;
@@ -2784,6 +2791,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 		skb_put(skb, hdr_len);
 
 		for (i = 0; i < pages; i++) {
+			dma_addr_t mapping_old;
+
 			frag_len = min(frag_size, (unsigned int) PAGE_SIZE);
 			if (unlikely(frag_len <= 4)) {
 				unsigned int tail = 4 - frag_len;
@@ -2806,9 +2815,10 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 			}
 			rx_pg = &rxr->rx_pg_ring[pg_cons];
 
-			pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping),
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
-
+			/* Don't unmap yet.  If we're unable to allocate a new
+			 * page, we need to recycle the page and the DMA addr.
+			 */
+			mapping_old = pci_unmap_addr(rx_pg, mapping);
 			if (i == pages - 1)
 				frag_len -= 4;
 
@@ -2825,6 +2835,9 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 				return err;
 			}
 
+			pci_unmap_page(bp->pdev, mapping_old,
+				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+
 			frag_size -= frag_len;
 			skb->data_len += frag_len;
 			skb->truesize += frag_len;
@@ -4971,31 +4984,20 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			continue;
 
 		for (j = 0; j < TX_DESC_CNT; ) {
-			struct sw_bd *tx_buf = &txr->tx_buf_ring[j];
+			struct sw_tx_bd *tx_buf = &txr->tx_buf_ring[j];
 			struct sk_buff *skb = tx_buf->skb;
-			int k, last;
 
 			if (skb == NULL) {
 				j++;
 				continue;
 			}
 
-			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(tx_buf, mapping),
-			skb_headlen(skb), PCI_DMA_TODEVICE);
+			skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
 
 			tx_buf->skb = NULL;
 
-			last = skb_shinfo(skb)->nr_frags;
-			for (k = 0; k < last; k++) {
-				tx_buf = &txr->tx_buf_ring[j + k + 1];
-				pci_unmap_page(bp->pdev,
-					pci_unmap_addr(tx_buf, mapping),
-					skb_shinfo(skb)->frags[j].size,
-					PCI_DMA_TODEVICE);
-			}
+			j += skb_shinfo(skb)->nr_frags + 1;
 			dev_kfree_skb(skb);
-			j += k + 1;
 		}
 	}
 }
@@ -5373,8 +5375,11 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	for (i = 14; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
 
-	map = pci_map_single(bp->pdev, skb->data, pkt_size,
-		PCI_DMA_TODEVICE);
+	if (skb_dma_map(&bp->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
+	map = skb_shinfo(skb)->dma_maps[0];
 
 	REG_WR(bp, BNX2_HC_COMMAND,
 	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
@@ -5409,7 +5414,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 
 	udelay(5);
 
-	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
+	skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
 	if (bnx2_get_hw_tx_cons(tx_napi) != txr->tx_prod)
@@ -5970,13 +5975,14 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	dma_addr_t mapping;
 	struct tx_bd *txbd;
-	struct sw_bd *tx_buf;
+	struct sw_tx_bd *tx_buf;
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
 	struct bnx2_napi *bnapi;
 	struct bnx2_tx_ring_info *txr;
 	struct netdev_queue *txq;
+	struct skb_shared_info *sp;
 
 	/*  Determine which tx ring we will be placed on */
 	i = skb_get_queue_mapping(skb);
@@ -6041,11 +6047,16 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		mss = 0;
 
-	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (skb_dma_map(&bp->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	sp = skb_shinfo(skb);
+	mapping = sp->dma_maps[0];
 
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
-	pci_unmap_addr_set(tx_buf, mapping, mapping);
 
 	txbd = &txr->tx_desc_ring[ring_prod];
 
@@ -6064,10 +6075,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
-		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
-			len, PCI_DMA_TODEVICE);
-		pci_unmap_addr_set(&txr->tx_buf_ring[ring_prod],
-				mapping, mapping);
+		mapping = sp->dma_maps[i + 1];
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
 		txbd->tx_bd_haddr_lo = (u64) mapping & 0xffffffff;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index edc7774..617d953 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6526,10 +6526,14 @@ struct sw_pg {
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
 
+struct sw_tx_bd {
+	struct sk_buff		*skb;
+};
+
 #define SW_RXBD_RING_SIZE (sizeof(struct sw_bd) * RX_DESC_CNT)
 #define SW_RXPG_RING_SIZE (sizeof(struct sw_pg) * RX_DESC_CNT)
 #define RXBD_RING_SIZE (sizeof(struct rx_bd) * RX_DESC_CNT)
-#define SW_TXBD_RING_SIZE (sizeof(struct sw_bd) * TX_DESC_CNT)
+#define SW_TXBD_RING_SIZE (sizeof(struct sw_tx_bd) * TX_DESC_CNT)
 #define TXBD_RING_SIZE (sizeof(struct tx_bd) * TX_DESC_CNT)
 
 /* Buffered flash (Atmel: AT45DB011B) specific information */
@@ -6609,7 +6613,7 @@ struct bnx2_tx_ring_info {
 	u32			tx_bseq_addr;
 
 	struct tx_bd		*tx_desc_ring;
-	struct sw_bd		*tx_buf_ring;
+	struct sw_tx_bd		*tx_buf_ring;
 
 	u16			tx_cons;
 	u16			hw_tx_cons;
-- 
1.5.6.GIT


