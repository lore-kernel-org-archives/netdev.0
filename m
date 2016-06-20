From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 05/14] net: dsa: mv88e6xxx: add switch register helpers
Date: Mon, 20 Jun 2016 12:03:28 -0400
Message-ID: <20160620160337.2934-6-vivien.didelot@savoirfairelinux.com>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46002 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888AbcFTQOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 12:14:49 -0400
In-Reply-To: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mixed assignments, allocations and registrations in the probe code
make it hard to follow the logic and figure out what is DSA or chip
specific.

Extract the struct dsa_switch related code in a simple
mv88e6xxx_register_switch helper function.

For symmetry in the code, add a mv88e6xxx_unregister_switch function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4b4bffc..ad7735d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3690,30 +3690,48 @@ static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
+static int mv88e6xxx_register_switch(struct mv88e6xxx_priv_state *ps,
+				     struct device_node *np)
+{
+	struct device *dev = ps->dev;
+	struct dsa_switch *ds;
+
+	ds = devm_kzalloc(dev, sizeof(*ds), GFP_KERNEL);
+	if (!ds)
+		return -ENOMEM;
+
+	ds->dev = dev;
+	ds->priv = ps;
+	ds->drv = &mv88e6xxx_switch_driver;
+
+	dev_set_drvdata(dev, ds);
+
+	return dsa_register_switch(ds, np);
+}
+
+static void mv88e6xxx_unregister_switch(struct mv88e6xxx_priv_state *ps)
+{
+	dsa_unregister_switch(ps->ds);
+}
+
 static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
 	struct mv88e6xxx_priv_state *ps;
 	int id, prod_num, rev;
-	struct dsa_switch *ds;
 	u32 eeprom_len;
 	int err;
 
-	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
-	if (!ds)
+	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
 		return -ENOMEM;
 
-	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
-	ds->priv = ps;
-	ds->dev = dev;
 	ps->dev = dev;
 	ps->bus = mdiodev->bus;
 	ps->sw_addr = mdiodev->addr;
 	mutex_init(&ps->smi_mutex);
 
-	ds->drv = &mv88e6xxx_switch_driver;
-
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
 		return id;
@@ -3745,9 +3763,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
-	dev_set_drvdata(dev, ds);
-
-	err = dsa_register_switch(ds, np);
+	err = mv88e6xxx_register_switch(ps, np);
 	if (err) {
 		mv88e6xxx_mdio_unregister(ps);
 		return err;
@@ -3764,8 +3780,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	dsa_unregister_switch(ds);
-
+	mv88e6xxx_unregister_switch(ps);
 	mv88e6xxx_mdio_unregister(ps);
 }
 
-- 
2.9.0
