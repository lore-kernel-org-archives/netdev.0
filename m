From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT PATCH 1/2] net: dsa: mv88e6xxx: Add EEE support
Date: Mon, 23 Feb 2015 08:26:09 -0800
Message-ID: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39138 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbbBWQ0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 11:26:15 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPvpm-001wGF-O1
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 16:26:15 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEE configuration is similar for the various MV88E6xxx chips.
Add generic support for it.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Applies to net-next.

The code seems to be working, at least according to ethtool, but some
more testing with other chip types would be useful. Also, I am not sure
what to do with phy_init_eee.

 drivers/net/dsa/mv88e6xxx.c | 55 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 2 files changed, 58 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a83ace0..2d5306a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -649,6 +649,61 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
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
+	/* Don't call phy_init_eee for now. It fails if the link is down,
+	 * but that should not really be a reason to fail configuration.
+	 */
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
