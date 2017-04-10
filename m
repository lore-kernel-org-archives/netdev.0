From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 04/12] ftgmac100: Factor tx packet dropping path
Date: Mon, 10 Apr 2017 11:15:18 +1000
Message-ID: <20170410011526.4509-5-benh@kernel.crashing.org>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33510 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdDJBoR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:44:17 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a simple goto to a drop path at the tail of the function,
it will be used in a few more cases soon

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index a5bab0d..84ae800 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -638,10 +638,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
 		if (net_ratelimit())
 			netdev_dbg(netdev, "tx packet too big\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
+		goto drop;
 	}
 
 	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
@@ -649,10 +646,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		/* drop packet */
 		if (net_ratelimit())
 			netdev_err(netdev, "map socket buffer failed\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
+		goto drop;
 	}
 
 	txdes = ftgmac100_current_txdes(priv);
@@ -692,6 +686,13 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	ftgmac100_txdma_normal_prio_start_polling(priv);
 
 	return NETDEV_TX_OK;
+
+ drop:
+	/* Drop the packet */
+	dev_kfree_skb_any(skb);
+	netdev->stats.tx_dropped++;
+
+	return NETDEV_TX_OK;
 }
 
 static void ftgmac100_free_buffers(struct ftgmac100 *priv)
-- 
2.9.3
