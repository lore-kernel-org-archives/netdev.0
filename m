From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 2/8] net/mlx5: Return EOPNOTSUPP when failing to get steering name-space
Date: Sun, 29 Jan 2017 23:46:20 +0200
Message-ID: <20170129214626.21977-3-saeedm@mellanox.com>
References: <20170129214626.21977-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41599 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750763AbdA2Vqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 16:46:43 -0500
In-Reply-To: <20170129214626.21977-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When we fail to retrieve a hardware steering name-space, the returned error
code should say that this operation is not supported. Align the various
places in the driver where this call is made to this convention.

Also, make sure to warn when we fail to retrieve a SW (ANCHOR) name-space.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c            | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c          | 6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c          | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 1fe80de5d68f..a0e5a69402b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -1089,7 +1089,7 @@ int mlx5e_create_flow_steering(struct mlx5e_priv *priv)
 					       MLX5_FLOW_NAMESPACE_KERNEL);
 
 	if (!priv->fs.ns)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	err = mlx5e_arfs_create_tables(priv);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index bb712139b36e..d0c8bf014453 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -353,7 +353,7 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get FDB flow namespace\n");
-		return -ENOMEM;
+		return -EOPNOTSUPP;
 	}
 
 	flow_group_in = mlx5_vzalloc(inlen);
@@ -962,7 +962,7 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ESW_EGRESS);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get E-Switch egress flow namespace\n");
-		return -EIO;
+		return -EOPNOTSUPP;
 	}
 
 	flow_group_in = mlx5_vzalloc(inlen);
@@ -1079,7 +1079,7 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ESW_INGRESS);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get E-Switch ingress flow namespace\n");
-		return -EIO;
+		return -EOPNOTSUPP;
 	}
 
 	flow_group_in = mlx5_vzalloc(inlen);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 657d319fc4c6..5803216157cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -535,7 +535,7 @@ static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_OFFLOADS);
 	if (!ns) {
 		esw_warn(esw->dev, "Failed to get offloads flow namespace\n");
-		return -ENOMEM;
+		return -EOPNOTSUPP;
 	}
 
 	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0, 0);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 0ac7a2fc916c..6346a8f5883b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1822,7 +1822,7 @@ static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 	struct mlx5_flow_table *ft;
 
 	ns = mlx5_get_flow_namespace(steering->dev, MLX5_FLOW_NAMESPACE_ANCHOR);
-	if (!ns)
+	if (WARN_ON(!ns))
 		return -EINVAL;
 	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL, 0);
 	if (IS_ERR(ft)) {
-- 
2.11.0
