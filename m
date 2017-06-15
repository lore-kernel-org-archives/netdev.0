From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 02/10] net/mlx4_en: Optimized single ring steering
Date: Thu, 15 Jun 2017 14:35:32 +0300
Message-ID: <1497526540-30028-3-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36059 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752310AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Avoid touching RX QP RSS context when loading with only
one RX ring, to allow optimized A0 RX steering.

Enable by:
- loading mlx4_core with module param: log_num_mgm_entry_size = -6.
- then: ethtool -L <interface> rx 1

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

XDP_DROP packet rate:
-------------------------------------
     | Before    | After     | Gain |
IPv4 | 20.5 Mpps | 28.1 Mpps |  37% |
IPv6 | 18.4 Mpps | 28.1 Mpps |  53% |
-------------------------------------

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |  6 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 12 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 48 ++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/main.c      |  4 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 +-
 5 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index d94f981eafc4..56cdf38d150e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -125,9 +125,9 @@ void mlx4_en_update_loopback_state(struct net_device *dev,
 		priv->flags |= MLX4_EN_FLAG_ENABLE_HW_LOOPBACK;
 
 	mutex_lock(&priv->mdev->state_lock);
-	if (priv->mdev->dev->caps.flags2 &
-	    MLX4_DEV_CAP_FLAG2_UPDATE_QP_SRC_CHECK_LB &&
-	    priv->rss_map.indir_qp.qpn) {
+	if ((priv->mdev->dev->caps.flags2 &
+	     MLX4_DEV_CAP_FLAG2_UPDATE_QP_SRC_CHECK_LB) &&
+	    priv->rss_map.indir_qp && priv->rss_map.indir_qp->qpn) {
 		int i;
 		int err = 0;
 		int loopback = !!(features & NETIF_F_LOOPBACK);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c1de75fc399a..51ce111b719e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -596,6 +596,8 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 		return err;
 	}
 
+	en_info(priv, "Steering Mode %d\n", dev->caps.steering_mode);
+
 	if (dev->caps.steering_mode == MLX4_STEERING_MODE_A0) {
 		int base_qpn = mlx4_get_base_qpn(dev, priv->port);
 		*qpn = base_qpn + index;
@@ -1010,7 +1012,7 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 				memcpy(&mc_list[10], mclist->addr, ETH_ALEN);
 				mc_list[5] = priv->port;
 				err = mlx4_multicast_detach(mdev->dev,
-							    &priv->rss_map.indir_qp,
+							    priv->rss_map.indir_qp,
 							    mc_list,
 							    MLX4_PROT_ETH,
 							    mclist->reg_id);
@@ -1032,7 +1034,7 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 				/* needed for B0 steering support */
 				mc_list[5] = priv->port;
 				err = mlx4_multicast_attach(mdev->dev,
-							    &priv->rss_map.indir_qp,
+							    priv->rss_map.indir_qp,
 							    mc_list,
 							    priv->port, 0,
 							    MLX4_PROT_ETH,
@@ -1742,7 +1744,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	/* Attach rx QP to bradcast address */
 	eth_broadcast_addr(&mc_list[10]);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
-	if (mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+	if (mlx4_multicast_attach(mdev->dev, priv->rss_map.indir_qp, mc_list,
 				  priv->port, 0, MLX4_PROT_ETH,
 				  &priv->broadcast_id))
 		mlx4_warn(mdev, "Failed Attaching Broadcast\n");
@@ -1866,12 +1868,12 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	/* Detach All multicasts */
 	eth_broadcast_addr(&mc_list[10]);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
-	mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
+	mlx4_multicast_detach(mdev->dev, priv->rss_map.indir_qp, mc_list,
 			      MLX4_PROT_ETH, priv->broadcast_id);
 	list_for_each_entry(mclist, &priv->curr_list, list) {
 		memcpy(&mc_list[10], mclist->addr, ETH_ALEN);
 		mc_list[5] = priv->port;
-		mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
+		mlx4_multicast_detach(mdev->dev, priv->rss_map.indir_qp,
 				      mc_list, MLX4_PROT_ETH, mclist->reg_id);
 		if (mclist->tunnel_reg_id)
 			mlx4_flow_detach(mdev->dev, mclist->tunnel_reg_id);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 77abd1813047..c4edae854f1b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1099,11 +1099,14 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
+	u8 flags;
 
 	en_dbg(DRV, priv, "Configuring rss steering\n");
+
+	flags = priv->rx_ring_num == 1 ? MLX4_RESERVE_A0_QP : 0;
 	err = mlx4_qp_reserve_range(mdev->dev, priv->rx_ring_num,
 				    priv->rx_ring_num,
-				    &rss_map->base_qpn, 0);
+				    &rss_map->base_qpn, flags);
 	if (err) {
 		en_err(priv, "Failed reserving %d qps\n", priv->rx_ring_num);
 		return err;
@@ -1120,13 +1123,28 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 		++good_qps;
 	}
 
+	if (priv->rx_ring_num == 1) {
+		rss_map->indir_qp = &rss_map->qps[0];
+		priv->base_qpn = rss_map->indir_qp->qpn;
+		en_info(priv, "Optimized Non-RSS steering\n");
+		return 0;
+	}
+
+	rss_map->indir_qp = kzalloc(sizeof(*rss_map->indir_qp), GFP_KERNEL);
+	if (!rss_map->indir_qp) {
+		err = -ENOMEM;
+		goto rss_err;
+	}
+
 	/* Configure RSS indirection qp */
-	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp, GFP_KERNEL);
+	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, rss_map->indir_qp,
+			    GFP_KERNEL);
 	if (err) {
 		en_err(priv, "Failed to allocate RSS indirection QP\n");
 		goto rss_err;
 	}
-	rss_map->indir_qp.event = mlx4_en_sqp_event;
+
+	rss_map->indir_qp->event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
 				priv->rx_ring[0]->cqn, -1, &context);
 
@@ -1164,8 +1182,9 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 		err = -EINVAL;
 		goto indir_err;
 	}
+
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
-			       &rss_map->indir_qp, &rss_map->indir_state);
+			       rss_map->indir_qp, &rss_map->indir_state);
 	if (err)
 		goto indir_err;
 
@@ -1173,9 +1192,11 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 indir_err:
 	mlx4_qp_modify(mdev->dev, NULL, rss_map->indir_state,
-		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
-	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
-	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
+		       MLX4_QP_STATE_RST, NULL, 0, 0, rss_map->indir_qp);
+	mlx4_qp_remove(mdev->dev, rss_map->indir_qp);
+	mlx4_qp_free(mdev->dev, rss_map->indir_qp);
+	kfree(rss_map->indir_qp);
+	rss_map->indir_qp = NULL;
 rss_err:
 	for (i = 0; i < good_qps; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
@@ -1193,10 +1214,15 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
 	int i;
 
-	mlx4_qp_modify(mdev->dev, NULL, rss_map->indir_state,
-		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
-	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
-	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
+	if (priv->rx_ring_num > 1) {
+		mlx4_qp_modify(mdev->dev, NULL, rss_map->indir_state,
+			       MLX4_QP_STATE_RST, NULL, 0, 0,
+			       rss_map->indir_qp);
+		mlx4_qp_remove(mdev->dev, rss_map->indir_qp);
+		mlx4_qp_free(mdev->dev, rss_map->indir_qp);
+		kfree(rss_map->indir_qp);
+		rss_map->indir_qp = NULL;
+	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ccae3c6593c4..457e070bca46 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2356,8 +2356,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 					MLX4_A0_STEERING_TABLE_SIZE;
 			}
 
-			mlx4_dbg(dev, "DMFS high rate steer mode is: %s\n",
-				 dmfs_high_rate_steering_mode_str(
+			mlx4_info(dev, "DMFS high rate steer mode is: %s\n",
+				  dmfs_high_rate_steering_mode_str(
 					dev->caps.dmfs_high_steer_mode));
 		}
 	} else {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 08b2906a98af..41f4f8f9f300 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -431,7 +431,7 @@ struct mlx4_en_rss_map {
 	int base_qpn;
 	struct mlx4_qp qps[MAX_RX_RINGS];
 	enum mlx4_qp_state state[MAX_RX_RINGS];
-	struct mlx4_qp indir_qp;
+	struct mlx4_qp *indir_qp;
 	enum mlx4_qp_state indir_state;
 };
 
-- 
1.8.3.1
