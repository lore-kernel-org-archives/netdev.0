From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 2/3] fec: Do not set fep->clk_enet_out to NULL on error
Date: Mon,  1 Sep 2014 22:12:54 -0300
Message-ID: <1409620375-20284-3-git-send-email-festevam@gmail.com>
References: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Cc: linux@arm.linux.org.uk, B38611@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:47190 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbaIBBN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:13:26 -0400
Received: by mail-vc0-f176.google.com with SMTP id ik5so6268450vcb.35
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:13:25 -0700 (PDT)
In-Reply-To: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is no need to set fep->clk_enet_out to NULL when devm_clk_get() returns an
error. We can simply use IS_ERR() instead, which makes the code simpler.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 76e4f56..e87cc66 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1605,7 +1605,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		ret = clk_prepare_enable(fep->clk_ipg);
 		if (ret)
 			goto failed_clk_ipg;
-		if (fep->clk_enet_out) {
+		if (!IS_ERR(fep->clk_enet_out)) {
 			ret = clk_prepare_enable(fep->clk_enet_out);
 			if (ret)
 				goto failed_clk_enet_out;
@@ -1624,7 +1624,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
 		clk_disable_unprepare(fep->clk_ipg);
-		if (fep->clk_enet_out)
+		if (!IS_ERR(fep->clk_enet_out))
 			clk_disable_unprepare(fep->clk_enet_out);
 		if (!IS_ERR(fep->clk_ptp)) {
 			mutex_lock(&fep->ptp_clk_mutex);
@@ -1636,7 +1636,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 
 	return 0;
 failed_clk_ptp:
-	if (fep->clk_enet_out)
+	if (!IS_ERR(fep->clk_enet_out))
 		clk_disable_unprepare(fep->clk_enet_out);
 failed_clk_enet_out:
 		clk_disable_unprepare(fep->clk_ipg);
@@ -2632,8 +2632,6 @@ fec_probe(struct platform_device *pdev)
 
 	/* enet_out is optional, depends on board */
 	fep->clk_enet_out = devm_clk_get(&pdev->dev, "enet_out");
-	if (IS_ERR(fep->clk_enet_out))
-		fep->clk_enet_out = NULL;
 
 	fep->ptp_clk_on = false;
 	mutex_init(&fep->ptp_clk_mutex);
-- 
1.9.1
