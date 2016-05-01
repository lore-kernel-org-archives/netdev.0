From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/4] net/mlx5e: Use workqueue for vxlan ops
Date: Sun,  1 May 2016 22:59:57 +0300
Message-ID: <1462132797-22853-5-git-send-email-saeedm@mellanox.com>
References: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:55761 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752075AbcEAUCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 16:02:07 -0400
In-Reply-To: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

The vxlan add/delete port NDOs are called under rcu lock.
The current mlx5e implementation can potentially block in these
calls, which is not allowed.  Move to using the mlx5e workqueue
to handle these NDOs.

Fixes: b3f63c3d5e2c ('net/mlx5e: Add netdev support for VXLAN tunneling')
Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c   | 50 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 ++++-
 3 files changed, 49 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9ab0841..d4dfc5c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2157,7 +2157,7 @@ static void mlx5e_add_vxlan_port(struct net_device *netdev,
 	if (!mlx5e_vxlan_allowed(priv->mdev))
 		return;
 
-	mlx5e_vxlan_add_port(priv, be16_to_cpu(port));
+	mlx5e_vxlan_queue_work(priv, sa_family, be16_to_cpu(port), 1);
 }
 
 static void mlx5e_del_vxlan_port(struct net_device *netdev,
@@ -2168,7 +2168,7 @@ static void mlx5e_del_vxlan_port(struct net_device *netdev,
 	if (!mlx5e_vxlan_allowed(priv->mdev))
 		return;
 
-	mlx5e_vxlan_del_port(priv, be16_to_cpu(port));
+	mlx5e_vxlan_queue_work(priv, sa_family, be16_to_cpu(port), 0);
 }
 
 static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
index 9f10df2..f2fd1ef 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
@@ -95,21 +95,22 @@ struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port)
 	return vxlan;
 }
 
-int mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port)
+static void mlx5e_vxlan_add_port(struct work_struct *work)
 {
+	struct mlx5e_vxlan_work *vxlan_work =
+		container_of(work, struct mlx5e_vxlan_work, work);
+	struct mlx5e_priv *priv = vxlan_work->priv;
 	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+	u16 port = vxlan_work->port;
 	struct mlx5e_vxlan *vxlan;
 	int err;
 
-	err = mlx5e_vxlan_core_add_port_cmd(priv->mdev, port);
-	if (err)
-		return err;
+	if (mlx5e_vxlan_core_add_port_cmd(priv->mdev, port))
+		goto free_work;
 
 	vxlan = kzalloc(sizeof(*vxlan), GFP_KERNEL);
-	if (!vxlan) {
-		err = -ENOMEM;
+	if (!vxlan)
 		goto err_delete_port;
-	}
 
 	vxlan->udp_port = port;
 
@@ -119,13 +120,14 @@ int mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port)
 	if (err)
 		goto err_free;
 
-	return 0;
+	goto free_work;
 
 err_free:
 	kfree(vxlan);
 err_delete_port:
 	mlx5e_vxlan_core_del_port_cmd(priv->mdev, port);
-	return err;
+free_work:
+	kfree(vxlan_work);
 }
 
 static void __mlx5e_vxlan_core_del_port(struct mlx5e_priv *priv, u16 port)
@@ -145,12 +147,36 @@ static void __mlx5e_vxlan_core_del_port(struct mlx5e_priv *priv, u16 port)
 	kfree(vxlan);
 }
 
-void mlx5e_vxlan_del_port(struct mlx5e_priv *priv, u16 port)
+static void mlx5e_vxlan_del_port(struct work_struct *work)
 {
-	if (!mlx5e_vxlan_lookup_port(priv, port))
-		return;
+	struct mlx5e_vxlan_work *vxlan_work =
+		container_of(work, struct mlx5e_vxlan_work, work);
+	struct mlx5e_priv *priv = vxlan_work->priv;
+	u16 port = vxlan_work->port;
 
 	__mlx5e_vxlan_core_del_port(priv, port);
+
+	kfree(vxlan_work);
+}
+
+void mlx5e_vxlan_queue_work(struct mlx5e_priv *priv, sa_family_t sa_family,
+			    u16 port, int add)
+{
+	struct mlx5e_vxlan_work *vxlan_work;
+
+	vxlan_work = kmalloc(sizeof(*vxlan_work), GFP_ATOMIC);
+	if (!vxlan_work)
+		return;
+
+	if (add)
+		INIT_WORK(&vxlan_work->work, mlx5e_vxlan_add_port);
+	else
+		INIT_WORK(&vxlan_work->work, mlx5e_vxlan_del_port);
+
+	vxlan_work->priv = priv;
+	vxlan_work->port = port;
+	vxlan_work->sa_family = sa_family;
+	queue_work(priv->wq, &vxlan_work->work);
 }
 
 void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
index a016850..129f352 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
@@ -39,6 +39,13 @@ struct mlx5e_vxlan {
 	u16 udp_port;
 };
 
+struct mlx5e_vxlan_work {
+	struct work_struct	work;
+	struct mlx5e_priv	*priv;
+	sa_family_t		sa_family;
+	u16			port;
+};
+
 static inline bool mlx5e_vxlan_allowed(struct mlx5_core_dev *mdev)
 {
 	return (MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
@@ -46,8 +53,8 @@ static inline bool mlx5e_vxlan_allowed(struct mlx5_core_dev *mdev)
 }
 
 void mlx5e_vxlan_init(struct mlx5e_priv *priv);
-int  mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port);
-void mlx5e_vxlan_del_port(struct mlx5e_priv *priv, u16 port);
+void mlx5e_vxlan_queue_work(struct mlx5e_priv *priv, sa_family_t sa_family,
+			    u16 port, int add);
 struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port);
 void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv);
 
-- 
2.8.0
