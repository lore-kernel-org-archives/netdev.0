From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/3] amd-xgbe: Fix initial mode when
 auto-negotiation is disabled
Date: Fri, 22 May 2015 16:32:14 -0500
Message-ID: <20150522213214.23869.91808.stgit@tlendack-t1.amdoffice.net>
References: <20150522213202.23869.67673.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0140.outbound.protection.outlook.com ([157.56.111.140]:34816
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756757AbbEVVca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 17:32:30 -0400
In-Reply-To: <20150522213202.23869.67673.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ethtool command is used to set the speed of the device while
the device is down, the check to set the initial mode may fail when
the device is brought up, causing failure to bring the device up.

Update the code to set the initial mode based on the desired speed if
auto-negotiation is disabled.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   45 +++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index cea19a3..8b86d94 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -376,6 +376,45 @@ static void xgbe_set_mode(struct xgbe_prv_data *pdata,
 		xgbe_switch_mode(pdata);
 }
 
+static bool xgbe_use_xgmii_mode(struct xgbe_prv_data *pdata)
+{
+	if (pdata->phy.autoneg == AUTONEG_ENABLE) {
+		if (pdata->phy.advertising & ADVERTISED_10000baseKR_Full)
+			return true;
+	} else {
+		if (pdata->phy.speed == SPEED_10000)
+			return true;
+	}
+
+	return false;
+}
+
+static bool xgbe_use_gmii_2500_mode(struct xgbe_prv_data *pdata)
+{
+	if (pdata->phy.autoneg == AUTONEG_ENABLE) {
+		if (pdata->phy.advertising & ADVERTISED_2500baseX_Full)
+			return true;
+	} else {
+		if (pdata->phy.speed == SPEED_2500)
+			return true;
+	}
+
+	return false;
+}
+
+static bool xgbe_use_gmii_mode(struct xgbe_prv_data *pdata)
+{
+	if (pdata->phy.autoneg == AUTONEG_ENABLE) {
+		if (pdata->phy.advertising & ADVERTISED_1000baseKX_Full)
+			return true;
+	} else {
+		if (pdata->phy.speed == SPEED_1000)
+			return true;
+	}
+
+	return false;
+}
+
 static void xgbe_set_an(struct xgbe_prv_data *pdata, bool enable, bool restart)
 {
 	unsigned int reg;
@@ -1108,11 +1147,11 @@ static int xgbe_phy_start(struct xgbe_prv_data *pdata)
 	/* Set initial mode - call the mode setting routines
 	 * directly to insure we are properly configured
 	 */
-	if (pdata->phy.advertising & ADVERTISED_10000baseKR_Full) {
+	if (xgbe_use_xgmii_mode(pdata)) {
 		xgbe_xgmii_mode(pdata);
-	} else if (pdata->phy.advertising & ADVERTISED_1000baseKX_Full) {
+	} else if (xgbe_use_gmii_mode(pdata)) {
 		xgbe_gmii_mode(pdata);
-	} else if (pdata->phy.advertising & ADVERTISED_2500baseX_Full) {
+	} else if (xgbe_use_gmii_2500_mode(pdata)) {
 		xgbe_gmii_2500_mode(pdata);
 	} else {
 		ret = -EINVAL;
