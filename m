From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/14] mlxsw: spectrum_router: Add virtual router management
Date: Mon,  4 Jul 2016 08:23:09 +0200
Message-ID: <1467613397-17140-7-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33375 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbcGDGXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so19141274wme.0
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:29 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Virtual router is a construct used inside HW. In this implementation
we map kernel tables to virtual routers one to one. Introduce management
logic to create virtual routers when needed and destroy in case they are
no longer in use. According to that, call into LPM tree management.
Each virtual router is always bound to one LPM tree.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  14 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 228 +++++++++++++++++++++
 2 files changed, 242 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5db57a7..5b40dfc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -65,6 +65,8 @@
 #define MLXSW_SP_LPM_TREE_MAX 22
 #define MLXSW_SP_LPM_TREE_COUNT (MLXSW_SP_LPM_TREE_MAX - MLXSW_SP_LPM_TREE_MIN)
 
+#define MLXSW_SP_VIRTUAL_ROUTER_MAX 256
+
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
 #define MLXSW_SP_BYTES_PER_CELL 96
@@ -183,8 +185,20 @@ struct mlxsw_sp_lpm_tree {
 	struct mlxsw_sp_prefix_usage prefix_usage;
 };
 
+struct mlxsw_sp_fib;
+
+struct mlxsw_sp_vr {
+	u16 id; /* virtual router ID */
+	bool used;
+	enum mlxsw_sp_l3proto proto;
+	u32 tb_id; /* kernel fib table id */
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	struct mlxsw_sp_fib *fib;
+};
+
 struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
+	struct mlxsw_sp_vr vrs[MLXSW_SP_VIRTUAL_ROUTER_MAX];
 };
 
 struct mlxsw_sp {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 73fd85c..11dab74 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -47,12 +47,46 @@
 	for_each_set_bit(prefix, (prefix_usage)->b, MLXSW_SP_PREFIX_COUNT)
 
 static bool
+mlxsw_sp_prefix_usage_subset(struct mlxsw_sp_prefix_usage *prefix_usage1,
+			     struct mlxsw_sp_prefix_usage *prefix_usage2)
+{
+	unsigned char prefix;
+
+	mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage1) {
+		if (!test_bit(prefix, prefix_usage2->b))
+			return false;
+	}
+	return true;
+}
+
+static bool
 mlxsw_sp_prefix_usage_eq(struct mlxsw_sp_prefix_usage *prefix_usage1,
 			 struct mlxsw_sp_prefix_usage *prefix_usage2)
 {
 	return !memcmp(prefix_usage1, prefix_usage2, sizeof(*prefix_usage1));
 }
 
+static bool
+mlxsw_sp_prefix_usage_none(struct mlxsw_sp_prefix_usage *prefix_usage)
+{
+	struct mlxsw_sp_prefix_usage prefix_usage_none = {{ 0 } };
+
+	return mlxsw_sp_prefix_usage_eq(prefix_usage, &prefix_usage_none);
+}
+
+static void
+mlxsw_sp_prefix_usage_cpy(struct mlxsw_sp_prefix_usage *prefix_usage1,
+			  struct mlxsw_sp_prefix_usage *prefix_usage2)
+{
+	memcpy(prefix_usage1, prefix_usage2, sizeof(*prefix_usage1));
+}
+
+static void
+mlxsw_sp_prefix_usage_zero(struct mlxsw_sp_prefix_usage *prefix_usage)
+{
+	memset(prefix_usage, 0, sizeof(*prefix_usage));
+}
+
 static void
 mlxsw_sp_prefix_usage_set(struct mlxsw_sp_prefix_usage *prefix_usage,
 			  unsigned char prefix_len)
@@ -307,6 +341,199 @@ static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 	}
 }
 
+static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_vr *vr;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+		vr = &mlxsw_sp->router.vrs[i];
+		if (!vr->used)
+			return vr;
+	}
+	return NULL;
+}
+
+static int mlxsw_sp_vr_lpm_tree_bind(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_vr *vr)
+{
+	char raltb_pl[MLXSW_REG_RALTB_LEN];
+
+	mlxsw_reg_raltb_pack(raltb_pl, vr->id, vr->proto, vr->lpm_tree->id);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
+}
+
+static int mlxsw_sp_vr_lpm_tree_unbind(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_vr *vr)
+{
+	char raltb_pl[MLXSW_REG_RALTB_LEN];
+
+	/* Bind to tree 0 which is default */
+	mlxsw_reg_raltb_pack(raltb_pl, vr->id, vr->proto, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
+}
+
+static u32 mlxsw_sp_fix_tb_id(u32 tb_id)
+{
+	/* For our purpose, squash main and local table into one */
+	if (tb_id == RT_TABLE_LOCAL)
+		tb_id = RT_TABLE_MAIN;
+	return tb_id;
+}
+
+static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
+					    u32 tb_id,
+					    enum mlxsw_sp_l3proto proto)
+{
+	struct mlxsw_sp_vr *vr;
+	int i;
+
+	tb_id = mlxsw_sp_fix_tb_id(tb_id);
+	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+		vr = &mlxsw_sp->router.vrs[i];
+		if (vr->used && vr->proto == proto && vr->tb_id == tb_id)
+			return vr;
+	}
+	return NULL;
+}
+
+static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
+					      unsigned char prefix_len,
+					      u32 tb_id,
+					      enum mlxsw_sp_l3proto proto)
+{
+	struct mlxsw_sp_prefix_usage req_prefix_usage;
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	struct mlxsw_sp_vr *vr;
+	int err;
+
+	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
+	if (!vr)
+		return ERR_PTR(-EBUSY);
+	vr->fib = mlxsw_sp_fib_create();
+	if (IS_ERR(vr->fib))
+		return ERR_CAST(vr->fib);
+
+	vr->proto = proto;
+	vr->tb_id = tb_id;
+	mlxsw_sp_prefix_usage_zero(&req_prefix_usage);
+	mlxsw_sp_prefix_usage_set(&req_prefix_usage, prefix_len);
+	lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, &req_prefix_usage,
+					 proto, true);
+	if (IS_ERR(lpm_tree)) {
+		err = PTR_ERR(lpm_tree);
+		goto err_tree_get;
+	}
+	vr->lpm_tree = lpm_tree;
+	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
+	if (err)
+		goto err_tree_bind;
+
+	vr->used = true;
+	return vr;
+
+err_tree_bind:
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
+err_tree_get:
+	mlxsw_sp_fib_destroy(vr->fib);
+
+	return ERR_PTR(err);
+}
+
+static void mlxsw_sp_vr_destroy(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_vr *vr)
+{
+	mlxsw_sp_vr_lpm_tree_unbind(mlxsw_sp, vr);
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
+	mlxsw_sp_fib_destroy(vr->fib);
+	vr->used = false;
+}
+
+static int
+mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
+			   struct mlxsw_sp_prefix_usage *req_prefix_usage)
+{
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+
+	if (mlxsw_sp_prefix_usage_eq(req_prefix_usage,
+				     &vr->lpm_tree->prefix_usage))
+		return 0;
+
+	lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, req_prefix_usage,
+					 vr->proto, false);
+	if (IS_ERR(lpm_tree)) {
+		/* We failed to get a tree according to the required
+		 * prefix usage. However, the current tree might be still good
+		 * for us if our requirement is subset of the prefixes used
+		 * in the tree.
+		 */
+		if (mlxsw_sp_prefix_usage_subset(req_prefix_usage,
+						 &vr->lpm_tree->prefix_usage))
+			return 0;
+		return PTR_ERR(lpm_tree);
+	}
+
+	mlxsw_sp_vr_lpm_tree_unbind(mlxsw_sp, vr);
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
+	vr->lpm_tree = lpm_tree;
+	return mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
+}
+
+static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp,
+					   unsigned char prefix_len,
+					   u32 tb_id,
+					   enum mlxsw_sp_l3proto proto)
+{
+	struct mlxsw_sp_vr *vr;
+	int err;
+
+	tb_id = mlxsw_sp_fix_tb_id(tb_id);
+	vr = mlxsw_sp_vr_find(mlxsw_sp, tb_id, proto);
+	if (!vr) {
+		vr = mlxsw_sp_vr_create(mlxsw_sp, prefix_len, tb_id, proto);
+		if (IS_ERR(vr))
+			return vr;
+	} else {
+		struct mlxsw_sp_prefix_usage req_prefix_usage;
+
+		mlxsw_sp_prefix_usage_cpy(&req_prefix_usage,
+					  &vr->fib->prefix_usage);
+		mlxsw_sp_prefix_usage_set(&req_prefix_usage, prefix_len);
+		/* Need to replace LPM tree in case new prefix is required. */
+		err = mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, vr,
+						 &req_prefix_usage);
+		if (err)
+			return ERR_PTR(err);
+	}
+	return vr;
+}
+
+static void mlxsw_sp_vr_put(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr)
+{
+	/* Destroy virtual router entity in case the associated FIB is empty
+	 * and allow it to be used for other tables in future. Otherwise,
+	 * check if some prefix usage did not disappear and change tree if
+	 * that is the case. Note that in case new, smaller tree cannot be
+	 * allocated, the original one will be kept being used.
+	 */
+	if (mlxsw_sp_prefix_usage_none(&vr->fib->prefix_usage))
+		mlxsw_sp_vr_destroy(mlxsw_sp, vr);
+	else
+		mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, vr,
+					   &vr->fib->prefix_usage);
+}
+
+static void mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_vr *vr;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+		vr = &mlxsw_sp->router.vrs[i];
+		vr->id = i;
+	}
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
@@ -332,6 +559,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 	mlxsw_sp_lpm_init(mlxsw_sp);
+	mlxsw_sp_vrs_init(mlxsw_sp);
 	return 0;
 }
 
-- 
2.5.5
