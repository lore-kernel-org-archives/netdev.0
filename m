From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/9] mlx4: removal of frag_sizes[]
Date: Mon,  6 Feb 2017 19:02:38 -0800
Message-ID: <20170207030240.31357-8-edumazet@google.com>
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
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36788 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbdBGDDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:47 -0500
Received: by mail-pf0-f182.google.com with SMTP id 189so28942974pfu.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:41 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
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
index 6c95694f6390aa9fbc5f941a97e305815949..dd3bfcfea10c4545dfeda0f999449b13ca91 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1178,13 +1178,6 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
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
@@ -1208,13 +1201,16 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
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
index c9916b75b94bc9364b2cbe6da06a5ea385c6..a5bb0103ad8fd3b3f4b3d16099b7bf7ba01b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -104,14 +104,6 @@
 
 #define MLX4_EN_ALLOC_PREFER_ORDER	PAGE_ALLOC_COSTLY_ORDER
 
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
2.11.0.483.g087da7b7c-goog
