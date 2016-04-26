From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: phy: at803x: only the AT8030 needs a hardware reset on link change
Date: Tue, 26 Apr 2016 12:44:18 -0500
Message-ID: <1461692658-1742-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59344 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbcDZRoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:44:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 13a56b44 ("at803x: Add support for hardware reset") added a
work-around for a hardware bug on the AT8030.  However, the work-around
was being called for all 803x PHYs, even those that don't need it.
Function at803x_link_change_notify() checks to make sure that it only
resets the PHY on the 8030, but it makes more sense to not call that
function at all if it isn't needed.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/phy/at803x.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index b3ffaee..f279a89 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -359,27 +359,25 @@ static void at803x_link_change_notify(struct phy_device *phydev)
 	 * in the FIFO. In such cases, the FIFO enters an error mode it
 	 * cannot recover from by software.
 	 */
-	if (phydev->drv->phy_id == ATH8030_PHY_ID) {
-		if (phydev->state == PHY_NOLINK) {
-			if (priv->gpiod_reset && !priv->phy_reset) {
-				struct at803x_context context;
-
-				at803x_context_save(phydev, &context);
-
-				gpiod_set_value(priv->gpiod_reset, 1);
-				msleep(1);
-				gpiod_set_value(priv->gpiod_reset, 0);
-				msleep(1);
-
-				at803x_context_restore(phydev, &context);
-
-				phydev_dbg(phydev, "%s(): phy was reset\n",
-					   __func__);
-				priv->phy_reset = true;
-			}
-		} else {
-			priv->phy_reset = false;
+	if (phydev->state == PHY_NOLINK) {
+		if (priv->gpiod_reset && !priv->phy_reset) {
+			struct at803x_context context;
+
+			at803x_context_save(phydev, &context);
+
+			gpiod_set_value(priv->gpiod_reset, 1);
+			msleep(1);
+			gpiod_set_value(priv->gpiod_reset, 0);
+			msleep(1);
+
+			at803x_context_restore(phydev, &context);
+
+			phydev_dbg(phydev, "%s(): phy was reset\n",
+				   __func__);
+			priv->phy_reset = true;
 		}
+	} else {
+		priv->phy_reset = false;
 	}
 }
 
@@ -391,7 +389,6 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id_mask		= 0xffffffef,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
-	.link_change_notify	= at803x_link_change_notify,
 	.set_wol		= at803x_set_wol,
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
@@ -427,7 +424,6 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id_mask		= 0xffffffef,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
-	.link_change_notify	= at803x_link_change_notify,
 	.set_wol		= at803x_set_wol,
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
