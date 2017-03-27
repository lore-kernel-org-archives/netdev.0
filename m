From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/14] net/mlx5e: Introduce switch channels
Date: Mon, 27 Mar 2017 23:49:06 +0300
Message-ID: <20170327204910.20287-11-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44896 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752215AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A fail safe helper functions that allows switching to new channels on the
fly,  In simple words:

make_new_config(new_params)
{
    new_channels = open_channels(new_params);
    if (!new_channels)
         return "Failed, but current channels are still active :)"

    switch_channels(new_channels);

    return "SUCCESS";
}

Demonstrate mlx5e_switch_priv_channels usage in set channels ethtool
callback and make it fail-safe using the new switch channels mechanism.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  7 +++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 29 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 30 +++++++++++++++++++---
 3 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 44c454b34754..2f259dfbf844 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -863,6 +863,13 @@ void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_params *params,
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
+
+int mlx5e_open_channels(struct mlx5e_priv *priv,
+			struct mlx5e_channels *chs);
+void mlx5e_close_channels(struct mlx5e_channels *chs);
+void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
+				struct mlx5e_channels *new_chs);
+
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
 				   int num_channels);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index b2cd0ef7921e..e5cee400a4d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -556,8 +556,8 @@ static int mlx5e_set_channels(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	unsigned int count = ch->combined_count;
+	struct mlx5e_channels new_channels = {};
 	bool arfs_enabled;
-	bool was_opened;
 	int err = 0;
 
 	if (!count) {
@@ -571,22 +571,27 @@ static int mlx5e_set_channels(struct net_device *dev,
 
 	mutex_lock(&priv->state_lock);
 
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
-		mlx5e_close_locked(dev);
+	new_channels.params = priv->channels.params;
+	new_channels.params.num_channels = count;
+	mlx5e_build_default_indir_rqt(priv->mdev, new_channels.params.indirection_rqt,
+				      MLX5E_INDIR_RQT_SIZE, count);
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		goto out;
+	}
+
+	/* Create fresh channels with new parameters */
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto out;
 
 	arfs_enabled = dev->features & NETIF_F_NTUPLE;
 	if (arfs_enabled)
 		mlx5e_arfs_disable(priv);
 
-	priv->channels.params.num_channels = count;
-	mlx5e_build_default_indir_rqt(priv->mdev, priv->channels.params.indirection_rqt,
-				      MLX5E_INDIR_RQT_SIZE, count);
-
-	if (was_opened)
-		err = mlx5e_open_locked(dev);
-	if (err)
-		goto out;
+	/* Switch to new channels, set new parameters and close old ones */
+	mlx5e_switch_priv_channels(priv, &new_channels);
 
 	if (arfs_enabled) {
 		err = mlx5e_arfs_enable(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a94f84ec2c1a..97e153209834 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1972,8 +1972,8 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 	mlx5e_build_ico_cq_param(priv, icosq_log_wq_sz, &cparam->icosq_cq);
 }
 
-static int mlx5e_open_channels(struct mlx5e_priv *priv,
-			       struct mlx5e_channels *chs)
+int mlx5e_open_channels(struct mlx5e_priv *priv,
+			struct mlx5e_channels *chs)
 {
 	struct mlx5e_channel_param *cparam;
 	int err = -ENOMEM;
@@ -2037,7 +2037,7 @@ static void mlx5e_deactivate_channels(struct mlx5e_channels *chs)
 		mlx5e_deactivate_channel(chs->c[i]);
 }
 
-static void mlx5e_close_channels(struct mlx5e_channels *chs)
+void mlx5e_close_channels(struct mlx5e_channels *chs)
 {
 	int i;
 
@@ -2533,6 +2533,30 @@ static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 	mlx5e_deactivate_channels(&priv->channels);
 }
 
+void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
+				struct mlx5e_channels *new_chs)
+{
+	struct net_device *netdev = priv->netdev;
+	int new_num_txqs;
+
+	new_num_txqs = new_chs->num * new_chs->params.num_tc;
+
+	netif_carrier_off(netdev);
+
+	if (new_num_txqs < netdev->real_num_tx_queues)
+		netif_set_real_num_tx_queues(netdev, new_num_txqs);
+
+	mlx5e_deactivate_priv_channels(priv);
+	mlx5e_close_channels(&priv->channels);
+
+	priv->channels = *new_chs;
+
+	mlx5e_refresh_tirs(priv, false);
+	mlx5e_activate_priv_channels(priv);
+
+	mlx5e_update_carrier(priv);
+}
+
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-- 
2.11.0
