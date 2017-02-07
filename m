From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/9] mlx4: reduce rx ring page_cache size
Date: Mon,  6 Feb 2017 19:02:37 -0800
Message-ID: <20170207030240.31357-7-edumazet@google.com>
References: <20170207030240.31357-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33782 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752489AbdBGDDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:45 -0500
Received: by mail-pf0-f170.google.com with SMTP id y143so28974246pfb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:44 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only need to store the page and dma address.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 17 ++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  2 --
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  6 +++++-
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 80bb3c15f7c169f7091eb4a8dc06804f98b6..6c95694f6390aa9fbc5f941a97e305815949 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -250,7 +250,10 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 					(index << priv->log_rx_info);
 
 	if (ring->page_cache.index > 0) {
-		frags[0] = ring->page_cache.buf[--ring->page_cache.index];
+		ring->page_cache.index--;
+		frags[0].page = ring->page_cache.buf[ring->page_cache.index].page;
+		frags[0].dma  = ring->page_cache.buf[ring->page_cache.index].dma;
+		frags[0].page_offset = XDP_PACKET_HEADROOM;
 		rx_desc->data[0].addr = cpu_to_be64(frags[0].dma +
 						    frags[0].page_offset);
 		return 0;
@@ -534,7 +537,9 @@ bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
 	if (cache->index >= MLX4_EN_CACHE_SIZE)
 		return false;
 
-	cache->buf[cache->index++] = *frame;
+	cache->buf[cache->index].page = frame->page;
+	cache->buf[cache->index].dma = frame->dma;
+	cache->index++;
 	return true;
 }
 
@@ -564,11 +569,9 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 	int i;
 
 	for (i = 0; i < ring->page_cache.index; i++) {
-		struct mlx4_en_rx_alloc *frame = &ring->page_cache.buf[i];
-
-		dma_unmap_page(priv->ddev, frame->dma, frame->page_size,
-			       priv->dma_dir);
-		put_page(frame->page);
+		dma_unmap_page(priv->ddev, ring->page_cache.buf[i].dma,
+			       PAGE_SIZE, priv->dma_dir);
+		put_page(ring->page_cache.buf[i].page);
 	}
 	ring->page_cache.index = 0;
 	mlx4_en_free_rx_buf(priv, ring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 98bc67a7249b14f8857fe1fd6baa40ae3ec5..e0c5ffb3e3a6607456e1f191b0b8c8becfc7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -354,8 +354,6 @@ u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_alloc frame = {
 		.page = tx_info->page,
 		.dma = tx_info->map0_dma,
-		.page_offset = XDP_PACKET_HEADROOM,
-		.page_size = PAGE_SIZE,
 	};
 
 	if (!mlx4_en_rx_recycle(ring->recycle_ring, &frame)) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 5d65a60e93b7a2ae84312cd0f2d474a065d9..c9916b75b94bc9364b2cbe6da06a5ea385c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -267,9 +267,13 @@ struct mlx4_en_rx_alloc {
 };
 
 #define MLX4_EN_CACHE_SIZE (2 * NAPI_POLL_WEIGHT)
+
 struct mlx4_en_page_cache {
 	u32 index;
-	struct mlx4_en_rx_alloc buf[MLX4_EN_CACHE_SIZE];
+	struct {
+		struct page	*page;
+		dma_addr_t	dma;
+	} buf[MLX4_EN_CACHE_SIZE];
 };
 
 struct mlx4_en_priv;
-- 
2.11.0.483.g087da7b7c-goog
