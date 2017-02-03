From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: introduce bridge notifier
Date: Fri,  3 Feb 2017 13:20:21 -0500
Message-ID: <20170203182021.14246-7-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A slave device will now notify the switch fabric once its port is
bridged or unbridged, instead of calling directly its switch operations.

This code allows propagating cross-chip bridging events in the fabric.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 10 ++++++++++
 net/dsa/slave.c   | 40 +++++++++++++++++++++++++++++-----------
 net/dsa/switch.c  | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+), 11 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ac4ea7c3a102..e9c940c8936f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -268,6 +268,16 @@ struct switchdev_obj_port_fdb;
 struct switchdev_obj_port_mdb;
 struct switchdev_obj_port_vlan;
 
+#define DSA_NOTIFIER_BRIDGE_JOIN		1
+#define DSA_NOTIFIER_BRIDGE_LEAVE		2
+
+/* DSA_NOTIFIER_BRIDGE_* */
+struct dsa_notifier_bridge_info {
+	struct net_device *br;
+	int sw_index;
+	int port;
+};
+
 struct dsa_switch_ops {
 	/*
 	 * Probing and setup.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d8c3c0f00cf3..061a49c29cef 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -27,6 +27,17 @@
 
 static bool dsa_slave_dev_check(struct net_device *dev);
 
+static int dsa_slave_notify(struct net_device *dev, unsigned long e, void *v)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct raw_notifier_head *nh = &p->dp->ds->dst->nh;
+	int err;
+
+	err = raw_notifier_call_chain(nh, e, v);
+
+	return notifier_to_errno(err);
+}
+
 /* slave mii_bus handling ***************************************************/
 static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
@@ -562,39 +573,46 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-	int ret = -EOPNOTSUPP;
+	struct dsa_notifier_bridge_info info = {
+		.sw_index = p->dp->ds->index,
+		.port = p->dp->index,
+		.br = br,
+	};
+	int err;
 
 	/* Here the port is already bridged. Reflect the current configuration
 	 * so that drivers can program their chips accordingly.
 	 */
 	p->dp->bridge_dev = br;
 
-	if (ds->ops->port_bridge_join)
-		ret = ds->ops->port_bridge_join(ds, p->dp->index, br);
+	err = dsa_slave_notify(dev, DSA_NOTIFIER_BRIDGE_JOIN, &info);
 
 	/* The bridging is rolled back on error */
-	if (ret && ret != -EOPNOTSUPP) {
+	if (err)
 		p->dp->bridge_dev = NULL;
-		return ret;
-	}
 
-	return 0;
+	return err;
 }
 
 static void dsa_slave_bridge_port_leave(struct net_device *dev,
 					struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_notifier_bridge_info info = {
+		.sw_index = p->dp->ds->index,
+		.port = p->dp->index,
+		.br = br,
+	};
+	int err;
 
 	/* Here the port is already unbridged. Reflect the current configuration
 	 * so that drivers can program their chips accordingly.
 	 */
 	p->dp->bridge_dev = NULL;
 
-	if (ds->ops->port_bridge_leave)
-		ds->ops->port_bridge_leave(ds, p->dp->index, br);
+	err = dsa_slave_notify(dev, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
+	if (err)
+		netdev_err(dev, "failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index e22fa7633d03..6456dacf9ae9 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -13,6 +13,32 @@
 #include <linux/notifier.h>
 #include <net/dsa.h>
 
+static int dsa_switch_bridge_join(struct dsa_switch *ds,
+				  struct dsa_notifier_bridge_info *info)
+{
+	if (ds->index == info->sw_index && ds->ops->port_bridge_join)
+		return ds->ops->port_bridge_join(ds, info->port, info->br);
+
+	if (ds->index != info->sw_index)
+		dev_dbg(ds->dev, "crosschip DSA port %d.%d bridged to %s\n",
+			info->sw_index, info->port, netdev_name(info->br));
+
+	return 0;
+}
+
+static int dsa_switch_bridge_leave(struct dsa_switch *ds,
+				   struct dsa_notifier_bridge_info *info)
+{
+	if (ds->index == info->sw_index && ds->ops->port_bridge_leave)
+		ds->ops->port_bridge_leave(ds, info->port, info->br);
+
+	if (ds->index != info->sw_index)
+		dev_dbg(ds->dev, "crosschip DSA port %d.%d unbridged from %s\n",
+			info->sw_index, info->port, netdev_name(info->br));
+
+	return 0;
+}
+
 static int dsa_switch_event(struct notifier_block *nb,
 			    unsigned long event, void *info)
 {
@@ -20,6 +46,12 @@ static int dsa_switch_event(struct notifier_block *nb,
 	int err;
 
 	switch (event) {
+	case DSA_NOTIFIER_BRIDGE_JOIN:
+		err = dsa_switch_bridge_join(ds, info);
+		break;
+	case DSA_NOTIFIER_BRIDGE_LEAVE:
+		err = dsa_switch_bridge_leave(ds, info);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.11.0
