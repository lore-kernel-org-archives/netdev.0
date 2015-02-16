From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH v2 net-next 4/4] be2net: Add a few inline functions to test TXQ conditions
Date: Mon, 16 Feb 2015 08:03:48 +0530
Message-ID: <1424054028-23659-5-git-send-email-sriharsha.basavapatna@emulex.com>
References: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:57681 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804AbbBPCly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 21:41:54 -0500
In-Reply-To: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Check qfull condition
- Check qwake condition
- Check pkts pending completion

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b37b099..c58f2835 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -728,6 +728,21 @@ static u16 skb_ip_proto(struct sk_buff *skb)
 		ip_hdr(skb)->protocol : ipv6_hdr(skb)->nexthdr;
 }
 
+static inline bool be_is_txq_full(struct be_tx_obj *txo)
+{
+	return atomic_read(&txo->q.used) + BE_MAX_TX_FRAG_COUNT >= txo->q.len;
+}
+
+static inline bool be_can_txq_wake(struct be_tx_obj *txo)
+{
+	return atomic_read(&txo->q.used) < txo->q.len / 2;
+}
+
+static inline bool be_is_tx_compl_pending(struct be_tx_obj *txo)
+{
+	return atomic_read(&txo->q.used) > txo->pend_wrb_cnt;
+}
+
 static void be_get_wrb_params_from_skb(struct be_adapter *adapter,
 				       struct sk_buff *skb,
 				       struct be_wrb_params *wrb_params)
@@ -1135,7 +1150,6 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 	u16 q_idx = skb_get_queue_mapping(skb);
 	struct be_tx_obj *txo = &adapter->tx_obj[q_idx];
 	struct be_wrb_params wrb_params = { 0 };
-	struct be_queue_info *txq = &txo->q;
 	bool flush = !skb->xmit_more;
 	u16 wrb_cnt;
 
@@ -1151,7 +1165,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto drop;
 	}
 
-	if ((atomic_read(&txq->used) + BE_MAX_TX_FRAG_COUNT) >= txq->len) {
+	if (be_is_txq_full(txo)) {
 		netif_stop_subqueue(netdev, q_idx);
 		tx_stats(txo)->tx_stops++;
 	}
@@ -2226,7 +2240,7 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 				atomic_sub(num_wrbs, &txq->used);
 				timeo = 0;
 			}
-			if (atomic_read(&txq->used) == txo->pend_wrb_cnt)
+			if (!be_is_tx_compl_pending(txo))
 				pending_txqs--;
 		}
 
@@ -2639,7 +2653,7 @@ static void be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 		/* As Tx wrbs have been freed up, wake up netdev queue
 		 * if it was stopped due to lack of tx wrbs.  */
 		if (__netif_subqueue_stopped(adapter->netdev, idx) &&
-		    atomic_read(&txo->q.used) < txo->q.len / 2) {
+		    be_can_txq_wake(txo)) {
 			netif_wake_subqueue(adapter->netdev, idx);
 		}
 
-- 
2.2.0.65.g9abc44b
