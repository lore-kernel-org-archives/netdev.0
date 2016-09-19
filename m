From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: flexcan: fix resume function
Date: Mon, 19 Sep 2016 16:19:49 +0200
Message-ID: <20160919141949.5826-2-mkl@pengutronix.de>
References: <20160919141949.5826-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Fabio Estevam <fabio.estevam@nxp.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59814 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751579AbcISOTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:19:54 -0400
In-Reply-To: <20160919141949.5826-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

On a imx6ul-pico board the following error is seen during system suspend:

dpm_run_callback(): platform_pm_resume+0x0/0x54 returns -110
PM: Device 2090000.flexcan failed to resume: error -110

The reason for this suspend error is because when the CAN interface is not
active the clocks are disabled and then flexcan_chip_enable() will
always fail due to a timeout error.

In order to fix this issue, only call flexcan_chip_enable/disable()
when the CAN interface is active.

Based on a patch from Dong Aisheng in the NXP kernel.

Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 41c0fc9f3b14..16f7cadda5c3 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1268,11 +1268,10 @@ static int __maybe_unused flexcan_suspend(struct device *device)
 	struct flexcan_priv *priv = netdev_priv(dev);
 	int err;
 
-	err = flexcan_chip_disable(priv);
-	if (err)
-		return err;
-
 	if (netif_running(dev)) {
+		err = flexcan_chip_disable(priv);
+		if (err)
+			return err;
 		netif_stop_queue(dev);
 		netif_device_detach(dev);
 	}
@@ -1285,13 +1284,17 @@ static int __maybe_unused flexcan_resume(struct device *device)
 {
 	struct net_device *dev = dev_get_drvdata(device);
 	struct flexcan_priv *priv = netdev_priv(dev);
+	int err;
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 	if (netif_running(dev)) {
 		netif_device_attach(dev);
 		netif_start_queue(dev);
+		err = flexcan_chip_enable(priv);
+		if (err)
+			return err;
 	}
-	return flexcan_chip_enable(priv);
+	return 0;
 }
 
 static SIMPLE_DEV_PM_OPS(flexcan_pm_ops, flexcan_suspend, flexcan_resume);
-- 
2.9.3
