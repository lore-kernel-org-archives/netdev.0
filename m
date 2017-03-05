From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: phy: Do not perform software reset for Generic PHY
Date: Sun,  5 Mar 2017 12:34:49 -0800
Message-ID: <20170305203449.14035-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, nbd@nbd.name,
        john@phrozen.org, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:35878 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdCEUey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 15:34:54 -0500
Received: by mail-ot0-f193.google.com with SMTP id i1so15627838ota.3
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 12:34:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Generic PHY driver is a catch-all PHY driver and it should preserve
whatever prior initialization has been done by boot loader or firmware
agents. For specific PHY device configuration it is expected that a
specialized PHY driver would take over that role.

Resetting the generic PHY was a bad idea that has lead to several
complaints and downstream workarounds e.g: in OpenWrt/LEDE so restore
the behavior prior to 87aa9f9c61ad ("net: phy: consolidate PHY
reset in phy_init_hw()").

Reported-by: Felix Fietkau <nbd@nbd.name>
Fixes: 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 2 +-
 include/linux/phy.h          | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index daec6555f3b1..5198ccfa347f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1864,7 +1864,7 @@ static struct phy_driver genphy_driver[] = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
-	.soft_reset	= genphy_soft_reset,
+	.soft_reset	= genphy_no_soft_reset,
 	.config_init	= genphy_config_init,
 	.features	= PHY_GBIT_FEATURES | SUPPORTED_MII |
 			  SUPPORTED_AUI | SUPPORTED_FIBRE |
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 772476028a65..43a774873aa9 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -837,6 +837,10 @@ int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
 int genphy_resume(struct phy_device *phydev);
 int genphy_soft_reset(struct phy_device *phydev);
+static inline int genphy_no_soft_reset(struct phy_device *phydev)
+{
+	return 0;
+}
 void phy_driver_unregister(struct phy_driver *drv);
 void phy_drivers_unregister(struct phy_driver *drv, int n);
 int phy_driver_register(struct phy_driver *new_driver, struct module *owner);
-- 
2.9.3
