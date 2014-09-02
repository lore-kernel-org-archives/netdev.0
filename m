From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 1/3] fec: Do not set fep->clk_ptp to NULL on error
Date: Mon,  1 Sep 2014 22:12:53 -0300
Message-ID: <1409620375-20284-2-git-send-email-festevam@gmail.com>
References: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Cc: linux@arm.linux.org.uk, B38611@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:42331 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbaIBBNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:13:23 -0400
Received: by mail-vc0-f179.google.com with SMTP id hy4so6130790vcb.24
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:13:22 -0700 (PDT)
In-Reply-To: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is no need to set fep->clk_ptp to NULL when devm_clk_get() returns an
error. We can simply use IS_ERR() instead, which makes the code simpler.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 89355a7..76e4f56 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1610,7 +1610,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 			if (ret)
 				goto failed_clk_enet_out;
 		}
-		if (fep->clk_ptp) {
+		if (!IS_ERR(fep->clk_ptp)) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			ret = clk_prepare_enable(fep->clk_ptp);
 			if (ret) {
@@ -1626,7 +1626,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		clk_disable_unprepare(fep->clk_ipg);
 		if (fep->clk_enet_out)
 			clk_disable_unprepare(fep->clk_enet_out);
-		if (fep->clk_ptp) {
+		if (!IS_ERR(fep->clk_ptp)) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			clk_disable_unprepare(fep->clk_ptp);
 			fep->ptp_clk_on = false;
@@ -2640,10 +2640,8 @@ fec_probe(struct platform_device *pdev)
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
 	fep->bufdesc_ex =
 		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
-	if (IS_ERR(fep->clk_ptp)) {
-		fep->clk_ptp = NULL;
+	if (IS_ERR(fep->clk_ptp))
 		fep->bufdesc_ex = 0;
-	}
 
 	ret = fec_enet_clk_enable(ndev, true);
 	if (ret)
-- 
1.9.1
