From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH 2/3] net: smsc911x: request and deassert optional RESET GPIO
Date: Fri,  8 Jul 2016 11:07:31 +0200
Message-ID: <1467968852-6175-2-git-send-email-linus.walleij@linaro.org>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:33006 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbcGHJHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 05:07:44 -0400
Received: by mail-lf0-f41.google.com with SMTP id f6so26064194lfg.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 02:07:43 -0700 (PDT)
In-Reply-To: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some systems (such as the Qualcomm APQ8060 Dragonboard) the
RESET signal of the SMSC911x is not pulled up by a resistor but
connected to a GPIO line, so that the operating system must
explicitly deassert RESET before use.

Support this in the SMSC911x driver so this ethernet connector
can be used on such targets.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8af25563f627..125d58ac22bd 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -62,6 +62,7 @@
 #include <linux/acpi.h>
 #include <linux/pm_runtime.h>
 #include <linux/property.h>
+#include <linux/gpio/consumer.h>
 
 #include "smsc911x.h"
 
@@ -149,6 +150,9 @@ struct smsc911x_data {
 	/* regulators */
 	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
 
+	/* Reset GPIO */
+	struct gpio_desc *reset_gpiod;
+
 	/* clock */
 	struct clk *clk;
 };
@@ -440,6 +444,15 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 		netdev_err(ndev, "couldn't get regulators %d\n",
 				ret);
 
+	/* Request optional RESET GPIO */
+	pdata->reset_gpiod = devm_gpiod_get(&pdev->dev, "reset",
+					    GPIOD_OUT_HIGH);
+	/* Deassert the signal */
+	if (!IS_ERR(pdata->reset_gpiod)) {
+		dev_info(&pdev->dev, "release reset\n");
+		gpiod_set_value(pdata->reset_gpiod, 0);
+	}
+
 	/* Request clock */
 	pdata->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk))
-- 
2.7.4
