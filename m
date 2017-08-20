From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 01/15] net/mlx5e: Send PAOS command on interface up/down
Date: Sun, 20 Aug 2017 16:49:02 +0300
Message-ID: <20170820134916.10222-2-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44792 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752956AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Upon interface up/down, driver will send PAOS (Ports Administrative and
Operational Status Register) in order to inform the Firmware on the
desired status of the port by the driver.

Since now we might change physical link status on mlx5e_open/close,
logical VF representor should not use mlx5e_open/close ndos as is, and
should call the logical version mlx5e_open/closed_locked.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 20 +++++++++++++-------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2fc3832bc2f3..7c512a4c6d5c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2682,6 +2682,8 @@ int mlx5e_open(struct net_device *netdev)
 
 	mutex_lock(&priv->state_lock);
 	err = mlx5e_open_locked(netdev);
+	if (!err)
+		mlx5_set_port_admin_status(priv->mdev, MLX5_PORT_UP);
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -2716,6 +2718,7 @@ int mlx5e_close(struct net_device *netdev)
 		return -ENODEV;
 
 	mutex_lock(&priv->state_lock);
+	mlx5_set_port_admin_status(priv->mdev, MLX5_PORT_DOWN);
 	err = mlx5e_close_locked(netdev);
 	mutex_unlock(&priv->state_lock);
 
@@ -4187,6 +4190,10 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 	mlx5e_init_l2_addr(priv);
 
+	/* Marking the link as currently not needed by the Driver */
+	if (!netif_running(netdev))
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
+
 	/* MTU range: 68 - hw-specific max */
 	netdev->min_mtu = ETH_MIN_MTU;
 	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 7a9f53f74976..45c088c10ee1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -613,15 +613,18 @@ static int mlx5e_rep_open(struct net_device *dev)
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	int err;
 
-	err = mlx5e_open(dev);
+	mutex_lock(&priv->state_lock);
+	err = mlx5e_open_locked(dev);
 	if (err)
-		return err;
+		goto unlock;
 
-	err = mlx5_eswitch_set_vport_state(esw, rep->vport, MLX5_ESW_VPORT_ADMIN_STATE_UP);
-	if (!err)
+	if (!mlx5_eswitch_set_vport_state(esw, rep->vport,
+					  MLX5_ESW_VPORT_ADMIN_STATE_UP))
 		netif_carrier_on(dev);
 
-	return 0;
+unlock:
+	mutex_unlock(&priv->state_lock);
+	return err;
 }
 
 static int mlx5e_rep_close(struct net_device *dev)
@@ -630,10 +633,13 @@ static int mlx5e_rep_close(struct net_device *dev)
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	int ret;
 
+	mutex_lock(&priv->state_lock);
 	(void)mlx5_eswitch_set_vport_state(esw, rep->vport, MLX5_ESW_VPORT_ADMIN_STATE_DOWN);
-
-	return mlx5e_close(dev);
+	ret = mlx5e_close_locked(dev);
+	mutex_unlock(&priv->state_lock);
+	return ret;
 }
 
 static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
-- 
2.13.0
