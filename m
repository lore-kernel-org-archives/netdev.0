From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/3] net: dsa: mv88e6xxx: make global2 code optional
Date: Fri,  2 Sep 2016 14:45:34 -0400
Message-ID: <20160902184534.28594-4-vivien.didelot@savoirfairelinux.com>
References: <20160902184534.28594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902184534.28594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since not every chip has a Global2 set of registers, make its support
optional, in which case the related functions will return -EOPNOTSUPP.

This also allows to reduce the size of the mv88e6xxx driver for devices
such as home routers embedding Ethernet chips without Global2 support.

It is present on most recent chips, thus enable its support by default.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Kconfig   | 11 +++++++
 drivers/net/dsa/mv88e6xxx/Makefile  |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c    |  4 +++
 drivers/net/dsa/mv88e6xxx/global2.h | 58 +++++++++++++++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
index ac77737..4866688 100644
--- a/drivers/net/dsa/mv88e6xxx/Kconfig
+++ b/drivers/net/dsa/mv88e6xxx/Kconfig
@@ -6,3 +6,14 @@ config NET_DSA_MV88E6XXX
 	help
 	  This driver adds support for most of the Marvell 88E6xxx models of
 	  Ethernet switch chips, except 88E6060.
+
+config NET_DSA_MV88E6XXX_GLOBAL2
+	bool "Switch Global 2 Registers support"
+	default y
+	depends on NET_DSA_MV88E6XXX
+	help
+	  This registers set at internal SMI address 0x1C provides extended
+	  features like EEPROM interface, trunking, cross-chip setup, etc.
+
+	  It is required on most chips. If the chip you compile the support for
+	  doesn't have such registers set, say N here. In doubt, say Y.
diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 5a42066..6971039 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
-mv88e6xxx-objs += global2.o
+mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 745e158..70a812d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3444,6 +3444,10 @@ static int mv88e6xxx_detect(struct mv88e6xxx_chip *chip)
 	/* Update the compatible info with the probed one */
 	chip->info = info;
 
+	err = mv88e6xxx_g2_require(chip);
+	if (err)
+		return err;
+
 	dev_info(chip->dev, "switch 0x%x detected: %s, revision %u\n",
 		 chip->info->prod_num, chip->info->name, rev);
 
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index bee1bc9..c4bb903 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -16,6 +16,13 @@
 
 #include "mv88e6xxx.h"
 
+#ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
+
+static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
+{
+	return 0;
+}
+
 int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 			      u16 *val);
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
@@ -27,4 +34,55 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
 
+#else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
+
+static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
+{
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
+		dev_err(chip->dev, "this chip requires CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 enabled\n");
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static inline int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
+					    int addr, int reg, u16 *val)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
+					     int addr, int reg, u16 val)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip,
+					      u8 *addr)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
+					    struct ethtool_eeprom *eeprom,
+					    u8 *data)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
+					    struct ethtool_eeprom *eeprom,
+					    u8 *data)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
+#endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
+
 #endif /* _MV88E6XXX_GLOBAL2_H */
-- 
2.9.3
