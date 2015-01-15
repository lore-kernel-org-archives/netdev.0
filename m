From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH_V5] dm9000: Add regulator and reset support to dm9000
Date: Thu, 15 Jan 2015 10:12:26 +0000
Message-ID: <1421316746-38128-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Zubair.Kakakhel@imgtec.com>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<s.hauer@pengutronix.de>, <sergei.shtylyov@cogentembedded.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In boards, the dm9000 chip's power and reset can be controlled by gpio.

It makes sense to add them to the dm9000 driver and let dt be used to
enable power and reset the phy.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Signed-off-by: Paul Burton <paul.burton@imgtec.com>

---
V4 Reordered an error check. PTR_ERR inside IS_ERR.

V3 Fixed an indentation and removed a call to gpio_direction_output as
devm_gpio_request_one can handle it.

V2 A few fixes and more error checks. Nothing major

V1 Minor blooper
---
 .../devicetree/bindings/net/davicom-dm9000.txt     |  4 +++
 drivers/net/ethernet/davicom/dm9000.c              | 40 ++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
index 28767ed..5224bf0 100644
--- a/Documentation/devicetree/bindings/net/davicom-dm9000.txt
+++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
@@ -11,6 +11,8 @@ Required properties:
 Optional properties:
 - davicom,no-eeprom : Configuration EEPROM is not available
 - davicom,ext-phy : Use external PHY
+- reset-gpios : phandle of gpio that will be used to reset chip during probe
+- vcc-supply : phandle of regulator that will be used to enable power to chip
 
 Example:
 
@@ -21,4 +23,6 @@ Example:
 		interrupts = <7 4>;
 		local-mac-address = [00 00 de ad be ef];
 		davicom,no-eeprom;
+		reset-gpios = <&gpf 12 GPIO_ACTIVE_LOW>;
+		vcc-supply = <&eth0_power>;
 	};
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index ef0bb58..c0a7813 100644
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
@@ -1426,11 +1429,48 @@ dm9000_probe(struct platform_device *pdev)
 	struct dm9000_plat_data *pdata = dev_get_platdata(&pdev->dev);
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	struct device *dev = &pdev->dev;
 	const unsigned char *mac_src;
 	int ret = 0;
 	int iosize;
 	int i;
 	u32 id_val;
+	int reset_gpios;
+	enum of_gpio_flags flags;
+	struct regulator *power;
+
+	power = devm_regulator_get(dev, "vcc");
+	if (IS_ERR(power)) {
+		if (PTR_ERR(power) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		dev_dbg(dev, "no regulator provided\n");
+	} else {
+		ret = regulator_enable(power);
+		if (ret != 0) {
+			dev_err(dev,
+				"Failed to enable power regulator: %d\n", ret);
+			return ret;
+		}
+		dev_dbg(dev, "regulator enabled\n");
+	}
+
+	reset_gpios = of_get_named_gpio_flags(dev->of_node, "reset-gpios", 0,
+					      &flags);
+	if (gpio_is_valid(reset_gpios)) {
+		ret = devm_gpio_request_one(dev, reset_gpios, flags,
+					    "dm9000_reset");
+		if (ret) {
+			dev_err(dev, "failed to request reset gpio %d: %d\n",
+				reset_gpios, ret);
+			return -ENODEV;
+		}
+
+		/* According to manual PWRST# Low Period Min 1ms */
+		msleep(2);
+		gpio_set_value(reset_gpios, 1);
+		/* Needs 3ms to read eeprom when PWRST is deasserted */
+		msleep(4);
+	}
 
 	if (!pdata) {
 		pdata = dm9000_parse_dt(&pdev->dev);
-- 
1.9.1
