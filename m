From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 2/4] net: freescale: fec: add support for optional enet_out clk
Date: Mon, 18 Mar 2013 16:26:23 +0800
Message-ID: <1363595185-12302-3-git-send-email-shawn.guo@linaro.org>
References: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:40800
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab3CRI0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:26:36 -0400
In-Reply-To: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>

Some MX28 boards need the internal enet_out clock to be enabled. So, do
this in the driver iff the clock was referenced via devicetree.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   10 ++++++++++
 drivers/net/ethernet/freescale/fec.h |    1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index d2a9851..2297283 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1800,6 +1800,11 @@ fec_probe(struct platform_device *pdev)
 		goto failed_clk;
 	}
 
+	/* enet_out is optional, depends on board */
+	fep->clk_enet_out = devm_clk_get(&pdev->dev, "enet_out");
+	if (IS_ERR(fep->clk_enet_out))
+		fep->clk_enet_out = NULL;
+
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
 	fep->bufdesc_ex =
 		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
@@ -1810,6 +1815,7 @@ fec_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
+	clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ptp);
 
 	reg_phy = devm_regulator_get(&pdev->dev, "phy");
@@ -1875,6 +1881,7 @@ failed_irq:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ptp);
 failed_pin:
 failed_clk:
@@ -1901,6 +1908,7 @@ fec_drv_remove(struct platform_device *pdev)
 	clk_disable_unprepare(fep->clk_ptp);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1931,6 +1939,7 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 
@@ -1943,6 +1952,7 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 	if (netif_running(ndev)) {
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 01579b8..becb7bd 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -208,6 +208,7 @@ struct fec_enet_private {
 
 	struct clk *clk_ipg;
 	struct clk *clk_ahb;
+	struct clk *clk_enet_out;
 	struct clk *clk_ptp;
 
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
-- 
1.7.9.5
