From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 02/12] net/mlx5: Flow steering, Add vport ACL support
Date: Tue,  3 May 2016 17:13:54 +0300
Message-ID: <1462284844-16926-3-git-send-email-saeedm@mellanox.com>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48752 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcECOPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:15:03 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Update the relevant flow steering device structs and commands to
support vport.
Update the flow steering core API to receive vport number.
Add ingress and egress ACL flow table name spaces.
Add ACL flow table support:
* ACL (Access Control List) flow table is a table that contains
only allow/drop steering rules.

* We have two types of ACL flow tables - ingress and egress.

* ACLs handle traffic sent from/to E-Switch FDB table, Ingress refers to
traffic sent from Vport to E-Switch and Egress refers to traffic sent
from E-Switch to vport.

* Ingress ACL flow table allow/drop rules is checked against traffic
sent from VF.

* Egress ACL flow table allow/drop rules is checked against traffic sent
to VF.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 33 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 85 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  7 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  2 +
 include/linux/mlx5/device.h                        | 12 +++
 include/linux/mlx5/driver.h                        |  2 +
 include/linux/mlx5/fs.h                            |  7 ++
 9 files changed, 142 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index ff91bb5..dd06619 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -845,7 +845,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 {
 	int l2_table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
-	int total_vports = 1 + pci_sriov_get_totalvfs(dev->pdev);
+	int total_vports = MLX5_TOTAL_VPORTS(dev);
 	struct mlx5_eswitch *esw;
 	int vport_num;
 	int err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index f46f1db..9797768 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -50,6 +50,10 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 		 MLX5_CMD_OP_SET_FLOW_TABLE_ROOT);
 	MLX5_SET(set_flow_table_root_in, in, table_type, ft->type);
 	MLX5_SET(set_flow_table_root_in, in, table_id, ft->id);
+	if (ft->vport) {
+		MLX5_SET(set_flow_table_root_in, in, vport_number, ft->vport);
+		MLX5_SET(set_flow_table_root_in, in, other_vport, 1);
+	}
 
 	memset(out, 0, sizeof(out));
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
@@ -57,6 +61,7 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 }
 
 int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
+			       u16 vport,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
 			       *next_ft, unsigned int *table_id)
@@ -77,6 +82,10 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 	MLX5_SET(create_flow_table_in, in, table_type, type);
 	MLX5_SET(create_flow_table_in, in, level, level);
 	MLX5_SET(create_flow_table_in, in, log_size, log_size);
+	if (vport) {
+		MLX5_SET(create_flow_table_in, in, vport_number, vport);
+		MLX5_SET(create_flow_table_in, in, other_vport, 1);
+	}
 
 	memset(out, 0, sizeof(out));
 	err = mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
@@ -101,6 +110,10 @@ int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
 		 MLX5_CMD_OP_DESTROY_FLOW_TABLE);
 	MLX5_SET(destroy_flow_table_in, in, table_type, ft->type);
 	MLX5_SET(destroy_flow_table_in, in, table_id, ft->id);
+	if (ft->vport) {
+		MLX5_SET(destroy_flow_table_in, in, vport_number, ft->vport);
+		MLX5_SET(destroy_flow_table_in, in, other_vport, 1);
+	}
 
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					  sizeof(out));
@@ -120,6 +133,10 @@ int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
 		 MLX5_CMD_OP_MODIFY_FLOW_TABLE);
 	MLX5_SET(modify_flow_table_in, in, table_type, ft->type);
 	MLX5_SET(modify_flow_table_in, in, table_id, ft->id);
+	if (ft->vport) {
+		MLX5_SET(modify_flow_table_in, in, vport_number, ft->vport);
+		MLX5_SET(modify_flow_table_in, in, other_vport, 1);
+	}
 	MLX5_SET(modify_flow_table_in, in, modify_field_select,
 		 MLX5_MODIFY_FLOW_TABLE_MISS_TABLE_ID);
 	if (next_ft) {
@@ -148,6 +165,10 @@ int mlx5_cmd_create_flow_group(struct mlx5_core_dev *dev,
 		 MLX5_CMD_OP_CREATE_FLOW_GROUP);
 	MLX5_SET(create_flow_group_in, in, table_type, ft->type);
 	MLX5_SET(create_flow_group_in, in, table_id, ft->id);
+	if (ft->vport) {
+		MLX5_SET(create_flow_group_in, in, vport_number, ft->vport);
+		MLX5_SET(create_flow_group_in, in, other_vport, 1);
+	}
 
 	err = mlx5_cmd_exec_check_status(dev, in,
 					 inlen, out,
@@ -174,6 +195,10 @@ int mlx5_cmd_destroy_flow_group(struct mlx5_core_dev *dev,
 	MLX5_SET(destroy_flow_group_in, in, table_type, ft->type);
 	MLX5_SET(destroy_flow_group_in, in, table_id, ft->id);
 	MLX5_SET(destroy_flow_group_in, in, group_id, group_id);
+	if (ft->vport) {
+		MLX5_SET(destroy_flow_group_in, in, vport_number, ft->vport);
+		MLX5_SET(destroy_flow_group_in, in, other_vport, 1);
+	}
 
 	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					  sizeof(out));
@@ -207,6 +232,10 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(set_fte_in, in, table_type, ft->type);
 	MLX5_SET(set_fte_in, in, table_id,   ft->id);
 	MLX5_SET(set_fte_in, in, flow_index, fte->index);
+	if (ft->vport) {
+		MLX5_SET(set_fte_in, in, vport_number, ft->vport);
+		MLX5_SET(set_fte_in, in, other_vport, 1);
+	}
 
 	in_flow_context = MLX5_ADDR_OF(set_fte_in, in, flow_context);
 	MLX5_SET(flow_context, in_flow_context, group_id, group_id);
@@ -285,6 +314,10 @@ int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(delete_fte_in, in, table_type, ft->type);
 	MLX5_SET(delete_fte_in, in, table_id, ft->id);
 	MLX5_SET(delete_fte_in, in, flow_index, index);
+	if (ft->vport) {
+		MLX5_SET(delete_fte_in, in, vport_number, ft->vport);
+		MLX5_SET(delete_fte_in, in, other_vport, 1);
+	}
 
 	err =  mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index 9814d47..c97b4a0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -34,6 +34,7 @@
 #define _MLX5_FS_CMD_
 
 int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
+			       u16 vport,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
 			       *next_ft, unsigned int *table_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 4d78d5a..659a698 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -457,7 +457,7 @@ static struct mlx5_flow_group *alloc_flow_group(u32 *create_fg_in)
 	return fg;
 }
 
-static struct mlx5_flow_table *alloc_flow_table(int level, int max_fte,
+static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_fte,
 						enum fs_flow_table_type table_type)
 {
 	struct mlx5_flow_table *ft;
@@ -469,6 +469,7 @@ static struct mlx5_flow_table *alloc_flow_table(int level, int max_fte,
 	ft->level = level;
 	ft->node.type = FS_TYPE_FLOW_TABLE;
 	ft->type = table_type;
+	ft->vport = vport;
 	ft->max_fte = max_fte;
 	INIT_LIST_HEAD(&ft->fwd_rules);
 	mutex_init(&ft->lock);
@@ -700,9 +701,9 @@ static void list_add_flow_table(struct mlx5_flow_table *ft,
 	list_add(&ft->node.list, prev);
 }
 
-struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-					       int prio, int max_fte,
-					       u32 level)
+static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
+							u16 vport, int prio,
+							int max_fte, u32 level)
 {
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_table *ft;
@@ -732,6 +733,7 @@ struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 	 */
 	level += fs_prio->start_level;
 	ft = alloc_flow_table(level,
+			      vport,
 			      roundup_pow_of_two(max_fte),
 			      root->table_type);
 	if (!ft) {
@@ -742,7 +744,7 @@ struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 	tree_init_node(&ft->node, 1, del_flow_table);
 	log_table_sz = ilog2(ft->max_fte);
 	next_ft = find_next_chained_ft(fs_prio);
-	err = mlx5_cmd_create_flow_table(root->dev, ft->type, ft->level,
+	err = mlx5_cmd_create_flow_table(root->dev, ft->vport, ft->type, ft->level,
 					 log_table_sz, next_ft, &ft->id);
 	if (err)
 		goto free_ft;
@@ -766,6 +768,20 @@ unlock_root:
 	return ERR_PTR(err);
 }
 
+struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
+					       int prio, int max_fte,
+					       u32 level)
+{
+	return __mlx5_create_flow_table(ns, 0, prio, max_fte, level);
+}
+
+struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
+						     int prio, int max_fte,
+						     u32 level, u16 vport)
+{
+	return __mlx5_create_flow_table(ns, vport, prio, max_fte, level);
+}
+
 struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 							    int prio,
 							    int num_flow_table_entries,
@@ -1319,6 +1335,16 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 			return &dev->priv.fdb_root_ns->ns;
 		else
 			return NULL;
+	case MLX5_FLOW_NAMESPACE_ESW_EGRESS:
+		if (dev->priv.esw_egress_root_ns)
+			return &dev->priv.esw_egress_root_ns->ns;
+		else
+			return NULL;
+	case MLX5_FLOW_NAMESPACE_ESW_INGRESS:
+		if (dev->priv.esw_ingress_root_ns)
+			return &dev->priv.esw_ingress_root_ns->ns;
+		else
+			return NULL;
 	default:
 		return NULL;
 	}
@@ -1699,6 +1725,8 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 {
 	cleanup_root_ns(dev);
 	cleanup_single_prio_root_ns(dev, dev->priv.fdb_root_ns);
+	cleanup_single_prio_root_ns(dev, dev->priv.esw_egress_root_ns);
+	cleanup_single_prio_root_ns(dev, dev->priv.esw_ingress_root_ns);
 }
 
 static int init_fdb_root_ns(struct mlx5_core_dev *dev)
@@ -1719,6 +1747,38 @@ static int init_fdb_root_ns(struct mlx5_core_dev *dev)
 	}
 }
 
+static int init_egress_acl_root_ns(struct mlx5_core_dev *dev)
+{
+	struct fs_prio *prio;
+
+	dev->priv.esw_egress_root_ns = create_root_ns(dev, FS_FT_ESW_EGRESS_ACL);
+	if (!dev->priv.esw_egress_root_ns)
+		return -ENOMEM;
+
+	/* create 1 prio*/
+	prio = fs_create_prio(&dev->priv.esw_egress_root_ns->ns, 0, MLX5_TOTAL_VPORTS(dev));
+	if (IS_ERR(prio))
+		return PTR_ERR(prio);
+	else
+		return 0;
+}
+
+static int init_ingress_acl_root_ns(struct mlx5_core_dev *dev)
+{
+	struct fs_prio *prio;
+
+	dev->priv.esw_ingress_root_ns = create_root_ns(dev, FS_FT_ESW_INGRESS_ACL);
+	if (!dev->priv.esw_ingress_root_ns)
+		return -ENOMEM;
+
+	/* create 1 prio*/
+	prio = fs_create_prio(&dev->priv.esw_ingress_root_ns->ns, 0, MLX5_TOTAL_VPORTS(dev));
+	if (IS_ERR(prio))
+		return PTR_ERR(prio);
+	else
+		return 0;
+}
+
 int mlx5_init_fs(struct mlx5_core_dev *dev)
 {
 	int err = 0;
@@ -1731,8 +1791,21 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
 		err = init_fdb_root_ns(dev);
 		if (err)
-			cleanup_root_ns(dev);
+			goto err;
+	}
+	if (MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support)) {
+		err = init_egress_acl_root_ns(dev);
+		if (err)
+			goto err;
+	}
+	if (MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support)) {
+		err = init_ingress_acl_root_ns(dev);
+		if (err)
+			goto err;
 	}
 
+	return 0;
+err:
+	mlx5_cleanup_fs(dev);
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index d607e56..8e76cc5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -45,8 +45,10 @@ enum fs_node_type {
 };
 
 enum fs_flow_table_type {
-	FS_FT_NIC_RX	 = 0x0,
-	FS_FT_FDB	 = 0X4,
+	FS_FT_NIC_RX          = 0x0,
+	FS_FT_ESW_EGRESS_ACL  = 0x2,
+	FS_FT_ESW_INGRESS_ACL = 0x3,
+	FS_FT_FDB             = 0X4,
 };
 
 enum fs_fte_status {
@@ -79,6 +81,7 @@ struct mlx5_flow_rule {
 struct mlx5_flow_table {
 	struct fs_node			node;
 	u32				id;
+	u16				vport;
 	unsigned int			max_fte;
 	unsigned int			level;
 	enum fs_flow_table_type		type;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 0b0b226..482604b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -42,6 +42,8 @@
 #define DRIVER_VERSION "3.0-1"
 #define DRIVER_RELDATE  "January 2015"
 
+#define MLX5_TOTAL_VPORTS(mdev) (1 + pci_sriov_get_totalvfs(mdev->pdev))
+
 extern int mlx5_core_debug_mask;
 
 #define mlx5_core_dbg(__dev, format, ...)				\
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 6bd429b..856de3b 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1338,6 +1338,18 @@ enum mlx5_cap_type {
 #define MLX5_CAP_ESW_FLOWTABLE_FDB_MAX(mdev, cap) \
 	MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, flow_table_properties_nic_esw_fdb.cap)
 
+#define MLX5_CAP_ESW_EGRESS_ACL(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE(mdev, flow_table_properties_esw_acl_egress.cap)
+
+#define MLX5_CAP_ESW_EGRESS_ACL_MAX(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, flow_table_properties_esw_acl_egress.cap)
+
+#define MLX5_CAP_ESW_INGRESS_ACL(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE(mdev, flow_table_properties_esw_acl_ingress.cap)
+
+#define MLX5_CAP_ESW_INGRESS_ACL_MAX(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, flow_table_properties_esw_acl_ingress.cap)
+
 #define MLX5_CAP_ESW(mdev, cap) \
 	MLX5_GET(e_switch_cap, \
 		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH], cap)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index d552944..9613143 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -518,6 +518,8 @@ struct mlx5_priv {
 	unsigned long		pci_dev_data;
 	struct mlx5_flow_root_namespace *root_ns;
 	struct mlx5_flow_root_namespace *fdb_root_ns;
+	struct mlx5_flow_root_namespace *esw_egress_root_ns;
+	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
 };
 
 enum mlx5_device_state {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 165ff4f..6467569 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -58,6 +58,8 @@ enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_LEFTOVERS,
 	MLX5_FLOW_NAMESPACE_ANCHOR,
 	MLX5_FLOW_NAMESPACE_FDB,
+	MLX5_FLOW_NAMESPACE_ESW_EGRESS,
+	MLX5_FLOW_NAMESPACE_ESW_INGRESS,
 };
 
 struct mlx5_flow_table;
@@ -90,6 +92,11 @@ mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 		       int prio,
 		       int num_flow_table_entries,
 		       u32 level);
+struct mlx5_flow_table *
+mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
+			     int prio,
+			     int num_flow_table_entries,
+			     u32 level, u16 vport);
 int mlx5_destroy_flow_table(struct mlx5_flow_table *ft);
 
 /* inbox should be set with the following values:
-- 
2.8.0
