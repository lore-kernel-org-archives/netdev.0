From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 1/3] be2net: Clear pending tx completions
	before destroying tx queue
Date: Mon, 10 Aug 2009 19:12:43 +0530
Message-ID: <20090810134243.GA10640@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:43041 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754444AbZHJNnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 09:43:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear pending tx completions in be_close() (ndo.stop method) so that after
unregister_netdev() calls be_close(), all tx skbs are freed and there are
no more tx completions when txq is destroyed.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   52 +++++++++++++++++++++++++++---------------
 1 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index d20235b..f7f8660 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1018,21 +1018,35 @@ static void be_rx_q_clean(struct be_adapter *adapter)
 	BUG_ON(atomic_read(&rxq->used));
 }
 
-static void be_tx_q_clean(struct be_adapter *adapter)
+static void be_tx_compl_clean(struct be_adapter *adapter)
 {
-	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
-	struct sk_buff *sent_skb;
+	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_queue_info *txq = &adapter->tx_obj.q;
-	u16 last_index;
-	bool dummy_wrb;
-
-	while (atomic_read(&txq->used)) {
-		sent_skb = sent_skbs[txq->tail];
-		last_index = txq->tail;
-		index_adv(&last_index,
-			wrb_cnt_for_skb(sent_skb, &dummy_wrb) - 1, txq->len);
-		be_tx_compl_process(adapter, last_index);
-	}
+	struct be_eth_tx_compl *txcp;
+	u16 end_idx, cmpl = 0, timeo = 0;
+
+	/* Wait for a max of 200ms for all the tx-completions to arrive. */
+	do {
+		while ((txcp = be_tx_compl_get(tx_cq))) {
+			end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
+					wrb_index, txcp);
+			be_tx_compl_process(adapter, end_idx);
+			cmpl++;
+		}
+		if (cmpl) {
+			be_cq_notify(adapter, tx_cq->id, false, cmpl);
+			cmpl = 0;
+		}
+
+		if (atomic_read(&txq->used) == 0 || ++timeo > 200)
+			break;
+
+		mdelay(1);
+	} while (true);
+
+	if (atomic_read(&txq->used))
+		dev_err(&adapter->pdev->dev, "%d pending tx-completions\n",
+			atomic_read(&txq->used));
 }
 
 static void be_mcc_queues_destroy(struct be_adapter *adapter)
@@ -1091,13 +1105,8 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 	struct be_queue_info *q;
 
 	q = &adapter->tx_obj.q;
-	if (q->created) {
+	if (q->created)
 		be_cmd_q_destroy(adapter, q, QTYPE_TXQ);
-
-		/* No more tx completions can be rcvd now; clean up if there
-		 * are any pending completions or pending tx requests */
-		be_tx_q_clean(adapter);
-	}
 	be_queue_free(adapter, q);
 
 	q = &adapter->tx_obj.cq;
@@ -1645,6 +1654,11 @@ static int be_close(struct net_device *netdev)
 	napi_disable(&rx_eq->napi);
 	napi_disable(&tx_eq->napi);
 
+	/* Wait for all pending tx completions to arrive so that
+	 * all tx skbs are freed.
+	 */
+	be_tx_compl_clean(adapter);
+
 	return 0;
 }
 
-- 
1.6.0.4
