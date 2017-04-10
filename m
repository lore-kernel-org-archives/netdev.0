From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 05/12] ftgmac100: Pad small frames properly
Date: Mon, 10 Apr 2017 11:15:19 +1000
Message-ID: <20170410011526.4509-6-benh@kernel.crashing.org>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56936 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752055AbdDJBP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:15:58 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than just transmitting garbage past the end of the small
packet.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v2. Use eth_skb_pad (wrapper around skb_put_padto)
---
 drivers/net/ethernet/faraday/ftgmac100.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 84ae800..739916d 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -630,11 +630,17 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
 static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 				     struct net_device *netdev)
 {
-	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct ftgmac100_txdes *txdes;
 	dma_addr_t map;
 
+	/* The HW doesn't pad small frames */
+	if (eth_skb_pad(skb)) {
+		netdev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
+	/* Reject oversize packets */
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
 		if (net_ratelimit())
 			netdev_dbg(netdev, "tx packet too big\n");
@@ -655,7 +661,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	/* setup TX descriptor */
 	ftgmac100_txdes_set_skb(txdes, skb);
 	ftgmac100_txdes_set_dma_addr(txdes, map);
-	ftgmac100_txdes_set_buffer_size(txdes, len);
+	ftgmac100_txdes_set_buffer_size(txdes, skb->len);
 
 	ftgmac100_txdes_set_first_segment(txdes);
 	ftgmac100_txdes_set_last_segment(txdes);
-- 
2.9.3
