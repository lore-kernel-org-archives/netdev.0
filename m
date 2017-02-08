From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/15] mlxsw: spectrum_router: Store routes in a more generic way
Date: Wed,  8 Feb 2017 11:16:33 +0100
Message-ID: <1486549002-2056-7-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36323 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752874AbdBHKQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:51 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so32479357wmd.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:51 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now, the only FIB entries that were associated with a nexthop
group were routes to remote networks where all the nexthop devices had a
valid router interface (RIF). This is in contrast to the FIB code,
where all the routes are associated with a FIB info. The same design
choice needs to be applied to the driver's cache.

Based on the NH_{ADD,DEL} events which will be added later in the
patchset, we need to be able to change the action (forward / trap)
associated with all the routes using the nexthop group. However, if we
can't link between the nexthop and the routes using it, then the above
is impossible.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 40 +++++++++++++++-------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 110a7bb..8a72a1b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -127,7 +127,6 @@ struct mlxsw_sp_fib_entry {
 	struct mlxsw_sp_fib_key key;
 	enum mlxsw_sp_fib_entry_type type;
 	unsigned int ref_count;
-	u16 rif; /* used for action local */
 	struct mlxsw_sp_vr *vr;
 	struct fib_info *fi;
 	struct list_head nexthop_group_node;
@@ -1101,6 +1100,7 @@ struct mlxsw_sp_nexthop {
 						*/
 	struct rhash_head ht_node;
 	struct mlxsw_sp_nexthop_key key;
+	struct mlxsw_sp_rif *r;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
 			      */
@@ -1127,6 +1127,7 @@ struct mlxsw_sp_nexthop_group {
 	u16 ecmp_size;
 	u16 count;
 	struct mlxsw_sp_nexthop nexthops[0];
+#define nh_rif	nexthops[0].r
 };
 
 static const struct rhashtable_params mlxsw_sp_nexthop_group_ht_params = {
@@ -1414,15 +1415,25 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct net_device *dev = fib_nh->nh_dev;
+	struct mlxsw_sp_rif *r;
 	struct neighbour *n;
 	u8 nud_state, dead;
 	int err;
 
+	nh->nh_grp = nh_grp;
 	nh->key.fib_nh = fib_nh;
 	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
 	if (err)
 		return err;
 
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!r)
+		return 0;
+	nh->r = r;
+
+	if (!nh_grp->gateway)
+		return 0;
+
 	/* Take a reference of neigh here ensuring that neigh would
 	 * not be detructed before the nexthop entry is finished.
 	 * The reference is taken either in neigh_lookup() or
@@ -1453,7 +1464,6 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 		list_add_tail(&neigh_entry->nexthop_neighs_list_node,
 			      &mlxsw_sp->router.nexthop_neighs_list);
 
-	nh->nh_grp = nh_grp;
 	nh->neigh_entry = neigh_entry;
 	list_add_tail(&nh->neigh_list_node, &neigh_entry->nexthop_list);
 	read_lock_bh(&n->lock);
@@ -1477,6 +1487,9 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 	struct neighbour *n = neigh_entry->key.n;
 
+	if (!neigh_entry)
+		goto out;
+
 	__mlxsw_sp_nexthop_neigh_update(nh, true);
 	list_del(&nh->neigh_list_node);
 	nh->neigh_entry = NULL;
@@ -1492,6 +1505,7 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 
 	neigh_release(n);
 
+out:
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
@@ -1619,6 +1633,7 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 					struct mlxsw_sp_fib_entry *fib_entry,
 					enum mlxsw_reg_ralue_op op)
 {
+	struct mlxsw_sp_rif *r = fib_entry->nh_group->nh_rif;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	u32 *p_dip = (u32 *) fib_entry->key.addr;
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
@@ -1628,7 +1643,7 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 			      vr->id, fib_entry->key.prefix_len, *p_dip);
 	mlxsw_reg_ralue_act_local_pack(ralue_pl,
 				       MLXSW_REG_RALUE_TRAP_ACTION_NOP, 0,
-				       fib_entry->rif);
+				       r->rif);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
@@ -1697,7 +1712,6 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 	struct fib_info *fi = fen_info->fi;
 	struct mlxsw_sp_rif *r = NULL;
 	int nhsel;
-	int err;
 
 	if (fen_info->type == RTN_LOCAL || fen_info->type == RTN_BROADCAST) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
@@ -1728,15 +1742,10 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 		return 0;
 	}
 
-	if (fi->fib_nh->nh_scope != RT_SCOPE_LINK) {
+	if (fi->fib_nh->nh_scope != RT_SCOPE_LINK)
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-		fib_entry->rif = r->rif;
-	} else {
+	else
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
-		err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
-		if (err)
-			return err;
-	}
 	fib_info_offload_inc(fen_info->fi);
 	return 0;
 }
@@ -1747,8 +1756,6 @@ mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
 {
 	if (fib_entry->type != MLXSW_SP_FIB_ENTRY_TYPE_TRAP)
 		fib_info_offload_dec(fib_entry->fi);
-	if (fib_entry->type == MLXSW_SP_FIB_ENTRY_TYPE_REMOTE)
-		mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
 }
 
 static struct mlxsw_sp_fib_entry *
@@ -1788,8 +1795,14 @@ mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_fib4_entry_init;
 
+	err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
+	if (err)
+		goto err_nexthop_group_get;
+
 	return fib_entry;
 
+err_nexthop_group_get:
+	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 err_fib4_entry_init:
 	mlxsw_sp_fib_entry_destroy(fib_entry);
 err_fib_entry_create:
@@ -1821,6 +1834,7 @@ static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
 	if (--fib_entry->ref_count == 0) {
+		mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
 		mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 		mlxsw_sp_fib_entry_destroy(fib_entry);
 	}
-- 
2.7.4
