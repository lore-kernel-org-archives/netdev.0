From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 5/5] be2net: Fix to prevent flooding of TX queue
Date: Tue, 10 May 2011 20:43:57 +0530
Message-ID: <2587062c-b21a-40a4-a8d1-279fe05b0882@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11304 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756510Ab1EJPO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:14:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start/stop TX queue is controlled by TX queue "used" counter.
It is incremented while WRBs are posted to TX queue and
decremented when TX completions are received. This counter was
getting decremented before HW is informed about processing of TX
completions. As used counter is decremented, transmit function
posts new WRBs and creates completion queue full scenario in HW.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_main.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 69728fb..168d802 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1272,7 +1272,7 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 	return txcp;
 }
 
-static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
+static u16 be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 {
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_eth_wrb *wrb;
@@ -1299,9 +1299,8 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 		queue_tail_inc(txq);
 	} while (cur_index != last_index);
 
-	atomic_sub(num_wrbs, &txq->used);
-
 	kfree_skb(sent_skb);
+	return num_wrbs;
 }
 
 static inline struct be_eq_entry *event_get(struct be_eq_obj *eq_obj)
@@ -1384,7 +1383,7 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_eth_tx_compl *txcp;
-	u16 end_idx, cmpl = 0, timeo = 0;
+	u16 end_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
 	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
 	struct sk_buff *sent_skb;
 	bool dummy_wrb;
@@ -1394,12 +1393,14 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 		while ((txcp = be_tx_compl_get(tx_cq))) {
 			end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
 					wrb_index, txcp);
-			be_tx_compl_process(adapter, end_idx);
+			num_wrbs += be_tx_compl_process(adapter, end_idx);
 			cmpl++;
 		}
 		if (cmpl) {
 			be_cq_notify(adapter, tx_cq->id, false, cmpl);
+			atomic_sub(num_wrbs, &txq->used);
 			cmpl = 0;
+			num_wrbs = 0;
 		}
 
 		if (atomic_read(&txq->used) == 0 || ++timeo > 200)
@@ -1419,7 +1420,8 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 		index_adv(&end_idx,
 			wrb_cnt_for_skb(adapter, sent_skb, &dummy_wrb) - 1,
 			txq->len);
-		be_tx_compl_process(adapter, end_idx);
+		num_wrbs = be_tx_compl_process(adapter, end_idx);
+		atomic_sub(num_wrbs, &txq->used);
 	}
 }
 
@@ -1793,12 +1795,12 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_eth_tx_compl *txcp;
 	int tx_compl = 0, mcc_compl, status = 0;
-	u16 end_idx;
+	u16 end_idx, num_wrbs = 0;
 
 	while ((txcp = be_tx_compl_get(tx_cq))) {
 		end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
 				wrb_index, txcp);
-		be_tx_compl_process(adapter, end_idx);
+		num_wrbs += be_tx_compl_process(adapter, end_idx);
 		tx_compl++;
 	}
 
@@ -1814,6 +1816,8 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	if (tx_compl) {
 		be_cq_notify(adapter, adapter->tx_obj.cq.id, true, tx_compl);
 
+		atomic_sub(num_wrbs, &txq->used);
+
 		/* As Tx wrbs have been freed up, wake up netdev queue if
 		 * it was stopped due to lack of tx wrbs.
 		 */
-- 
1.6.0.2

