From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: phy: allow PHY drivers to implement their own software reset
Date: Mon, 17 Feb 2014 12:52:45 -0800
Message-ID: <1392670366-31457-3-git-send-email-f.fainelli@gmail.com>
References: <1392670366-31457-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:40434 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbaBQUxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:12 -0500
In-Reply-To: <1392670366-31457-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Shaohui, most 10G PHYs out there have a non-standard
compliant software reset sequence, eventually something much more
complex than just toggling the BMCR_RESET bit. Allow PHY driver to
implement their own soft_reset() callback to deal with that. If no
callback is provided, call into genphy_soft_reset() which makes sure the
existing behavior is kept intact.

Reported-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 16 ++++++++++++++--
 include/linux/phy.h          |  5 +++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 7c21b82..e6bbe1b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -535,12 +535,16 @@ static int phy_poll_reset(struct phy_device *phydev)
 
 int phy_init_hw(struct phy_device *phydev)
 {
-	int ret;
+	int ret = 0;
 
 	if (!phydev->drv || !phydev->drv->config_init)
 		return 0;
 
-	ret = genphy_soft_reset(phydev);
+	if (phydev->drv->soft_reset(phydev))
+		ret = phydev->drv->soft_reset(phydev);
+	else
+		ret = genphy_soft_reset(phydev);
+
 	if (ret < 0)
 		return ret;
 
@@ -1108,6 +1112,12 @@ static int genphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int gen10g_soft_reset(struct phy_device *phydev)
+{
+	/* Do nothing for now */
+	return 0;
+}
+
 static int gen10g_config_init(struct phy_device *phydev)
 {
 	/* Temporarily just say we support everything */
@@ -1282,6 +1292,7 @@ static struct phy_driver genphy_driver[] = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
+	.soft_reset	= genphy_soft_reset,
 	.config_init	= genphy_config_init,
 	.features	= 0,
 	.config_aneg	= genphy_config_aneg,
@@ -1294,6 +1305,7 @@ static struct phy_driver genphy_driver[] = {
 	.phy_id         = 0xffffffff,
 	.phy_id_mask    = 0xffffffff,
 	.name           = "Generic 10G PHY",
+	.soft_reset	= gen10g_soft_reset,
 	.config_init    = gen10g_config_init,
 	.features       = 0,
 	.config_aneg    = gen10g_config_aneg,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index bffe0ec..24126c4 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -440,6 +440,11 @@ struct phy_driver {
 	u32 flags;
 
 	/*
+	 * Called to issue a PHY software reset
+	 */
+	int (*soft_reset)(struct phy_device *phydev);
+
+	/*
 	 * Called to initialize the PHY,
 	 * including after a reset
 	 */
-- 
1.8.3.2
