From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Mon, 25 Apr 2016 15:15:23 +0200
Message-ID: <1461590139-1396745-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct mlx5e_channel_param is a large structure that is allocated
on the stack of mlx5e_open_channels, and with a recent change
it has grown beyond the warning size for the maximum stack
that a single function should use:

mellanox/mlx5/core/en_main.c: In function 'mlx5e_open_channels':
mellanox/mlx5/core/en_main.c:1325:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

The function is already using dynamic allocation and is not in
a fast path, so the easiest workaround is to use another kzalloc
for allocating the channel parameters.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: d3c9bc2743dc ("net/mlx5e: Added ICO SQs")
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 22742e1fbcb9..2ec547a80886 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1266,12 +1266,14 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 	param->icosq = true;
 }
 
-static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
-				      struct mlx5e_channel_param *cparam)
+static struct mlx5e_channel_param *mlx5e_build_channel_param(struct mlx5e_priv *priv)
 {
+	struct mlx5e_channel_param *cparam;
 	u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
 
-	memset(cparam, 0, sizeof(*cparam));
+	cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
+	if (!cparam)
+		return NULL;
 
 	mlx5e_build_rq_param(priv, &cparam->rq);
 	mlx5e_build_sq_param(priv, &cparam->sq);
@@ -1279,11 +1281,13 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 	mlx5e_build_rx_cq_param(priv, &cparam->rx_cq);
 	mlx5e_build_tx_cq_param(priv, &cparam->tx_cq);
 	mlx5e_build_ico_cq_param(priv, &cparam->icosq_cq, icosq_log_wq_sz);
+
+	return cparam;
 }
 
 static int mlx5e_open_channels(struct mlx5e_priv *priv)
 {
-	struct mlx5e_channel_param cparam;
+	struct mlx5e_channel_param *cparam;
 	int nch = priv->params.num_channels;
 	int err = -ENOMEM;
 	int i;
@@ -1298,9 +1302,12 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 	if (!priv->channel || !priv->txq_to_sq_map)
 		goto err_free_txq_to_sq_map;
 
-	mlx5e_build_channel_param(priv, &cparam);
+	cparam = mlx5e_build_channel_param(priv);
+	if (!cparam)
+		goto err_free_txq_to_sq_map;
+
 	for (i = 0; i < nch; i++) {
-		err = mlx5e_open_channel(priv, i, &cparam, &priv->channel[i]);
+		err = mlx5e_open_channel(priv, i, cparam, &priv->channel[i]);
 		if (err)
 			goto err_close_channels;
 	}
@@ -1311,11 +1318,13 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 			goto err_close_channels;
 	}
 
+	kfree(cparam);
 	return 0;
 
 err_close_channels:
 	for (i--; i >= 0; i--)
 		mlx5e_close_channel(priv->channel[i]);
+	kfree(cparam);
 
 err_free_txq_to_sq_map:
 	kfree(priv->txq_to_sq_map);
-- 
2.7.0
