From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 05/10] ftgmac100: Simplify rx packets error handling
Date: Thu,  6 Apr 2017 11:02:47 +1000
Message-ID: <20170406010252.29208-6-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37936 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756439AbdDFBDa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:30 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fast path has a single unlikely() test for any error bit,
calling into a helper that sets the appropriate statistics.

The various netdev_info aren't particularly interesting. If
we want to differentiate the various length errors later we
can introduce driver specific stats using ethtool.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 61 +++++++++++++-------------------
 1 file changed, 25 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 60c2860..0bfcfdd 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -298,6 +298,18 @@ static void ftgmac100_rxdes_set_dma_own(const struct ftgmac100 *priv,
 	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
 }
 
+#define RXDES0_ANY_ERROR		( \
+	FTGMAC100_RXDES0_RX_ERR		| \
+	FTGMAC100_RXDES0_CRC_ERR	| \
+	FTGMAC100_RXDES0_FTL		| \
+	FTGMAC100_RXDES0_RUNT		| \
+	FTGMAC100_RXDES0_RX_ODD_NB)
+
+static inline bool ftgmac100_rxdes_any_error(struct ftgmac100_rxdes *rxdes)
+{
+	return rxdes->rxdes0 & cpu_to_le32(RXDES0_ANY_ERROR);
+}
+
 static bool ftgmac100_rxdes_rx_error(struct ftgmac100_rxdes *rxdes)
 {
 	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ERR);
@@ -444,49 +456,22 @@ ftgmac100_rx_locate_first_segment(struct ftgmac100 *priv)
 	return NULL;
 }
 
-static bool ftgmac100_rx_packet_error(struct ftgmac100 *priv,
+
+static void ftgmac100_rx_packet_error(struct ftgmac100 *priv,
 				      struct ftgmac100_rxdes *rxdes)
 {
 	struct net_device *netdev = priv->netdev;
-	bool error = false;
-
-	if (unlikely(ftgmac100_rxdes_rx_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx err\n");
 
+	if (ftgmac100_rxdes_rx_error(rxdes))
 		netdev->stats.rx_errors++;
-		error = true;
-	}
-
-	if (unlikely(ftgmac100_rxdes_crc_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx crc err\n");
 
+	if (ftgmac100_rxdes_crc_error(rxdes))
 		netdev->stats.rx_crc_errors++;
-		error = true;
-	}
-
-	if (unlikely(ftgmac100_rxdes_frame_too_long(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx frame too long\n");
-
-		netdev->stats.rx_length_errors++;
-		error = true;
-	} else if (unlikely(ftgmac100_rxdes_runt(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx runt\n");
-
-		netdev->stats.rx_length_errors++;
-		error = true;
-	} else if (unlikely(ftgmac100_rxdes_odd_nibble(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx odd nibble\n");
 
+	if (ftgmac100_rxdes_frame_too_long(rxdes) ||
+	    ftgmac100_rxdes_runt(rxdes) ||
+	    ftgmac100_rxdes_odd_nibble(rxdes))
 		netdev->stats.rx_length_errors++;
-		error = true;
-	}
-
-	return error;
 }
 
 static void ftgmac100_rx_drop_packet(struct ftgmac100 *priv)
@@ -526,8 +511,12 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	/* We don't support segmented rx frames, so drop these
 	 * along with packets with errors.
 	 */
-	if (unlikely(!ftgmac100_rxdes_last_segment(rxdes) ||
-		     ftgmac100_rx_packet_error(priv, rxdes))) {
+	if (unlikely(!ftgmac100_rxdes_last_segment(rxdes))) {
+		ftgmac100_rx_drop_packet(priv);
+		return true;
+	}
+	if (unlikely(ftgmac100_rxdes_any_error(rxdes))) {
+		ftgmac100_rx_packet_error(priv, rxdes);
 		ftgmac100_rx_drop_packet(priv);
 		return true;
 	}
-- 
2.9.3
