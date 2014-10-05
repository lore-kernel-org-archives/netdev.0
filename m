From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 05/14] net/mlx4_en: Avoid a cache line miss in TX completion for single frag skb's
Date: Sun,  5 Oct 2014 12:35:13 +0300
Message-ID: <1412501722-25092-6-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59530 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750950AbaJEJfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:39 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add frag0_dma/frag0_byte_count into mlx4_en_tx_info to avoid a cache
line miss in TX completion for frames having one dma element.  (We avoid
reading back the tx descriptor)

Note this could be extended to 2/3 dma elements later, as we have free
room in mlx4_en_tx_info

Also, mlx4_en_free_tx_desc() no longer accesses skb_shinfo(). We use a
new nr_maps fields in mlx4_en_tx_info to avoid 2 or 3 cache misses.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 83 +++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +
 2 files changed, 49 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 1447906..edc4a88 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -259,38 +259,40 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring,
 				int index, u8 owner, u64 timestamp)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
 	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
 	struct mlx4_wqe_data_seg *data = (void *) tx_desc + tx_info->data_offset;
-	struct sk_buff *skb = tx_info->skb;
-	struct skb_frag_struct *frag;
 	void *end = ring->buf + ring->buf_size;
-	int frags = skb_shinfo(skb)->nr_frags;
+	struct sk_buff *skb = tx_info->skb;
+	int nr_maps = tx_info->nr_maps;
 	int i;
-	struct skb_shared_hwtstamps hwts;
 
-	if (timestamp) {
-		mlx4_en_fill_hwtstamps(mdev, &hwts, timestamp);
+	if (unlikely(timestamp)) {
+		struct skb_shared_hwtstamps hwts;
+
+		mlx4_en_fill_hwtstamps(priv->mdev, &hwts, timestamp);
 		skb_tstamp_tx(skb, &hwts);
 	}
 
 	/* Optimize the common case when there are no wraparounds */
 	if (likely((void *) tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
 		if (!tx_info->inl) {
-			if (tx_info->linear) {
+			if (tx_info->linear)
 				dma_unmap_single(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 be32_to_cpu(data->byte_count),
-					 PCI_DMA_TODEVICE);
-				++data;
-			}
-
-			for (i = 0; i < frags; i++) {
-				frag = &skb_shinfo(skb)->frags[i];
+						tx_info->map0_dma,
+						tx_info->map0_byte_count,
+						PCI_DMA_TODEVICE);
+			else
+				dma_unmap_page(priv->ddev,
+					       tx_info->map0_dma,
+					       tx_info->map0_byte_count,
+					       PCI_DMA_TODEVICE);
+			for (i = 1; i < nr_maps; i++) {
+				data++;
 				dma_unmap_page(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data[i].addr),
-					skb_frag_size(frag), PCI_DMA_TODEVICE);
+					(dma_addr_t)be64_to_cpu(data->addr),
+					be32_to_cpu(data->byte_count),
+					PCI_DMA_TODEVICE);
 			}
 		}
 	} else {
@@ -299,23 +301,25 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				data = ring->buf + ((void *)data - end);
 			}
 
-			if (tx_info->linear) {
+			if (tx_info->linear)
 				dma_unmap_single(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 be32_to_cpu(data->byte_count),
-					 PCI_DMA_TODEVICE);
-				++data;
-			}
-
-			for (i = 0; i < frags; i++) {
+						tx_info->map0_dma,
+						tx_info->map0_byte_count,
+						PCI_DMA_TODEVICE);
+			else
+				dma_unmap_page(priv->ddev,
+					       tx_info->map0_dma,
+					       tx_info->map0_byte_count,
+					       PCI_DMA_TODEVICE);
+			for (i = 1; i < nr_maps; i++) {
+				data++;
 				/* Check for wraparound before unmapping */
 				if ((void *) data >= end)
 					data = ring->buf;
-				frag = &skb_shinfo(skb)->frags[i];
 				dma_unmap_page(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 skb_frag_size(frag), PCI_DMA_TODEVICE);
-				++data;
+					(dma_addr_t)be64_to_cpu(data->addr),
+					be32_to_cpu(data->byte_count),
+					PCI_DMA_TODEVICE);
 			}
 		}
 	}
@@ -751,19 +755,22 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
 			   !is_inline(ring->inline_thold, skb, NULL)) ? 1 : 0;
 
-	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
+	tx_info->nr_maps = skb_shinfo(skb)->nr_frags + tx_info->linear;
+	data += tx_info->nr_maps - 1;
 
 	if (is_inline(ring->inline_thold, skb, &fragptr)) {
 		tx_info->inl = 1;
 	} else {
+		dma_addr_t dma = 0;
+		u32 byte_count = 0;
+
 		/* Map fragments if any */
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
 			const struct skb_frag_struct *frag;
-			dma_addr_t dma;
-
 			frag = &skb_shinfo(skb)->frags[i];
+			byte_count = skb_frag_size(frag);
 			dma = skb_frag_dma_map(ddev, frag,
-					       0, skb_frag_size(frag),
+					       0, byte_count,
 					       DMA_TO_DEVICE);
 			if (dma_mapping_error(ddev, dma))
 				goto tx_drop_unmap;
@@ -771,14 +778,13 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			data->addr = cpu_to_be64(dma);
 			data->lkey = ring->mr_key;
 			wmb();
-			data->byte_count = cpu_to_be32(skb_frag_size(frag));
+			data->byte_count = cpu_to_be32(byte_count);
 			--data;
 		}
 
 		/* Map linear part if needed */
 		if (tx_info->linear) {
-			u32 byte_count = skb_headlen(skb) - lso_header_size;
-			dma_addr_t dma;
+			byte_count = skb_headlen(skb) - lso_header_size;
 
 			dma = dma_map_single(ddev, skb->data +
 					     lso_header_size, byte_count,
@@ -792,6 +798,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			data->byte_count = cpu_to_be32(byte_count);
 		}
 		tx_info->inl = 0;
+		/* tx completion can avoid cache line miss for common cases */
+		tx_info->map0_dma = dma;
+		tx_info->map0_byte_count = byte_count;
 	}
 
 	/*
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ab34461..a904030 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -216,12 +216,15 @@ enum cq_type {
 
 struct mlx4_en_tx_info {
 	struct sk_buff *skb;
+	dma_addr_t	map0_dma;
+	u32		map0_byte_count;
 	u32		nr_txbb;
 	u32		nr_bytes;
 	u8		linear;
 	u8		data_offset;
 	u8		inl;
 	u8		ts_requested;
+	u8		nr_maps;
 } ____cacheline_aligned_in_smp;
 
 
-- 
1.8.3.4
