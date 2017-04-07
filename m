From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/12] ftgmac100: Factor tx packet dropping path
Date: Fri,  7 Apr 2017 13:30:57 +1000
Message-ID: <20170407033105.29558-5-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39158 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753424AbdDGDbf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:35 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a simple goto to a drop path at the tail of the function,
it will be used in a few more cases soon

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 6fa070a..6c71726 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -639,10 +639,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
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
@@ -650,10 +647,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
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
@@ -693,6 +687,13 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
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
