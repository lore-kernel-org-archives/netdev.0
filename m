From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/18] mlxsw: spectrum_router: Allocate RIF prior to its configuration
Date: Fri, 26 May 2017 08:37:33 +0200
Message-ID: <20170526063740.8909-12-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34212 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163697AbdEZGiE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so1687192wmf.1
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:03 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In the following patches the RIF's configuration function is going to
expect a RIF struct with all the necessary information.

Therefore, allocate the RIF just before it's configured to the device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 40 ++++++++++------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c8d136c..e81d45c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3029,6 +3029,12 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 		goto err_vr_get;
 	}
 
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	if (!rif) {
+		err = -ENOMEM;
+		goto err_rif_alloc;
+	}
+
 	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 					   rif_index, true);
 	if (err)
@@ -3038,12 +3044,6 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	if (err)
 		goto err_rif_fdb_op;
 
-	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
-	if (!rif) {
-		err = -ENOMEM;
-		goto err_rif_alloc;
-	}
-
 	if (devlink_dpipe_table_counter_enabled(priv_to_devlink(mlxsw_sp->core),
 						MLXSW_SP_DPIPE_TABLE_NAME_ERIF)) {
 		err = mlxsw_sp_rif_counter_alloc(mlxsw_sp, rif,
@@ -3059,12 +3059,12 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 
 	return rif;
 
-err_rif_alloc:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 err_rif_fdb_op:
 	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 				     rif_index, false);
 err_port_vlan_rif_sp_op:
+	kfree(rif);
+err_rif_alloc:
 	mlxsw_sp_vr_put(vr);
 err_vr_get:
 	kfree(f);
@@ -3092,13 +3092,11 @@ mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	mlxsw_sp->router->rifs[rif_index] = NULL;
 	f->rif = NULL;
 
-	kfree(rif);
-
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
 	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 				     rif_index, false);
-
+	kfree(rif);
 	mlxsw_sp_vr_put(vr);
 	kfree(f);
 }
@@ -3343,6 +3341,12 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_port_flood_set;
 
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	if (!rif) {
+		err = -ENOMEM;
+		goto err_rif_alloc;
+	}
+
 	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid,
 				     rif_index, true);
 	if (err)
@@ -3352,12 +3356,6 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_rif_fdb_op;
 
-	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
-	if (!rif) {
-		err = -ENOMEM;
-		goto err_rif_alloc;
-	}
-
 	f->rif = rif;
 	mlxsw_sp->router->rifs[rif_index] = rif;
 	vr->rif_count++;
@@ -3366,12 +3364,12 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 
 	return 0;
 
-err_rif_alloc:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 err_rif_fdb_op:
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
 			       false);
 err_rif_bridge_op:
+	kfree(rif);
+err_rif_alloc:
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 err_port_flood_set:
 	mlxsw_sp_vr_put(vr);
@@ -3392,13 +3390,13 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp->router->rifs[rif_index] = NULL;
 	f->rif = NULL;
 
-	kfree(rif);
-
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
 			       false);
 
+	kfree(rif);
+
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 
 	mlxsw_sp_vr_put(vr);
-- 
2.9.3
