From: Rodolfo Giometti <giometti@linux.it>
Subject: [PATCH] net dsa: add per port phy address mapping
Date: Mon, 15 Oct 2012 15:33:25 +0200
Message-ID: <1350308008-17189-1-git-send-email-giometti@linux.it>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Rodolfo Giometti <giometti@linux.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-196-116.sn1.eutelia.it ([62.94.196.116]:13952 "EHLO
	goldrake.enneenne.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753352Ab2JONyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 09:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some circumstances ports' phy addresses must be remapped in a custom
manner (i.e. when phys have multiple MDIO addresses).

Compatibility with old behaviour is kept by using a special flag named
"port_phy_remap" which must be set to 1 in order to enable remapping
defined into "port_phy_addr" array.

Signed-off-by: Rodolfo Giometti <giometti@linux.it>
---
 include/net/dsa.h  |   11 +++++++++++
 net/dsa/dsa.c      |    3 ++-
 net/dsa/dsa_priv.h |    3 ++-
 net/dsa/slave.c    |   25 +++++++++++++++----------
 4 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7828ebf..ff07a86 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -36,6 +36,17 @@ struct dsa_chip_data {
 	char		*port_names[DSA_MAX_PORTS];
 
 	/*
+	 * The MDIO address of the phy connected to each port.
+	 * Set port_phy_remap = 1 in order to activate the remap otherwise
+	 * is assumed that phy on port0 has address 0x0, phy on port1 has
+	 * address 0x1 and so on...
+	 * Note that for ports marked as "cpu" or "dsa" these fields are
+	 * ignored.
+	 */
+	unsigned long	port_phy_remap:1;
+	int		port_phy_addr[DSA_MAX_PORTS];
+
+	/*
 	 * An array (with nr_chips elements) of which element [a]
 	 * indicates which port on this switch should be used to
 	 * send packets to that are destined for switch a.  Can be
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 88e7c2f..a7f6fa2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -175,7 +175,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		if (!(ds->phys_port_mask & (1 << i)))
 			continue;
 
-		slave_dev = dsa_slave_create(ds, parent, i, pd->port_names[i]);
+		slave_dev = dsa_slave_create(ds, parent, i, pd->port_names[i],
+				pd->port_phy_remap ? pd->port_phy_addr[i] : i);
 		if (slave_dev == NULL) {
 			printk(KERN_ERR "%s[%d]: can't create dsa "
 			       "slave device for port %d(%s)\n",
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d4cf5cc..7bf1876 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -42,7 +42,8 @@ extern char dsa_driver_version[];
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    struct device *parent,
-				    int port, char *name);
+				    int port, char *name,
+				    int phy_addr);
 
 /* tag_dsa.c */
 netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e32083d..4286964 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -19,20 +19,25 @@ static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->phys_port_mask & (1 << addr))
-		return ds->drv->phy_read(ds, addr, reg);
-
-	return 0xffff;
+	/*
+	 * if port_phy_remap is not enabled when can use old sanity check:
+	 *
+	 *	if (ds->phys_port_mask & (1 << port))
+	 *
+	 * but if port_phy_remap is enabled we should find port<-->addr
+	 * mapping by looking into port_phy_addr array... that why I dropped
+	 * any sanity checks here (real kernel programmers should know what
+	 * they do! ;) - Rodolfo Giometti
+	 */
+	return ds->drv->phy_read(ds, addr, reg);
 }
 
 static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
 	struct dsa_switch *ds = bus->priv;
 
-	if (ds->phys_port_mask & (1 << addr))
-		return ds->drv->phy_write(ds, addr, reg, val);
-
-	return 0;
+	/* See comment in function dsa_slave_phy_read() above */
+	return ds->drv->phy_write(ds, addr, reg, val);
 }
 
 void dsa_slave_mii_bus_init(struct dsa_switch *ds)
@@ -333,7 +338,7 @@ static const struct net_device_ops trailer_netdev_ops = {
 /* slave device setup *******************************************************/
 struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		 int port, char *name)
+		 int port, char *name, int phy_addr)
 {
 	struct net_device *master = ds->dst->master_netdev;
 	struct net_device *slave_dev;
@@ -377,7 +382,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->dev = slave_dev;
 	p->parent = ds;
 	p->port = port;
-	p->phy = ds->slave_mii_bus->phy_map[port];
+	p->phy = ds->slave_mii_bus->phy_map[phy_addr];
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
-- 
1.7.9.5
