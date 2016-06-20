From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 09/14] net: dsa: mv88e6xxx: add chip allocation helper
Date: Mon, 20 Jun 2016 12:03:32 -0400
Message-ID: <20160620160337.2934-10-vivien.didelot@savoirfairelinux.com>
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

Add an helper function to allocate the chip structure at the beginning
of the probe functions. It will be used to initialize the SMI access.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2c86172..113092a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3601,6 +3601,21 @@ static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
 	return NULL;
 }
 
+static struct mv88e6xxx_priv_state *mv88e6xxx_alloc_chip(struct device *dev)
+{
+	struct mv88e6xxx_priv_state *ps;
+
+	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
+		return NULL;
+
+	ps->dev = dev;
+
+	mutex_init(&ps->reg_lock);
+
+	return ps;
+}
+
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
@@ -3616,32 +3631,30 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!bus)
 		return NULL;
 
+	ps = mv88e6xxx_alloc_chip(dsa_dev);
+	if (!ps)
+		return NULL;
+
 	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
-		return NULL;
+		goto free;
 
 	prod_num = (id & 0xfff0) >> 4;
 	rev = id & 0x000f;
 
 	info = mv88e6xxx_lookup_info(prod_num);
 	if (!info)
-		return NULL;
+		goto free;
 
 	name = info->name;
 
-	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
-	if (!ps)
-		return NULL;
-
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 	ps->info = info;
-	ps->dev = dsa_dev;
-	mutex_init(&ps->reg_lock);
 
 	err = mv88e6xxx_mdio_register(ps, NULL);
 	if (err)
-		return NULL;
+		goto free;
 
 	*priv = ps;
 
@@ -3649,6 +3662,10 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 		 prod_num, name, rev);
 
 	return name;
+free:
+	devm_kfree(dsa_dev, ps);
+
+	return NULL;
 }
 
 static struct dsa_switch_driver mv88e6xxx_switch_driver = {
@@ -3720,14 +3737,12 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	u32 eeprom_len;
 	int err;
 
-	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+	ps = mv88e6xxx_alloc_chip(dev);
 	if (!ps)
 		return -ENOMEM;
 
-	ps->dev = dev;
 	ps->bus = mdiodev->bus;
 	ps->sw_addr = mdiodev->addr;
-	mutex_init(&ps->reg_lock);
 
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
-- 
2.9.0
