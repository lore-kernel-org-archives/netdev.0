From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 10/10] chelesio: transmit locking (plus bug fix).
Date: Fri, 01 Dec 2006 16:36:22 -0800
Message-ID: <20061202003707.873200000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:35812 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162439AbWLBApB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:45:01 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-tx-lock.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If transmit lock is contended on, then push return code back
and retry at higher level.

Bugfix: If buffer is reallocated because of lack of headroom
and the send is blocked, then drop packet. This is necessary
because caller would end up requeuing a freed skb.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/sge.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

--- chelsio.orig/drivers/net/chelsio/sge.c
+++ chelsio/drivers/net/chelsio/sge.c
@@ -1778,7 +1778,9 @@ static int t1_sge_tx(struct sk_buff *skb
 	struct cmdQ *q = &sge->cmdQ[qid];
 	unsigned int credits, pidx, genbit, count, use_sched_skb = 0;
 
-	spin_lock(&q->lock);
+	if (!spin_trylock(&q->lock))
+		return NETDEV_TX_LOCKED;
+
 	reclaim_completed_tx(sge, q);
 
 	pidx = q->pidx;
@@ -1887,6 +1889,8 @@ int t1_start_xmit(struct sk_buff *skb, s
 	struct sge *sge = adapter->sge;
 	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
 	struct cpl_tx_pkt *cpl;
+	struct sk_buff *orig_skb = skb;
+	int ret;
 
 	if (skb->protocol == htons(ETH_P_CPL5))
 		goto send;
@@ -1930,8 +1934,6 @@ int t1_start_xmit(struct sk_buff *skb, s
 		 * Complain when this happens but try to fix things up.
 		 */
 		if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
-			struct sk_buff *orig_skb = skb;
-
 			pr_debug("%s: headroom %d header_len %d\n", dev->name,
 				 skb_headroom(skb), dev->hard_header_len);
 
@@ -1991,7 +1993,16 @@ int t1_start_xmit(struct sk_buff *skb, s
 send:
 	st->tx_packets++;
 	dev->trans_start = jiffies;
-	return t1_sge_tx(skb, adapter, 0, dev);
+	ret = t1_sge_tx(skb, adapter, 0, dev);
+
+	/* If transmit busy, and we reallocated skb's due to headroom limit,
+	 * then silently discard to avoid leak.
+	 */
+	if (unlikely(ret != NETDEV_TX_OK && skb != orig_skb)) {
+ 		dev_kfree_skb_any(skb);
+		ret = NETDEV_TX_OK;
+ 	}
+	return ret;
 }
 
 /*

-- 

