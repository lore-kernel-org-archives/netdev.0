From: Sascha Herrmann <sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
Subject: [PATCH 1/2 v2] at86rf230: add irq type
	configuration option
Date: Fri, 12 Apr 2013 00:16:13 +0200
Message-ID: <031f12b1d0449ffb6fe43dfd6b136369581cae4c.1365716125.git.sascha@ps.nvbi.de>
References: <cover.1365716125.git.sascha@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <cover.1365716125.git.sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
In-Reply-To: <cover.1365716125.git.sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
References: <cover.1365716125.git.sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Add option to at86rf230 platform data to configure the type of the
interrupt used by the driver. The irq polarity of the device will
be configured accordingly.

Signed-off-by: Sascha Herrmann <sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |   44 ++++++++++++++++++++++++------------
 include/linux/spi/at86rf230.h      |   14 ++++++++++++
 2 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index fc315dd..c69acb2 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -219,6 +219,9 @@ struct at86rf230_local {
 #define IRQ_PLL_UNL	(1 << 1)
 #define IRQ_PLL_LOCK	(1 << 0)
 
+#define IRQ_ACTIVE_HIGH	0
+#define IRQ_ACTIVE_LOW	1
+
 #define STATE_P_ON		0x00	/* BUSY */
 #define STATE_BUSY_RX		0x01
 #define STATE_BUSY_TX		0x02
@@ -726,11 +729,16 @@ static irqreturn_t at86rf230_isr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static int at86rf230_irq_polarity(struct at86rf230_local *lp, int pol)
+{
+	return at86rf230_write_subreg(lp, SR_IRQ_POLARITY, pol);
+}
 
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
 	u8 status;
-	int rc;
+	int rc, irq_pol;
+	struct at86rf230_platform_data *pdata = lp->spi->dev.platform_data;
 
 	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
 	if (rc)
@@ -748,6 +756,16 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		dev_info(&lp->spi->dev, "Status: %02x\n", status);
 	}
 
+	/* configure irq polarity, defaults to high active */
+	if (pdata->irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
+		irq_pol = IRQ_ACTIVE_LOW;
+	else
+		irq_pol = IRQ_ACTIVE_HIGH;
+
+	rc = at86rf230_irq_polarity(lp, irq_pol);
+	if (rc)
+		return rc;
+
 	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, 0xff); /* IRQ_TRX_UR |
 							     * IRQ_CCA_ED |
 							     * IRQ_TRX_END |
@@ -798,27 +816,21 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	return 0;
 }
 
-static int at86rf230_fill_data(struct spi_device *spi)
+static void at86rf230_fill_data(struct spi_device *spi)
 {
 	struct at86rf230_local *lp = spi_get_drvdata(spi);
 	struct at86rf230_platform_data *pdata = spi->dev.platform_data;
 
-	if (!pdata) {
-		dev_err(&spi->dev, "no platform_data\n");
-		return -EINVAL;
-	}
-
 	lp->rstn = pdata->rstn;
 	lp->slp_tr = pdata->slp_tr;
 	lp->dig2 = pdata->dig2;
-
-	return 0;
 }
 
 static int at86rf230_probe(struct spi_device *spi)
 {
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
+	struct at86rf230_platform_data *pdata;
 	u8 man_id_0, man_id_1;
 	int rc;
 	const char *chip;
@@ -829,6 +841,12 @@ static int at86rf230_probe(struct spi_device *spi)
 		return -EINVAL;
 	}
 
+	pdata = spi->dev.platform_data;
+	if (!pdata) {
+		dev_err(&spi->dev, "no platform_data\n");
+		return -EINVAL;
+	}
+
 	dev = ieee802154_alloc_device(sizeof(*lp), &at86rf230_ops);
 	if (!dev)
 		return -ENOMEM;
@@ -851,9 +869,7 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	spi_set_drvdata(spi, lp);
 
-	rc = at86rf230_fill_data(spi);
-	if (rc)
-		goto err_fill;
+	at86rf230_fill_data(spi);
 
 	rc = gpio_request(lp->rstn, "rstn");
 	if (rc)
@@ -928,7 +944,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc)
 		goto err_gpio_dir;
 
-	rc = request_irq(spi->irq, at86rf230_isr, IRQF_SHARED,
+	rc = request_irq(spi->irq, at86rf230_isr,
+			 IRQF_SHARED | pdata->irq_type,
 			 dev_name(&spi->dev), lp);
 	if (rc)
 		goto err_gpio_dir;
@@ -948,7 +965,6 @@ err_gpio_dir:
 err_slp_tr:
 	gpio_free(lp->rstn);
 err_rstn:
-err_fill:
 	spi_set_drvdata(spi, NULL);
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
diff --git a/include/linux/spi/at86rf230.h b/include/linux/spi/at86rf230.h
index b2b1afb..aa327a8 100644
--- a/include/linux/spi/at86rf230.h
+++ b/include/linux/spi/at86rf230.h
@@ -26,6 +26,20 @@ struct at86rf230_platform_data {
 	int rstn;
 	int slp_tr;
 	int dig2;
+
+	/* Setting the irq_type will configure the driver to request
+	 * the platform irq trigger type according to the given value
+	 * and configure the interrupt polarity of the device to the
+	 * corresponding polarity.
+	 *
+	 * Allowed values are: IRQF_TRIGGER_RISING, IRQF_TRIGGER_FALLING,
+	 *                     IRQF_TRIGGER_HIGH and IRQF_TRIGGER_LOW
+	 *
+	 * Setting it to 0, the driver does not touch the trigger type
+	 * configuration of the interrupt and sets the interrupt polarity
+	 * of the device to high active (the default value).
+	 */
+	int irq_type;
 };
 
 #endif
-- 
1.7.10.4


------------------------------------------------------------------------------
Precog is a next-generation analytics platform capable of advanced
analytics on semi-structured data. The platform includes APIs for building
apps and a phenomenal toolset for data science. Developers can use
our toolset for easy data analysis & visualization. Get a free account!
http://www2.precog.com/precogplatform/slashdotnewsletter
