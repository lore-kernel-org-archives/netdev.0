From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] net: fec: Fix division by zero
Date: Fri, 22 Feb 2013 13:40:45 -0300
Message-ID: <1361551245-11021-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Frank.Li@freescale.com>, <s.hauer@pengutronix.de>,
	<jim_baxter@mentor.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:55897 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757714Ab3BVQkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 11:40:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7f7d6c282 (net: fec: Ensure that initialization is done prior to 
request_irq()) placed fec_ptp_init() into a point that ptp clock was not 
available, which causes a division by zero in fec_ptp_start_cyclecounter():

[   17.895723] Division by zero in kernel.
[   17.899571] Backtrace:
[   17.902094] [<80012564>] (dump_backtrace+0x0/0x10c) from [<8056deec>]
(dump_stack+0x18/0x1c)
[   17.910539]  r6:bfba8500 r5:8075c950 r4:bfba8000 r3:bfbd0000
[   17.916284] [<8056ded4>] (dump_stack+0x0/0x1c) from [<80012688>]
(__div0+0x18/0x20)
[   17.923968] [<80012670>] (__div0+0x0/0x20) from [<802829c4>] (Ldiv0+0x8/0x10)
[   17.931140] [<80398534>] (fec_ptp_start_cyclecounter+0x0/0x110) from
[<80394f64>] (fec_restart+0x6c8/0x754)
[   17.940898] [<8039489c>] (fec_restart+0x0/0x754) from [<803969a0>]
(fec_enet_adjust_link+0xdc/0x108)
[   17.950046] [<803968c4>] (fec_enet_adjust_link+0x0/0x108) from [<80390bc4>]
(phy_state_machine+0x178/0x534)
...

Fix this by rearraging the code so that fec_ptp_init() is called only after
the clocks have been properly acquired.

Tested on both mx53 and mx6 platforms.

Reported-by: Jim Baxter <jim_baxter@mentor.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   68 +++++++++++++++++-----------------
 1 file changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 2dbb36c..fccc3bf 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1782,33 +1782,6 @@ fec_probe(struct platform_device *pdev)
 		fep->phy_interface = ret;
 	}
 
-	fep->bufdesc_ex =
-		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
-	if (fep->bufdesc_ex)
-		fec_ptp_init(ndev, pdev);
-
-	ret = fec_enet_init(ndev);
-	if (ret)
-		goto failed_init;
-
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		irq = platform_get_irq(pdev, i);
-		if (irq < 0) {
-			if (i)
-				break;
-			ret = irq;
-			goto failed_irq;
-		}
-		ret = request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
-		if (ret) {
-			while (--i >= 0) {
-				irq = platform_get_irq(pdev, i);
-				free_irq(irq, ndev);
-			}
-			goto failed_irq;
-		}
-	}
-
 	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
 	if (IS_ERR(pinctrl)) {
 		ret = PTR_ERR(pinctrl);
@@ -1828,6 +1801,8 @@ fec_probe(struct platform_device *pdev)
 	}
 
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
+	fep->bufdesc_ex =
+		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
 	if (IS_ERR(fep->clk_ptp)) {
 		ret = PTR_ERR(fep->clk_ptp);
 		fep->bufdesc_ex = 0;
@@ -1850,6 +1825,31 @@ fec_probe(struct platform_device *pdev)
 
 	fec_reset_phy(pdev);
 
+	if (fep->bufdesc_ex)
+		fec_ptp_init(ndev, pdev);
+
+	ret = fec_enet_init(ndev);
+	if (ret)
+		goto failed_init;
+
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		irq = platform_get_irq(pdev, i);
+		if (irq < 0) {
+			if (i)
+				break;
+			ret = irq;
+			goto failed_irq;
+		}
+		ret = request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
+		if (ret) {
+			while (--i >= 0) {
+				irq = platform_get_irq(pdev, i);
+				free_irq(irq, ndev);
+			}
+			goto failed_irq;
+		}
+	}
+
 	ret = fec_enet_mii_init(pdev);
 	if (ret)
 		goto failed_mii_init;
@@ -1866,6 +1866,13 @@ fec_probe(struct platform_device *pdev)
 failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
+failed_init:
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		irq = platform_get_irq(pdev, i);
+		if (irq > 0)
+			free_irq(irq, ndev);
+	}
+failed_irq:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
@@ -1873,14 +1880,7 @@ failed_regulator:
 		clk_disable_unprepare(fep->clk_ptp);
 failed_pin:
 failed_clk:
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		irq = platform_get_irq(pdev, i);
-		if (irq > 0)
-			free_irq(irq, ndev);
-	}
-failed_irq:
 	iounmap(fep->hwp);
-failed_init:
 failed_ioremap:
 	free_netdev(ndev);
 failed_alloc_etherdev:
-- 
1.7.9.5
