From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 09/13] net: wl12xx: sdio: add a platform_device
Date: Sat, 14 May 2011 00:26:26 +0300
Message-ID: <1305321990-22041-10-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

that device will match with a driver to
be added to the core driver.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/sdio.c |   45 ++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index bb7569c..5c5e4f2 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/crc7.h>
 #include <linux/vmalloc.h>
+#include <linux/platform_device.h>
 #include <linux/mmc/sdio_func.h>
 #include <linux/mmc/sdio_ids.h>
 #include <linux/mmc/card.h>
@@ -48,6 +49,7 @@
 struct wl12xx_sdio_glue {
 	struct device		*dev;
 	struct wl1271		*wl;
+	struct platform_device	*core;
 };
 
 static const struct sdio_device_id wl1271_devices[] __devinitconst = {
@@ -210,6 +212,8 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 {
 	const struct wl12xx_platform_data *wlan_data;
 
+	struct platform_device		*core;
+	struct resource			res[1];
 	struct wl12xx_sdio_glue		*glue;
 	struct ieee80211_hw		*hw;
 	struct wl1271			*wl;
@@ -277,8 +281,47 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	/* Tell PM core that we don't need the card to be powered now */
 	pm_runtime_put_noidle(&func->dev);
 
+	core = platform_device_alloc("wl12xx-sdio", -1);
+	if (!core) {
+		dev_err(&func->dev, "can't allocate platform_device\n");
+		ret = -ENOMEM;
+		goto err4;
+	}
+
+	core->dev.parent = &func->dev;
+
+	memset(res, 0x00, sizeof(res) * ARRAY_SIZE(res));
+
+	res[0].start	= wlan_data->irq;
+	res[0].flags	= IORESOURCE_IRQ;
+	res[0].name	= "irq";
+
+	ret = platform_device_add_resources(core, res, ARRAY_SIZE(res));
+	if (ret) {
+		dev_err(&func->dev, "can't add resources\n");
+		goto err5;
+	}
+
+	ret = platform_device_add_data(core, wlan_data, sizeof(*wlan_data));
+	if (ret) {
+		dev_err(&func->dev, "can't add platform data\n");
+		goto err5;
+	}
+
+	ret = platform_device_register(core);
+	if (ret) {
+		dev_err(&func->dev, "can't register platform device\n");
+		goto err5;
+	}
+
 	return 0;
 
+err5:
+	platform_device_put(core);
+
+err4:
+	wl1271_unregister_hw(wl);
+
 err3:
 	free_irq(wl->irq, wl);
 
@@ -303,6 +346,8 @@ static void __devexit wl1271_remove(struct sdio_func *func)
 	wl1271_unregister_hw(wl);
 	free_irq(wl->irq, wl);
 	wl1271_free_hw(wl);
+	platform_device_del(glue->core);
+	platform_device_put(glue->core);
 	kfree(glue);
 }
 
-- 
1.7.4.1.343.ga91df
