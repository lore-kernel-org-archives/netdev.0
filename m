From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 03/13] mlx4: get rid of frag_prefix_size
Date: Wed,  8 Mar 2017 08:17:08 -0800
Message-ID: <20170308161718.2867-4-edumazet@google.com>
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
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34473 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbdCHQRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:32 -0500
Received: by mail-pg0-f51.google.com with SMTP id 77so14839545pgc.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:30 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using per frag storage for frag_prefix_size is really silly.

mlx4_en_complete_rx_desc() has all needed info already.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 27 ++++++++++++---------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +--
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b78d6762e03fc9f0c9e8bfa710efc2e7c86ad306..118ea83cff089f614a11f99f6623358f200638a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -588,15 +588,14 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 				    int length)
 {
 	struct skb_frag_struct *skb_frags_rx = skb_shinfo(skb)->frags;
-	struct mlx4_en_frag_info *frag_info;
-	int nr;
+	struct mlx4_en_frag_info *frag_info = priv->frag_info;
+	int nr, frag_size;
 	dma_addr_t dma;
 
 	/* Collect used fragments while replacing them in the HW descriptors */
-	for (nr = 0; nr < priv->num_frags; nr++) {
-		frag_info = &priv->frag_info[nr];
-		if (length <= frag_info->frag_prefix_size)
-			break;
+	for (nr = 0;;) {
+		frag_size = min_t(int, length, frag_info->frag_size);
+
 		if (unlikely(!frags[nr].page))
 			goto fail;
 
@@ -606,15 +605,16 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 
 		__skb_fill_page_desc(skb, nr, frags[nr].page,
 				     frags[nr].page_offset,
-				     frag_info->frag_size);
+				     frag_size);
 
 		skb->truesize += frag_info->frag_stride;
 		frags[nr].page = NULL;
+		nr++;
+		length -= frag_size;
+		if (!length)
+			break;
+		frag_info++;
 	}
-	/* Adjust size of last fragment to match actual length */
-	if (nr > 0)
-		skb_frag_size_set(&skb_frags_rx[nr - 1],
-			length - priv->frag_info[nr - 1].frag_prefix_size);
 	return nr;
 
 fail:
@@ -1197,7 +1197,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	if (priv->tx_ring_num[TX_XDP]) {
 		priv->rx_page_order = 0;
 		priv->frag_info[0].frag_size = eff_mtu;
-		priv->frag_info[0].frag_prefix_size = 0;
 		/* This will gain efficient xdp frame recycling at the
 		 * expense of more costly truesize accounting
 		 */
@@ -1212,7 +1211,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			priv->frag_info[i].frag_size =
 				(eff_mtu > buf_size + frag_sizes[i]) ?
 					frag_sizes[i] : eff_mtu - buf_size;
-			priv->frag_info[i].frag_prefix_size = buf_size;
 			priv->frag_info[i].frag_stride =
 				ALIGN(priv->frag_info[i].frag_size,
 				      SMP_CACHE_BYTES);
@@ -1232,10 +1230,9 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	       eff_mtu, priv->num_frags);
 	for (i = 0; i < priv->num_frags; i++) {
 		en_err(priv,
-		       "  frag:%d - size:%d prefix:%d stride:%d\n",
+		       "  frag:%d - size:%d stride:%d\n",
 		       i,
 		       priv->frag_info[i].frag_size,
-		       priv->frag_info[i].frag_prefix_size,
 		       priv->frag_info[i].frag_stride);
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9d2c53ddb15c6d2262272a1b429f0ebde366e3ac..849aa8af4dd771cdd44fae25516980bd36ed45a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -472,9 +472,8 @@ struct mlx4_en_mc_list {
 
 struct mlx4_en_frag_info {
 	u16 frag_size;
-	u16 frag_prefix_size;
-	u32 frag_stride;
 	u16 rx_headroom;
+	u32 frag_stride;
 };
 
 #ifdef CONFIG_MLX4_EN_DCB
-- 
2.12.0.246.ga2ecc84866-goog
