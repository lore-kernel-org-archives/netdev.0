From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2] mv643xx_eth: OOM handling fixes
Date: Wed, 29 Apr 2009 23:57:34 +0200
Message-ID: <20090429215734.GZ14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43729 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbZD2VyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:54:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when OOM occurs during rx ring refill, mv643xx_eth will get
into an infinite loop, due to the refill function setting the OOM bit
but not clearing the 'rx refill needed' bit for this queue, while the
calling function (the NAPI poll handler) will call the refill function
in a loop until the 'rx refill needed' bit goes off, without checking
the OOM bit.

This patch fixes this by checking the OOM bit in the NAPI poll handler
before attempting to do rx refill.  This means that once OOM occurs,
we won't try to do any memory allocations again until the next invocation
of the poll handler.

While we're at it, change the OOM flag to be a single bit instead of
one bit per receive queue since OOM is a system state rather than a
per-queue state, and cancel the OOM timer on entry to the NAPI poll
handler if it's running to prevent it from firing when we've already
come out of OOM.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Cc: stable@kernel.org
---
 drivers/net/mv643xx_eth.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b3185bf..038beff 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -393,12 +393,12 @@ struct mv643xx_eth_private {
 	struct work_struct tx_timeout_task;
 
 	struct napi_struct napi;
+	u8 oom;
 	u8 work_link;
 	u8 work_tx;
 	u8 work_tx_end;
 	u8 work_rx;
 	u8 work_rx_refill;
-	u8 work_rx_oom;
 
 	int skb_size;
 	struct sk_buff_head rx_recycle;
@@ -661,7 +661,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 					    dma_get_cache_alignment() - 1);
 
 		if (skb == NULL) {
-			mp->work_rx_oom |= 1 << rxq->index;
+			mp->oom = 1;
 			goto oom;
 		}
 
@@ -2167,8 +2167,10 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 	mp = container_of(napi, struct mv643xx_eth_private, napi);
 
-	mp->work_rx_refill |= mp->work_rx_oom;
-	mp->work_rx_oom = 0;
+	if (unlikely(mp->oom)) {
+		mp->oom = 0;
+		del_timer(&mp->rx_oom);
+	}
 
 	work_done = 0;
 	while (work_done < budget) {
@@ -2182,8 +2184,10 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 			continue;
 		}
 
-		queue_mask = mp->work_tx | mp->work_tx_end |
-				mp->work_rx | mp->work_rx_refill;
+		queue_mask = mp->work_tx | mp->work_tx_end | mp->work_rx;
+		if (likely(!mp->oom))
+			queue_mask |= mp->work_rx_refill;
+
 		if (!queue_mask) {
 			if (mv643xx_eth_collect_events(mp))
 				continue;
@@ -2204,7 +2208,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 			txq_maybe_wake(mp->txq + queue);
 		} else if (mp->work_rx & queue_mask) {
 			work_done += rxq_process(mp->rxq + queue, work_tbd);
-		} else if (mp->work_rx_refill & queue_mask) {
+		} else if (!mp->oom && (mp->work_rx_refill & queue_mask)) {
 			work_done += rxq_refill(mp->rxq + queue, work_tbd);
 		} else {
 			BUG();
@@ -2212,7 +2216,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		if (mp->work_rx_oom)
+		if (mp->oom)
 			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
 		napi_complete(napi);
 		wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
@@ -2372,7 +2376,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 		rxq_refill(mp->rxq + i, INT_MAX);
 	}
 
-	if (mp->work_rx_oom) {
+	if (mp->oom) {
 		mp->rx_oom.expires = jiffies + (HZ / 10);
 		add_timer(&mp->rx_oom);
 	}
-- 
1.5.6.4
