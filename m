From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: fix ptp init for gmac4
Date: Wed, 12 Oct 2016 15:42:03 +0200
Message-ID: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:42137 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754827AbcJLNsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:48:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gmac 4.x version has not extended descriptors
(that are available on 3.x instead of).
While initializing the PTP module, the advanced PTP was
enabled in case of extended descriptors. This cannot be
applied for 4.x version where only the hardware capability
register has to show if the feature is present.
Patch also adds some extra netdev_(debug/inof) to better
dump the configuration.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4c8c60a..e838850 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -650,20 +650,27 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 	if (IS_ERR(priv->clk_ptp_ref)) {
 		priv->clk_ptp_rate = clk_get_rate(priv->stmmac_clk);
 		priv->clk_ptp_ref = NULL;
+		netdev_dbg(priv->dev, "PTP uses main clock\n");
 	} else {
 		clk_prepare_enable(priv->clk_ptp_ref);
 		priv->clk_ptp_rate = clk_get_rate(priv->clk_ptp_ref);
+		netdev_dbg(priv->dev, "PTP rate %d\n", priv->clk_ptp_rate);
 	}
 
 	priv->adv_ts = 0;
-	if (priv->dma_cap.atime_stamp && priv->extend_desc)
+	/* Check if adv_ts can be enabled for dwmac 4.x core */
+	if (priv->plat->has_gmac4 && priv->dma_cap.atime_stamp)
+		priv->adv_ts = 1;
+	/* Dwmac 3.x core with extend_desc can support adv_ts */
+	else if (priv->extend_desc && priv->dma_cap.atime_stamp)
 		priv->adv_ts = 1;
 
-	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
-		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+	if (priv->dma_cap.time_stamp)
+		netdev_info(priv->dev, "IEEE 1588-2002 Timestamp supported\n");
 
-	if (netif_msg_hw(priv) && priv->adv_ts)
-		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+	if (priv->adv_ts)
+		netdev_info(priv->dev,
+			    "IEEE 1588-2008 Advanced Timestamp supported\n");
 
 	priv->hw->ptp = &stmmac_ptp;
 	priv->hwts_tx_en = 0;
-- 
2.7.4
