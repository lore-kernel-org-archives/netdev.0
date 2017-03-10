From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] mlxsw: spectrum_router: Simplify LPM tree allocation
Date: Fri, 10 Mar 2017 08:53:40 +0100
Message-ID: <1489132423-12575-8-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33853 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdCJHx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:58 -0500
Received: by mail-wr0-f194.google.com with SMTP id u48so10591870wrc.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:56 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When looking for a new LPM tree we should always consider all the unused
trees. It doesn't matter if the new tree is required due to changes in
currently used prefixes inside an existing routing table or because a
route was inserted into an empty table.

Both cases are functionally identical and therefore should be treated
the same.

When looking for a new LPM tree, consider all unused trees and don't
reserve trees for specific cases.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 1839ba0..c11a5ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -196,19 +196,15 @@ static void mlxsw_sp_fib_destroy(struct mlxsw_sp_fib *fib)
 }
 
 static struct mlxsw_sp_lpm_tree *
-mlxsw_sp_lpm_tree_find_unused(struct mlxsw_sp *mlxsw_sp, bool one_reserved)
+mlxsw_sp_lpm_tree_find_unused(struct mlxsw_sp *mlxsw_sp)
 {
 	static struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
 
 	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
 		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
-		if (lpm_tree->ref_count == 0) {
-			if (one_reserved)
-				one_reserved = false;
-			else
-				return lpm_tree;
-		}
+		if (lpm_tree->ref_count == 0)
+			return lpm_tree;
 	}
 	return NULL;
 }
@@ -262,12 +258,12 @@ mlxsw_sp_lpm_tree_left_struct_set(struct mlxsw_sp *mlxsw_sp,
 static struct mlxsw_sp_lpm_tree *
 mlxsw_sp_lpm_tree_create(struct mlxsw_sp *mlxsw_sp,
 			 struct mlxsw_sp_prefix_usage *prefix_usage,
-			 enum mlxsw_sp_l3proto proto, bool one_reserved)
+			 enum mlxsw_sp_l3proto proto)
 {
 	struct mlxsw_sp_lpm_tree *lpm_tree;
 	int err;
 
-	lpm_tree = mlxsw_sp_lpm_tree_find_unused(mlxsw_sp, one_reserved);
+	lpm_tree = mlxsw_sp_lpm_tree_find_unused(mlxsw_sp);
 	if (!lpm_tree)
 		return ERR_PTR(-EBUSY);
 	lpm_tree->proto = proto;
@@ -297,7 +293,7 @@ static int mlxsw_sp_lpm_tree_destroy(struct mlxsw_sp *mlxsw_sp,
 static struct mlxsw_sp_lpm_tree *
 mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 		      struct mlxsw_sp_prefix_usage *prefix_usage,
-		      enum mlxsw_sp_l3proto proto, bool one_reserved)
+		      enum mlxsw_sp_l3proto proto)
 {
 	struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
@@ -311,7 +307,7 @@ mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 			goto inc_ref_count;
 	}
 	lpm_tree = mlxsw_sp_lpm_tree_create(mlxsw_sp, prefix_usage,
-					    proto, one_reserved);
+					    proto);
 	if (IS_ERR(lpm_tree))
 		return lpm_tree;
 
@@ -421,7 +417,7 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_prefix_usage_zero(&req_prefix_usage);
 	mlxsw_sp_prefix_usage_set(&req_prefix_usage, prefix_len);
 	lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, &req_prefix_usage,
-					 proto, true);
+					 proto);
 	if (IS_ERR(lpm_tree)) {
 		err = PTR_ERR(lpm_tree);
 		goto err_tree_get;
@@ -463,7 +459,7 @@ mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
 		return 0;
 
 	new_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, req_prefix_usage,
-					 vr->proto, false);
+					 vr->proto);
 	if (IS_ERR(new_tree)) {
 		/* We failed to get a tree according to the required
 		 * prefix usage. However, the current tree might be still good
-- 
2.7.4
