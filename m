From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 3/7 v2] GRETH: GBit transmit descriptor handling optimization
Date: Fri, 14 Jan 2011 14:02:39 +0100
Message-ID: <1295010163-2585-3-git-send-email-daniel@gaisler.com>
References: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:57038 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756925Ab1ANNCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 08:02:55 -0500
In-Reply-To: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is safe to enable all fragments before enabling the first descriptor,
this way all descriptors don't have to be processed twice, added extra
memory barrier.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index b307696..869e38d 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -503,7 +503,7 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 		greth->tx_skbuff[curr_tx] = NULL;
 		bdp = greth->tx_bd_base + curr_tx;
 
-		status = GRETH_TXBD_CSALL;
+		status = GRETH_TXBD_CSALL | GRETH_BD_EN;
 		status |= frag->size & GRETH_BD_LEN;
 
 		/* Wrap around descriptor ring */
@@ -540,26 +540,27 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 
 	wmb();
 
-	/* Enable the descriptors that we configured ...  */
-	for (i = 0; i < nr_frags + 1; i++) {
-		bdp = greth->tx_bd_base + greth->tx_next;
-		greth_write_bd(&bdp->stat, greth_read_bd(&bdp->stat) | GRETH_BD_EN);
-		greth->tx_next = NEXT_TX(greth->tx_next);
-		greth->tx_free--;
-	}
+	/* Enable the descriptor chain by enabling the first descriptor */
+	bdp = greth->tx_bd_base + greth->tx_next;
+	greth_write_bd(&bdp->stat, greth_read_bd(&bdp->stat) | GRETH_BD_EN);
+	greth->tx_next = curr_tx;
+	greth->tx_free -= nr_frags + 1;
+
+	wmb();
 
 	greth_enable_tx(greth);
 
 	return NETDEV_TX_OK;
 
 frag_map_error:
-	/* Unmap SKB mappings that succeeded */
+	/* Unmap SKB mappings that succeeded and disable descriptor */
 	for (i = 0; greth->tx_next + i != curr_tx; i++) {
 		bdp = greth->tx_bd_base + greth->tx_next + i;
 		dma_unmap_single(greth->dev,
 				 greth_read_bd(&bdp->addr),
 				 greth_read_bd(&bdp->stat) & GRETH_BD_LEN,
 				 DMA_TO_DEVICE);
+		greth_write_bd(&bdp->stat, 0);
 	}
 map_error:
 	if (net_ratelimit())
-- 
1.5.4

