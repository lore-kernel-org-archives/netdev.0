From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 07/12] net/mlx5e: Unregister netdev before detaching it
Date: Tue, 25 Oct 2016 18:36:30 +0300
Message-ID: <1477409795-28807-8-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40946 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932951AbcJYPiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:25 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Detaching the netdev before unregistering it cause some netdev cleanup
ndos to fail because they check presence of the netdev, so we need to
unregister the netdev first.

Fixes: 26e59d8077a3 ('net/mlx5e: Implement mlx5e interface attach/detach callbacks')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5c8ab3e..f4c687c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -4048,7 +4048,6 @@ void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
 	const struct mlx5e_profile *profile = priv->profile;
 	struct net_device *netdev = priv->netdev;
 
-	unregister_netdev(netdev);
 	destroy_workqueue(priv->wq);
 	if (profile->cleanup)
 		profile->cleanup(priv);
@@ -4065,6 +4064,7 @@ static void mlx5e_remove(struct mlx5_core_dev *mdev, void *vpriv)
 	for (vport = 1; vport < total_vfs; vport++)
 		mlx5_eswitch_unregister_vport_rep(esw, vport);
 
+	unregister_netdev(priv->netdev);
 	mlx5e_detach(mdev, vpriv);
 	mlx5e_destroy_netdev(mdev, priv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 3c97da1..7fe6559 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -457,6 +457,7 @@ void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
 	struct mlx5e_priv *priv = rep->priv_data;
 	struct net_device *netdev = priv->netdev;
 
+	unregister_netdev(netdev);
 	mlx5e_detach_netdev(esw->dev, netdev);
 	mlx5e_destroy_netdev(esw->dev, priv);
 }
-- 
2.7.4
