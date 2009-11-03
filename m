From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/20] broadcom: Fix slow link problem
Date: Mon, 2 Nov 2009 16:28:33 -0800
Message-ID: <1257212002.22016@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3429 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757619AbZKCBd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a 50610 or 50610M is paired against particular remote partners,
link is slow to come up.  This patch works around the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 9e574ce..1a2b2f2 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -242,12 +242,6 @@ static int bcm50610_a0_workaround(struct phy_device *phydev)
 {
 	int err;
 
-	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP08,
-				MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	|
-				MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE);
-	if (err < 0)
-		return err;
-
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH0,
 				MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN |
 				MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF);
@@ -287,8 +281,20 @@ static int bcm54xx_phydsp_config(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	if (phydev->drv->phy_id == PHY_ID_BCM50610)
-		err = bcm50610_a0_workaround(phydev);
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
+	    BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) {
+		/* Clear bit 9 to fix a phy interop issue. */
+		err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP08,
+					MII_BCM54XX_EXP_EXP08_RJCT_2MHZ);
+		if (err < 0)
+			goto error;
+
+		if (phydev->drv->phy_id == PHY_ID_BCM50610) {
+			err = bcm50610_a0_workaround(phydev);
+			if (err < 0)
+				goto error;
+		}
+	}
 
 	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM57780) {
 		int val;
-- 
1.6.4.4


