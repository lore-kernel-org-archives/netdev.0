From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 03/14] mlx4: remove order field from mlx4_en_frag_info
Date: Mon, 13 Feb 2017 11:58:47 -0800
Message-ID: <20170213195858.5215-4-edumazet@google.com>
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
Received: from mail-it0-f42.google.com ([209.85.214.42]:35419 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753010AbdBMT7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 14:59:23 -0500
Received: by mail-it0-f42.google.com with SMTP id 203so1068907ith.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 11:59:18 -0800 (PST)
In-Reply-To: <20170213195858.5215-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is really a port attribute, no need to duplicate it per
RX queue and per frag.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6183128b2d3d0519b46d14152b15c95ebbf62db7..b78d6762e03fc9f0c9e8bfa710efc2e7c86ad306 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -59,7 +59,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	struct page *page;
 	dma_addr_t dma;
 
-	for (order = frag_info->order; ;) {
+	for (order = priv->rx_page_order; ;) {
 		gfp_t gfp = _gfp;
 
 		if (order)
@@ -1195,7 +1195,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	 * This only works when num_frags == 1.
 	 */
 	if (priv->tx_ring_num[TX_XDP]) {
-		priv->frag_info[0].order = 0;
+		priv->rx_page_order = 0;
 		priv->frag_info[0].frag_size = eff_mtu;
 		priv->frag_info[0].frag_prefix_size = 0;
 		/* This will gain efficient xdp frame recycling at the
@@ -1209,7 +1209,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		int buf_size = 0;
 
 		while (buf_size < eff_mtu) {
-			priv->frag_info[i].order = MLX4_EN_ALLOC_PREFER_ORDER;
 			priv->frag_info[i].frag_size =
 				(eff_mtu > buf_size + frag_sizes[i]) ?
 					frag_sizes[i] : eff_mtu - buf_size;
@@ -1221,6 +1220,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			buf_size += priv->frag_info[i].frag_size;
 			i++;
 		}
+		priv->rx_page_order = MLX4_EN_ALLOC_PREFER_ORDER;
 		priv->dma_dir = PCI_DMA_FROMDEVICE;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c914915075b06fa60758cad44119507b1c55a57d..670eed48cf3c3f6f76e86e077c997d6f8e655d69 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -474,7 +474,6 @@ struct mlx4_en_frag_info {
 	u16 frag_size;
 	u16 frag_prefix_size;
 	u32 frag_stride;
-	u16 order;
 	u16 rx_headroom;
 };
 
@@ -586,6 +585,7 @@ struct mlx4_en_priv {
 	u8 num_frags;
 	u8 log_rx_info;
 	u8 dma_dir;
+	u8 rx_page_order;
 
 	struct mlx4_en_tx_ring **tx_ring[MLX4_EN_NUM_TX_TYPES];
 	struct mlx4_en_rx_ring *rx_ring[MAX_RX_RINGS];
-- 
2.11.0.483.g087da7b7c-goog
