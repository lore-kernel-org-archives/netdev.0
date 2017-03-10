From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/10] mlxsw: spectrum_router: Refactor virtual router handling
Date: Fri, 10 Mar 2017 08:53:41 +0100
Message-ID: <1489132423-12575-9-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33861 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752336AbdCJHyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:54:04 -0500
Received: by mail-wr0-f195.google.com with SMTP id u48so10591953wrc.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:54:03 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

A virtual router (VR) is an entity within the device to which routing
tables and interfaces can be bound to. It can be used to implement VRFs.

In the initial implementation we associated the VR with a specific
protocol (e.g., IPv4) and an LPM tree. However, this isn't really
accurate, as the same VR can be used for both IPv4 and IPv6 traffic, by
binding a different LPM tree to a {VR, Proto} pair.

This patch aims to restructure the VR code according to the above logic,
so that VRs are more accurately represented by the driver's data
structures. The main motivation behind this change is to prepare the
driver for VRF offload.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   5 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 326 +++++++++++----------
 2 files changed, 180 insertions(+), 151 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5bc6042..5a7ffa1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -186,11 +186,8 @@ struct mlxsw_sp_fib;
 
 struct mlxsw_sp_vr {
 	u16 id; /* virtual router ID */
-	bool used;
-	enum mlxsw_sp_l3proto proto;
 	u32 tb_id; /* kernel fib table id */
-	struct mlxsw_sp_lpm_tree *lpm_tree;
-	struct mlxsw_sp_fib *fib;
+	struct mlxsw_sp_fib *fib4;
 };
 
 enum mlxsw_sp_span_type {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c11a5ba..0a79fc7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -103,12 +103,6 @@ mlxsw_sp_prefix_usage_cpy(struct mlxsw_sp_prefix_usage *prefix_usage1,
 }
 
 static void
-mlxsw_sp_prefix_usage_zero(struct mlxsw_sp_prefix_usage *prefix_usage)
-{
-	memset(prefix_usage, 0, sizeof(*prefix_usage));
-}
-
-static void
 mlxsw_sp_prefix_usage_set(struct mlxsw_sp_prefix_usage *prefix_usage,
 			  unsigned char prefix_len)
 {
@@ -139,7 +133,7 @@ struct mlxsw_sp_fib_node {
 	struct list_head entry_list;
 	struct list_head list;
 	struct rhash_head ht_node;
-	struct mlxsw_sp_vr *vr;
+	struct mlxsw_sp_fib *fib;
 	struct mlxsw_sp_fib_key key;
 };
 
@@ -163,13 +157,17 @@ struct mlxsw_sp_fib_entry {
 struct mlxsw_sp_fib {
 	struct rhashtable ht;
 	struct list_head node_list;
+	struct mlxsw_sp_vr *vr;
+	struct mlxsw_sp_lpm_tree *lpm_tree;
 	unsigned long prefix_ref_count[MLXSW_SP_PREFIX_COUNT];
 	struct mlxsw_sp_prefix_usage prefix_usage;
+	enum mlxsw_sp_l3proto proto;
 };
 
 static const struct rhashtable_params mlxsw_sp_fib_ht_params;
 
-static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
+static struct mlxsw_sp_fib *mlxsw_sp_fib_create(struct mlxsw_sp_vr *vr,
+						enum mlxsw_sp_l3proto proto)
 {
 	struct mlxsw_sp_fib *fib;
 	int err;
@@ -181,6 +179,8 @@ static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 	if (err)
 		goto err_rhashtable_init;
 	INIT_LIST_HEAD(&fib->node_list);
+	fib->proto = proto;
+	fib->vr = vr;
 	return fib;
 
 err_rhashtable_init:
@@ -191,6 +191,7 @@ static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 static void mlxsw_sp_fib_destroy(struct mlxsw_sp_fib *fib)
 {
 	WARN_ON(!list_empty(&fib->node_list));
+	WARN_ON(fib->lpm_tree);
 	rhashtable_destroy(&fib->ht);
 	kfree(fib);
 }
@@ -335,6 +336,11 @@ static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 	}
 }
 
+static bool mlxsw_sp_vr_is_used(const struct mlxsw_sp_vr *vr)
+{
+	return !!vr->fib4;
+}
+
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_vr *vr;
@@ -342,31 +348,31 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
-		if (!vr->used)
+		if (!mlxsw_sp_vr_is_used(vr))
 			return vr;
 	}
 	return NULL;
 }
 
 static int mlxsw_sp_vr_lpm_tree_bind(struct mlxsw_sp *mlxsw_sp,
-				     struct mlxsw_sp_vr *vr)
+				     const struct mlxsw_sp_fib *fib)
 {
 	char raltb_pl[MLXSW_REG_RALTB_LEN];
 
-	mlxsw_reg_raltb_pack(raltb_pl, vr->id,
-			     (enum mlxsw_reg_ralxx_protocol) vr->proto,
-			     vr->lpm_tree->id);
+	mlxsw_reg_raltb_pack(raltb_pl, fib->vr->id,
+			     (enum mlxsw_reg_ralxx_protocol) fib->proto,
+			     fib->lpm_tree->id);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 }
 
 static int mlxsw_sp_vr_lpm_tree_unbind(struct mlxsw_sp *mlxsw_sp,
-				       struct mlxsw_sp_vr *vr)
+				       const struct mlxsw_sp_fib *fib)
 {
 	char raltb_pl[MLXSW_REG_RALTB_LEN];
 
 	/* Bind to tree 0 which is default */
-	mlxsw_reg_raltb_pack(raltb_pl, vr->id,
-			     (enum mlxsw_reg_ralxx_protocol) vr->proto, 0);
+	mlxsw_reg_raltb_pack(raltb_pl, fib->vr->id,
+			     (enum mlxsw_reg_ralxx_protocol) fib->proto, 0);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 }
 
@@ -379,8 +385,7 @@ static u32 mlxsw_sp_fix_tb_id(u32 tb_id)
 }
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
-					    u32 tb_id,
-					    enum mlxsw_sp_l3proto proto)
+					    u32 tb_id)
 {
 	struct mlxsw_sp_vr *vr;
 	int i;
@@ -389,69 +394,50 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
-		if (vr->used && vr->proto == proto && vr->tb_id == tb_id)
+		if (mlxsw_sp_vr_is_used(vr) && vr->tb_id == tb_id)
 			return vr;
 	}
 	return NULL;
 }
 
+static struct mlxsw_sp_fib *mlxsw_sp_vr_fib(const struct mlxsw_sp_vr *vr,
+					    enum mlxsw_sp_l3proto proto)
+{
+	switch (proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		return vr->fib4;
+	case MLXSW_SP_L3_PROTO_IPV6:
+		BUG_ON(1);
+	}
+	return NULL;
+}
+
 static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
-					      unsigned char prefix_len,
-					      u32 tb_id,
-					      enum mlxsw_sp_l3proto proto)
+					      u32 tb_id)
 {
-	struct mlxsw_sp_prefix_usage req_prefix_usage;
-	struct mlxsw_sp_lpm_tree *lpm_tree;
 	struct mlxsw_sp_vr *vr;
-	int err;
 
 	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
 	if (!vr)
 		return ERR_PTR(-EBUSY);
-	vr->fib = mlxsw_sp_fib_create();
-	if (IS_ERR(vr->fib))
-		return ERR_CAST(vr->fib);
-
-	vr->proto = proto;
+	vr->fib4 = mlxsw_sp_fib_create(vr, MLXSW_SP_L3_PROTO_IPV4);
+	if (IS_ERR(vr->fib4))
+		return ERR_CAST(vr->fib4);
 	vr->tb_id = tb_id;
-	mlxsw_sp_prefix_usage_zero(&req_prefix_usage);
-	mlxsw_sp_prefix_usage_set(&req_prefix_usage, prefix_len);
-	lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, &req_prefix_usage,
-					 proto);
-	if (IS_ERR(lpm_tree)) {
-		err = PTR_ERR(lpm_tree);
-		goto err_tree_get;
-	}
-	vr->lpm_tree = lpm_tree;
-	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
-	if (err)
-		goto err_tree_bind;
-
-	vr->used = true;
 	return vr;
-
-err_tree_bind:
-	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
-err_tree_get:
-	mlxsw_sp_fib_destroy(vr->fib);
-
-	return ERR_PTR(err);
 }
 
-static void mlxsw_sp_vr_destroy(struct mlxsw_sp *mlxsw_sp,
-				struct mlxsw_sp_vr *vr)
+static void mlxsw_sp_vr_destroy(struct mlxsw_sp_vr *vr)
 {
-	mlxsw_sp_vr_lpm_tree_unbind(mlxsw_sp, vr);
-	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
-	mlxsw_sp_fib_destroy(vr->fib);
-	vr->used = false;
+	mlxsw_sp_fib_destroy(vr->fib4);
+	vr->fib4 = NULL;
 }
 
 static int
-mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
+mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fib *fib,
 			   struct mlxsw_sp_prefix_usage *req_prefix_usage)
 {
-	struct mlxsw_sp_lpm_tree *lpm_tree = vr->lpm_tree;
+	struct mlxsw_sp_lpm_tree *lpm_tree = fib->lpm_tree;
 	struct mlxsw_sp_lpm_tree *new_tree;
 	int err;
 
@@ -459,7 +445,7 @@ mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
 		return 0;
 
 	new_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, req_prefix_usage,
-					 vr->proto);
+					 fib->proto);
 	if (IS_ERR(new_tree)) {
 		/* We failed to get a tree according to the required
 		 * prefix usage. However, the current tree might be still good
@@ -473,8 +459,8 @@ mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
 	}
 
 	/* Prevent packet loss by overwriting existing binding */
-	vr->lpm_tree = new_tree;
-	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
+	fib->lpm_tree = new_tree;
+	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib);
 	if (err)
 		goto err_tree_bind;
 	mlxsw_sp_lpm_tree_put(mlxsw_sp, lpm_tree);
@@ -482,53 +468,26 @@ mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
 	return 0;
 
 err_tree_bind:
-	vr->lpm_tree = lpm_tree;
+	fib->lpm_tree = lpm_tree;
 	mlxsw_sp_lpm_tree_put(mlxsw_sp, new_tree);
 	return err;
 }
 
-static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp,
-					   unsigned char prefix_len,
-					   u32 tb_id,
-					   enum mlxsw_sp_l3proto proto)
+static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id)
 {
 	struct mlxsw_sp_vr *vr;
-	int err;
 
 	tb_id = mlxsw_sp_fix_tb_id(tb_id);
-	vr = mlxsw_sp_vr_find(mlxsw_sp, tb_id, proto);
-	if (!vr) {
-		vr = mlxsw_sp_vr_create(mlxsw_sp, prefix_len, tb_id, proto);
-		if (IS_ERR(vr))
-			return vr;
-	} else {
-		struct mlxsw_sp_prefix_usage req_prefix_usage;
-
-		mlxsw_sp_prefix_usage_cpy(&req_prefix_usage,
-					  &vr->fib->prefix_usage);
-		mlxsw_sp_prefix_usage_set(&req_prefix_usage, prefix_len);
-		/* Need to replace LPM tree in case new prefix is required. */
-		err = mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, vr,
-						 &req_prefix_usage);
-		if (err)
-			return ERR_PTR(err);
-	}
+	vr = mlxsw_sp_vr_find(mlxsw_sp, tb_id);
+	if (!vr)
+		vr = mlxsw_sp_vr_create(mlxsw_sp, tb_id);
 	return vr;
 }
 
-static void mlxsw_sp_vr_put(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr)
+static void mlxsw_sp_vr_put(struct mlxsw_sp_vr *vr)
 {
-	/* Destroy virtual router entity in case the associated FIB is empty
-	 * and allow it to be used for other tables in future. Otherwise,
-	 * check if some prefix usage did not disappear and change tree if
-	 * that is the case. Note that in case new, smaller tree cannot be
-	 * allocated, the original one will be kept being used.
-	 */
-	if (mlxsw_sp_prefix_usage_none(&vr->fib->prefix_usage))
-		mlxsw_sp_vr_destroy(mlxsw_sp, vr);
-	else
-		mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, vr,
-					   &vr->fib->prefix_usage);
+	if (list_empty(&vr->fib4->node_list))
+		mlxsw_sp_vr_destroy(vr);
 }
 
 static int mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
@@ -1181,7 +1140,7 @@ mlxsw_sp_nexthop_lookup(struct mlxsw_sp *mlxsw_sp,
 }
 
 static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
-					     struct mlxsw_sp_vr *vr,
+					     const struct mlxsw_sp_fib *fib,
 					     u32 adj_index, u16 ecmp_size,
 					     u32 new_adj_index,
 					     u16 new_ecmp_size)
@@ -1189,8 +1148,8 @@ static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
 	char raleu_pl[MLXSW_REG_RALEU_LEN];
 
 	mlxsw_reg_raleu_pack(raleu_pl,
-			     (enum mlxsw_reg_ralxx_protocol) vr->proto, vr->id,
-			     adj_index, ecmp_size, new_adj_index,
+			     (enum mlxsw_reg_ralxx_protocol) fib->proto,
+			     fib->vr->id, adj_index, ecmp_size, new_adj_index,
 			     new_ecmp_size);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raleu), raleu_pl);
 }
@@ -1200,14 +1159,14 @@ static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
 					  u32 old_adj_index, u16 old_ecmp_size)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct mlxsw_sp_vr *vr = NULL;
+	struct mlxsw_sp_fib *fib = NULL;
 	int err;
 
 	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
-		if (vr == fib_entry->fib_node->vr)
+		if (fib == fib_entry->fib_node->fib)
 			continue;
-		vr = fib_entry->fib_node->vr;
-		err = mlxsw_sp_adj_index_mass_update_vr(mlxsw_sp, vr,
+		fib = fib_entry->fib_node->fib;
+		err = mlxsw_sp_adj_index_mass_update_vr(mlxsw_sp, fib,
 							old_adj_index,
 							old_ecmp_size,
 							nh_grp->adj_index,
@@ -1712,7 +1671,7 @@ static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 {
 	fib_entry->offloaded = true;
 
-	switch (fib_entry->fib_node->vr->proto) {
+	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		fib_info_offload_inc(fib_entry->nh_group->key.fi);
 		break;
@@ -1724,7 +1683,7 @@ static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 static void
 mlxsw_sp_fib_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 {
-	switch (fib_entry->fib_node->vr->proto) {
+	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		fib_info_offload_dec(fib_entry->nh_group->key.fi);
 		break;
@@ -1764,8 +1723,8 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 					 enum mlxsw_reg_ralue_op op)
 {
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
+	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	u16 trap_id = 0;
 	u32 adjacency_index = 0;
@@ -1785,8 +1744,8 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
+			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
 			      *p_dip);
 	mlxsw_reg_ralue_act_remote_pack(ralue_pl, trap_action, trap_id,
 					adjacency_index, ecmp_size);
@@ -1798,10 +1757,10 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 					enum mlxsw_reg_ralue_op op)
 {
 	struct mlxsw_sp_rif *r = fib_entry->nh_group->nh_rif;
+	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 	u16 trap_id = 0;
 	u16 rif = 0;
 
@@ -1814,8 +1773,8 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
+			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
 			      *p_dip);
 	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id, rif);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
@@ -1825,13 +1784,13 @@ static int mlxsw_sp_fib_entry_op4_trap(struct mlxsw_sp *mlxsw_sp,
 				       struct mlxsw_sp_fib_entry *fib_entry,
 				       enum mlxsw_reg_ralue_op op)
 {
+	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
-			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
+			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
 			      *p_dip);
 	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
@@ -1858,7 +1817,7 @@ static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
 {
 	int err = -EINVAL;
 
-	switch (fib_entry->fib_node->vr->proto) {
+	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		err = mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
 		break;
@@ -2021,7 +1980,7 @@ mlxsw_sp_fib_node_lookup(struct mlxsw_sp_fib *fib, const void *addr,
 }
 
 static struct mlxsw_sp_fib_node *
-mlxsw_sp_fib_node_create(struct mlxsw_sp_vr *vr, const void *addr,
+mlxsw_sp_fib_node_create(struct mlxsw_sp_fib *fib, const void *addr,
 			 size_t addr_len, unsigned char prefix_len)
 {
 	struct mlxsw_sp_fib_node *fib_node;
@@ -2031,18 +1990,15 @@ mlxsw_sp_fib_node_create(struct mlxsw_sp_vr *vr, const void *addr,
 		return NULL;
 
 	INIT_LIST_HEAD(&fib_node->entry_list);
-	list_add(&fib_node->list, &vr->fib->node_list);
+	list_add(&fib_node->list, &fib->node_list);
 	memcpy(fib_node->key.addr, addr, addr_len);
 	fib_node->key.prefix_len = prefix_len;
-	mlxsw_sp_fib_node_insert(vr->fib, fib_node);
-	fib_node->vr = vr;
 
 	return fib_node;
 }
 
 static void mlxsw_sp_fib_node_destroy(struct mlxsw_sp_fib_node *fib_node)
 {
-	mlxsw_sp_fib_node_remove(fib_node->vr->fib, fib_node);
 	list_del(&fib_node->list);
 	WARN_ON(!list_empty(&fib_node->entry_list));
 	kfree(fib_node);
@@ -2059,7 +2015,7 @@ mlxsw_sp_fib_node_entry_is_first(const struct mlxsw_sp_fib_node *fib_node,
 static void mlxsw_sp_fib_node_prefix_inc(struct mlxsw_sp_fib_node *fib_node)
 {
 	unsigned char prefix_len = fib_node->key.prefix_len;
-	struct mlxsw_sp_fib *fib = fib_node->vr->fib;
+	struct mlxsw_sp_fib *fib = fib_node->fib;
 
 	if (fib->prefix_ref_count[prefix_len]++ == 0)
 		mlxsw_sp_prefix_usage_set(&fib->prefix_usage, prefix_len);
@@ -2068,32 +2024,98 @@ static void mlxsw_sp_fib_node_prefix_inc(struct mlxsw_sp_fib_node *fib_node)
 static void mlxsw_sp_fib_node_prefix_dec(struct mlxsw_sp_fib_node *fib_node)
 {
 	unsigned char prefix_len = fib_node->key.prefix_len;
-	struct mlxsw_sp_fib *fib = fib_node->vr->fib;
+	struct mlxsw_sp_fib *fib = fib_node->fib;
 
 	if (--fib->prefix_ref_count[prefix_len] == 0)
 		mlxsw_sp_prefix_usage_clear(&fib->prefix_usage, prefix_len);
 }
 
+static int mlxsw_sp_fib_node_init(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_fib_node *fib_node,
+				  struct mlxsw_sp_fib *fib)
+{
+	struct mlxsw_sp_prefix_usage req_prefix_usage;
+	struct mlxsw_sp_lpm_tree *lpm_tree;
+	int err;
+
+	err = mlxsw_sp_fib_node_insert(fib, fib_node);
+	if (err)
+		return err;
+	fib_node->fib = fib;
+
+	mlxsw_sp_prefix_usage_cpy(&req_prefix_usage, &fib->prefix_usage);
+	mlxsw_sp_prefix_usage_set(&req_prefix_usage, fib_node->key.prefix_len);
+
+	if (!mlxsw_sp_prefix_usage_none(&fib->prefix_usage)) {
+		err = mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, fib,
+						 &req_prefix_usage);
+		if (err)
+			goto err_tree_check;
+	} else {
+		lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, &req_prefix_usage,
+						 fib->proto);
+		if (IS_ERR(lpm_tree))
+			return PTR_ERR(lpm_tree);
+		fib->lpm_tree = lpm_tree;
+		err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib);
+		if (err)
+			goto err_tree_bind;
+	}
+
+	mlxsw_sp_fib_node_prefix_inc(fib_node);
+
+	return 0;
+
+err_tree_bind:
+	fib->lpm_tree = NULL;
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, lpm_tree);
+err_tree_check:
+	fib_node->fib = NULL;
+	mlxsw_sp_fib_node_remove(fib, fib_node);
+	return err;
+}
+
+static void mlxsw_sp_fib_node_fini(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_fib_node *fib_node)
+{
+	struct mlxsw_sp_lpm_tree *lpm_tree = fib_node->fib->lpm_tree;
+	struct mlxsw_sp_fib *fib = fib_node->fib;
+
+	mlxsw_sp_fib_node_prefix_dec(fib_node);
+
+	if (mlxsw_sp_prefix_usage_none(&fib->prefix_usage)) {
+		mlxsw_sp_vr_lpm_tree_unbind(mlxsw_sp, fib);
+		fib->lpm_tree = NULL;
+		mlxsw_sp_lpm_tree_put(mlxsw_sp, lpm_tree);
+	} else {
+		mlxsw_sp_vr_lpm_tree_check(mlxsw_sp, fib, &fib->prefix_usage);
+	}
+
+	fib_node->fib = NULL;
+	mlxsw_sp_fib_node_remove(fib, fib_node);
+}
+
 static struct mlxsw_sp_fib_node *
 mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
 		       const struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_fib_node *fib_node;
+	struct mlxsw_sp_fib *fib;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->dst_len, fen_info->tb_id,
-			     MLXSW_SP_L3_PROTO_IPV4);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->tb_id);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
+	fib = mlxsw_sp_vr_fib(vr, MLXSW_SP_L3_PROTO_IPV4);
 
-	fib_node = mlxsw_sp_fib_node_lookup(vr->fib, &fen_info->dst,
+	fib_node = mlxsw_sp_fib_node_lookup(fib, &fen_info->dst,
 					    sizeof(fen_info->dst),
 					    fen_info->dst_len);
 	if (fib_node)
 		return fib_node;
 
-	fib_node = mlxsw_sp_fib_node_create(vr, &fen_info->dst,
+	fib_node = mlxsw_sp_fib_node_create(fib, &fen_info->dst,
 					    sizeof(fen_info->dst),
 					    fen_info->dst_len);
 	if (!fib_node) {
@@ -2101,22 +2123,29 @@ mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
 		goto err_fib_node_create;
 	}
 
+	err = mlxsw_sp_fib_node_init(mlxsw_sp, fib_node, fib);
+	if (err)
+		goto err_fib_node_init;
+
 	return fib_node;
 
+err_fib_node_init:
+	mlxsw_sp_fib_node_destroy(fib_node);
 err_fib_node_create:
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
 
 static void mlxsw_sp_fib4_node_put(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_fib_node *fib_node)
 {
-	struct mlxsw_sp_vr *vr = fib_node->vr;
+	struct mlxsw_sp_vr *vr = fib_node->fib->vr;
 
 	if (!list_empty(&fib_node->entry_list))
 		return;
+	mlxsw_sp_fib_node_fini(mlxsw_sp, fib_node);
 	mlxsw_sp_fib_node_destroy(fib_node);
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	mlxsw_sp_vr_put(vr);
 }
 
 static struct mlxsw_sp_fib_entry *
@@ -2261,8 +2290,6 @@ static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_fib4_node_entry_add;
 
-	mlxsw_sp_fib_node_prefix_inc(fib_node);
-
 	return 0;
 
 err_fib4_node_entry_add:
@@ -2276,7 +2303,6 @@ mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
 
-	mlxsw_sp_fib_node_prefix_dec(fib_node);
 	mlxsw_sp_fib4_node_entry_del(mlxsw_sp, fib_node, fib_entry);
 	mlxsw_sp_fib4_node_list_remove(fib_entry);
 }
@@ -2415,7 +2441,7 @@ static void mlxsw_sp_fib4_node_flush(struct mlxsw_sp *mlxsw_sp,
 static void mlxsw_sp_fib_node_flush(struct mlxsw_sp *mlxsw_sp,
 				    struct mlxsw_sp_fib_node *fib_node)
 {
-	switch (fib_node->vr->proto) {
+	switch (fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		mlxsw_sp_fib4_node_flush(mlxsw_sp, fib_node);
 		break;
@@ -2425,26 +2451,32 @@ static void mlxsw_sp_fib_node_flush(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
-static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
+static void mlxsw_sp_vr_fib_flush(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_vr *vr,
+				  enum mlxsw_sp_l3proto proto)
 {
+	struct mlxsw_sp_fib *fib = mlxsw_sp_vr_fib(vr, proto);
 	struct mlxsw_sp_fib_node *fib_node, *tmp;
-	struct mlxsw_sp_vr *vr;
+
+	list_for_each_entry_safe(fib_node, tmp, &fib->node_list, list) {
+		bool do_break = &tmp->list == &fib->node_list;
+
+		mlxsw_sp_fib_node_flush(mlxsw_sp, fib_node);
+		if (do_break)
+			break;
+	}
+}
+
+static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
+{
 	int i;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
-		vr = &mlxsw_sp->router.vrs[i];
+		struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[i];
 
-		if (!vr->used)
+		if (!mlxsw_sp_vr_is_used(vr))
 			continue;
-
-		list_for_each_entry_safe(fib_node, tmp, &vr->fib->node_list,
-					 list) {
-			bool do_break = &tmp->list == &vr->fib->node_list;
-
-			mlxsw_sp_fib_node_flush(mlxsw_sp, fib_node);
-			if (do_break)
-				break;
-		}
+		mlxsw_sp_vr_fib_flush(mlxsw_sp, vr, MLXSW_SP_L3_PROTO_IPV4);
 	}
 }
 
-- 
2.7.4
