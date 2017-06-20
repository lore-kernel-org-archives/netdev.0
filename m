From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/10] net/mlx5e: Add new profile function update_carrier
Date: Tue, 20 Jun 2017 17:13:08 +0300
Message-ID: <20170620141314.25620-5-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42047 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751223AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Updating the carrier involves specific HW setting, each profile should
use its own function for that.

Both IPoIB and VF representor don't need carrier update function, since
VF representor has only a logical link to VF and IPoIB manages its own
link via ib_core upper layer.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     | 14 ++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c |  2 ++
 4 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 49c5fe9fdff0..a223a8e15ece 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -782,6 +782,7 @@ struct mlx5e_profile {
 	void	(*enable)(struct mlx5e_priv *priv);
 	void	(*disable)(struct mlx5e_priv *priv);
 	void	(*update_stats)(struct mlx5e_priv *priv);
+	void	(*update_carrier)(struct mlx5e_priv *priv);
 	int	(*max_nch)(struct mlx5_core_dev *mdev);
 	struct {
 		mlx5e_fp_handle_rx_cqe handle_rx_cqe;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 06eb7a8b487c..343be65621db 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -143,7 +143,8 @@ static void mlx5e_update_carrier_work(struct work_struct *work)
 
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_update_carrier(priv);
+		if (priv->profile->update_carrier)
+			priv->profile->update_carrier(priv);
 	mutex_unlock(&priv->state_lock);
 }
 
@@ -2598,9 +2599,10 @@ void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
 {
 	struct net_device *netdev = priv->netdev;
 	int new_num_txqs;
-
+	int carrier_ok;
 	new_num_txqs = new_chs->num * new_chs->params.num_tc;
 
+	carrier_ok = netif_carrier_ok(netdev);
 	netif_carrier_off(netdev);
 
 	if (new_num_txqs < netdev->real_num_tx_queues)
@@ -2618,7 +2620,9 @@ void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
 
-	mlx5e_update_carrier(priv);
+	/* return carrier back if needed */
+	if (carrier_ok)
+		netif_carrier_on(netdev);
 }
 
 int mlx5e_open_locked(struct net_device *netdev)
@@ -2634,7 +2638,8 @@ int mlx5e_open_locked(struct net_device *netdev)
 
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
-	mlx5e_update_carrier(priv);
+	if (priv->profile->update_carrier)
+		priv->profile->update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 
 	if (priv->profile->update_stats)
@@ -4215,6 +4220,7 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 	.disable	   = mlx5e_nic_disable,
 	.update_stats	   = mlx5e_update_ndo_stats,
 	.max_nch	   = mlx5e_get_max_num_channels,
+	.update_carrier	   = mlx5e_update_carrier,
 	.rx_handlers.handle_rx_cqe       = mlx5e_handle_rx_cqe,
 	.rx_handlers.handle_rx_cqe_mpwqe = mlx5e_handle_rx_cqe_mpwrq,
 	.max_tc		   = MLX5E_MAX_NUM_TC,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 01798e1ab667..a39873bd88a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -916,6 +916,7 @@ static struct mlx5e_profile mlx5e_rep_profile = {
 	.cleanup_tx		= mlx5e_cleanup_nic_tx,
 	.update_stats           = mlx5e_rep_update_stats,
 	.max_nch		= mlx5e_get_rep_max_num_channels,
+	.update_carrier		= NULL,
 	.rx_handlers.handle_rx_cqe       = mlx5e_handle_rx_cqe_rep,
 	.rx_handlers.handle_rx_cqe_mpwqe = NULL /* Not supported */,
 	.max_tc			= 1,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index fdeb426d4751..cc9ff4014e5c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -291,6 +291,7 @@ static const struct mlx5e_profile mlx5i_nic_profile = {
 	.disable	   = NULL, /* mlx5i_disable */
 	.update_stats	   = NULL, /* mlx5i_update_stats */
 	.max_nch	   = mlx5e_get_max_num_channels,
+	.update_carrier    = NULL, /* no HW update in IB link */
 	.rx_handlers.handle_rx_cqe       = mlx5i_handle_rx_cqe,
 	.rx_handlers.handle_rx_cqe_mpwqe = NULL, /* Not supported */
 	.max_tc		   = MLX5I_MAX_NUM_TC,
@@ -337,6 +338,7 @@ static int mlx5i_open(struct net_device *netdev)
 
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
+
 	mutex_unlock(&priv->state_lock);
 	return 0;
 
-- 
2.11.0
