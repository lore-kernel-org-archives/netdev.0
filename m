From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 20/20] net: dsa: add VLAN notifier
Date: Fri, 19 May 2017 17:00:55 -0400
Message-ID: <20170519210055.9366-21-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add two new DSA_NOTIFIER_VLAN_ADD and DSA_NOTIFIER_VLAN_DEL events to
notify not only a single switch, but all switches of a the fabric when
an VLAN entry is added or removed.

For the moment, keep the current behavior and ignore other switches.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 10 ++++++++++
 net/dsa/port.c     | 31 ++++++++++++++-----------------
 net/dsa/switch.c   | 43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 17 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2b60293b325c..1d52f9051d0e 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -24,6 +24,8 @@ enum {
 	DSA_NOTIFIER_FDB_DEL,
 	DSA_NOTIFIER_MDB_ADD,
 	DSA_NOTIFIER_MDB_DEL,
+	DSA_NOTIFIER_VLAN_ADD,
+	DSA_NOTIFIER_VLAN_DEL,
 };
 
 /* DSA_NOTIFIER_AGEING_TIME */
@@ -56,6 +58,14 @@ struct dsa_notifier_mdb_info {
 	int port;
 };
 
+/* DSA_NOTIFIER_VLAN_* */
+struct dsa_notifier_vlan_info {
+	const struct switchdev_obj_port_vlan *vlan;
+	struct switchdev_trans *trans;
+	int sw_index;
+	int port;
+};
+
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/port.c b/net/dsa/port.c
index c7c4920e7bc9..c88c0cec8454 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -225,29 +225,26 @@ int dsa_port_vlan_add(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan,
 		      struct switchdev_trans *trans)
 {
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_vlan_prepare(ds, dp->index, vlan, trans);
-	}
-
-	ds->ops->port_vlan_add(ds, dp->index, vlan, trans);
-
-	return 0;
+	struct dsa_notifier_vlan_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.trans = trans,
+		.vlan = vlan,
+	};
+
+	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_ADD, &info);
 }
 
 int dsa_port_vlan_del(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan)
 {
-	struct dsa_switch *ds = dp->ds;
+	struct dsa_notifier_vlan_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.vlan = vlan,
+	};
 
-	if (!ds->ops->port_vlan_del)
-		return -EOPNOTSUPP;
-
-	return ds->ops->port_vlan_del(ds, dp->index, vlan);
+	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_DEL, &info);
 }
 
 int dsa_port_vlan_dump(struct dsa_port *dp,
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index b7e8e45869fc..c1e4b2d5a3ae 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -158,6 +158,43 @@ static int dsa_switch_mdb_del(struct dsa_switch *ds,
 	return ds->ops->port_mdb_del(ds, info->port, mdb);
 }
 
+static int dsa_switch_vlan_add(struct dsa_switch *ds,
+			       struct dsa_notifier_vlan_info *info)
+{
+	const struct switchdev_obj_port_vlan *vlan = info->vlan;
+	struct switchdev_trans *trans = info->trans;
+
+	/* Do not care yet about other switch chips of the fabric */
+	if (ds->index != info->sw_index)
+		return 0;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
+			return -EOPNOTSUPP;
+
+		return ds->ops->port_vlan_prepare(ds, info->port, vlan, trans);
+	}
+
+	ds->ops->port_vlan_add(ds, info->port, vlan, trans);
+
+	return 0;
+}
+
+static int dsa_switch_vlan_del(struct dsa_switch *ds,
+			       struct dsa_notifier_vlan_info *info)
+{
+	const struct switchdev_obj_port_vlan *vlan = info->vlan;
+
+	/* Do not care yet about other switch chips of the fabric */
+	if (ds->index != info->sw_index)
+		return 0;
+
+	if (!ds->ops->port_vlan_del)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_vlan_del(ds, info->port, vlan);
+}
+
 static int dsa_switch_event(struct notifier_block *nb,
 			    unsigned long event, void *info)
 {
@@ -186,6 +223,12 @@ static int dsa_switch_event(struct notifier_block *nb,
 	case DSA_NOTIFIER_MDB_DEL:
 		err = dsa_switch_mdb_del(ds, info);
 		break;
+	case DSA_NOTIFIER_VLAN_ADD:
+		err = dsa_switch_vlan_add(ds, info);
+		break;
+	case DSA_NOTIFIER_VLAN_DEL:
+		err = dsa_switch_vlan_del(ds, info);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.13.0
