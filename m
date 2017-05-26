From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/18] mlxsw: spectrum_router: Allocate FID prior to RIF configuration
Date: Fri, 26 May 2017 08:37:32 +0200
Message-ID: <20170526063740.8909-11-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33468 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970584AbdEZGiD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id b84so1690459wmh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:57 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The following patches are going to re-arrange the FID and RIF code, so
that when the RIF is configured to the device based on the information
present in the RIF struct (which points to a FID).

For this reason, move the FID allocation to just before the RIF
configuration.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 25 +++++++++++-----------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7f1054f..c8d136c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3018,26 +3018,26 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF)
 		return ERR_PTR(-ERANGE);
 
+	fid = mlxsw_sp_rif_sp_to_fid(rif_index);
+	f = mlxsw_sp_rfid_alloc(fid, l3_dev);
+	if (!f)
+		return ERR_PTR(-ENOMEM);
+
 	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
-	if (IS_ERR(vr))
-		return ERR_CAST(vr);
+	if (IS_ERR(vr)) {
+		err = PTR_ERR(vr);
+		goto err_vr_get;
+	}
 
 	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 					   rif_index, true);
 	if (err)
 		goto err_port_vlan_rif_sp_op;
 
-	fid = mlxsw_sp_rif_sp_to_fid(rif_index);
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
 	if (err)
 		goto err_rif_fdb_op;
 
-	f = mlxsw_sp_rfid_alloc(fid, l3_dev);
-	if (!f) {
-		err = -ENOMEM;
-		goto err_rfid_alloc;
-	}
-
 	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
 	if (!rif) {
 		err = -ENOMEM;
@@ -3060,14 +3060,14 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	return rif;
 
 err_rif_alloc:
-	kfree(f);
-err_rfid_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 err_rif_fdb_op:
 	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 				     rif_index, false);
 err_port_vlan_rif_sp_op:
 	mlxsw_sp_vr_put(vr);
+err_vr_get:
+	kfree(f);
 	return ERR_PTR(err);
 }
 
@@ -3094,14 +3094,13 @@ mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 
 	kfree(rif);
 
-	kfree(f);
-
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
 	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 				     rif_index, false);
 
 	mlxsw_sp_vr_put(vr);
+	kfree(f);
 }
 
 static int
-- 
2.9.3
