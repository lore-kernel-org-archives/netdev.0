From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [net-next-2.6 PATCH 2/3] mlx4_en: Using real number of rings as RSS
 map size
Date: Sun, 19 Jul 2009 16:07:08 +0300
Message-ID: <4A631A7C.7090504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39278 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754250AbZGSNIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 09:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point in using more QPs then actual number of receive rings.
If the RSS function for two streams gives the same result modulo number
of rings, they will arrive to the same RX ring anyway.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |    5 +++--
 drivers/net/mlx4/en_netdev.c |    3 ---
 drivers/net/mlx4/en_rx.c     |   38 +++++++++++---------------------------
 drivers/net/mlx4/mlx4_en.h   |   11 ++---------
 4 files changed, 16 insertions(+), 41 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 9ed4a15..507e11f 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -218,8 +218,9 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
-		mdev->profile.prof[i].rx_ring_num =
-			min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
+		mdev->profile.prof[i].rx_ring_num = min_t(int,
+			roundup_pow_of_two(dev->caps.num_comp_vectors),
+			MAX_RX_RINGS);
 		mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
 			  mdev->profile.prof[i].rx_ring_num, i);
 	}
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c8a24dc..f8bbc5a 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1011,9 +1011,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (err)
 		goto out;
 
-	/* Populate Rx default RSS mappings */
-	mlx4_en_set_default_rss_map(priv, &priv->rss_map, priv->rx_ring_num *
-						RSS_FACTOR, priv->rx_ring_num);
 	/* Allocate page for receive rings */
 	err = mlx4_alloc_hwq_res(mdev->dev, &priv->res,
 				MLX4_EN_PAGE_SIZE, MLX4_EN_PAGE_SIZE);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 91bdfdf..47b178e 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -835,23 +835,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 
 /* RSS related functions */
 
-/* Calculate rss size and map each entry in rss table to rx ring */
-void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
-				 struct mlx4_en_rss_map *rss_map,
-				 int num_entries, int num_rings)
-{
-	int i;
-
-	rss_map->size = roundup_pow_of_two(num_entries);
-	en_dbg(DRV, priv, "Setting default RSS map of %d entires\n",
-	       rss_map->size);
-
-	for (i = 0; i < rss_map->size; i++) {
-		rss_map->map[i] = i % num_rings;
-		en_dbg(DRV, priv, "Entry %d ---> ring %d\n", i, rss_map->map[i]);
-	}
-}
-
 static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,
 				 int qpn, int srqn, int cqn,
 				 enum mlx4_qp_state *state,
@@ -902,16 +885,17 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	int good_qps = 0;
 
 	en_dbg(DRV, priv, "Configuring rss steering\n");
-	err = mlx4_qp_reserve_range(mdev->dev, rss_map->size,
-				    rss_map->size, &rss_map->base_qpn);
+	err = mlx4_qp_reserve_range(mdev->dev, priv->rx_ring_num,
+				    priv->rx_ring_num,
+				    &rss_map->base_qpn);
 	if (err) {
-		en_err(priv, "Failed reserving %d qps\n", rss_map->size);
+		en_err(priv, "Failed reserving %d qps\n", priv->rx_ring_num);
 		return err;
 	}
 
-	for (i = 0; i < rss_map->size; i++) {
-		cqn = priv->rx_ring[rss_map->map[i]].cqn;
-		srqn = priv->rx_ring[rss_map->map[i]].srq.srqn;
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		cqn = priv->rx_ring[i].cqn;
+		srqn = priv->rx_ring[i].srq.srqn;
 		qpn = rss_map->base_qpn + i;
 		err = mlx4_en_config_rss_qp(priv, qpn, srqn, cqn,
 					    &rss_map->state[i],
@@ -940,7 +924,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	ptr = ((void *) &context) + 0x3c;
 	rss_context = (struct mlx4_en_rss_context *) ptr;
-	rss_context->base_qpn = cpu_to_be32(ilog2(rss_map->size) << 24 |
+	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->hash_fn = rss_xor & 0x3;
@@ -967,7 +951,7 @@ rss_err:
 		mlx4_qp_remove(mdev->dev, &rss_map->qps[i]);
 		mlx4_qp_free(mdev->dev, &rss_map->qps[i]);
 	}
-	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, rss_map->size);
+	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, priv->rx_ring_num);
 	return err;
 }
 
@@ -983,13 +967,13 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 
-	for (i = 0; i < rss_map->size; i++) {
+	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
 			       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->qps[i]);
 		mlx4_qp_remove(mdev->dev, &rss_map->qps[i]);
 		mlx4_qp_free(mdev->dev, &rss_map->qps[i]);
 	}
-	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, rss_map->size);
+	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, priv->rx_ring_num);
 }
 
 
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index c7c5e86..2d76ff4 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -95,8 +95,6 @@
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
 #define MAX_TX_RINGS		16
 #define MAX_RX_RINGS		16
-#define MAX_RSS_MAP_SIZE	64
-#define RSS_FACTOR		2
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
 #define STAMP_STRIDE		64
@@ -377,11 +375,9 @@ struct mlx4_en_dev {
 
 
 struct mlx4_en_rss_map {
-	int size;
 	int base_qpn;
-	u16 map[MAX_RSS_MAP_SIZE];
-	struct mlx4_qp qps[MAX_RSS_MAP_SIZE];
-	enum mlx4_qp_state state[MAX_RSS_MAP_SIZE];
+	struct mlx4_qp qps[MAX_RX_RINGS];
+	enum mlx4_qp_state state[MAX_RX_RINGS];
 	struct mlx4_qp indir_qp;
 	enum mlx4_qp_state indir_state;
 };
@@ -555,9 +551,6 @@ int mlx4_en_map_buffer(struct mlx4_buf *buf);
 void mlx4_en_unmap_buffer(struct mlx4_buf *buf);
 
 void mlx4_en_calc_rx_buf(struct net_device *dev);
-void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
-				 struct mlx4_en_rss_map *rss_map,
-				 int num_entries, int num_rings);
 int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv);
 void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
-- 
1.6.0

