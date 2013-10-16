From: Jimmy Perchet <jimmy.perchet@parrot.com>
Subject: [PATCH RFC 1/5] net:stmmac: set threshold/store and forward mode according to mtu size.
Date: Wed, 16 Oct 2013 17:24:08 +0200
Message-ID: <1381937052-8999-2-git-send-email-jimmy.perchet@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:60739 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281Ab3JPPjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 11:39:23 -0400
In-Reply-To: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Threshold mode dma is needed on rx path if jumbo frames are expected.


Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 48 ++++++++++++++++-------
 1 file changed, 33 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8d4ccd3..170f043 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1222,22 +1222,40 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  *  Description: it sets the DMA operation mode: tx/rx DMA thresholds
  *  or Store-And-Forward capability.
  */
-static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
-{
-	if (priv->plat->force_thresh_dma_mode)
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
-	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
-		/*
-		 * In case of GMAC, SF mode can be enabled
-		 * to perform the TX COE in HW. This depends on:
-		 * 1) TX COE if actually supported
-		 * 2) There is no bugged Jumbo frame support
-		 *    that needs to not insert csum in the TDES.
-		 */
-		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE);
+static void stmmac_dma_operation_mode(int mtu, struct stmmac_priv *priv)
+{
+	int rx_tc, tx_tc;
+
+	/*
+	 * In case of GMAC, SF mode can be enabled
+	 * to perform the TX COE in HW. This depends on:
+	 * 1) TX COE if actually supported
+	 * 2) There is no bugged Jumbo frame support
+	 *    that needs to not insert csum in the TDES.
+	 */
+	if (priv->plat->tx_coe &&
+	    !(priv->plat->bugged_jumbo && (mtu > ETH_DATA_LEN))) {
 		tc = SF_DMA_MODE;
+		tx_tc = SF_DMA_MODE;
 	} else
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
+		tx_tc = tc;
+
+	if (mtu > ETH_DATA_LEN && priv->hw_cap_support
+	    && !priv->dma_cap.rxfifo_over_2048)
+		rx_tc = tc;
+	else
+		rx_tc = SF_DMA_MODE;
+
+	if (priv->plat->force_sf_dma_mode) {
+		tc = SF_DMA_MODE;
+		tx_tc = SF_DMA_MODE;
+		rx_tc = SF_DMA_MODE;
+	} else if (priv->plat->force_thresh_dma_mode) {
+		tx_tc = tc;
+		rx_tc = tc;
+	}
+
+	priv->hw->dma->dma_mode(priv->ioaddr, tx_tc, rx_tc);
 }
 
 /**
@@ -1687,7 +1705,7 @@ static int stmmac_open(struct net_device *dev)
 	stmmac_set_mac(priv->ioaddr, true);
 
 	/* Set the HW DMA mode and the COE */
-	stmmac_dma_operation_mode(priv);
+	stmmac_dma_operation_mode(dev->mtu, priv);
 
 	/* Extra statistics */
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
-- 
1.8.1.2
