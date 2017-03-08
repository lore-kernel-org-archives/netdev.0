From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 06/13] mlx4: removal of frag_sizes[]
Date: Wed,  8 Mar 2017 08:17:11 -0800
Message-ID: <20170308161718.2867-7-edumazet@google.com>
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
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33211 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753661AbdCHQRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:38 -0500
Received: by mail-pf0-f176.google.com with SMTP id w189so16563437pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:37 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon use order-0 pages, and frag truesize will more precisely
match real sizes.

In the new model, we prefer to use <= 2048 bytes fragments, so that
we can use page-recycle technique on PAGE_SIZE=4096 arches.

We will still pack as much frames as possible on arches with big
pages, like PowerPC.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 24 ++++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  8 --------
 2 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 453313d404e3698b0d41a8220005b3834c9d68a1..0c61c1200f2aec4c74d7403d9ec3ed06821c1bac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1181,13 +1181,6 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	return done;
 }
 
-static const int frag_sizes[] = {
-	FRAG_SZ0,
-	FRAG_SZ1,
-	FRAG_SZ2,
-	FRAG_SZ3
-};
-
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1211,13 +1204,16 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		int buf_size = 0;
 
 		while (buf_size < eff_mtu) {
-			priv->frag_info[i].frag_size =
-				(eff_mtu > buf_size + frag_sizes[i]) ?
-					frag_sizes[i] : eff_mtu - buf_size;
-			priv->frag_info[i].frag_stride =
-				ALIGN(priv->frag_info[i].frag_size,
-				      SMP_CACHE_BYTES);
-			buf_size += priv->frag_info[i].frag_size;
+			int frag_size = eff_mtu - buf_size;
+
+			if (i < MLX4_EN_MAX_RX_FRAGS - 1)
+				frag_size = min(frag_size, 2048);
+
+			priv->frag_info[i].frag_size = frag_size;
+
+			priv->frag_info[i].frag_stride = ALIGN(frag_size,
+							       SMP_CACHE_BYTES);
+			buf_size += frag_size;
 			i++;
 		}
 		priv->rx_page_order = MLX4_EN_ALLOC_PREFER_ORDER;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c98940c6acd02c1bd8c4f82107d82979ead051d1..608396dc6d95a05cd88bcf054df990298365ecfa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -105,14 +105,6 @@
 #define MLX4_EN_ALLOC_PREFER_ORDER min_t(int, get_order(32768),		\
 					 PAGE_ALLOC_COSTLY_ORDER)
 
-/* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
- * and 4K allocations) */
-enum {
-	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
-	FRAG_SZ1 = 4096,
-	FRAG_SZ2 = 4096,
-	FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
-};
 #define MLX4_EN_MAX_RX_FRAGS	4
 
 /* Maximum ring sizes */
-- 
2.12.0.246.ga2ecc84866-goog
