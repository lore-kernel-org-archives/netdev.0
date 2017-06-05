From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/19] rocker: Remove support bridge bypass FDB
Date: Mon,  5 Jun 2017 11:20:43 +0200
Message-ID: <20170605092043.3523-20-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34926 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751417AbdFEJVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:21:17 -0400
Received: by mail-wr0-f194.google.com with SMTP id g76so6834456wrd.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:21:16 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The FDB add/delete are now done through the notification chain. The FDBs
are synced with the bridge and there is no need for extra dumping.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  3 --
 drivers/net/ethernet/rocker/rocker_main.c  | 73 ------------------------------
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 30 ------------
 3 files changed, 106 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index a0fa3f8..748fb12 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -126,9 +126,6 @@ struct rocker_world_ops {
 				u16 vid, const unsigned char *addr);
 	int (*port_obj_fdb_del)(struct rocker_port *rocker_port,
 				u16 vid, const unsigned char *addr);
-	int (*port_obj_fdb_dump)(const struct rocker_port *rocker_port,
-				 struct switchdev_obj_port_fdb *fdb,
-				 switchdev_obj_dump_cb_t *cb);
 	int (*port_master_linked)(struct rocker_port *rocker_port,
 				  struct net_device *master);
 	int (*port_master_unlinked)(struct rocker_port *rocker_port,
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 3e78129..b1e5c07 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1652,33 +1652,6 @@ rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
 }
 
 static int
-rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
-			      const struct switchdev_obj_port_fdb *fdb,
-			      struct switchdev_trans *trans)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_fdb_add)
-		return -EOPNOTSUPP;
-
-	if (switchdev_trans_ph_prepare(trans))
-		return 0;
-
-	return wops->port_obj_fdb_add(rocker_port, fdb->vid, fdb->addr);
-}
-
-static int
-rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
-			      const struct switchdev_obj_port_fdb *fdb)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_fdb_del)
-		return -EOPNOTSUPP;
-	return wops->port_obj_fdb_del(rocker_port, fdb->vid, fdb->addr);
-}
-
-static int
 rocker_world_port_fdb_add(struct rocker_port *rocker_port,
 			  struct switchdev_notifier_fdb_info *info)
 {
@@ -1701,18 +1674,6 @@ rocker_world_port_fdb_del(struct rocker_port *rocker_port,
 	return wops->port_obj_fdb_del(rocker_port, info->vid, info->addr);
 }
 
-static int
-rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
-			       struct switchdev_obj_port_fdb *fdb,
-			       switchdev_obj_dump_cb_t *cb)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_fdb_dump)
-		return -EOPNOTSUPP;
-	return wops->port_obj_fdb_dump(rocker_port, fdb, cb);
-}
-
 static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
 					   struct net_device *master)
 {
@@ -2067,9 +2028,6 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_start_xmit			= rocker_port_xmit,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
 	.ndo_change_mtu			= rocker_port_change_mtu,
-	.ndo_fdb_add			= switchdev_port_fdb_add,
-	.ndo_fdb_del			= switchdev_port_fdb_del,
-	.ndo_fdb_dump			= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 	.ndo_change_proto_down		= rocker_port_change_proto_down,
 	.ndo_neigh_destroy		= rocker_port_neigh_destroy,
@@ -2150,11 +2108,6 @@ static int rocker_port_obj_add(struct net_device *dev,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj),
 						     trans);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_world_port_obj_fdb_add(rocker_port,
-						    SWITCHDEV_OBJ_PORT_FDB(obj),
-						    trans);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -2174,31 +2127,6 @@ static int rocker_port_obj_del(struct net_device *dev,
 		err = rocker_world_port_obj_vlan_del(rocker_port,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_world_port_obj_fdb_del(rocker_port,
-						    SWITCHDEV_OBJ_PORT_FDB(obj));
-		break;
-	default:
-		err = -EOPNOTSUPP;
-		break;
-	}
-
-	return err;
-}
-
-static int rocker_port_obj_dump(struct net_device *dev,
-				struct switchdev_obj *obj,
-				switchdev_obj_dump_cb_t *cb)
-{
-	const struct rocker_port *rocker_port = netdev_priv(dev);
-	int err = 0;
-
-	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = rocker_world_port_obj_fdb_dump(rocker_port,
-						     SWITCHDEV_OBJ_PORT_FDB(obj),
-						     cb);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -2212,7 +2140,6 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_port_obj_add		= rocker_port_obj_add,
 	.switchdev_port_obj_del		= rocker_port_obj_del,
-	.switchdev_port_obj_dump	= rocker_port_obj_dump,
 };
 
 struct rocker_fib_event_work {
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 5510ad0..bd0e3f1 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2608,35 +2608,6 @@ static int ofdpa_port_obj_fdb_del(struct rocker_port *rocker_port,
 	return ofdpa_port_fdb(ofdpa_port, addr, vlan_id, flags);
 }
 
-static int ofdpa_port_obj_fdb_dump(const struct rocker_port *rocker_port,
-				   struct switchdev_obj_port_fdb *fdb,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	const struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-	struct ofdpa *ofdpa = ofdpa_port->ofdpa;
-	struct ofdpa_fdb_tbl_entry *found;
-	struct hlist_node *tmp;
-	unsigned long lock_flags;
-	int bkt;
-	int err = 0;
-
-	spin_lock_irqsave(&ofdpa->fdb_tbl_lock, lock_flags);
-	hash_for_each_safe(ofdpa->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.ofdpa_port != ofdpa_port)
-			continue;
-		ether_addr_copy(fdb->addr, found->key.addr);
-		fdb->ndm_state = NUD_REACHABLE;
-		fdb->vid = ofdpa_port_vlan_to_vid(ofdpa_port,
-						  found->key.vlan_id);
-		err = cb(&fdb->obj);
-		if (err)
-			break;
-	}
-	spin_unlock_irqrestore(&ofdpa->fdb_tbl_lock, lock_flags);
-
-	return err;
-}
-
 static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
 				  struct net_device *bridge)
 {
@@ -2861,7 +2832,6 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_obj_vlan_del = ofdpa_port_obj_vlan_del,
 	.port_obj_fdb_add = ofdpa_port_obj_fdb_add,
 	.port_obj_fdb_del = ofdpa_port_obj_fdb_del,
-	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
 	.port_master_linked = ofdpa_port_master_linked,
 	.port_master_unlinked = ofdpa_port_master_unlinked,
 	.port_neigh_update = ofdpa_port_neigh_update,
-- 
2.9.3
