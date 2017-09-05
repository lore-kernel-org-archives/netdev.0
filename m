From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 4/8] net: dsa: slave: Handle switchdev host mdb add/del
Date: Wed,  6 Sep 2017 01:35:06 +0200
Message-ID: <1504654510-31004-5-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58220 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753545AbdIEXhj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:37:39 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to handle switchdev host mdb add/del. As with normal mdb
add/del, send a notification to the switch layer.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa_priv.h |  7 +++++++
 net/dsa/port.c     | 26 ++++++++++++++++++++++++++
 net/dsa/slave.c    |  6 ++++++
 3 files changed, 39 insertions(+)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 9c3eeb72462d..0ffe49f78d14 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -24,6 +24,8 @@ enum {
 	DSA_NOTIFIER_FDB_DEL,
 	DSA_NOTIFIER_MDB_ADD,
 	DSA_NOTIFIER_MDB_DEL,
+	DSA_NOTIFIER_HOST_MDB_ADD,
+	DSA_NOTIFIER_HOST_MDB_DEL,
 	DSA_NOTIFIER_VLAN_ADD,
 	DSA_NOTIFIER_VLAN_DEL,
 };
@@ -131,6 +133,11 @@ int dsa_port_mdb_add(struct dsa_port *dp,
 		     struct switchdev_trans *trans);
 int dsa_port_mdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb);
+int dsa_host_mdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb,
+		     struct switchdev_trans *trans);
+int dsa_host_mdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb);
 int dsa_port_vlan_add(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan,
 		      struct switchdev_trans *trans);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 659676ba3f8b..5b18b9fe2219 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -199,6 +199,32 @@ int dsa_port_mdb_del(struct dsa_port *dp,
 	return dsa_port_notify(dp, DSA_NOTIFIER_MDB_DEL, &info);
 }
 
+int dsa_host_mdb_add(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb,
+		     struct switchdev_trans *trans)
+{
+	struct dsa_notifier_mdb_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.trans = trans,
+		.mdb = mdb,
+	};
+
+	return dsa_port_notify(dp, DSA_NOTIFIER_HOST_MDB_ADD, &info);
+}
+
+int dsa_host_mdb_del(struct dsa_port *dp,
+		     const struct switchdev_obj_port_mdb *mdb)
+{
+	struct dsa_notifier_mdb_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.mdb = mdb,
+	};
+
+	return dsa_port_notify(dp, DSA_NOTIFIER_HOST_MDB_DEL, &info);
+}
+
 int dsa_port_vlan_add(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan,
 		      struct switchdev_trans *trans)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78e78a6e6833..2e07be149415 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -330,6 +330,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
 		break;
+	case SWITCHDEV_OBJ_ID_HOST_MDB:
+		err = dsa_host_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_port_vlan_add(dp, SWITCHDEV_OBJ_PORT_VLAN(obj),
 					trans);
@@ -353,6 +356,9 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
+	case SWITCHDEV_OBJ_ID_HOST_MDB:
+		err = dsa_host_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_port_vlan_del(dp, SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
-- 
2.14.1
