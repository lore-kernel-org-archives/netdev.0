From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v4 net-next 1/5] net: dsa: lan9303: Change lan9303_xxx_packet_processing() port param.
Date: Sat,  5 Aug 2017 13:05:46 +0200
Message-ID: <20170805110550.26337-2-privat@egil-hjelmeland.no>
References: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lan9303_enable_packet_processing, lan9303_disable_packet_processing()
Pass port number (0,1,2) as parameter instead of port offset.
Because other functions in the module pass port numbers.
And to enable simplifications in following patch.

Introduce lan9303_write_switch_port().

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/lan9303-core.c | 46 +++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 8e430d1ee297..77f3cee3af0d 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -159,9 +159,7 @@
 # define LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT1 (BIT(9) | BIT(8))
 # define LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0 (BIT(1) | BIT(0))
 
-#define LAN9303_PORT_0_OFFSET 0x400
-#define LAN9303_PORT_1_OFFSET 0x800
-#define LAN9303_PORT_2_OFFSET 0xc00
+#define LAN9303_SWITCH_PORT_REG(port, reg0) (0x400 * (port) + (reg0))
 
 /* the built-in PHYs are of type LAN911X */
 #define MII_LAN911X_SPECIAL_MODES 0x12
@@ -428,6 +426,13 @@ static int lan9303_read_switch_reg(struct lan9303 *chip, u16 regnum, u32 *val)
 	return ret;
 }
 
+static int lan9303_write_switch_port(struct lan9303 *chip, int port,
+				     u16 regnum, u32 val)
+{
+	return lan9303_write_switch_reg(
+		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
+}
+
 static int lan9303_detect_phy_setup(struct lan9303 *chip)
 {
 	int reg;
@@ -458,22 +463,19 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	return 0;
 }
 
-#define LAN9303_MAC_RX_CFG_OFFS (LAN9303_MAC_RX_CFG_0 - LAN9303_PORT_0_OFFSET)
-#define LAN9303_MAC_TX_CFG_OFFS (LAN9303_MAC_TX_CFG_0 - LAN9303_PORT_0_OFFSET)
-
 static int lan9303_disable_packet_processing(struct lan9303 *chip,
 					     unsigned int port)
 {
 	int ret;
 
 	/* disable RX, but keep register reset default values else */
-	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_OFFS + port,
-				       LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES);
+	ret = lan9303_write_switch_port(chip, port, LAN9303_MAC_RX_CFG_0,
+					LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES);
 	if (ret)
 		return ret;
 
 	/* disable TX, but keep register reset default values else */
-	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_OFFS + port,
+	return lan9303_write_switch_port(chip, port, LAN9303_MAC_TX_CFG_0,
 				LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
 				LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE);
 }
@@ -484,14 +486,14 @@ static int lan9303_enable_packet_processing(struct lan9303 *chip,
 	int ret;
 
 	/* enable RX and keep register reset default values else */
-	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_OFFS + port,
-				       LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES |
-				       LAN9303_MAC_RX_CFG_X_RX_ENABLE);
+	ret = lan9303_write_switch_port(chip, port, LAN9303_MAC_RX_CFG_0,
+					LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES |
+					LAN9303_MAC_RX_CFG_X_RX_ENABLE);
 	if (ret)
 		return ret;
 
 	/* enable TX and keep register reset default values else */
-	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_OFFS + port,
+	return lan9303_write_switch_port(chip, port, LAN9303_MAC_TX_CFG_0,
 				LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
 				LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE |
 				LAN9303_MAC_TX_CFG_X_TX_ENABLE);
@@ -558,13 +560,13 @@ static int lan9303_disable_processing(struct lan9303 *chip)
 {
 	int ret;
 
-	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
+	ret = lan9303_disable_packet_processing(chip, 0);
 	if (ret)
 		return ret;
-	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
+	ret = lan9303_disable_packet_processing(chip, 1);
 	if (ret)
 		return ret;
-	return lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
+	return lan9303_disable_packet_processing(chip, 2);
 }
 
 static int lan9303_check_device(struct lan9303 *chip)
@@ -634,7 +636,7 @@ static int lan9303_setup(struct dsa_switch *ds)
 	if (ret)
 		dev_err(chip->dev, "failed to separate ports %d\n", ret);
 
-	ret = lan9303_enable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
+	ret = lan9303_enable_packet_processing(chip, 0);
 	if (ret)
 		dev_err(chip->dev, "failed to re-enable switching %d\n", ret);
 
@@ -757,11 +759,9 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	/* enable internal packet processing */
 	switch (port) {
 	case 1:
-		return lan9303_enable_packet_processing(chip,
-							LAN9303_PORT_1_OFFSET);
+		return lan9303_enable_packet_processing(chip, port);
 	case 2:
-		return lan9303_enable_packet_processing(chip,
-							LAN9303_PORT_2_OFFSET);
+		return lan9303_enable_packet_processing(chip, port);
 	default:
 		dev_dbg(chip->dev,
 			"Error: request to power up invalid port %d\n", port);
@@ -778,12 +778,12 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	/* disable internal packet processing */
 	switch (port) {
 	case 1:
-		lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
+		lan9303_disable_packet_processing(chip, port);
 		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
 				  MII_BMCR, BMCR_PDOWN);
 		break;
 	case 2:
-		lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
+		lan9303_disable_packet_processing(chip, port);
 		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
 				  MII_BMCR, BMCR_PDOWN);
 		break;
-- 
2.11.0
