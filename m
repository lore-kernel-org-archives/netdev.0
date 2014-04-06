From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Subject: [PATCH] net/at91_ether: avoid NULL pointer dereference
Date: Sun,  6 Apr 2014 20:37:44 +0200
Message-ID: <1396809464-22471-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Cc: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-51317.dedibox.fr ([62.210.215.82]:35620 "EHLO
	sd-51317.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbaDFSxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 14:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The at91_ether driver calls macb_mii_init passing a 'struct macb'
structure whose tx_clk member is initialized to 0. However,
macb_handle_link_change() expects tx_clk to be the result of
a call to clk_get, and so IS_ERR(tx_clk) to be true if the clock
is invalid. This causes an oops when booting Linux 3.14 on the
csb637 board. The following changes avoids this.

Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
---
 drivers/net/ethernet/cadence/at91_ether.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index ce75de9..4a79eda 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -342,6 +342,9 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	}
 	clk_enable(lp->pclk);
 
+	lp->hclk = ERR_PTR(-ENOENT);
+	lp->tx_clk = ERR_PTR(-ENOENT);
+
 	/* Install the interrupt handler */
 	dev->irq = platform_get_irq(pdev, 0);
 	res = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt, 0, dev->name, dev);
-- 
1.7.10.4
