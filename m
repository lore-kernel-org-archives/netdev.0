From: Chris Healy <chealy@imsco-us.com>
Subject: RE: [PATCH 3/3] net: mdio-gpio: Add support for separate MDI and
 MDO 	gpio pins
Date: Wed, 16 Apr 2014 02:45:50 +0000
Message-ID: <724F6C6CDC8C86478473775085778C4E09E85DFE@ImsEx1.ims.dom>
References: <1397614602-29694-1-git-send-email-linux@roeck-us.net>,<1397614602-29694-4-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cphealy@gmail.com" <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397614602-29694-4-git-send-email-linux@roeck-us.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is for a system with fixed assignments of input and output pins
(various variants of Kontron COMe).

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Chris Healy <cphealy@gmail.com>
---
 drivers/net/phy/mdio-gpio.c |   34 +++++++++++++++++++++++++++++++---
 include/linux/mdio-gpio.h   |    2 ++
 2 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index fac211a..9c4defd 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -32,8 +32,8 @@

 struct mdio_gpio_info {
        struct mdiobb_ctrl ctrl;
-       int mdc, mdio;
-       int mdc_active_low, mdio_active_low;
+       int mdc, mdio, mdo;
+       int mdc_active_low, mdio_active_low, mdo_active_low;
 };

 static void *mdio_gpio_of_get_data(struct platform_device *pdev)
@@ -60,6 +60,12 @@ static void *mdio_gpio_of_get_data(struct platform_device *pdev)
        pdata->mdio = ret;
        pdata->mdio_active_low = flags & OF_GPIO_ACTIVE_LOW;

+       ret = of_get_gpio_flags(np, 2, &flags);
+       if (ret > 0) {
+               pdata->mdo = ret;
+               pdata->mdo_active_low = flags & OF_GPIO_ACTIVE_LOW;
+       }
+
        return pdata;
 }

@@ -68,6 +74,16 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
        struct mdio_gpio_info *bitbang =
                container_of(ctrl, struct mdio_gpio_info, ctrl);

+       if (bitbang->mdo) {
+               /* Separate output pin. Always set its value to high
+                * when changing direction. If direction is input,
+                * assume the pin serves as pull-up. If direction is
+                * output, the default value is high.
+                */
+               gpio_set_value(bitbang->mdo, 1 ^ bitbang->mdo_active_low);
+               return;
+       }
+
        if (dir)
                gpio_direction_output(bitbang->mdio,
                                      1 ^ bitbang->mdio_active_low);
@@ -88,7 +104,10 @@ static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
        struct mdio_gpio_info *bitbang =
                container_of(ctrl, struct mdio_gpio_info, ctrl);

-       gpio_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
+       if (bitbang->mdo)
+               gpio_set_value(bitbang->mdo, what ^ bitbang->mdo_active_low);
+       else
+               gpio_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
 }

 static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
@@ -125,6 +144,8 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
        bitbang->mdc_active_low = pdata->mdc_active_low;
        bitbang->mdio = pdata->mdio;
        bitbang->mdio_active_low = pdata->mdio_active_low;
+       bitbang->mdo = pdata->mdo;
+       bitbang->mdo_active_low = pdata->mdo_active_low;

        new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
        if (!new_bus)
@@ -151,6 +172,13 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
        if (devm_gpio_request(dev, bitbang->mdio, "mdio"))
                goto out_free_bus;

+       if (bitbang->mdo) {
+               if (devm_gpio_request(dev, bitbang->mdo, "mdo"))
+                       goto out_free_bus;
+               gpio_direction_output(bitbang->mdo, 1);
+               gpio_direction_input(bitbang->mdio);
+       }
+
        gpio_direction_output(bitbang->mdc, 0);

        dev_set_drvdata(dev, new_bus);
diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
index 57e57fe..66c30a7 100644
--- a/include/linux/mdio-gpio.h
+++ b/include/linux/mdio-gpio.h
@@ -17,9 +17,11 @@ struct mdio_gpio_platform_data {
        /* GPIO numbers for bus pins */
        unsigned int mdc;
        unsigned int mdio;
+       unsigned int mdo;

        bool mdc_active_low;
        bool mdio_active_low;
+       bool mdo_active_low;

        unsigned int phy_mask;
        int irqs[PHY_MAX_ADDR];
--
1.7.9.7


________________________________


This email and any files transmitted with it are confidential & proprietary to Systems and Software Enterprises, LLC. This information is intended solely for the use of the individual or entity to which it is addressed. Access or transmittal of the information contained in this e-mail, in full or in part, to any other organization or persons is not authorized.
