From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v4 4/9] net: dsa: mv88e6xxx: read switch ID in probe
Date: Sun, 17 Apr 2016 13:23:58 -0400
Message-ID: <1460913843-7459-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49702 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbcDQRYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 13:24:25 -0400
In-Reply-To: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read the switch ID only once, at probe time, to avoid multiple read
accesses and MII bus checking.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 57 ++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 469d8a3..49f085a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2700,10 +2700,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	ps->ds = ds;
 	mutex_init(&ps->smi_mutex);
 
-	ps->id = mv88e6xxx_reg_read(ds, REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
-	if (ps->id < 0)
-		return ps->id;
-
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	return 0;
@@ -3174,21 +3170,13 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 #endif /* CONFIG_NET_DSA_HWMON */
 
 static const char *
-mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
-		      const struct mv88e6xxx_switch_id *table,
+mv88e6xxx_lookup_name(unsigned int id, const struct mv88e6xxx_switch_id *table,
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
@@ -3200,23 +3188,38 @@ const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 				unsigned int num)
 {
 	struct mv88e6xxx_priv_state *ps;
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	struct mii_bus *bus;
 	const char *name;
+	int id, prod_num, rev;
 
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
