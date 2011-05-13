From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 11/13] net: wireless: wl12xx: re-factor all drivers
Date: Sat, 14 May 2011 00:26:28 +0300
Message-ID: <1305321990-22041-12-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move all common parts to where they belong,
namely main.c.

Ok this is a big patch but I didn't find
ways to make it so that we don't break
compilation. A few more patches will come
to make static whatever should be static.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/io.c                   |    8 +-
 drivers/net/wireless/wl12xx/io.h                   |   14 +--
 drivers/net/wireless/wl12xx/main.c                 |   90 +++++++++++-
 drivers/net/wireless/wl12xx/sdio.c                 |  128 +++--------------
 drivers/net/wireless/wl12xx/spi.c                  |  153 +++-----------------
 drivers/net/wireless/wl12xx/wl12xx.h               |   15 +-
 drivers/net/wireless/wl12xx/wl12xx_platform_data.c |    4 +-
 include/linux/wl12xx.h                             |    4 +-
 8 files changed, 147 insertions(+), 269 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/io.c b/drivers/net/wireless/wl12xx/io.c
index 57bc646..95a9a16 100644
--- a/drivers/net/wireless/wl12xx/io.c
+++ b/drivers/net/wireless/wl12xx/io.c
@@ -45,12 +45,12 @@
 
 void wl1271_disable_interrupts(struct wl1271 *wl)
 {
-	wl->if_ops->disable_irq(wl);
+	disable_irq(wl->irq);
 }
 
 void wl1271_enable_interrupts(struct wl1271 *wl)
 {
-	wl->if_ops->enable_irq(wl);
+	enable_irq(wl->irq);
 }
 
 /* Set the SPI partitions to access the chip addresses
@@ -118,13 +118,13 @@ EXPORT_SYMBOL_GPL(wl1271_set_partition);
 void wl1271_io_reset(struct wl1271 *wl)
 {
 	if (wl->if_ops->reset)
-		wl->if_ops->reset(wl);
+		wl->if_ops->reset(wl->dev);
 }
 
 void wl1271_io_init(struct wl1271 *wl)
 {
 	if (wl->if_ops->init)
-		wl->if_ops->init(wl);
+		wl->if_ops->init(wl->dev);
 }
 
 void wl1271_top_reg_write(struct wl1271 *wl, int addr, u16 val)
diff --git a/drivers/net/wireless/wl12xx/io.h b/drivers/net/wireless/wl12xx/io.h
index 00c771e..2bb2295 100644
--- a/drivers/net/wireless/wl12xx/io.h
+++ b/drivers/net/wireless/wl12xx/io.h
@@ -50,23 +50,17 @@ void wl1271_enable_interrupts(struct wl1271 *wl);
 void wl1271_io_reset(struct wl1271 *wl);
 void wl1271_io_init(struct wl1271 *wl);
 
-static inline struct device *wl1271_wl_to_dev(struct wl1271 *wl)
-{
-	return wl->if_ops->dev(wl);
-}
-
-
 /* Raw target IO, address is not translated */
 static inline void wl1271_raw_write(struct wl1271 *wl, int addr, void *buf,
 				    size_t len, bool fixed)
 {
-	wl->if_ops->write(wl, addr, buf, len, fixed);
+	wl->if_ops->write(wl->dev, addr, buf, len, fixed);
 }
 
 static inline void wl1271_raw_read(struct wl1271 *wl, int addr, void *buf,
 				   size_t len, bool fixed)
 {
-	wl->if_ops->read(wl, addr, buf, len, fixed);
+	wl->if_ops->read(wl->dev, addr, buf, len, fixed);
 }
 
 static inline u32 wl1271_raw_read32(struct wl1271 *wl, int addr)
@@ -140,13 +134,13 @@ static inline void wl1271_write32(struct wl1271 *wl, int addr, u32 val)
 
 static inline void wl1271_power_off(struct wl1271 *wl)
 {
-	wl->if_ops->power(wl, false);
+	wl->if_ops->power(wl->dev, false);
 	clear_bit(WL1271_FLAG_GPIO_POWER, &wl->flags);
 }
 
 static inline int wl1271_power_on(struct wl1271 *wl)
 {
-	int ret = wl->if_ops->power(wl, true);
+	int ret = wl->if_ops->power(wl->dev, true);
 	if (ret == 0)
 		set_bit(WL1271_FLAG_GPIO_POWER, &wl->flags);
 
diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index d377e1f..628f7a3 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -30,6 +30,7 @@
 #include <linux/vmalloc.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
+#include <linux/wl12xx.h>
 
 #include "wl12xx.h"
 #include "wl12xx_80211.h"
@@ -799,7 +800,7 @@ static int wl1271_fetch_firmware(struct wl1271 *wl)
 
 	wl1271_debug(DEBUG_BOOT, "booting firmware %s", fw_name);
 
-	ret = request_firmware(&fw, fw_name, wl1271_wl_to_dev(wl));
+	ret = request_firmware(&fw, fw_name, wl->dev);
 
 	if (ret < 0) {
 		wl1271_error("could not get firmware: %d", ret);
@@ -838,7 +839,7 @@ static int wl1271_fetch_nvs(struct wl1271 *wl)
 	const struct firmware *fw;
 	int ret;
 
-	ret = request_firmware(&fw, WL1271_NVS_NAME, wl1271_wl_to_dev(wl));
+	ret = request_firmware(&fw, WL1271_NVS_NAME, wl->dev);
 
 	if (ret < 0) {
 		wl1271_error("could not get nvs file: %d", ret);
@@ -3377,7 +3378,7 @@ int wl1271_init_ieee80211(struct wl1271 *wl)
 
 	wl->hw->wiphy->reg_notifier = wl1271_reg_notify;
 
-	SET_IEEE80211_DEV(wl->hw, wl1271_wl_to_dev(wl));
+	SET_IEEE80211_DEV(wl->hw, wl->dev);
 
 	wl->hw->sta_data_size = sizeof(struct wl1271_station);
 
@@ -3547,13 +3548,96 @@ int wl1271_free_hw(struct wl1271 *wl)
 }
 EXPORT_SYMBOL_GPL(wl1271_free_hw);
 
+static irqreturn_t wl12xx_hardirq(int irq, void *_wl)
+{
+	struct wl1271		*wl = _wl;
+	unsigned long		flags;
+
+	wl1271_debug(DEBUG_IRQ, "IRQ");
+
+	/* complete the ELP completion */
+	spin_lock_irqsave(&wl->wl_lock, flags);
+	set_bit(WL1271_FLAG_IRQ_RUNNING, &wl->flags);
+	if (wl->elp_compl) {
+		complete(wl->elp_compl);
+		wl->elp_compl = NULL;
+	}
+	spin_unlock_irqrestore(&wl->wl_lock, flags);
+
+	return IRQ_WAKE_THREAD;
+}
+
 static int __devinit wl12xx_probe(struct platform_device *pdev)
 {
+	struct wl12xx_platform_data *pdata = pdev->dev.platform_data;
+	struct ieee80211_hw	*hw;
+	struct wl1271		*wl;
+
+	int			ret = -ENODEV;
+	int			irq;
+
+	hw = wl1271_alloc_hw();
+	if (IS_ERR(hw)) {
+		dev_err(&pdev->dev, "can't allocate hw\n");
+		goto err0;
+	}
+
+	irq = platform_get_irq(pdev, 0);
+
+	wl = hw->priv;
+
+	wl->ref_clock	= pdata->board_ref_clock;
+	wl->set_power	= pdata->set_power;
+	wl->irq		= irq;
+	wl->dev		= &pdev->dev;
+
+	platform_set_drvdata(pdev, wl);
+
+	ret = request_threaded_irq(wl->irq, wl12xx_hardirq, wl1271_irq,
+			IRQF_TRIGGER_HIGH | IRQF_ONESHOT,
+			pdev->name, wl);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "failed to request irq --> %d\n", ret);
+		goto err1;
+	}
+
+	disable_irq(wl->irq);
+
+	ret = wl1271_init_ieee80211(wl);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to initialize hw\n");
+		goto err2;
+	}
+
+	ret = wl1271_register_hw(wl);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register hw\n");
+		goto err3;
+	}
+
 	return 0;
+
+err3:
+	wl1271_free_hw(wl);
+
+err2:
+	free_irq(wl->irq, wl);
+
+err1:
+	wl1271_free_hw(wl);
+
+err0:
+	return ret;
 }
 
 static int __devexit wl12xx_remove(struct platform_device *pdev)
 {
+	struct wl1271		*wl = platform_get_drvdata(pdev);
+
+	wl1271_unregister_hw(wl);
+	free_irq(wl->irq, wl);
+	wl1271_free_hw(wl);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index 5c5e4f2..a0db640 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -48,7 +48,6 @@
 
 struct wl12xx_sdio_glue {
 	struct device		*dev;
-	struct wl1271		*wl;
 	struct platform_device	*core;
 };
 
@@ -58,49 +57,10 @@ static const struct sdio_device_id wl1271_devices[] __devinitconst = {
 };
 MODULE_DEVICE_TABLE(sdio, wl1271_devices);
 
-static inline struct wl12xx_sdio_glue *wl_to_glue(struct wl1271 *wl)
-{
-	return wl->if_priv;
-}
-
-static struct device *wl1271_sdio_wl_to_dev(struct wl1271 *wl)
-{
-	return wl_to_glue(wl)->dev;
-}
-
-static irqreturn_t wl1271_hardirq(int irq, void *cookie)
-{
-	struct wl1271 *wl = cookie;
-	unsigned long flags;
-
-	wl1271_debug(DEBUG_IRQ, "IRQ");
-
-	/* complete the ELP completion */
-	spin_lock_irqsave(&wl->wl_lock, flags);
-	set_bit(WL1271_FLAG_IRQ_RUNNING, &wl->flags);
-	if (wl->elp_compl) {
-		complete(wl->elp_compl);
-		wl->elp_compl = NULL;
-	}
-	spin_unlock_irqrestore(&wl->wl_lock, flags);
-
-	return IRQ_WAKE_THREAD;
-}
-
-static void wl1271_sdio_disable_interrupts(struct wl1271 *wl)
-{
-	disable_irq(wl->irq);
-}
-
-static void wl1271_sdio_enable_interrupts(struct wl1271 *wl)
-{
-	enable_irq(wl->irq);
-}
-
-static void wl1271_sdio_raw_read(struct wl1271 *wl, int addr, void *buf,
+static void wl1271_sdio_raw_read(struct device *child, int addr, void *buf,
 				 size_t len, bool fixed)
 {
-	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_sdio_glue	*glue = dev_get_drvdata(child->parent);
 	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
 	int			ret;
 
@@ -123,10 +83,10 @@ static void wl1271_sdio_raw_read(struct wl1271 *wl, int addr, void *buf,
 		wl1271_error("sdio read failed (%d)", ret);
 }
 
-static void wl1271_sdio_raw_write(struct wl1271 *wl, int addr, void *buf,
+static void wl1271_sdio_raw_write(struct device *child, int addr, void *buf,
 				  size_t len, bool fixed)
 {
-	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_sdio_glue	*glue = dev_get_drvdata(child->parent);
 	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
 	int			ret;
 
@@ -149,9 +109,8 @@ static void wl1271_sdio_raw_write(struct wl1271 *wl, int addr, void *buf,
 		wl1271_error("sdio write failed (%d)", ret);
 }
 
-static int wl1271_sdio_power_on(struct wl1271 *wl)
+static int wl1271_sdio_power_on(struct wl12xx_sdio_glue *glue)
 {
-	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
 	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
 	int			ret;
 
@@ -172,9 +131,8 @@ out:
 	return ret;
 }
 
-static int wl1271_sdio_power_off(struct wl1271 *wl)
+static int wl1271_sdio_power_off(struct wl12xx_sdio_glue *glue)
 {
-	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
 	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
 	int			ret;
 
@@ -190,33 +148,30 @@ static int wl1271_sdio_power_off(struct wl1271 *wl)
 	return pm_runtime_put_sync(&func->dev);
 }
 
-static int wl1271_sdio_set_power(struct wl1271 *wl, bool enable)
+static int wl1271_sdio_set_power(struct device *child, bool enable)
 {
+	struct wl12xx_sdio_glue	*glue = dev_get_drvdata(child->parent);
+
 	if (enable)
-		return wl1271_sdio_power_on(wl);
+		return wl1271_sdio_power_on(glue);
 	else
-		return wl1271_sdio_power_off(wl);
+		return wl1271_sdio_power_off(glue);
 }
 
 static struct wl1271_if_operations sdio_ops = {
 	.read		= wl1271_sdio_raw_read,
 	.write		= wl1271_sdio_raw_write,
 	.power		= wl1271_sdio_set_power,
-	.dev		= wl1271_sdio_wl_to_dev,
-	.enable_irq	= wl1271_sdio_enable_interrupts,
-	.disable_irq	= wl1271_sdio_disable_interrupts
 };
 
 static int __devinit wl1271_probe(struct sdio_func *func,
 				  const struct sdio_device_id *id)
 {
-	const struct wl12xx_platform_data *wlan_data;
+	struct wl12xx_platform_data	*wlan_data;
 
 	struct platform_device		*core;
 	struct resource			res[1];
 	struct wl12xx_sdio_glue		*glue;
-	struct ieee80211_hw		*hw;
-	struct wl1271			*wl;
 
 	int				ret = -ENOMEM;
 
@@ -230,20 +185,7 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 		goto err0;
 	}
 
-	hw = wl1271_alloc_hw();
-	if (IS_ERR(hw)) {
-		dev_err(&func->dev, "can't allocate hw\n");
-		ret = PTR_ERR(hw);
-		goto err1;
-	}
-
-	wl = hw->priv;
-
-	wl->if_priv = glue;
-	wl->if_ops = &sdio_ops;
-
 	glue->dev = &func->dev;
-	glue->wl = wl;
 
 	/* Grab access to FN0 for ELP reg. */
 	func->card->quirks |= MMC_QUIRK_LENIENT_FN0;
@@ -252,29 +194,10 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	if (IS_ERR(wlan_data)) {
 		ret = PTR_ERR(wlan_data);
 		wl1271_error("missing wlan platform data: %d", ret);
-		goto err2;
-	}
-
-	wl->irq = wlan_data->irq;
-	wl->ref_clock = wlan_data->board_ref_clock;
-
-	ret = request_threaded_irq(wl->irq, wl1271_hardirq, wl1271_irq,
-				   IRQF_TRIGGER_HIGH | IRQF_ONESHOT,
-				   DRIVER_NAME, wl);
-	if (ret < 0) {
-		wl1271_error("request_irq() failed: %d", ret);
-		goto err2;
+		goto err1;
 	}
 
-	disable_irq(wl->irq);
-
-	ret = wl1271_init_ieee80211(wl);
-	if (ret)
-		goto err3;
-
-	ret = wl1271_register_hw(wl);
-	if (ret)
-		goto err3;
+	wlan_data->ops = &sdio_ops;
 
 	sdio_set_drvdata(func, glue);
 
@@ -285,7 +208,7 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	if (!core) {
 		dev_err(&func->dev, "can't allocate platform_device\n");
 		ret = -ENOMEM;
-		goto err4;
+		goto err1;
 	}
 
 	core->dev.parent = &func->dev;
@@ -299,34 +222,25 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	ret = platform_device_add_resources(core, res, ARRAY_SIZE(res));
 	if (ret) {
 		dev_err(&func->dev, "can't add resources\n");
-		goto err5;
+		goto err2;
 	}
 
 	ret = platform_device_add_data(core, wlan_data, sizeof(*wlan_data));
 	if (ret) {
 		dev_err(&func->dev, "can't add platform data\n");
-		goto err5;
+		goto err2;
 	}
 
 	ret = platform_device_register(core);
 	if (ret) {
 		dev_err(&func->dev, "can't register platform device\n");
-		goto err5;
+		goto err2;
 	}
 
 	return 0;
 
-err5:
-	platform_device_put(core);
-
-err4:
-	wl1271_unregister_hw(wl);
-
-err3:
-	free_irq(wl->irq, wl);
-
 err2:
-	wl1271_free_hw(wl);
+	platform_device_put(core);
 
 err1:
 	kfree(glue);
@@ -338,14 +252,10 @@ err0:
 static void __devexit wl1271_remove(struct sdio_func *func)
 {
 	struct wl12xx_sdio_glue	*glue = sdio_get_drvdata(func);
-	struct wl1271		*wl = glue->wl;
 
 	/* Undo decrement done above in wl1271_probe */
 	pm_runtime_get_noresume(&func->dev);
 
-	wl1271_unregister_hw(wl);
-	free_irq(wl->irq, wl);
-	wl1271_free_hw(wl);
 	platform_device_del(glue->core);
 	platform_device_put(glue->core);
 	kfree(glue);
diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index 6644996..edc2c64 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -71,33 +71,12 @@
 
 struct wl12xx_spi_glue {
 	struct device		*dev;
-	struct wl1271		*wl;
 	struct platform_device	*core;
 };
 
-static inline struct wl12xx_spi_glue *wl_to_glue(struct wl1271 *wl)
+static void wl1271_spi_reset(struct device *child)
 {
-	return wl->if_priv;
-}
-
-static struct device *wl1271_spi_wl_to_dev(struct wl1271 *wl)
-{
-	return wl_to_glue(wl)->dev;
-}
-
-static void wl1271_spi_disable_interrupts(struct wl1271 *wl)
-{
-	disable_irq(wl->irq);
-}
-
-static void wl1271_spi_enable_interrupts(struct wl1271 *wl)
-{
-	enable_irq(wl->irq);
-}
-
-static void wl1271_spi_reset(struct wl1271 *wl)
-{
-	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_spi_glue	*glue = dev_get_drvdata(child->parent);
 	struct spi_transfer	t;
 	struct spi_message	m;
 	u8			*cmd;
@@ -123,9 +102,9 @@ static void wl1271_spi_reset(struct wl1271 *wl)
 	kfree(cmd);
 }
 
-static void wl1271_spi_init(struct wl1271 *wl)
+static void wl1271_spi_init(struct device *child)
 {
-	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_spi_glue	*glue = dev_get_drvdata(child->parent);
 	struct spi_transfer	t;
 	struct spi_message	m;
 
@@ -182,9 +161,10 @@ static void wl1271_spi_init(struct wl1271 *wl)
 
 #define WL1271_BUSY_WORD_TIMEOUT 1000
 
-static int wl1271_spi_read_busy(struct wl1271 *wl)
+static int wl1271_spi_read_busy(struct device *child)
 {
-	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_spi_glue	*glue = dev_get_drvdata(child->parent);
+	struct wl1271		*wl = dev_get_drvdata(child);
 	struct spi_transfer	t[1];
 	struct spi_message	m;
 
@@ -217,10 +197,11 @@ static int wl1271_spi_read_busy(struct wl1271 *wl)
 	return -ETIMEDOUT;
 }
 
-static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
+static void wl1271_spi_raw_read(struct device *child, int addr, void *buf,
 				size_t len, bool fixed)
 {
-	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_spi_glue	*glue = dev_get_drvdata(child->parent);
+	struct wl1271		*wl = dev_get_drvdata(child);
 	struct spi_transfer	t[2];
 	struct spi_message	m;
 
@@ -260,7 +241,7 @@ static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 		spi_sync(to_spi_device(glue->dev), &m);
 
 		if (!(busy_buf[WL1271_BUSY_WORD_CNT - 1] & 0x1) &&
-		    wl1271_spi_read_busy(wl)) {
+		    wl1271_spi_read_busy(child)) {
 			memset(buf, 0, chunk_len);
 			return;
 		}
@@ -285,10 +266,10 @@ static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 	}
 }
 
-static void wl1271_spi_raw_write(struct wl1271 *wl, int addr, void *buf,
+static void wl1271_spi_raw_write(struct device *child, int addr, void *buf,
 			  size_t len, bool fixed)
 {
-	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct wl12xx_spi_glue	*glue = dev_get_drvdata(child->parent);
 	struct spi_transfer	t[2 * WSPI_MAX_NUM_OF_CHUNKS];
 	struct spi_message	m;
 
@@ -338,42 +319,11 @@ static void wl1271_spi_raw_write(struct wl1271 *wl, int addr, void *buf,
 	spi_sync(to_spi_device(glue->dev), &m);
 }
 
-static irqreturn_t wl1271_hardirq(int irq, void *cookie)
-{
-	struct wl1271 *wl = cookie;
-	unsigned long flags;
-
-	wl1271_debug(DEBUG_IRQ, "IRQ");
-
-	/* complete the ELP completion */
-	spin_lock_irqsave(&wl->wl_lock, flags);
-	set_bit(WL1271_FLAG_IRQ_RUNNING, &wl->flags);
-	if (wl->elp_compl) {
-		complete(wl->elp_compl);
-		wl->elp_compl = NULL;
-	}
-	spin_unlock_irqrestore(&wl->wl_lock, flags);
-
-	return IRQ_WAKE_THREAD;
-}
-
-static int wl1271_spi_set_power(struct wl1271 *wl, bool enable)
-{
-	if (wl->set_power)
-		wl->set_power(enable);
-
-	return 0;
-}
-
 static struct wl1271_if_operations spi_ops = {
 	.read		= wl1271_spi_raw_read,
 	.write		= wl1271_spi_raw_write,
 	.reset		= wl1271_spi_reset,
 	.init		= wl1271_spi_init,
-	.power		= wl1271_spi_set_power,
-	.dev		= wl1271_spi_wl_to_dev,
-	.enable_irq	= wl1271_spi_enable_interrupts,
-	.disable_irq	= wl1271_spi_disable_interrupts
 };
 
 static int __devinit wl1271_probe(struct spi_device *spi)
@@ -381,10 +331,7 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	struct wl12xx_platform_data	*pdata;
 	struct platform_device		*core;
 	struct resource			res[1];
-
 	struct wl12xx_spi_glue		*glue;
-	struct ieee80211_hw		*hw;
-	struct wl1271			*wl;
 
 	int				ret = -ENOMEM;
 
@@ -394,27 +341,16 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 		return -ENODEV;
 	}
 
+	pdata->ops = &spi_ops;
+
 	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
 	if (!glue) {
 		dev_err(&spi->dev, "not enought memory\n");
 		goto err0;
 	}
 
-	hw = wl1271_alloc_hw();
-	if (IS_ERR(hw)) {
-		ret = PTR_ERR(hw);
-		goto err1;
-	}
-
-	wl = hw->priv;
-
 	glue->dev = &spi->dev;
-	glue->wl = wl;
-
 	spi_set_drvdata(spi, glue);
-	wl->if_priv = glue;
-
-	wl->if_ops = &spi_ops;
 
 	/* This is the only SPI value that we need to set here, the rest
 	 * comes from the board-peripherals file */
@@ -423,48 +359,14 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	ret = spi_setup(spi);
 	if (ret < 0) {
 		wl1271_error("spi_setup failed");
-		goto err2;
-	}
-
-	wl->set_power = pdata->set_power;
-	if (!wl->set_power) {
-		wl1271_error("set power function missing in platform data");
-		ret = -ENODEV;
-		goto err2;
-	}
-
-	wl->ref_clock = pdata->board_ref_clock;
-
-	wl->irq = spi->irq;
-	if (wl->irq < 0) {
-		wl1271_error("irq missing in platform data");
-		ret = -ENODEV;
-		goto err2;
-	}
-
-	ret = request_threaded_irq(wl->irq, wl1271_hardirq, wl1271_irq,
-				   IRQF_TRIGGER_HIGH | IRQF_ONESHOT,
-				   DRIVER_NAME, wl);
-	if (ret < 0) {
-		wl1271_error("request_irq() failed: %d", ret);
-		goto err2;
+		goto err1;
 	}
 
-	disable_irq(wl->irq);
-
-	ret = wl1271_init_ieee80211(wl);
-	if (ret)
-		goto err3;
-
-	ret = wl1271_register_hw(wl);
-	if (ret)
-		goto err3;
-
 	core = platform_device_alloc("wl12xx-spi", -1);
 	if (!core) {
 		dev_err(&spi->dev, "can't allocate platform_device\n");
 		ret = -ENOMEM;
-		goto err4;
+		goto err1;
 	}
 
 	core->dev.parent = &spi->dev;
@@ -478,34 +380,25 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	ret = platform_device_add_resources(core, res, ARRAY_SIZE(res));
 	if (ret) {
 		dev_err(&spi->dev, "can't add resources\n");
-		goto err5;
+		goto err2;
 	}
 
 	ret = platform_device_add_data(core, pdata, sizeof(*pdata));
 	if (ret) {
 		dev_err(&spi->dev, "can't add platform data\n");
-		goto err5;
+		goto err2;
 	}
 
 	ret = platform_device_register(core);
 	if (ret) {
 		dev_err(&spi->dev, "can't register platform device\n");
-		goto err5;
+		goto err2;
 	}
 
 	return 0;
 
-err5:
-	platform_device_put(core);
-
-err4:
-	wl1271_unregister_hw(wl);
-
-err3:
-	free_irq(wl->irq, wl);
-
 err2:
-	wl1271_free_hw(wl);
+	platform_device_put(core);
 
 err1:
 	kfree(glue);
@@ -517,11 +410,7 @@ err0:
 static int __devexit wl1271_remove(struct spi_device *spi)
 {
 	struct wl12xx_spi_glue	*glue = spi_get_drvdata(spi);
-	struct wl1271		*wl = glue->wl;
 
-	wl1271_unregister_hw(wl);
-	free_irq(wl->irq, wl);
-	wl1271_free_hw(wl);
 	platform_device_del(glue->core);
 	platform_device_put(glue->core);
 	kfree(glue);
diff --git a/drivers/net/wireless/wl12xx/wl12xx.h b/drivers/net/wireless/wl12xx/wl12xx.h
index 86be83e..eb3d3fc 100644
--- a/drivers/net/wireless/wl12xx/wl12xx.h
+++ b/drivers/net/wireless/wl12xx/wl12xx.h
@@ -287,16 +287,13 @@ struct wl1271_scan {
 };
 
 struct wl1271_if_operations {
-	void (*read)(struct wl1271 *wl, int addr, void *buf, size_t len,
+	void (*read)(struct device *child, int addr, void *buf, size_t len,
 		     bool fixed);
-	void (*write)(struct wl1271 *wl, int addr, void *buf, size_t len,
+	void (*write)(struct device *child, int addr, void *buf, size_t len,
 		     bool fixed);
-	void (*reset)(struct wl1271 *wl);
-	void (*init)(struct wl1271 *wl);
-	int (*power)(struct wl1271 *wl, bool enable);
-	struct device* (*dev)(struct wl1271 *wl);
-	void (*enable_irq)(struct wl1271 *wl);
-	void (*disable_irq)(struct wl1271 *wl);
+	void (*reset)(struct device *child);
+	void (*init)(struct device *child);
+	int (*power)(struct device *child, bool enable);
 };
 
 #define MAX_NUM_KEYS 14
@@ -346,6 +343,8 @@ struct wl1271 {
 	struct ieee80211_hw *hw;
 	bool mac80211_registered;
 
+	struct device *dev;
+
 	void *if_priv;
 
 	struct wl1271_if_operations *if_ops;
diff --git a/drivers/net/wireless/wl12xx/wl12xx_platform_data.c b/drivers/net/wireless/wl12xx/wl12xx_platform_data.c
index 973b110..3c96b33 100644
--- a/drivers/net/wireless/wl12xx/wl12xx_platform_data.c
+++ b/drivers/net/wireless/wl12xx/wl12xx_platform_data.c
@@ -2,7 +2,7 @@
 #include <linux/err.h>
 #include <linux/wl12xx.h>
 
-static const struct wl12xx_platform_data *platform_data;
+static struct wl12xx_platform_data *platform_data;
 
 int __init wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
 {
@@ -18,7 +18,7 @@ int __init wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
 	return 0;
 }
 
-const struct wl12xx_platform_data *wl12xx_get_platform_data(void)
+struct wl12xx_platform_data *wl12xx_get_platform_data(void)
 {
 	if (!platform_data)
 		return ERR_PTR(-ENODEV);
diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
index bebb8ef..98c17e3 100644
--- a/include/linux/wl12xx.h
+++ b/include/linux/wl12xx.h
@@ -38,6 +38,8 @@ struct wl12xx_platform_data {
 	int irq;
 	bool use_eeprom;
 	int board_ref_clock;
+
+	struct wl1271_if_operations *ops;
 };
 
 #ifdef CONFIG_WL12XX_PLATFORM_DATA
@@ -54,6 +56,6 @@ int wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
 
 #endif
 
-const struct wl12xx_platform_data *wl12xx_get_platform_data(void);
+struct wl12xx_platform_data *wl12xx_get_platform_data(void);
 
 #endif
-- 
1.7.4.1.343.ga91df
