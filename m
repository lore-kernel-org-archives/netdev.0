From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/10] mlxsw: spectrum: Break flood set func to be per table
Date: Thu,  9 Feb 2017 14:54:43 +0100
Message-ID: <1486648489-16455-5-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35886 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdBIPBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 10:01:15 -0500
Received: by mail-wr0-f196.google.com with SMTP id k90so12165760wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 07:01:15 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Currently, the flood set function can't operate on only one table, but
sets both uc_flood and mb_flood together.
This patch creates a function that sets the flood state per table.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 54 ++++++++++++++--------
 1 file changed, 34 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index b87ba7d3..2bd5ffe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -166,9 +166,10 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
 }
 
-static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 idx_begin, u16 idx_end, bool uc_set,
-				     bool bm_set)
+static int __mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					   u16 idx_begin, u16 idx_end,
+					   enum mlxsw_sp_flood_table table,
+					   bool set)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 local_port = mlxsw_sp_port->local_port;
@@ -186,26 +187,35 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sftr_pl)
 		return -ENOMEM;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
-			    table_type, range, local_port, uc_set);
+	mlxsw_reg_sftr_pack(sftr_pl, table, idx_begin,
+			    table_type, range, local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+
+	kfree(sftr_pl);
+	return err;
+}
+
+static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 idx_begin, u16 idx_end, bool uc_set,
+				     bool bm_set)
+{
+	int err;
+
+	err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
+					      MLXSW_SP_FLOOD_TABLE_UC, uc_set);
 	if (err)
-		goto buffer_out;
+		return err;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, idx_begin,
-			    table_type, range, local_port, bm_set);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+	err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
+					      MLXSW_SP_FLOOD_TABLE_BM, bm_set);
 	if (err)
 		goto err_flood_bm_set;
 
-	goto buffer_out;
+	return 0;
 
 err_flood_bm_set:
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
-			    table_type, range, local_port, !uc_set);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
-buffer_out:
-	kfree(sftr_pl);
+	__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, idx_begin, idx_end,
+					MLXSW_SP_FLOOD_TABLE_UC, !uc_set);
 	return err;
 }
 
@@ -220,13 +230,16 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
 		u16 vfid = mlxsw_sp_fid_to_vfid(fid);
 
-		return  __mlxsw_sp_port_flood_set(mlxsw_sp_port, vfid, vfid,
-						  set, true);
+		return __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vfid,
+						       vfid,
+						       MLXSW_SP_FLOOD_TABLE_UC,
+						       set);
 	}
 
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
-		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, vid, set,
-						true);
+		err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vid, vid,
+						      MLXSW_SP_FLOOD_TABLE_UC,
+						      set);
 		if (err) {
 			last_visited_vid = vid;
 			goto err_port_flood_set;
@@ -237,7 +250,8 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 err_port_flood_set:
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, last_visited_vid)
-		__mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, vid, !set, true);
+		__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vid, vid,
+						MLXSW_SP_FLOOD_TABLE_UC, !set);
 	netdev_err(dev, "Failed to configure unicast flooding\n");
 	return err;
 }
-- 
2.7.4
