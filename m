From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe-phy: Fix initial mode when autoneg is disabled
Date: Tue, 26 May 2015 09:51:49 -0500
Message-ID: <20150526145149.29899.24836.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0146.outbound.protection.outlook.com ([65.55.169.146]:42170
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753369AbbEZOw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 10:52:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ethtool command is used to set the speed of the device while
the device is down, the check to set the initial mode may fail when
the device is brought up, causing failure to bring the device up.

Update the code to set the initial mode based on the desired speed if
auto-negotiation is disabled.

This patch fixes a bug introduced by:
d9663c8c2149 ("amd-xgbe-phy: Use phydev advertising field vs supported")

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   45 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index fb276f6..34a75cb 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -755,6 +755,45 @@ static int amd_xgbe_phy_set_mode(struct phy_device *phydev,
 	return ret;
 }
 
+static bool amd_xgbe_phy_use_xgmii_mode(struct phy_device *phydev)
+{
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		if (phydev->advertising & ADVERTISED_10000baseKR_Full)
+			return true;
+	} else {
+		if (phydev->speed == SPEED_10000)
+			return true;
+	}
+
+	return false;
+}
+
+static bool amd_xgbe_phy_use_gmii_2500_mode(struct phy_device *phydev)
+{
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		if (phydev->advertising & ADVERTISED_2500baseX_Full)
+			return true;
+	} else {
+		if (phydev->speed == SPEED_2500)
+			return true;
+	}
+
+	return false;
+}
+
+static bool amd_xgbe_phy_use_gmii_mode(struct phy_device *phydev)
+{
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		if (phydev->advertising & ADVERTISED_1000baseKX_Full)
+			return true;
+	} else {
+		if (phydev->speed == SPEED_1000)
+			return true;
+	}
+
+	return false;
+}
+
 static int amd_xgbe_phy_set_an(struct phy_device *phydev, bool enable,
 			       bool restart)
 {
@@ -1235,11 +1274,11 @@ static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 	/* Set initial mode - call the mode setting routines
 	 * directly to insure we are properly configured
 	 */
-	if (phydev->advertising & SUPPORTED_10000baseKR_Full)
+	if (amd_xgbe_phy_use_xgmii_mode(phydev))
 		ret = amd_xgbe_phy_xgmii_mode(phydev);
-	else if (phydev->advertising & SUPPORTED_1000baseKX_Full)
+	else if (amd_xgbe_phy_use_gmii_mode(phydev))
 		ret = amd_xgbe_phy_gmii_mode(phydev);
-	else if (phydev->advertising & SUPPORTED_2500baseX_Full)
+	else if (amd_xgbe_phy_use_gmii_2500_mode(phydev))
 		ret = amd_xgbe_phy_gmii_2500_mode(phydev);
 	else
 		ret = -EINVAL;
