From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: phy: keep track of the PHY suspend state
Date: Mon, 26 Jan 2015 16:31:12 -0800
Message-ID: <1422318673-9418-4-git-send-email-f.fainelli@gmail.com>
References: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44842 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336AbbA0Abm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:31:42 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so15259389pdj.9
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 16:31:41 -0800 (PST)
In-Reply-To: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid double calls to phydev->drv->suspend and resume, keep
track of whether the PHY has already been suspended as a consequence of
a successful call to phy_suspend(). We will use this in our MDIO bus
suspend/resume hooks to avoid a double suspend call.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 22 ++++++++++++++++++----
 include/linux/phy.h          |  2 ++
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3fc91e89f5a5..c90cecc0fe15 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -699,6 +699,7 @@ int phy_suspend(struct phy_device *phydev)
 {
 	struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
 	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
+	int ret = 0;
 
 	/* If the device has WOL enabled, we cannot suspend the PHY */
 	phy_ethtool_get_wol(phydev, &wol);
@@ -706,18 +707,31 @@ int phy_suspend(struct phy_device *phydev)
 		return -EBUSY;
 
 	if (phydrv->suspend)
-		return phydrv->suspend(phydev);
-	return 0;
+		ret = phydrv->suspend(phydev);
+
+	if (ret)
+		return ret;
+
+	phydev->suspended = true;
+
+	return ret;
 }
 EXPORT_SYMBOL(phy_suspend);
 
 int phy_resume(struct phy_device *phydev)
 {
 	struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
+	int ret;
 
 	if (phydrv->resume)
-		return phydrv->resume(phydev);
-	return 0;
+		ret = phydrv->resume(phydev);
+
+	if (ret)
+		return ret;
+
+	phydev->suspended = false;
+
+	return ret;
 }
 EXPORT_SYMBOL(phy_resume);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 1b3690b597d5..685809835b5c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -328,6 +328,7 @@ struct phy_c45_device_ids {
  * is_c45:  Set to true if this phy uses clause 45 addressing.
  * is_internal: Set to true if this phy is internal to a MAC.
  * has_fixups: Set to true if this phy has fixups/quirks.
+ * suspended: Set to true if this phy has been suspended successfully.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
  * addr: Bus address of PHY
@@ -365,6 +366,7 @@ struct phy_device {
 	bool is_c45;
 	bool is_internal;
 	bool has_fixups;
+	bool suspended;
 
 	enum phy_state state;
 
-- 
2.1.0
