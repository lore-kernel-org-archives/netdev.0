From: David Miller <davem@davemloft.net>
Subject: [PATCH] Revert "niu: Add support for byte queue limits."
Date: Fri, 08 Jun 2012 00:30:43 -0700 (PDT)
Message-ID: <20120608.003043.1986430143540742088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab2FHHaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 03:30:46 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E6723583CEE
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 00:30:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts commit efa230f2c68abab817f13473077f8d0cc74f43f3.

BQL doesn't work with how this driver currently only takes TX
interrupts every 1/4 of the TX ring.  That behavior needs to be fixed,
but that's a larger non-trivial task and for now we have to revert
BQL support as this makes the device currently completely unusable.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sun/niu.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 703c8cc..8c726b7 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3598,7 +3598,6 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 {
 	struct netdev_queue *txq;
-	unsigned int tx_bytes;
 	u16 pkt_cnt, tmp;
 	int cons, index;
 	u64 cs;
@@ -3621,18 +3620,12 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 	netif_printk(np, tx_done, KERN_DEBUG, np->dev,
 		     "%s() pkt_cnt[%u] cons[%d]\n", __func__, pkt_cnt, cons);
 
-	tx_bytes = 0;
-	tmp = pkt_cnt;
-	while (tmp--) {
-		tx_bytes += rp->tx_buffs[cons].skb->len;
+	while (pkt_cnt--)
 		cons = release_tx_packet(np, rp, cons);
-	}
 
 	rp->cons = cons;
 	smp_mb();
 
-	netdev_tx_completed_queue(txq, pkt_cnt, tx_bytes);
-
 out:
 	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))) {
@@ -4333,7 +4326,6 @@ static void niu_free_channels(struct niu *np)
 			struct tx_ring_info *rp = &np->tx_rings[i];
 
 			niu_free_tx_ring_info(np, rp);
-			netdev_tx_reset_queue(netdev_get_tx_queue(np->dev, i));
 		}
 		kfree(np->tx_rings);
 		np->tx_rings = NULL;
@@ -6739,8 +6731,6 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 		prod = NEXT_TX(rp, prod);
 	}
 
-	netdev_tx_sent_queue(txq, skb->len);
-
 	if (prod < rp->prod)
 		rp->wrap_bit ^= TX_RING_KICK_WRAP;
 	rp->prod = prod;
-- 
1.7.6.5
