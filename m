From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 01/14] at86rf230: use
	irq_get_trigger_type
Date: Thu, 24 Apr 2014 19:09:05 +0200
Message-ID: <1398359358-11085-2-git-send-email-alex.aring@gmail.com>
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

This patch removes the platform data for the irq_type. We use instead
the irq_get_trigger_type function to get these flags which should
already configured by the interrupt controller.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 28 ++++++++--------------------
 include/linux/spi/at86rf230.h      | 14 --------------
 2 files changed, 8 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index e36f194..17b9c9a 100644
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
@@ -970,8 +971,7 @@ static int at86rf230_irq_polarity(struct at86rf230_local *lp, int pol)
 
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
-	struct at86rf230_platform_data *pdata = lp->spi->dev.platform_data;
-	int rc, irq_pol;
+	int rc, irq_pol, irq_type;
 	u8 status;
 	u8 csma_seed[2];
 
@@ -983,8 +983,9 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
+	irq_type = irq_get_trigger_type(lp->spi->irq);
 	/* configure irq polarity, defaults to high active */
-	if (pdata->irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
+	if (irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
 		irq_pol = IRQ_ACTIVE_LOW;
 	else
 		irq_pol = IRQ_ACTIVE_HIGH;
@@ -1032,7 +1033,6 @@ static struct at86rf230_platform_data *
 at86rf230_get_pdata(struct spi_device *spi)
 {
 	struct at86rf230_platform_data *pdata;
-	const char *irq_type;
 
 	if (!IS_ENABLED(CONFIG_OF) || !spi->dev.of_node)
 		return spi->dev.platform_data;
@@ -1044,19 +1044,6 @@ at86rf230_get_pdata(struct spi_device *spi)
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
@@ -1071,7 +1058,7 @@ static int at86rf230_probe(struct spi_device *spi)
 	u8 part = 0, version = 0, status;
 	irq_handler_t irq_handler;
 	work_func_t irq_worker;
-	int rc;
+	int rc, irq_type;
 	const char *chip;
 	struct ieee802154_ops *ops = NULL;
 
@@ -1176,7 +1163,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	dev->extra_tx_headroom = 0;
 	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK;
 
-	if (pdata->irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
+	irq_type = irq_get_trigger_type(spi->irq);
+	if (irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
 		irq_worker = at86rf230_irqwork;
 		irq_handler = at86rf230_isr;
 	} else {
@@ -1203,7 +1191,7 @@ static int at86rf230_probe(struct spi_device *spi)
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
1.9.2


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
