From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/14] mlxsw: spectrum_router: Implement LPM trees management
Date: Mon,  4 Jul 2016 08:23:08 +0200
Message-ID: <1467613397-17140-6-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34603 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbcGDGXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:32 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so19172133wmz.1
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:31 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce basic LPM tree management allowing to share the trees in
between tables if the used prefixes in the tables are the same.
Build the tree structure according to the used prefixes. Although it is
not optimal for many use cases, this initial implementation does only
simple linear left-tree. More advanced structures will be introduced
later on, possibly including mechanisms to change trees on the fly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  21 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 155 ++++++++++++++++++++-
 2 files changed, 175 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index da0e072..5db57a7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -61,6 +61,10 @@
 
 #define MLXSW_SP_PORTS_PER_CLUSTER_MAX 4
 
+#define MLXSW_SP_LPM_TREE_MIN 2 /* trees 0 and 1 are reserved */
+#define MLXSW_SP_LPM_TREE_MAX 22
+#define MLXSW_SP_LPM_TREE_COUNT (MLXSW_SP_LPM_TREE_MAX - MLXSW_SP_LPM_TREE_MIN)
+
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
 #define MLXSW_SP_BYTES_PER_CELL 96
@@ -167,6 +171,22 @@ struct mlxsw_sp_prefix_usage {
 	DECLARE_BITMAP(b, MLXSW_SP_PREFIX_COUNT);
 };
 
+enum mlxsw_sp_l3proto {
+	MLXSW_SP_L3_PROTO_IPV4,
+	MLXSW_SP_L3_PROTO_IPV6,
+};
+
+struct mlxsw_sp_lpm_tree {
+	u8 id; /* tree ID */
+	unsigned int ref_count;
+	enum mlxsw_sp_l3proto proto;
+	struct mlxsw_sp_prefix_usage prefix_usage;
+};
+
+struct mlxsw_sp_router {
+	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
+};
+
 struct mlxsw_sp {
 	struct {
 		struct list_head list;
@@ -199,6 +219,7 @@ struct mlxsw_sp {
 	struct mlxsw_sp_upper lags[MLXSW_SP_LAG_MAX];
 	u8 port_to_module[MLXSW_PORT_MAX_PORTS];
 	struct mlxsw_sp_sb sb;
+	struct mlxsw_sp_router router;
 };
 
 static inline struct mlxsw_sp_upper *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index af4a35d..73fd85c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -43,6 +43,16 @@
 #include "core.h"
 #include "reg.h"
 
+#define mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage) \
+	for_each_set_bit(prefix, (prefix_usage)->b, MLXSW_SP_PREFIX_COUNT)
+
+static bool
+mlxsw_sp_prefix_usage_eq(struct mlxsw_sp_prefix_usage *prefix_usage1,
+			 struct mlxsw_sp_prefix_usage *prefix_usage2)
+{
+	return !memcmp(prefix_usage1, prefix_usage2, sizeof(*prefix_usage1));
+}
+
 static void
 mlxsw_sp_prefix_usage_set(struct mlxsw_sp_prefix_usage *prefix_usage,
 			  unsigned char prefix_len)
@@ -160,6 +170,143 @@ static void mlxsw_sp_fib_destroy(struct mlxsw_sp_fib *fib)
 	kfree(fib);
 }
 
+static struct mlxsw_sp_lpm_tree *
+mlxsw_sp_lpm_tree_find_unused(struct mlxsw_sp *mlxsw_sp, bool one_reserved)
+{
+	static struct mlxsw_sp_lpm_tree *lpm_tree;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+		if (lpm_tree->ref_count == 0) {
+			if (one_reserved)
+				one_reserved = false;
+			else
+				return lpm_tree;
+		}
+	}
+	return NULL;
+}
+
+static int mlxsw_sp_lpm_tree_alloc(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_lpm_tree *lpm_tree)
+{
+	char ralta_pl[MLXSW_REG_RALTA_LEN];
+
+	mlxsw_reg_ralta_pack(ralta_pl, true, lpm_tree->proto, lpm_tree->id);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
+}
+
+static int mlxsw_sp_lpm_tree_free(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_lpm_tree *lpm_tree)
+{
+	char ralta_pl[MLXSW_REG_RALTA_LEN];
+
+	mlxsw_reg_ralta_pack(ralta_pl, false, lpm_tree->proto, lpm_tree->id);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
+}
+
+static int
+mlxsw_sp_lpm_tree_left_struct_set(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_prefix_usage *prefix_usage,
+				  struct mlxsw_sp_lpm_tree *lpm_tree)
+{
+	char ralst_pl[MLXSW_REG_RALST_LEN];
+	u8 root_bin = 0;
+	u8 prefix;
+	u8 last_prefix = MLXSW_REG_RALST_BIN_NO_CHILD;
+
+	mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage)
+		root_bin = prefix;
+
+	mlxsw_reg_ralst_pack(ralst_pl, root_bin, lpm_tree->id);
+	mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage) {
+		if (prefix == 0)
+			continue;
+		mlxsw_reg_ralst_bin_pack(ralst_pl, prefix, last_prefix,
+					 MLXSW_REG_RALST_BIN_NO_CHILD);
+		last_prefix = prefix;
+	}
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralst), ralst_pl);
+}
+
+static struct mlxsw_sp_lpm_tree *
+mlxsw_sp_lpm_tree_create(struct mlxsw_sp *mlxsw_sp,
+			 struct mlxsw_sp_prefix_usage *prefix_usage,
+			 enum mlxsw_sp_l3proto proto, bool one_reserved)
+{
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	int err;
+
+	lpm_tree = mlxsw_sp_lpm_tree_find_unused(mlxsw_sp, one_reserved);
+	if (!lpm_tree)
+		return ERR_PTR(-EBUSY);
+	lpm_tree->proto = proto;
+	err = mlxsw_sp_lpm_tree_alloc(mlxsw_sp, lpm_tree);
+	if (err)
+		return ERR_PTR(err);
+
+	err = mlxsw_sp_lpm_tree_left_struct_set(mlxsw_sp, prefix_usage,
+						lpm_tree);
+	if (err)
+		goto err_left_struct_set;
+	return lpm_tree;
+
+err_left_struct_set:
+	mlxsw_sp_lpm_tree_free(mlxsw_sp, lpm_tree);
+	return ERR_PTR(err);
+}
+
+static int mlxsw_sp_lpm_tree_destroy(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_lpm_tree *lpm_tree)
+{
+	return mlxsw_sp_lpm_tree_free(mlxsw_sp, lpm_tree);
+}
+
+static struct mlxsw_sp_lpm_tree *
+mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
+		      struct mlxsw_sp_prefix_usage *prefix_usage,
+		      enum mlxsw_sp_l3proto proto, bool one_reserved)
+{
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+		if (lpm_tree->proto == proto &&
+		    mlxsw_sp_prefix_usage_eq(&lpm_tree->prefix_usage,
+					     prefix_usage))
+			goto inc_ref_count;
+	}
+	lpm_tree = mlxsw_sp_lpm_tree_create(mlxsw_sp, prefix_usage,
+					    proto, one_reserved);
+	if (IS_ERR(lpm_tree))
+		return lpm_tree;
+
+inc_ref_count:
+	lpm_tree->ref_count++;
+	return lpm_tree;
+}
+
+static int mlxsw_sp_lpm_tree_put(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_lpm_tree *lpm_tree)
+{
+	if (--lpm_tree->ref_count == 0)
+		return mlxsw_sp_lpm_tree_destroy(mlxsw_sp, lpm_tree);
+	return 0;
+}
+
+static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+		lpm_tree->id = i + MLXSW_SP_LPM_TREE_MIN;
+	}
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
@@ -179,7 +326,13 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
-	return __mlxsw_sp_router_init(mlxsw_sp);
+	int err;
+
+	err = __mlxsw_sp_router_init(mlxsw_sp);
+	if (err)
+		return err;
+	mlxsw_sp_lpm_init(mlxsw_sp);
+	return 0;
 }
 
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-- 
2.5.5
