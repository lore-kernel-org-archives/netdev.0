From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH net] Revert "mdio_bus: Remove unneeded gpiod NULL check"
Date: Sat, 9 Sep 2017 01:13:14 +0200
Message-ID: <CACRpkdZD-nRXXusX36Gaypf5A601CMEO3vVgaOV5tKufvy1M3Q@mail.gmail.com>
References: <20170908223807.6015-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Bryan.Whitehead@microchip.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35748 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757173AbdIHXNP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:13:15 -0400
Received: by mail-oi0-f48.google.com with SMTP id z73so19214422oia.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 16:13:15 -0700 (PDT)
In-Reply-To: <20170908223807.6015-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 9, 2017 at 12:38 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:

> This reverts commit 95b80bf3db03c2bf572a357cf74b9a6aefef0a4a ("mdio_bus:
> Remove unneeded gpiod NULL check"), this commit assumed that GPIOLIB
> checks for NULL descriptors, so it's safe to drop them, but it is not
> when CONFIG_GPIOLIB is disabled in the kernel. If we do call
> gpiod_set_value_cansleep() on a GPIO descriptor we will issue warnings
> coming from the inline stubs declared in include/linux/gpio/consumer.h.
>
> Fixes: 95b80bf3db03 ("mdio_bus: Remove unneeded gpiod NULL check")
> Reported-by: Woojung Huh <Woojung.Huh@microchip.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Yeah I guess you don't wanna have these messages spewing
in the console. :/

But what about simply doing this:


>From 150e4f3c1f227c9a4c31bbb48d44220e25b792ec Mon Sep 17 00:00:00 2001
From: Linus Walleij <linus.walleij@linaro.org>
Date: Sat, 9 Sep 2017 01:07:22 +0200
Subject: [PATCH] net: phy: mdio_bus: mandate gpiolib

The core mdio bus unconditionally uses gpiolib APIs to handle
reset lines which results in runtime errors when it is compiled
out. It is not supposed to be possible to stub out gpiolib
like this, the error messages from the stubs are a sign that
something is wrong.

So just select it. Fix some unneeded #includes while we're
at it.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/phy/Kconfig    | 1 +
 drivers/net/phy/mdio_bus.c | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a9d16a3af514..b6c5bb9941c3 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -4,6 +4,7 @@

 menuconfig MDIO_DEVICE
     tristate "MDIO bus device drivers"
+    select GPIOLIB
     help
       MDIO devices and driver infrastructure code.

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index b6f9fa670168..9c60f87b7209 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -22,11 +22,9 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/device.h>
-#include <linux/gpio.h>
 #include <linux/gpio/consumer.h>
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
-#include <linux/of_gpio.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-- 
2.13.5

Yours,
Linus Walleij
