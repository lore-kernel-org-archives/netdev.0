From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 3/3] fec: Do not set fep->reg_phy to NULL on error
Date: Mon,  1 Sep 2014 22:12:55 -0300
Message-ID: <1409620375-20284-4-git-send-email-festevam@gmail.com>
References: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Cc: linux@arm.linux.org.uk, B38611@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:57718 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbaIBBN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:13:29 -0400
Received: by mail-vc0-f171.google.com with SMTP id id10so6254149vcb.16
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:13:28 -0700 (PDT)
In-Reply-To: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is no need to set fep->reg_phy to NULL when devm_regulator_get()
returns an error. We can simply use IS_ERR() instead, which makes the code
simpler.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e87cc66..39c28d1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2653,8 +2653,6 @@ fec_probe(struct platform_device *pdev)
 				"Failed to enable phy regulator: %d\n", ret);
 			goto failed_regulator;
 		}
-	} else {
-		fep->reg_phy = NULL;
 	}
 
 	fec_reset_phy(pdev);
@@ -2704,7 +2702,7 @@ failed_register:
 failed_mii_init:
 failed_irq:
 failed_init:
-	if (fep->reg_phy)
+	if (!IS_ERR(fep->reg_phy))
 		regulator_disable(fep->reg_phy);
 failed_regulator:
 	fec_enet_clk_enable(ndev, false);
@@ -2727,7 +2725,7 @@ fec_drv_remove(struct platform_device *pdev)
 	cancel_work_sync(&fep->tx_timeout_work);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
-	if (fep->reg_phy)
+	if (!IS_ERR(fep->reg_phy))
 		regulator_disable(fep->reg_phy);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
@@ -2757,7 +2755,7 @@ static int __maybe_unused fec_suspend(struct device *dev)
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 
-	if (fep->reg_phy)
+	if (!IS_ERR(fep->reg_phy))
 		regulator_disable(fep->reg_phy);
 
 	return 0;
@@ -2769,7 +2767,7 @@ static int __maybe_unused fec_resume(struct device *dev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
-	if (fep->reg_phy) {
+	if (!IS_ERR(fep->reg_phy)) {
 		ret = regulator_enable(fep->reg_phy);
 		if (ret)
 			return ret;
@@ -2794,7 +2792,7 @@ static int __maybe_unused fec_resume(struct device *dev)
 	return 0;
 
 failed_clk:
-	if (fep->reg_phy)
+	if (!IS_ERR(fep->reg_phy))
 		regulator_disable(fep->reg_phy);
 	return ret;
 }
-- 
1.9.1
