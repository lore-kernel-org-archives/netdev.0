From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH v2] net/phy: micrel: Add clock support for KSZ8021/KSZ8031
Date: Fri, 10 Oct 2014 09:48:05 +0200
Message-ID: <1412927285-6809-1-git-send-email-s.hauer@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de, Sascha Hauer <s.hauer@pengutronix.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42569 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaJJHsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 03:48:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The KSZ8021 and KSZ8031 support RMII reference input clocks of 25MHz
and 50MHz. Both PHYs differ in the default frequency they expect
after reset. If this differs from the actual input clock, then
register 0x1f bit 7 must be changed.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---

Changes since v1:

- Move clock handling to the probe callback
- Bail out with an error for invalid clock rates

 Documentation/devicetree/bindings/net/micrel.txt |  6 +++++
 drivers/net/phy/micrel.c                         | 31 ++++++++++++++++++++++--
 include/linux/micrel_phy.h                       |  1 +
 3 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index 98a3e61..e1d99b9 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -16,3 +16,9 @@ Optional properties:
 	      KSZ8051: register 0x1f, bits 5..4
 
               See the respective PHY datasheet for the mode values.
+
+ - clocks, clock-names: contains clocks according to the common clock bindings.
+
+              supported clocks:
+	      - KSZ8021, KSZ8031: "rmii-ref": The RMII refence input clock. Used
+		to determine the XI input clock.
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 011dbda..492435f 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -26,6 +26,7 @@
 #include <linux/phy.h>
 #include <linux/micrel_phy.h>
 #include <linux/of.h>
+#include <linux/clk.h>
 
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
@@ -72,9 +73,12 @@ static int ksz_config_flags(struct phy_device *phydev)
 {
 	int regval;
 
-	if (phydev->dev_flags & MICREL_PHY_50MHZ_CLK) {
+	if (phydev->dev_flags & (MICREL_PHY_50MHZ_CLK | MICREL_PHY_25MHZ_CLK)) {
 		regval = phy_read(phydev, MII_KSZPHY_CTRL);
-		regval |= KSZ8051_RMII_50MHZ_CLK;
+		if (phydev->dev_flags & MICREL_PHY_50MHZ_CLK)
+			regval |= KSZ8051_RMII_50MHZ_CLK;
+		else
+			regval &= ~KSZ8051_RMII_50MHZ_CLK;
 		return phy_write(phydev, MII_KSZPHY_CTRL, regval);
 	}
 	return 0;
@@ -440,6 +444,27 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 {
 }
 
+static int ksz8021_probe(struct phy_device *phydev)
+{
+	struct clk *clk;
+
+	clk = devm_clk_get(&phydev->dev, "rmii-ref");
+	if (!IS_ERR(clk)) {
+		unsigned long rate = clk_get_rate(clk);
+
+		if (rate > 24500000 && rate < 25500000) {
+			phydev->dev_flags |= MICREL_PHY_25MHZ_CLK;
+		} else if (rate > 49500000 && rate < 50500000) {
+			phydev->dev_flags |= MICREL_PHY_50MHZ_CLK;
+		} else {
+			dev_err(&phydev->dev, "Clock rate out of range: %ld\n", rate);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
 static struct phy_driver ksphy_driver[] = {
 {
 	.phy_id		= PHY_ID_KS8737,
@@ -462,6 +487,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.probe		= ksz8021_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -477,6 +503,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.probe		= ksz8021_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 2e5b194..53d33de 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -37,6 +37,7 @@
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
+#define MICREL_PHY_25MHZ_CLK	0x00000002
 
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
-- 
2.1.1
