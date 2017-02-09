From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 06/14] mlx4: reduce rx ring page_cache size
Date: Thu,  9 Feb 2017 05:58:30 -0800
Message-ID: <20170209135838.16487-7-edumazet@google.com>
References: <20170209135838.16487-1-edumazet@google.com>
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
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35730 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdBIOIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:08:43 -0500
Received: by mail-pg0-f54.google.com with SMTP id 194so1130273pgd.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:07:10 -0800 (PST)
In-Reply-To: <20170209135838.16487-1-edumazet@google.com>
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
index bb33032a280f00ee62cc39d4261e72543ed0..453313d404e3698b0d41a8220005b3834c9d 100644
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
@@ -537,7 +540,9 @@ bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
 	if (cache->index >= MLX4_EN_CACHE_SIZE)
 		return false;
 
-	cache->buf[cache->index++] = *frame;
+	cache->buf[cache->index].page = frame->page;
+	cache->buf[cache->index].dma = frame->dma;
+	cache->index++;
 	return true;
 }
 
@@ -567,11 +572,9 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
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
index 535bf2478d5fe7433b83687e04dedccf1278..d92e5228d4248f28151cba117a9485c71ef5 100644
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
