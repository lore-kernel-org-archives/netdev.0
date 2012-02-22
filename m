From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2] netdev/phy/icplus: Correct broken phy_init code
Date: Wed, 22 Feb 2012 08:24:57 +0100
Message-ID: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
Cc: David McKay <david.mckay@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:44908 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055Ab2BVHZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:25:22 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C085C12B
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 07:25:19 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 495EE1708
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 07:25:19 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David McKay <david.mckay@st.com>

The code for ip1001_config_init() was totally broken if you were not
using RGMII. Instead of returning an error code or zero it actually
returned the value in the IP1001_SPEC_CTRL_STATUS_2 register. It was
also trying to set the IP1001_APS_ON bit , but never actually wrote
back the register.

The error checking was also incorrect in both this function and the
reset function, so this patch fixes that up in a consistent fashion.

Signed-off-by: David McKay <david.mckay@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index c81f136..7ee4f58 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -98,20 +98,24 @@ static int ip175c_config_init(struct phy_device *phydev)
 
 static int ip1xx_reset(struct phy_device *phydev)
 {
-	int err, bmcr;
+	int bmcr;
 
 	/* Software Reset PHY */
 	bmcr = phy_read(phydev, MII_BMCR);
+	if (bmcr < 0)
+		return bmcr;
 	bmcr |= BMCR_RESET;
-	err = phy_write(phydev, MII_BMCR, bmcr);
-	if (err < 0)
-		return err;
+	bmcr = phy_write(phydev, MII_BMCR, bmcr);
+	if (bmcr < 0)
+		return bmcr;
 
 	do {
 		bmcr = phy_read(phydev, MII_BMCR);
+		if (bmcr < 0)
+			return bmcr;
 	} while (bmcr & BMCR_RESET);
 
-	return err;
+	return 0;
 }
 
 static int ip1001_config_init(struct phy_device *phydev)
@@ -124,7 +128,10 @@ static int ip1001_config_init(struct phy_device *phydev)
 
 	/* Enable Auto Power Saving mode */
 	c = phy_read(phydev, IP1001_SPEC_CTRL_STATUS_2);
+	if (c < 0)
+		return c;
 	c |= IP1001_APS_ON;
+	c = phy_write(phydev, IP1001_SPEC_CTRL_STATUS_2, c);
 	if (c < 0)
 		return c;
 
@@ -132,11 +139,16 @@ static int ip1001_config_init(struct phy_device *phydev)
 		/* Additional delay (2ns) used to adjust RX clock phase
 		 * at RGMII interface */
 		c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
+		if (c < 0)
+			return c;
+
 		c |= IP1001_PHASE_SEL_MASK;
 		c = phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
+		if (c < 0)
+			return c;
 	}
 
-	return c;
+	return 0;
 }
 
 static int ip101a_config_init(struct phy_device *phydev)
-- 
1.7.4.4
