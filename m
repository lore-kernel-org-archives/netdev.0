From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 05/14] at86rf230: use
	devm_gpio_request_one
Date: Thu, 24 Apr 2014 19:09:09 +0200
Message-ID: <1398359358-11085-6-git-send-email-alex.aring@gmail.com>
References: <1398359358-11085-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1398359358-11085-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
index 5856488..d52700f 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1074,27 +1074,17 @@ static int at86rf230_probe(struct spi_device *spi)
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
@@ -1108,13 +1098,12 @@ static int at86rf230_probe(struct spi_device *spi)
 
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
@@ -1141,16 +1130,12 @@ static int at86rf230_probe(struct spi_device *spi)
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
@@ -1212,35 +1197,21 @@ err_hw_init:
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
 
 	/* mask all at86rf230 irq's */
 	at86rf230_write_subreg(lp, SR_IRQ_MASK, 0);
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
1.9.2


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
