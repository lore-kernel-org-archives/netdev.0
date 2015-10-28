From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/12] mlxsw: spectrum: Add support for flood control
Date: Wed, 28 Oct 2015 10:16:58 +0100
Message-ID: <1446023825-7162-6-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37774 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbJ1JR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:29 -0400
Received: by wicfv8 with SMTP id fv8so4711489wic.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:28 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Add or remove a bridged port from the flooding domain of unknown unicast
packets according to user configuration.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 113 ++++++++++++++-------
 3 files changed, 78 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e30b2da..3be4a23 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1227,6 +1227,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port->local_port = local_port;
 	mlxsw_sp_port->learning = 1;
 	mlxsw_sp_port->learning_sync = 1;
+	mlxsw_sp_port->uc_flood = 1;
 	mlxsw_sp_port->pvid = 1;
 
 	mlxsw_sp_port->pcpu_stats =
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b4d8393..4365c8b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -86,6 +86,7 @@ struct mlxsw_sp_port {
 	u8 stp_state;
 	u8 learning:1,
 	   learning_sync:1,
+	   uc_flood:1,
 	   bridged:1;
 	u16 pvid;
 	/* 802.1Q bridge VLANs */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index c3881c9..1f3b12e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -66,7 +66,8 @@ static int mlxsw_sp_port_attr_get(struct net_device *dev,
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
 		attr->u.brport_flags =
 			(mlxsw_sp_port->learning ? BR_LEARNING : 0) |
-			(mlxsw_sp_port->learning_sync ? BR_LEARNING_SYNC : 0);
+			(mlxsw_sp_port->learning_sync ? BR_LEARNING_SYNC : 0) |
+			(mlxsw_sp_port->uc_flood ? BR_FLOOD : 0);
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -123,15 +124,89 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
 }
 
+static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 fid_begin, u16 fid_end, bool set,
+				     bool only_uc)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u16 range = fid_end - fid_begin + 1;
+	char *sftr_pl;
+	int err;
+
+	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+	if (!sftr_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid_begin,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
+			    mlxsw_sp_port->local_port, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+	if (err)
+		goto buffer_out;
+
+	/* Flooding control allows one to decide whether a given port will
+	 * flood unicast traffic for which there is no FDB entry.
+	 */
+	if (only_uc)
+		goto buffer_out;
+
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid_begin,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
+			    mlxsw_sp_port->local_port, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+
+buffer_out:
+	kfree(sftr_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      bool set)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	u16 vid, last_visited_vid;
+	int err;
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, vid, set,
+						true);
+		if (err) {
+			last_visited_vid = vid;
+			goto err_port_flood_set;
+		}
+	}
+
+	return 0;
+
+err_port_flood_set:
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, last_visited_vid)
+		__mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, vid, !set, true);
+	netdev_err(dev, "Failed to configure unicast flooding\n");
+	return err;
+}
+
 static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					   struct switchdev_trans *trans,
 					   unsigned long brport_flags)
 {
+	unsigned long uc_flood = mlxsw_sp_port->uc_flood ? BR_FLOOD : 0;
+	bool set;
+	int err;
+
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
+	if ((uc_flood ^ brport_flags) & BR_FLOOD) {
+		set = mlxsw_sp_port->uc_flood ? false : true;
+		err = mlxsw_sp_port_uc_flood_set(mlxsw_sp_port, set);
+		if (err)
+			return err;
+	}
+
+	mlxsw_sp_port->uc_flood = brport_flags & BR_FLOOD ? 1 : 0;
 	mlxsw_sp_port->learning = brport_flags & BR_LEARNING ? 1 : 0;
 	mlxsw_sp_port->learning_sync = brport_flags & BR_LEARNING_SYNC ? 1 : 0;
+
 	return 0;
 }
 
@@ -247,42 +322,6 @@ static int mlxsw_sp_port_fid_unmap(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
 	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, false, fid, fid);
 }
 
-static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 fid_begin, u16 fid_end, bool set,
-				     bool only_uc)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	u16 range = fid_end - fid_begin + 1;
-	char *sftr_pl;
-	int err;
-
-	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
-	if (!sftr_pl)
-		return -ENOMEM;
-
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid_begin,
-			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
-			    mlxsw_sp_port->local_port, set);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
-	if (err)
-		goto buffer_out;
-
-	/* Flooding control allows one to decide whether a given port will
-	 * flood unicast traffic for which there is no FDB entry.
-	 */
-	if (only_uc)
-		goto buffer_out;
-
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid_begin,
-			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, range,
-			    mlxsw_sp_port->local_port, set);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
-
-buffer_out:
-	kfree(sftr_pl);
-	return err;
-}
-
 static int mlxsw_sp_port_add_vids(struct net_device *dev, u16 vid_begin,
 				  u16 vid_end)
 {
-- 
1.9.3
