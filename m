From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: b53: Allow SRAB driver to specify platform data
Date: Fri,  8 Jul 2016 11:39:12 -0700
Message-ID: <1468003153-14026-2-git-send-email-f.fainelli@gmail.com>
References: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jon.mason@broadcom.com, andrew@lunn.ch,
	zajec5@gmail.com, vivien.didelot@savoirfairelinux.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33796 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755484AbcGHSkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:40:18 -0400
Received: by mail-pf0-f195.google.com with SMTP id 66so9013823pfy.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 11:39:55 -0700 (PDT)
In-Reply-To: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For Northstart Plus SoCs, we cannot detect the switch because only the
revision information is provied in the Management page, instead, rely on
Device Tree to tell us the chip id, and pass it down using the
b53_platform_data structure.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_srab.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 70fd47284535..de2b9e710041 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -21,6 +21,7 @@
 #include <linux/delay.h>
 #include <linux/platform_device.h>
 #include <linux/platform_data/b53.h>
+#include <linux/of.h>
 
 #include "b53_priv.h"
 
@@ -356,12 +357,37 @@ static struct b53_io_ops b53_srab_ops = {
 	.write64 = b53_srab_write64,
 };
 
+static const struct of_device_id b53_srab_of_match[] = {
+	{ .compatible = "brcm,bcm53010-srab" },
+	{ .compatible = "brcm,bcm53011-srab" },
+	{ .compatible = "brcm,bcm53012-srab" },
+	{ .compatible = "brcm,bcm53018-srab" },
+	{ .compatible = "brcm,bcm53019-srab" },
+	{ .compatible = "brcm,bcm5301x-srab" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, b53_srab_of_match);
+
 static int b53_srab_probe(struct platform_device *pdev)
 {
+	struct b53_platform_data *pdata = pdev->dev.platform_data;
+	struct device_node *dn = pdev->dev.of_node;
+	const struct of_device_id *of_id = NULL;
 	struct b53_srab_priv *priv;
 	struct b53_device *dev;
 	struct resource *r;
 
+	if (dn)
+		of_id = of_match_node(b53_srab_of_match, dn);
+
+	if (of_id) {
+		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+		if (!pdata)
+			return -ENOMEM;
+
+		pdata->chip_id = (u32)of_id->data;
+	}
+
 	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
@@ -375,6 +401,9 @@ static int b53_srab_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
+	if (pdata)
+		dev->pdata = pdata;
+
 	platform_set_drvdata(pdev, dev);
 
 	return b53_switch_register(dev);
@@ -390,16 +419,6 @@ static int b53_srab_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static const struct of_device_id b53_srab_of_match[] = {
-	{ .compatible = "brcm,bcm53010-srab" },
-	{ .compatible = "brcm,bcm53011-srab" },
-	{ .compatible = "brcm,bcm53012-srab" },
-	{ .compatible = "brcm,bcm53018-srab" },
-	{ .compatible = "brcm,bcm53019-srab" },
-	{ .compatible = "brcm,bcm5301x-srab" },
-	{ /* sentinel */ },
-};
-
 static struct platform_driver b53_srab_driver = {
 	.probe = b53_srab_probe,
 	.remove = b53_srab_remove,
-- 
2.7.4
