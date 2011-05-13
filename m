From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 08/13] net: wl12xx: spi: add a platform_device
Date: Sat, 14 May 2011 00:26:25 +0300
Message-ID: <1305321990-22041-9-git-send-email-balbi@ti.com>
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

that driver will be added once the other
glue layer (sdio.c) is converted to this
new scheme.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/spi.c |   50 ++++++++++++++++++++++++++++++++++--
 1 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index 5dbd5b3..6644996 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -26,6 +26,7 @@
 #include <linux/crc7.h>
 #include <linux/spi/spi.h>
 #include <linux/wl12xx.h>
+#include <linux/platform_device.h>
 #include <linux/slab.h>
 
 #include "wl12xx.h"
@@ -69,8 +70,9 @@
 #define WSPI_MAX_NUM_OF_CHUNKS (WL1271_AGGR_BUFFER_SIZE / WSPI_MAX_CHUNK_SIZE)
 
 struct wl12xx_spi_glue {
-	struct device	*dev;
-	struct wl1271	*wl;
+	struct device		*dev;
+	struct wl1271		*wl;
+	struct platform_device	*core;
 };
 
 static inline struct wl12xx_spi_glue *wl_to_glue(struct wl1271 *wl)
@@ -377,6 +379,8 @@ static struct wl1271_if_operations spi_ops = {
 static int __devinit wl1271_probe(struct spi_device *spi)
 {
 	struct wl12xx_platform_data	*pdata;
+	struct platform_device		*core;
+	struct resource			res[1];
 
 	struct wl12xx_spi_glue		*glue;
 	struct ieee80211_hw		*hw;
@@ -456,8 +460,47 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	if (ret)
 		goto err3;
 
+	core = platform_device_alloc("wl12xx-spi", -1);
+	if (!core) {
+		dev_err(&spi->dev, "can't allocate platform_device\n");
+		ret = -ENOMEM;
+		goto err4;
+	}
+
+	core->dev.parent = &spi->dev;
+
+	memset(res, 0x00, sizeof(res) * ARRAY_SIZE(res));
+
+	res[0].start	= spi->irq;
+	res[0].flags	= IORESOURCE_IRQ;
+	res[0].name	= "irq";
+
+	ret = platform_device_add_resources(core, res, ARRAY_SIZE(res));
+	if (ret) {
+		dev_err(&spi->dev, "can't add resources\n");
+		goto err5;
+	}
+
+	ret = platform_device_add_data(core, pdata, sizeof(*pdata));
+	if (ret) {
+		dev_err(&spi->dev, "can't add platform data\n");
+		goto err5;
+	}
+
+	ret = platform_device_register(core);
+	if (ret) {
+		dev_err(&spi->dev, "can't register platform device\n");
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
 
@@ -479,12 +522,13 @@ static int __devexit wl1271_remove(struct spi_device *spi)
 	wl1271_unregister_hw(wl);
 	free_irq(wl->irq, wl);
 	wl1271_free_hw(wl);
+	platform_device_del(glue->core);
+	platform_device_put(glue->core);
 	kfree(glue);
 
 	return 0;
 }
 
-
 static struct spi_driver wl1271_spi_driver = {
 	.driver = {
 		.name		= "wl1271_spi",
-- 
1.7.4.1.343.ga91df
