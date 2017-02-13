From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 05/14] mlx4: rx_headroom is a per port attribute
Date: Mon, 13 Feb 2017 11:58:49 -0800
Message-ID: <20170213195858.5215-6-edumazet@google.com>
References: <20170213195858.5215-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35985 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753090AbdBMT71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 14:59:27 -0500
Received: by mail-oi0-f44.google.com with SMTP id u143so57165011oif.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 11:59:27 -0800 (PST)
In-Reply-To: <20170213195858.5215-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate it per RX queue / frags.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 118ea83cff089f614a11f99f6623358f200638a8..bb33032a280f00ee62cc39d4261e72543ed0434e 100644
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
@@ -1202,7 +1202,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		 */
 		priv->frag_info[0].frag_stride = PAGE_SIZE;
 		priv->dma_dir = PCI_DMA_BIDIRECTIONAL;
-		priv->frag_info[0].rx_headroom = XDP_PACKET_HEADROOM;
+		priv->rx_headroom = XDP_PACKET_HEADROOM;
 		i = 1;
 	} else {
 		int buf_size = 0;
@@ -1214,12 +1214,12 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
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
index edd0f89fc1a1fdb711b8a8aefb4872fec23a5611..535bf2478d5fe7433b83687e04dedccf127838c7 100644
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
