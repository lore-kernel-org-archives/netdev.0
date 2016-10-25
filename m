From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 08/12] net/mlx5: Change the acl enable prototype to return status
Date: Tue, 25 Oct 2016 18:36:31 +0300
Message-ID: <1477409795-28807-9-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40941 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933381AbcJYPiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:25 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

The Ingress/Egress ACL enable function may fail and it should return
status to its caller to avoid NULL pointer dereference.

Fixes: f942380c1239 ('net/mlx5: E-Switch, Vport ingress/egress ACLs rules for spoofchk')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 50 +++++++++++++++--------
 1 file changed, 34 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index abbf2c3..be1f733 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -931,8 +931,8 @@ static void esw_vport_change_handler(struct work_struct *work)
 	mutex_unlock(&esw->state_lock);
 }
 
-static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
-					struct mlx5_vport *vport)
+static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
+				       struct mlx5_vport *vport)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	struct mlx5_flow_group *vlan_grp = NULL;
@@ -949,9 +949,11 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	int table_size = 2;
 	int err = 0;
 
-	if (!MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support) ||
-	    !IS_ERR_OR_NULL(vport->egress.acl))
-		return;
+	if (!MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support))
+		return -EOPNOTSUPP;
+
+	if (!IS_ERR_OR_NULL(vport->egress.acl))
+		return 0;
 
 	esw_debug(dev, "Create vport[%d] egress ACL log_max_size(%d)\n",
 		  vport->vport, MLX5_CAP_ESW_EGRESS_ACL(dev, log_max_ft_size));
@@ -959,12 +961,12 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ESW_EGRESS);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get E-Switch egress flow namespace\n");
-		return;
+		return -EIO;
 	}
 
 	flow_group_in = mlx5_vzalloc(inlen);
 	if (!flow_group_in)
-		return;
+		return -ENOMEM;
 
 	acl = mlx5_create_vport_flow_table(root_ns, 0, table_size, 0, vport->vport);
 	if (IS_ERR(acl)) {
@@ -1009,6 +1011,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 		mlx5_destroy_flow_group(vlan_grp);
 	if (err && !IS_ERR_OR_NULL(acl))
 		mlx5_destroy_flow_table(acl);
+	return err;
 }
 
 static void esw_vport_cleanup_egress_rules(struct mlx5_eswitch *esw,
@@ -1041,8 +1044,8 @@ static void esw_vport_disable_egress_acl(struct mlx5_eswitch *esw,
 	vport->egress.acl = NULL;
 }
 
-static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
-					 struct mlx5_vport *vport)
+static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
+					struct mlx5_vport *vport)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	struct mlx5_core_dev *dev = esw->dev;
@@ -1063,9 +1066,11 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	int table_size = 4;
 	int err = 0;
 
-	if (!MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support) ||
-	    !IS_ERR_OR_NULL(vport->ingress.acl))
-		return;
+	if (!MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support))
+		return -EOPNOTSUPP;
+
+	if (!IS_ERR_OR_NULL(vport->ingress.acl))
+		return 0;
 
 	esw_debug(dev, "Create vport[%d] ingress ACL log_max_size(%d)\n",
 		  vport->vport, MLX5_CAP_ESW_INGRESS_ACL(dev, log_max_ft_size));
@@ -1073,12 +1078,12 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ESW_INGRESS);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get E-Switch ingress flow namespace\n");
-		return;
+		return -EIO;
 	}
 
 	flow_group_in = mlx5_vzalloc(inlen);
 	if (!flow_group_in)
-		return;
+		return -ENOMEM;
 
 	acl = mlx5_create_vport_flow_table(root_ns, 0, table_size, 0, vport->vport);
 	if (IS_ERR(acl)) {
@@ -1167,6 +1172,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	}
 
 	kvfree(flow_group_in);
+	return err;
 }
 
 static void esw_vport_cleanup_ingress_rules(struct mlx5_eswitch *esw,
@@ -1225,7 +1231,13 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		return 0;
 	}
 
-	esw_vport_enable_ingress_acl(esw, vport);
+	err = esw_vport_enable_ingress_acl(esw, vport);
+	if (err) {
+		mlx5_core_warn(esw->dev,
+			       "failed to enable ingress acl (%d) on vport[%d]\n",
+			       err, vport->vport);
+		return err;
+	}
 
 	esw_debug(esw->dev,
 		  "vport[%d] configure ingress rules, vlan(%d) qos(%d)\n",
@@ -1299,7 +1311,13 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 		return 0;
 	}
 
-	esw_vport_enable_egress_acl(esw, vport);
+	err = esw_vport_enable_egress_acl(esw, vport);
+	if (err) {
+		mlx5_core_warn(esw->dev,
+			       "failed to enable egress acl (%d) on vport[%d]\n",
+			       err, vport->vport);
+		return err;
+	}
 
 	esw_debug(esw->dev,
 		  "vport[%d] configure egress rules, vlan(%d) qos(%d)\n",
-- 
2.7.4
