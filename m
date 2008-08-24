From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/5] mv643xx_eth: fix double add_timer() on the receive oom timer
Date: Sun, 24 Aug 2008 04:05:02 +0200
Message-ID: <20080824020502.GC8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@cam.org>,
	Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57596 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbYHXCFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:05:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 12e4ab79cd828563dc090d2117dc8626b344bc8f ("mv643xx_eth: be
more agressive about RX refill") changed the condition for the receive
out-of-memory timer to be scheduled from "the receive ring is empty"
to "the receive ring is not full".

This can lead to a situation where the receive out-of-memory timer is
pending because a previous rxq_refill() didn't manage to refill the
receive ring entirely as a result of being out of memory, and
rxq_refill() is then called again as a side effect of a packet receive
interrupt, and that rxq_refill() call then again does not succeed to
refill the entire receive ring with fresh empty skbuffs because we are
still out of memory, and then tries to call add_timer() on the already
scheduled out-of-memory timer.

This patch fixes this issue by changing the add_timer() call in
rxq_refill() to a mod_timer() call.  If the OOM timer was not already
scheduled, this will behave as before, whereas if it was already
scheduled, this patch will push back its firing time a bit, which is
safe because we've (unsuccessfully) attempted to refill the receive
ring just before we do this.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index af279f2..8a91d79 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -509,10 +509,8 @@ static void rxq_refill(struct rx_queue *rxq)
 		skb_reserve(skb, 2);
 	}
 
-	if (rxq->rx_desc_count != rxq->rx_ring_size) {
-		rxq->rx_oom.expires = jiffies + (HZ / 10);
-		add_timer(&rxq->rx_oom);
-	}
+	if (rxq->rx_desc_count != rxq->rx_ring_size)
+		mod_timer(&rxq->rx_oom, jiffies + (HZ / 10));
 
 	spin_unlock_irqrestore(&mp->lock, flags);
 }
-- 
1.5.6.4
