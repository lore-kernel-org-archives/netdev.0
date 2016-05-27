From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 06/16] dsa: Move port device node into port structure
Date: Fri, 27 May 2016 03:20:40 +0200
Message-ID: <1464312050-23023-7-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52492 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755771AbcE0BVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:21:51 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the port device node structure into the port structure, from the
chip data. This information is needed in the next step of implementing
the new binding.

The chip data structure is used while parsing the whole old binding,
before the individual switch structures exist. With the new bindings,
this is reversed, the switches exist first, and the interconnections
between the switches is derived from the individual switch
bindings. Thus this chip data structure becomes unneeded.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 8 ++++----
 net/dsa/slave.c   | 5 ++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9aed8572037c..8314197d028f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -121,6 +121,7 @@ struct dsa_switch_tree {
 
 struct dsa_port {
 	struct net_device	*netdev;
+	struct device_node	*dn;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 18086e0cc617..5907f8cd13b6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -182,7 +182,6 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 /* basic switch operations **************************************************/
 static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
 {
-	struct dsa_chip_data *cd = ds->cd;
 	struct device_node *port_dn;
 	struct phy_device *phydev;
 	int ret, port, mode;
@@ -191,7 +190,7 @@ static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
-		port_dn = cd->port_dn[port];
+		port_dn = ds->ports[port].dn;
 		if (of_phy_is_fixed_link(port_dn)) {
 			ret = of_phy_register_fixed_link(port_dn);
 			if (ret) {
@@ -325,6 +324,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * Create network devices for physical switch ports.
 	 */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		ds->ports[i].dn = cd->port_dn[i];
+
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
@@ -424,7 +425,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 {
 	struct device_node *port_dn;
 	struct phy_device *phydev;
-	struct dsa_chip_data *cd = ds->cd;
 	int port;
 
 #ifdef CONFIG_NET_DSA_HWMON
@@ -445,7 +445,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
 	/* Remove any fixed link PHYs */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		port_dn = cd->port_dn[port];
+		port_dn = ds->ports[port].dn;
 		if (of_phy_is_fixed_link(port_dn)) {
 			phydev = of_phy_find_device(port_dn);
 			if (phydev) {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 169abacbc6ce..52f1183c42a0 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -998,13 +998,12 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
 	struct dsa_switch *ds = p->parent;
-	struct dsa_chip_data *cd = ds->cd;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
 	int mode, ret;
 
-	port_dn = cd->port_dn[p->port];
+	port_dn = ds->ports[p->port].dn;
 	mode = of_get_phy_mode(port_dn);
 	if (mode < 0)
 		mode = PHY_INTERFACE_MODE_NA;
@@ -1146,7 +1145,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 				 NULL);
 
 	SET_NETDEV_DEV(slave_dev, parent);
-	slave_dev->dev.of_node = ds->cd->port_dn[port];
+	slave_dev->dev.of_node = ds->ports[port].dn;
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-- 
2.8.1
