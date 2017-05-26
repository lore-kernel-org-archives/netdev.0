From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/18] mlxsw: spectrum_router: Determine VR first when creating RIF
Date: Fri, 26 May 2017 08:37:38 +0200
Message-ID: <20170526063740.8909-17-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33084 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166199AbdEZGiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:06 -0400
Received: by mail-lf0-f67.google.com with SMTP id m18so172141lfj.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:05 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

All RIF types are associated with a virtual router (VR), so determine VR
first when creating a RIF.

That way, we can more easily integrate the common RIF core in the
following patches.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 38 +++++++++++++---------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 32bf658..0c0ec2a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3025,19 +3025,21 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	u16 fid, rif_index;
 	int err;
 
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
+	if (IS_ERR(vr))
+		return ERR_CAST(vr);
+
 	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF)
-		return ERR_PTR(-ERANGE);
+	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF) {
+		err = -ERANGE;
+		goto err_avail_rif_get;
+	}
 
 	fid = mlxsw_sp_rif_sp_to_fid(rif_index);
 	f = mlxsw_sp_rfid_alloc(fid, l3_dev);
-	if (!f)
-		return ERR_PTR(-ENOMEM);
-
-	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
-	if (IS_ERR(vr)) {
-		err = PTR_ERR(vr);
-		goto err_vr_get;
+	if (!f) {
+		err = -ENOMEM;
+		goto err_rfid_alloc;
 	}
 
 	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f, true);
@@ -3084,9 +3086,10 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 err_port_vlan_rif_sp_op:
 	kfree(rif);
 err_rif_alloc:
-	mlxsw_sp_vr_put(vr);
-err_vr_get:
 	kfree(f);
+err_rfid_alloc:
+err_avail_rif_get:
+	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
 
@@ -3113,8 +3116,8 @@ mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp, rif, false);
 	kfree(rif);
-	mlxsw_sp_vr_put(vr);
 	kfree(f);
+	mlxsw_sp_vr_put(vr);
 }
 
 static int
@@ -3345,14 +3348,16 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	u16 rif_index;
 	int err;
 
-	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF)
-		return -ERANGE;
-
 	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
 	if (IS_ERR(vr))
 		return PTR_ERR(vr);
 
+	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
+	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF) {
+		err = -ERANGE;
+		goto err_avail_rif_get;
+	}
+
 	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f, false);
 	if (!rif) {
 		err = -ENOMEM;
@@ -3386,6 +3391,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 err_rif_bridge_op:
 	kfree(rif);
 err_rif_alloc:
+err_avail_rif_get:
 	mlxsw_sp_vr_put(vr);
 	return err;
 }
-- 
2.9.3
