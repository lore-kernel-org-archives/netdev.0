From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/14] net/mlx5e: Minimize mlx5e_{open/close}_locked
Date: Mon, 27 Mar 2017 23:49:05 +0300
Message-ID: <20170327204910.20287-10-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44889 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752542AbdC0UuQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:16 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx5e_redirect_rqts_to_{channels,drop} and mlx5e_{add,del}_sqs_fwd_rules
and Set real num tx/rx queues belong to
mlx5e_{activate,deactivate}_priv_channels, for that we move those functions
and minimize mlx5e_open/close flows.

This will be needed in downstream patches to replace old channels with new
ones without the need to call mlx5e_close/open.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 40 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 10 ++++--
 2 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a6e09c46440b..a94f84ec2c1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2498,14 +2498,33 @@ static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
 
 static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 {
+	int num_txqs = priv->channels.num * priv->channels.params.num_tc;
+	struct net_device *netdev = priv->netdev;
+
+	mlx5e_netdev_set_tcs(netdev);
+	if (netdev->real_num_tx_queues != num_txqs)
+		netif_set_real_num_tx_queues(netdev, num_txqs);
+	if (netdev->real_num_rx_queues != priv->channels.num)
+		netif_set_real_num_rx_queues(netdev, priv->channels.num);
+
 	mlx5e_build_channels_tx_maps(priv);
 	mlx5e_activate_channels(&priv->channels);
 	netif_tx_start_all_queues(priv->netdev);
+
+	if (MLX5_CAP_GEN(priv->mdev, vport_group_manager))
+		mlx5e_add_sqs_fwd_rules(priv);
+
 	mlx5e_wait_channels_min_rx_wqes(&priv->channels);
+	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 }
 
 static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 {
+	mlx5e_redirect_rqts_to_drop(priv);
+
+	if (MLX5_CAP_GEN(priv->mdev, vport_group_manager))
+		mlx5e_remove_sqs_fwd_rules(priv);
+
 	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
 	 * polling for inactive tx queues.
 	 */
@@ -2517,40 +2536,24 @@ static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5_core_dev *mdev = priv->mdev;
-	int num_txqs;
 	int err;
 
 	set_bit(MLX5E_STATE_OPENED, &priv->state);
 
-	mlx5e_netdev_set_tcs(netdev);
-
-	num_txqs = priv->channels.params.num_channels * priv->channels.params.num_tc;
-	netif_set_real_num_tx_queues(netdev, num_txqs);
-	netif_set_real_num_rx_queues(netdev, priv->channels.params.num_channels);
-
 	err = mlx5e_open_channels(priv, &priv->channels);
 	if (err)
 		goto err_clear_state_opened_flag;
 
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
-	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 
 	if (priv->profile->update_stats)
 		queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		err = mlx5e_add_sqs_fwd_rules(priv);
-		if (err)
-			goto err_close_channels;
-	}
 	return 0;
 
-err_close_channels:
-	mlx5e_close_channels(&priv->channels);
 err_clear_state_opened_flag:
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 	return err;
@@ -2571,7 +2574,6 @@ int mlx5e_open(struct net_device *netdev)
 int mlx5e_close_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5_core_dev *mdev = priv->mdev;
 
 	/* May already be CLOSED in case a previous configuration operation
 	 * (e.g RX/TX queue size change) that involves close&open failed.
@@ -2581,12 +2583,8 @@ int mlx5e_close_locked(struct net_device *netdev)
 
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
-		mlx5e_remove_sqs_fwd_rules(priv);
-
 	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
-	mlx5e_redirect_rqts_to_drop(priv);
 	mlx5e_deactivate_priv_channels(priv);
 	mlx5e_close_channels(&priv->channels);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index d277c1979b2a..53db5ec2c122 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -189,12 +189,13 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	struct mlx5e_channel *c;
-	int n, tc, err, num_sqs = 0;
+	int n, tc, num_sqs = 0;
+	int err = -ENOMEM;
 	u16 *sqs;
 
 	sqs = kcalloc(priv->channels.num * priv->channels.params.num_tc, sizeof(u16), GFP_KERNEL);
 	if (!sqs)
-		return -ENOMEM;
+		goto out;
 
 	for (n = 0; n < priv->channels.num; n++) {
 		c = priv->channels.c[n];
@@ -203,8 +204,11 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 	}
 
 	err = mlx5_eswitch_sqs2vport_start(esw, rep, sqs, num_sqs);
-
 	kfree(sqs);
+
+out:
+	if (err)
+		netdev_warn(priv->netdev, "Failed to add SQs FWD rules %d\n", err);
 	return err;
 }
 
-- 
2.11.0
