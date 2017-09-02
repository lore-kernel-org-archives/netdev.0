From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/21] mlxsw: spectrum_router: Support FID-less RIFs
Date: Sat,  2 Sep 2017 23:49:18 +0200
Message-ID: <20170902214929.2890-11-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37224 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752827AbdIBVtt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:49 -0400
Received: by mail-wm0-f67.google.com with SMTP id x189so3152533wmg.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:48 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Loopback RIFs, which will be introduced in a follow-up patch, differ
from other RIFs in that they do not have a FID associated with them.

To support this, demote FID allocation from mlxsw_sp_rif_create to
configure op of the existing RIF types, and likewise the FID release
from mlxsw_sp_rif_destroy to deconfigure op.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 85 ++++++++++++++++------
 1 file changed, 63 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index f85d249..38477c5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -4444,9 +4444,9 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 {
 	u32 tb_id = l3mdev_fib_table(params->dev);
 	const struct mlxsw_sp_rif_ops *ops;
+	struct mlxsw_sp_fid *fid = NULL;
 	enum mlxsw_sp_rif_type type;
 	struct mlxsw_sp_rif *rif;
-	struct mlxsw_sp_fid *fid;
 	struct mlxsw_sp_vr *vr;
 	u16 rif_index;
 	int err;
@@ -4470,12 +4470,14 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	rif->mlxsw_sp = mlxsw_sp;
 	rif->ops = ops;
 
-	fid = ops->fid_get(rif);
-	if (IS_ERR(fid)) {
-		err = PTR_ERR(fid);
-		goto err_fid_get;
+	if (ops->fid_get) {
+		fid = ops->fid_get(rif);
+		if (IS_ERR(fid)) {
+			err = PTR_ERR(fid);
+			goto err_fid_get;
+		}
+		rif->fid = fid;
 	}
-	rif->fid = fid;
 
 	if (ops->setup)
 		ops->setup(rif, params);
@@ -4484,22 +4486,15 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_configure;
 
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, params->dev->dev_addr,
-				  mlxsw_sp_fid_index(fid), true);
-	if (err)
-		goto err_rif_fdb_op;
-
 	mlxsw_sp_rif_counters_alloc(rif);
-	mlxsw_sp_fid_rif_set(fid, rif);
 	mlxsw_sp->router->rifs[rif_index] = rif;
 	vr->rif_count++;
 
 	return rif;
 
-err_rif_fdb_op:
-	ops->deconfigure(rif);
 err_configure:
-	mlxsw_sp_fid_put(fid);
+	if (fid)
+		mlxsw_sp_fid_put(fid);
 err_fid_get:
 	kfree(rif);
 err_rif_alloc:
@@ -4520,12 +4515,11 @@ void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif)
 
 	vr->rif_count--;
 	mlxsw_sp->router->rifs[rif->rif_index] = NULL;
-	mlxsw_sp_fid_rif_set(fid, NULL);
 	mlxsw_sp_rif_counters_free(rif);
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, rif->dev->dev_addr,
-			    mlxsw_sp_fid_index(fid), false);
 	ops->deconfigure(rif);
-	mlxsw_sp_fid_put(fid);
+	if (fid)
+		/* Loopback RIFs are not associated with a FID. */
+		mlxsw_sp_fid_put(fid);
 	kfree(rif);
 	mlxsw_sp_vr_put(vr);
 }
@@ -4965,11 +4959,32 @@ static int mlxsw_sp_rif_subport_op(struct mlxsw_sp_rif *rif, bool enable)
 
 static int mlxsw_sp_rif_subport_configure(struct mlxsw_sp_rif *rif)
 {
-	return mlxsw_sp_rif_subport_op(rif, true);
+	int err;
+
+	err = mlxsw_sp_rif_subport_op(rif, true);
+	if (err)
+		return err;
+
+	err = mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+				  mlxsw_sp_fid_index(rif->fid), true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	mlxsw_sp_fid_rif_set(rif->fid, rif);
+	return 0;
+
+err_rif_fdb_op:
+	mlxsw_sp_rif_subport_op(rif, false);
+	return err;
 }
 
 static void mlxsw_sp_rif_subport_deconfigure(struct mlxsw_sp_rif *rif)
 {
+	struct mlxsw_sp_fid *fid = rif->fid;
+
+	mlxsw_sp_fid_rif_set(fid, NULL);
+	mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+			    mlxsw_sp_fid_index(fid), false);
 	mlxsw_sp_rif_subport_op(rif, false);
 }
 
@@ -5028,8 +5043,17 @@ static int mlxsw_sp_rif_vlan_configure(struct mlxsw_sp_rif *rif)
 	if (err)
 		goto err_fid_bc_flood_set;
 
+	err = mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+				  mlxsw_sp_fid_index(rif->fid), true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	mlxsw_sp_fid_rif_set(rif->fid, rif);
 	return 0;
 
+err_rif_fdb_op:
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
 err_fid_bc_flood_set:
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
@@ -5040,9 +5064,13 @@ static int mlxsw_sp_rif_vlan_configure(struct mlxsw_sp_rif *rif)
 
 static void mlxsw_sp_rif_vlan_deconfigure(struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp *mlxsw_sp = rif->mlxsw_sp;
 	u16 vid = mlxsw_sp_fid_8021q_vid(rif->fid);
+	struct mlxsw_sp *mlxsw_sp = rif->mlxsw_sp;
+	struct mlxsw_sp_fid *fid = rif->fid;
 
+	mlxsw_sp_fid_rif_set(fid, NULL);
+	mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+			    mlxsw_sp_fid_index(fid), false);
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
@@ -5087,8 +5115,17 @@ static int mlxsw_sp_rif_fid_configure(struct mlxsw_sp_rif *rif)
 	if (err)
 		goto err_fid_bc_flood_set;
 
+	err = mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+				  mlxsw_sp_fid_index(rif->fid), true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	mlxsw_sp_fid_rif_set(rif->fid, rif);
 	return 0;
 
+err_rif_fdb_op:
+	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
+			       mlxsw_sp_router_port(mlxsw_sp), false);
 err_fid_bc_flood_set:
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
@@ -5099,9 +5136,13 @@ static int mlxsw_sp_rif_fid_configure(struct mlxsw_sp_rif *rif)
 
 static void mlxsw_sp_rif_fid_deconfigure(struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp *mlxsw_sp = rif->mlxsw_sp;
 	u16 fid_index = mlxsw_sp_fid_index(rif->fid);
+	struct mlxsw_sp *mlxsw_sp = rif->mlxsw_sp;
+	struct mlxsw_sp_fid *fid = rif->fid;
 
+	mlxsw_sp_fid_rif_set(fid, NULL);
+	mlxsw_sp_rif_fdb_op(rif->mlxsw_sp, rif->dev->dev_addr,
+			    mlxsw_sp_fid_index(fid), false);
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_BC,
 			       mlxsw_sp_router_port(mlxsw_sp), false);
 	mlxsw_sp_fid_flood_set(rif->fid, MLXSW_SP_FLOOD_TYPE_MC,
-- 
2.9.3
