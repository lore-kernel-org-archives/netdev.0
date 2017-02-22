From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/6] net/mlx5e: Fix broken CQE compression initialization
Date: Wed, 22 Feb 2017 17:20:14 +0200
Message-ID: <20170222152016.31263-5-saeedm@mellanox.com>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57753 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933000AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Some of RQ type parameters are derived from CQE compression state flag,
CQE compression flag was initialized only after RQ type parameters
setup. This leads to load RQ with stride size smaller than what we
want for when CQE compression is on.

This bug introduces no functional damage, it only makes CQE compression
occur less often, since in ConnectX4-LX CQE compression is performed
only on packets smaller than stride size.

Fix this by marking default status of CQE compression in PFLAG prior to
calling mlx5e_set_rq_priv_params(), as it inits some fields based on it.

Tested:
 load driver on systems where rx CQE compress will be on (MH)
 pktgen with  64 < pkt size < 256 and netperf TCP_STREAM (IPv4/IPv6)
 verify `ethtool -S ethxx | grep compress` are advancing more often
 (rapidly)

Fixes: 2fc4bfb7250d ("net/mlx5e: Dynamic RQ type infrastructure")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0d58729b42ae..dc621bc4e173 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3526,6 +3526,9 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 			cqe_compress_heuristic(link_speed, pci_bw);
 	}
 
+	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS,
+			priv->params.rx_cqe_compress_def);
+
 	mlx5e_set_rq_priv_params(priv);
 	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		priv->params.lro_en = true;
@@ -3555,7 +3558,6 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	/* Initialize pflags */
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
 			priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
-	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, priv->params.rx_cqe_compress_def);
 
 	mutex_init(&priv->state_lock);
 
-- 
2.11.0
