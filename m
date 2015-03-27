From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 3/4] net/macb: fix capabilities configuration
Date: Fri, 27 Mar 2015 16:34:11 +0100
Message-ID: <bd7194896b4e4517a7675ae02fe7bed01f19a02d.1427469791.git.nicolas.ferre@atmel.com>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>,
	<punnaia@xilinx.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:17397 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964794AbbC0PfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 11:35:12 -0400
In-Reply-To: <cover.1427469791.git.nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Capabilities configuration by macb_configure_caps() was moved far too late by
421d9df0628b (net/macb: merge at91_ether driver into macb driver) which would
lead to badly configured hardware.
So, move this function to early probe and modify its prototype to re-gain its
original behavior.
DT data retrieval is also moved to simplify the probe code flow.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Cc: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 drivers/net/ethernet/cadence/macb.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index bc3eab95022f..64e35a50e5c1 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2132,10 +2132,13 @@ static const struct net_device_ops macb_netdev_ops = {
  * Configure peripheral capacities according to device tree
  * and integration options used
  */
-static void macb_configure_caps(struct macb *bp)
+static void macb_configure_caps(struct macb *bp, const struct macb_config *dt_conf)
 {
 	u32 dcfg;
 
+	if (dt_conf)
+		bp->caps = dt_conf->caps;
+
 	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2)
 		bp->caps |= MACB_CAPS_MACB_IS_GEM;
 
@@ -2313,9 +2316,6 @@ static int macb_init(struct platform_device *pdev)
 
 	macb_or_gem_writel(bp, USRIO, val);
 
-	/* setup capacities */
-	macb_configure_caps(bp);
-
 	/* Set MII management clock divider */
 	val = macb_mdc_clk_div(bp);
 	val |= macb_dbw(bp);
@@ -2720,6 +2720,20 @@ static int macb_probe(struct platform_device *pdev)
 	bp->queue_mask = queue_mask;
 	spin_lock_init(&bp->lock);
 
+	if (np) {
+		const struct of_device_id *match;
+
+		match = of_match_node(macb_dt_ids, np);
+		if (match && match->data) {
+			macb_config = match->data;
+			bp->dma_burst_length = macb_config->dma_burst_length;
+			init = macb_config->init;
+		}
+	}
+
+	/* setup capacities */
+	macb_configure_caps(bp, macb_config);
+
 	platform_set_drvdata(pdev, dev);
 
 	dev->irq = platform_get_irq(pdev, 0);
@@ -2743,20 +2757,6 @@ static int macb_probe(struct platform_device *pdev)
 		bp->phy_interface = err;
 	}
 
-	if (np) {
-		const struct of_device_id *match;
-
-		match = of_match_node(macb_dt_ids, np);
-		if (match)
-			macb_config = match->data;
-	}
-
-	if (macb_config) {
-		bp->caps = macb_config->caps;
-		bp->dma_burst_length = macb_config->dma_burst_length;
-		init = macb_config->init;
-	}
-
 	/* IP specific init */
 	err = init(pdev);
 	if (err)
-- 
2.1.3
