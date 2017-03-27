From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/14] net/mlx5e: Set SQ max rate on mlx5e_open_txqsq rather on open_channel
Date: Mon, 27 Mar 2017 23:48:57 +0300
Message-ID: <20170327204910.20287-2-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44883 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752542AbdC0UuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:06 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of iterating over the channel SQs to set their max rate, do it
on SQ creation per TXQ SQ.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e849a0fc2653..469d6c147db7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1207,6 +1207,9 @@ static int mlx5e_create_sq_rdy(struct mlx5e_priv *priv,
 	return err;
 }
 
+static int mlx5e_set_sq_maxrate(struct net_device *dev,
+				struct mlx5e_txqsq *sq, u32 rate);
+
 static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 			    int tc,
 			    struct mlx5e_sq_param *param,
@@ -1214,6 +1217,8 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 {
 	struct mlx5e_create_sq_param csp = {};
 	struct mlx5e_priv *priv = c->priv;
+	u32 tx_rate;
+	int txq_ix;
 	int err;
 
 	err = mlx5e_alloc_txqsq(c, tc, param, sq);
@@ -1230,6 +1235,11 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	if (err)
 		goto err_free_txqsq;
 
+	txq_ix = c->ix + tc * priv->params.num_channels;
+	tx_rate = priv->tx_rates[txq_ix];
+	if (tx_rate)
+		mlx5e_set_sq_maxrate(priv->netdev, sq, tx_rate);
+
 	netdev_tx_reset_queue(sq->txq);
 	netif_tx_start_queue(sq->txq);
 	return 0;
@@ -1692,7 +1702,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
 	int err;
-	int i;
 
 	c = kzalloc_node(sizeof(*c), GFP_KERNEL, cpu_to_node(cpu));
 	if (!c)
@@ -1745,17 +1754,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	if (err)
 		goto err_close_icosq;
 
-	for (i = 0; i < priv->params.num_tc; i++) {
-		u32 txq_ix = priv->channeltc_to_txq_map[ix][i];
-
-		if (priv->tx_rates[txq_ix]) {
-			struct mlx5e_txqsq *sq = priv->txq_to_sq_map[txq_ix];
-
-			mlx5e_set_sq_maxrate(priv->netdev, sq,
-					     priv->tx_rates[txq_ix]);
-		}
-	}
-
 	err = c->xdp ? mlx5e_open_xdpsq(c, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
 	if (err)
 		goto err_close_sqs;
-- 
2.11.0
