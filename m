From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/2] mlxsw: spectrum: pass local_port to mlxsw_sp_port_fdb_uc_op
Date: Thu,  7 Jan 2016 11:50:29 +0100
Message-ID: <1452163830-20425-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36677 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbcAGKud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:50:33 -0500
Received: by mail-wm0-f42.google.com with SMTP id l65so91779002wmf.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 02:50:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do not pass struct mlxsw_sp_port to mlxsw_sp_port_fdb_uc_op and rather
just pass local_port. This is needed in case this is called from SFN
process function and mlxsw_sp_port is not existent for particular
local_port.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
v1->v2:
- no change
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 614ef57..5150e9e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -594,11 +594,10 @@ static enum mlxsw_reg_sfd_op mlxsw_sp_sfd_op(bool adding)
 			MLXSW_REG_SFD_OP_WRITE_REMOVE;
 }
 
-static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
+static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				   const char *mac, u16 fid, bool adding,
 				   bool dynamic)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *sfd_pl;
 	int err;
 
@@ -609,7 +608,7 @@ static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
 			      mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
-			      mlxsw_sp_port->local_port);
+			      local_port);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
 
@@ -659,7 +658,8 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		fid = mlxsw_sp_port->pvid;
 
 	if (!mlxsw_sp_port->lagged)
-		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
+		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port->mlxsw_sp,
+					       mlxsw_sp_port->local_port,
 					       fdb->addr, fid, true, false);
 	else
 		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
@@ -798,7 +798,8 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	if (!mlxsw_sp_port->lagged)
-		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
+		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port->mlxsw_sp,
+					       mlxsw_sp_port->local_port,
 					       fdb->addr, fid,
 					       false, false);
 	else
@@ -1056,7 +1057,7 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		vid = fid;
 	}
 
-	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port, mac, fid,
+	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid,
 				      adding && mlxsw_sp_port->learning, true);
 	if (err) {
 		if (net_ratelimit())
-- 
1.9.3
