From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 4/6] net: fec: add phy-reset-gpios PROBE_DEFER check
Date: Tue, 11 Apr 2017 19:13:06 +0800
Message-ID: <1491909188-8971-5-git-send-email-fugang.duan@nxp.com>
References: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0068.outbound.protection.outlook.com ([104.47.40.68]:37728
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753071AbdDKLPY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:24 -0400
In-Reply-To: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many boards use i2c/spi expander gpio as phy-reset-gpios and these
gpios maybe registered after fec port, driver should check the return
value of .of_get_named_gpio().

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bcf8675..3cec94e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3187,7 +3187,7 @@ static int fec_enet_init(struct net_device *ndev)
 }
 
 #ifdef CONFIG_OF
-static void fec_reset_phy(struct platform_device *pdev)
+static int fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
 	bool active_high = false;
@@ -3195,7 +3195,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node;
 
 	if (!np)
-		return;
+		return 0;
 
 	err = of_property_read_u32(np, "phy-reset-duration", &msec);
 	/* A sane reset duration should not be longer than 1s */
@@ -3203,8 +3203,10 @@ static void fec_reset_phy(struct platform_device *pdev)
 		msec = 1;
 
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (!gpio_is_valid(phy_reset))
-		return;
+	if (phy_reset == -EPROBE_DEFER)
+		return phy_reset;
+	else if (!gpio_is_valid(phy_reset))
+		return 0;
 
 	active_high = of_property_read_bool(np, "phy-reset-active-high");
 
@@ -3213,7 +3215,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 			"phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
-		return;
+		return err;
 	}
 
 	if (msec > 20)
@@ -3222,14 +3224,17 @@ static void fec_reset_phy(struct platform_device *pdev)
 		usleep_range(msec * 1000, msec * 1000 + 1000);
 
 	gpio_set_value_cansleep(phy_reset, !active_high);
+
+	return 0;
 }
 #else /* CONFIG_OF */
-static void fec_reset_phy(struct platform_device *pdev)
+static int fec_reset_phy(struct platform_device *pdev)
 {
 	/*
 	 * In case of platform probe, the reset has been done
 	 * by machine code.
 	 */
+	return 0;
 }
 #endif /* CONFIG_OF */
 
@@ -3400,6 +3405,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 		if (ret) {
 			dev_err(&pdev->dev,
 				"Failed to enable phy regulator: %d\n", ret);
+			clk_disable_unprepare(fep->clk_ipg);
 			goto failed_regulator;
 		}
 	} else {
@@ -3412,7 +3418,9 @@ static void fec_reset_phy(struct platform_device *pdev)
 	pm_runtime_set_active(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
 
-	fec_reset_phy(pdev);
+	ret = fec_reset_phy(pdev);
+	if (ret)
+		goto failed_reset;
 
 	if (fep->bufdesc_ex)
 		fec_ptp_init(pdev);
@@ -3473,8 +3481,10 @@ static void fec_reset_phy(struct platform_device *pdev)
 	fec_ptp_stop(pdev);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
+failed_reset:
+	pm_runtime_put(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
 failed_regulator:
-	clk_disable_unprepare(fep->clk_ipg);
 failed_clk_ipg:
 	fec_enet_clk_enable(ndev, false);
 failed_clk:
-- 
1.9.1
