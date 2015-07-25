From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code to mv88e6xxx.c
Date: Sat, 25 Jul 2015 09:42:28 -0700
Message-ID: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:38575 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbbGYQmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 12:42:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the temperature sensing code for mv88e6352 and mv88e6320 families
into mv88e6xxx.c to simplify adding support for additional chips.

With this change, mv88e6xxx_6320_family() no longer needs to be
a global function and is made static.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c |  72 +-----------------
 drivers/net/dsa/mv88e6xxx.c | 176 ++++++++++++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx.h |   7 +-
 3 files changed, 136 insertions(+), 119 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cfece5ae9d5f..af210efecc55 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -92,70 +92,6 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-#ifdef CONFIG_NET_DSA_HWMON
-
-static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
-{
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
-	int ret;
-
-	*temp = 0;
-
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 27);
-	if (ret < 0)
-		return ret;
-
-	*temp = (ret & 0xff) - 25;
-
-	return 0;
-}
-
-static int mv88e6352_get_temp_limit(struct dsa_switch *ds, int *temp)
-{
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
-	int ret;
-
-	*temp = 0;
-
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
-	if (ret < 0)
-		return ret;
-
-	*temp = (((ret >> 8) & 0x1f) * 5) - 25;
-
-	return 0;
-}
-
-static int mv88e6352_set_temp_limit(struct dsa_switch *ds, int temp)
-{
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
-	int ret;
-
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
-	if (ret < 0)
-		return ret;
-	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
-	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
-					(ret & 0xe0ff) | (temp << 8));
-}
-
-static int mv88e6352_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
-{
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
-	int ret;
-
-	*alarm = false;
-
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
-	if (ret < 0)
-		return ret;
-
-	*alarm = !!(ret & 0x40);
-
-	return 0;
-}
-#endif /* CONFIG_NET_DSA_HWMON */
-
 static int mv88e6352_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -393,10 +329,10 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_eee		= mv88e6xxx_set_eee,
 	.get_eee		= mv88e6xxx_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
-	.get_temp		= mv88e6352_get_temp,
-	.get_temp_limit		= mv88e6352_get_temp_limit,
-	.set_temp_limit		= mv88e6352_set_temp_limit,
-	.get_temp_alarm		= mv88e6352_get_temp_alarm,
+	.get_temp		= mv88e6xxx_get_temp,
+	.get_temp_limit		= mv88e6xxx_get_temp_limit,
+	.set_temp_limit		= mv88e6xxx_set_temp_limit,
+	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
 	.get_eeprom		= mv88e6352_get_eeprom,
 	.set_eeprom		= mv88e6352_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5158375b7abd..61ce4cf120a6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -517,7 +517,7 @@ static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
 	return false;
 }
 
-bool mv88e6xxx_6320_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6320_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
@@ -808,54 +808,6 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	}
 }
 
-#ifdef CONFIG_NET_DSA_HWMON
-
-int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-	int val;
-
-	*temp = 0;
-
-	mutex_lock(&ps->smi_mutex);
-
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
-	if (ret < 0)
-		goto error;
-
-	/* Enable temperature sensor */
-	ret = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
-	if (ret < 0)
-		goto error;
-
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
-	if (ret < 0)
-		goto error;
-
-	/* Wait for temperature to stabilize */
-	usleep_range(10000, 12000);
-
-	val = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
-	if (val < 0) {
-		ret = val;
-		goto error;
-	}
-
-	/* Disable temperature sensor */
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
-	if (ret < 0)
-		goto error;
-
-	*temp = ((val & 0x1f) - 5) * 5;
-
-error:
-	_mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->smi_mutex);
-	return ret;
-}
-#endif /* CONFIG_NET_DSA_HWMON */
-
 /* Must be called with SMI lock held */
 static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 			   u16 mask)
@@ -2180,6 +2132,132 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	return ret;
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
+
+static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+	int val;
+
+	*temp = 0;
+
+	mutex_lock(&ps->smi_mutex);
+
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
+	if (ret < 0)
+		goto error;
+
+	/* Enable temperature sensor */
+	ret = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	if (ret < 0)
+		goto error;
+
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
+	if (ret < 0)
+		goto error;
+
+	/* Wait for temperature to stabilize */
+	usleep_range(10000, 12000);
+
+	val = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	if (val < 0) {
+		ret = val;
+		goto error;
+	}
+
+	/* Disable temperature sensor */
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
+	if (ret < 0)
+		goto error;
+
+	*temp = ((val & 0x1f) - 5) * 5;
+
+error:
+	_mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
+	mutex_unlock(&ps->smi_mutex);
+	return ret;
+}
+
+static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
+{
+	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	int ret;
+
+	*temp = 0;
+
+	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 27);
+	if (ret < 0)
+		return ret;
+
+	*temp = (ret & 0xff) - 25;
+
+	return 0;
+}
+
+int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
+{
+	if (mv88e6xxx_6320_family(ds) || mv88e6xxx_6352_family(ds))
+		return mv88e63xx_get_temp(ds, temp);
+
+	return mv88e61xx_get_temp(ds, temp);
+}
+
+int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
+{
+	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	int ret;
+
+	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+		return -EOPNOTSUPP;
+
+	*temp = 0;
+
+	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	if (ret < 0)
+		return ret;
+
+	*temp = (((ret >> 8) & 0x1f) * 5) - 25;
+
+	return 0;
+}
+
+int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
+{
+	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	int ret;
+
+	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+		return -EOPNOTSUPP;
+
+	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	if (ret < 0)
+		return ret;
+	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
+	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
+					(ret & 0xe0ff) | (temp << 8));
+}
+
+int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
+{
+	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	int ret;
+
+	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+		return -EOPNOTSUPP;
+
+	*alarm = false;
+
+	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
+	if (ret < 0)
+		return ret;
+
+	*alarm = !!(ret & 0x40);
+
+	return 0;
+}
+#endif /* CONFIG_NET_DSA_HWMON */
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 64786cb89a93..78e37226a37d 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -394,7 +394,10 @@ int mv88e6xxx_get_sset_count_basic(struct dsa_switch *ds);
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
-int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
+int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
+int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp);
+int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp);
+int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm);
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds);
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum);
@@ -415,7 +418,7 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
-bool mv88e6xxx_6320_family(struct dsa_switch *ds);
+
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
-- 
2.1.0
