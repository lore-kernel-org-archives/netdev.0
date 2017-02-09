From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/10] mlxsw: spectrum: Make port flood update more generic
Date: Thu,  9 Feb 2017 14:54:44 +0100
Message-ID: <1486648489-16455-6-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36433 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752353AbdBIN4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:56:55 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so2993416wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:54:57 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Currently, there is a per port flood update function only for the UC
table. Make the function  more generic by changing the table type to be
an input.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 26 +++++++++++-----------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 2bd5ffe..b1e2ec12 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -219,8 +219,9 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return err;
 }
 
-static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				      bool set)
+static int mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					 enum mlxsw_sp_flood_table table,
+					 bool set)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 	u16 vid, last_visited_vid;
@@ -231,15 +232,12 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		u16 vfid = mlxsw_sp_fid_to_vfid(fid);
 
 		return __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vfid,
-						       vfid,
-						       MLXSW_SP_FLOOD_TABLE_UC,
-						       set);
+						       vfid, table, set);
 	}
 
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
 		err = __mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vid, vid,
-						      MLXSW_SP_FLOOD_TABLE_UC,
-						      set);
+						      table, set);
 		if (err) {
 			last_visited_vid = vid;
 			goto err_port_flood_set;
@@ -250,8 +248,8 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 err_port_flood_set:
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, last_visited_vid)
-		__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vid, vid,
-						MLXSW_SP_FLOOD_TABLE_UC, !set);
+		__mlxsw_sp_port_flood_table_set(mlxsw_sp_port, vid, vid, table,
+						!set);
 	netdev_err(dev, "Failed to configure unicast flooding\n");
 	return err;
 }
@@ -311,8 +309,9 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		return 0;
 
 	if ((uc_flood ^ brport_flags) & BR_FLOOD) {
-		err = mlxsw_sp_port_uc_flood_set(mlxsw_sp_port,
-						 !mlxsw_sp_port->uc_flood);
+		err = mlxsw_sp_port_flood_table_set(mlxsw_sp_port,
+						    MLXSW_SP_FLOOD_TABLE_UC,
+						    !mlxsw_sp_port->uc_flood);
 		if (err)
 			return err;
 	}
@@ -332,8 +331,9 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 err_port_learning_set:
 	if ((uc_flood ^ brport_flags) & BR_FLOOD)
-		mlxsw_sp_port_uc_flood_set(mlxsw_sp_port,
-					   mlxsw_sp_port->uc_flood);
+		mlxsw_sp_port_flood_table_set(mlxsw_sp_port,
+					      MLXSW_SP_FLOOD_TABLE_UC,
+					      mlxsw_sp_port->uc_flood);
 	return err;
 }
 
-- 
2.7.4
