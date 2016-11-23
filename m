From: <Woojung.Huh@microchip.com>
Subject: [PATCH net] phy: fix error case of phy_led_triggers_(un)register
Date: Wed, 23 Nov 2016 21:39:37 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>
To: <zach.brown@ni.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:42446 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752437AbcKWVka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 16:40:30 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

When phy_init_hw() fails at phy_attach_direct();
- phy_detach() calls phy_led_triggers_unregister() without 
  previous call of phy_led_triggers_register().
- still call phy_led_triggers_register() and cause memory leak.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/phy_device.c       | 6 +++---
 drivers/net/phy/phy_led_triggers.c | 3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9e8f048..094a959 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -915,10 +915,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	err = phy_init_hw(phydev);
 	if (err)
 		phy_detach(phydev);
-	else
+	else {
 		phy_resume(phydev);
-
-	phy_led_triggers_register(phydev);
+		phy_led_triggers_register(phydev);
+	}
 
 	return err;
 
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index cda600a..3b0b726 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -128,6 +128,9 @@ void phy_led_triggers_unregister(struct phy_device *phy)
 {
 	int i;
 
+	if (!phy->phy_num_led_triggers)
+		return;
+
 	for (i = 0; i < phy->phy_num_led_triggers; i++)
 		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
 
-- 
2.7.4
