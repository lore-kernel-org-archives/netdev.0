From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] net: fec: fix initial runtime PM refcount
Date: Mon,  3 Aug 2015 17:50:11 +0200
Message-ID: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Cc: Andrew Lunn <andrew@lunn.ch>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42727 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998AbbHCPuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 11:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The clocks are initially active and thus the device is marked active.
This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
call at the end of probe then leaves us with an invalid refcount of -1,
which in turn leads to the device staying in suspended state even though
netdev open had been called.

Fix this by initializing the refcount to be coherent with the initial
device status.

Fixes:
8fff755e9f8 (net: fec: Ensure clocks are enabled while using mdio bus)

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
Please apply this as a fix for 4.2
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 32e3807c650e..271bb5862346 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
 
 	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
 	pm_runtime_use_autosuspend(&pdev->dev);
+	pm_runtime_get_noresume(&pdev->dev);
 	pm_runtime_set_active(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
 
-- 
2.1.4
