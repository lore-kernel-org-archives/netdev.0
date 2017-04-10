From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 10/12] ftgmac100: Don't clear tx desc fields unnecessarily
Date: Mon, 10 Apr 2017 11:15:24 +1000
Message-ID: <20170410011526.4509-11-benh@kernel.crashing.org>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33510 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdDJBoT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:44:19 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those are non-cachable stores, let's avoid those we don't need. Remove
the helper, it's not particularly helpful and since it uses "priv"
I can't move it to the header file.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index b33de5c..8a44c22 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -466,16 +466,6 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	return true;
 }
 
-static void ftgmac100_txdes_reset(const struct ftgmac100 *priv,
-				  struct ftgmac100_txdes *txdes)
-{
-	/* clear all except end of ring bit */
-	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
-	txdes->txdes1 = 0;
-	txdes->txdes2 = 0;
-	txdes->txdes3 = 0;
-}
-
 static bool ftgmac100_txdes_owned_by_dma(struct ftgmac100_txdes *txdes)
 {
 	return txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
@@ -575,7 +565,12 @@ static void ftgmac100_free_tx_packet(struct ftgmac100 *priv,
 	dev_kfree_skb(skb);
 	priv->tx_skbs[pointer] = NULL;
 
-	ftgmac100_txdes_reset(priv, txdes);
+	/* Clear txdes0 except end of ring bit, clear txdes1 as we
+	 * only "OR" into it, leave 2 and 3 alone as 2 is unused
+	 * and 3 will be overwritten entirely
+	 */
+	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
+	txdes->txdes1 = 0;
 }
 
 static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
-- 
2.9.3
