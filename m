From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 11/14] net: dsa: mv88e6xxx: add detection helper
Date: Mon, 20 Jun 2016 12:03:34 -0400
Message-ID: <20160620160337.2934-12-vivien.didelot@savoirfairelinux.com>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extract the common detection code which assigns the info structure to
the chip given the read switch ID.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 64 +++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 34 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4e24ac5..de92add 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3601,6 +3601,30 @@ static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
 	return NULL;
 }
 
+static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
+{
+	const struct mv88e6xxx_info *info;
+	int id, prod_num, rev;
+
+	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
+	if (id < 0)
+		return id;
+
+	prod_num = (id & 0xfff0) >> 4;
+	rev = id & 0x000f;
+
+	info = mv88e6xxx_lookup_info(prod_num);
+	if (!info)
+		return -ENODEV;
+
+	ps->info = info;
+
+	dev_info(ps->dev, "switch 0x%x detected: %s, revision %u\n",
+		 ps->info->prod_num, ps->info->name, rev);
+
+	return 0;
+}
+
 static struct mv88e6xxx_priv_state *mv88e6xxx_alloc_chip(struct device *dev)
 {
 	struct mv88e6xxx_priv_state *ps;
@@ -3633,11 +3657,8 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
 {
-	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
 	struct mii_bus *bus;
-	const char *name;
-	int id, prod_num, rev;
 	int err;
 
 	bus = dsa_host_dev_to_mii_bus(host_dev);
@@ -3652,31 +3673,17 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (err)
 		goto free;
 
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
-	if (id < 0)
-		goto free;
-
-	prod_num = (id & 0xfff0) >> 4;
-	rev = id & 0x000f;
-
-	info = mv88e6xxx_lookup_info(prod_num);
-	if (!info)
+	err = mv88e6xxx_detect(ps);
+	if (err)
 		goto free;
 
-	name = info->name;
-
-	ps->info = info;
-
 	err = mv88e6xxx_mdio_register(ps, NULL);
 	if (err)
 		goto free;
 
 	*priv = ps;
 
-	dev_info(&ps->bus->dev, "switch 0x%x probed: %s, revision %u\n",
-		 prod_num, name, rev);
-
-	return name;
+	return ps->info->name;
 free:
 	devm_kfree(dsa_dev, ps);
 
@@ -3748,7 +3755,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
 	struct mv88e6xxx_priv_state *ps;
-	int id, prod_num, rev;
 	u32 eeprom_len;
 	int err;
 
@@ -3760,16 +3766,9 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
-	if (id < 0)
-		return id;
-
-	prod_num = (id & 0xfff0) >> 4;
-	rev = id & 0x000f;
-
-	ps->info = mv88e6xxx_lookup_info(prod_num);
-	if (!ps->info)
-		return -ENODEV;
+	err = mv88e6xxx_detect(ps);
+	if (err)
+		return err;
 
 	ps->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
 	if (IS_ERR(ps->reset))
@@ -3789,9 +3788,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		return err;
 	}
 
-	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
-		 prod_num, ps->info->name, rev);
-
 	return 0;
 }
 
-- 
2.9.0
