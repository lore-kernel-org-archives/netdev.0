From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: move fixed link registration helpers
Date: Thu, 26 Oct 2017 10:50:07 -0400
Message-ID: <20171026145007.17583-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new bindings (dsa2.c) and the old bindings (legacy.c) share two
helpers dsa_cpu_dsa_setup and dsa_cpu_dsa_destroy, used to register or
deregister a fixed PHY if a given port has a corresponding device node.

Unclutter the code by moving them into two new port.c helpers,
dsa_port_fixed_link_register_of and dsa_port_fixed_link_(un)register_of.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c      | 39 ---------------------------------------
 net/dsa/dsa2.c     |  8 ++++----
 net/dsa/dsa_priv.h |  5 +++--
 net/dsa/legacy.c   |  4 ++--
 net/dsa/port.c     | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 56 insertions(+), 47 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fe0081730305..b8f2d9f7c3ed 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -68,37 +68,6 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 	[DSA_TAG_PROTO_NONE] = &none_ops,
 };
 
-int dsa_cpu_dsa_setup(struct dsa_port *port)
-{
-	struct device_node *port_dn = port->dn;
-	struct dsa_switch *ds = port->ds;
-	struct phy_device *phydev;
-	int ret, mode;
-
-	if (of_phy_is_fixed_link(port_dn)) {
-		ret = of_phy_register_fixed_link(port_dn);
-		if (ret) {
-			dev_err(ds->dev, "failed to register fixed PHY\n");
-			return ret;
-		}
-		phydev = of_phy_find_device(port_dn);
-
-		mode = of_get_phy_mode(port_dn);
-		if (mode < 0)
-			mode = PHY_INTERFACE_MODE_NA;
-		phydev->interface = mode;
-
-		genphy_config_init(phydev);
-		genphy_read_status(phydev);
-		if (ds->ops->adjust_link)
-			ds->ops->adjust_link(ds, port->index, phydev);
-
-		put_device(&phydev->mdio.dev);
-	}
-
-	return 0;
-}
-
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
 {
 	const struct dsa_device_ops *ops;
@@ -113,14 +82,6 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
 	return ops;
 }
 
-void dsa_cpu_dsa_destroy(struct dsa_port *port)
-{
-	struct device_node *port_dn = port->dn;
-
-	if (of_phy_is_fixed_link(port_dn))
-		of_phy_deregister_fixed_link(port_dn);
-}
-
 static int dev_is_class(struct device *dev, void *class)
 {
 	if (dev->class != NULL && !strcmp(dev->class->name, class))
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index ec58654a71cd..de91c48b6806 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -219,7 +219,7 @@ static int dsa_dsa_port_apply(struct dsa_port *port)
 	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(port);
+	err = dsa_port_fixed_link_register_of(port);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup dsa port %d: %d\n",
 			 port->index, err);
@@ -235,7 +235,7 @@ static int dsa_dsa_port_apply(struct dsa_port *port)
 static void dsa_dsa_port_unapply(struct dsa_port *port)
 {
 	devlink_port_unregister(&port->devlink_port);
-	dsa_cpu_dsa_destroy(port);
+	dsa_port_fixed_link_unregister_of(port);
 }
 
 static int dsa_cpu_port_apply(struct dsa_port *port)
@@ -243,7 +243,7 @@ static int dsa_cpu_port_apply(struct dsa_port *port)
 	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(port);
+	err = dsa_port_fixed_link_register_of(port);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup cpu port %d: %d\n",
 			 port->index, err);
@@ -259,7 +259,7 @@ static int dsa_cpu_port_apply(struct dsa_port *port)
 static void dsa_cpu_port_unapply(struct dsa_port *port)
 {
 	devlink_port_unregister(&port->devlink_port);
-	dsa_cpu_dsa_destroy(port);
+	dsa_port_fixed_link_unregister_of(port);
 }
 
 static int dsa_user_port_apply(struct dsa_port *port)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1e9914062d0b..1e65afd6989e 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -93,8 +93,6 @@ struct dsa_slave_priv {
 };
 
 /* dsa.c */
-int dsa_cpu_dsa_setup(struct dsa_port *port);
-void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 bool dsa_schedule_work(struct work_struct *work);
 
@@ -159,6 +157,9 @@ int dsa_port_vlan_add(struct dsa_port *dp,
 		      struct switchdev_trans *trans);
 int dsa_port_vlan_del(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan);
+int dsa_port_fixed_link_register_of(struct dsa_port *dp);
+void dsa_port_fixed_link_unregister_of(struct dsa_port *dp);
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 93e1b116ef83..ed7aae342fca 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -86,7 +86,7 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds)
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
-		ret = dsa_cpu_dsa_setup(&ds->ports[port]);
+		ret = dsa_port_fixed_link_register_of(&ds->ports[port]);
 		if (ret)
 			return ret;
 	}
@@ -274,7 +274,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	for (port = 0; port < ds->num_ports; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
-		dsa_cpu_dsa_destroy(&ds->ports[port]);
+		dsa_port_fixed_link_unregister_of(&ds->ports[port]);
 	}
 
 	if (ds->slave_mii_bus && ds->ops->phy_read)
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 72c8dbd3d3f2..bb30b1a7de3a 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -12,6 +12,8 @@
 
 #include <linux/if_bridge.h>
 #include <linux/notifier.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
 
 #include "dsa_priv.h"
 
@@ -264,3 +266,48 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_DEL, &info);
 }
+
+int dsa_port_fixed_link_register_of(struct dsa_port *dp)
+{
+	struct device_node *dn = dp->dn;
+	struct dsa_switch *ds = dp->ds;
+	struct phy_device *phydev;
+	int port = dp->index;
+	int mode;
+	int err;
+
+	if (of_phy_is_fixed_link(dn)) {
+		err = of_phy_register_fixed_link(dn);
+		if (err) {
+			dev_err(ds->dev,
+				"failed to register the fixed PHY of port %d\n",
+				port);
+			return err;
+		}
+
+		phydev = of_phy_find_device(dn);
+
+		mode = of_get_phy_mode(dn);
+		if (mode < 0)
+			mode = PHY_INTERFACE_MODE_NA;
+		phydev->interface = mode;
+
+		genphy_config_init(phydev);
+		genphy_read_status(phydev);
+
+		if (ds->ops->adjust_link)
+			ds->ops->adjust_link(ds, port, phydev);
+
+		put_device(&phydev->mdio.dev);
+	}
+
+	return 0;
+}
+
+void dsa_port_fixed_link_unregister_of(struct dsa_port *dp)
+{
+	struct device_node *dn = dp->dn;
+
+	if (of_phy_is_fixed_link(dn))
+		of_phy_deregister_fixed_link(dn);
+}
-- 
2.14.3
