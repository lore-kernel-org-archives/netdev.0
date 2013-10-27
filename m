From: Sebastian Reichel <sre@debian.org>
Subject: [PATCH 4/4] wl1251: spi: add device tree support
Date: Sun, 27 Oct 2013 17:14:29 +0100
Message-ID: <1382890469-25286-5-git-send-email-sre@debian.org>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@arm.linux.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felipe Balbi <balbi@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Sebastian Reichel <sre@debian.org>
To: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1382890469-25286-1-git-send-email-sre@debian.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree support for the spi variant of wl1251
and document the binding.

Signed-off-by: Sebastian Reichel <sre@debian.org>
---
 .../devicetree/bindings/net/wireless/ti,wl1251.txt | 36 ++++++++++++++++++++++
 drivers/net/wireless/ti/wl1251/spi.c               | 23 ++++++++++----
 2 files changed, 53 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt

diff --git a/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
new file mode 100644
index 0000000..5f8a154
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
@@ -0,0 +1,36 @@
+* Texas Instruments wl1251 controller
+
+The wl1251 chip can be connected via SPI or via SDIO. The linux
+kernel currently only supports device tree for the SPI variant.
+
+Required properties:
+- compatible : Should be "ti,wl1251"
+- interrupts : Should contain interrupt line
+- interrupt-parent : Should be the phandle for the interrupt
+  controller that services interrupts for this device
+- vio-supply : phandle to regulator providing VIO
+- power-gpio : GPIO connected to chip's PMEN pin
+- For additional required properties on SPI, please consult
+  Documentation/devicetree/bindings/spi/spi-bus.txt
+
+Optional properties:
+- ti,use-eeprom : If found, configuration will be loaded from eeprom.
+
+Examples:
+
+&spi1 {
+	wl1251_spi@0 {
+		compatible = "ti,wl1251";
+
+		reg = <0>;
+		spi-max-frequency = <48000000>;
+		spi-cpol;
+		spi-cpha;
+
+		interrupt-parent = <&gpio2>;
+		interrupts = <10 IRQ_TYPE_NONE>; /* gpio line 42 */
+
+		vio-supply = <&vio>;
+		power-gpio = <&gpio3 23 GPIO_ACTIVE_HIGH>; /* 87 */
+	};
+};
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index efea57a..ee6ce4c 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -27,6 +27,8 @@
 #include <linux/spi/spi.h>
 #include <linux/wl12xx.h>
 #include <linux/gpio.h>
+#include <linux/of.h>
+#include <linux/of_gpio.h>
 #include <linux/regulator/consumer.h>
 
 #include "wl1251.h"
@@ -240,13 +242,13 @@ static const struct wl1251_if_operations wl1251_spi_ops = {
 
 static int wl1251_spi_probe(struct spi_device *spi)
 {
-	struct wl1251_platform_data *pdata;
+	struct wl1251_platform_data *pdata = spi->dev.platform_data;
+	struct device_node *np = spi->dev.of_node;
 	struct ieee80211_hw *hw;
 	struct wl1251 *wl;
 	int ret;
 
-	pdata = spi->dev.platform_data;
-	if (!pdata) {
+	if (!np && !pdata) {
 		wl1251_error("no platform data");
 		return -ENODEV;
 	}
@@ -273,7 +275,18 @@ static int wl1251_spi_probe(struct spi_device *spi)
 		goto out_free;
 	}
 
-	wl->power_gpio = pdata->power_gpio;
+	if (np) {
+		wl->use_eeprom = of_property_read_bool(np, "ti,use-eeprom");
+		wl->power_gpio = of_get_named_gpio(np, "power-gpio", 0);
+	} else if (pdata) {
+		wl->power_gpio = pdata->power_gpio;
+		wl->use_eeprom = pdata->use_eeprom;
+	}
+
+	if (wl->power_gpio == -EPROBE_DEFER) {
+		ret = -EPROBE_DEFER;
+		goto out_free;
+	}
 
 	if (gpio_is_valid(wl->power_gpio)) {
 		ret = devm_gpio_request_one(&spi->dev, wl->power_gpio,
@@ -295,8 +308,6 @@ static int wl1251_spi_probe(struct spi_device *spi)
 		goto out_free;
 	}
 
-	wl->use_eeprom = pdata->use_eeprom;
-
 	irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 	ret = devm_request_irq(&spi->dev, wl->irq, wl1251_irq, 0,
 							DRIVER_NAME, wl);
-- 
1.8.4.rc3

