From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 5/6] at86rf230: use
	devm_gpio_request_one
Date: Wed, 26 Mar 2014 15:11:56 +0100
Message-ID: <1395843117-16494-6-git-send-email-alex.aring@gmail.com>
References: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1395843117-16494-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch replace the gpio_request functions with devm_gpio_request_one
functions. Then we don't need to take care about freeing gpios.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 53 +++++++++-----------------------------
 1 file changed, 12 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index a3f9d91..1044a02 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1083,27 +1083,17 @@ static int at86rf230_probe(struct spi_device *spi)
 	}
 
 	if (gpio_is_valid(pdata->rstn)) {
-		rc = gpio_request(pdata->rstn, "rstn");
+		rc = devm_gpio_request_one(&spi->dev, pdata->rstn,
+					   GPIOF_OUT_INIT_HIGH, "rstn");
 		if (rc)
 			return rc;
 	}
 
 	if (gpio_is_valid(pdata->slp_tr)) {
-		rc = gpio_request(pdata->slp_tr, "slp_tr");
+		rc = devm_gpio_request_one(&spi->dev, pdata->slp_tr,
+					   GPIOF_OUT_INIT_LOW, "slp_tr");
 		if (rc)
-			goto err_slp_tr;
-	}
-
-	if (gpio_is_valid(pdata->rstn)) {
-		rc = gpio_direction_output(pdata->rstn, 1);
-		if (rc)
-			goto err_gpio_dir;
-	}
-
-	if (gpio_is_valid(pdata->slp_tr)) {
-		rc = gpio_direction_output(pdata->slp_tr, 0);
-		if (rc)
-			goto err_gpio_dir;
+			return rc;
 	}
 
 	/* Reset */
@@ -1117,13 +1107,12 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	rc = __at86rf230_detect_device(spi, &man_id, &part, &version);
 	if (rc < 0)
-		goto err_gpio_dir;
+		return rc;
 
 	if (man_id != 0x001f) {
 		dev_err(&spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
 			man_id >> 8, man_id & 0xFF);
-		rc = -EINVAL;
-		goto err_gpio_dir;
+		return -EINVAL;
 	}
 
 	switch (part) {
@@ -1150,16 +1139,12 @@ static int at86rf230_probe(struct spi_device *spi)
 	}
 
 	dev_info(&spi->dev, "Detected %s chip version %d\n", chip, version);
-	if (!ops) {
-		rc = -ENOTSUPP;
-		goto err_gpio_dir;
-	}
+	if (!ops)
+		return -ENOTSUPP;
 
 	dev = ieee802154_alloc_device(sizeof(*lp), ops);
-	if (!dev) {
-		rc = -ENOMEM;
-		goto err_gpio_dir;
-	}
+	if (!dev)
+		return -ENOMEM;
 
 	lp = dev->priv;
 	lp->dev = dev;
@@ -1221,33 +1206,19 @@ err_hw_init:
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
 
-err_gpio_dir:
-	if (gpio_is_valid(pdata->slp_tr))
-		gpio_free(pdata->slp_tr);
-err_slp_tr:
-	if (gpio_is_valid(pdata->rstn))
-		gpio_free(pdata->rstn);
 	return rc;
 }
 
 static int at86rf230_remove(struct spi_device *spi)
 {
 	struct at86rf230_local *lp = spi_get_drvdata(spi);
-	struct at86rf230_platform_data *pdata = spi->dev.platform_data;
 
 	ieee802154_unregister_device(lp->dev);
-
 	flush_work(&lp->irqwork);
-
-	if (gpio_is_valid(pdata->slp_tr))
-		gpio_free(pdata->slp_tr);
-	if (gpio_is_valid(pdata->rstn))
-		gpio_free(pdata->rstn);
-
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
-
 	dev_dbg(&spi->dev, "unregistered at86rf230\n");
+
 	return 0;
 }
 
-- 
1.9.1


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
