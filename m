From: Sebastian Reichel <sre@debian.org>
Subject: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Sun, 27 Oct 2013 17:14:27 +0100
Message-ID: <1382890469-25286-3-git-send-email-sre@debian.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ring0.de ([91.143.88.219]:59044 "EHLO smtp.ring0.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754745Ab3J0QOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 12:14:53 -0400
In-Reply-To: <1382890469-25286-1-git-send-email-sre@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the power GPIO handling from the board code into
the driver. This is a dependency for device tree support.

Signed-off-by: Sebastian Reichel <sre@debian.org>
---
 arch/arm/mach-omap2/board-omap3pandora.c     |  2 ++
 arch/arm/mach-omap2/board-rx51-peripherals.c | 11 ++--------
 drivers/net/wireless/ti/wl1251/sdio.c        | 21 +++++++++++++-----
 drivers/net/wireless/ti/wl1251/spi.c         | 33 ++++++++++++++++++----------
 drivers/net/wireless/ti/wl1251/wl1251.h      |  2 +-
 include/linux/wl12xx.h                       |  2 +-
 6 files changed, 43 insertions(+), 28 deletions(-)

diff --git a/arch/arm/mach-omap2/board-omap3pandora.c b/arch/arm/mach-omap2/board-omap3pandora.c
index 24f3c1b..cf18340 100644
--- a/arch/arm/mach-omap2/board-omap3pandora.c
+++ b/arch/arm/mach-omap2/board-omap3pandora.c
@@ -541,6 +541,8 @@ static void __init pandora_wl1251_init(void)
 
 	memset(&pandora_wl1251_pdata, 0, sizeof(pandora_wl1251_pdata));
 
+	pandora_wl1251_pdata.power_gpio = -1;
+
 	ret = gpio_request_one(PANDORA_WIFI_IRQ_GPIO, GPIOF_IN, "wl1251 irq");
 	if (ret < 0)
 		goto fail;
diff --git a/arch/arm/mach-omap2/board-rx51-peripherals.c b/arch/arm/mach-omap2/board-rx51-peripherals.c
index 0d8e7d2..b9d95dd 100644
--- a/arch/arm/mach-omap2/board-rx51-peripherals.c
+++ b/arch/arm/mach-omap2/board-rx51-peripherals.c
@@ -1164,13 +1164,7 @@ static inline void board_smc91x_init(void)
 
 #endif
 
-static void rx51_wl1251_set_power(bool enable)
-{
-	gpio_set_value(RX51_WL1251_POWER_GPIO, enable);
-}
-
 static struct gpio rx51_wl1251_gpios[] __initdata = {
-	{ RX51_WL1251_POWER_GPIO, GPIOF_OUT_INIT_LOW,	"wl1251 power"	},
 	{ RX51_WL1251_IRQ_GPIO,	  GPIOF_IN,		"wl1251 irq"	},
 };
 
@@ -1187,17 +1181,16 @@ static void __init rx51_init_wl1251(void)
 	if (irq < 0)
 		goto err_irq;
 
-	wl1251_pdata.set_power = rx51_wl1251_set_power;
+	wl1251_pdata.power_gpio = RX51_WL1251_POWER_GPIO;
 	rx51_peripherals_spi_board_info[RX51_SPI_WL1251].irq = irq;
 
 	return;
 
 err_irq:
 	gpio_free(RX51_WL1251_IRQ_GPIO);
-	gpio_free(RX51_WL1251_POWER_GPIO);
 error:
 	printk(KERN_ERR "wl1251 board initialisation failed\n");
-	wl1251_pdata.set_power = NULL;
+	wl1251_pdata.power_gpio = -1;
 
 	/*
 	 * Now rx51_peripherals_spi_board_info[1].irq is zero and
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index b75a37a..b661f89 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -28,6 +28,7 @@
 #include <linux/wl12xx.h>
 #include <linux/irq.h>
 #include <linux/pm_runtime.h>
+#include <linux/gpio.h>
 
 #include "wl1251.h"
 
@@ -182,8 +183,9 @@ static int wl1251_sdio_set_power(struct wl1251 *wl, bool enable)
 		 * callback in case it wants to do any additional setup,
 		 * for example enabling clock buffer for the module.
 		 */
-		if (wl->set_power)
-			wl->set_power(true);
+		if (gpio_is_valid(wl->power_gpio))
+			gpio_set_value(wl->power_gpio, true);
+
 
 		ret = pm_runtime_get_sync(&func->dev);
 		if (ret < 0) {
@@ -203,8 +205,8 @@ static int wl1251_sdio_set_power(struct wl1251 *wl, bool enable)
 		if (ret < 0)
 			goto out;
 
-		if (wl->set_power)
-			wl->set_power(false);
+		if (gpio_is_valid(wl->power_gpio))
+			gpio_set_value(wl->power_gpio, false);
 	}
 
 out:
@@ -256,11 +258,20 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 
 	wl1251_board_data = wl1251_get_platform_data();
 	if (!IS_ERR(wl1251_board_data)) {
-		wl->set_power = wl1251_board_data->set_power;
+		wl->power_gpio = wl1251_board_data->power_gpio;
 		wl->irq = wl1251_board_data->irq;
 		wl->use_eeprom = wl1251_board_data->use_eeprom;
 	}
 
+	if (gpio_is_valid(wl->power_gpio)) {
+		ret = devm_gpio_request(&func->dev, wl->power_gpio,
+								"wl1251 power");
+		if (ret) {
+			wl1251_error("Failed to request gpio: %d\n", ret);
+			goto disable;
+		}
+	}
+
 	if (wl->irq) {
 		irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 		ret = request_irq(wl->irq, wl1251_line_irq, 0, "wl1251", wl);
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 6bbbfe6..9a2df9d 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -26,6 +26,7 @@
 #include <linux/crc7.h>
 #include <linux/spi/spi.h>
 #include <linux/wl12xx.h>
+#include <linux/gpio.h>
 
 #include "wl1251.h"
 #include "reg.h"
@@ -221,8 +222,8 @@ static void wl1251_spi_disable_irq(struct wl1251 *wl)
 
 static int wl1251_spi_set_power(struct wl1251 *wl, bool enable)
 {
-	if (wl->set_power)
-		wl->set_power(enable);
+	if (gpio_is_valid(wl->power_gpio))
+		gpio_set_value(wl->power_gpio, enable);
 
 	return 0;
 }
@@ -271,22 +272,33 @@ static int wl1251_spi_probe(struct spi_device *spi)
 		goto out_free;
 	}
 
-	wl->set_power = pdata->set_power;
-	if (!wl->set_power) {
-		wl1251_error("set power function missing in platform data");
-		return -ENODEV;
+	wl->power_gpio = pdata->power_gpio;
+
+	if (gpio_is_valid(wl->power_gpio)) {
+		ret = devm_gpio_request_one(&spi->dev, wl->power_gpio,
+					GPIOF_OUT_INIT_LOW, "wl1251 power");
+		if (ret) {
+			wl1251_error("Failed to request gpio: %d\n", ret);
+			goto out_free;
+		}
+	} else {
+		wl1251_error("set power gpio missing in platform data");
+		ret = -ENODEV;
+		goto out_free;
 	}
 
 	wl->irq = spi->irq;
 	if (wl->irq < 0) {
 		wl1251_error("irq missing in platform data");
-		return -ENODEV;
+		ret = -ENODEV;
+		goto out_free;
 	}
 
 	wl->use_eeprom = pdata->use_eeprom;
 
 	irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
-	ret = request_irq(wl->irq, wl1251_irq, 0, DRIVER_NAME, wl);
+	ret = devm_request_irq(&spi->dev, wl->irq, wl1251_irq, 0,
+							DRIVER_NAME, wl);
 	if (ret < 0) {
 		wl1251_error("request_irq() failed: %d", ret);
 		goto out_free;
@@ -296,13 +308,10 @@ static int wl1251_spi_probe(struct spi_device *spi)
 
 	ret = wl1251_init_ieee80211(wl);
 	if (ret)
-		goto out_irq;
+		goto out_free;
 
 	return 0;
 
- out_irq:
-	free_irq(wl->irq, wl);
-
  out_free:
 	ieee80211_free_hw(hw);
 
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index fd02060..5e9808c 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -275,7 +275,7 @@ struct wl1251 {
 	void *if_priv;
 	const struct wl1251_if_operations *if_ops;
 
-	void (*set_power)(bool enable);
+	int power_gpio;
 	int irq;
 	bool use_eeprom;
 
diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
index b516b4f..a9c723b 100644
--- a/include/linux/wl12xx.h
+++ b/include/linux/wl12xx.h
@@ -49,7 +49,7 @@ enum {
 };
 
 struct wl1251_platform_data {
-	void (*set_power)(bool enable);
+	int power_gpio;
 	/* SDIO only: IRQ number if WLAN_IRQ line is used, 0 for SDIO IRQs */
 	int irq;
 	bool use_eeprom;
-- 
1.8.4.rc3
