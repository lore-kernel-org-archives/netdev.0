From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: fec: drop check for clk==NULL before calling clk_*
Date: Thu, 20 Oct 2016 10:28:27 +0200
Message-ID: <20161020082827.598-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: kernel@pengutronix.de, netdev@vger.kernel.org
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45693 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753058AbcJTI2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 04:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clk_prepare, clk_enable and their counterparts (at least the common clk
ones, but also most others) do check for the clk being NULL anyhow (and
return 0 then), so there is no gain when the caller checks, too.

Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 48a033e64423..1722ccac18c2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1841,11 +1841,11 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		ret = clk_prepare_enable(fep->clk_ahb);
 		if (ret)
 			return ret;
-		if (fep->clk_enet_out) {
-			ret = clk_prepare_enable(fep->clk_enet_out);
-			if (ret)
-				goto failed_clk_enet_out;
-		}
+
+		ret = clk_prepare_enable(fep->clk_enet_out);
+		if (ret)
+			goto failed_clk_enet_out;
+
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			ret = clk_prepare_enable(fep->clk_ptp);
@@ -1857,23 +1857,20 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 			}
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref) {
-			ret = clk_prepare_enable(fep->clk_ref);
-			if (ret)
-				goto failed_clk_ref;
-		}
+
+		ret = clk_prepare_enable(fep->clk_ref);
+		if (ret)
+			goto failed_clk_ref;
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
-		if (fep->clk_enet_out)
-			clk_disable_unprepare(fep->clk_enet_out);
+		clk_disable_unprepare(fep->clk_enet_out);
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			clk_disable_unprepare(fep->clk_ptp);
 			fep->ptp_clk_on = false;
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref)
-			clk_disable_unprepare(fep->clk_ref);
+		clk_disable_unprepare(fep->clk_ref);
 	}
 
 	return 0;
-- 
2.9.3
