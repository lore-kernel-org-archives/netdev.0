From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 2/7] net/mlx5e: Fix LRO modify
Date: Mon, 29 Feb 2016 21:17:10 +0200
Message-ID: <1456773435-16607-3-git-send-email-saeedm@mellanox.com>
References: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53120 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753637AbcB2TSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 14:18:05 -0500
In-Reply-To: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Ethtool LRO enable/disable is broken, as of today we only modify TCP
TIRs in order to apply the requested configuration.

Hardware requires that all TIRs pointing to the same RQ should share the
same LRO configuration. For that all other TIRs' LRO fields must be
modified as well.

Fixes: 5c50368f3831 ('net/mlx5e: Light-weight netdev open/stop')
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d4e1c30..137b05e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1317,7 +1317,7 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 			      lro_timer_supported_periods[2]));
 }
 
-static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
+static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 
@@ -1325,6 +1325,7 @@ static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
 	void *tirc;
 	int inlen;
 	int err;
+	int tt;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
 	in = mlx5_vzalloc(inlen);
@@ -1336,7 +1337,11 @@ static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
 
 	mlx5e_build_tir_ctx_lro(tirc, priv);
 
-	err = mlx5_core_modify_tir(mdev, priv->tirn[tt], in, inlen);
+	for (tt = 0; tt < MLX5E_NUM_TT; tt++) {
+		err = mlx5_core_modify_tir(mdev, priv->tirn[tt], in, inlen);
+		if (err)
+			break;
+	}
 
 	kvfree(in);
 
@@ -1885,8 +1890,10 @@ static int mlx5e_set_features(struct net_device *netdev,
 			mlx5e_close_locked(priv->netdev);
 
 		priv->params.lro_en = !!(features & NETIF_F_LRO);
-		mlx5e_modify_tir_lro(priv, MLX5E_TT_IPV4_TCP);
-		mlx5e_modify_tir_lro(priv, MLX5E_TT_IPV6_TCP);
+		err = mlx5e_modify_tirs_lro(priv);
+		if (err)
+			mlx5_core_warn(priv->mdev, "lro modify failed, %d\n",
+				       err);
 
 		if (was_opened)
 			err = mlx5e_open_locked(priv->netdev);
-- 
1.7.1
