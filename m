From: Lukasz Majewski <lukma@denx.de>
Subject: [PATCH v2 2/2] net: phy: dp83867: Recover from "port mirroring" N/A MODE4
Date: Sat,  4 Feb 2017 17:02:12 +0100
Message-ID: <1486224132-15420-2-git-send-email-lukma@denx.de>
References: <1486224132-15420-1-git-send-email-lukma@denx.de>
Cc: Lukasz Majewski <lukma@denx.de>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34614 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdBDQCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:02:39 -0500
In-Reply-To: <1486224132-15420-1-git-send-email-lukma@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DP83867 when not properly bootstrapped - especially with LED_0 pin -
can enter N/A MODE4 for "port mirroring" feature.

To provide normal operation of the PHY, one needs not only to explicitly
disable the port mirroring feature, but as well stop some IC internal
testing (which disables RGMII communication).

To do that the STRAP_STS1 (0x006E) register must be read and RESERVED bit
11 examined. When it is set, the another RESERVED bit (11) at PHYCR
(0x0010) register must be clear to disable testing mode and enable RGMII
communication.

Thorough explanation of the problem can be found at following e2e thread:
"DP83867IR: Problem with RESERVED bits in PHY Control Register (PHYCR) -
Linux driver"

https://e2e.ti.com/support/interface/ethernet/f/903/p/571313/2096954#2096954

Signed-off-by: Lukasz Majewski <lukma@denx.de>
---
 drivers/net/phy/dp83867.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index b5f0c2d..7a4208e 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -34,6 +34,7 @@
 /* Extended Registers */
 #define DP83867_CFG4            0x0031
 #define DP83867_RGMIICTL	0x0032
+#define DP83867_STRAP_STS1	0x006E
 #define DP83867_RGMIIDCTL	0x0086
 #define DP83867_IO_MUX_CFG	0x0170
 
@@ -58,9 +59,13 @@
 #define DP83867_RGMII_TX_CLK_DELAY_EN		BIT(1)
 #define DP83867_RGMII_RX_CLK_DELAY_EN		BIT(0)
 
+/* STRAP_STS1 bits */
+#define DP83867_STRAP_STS1_RESERVED		BIT(11)
+
 /* PHY CTRL bits */
 #define DP83867_PHYCR_FIFO_DEPTH_SHIFT		14
 #define DP83867_PHYCR_FIFO_DEPTH_MASK		(3 << 14)
+#define DP83867_PHYCR_RESERVED_MASK		BIT(11)
 
 /* RGMIIDCTL bits */
 #define DP83867_RGMII_TX_CLK_DELAY_SHIFT	4
@@ -191,7 +196,7 @@ static int dp83867_of_init(struct phy_device *phydev)
 static int dp83867_config_init(struct phy_device *phydev)
 {
 	struct dp83867_private *dp83867;
-	int ret, val;
+	int ret, val, bs;
 	u16 delay;
 
 	if (!phydev->priv) {
@@ -214,6 +219,22 @@ static int dp83867_config_init(struct phy_device *phydev)
 			return val;
 		val &= ~DP83867_PHYCR_FIFO_DEPTH_MASK;
 		val |= (dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT);
+
+		/* The code below checks if "port mirroring" N/A MODE4 has been
+		 * enabled during power on bootstrap.
+		 *
+		 * Such N/A mode enabled by mistake can put PHY IC in some
+		 * internal testing mode and disable RGMII transmission.
+		 *
+		 * In this particular case one needs to check STRAP_STS1
+		 * register's bit 11 (marked as RESERVED).
+		 */
+
+		bs = phy_read_mmd_indirect(phydev, DP83867_STRAP_STS1,
+					   DP83867_DEVADDR);
+		if (bs & DP83867_STRAP_STS1_RESERVED)
+			val &= ~DP83867_PHYCR_RESERVED_MASK;
+
 		ret = phy_write(phydev, MII_DP83867_PHYCTRL, val);
 		if (ret)
 			return ret;
-- 
2.1.4
