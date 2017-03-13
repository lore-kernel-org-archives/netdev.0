From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 09/25] net/mlx5e: Creating and Destroying flow-steering tables for IB link
Date: Mon, 13 Mar 2017 20:31:20 +0200
Message-ID: <1489429896-10781-10-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


New function to handle RSS table for IB link type.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c | 41 +++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 39f8ac849af7..f3337ec4457f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -755,6 +755,8 @@ void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 
 int mlx5e_create_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv);
+int mlx5i_create_flow_steering(struct mlx5e_priv *priv);
+void mlx5i_destroy_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_init_l2_addr(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_table(struct mlx5e_flow_table *ft);
 int mlx5e_self_test_num(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index a0e5a69402b3..c6b40003007c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -1081,6 +1081,40 @@ static void mlx5e_destroy_vlan_table(struct mlx5e_priv *priv)
 	mlx5e_destroy_flow_table(&priv->fs.vlan.ft);
 }
 
+int mlx5i_create_flow_steering(struct mlx5e_priv *priv)
+{
+	int err;
+
+	priv->fs.ns = mlx5_get_flow_namespace(priv->mdev,
+					       MLX5_FLOW_NAMESPACE_KERNEL);
+
+	if (!priv->fs.ns)
+		return -EINVAL;
+
+	err = mlx5e_arfs_create_tables(priv);
+	if (err) {
+		netdev_err(priv->netdev, "Failed to create arfs tables, err=%d\n",
+			   err);
+		priv->netdev->hw_features &= ~NETIF_F_NTUPLE;
+	}
+
+	err = mlx5e_create_ttc_table(priv);
+	if (err) {
+		netdev_err(priv->netdev, "Failed to create ttc table, err=%d\n",
+			   err);
+		goto err_destroy_arfs_tables;
+	}
+
+	mlx5e_ethtool_init_steering(priv);
+
+	return 0;
+
+err_destroy_arfs_tables:
+	mlx5e_arfs_destroy_tables(priv);
+
+	return err;
+}
+
 int mlx5e_create_flow_steering(struct mlx5e_priv *priv)
 {
 	int err;
@@ -1141,3 +1175,10 @@ void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv)
 	mlx5e_arfs_destroy_tables(priv);
 	mlx5e_ethtool_cleanup_steering(priv);
 }
+
+void mlx5i_destroy_flow_steering(struct mlx5e_priv *priv)
+{
+	mlx5e_destroy_ttc_table(priv);
+	mlx5e_arfs_destroy_tables(priv);
+	mlx5e_ethtool_cleanup_steering(priv);
+}
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
