From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] wireless: wlcore: Use devm_kzalloc
Date: Thu, 7 Aug 2014 16:32:45 +0530
Message-ID: <20140807110244.GA10257@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of devm_kzalloc and does away with the
kfrees in the probe and remove functions. Also, a couple of labels and
the initial assignment of the ret variable in the probe function are
removed.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/wireless/ti/wlcore/spi.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 392c882..69601f6 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -327,23 +327,22 @@ static int wl1271_probe(struct spi_device *spi)
 	struct wl12xx_spi_glue *glue;
 	struct wlcore_platdev_data pdev_data;
 	struct resource res[1];
-	int ret = -ENOMEM;
+	int ret;
 
 	memset(&pdev_data, 0x00, sizeof(pdev_data));
 
 	pdev_data.pdata = dev_get_platdata(&spi->dev);
 	if (!pdev_data.pdata) {
 		dev_err(&spi->dev, "no platform data\n");
-		ret = -ENODEV;
-		goto out;
+		return -ENODEV;
 	}
 
 	pdev_data.if_ops = &spi_ops;
 
-	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
+	glue = devm_kzalloc(&spi->dev, sizeof(*glue), GFP_KERNEL);
 	if (!glue) {
 		dev_err(&spi->dev, "can't allocate glue\n");
-		goto out;
+		return -ENOMEM;
 	}
 
 	glue->dev = &spi->dev;
@@ -357,14 +356,13 @@ static int wl1271_probe(struct spi_device *spi)
 	ret = spi_setup(spi);
 	if (ret < 0) {
 		dev_err(glue->dev, "spi_setup failed\n");
-		goto out_free_glue;
+		return ret;
 	}
 
 	glue->core = platform_device_alloc("wl12xx", PLATFORM_DEVID_AUTO);
 	if (!glue->core) {
 		dev_err(glue->dev, "can't allocate platform_device\n");
-		ret = -ENOMEM;
-		goto out_free_glue;
+		return -ENOMEM;
 	}
 
 	glue->core->dev.parent = &spi->dev;
@@ -398,11 +396,6 @@ static int wl1271_probe(struct spi_device *spi)
 
 out_dev_put:
 	platform_device_put(glue->core);
-
-out_free_glue:
-	kfree(glue);
-
-out:
 	return ret;
 }
 
@@ -411,7 +404,6 @@ static int wl1271_remove(struct spi_device *spi)
 	struct wl12xx_spi_glue *glue = spi_get_drvdata(spi);
 
 	platform_device_unregister(glue->core);
-	kfree(glue);
 
 	return 0;
 }
-- 
1.9.1
