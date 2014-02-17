From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] net: phy: move PHY software reset to genphy_soft_reset
Date: Mon, 17 Feb 2014 13:34:02 -0800
Message-ID: <1392672844-1767-2-git-send-email-f.fainelli@gmail.com>
References: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:44959 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbaBQVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:34:32 -0500
In-Reply-To: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Shaohui, this function is generic for 10/100/1000
PHYs, but 10G PHYs might have a slightly different reset sequence which
prevents most of them from using this function.

Move the BMCR_RESET based software resent sequence to
genphy_soft_reset() in preparation for allowing PHY drivers to implement
a soft_reset() callback.

Reported-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- respin

 drivers/net/phy/phy_device.c | 27 ++++++++++++++++++++++-----
 include/linux/phy.h          |  1 +
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c2d778d..7c21b82 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -540,11 +540,7 @@ int phy_init_hw(struct phy_device *phydev)
 	if (!phydev->drv || !phydev->drv->config_init)
 		return 0;
 
-	ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
-	if (ret < 0)
-		return ret;
-
-	ret = phy_poll_reset(phydev);
+	ret = genphy_soft_reset(phydev);
 	if (ret < 0)
 		return ret;
 
@@ -1045,6 +1041,27 @@ static int gen10g_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+/**
+ * genphy_soft_reset - software reset the PHY via BMCR_RESET bit
+ * @phydev: target phy_device struct
+ *
+ * Description: Perform a software PHY reset using the standard
+ * BMCR_RESET bit and poll for the reset bit to be cleared.
+ *
+ * Returns: 0 on success, < 0 on failure
+ */
+int genphy_soft_reset(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (ret < 0)
+		return ret;
+
+	return phy_poll_reset(phydev);
+}
+EXPORT_SYMBOL(genphy_soft_reset);
+
 static int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7fe546..bffe0ec 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -666,6 +666,7 @@ int genphy_update_link(struct phy_device *phydev);
 int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
+int genphy_soft_reset(struct phy_device *phydev);
 void phy_driver_unregister(struct phy_driver *drv);
 void phy_drivers_unregister(struct phy_driver *drv, int n);
 int phy_driver_register(struct phy_driver *new_driver);
-- 
1.8.3.2
