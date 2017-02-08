From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/15] mlxsw: spectrum_router: Store nexthop groups in a hash table
Date: Wed,  8 Feb 2017 11:16:29 +0100
Message-ID: <1486549002-2056-3-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34661 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752751AbdBHKQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:47 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so32407066wmi.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:46 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when we're notified about a new RTN_UNICAST route we perform
a lookup on the nexthop group list looking for a group with a matching
configuration to that found in the FIB info. This is quite inefficient.

Instead, we can simply rely on the kernel to consolidate several FIB
configurations into the same FIB info and use the FIB info as the key
for our private nexthop group struct.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 104 +++++++++++----------
 2 files changed, 54 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index dcd641a..8014d15 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -254,13 +254,13 @@ struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
 	struct mlxsw_sp_vr *vrs;
 	struct rhashtable neigh_ht;
+	struct rhashtable nexthop_group_ht;
 	struct {
 		struct delayed_work dw;
 		unsigned long interval;	/* ms */
 	} neighs_update;
 	struct delayed_work nexthop_probe_dw;
 #define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
-	struct list_head nexthop_group_list;
 	struct list_head nexthop_neighs_list;
 	bool aborted;
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 31680de..a511b95 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1107,9 +1107,14 @@ struct mlxsw_sp_nexthop {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 };
 
+struct mlxsw_sp_nexthop_group_key {
+	struct fib_info *fi;
+};
+
 struct mlxsw_sp_nexthop_group {
-	struct list_head list; /* node in mlxsw->router.nexthop_group_list */
+	struct rhash_head ht_node;
 	struct list_head fib_list; /* list of fib entries that use this group */
+	struct mlxsw_sp_nexthop_group_key key;
 	u8 adj_index_valid:1;
 	u32 adj_index;
 	u16 ecmp_size;
@@ -1117,6 +1122,36 @@ struct mlxsw_sp_nexthop_group {
 	struct mlxsw_sp_nexthop nexthops[0];
 };
 
+static const struct rhashtable_params mlxsw_sp_nexthop_group_ht_params = {
+	.key_offset = offsetof(struct mlxsw_sp_nexthop_group, key),
+	.head_offset = offsetof(struct mlxsw_sp_nexthop_group, ht_node),
+	.key_len = sizeof(struct mlxsw_sp_nexthop_group_key),
+};
+
+static int mlxsw_sp_nexthop_group_insert(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	return rhashtable_insert_fast(&mlxsw_sp->router.nexthop_group_ht,
+				      &nh_grp->ht_node,
+				      mlxsw_sp_nexthop_group_ht_params);
+}
+
+static void mlxsw_sp_nexthop_group_remove(struct mlxsw_sp *mlxsw_sp,
+					  struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	rhashtable_remove_fast(&mlxsw_sp->router.nexthop_group_ht,
+			       &nh_grp->ht_node,
+			       mlxsw_sp_nexthop_group_ht_params);
+}
+
+static struct mlxsw_sp_nexthop_group *
+mlxsw_sp_nexthop_group_lookup(struct mlxsw_sp *mlxsw_sp,
+			      struct mlxsw_sp_nexthop_group_key key)
+{
+	return rhashtable_lookup_fast(&mlxsw_sp->router.nexthop_group_ht, &key,
+				      mlxsw_sp_nexthop_group_ht_params);
+}
+
 static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
 					     struct mlxsw_sp_vr *vr,
 					     u32 adj_index, u16 ecmp_size,
@@ -1429,6 +1464,7 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 		return ERR_PTR(-ENOMEM);
 	INIT_LIST_HEAD(&nh_grp->fib_list);
 	nh_grp->count = fi->fib_nhs;
+	nh_grp->key.fi = fi;
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
 		fib_nh = &fi->fib_nh[i];
@@ -1436,10 +1472,13 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 		if (err)
 			goto err_nexthop_init;
 	}
-	list_add_tail(&nh_grp->list, &mlxsw_sp->router.nexthop_group_list);
+	err = mlxsw_sp_nexthop_group_insert(mlxsw_sp, nh_grp);
+	if (err)
+		goto err_nexthop_group_insert;
 	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh_grp);
 	return nh_grp;
 
+err_nexthop_group_insert:
 err_nexthop_init:
 	for (i--; i >= 0; i--)
 		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
@@ -1454,7 +1493,7 @@ mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_nexthop *nh;
 	int i;
 
-	list_del(&nh_grp->list);
+	mlxsw_sp_nexthop_group_remove(mlxsw_sp, nh_grp);
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
 		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
@@ -1464,59 +1503,15 @@ mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
 	kfree(nh_grp);
 }
 
-static bool mlxsw_sp_nexthop_match(struct mlxsw_sp_nexthop *nh,
-				   struct fib_info *fi)
-{
-	int i;
-
-	for (i = 0; i < fi->fib_nhs; i++) {
-		struct fib_nh *fib_nh = &fi->fib_nh[i];
-		struct neighbour *n = nh->neigh_entry->key.n;
-
-		if (memcmp(n->primary_key, &fib_nh->nh_gw,
-			   sizeof(fib_nh->nh_gw)) == 0 &&
-		    n->dev == fib_nh->nh_dev)
-			return true;
-	}
-	return false;
-}
-
-static bool mlxsw_sp_nexthop_group_match(struct mlxsw_sp_nexthop_group *nh_grp,
-					 struct fib_info *fi)
-{
-	int i;
-
-	if (nh_grp->count != fi->fib_nhs)
-		return false;
-	for (i = 0; i < nh_grp->count; i++) {
-		struct mlxsw_sp_nexthop *nh = &nh_grp->nexthops[i];
-
-		if (!mlxsw_sp_nexthop_match(nh, fi))
-			return false;
-	}
-	return true;
-}
-
-static struct mlxsw_sp_nexthop_group *
-mlxsw_sp_nexthop_group_find(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
-{
-	struct mlxsw_sp_nexthop_group *nh_grp;
-
-	list_for_each_entry(nh_grp, &mlxsw_sp->router.nexthop_group_list,
-			    list) {
-		if (mlxsw_sp_nexthop_group_match(nh_grp, fi))
-			return nh_grp;
-	}
-	return NULL;
-}
-
 static int mlxsw_sp_nexthop_group_get(struct mlxsw_sp *mlxsw_sp,
 				      struct mlxsw_sp_fib_entry *fib_entry,
 				      struct fib_info *fi)
 {
+	struct mlxsw_sp_nexthop_group_key key;
 	struct mlxsw_sp_nexthop_group *nh_grp;
 
-	nh_grp = mlxsw_sp_nexthop_group_find(mlxsw_sp, fi);
+	key.fi = fi;
+	nh_grp = mlxsw_sp_nexthop_group_lookup(mlxsw_sp, key);
 	if (!nh_grp) {
 		nh_grp = mlxsw_sp_nexthop_group_create(mlxsw_sp, fi);
 		if (IS_ERR(nh_grp))
@@ -2053,11 +2048,15 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	int err;
 
 	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
-	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_group_list);
 	err = __mlxsw_sp_router_init(mlxsw_sp);
 	if (err)
 		return err;
 
+	err = rhashtable_init(&mlxsw_sp->router.nexthop_group_ht,
+			      &mlxsw_sp_nexthop_group_ht_params);
+	if (err)
+		goto err_nexthop_group_ht_init;
+
 	mlxsw_sp_lpm_init(mlxsw_sp);
 	err = mlxsw_sp_vrs_init(mlxsw_sp);
 	if (err)
@@ -2080,6 +2079,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_neigh_init:
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 err_vrs_init:
+	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
+err_nexthop_group_ht_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
 	return err;
 }
@@ -2089,5 +2090,6 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	unregister_fib_notifier(&mlxsw_sp->fib_nb);
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
+	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
-- 
2.7.4
