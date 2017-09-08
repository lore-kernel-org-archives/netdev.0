From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] Revert "mdio_bus: Remove unneeded gpiod NULL check"
Date: Fri,  8 Sep 2017 15:38:07 -0700
Message-ID: <20170908223807.6015-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linus.walleij@linaro.org, andrew@lunn.ch,
        festevam@gmail.com, sergei.shtylyov@cogentembedded.com,
        fabio.estevam@nxp.com, Bryan.Whitehead@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33253 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752952AbdIHWiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 18:38:15 -0400
Received: by mail-qk0-f195.google.com with SMTP id g128so2318635qke.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 15:38:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 95b80bf3db03c2bf572a357cf74b9a6aefef0a4a ("mdio_bus:
Remove unneeded gpiod NULL check"), this commit assumed that GPIOLIB
checks for NULL descriptors, so it's safe to drop them, but it is not
when CONFIG_GPIOLIB is disabled in the kernel. If we do call
gpiod_set_value_cansleep() on a GPIO descriptor we will issue warnings
coming from the inline stubs declared in include/linux/gpio/consumer.h.

Fixes: 95b80bf3db03 ("mdio_bus: Remove unneeded gpiod NULL check")
Reported-by: Woojung Huh <Woojung.Huh@microchip.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index b6f9fa670168..2df7b62c1a36 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -399,7 +399,8 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 	}
 
 	/* Put PHYs in RESET to save power */
-	gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+	if (bus->reset_gpiod)
+		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 	return err;
@@ -424,7 +425,8 @@ void mdiobus_unregister(struct mii_bus *bus)
 	}
 
 	/* Put PHYs in RESET to save power */
-	gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+	if (bus->reset_gpiod)
+		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 }
-- 
2.9.3
