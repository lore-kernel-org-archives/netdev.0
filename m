From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 34/75] mlx4: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:06 +0100
Message-ID: <1313760467-8598-34-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Markuze Alex <markuze@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Joe Perches <joe@perches.com>,
	Luciano Coelho <luciano.coelho@nokia.com>,
	Jon Mason <jdmason@kudzu.us>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37564 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838Ab1HSN3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:29:01 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Markuze Alex <markuze@mellanox.co.il>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Joe Perches <joe@perches.com>
Cc: Luciano Coelho <luciano.coelho@nokia.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: Lucas De Marchi <lucas.demarchi@profusion.mobi>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/mlx4/en_rx.c |   22 ++++++++++------------
 drivers/net/mlx4/en_tx.c |   20 ++++----------------
 2 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 37cc9e5..0c26ee7 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -60,20 +60,18 @@ static int mlx4_en_alloc_frag(struct mlx4_en_priv *priv,
 		if (!page)
 			return -ENOMEM;
 
-		skb_frags[i].page = page_alloc->page;
+		__skb_frag_set_page(&skb_frags[i], page_alloc->page);
 		skb_frags[i].page_offset = page_alloc->offset;
 		page_alloc->page = page;
 		page_alloc->offset = frag_info->frag_align;
 	} else {
-		page = page_alloc->page;
-		get_page(page);
-
-		skb_frags[i].page = page;
+		__skb_frag_set_page(&skb_frags[i], page_alloc->page);
+		__skb_frag_ref(&skb_frags[i]);
 		skb_frags[i].page_offset = page_alloc->offset;
 		page_alloc->offset += frag_info->frag_stride;
 	}
-	dma = pci_map_single(mdev->pdev, page_address(skb_frags[i].page) +
-			     skb_frags[i].page_offset, frag_info->frag_size,
+	dma = pci_map_single(mdev->pdev, skb_frag_address(&skb_frags[i]),
+			     frag_info->frag_size,
 			     PCI_DMA_FROMDEVICE);
 	rx_desc->data[i].addr = cpu_to_be64(dma);
 	return 0;
@@ -169,7 +167,7 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 
 err:
 	while (i--)
-		put_page(skb_frags[i].page);
+		__skb_frag_unref(&skb_frags[i]);
 	return -ENOMEM;
 }
 
@@ -196,7 +194,7 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
 		en_dbg(DRV, priv, "Unmapping buffer at dma:0x%llx\n", (u64) dma);
 		pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
 				 PCI_DMA_FROMDEVICE);
-		put_page(skb_frags[nr].page);
+		__skb_frag_unref(&skb_frags[nr]);
 	}
 }
 
@@ -420,7 +418,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			break;
 
 		/* Save page reference in skb */
-		skb_frags_rx[nr].page = skb_frags[nr].page;
+		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page);
 		skb_frags_rx[nr].size = skb_frags[nr].size;
 		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
@@ -444,7 +442,7 @@ fail:
 	 * the descriptor) of this packet; remaining fragments are reused... */
 	while (nr > 0) {
 		nr--;
-		put_page(skb_frags_rx[nr].page);
+		__skb_frag_unref(&skb_frags_rx[nr]);
 	}
 	return 0;
 }
@@ -474,7 +472,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 
 	/* Get pointer to first fragment so we could copy the headers into the
 	 * (linear part of the) skb */
-	va = page_address(skb_frags[0].page) + skb_frags[0].page_offset;
+	va = skb_frag_address(&skb_frags[0]);
 
 	if (length <= SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 6e03de0..4eae254 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -460,26 +460,13 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
 		}
 }
 
-static void *get_frag_ptr(struct sk_buff *skb)
-{
-	struct skb_frag_struct *frag =  &skb_shinfo(skb)->frags[0];
-	struct page *page = frag->page;
-	void *ptr;
-
-	ptr = page_address(page);
-	if (unlikely(!ptr))
-		return NULL;
-
-	return ptr + frag->page_offset;
-}
-
 static int is_inline(struct sk_buff *skb, void **pfrag)
 {
 	void *ptr;
 
 	if (inline_thold && !skb_is_gso(skb) && skb->len <= inline_thold) {
 		if (skb_shinfo(skb)->nr_frags == 1) {
-			ptr = get_frag_ptr(skb);
+			ptr = skb_frag_address_safe(&skb_shinfo(skb)->frags[0]);
 			if (unlikely(!ptr))
 				return 0;
 
@@ -756,8 +743,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Map fragments */
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
 			frag = &skb_shinfo(skb)->frags[i];
-			dma = pci_map_page(mdev->dev->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			dma = skb_frag_dma_map(&mdev->dev->pdev->dev, frag,
+					       0, frag->size,
+					       PCI_DMA_TODEVICE);
 			data->addr = cpu_to_be64(dma);
 			data->lkey = cpu_to_be32(mdev->mr.key);
 			wmb();
-- 
1.7.2.5

