From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: phy: Fix PHY unbind crash
Date: Fri, 17 Feb 2017 16:07:33 -0800
Message-ID: <20170218000734.32590-2-f.fainelli@gmail.com>
References: <20170218000734.32590-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35355 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbdBRAOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 19:14:30 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so4997085wmu.2
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 16:14:29 -0800 (PST)
In-Reply-To: <20170218000734.32590-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library does not deal very well with bind and unbind events. The first
thing we would see is that we were not properly canceling the PHY state machine
workqueue, so we would be crashing while dereferencing phydev->drv since there
is no driver attached anymore.

Suggested-by: Russell King <rmk+kernel@armlinux.org.uk>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8c8e15b8739d..7f9319586b7e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1784,6 +1784,8 @@ static int phy_remove(struct device *dev)
 {
 	struct phy_device *phydev = to_phy_device(dev);
 
+	cancel_delayed_work_sync(&phydev->state_queue);
+
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);
-- 
2.9.3
