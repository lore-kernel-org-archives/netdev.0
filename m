From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 3/8] net: dsa: mv88e6xxx: read switch ID in probe
Date: Sat, 16 Apr 2016 18:41:40 -0400
Message-ID: <1460846505-20305-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Read the switch ID only once, at probe time, to avoid multiple read
accesses and MII bus checking.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 54 +++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b63e985..af5ae70 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2667,8 +2667,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	ps->ds = ds;
 	mutex_init(&ps->smi_mutex);
 
-	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
-
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	return 0;
@@ -3068,21 +3066,14 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
+static char *mv88e6xxx_lookup_name(unsigned int id,
 				   const struct mv88e6xxx_switch_id *table,
 				   unsigned int num)
 {
-	int i, ret;
-
-	if (!bus)
-		return NULL;
-
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret < 0)
-		return NULL;
+	int i;
 
 	for (i = 0; i < num; ++i)
-		if (table[i].id == (ret & 0xfff0))
+		if (table[i].id == (id & 0xfff0))
 			return table[i].name;
 
 	return NULL;
@@ -3094,23 +3085,38 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 			  unsigned int num)
 {
 	struct mv88e6xxx_priv_state *ps;
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mii_bus *bus;
+	int id, prod_num, rev;
 	char *name;
 
+	bus = dsa_host_dev_to_mii_bus(host_dev);
 	if (!bus)
 		return NULL;
 
-	name = mv88e6xxx_lookup_name(bus, sw_addr, table, num);
-	if (name) {
-		ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
-		if (!ps)
-			return NULL;
-		*priv = ps;
-		ps->bus = dsa_host_dev_to_mii_bus(host_dev);
-		if (!ps->bus)
-			return NULL;
-		ps->sw_addr = sw_addr;
-	}
+	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	if (id < 0)
+		return NULL;
+
+	prod_num = (id & 0xfff0) >> 4;
+	rev = id & 0x000f;
+
+	name = mv88e6xxx_lookup_name(id, table, num);
+	if (!name)
+		return NULL;
+
+	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
+		return NULL;
+
+	ps->bus = bus;
+	ps->sw_addr = sw_addr;
+	ps->id = id & 0xfff0;
+
+	*priv = ps;
+
+	dev_info(&ps->bus->dev, "switch 0x%x probed: %s, revision %u\n",
+		 prod_num, name, rev);
+
 	return name;
 }
 
-- 
2.8.0
