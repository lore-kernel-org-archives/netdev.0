From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 02/13] net: wl12xx: sdio: add a context structure
Date: Sat, 14 May 2011 00:26:19 +0300
Message-ID: <1305321990-22041-3-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this will help re-structuring the driver so
that we avoid all duplications which are
currently on this driver.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/sdio.c |   78 +++++++++++++++++++++++++-----------
 1 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index 1268efe..fe775d3 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -45,20 +45,25 @@
 #define SDIO_DEVICE_ID_TI_WL1271	0x4076
 #endif
 
+struct wl12xx_sdio_glue {
+	struct device		*dev;
+	struct wl1271		*wl;
+};
+
 static const struct sdio_device_id wl1271_devices[] __devinitconst = {
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_TI, SDIO_DEVICE_ID_TI_WL1271) },
 	{}
 };
 MODULE_DEVICE_TABLE(sdio, wl1271_devices);
 
-static inline struct sdio_func *wl_to_func(struct wl1271 *wl)
+static inline struct wl12xx_sdio_glue *wl_to_glue(struct wl1271 *wl)
 {
 	return wl->if_priv;
 }
 
 static struct device *wl1271_sdio_wl_to_dev(struct wl1271 *wl)
 {
-	return &(wl_to_func(wl)->dev);
+	return wl_to_glue(wl)->dev;
 }
 
 static irqreturn_t wl1271_hardirq(int irq, void *cookie)
@@ -101,8 +106,9 @@ static void wl1271_sdio_init(struct wl1271 *wl)
 static void wl1271_sdio_raw_read(struct wl1271 *wl, int addr, void *buf,
 				 size_t len, bool fixed)
 {
-	int ret;
-	struct sdio_func *func = wl_to_func(wl);
+	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
+	int			ret;
 
 	if (unlikely(addr == HW_ACCESS_ELP_CTRL_REG_ADDR)) {
 		((u8 *)buf)[0] = sdio_f0_readb(func, addr, &ret);
@@ -126,8 +132,9 @@ static void wl1271_sdio_raw_read(struct wl1271 *wl, int addr, void *buf,
 static void wl1271_sdio_raw_write(struct wl1271 *wl, int addr, void *buf,
 				  size_t len, bool fixed)
 {
-	int ret;
-	struct sdio_func *func = wl_to_func(wl);
+	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
+	int			ret;
 
 	if (unlikely(addr == HW_ACCESS_ELP_CTRL_REG_ADDR)) {
 		sdio_f0_writeb(func, ((u8 *)buf)[0], addr, &ret);
@@ -150,8 +157,9 @@ static void wl1271_sdio_raw_write(struct wl1271 *wl, int addr, void *buf,
 
 static int wl1271_sdio_power_on(struct wl1271 *wl)
 {
-	struct sdio_func *func = wl_to_func(wl);
-	int ret;
+	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
+	int			ret;
 
 	/* Make sure the card will not be powered off by runtime PM */
 	ret = pm_runtime_get_sync(&func->dev);
@@ -172,8 +180,9 @@ out:
 
 static int wl1271_sdio_power_off(struct wl1271 *wl)
 {
-	struct sdio_func *func = wl_to_func(wl);
-	int ret;
+	struct wl12xx_sdio_glue	*glue = wl_to_glue(wl);
+	struct sdio_func	*func = dev_to_sdio_func(glue->dev);
+	int			ret;
 
 	sdio_disable_func(func);
 	sdio_release_host(func);
@@ -209,24 +218,39 @@ static struct wl1271_if_operations sdio_ops = {
 static int __devinit wl1271_probe(struct sdio_func *func,
 				  const struct sdio_device_id *id)
 {
-	struct ieee80211_hw *hw;
 	const struct wl12xx_platform_data *wlan_data;
-	struct wl1271 *wl;
-	int ret;
+
+	struct wl12xx_sdio_glue		*glue;
+	struct ieee80211_hw		*hw;
+	struct wl1271			*wl;
+
+	int				ret = -ENOMEM;
 
 	/* We are only able to handle the wlan function */
 	if (func->num != 0x02)
 		return -ENODEV;
 
+	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
+	if (!glue) {
+		dev_err(&func->dev, "not enough memory\n");
+		goto err0;
+	}
+
 	hw = wl1271_alloc_hw();
-	if (IS_ERR(hw))
-		return PTR_ERR(hw);
+	if (IS_ERR(hw)) {
+		dev_err(&func->dev, "can't allocate hw\n");
+		ret = PTR_ERR(hw);
+		goto err1;
+	}
 
 	wl = hw->priv;
 
-	wl->if_priv = func;
+	wl->if_priv = glue;
 	wl->if_ops = &sdio_ops;
 
+	glue->dev = &func->dev;
+	glue->wl = wl;
+
 	/* Grab access to FN0 for ELP reg. */
 	func->card->quirks |= MMC_QUIRK_LENIENT_FN0;
 
@@ -234,7 +258,7 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	if (IS_ERR(wlan_data)) {
 		ret = PTR_ERR(wlan_data);
 		wl1271_error("missing wlan platform data: %d", ret);
-		goto out_free;
+		goto err2;
 	}
 
 	wl->irq = wlan_data->irq;
@@ -245,20 +269,20 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 				   DRIVER_NAME, wl);
 	if (ret < 0) {
 		wl1271_error("request_irq() failed: %d", ret);
-		goto out_free;
+		goto err2;
 	}
 
 	disable_irq(wl->irq);
 
 	ret = wl1271_init_ieee80211(wl);
 	if (ret)
-		goto out_irq;
+		goto err3;
 
 	ret = wl1271_register_hw(wl);
 	if (ret)
-		goto out_irq;
+		goto err3;
 
-	sdio_set_drvdata(func, wl);
+	sdio_set_drvdata(func, glue);
 
 	/* Tell PM core that we don't need the card to be powered now */
 	pm_runtime_put_noidle(&func->dev);
@@ -267,18 +291,23 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 
 	return 0;
 
- out_irq:
+err3:
 	free_irq(wl->irq, wl);
 
- out_free:
+err2:
 	wl1271_free_hw(wl);
 
+err1:
+	kfree(glue);
+
+err0:
 	return ret;
 }
 
 static void __devexit wl1271_remove(struct sdio_func *func)
 {
-	struct wl1271 *wl = sdio_get_drvdata(func);
+	struct wl12xx_sdio_glue	*glue = sdio_get_drvdata(func);
+	struct wl1271		*wl = glue->wl;
 
 	/* Undo decrement done above in wl1271_probe */
 	pm_runtime_get_noresume(&func->dev);
@@ -286,6 +315,7 @@ static void __devexit wl1271_remove(struct sdio_func *func)
 	wl1271_unregister_hw(wl);
 	free_irq(wl->irq, wl);
 	wl1271_free_hw(wl);
+	kfree(glue);
 }
 
 static int wl1271_suspend(struct device *dev)
-- 
1.7.4.1.343.ga91df
