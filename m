From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 27/28] mlxsw: spectrum: Implement FDB add/remove/dump for LAG
Date: Thu,  3 Dec 2015 12:12:29 +0100
Message-ID: <1449141150-8172-28-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33498 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758834AbbLCLNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:13:11 -0500
Received: by wmec201 with SMTP id c201so21520014wme.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:13:10 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement FDB offloading for lagged ports, including learning LAG FDB
entries, adding/removing static FDB entries and dumping existing LAG FDB
entries.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 182 +++++++++++++++++----
 1 file changed, 150 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index f21e239..406dab2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -490,32 +490,56 @@ static int mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 					 untagged_flag, pvid_flag);
 }
 
-static int mlxsw_sp_port_fdb_op(struct mlxsw_sp_port *mlxsw_sp_port,
-				const char *mac, u16 vid, bool adding,
-				bool dynamic)
+static enum mlxsw_reg_sfd_rec_policy mlxsw_sp_sfd_rec_policy(bool dynamic)
 {
-	enum mlxsw_reg_sfd_rec_policy policy;
-	enum mlxsw_reg_sfd_op op;
+	return dynamic ? MLXSW_REG_SFD_REC_POLICY_DYNAMIC_ENTRY_INGRESS :
+			 MLXSW_REG_SFD_REC_POLICY_STATIC_ENTRY;
+}
+
+static enum mlxsw_reg_sfd_op mlxsw_sp_sfd_op(bool adding)
+{
+	return adding ? MLXSW_REG_SFD_OP_WRITE_EDIT :
+			MLXSW_REG_SFD_OP_WRITE_REMOVE;
+}
+
+static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
+				   const char *mac, u16 vid, bool adding,
+				   bool dynamic)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *sfd_pl;
 	int err;
 
-	if (!vid)
-		vid = mlxsw_sp_port->pvid;
-
 	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
 	if (!sfd_pl)
 		return -ENOMEM;
 
-	policy = dynamic ? MLXSW_REG_SFD_REC_POLICY_DYNAMIC_ENTRY_INGRESS :
-			   MLXSW_REG_SFD_REC_POLICY_STATIC_ENTRY;
-	op = adding ? MLXSW_REG_SFD_OP_WRITE_EDIT :
-		      MLXSW_REG_SFD_OP_WRITE_REMOVE;
-	mlxsw_reg_sfd_pack(sfd_pl, op, 0);
-	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, policy,
+	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
+	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
 			      mac, vid, MLXSW_REG_SFD_REC_ACTION_NOP,
 			      mlxsw_sp_port->local_port);
-	err = mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(sfd),
-			      sfd_pl);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
+	kfree(sfd_pl);
+
+	return err;
+}
+
+static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
+				       const char *mac, u16 vid, bool adding,
+				       bool dynamic)
+{
+	char *sfd_pl;
+	int err;
+
+	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
+	if (!sfd_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
+	mlxsw_reg_sfd_uc_lag_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
+				  mac, vid, MLXSW_REG_SFD_REC_ACTION_NOP,
+				  lag_id);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
 
 	return err;
@@ -526,11 +550,21 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb,
 			     struct switchdev_trans *trans)
 {
+	u16 vid = fdb->vid;
+
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
-	return mlxsw_sp_port_fdb_op(mlxsw_sp_port, fdb->addr, fdb->vid,
-				    true, false);
+	if (!vid)
+		vid = mlxsw_sp_port->pvid;
+
+	if (!mlxsw_sp_port->lagged)
+		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
+					       fdb->addr, vid, true, false);
+	else
+		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
+						   mlxsw_sp_port->lag_id,
+						   fdb->addr, vid, true, false);
 }
 
 static int mlxsw_sp_port_obj_add(struct net_device *dev,
@@ -645,8 +679,15 @@ static int
 mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb)
 {
-	return mlxsw_sp_port_fdb_op(mlxsw_sp_port, fdb->addr, fdb->vid,
-				    false, false);
+	if (!mlxsw_sp_port->lagged)
+		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
+					       fdb->addr, fdb->vid,
+					       false, false);
+	else
+		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
+						   mlxsw_sp_port->lag_id,
+						   fdb->addr, fdb->vid,
+						   false, false);
 }
 
 static int mlxsw_sp_port_obj_del(struct net_device *dev,
@@ -672,14 +713,30 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 	return err;
 }
 
+static struct mlxsw_sp_port *mlxsw_sp_lag_rep_port(struct mlxsw_sp *mlxsw_sp,
+						   u16 lag_id)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_PER_LAG_MAX; i++) {
+		mlxsw_sp_port = mlxsw_sp_port_lagged_get(mlxsw_sp, lag_id, i);
+		if (mlxsw_sp_port)
+			return mlxsw_sp_port;
+	}
+	return NULL;
+}
+
 static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				  struct switchdev_obj_port_fdb *fdb,
 				  switchdev_obj_dump_cb_t *cb)
 {
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
 	u16 vid;
 	u8 local_port;
+	u16 lag_id;
 	u8 num_rec;
 	int stored_err = 0;
 	int i;
@@ -692,8 +749,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
 		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
-		err = mlxsw_reg_query(mlxsw_sp_port->mlxsw_sp->core,
-				      MLXSW_REG(sfd), sfd_pl);
+		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 		if (err)
 			goto out;
 
@@ -718,6 +774,20 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 					if (err)
 						stored_err = err;
 				}
+				break;
+			case MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG:
+				mlxsw_reg_sfd_uc_lag_unpack(sfd_pl, i,
+							    mac, &vid, &lag_id);
+				if (mlxsw_sp_port ==
+				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
+					ether_addr_copy(fdb->addr, mac);
+					fdb->ndm_state = NUD_REACHABLE;
+					fdb->vid = vid;
+					err = cb(&fdb->obj);
+					if (err)
+						stored_err = err;
+				}
+				break;
 			}
 		}
 	} while (num_rec == MLXSW_REG_SFD_REC_MAX_COUNT);
@@ -779,6 +849,21 @@ static const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
 	.switchdev_port_obj_dump	= mlxsw_sp_port_obj_dump,
 };
 
+static void mlxsw_sp_fdb_call_notifiers(bool learning, bool learning_sync,
+					bool adding, char *mac, u16 vid,
+					struct net_device *dev)
+{
+	struct switchdev_notifier_fdb_info info;
+	unsigned long notifier_type;
+
+	if (learning && learning_sync) {
+		info.addr = mac;
+		info.vid = vid;
+		notifier_type = adding ? SWITCHDEV_FDB_ADD : SWITCHDEV_FDB_DEL;
+		call_switchdev_notifiers(notifier_type, dev, &info.info);
+	}
+}
+
 static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 					    char *sfn_pl, int rec_index,
 					    bool adding)
@@ -796,24 +881,49 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		return;
 	}
 
-	err = mlxsw_sp_port_fdb_op(mlxsw_sp_port, mac, vid,
-				   adding && mlxsw_sp_port->learning, true);
+	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port, mac, vid,
+				      adding && mlxsw_sp_port->learning, true);
 	if (err) {
 		if (net_ratelimit())
 			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
 		return;
 	}
 
-	if (mlxsw_sp_port->learning && mlxsw_sp_port->learning_sync) {
-		struct switchdev_notifier_fdb_info info;
-		unsigned long notifier_type;
+	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
+				    mlxsw_sp_port->learning_sync,
+				    adding, mac, vid, mlxsw_sp_port->dev);
+}
 
-		info.addr = mac;
-		info.vid = vid;
-		notifier_type = adding ? SWITCHDEV_FDB_ADD : SWITCHDEV_FDB_DEL;
-		call_switchdev_notifiers(notifier_type, mlxsw_sp_port->dev,
-					 &info.info);
+static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
+						char *sfn_pl, int rec_index,
+						bool adding)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	char mac[ETH_ALEN];
+	u16 lag_id;
+	u16 vid;
+	int err;
+
+	mlxsw_reg_sfn_mac_lag_unpack(sfn_pl, rec_index, mac, &vid, &lag_id);
+	mlxsw_sp_port = mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id);
+	if (!mlxsw_sp_port) {
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Cannot find port representor for LAG\n");
+		return;
 	}
+
+	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, vid,
+					  adding && mlxsw_sp_port->learning,
+					  true);
+	if (err) {
+		if (net_ratelimit())
+			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
+		return;
+	}
+
+	mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning,
+				    mlxsw_sp_port->learning_sync,
+				    adding, mac, vid,
+				    mlxsw_sp_lag_get(mlxsw_sp, lag_id)->dev);
 }
 
 static void mlxsw_sp_fdb_notify_rec_process(struct mlxsw_sp *mlxsw_sp,
@@ -828,6 +938,14 @@ static void mlxsw_sp_fdb_notify_rec_process(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_fdb_notify_mac_process(mlxsw_sp, sfn_pl,
 						rec_index, false);
 		break;
+	case MLXSW_REG_SFN_REC_TYPE_LEARNED_MAC_LAG:
+		mlxsw_sp_fdb_notify_mac_lag_process(mlxsw_sp, sfn_pl,
+						    rec_index, true);
+		break;
+	case MLXSW_REG_SFN_REC_TYPE_AGED_OUT_MAC_LAG:
+		mlxsw_sp_fdb_notify_mac_lag_process(mlxsw_sp, sfn_pl,
+						    rec_index, false);
+		break;
 	}
 }
 
-- 
1.9.3
