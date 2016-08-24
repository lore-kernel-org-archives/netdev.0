From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH 2/3 v2] net: smsc911x: request and deassert optional RESET GPIO
Date: Wed, 24 Aug 2016 14:59:41 +0200
Message-ID: <1472043582-7653-2-git-send-email-linus.walleij@linaro.org>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>,
        Jeremy Linton <jeremy.linton@arm.com>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>,
        Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36016 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753012AbcHXNAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 09:00:17 -0400
Received: by mail-lf0-f46.google.com with SMTP id g62so11270104lfe.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 05:59:58 -0700 (PDT)
In-Reply-To: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
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
ChangeLog v1->v2:
- Use devm_gpiod_request_optiona() and request the line with
  GPIOD_OUT_LOW so it is deasserted immediately if active.
---
 drivers/net/ethernet/smsc/smsc911x.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index ca3134540d2d..8ab8d4b9614b 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -62,6 +62,7 @@
 #include <linux/acpi.h>
 #include <linux/pm_runtime.h>
 #include <linux/property.h>
+#include <linux/gpio/consumer.h>
 
 #include "smsc911x.h"
 
@@ -147,6 +148,9 @@ struct smsc911x_data {
 	/* regulators */
 	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
 
+	/* Reset GPIO */
+	struct gpio_desc *reset_gpiod;
+
 	/* clock */
 	struct clk *clk;
 };
@@ -438,6 +442,11 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 		netdev_err(ndev, "couldn't get regulators %d\n",
 				ret);
 
+	/* Request optional RESET GPIO */
+	pdata->reset_gpiod = devm_gpiod_get_optional(&pdev->dev,
+						     "reset",
+						     GPIOD_OUT_LOW);
+
 	/* Request clock */
 	pdata->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk))
-- 
2.7.4
