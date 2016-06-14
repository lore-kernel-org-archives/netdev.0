From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 09/12] net: dsa: mv88e6xxx: add SMI detection helper
Date: Tue, 14 Jun 2016 14:31:50 -0400
Message-ID: <20160614183153.32327-10-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extract the allocation and switch ID reading code used by both legacy
and new probing into an helper function which uses a info structure to
describe how to access the switch ID register.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 74 ++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 42 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8ac9f9a..2f36d01 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3631,22 +3631,15 @@ mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
 	return NULL;
 }
 
-static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
-				       struct device *host_dev, int sw_addr,
-				       void **priv)
+static struct mv88e6xxx_priv_state *
+mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
+		     const struct mv88e6xxx_info *info)
 {
-	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
-	struct mii_bus *bus;
-	const char *name;
 	int id, prod_num, rev;
-	int err;
 
-	bus = dsa_host_dev_to_mii_bus(host_dev);
-	if (!bus)
-		return NULL;
-
-	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	id = __mv88e6xxx_reg_read(bus, sw_addr, info->port_base_addr,
+				  PORT_SWITCH_ID);
 	if (id < 0)
 		return NULL;
 
@@ -3658,28 +3651,46 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
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
+	ps = mv88e6xxx_smi_detect(dsa_dev, bus, sw_addr, &mv88e6xxx_table[0]);
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
 
 static struct dsa_switch_driver mv88e6xxx_switch_driver = {
@@ -3749,35 +3760,17 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	const struct of_device_id *of_id;
 	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
-	int id, prod_num, rev;
 	u32 eeprom_len;
 	int err;
 
-	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
-	if (!ps)
-		return -ENOMEM;
-
-	ps->dev = dev;
-	ps->bus = mdiodev->bus;
-	ps->sw_addr = mdiodev->addr;
-	mutex_init(&ps->smi_mutex);
-
 	of_id = of_match_node(mv88e6xxx_of_id_table, np);
 	if (!of_id)
 		return -EINVAL;
 
 	info = (const struct mv88e6xxx_info *)of_id->data;
 
-	id = mv88e6xxx_reg_read(ps, info->port_base_addr, PORT_SWITCH_ID);
-	if (id < 0)
-		return id;
-
-	prod_num = (id & 0xfff0) >> 4;
-	rev = id & 0x000f;
-
-	ps->info = mv88e6xxx_lookup_info(prod_num, mv88e6xxx_table,
-					 ARRAY_SIZE(mv88e6xxx_table));
-	if (!ps->info)
+	ps = mv88e6xxx_smi_detect(dev, mdiodev->bus, mdiodev->addr, info);
+	if (!ps)
 		return -ENODEV;
 
 	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
@@ -3805,9 +3798,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		return err;
 	}
 
-	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
-		 prod_num, ps->info->name, rev);
-
 	return 0;
 }
 
-- 
2.8.3
