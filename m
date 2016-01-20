From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v6 1/3] can: sja1000: of: add per-compatible init hook
Date: Wed, 20 Jan 2016 16:43:29 +0100
Message-ID: <1453304611-31207-2-git-send-email-mkl@pengutronix.de>
References: <1453304611-31207-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org,
	Damien Riegel <damien.riegel@savoirfairelinux.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:55982 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934453AbcATPng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 10:43:36 -0500
In-Reply-To: <1453304611-31207-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damien Riegel <damien.riegel@savoirfairelinux.com>

This commit adds the capability to allocate and init private data
embedded in the sja1000_priv structure on a per-compatible basis. The
device node is passed as a parameter of the init callback to allow
parsing of custom device tree properties.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_platform.c | 40 +++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 0552ed46a206..777d312f1779 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -27,6 +27,7 @@
 #include <linux/can/platform/sja1000.h>
 #include <linux/io.h>
 #include <linux/of.h>
+#include <linux/of_device.h>
 #include <linux/of_irq.h>
 
 #include "sja1000.h"
@@ -40,6 +41,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
 MODULE_ALIAS("platform:" DRV_NAME);
 MODULE_LICENSE("GPL v2");
 
+struct sja1000_of_data {
+	size_t  priv_sz;
+	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
+};
+
 static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
@@ -154,6 +160,12 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 		priv->cdr |= CDR_CBP; /* default */
 }
 
+static const struct of_device_id sp_of_table[] = {
+	{ .compatible = "nxp,sja1000", .data = NULL, },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, sp_of_table);
+
 static int sp_probe(struct platform_device *pdev)
 {
 	int err, irq = 0;
@@ -163,6 +175,9 @@ static int sp_probe(struct platform_device *pdev)
 	struct resource *res_mem, *res_irq = NULL;
 	struct sja1000_platform_data *pdata;
 	struct device_node *of = pdev->dev.of_node;
+	const struct of_device_id *of_id;
+	const struct sja1000_of_data *of_data = NULL;
+	size_t priv_sz = 0;
 
 	pdata = dev_get_platdata(&pdev->dev);
 	if (!pdata && !of) {
@@ -191,7 +206,13 @@ static int sp_probe(struct platform_device *pdev)
 	if (!irq && !res_irq)
 		return -ENODEV;
 
-	dev = alloc_sja1000dev(0);
+	of_id = of_match_device(sp_of_table, &pdev->dev);
+	if (of_id && of_id->data) {
+		of_data = of_id->data;
+		priv_sz = of_data->priv_sz;
+	}
+
+	dev = alloc_sja1000dev(priv_sz);
 	if (!dev)
 		return -ENOMEM;
 	priv = netdev_priv(dev);
@@ -208,10 +229,17 @@ static int sp_probe(struct platform_device *pdev)
 	dev->irq = irq;
 	priv->reg_base = addr;
 
-	if (of)
+	if (of) {
 		sp_populate_of(priv, of);
-	else
+
+		if (of_data && of_data->init) {
+			err = of_data->init(priv, of);
+			if (err)
+				goto exit_free;
+		}
+	} else {
 		sp_populate(priv, pdata, res_mem->flags);
+	}
 
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -242,12 +270,6 @@ static int sp_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static const struct of_device_id sp_of_table[] = {
-	{.compatible = "nxp,sja1000"},
-	{},
-};
-MODULE_DEVICE_TABLE(of, sp_of_table);
-
 static struct platform_driver sp_driver = {
 	.probe = sp_probe,
 	.remove = sp_remove,
-- 
2.7.0.rc3
