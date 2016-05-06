From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/21] net: dsa: mv88e6xxx: factorize temperature access
Date: Fri,  6 May 2016 17:57:07 -0400
Message-ID: <1462571843-14397-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add MV88E6XXX_FLAG_TEMP and MV88E6XXX_FLAG_TEMP_LIMIT flags to describe
switch models featuring a temperature access. Use them to centralize the
access to the temperature feature.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  3 +++
 drivers/net/dsa/mv88e6131.c |  6 ++++++
 drivers/net/dsa/mv88e6171.c |  3 +++
 drivers/net/dsa/mv88e6xxx.c |  9 ++++++---
 drivers/net/dsa/mv88e6xxx.h | 22 ++++++++++++++++++----
 5 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 8330a8e..e234bdb 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -123,6 +123,9 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
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
index ab8c507..089f9c0 100644
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
index a7afbaa..588b486 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -132,6 +132,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.adjust_link		= mv88e6xxx_adjust_link,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
+	.get_temp_limit		= mv88e6xxx_get_temp_limit,
+	.set_temp_limit		= mv88e6xxx_set_temp_limit,
+	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 921fe87..c010bb9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3191,6 +3191,9 @@ int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP))
+		return -EOPNOTSUPP;
+
 	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
 		return mv88e63xx_get_temp(ds, temp);
 
@@ -3203,7 +3206,7 @@ int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*temp = 0;
@@ -3223,7 +3226,7 @@ int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
@@ -3240,7 +3243,7 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP_LIMIT))
 		return -EOPNOTSUPP;
 
 	*alarm = false;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 0181f67..9ddb6d0 100644
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
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	MV88E6XXX_FLAG_PPU
@@ -379,21 +387,27 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	MV88E6XXX_FLAG_PPU
 
-#define MV88E6XXX_FLAGS_FAMILY_6165	0
+#define MV88E6XXX_FLAGS_FAMILY_6165	\
+	MV88E6XXX_FLAG_TEMP
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	MV88E6XXX_FLAG_PPU
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEPROM |	\
-	 MV88E6XXX_FLAG_SMI_PHY)
+	 MV88E6XXX_FLAG_SMI_PHY |	\
+	 MV88E6XXX_FLAG_TEMP |		\
+	 MV88E6XXX_FLAG_TEMP_LIMIT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	MV88E6XXX_FLAG_SMI_PHY
+	(MV88E6XXX_FLAG_SMI_PHY |	\
+	 MV88E6XXX_FLAG_TEMP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEPROM |	\
-	 MV88E6XXX_FLAG_SMI_PHY)
+	 MV88E6XXX_FLAG_SMI_PHY	|	\
+	 MV88E6XXX_FLAG_TEMP |		\
+	 MV88E6XXX_FLAG_TEMP_LIMIT)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.8.2
