From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/6] net/mlx5e: Update MPWQE stride size when modifying CQE compress state
Date: Wed, 22 Feb 2017 17:20:15 +0200
Message-ID: <20170222152016.31263-6-saeedm@mellanox.com>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57767 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933018AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the admin enables/disables cqe compression, updating
mpwqe stride size is required:
    CQE compress ON  ==> stride size = 256B
    CQE compress OFF ==> stride size = 64B

This is already done on driver load via mlx5e_set_rq_type_params, all we
need is just to call it on arbitrary admin changes of cqe compression
state via priv flags or when changing timestamping state
(as it is mutually exclusive with cqe compression).

This bug introduces no functional damage, it only makes cqe compression
occur less often, since in ConnectX4-LX CQE compression is performed
only on packets smaller than stride size.

Tested:
 ethtool --set-priv-flags ethxx rx_cqe_compress on
 pktgen with  64 < pkt size < 256 and netperf TCP_STREAM (IPv4/IPv6)
 verify `ethtool -S ethxx | grep compress` are advancing more often
 (rapidly)

Fixes: 7219ab34f184 ("net/mlx5e: CQE compression")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c      | 1 +
 4 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 95ca03c0d9f5..f6a6ded204f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -816,6 +816,7 @@ int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 
 void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 				 u8 cq_period_mode);
+void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index cc80522b5854..a004a5a1a4c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1487,6 +1487,7 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 
 	mlx5e_modify_rx_cqe_compression_locked(priv, enable);
 	priv->params.rx_cqe_compress_def = enable;
+	mlx5e_set_rq_type_params(priv, priv->params.rq_wq_type);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index dc621bc4e173..8ef64c4db2c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -79,7 +79,7 @@ static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
 		MLX5_CAP_ETH(mdev, reg_umr_sq);
 }
 
-static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
+void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 {
 	priv->params.rq_wq_type = rq_type;
 	priv->params.lro_wqe_sz = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 9fad22768aab..d5ce20db3f0b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -172,6 +172,7 @@ void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val)
 		mlx5e_close_locked(priv->netdev);
 
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
+	mlx5e_set_rq_type_params(priv, priv->params.rq_wq_type);
 
 	if (was_opened)
 		mlx5e_open_locked(priv->netdev);
-- 
2.11.0
