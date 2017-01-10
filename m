From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 08/10] net/mlx5e: Un-register uplink representor on nic_disable
Date: Tue, 10 Jan 2017 22:33:37 +0200
Message-ID: <1484080419-24256-9-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52045 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751111AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code before this patch registered uplink e-Switch representor
on nic_enable and unregistered on nic_cleanup, the right place
for this unregister is in nic_disable.

Fixes: 127ea380acc9 ("net/mlx5: Add Representors registration API")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Mohamad Haj Yahia <mohamad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1236b27..2b7dd31 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3675,14 +3675,8 @@ static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 
 static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-
 	mlx5e_vxlan_cleanup(priv);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
-		mlx5_eswitch_unregister_vport_rep(esw, 0);
-
 	if (priv->xdp_prog)
 		bpf_prog_put(priv->xdp_prog);
 }
@@ -3807,9 +3801,14 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 {
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+
 	queue_work(priv->wq, &priv->set_rx_mode_work);
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		mlx5_eswitch_unregister_vport_rep(esw, 0);
 	mlx5e_disable_async_events(priv);
-	mlx5_lag_remove(priv->mdev);
+	mlx5_lag_remove(mdev);
 }
 
 static const struct mlx5e_profile mlx5e_nic_profile = {
-- 
2.7.4
