From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum_router: Align RIF index allocation with existing code
Date: Sun,  4 Jun 2017 16:53:40 +0200
Message-ID: <20170604145340.14447-4-jiri@resnulli.us>
References: <20170604145340.14447-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36290 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdFDOxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 10:53:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so26125170wmh.3
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 07:53:46 -0700 (PDT)
In-Reply-To: <20170604145340.14447-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The way we usually allocate an index is by letting the allocation
function return an error instead of an invalid index.

Do the same for RIF index.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Petr Machata <petrm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 24 +++++++++++-----------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a4272c3..2006105 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2979,16 +2979,18 @@ mlxsw_sp_dev_rif_type(const struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_sp_fid_type_rif_type(mlxsw_sp, type);
 }
 
-#define MLXSW_SP_INVALID_INDEX_RIF 0xffff
-static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
+static int mlxsw_sp_rif_index_alloc(struct mlxsw_sp *mlxsw_sp, u16 *p_rif_index)
 {
 	int i;
 
-	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		if (!mlxsw_sp->router->rifs[i])
-			return i;
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
+		if (!mlxsw_sp->router->rifs[i]) {
+			*p_rif_index = i;
+			return 0;
+		}
+	}
 
-	return MLXSW_SP_INVALID_INDEX_RIF;
+	return -ENOBUFS;
 }
 
 static struct mlxsw_sp_rif *mlxsw_sp_rif_alloc(size_t rif_size, u16 rif_index,
@@ -3048,11 +3050,9 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
-	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF) {
-		err = -ERANGE;
-		goto err_avail_rif_get;
-	}
+	err = mlxsw_sp_rif_index_alloc(mlxsw_sp, &rif_index);
+	if (err)
+		goto err_rif_index_alloc;
 
 	rif = mlxsw_sp_rif_alloc(ops->rif_size, rif_index, vr->id, params->dev);
 	if (!rif) {
@@ -3095,7 +3095,7 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 err_fid_get:
 	kfree(rif);
 err_rif_alloc:
-err_avail_rif_get:
+err_rif_index_alloc:
 	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
-- 
2.9.3
