From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/14] mlxsw: spectrum: Use FID instead of VID when accessing FDB
Date: Tue, 15 Dec 2015 16:03:40 +0100
Message-ID: <1450191827-6679-8-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34421 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933578AbbLOPEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:01 -0500
Received: by mail-wm0-f45.google.com with SMTP id p66so114407914wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:00 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In the Spectrum ASIC - unlike SwitchX-2 - FDB access is done by
specifying FID as parameter and not VID.

Change the relevant variables and parameters names to reflect that.

Note that this was OK up until now, since FID was always equal to VID,
but with the introduction of VLAN interfaces this is no longer the case.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 12 +++---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 50 ++++++++++++----------
 2 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index af631df..be529e4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -396,7 +396,7 @@ static inline void mlxsw_reg_sfd_rec_pack(char *payload, int rec_index,
 
 static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
 					 enum mlxsw_reg_sfd_rec_policy policy,
-					 const char *mac, u16 vid,
+					 const char *mac, u16 fid_vid,
 					 enum mlxsw_reg_sfd_rec_action action,
 					 u8 local_port)
 {
@@ -404,16 +404,16 @@ static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
 			       MLXSW_REG_SFD_REC_TYPE_UNICAST,
 			       policy, mac, action);
 	mlxsw_reg_sfd_uc_sub_port_set(payload, rec_index, 0);
-	mlxsw_reg_sfd_uc_fid_vid_set(payload, rec_index, vid);
+	mlxsw_reg_sfd_uc_fid_vid_set(payload, rec_index, fid_vid);
 	mlxsw_reg_sfd_uc_system_port_set(payload, rec_index, local_port);
 }
 
 static inline void mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
-					   char *mac, u16 *p_vid,
+					   char *mac, u16 *p_fid_vid,
 					   u8 *p_local_port)
 {
 	mlxsw_reg_sfd_rec_mac_memcpy_from(payload, rec_index, mac);
-	*p_vid = mlxsw_reg_sfd_uc_fid_vid_get(payload, rec_index);
+	*p_fid_vid = mlxsw_reg_sfd_uc_fid_vid_get(payload, rec_index);
 	*p_local_port = mlxsw_reg_sfd_uc_system_port_get(payload, rec_index);
 }
 
@@ -448,7 +448,7 @@ MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_lag_id, MLXSW_REG_SFD_BASE_LEN, 0, 10,
 static inline void
 mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
 			  enum mlxsw_reg_sfd_rec_policy policy,
-			  const char *mac, u16 vid,
+			  const char *mac, u16 fid_vid,
 			  enum mlxsw_reg_sfd_rec_action action,
 			  u16 lag_id)
 {
@@ -456,7 +456,7 @@ mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
 			       MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG,
 			       policy, mac, action);
 	mlxsw_reg_sfd_uc_lag_sub_port_set(payload, rec_index, 0);
-	mlxsw_reg_sfd_uc_lag_fid_vid_set(payload, rec_index, vid);
+	mlxsw_reg_sfd_uc_lag_fid_vid_set(payload, rec_index, fid_vid);
 	mlxsw_reg_sfd_uc_lag_lag_id_set(payload, rec_index, lag_id);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index af9c73b..97714e7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -520,7 +520,7 @@ static enum mlxsw_reg_sfd_op mlxsw_sp_sfd_op(bool adding)
 }
 
 static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
-				   const char *mac, u16 vid, bool adding,
+				   const char *mac, u16 fid, bool adding,
 				   bool dynamic)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
@@ -533,7 +533,7 @@ static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
-			      mac, vid, MLXSW_REG_SFD_REC_ACTION_NOP,
+			      mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
 			      mlxsw_sp_port->local_port);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
@@ -542,7 +542,7 @@ static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
-				       const char *mac, u16 vid, bool adding,
+				       const char *mac, u16 fid, bool adding,
 				       bool dynamic)
 {
 	char *sfd_pl;
@@ -554,7 +554,7 @@ static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_lag_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
-				  mac, vid, MLXSW_REG_SFD_REC_ACTION_NOP,
+				  mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
 				  lag_id);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
@@ -567,21 +567,21 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb,
 			     struct switchdev_trans *trans)
 {
-	u16 vid = fdb->vid;
+	u16 fid = fdb->vid;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
-	if (!vid)
-		vid = mlxsw_sp_port->pvid;
+	if (!fid)
+		fid = mlxsw_sp_port->pvid;
 
 	if (!mlxsw_sp_port->lagged)
 		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
-					       fdb->addr, vid, true, false);
+					       fdb->addr, fid, true, false);
 	else
 		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
 						   mlxsw_sp_port->lag_id,
-						   fdb->addr, vid, true, false);
+						   fdb->addr, fid, true, false);
 }
 
 static int mlxsw_sp_port_obj_add(struct net_device *dev,
@@ -696,14 +696,16 @@ static int
 mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb)
 {
+	u16 fid = fdb->vid;
+
 	if (!mlxsw_sp_port->lagged)
 		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
-					       fdb->addr, fdb->vid,
+					       fdb->addr, fid,
 					       false, false);
 	else
 		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
 						   mlxsw_sp_port->lag_id,
-						   fdb->addr, fdb->vid,
+						   fdb->addr, fid,
 						   false, false);
 }
 
@@ -751,7 +753,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
-	u16 vid;
+	u16 fid;
 	u8 local_port;
 	u16 lag_id;
 	u8 num_rec;
@@ -781,12 +783,12 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 		for (i = 0; i < num_rec; i++) {
 			switch (mlxsw_reg_sfd_rec_type_get(sfd_pl, i)) {
 			case MLXSW_REG_SFD_REC_TYPE_UNICAST:
-				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac, &vid,
+				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac, &fid,
 							&local_port);
 				if (local_port == mlxsw_sp_port->local_port) {
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
-					fdb->vid = vid;
+					fdb->vid = fid;
 					err = cb(&fdb->obj);
 					if (err)
 						stored_err = err;
@@ -794,12 +796,12 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				break;
 			case MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG:
 				mlxsw_reg_sfd_uc_lag_unpack(sfd_pl, i,
-							    mac, &vid, &lag_id);
+							    mac, &fid, &lag_id);
 				if (mlxsw_sp_port ==
 				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
-					fdb->vid = vid;
+					fdb->vid = fid;
 					err = cb(&fdb->obj);
 					if (err)
 						stored_err = err;
@@ -888,17 +890,17 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	char mac[ETH_ALEN];
 	u8 local_port;
-	u16 vid;
+	u16 vid, fid;
 	int err;
 
-	mlxsw_reg_sfn_mac_unpack(sfn_pl, rec_index, mac, &vid, &local_port);
+	mlxsw_reg_sfn_mac_unpack(sfn_pl, rec_index, mac, &fid, &local_port);
 	mlxsw_sp_port = mlxsw_sp->ports[local_port];
 	if (!mlxsw_sp_port) {
 		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect local port in FDB notification\n");
 		return;
 	}
 
-	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port, mac, vid,
+	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port, mac, fid,
 				      adding && mlxsw_sp_port->learning, true);
 	if (err) {
 		if (net_ratelimit())
@@ -906,6 +908,8 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		return;
 	}
 
+	vid = fid;
+
 	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
 				    mlxsw_sp_port->learning_sync,
 				    adding, mac, vid, mlxsw_sp_port->dev);
@@ -918,17 +922,17 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	char mac[ETH_ALEN];
 	u16 lag_id;
-	u16 vid;
+	u16 vid, fid;
 	int err;
 
-	mlxsw_reg_sfn_mac_lag_unpack(sfn_pl, rec_index, mac, &vid, &lag_id);
+	mlxsw_reg_sfn_mac_lag_unpack(sfn_pl, rec_index, mac, &fid, &lag_id);
 	mlxsw_sp_port = mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id);
 	if (!mlxsw_sp_port) {
 		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Cannot find port representor for LAG\n");
 		return;
 	}
 
-	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, vid,
+	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid,
 					  adding && mlxsw_sp_port->learning,
 					  true);
 	if (err) {
@@ -937,6 +941,8 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		return;
 	}
 
+	vid = fid;
+
 	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
 				    mlxsw_sp_port->learning_sync,
 				    adding, mac, vid,
-- 
1.9.3
