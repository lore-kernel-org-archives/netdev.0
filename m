From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/14] mlxsw: spectrum: Adjust switchdev ops for VLAN devices
Date: Tue, 15 Dec 2015 16:03:41 +0100
Message-ID: <1450191827-6679-9-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33533 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933457AbbLOPED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:03 -0500
Received: by mail-wm0-f47.google.com with SMTP id n186so98872339wmn.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:02 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

switchdev ops can now be called for VLAN devices and we need to be
prepared for it. Until now they were only called for the port netdev.

Use the newly propagated orig_dev passed as part of the switchdev
attr/obj and determine whether the original device is a VLAN device. If
so, act accordingly, otherwise continue as usual.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 100 ++++++++++++++++++++-
 2 files changed, 98 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index ec8caf8..ce26adc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -41,7 +41,7 @@ config MLXSW_SWITCHX2
 
 config MLXSW_SPECTRUM
 	tristate "Mellanox Technologies Spectrum support"
-	depends on MLXSW_CORE && NET_SWITCHDEV
+	depends on MLXSW_CORE && NET_SWITCHDEV && VLAN_8021Q
 	default m
 	---help---
 	  This driver supports Mellanox Technologies Spectrum Ethernet
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 97714e7..49d5318 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -51,12 +51,33 @@
 #include "core.h"
 #include "reg.h"
 
+static struct mlxsw_sp_port *
+mlxsw_sp_port_orig_get(struct net_device *dev,
+		       struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	u16 vid;
+
+	if (!is_vlan_dev(dev))
+		return mlxsw_sp_port;
+
+	vid = vlan_dev_vlan_id(dev);
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	WARN_ON(!mlxsw_sp_vport);
+
+	return mlxsw_sp_vport;
+}
+
 static int mlxsw_sp_port_attr_get(struct net_device *dev,
 				  struct switchdev_attr *attr)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 
+	mlxsw_sp_port = mlxsw_sp_port_orig_get(attr->orig_dev, mlxsw_sp_port);
+	if (!mlxsw_sp_port)
+		return -EINVAL;
+
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
 		attr->u.ppid.id_len = sizeof(mlxsw_sp->base_mac);
@@ -105,8 +126,14 @@ static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!spms_pl)
 		return -ENOMEM;
 	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
-	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
+
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 		mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
+	} else {
+		for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
+			mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
+	}
 
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
 	kfree(spms_pl);
@@ -174,6 +201,13 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid, last_visited_vid;
 	int err;
 
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+
+		return  __mlxsw_sp_port_flood_set(mlxsw_sp_port, vfid, vfid,
+						  set, true);
+	}
+
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
 		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, vid, set,
 						true);
@@ -261,6 +295,10 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err = 0;
 
+	mlxsw_sp_port = mlxsw_sp_port_orig_get(attr->orig_dev, mlxsw_sp_port);
+	if (!mlxsw_sp_port)
+		return -EINVAL;
+
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
 		err = mlxsw_sp_port_attr_stp_state_set(mlxsw_sp_port, trans,
@@ -572,6 +610,12 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+
+		fid = mlxsw_sp_vfid_to_fid(vfid);
+	}
+
 	if (!fid)
 		fid = mlxsw_sp_port->pvid;
 
@@ -591,8 +635,15 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err = 0;
 
+	mlxsw_sp_port = mlxsw_sp_port_orig_get(obj->orig_dev, mlxsw_sp_port);
+	if (!mlxsw_sp_port)
+		return -EINVAL;
+
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
+			return 0;
+
 		err = mlxsw_sp_port_vlans_add(mlxsw_sp_port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
@@ -698,6 +749,12 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	u16 fid = fdb->vid;
 
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+
+		fid = mlxsw_sp_vfid_to_fid(vfid);
+	}
+
 	if (!mlxsw_sp_port->lagged)
 		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp_port,
 					       fdb->addr, fid,
@@ -715,8 +772,15 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err = 0;
 
+	mlxsw_sp_port = mlxsw_sp_port_orig_get(obj->orig_dev, mlxsw_sp_port);
+	if (!mlxsw_sp_port)
+		return -EINVAL;
+
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
+			return 0;
+
 		err = mlxsw_sp_port_vlans_del(mlxsw_sp_port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
@@ -751,6 +815,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				  switchdev_obj_dump_cb_t *cb)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u16 vport_vid = 0, vport_fid = 0;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
 	u16 fid;
@@ -765,6 +830,14 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sfd_pl)
 		return -ENOMEM;
 
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		u16 tmp;
+
+		tmp = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+		vport_fid = mlxsw_sp_vfid_to_fid(tmp);
+		vport_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+	}
+
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
 		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
@@ -786,9 +859,14 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac, &fid,
 							&local_port);
 				if (local_port == mlxsw_sp_port->local_port) {
+					if (vport_fid && vport_fid != fid)
+						continue;
+					else if (vport_fid)
+						fdb->vid = vport_vid;
+					else
+						fdb->vid = fid;
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
-					fdb->vid = fid;
 					err = cb(&fdb->obj);
 					if (err)
 						stored_err = err;
@@ -799,9 +877,14 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 							    mac, &fid, &lag_id);
 				if (mlxsw_sp_port ==
 				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
+					if (vport_fid && vport_fid != fid)
+						continue;
+					else if (vport_fid)
+						fdb->vid = vport_vid;
+					else
+						fdb->vid = fid;
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
-					fdb->vid = fid;
 					err = cb(&fdb->obj);
 					if (err)
 						stored_err = err;
@@ -823,6 +906,13 @@ static int mlxsw_sp_port_vlan_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid;
 	int err = 0;
 
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+		vlan->flags = 0;
+		vlan->vid_begin = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+		vlan->vid_end = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+		return cb(&vlan->obj);
+	}
+
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
 		vlan->flags = 0;
 		if (vid == mlxsw_sp_port->pvid)
@@ -843,6 +933,10 @@ static int mlxsw_sp_port_obj_dump(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err = 0;
 
+	mlxsw_sp_port = mlxsw_sp_port_orig_get(obj->orig_dev, mlxsw_sp_port);
+	if (!mlxsw_sp_port)
+		return -EINVAL;
+
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = mlxsw_sp_port_vlan_dump(mlxsw_sp_port,
-- 
1.9.3
