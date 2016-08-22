From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/4] net: dsa: mv88e6xxx: Fix support for DSA tagging for older switches.
Date: Mon, 22 Aug 2016 16:01:02 +0200
Message-ID: <1471874464-16142-3-git-send-email-andrew@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40567 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751032AbcHVOMX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:12:23 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older chips only support DSA tagging on the CPU port. New devices
support both DSA and EDSA. The driver needs to tell the core the tag
protocol to use, and configure the switch for what is available.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/Kconfig     |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 41 +++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 16 +++++++++++---
 3 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
index 490bc06f993e..ac77737bbd87 100644
--- a/drivers/net/dsa/mv88e6xxx/Kconfig
+++ b/drivers/net/dsa/mv88e6xxx/Kconfig
@@ -2,6 +2,7 @@ config NET_DSA_MV88E6XXX
 	tristate "Marvell 88E6xxx Ethernet switch fabric support"
 	depends on NET_DSA
 	select NET_DSA_TAG_EDSA
+	select NET_DSA_TAG_DSA
 	help
 	  This driver adds support for most of the Marvell 88E6xxx models of
 	  Ethernet switch chips, except 88E6060.
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 63cad6c00bc7..b315769aa5be 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2483,28 +2483,13 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
 	if (dsa_is_cpu_port(ds, port)) {
-		if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip))
-			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(chip) ||
-		    mv88e6xxx_6351_family(chip) ||
-		    mv88e6xxx_6165_family(chip) ||
-		    mv88e6xxx_6097_family(chip) ||
-		    mv88e6xxx_6320_family(chip)) {
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
 			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
 				PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
-		}
-
-		if (mv88e6xxx_6352_family(chip) ||
-		    mv88e6xxx_6351_family(chip) ||
-		    mv88e6xxx_6165_family(chip) ||
-		    mv88e6xxx_6097_family(chip) ||
-		    mv88e6xxx_6095_family(chip) ||
-		    mv88e6xxx_6065_family(chip) ||
-		    mv88e6xxx_6185_family(chip) ||
-		    mv88e6xxx_6320_family(chip)) {
-			reg |= PORT_CONTROL_EGRESS_ADD_TAG;
-		}
+		else
+			reg |= PORT_CONTROL_DSA_TAG;
+		reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 	}
 	if (dsa_is_dsa_port(ds, port)) {
 		if (mv88e6xxx_6095_family(chip) ||
@@ -2632,10 +2617,13 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_ETH_TYPE, ETH_P_EDSA);
-		if (ret)
-			return ret;
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA)) {
+			ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
+						   PORT_ETH_TYPE, ETH_P_EDSA);
+			if (ret)
+				return ret;
+		}
+
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
@@ -3926,7 +3914,12 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 
 static enum dsa_tag_protocol mv88e6xxx_get_tag_protocol(struct dsa_switch *ds)
 {
-	return DSA_TAG_PROTO_EDSA;
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
+		return DSA_TAG_PROTO_EDSA;
+
+	return DSA_TAG_PROTO_DSA;
 }
 
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 1f9bab5891b1..e157d4f69864 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -386,6 +386,12 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* Two different tag protocols can be used by the driver. All
+	 * switches support DSA, but only later generations support
+	 * EDSA.
+	 */
+	MV88E6XXX_CAP_EDSA,
+
 	/* Energy Efficient Ethernet.
 	 */
 	MV88E6XXX_CAP_EEE,
@@ -447,6 +453,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_EDSA		BIT(MV88E6XXX_CAP_EDSA)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 
 #define MV88E6XXX_FLAG_SMI_CMD		BIT(MV88E6XXX_CAP_SMI_CMD)
@@ -547,7 +554,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EDSA |		\
+	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -564,7 +572,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_SMI_PHY)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_EDSA |		\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
@@ -579,7 +588,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_SMI_PHY)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EDSA |		\
+	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-- 
2.8.1
