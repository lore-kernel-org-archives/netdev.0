From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_router: Avoid potential packets loss
Date: Tue, 28 Feb 2017 08:55:40 +0100
Message-ID: <1488268540-1767-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35852 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdB1H5N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 02:57:13 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so962758wmd.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 23:55:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the structure of the LPM tree changes (f.e., due to the addition of
a new prefix), we unbind the old tree and then bind the new one. This
may result in temporary packet loss.

Instead, overwrite the old binding with the new one.

Fixes: 6b75c4807db3 ("mlxsw: spectrum_router: Add virtual router management")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 30 ++++++++++++++--------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index d7ac22d..bd8de6b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -441,30 +441,40 @@ static int
 mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr,
 			   struct mlxsw_sp_prefix_usage *req_prefix_usage)
 {
-	struct mlxsw_sp_lpm_tree *lpm_tree;
+	struct mlxsw_sp_lpm_tree *lpm_tree = vr->lpm_tree;
+	struct mlxsw_sp_lpm_tree *new_tree;
+	int err;
 
-	if (mlxsw_sp_prefix_usage_eq(req_prefix_usage,
-				     &vr->lpm_tree->prefix_usage))
+	if (mlxsw_sp_prefix_usage_eq(req_prefix_usage, &lpm_tree->prefix_usage))
 		return 0;
 
-	lpm_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, req_prefix_usage,
+	new_tree = mlxsw_sp_lpm_tree_get(mlxsw_sp, req_prefix_usage,
 					 vr->proto, false);
-	if (IS_ERR(lpm_tree)) {
+	if (IS_ERR(new_tree)) {
 		/* We failed to get a tree according to the required
 		 * prefix usage. However, the current tree might be still good
 		 * for us if our requirement is subset of the prefixes used
 		 * in the tree.
 		 */
 		if (mlxsw_sp_prefix_usage_subset(req_prefix_usage,
-						 &vr->lpm_tree->prefix_usage))
+						 &lpm_tree->prefix_usage))
 			return 0;
-		return PTR_ERR(lpm_tree);
+		return PTR_ERR(new_tree);
 	}
 
-	mlxsw_sp_vr_lpm_tree_unbind(mlxsw_sp, vr);
-	mlxsw_sp_lpm_tree_put(mlxsw_sp, vr->lpm_tree);
+	/* Prevent packet loss by overwriting existing binding */
+	vr->lpm_tree = new_tree;
+	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
+	if (err)
+		goto err_tree_bind;
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, lpm_tree);
+
+	return 0;
+
+err_tree_bind:
 	vr->lpm_tree = lpm_tree;
-	return mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, vr);
+	mlxsw_sp_lpm_tree_put(mlxsw_sp, new_tree);
+	return err;
 }
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp,
-- 
2.7.4
