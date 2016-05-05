From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 04/20] net: dsa: mv88e6xxx: factorize temperature access
Date: Thu,  5 May 2016 18:40:48 -0400
Message-ID: <1462488064-1841-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58634 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758019AbcEEWls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 18:41:48 -0400
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MV88E6XXX_FLAG_TEMP and MV88E6XXX_FLAG_TEMP_LIMIT flags to describe
switch models featuring a temperature access. Use them to centralize the
access to the temperature feature.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  6 ++++++
 drivers/net/dsa/mv88e6131.c |  6 ++++++
 drivers/net/dsa/mv88e6171.c | 17 ++++++++++++-----
 drivers/net/dsa/mv88e6352.c | 24 ++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.c | 32 +++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx.h |  8 ++++++++
 6 files changed, 69 insertions(+), 24 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 1fc8f0d..6f4f719 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -24,18 +24,21 @@ static const struct mv88e6xxx_info mv88e6123_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.flags = MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.flags = MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.flags = MV88E6XXX_FLAG_TEMP,
 	}
 };
 
@@ -120,6 +123,9 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.adjust_link		= mv88e6xxx_adjust_link,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6xxx_get_temp,
+	.get_temp_limit		= mv88e6xxx_get_temp_limit,
+	.set_temp_limit		= mv88e6xxx_set_temp_limit,
+	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 3796f6d..e8eb9a6 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -155,6 +155,12 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
+#ifdef CONFIG_NET_DSA_HWMON
+	.get_temp		= mv88e6xxx_get_temp,
+	.get_temp_limit		= mv88e6xxx_get_temp_limit,
+	.set_temp_limit		= mv88e6xxx_set_temp_limit,
+	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
+#endif
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index b8b6902..bd2082e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,28 +24,32 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP,
 	}
 };
 
@@ -131,7 +135,10 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.adjust_link		= mv88e6xxx_adjust_link,
 #ifdef CONFIG_NET_DSA_HWMON
-	.get_temp               = mv88e6xxx_get_temp,
+	.get_temp		= mv88e6xxx_get_temp,
+	.get_temp_limit		= mv88e6xxx_get_temp_limit,
+	.set_temp_limit		= mv88e6xxx_set_temp_limit,
+	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e6437de..f588e2f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -30,7 +30,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
@@ -38,7 +40,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -46,7 +50,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -54,7 +60,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -62,7 +70,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -70,7 +80,9 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
-			MV88E6XXX_FLAG_SMI_PHY,
+			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 233c265..5f7851e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3125,16 +3125,13 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 
 #ifdef CONFIG_NET_DSA_HWMON
 
-static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
+static int _mv88e61xx_get_temp(struct mv88e6xxx_priv_state *ps, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 	int val;
 
 	*temp = 0;
 
-	mutex_lock(&ps->smi_mutex);
-
 	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
@@ -3166,19 +3163,18 @@ static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 
 error:
 	_mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->smi_mutex);
+
 	return ret;
 }
 
-static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
+static int _mv88e63xx_get_temp(struct mv88e6xxx_priv_state *ps, int *temp)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
 	*temp = 0;
 
-	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 27);
+	ret = _mv88e6xxx_phy_page_read(ps, phy, 6, 27);
 	if (ret < 0)
 		return ret;
 
@@ -3190,11 +3186,21 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int err;
+
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP))
+		return -EOPNOTSUPP;
+
+	mutex_lock(&ps->smi_mutex);
 
 	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
-		return mv88e63xx_get_temp(ds, temp);
+		err = _mv88e63xx_get_temp(ps, temp);
+	else
+		err = _mv88e61xx_get_temp(ps, temp);
 
-	return mv88e61xx_get_temp(ds, temp);
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
 }
 
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
@@ -3203,7 +3209,7 @@ int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*temp = 0;
@@ -3223,7 +3229,7 @@ int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
@@ -3240,7 +3246,7 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*alarm = false;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 08cb5c4..e7c2e45 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -366,12 +366,20 @@ enum mv88e6xxx_cap {
 	 * GLOBAL2_SMI_OP, otherwise direct access to PHY registers is done.
 	 */
 	MV88E6XXX_CAP_SMI_PHY,
+
+	/* Internal temperature sensor.
+	 * Available from any enabled port's PHY register 26, page 6.
+	 */
+	MV88E6XXX_CAP_TEMP,
+	MV88E6XXX_CAP_TEMP_LIMIT,
 };
 
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
+#define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
+#define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.8.2
