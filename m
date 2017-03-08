From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 01/13] mlx4: dma_dir is a mlx4_en_priv attribute
Date: Wed,  8 Mar 2017 08:17:06 -0800
Message-ID: <20170308161718.2867-2-edumazet@google.com>
References: <20170308161718.2867-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33024 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdCHQR0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:26 -0500
Received: by mail-pg0-f41.google.com with SMTP id 25so14901474pgy.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:25 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate it for all queues and frags.

num_frags & log_rx_info become u8 to save space.
u8 accesses are a bit faster than u16 anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 16 ++++++++--------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  6 +++---
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 867292880c07a15124a0cf099d1fcda09926548e..6183128b2d3d0519b46d14152b15c95ebbf62db7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -72,7 +72,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 			return -ENOMEM;
 	}
 	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
-			   frag_info->dma_dir);
+			   priv->dma_dir);
 	if (unlikely(dma_mapping_error(priv->ddev, dma))) {
 		put_page(page);
 		return -ENOMEM;
@@ -128,7 +128,7 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 		if (page_alloc[i].page != ring_alloc[i].page) {
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
 				page_alloc[i].page_size,
-				priv->frag_info[i].dma_dir);
+				priv->dma_dir);
 			page = page_alloc[i].page;
 			/* Revert changes done by mlx4_alloc_pages */
 			page_ref_sub(page, page_alloc[i].page_size /
@@ -149,7 +149,7 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 
 	if (next_frag_end > frags[i].page_size)
 		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
-			       frag_info->dma_dir);
+			       priv->dma_dir);
 
 	if (frags[i].page)
 		put_page(frags[i].page);
@@ -181,7 +181,7 @@ static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
 		page_alloc = &ring->page_alloc[i];
 		dma_unmap_page(priv->ddev, page_alloc->dma,
 			       page_alloc->page_size,
-			       priv->frag_info[i].dma_dir);
+			       priv->dma_dir);
 		page = page_alloc->page;
 		/* Revert changes done by mlx4_alloc_pages */
 		page_ref_sub(page, page_alloc->page_size /
@@ -206,7 +206,7 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
 		       i, page_count(page_alloc->page));
 
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-				page_alloc->page_size, frag_info->dma_dir);
+				page_alloc->page_size, priv->dma_dir);
 		while (page_alloc->page_offset + frag_info->frag_stride <
 		       page_alloc->page_size) {
 			put_page(page_alloc->page);
@@ -570,7 +570,7 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 		struct mlx4_en_rx_alloc *frame = &ring->page_cache.buf[i];
 
 		dma_unmap_page(priv->ddev, frame->dma, frame->page_size,
-			       priv->frag_info[0].dma_dir);
+			       priv->dma_dir);
 		put_page(frame->page);
 	}
 	ring->page_cache.index = 0;
@@ -1202,7 +1202,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		 * expense of more costly truesize accounting
 		 */
 		priv->frag_info[0].frag_stride = PAGE_SIZE;
-		priv->frag_info[0].dma_dir = PCI_DMA_BIDIRECTIONAL;
+		priv->dma_dir = PCI_DMA_BIDIRECTIONAL;
 		priv->frag_info[0].rx_headroom = XDP_PACKET_HEADROOM;
 		i = 1;
 	} else {
@@ -1217,11 +1217,11 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			priv->frag_info[i].frag_stride =
 				ALIGN(priv->frag_info[i].frag_size,
 				      SMP_CACHE_BYTES);
-			priv->frag_info[i].dma_dir = PCI_DMA_FROMDEVICE;
 			priv->frag_info[i].rx_headroom = 0;
 			buf_size += priv->frag_info[i].frag_size;
 			i++;
 		}
+		priv->dma_dir = PCI_DMA_FROMDEVICE;
 	}
 
 	priv->num_frags = i;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 3ed42199d3f1275f77560e92a430c0dde181e95a..98bc67a7249b14f8857fe1fd6baa40ae3ec5a880 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -360,7 +360,7 @@ u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 
 	if (!mlx4_en_rx_recycle(ring->recycle_ring, &frame)) {
 		dma_unmap_page(priv->ddev, tx_info->map0_dma,
-			       PAGE_SIZE, priv->frag_info[0].dma_dir);
+			       PAGE_SIZE, priv->dma_dir);
 		put_page(tx_info->page);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3629ce11a68b9dec5c1659539bdc6f2c11114e35..a4c7d94d52c698c23c9768a4c0387378898cdbc5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -474,7 +474,6 @@ struct mlx4_en_frag_info {
 	u16 frag_size;
 	u16 frag_prefix_size;
 	u32 frag_stride;
-	enum dma_data_direction dma_dir;
 	u16 order;
 	u16 rx_headroom;
 };
@@ -584,8 +583,9 @@ struct mlx4_en_priv {
 	u32 rx_ring_num;
 	u32 rx_skb_size;
 	struct mlx4_en_frag_info frag_info[MLX4_EN_MAX_RX_FRAGS];
-	u16 num_frags;
-	u16 log_rx_info;
+	u8 num_frags;
+	u8 log_rx_info;
+	u8 dma_dir;
 
 	struct mlx4_en_tx_ring **tx_ring[MLX4_EN_NUM_TX_TYPES];
 	struct mlx4_en_rx_ring *rx_ring[MAX_RX_RINGS];
-- 
2.12.0.246.ga2ecc84866-goog
