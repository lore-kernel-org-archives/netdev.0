From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 10/11] net: dsa: mv88e6xxx: add port's MAC speed setter
Date: Fri,  4 Nov 2016 03:23:35 +0100
Message-ID: <20161104022336.14273-11-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While the two bits for link, duplex or RGMII delays are used the same
way on chips supporting the said feature, the two bits for speed have
different meaning for most of the chips out there.

Speed value is stored in bits 1:0, 0x3 means unforce (normal detection).

Some chips reuse values for alternative speeds when bit 12 is set.

Newer chips with speed > 1Gbps reuse value 0x3 thus need a new bit 13.

Here are the values to write in register 0x1 to (un)force speed:

    | Speed   | 88E6065 | 88E6185 | 88E6352 | 88E6390 | 88E6390X |
    | ------- | ------- | ------- | ------- | ------- | -------- |
    | 10      | 0x0000  | 0x0000  | 0x0000  | 0x2000  | 0x2000   |
    | 100     | 0x0001  | 0x0001  | 0x0001  | 0x2001  | 0x2001   |
    | 200     | 0x0002  | NA      | 0x1001  | 0x3001  | 0x3001   |
    | 1000    | NA      | 0x0002  | 0x0002  | 0x2002  | 0x2002   |
    | 2500    | NA      | NA      | NA      | 0x3003  | 0x3003   |
    | 10000   | NA      | NA      | NA      | NA      | 0x2003   |
    | unforce | 0x0003  | 0x0003  | 0x0003  | 0x0000  | 0x0000   |

This patch implements a generic mv88e6xxx_port_set_speed() function used
by chip-specific wrappers to filter supported ports and speeds.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  33 ++++++--
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  24 +++++-
 drivers/net/dsa/mv88e6xxx/port.c      | 138 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |   6 ++
 4 files changed, 189 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bb93d0a..23c05e3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -725,7 +725,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 		 PORT_PCS_CTRL_FORCE_LINK |
 		 PORT_PCS_CTRL_DUPLEX_FULL |
 		 PORT_PCS_CTRL_FORCE_DUPLEX |
-		 PORT_PCS_CTRL_UNFORCED);
+		 PORT_PCS_CTRL_SPEED_UNFORCED);
 
 	reg |= PORT_PCS_CTRL_FORCE_LINK;
 	if (phydev->link)
@@ -736,13 +736,13 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 
 	switch (phydev->speed) {
 	case SPEED_1000:
-		reg |= PORT_PCS_CTRL_1000;
+		reg |= PORT_PCS_CTRL_SPEED_1000;
 		break;
 	case SPEED_100:
-		reg |= PORT_PCS_CTRL_100;
+		reg |= PORT_PCS_CTRL_SPEED_100;
 		break;
 	case SPEED_10:
-		reg |= PORT_PCS_CTRL_10;
+		reg |= PORT_PCS_CTRL_SPEED_10;
 		break;
 	default:
 		pr_info("Unknown speed");
@@ -2421,17 +2421,17 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		 */
 		err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
 		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
-			reg &= ~PORT_PCS_CTRL_UNFORCED;
+			reg &= ~PORT_PCS_CTRL_SPEED_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
 				PORT_PCS_CTRL_FORCE_DUPLEX;
 			if (mv88e6xxx_6065_family(chip))
-				reg |= PORT_PCS_CTRL_100;
+				reg |= PORT_PCS_CTRL_SPEED_100;
 			else
-				reg |= PORT_PCS_CTRL_1000;
+				reg |= PORT_PCS_CTRL_SPEED_1000;
 		} else {
-			reg |= PORT_PCS_CTRL_UNFORCED;
+			reg |= PORT_PCS_CTRL_SPEED_UNFORCED;
 		}
 
 		err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
@@ -3162,6 +3162,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3170,6 +3171,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3178,6 +3180,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3186,6 +3189,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3194,6 +3198,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3202,6 +3207,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.phy_write = mv88e6xxx_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3210,6 +3216,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3221,6 +3228,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
+	.port_set_speed = mv88e6352_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3229,6 +3237,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3240,6 +3249,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
+	.port_set_speed = mv88e6352_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3248,6 +3258,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.phy_write = mv88e6xxx_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3259,6 +3270,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
+	.port_set_speed = mv88e6352_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3269,6 +3281,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3279,6 +3292,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3287,6 +3301,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3295,6 +3310,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_speed = mv88e6185_port_set_speed,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3306,6 +3322,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
+	.port_set_speed = mv88e6352_port_set_speed,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index c7527c0..9296130 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -61,16 +61,22 @@
 #define PORT_PCS_CTRL		0x01
 #define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
 #define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
+#define PORT_PCS_CTRL_FORCE_SPEED	BIT(13) /* 6390 */
+#define PORT_PCS_CTRL_ALTSPEED		BIT(12) /* 6390 */
+#define PORT_PCS_CTRL_200BASE		BIT(12) /* 6352 */
 #define PORT_PCS_CTRL_FC		BIT(7)
 #define PORT_PCS_CTRL_FORCE_FC		BIT(6)
 #define PORT_PCS_CTRL_LINK_UP		BIT(5)
 #define PORT_PCS_CTRL_FORCE_LINK	BIT(4)
 #define PORT_PCS_CTRL_DUPLEX_FULL	BIT(3)
 #define PORT_PCS_CTRL_FORCE_DUPLEX	BIT(2)
-#define PORT_PCS_CTRL_10		0x00
-#define PORT_PCS_CTRL_100		0x01
-#define PORT_PCS_CTRL_1000		0x02
-#define PORT_PCS_CTRL_UNFORCED		0x03
+#define PORT_PCS_CTRL_SPEED_MASK	(0x03)
+#define PORT_PCS_CTRL_SPEED_10		(0x00)
+#define PORT_PCS_CTRL_SPEED_100		(0x01)
+#define PORT_PCS_CTRL_SPEED_200		(0x02) /* 6065 and non Gb chips */
+#define PORT_PCS_CTRL_SPEED_1000	(0x02)
+#define PORT_PCS_CTRL_SPEED_10000	(0x03) /* 6390X */
+#define PORT_PCS_CTRL_SPEED_UNFORCED	(0x03)
 #define PORT_PAUSE_CTRL		0x02
 #define PORT_SWITCH_ID		0x03
 #define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
@@ -752,6 +758,16 @@ struct mv88e6xxx_ops {
 	 * or DUPLEX_UNFORCED for normal duplex detection.
 	 */
 	int (*port_set_duplex)(struct mv88e6xxx_chip *chip, int port, int dup);
+
+#define SPEED_MAX		INT_MAX
+#define SPEED_UNFORCED		-2
+
+	/* Port's MAC speed (in Mbps)
+	 *
+	 * Depending on the chip, 10, 100, 200, 1000, 2500, 10000 are valid.
+	 * Use SPEED_UNFORCED for normal detection, SPEED_MAX for max value.
+	 */
+	int (*port_set_speed)(struct mv88e6xxx_chip *chip, int port, int speed);
 };
 
 enum stat_type {
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 838068d..18eeed0 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -33,6 +33,10 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 /* Offset 0x01: MAC (or PCS or Physical) Control Register
  *
  * Link, Duplex and Flow Control have one force bit, one value bit.
+ *
+ * For port's MAC speed, ForceSpd (or SpdValue) bits 1:0 program the value.
+ * Alternative values require the 200BASE (or AltSpeed) bit 12 set.
+ * Newer chips need a ForcedSpd bit 13 set to consider the value.
  */
 
 static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
@@ -165,6 +169,140 @@ int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
 	return 0;
 }
 
+static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
+				    int speed, bool alt_bit, bool force_bit)
+{
+	u16 reg, ctrl;
+	int err;
+
+	switch (speed) {
+	case 10:
+		ctrl = PORT_PCS_CTRL_SPEED_10;
+		break;
+	case 100:
+		ctrl = PORT_PCS_CTRL_SPEED_100;
+		break;
+	case 200:
+		if (alt_bit)
+			ctrl = PORT_PCS_CTRL_SPEED_100 | PORT_PCS_CTRL_ALTSPEED;
+		else
+			ctrl = PORT_PCS_CTRL_SPEED_200;
+		break;
+	case 1000:
+		ctrl = PORT_PCS_CTRL_SPEED_1000;
+		break;
+	case 2500:
+		ctrl = PORT_PCS_CTRL_SPEED_1000 | PORT_PCS_CTRL_ALTSPEED;
+		break;
+	case 10000:
+		/* all bits set, fall through... */
+	case SPEED_UNFORCED:
+		ctrl = PORT_PCS_CTRL_SPEED_UNFORCED;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_PCS_CTRL_SPEED_MASK;
+	if (alt_bit)
+		reg &= ~PORT_PCS_CTRL_ALTSPEED;
+	if (force_bit) {
+		reg &= ~PORT_PCS_CTRL_FORCE_SPEED;
+		if (speed)
+			ctrl |= PORT_PCS_CTRL_FORCE_SPEED;
+	}
+	reg |= ctrl;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	if (err)
+		return err;
+
+	if (speed)
+		netdev_dbg(chip->ds->ports[port].netdev,
+			   "Speed set to %d Mbps\n", speed);
+	else
+		netdev_dbg(chip->ds->ports[port].netdev, "Speed unforced\n");
+
+	return 0;
+}
+
+/* Support 10, 100, 200 Mbps (e.g. 88E6065 family) */
+int mv88e6065_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
+{
+	if (speed == SPEED_MAX)
+		speed = 200;
+
+	if (speed > 200)
+		return -EOPNOTSUPP;
+
+	/* Setting 200 Mbps on port 0 to 3 selects 100 Mbps */
+	return mv88e6xxx_port_set_speed(chip, port, speed, false, false);
+}
+
+/* Support 10, 100, 1000 Mbps (e.g. 88E6185 family) */
+int mv88e6185_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
+{
+	if (speed == SPEED_MAX)
+		speed = 1000;
+
+	if (speed == 200 || speed > 1000)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_speed(chip, port, speed, false, false);
+}
+
+/* Support 10, 100, 200, 1000 Mbps (e.g. 88E6352 family) */
+int mv88e6352_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
+{
+	if (speed == SPEED_MAX)
+		speed = 1000;
+
+	if (speed > 1000)
+		return -EOPNOTSUPP;
+
+	if (speed == 200 && port < 5)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_speed(chip, port, speed, true, false);
+}
+
+/* Support 10, 100, 200, 1000, 2500 Mbps (e.g. 88E6390) */
+int mv88e6390_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
+{
+	if (speed == SPEED_MAX)
+		speed = port < 9 ? 1000 : 2500;
+
+	if (speed > 2500)
+		return -EOPNOTSUPP;
+
+	if (speed == 200 && port != 0)
+		return -EOPNOTSUPP;
+
+	if (speed == 2500 && port < 9)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_speed(chip, port, speed, true, true);
+}
+
+/* Support 10, 100, 200, 1000, 2500, 10000 Mbps (e.g. 88E6190X) */
+int mv88e6390x_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
+{
+	if (speed == SPEED_MAX)
+		speed = port < 9 ? 1000 : 10000;
+
+	if (speed == 200 && port != 0)
+		return -EOPNOTSUPP;
+
+	if (speed >= 2500 && port < 9)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_speed(chip, port, speed, true, true);
+}
+
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 3472b79..499129c 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -30,6 +30,12 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link);
 
 int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup);
 
+int mv88e6065_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed);
+int mv88e6185_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed);
+int mv88e6352_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed);
+int mv88e6390_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed);
+int mv88e6390x_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed);
+
 int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
-- 
2.10.2
