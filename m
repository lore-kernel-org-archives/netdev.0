From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/5] be2net: fix tx completion cleanup
Date: Fri, 24 Feb 2012 10:20:14 +0530
Message-ID: <1330059017-5976-3-git-send-email-sathya.perla@emulex.com>
References: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755912Ab2BXEzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:42 -0500
In-Reply-To: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a part of be_close(), instead of waiting for a max of 200ms for each TXQ,
wait for a total of 200ms for completions from all TXQs to arrive.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   73 +++++++++++++++------------
 1 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 68408d5..36ad9a7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1563,51 +1563,62 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 	rxq->tail = rxq->head = 0;
 }
 
-static void be_tx_compl_clean(struct be_adapter *adapter,
-				struct be_tx_obj *txo)
+static void be_tx_compl_clean(struct be_adapter *adapter)
 {
-	struct be_queue_info *tx_cq = &txo->cq;
-	struct be_queue_info *txq = &txo->q;
+	struct be_tx_obj *txo;
+	struct be_queue_info *txq;
 	struct be_eth_tx_compl *txcp;
 	u16 end_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
-	struct sk_buff **sent_skbs = txo->sent_skb_list;
 	struct sk_buff *sent_skb;
 	bool dummy_wrb;
+	int i, pending_txqs;
 
 	/* Wait for a max of 200ms for all the tx-completions to arrive. */
 	do {
-		while ((txcp = be_tx_compl_get(tx_cq))) {
-			end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
-					wrb_index, txcp);
-			num_wrbs += be_tx_compl_process(adapter, txo, end_idx);
-			cmpl++;
-		}
-		if (cmpl) {
-			be_cq_notify(adapter, tx_cq->id, false, cmpl);
-			atomic_sub(num_wrbs, &txq->used);
-			cmpl = 0;
-			num_wrbs = 0;
+		pending_txqs = adapter->num_tx_qs;
+
+		for_all_tx_queues(adapter, txo, i) {
+			txq = &txo->q;
+			while ((txcp = be_tx_compl_get(&txo->cq))) {
+				end_idx =
+					AMAP_GET_BITS(struct amap_eth_tx_compl,
+						      wrb_index, txcp);
+				num_wrbs += be_tx_compl_process(adapter, txo,
+								end_idx);
+				cmpl++;
+			}
+			if (cmpl) {
+				be_cq_notify(adapter, txo->cq.id, false, cmpl);
+				atomic_sub(num_wrbs, &txq->used);
+				cmpl = 0;
+				num_wrbs = 0;
+			}
+			if (atomic_read(&txq->used) == 0)
+				pending_txqs--;
 		}
 
-		if (atomic_read(&txq->used) == 0 || ++timeo > 200)
+		if (pending_txqs == 0 || ++timeo > 200)
 			break;
 
 		mdelay(1);
 	} while (true);
 
-	if (atomic_read(&txq->used))
-		dev_err(&adapter->pdev->dev, "%d pending tx-completions\n",
-			atomic_read(&txq->used));
+	for_all_tx_queues(adapter, txo, i) {
+		txq = &txo->q;
+		if (atomic_read(&txq->used))
+			dev_err(&adapter->pdev->dev, "%d pending tx-compls\n",
+				atomic_read(&txq->used));
 
-	/* free posted tx for which compls will never arrive */
-	while (atomic_read(&txq->used)) {
-		sent_skb = sent_skbs[txq->tail];
-		end_idx = txq->tail;
-		index_adv(&end_idx,
-			wrb_cnt_for_skb(adapter, sent_skb, &dummy_wrb) - 1,
-			txq->len);
-		num_wrbs = be_tx_compl_process(adapter, txo, end_idx);
-		atomic_sub(num_wrbs, &txq->used);
+		/* free posted tx for which compls will never arrive */
+		while (atomic_read(&txq->used)) {
+			sent_skb = txo->sent_skb_list[txq->tail];
+			end_idx = txq->tail;
+			num_wrbs = wrb_cnt_for_skb(adapter, sent_skb,
+						   &dummy_wrb);
+			index_adv(&end_idx, num_wrbs - 1, txq->len);
+			num_wrbs = be_tx_compl_process(adapter, txo, end_idx);
+			atomic_sub(num_wrbs, &txq->used);
+		}
 	}
 }
 
@@ -2236,7 +2247,6 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 static int be_close(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_tx_obj *txo;
 	struct be_eq_obj *eqo;
 	int i;
 
@@ -2259,8 +2269,7 @@ static int be_close(struct net_device *netdev)
 	/* Wait for all pending tx completions to arrive so that
 	 * all tx skbs are freed.
 	 */
-	for_all_tx_queues(adapter, txo, i)
-		be_tx_compl_clean(adapter, txo);
+	be_tx_compl_clean(adapter);
 
 	be_rx_qs_destroy(adapter);
 	return 0;
-- 
1.7.4
