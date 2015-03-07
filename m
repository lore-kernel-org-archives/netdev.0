From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 1/2] net: dsa: mv88e6xxx: Add EEE support
Date: Fri,  6 Mar 2015 22:23:51 -0800
Message-ID: <1425709432-30419-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:49290 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099AbbCGGYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 01:24:03 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YU89Z-004A2v-Jy
	for netdev@vger.kernel.org; Sat, 07 Mar 2015 06:24:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEE configuration is similar for the various MV88E6xxx chips.
Add generic support for it.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since RFT:
- Additional testing; no code changes
- Dropped comment about phy_init_eee

 drivers/net/dsa/mv88e6xxx.c | 51 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a83ace0..c18ffc9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -649,6 +649,57 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 	return mv88e6xxx_phy_wait(ds);
 }
 
+int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
+{
+	int reg;
+
+	reg = mv88e6xxx_phy_read_indirect(ds, port, 16);
+	if (reg < 0)
+		return -EOPNOTSUPP;
+
+	e->eee_enabled = !!(reg & 0x0200);
+	e->tx_lpi_enabled = !!(reg & 0x0100);
+
+	reg = REG_READ(REG_PORT(port), 0);
+	e->eee_active = !!(reg & 0x0040);
+
+	return 0;
+}
+
+static int mv88e6xxx_eee_enable_set(struct dsa_switch *ds, int port,
+				    bool eee_enabled, bool tx_lpi_enabled)
+{
+	int reg, nreg;
+
+	reg = mv88e6xxx_phy_read_indirect(ds, port, 16);
+	if (reg < 0)
+		return reg;
+
+	nreg = reg & ~0x0300;
+	if (eee_enabled)
+		nreg |= 0x0200;
+	if (tx_lpi_enabled)
+		nreg |= 0x0100;
+
+	if (nreg != reg)
+		return mv88e6xxx_phy_write_indirect(ds, port, 16, nreg);
+
+	return 0;
+}
+
+int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
+		      struct phy_device *phydev, struct ethtool_eee *e)
+{
+	int ret;
+
+	ret = mv88e6xxx_eee_enable_set(ds, port, e->eee_enabled,
+				       e->tx_lpi_enabled);
+	if (ret)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7294227..5fd42ce 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -88,6 +88,9 @@ int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 				 u16 val);
+int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
+int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
+		      struct phy_device *phydev, struct ethtool_eee *e);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.1.0
