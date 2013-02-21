From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] net: fec: Ensure that initialization is done prior to request_irq()
Date: Thu, 21 Feb 2013 16:21:50 -0300
Message-ID: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Frank.Li@freescale.com>, <s.hauer@pengutronix.de>,
	<jim_baxter@mentor.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.181] ([216.32.181.181]:23201 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab3BUTXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 14:23:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently request_irq() is called prior to fec_enet_init() and fec_ptp_init(), 
which causes the following crash on a mx53qsb:

Unable to handle kernel NULL pointer dereference at virtual address 00000002
pgd = 80004000
[00000002] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 0    Not tainted  (3.8.0-rc7-next-20130215+ #346)
PC is at fec_enet_interrupt+0xd0/0x348
LR is at fec_enet_interrupt+0xb8/0x348
pc : [<80372b7c>]    lr : [<80372b64>]    psr: 60000193
sp : df855c20  ip : df855c20  fp : df855c74
r10: 00000516  r9 : 1c000000  r8 : 00000000
r7 : 00000000  r6 : 00000000  r5 : 00000000  r4 : df9b7800
r3 : df9b7df4  r2 : 00000000  r1 : 00000000  r0 : df9b7d34

Ensure that such initialization functions are called prior to requesting the 
interrupts, so that all necessary the data structures are in place when the 
irqs occur. 

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 29d82cf..2dbb36c 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1782,6 +1782,15 @@ fec_probe(struct platform_device *pdev)
 		fep->phy_interface = ret;
 	}
 
+	fep->bufdesc_ex =
+		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
+	if (fep->bufdesc_ex)
+		fec_ptp_init(ndev, pdev);
+
+	ret = fec_enet_init(ndev);
+	if (ret)
+		goto failed_init;
+
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
 		irq = platform_get_irq(pdev, i);
 		if (irq < 0) {
@@ -1819,8 +1828,6 @@ fec_probe(struct platform_device *pdev)
 	}
 
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
-	fep->bufdesc_ex =
-		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
 	if (IS_ERR(fep->clk_ptp)) {
 		ret = PTR_ERR(fep->clk_ptp);
 		fep->bufdesc_ex = 0;
@@ -1843,13 +1850,6 @@ fec_probe(struct platform_device *pdev)
 
 	fec_reset_phy(pdev);
 
-	if (fep->bufdesc_ex)
-		fec_ptp_init(ndev, pdev);
-
-	ret = fec_enet_init(ndev);
-	if (ret)
-		goto failed_init;
-
 	ret = fec_enet_mii_init(pdev);
 	if (ret)
 		goto failed_mii_init;
@@ -1866,7 +1866,6 @@ fec_probe(struct platform_device *pdev)
 failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
-failed_init:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
@@ -1881,6 +1880,7 @@ failed_clk:
 	}
 failed_irq:
 	iounmap(fep->hwp);
+failed_init:
 failed_ioremap:
 	free_netdev(ndev);
 failed_alloc_etherdev:
@@ -1899,17 +1899,17 @@ fec_drv_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		int irq = platform_get_irq(pdev, i);
-		if (irq > 0)
-			free_irq(irq, ndev);
-	}
 	del_timer_sync(&fep->time_keep);
 	clk_disable_unprepare(fep->clk_ptp);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		int irq = platform_get_irq(pdev, i);
+		if (irq > 0)
+			free_irq(irq, ndev);
+	}
 	iounmap(fep->hwp);
 	free_netdev(ndev);
 
-- 
1.7.9.5
