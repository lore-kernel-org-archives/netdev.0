From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] phylib: Fix auto-negotiation restart avoidance
Date: Mon, 17 Nov 2008 13:33:25 -0800
Message-ID: <1226957605-5407-1-git-send-email-tpiepho@freescale.com>
Cc: Scott Wood <scottwood@freescale.com>,
	Trent Piepho <tpiepho@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63879 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbYKQVfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 16:35:52 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id mAHLZnD7016705
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 14:35:50 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous patch, 51e2a3846eab18711f4eb59cd0a4c33054e2980a, made
genphy_config_aneg() not restart aneg by calling genphy_restart_aneg() if
the advertisement hadn't changed.

But, genphy_restart_aneg() doesn't just restart aneg, it may also *enable*
aneg or un-isolate the PHY from the MII (those functions are controlled by
the same register).  The code to avoid calling genphy_restart_aneg() didn't
consider this.

So, modify genphy_config_aneg() to also check if the PHY needs to have aneg
enabled or be un-isolated before deciding not to restart aneg.

This caused a problem with certain Davicom PHYs, as that driver isolates
the PHY (why?) before calling genphy_config_aneg() and expects the PHY to
be un-isolated by that function.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
Reported-by: Scott Wood <scottwood@freescale.com>
CC: Andy Fleming <afleming@freescale.com>
---
This fixes a 2.6.28 regression.

 drivers/net/phy/phy_device.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e11b03b..4fe2a53 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -564,20 +564,32 @@ EXPORT_SYMBOL(genphy_restart_aneg);
  */
 int genphy_config_aneg(struct phy_device *phydev)
 {
-	int result = 0;
+	int result;
 
-	if (AUTONEG_ENABLE == phydev->autoneg) {
-		int result = genphy_config_advert(phydev);
+	if (AUTONEG_ENABLE != phydev->autoneg)
+		return genphy_setup_forced(phydev);
+
+	result = genphy_config_advert(phydev);
+
+	if (result < 0) /* error */
+		return result;
 
-		if (result < 0) /* error */
-			return result;
+	if (result == 0) {
+		/* Advertisment hasn't changed, but maybe aneg was never on to
+		 * begin with?  Or maybe phy was isolated? */
+		int ctl = phy_read(phydev, MII_BMCR);
+
+		if (ctl < 0)
+			return ctl;
+
+		if (!(ctl & BMCR_ANENABLE) || (ctl & BMCR_ISOLATE))
+			result = 1; /* do restart aneg */
+	}
 
-		/* Only restart aneg if we are advertising something different
-		 * than we were before.	 */
-		if (result > 0)
-			result = genphy_restart_aneg(phydev);
-	} else
-		result = genphy_setup_forced(phydev);
+	/* Only restart aneg if we are advertising something different
+	 * than we were before.	 */
+	if (result > 0)
+		result = genphy_restart_aneg(phydev);
 
 	return result;
 }
-- 
1.5.4.1

