From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net: fec: fix phy reset operation to let imx6sl evk work
Date: Tue, 10 Sep 2013 10:35:05 +0800
Message-ID: <1378780505-23102-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<s.hauer@pengutronix.de>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:16045
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751210Ab3IJCnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 22:43:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch do correct phy reset operation to let imx6sl evk
ethernet work.

Current driver only do phy reset in probe function, which is
not right. Since some phy clock is disabled after module probe,
the phy enter abnormal status, which needs do reset to recovery
the phy. And do ifconfig ethx up/down test, the phy also enter
abnormal status.

The log as:
libphy: 2188000.ethernet:04 - Link is Up - 10/Full
libphy: 2188000.ethernet:04 - Link is Up - 100/Full
libphy: 2188000.ethernet:04 - Link is Down
libphy: 2188000.ethernet:04 - Link is Up - 10/Half
libphy: 2188000.ethernet:04 - Link is Up - 10/Full
libphy: 2188000.ethernet:04 - Link is Up - 100/Full
...

So, do phy reset if ethx up/down or clock enable/disable.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Reviewed-by: Shawn Guo <R65073@freescale.com>
CC: Shawn Guo <R65073@freescale.com>
CC: Li Frank <B20596@freescale.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/freescale/fec.h      |    3 +
 drivers/net/ethernet/freescale/fec_main.c |   61 +++++++++++++++++-----------
 2 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 0120217..b33c92d 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -321,6 +321,9 @@ struct fec_enet_private {
 	struct	napi_struct napi;
 	int	csum_flags;
 
+	int	phy_reset_gpio;
+	int     reset_duration;
+
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	unsigned long last_overflow_check;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7a87012..5a9ba1d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -18,7 +18,7 @@
  * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
  * Copyright (c) 2004-2006 Macq Electronique SA.
  *
- * Copyright (C) 2010-2011 Freescale Semiconductor, Inc.
+ * Copyright (C) 2010-2013 Freescale Semiconductor, Inc.
  */
 
 #include <linux/module.h>
@@ -61,6 +61,7 @@
 #include "fec.h"
 
 static void set_multicast_list(struct net_device *ndev);
+static void fec_reset_phy(struct platform_device *pdev);
 
 #if defined(CONFIG_ARM)
 #define FEC_ALIGNMENT	0xf
@@ -1781,6 +1782,10 @@ fec_enet_open(struct net_device *ndev)
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
 	fep->opened = 1;
+
+	/* reset phy */
+	fec_enet_reset_phy(fep->pdev);
+
 	return 0;
 }
 
@@ -2030,43 +2035,52 @@ static int fec_enet_init(struct net_device *ndev)
 	return 0;
 }
 
-#ifdef CONFIG_OF
-static void fec_reset_phy(struct platform_device *pdev)
+static void fec_enet_of_init(struct platform_device *pdev)
 {
-	int err, phy_reset;
-	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	int err;
+
+	/*
+	 * init phy-reset-gpio to one invalid GPIO for no phy
+	 * gpio reset platform
+	 */
+	fep->phy_reset_gpio = -1;
 
 	if (!np)
 		return;
 
-	of_property_read_u32(np, "phy-reset-duration", &msec);
+	of_property_read_u32(np, "phy-reset-duration"
+				&fep->reset_duration);
 	/* A sane reset duration should not be longer than 1s */
-	if (msec > 1000)
-		msec = 1;
+	if ((fep->reset_duration > 1000) || (fep->reset_duration == 0))
+		fep->reset_duration = 1;
 
-	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (!gpio_is_valid(phy_reset))
+	fep->phy_reset_gpio = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (!gpio_is_valid(fep->phy_reset_gpio))
 		return;
 
-	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-				    GPIOF_OUT_INIT_LOW, "phy-reset");
+	err = devm_gpio_request_one(&pdev->dev, fep->phy_reset_gpio,
+				    GPIOF_OUT_INIT_HIGH, "phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
-		return;
+		fep->phy_reset_gpio = -1;
 	}
-	msleep(msec);
-	gpio_set_value(phy_reset, 1);
 }
-#else /* CONFIG_OF */
-static void fec_reset_phy(struct platform_device *pdev)
+
+static void fec_enet_reset_phy(struct platform_device *pdev)
 {
-	/*
-	 * In case of platform probe, the reset has been done
-	 * by machine code.
-	 */
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	/* check GPIO valid to avoid kernel print warning when no gpio reset */
+	if (gpio_is_valid(fep->phy_reset_gpio)) {
+		gpio_set_value(fep->phy_reset_gpio, 0);
+		msleep(fep->reset_duration);
+		gpio_set_value(fep->phy_reset_gpio, 1);
+	}
 }
-#endif /* CONFIG_OF */
 
 static int
 fec_probe(struct platform_device *pdev)
@@ -2117,6 +2131,7 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
+	fec_enet_of_init(pdev);
 	ret = of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
 		pdata = pdev->dev.platform_data;
@@ -2170,8 +2185,6 @@ fec_probe(struct platform_device *pdev)
 		fep->reg_phy = NULL;
 	}
 
-	fec_reset_phy(pdev);
-
 	if (fep->bufdesc_ex)
 		fec_ptp_init(pdev);
 
-- 
1.7.1
