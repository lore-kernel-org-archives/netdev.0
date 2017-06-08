From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 18/19] rocker: Remove support for bypass bridge port attributes/vlan set
Date: Thu,  8 Jun 2017 08:44:27 +0200
Message-ID: <20170608064428.4785-19-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35524 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdFHGo5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:57 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so5662146wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:56 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The bridge port attributes/vlan for mlxsw devices should be set only
from bridge code. The vlans are synced totally with the bridge so
there is no need to special dump support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  3 ---
 drivers/net/ethernet/rocker/rocker_main.c  | 20 --------------------
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 24 ------------------------
 3 files changed, 47 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index a0f7782..a0fa3f8 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -122,9 +122,6 @@ struct rocker_world_ops {
 				 const struct switchdev_obj_port_vlan *vlan);
 	int (*port_obj_vlan_del)(struct rocker_port *rocker_port,
 				 const struct switchdev_obj_port_vlan *vlan);
-	int (*port_obj_vlan_dump)(const struct rocker_port *rocker_port,
-				  struct switchdev_obj_port_vlan *vlan,
-				  switchdev_obj_dump_cb_t *cb);
 	int (*port_obj_fdb_add)(struct rocker_port *rocker_port,
 				u16 vid, const unsigned char *addr);
 	int (*port_obj_fdb_del)(struct rocker_port *rocker_port,
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 72dab7c..3e78129 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1652,18 +1652,6 @@ rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
 }
 
 static int
-rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
-				struct switchdev_obj_port_vlan *vlan,
-				switchdev_obj_dump_cb_t *cb)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_vlan_dump)
-		return -EOPNOTSUPP;
-	return wops->port_obj_vlan_dump(rocker_port, vlan, cb);
-}
-
-static int
 rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
 			      const struct switchdev_obj_port_fdb *fdb,
 			      struct switchdev_trans *trans)
@@ -2079,9 +2067,6 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_start_xmit			= rocker_port_xmit,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
 	.ndo_change_mtu			= rocker_port_change_mtu,
-	.ndo_bridge_getlink		= switchdev_port_bridge_getlink,
-	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
-	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
 	.ndo_fdb_add			= switchdev_port_fdb_add,
 	.ndo_fdb_del			= switchdev_port_fdb_del,
 	.ndo_fdb_dump			= switchdev_port_fdb_dump,
@@ -2214,11 +2199,6 @@ static int rocker_port_obj_dump(struct net_device *dev,
 						     SWITCHDEV_OBJ_PORT_FDB(obj),
 						     cb);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = rocker_world_port_obj_vlan_dump(rocker_port,
-						      SWITCHDEV_OBJ_PORT_VLAN(obj),
-						      cb);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 184a478..5510ad0 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2583,29 +2583,6 @@ static int ofdpa_port_obj_vlan_del(struct rocker_port *rocker_port,
 	return 0;
 }
 
-static int ofdpa_port_obj_vlan_dump(const struct rocker_port *rocker_port,
-				    struct switchdev_obj_port_vlan *vlan,
-				    switchdev_obj_dump_cb_t *cb)
-{
-	const struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-	u16 vid;
-	int err = 0;
-
-	for (vid = 1; vid < VLAN_N_VID; vid++) {
-		if (!test_bit(vid, ofdpa_port->vlan_bitmap))
-			continue;
-		vlan->flags = 0;
-		if (ofdpa_vlan_id_is_internal(htons(vid)))
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-		vlan->vid_begin = vlan->vid_end = vid;
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
 static int ofdpa_port_obj_fdb_add(struct rocker_port *rocker_port,
 				  u16 vid, const unsigned char *addr)
 {
@@ -2882,7 +2859,6 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_attr_bridge_ageing_time_set = ofdpa_port_attr_bridge_ageing_time_set,
 	.port_obj_vlan_add = ofdpa_port_obj_vlan_add,
 	.port_obj_vlan_del = ofdpa_port_obj_vlan_del,
-	.port_obj_vlan_dump = ofdpa_port_obj_vlan_dump,
 	.port_obj_fdb_add = ofdpa_port_obj_fdb_add,
 	.port_obj_fdb_del = ofdpa_port_obj_fdb_del,
 	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
-- 
2.9.3
