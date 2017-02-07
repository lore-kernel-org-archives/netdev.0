From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/9] mlx4: rx_headroom is a per port attribute
Date: Mon,  6 Feb 2017 19:02:36 -0800
Message-ID: <20170207030240.31357-6-edumazet@google.com>
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
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36780 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752489AbdBGDDd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:33 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so28942503pfu.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:33 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate it per RX queue / frags.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c6c64ac1e25931fc172beb5c718ec3a799f6..80bb3c15f7c169f7091eb4a8dc06804f98b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -115,7 +115,7 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 
 	for (i = 0; i < priv->num_frags; i++) {
 		frags[i] = ring_alloc[i];
-		frags[i].page_offset += priv->frag_info[i].rx_headroom;
+		frags[i].page_offset += priv->rx_headroom;
 		rx_desc->data[i].addr = cpu_to_be64(frags[i].dma +
 						    frags[i].page_offset);
 		ring_alloc[i] = page_alloc[i];
@@ -1199,7 +1199,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		 */
 		priv->frag_info[0].frag_stride = PAGE_SIZE;
 		priv->dma_dir = PCI_DMA_BIDIRECTIONAL;
-		priv->frag_info[0].rx_headroom = XDP_PACKET_HEADROOM;
+		priv->rx_headroom = XDP_PACKET_HEADROOM;
 		i = 1;
 	} else {
 		int buf_size = 0;
@@ -1211,12 +1211,12 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			priv->frag_info[i].frag_stride =
 				ALIGN(priv->frag_info[i].frag_size,
 				      SMP_CACHE_BYTES);
-			priv->frag_info[i].rx_headroom = 0;
 			buf_size += priv->frag_info[i].frag_size;
 			i++;
 		}
 		priv->rx_page_order = MLX4_EN_ALLOC_PREFER_ORDER;
 		priv->dma_dir = PCI_DMA_FROMDEVICE;
+		priv->rx_headroom = 0;
 	}
 
 	priv->num_frags = i;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index fe8ed4e85e9645679cc37d0d30284b523689..5d65a60e93b7a2ae84312cd0f2d474a065d9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -472,7 +472,6 @@ struct mlx4_en_mc_list {
 
 struct mlx4_en_frag_info {
 	u16 frag_size;
-	u16 rx_headroom;
 	u32 frag_stride;
 };
 
@@ -585,6 +584,7 @@ struct mlx4_en_priv {
 	u8 log_rx_info;
 	u8 dma_dir;
 	u8 rx_page_order;
+	u16 rx_headroom;
 
 	struct mlx4_en_tx_ring **tx_ring[MLX4_EN_NUM_TX_TYPES];
 	struct mlx4_en_rx_ring *rx_ring[MAX_RX_RINGS];
-- 
2.11.0.483.g087da7b7c-goog
