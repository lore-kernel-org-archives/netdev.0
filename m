From: Steven King <sfking@fdwdc.com>
Subject: [PATCH v3] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 16:39:43 -0700
Message-ID: <201206171639.43651.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm27-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.227]:27791
	"HELO nm27-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753624Ab2FQXjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:39:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f4d40de39a23f0c39cca55ac63e1175c69c3d2f7
'net fec: do not depend on grouped clocks' broke fec for Coldfire.

Hide the details of the fec clk management in a trio of new functions: 
fec_clk_get, fec_clk_prepare and fec_clk_disable_unprepare.  these then can 
be modified as needed to manage the clks for the different arches that use
the fec controller.

Signed-off-by: Steven King <sfking@fdwdc.com>
---
 drivers/net/ethernet/freescale/fec.c |   84 ++++++++++++++++++++++++++--------
 1 file changed, 65 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ff7f4c5..1072da6 100644
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
@@ -248,6 +252,56 @@ struct fec_enet_private {
 	int	irq[FEC_IRQ_NUM];
 };
 
+static int fec_clk_get(struct platform_device *pdev,
+		       struct fec_enet_private *fep)
+{
+	int ret;
+
+#ifdef CONFIG_COLDFIRE
+	fep->clk = clk_get(&pdev->dev, NULL);
+	if (IS_ERR(fep->clk)) {
+		ret = PTR_ERR(fep->clk);
+		goto failed_clk;
+	}
+#else
+	fep->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
+	if (IS_ERR(fep->clk_ipg)) {
+		ret = PTR_ERR(fep->clk_ipg);
+		goto failed_clk;
+	}
+
+	fep->clk_ahb = devm_clk_get(&pdev->dev, "ahb");
+	if (IS_ERR(fep->clk_ahb)) {
+		ret = PTR_ERR(fep->clk_ahb);
+		goto failed_clk;
+	}
+#endif
+	return 0;
+
+failed_clk:
+	return ret;
+}
+
+static void fec_clk_prepare(struct fec_enet_private *fep)
+{
+#ifdef CONFIG_COLDFIRE
+	clk_prepare_enable(fep->clk);
+#else
+	clk_prepare_enable(fep->clk_ahb);
+	clk_prepare_enable(fep->clk_ipg);
+#endif
+}
+
+static void fec_clk_disable_unprepare(struct fec_enet_private *fep)
+{
+#ifdef CONFIG_COLDFIRE
+	clk_disable_unprepare(fep->clk);
+#else
+	clk_disable_unprepare(fep->clk_ahb);
+	clk_disable_unprepare(fep->clk_ipg);
+#endif
+}
+
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
 #define FEC_MMFR_OP_READ	(2 << 28)
@@ -1066,7 +1120,11 @@ static int fec_enet_mii_init(struct platform_device *pdev)
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
@@ -1619,20 +1677,11 @@ fec_probe(struct platform_device *pdev)
 		goto failed_pin;
 	}
 
-	fep->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
-	if (IS_ERR(fep->clk_ipg)) {
-		ret = PTR_ERR(fep->clk_ipg);
-		goto failed_clk;
-	}
 
-	fep->clk_ahb = devm_clk_get(&pdev->dev, "ahb");
-	if (IS_ERR(fep->clk_ahb)) {
-		ret = PTR_ERR(fep->clk_ahb);
+	if (fec_clk_get(pdev, fep))
 		goto failed_clk;
-	}
 
-	clk_prepare_enable(fep->clk_ahb);
-	clk_prepare_enable(fep->clk_ipg);
+	fec_clk_prepare(fep);
 
 	ret = fec_enet_init(ndev);
 	if (ret)
@@ -1655,8 +1704,7 @@ failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
 failed_init:
-	clk_disable_unprepare(fep->clk_ahb);
-	clk_disable_unprepare(fep->clk_ipg);
+	fec_clk_disable_unprepare(fep);
 failed_pin:
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1689,8 +1737,7 @@ fec_drv_remove(struct platform_device *pdev)
 		if (irq > 0)
 			free_irq(irq, ndev);
 	}
-	clk_disable_unprepare(fep->clk_ahb);
-	clk_disable_unprepare(fep->clk_ipg);
+	fec_clk_disable_unprepare(fep);
 	iounmap(fep->hwp);
 	free_netdev(ndev);
 
@@ -1714,8 +1761,7 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
-	clk_disable_unprepare(fep->clk_ahb);
-	clk_disable_unprepare(fep->clk_ipg);
+	fec_clk_disable_unprepare(fep);
 
 	return 0;
 }
@@ -1726,8 +1772,8 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	clk_prepare_enable(fep->clk_ahb);
-	clk_prepare_enable(fep->clk_ipg);
+	fec_clk_prepare(fep);
+
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
