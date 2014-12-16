From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] dm9000: Add regulator and reset support to dm9000
Date: Tue, 16 Dec 2014 16:33:44 +0000
Message-ID: <1418747624-2682-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>,
	<Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In boards, the dm9000 chip's power and reset can be controlled by gpio.

It makes sense to add them to the dm9000 driver and let dt be used to
enable power and reset the phy.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Paul Burton <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/davicom-dm9000.txt     |  4 +++
 drivers/net/ethernet/davicom/dm9000.c              | 33 ++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
index 28767ed..dba19a2 100644
--- a/Documentation/devicetree/bindings/net/davicom-dm9000.txt
+++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
@@ -11,6 +11,8 @@ Required properties:
 Optional properties:
 - davicom,no-eeprom : Configuration EEPROM is not available
 - davicom,ext-phy : Use external PHY
+- reset-gpio : phandle of gpio that will be used to reset chip during probe
+- vcc-supply : phandle of regulator that will be used to enable power to chip
 
 Example:
 
@@ -21,4 +23,6 @@ Example:
 		interrupts = <7 4>;
 		local-mac-address = [00 00 de ad be ef];
 		davicom,no-eeprom;
+		reset-gpio = <&gpf 12 GPIO_ACTIVE_LOW>;
+		vcc-supply = <&eth0_power>;
 	};
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index ef0bb58..7333b8d 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -36,6 +36,9 @@
 #include <linux/platform_device.h>
 #include <linux/irq.h>
 #include <linux/slab.h>
+#include <linux/regulator/consumer.h>
+#include <linux/gpio.h>
+#include <linux/of_gpio.h>
 
 #include <asm/delay.h>
 #include <asm/irq.h>
@@ -1426,11 +1429,41 @@ dm9000_probe(struct platform_device *pdev)
 	struct dm9000_plat_data *pdata = dev_get_platdata(&pdev->dev);
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	struct device *dev = &pdev->dev;
 	const unsigned char *mac_src;
 	int ret = 0;
 	int iosize;
 	int i;
 	u32 id_val;
+	int reset_gpio;
+	enum of_gpio_flags flags;
+	struct regulator *power;
+
+	power = devm_regulator_get(dev, "vcc");
+	if (IS_ERR(power)) {
+		dev_dbg(dev, "no regulator provided\n");
+	} else if (!regulator_is_enabled(power)) {
+		ret = regulator_enable(power);
+		dev_dgb(dev, "regulator enabled\n");
+	}
+
+	reset_gpio = of_get_named_gpio_flags(dev->of_node, "reset-gpio", 0,
+					     &flags);
+	if (gpio_is_valid(reset_gpio)) {
+		ret = devm_gpio_request_one(dev, reset_gpio, flags,
+					    "dm9000_reset");
+		if (ret) {
+			dev_err(dev, "failed to request reset gpio %d: %d\n",
+				reset_gpio, ret);
+		} else {
+			gpio_direction_output(reset_gpio, 0);
+			/* According to manual PWRST# Low Period Min 1ms */
+			msleep(2);
+			gpio_direction_output(reset_gpio, 1);
+			/* Needs 3ms to read eeprom when PWRST is deasserted */
+			msleep(4);
+		}
+	}
 
 	if (!pdata) {
 		pdata = dm9000_parse_dt(&pdev->dev);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
