From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/12] net/mlx5e: CQE compression control code reuse
Date: Tue, 24 Jan 2017 22:16:52 +0200
Message-ID: <20170124201652.2920-13-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54286 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750828AbdAXURU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:20 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

This patch is intended for code reuse of mlx5e_modify_rx_cqe_compression
function.

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c   |  7 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 13 ++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c      |  8 ++------
 4 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8d660a018bf8..46f728de9e76 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -787,7 +787,7 @@ void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
 			     struct ptp_clock_event *event);
 int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr);
 int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr);
-void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val);
+void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 349dc72cd2b6..37e66eef6fb5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -106,11 +106,12 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 		return -ERANGE;
 	}
 
+	mutex_lock(&priv->state_lock);
 	/* RX HW timestamp */
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		/* Reset CQE compression to Admin default */
-		mlx5e_modify_rx_cqe_compression(priv, priv->params.rx_cqe_compress_def);
+		mlx5e_modify_rx_cqe_compression_locked(priv, priv->params.rx_cqe_compress_def);
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
@@ -128,14 +129,16 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		/* Disable CQE compression */
 		netdev_warn(dev, "Disabling cqe compression");
-		mlx5e_modify_rx_cqe_compression(priv, false);
+		mlx5e_modify_rx_cqe_compression_locked(priv, false);
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
+		mutex_unlock(&priv->state_lock);
 		return -ERANGE;
 	}
 
 	memcpy(&priv->tstamp.hwtstamp_config, &config, sizeof(config));
+	mutex_unlock(&priv->state_lock);
 
 	return copy_to_user(ifr->ifr_data, &config,
 			    sizeof(config)) ? -EFAULT : 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 9d520f8d6d1a..6c1a5cb43f8c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1476,8 +1476,6 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	int err = 0;
-	bool reset;
 
 	if (!MLX5_CAP_GEN(mdev, cqe_compression))
 		return -ENOTSUPP;
@@ -1487,17 +1485,10 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 		return -EINVAL;
 	}
 
-	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
-
-	if (reset)
-		mlx5e_close_locked(netdev);
-
-	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, enable);
+	mlx5e_modify_rx_cqe_compression_locked(priv, enable);
 	priv->params.rx_cqe_compress_def = enable;
 
-	if (reset)
-		err = mlx5e_open_locked(netdev);
-	return err;
+	return 0;
 }
 
 static int mlx5e_handle_pflag(struct net_device *netdev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 20f116f8c457..ba50583ea3ed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -155,17 +155,15 @@ static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
 	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem) - 1;
 }
 
-void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
+void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val)
 {
 	bool was_opened;
 
 	if (!MLX5_CAP_GEN(priv->mdev, cqe_compression))
 		return;
 
-	mutex_lock(&priv->state_lock);
-
 	if (MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) == val)
-		goto unlock;
+		return;
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
@@ -176,8 +174,6 @@ void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
 	if (was_opened)
 		mlx5e_open_locked(priv->netdev);
 
-unlock:
-	mutex_unlock(&priv->state_lock);
 }
 
 #define RQ_PAGE_SIZE(rq) ((1 << rq->buff.page_order) << PAGE_SHIFT)
-- 
2.11.0
