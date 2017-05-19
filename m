From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 18/20] net: dsa: add FDB notifier
Date: Fri, 19 May 2017 17:00:53 -0400
Message-ID: <20170519210055.9366-19-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48412 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932592AbdESVDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 17:03:18 -0400
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two new DSA_NOTIFIER_FDB_ADD and DSA_NOTIFIER_FDB_DEL events to
notify not only a single switch, but all switches of a the fabric when
an FDB entry is added or removed.

For the moment, keep the current behavior and ignore other switches.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 10 ++++++++++
 net/dsa/port.c     | 31 ++++++++++++++-----------------
 net/dsa/switch.c   | 43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 17 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index becaf8a61b13..6a7d0d7d0489 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -20,6 +20,8 @@ enum {
 	DSA_NOTIFIER_AGEING_TIME,
 	DSA_NOTIFIER_BRIDGE_JOIN,
 	DSA_NOTIFIER_BRIDGE_LEAVE,
+	DSA_NOTIFIER_FDB_ADD,
+	DSA_NOTIFIER_FDB_DEL,
 };
 
 /* DSA_NOTIFIER_AGEING_TIME */
@@ -36,6 +38,14 @@ struct dsa_notifier_bridge_info {
 	int port;
 };
 
+/* DSA_NOTIFIER_FDB_* */
+struct dsa_notifier_fdb_info {
+	const struct switchdev_obj_port_fdb *fdb;
+	struct switchdev_trans *trans;
+	int sw_index;
+	int port;
+};
+
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 59328a35394d..ed88d8381642 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -151,29 +151,26 @@ int dsa_port_fdb_add(struct dsa_port *dp,
 		     const struct switchdev_obj_port_fdb *fdb,
 		     struct switchdev_trans *trans)
 {
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_fdb_prepare(ds, dp->index, fdb, trans);
-	}
-
-	ds->ops->port_fdb_add(ds, dp->index, fdb, trans);
-
-	return 0;
+	struct dsa_notifier_fdb_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.trans = trans,
+		.fdb = fdb,
+	};
+
+	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_ADD, &info);
 }
 
 int dsa_port_fdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_fdb *fdb)
 {
-	struct dsa_switch *ds = dp->ds;
+	struct dsa_notifier_fdb_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.fdb = fdb,
+	};
 
-	if (ds->ops->port_fdb_del)
-		return -EOPNOTSUPP;
-
-	return ds->ops->port_fdb_del(ds, dp->index, fdb);
+	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_DEL, &info);
 }
 
 int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 540770ecc8b0..e71cc860d32c 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -84,6 +84,43 @@ static int dsa_switch_bridge_leave(struct dsa_switch *ds,
 	return 0;
 }
 
+static int dsa_switch_fdb_add(struct dsa_switch *ds,
+			      struct dsa_notifier_fdb_info *info)
+{
+	const struct switchdev_obj_port_fdb *fdb = info->fdb;
+	struct switchdev_trans *trans = info->trans;
+
+	/* Do not care yet about other switch chips of the fabric */
+	if (ds->index != info->sw_index)
+		return 0;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_fdb_prepare(ds, info->port, fdb, trans);
+	}
+
+	ds->ops->port_fdb_add(ds, info->port, fdb, trans);
+
+	return 0;
+}
+
+static int dsa_switch_fdb_del(struct dsa_switch *ds,
+			      struct dsa_notifier_fdb_info *info)
+{
+	const struct switchdev_obj_port_fdb *fdb = info->fdb;
+
+	/* Do not care yet about other switch chips of the fabric */
+	if (ds->index != info->sw_index)
+		return 0;
+
+	if (!ds->ops->port_fdb_del)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_fdb_del(ds, info->port, fdb);
+}
+
 static int dsa_switch_event(struct notifier_block *nb,
 			    unsigned long event, void *info)
 {
@@ -100,6 +137,12 @@ static int dsa_switch_event(struct notifier_block *nb,
 	case DSA_NOTIFIER_BRIDGE_LEAVE:
 		err = dsa_switch_bridge_leave(ds, info);
 		break;
+	case DSA_NOTIFIER_FDB_ADD:
+		err = dsa_switch_fdb_add(ds, info);
+		break;
+	case DSA_NOTIFIER_FDB_DEL:
+		err = dsa_switch_fdb_del(ds, info);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.13.0
