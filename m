From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] mlxsw: spectrum: Separate bc and mc floods
Date: Thu,  9 Feb 2017 14:54:46 +0100
Message-ID: <1486648489-16455-8-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37648 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752791AbdBIOY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:24:59 -0500
Received: by mail-wm0-f49.google.com with SMTP id v77so20703245wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:24:26 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Break the bm (broadcast-multicast) into two tables, one for broadcast
(and link local multicast that behaves like bc) and one for unknown
multicasts.
Add a bool into mlxsw_sp_port named mc_flood that reflect the value this
port should have in the mc flood table (currently, always 1);

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 23 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 +++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 21 ++++++++++++++------
 3 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8de5ed5..1d9a8c5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3073,10 +3073,17 @@ static int __mlxsw_sp_flood_init(struct mlxsw_core *mlxsw_core,
 	else
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
 
-	if (type == MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST)
+	switch (type) {
+	case MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST:
 		flood_table = MLXSW_SP_FLOOD_TABLE_UC;
-	else
-		flood_table = MLXSW_SP_FLOOD_TABLE_BM;
+		break;
+	case MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4:
+	case MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6:
+		flood_table = MLXSW_SP_FLOOD_TABLE_MC;
+		break;
+	default:
+		flood_table = MLXSW_SP_FLOOD_TABLE_BC;
+	}
 
 	mlxsw_reg_sfgc_pack(sfgc_pl, type, bridge_type, table_type,
 			    flood_table);
@@ -3270,9 +3277,9 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.used_flood_tables		= 1,
 	.used_flood_mode		= 1,
 	.flood_mode			= 3,
-	.max_fid_offset_flood_tables	= 2,
+	.max_fid_offset_flood_tables	= 3,
 	.fid_offset_flood_table_size	= VLAN_N_VID - 1,
-	.max_fid_flood_tables		= 2,
+	.max_fid_flood_tables		= 3,
 	.fid_flood_table_size		= MLXSW_SP_VFID_MAX,
 	.used_max_ib_mc			= 1,
 	.max_ib_mc			= 0,
@@ -3689,7 +3696,7 @@ static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
 
 	table_type = mlxsw_sp_flood_table_type_get(fid);
 	index = mlxsw_sp_flood_table_index_get(fid);
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, index, table_type,
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BC, index, table_type,
 			    1, MLXSW_PORT_ROUTER_PORT, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 
@@ -4065,6 +4072,7 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_port->learning = 1;
 	mlxsw_sp_port->learning_sync = 1;
 	mlxsw_sp_port->uc_flood = 1;
+	mlxsw_sp_port->mc_flood = 1;
 	mlxsw_sp_port->bridged = 1;
 
 	return 0;
@@ -4081,6 +4089,7 @@ static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_sp_port->learning = 0;
 	mlxsw_sp_port->learning_sync = 0;
 	mlxsw_sp_port->uc_flood = 0;
+	mlxsw_sp_port->mc_flood = 0;
 	mlxsw_sp_port->bridged = 0;
 
 	/* Add implicit VLAN interface in the device, so that untagged
@@ -4743,6 +4752,7 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_vport->learning = 1;
 	mlxsw_sp_vport->learning_sync = 1;
 	mlxsw_sp_vport->uc_flood = 1;
+	mlxsw_sp_vport->mc_flood = 1;
 	mlxsw_sp_vport->bridged = 1;
 
 	return 0;
@@ -4763,6 +4773,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
 	mlxsw_sp_vport->uc_flood = 0;
+	mlxsw_sp_vport->mc_flood = 0;
 	mlxsw_sp_vport->bridged = 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 49fe75f..7b8d1cf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -342,6 +342,7 @@ struct mlxsw_sp_port {
 	u8 learning:1,
 	   learning_sync:1,
 	   uc_flood:1,
+	   mc_flood:1,
 	   bridged:1,
 	   lagged:1,
 	   split:1;
@@ -509,7 +510,8 @@ mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 
 enum mlxsw_sp_flood_table {
 	MLXSW_SP_FLOOD_TABLE_UC,
-	MLXSW_SP_FLOOD_TABLE_BM,
+	MLXSW_SP_FLOOD_TABLE_BC,
+	MLXSW_SP_FLOOD_TABLE_MC,
 };
 
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index b1e2ec12..fe3cf568 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -197,7 +197,7 @@ static int __mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 idx_begin, u16 idx_end, bool uc_set,
-				     bool bm_set)
+				     bool bc_set, bool mc_set)
 {
 	int err;
 
@@ -207,12 +207,19 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		return err;
 
 	err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
-					      MLXSW_SP_FLOOD_TABLE_BM, bm_set);
+					      MLXSW_SP_FLOOD_TABLE_BC, bc_set);
 	if (err)
 		goto err_flood_bm_set;
 
+	err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
+					      MLXSW_SP_FLOOD_TABLE_MC, mc_set);
+	if (err)
+		goto err_flood_mc_set;
 	return 0;
 
+err_flood_mc_set:
+	__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
+					MLXSW_SP_FLOOD_TABLE_BC, !bc_set);
 err_flood_bm_set:
 	__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
 					MLXSW_SP_FLOOD_TABLE_UC, !uc_set);
@@ -263,7 +270,8 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 	 * the start of the vFIDs range.
 	 */
 	vfid = mlxsw_sp_fid_to_vfid(fid);
-	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set, set);
+	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set, set,
+					 set);
 }
 
 static int mlxsw_sp_port_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -568,7 +576,8 @@ static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end,
-					mlxsw_sp_port->uc_flood, true);
+					mlxsw_sp_port->uc_flood, true,
+					mlxsw_sp_port->mc_flood);
 	if (err)
 		goto err_port_flood_set;
 
@@ -584,7 +593,7 @@ static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	for (fid--; fid >= fid_begin; fid--)
 		mlxsw_sp_port_fid_map(mlxsw_sp_port, fid, false);
 	__mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end, false,
-				  false);
+				  false, false);
 err_port_flood_set:
 	fid = fid_end;
 err_port_fid_join:
@@ -602,7 +611,7 @@ static void mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 		mlxsw_sp_port_fid_map(mlxsw_sp_port, fid, false);
 
 	__mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end, false,
-				  false);
+				  false, false);
 
 	for (fid = fid_begin; fid <= fid_end; fid++)
 		__mlxsw_sp_port_fid_leave(mlxsw_sp_port, fid);
-- 
2.7.4
