From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code optional
Date: Fri,  2 Sep 2016 08:08:19 -0400
Message-ID: <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33434 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753240AbcIBMIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 08:08:42 -0400
In-Reply-To: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since not every chip has a Global2 set of registers, make its support
optional, in which case the related functions will return -EOPNOTSUPP.

This also allows to reduce the size of the mv88e6xxx driver for devices
such as home routers embedding Ethernet chips without Global2 support.

It is present on most recent chips, thus enable its support by default.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Kconfig     | 11 ++++++++++
 drivers/net/dsa/mv88e6xxx/Makefile    |  2 +-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 40 +++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
index ac77737..4ba9d5a 100644
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
+	  features like indirect PHY access, EEPROM interface, trunking, etc.
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
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 151f0af..18924c2 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -726,6 +726,7 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask);
 
 /* global2.c */
+#ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
 int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 			      u16 *val);
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
@@ -736,4 +737,43 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
+#else
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
+	return 0;
+}
+#endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
+
 #endif
-- 
2.9.3
