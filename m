From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] mlxsw: spectrum: Offload learning to the switch ASIC
Date: Wed, 24 Aug 2016 12:00:27 +0200
Message-ID: <1472032829-6322-6-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35065 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932449AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so1860661wmg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:38 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we simply stored the learning configuration of a bridge
port in the driver and decided whether to learn a new FDB record based
on this value.

However, this is sub-optimal in cases where learning is disabled on the
bridge port, as the device repeatedly generates learning notifications
for the same record.

Instead, offload the learning configuration to the device, thereby
preventing it from generating notifications when learning is disabled.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 47 ++++++++++++++++++++--
 1 file changed, 44 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d1b2b11..e0a7232 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -261,12 +261,40 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 					 false);
 }
 
+static int mlxsw_sp_port_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      bool set)
+{
+	u16 vid;
+	int err;
+
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+
+		return __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
+							set);
+	}
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		err = __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
+						       set);
+		if (err)
+			goto err_port_vid_learning_set;
+	}
+
+	return 0;
+
+err_port_vid_learning_set:
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
+		__mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid, !set);
+	return err;
+}
+
 static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					   struct switchdev_trans *trans,
 					   unsigned long brport_flags)
 {
+	unsigned long learning = mlxsw_sp_port->learning ? BR_LEARNING : 0;
 	unsigned long uc_flood = mlxsw_sp_port->uc_flood ? BR_FLOOD : 0;
-	bool set;
 	int err;
 
 	if (!mlxsw_sp_port->bridged)
@@ -276,17 +304,30 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		return 0;
 
 	if ((uc_flood ^ brport_flags) & BR_FLOOD) {
-		set = mlxsw_sp_port->uc_flood ? false : true;
-		err = mlxsw_sp_port_uc_flood_set(mlxsw_sp_port, set);
+		err = mlxsw_sp_port_uc_flood_set(mlxsw_sp_port,
+						 !mlxsw_sp_port->uc_flood);
 		if (err)
 			return err;
 	}
 
+	if ((learning ^ brport_flags) & BR_LEARNING) {
+		err = mlxsw_sp_port_learning_set(mlxsw_sp_port,
+						 !mlxsw_sp_port->learning);
+		if (err)
+			goto err_port_learning_set;
+	}
+
 	mlxsw_sp_port->uc_flood = brport_flags & BR_FLOOD ? 1 : 0;
 	mlxsw_sp_port->learning = brport_flags & BR_LEARNING ? 1 : 0;
 	mlxsw_sp_port->learning_sync = brport_flags & BR_LEARNING_SYNC ? 1 : 0;
 
 	return 0;
+
+err_port_learning_set:
+	if ((uc_flood ^ brport_flags) & BR_FLOOD)
+		mlxsw_sp_port_uc_flood_set(mlxsw_sp_port,
+					   mlxsw_sp_port->uc_flood);
+	return err;
 }
 
 static int mlxsw_sp_ageing_set(struct mlxsw_sp *mlxsw_sp, u32 ageing_time)
-- 
2.5.5
