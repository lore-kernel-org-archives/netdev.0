From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 1/2] Fix hang when loading the mvneta driver
Date: Fri, 21 Jun 2013 00:06:45 +0200
Message-ID: <20130620221008.449950285@rtp-net.org>
References: <20130620220644.715387300@rtp-net.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:50537 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3FVUZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 16:25:31 -0400
Content-Disposition: inline; filename=mvneta-module-hang.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the mvneta driver is compiled, it'll be loaded with clocks disabled.
This implies that the clocks should be enabled again before any register
access or it'll hang.

To fix it:
- enable clock earlier
- move timer callback after setting timer.data

Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>

Index: linux-next/drivers/net/ethernet/marvell/mvneta.c
===================================================================
--- linux-next.orig/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.485391949 +0200
+++ linux-next/drivers/net/ethernet/marvell/mvneta.c	2013-06-20 23:39:37.481391949 +0200
@@ -2728,20 +2733,10 @@ static int mvneta_probe(struct platform_
 
 	pp = netdev_priv(dev);
 
-	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
-	init_timer(&pp->tx_done_timer);
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
-
 	pp->weight = MVNETA_RX_POLL_WEIGHT;
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
 
-	pp->base = of_iomap(dn, 0);
-	if (pp->base == NULL) {
-		err = -ENOMEM;
-		goto err_free_irq;
-	}
-
 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
 		err = PTR_ERR(pp->clk);
@@ -2765,7 +2760,16 @@ static int mvneta_probe(struct platform_
 		}
 	}
 
+	pp->base = of_iomap(dn, 0);
+	if (pp->base == NULL) {
+		err = -ENOMEM;
+		goto err_free_irq;
+	}
+
 	pp->tx_done_timer.data = (unsigned long)dev;
+	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
+	init_timer(&pp->tx_done_timer);
+	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
