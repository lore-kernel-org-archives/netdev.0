From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 17:52:33 +0200
Message-ID: <1461685993-1049370-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:52087 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbcDZPxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
v2: move allocation back into caller, as suggested by Saeed Mahameed

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index af8c54d2e99c..7106006c792b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1266,13 +1266,10 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 	param->icosq = true;
 }
 
-static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
-				      struct mlx5e_channel_param *cparam)
+static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_channel_param *cparam)
 {
 	u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
 
-	memset(cparam, 0, sizeof(*cparam));
-
 	mlx5e_build_rq_param(priv, &cparam->rq);
 	mlx5e_build_sq_param(priv, &cparam->sq);
 	mlx5e_build_icosq_param(priv, &cparam->icosq, icosq_log_wq_sz);
@@ -1283,7 +1280,7 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 
 static int mlx5e_open_channels(struct mlx5e_priv *priv)
 {
-	struct mlx5e_channel_param cparam;
+	struct mlx5e_channel_param *cparam;
 	int nch = priv->params.num_channels;
 	int err = -ENOMEM;
 	int i;
@@ -1295,12 +1292,15 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 	priv->txq_to_sq_map = kcalloc(nch * priv->params.num_tc,
 				      sizeof(struct mlx5e_sq *), GFP_KERNEL);
 
-	if (!priv->channel || !priv->txq_to_sq_map)
+	cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
+
+	if (!priv->channel || !priv->txq_to_sq_map || !cparam)
 		goto err_free_txq_to_sq_map;
 
-	mlx5e_build_channel_param(priv, &cparam);
+	mlx5e_build_channel_param(priv, cparam);
+
 	for (i = 0; i < nch; i++) {
-		err = mlx5e_open_channel(priv, i, &cparam, &priv->channel[i]);
+		err = mlx5e_open_channel(priv, i, cparam, &priv->channel[i]);
 		if (err)
 			goto err_close_channels;
 	}
@@ -1311,6 +1311,7 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 			goto err_close_channels;
 	}
 
+	kfree(cparam);
 	return 0;
 
 err_close_channels:
@@ -1320,6 +1321,7 @@ err_close_channels:
 err_free_txq_to_sq_map:
 	kfree(priv->txq_to_sq_map);
 	kfree(priv->channel);
+	kfree(cparam);
 
 	return err;
 }
-- 
2.7.0
