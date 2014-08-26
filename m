From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 06/13] net: dsa: allow for more complex PHY setups
Date: Mon, 25 Aug 2014 21:49:34 -0700
Message-ID: <1409028581-17399-7-git-send-email-f.fainelli@gmail.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:48588 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932142AbaHZEue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 00:50:34 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so21318186pdj.15
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 21:50:33 -0700 (PDT)
In-Reply-To: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify the DSA slave interface to be bound to an arbitray PHY, not just
the ones that are available as child PHY devices of the switch MDIO bus.

This allows us for instance to have external PHYs connected to a
separate MDIO bus, but yet also connected to a given switch port.

Under certain configurations, the physical port mask might not be a 1:1
mapping to the MII PHYs mask. This is the case, if e.g: Port 1 of the
switch is used and connects to a PHY at a MDIO address different than 1.

Introduce a phys_mii_mask variable which allows driver to implement and
divert their own MDIO read/writes operations for a subset of the MDIO
PHY addresses.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v4:
- make more build testing
- changed phy_is_fixed from 'unsigned int' to 'bool' type

Changes in v2:
- introduce phys_mii_mask to allow switch drivers to divert MDIO operations
  for some PHY addresses

- use the latest fixed PHY API
- iron out non-OF setups

 include/net/dsa.h  |  1 +
 net/dsa/dsa.c      |  5 ++++
 net/dsa/dsa_priv.h |  4 +++
 net/dsa/slave.c    | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 597875d3f69e..dc357454ae3b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -130,6 +130,7 @@ struct dsa_switch {
 	 */
 	u32			dsa_port_mask;
 	u32			phys_port_mask;
+	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 	struct net_device	*ports[DSA_MAX_PORTS];
 };
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index e3a1ec109a01..03b0d9221d35 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -144,6 +144,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		goto out;
 	}
 
+	/* Make the built-in MII bus mask match the number of ports,
+	 * switch drivers can override this later
+	 */
+	ds->phys_mii_mask = ds->phys_port_mask;
+
 	/*
 	 * If the CPU connects to this switch, set the switch tree
 	 * tagging protocol to the preferred tagging format of this
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 218d75d16f6f..d20364ac1574 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -33,6 +33,10 @@ struct dsa_slave_priv {
 	 * to this port.
 	 */
 	struct phy_device	*phy;
+	phy_interface_t		phy_interface;
+	int			old_link;
+	int			old_pause;
+	int			old_duplex;
 };
 
 /* dsa.c */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5688c34253e5..03d2894a0f8a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -12,6 +12,8 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/phy.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -19,7 +21,7 @@ static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->phys_port_mask & (1 << addr))
+	if (ds->phys_mii_mask & (1 << addr))
 		return ds->drv->phy_read(ds, addr, reg);
 
 	return 0xffff;
@@ -29,7 +31,7 @@ static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->phys_port_mask & (1 << addr))
+	if (ds->phys_mii_mask & (1 << addr))
 		return ds->drv->phy_write(ds, addr, reg, val);
 
 	return 0;
@@ -312,7 +314,70 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
 
+static void dsa_slave_adjust_link(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	unsigned int status_changed = 0;
+
+	if (p->old_link != p->phy->link) {
+		status_changed = 1;
+		p->old_link = p->phy->link;
+	}
+
+	if (p->old_duplex != p->phy->duplex) {
+		status_changed = 1;
+		p->old_duplex = p->phy->duplex;
+	}
+
+	if (p->old_pause != p->phy->pause) {
+		status_changed = 1;
+		p->old_pause = p->phy->pause;
+	}
+
+	if (status_changed)
+		phy_print_status(p->phy);
+}
+
 /* slave device setup *******************************************************/
+static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
+				struct net_device *slave_dev)
+{
+	struct dsa_switch *ds = p->parent;
+	struct dsa_chip_data *cd = ds->pd;
+	struct device_node *phy_dn, *port_dn;
+	int ret;
+
+	port_dn = cd->port_dn[p->port];
+	p->phy_interface = of_get_phy_mode(port_dn);
+
+	phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
+	if (of_phy_is_fixed_link(port_dn)) {
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the fixed PHY is the Port DT node
+		 */
+		ret = of_phy_register_fixed_link(port_dn);
+		if (ret) {
+			pr_err("failed to register fixed PHY\n");
+			return;
+		}
+		phy_dn = port_dn;
+	}
+
+	if (phy_dn)
+		p->phy = of_phy_connect(slave_dev, phy_dn,
+					dsa_slave_adjust_link, 0,
+					p->phy_interface);
+
+	/* We could not connect to a designated PHY, so use the switch internal
+	 * MDIO bus instead
+	 */
+	if (!p->phy)
+		p->phy = ds->slave_mii_bus->phy_map[p->port];
+	else
+		pr_info("attached PHY at address %d [%s]\n",
+			p->phy->addr, p->phy->drv->name);
+}
+
 struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		 int port, char *name)
@@ -361,7 +426,12 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->dev = slave_dev;
 	p->parent = ds;
 	p->port = port;
-	p->phy = ds->slave_mii_bus->phy_map[port];
+
+	p->old_pause = -1;
+	p->old_link = -1;
+	p->old_duplex = -1;
+
+	dsa_slave_phy_setup(p, slave_dev);
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
-- 
1.9.1
