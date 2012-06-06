From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] Net: mv643xx_eth: Fix compile error for architectures without clk.
Date: Wed,  6 Jun 2012 18:40:43 +0200
Message-ID: <1339000843-26078-1-git-send-email-andrew@lunn.ch>
Cc: buytenh@wantstofly.org, olof@lixom.net, netdev@vger.kernel.org,
	ben@decadent.org.uk, Andrew Lunn <andrew@lunn.ch>
To: jwboyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:33674 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756742Ab2FFQk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 12:40:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) broke
the building of the driver on architectures which don't have clk
support. In particular PPC32 Pegasos which uses this driver.

Add #ifdef around the clk API usage.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 04d901d..f0f06b2 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -436,7 +436,9 @@ struct mv643xx_eth_private {
 	/*
 	 * Hardware-specific parameters.
 	 */
+#if defined(CONFIG_HAVE_CLK)
 	struct clk *clk;
+#endif
 	unsigned int t_clk;
 };
 
@@ -2895,17 +2897,17 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->dev = dev;
 
 	/*
-	 * Get the clk rate, if there is one, otherwise use the default.
+	 * Start with a default rate, and if there is a clock, allow
+	 * it to override the default.
 	 */
+	mp->t_clk = 133000000;
+#if defined(CONFIG_HAVE_CLK)
 	mp->clk = clk_get(&pdev->dev, (pdev->id ? "1" : "0"));
 	if (!IS_ERR(mp->clk)) {
 		clk_prepare_enable(mp->clk);
 		mp->t_clk = clk_get_rate(mp->clk);
-	} else {
-		mp->t_clk = 133000000;
-		printk(KERN_WARNING "Unable to get clock");
 	}
-
+#endif
 	set_params(mp, pd);
 	netif_set_real_num_tx_queues(dev, mp->txq_count);
 	netif_set_real_num_rx_queues(dev, mp->rxq_count);
@@ -2995,10 +2997,13 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 		phy_detach(mp->phy);
 	cancel_work_sync(&mp->tx_timeout_task);
 
+#if defined(CONFIG_HAVE_CLK)
 	if (!IS_ERR(mp->clk)) {
 		clk_disable_unprepare(mp->clk);
 		clk_put(mp->clk);
 	}
+#endif
+
 	free_netdev(mp->dev);
 
 	platform_set_drvdata(pdev, NULL);
-- 
1.7.10
