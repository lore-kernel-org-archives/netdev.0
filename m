From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net] phy: fix error case of phy_led_triggers_(un)register
Date: Wed, 23 Nov 2016 23:10:33 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40969DE2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <davem@davemloft.net>, <zach.brown@ni.com>,
        <netdev@vger.kernel.org>, <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:40979 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934818AbcKWXKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 18:10:35 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

When phy_init_hw() fails at phy_attach_direct();
- phy_detach() calls phy_led_triggers_unregister() without
  previous call of phy_led_triggers_register().
- still call phy_led_triggers_register() and cause memory leak.

Fixes: 2e0bc452f472 ("net: phy: leds: add support for led triggers on phy link state change")
Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/phy_device.c       | 6 +++---
 drivers/net/phy/phy_led_triggers.c | 2 --
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9e8f048..ba86c19 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -914,15 +914,15 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	 */
 	err = phy_init_hw(phydev);
 	if (err)
-		phy_detach(phydev);
-	else
-		phy_resume(phydev);
+		goto error;
 
+	phy_resume(phydev);
 	phy_led_triggers_register(phydev);
 
 	return err;
 
 error:
+	phy_detach(phydev);
 	put_device(d);
 	module_put(bus->owner);
 	return err;
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index cda600a..fa62bdf 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -130,7 +130,5 @@ void phy_led_triggers_unregister(struct phy_device *phy)
 
 	for (i = 0; i < phy->phy_num_led_triggers; i++)
 		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
-
-	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
 }
 EXPORT_SYMBOL_GPL(phy_led_triggers_unregister);
-- 
2.7.4
