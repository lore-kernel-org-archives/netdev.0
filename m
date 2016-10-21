From: Xo Wang <xow@google.com>
Subject: [PATCH 2/2] net: phy: broadcom: Add support for BCM54612E
Date: Fri, 21 Oct 2016 10:20:13 -0700
Message-ID: <1477070413-92621-3-git-send-email-xow@google.com>
References: <1477070413-92621-1-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        joel@jms.id.au, Xo Wang <xow@google.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477070413-92621-1-git-send-email-xow@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This PHY has internal delays enabled after reset. This clears the
internal delay enables unless the interface specifically requests them.

Signed-off-by: Xo Wang <xow@google.com>
---
 drivers/net/phy/broadcom.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/brcmphy.h    |  1 +
 2 files changed, 49 insertions(+)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 870327e..583ef8a 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -337,6 +337,41 @@ static int bcm5481_config_aneg(struct phy_device *phydev)
 	return ret;
 }
 
+static int bcm54612e_config_aneg(struct phy_device *phydev)
+{
+	int ret;
+
+	/* First, auto-negotiate. */
+	ret = genphy_config_aneg(phydev);
+
+	/* Clear TX internal delay unless requested. */
+	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
+	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_TXID)) {
+		/* Disable TXD to GTXCLK clock delay (default set) */
+		/* Bit 9 is the only field in shadow register 00011 */
+		bcm_phy_write_shadow(phydev, 0x03, 0);
+	}
+
+	/* Clear RX internal delay unless requested. */
+	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
+	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_RXID)) {
+		u16 reg;
+
+		/* Errata: reads require filling in the write selector field */
+		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+				     MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC);
+		reg = phy_read(phydev, MII_BCM54XX_AUX_CTL);
+		/* Disable RXD to RXC delay (default set) */
+		reg &= ~MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW;
+		/* Clear shadow selector field */
+		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MASK;
+		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+				     MII_BCM54XX_AUXCTL_MISC_WREN | reg);
+	}
+
+	return ret;
+}
+
 static int brcm_phy_setbits(struct phy_device *phydev, int reg, int set)
 {
 	int val;
@@ -485,6 +520,18 @@ static struct phy_driver broadcom_drivers[] = {
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
 }, {
+	.phy_id		= PHY_ID_BCM54612E,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM54612E",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= bcm54612e_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm_phy_ack_intr,
+	.config_intr	= bcm_phy_config_intr,
+}, {
 	.phy_id		= PHY_ID_BCM54616S,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM54616S",
@@ -600,6 +647,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM5411, 0xfffffff0 },
 	{ PHY_ID_BCM5421, 0xfffffff0 },
 	{ PHY_ID_BCM5461, 0xfffffff0 },
+	{ PHY_ID_BCM54612E, 0xfffffff0 },
 	{ PHY_ID_BCM54616S, 0xfffffff0 },
 	{ PHY_ID_BCM5464, 0xfffffff0 },
 	{ PHY_ID_BCM5481, 0xfffffff0 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 22c4421..60def78 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -18,6 +18,7 @@
 #define PHY_ID_BCM5421			0x002060e0
 #define PHY_ID_BCM5464			0x002060b0
 #define PHY_ID_BCM5461			0x002060c0
+#define PHY_ID_BCM54612E		0x03625e60
 #define PHY_ID_BCM54616S		0x03625d10
 #define PHY_ID_BCM57780			0x03625d90
 
-- 
2.8.0.rc3.226.g39d4020
