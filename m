From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 6/7] dsa: Rename switch chip data to cd
Date: Tue, 10 May 2016 23:27:24 +0200
Message-ID: <1462915645-24674-7-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35022 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525AbcEJVbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:31:01 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dsa_switch structure contains a dsa_chip_data member called pd.
However in the rest of the code, pd is used for dsa_platform_data.
This is confusing. Rename it cd, which is already often used in dsa.c
and slave.c for this data type.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/bcm_sf2.c   |  4 ++--
 drivers/net/dsa/mv88e6xxx.c |  4 ++--
 include/net/dsa.h           |  4 ++--
 net/dsa/dsa.c               | 18 +++++++++---------
 net/dsa/slave.c             | 10 +++++-----
 5 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 448deb59b9a4..10ddd5a5dfb6 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -949,8 +949,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	/* All the interesting properties are at the parent device_node
 	 * level
 	 */
-	dn = ds->pd->of_node->parent;
-	bcm_sf2_identify_ports(priv, ds->pd->of_node);
+	dn = ds->cd->of_node->parent;
+	bcm_sf2_identify_ports(priv, ds->cd->of_node);
 
 	priv->irq0 = irq_of_parse_and_map(dn, 0);
 	priv->irq1 = irq_of_parse_and_map(dn, 1);
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 428d213ed4fc..c41ec38613c7 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3009,9 +3009,9 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	for (i = 0; i < 32; i++) {
 		int nexthop = 0x1f;
 
-		if (ps->ds->pd->rtable &&
+		if (ps->ds->cd->rtable &&
 		    i != ps->ds->index && i < ps->ds->dst->pd->nr_chips)
-			nexthop = ps->ds->pd->rtable[i] & 0x1f;
+			nexthop = ps->ds->cd->rtable[i] & 0x1f;
 
 		err = _mv88e6xxx_reg_write(
 			ps, REG_GLOBAL2,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index f4c0bff8d9d6..17c3d37b6779 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -137,7 +137,7 @@ struct dsa_switch {
 	/*
 	 * Configuration data for this switch.
 	 */
-	struct dsa_chip_data	*pd;
+	struct dsa_chip_data	*cd;
 
 	/*
 	 * The used switch driver.
@@ -190,7 +190,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 	if (dst->cpu_switch == ds->index)
 		return dst->cpu_port;
 	else
-		return ds->pd->rtable[dst->cpu_switch];
+		return ds->cd->rtable[dst->cpu_switch];
 }
 
 struct switchdev_trans;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5db779c69a68..eff5dfc2e33f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -182,7 +182,7 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 /* basic switch operations **************************************************/
 static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
 {
-	struct dsa_chip_data *cd = ds->pd;
+	struct dsa_chip_data *cd = ds->cd;
 	struct device_node *port_dn;
 	struct phy_device *phydev;
 	int ret, port, mode;
@@ -219,7 +219,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
 	struct dsa_switch_tree *dst = ds->dst;
-	struct dsa_chip_data *pd = ds->pd;
+	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
 	int index = ds->index;
 	int i, ret;
@@ -230,7 +230,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		char *name;
 
-		name = pd->port_names[i];
+		name = cd->port_names[i];
 		if (name == NULL)
 			continue;
 
@@ -328,10 +328,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
 
-		ret = dsa_slave_create(ds, parent, i, pd->port_names[i]);
+		ret = dsa_slave_create(ds, parent, i, cd->port_names[i]);
 		if (ret < 0) {
 			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
-				   index, i, pd->port_names[i], ret);
+				   index, i, cd->port_names[i], ret);
 			ret = 0;
 		}
 	}
@@ -379,7 +379,7 @@ static struct dsa_switch *
 dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		 struct device *parent, struct device *host_dev)
 {
-	struct dsa_chip_data *pd = dst->pd->chip + index;
+	struct dsa_chip_data *cd = dst->pd->chip + index;
 	struct dsa_switch_driver *drv;
 	struct dsa_switch *ds;
 	int ret;
@@ -389,7 +389,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Probe for switch model.
 	 */
-	drv = dsa_switch_probe(parent, host_dev, pd->sw_addr, &name, &priv);
+	drv = dsa_switch_probe(parent, host_dev, cd->sw_addr, &name, &priv);
 	if (drv == NULL) {
 		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
 			   index);
@@ -408,7 +408,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 	ds->dst = dst;
 	ds->index = index;
-	ds->pd = pd;
+	ds->cd = cd;
 	ds->drv = drv;
 	ds->priv = priv;
 	ds->dev = parent;
@@ -424,7 +424,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 {
 	struct device_node *port_dn;
 	struct phy_device *phydev;
-	struct dsa_chip_data *cd = ds->pd;
+	struct dsa_chip_data *cd = ds->cd;
 	int port;
 
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f25dcd9e814a..152436cdab30 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -50,7 +50,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
 	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
-			ds->index, ds->pd->sw_addr);
+			ds->index, ds->cd->sw_addr);
 	ds->slave_mii_bus->parent = ds->dev;
 	ds->slave_mii_bus->phy_mask = ~ds->phys_mii_mask;
 }
@@ -615,8 +615,8 @@ static int dsa_slave_get_eeprom_len(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->pd->eeprom_len)
-		return ds->pd->eeprom_len;
+	if (ds->cd->eeprom_len)
+		return ds->cd->eeprom_len;
 
 	if (ds->drv->get_eeprom_len)
 		return ds->drv->get_eeprom_len(ds);
@@ -999,7 +999,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
 	struct dsa_switch *ds = p->parent;
-	struct dsa_chip_data *cd = ds->pd;
+	struct dsa_chip_data *cd = ds->cd;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
@@ -1147,7 +1147,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 				 NULL);
 
 	SET_NETDEV_DEV(slave_dev, parent);
-	slave_dev->dev.of_node = ds->pd->port_dn[port];
+	slave_dev->dev.of_node = ds->cd->port_dn[port];
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-- 
2.8.1
