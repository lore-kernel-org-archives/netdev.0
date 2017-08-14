From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: spectrum_router: Pass argument explicitly
Date: Mon, 14 Aug 2017 10:54:04 +0200
Message-ID: <20170814085405.1452-3-jiri@resnulli.us>
References: <20170814085405.1452-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34725 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbdHNIyL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 04:54:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id x64so13680135wmg.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 01:54:11 -0700 (PDT)
In-Reply-To: <20170814085405.1452-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of relying on the LPM tree to be assigned to the virtual router
before binding the two, lets pass it explicitly.

This will later allow us to return upon binding error instead of having
to perform a rollback of the assignment.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 220e7e7..3c204d2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -659,13 +659,13 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 }
 
 static int mlxsw_sp_vr_lpm_tree_bind(struct mlxsw_sp *mlxsw_sp,
-				     const struct mlxsw_sp_fib *fib)
+				     const struct mlxsw_sp_fib *fib, u8 tree_id)
 {
 	char raltb_pl[MLXSW_REG_RALTB_LEN];
 
 	mlxsw_reg_raltb_pack(raltb_pl, fib->vr->id,
 			     (enum mlxsw_reg_ralxx_protocol) fib->proto,
-			     fib->lpm_tree->id);
+			     tree_id);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 }
 
@@ -777,7 +777,7 @@ mlxsw_sp_vr_lpm_tree_check(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fib *fib,
 
 	/* Prevent packet loss by overwriting existing binding */
 	fib->lpm_tree = new_tree;
-	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib);
+	err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib, new_tree->id);
 	if (err)
 		goto err_tree_bind;
 	mlxsw_sp_lpm_tree_put(mlxsw_sp, lpm_tree);
@@ -2631,7 +2631,7 @@ static int mlxsw_sp_fib_node_init(struct mlxsw_sp *mlxsw_sp,
 		if (IS_ERR(lpm_tree))
 			return PTR_ERR(lpm_tree);
 		fib->lpm_tree = lpm_tree;
-		err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib);
+		err = mlxsw_sp_vr_lpm_tree_bind(mlxsw_sp, fib, lpm_tree->id);
 		if (err)
 			goto err_tree_bind;
 	}
-- 
2.9.3
