From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/5] net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
Date: Mon,  6 Jun 2016 16:14:52 -0700
Message-ID: <1465254895-11152-3-git-send-email-f.fainelli@gmail.com>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36537 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcFFXPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:15:04 -0400
Received: by mail-pf0-f194.google.com with SMTP id 62so18950897pfd.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:15:04 -0700 (PDT)
In-Reply-To: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers rely on these two bitmasks to contain the correct values
for them to successfully probe and initialize at drv->setup() time,
calculate correct values to put in both masks as early as possible in
dsa_get_ports_dn().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 80dfe08db825..5ae45210a936 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -283,6 +283,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 	if (ds->ports[index].netdev) {
 		dsa_slave_destroy(ds->ports[index].netdev);
 		ds->ports[index].netdev = NULL;
+		ds->enabled_port_mask &= ~(1 << index);
 	}
 }
 
@@ -292,6 +293,13 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
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
@@ -304,6 +312,18 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
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
@@ -511,6 +531,13 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 			return -EINVAL;
 
 		ds->ports[reg].dn = port;
+
+		/* Initialize enabled_port_mask now for drv->setup()
+		 * to have access to a correct value, just like what
+		 * net/dsa/dsa.c::dsa_switch_setup_one does.
+		 */
+		if (!dsa_port_is_cpu(port))
+			ds->enabled_port_mask |= 1 << reg;
 	}
 
 	return 0;
-- 
2.7.4
