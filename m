From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 05/20] net: dsa: mv88e6xxx: factorize MAC address setting
Date: Thu,  5 May 2016 18:40:49 -0400
Message-ID: <1462488064-1841-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some switch models have a dedicated register for Switch MAC/WoF/WoL.
This register, when present, is used to indirectly set the switch MAC
address, instead of a direct write to 3 global registers.

Identify this feature and share a common mv88e6xxx_set_addr function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  11 +++--
 drivers/net/dsa/mv88e6131.c |   2 +-
 drivers/net/dsa/mv88e6171.c |   6 ++-
 drivers/net/dsa/mv88e6352.c |   8 ++-
 drivers/net/dsa/mv88e6xxx.c | 115 ++++++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx.h |  11 ++++-
 6 files changed, 92 insertions(+), 61 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 6f4f719..57a6d76 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -24,21 +24,24 @@ static const struct mv88e6xxx_info mv88e6123_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
-		.flags = MV88E6XXX_FLAG_TEMP,
+		.flags = MV88E6XXX_FLAG_SWITCH_MAC |
+			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
-		.flags = MV88E6XXX_FLAG_TEMP,
+		.flags = MV88E6XXX_FLAG_SWITCH_MAC |
+			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
-		.flags = MV88E6XXX_FLAG_TEMP,
+		.flags = MV88E6XXX_FLAG_SWITCH_MAC |
+			MV88E6XXX_FLAG_TEMP,
 	}
 };
 
@@ -114,7 +117,7 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6123_drv_probe,
 	.setup			= mv88e6123_setup,
-	.set_addr		= mv88e6xxx_set_addr_indirect,
+	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e8eb9a6..519d1eb 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -147,7 +147,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6131_setup,
-	.set_addr		= mv88e6xxx_set_addr_direct,
+	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index bd2082e..f947950 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -25,6 +25,7 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
@@ -33,6 +34,7 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
@@ -41,6 +43,7 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
@@ -49,6 +52,7 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP,
 	}
 };
@@ -127,7 +131,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6171_drv_probe,
 	.setup			= mv88e6171_setup,
-	.set_addr		= mv88e6xxx_set_addr_indirect,
+	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index f588e2f..90732da 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -31,6 +31,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
@@ -41,6 +42,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
@@ -51,6 +53,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
@@ -61,6 +64,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
@@ -71,6 +75,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}, {
@@ -81,6 +86,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
+			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT,
 	}
@@ -158,7 +164,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6352_drv_probe,
 	.setup			= mv88e6352_setup,
-	.set_addr		= mv88e6xxx_set_addr_indirect,
+	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5f7851e..5483e69 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -173,58 +173,6 @@ int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 	return ret;
 }
 
-int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int err;
-
-	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_01,
-				  (addr[0] << 8) | addr[1]);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_23,
-				  (addr[2] << 8) | addr[3]);
-	if (err)
-		return err;
-
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_45,
-				   (addr[4] << 8) | addr[5]);
-}
-
-int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-	int i;
-
-	for (i = 0; i < 6; i++) {
-		int j;
-
-		/* Write the MAC address byte. */
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
-					  GLOBAL2_SWITCH_MAC_BUSY |
-					  (i << 8) | addr[i]);
-		if (ret)
-			return ret;
-
-		/* Wait for the write to complete. */
-		for (j = 0; j < 16; j++) {
-			ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2,
-						 GLOBAL2_SWITCH_MAC);
-			if (ret < 0)
-				return ret;
-
-			if ((ret & GLOBAL2_SWITCH_MAC_BUSY) == 0)
-				break;
-		}
-		if (j == 16)
-			return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
 static int _mv88e6xxx_phy_read(struct mv88e6xxx_priv_state *ps, int addr,
 			       int regnum)
 {
@@ -1131,6 +1079,69 @@ out:
 	return ret;
 }
 
+static int _mv88e6xxx_set_addr_direct(struct mv88e6xxx_priv_state *ps, u8 *addr)
+{
+	int err;
+
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_01,
+				   (addr[0] << 8) | addr[1]);
+	if (err)
+		return err;
+
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_23,
+				   (addr[2] << 8) | addr[3]);
+	if (err)
+		return err;
+
+	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_45,
+				    (addr[4] << 8) | addr[5]);
+}
+
+static int _mv88e6xxx_switch_mac_wait(struct mv88e6xxx_priv_state *ps)
+{
+	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
+			       GLOBAL2_SWITCH_MAC_BUSY);
+}
+
+static int _mv88e6xxx_set_addr_indirect(struct mv88e6xxx_priv_state *ps,
+					u8 *addr)
+{
+	int i, err;
+
+	for (i = 0; i < 6; i++) {
+		/* Write the MAC address byte. */
+		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
+					   GLOBAL2_SWITCH_MAC_BUSY |
+					   (i << 8) | addr[i]);
+		if (err)
+			break;
+
+		/* Wait for the write to complete. */
+		err = _mv88e6xxx_switch_mac_wait(ps);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&ps->smi_mutex);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SWITCH_MAC))
+		err = _mv88e6xxx_set_addr_indirect(ps, addr);
+	else
+		err = _mv88e6xxx_set_addr_direct(ps, addr);
+
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
 static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_priv_state *ps, u16 fid, u16 cmd)
 {
 	int ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e7c2e45..72b563e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -367,6 +367,13 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_SMI_PHY,
 
+	/* Switch MAC/WoL/WoF register.
+	 * This requires an indirect access to set the switch MAC address
+	 * through GLOBAL2_SWITCH_MAC, otherwise GLOBAL_MAC_01, GLOBAL_MAC_23,
+	 * and GLOBAL_MAC_45 are used with a direct access.
+	 */
+	MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF,
+
 	/* Internal temperature sensor.
 	 * Available from any enabled port's PHY register 26, page 6.
 	 */
@@ -378,6 +385,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
+#define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 
@@ -497,8 +505,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg);
 int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 			int reg, u16 val);
-int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
-int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
+int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val);
 void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
-- 
2.8.2
