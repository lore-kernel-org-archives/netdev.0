From: Sebastian Reichel <sre@debian.org>
Subject: [PATCH 1/4] wl1251: split wl251 platform data to a separate structure
Date: Sun, 27 Oct 2013 17:14:26 +0100
Message-ID: <1382890469-25286-2-git-send-email-sre@debian.org>
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
	Luciano Coelho <coelho@ti.com>
To: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382890469-25286-1-git-send-email-sre@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luciano Coelho <coelho@ti.com>

Move the wl1251 part of the wl12xx platform data structure into a new
structure specifically for wl1251.  Change the platform data built-in
block and board files accordingly.

Cc: Tony Lindgren <tony@atomide.com>
Signed-off-by: Luciano Coelho <coelho@ti.com>
Acked-by: Tony Lindgren <tony@atomide.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
 arch/arm/mach-omap2/board-omap3pandora.c       |  4 +--
 arch/arm/mach-omap2/board-rx51-peripherals.c   |  2 +-
 drivers/net/wireless/ti/wilink_platform_data.c | 37 +++++++++++++++++++++-----
 drivers/net/wireless/ti/wl1251/sdio.c          | 12 ++++-----
 drivers/net/wireless/ti/wl1251/spi.c           |  2 +-
 include/linux/wl12xx.h                         | 22 ++++++++++++++-
 6 files changed, 62 insertions(+), 17 deletions(-)

diff --git a/arch/arm/mach-omap2/board-omap3pandora.c b/arch/arm/mach-omap2/board-omap3pandora.c
index de1bc6b..24f3c1b 100644
--- a/arch/arm/mach-omap2/board-omap3pandora.c
+++ b/arch/arm/mach-omap2/board-omap3pandora.c
@@ -536,7 +536,7 @@ static struct spi_board_info omap3pandora_spi_board_info[] __initdata = {
 
 static void __init pandora_wl1251_init(void)
 {
-	struct wl12xx_platform_data pandora_wl1251_pdata;
+	struct wl1251_platform_data pandora_wl1251_pdata;
 	int ret;
 
 	memset(&pandora_wl1251_pdata, 0, sizeof(pandora_wl1251_pdata));
@@ -550,7 +550,7 @@ static void __init pandora_wl1251_init(void)
 		goto fail_irq;
 
 	pandora_wl1251_pdata.use_eeprom = true;
-	ret = wl12xx_set_platform_data(&pandora_wl1251_pdata);
+	ret = wl1251_set_platform_data(&pandora_wl1251_pdata);
 	if (ret < 0)
 		goto fail_irq;
 
diff --git a/arch/arm/mach-omap2/board-rx51-peripherals.c b/arch/arm/mach-omap2/board-rx51-peripherals.c
index 65e3627..0d8e7d2 100644
--- a/arch/arm/mach-omap2/board-rx51-peripherals.c
+++ b/arch/arm/mach-omap2/board-rx51-peripherals.c
@@ -82,7 +82,7 @@ enum {
 	RX51_SPI_MIPID,		/* LCD panel */
 };
 
-static struct wl12xx_platform_data wl1251_pdata;
+static struct wl1251_platform_data wl1251_pdata;
 static struct tsc2005_platform_data tsc2005_pdata;
 
 #if defined(CONFIG_SENSORS_LIS3_I2C) || defined(CONFIG_SENSORS_LIS3_I2C_MODULE)
diff --git a/drivers/net/wireless/ti/wilink_platform_data.c b/drivers/net/wireless/ti/wilink_platform_data.c
index 998e958..a92bd3e 100644
--- a/drivers/net/wireless/ti/wilink_platform_data.c
+++ b/drivers/net/wireless/ti/wilink_platform_data.c
@@ -23,17 +23,17 @@
 #include <linux/err.h>
 #include <linux/wl12xx.h>
 
-static struct wl12xx_platform_data *platform_data;
+static struct wl12xx_platform_data *wl12xx_platform_data;
 
 int __init wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
 {
-	if (platform_data)
+	if (wl12xx_platform_data)
 		return -EBUSY;
 	if (!data)
 		return -EINVAL;
 
-	platform_data = kmemdup(data, sizeof(*data), GFP_KERNEL);
-	if (!platform_data)
+	wl12xx_platform_data = kmemdup(data, sizeof(*data), GFP_KERNEL);
+	if (!wl12xx_platform_data)
 		return -ENOMEM;
 
 	return 0;
@@ -41,9 +41,34 @@ int __init wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
 
 struct wl12xx_platform_data *wl12xx_get_platform_data(void)
 {
-	if (!platform_data)
+	if (!wl12xx_platform_data)
 		return ERR_PTR(-ENODEV);
 
-	return platform_data;
+	return wl12xx_platform_data;
 }
 EXPORT_SYMBOL(wl12xx_get_platform_data);
+
+static struct wl1251_platform_data *wl1251_platform_data;
+
+int __init wl1251_set_platform_data(const struct wl1251_platform_data *data)
+{
+	if (wl1251_platform_data)
+		return -EBUSY;
+	if (!data)
+		return -EINVAL;
+
+	wl1251_platform_data = kmemdup(data, sizeof(*data), GFP_KERNEL);
+	if (!wl1251_platform_data)
+		return -ENOMEM;
+
+	return 0;
+}
+
+struct wl1251_platform_data *wl1251_get_platform_data(void)
+{
+	if (!wl1251_platform_data)
+		return ERR_PTR(-ENODEV);
+
+	return wl1251_platform_data;
+}
+EXPORT_SYMBOL(wl1251_get_platform_data);
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index e2b3d9c..b75a37a 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -227,7 +227,7 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 	struct wl1251 *wl;
 	struct ieee80211_hw *hw;
 	struct wl1251_sdio *wl_sdio;
-	const struct wl12xx_platform_data *wl12xx_board_data;
+	const struct wl1251_platform_data *wl1251_board_data;
 
 	hw = wl1251_alloc_hw();
 	if (IS_ERR(hw))
@@ -254,11 +254,11 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 	wl->if_priv = wl_sdio;
 	wl->if_ops = &wl1251_sdio_ops;
 
-	wl12xx_board_data = wl12xx_get_platform_data();
-	if (!IS_ERR(wl12xx_board_data)) {
-		wl->set_power = wl12xx_board_data->set_power;
-		wl->irq = wl12xx_board_data->irq;
-		wl->use_eeprom = wl12xx_board_data->use_eeprom;
+	wl1251_board_data = wl1251_get_platform_data();
+	if (!IS_ERR(wl1251_board_data)) {
+		wl->set_power = wl1251_board_data->set_power;
+		wl->irq = wl1251_board_data->irq;
+		wl->use_eeprom = wl1251_board_data->use_eeprom;
 	}
 
 	if (wl->irq) {
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index c7dc6fe..6bbbfe6 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -238,7 +238,7 @@ static const struct wl1251_if_operations wl1251_spi_ops = {
 
 static int wl1251_spi_probe(struct spi_device *spi)
 {
-	struct wl12xx_platform_data *pdata;
+	struct wl1251_platform_data *pdata;
 	struct ieee80211_hw *hw;
 	struct wl1251 *wl;
 	int ret;
diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
index a54fe82..b516b4f 100644
--- a/include/linux/wl12xx.h
+++ b/include/linux/wl12xx.h
@@ -48,11 +48,15 @@ enum {
 	WL12XX_TCXOCLOCK_33_6	= 7, /* 33.6 MHz */
 };
 
-struct wl12xx_platform_data {
+struct wl1251_platform_data {
 	void (*set_power)(bool enable);
 	/* SDIO only: IRQ number if WLAN_IRQ line is used, 0 for SDIO IRQs */
 	int irq;
 	bool use_eeprom;
+};
+
+struct wl12xx_platform_data {
+	int irq;
 	int board_ref_clock;
 	int board_tcxo_clock;
 	unsigned long platform_quirks;
@@ -68,6 +72,10 @@ int wl12xx_set_platform_data(const struct wl12xx_platform_data *data);
 
 struct wl12xx_platform_data *wl12xx_get_platform_data(void);
 
+int wl1251_set_platform_data(const struct wl1251_platform_data *data);
+
+struct wl1251_platform_data *wl1251_get_platform_data(void);
+
 #else
 
 static inline
@@ -82,6 +90,18 @@ struct wl12xx_platform_data *wl12xx_get_platform_data(void)
 	return ERR_PTR(-ENODATA);
 }
 
+static inline
+int wl1251_set_platform_data(const struct wl1251_platform_data *data)
+{
+	return -ENOSYS;
+}
+
+static inline
+struct wl1251_platform_data *wl1251_get_platform_data(void)
+{
+	return ERR_PTR(-ENODATA);
+}
+
 #endif
 
 #endif
-- 
1.8.4.rc3
