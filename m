From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/18] mlxsw: spectrum_router: Configure RIFs based on RIF struct
Date: Fri, 26 May 2017 08:37:35 +0200
Message-ID: <20170526063740.8909-14-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34280 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970583AbdEZGiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:02 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so1687349wmf.1
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:01 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

All the information necessary for the configuration of RIFs can now be
found in the RIF struct itself, so reduce the arguments list.

This gets us one step closer to the common RIF core.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 56 +++++++++-------------
 1 file changed, 23 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 28ba5d3..73cc519 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2928,22 +2928,20 @@ static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 }
 
 static int
-mlxsw_sp_port_vlan_rif_sp_op(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
-			     u16 vr_id, struct net_device *l3_dev,
-			     u16 rif_index, bool create)
+mlxsw_sp_port_vlan_rif_sp_op(struct mlxsw_sp *mlxsw_sp,
+			     const struct mlxsw_sp_rif *rif, bool create)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	bool lagged = mlxsw_sp_port->lagged;
+	struct mlxsw_sp_rif_subport *rif_subport;
 	char ritr_pl[MLXSW_REG_RITR_LEN];
-	u16 system_port;
 
-	system_port = lagged ? mlxsw_sp_port->lag_id :
-			       mlxsw_sp_port->local_port;
-	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif_index,
-			    vr_id, l3_dev->mtu, l3_dev->dev_addr);
-	mlxsw_reg_ritr_sp_if_pack(ritr_pl, lagged, system_port,
-				  mlxsw_sp_port_vlan->vid);
+	rif_subport = container_of(rif, struct mlxsw_sp_rif_subport, common);
+	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF,
+			    rif->rif_index, rif->vr_id, rif->dev->mtu,
+			    rif->dev->dev_addr);
+	mlxsw_reg_ritr_sp_if_pack(ritr_pl, rif_subport->lag,
+				  rif_subport->lag ? rif_subport->lag_id :
+						     rif_subport->system_port,
+				  rif_subport->vid);
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 }
@@ -3058,8 +3056,7 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 		rif_subport->system_port = mlxsw_sp_port->local_port;
 	}
 
-	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
-					   rif_index, true);
+	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp, rif, true);
 	if (err)
 		goto err_port_vlan_rif_sp_op;
 
@@ -3083,8 +3080,7 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 	return rif;
 
 err_rif_fdb_op:
-	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
-				     rif_index, false);
+	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp, rif, false);
 err_port_vlan_rif_sp_op:
 	kfree(rif);
 err_rif_alloc:
@@ -3117,8 +3113,7 @@ mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
-	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
-				     rif_index, false);
+	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp, rif, false);
 	kfree(rif);
 	mlxsw_sp_vr_put(vr);
 	kfree(f);
@@ -3326,18 +3321,16 @@ static enum mlxsw_reg_ritr_if_type mlxsw_sp_rif_type_get(u16 fid)
 		return MLXSW_REG_RITR_VLAN_IF;
 }
 
-static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp, u16 vr_id,
-				  struct net_device *l3_dev,
-				  u16 fid, u16 rif,
-				  bool create)
+static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp,
+				  const struct mlxsw_sp_rif *rif, bool create)
 {
 	enum mlxsw_reg_ritr_if_type rif_type;
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 
-	rif_type = mlxsw_sp_rif_type_get(fid);
-	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif, vr_id, l3_dev->mtu,
-			    l3_dev->dev_addr);
-	mlxsw_reg_ritr_fid_set(ritr_pl, rif_type, fid);
+	rif_type = mlxsw_sp_rif_type_get(rif->f->fid);
+	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif->rif_index,
+			    rif->vr_id, rif->dev->mtu, rif->dev->dev_addr);
+	mlxsw_reg_ritr_fid_set(ritr_pl, rif_type, rif->f->fid);
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 }
@@ -3370,8 +3363,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 		goto err_rif_alloc;
 	}
 
-	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid,
-				     rif_index, true);
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, rif, true);
 	if (err)
 		goto err_rif_bridge_op;
 
@@ -3388,8 +3380,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 
 err_rif_fdb_op:
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
-			       false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, rif, false);
 err_rif_bridge_op:
 	kfree(rif);
 err_rif_alloc:
@@ -3415,8 +3406,7 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
-			       false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, rif, false);
 
 	kfree(rif);
 
-- 
2.9.3
