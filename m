From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/8] net: dsa: mv88e6xxx: add chip detection helper
Date: Wed,  8 Jun 2016 20:44:54 -0400
Message-ID: <20160609004456.5441-7-vivien.didelot@savoirfairelinux.com>
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

Extract the common code to read the switch ID and allocate the private
chip data, found in both legacy and new MDIO probe functions, into its
own mv88e6xxx_detect helper to reduce boiler plate.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 68 +++++++++++++++++++--------------------------
 1 file changed, 29 insertions(+), 39 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 584a6b6..28070e5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3601,20 +3601,13 @@ mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
 	return NULL;
 }
 
-static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
-				       struct device *host_dev, int sw_addr,
-				       void **priv)
+static struct mv88e6xxx_priv_state *mv88e6xxx_detect(struct device *dev,
+						     struct mii_bus *bus,
+						     int sw_addr)
 {
 	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
-	struct mii_bus *bus;
-	const char *name;
 	int id, prod_num, rev;
-	int err;
-
-	bus = dsa_host_dev_to_mii_bus(host_dev);
-	if (!bus)
-		return NULL;
 
 	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
@@ -3628,28 +3621,46 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!info)
 		return NULL;
 
-	name = info->name;
+	dev_info(dev, "switch 0x%x detected: %s, revision %u\n", prod_num,
+		 info->name, rev);
 
-	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
+	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
 	if (!ps)
 		return NULL;
 
+	ps->dev = dev;
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 	ps->info = info;
-	ps->dev = dsa_dev;
+
 	mutex_init(&ps->smi_mutex);
 
+	return ps;
+}
+
+static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
+				       struct device *host_dev, int sw_addr,
+				       void **priv)
+{
+	struct mv88e6xxx_priv_state *ps;
+	struct mii_bus *bus;
+	int err;
+
+	bus = dsa_host_dev_to_mii_bus(host_dev);
+	if (!bus)
+		return NULL;
+
+	ps = mv88e6xxx_detect(dsa_dev, bus, sw_addr);
+	if (!ps)
+		return NULL;
+
 	err = mv88e6xxx_mdio_register(ps, NULL);
 	if (err)
 		return NULL;
 
 	*priv = ps;
 
-	dev_info(&ps->bus->dev, "switch 0x%x probed: %s, revision %u\n",
-		 prod_num, name, rev);
-
-	return name;
+	return ps->info->name;
 }
 
 struct dsa_switch_driver mv88e6xxx_switch_driver = {
@@ -3717,29 +3728,11 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
 	struct mv88e6xxx_priv_state *ps;
-	int id, prod_num, rev;
 	u32 eeprom_len;
 	int err;
 
-	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+	ps = mv88e6xxx_detect(dev, mdiodev->bus, mdiodev->addr);
 	if (!ps)
-		return -ENOMEM;
-
-	ps->dev = dev;
-	ps->bus = mdiodev->bus;
-	ps->sw_addr = mdiodev->addr;
-	mutex_init(&ps->smi_mutex);
-
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
-	if (id < 0)
-		return id;
-
-	prod_num = (id & 0xfff0) >> 4;
-	rev = id & 0x000f;
-
-	ps->info = mv88e6xxx_lookup_info(prod_num, mv88e6xxx_table,
-					 ARRAY_SIZE(mv88e6xxx_table));
-	if (!ps->info)
 		return -ENODEV;
 
 	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
@@ -3767,9 +3760,6 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		return err;
 	}
 
-	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
-		 prod_num, ps->info->name, rev);
-
 	return 0;
 }
 
-- 
2.8.3
