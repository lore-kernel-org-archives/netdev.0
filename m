From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/15] mlxsw: spectrum_router: More accurately set offload flag
Date: Wed,  8 Feb 2017 11:16:36 +0100
Message-ID: <1486549002-2056-10-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36345 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753313AbdBHKQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:55 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so32479548wmd.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:54 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We currently set the RTNH_F_OFFLOAD flag for all routes using remote
action, but this isn't always correct. If none of the nexthops
associated with a gatewayed route can be offloaded into the device, then
any packet hitting it would be trapped to the CPU and forwarded by the
kernel.

Solve this by pushing the setting of the offload flag to after the route
was programmed into the device, thereby allowing us to take all the
parameters into account.

This change will also help us further in the patchset, when we refresh
routes following the reception of NH_{ADD,DEL} events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 100 ++++++++++++++++-----
 1 file changed, 80 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index f535135..acabb35 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -130,6 +130,7 @@ struct mlxsw_sp_fib_entry {
 	struct mlxsw_sp_vr *vr;
 	struct list_head nexthop_group_node;
 	struct mlxsw_sp_nexthop_group *nh_group;
+	bool offloaded;
 };
 
 struct mlxsw_sp_fib {
@@ -1613,6 +1614,72 @@ static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_group_destroy(mlxsw_sp, nh_grp);
 }
 
+static bool
+mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_nexthop_group *nh_group = fib_entry->nh_group;
+
+	switch (fib_entry->type) {
+	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
+		return !!nh_group->adj_index_valid;
+	case MLXSW_SP_FIB_ENTRY_TYPE_LOCAL:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	fib_entry->offloaded = true;
+
+	switch (fib_entry->vr->proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		fib_info_offload_inc(fib_entry->nh_group->key.fi);
+		break;
+	case MLXSW_SP_L3_PROTO_IPV6:
+		WARN_ON_ONCE(1);
+	}
+}
+
+static void
+mlxsw_sp_fib_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	switch (fib_entry->vr->proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		fib_info_offload_dec(fib_entry->nh_group->key.fi);
+		break;
+	case MLXSW_SP_L3_PROTO_IPV6:
+		WARN_ON_ONCE(1);
+	}
+
+	fib_entry->offloaded = false;
+}
+
+static void
+mlxsw_sp_fib_entry_offload_refresh(struct mlxsw_sp_fib_entry *fib_entry,
+				   enum mlxsw_reg_ralue_op op, int err)
+{
+	switch (op) {
+	case MLXSW_REG_RALUE_OP_WRITE_DELETE:
+		if (!fib_entry->offloaded)
+			return;
+		return mlxsw_sp_fib_entry_offload_unset(fib_entry);
+	case MLXSW_REG_RALUE_OP_WRITE_WRITE:
+		if (err)
+			return;
+		if (mlxsw_sp_fib_entry_should_offload(fib_entry) &&
+		    !fib_entry->offloaded)
+			mlxsw_sp_fib_entry_offload_set(fib_entry);
+		else if (!mlxsw_sp_fib_entry_should_offload(fib_entry) &&
+			 fib_entry->offloaded)
+			mlxsw_sp_fib_entry_offload_unset(fib_entry);
+		return;
+	default:
+		return;
+	}
+}
+
 static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_fib_entry *fib_entry,
 					 enum mlxsw_reg_ralue_op op)
@@ -1698,13 +1765,17 @@ static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_fib_entry *fib_entry,
 				 enum mlxsw_reg_ralue_op op)
 {
+	int err = -EINVAL;
+
 	switch (fib_entry->vr->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
-		return mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
+		err = mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
+		break;
 	case MLXSW_SP_L3_PROTO_IPV6:
-		return -EINVAL;
+		return err;
 	}
-	return -EINVAL;
+	mlxsw_sp_fib_entry_offload_refresh(fib_entry, op, err);
+	return err;
 }
 
 static int mlxsw_sp_fib_entry_update(struct mlxsw_sp *mlxsw_sp,
@@ -1722,9 +1793,9 @@ static int mlxsw_sp_fib_entry_del(struct mlxsw_sp *mlxsw_sp,
 }
 
 static int
-mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
-				const struct fib_entry_notifier_info *fen_info,
-				struct mlxsw_sp_fib_entry *fib_entry)
+mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
+			     const struct fib_entry_notifier_info *fen_info,
+			     struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct fib_info *fi = fen_info->fi;
 	struct mlxsw_sp_rif *r = NULL;
@@ -1763,18 +1834,9 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 	else
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
-	fib_info_offload_inc(fen_info->fi);
 	return 0;
 }
 
-static void
-mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
-				struct mlxsw_sp_fib_entry *fib_entry)
-{
-	if (fib_entry->type != MLXSW_SP_FIB_ENTRY_TYPE_TRAP)
-		fib_info_offload_dec(fib_entry->nh_group->key.fi);
-}
-
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 		       const struct fib_entry_notifier_info *fen_info)
@@ -1807,9 +1869,9 @@ mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 	fib_entry->vr = vr;
 	fib_entry->ref_count = 1;
 
-	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fen_info, fib_entry);
+	err = mlxsw_sp_fib4_entry_type_set(mlxsw_sp, fen_info, fib_entry);
 	if (err)
-		goto err_fib4_entry_init;
+		goto err_fib4_entry_type_set;
 
 	err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
 	if (err)
@@ -1818,8 +1880,7 @@ mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 	return fib_entry;
 
 err_nexthop_group_get:
-	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
-err_fib4_entry_init:
+err_fib4_entry_type_set:
 	mlxsw_sp_fib_entry_destroy(fib_entry);
 err_fib_entry_create:
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
@@ -1851,7 +1912,6 @@ static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
 
 	if (--fib_entry->ref_count == 0) {
 		mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
-		mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 		mlxsw_sp_fib_entry_destroy(fib_entry);
 	}
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
-- 
2.7.4
