From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH v2 1/1] net: fec: fix phy reset operation to let imx6sl evk work
Date: Wed, 11 Sep 2013 10:18:57 +0800
Message-ID: <1378865937-12055-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<s.hauer@pengutronix.de>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:51791 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750844Ab3IKC1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 22:27:14 -0400
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

Changes from V1:
 - remove some unecessary comments.
 - move the function "fec_enet_reset_phy()" up and remove
   the prototype for the function.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Reviewed-by: Shawn Guo <R65073@freescale.com>
CC: Shawn Guo <shawn.guo@linaro.org>
CC: Li Frank <B20596@freescale.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.h      |    3 +
 drivers/net/ethernet/freescale/fec_main.c |   60 +++++++++++++++++------------
 2 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 0120217..473d5fb 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -321,6 +321,9 @@ struct fec_enet_private {
 	struct	napi_struct napi;
 	int	csum_flags;
 
+	int	phy_reset_gpio;
+	int	reset_duration;
+
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	unsigned long last_overflow_check;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f9aacf5..153dcbf 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -238,6 +238,18 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 static int mii_cnt;
 
+static void fec_enet_reset_phy(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	if (gpio_is_valid(fep->phy_reset_gpio)) {
+		gpio_set_value(fep->phy_reset_gpio, 0);
+		msleep(fep->reset_duration);
+		gpio_set_value(fep->phy_reset_gpio, 1);
+	}
+}
+
 static inline
 struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp, struct fec_enet_private *fep)
 {
@@ -1780,6 +1792,9 @@ fec_enet_open(struct net_device *ndev)
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
 	fep->opened = 1;
+
+	fec_enet_reset_phy(fep->pdev);
+
 	return 0;
 }
 
@@ -2029,43 +2044,39 @@ static int fec_enet_init(struct net_device *ndev)
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
+	of_property_read_u32(np, "phy-reset-duration",
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
+				GPIOF_OUT_INIT_HIGH, "phy-reset");
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
-{
-	/*
-	 * In case of platform probe, the reset has been done
-	 * by machine code.
-	 */
-}
-#endif /* CONFIG_OF */
 
 static int
 fec_probe(struct platform_device *pdev)
@@ -2113,6 +2124,7 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
+	fec_enet_of_init(pdev);
 	ret = of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -2181,8 +2193,6 @@ fec_probe(struct platform_device *pdev)
 		fep->reg_phy = NULL;
 	}
 
-	fec_reset_phy(pdev);
-
 	if (fep->bufdesc_ex)
 		fec_ptp_init(pdev);
 
-- 
1.7.1
