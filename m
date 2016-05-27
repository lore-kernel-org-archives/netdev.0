From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA and CPU ports
Date: Fri, 27 May 2016 03:20:43 +0200
Message-ID: <1464312050-23023-10-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52534 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774AbcE0BXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:23:43 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the code to setup a single DSA/CPU port into a function of
its own, and export it, so it can be used by the new binding.

Similarly, refactor the destroy code into a function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c      | 86 ++++++++++++++++++++++++++++++++----------------------
 net/dsa/dsa_priv.h |  3 ++
 2 files changed, 54 insertions(+), 35 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index bfe1d03d4730..20eede3facf5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -180,36 +180,47 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 /* basic switch operations **************************************************/
-static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
+int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
+		      struct device_node *port_dn, int port)
 {
-	struct device_node *port_dn;
 	struct phy_device *phydev;
-	int ret, port, mode;
+	int ret, mode;
+
+	if (of_phy_is_fixed_link(port_dn)) {
+		ret = of_phy_register_fixed_link(port_dn);
+		if (ret) {
+			dev_err(dev, "failed to register fixed PHY\n");
+			return ret;
+		}
+		phydev = of_phy_find_device(port_dn);
+
+		mode = of_get_phy_mode(port_dn);
+		if (mode < 0)
+			mode = PHY_INTERFACE_MODE_NA;
+		phydev->interface = mode;
+
+		genphy_config_init(phydev);
+		genphy_read_status(phydev);
+		if (ds->drv->adjust_link)
+			ds->drv->adjust_link(ds, port, phydev);
+	}
+
+	return 0;
+}
+
+static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
+{
+	struct device_node *port_dn;
+	int ret, port;
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
 		port_dn = ds->ports[port].dn;
-		if (of_phy_is_fixed_link(port_dn)) {
-			ret = of_phy_register_fixed_link(port_dn);
-			if (ret) {
-				netdev_err(master,
-					   "failed to register fixed PHY\n");
-				return ret;
-			}
-			phydev = of_phy_find_device(port_dn);
-
-			mode = of_get_phy_mode(port_dn);
-			if (mode < 0)
-				mode = PHY_INTERFACE_MODE_NA;
-			phydev->interface = mode;
-
-			genphy_config_init(phydev);
-			genphy_read_status(phydev);
-			if (ds->drv->adjust_link)
-				ds->drv->adjust_link(ds, port, phydev);
-		}
+		ret = dsa_cpu_dsa_setup(ds, dev, port_dn, port);
+		if (ret)
+			return ret;
 	}
 	return 0;
 }
@@ -340,7 +351,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	}
 
 	/* Perform configuration of the CPU and DSA ports */
-	ret = dsa_cpu_dsa_setup(ds, dst->master_netdev);
+	ret = dsa_cpu_dsa_setups(ds, parent);
 	if (ret < 0) {
 		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
@@ -423,10 +434,21 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	return ds;
 }
 
-static void dsa_switch_destroy(struct dsa_switch *ds)
+void dsa_cpu_dsa_destroy(struct device_node *port_dn)
 {
-	struct device_node *port_dn;
 	struct phy_device *phydev;
+
+	if (of_phy_is_fixed_link(port_dn)) {
+		phydev = of_phy_find_device(port_dn);
+		if (phydev) {
+			phy_device_free(phydev);
+			fixed_phy_unregister(phydev);
+		}
+	}
+}
+
+static void dsa_switch_destroy(struct dsa_switch *ds)
+{
 	int port;
 
 #ifdef CONFIG_NET_DSA_HWMON
@@ -445,17 +467,11 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		dsa_slave_destroy(ds->ports[port].netdev);
 	}
 
-	/* Remove any fixed link PHYs */
+	/* Disable configuration of the CPU and DSA ports */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		port_dn = ds->ports[port].dn;
-		if (of_phy_is_fixed_link(port_dn)) {
-			phydev = of_phy_find_device(port_dn);
-			if (phydev) {
-				phy_device_free(phydev);
-				of_node_put(port_dn);
-				fixed_phy_unregister(phydev);
-			}
-		}
+		if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
+			continue;
+		dsa_cpu_dsa_destroy(ds->ports[port].dn);
 	}
 
 	mdiobus_unregister(ds->slave_mii_bus);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dfa33779d49c..dbea5d9e7f75 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -50,6 +50,9 @@ struct dsa_slave_priv {
 
 /* dsa.c */
 extern char dsa_driver_version[];
+int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
+		      struct device_node *port_dn, int port);
+void dsa_cpu_dsa_destroy(struct device_node *port_dn);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
-- 
2.8.1
