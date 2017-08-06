From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 08/13] net: dsa: Remove support for bypass bridge port attributes/vlan set
Date: Sun,  6 Aug 2017 16:15:46 +0300
Message-ID: <1502025351-41261-9-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44806 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751342AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge port attributes/vlan for DSA devices should be set only
from bridge code. Furthermore, The vlans are synced totally with the
bridge so there is no need for special dump support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 include/net/dsa.h  |  4 ----
 net/dsa/dsa_priv.h |  4 ----
 net/dsa/port.c     | 12 ------------
 net/dsa/slave.c    |  6 ------
 4 files changed, 26 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 446fc43..d7b9bdd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -378,10 +378,6 @@ struct dsa_switch_ops {
 				 struct switchdev_trans *trans);
 	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
 				 const struct switchdev_obj_port_vlan *vlan);
-	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
-				  struct switchdev_obj_port_vlan *vlan,
-				  switchdev_obj_dump_cb_t *cb);
-
 	/*
 	 * Forwarding database
 	 */
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dab10d5..77ddec4 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -148,10 +148,6 @@ int dsa_port_vlan_add(struct dsa_port *dp,
 		      struct switchdev_trans *trans);
 int dsa_port_vlan_del(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan);
-int dsa_port_vlan_dump(struct dsa_port *dp,
-		       struct switchdev_obj_port_vlan *vlan,
-		       switchdev_obj_dump_cb_t *cb);
-
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 86e0585..ce19216 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -246,15 +246,3 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_DEL, &info);
 }
-
-int dsa_port_vlan_dump(struct dsa_port *dp,
-		       struct switchdev_obj_port_vlan *vlan,
-		       switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_vlan_dump)
-		return ds->ops->port_vlan_dump(ds, dp->index, vlan, cb);
-
-	return -EOPNOTSUPP;
-}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9205fda..5b37298 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -302,9 +302,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_dump(dp, SWITCHDEV_OBJ_PORT_MDB(obj), cb);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_port_vlan_dump(dp, SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -958,9 +955,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
 	.ndo_poll_controller	= dsa_slave_poll_controller,
 #endif
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
 	.ndo_setup_tc		= dsa_slave_setup_tc,
 	.ndo_get_stats64	= dsa_slave_get_stats64,
-- 
2.4.11
