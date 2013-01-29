From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [RFC 1/3] net: freescale: fec: add support for optional enet_out clk
Date: Tue, 29 Jan 2013 15:46:11 +0100
Message-ID: <1359470773-14290-2-git-send-email-w.sang@pengutronix.de>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@freescale.com>,
	Wolfram Sang <w.sang@pengutronix.de>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59045 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756926Ab3A2Oq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:46:28 -0500
In-Reply-To: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some MX28 boards need the internal enet_out clock to be enabled. So, do
this in the driver iff the clock was referenced via devicetree.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
---

davidm: Please don't apply before Shawn as the mxs-maintainer has given his ack
on the general procedure. Or maybe he can merge it via his tree?

 drivers/net/ethernet/freescale/fec.c |   10 ++++++++++
 drivers/net/ethernet/freescale/fec.h |    1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0704bca..6573bd5 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1628,6 +1628,11 @@ fec_probe(struct platform_device *pdev)
 		goto failed_clk;
 	}
 
+	/* enet_out is optional, depends on board */
+	fep->clk_enet_out = devm_clk_get(&pdev->dev, "enet_out");
+	if (IS_ERR(fep->clk_enet_out))
+		fep->clk_enet_out = NULL;
+
 #ifdef CONFIG_FEC_PTP
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
 	if (IS_ERR(fep->clk_ptp)) {
@@ -1638,6 +1643,7 @@ fec_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
+	clk_prepare_enable(fep->clk_enet_out);
 #ifdef CONFIG_FEC_PTP
 	clk_prepare_enable(fep->clk_ptp);
 #endif
@@ -1679,6 +1685,7 @@ failed_register:
 failed_mii_init:
 failed_init:
 failed_regulator:
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 #ifdef CONFIG_FEC_PTP
@@ -1722,6 +1729,7 @@ fec_drv_remove(struct platform_device *pdev)
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
 #endif
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 	iounmap(fep->hwp);
@@ -1747,6 +1755,7 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
+	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 
@@ -1759,6 +1768,7 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 	if (netif_running(ndev)) {
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index c5a3bc1..0648dbe 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -203,6 +203,7 @@ struct fec_enet_private {
 
 	struct clk *clk_ipg;
 	struct clk *clk_ahb;
+	struct clk *clk_enet_out;
 #ifdef CONFIG_FEC_PTP
 	struct clk *clk_ptp;
 #endif
-- 
1.7.10.4
