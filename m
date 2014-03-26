From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 2/6] at86rf230: use irq_get_trigger_type
Date: Wed, 26 Mar 2014 15:11:53 +0100
Message-ID: <1395843117-16494-3-git-send-email-alex.aring@gmail.com>
References: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64214 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbaCZOMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:12:35 -0400
In-Reply-To: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the platform data for the irq_type. We use instead
the irq_get_trigger_type function to get these flags which should
already configured by the interrupt controller.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 28 ++++++++--------------------
 include/linux/spi/at86rf230.h      | 14 --------------
 2 files changed, 8 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index df290a5..b6aa741 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -23,6 +23,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
+#include <linux/irq.h>
 #include <linux/gpio.h>
 #include <linux/delay.h>
 #include <linux/mutex.h>
@@ -971,8 +972,7 @@ static int at86rf230_irq_polarity(struct at86rf230_local *lp, int pol)
 
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
-	struct at86rf230_platform_data *pdata = lp->spi->dev.platform_data;
-	int rc, irq_pol;
+	int rc, irq_pol, irq_type;
 	u8 status;
 	u8 csma_seed[2];
 
@@ -984,8 +984,9 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
+	irq_type = irq_get_trigger_type(lp->spi->irq);
 	/* configure irq polarity, defaults to high active */
-	if (pdata->irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
+	if (irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
 		irq_pol = IRQ_ACTIVE_LOW;
 	else
 		irq_pol = IRQ_ACTIVE_HIGH;
@@ -1041,7 +1042,6 @@ static struct at86rf230_platform_data *
 at86rf230_get_pdata(struct spi_device *spi)
 {
 	struct at86rf230_platform_data *pdata;
-	const char *irq_type;
 
 	if (!IS_ENABLED(CONFIG_OF) || !spi->dev.of_node)
 		return spi->dev.platform_data;
@@ -1053,19 +1053,6 @@ at86rf230_get_pdata(struct spi_device *spi)
 	pdata->rstn = of_get_named_gpio(spi->dev.of_node, "reset-gpio", 0);
 	pdata->slp_tr = of_get_named_gpio(spi->dev.of_node, "sleep-gpio", 0);
 
-	pdata->irq_type = IRQF_TRIGGER_RISING;
-	of_property_read_string(spi->dev.of_node, "irq-type", &irq_type);
-	if (!strcmp(irq_type, "level-high"))
-		pdata->irq_type = IRQF_TRIGGER_HIGH;
-	else if (!strcmp(irq_type, "level-low"))
-		pdata->irq_type = IRQF_TRIGGER_LOW;
-	else if (!strcmp(irq_type, "edge-rising"))
-		pdata->irq_type = IRQF_TRIGGER_RISING;
-	else if (!strcmp(irq_type, "edge-falling"))
-		pdata->irq_type = IRQF_TRIGGER_FALLING;
-	else
-		dev_warn(&spi->dev, "wrong irq-type specified using edge-rising\n");
-
 	spi->dev.platform_data = pdata;
 done:
 	return pdata;
@@ -1080,7 +1067,7 @@ static int at86rf230_probe(struct spi_device *spi)
 	u8 part = 0, version = 0, status;
 	irq_handler_t irq_handler;
 	work_func_t irq_worker;
-	int rc;
+	int rc, irq_type;
 	const char *chip;
 	struct ieee802154_ops *ops = NULL;
 
@@ -1185,7 +1172,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	dev->extra_tx_headroom = 0;
 	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK;
 
-	if (pdata->irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
+	irq_type = irq_get_trigger_type(spi->irq);
+	if (irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
 		irq_worker = at86rf230_irqwork;
 		irq_handler = at86rf230_isr;
 	} else {
@@ -1212,7 +1200,7 @@ static int at86rf230_probe(struct spi_device *spi)
 		goto err_hw_init;
 
 	rc = request_irq(spi->irq, irq_handler,
-			 IRQF_SHARED | pdata->irq_type,
+			 IRQF_SHARED | irq_type,
 			 dev_name(&spi->dev), lp);
 	if (rc)
 		goto err_hw_init;
diff --git a/include/linux/spi/at86rf230.h b/include/linux/spi/at86rf230.h
index aa327a8..b2b1afb 100644
--- a/include/linux/spi/at86rf230.h
+++ b/include/linux/spi/at86rf230.h
@@ -26,20 +26,6 @@ struct at86rf230_platform_data {
 	int rstn;
 	int slp_tr;
 	int dig2;
-
-	/* Setting the irq_type will configure the driver to request
-	 * the platform irq trigger type according to the given value
-	 * and configure the interrupt polarity of the device to the
-	 * corresponding polarity.
-	 *
-	 * Allowed values are: IRQF_TRIGGER_RISING, IRQF_TRIGGER_FALLING,
-	 *                     IRQF_TRIGGER_HIGH and IRQF_TRIGGER_LOW
-	 *
-	 * Setting it to 0, the driver does not touch the trigger type
-	 * configuration of the interrupt and sets the interrupt polarity
-	 * of the device to high active (the default value).
-	 */
-	int irq_type;
 };
 
 #endif
-- 
1.9.1
