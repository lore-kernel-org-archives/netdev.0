From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/10] mlxsw: spectrum: Add an option to flood mc by mc_router_port
Date: Thu,  9 Feb 2017 14:54:47 +0100
Message-ID: <1486648489-16455-9-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32782 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbdBIO0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:26:38 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so3129577wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:26:38 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

The decision whether to flood a multicast packet to a port dependent
on three flags: mc_disabled, mc_router_port, mc_flood.

If mc_disabled is on, the port will be flooded according to mc_flood,
otherwise, according to mc_router_port. To accomplish that, add those
flags into the mlxsw_sp_port struct and update the mc flood table
accordingly.

Update mc_router_port by switchdev attribute
SWITCHDEV_ATTR_ID_PORT_MC_ROUTER_PORT.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 34 ++++++++++++++++++++--
 3 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1d9a8c5..37c018b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4073,6 +4073,8 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_port->learning_sync = 1;
 	mlxsw_sp_port->uc_flood = 1;
 	mlxsw_sp_port->mc_flood = 1;
+	mlxsw_sp_port->mc_router = 0;
+	mlxsw_sp_port->mc_disabled = 1;
 	mlxsw_sp_port->bridged = 1;
 
 	return 0;
@@ -4090,6 +4092,7 @@ static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_sp_port->learning_sync = 0;
 	mlxsw_sp_port->uc_flood = 0;
 	mlxsw_sp_port->mc_flood = 0;
+	mlxsw_sp_port->mc_router = 0;
 	mlxsw_sp_port->bridged = 0;
 
 	/* Add implicit VLAN interface in the device, so that untagged
@@ -4753,6 +4756,8 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_vport->learning_sync = 1;
 	mlxsw_sp_vport->uc_flood = 1;
 	mlxsw_sp_vport->mc_flood = 1;
+	mlxsw_sp_vport->mc_router = 0;
+	mlxsw_sp_vport->mc_disabled = 1;
 	mlxsw_sp_vport->bridged = 1;
 
 	return 0;
@@ -4774,6 +4779,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 	mlxsw_sp_vport->learning_sync = 0;
 	mlxsw_sp_vport->uc_flood = 0;
 	mlxsw_sp_vport->mc_flood = 0;
+	mlxsw_sp_vport->mc_router = 0;
 	mlxsw_sp_vport->bridged = 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7b8d1cf..13ec85e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -339,10 +339,12 @@ struct mlxsw_sp_port {
 	struct mlxsw_sp *mlxsw_sp;
 	u8 local_port;
 	u8 stp_state;
-	u8 learning:1,
+	u16 learning:1,
 	   learning_sync:1,
 	   uc_flood:1,
 	   mc_flood:1,
+	   mc_router:1,
+	   mc_disabled:1,
 	   bridged:1,
 	   lagged:1,
 	   split:1;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index fe3cf568..5370246 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -264,14 +264,20 @@ static int mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set)
 {
+	bool mc_set = set;
 	u16 vfid;
 
 	/* In case of vFIDs, index into the flooding table is relative to
 	 * the start of the vFIDs range.
 	 */
 	vfid = mlxsw_sp_fid_to_vfid(fid);
+
+	if (set)
+		mc_set = mlxsw_sp_vport->mc_disabled ?
+			 mlxsw_sp_vport->mc_flood : mlxsw_sp_vport->mc_router;
+
 	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set, set,
-					 set);
+					 mc_set);
 }
 
 static int mlxsw_sp_port_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -393,6 +399,22 @@ static int mlxsw_sp_port_attr_br_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					    struct switchdev_trans *trans,
+					    bool is_port_mc_router)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	mlxsw_sp_port->mc_router = is_port_mc_router;
+	if (!mlxsw_sp_port->mc_disabled)
+		return mlxsw_sp_port_flood_table_set(mlxsw_sp_port,
+						     MLXSW_SP_FLOOD_TABLE_MC,
+						     is_port_mc_router);
+
+	return 0;
+}
+
 static int mlxsw_sp_port_attr_set(struct net_device *dev,
 				  const struct switchdev_attr *attr,
 				  struct switchdev_trans *trans)
@@ -422,6 +444,10 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 						     attr->orig_dev,
 						     attr->u.vlan_filtering);
 		break;
+	case SWITCHDEV_ATTR_ID_PORT_MROUTER:
+		err = mlxsw_sp_port_attr_mc_router_set(mlxsw_sp_port, trans,
+						       attr->u.mrouter);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -567,6 +593,7 @@ static int mlxsw_sp_port_fid_map(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid,
 static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 				  u16 fid_begin, u16 fid_end)
 {
+	bool mc_flood;
 	int fid, err;
 
 	for (fid = fid_begin; fid <= fid_end; fid++) {
@@ -575,9 +602,12 @@ static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 			goto err_port_fid_join;
 	}
 
+	mc_flood = mlxsw_sp_port->mc_disabled ?
+			mlxsw_sp_port->mc_flood : mlxsw_sp_port->mc_router;
+
 	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end,
 					mlxsw_sp_port->uc_flood, true,
-					mlxsw_sp_port->mc_flood);
+					mc_flood);
 	if (err)
 		goto err_port_flood_set;
 
-- 
2.7.4
