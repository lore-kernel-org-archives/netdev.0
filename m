From: David Miller <davem@davemloft.net>
Subject: [PATCH] niu: Add support for byte queue limits.
Date: Thu, 01 Dec 2011 22:17:22 -0500 (EST)
Message-ID: <20111201.221722.1576973992657728413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab1LBDRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 22:17:24 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB23HNTY005108
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 1 Dec 2011 19:17:23 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sun/niu.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 56d106e..88e6b15 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3598,6 +3598,7 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 {
 	struct netdev_queue *txq;
+	unsigned int tx_bytes;
 	u16 pkt_cnt, tmp;
 	int cons, index;
 	u64 cs;
@@ -3620,12 +3621,18 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 	netif_printk(np, tx_done, KERN_DEBUG, np->dev,
 		     "%s() pkt_cnt[%u] cons[%d]\n", __func__, pkt_cnt, cons);
 
-	while (pkt_cnt--)
+	tx_bytes = 0;
+	tmp = pkt_cnt;
+	while (tmp--) {
+		tx_bytes += rp->tx_buffs[cons].skb->len;
 		cons = release_tx_packet(np, rp, cons);
+	}
 
 	rp->cons = cons;
 	smp_mb();
 
+	netdev_tx_completed_queue(txq, pkt_cnt, tx_bytes);
+
 out:
 	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))) {
@@ -4326,6 +4333,7 @@ static void niu_free_channels(struct niu *np)
 			struct tx_ring_info *rp = &np->tx_rings[i];
 
 			niu_free_tx_ring_info(np, rp);
+			netdev_tx_reset_queue(netdev_get_tx_queue(np->dev, i));
 		}
 		kfree(np->tx_rings);
 		np->tx_rings = NULL;
@@ -6731,6 +6739,8 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 		prod = NEXT_TX(rp, prod);
 	}
 
+	netdev_tx_sent_queue(txq, skb->len);
+
 	if (prod < rp->prod)
 		rp->wrap_bit ^= TX_RING_KICK_WRAP;
 	rp->prod = prod;
-- 
1.7.7.3
