From: Steven King <sfking@fdwdc.com>
Subject: [PATCH] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 00:00:47 -0700
Message-ID: <201206170000.48076.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28.access.bullet.mail.mud.yahoo.com ([66.94.237.93]:46775
	"HELO nm28.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750913Ab2FQHGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 03:06:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f4d40de39a23f0c39cca55ac63e1175c69c3d2f7
'net fec: do not depend on grouped clocks' broke fec for Coldfire.

Add #ifdef's to restore the working 3.4 clk handling for Coldfire.

Signed-off-by: Steven King <sfking@fdwdc.com>
---
 drivers/net/ethernet/freescale/fec.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ff7f4c5..f7b0372 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -207,8 +207,12 @@ struct fec_enet_private {
 
 	struct net_device *netdev;
 
+#ifdef CONFIG_COLDFIRE
+	struct clk *clk;
+#else
 	struct clk *clk_ipg;
 	struct clk *clk_ahb;
+#endif
 
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	unsigned char *tx_bounce[TX_RING_SIZE];
@@ -1066,7 +1070,11 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * Reference Manual has an error on this, and gets fixed on i.MX6Q
 	 * document.
 	 */
+#ifdef CONFIG_COLDFIRE
+	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
+#else
 	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk_ahb), 5000000);
+#endif
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
 		fep->phy_speed--;
 	fep->phy_speed <<= 1;
@@ -1619,6 +1627,14 @@ fec_probe(struct platform_device *pdev)
 		goto failed_pin;
 	}
 
+#ifdef CONFIG_COLDFIRE
+	fep->clk = clk_get(&pdev->dev, NULL);
+	if (IS_ERR(fep->clk)) {
+		ret = PTR_ERR(fep->clk);
+		goto failed_clk;
+	}
+	clk_prepare_enable(fep->clk);
+#else
 	fep->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
 	if (IS_ERR(fep->clk_ipg)) {
 		ret = PTR_ERR(fep->clk_ipg);
@@ -1633,6 +1649,7 @@ fec_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
+#endif
 
 	ret = fec_enet_init(ndev);
 	if (ret)
@@ -1655,8 +1672,12 @@ failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
 failed_init:
+#ifdef CONFIG_COLDFIRE
+	clk_disable_unprepare(fep->clk);
+#else
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+#endif
 failed_pin:
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1689,8 +1710,12 @@ fec_drv_remove(struct platform_device *pdev)
 		if (irq > 0)
 			free_irq(irq, ndev);
 	}
+#ifdef CONFIG_COLDFIRE
+	clk_disable_unprepare(fep->clk);
+#else
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+#endif
 	iounmap(fep->hwp);
 	free_netdev(ndev);
 
@@ -1714,8 +1739,12 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
+#ifdef CONFIG_COLDFIRE
+	clk_disable_unprepare(fep->clk);
+#else
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+#endif
 
 	return 0;
 }
@@ -1726,8 +1755,12 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+#ifdef CONFIG_COLDFIRE
+	clk_prepare_enable(fep->clk);
+#else
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
+#endif
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
