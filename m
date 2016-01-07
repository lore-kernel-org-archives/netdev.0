From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum: remove FDB entry in case we get unknown object notification
Date: Thu,  7 Jan 2016 10:25:01 +0100
Message-ID: <1452158701-15747-2-git-send-email-jiri@resnulli.us>
References: <1452158701-15747-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36359 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcAGJZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:25:05 -0500
Received: by mail-wm0-f51.google.com with SMTP id l65so88967749wmf.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 01:25:04 -0800 (PST)
In-Reply-To: <1452158701-15747-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It may happen that we get notification for FDB entry for object (port,
lag, vport), which does not exist. Currently we ignore that, which only
causes this being re-sent in next notification. The entry will never
disappear. So get rid of it by simply removing it using SFD register.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 29 ++++++++++++++++++----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d22076b..b2873ef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1002,13 +1002,14 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 	char mac[ETH_ALEN];
 	u8 local_port;
 	u16 vid, fid;
+	bool do_notification = true;
 	int err;
 
 	mlxsw_reg_sfn_mac_unpack(sfn_pl, rec_index, mac, &fid, &local_port);
 	mlxsw_sp_port = mlxsw_sp->ports[local_port];
 	if (!mlxsw_sp_port) {
 		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect local port in FDB notification\n");
-		return;
+		goto just_remove;
 	}
 
 	if (mlxsw_sp_fid_is_vfid(fid)) {
@@ -1019,9 +1020,8 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 								  vfid);
 		if (!mlxsw_sp_vport) {
 			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
-			return;
+			goto just_remove;
 		}
-
 		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 		/* Override the physical port with the vPort. */
 		mlxsw_sp_port = mlxsw_sp_vport;
@@ -1029,6 +1029,7 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		vid = fid;
 	}
 
+do_fdb_op:
 	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid,
 				      adding && mlxsw_sp_port->learning, true);
 	if (err) {
@@ -1037,9 +1038,17 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		return;
 	}
 
+	if (!do_notification)
+		return;
 	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
 				    mlxsw_sp_port->learning_sync,
 				    adding, mac, vid, mlxsw_sp_port->dev);
+	return;
+
+just_remove:
+	adding = false;
+	do_notification = false;
+	goto do_fdb_op;
 }
 
 static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
@@ -1051,13 +1060,14 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 	u16 lag_vid = 0;
 	u16 lag_id;
 	u16 vid, fid;
+	bool do_notification = true;
 	int err;
 
 	mlxsw_reg_sfn_mac_lag_unpack(sfn_pl, rec_index, mac, &fid, &lag_id);
 	mlxsw_sp_port = mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id);
 	if (!mlxsw_sp_port) {
 		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Cannot find port representor for LAG\n");
-		return;
+		goto just_remove;
 	}
 
 	if (mlxsw_sp_fid_is_vfid(fid)) {
@@ -1068,7 +1078,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 								  vfid);
 		if (!mlxsw_sp_vport) {
 			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
-			return;
+			goto just_remove;
 		}
 
 		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
@@ -1079,6 +1089,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		vid = fid;
 	}
 
+do_fdb_op:
 	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid, lag_vid,
 					  adding && mlxsw_sp_port->learning,
 					  true);
@@ -1088,10 +1099,18 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		return;
 	}
 
+	if (!do_notification)
+		return;
 	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
 				    mlxsw_sp_port->learning_sync,
 				    adding, mac, vid,
 				    mlxsw_sp_lag_get(mlxsw_sp, lag_id)->dev);
+	return;
+
+just_remove:
+	adding = false;
+	do_notification = false;
+	goto do_fdb_op;
 }
 
 static void mlxsw_sp_fdb_notify_rec_process(struct mlxsw_sp *mlxsw_sp,
-- 
1.9.3
