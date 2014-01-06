From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Revert "fec: Do not assume that PHY reset is active low"
Date: Sun,  5 Jan 2014 22:08:25 -0200
Message-ID: <1388966905-8092-1-git-send-email-festevam@gmail.com>
Cc: shawn.guo@linaro.org, olof@lixom.net, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:41369 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaAFAIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 19:08:47 -0500
Received: by mail-qa0-f50.google.com with SMTP id k15so853369qaq.2
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 16:08:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

In order to keep DT compatibility we need to revert this, otherwise the original
dts files will no longer work with this driver change.

This reverts commit 7a399e3a2e05bc580a78ea72371b3896827f72e1.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
David,

We need this for 3.13.

Sorry for the breakage.

 drivers/net/ethernet/freescale/fec_main.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 45b8b22..50bb71c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2049,8 +2049,6 @@ static void fec_reset_phy(struct platform_device *pdev)
 	int err, phy_reset;
 	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
-	enum of_gpio_flags flags;
-	bool port;
 
 	if (!np)
 		return;
@@ -2060,22 +2058,18 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (msec > 1000)
 		msec = 1;
 
-	phy_reset = of_get_named_gpio_flags(np, "phy-reset-gpios", 0, &flags);
+	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	if (!gpio_is_valid(phy_reset))
 		return;
 
-	if (flags & OF_GPIO_ACTIVE_LOW)
-		port = GPIOF_OUT_INIT_LOW;
-	else
-		port = GPIOF_OUT_INIT_HIGH;
-
-	err = devm_gpio_request_one(&pdev->dev, phy_reset, port, "phy-reset");
+	err = devm_gpio_request_one(&pdev->dev, phy_reset,
+				    GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-	gpio_set_value(phy_reset, !port);
+	gpio_set_value(phy_reset, 1);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
1.8.1.2
