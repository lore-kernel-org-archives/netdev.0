From: Karl Beldan <karl.beldan@gmail.com>
Subject: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released by the HW
Date: Wed,  5 Nov 2014 15:32:59 +0100
Message-ID: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
Cc: Karl Beldan <karl.beldan@rivierawaves.com>, netdev@vger.kernel.org,
	Ian Campbell <ijc@hellion.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:55734 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaKEOdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 09:33:33 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so2170643wiv.14
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 06:33:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Beldan <karl.beldan@rivierawaves.com>

ATM, txq_reclaim will dequeue and free an skb for each tx desc released
by the hw that has TX_LAST_DESC set. However, in case of TSO, each
hw desc embedding the last part of a segment has TX_LAST_DESC set,
losing the one-to-one 'last skb frag'/'TX_LAST_DESC set' correspondance,
which causes data corruption.

Fix this by checking TX_ENABLE_INTERRUPT instead of TX_LAST_DESC, and
warn when trying to dequeue from an empty txq (which can be symptomatic
of releasing skbs prematurely).

Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
Reported-by: Slawomir Gajzner <slawomir.gajzner@gmail.com>
Reported-by: Julien D'Ascenzio <jdascenzio@yahoo.fr>
Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
Cc: Ian Campbell <ijc@hellion.org.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Ian, I refrained myself from embedding your Tested-by since this change is a
little bit different from my first.
David, please consider queueing this one up for -stable, and possibly adjust
Ian's Tested-by (I am not sure about the process).

 drivers/net/ethernet/marvell/mv643xx_eth.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index b151a94..d44560d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1047,7 +1047,6 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		int tx_index;
 		struct tx_desc *desc;
 		u32 cmd_sts;
-		struct sk_buff *skb;
 
 		tx_index = txq->tx_used_desc;
 		desc = &txq->tx_desc_area[tx_index];
@@ -1066,19 +1065,22 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		reclaimed++;
 		txq->tx_desc_count--;
 
-		skb = NULL;
-		if (cmd_sts & TX_LAST_DESC)
-			skb = __skb_dequeue(&txq->tx_skb);
+		if (!IS_TSO_HEADER(txq, desc->buf_ptr))
+			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
+					 desc->byte_cnt, DMA_TO_DEVICE);
+
+		if (cmd_sts & TX_ENABLE_INTERRUPT) {
+			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
+
+			if (!WARN_ON(!skb))
+				dev_kfree_skb(skb);
+		}
 
 		if (cmd_sts & ERROR_SUMMARY) {
 			netdev_info(mp->dev, "tx error\n");
 			mp->dev->stats.tx_errors++;
 		}
 
-		if (!IS_TSO_HEADER(txq, desc->buf_ptr))
-			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-					 desc->byte_cnt, DMA_TO_DEVICE);
-		dev_kfree_skb(skb);
 	}
 
 	__netif_tx_unlock_bh(nq);
-- 
2.0.1
