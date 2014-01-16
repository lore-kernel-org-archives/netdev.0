From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 07/13] net: mvneta: factor rx refilling code
Date: Thu, 16 Jan 2014 08:20:13 +0100
Message-ID: <1389856819-6503-8-git-send-email-w@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55465 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbaAPHUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:20:40 -0500
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make mvneta_rxq_fill() use mvneta_rx_refill() instead of using
duplicate code.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Tested-by: Arnaud Ebalard <arno@natisbad.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 23 +++--------------------
 1 file changed, 3 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 2fb9559..eccafd1 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1969,32 +1969,15 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 			   int num)
 {
-	struct net_device *dev = pp->dev;
 	int i;
 
 	for (i = 0; i < num; i++) {
-		struct sk_buff *skb;
-		struct mvneta_rx_desc *rx_desc;
-		unsigned long phys_addr;
-
-		skb = dev_alloc_skb(pp->pkt_size);
-		if (!skb) {
-			netdev_err(dev, "%s:rxq %d, %d of %d buffs  filled\n",
+		memset(rxq->descs + i, 0, sizeof(struct mvneta_rx_desc));
+		if (mvneta_rx_refill(pp, rxq->descs + i) != 0) {
+			netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs  filled\n",
 				__func__, rxq->id, i, num);
 			break;
 		}
-
-		rx_desc = rxq->descs + i;
-		memset(rx_desc, 0, sizeof(struct mvneta_rx_desc));
-		phys_addr = dma_map_single(dev->dev.parent, skb->head,
-					   MVNETA_RX_BUF_SIZE(pp->pkt_size),
-					   DMA_FROM_DEVICE);
-		if (unlikely(dma_mapping_error(dev->dev.parent, phys_addr))) {
-			dev_kfree_skb(skb);
-			break;
-		}
-
-		mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
 	}
 
 	/* Add this number of RX descriptors as non occupied (ready to
-- 
1.7.12.2.21.g234cd45.dirty
