From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/16] mlxsw: spectrum_switchdev: Break smid write function
Date: Wed, 20 Sep 2017 16:15:05 +0200
Message-ID: <20170920141516.1402-6-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37562 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdITOPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:24 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so2563870wmh.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:23 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Break the smid write function into two, one that cleans the ports that
might be still written there and one that changes an exiting mid entry.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 42 +++++++++++++++-------
 1 file changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 2ba8a44..09ead97 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1190,7 +1190,7 @@ mlxsw_sp_port_fdb_set(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_port_mdb_op(struct mlxsw_sp *mlxsw_sp, const char *addr,
-				u16 fid, u16 mid, bool adding)
+				u16 fid, u16 mid_idx, bool adding)
 {
 	char *sfd_pl;
 	int err;
@@ -1201,16 +1201,16 @@ static int mlxsw_sp_port_mdb_op(struct mlxsw_sp *mlxsw_sp, const char *addr,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_mc_pack(sfd_pl, 0, addr, fid,
-			      MLXSW_REG_SFD_REC_ACTION_NOP, mid);
+			      MLXSW_REG_SFD_REC_ACTION_NOP, mid_idx);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
 	return err;
 }
 
-static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
-				  bool add, bool clear_all_ports)
+/* clean the an entry from the HW and write there a full new entry */
+static int mlxsw_sp_port_smid_full_entry(struct mlxsw_sp *mlxsw_sp,
+					 u16 mid_idx)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *smid_pl;
 	int err, i;
 
@@ -1218,12 +1218,29 @@ static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
 	if (!smid_pl)
 		return -ENOMEM;
 
-	mlxsw_reg_smid_pack(smid_pl, mid, mlxsw_sp_port->local_port, add);
-	if (clear_all_ports) {
-		for (i = 1; i < mlxsw_core_max_ports(mlxsw_sp->core); i++)
-			if (mlxsw_sp->ports[i])
-				mlxsw_reg_smid_port_mask_set(smid_pl, i, 1);
+	mlxsw_reg_smid_pack(smid_pl, mid_idx, 0, false);
+	for (i = 1; i < mlxsw_core_max_ports(mlxsw_sp->core); i++) {
+		if (mlxsw_sp->ports[i])
+			mlxsw_reg_smid_port_mask_set(smid_pl, i, 1);
 	}
+
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(smid), smid_pl);
+	kfree(smid_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				  u16 mid_idx, bool add)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *smid_pl;
+	int err;
+
+	smid_pl = kmalloc(MLXSW_REG_SMID_LEN, GFP_KERNEL);
+	if (!smid_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_smid_pack(smid_pl, mid_idx, mlxsw_sp_port->local_port, add);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(smid), smid_pl);
 	kfree(smid_pl);
 	return err;
@@ -1336,10 +1353,11 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			return -ENOMEM;
 		}
 		is_new_mid = true;
+		mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid->mid);
 	}
 	set_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
 
-	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true, is_new_mid);
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true);
 	if (err) {
 		netdev_err(dev, "Unable to set SMID\n");
 		goto err_out;
@@ -1458,7 +1476,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -EINVAL;
 	}
 
-	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false, false);
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
 	if (err)
 		netdev_err(dev, "Unable to remove port from SMID\n");
 
-- 
2.9.5
