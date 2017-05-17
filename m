From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/3] net: dsa: mv88e6xxx: mv88e6390X SERDES support
Date: Wed, 17 May 2017 22:05:11 +0200
Message-ID: <1495051512-13554-3-git-send-email-andrew@lunn.ch>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34768 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751957AbdEQUFt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 16:05:49 -0400
In-Reply-To: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390X family has 8 SERDES lanes. These can be used for 2
10Gbps ports, ports 9 or 10. If these ports are used at slower speeds,
the SERDES lanes become available for other ports for 1000Base-X.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  28 +++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   4 +
 drivers/net/dsa/mv88e6xxx/serdes.c    | 154 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h    |  24 ++++++
 4 files changed, 196 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6adaff3876b7..067f64dcf1b6 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -249,8 +249,8 @@ static struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
 	return mdio_bus->bus;
 }
 
-static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
-			      int reg, u16 *val)
+int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
+		       int reg, u16 *val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 	struct mii_bus *bus;
@@ -265,8 +265,8 @@ static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
 }
 
-static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
-			       int reg, u16 val)
+int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
+			int reg, u16 val)
 {
 	int addr = phy; /* PHY devices addresses start at 0x0 */
 	struct mii_bus *bus;
@@ -1996,7 +1996,10 @@ static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
 	if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
 		return mv88e6xxx_set_port_mode_edsa(chip, port);
 
-	return -EINVAL;
+	if (chip->info->ops->serdes_power)
+		return chip->info->ops->serdes_power(chip, port, true);
+
+	return 0;
 }
 
 static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
@@ -2068,15 +2071,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	/* If this port is connected to a SerDes, make sure the SerDes is
-	 * powered up.
-	 */
-	if (chip->info->ops->serdes_power) {
-		err = chip->info->ops->serdes_power(chip, port, true);
-		if (err)
-			return err;
-	}
-
 	/* Port Control 2: don't force a good FCS, set the maximum frame size to
 	 * 10240 bytes, disable 802.1q tags checking, don't discard tagged or
 	 * untagged frames on this port, do a destination address lookup on all
@@ -2965,6 +2959,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -2997,6 +2992,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3029,6 +3025,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3096,6 +3093,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3321,6 +3319,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3355,6 +3354,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
+	.serdes_power = mv88e6390_serdes_power,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 30ccd50832ff..aa74705c46d3 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -928,4 +928,8 @@ int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 			     u8 page, int reg, u16 val);
 int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
 			    u8 page, int reg, u16 *val);
+int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
+			int reg, u16 val);
+int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
+		       int reg, u16 *val);
 #endif
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
index fc2d02c32908..6a4b4f7970f6 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.c
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -13,6 +13,7 @@
 
 #include <linux/mii.h>
 
+#include "global2.h"
 #include "mv88e6xxx.h"
 #include "port.h"
 #include "serdes.h"
@@ -75,3 +76,156 @@ int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
 
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
index e183727388cb..d5223d9775ab 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.h
+++ b/drivers/net/dsa/mv88e6xxx/serdes.h
@@ -16,6 +16,30 @@
 
 #include "mv88e6xxx.h"
 
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
