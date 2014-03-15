From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 5/5] at86rf230: add support
	for devicetree
Date: Sat, 15 Mar 2014 09:29:07 +0100
Message-ID: <1394872147-3021-6-git-send-email-alex.aring@gmail.com>
References: <1394872147-3021-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394872147-3021-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds devicetree support for the at86rf230 driver.

Possible gpios to configure are "reset-gpio" and "sleep-gpio".
Also add support to configure the "irq-type" for the irq polarity
register.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 48 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 47677e3f9..e8004ef 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -31,6 +31,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/at86rf230.h>
 #include <linux/skbuff.h>
+#include <linux/of_gpio.h>
 
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
@@ -1035,6 +1036,40 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	return 0;
 }
 
+static struct at86rf230_platform_data *
+at86rf230_get_pdata(struct spi_device *spi)
+{
+	struct at86rf230_platform_data *pdata;
+	const char *irq_type;
+
+	if (!IS_ENABLED(CONFIG_OF) || !spi->dev.of_node)
+		return spi->dev.platform_data;
+
+	pdata = devm_kzalloc(&spi->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		goto done;
+
+	pdata->rstn = of_get_named_gpio(spi->dev.of_node, "reset-gpio", 0);
+	pdata->slp_tr = of_get_named_gpio(spi->dev.of_node, "sleep-gpio", 0);
+
+	pdata->irq_type = IRQF_TRIGGER_RISING;
+	of_property_read_string(spi->dev.of_node, "irq-type", &irq_type);
+	if (!strcmp(irq_type, "level-high"))
+		pdata->irq_type = IRQF_TRIGGER_HIGH;
+	else if (!strcmp(irq_type, "level-low"))
+		pdata->irq_type = IRQF_TRIGGER_LOW;
+	else if (!strcmp(irq_type, "edge-rising"))
+		pdata->irq_type = IRQF_TRIGGER_RISING;
+	else if (!strcmp(irq_type, "edge-falling"))
+		pdata->irq_type = IRQF_TRIGGER_FALLING;
+	else
+		dev_warn(&spi->dev, "wrong irq-type specified using edge-rising\n");
+
+	spi->dev.platform_data = pdata;
+done:
+	return pdata;
+}
+
 static int at86rf230_probe(struct spi_device *spi)
 {
 	struct at86rf230_platform_data *pdata;
@@ -1053,7 +1088,7 @@ static int at86rf230_probe(struct spi_device *spi)
 		return -EINVAL;
 	}
 
-	pdata = spi->dev.platform_data;
+	pdata = at86rf230_get_pdata(spi);
 	if (!pdata) {
 		dev_err(&spi->dev, "no platform_data\n");
 		return -EINVAL;
@@ -1231,8 +1266,19 @@ static int at86rf230_remove(struct spi_device *spi)
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_OF)
+static struct of_device_id at86rf230_of_match[] = {
+	{ .compatible = "atmel,at86rf230", },
+	{ .compatible = "atmel,at86rf231", },
+	{ .compatible = "atmel,at86rf233", },
+	{ .compatible = "atmel,at86rf212", },
+	{ },
+};
+#endif
+
 static struct spi_driver at86rf230_driver = {
 	.driver = {
+		.of_match_table = of_match_ptr(at86rf230_of_match),
 		.name	= "at86rf230",
 		.owner	= THIS_MODULE,
 	},
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
