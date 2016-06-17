From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 17/18] net/mlx5e: Lock device state in set features
Date: Fri, 17 Jun 2016 17:43:58 +0300
Message-ID: <1466174639-14576-18-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57716 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752776AbcFQOtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:49:21 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Lock device state in mlx5e_set_features, rather than make each set
feature handler lock it itself.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 982f852..94d6f60 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2247,7 +2247,6 @@ static int set_feature_lro(struct net_device *netdev, bool enable)
 	bool was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	int err;
 
-	mutex_lock(&priv->state_lock);
 
 	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
 		mlx5e_close_locked(priv->netdev);
@@ -2262,8 +2261,6 @@ static int set_feature_lro(struct net_device *netdev, bool enable)
 	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
 		mlx5e_open_locked(priv->netdev);
 
-	mutex_unlock(&priv->state_lock);
-
 	return err;
 }
 
@@ -2305,15 +2302,11 @@ static int set_feature_rx_vlan(struct net_device *netdev, bool enable)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
 
-	mutex_lock(&priv->state_lock);
-
 	priv->params.vlan_strip_disable = !enable;
 	err = mlx5e_modify_rqs_vsd(priv, !enable);
 	if (err)
 		priv->params.vlan_strip_disable = enable;
 
-	mutex_unlock(&priv->state_lock);
-
 	return err;
 }
 
@@ -2358,8 +2351,11 @@ static int mlx5e_handle_feature(struct net_device *netdev,
 static int mlx5e_set_features(struct net_device *netdev,
 			      netdev_features_t features)
 {
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
 
+	mutex_lock(&priv->state_lock);
+
 	err  = mlx5e_handle_feature(netdev, features, NETIF_F_LRO,
 				    set_feature_lro);
 	err |= mlx5e_handle_feature(netdev, features,
@@ -2376,6 +2372,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 				    set_feature_arfs);
 #endif
 
+	mutex_unlock(&priv->state_lock);
+
 	return err ? -EINVAL : 0;
 }
 
-- 
2.8.0
