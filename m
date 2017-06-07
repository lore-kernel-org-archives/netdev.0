From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 03/13] net: dsa: lan9303: Refactor
 lan9303_enable_packet_processing()
Date: Wed, 7 Jun 2017 16:58:59 +0200
Message-ID: <5877a7f72aca445984e3815a0709b965@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta5.messagelabs.com ([195.245.231.149]:16223 "EHLO
        mail1.bemta5.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756510AbdGXPmJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lan9303_enable_packet_processing, lan9303_disable_packet_processing()
Pass port number (0,1,2) as parameter instead of port offset.
Simplify accordingly.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 66 ++++++++++++++++++++----------------------
 1 file changed, 32 insertions(+), 34 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index c2b53659f58f..0806a0684d55 100644
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
@@ -457,24 +455,25 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
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
+	ret = lan9303_write_switch_reg(
+			chip,
+			LAN9303_SWITCH_PORT_REG(port, LAN9303_MAC_RX_CFG_0),
+			LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES);
 	if (ret)
 		return ret;
 
 	/* disable TX, but keep register reset default values else */
-	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_OFFS + port,
-				LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
-				LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE);
+	return lan9303_write_switch_reg(
+			chip,
+			LAN9303_SWITCH_PORT_REG(port, LAN9303_MAC_TX_CFG_0),
+			LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
+			LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE);
 }
 
 static int lan9303_enable_packet_processing(struct lan9303 *chip,
@@ -483,17 +482,21 @@ static int lan9303_enable_packet_processing(struct lan9303 *chip,
 	int ret;
 
 	/* enable RX and keep register reset default values else */
-	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_OFFS + port,
-				       LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES |
-				       LAN9303_MAC_RX_CFG_X_RX_ENABLE);
+	ret = lan9303_write_switch_reg(
+			chip,
+			LAN9303_SWITCH_PORT_REG(port, LAN9303_MAC_RX_CFG_0),
+			LAN9303_MAC_RX_CFG_X_REJECT_MAC_TYPES |
+			LAN9303_MAC_RX_CFG_X_RX_ENABLE);
 	if (ret)
 		return ret;
 
 	/* enable TX and keep register reset default values else */
-	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_OFFS + port,
-				LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
-				LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE |
-				LAN9303_MAC_TX_CFG_X_TX_ENABLE);
+	return lan9303_write_switch_reg(
+			chip,
+			LAN9303_SWITCH_PORT_REG(port, LAN9303_MAC_TX_CFG_0),
+			LAN9303_MAC_TX_CFG_X_TX_IFG_CONFIG_DEFAULT |
+			LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE |
+			LAN9303_MAC_TX_CFG_X_TX_ENABLE);
 }
 
 /* We want a special working switch:
@@ -555,12 +558,14 @@ static int lan9303_handle_reset(struct lan9303 *chip)
 /* stop processing packets for all ports */
 static int lan9303_disable_processing(struct lan9303 *chip)
 {
-	int ret;
+	int ret, p;
 
-	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
-	if (ret)
-		return ret;
-	return lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
+	for (p = 1; p <= 2; p++) {
+		ret = lan9303_disable_packet_processing(chip, p);
+		if (ret)
+			return ret;
+	}
+	return 0;
 }
 
 static int lan9303_check_device(struct lan9303 *chip)
@@ -696,7 +701,7 @@ static void lan9303_get_ethtool_stats(struct dsa_switch *ds, int port,
 	unsigned int u, poff;
 	int ret;
 
-	poff = port * 0x400;
+	poff = LAN9303_SWITCH_PORT_REG(port, 0);
 
 	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
 		ret = lan9303_read_switch_reg(chip,
@@ -749,11 +754,8 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	/* enable internal packet processing */
 	switch (port) {
 	case 1:
-		return lan9303_enable_packet_processing(chip,
-							LAN9303_PORT_1_OFFSET);
 	case 2:
-		return lan9303_enable_packet_processing(chip,
-							LAN9303_PORT_2_OFFSET);
+		return lan9303_enable_packet_processing(chip, port);
 	default:
 		dev_dbg(chip->dev,
 			"Error: request to power up invalid port %d\n", port);
@@ -770,13 +772,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	/* disable internal packet processing */
 	switch (port) {
 	case 1:
-		lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
-		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
-				  MII_BMCR, BMCR_PDOWN);
-		break;
 	case 2:
-		lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
-		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
+		lan9303_disable_packet_processing(chip, port);
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
 				  MII_BMCR, BMCR_PDOWN);
 		break;
 	default:
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
