From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 1/4] net: fec: handle optional clk_ptp more gracefully
Date: Mon, 18 Mar 2013 16:26:22 +0800
Message-ID: <1363595185-12302-2-git-send-email-shawn.guo@linaro.org>
References: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:44238
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab3CRI0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:26:33 -0400
In-Reply-To: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the optional clk_ptp is absent, we can just set it to NULL, and
clk API will just handle it gracefully.  It saves us from checking
clk_ptp whenever calling into clk API.

Also since clk_ptp is optional, the "ret" variable shouldn't be set
in case that the clock is absent.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index fccc3bf..d2a9851 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1804,14 +1804,13 @@ fec_probe(struct platform_device *pdev)
 	fep->bufdesc_ex =
 		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
 	if (IS_ERR(fep->clk_ptp)) {
-		ret = PTR_ERR(fep->clk_ptp);
+		fep->clk_ptp = NULL;
 		fep->bufdesc_ex = 0;
 	}
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
-	if (!IS_ERR(fep->clk_ptp))
-		clk_prepare_enable(fep->clk_ptp);
+	clk_prepare_enable(fep->clk_ptp);
 
 	reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(reg_phy)) {
@@ -1876,8 +1875,7 @@ failed_irq:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
-	if (!IS_ERR(fep->clk_ptp))
-		clk_disable_unprepare(fep->clk_ptp);
+	clk_disable_unprepare(fep->clk_ptp);
 failed_pin:
 failed_clk:
 	iounmap(fep->hwp);
-- 
1.7.9.5
