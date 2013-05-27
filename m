From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 3/5] fec: Disable the PHY regulator on error and removal
Date: Mon, 27 May 2013 10:48:31 -0300
Message-ID: <1369662513-32133-4-git-send-email-fabio.estevam@freescale.com>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:43460
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932379Ab3E0Ns6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:48:58 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of error during probe, disable the PHY regulator.

Do the same in fec_drv_remove().

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index dc7388e..58ac0c7 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1926,6 +1926,8 @@ fec_probe(struct platform_device *pdev)
 				"Failed to enable phy regulator: %d\n", ret);
 			goto failed_regulator;
 		}
+	} else {
+		fep->reg_phy = NULL;
 	}
 
 	fec_reset_phy(pdev);
@@ -1982,6 +1984,8 @@ failed_irq:
 			free_irq(irq, ndev);
 	}
 failed_init:
+	if (fep->reg_phy)
+		regulator_disable(fep->reg_phy);
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
@@ -2005,6 +2009,8 @@ fec_drv_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	del_timer_sync(&fep->time_keep);
+	if (fep->reg_phy)
+		regulator_disable(fep->reg_phy);
 	clk_disable_unprepare(fep->clk_ptp);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
-- 
1.8.1.2
