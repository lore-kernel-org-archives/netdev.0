From: Lucas Stach <l.stach@pengutronix.de>
Subject: [Patch v2 resend 2/2] net: fec: introduce fec_ptp_stop and use in probe fail path
Date: Thu, 23 Jul 2015 16:06:20 +0200
Message-ID: <1437660380-21164-2-git-send-email-l.stach@pengutronix.de>
References: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
Cc: Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47726 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbbGWOG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 10:06:26 -0400
In-Reply-To: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function frees resources and cancels delayed work item that
have been initialized in fec_ptp_init().

Use this to do proper error handling if something goes wrong in
probe function after fec_ptp_init has been called.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
Acked-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  1 +
 drivers/net/ethernet/freescale/fec_main.c |  5 ++---
 drivers/net/ethernet/freescale/fec_ptp.c  | 10 ++++++++++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 1eee73cccdf5..99d33e2d35e6 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -562,6 +562,7 @@ struct fec_enet_private {
 };
 
 void fec_ptp_init(struct platform_device *pdev);
+void fec_ptp_stop(struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
 int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);
 int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a7f1bdf718f8..32e3807c650e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3494,6 +3494,7 @@ failed_register:
 failed_mii_init:
 failed_irq:
 failed_init:
+	fec_ptp_stop(pdev);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 failed_regulator:
@@ -3515,14 +3516,12 @@ fec_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	cancel_delayed_work_sync(&fep->time_keep);
 	cancel_work_sync(&fep->tx_timeout_work);
+	fec_ptp_stop(pdev);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
-	if (fep->ptp_clock)
-		ptp_clock_unregister(fep->ptp_clock);
 	of_node_put(fep->phy_node);
 	free_netdev(ndev);
 
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index a15663ad7f5e..f457a23d0bfb 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -604,6 +604,16 @@ void fec_ptp_init(struct platform_device *pdev)
 	schedule_delayed_work(&fep->time_keep, HZ);
 }
 
+void fec_ptp_stop(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	cancel_delayed_work_sync(&fep->time_keep);
+	if (fep->ptp_clock)
+		ptp_clock_unregister(fep->ptp_clock);
+}
+
 /**
  * fec_ptp_check_pps_event
  * @fep: the fec_enet_private structure handle
-- 
2.1.4
