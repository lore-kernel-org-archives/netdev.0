From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 6/7] dsa: Rename phys_port_mask to enabled_port_mask
Date: Wed, 13 Apr 2016 02:40:44 +0200
Message-ID: <1460508045-20254-7-git-send-email-andrew@lunn.ch>
References: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54353 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757189AbcDMAmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 20:42:49 -0400
In-Reply-To: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phys in phys_port_mask suggests this mask is about PHYs. In fact,
it means physical ports. Rename to enabled_port_mask, indicating
external enabled ports of the switch, which is hopefully less
confusing.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
v2:
    s/user_port_mask/enabled_port_mask/g
---
 drivers/net/dsa/bcm_sf2.c   | 19 ++++++++++---------
 drivers/net/dsa/mv88e6060.c |  2 +-
 include/net/dsa.h           |  4 ++--
 net/dsa/dsa.c               |  8 ++++----
 4 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 50caa525cda3..7a5f0ef46bd6 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -160,7 +160,7 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 	 * the same VLAN.
 	 */
 	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		if (!((1 << i) & ds->phys_port_mask))
+		if (!((1 << i) & ds->enabled_port_mask))
 			continue;
 
 		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
@@ -1009,7 +1009,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	/* Enable all valid ports and disable those unused */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
 		/* IMP port receives special treatment */
-		if ((1 << port) & ds->phys_port_mask)
+		if ((1 << port) & ds->enabled_port_mask)
 			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
@@ -1022,11 +1022,12 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
 	 * that we can use the regular SWITCH_MDIO master controller instead.
 	 *
-	 * By default, DSA initializes ds->phys_mii_mask to ds->phys_port_mask
-	 * to have a 1:1 mapping between Port address and PHY address in order
-	 * to utilize the slave_mii_bus instance to read from Port PHYs. This is
-	 * not what we want here, so we initialize phys_mii_mask 0 to always
-	 * utilize the "master" MDIO bus backed by the "mdio-unimac" driver.
+	 * By default, DSA initializes ds->phys_mii_mask to
+	 * ds->enabled_port_mask to have a 1:1 mapping between Port address
+	 * and PHY address in order to utilize the slave_mii_bus instance to
+	 * read from Port PHYs. This is not what we want here, so we
+	 * initialize phys_mii_mask 0 to always utilize the "master" MDIO
+	 * bus backed by the "mdio-unimac" driver.
 	 */
 	if (of_machine_is_compatible("brcm,bcm7445d0"))
 		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
@@ -1284,7 +1285,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	 * bcm_sf2_sw_setup
 	 */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if ((1 << port) & ds->phys_port_mask ||
+		if ((1 << port) & ds->enabled_port_mask ||
 		    dsa_is_cpu_port(ds, port))
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
@@ -1308,7 +1309,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 		bcm_sf2_gphy_enable_set(ds, true);
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if ((1 << port) & ds->phys_port_mask)
+		if ((1 << port) & ds->enabled_port_mask)
 			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index adb608ccd9aa..92cebab9383e 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -170,7 +170,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	REG_WRITE(addr, PORT_VLAN_MAP,
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
-			ds->phys_port_mask :
+			ds->enabled_port_mask :
 			BIT(ds->dst->cpu_port)));
 
 	/* Port Association Vector: when learning source addresses
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 165c2e10615c..689ebd3542ba 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -167,7 +167,7 @@ struct dsa_switch {
 	 * Slave mii_bus and devices for the individual ports.
 	 */
 	u32			dsa_port_mask;
-	u32			phys_port_mask;
+	u32			enabled_port_mask;
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 	struct net_device	*ports[DSA_MAX_PORTS];
@@ -185,7 +185,7 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 
 static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
-	return ds->phys_port_mask & (1 << p) && ds->ports[p];
+	return ds->enabled_port_mask & (1 << p) && ds->ports[p];
 }
 
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 14bf12f637d2..60ea98481806 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -246,7 +246,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
 		} else {
-			ds->phys_port_mask |= 1 << i;
+			ds->enabled_port_mask |= 1 << i;
 		}
 		valid_name_found = true;
 	}
@@ -259,7 +259,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	/* Make the built-in MII bus mask match the number of ports,
 	 * switch drivers can override this later
 	 */
-	ds->phys_mii_mask = ds->phys_port_mask;
+	ds->phys_mii_mask = ds->enabled_port_mask;
 
 	/*
 	 * If the CPU connects to this switch, set the switch tree
@@ -325,7 +325,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * Create network devices for physical switch ports.
 	 */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		if (!(ds->phys_port_mask & (1 << i)))
+		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
 		ret = dsa_slave_create(ds, parent, i, pd->port_names[i]);
@@ -435,7 +435,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
 	/* Destroy network devices for physical switch ports. */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if (!(ds->phys_port_mask & (1 << port)))
+		if (!(ds->enabled_port_mask & (1 << port)))
 			continue;
 
 		if (!ds->ports[port])
-- 
2.7.0
