From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next] fec: Fix fec_enet_alloc_buffers() error path
Date: Sat,  4 Oct 2014 13:40:01 -0300
Message-ID: <1412440801-15381-1-git-send-email-festevam@gmail.com>
Cc: rmk+kernel@arm.linux.org.uk, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:44602 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbaJDQkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 12:40:35 -0400
Received: by mail-qa0-f44.google.com with SMTP id x12so2036957qac.17
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2014 09:40:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

When fec_enet_alloc_buffers() fails we should better undo the previous actions,
which consists of: disabling the FEC clocks and putting the FEC pins into
inactive state.

The error path for fec_enet_mii_probe() is kept unchanged.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1f07db8..620feaf 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2746,16 +2746,12 @@ fec_enet_open(struct net_device *ndev)
 
 	ret = fec_enet_alloc_buffers(ndev);
 	if (ret)
-		return ret;
+		goto err_enet_alloc;
 
 	/* Probe and connect to PHY when open the interface */
 	ret = fec_enet_mii_probe(ndev);
-	if (ret) {
-		fec_enet_free_buffers(ndev);
-		fec_enet_clk_enable(ndev, false);
-		pinctrl_pm_select_sleep_state(&fep->pdev->dev);
-		return ret;
-	}
+	if (ret)
+		goto err_enet_mii_probe;
 
 	fec_restart(ndev);
 	napi_enable(&fep->napi);
@@ -2763,6 +2759,13 @@ fec_enet_open(struct net_device *ndev)
 	netif_tx_start_all_queues(ndev);
 
 	return 0;
+
+err_enet_mii_probe:
+	fec_enet_free_buffers(ndev);
+err_enet_alloc:
+	fec_enet_clk_enable(ndev, false);
+	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
+	return ret;
 }
 
 static int
-- 
1.9.1
