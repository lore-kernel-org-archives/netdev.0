From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4_en: Disable blueflame using ethtool private flags
Date: Tue, 22 Jul 2014 15:44:10 +0300
Message-ID: <1406033052-16550-3-git-send-email-amirv@mellanox.com>
References: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47450 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750898AbaGVMpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 08:45:01 -0400
In-Reply-To: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the user to turn off the hardware feature called BlueFlame.
Since it is something specific to mlx4_en hardware, we control
the feature via ethtool private flags.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 57 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 13 ++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  5 +++
 4 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 68d763d..50e85cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -98,6 +98,10 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	drvinfo->eedump_len = 0;
 }
 
+static const char mlx4_en_priv_flags[][ETH_GSTRING_LEN] = {
+	"blueflame",
+};
+
 static const char main_strings[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -235,6 +239,8 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UC_LOOPBACK) * 2;
+	case ETH_SS_PRIV_FLAGS:
+		return ARRAY_SIZE(mlx4_en_priv_flags);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -358,6 +364,12 @@ static void mlx4_en_get_strings(struct net_device *dev,
 #endif
 		}
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		for (i = 0; i < ARRAY_SIZE(mlx4_en_priv_flags); i++)
+			strcpy(data + i * ETH_GSTRING_LEN,
+			       mlx4_en_priv_flags[i]);
+		break;
+
 	}
 }
 
@@ -1209,6 +1221,49 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 	return ret;
 }
 
+int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	bool bf_enabled_new = !!(flags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
+	bool bf_enabled_old = !!(priv->pflags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
+	int i;
+
+	if (bf_enabled_new == bf_enabled_old)
+		return 0; /* Nothing to do */
+
+	if (bf_enabled_new) {
+		bool bf_supported = true;
+
+		for (i = 0; i < priv->tx_ring_num; i++)
+			bf_supported &= priv->tx_ring[i]->bf_alloced;
+
+		if (!bf_supported) {
+			en_err(priv, "BlueFlame is not supported\n");
+			return -EINVAL;
+		}
+
+		priv->pflags |= MLX4_EN_PRIV_FLAGS_BLUEFLAME;
+	} else {
+		priv->pflags &= ~MLX4_EN_PRIV_FLAGS_BLUEFLAME;
+	}
+
+	for (i = 0; i < priv->tx_ring_num; i++)
+		priv->tx_ring[i]->bf_enabled = bf_enabled_new;
+
+	en_info(priv, "BlueFlame %s\n",
+		bf_enabled_new ?  "Enabled" : "Disabled");
+
+	return 0;
+}
+
+u32 mlx4_en_get_priv_flags(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return priv->pflags;
+}
+
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -1236,6 +1291,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_channels = mlx4_en_get_channels,
 	.set_channels = mlx4_en_set_channels,
 	.get_ts_info = mlx4_en_get_ts_info,
+	.set_priv_flags = mlx4_en_set_priv_flags,
+	.get_priv_flags = mlx4_en_get_priv_flags,
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 82708bd..bb536aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2465,6 +2465,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->port = port;
 	priv->port_up = false;
 	priv->flags = prof->flags;
+	priv->pflags = MLX4_EN_PRIV_FLAGS_BLUEFLAME;
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
 	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 5045bab..dae3da6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -126,8 +126,13 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 		ring->bf.uar = &mdev->priv_uar;
 		ring->bf.uar->map = mdev->uar_map;
 		ring->bf_enabled = false;
-	} else
-		ring->bf_enabled = true;
+		ring->bf_alloced = false;
+		priv->pflags &= ~MLX4_EN_PRIV_FLAGS_BLUEFLAME;
+	} else {
+		ring->bf_alloced = true;
+		ring->bf_enabled = !!(priv->pflags &
+				      MLX4_EN_PRIV_FLAGS_BLUEFLAME);
+	}
 
 	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
 	ring->queue_index = queue_index;
@@ -161,7 +166,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	struct mlx4_en_tx_ring *ring = *pring;
 	en_dbg(DRV, priv, "Destroying tx ring, qpn: %d\n", ring->qpn);
 
-	if (ring->bf_enabled)
+	if (ring->bf_alloced)
 		mlx4_bf_free(mdev->dev, &ring->bf);
 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
@@ -195,7 +200,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, user_prio, &ring->context);
-	if (ring->bf_enabled)
+	if (ring->bf_alloced)
 		ring->context.usr_page = cpu_to_be32(ring->bf.uar->index);
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2b19dd1..54c2774 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -93,6 +93,8 @@
  * OS related constants and tunables
  */
 
+#define MLX4_EN_PRIV_FLAGS_BLUEFLAME 1
+
 #define MLX4_EN_WATCHDOG_TIMEOUT	(15 * HZ)
 
 /* Use the maximum between 16384 and a single page */
@@ -278,6 +280,7 @@ struct mlx4_en_tx_ring {
 	unsigned long wake_queue;
 	struct mlx4_bf bf;
 	bool bf_enabled;
+	bool bf_alloced;
 	struct netdev_queue *tx_queue;
 	int hwtstamp_tx_type;
 	int inline_thold;
@@ -592,6 +595,8 @@ struct mlx4_en_priv {
 #endif
 	u64 tunnel_reg_id;
 	__be16 vxlan_port;
+
+	u32 pflags;
 };
 
 enum mlx4_en_wol {
-- 
1.8.3.4
