From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Do not assume that PHY reset is active low
Date: Tue, 24 Dec 2013 12:16:01 -0200
Message-ID: <1387894561-31494-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org,
	p.zabel@pengutronix.de, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:34221 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab3LXOQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 09:16:11 -0500
Received: by mail-qa0-f50.google.com with SMTP id i13so6236443qae.9
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 06:16:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

We should not assume that the PHY reset is always active low.

Retrieve this information from the device tree instead, so that the PHY reset
can work on both cases.

Reported-by: Philipp Zabel <p.zabel@pengutronix.de>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6530177..4b9976a0 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2053,6 +2053,8 @@ static void fec_reset_phy(struct platform_device *pdev)
 	int err, phy_reset;
 	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
+	enum of_gpio_flags flags;
+	bool port;
 
 	if (!np)
 		return;
@@ -2062,18 +2064,22 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (msec > 1000)
 		msec = 1;
 
-	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	phy_reset = of_get_named_gpio_flags(np, "phy-reset-gpios", 0, &flags);
 	if (!gpio_is_valid(phy_reset))
 		return;
 
-	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-				    GPIOF_OUT_INIT_LOW, "phy-reset");
+	if (flags & OF_GPIO_ACTIVE_LOW)
+		port = GPIOF_OUT_INIT_LOW;
+	else
+		port = GPIOF_OUT_INIT_HIGH;
+
+	err = devm_gpio_request_one(&pdev->dev, phy_reset, port, "phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-	gpio_set_value(phy_reset, 1);
+	gpio_set_value(phy_reset, !port);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
1.8.1.2
