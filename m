From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 02/10] net/mlx5e: Add TXQ set max rate support
Date: Thu, 23 Jun 2016 17:02:38 +0300
Message-ID: <1466690566-14700-3-git-send-email-saeedm@mellanox.com>
References: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35314 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751719AbcFWPqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 11:46:52 -0400
In-Reply-To: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>

Implement set_maxrate ndo.
Use the rate index from the hardware table to attach to channel SQ/TXQ.
In case of failure to configure new rate, the queue remains with
unlimited rate.

We save the configuration on priv structure and apply it each time
Send Queues are being reinitialized (after open/close) operations.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 102 +++++++++++++++++++++-
 2 files changed, 102 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e8a6c33..017e047 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -88,6 +88,7 @@
 #define MLX5E_LOG_INDIR_RQT_SIZE       0x7
 #define MLX5E_INDIR_RQT_SIZE           BIT(MLX5E_LOG_INDIR_RQT_SIZE)
 #define MLX5E_MAX_NUM_CHANNELS         (MLX5E_INDIR_RQT_SIZE >> 1)
+#define MLX5E_MAX_NUM_SQS              (MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC)
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
 #define MLX5E_SQ_BF_BUDGET             16
@@ -354,6 +355,7 @@ struct mlx5e_sq {
 	struct mlx5e_channel      *channel;
 	int                        tc;
 	struct mlx5e_ico_wqe_info *ico_wqe_info;
+	u32                        rate_limit;
 } ____cacheline_aligned_in_smp;
 
 static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
@@ -530,6 +532,7 @@ struct mlx5e_priv {
 	u32                        indir_rqtn;
 	u32                        indir_tirn[MLX5E_NUM_INDIR_TIRS];
 	struct mlx5e_direct_tir    direct_tir[MLX5E_MAX_NUM_CHANNELS];
+	u32                        tx_rates[MLX5E_MAX_NUM_SQS];
 
 	struct mlx5e_flow_steering fs;
 	struct mlx5e_vxlan_db      vxlan;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8b7c6f3..e5a2cef 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -702,7 +702,8 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	return err;
 }
 
-static int mlx5e_modify_sq(struct mlx5e_sq *sq, int curr_state, int next_state)
+static int mlx5e_modify_sq(struct mlx5e_sq *sq, int curr_state,
+			   int next_state, bool update_rl, int rl_index)
 {
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
@@ -722,6 +723,10 @@ static int mlx5e_modify_sq(struct mlx5e_sq *sq, int curr_state, int next_state)
 
 	MLX5_SET(modify_sq_in, in, sq_state, curr_state);
 	MLX5_SET(sqc, sqc, state, next_state);
+	if (update_rl && next_state == MLX5_SQC_STATE_RDY) {
+		MLX5_SET64(modify_sq_in, in, modify_bitmask, 1);
+		MLX5_SET(sqc,  sqc, packet_pacing_rate_limit_index, rl_index);
+	}
 
 	err = mlx5_core_modify_sq(mdev, sq->sqn, in, inlen);
 
@@ -737,6 +742,8 @@ static void mlx5e_disable_sq(struct mlx5e_sq *sq)
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	mlx5_core_destroy_sq(mdev, sq->sqn);
+	if (sq->rate_limit)
+		mlx5_rl_remove_rate(mdev, sq->rate_limit);
 }
 
 static int mlx5e_open_sq(struct mlx5e_channel *c,
@@ -754,7 +761,8 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_sq;
 
-	err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RST, MLX5_SQC_STATE_RDY);
+	err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RST, MLX5_SQC_STATE_RDY,
+			      false, 0);
 	if (err)
 		goto err_disable_sq;
 
@@ -793,7 +801,8 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 		if (mlx5e_sq_has_room_for(sq, 1))
 			mlx5e_send_nop(sq, true);
 
-		mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR);
+		mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR,
+				false, 0);
 	}
 
 	while (sq->cc != sq->pc) /* wait till sq is empty */
@@ -1024,6 +1033,79 @@ static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
 			ix + i * priv->params.num_channels;
 }
 
+static int mlx5e_set_sq_maxrate(struct net_device *dev,
+				struct mlx5e_sq *sq, u32 rate)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u16 rl_index = 0;
+	int err;
+
+	if (rate == sq->rate_limit)
+		/* nothing to do */
+		return 0;
+
+	if (sq->rate_limit)
+		/* remove current rl index to free space to next ones */
+		mlx5_rl_remove_rate(mdev, sq->rate_limit);
+
+	sq->rate_limit = 0;
+
+	if (rate) {
+		err = mlx5_rl_add_rate(mdev, rate, &rl_index);
+		if (err) {
+			netdev_err(dev, "Failed configuring rate %u: %d\n",
+				   rate, err);
+			return err;
+		}
+	}
+
+	err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
+			      MLX5_SQC_STATE_RDY, true, rl_index);
+	if (err) {
+		netdev_err(dev, "Failed configuring rate %u: %d\n",
+			   rate, err);
+		/* remove the rate from the table */
+		if (rate)
+			mlx5_rl_remove_rate(mdev, rate);
+		return err;
+	}
+
+	sq->rate_limit = rate;
+	return 0;
+}
+
+static int mlx5e_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_sq *sq = priv->txq_to_sq_map[index];
+	int err = 0;
+
+	if (!mlx5_rl_is_supported(mdev)) {
+		netdev_err(dev, "Rate limiting is not supported on this device\n");
+		return -EINVAL;
+	}
+
+	/* rate is given in Mb/sec, HW config is in Kb/sec */
+	rate = rate << 10;
+
+	/* Check whether rate in valid range, 0 is always valid */
+	if (rate && !mlx5_rl_is_in_range(mdev, rate)) {
+		netdev_err(dev, "TX rate %u, is not in range\n", rate);
+		return -ERANGE;
+	}
+
+	mutex_lock(&priv->state_lock);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		err = mlx5e_set_sq_maxrate(dev, sq, rate);
+	if (!err)
+		priv->tx_rates[index] = rate;
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
@@ -1031,7 +1113,9 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	struct net_device *netdev = priv->netdev;
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
+	struct mlx5e_sq *sq;
 	int err;
+	int i;
 
 	c = kzalloc_node(sizeof(*c), GFP_KERNEL, cpu_to_node(cpu));
 	if (!c)
@@ -1073,6 +1157,16 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	if (err)
 		goto err_close_icosq;
 
+	for (i = 0; i < priv->params.num_tc; i++) {
+		u32 txq_ix = priv->channeltc_to_txq_map[ix][i];
+
+		if (priv->tx_rates[txq_ix]) {
+			sq = priv->txq_to_sq_map[txq_ix];
+			mlx5e_set_sq_maxrate(priv->netdev, sq,
+					     priv->tx_rates[txq_ix]);
+		}
+	}
+
 	err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
 	if (err)
 		goto err_close_sqs;
@@ -2611,6 +2705,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
@@ -2632,6 +2727,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_do_ioctl            = mlx5e_ioctl,
 	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
 	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
+	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
 	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
-- 
2.8.0
