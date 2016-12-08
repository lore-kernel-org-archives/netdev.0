From: Shaohui Xie <Shaohui.Xie@nxp.com>
Subject: [PATCH] net: gianfar: add ethtool eee support
Date: Thu, 8 Dec 2016 19:27:06 +0800
Message-ID: <1481196426-45576-1-git-send-email-Shaohui.Xie@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0073.outbound.protection.outlook.com ([104.47.34.73]:63778
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752672AbcLHMOD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 07:14:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gianfar does not support EEE, but it can connect to a PHY which supports
EEE and the PHY advertises EEE by default, and its link partner also
advertises EEE, so the PHY enters low power mode when traffic rate is low,
which causes packet loss if an application's traffic rate is low. This
patch provides .get_eee and .set_eee so that to disable the EEE
advertisement via ethtool if needed, other EEE features are not supported.

Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 28 ++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 56588f2..9375078 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -184,6 +184,32 @@ static void gfar_gdrvinfo(struct net_device *dev,
 	strlcpy(drvinfo->bus_info, "N/A", sizeof(drvinfo->bus_info));
 }
 
+static int gfar_get_eee(struct net_device *dev, struct ethtool_eee *et_eee)
+{
+	struct phy_device *phydev = dev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_get_eee(phydev, et_eee);
+}
+
+static int gfar_set_eee(struct net_device *dev, struct ethtool_eee *et_eee)
+{
+	struct phy_device *phydev = dev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	if (et_eee->eee_enabled ||
+	    et_eee->tx_lpi_enabled ||
+	    et_eee->tx_lpi_timer) {
+		return -EOPNOTSUPP;
+	}
+
+	return phy_ethtool_set_eee(phydev, et_eee);
+}
+
 /* Return the length of the register structure */
 static int gfar_reglen(struct net_device *dev)
 {
@@ -1548,6 +1574,8 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.get_strings = gfar_gstrings,
 	.get_sset_count = gfar_sset_count,
 	.get_ethtool_stats = gfar_fill_stats,
+	.get_eee = gfar_get_eee,
+	.set_eee = gfar_set_eee,
 	.get_msglevel = gfar_get_msglevel,
 	.set_msglevel = gfar_set_msglevel,
 #ifdef CONFIG_PM
-- 
2.1.0.27.g96db324
