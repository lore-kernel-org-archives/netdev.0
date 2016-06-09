From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/8] net: dsa: mv88e6xxx: add switch register helpers
Date: Wed,  8 Jun 2016 20:44:53 -0400
Message-ID: <20160609004456.5441-6-vivien.didelot@savoirfairelinux.com>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extract the allocation and registration code related to the dsa_switch
structure in a mv88e6xxx_register_switch helper function.

For symmetry in the code, add a mv88e6xxx_unregister_switch function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 02b0af7..584a6b6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3688,30 +3688,48 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
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
 int mv88e6xxx_probe(struct mdio_device *mdiodev)
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
@@ -3743,9 +3761,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
-	dev_set_drvdata(dev, ds);
-
-	err = dsa_register_switch(ds, np);
+	err = mv88e6xxx_register_switch(ps, np);
 	if (err) {
 		mv88e6xxx_mdio_unregister(ps);
 		return err;
@@ -3762,8 +3778,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	dsa_unregister_switch(ds);
-
+	mv88e6xxx_unregister_switch(ps);
 	mv88e6xxx_mdio_unregister(ps);
 }
 
-- 
2.8.3
