From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/21] net: dsa: mv88e6xxx: factorize EEE access
Date: Fri,  6 May 2016 17:57:09 -0400
Message-ID: <1462571843-14397-8-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a MV88E6XXX_FLAG_EEE flag to describe switch models featuring Energy
Efficient Ethernet. Use it to conditionally support such access in the
common code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  2 ++
 drivers/net/dsa/mv88e6131.c |  2 ++
 drivers/net/dsa/mv88e6171.c |  2 ++
 drivers/net/dsa/mv88e6xxx.c |  6 ++++++
 drivers/net/dsa/mv88e6xxx.h | 11 +++++++++--
 5 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index c349fb7..1ad7bcd 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -117,6 +117,8 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 1e040c6..432d3c4 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -150,6 +150,8 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f9b20e0..a98e7d3 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -126,6 +126,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 10cc277..f76cdc9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1097,6 +1097,9 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int reg;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	reg = _mv88e6xxx_phy_read_indirect(ps, port, 16);
@@ -1125,6 +1128,9 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	int reg;
 	int ret;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	ret = _mv88e6xxx_phy_read_indirect(ps, port, 16);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 517e95f..b99e090 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -351,6 +351,10 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* Energy Efficient Ethernet.
+	 */
+	MV88E6XXX_CAP_EEE,
+
 	/* EEPROM Command and Data registers.
 	 * See GLOBAL2_EEPROM_OP and GLOBAL2_EEPROM_DATA.
 	 */
@@ -382,6 +386,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
@@ -403,7 +408,8 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_FLAG_PPU
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EEPROM |	\
+	(MV88E6XXX_FLAG_EEE |		\
+	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -415,7 +421,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EEPROM |	\
+	(MV88E6XXX_FLAG_EEE |		\
+	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_SMI_PHY	|	\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
-- 
2.8.2
