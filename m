From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2] mv643xx_eth: fix recycle check bound
Date: Tue, 18 Nov 2008 15:28:58 +0100
Message-ID: <20081118142858.GQ5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:41511 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbYKRO27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 09:28:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mv643xx_eth allocates skbuffs, it adds
'dma_get_cache_alignment() - 1' to the length it needs, so that it can
align the skb's ->data pointer to a cache boundary.  When checking
whether a transmitted skbuff can be reused as a receive buffer, these
bytes needs to be included into the minimum bound for the recycle check.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 7a6b37b..4d183af 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -898,7 +898,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		if (skb != NULL) {
 			if (skb_queue_len(&mp->rx_recycle) <
 					mp->default_rx_ring_size &&
-			    skb_recycle_check(skb, mp->skb_size))
+			    skb_recycle_check(skb, mp->skb_size +
+					dma_get_cache_alignment() - 1))
 				__skb_queue_head(&mp->rx_recycle, skb);
 			else
 				dev_kfree_skb(skb);
