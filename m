From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 6/6] mlxsw: spectrum: Use existing flood setup when adding VLANs
Date: Thu,  1 Sep 2016 10:37:45 +0200
Message-ID: <1472719065-3247-7-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36292 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753129AbcIAIiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:38:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so11482123wmf.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:59 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a VLAN is added on a bridge port we should use the existing unicast
flood configuration of the port instead of assuming it's enabled.

Fixes: 0293038e0c36 ("mlxsw: spectrum: Add support for flood control")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 25 ++++++++--------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e0d95c4..7b654c51 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -167,8 +167,8 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 idx_begin, u16 idx_end, bool set,
-				     bool only_uc)
+				     u16 idx_begin, u16 idx_end, bool uc_set,
+				     bool bm_set)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 local_port = mlxsw_sp_port->local_port;
@@ -187,28 +187,22 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -ENOMEM;
 
 	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
-			    table_type, range, local_port, set);
+			    table_type, range, local_port, uc_set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 	if (err)
 		goto buffer_out;
 
-	/* Flooding control allows one to decide whether a given port will
-	 * flood unicast traffic for which there is no FDB entry.
-	 */
-	if (only_uc)
-		goto buffer_out;
-
 	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, idx_begin,
-			    table_type, range, local_port, set);
+			    table_type, range, local_port, bm_set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 	if (err)
 		goto err_flood_bm_set;
-	else
-		goto buffer_out;
+
+	goto buffer_out;
 
 err_flood_bm_set:
 	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
-			    table_type, range, local_port, !set);
+			    table_type, range, local_port, !uc_set);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 buffer_out:
 	kfree(sftr_pl);
@@ -257,8 +251,7 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 	 * the start of the vFIDs range.
 	 */
 	vfid = mlxsw_sp_fid_to_vfid(fid);
-	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set,
-					 false);
+	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set, set);
 }
 
 static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -520,7 +513,7 @@ static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end,
-					true, false);
+					mlxsw_sp_port->uc_flood, true);
 	if (err)
 		goto err_port_flood_set;
 
-- 
2.5.5
