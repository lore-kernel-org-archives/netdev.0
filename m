From: Fabio Estevam <fabio.estevam@nxp.com>
Subject: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Wed, 18 May 2016 13:05:00 -0300
Message-ID: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <u.kleine-koenig@pengutronix.de>, <linux@roeck-us.net>,
	<f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0091.outbound.protection.outlook.com ([207.46.100.91]:6048
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752603AbcERQUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 12:20:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit da47b4572056 ("phy: add support for a reset-gpio specification")
causes the following xtensa qemu crash according to Guenter Roeck:

[    9.366256] libphy: ethoc-mdio: probed
[    9.367389]  (null): could not attach to PHY
[    9.368555]  (null): failed to probe MDIO bus
[    9.371540] Unable to handle kernel paging request at virtual address 0000001c
[    9.371540]  pc = d0320926, ra = 903209d1
[    9.375358] Oops: sig: 11 [#1]

This reverts commit da47b4572056487fd7941c26f73b3e8815ff712a.

Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 3 ---
 drivers/net/phy/phy_device.c                  | 8 --------
 2 files changed, 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index c00a9a8..bc1c3c8 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -35,8 +35,6 @@ Optional Properties:
 - broken-turn-around: If set, indicates the PHY device does not correctly
   release the turn around line low at the end of a MDIO transaction.
 
-- reset-gpios: Reference to a GPIO used to reset the phy.
-
 Example:
 
 ethernet-phy@0 {
@@ -44,5 +42,4 @@ ethernet-phy@0 {
 	interrupt-parent = <40000>;
 	interrupts = <35 1>;
 	reg = <0>;
-	reset-gpios = <&gpio1 17 GPIO_ACTIVE_LOW>;
 };
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 307f72a..e977ba9 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -34,7 +34,6 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/of.h>
-#include <linux/gpio/consumer.h>
 
 #include <asm/irq.h>
 
@@ -1571,16 +1570,9 @@ static int phy_probe(struct device *dev)
 	struct device_driver *drv = phydev->mdio.dev.driver;
 	struct phy_driver *phydrv = to_phy_driver(drv);
 	int err = 0;
-	struct gpio_descs *reset_gpios;
 
 	phydev->drv = phydrv;
 
-	/* take phy out of reset */
-	reset_gpios = devm_gpiod_get_array_optional(dev, "reset",
-						    GPIOD_OUT_LOW);
-	if (IS_ERR(reset_gpios))
-		return PTR_ERR(reset_gpios);
-
 	/* Disable the interrupt if the PHY doesn't support it
 	 * but the interrupt is still a valid one
 	 */
-- 
1.9.1
