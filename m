From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/6] mv643xx_eth: inline txq_alloc_desc_index()
Date: Tue, 18 Nov 2008 23:29:14 +0100
Message-ID: <20081118222913.GU5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53432 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbYKRW3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:29:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since txq_alloc_desc_index() is a very simple function, and since
descriptor ring index handling for transmit reclaim, receive
processing and receive refill is already handled inline as well,
inline txq_alloc_desc_index() into its two call sites.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0f73d85..3326587 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -651,21 +651,6 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 	return 0;
 }
 
-static int txq_alloc_desc_index(struct tx_queue *txq)
-{
-	int tx_desc_curr;
-
-	BUG_ON(txq->tx_desc_count >= txq->tx_ring_size);
-
-	tx_desc_curr = txq->tx_curr_desc++;
-	if (txq->tx_curr_desc == txq->tx_ring_size)
-		txq->tx_curr_desc = 0;
-
-	BUG_ON(txq->tx_curr_desc == txq->tx_used_desc);
-
-	return tx_desc_curr;
-}
-
 static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
 	int nr_frags = skb_shinfo(skb)->nr_frags;
@@ -677,7 +662,9 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		struct tx_desc *desc;
 
 		this_frag = &skb_shinfo(skb)->frags[frag];
-		tx_index = txq_alloc_desc_index(txq);
+		tx_index = txq->tx_curr_desc++;
+		if (txq->tx_curr_desc == txq->tx_ring_size)
+			txq->tx_curr_desc = 0;
 		desc = &txq->tx_desc_area[tx_index];
 
 		/*
@@ -759,7 +746,9 @@ no_csum:
 		cmd_sts |= 5 << TX_IHL_SHIFT;
 	}
 
-	tx_index = txq_alloc_desc_index(txq);
+	tx_index = txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
 	desc = &txq->tx_desc_area[tx_index];
 
 	if (nr_frags) {
-- 
1.5.6.4
