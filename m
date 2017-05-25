From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 4/5] net: dsa: mv88e6xxx: mv88e6390X SERDES support
Date: Fri, 26 May 2017 01:03:23 +0200
Message-ID: <1495753404-29943-5-git-send-email-andrew@lunn.ch>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45094 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165913AbdEYXFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:05:25 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390X family has 8 SERDES lanes. These can be used for 2
10Gbps ports, ports 9 or 10. If these ports are used at slower speeds,
the SERDES lanes become available for other ports for 1000Base-X.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c   |   6 ++
 drivers/net/dsa/mv88e6xxx/serdes.c | 154 +++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h |  24 ++++++
 3 files changed, 184 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bc7b345d91d3..4e58d9a82d9e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2757,6 +2757,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -2789,6 +2790,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -2821,6 +2823,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -2888,6 +2891,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3113,6 +3117,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3147,6 +3152,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
index 235f5f0c30ae..53795676bd70 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.c
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -13,6 +13,7 @@
 
 #include <linux/mii.h>
 
+#include "global2.h"
 #include "mv88e6xxx.h"
 #include "phy.h"
 #include "port.h"
@@ -73,3 +74,156 @@ int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
 
 	return 0;
 }
+
+/* Set the power on/off for 10GBASE-R and 10GBASE-X4/X2 */
+static int mv88e6390_serdes_10g(struct mv88e6xxx_chip *chip, int addr, bool on)
+{
+	u16 val, new_val;
+	int reg_c45;
+	int err;
+
+	reg_c45 = MII_ADDR_C45 | MV88E6390_SERDES_DEVICE |
+		MV88E6390_PCS_CONTROL_1;
+	err = mv88e6xxx_phy_read(chip, addr, reg_c45, &val);
+	if (err)
+		return err;
+
+	if (on)
+		new_val = val & ~(MV88E6390_PCS_CONTROL_1_RESET |
+				  MV88E6390_PCS_CONTROL_1_LOOPBACK |
+				  MV88E6390_PCS_CONTROL_1_PDOWN);
+	else
+		new_val = val | MV88E6390_PCS_CONTROL_1_PDOWN;
+
+	if (val != new_val)
+		err = mv88e6xxx_phy_write(chip, addr, reg_c45, new_val);
+
+	return err;
+}
+
+/* Set the power on/off for 10GBASE-R and 10GBASE-X4/X2 */
+static int mv88e6390_serdes_sgmii(struct mv88e6xxx_chip *chip, int addr,
+				  bool on)
+{
+	u16 val, new_val;
+	int reg_c45;
+	int err;
+
+	reg_c45 = MII_ADDR_C45 | MV88E6390_SERDES_DEVICE |
+		MV88E6390_SGMII_CONTROL;
+	err = mv88e6xxx_phy_read(chip, addr, reg_c45, &val);
+	if (err)
+		return err;
+
+	if (on)
+		new_val = val & ~(MV88E6390_SGMII_CONTROL_RESET |
+				  MV88E6390_SGMII_CONTROL_LOOPBACK |
+				  MV88E6390_SGMII_CONTROL_PDOWN);
+	else
+		new_val = val | MV88E6390_SGMII_CONTROL_PDOWN;
+
+	if (val != new_val)
+		err = mv88e6xxx_phy_write(chip, addr, reg_c45, new_val);
+
+	return err;
+}
+
+static int mv88e6390_serdes_lower(struct mv88e6xxx_chip *chip, u8 cmode,
+				  int port_donor, int lane, bool rxaui, bool on)
+{
+	int err;
+	u8 cmode_donor;
+
+	err = mv88e6xxx_port_get_cmode(chip, port_donor, &cmode_donor);
+	if (err)
+		return err;
+
+	switch (cmode_donor) {
+	case PORT_STATUS_CMODE_RXAUI:
+		if (!rxaui)
+			break;
+		/* Fall through */
+	case PORT_STATUS_CMODE_1000BASE_X:
+	case PORT_STATUS_CMODE_SGMII:
+	case PORT_STATUS_CMODE_2500BASEX:
+		if (cmode == PORT_STATUS_CMODE_1000BASE_X ||
+		    cmode == PORT_STATUS_CMODE_SGMII)
+			return	mv88e6390_serdes_sgmii(chip, lane, on);
+	}
+	return 0;
+}
+
+static int mv88e6390_serdes_port9(struct mv88e6xxx_chip *chip, u8 cmode,
+				  bool on)
+{
+	switch (cmode) {
+	case PORT_STATUS_CMODE_1000BASE_X:
+	case PORT_STATUS_CMODE_SGMII:
+		return mv88e6390_serdes_sgmii(chip, MV88E6390_PORT9_LANE0, on);
+	case PORT_STATUS_CMODE_XAUI:
+	case PORT_STATUS_CMODE_RXAUI:
+	case PORT_STATUS_CMODE_2500BASEX:
+		return mv88e6390_serdes_10g(chip, MV88E6390_PORT9_LANE0, on);
+	}
+
+	return 0;
+}
+
+static int mv88e6390_serdes_port10(struct mv88e6xxx_chip *chip, u8 cmode,
+				   bool on)
+{
+	switch (cmode) {
+	case PORT_STATUS_CMODE_SGMII:
+		return mv88e6390_serdes_sgmii(chip, MV88E6390_PORT10_LANE0, on);
+	case PORT_STATUS_CMODE_XAUI:
+	case PORT_STATUS_CMODE_RXAUI:
+	case PORT_STATUS_CMODE_1000BASE_X:
+	case PORT_STATUS_CMODE_2500BASEX:
+		return mv88e6390_serdes_10g(chip, MV88E6390_PORT10_LANE0, on);
+	}
+
+	return 0;
+}
+
+int mv88e6390_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
+{
+	u8 cmode;
+	int err;
+
+	err = mv88e6xxx_port_get_cmode(chip, port, &cmode);
+	if (err)
+		return cmode;
+
+	switch (port) {
+	case 2:
+		return mv88e6390_serdes_lower(chip, cmode, 9,
+					      MV88E6390_PORT9_LANE1,
+					      false, on);
+	case 3:
+		return mv88e6390_serdes_lower(chip, cmode, 9,
+					      MV88E6390_PORT9_LANE2,
+					      true, on);
+	case 4:
+		return mv88e6390_serdes_lower(chip, cmode, 9,
+					      MV88E6390_PORT9_LANE3,
+					      true, on);
+	case 5:
+		return mv88e6390_serdes_lower(chip, cmode, 10,
+					      MV88E6390_PORT10_LANE1,
+					      false, on);
+	case 6:
+		return mv88e6390_serdes_lower(chip, cmode, 10,
+					      MV88E6390_PORT10_LANE2,
+					      true, on);
+	case 7:
+		return mv88e6390_serdes_lower(chip, cmode, 10,
+					      MV88E6390_PORT10_LANE3,
+					      true, on);
+	case 9:
+		return mv88e6390_serdes_port9(chip, cmode, on);
+	case 10:
+		return mv88e6390_serdes_port10(chip, cmode, on);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.h b/drivers/net/dsa/mv88e6xxx/serdes.h
index a690be09ac52..eb3ceaef790f 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.h
+++ b/drivers/net/dsa/mv88e6xxx/serdes.h
@@ -19,6 +19,30 @@
 #define MV88E6352_ADDR_SERDES		0x0f
 #define MV88E6352_SERDES_PAGE_FIBER	0x01
 
+#define MV88E6390_PORT9_LANE0		0x09
+#define MV88E6390_PORT9_LANE1		0x12
+#define MV88E6390_PORT9_LANE2		0x13
+#define MV88E6390_PORT9_LANE3		0x14
+#define MV88E6390_PORT10_LANE0		0x0a
+#define MV88E6390_PORT10_LANE1		0x15
+#define MV88E6390_PORT10_LANE2		0x16
+#define MV88E6390_PORT10_LANE3		0x17
+#define MV88E6390_SERDES_DEVICE		(4 << 16)
+
+/* 10GBASE-R and 10GBASE-X4/X2 */
+#define MV88E6390_PCS_CONTROL_1		0x1000
+#define MV88E6390_PCS_CONTROL_1_RESET		BIT(15)
+#define MV88E6390_PCS_CONTROL_1_LOOPBACK	BIT(14)
+#define MV88E6390_PCS_CONTROL_1_SPEED		BIT(13)
+#define MV88E6390_PCS_CONTROL_1_PDOWN		BIT(11)
+
+/* 1000BASE-X and SGMII */
+#define MV88E6390_SGMII_CONTROL		0x2000
+#define MV88E6390_SGMII_CONTROL_RESET		BIT(15)
+#define MV88E6390_SGMII_CONTROL_LOOPBACK	BIT(14)
+#define MV88E6390_SGMII_CONTROL_PDOWN		BIT(11)
+
 int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on);
+int mv88e6390_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on);
 
 #endif
-- 
2.11.0
