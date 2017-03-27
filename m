From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/14] net/mlx5e: Fail safe tc setup
Date: Mon, 27 Mar 2017 23:49:09 +0300
Message-ID: <20170327204910.20287-14-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44904 "EHLO
        mellanox.co.il" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752616AbdC0Uup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:45 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new fail-safe channels switch mechanism to set up new
tc parameters.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 97e153209834..1e29f40d84ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2910,7 +2910,7 @@ int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	bool was_opened;
+	struct mlx5e_channels new_channels = {};
 	int err = 0;
 
 	if (tc && tc != MLX5E_MAX_NUM_TC)
@@ -2918,17 +2918,21 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 
 	mutex_lock(&priv->state_lock);
 
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
-		mlx5e_close_locked(priv->netdev);
+	new_channels.params = priv->channels.params;
+	new_channels.params.num_tc = tc ? tc : 1;
 
-	priv->channels.params.num_tc = tc ? tc : 1;
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		goto out;
+	}
 
-	if (was_opened)
-		err = mlx5e_open_locked(priv->netdev);
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto out;
 
+	mlx5e_switch_priv_channels(priv, &new_channels);
+out:
 	mutex_unlock(&priv->state_lock);
-
 	return err;
 }
 
-- 
2.11.0
