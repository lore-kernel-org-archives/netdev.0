From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 03/13] net: dsa: Remove switchdev dependency from DSA switch notifier chain
Date: Sun,  6 Aug 2017 16:15:41 +0300
Message-ID: <1502025351-41261-4-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44771 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751331AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the switchdev objects are embedded inside the DSA notifier
info. This patch removes this dependency. This is done as a preparation
stage before adding support for learning FDB through the switchdev
notification chain.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 11 ++++++-----
 net/dsa/port.c     | 15 +++++++++------
 net/dsa/slave.c    |  6 ++++--
 net/dsa/switch.c   | 11 ++++-------
 4 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 330078d..f9f5de0 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -43,9 +43,10 @@ struct dsa_notifier_bridge_info {
 
 /* DSA_NOTIFIER_FDB_* */
 struct dsa_notifier_fdb_info {
-	const struct switchdev_obj_port_fdb *fdb;
 	int sw_index;
 	int port;
+	const unsigned char *addr;
+	u16 vid;
 };
 
 /* DSA_NOTIFIER_MDB_* */
@@ -121,10 +122,10 @@ int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 			    struct switchdev_trans *trans);
 int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 			 struct switchdev_trans *trans);
-int dsa_port_fdb_add(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb);
-int dsa_port_fdb_del(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb);
+int dsa_port_fdb_add(struct dsa_port *dp, const unsigned char *addr,
+		     u16 vid);
+int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
+		     u16 vid);
 int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
 		      switchdev_obj_dump_cb_t *cb);
 int dsa_port_mdb_add(struct dsa_port *dp,
diff --git a/net/dsa/port.c b/net/dsa/port.c
index bd271b9..86e0585 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -146,25 +146,28 @@ int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 	return dsa_port_notify(dp, DSA_NOTIFIER_AGEING_TIME, &info);
 }
 
-int dsa_port_fdb_add(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb)
+int dsa_port_fdb_add(struct dsa_port *dp, const unsigned char *addr,
+		     u16 vid)
 {
 	struct dsa_notifier_fdb_info info = {
 		.sw_index = dp->ds->index,
 		.port = dp->index,
-		.fdb = fdb,
+		.addr = addr,
+		.vid = vid,
 	};
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_ADD, &info);
 }
 
-int dsa_port_fdb_del(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb)
+int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
+		     u16 vid)
 {
 	struct dsa_notifier_fdb_info info = {
 		.sw_index = dp->ds->index,
 		.port = dp->index,
-		.fdb = fdb,
+		.addr = addr,
+		.vid = vid,
+
 	};
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_DEL, &info);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4f06984..13c90e2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -253,7 +253,8 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		if (switchdev_trans_ph_prepare(trans))
 			return 0;
-		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj));
+		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
+				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
@@ -279,7 +280,8 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj));
+		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
+				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index eb20e0f..e6c06aa 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -83,8 +83,6 @@ static int dsa_switch_bridge_leave(struct dsa_switch *ds,
 static int dsa_switch_fdb_add(struct dsa_switch *ds,
 			      struct dsa_notifier_fdb_info *info)
 {
-	const struct switchdev_obj_port_fdb *fdb = info->fdb;
-
 	/* Do not care yet about other switch chips of the fabric */
 	if (ds->index != info->sw_index)
 		return 0;
@@ -92,14 +90,13 @@ static int dsa_switch_fdb_add(struct dsa_switch *ds,
 	if (!ds->ops->port_fdb_add)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_fdb_add(ds, info->port, fdb->addr, fdb->vid);
+	return ds->ops->port_fdb_add(ds, info->port, info->addr,
+				     info->vid);
 }
 
 static int dsa_switch_fdb_del(struct dsa_switch *ds,
 			      struct dsa_notifier_fdb_info *info)
 {
-	const struct switchdev_obj_port_fdb *fdb = info->fdb;
-
 	/* Do not care yet about other switch chips of the fabric */
 	if (ds->index != info->sw_index)
 		return 0;
@@ -107,8 +104,8 @@ static int dsa_switch_fdb_del(struct dsa_switch *ds,
 	if (!ds->ops->port_fdb_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_fdb_del(ds, info->port, fdb->addr,
-				     fdb->vid);
+	return ds->ops->port_fdb_del(ds, info->port, info->addr,
+				     info->vid);
 }
 
 static int dsa_switch_mdb_add(struct dsa_switch *ds,
-- 
2.4.11
