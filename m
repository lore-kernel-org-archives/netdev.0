From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/5] net/mlx5: E-Switch, Refactor fast path FDB table creation in switchdev mode
Date: Sat, 22 Apr 2017 21:45:04 +0300
Message-ID: <20170422184507.26569-3-saeedm@mellanox.com>
References: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48067 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1426246AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
In-Reply-To: <20170422184507.26569-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Refactor the creation of the fast path FDB table that holds the
offloaded rules in SRIOV switchdev mode into it's own function.

This will be used in the next patch to be able and re-create the
table under different settings without going through legacy mode.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 69 +++++++++++++++-------
 1 file changed, 49 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 992b380d36be..ce3a2c040706 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -426,31 +426,21 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 	return err;
 }
 
-#define MAX_PF_SQ 256
 #define ESW_OFFLOADS_NUM_GROUPS  4
 
-static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
+static int esw_create_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 {
-	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
-	struct mlx5_flow_table_attr ft_attr = {};
-	int table_size, ix, esw_size, err = 0;
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *fdb = NULL;
-	struct mlx5_flow_group *g;
-	u32 *flow_group_in;
-	void *match_criteria;
+	int esw_size, err = 0;
 	u32 flags = 0;
 
-	flow_group_in = mlx5_vzalloc(inlen);
-	if (!flow_group_in)
-		return -ENOMEM;
-
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
 	if (!root_ns) {
 		esw_warn(dev, "Failed to get FDB flow namespace\n");
 		err = -EOPNOTSUPP;
-		goto ns_err;
+		goto out;
 	}
 
 	esw_debug(dev, "Create offloads FDB table, min (max esw size(2^%d), max counters(%d)*groups(%d))\n",
@@ -471,10 +461,49 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create Fast path FDB Table err %d\n", err);
-		goto fast_fdb_err;
+		goto out;
 	}
 	esw->fdb_table.fdb = fdb;
 
+out:
+	return err;
+}
+
+static void esw_destroy_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
+{
+	mlx5_destroy_flow_table(esw->fdb_table.fdb);
+}
+
+#define MAX_PF_SQ 256
+
+static int esw_create_offloads_fdb_tables(struct mlx5_eswitch *esw, int nvports)
+{
+	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_table_attr ft_attr = {};
+	struct mlx5_core_dev *dev = esw->dev;
+	struct mlx5_flow_namespace *root_ns;
+	struct mlx5_flow_table *fdb = NULL;
+	int table_size, ix, err = 0;
+	struct mlx5_flow_group *g;
+	void *match_criteria;
+	u32 *flow_group_in;
+
+	esw_debug(esw->dev, "Create offloads FDB Tables\n");
+	flow_group_in = mlx5_vzalloc(inlen);
+	if (!flow_group_in)
+		return -ENOMEM;
+
+	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
+	if (!root_ns) {
+		esw_warn(dev, "Failed to get FDB flow namespace\n");
+		err = -EOPNOTSUPP;
+		goto ns_err;
+	}
+
+	err = esw_create_offloads_fast_fdb_table(esw);
+	if (err)
+		goto fast_fdb_err;
+
 	table_size = nvports + MAX_PF_SQ + 1;
 
 	ft_attr.max_fte = table_size;
@@ -545,18 +574,18 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	return err;
 }
 
-static void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
+static void esw_destroy_offloads_fdb_tables(struct mlx5_eswitch *esw)
 {
 	if (!esw->fdb_table.fdb)
 		return;
 
-	esw_debug(esw->dev, "Destroy offloads FDB Table\n");
+	esw_debug(esw->dev, "Destroy offloads FDB Tables\n");
 	mlx5_del_flow_rules(esw->fdb_table.offloads.miss_rule);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.send_to_vport_grp);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.miss_grp);
 
 	mlx5_destroy_flow_table(esw->fdb_table.offloads.fdb);
-	mlx5_destroy_flow_table(esw->fdb_table.fdb);
+	esw_destroy_offloads_fast_fdb_table(esw);
 }
 
 static int esw_create_offloads_table(struct mlx5_eswitch *esw)
@@ -716,7 +745,7 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 	mlx5_remove_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
 	mlx5_dev_list_unlock();
 
-	err = esw_create_offloads_fdb_table(esw, nvports);
+	err = esw_create_offloads_fdb_tables(esw, nvports);
 	if (err)
 		goto create_fdb_err;
 
@@ -753,7 +782,7 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 	esw_destroy_offloads_table(esw);
 
 create_ft_err:
-	esw_destroy_offloads_fdb_table(esw);
+	esw_destroy_offloads_fdb_tables(esw);
 
 create_fdb_err:
 	/* enable back PF RoCE */
@@ -799,7 +828,7 @@ void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 
 	esw_destroy_vport_rx_group(esw);
 	esw_destroy_offloads_table(esw);
-	esw_destroy_offloads_fdb_table(esw);
+	esw_destroy_offloads_fdb_tables(esw);
 }
 
 static int esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
-- 
2.11.0
