From: Stefan Hauser <stefan@shauser.net>
Subject: [PATCH] net: phy: dp83867: Fix initialization of PHYCR register
Date: Fri,  1 Jul 2016 22:35:03 +0200
Message-ID: <1467405303-19212-1-git-send-email-stefan@shauser.net>
Cc: f.fainelli@gmail.com, Stefan Hauser <stefan@shauser.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx24.sysproserver.de ([79.133.52.76]:43532 "EHLO
	mx24.sysproserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcGAVBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 17:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initializing the PHY control register, the FIFO depth bits are
written without reading the previous register value, i.e. all other
bits are overwritten with zero. This disables automatic MDI-X
configuration, which is enabled by default. Fix initialization by doing
a read/modify/write operation.

Signed-off-by: Stefan Hauser <stefan@shauser.net>
---
 drivers/net/phy/dp83867.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 2afa61b..91177a4 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -57,6 +57,7 @@
 
 /* PHY CTRL bits */
 #define DP83867_PHYCR_FIFO_DEPTH_SHIFT		14
+#define DP83867_PHYCR_FIFO_DEPTH_MASK		(3 << 14)
 
 /* RGMIIDCTL bits */
 #define DP83867_RGMII_TX_CLK_DELAY_SHIFT	4
@@ -133,8 +134,8 @@ static int dp83867_of_init(struct phy_device *phydev)
 static int dp83867_config_init(struct phy_device *phydev)
 {
 	struct dp83867_private *dp83867;
-	int ret;
-	u16 val, delay;
+	int ret, val;
+	u16 delay;
 
 	if (!phydev->priv) {
 		dp83867 = devm_kzalloc(&phydev->mdio.dev, sizeof(*dp83867),
@@ -151,8 +152,12 @@ static int dp83867_config_init(struct phy_device *phydev)
 	}
 
 	if (phy_interface_is_rgmii(phydev)) {
-		ret = phy_write(phydev, MII_DP83867_PHYCTRL,
-			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
+		val = phy_read(phydev, MII_DP83867_PHYCTRL);
+		if (val < 0)
+			return val;
+		val &= ~DP83867_PHYCR_FIFO_DEPTH_MASK;
+		val |= (dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT);
+		ret = phy_write(phydev, MII_DP83867_PHYCTRL, val);
 		if (ret)
 			return ret;
 	}
-- 
1.9.1
