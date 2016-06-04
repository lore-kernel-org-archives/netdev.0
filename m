From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/9] net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
Date: Fri,  3 Jun 2016 17:05:26 -0700
Message-ID: <1464998733-10405-7-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35351 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbcFDAFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:53 -0400
Received: by mail-pa0-f68.google.com with SMTP id gp3so6932569pac.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:52 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers heavily rely on these two bitmasks to contain the correct
values for them to successfully probe and initialize at drv->setup()
time, calculate correct values to put in both masks.

To avoid multiple ports lookup, we also try to set dst->cpu_port during
dsa_parse_ports_dn(), which is mostly useful for the case where we probe
using the legacy binding which has properties/nodes in different places
and does not use dsa_dst_parse().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 47 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 23273fd984a8..e8386157de30 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -281,6 +281,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 	if (ds->ports[index].netdev) {
 		dsa_slave_destroy(ds->ports[index].netdev);
 		ds->ports[index].netdev = NULL;
+		ds->enabled_port_mask &= ~(1 << index);
 	}
 }
 
@@ -290,6 +291,13 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	u32 index;
 	int err;
 
+	/* Initialize ds->phys_mii_mask before registering the slave MDIO bus
+	 * driver and before drv->setup() has run, since the switch drivers and
+	 * the slave MDIO bus driver rely on these values for probing PHY
+	 * devices or not
+	 */
+	ds->phys_mii_mask = ds->enabled_port_mask;
+
 	err = ds->drv->setup(ds);
 	if (err < 0)
 		return err;
@@ -302,6 +310,18 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err < 0)
 		return err;
 
+	if (!ds->slave_mii_bus && ds->drv->phy_read) {
+		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
+		if (!ds->slave_mii_bus)
+			return err;
+
+		dsa_slave_mii_bus_init(ds);
+
+		err = mdiobus_register(ds->slave_mii_bus);
+		if (err < 0)
+			return err;
+	}
+
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
 		port = ds->ports[index].dn;
 		if (!port)
@@ -421,7 +441,11 @@ static int _dsa_cpu_parse(struct dsa_switch_tree *dst,
 
 	if (dst->cpu_switch == -1) {
 		dst->cpu_switch = ds->index;
-		dst->cpu_port = index;
+		/* Only assign dst->cpu_port if not done already by
+		 * dsa_parse_ports_dn
+		 */
+		if (!dst->cpu_port)
+			dst->cpu_port = index;
 	}
 
 	dst->tag_ops = dsa_resolve_tag_protocol(ds->drv->tag_protocol);
@@ -517,6 +541,15 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 			return -EINVAL;
 
 		ds->ports[reg].dn = port;
+
+		if (dsa_port_is_cpu(port))
+			ds->dst->cpu_port = reg;
+		else
+			/* Initialize enabled_port_mask now for drv->setup()
+			 * to have access to a correct value, just like what
+			 * net/dsa/dsa.c::dsa_switch_setup_one does.
+			 */
+			ds->enabled_port_mask |= 1 << reg;
 	}
 
 	return 0;
@@ -585,10 +618,6 @@ static int _dsa_register_switch_legacy(struct dsa_switch *ds, struct device_node
 	if (index >= DSA_MAX_SWITCHES)
 		return -EINVAL;
 
-	err = dsa_parse_ports_dn(np->child, ds);
-	if (err)
-		return err;
-
 	dst = dsa_get_dst(tree);
 	if (!dst) {
 		dst = dsa_add_dst(tree);
@@ -596,12 +625,17 @@ static int _dsa_register_switch_legacy(struct dsa_switch *ds, struct device_node
 			return -ENOMEM;
 	}
 
+	ds->dst = dst;
+
+	err = dsa_parse_ports_dn(np->child, ds);
+	if (err)
+		return err;
+
 	if (dst->ds[index]) {
 		err = -EBUSY;
 		goto out;
 	}
 
-	ds->dst = dst;
 	ds->index = index;
 	dsa_dst_add_ds(dst, ds, index);
 
@@ -633,7 +667,7 @@ static int _dsa_register_switch_legacy(struct dsa_switch *ds, struct device_node
 		goto out_del_dst;
 	}
 
-	err = _dsa_cpu_parse(dst, ds, ethernet_dev, index);
+	err = _dsa_cpu_parse(dst, ds, ethernet_dev, dst->cpu_port);
 	if (err)
 		goto out_del_dst;
 
@@ -676,10 +710,6 @@ static int __dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 	if (IS_ERR(ports))
 		return PTR_ERR(ports);
 
-	err = dsa_parse_ports_dn(ports, ds);
-	if (err)
-		return err;
-
 	dst = dsa_get_dst(tree);
 	if (!dst) {
 		dst = dsa_add_dst(tree);
@@ -687,12 +717,17 @@ static int __dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 			return -ENOMEM;
 	}
 
+	ds->dst = dst;
+
+	err = dsa_parse_ports_dn(ports, ds);
+	if (err)
+		return err;
+
 	if (dst->ds[index]) {
 		err = -EBUSY;
 		goto out;
 	}
 
-	ds->dst = dst;
 	ds->index = index;
 	dsa_dst_add_ds(dst, ds, index);
 
-- 
2.7.4
