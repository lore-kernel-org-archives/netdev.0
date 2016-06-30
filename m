From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/5] qede: Utilize xmit_more
Date: Thu, 30 Jun 2016 02:35:20 -0400
Message-ID: <1467268522-24589-4-git-send-email-manish.chopra@qlogic.com>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34727 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751837AbcF3HTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:52 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses xmit_more optimization to reduce
number of TX doorbells write per packet.

Signed-off-by: Manish <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 37 +++++++++++++++++-----------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index ab811e2..2c27b3b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -485,6 +485,24 @@ static bool qede_pkt_req_lin(struct qede_dev *edev, struct sk_buff *skb,
 }
 #endif
 
+static inline void qede_update_tx_producer(struct qede_tx_queue *txq)
+{
+	/* wmb makes sure that the BDs data is updated before updating the
+	 * producer, otherwise FW may read old data from the BDs.
+	 */
+	wmb();
+	barrier();
+	writel(txq->tx_db.raw, txq->doorbell_addr);
+
+	/* mmiowb is needed to synchronize doorbell writes from more than one
+	 * processor. It guarantees that the write arrives to the device before
+	 * the queue lock is released and another start_xmit is called (possibly
+	 * on another CPU). Without this barrier, the next doorbell can bypass
+	 * this doorbell. This is applicable to IA64/Altix systems.
+	 */
+	mmiowb();
+}
+
 /* Main transmit function */
 static
 netdev_tx_t qede_start_xmit(struct sk_buff *skb,
@@ -543,6 +561,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
 		DP_NOTICE(edev, "SKB mapping failed\n");
 		qede_free_failed_tx_pkt(edev, txq, first_bd, 0, false);
+		qede_update_tx_producer(txq);
 		return NETDEV_TX_OK;
 	}
 	nbd++;
@@ -657,6 +676,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		if (rc) {
 			qede_free_failed_tx_pkt(edev, txq, first_bd, nbd,
 						data_split);
+			qede_update_tx_producer(txq);
 			return NETDEV_TX_OK;
 		}
 
@@ -681,6 +701,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		if (rc) {
 			qede_free_failed_tx_pkt(edev, txq, first_bd, nbd,
 						data_split);
+			qede_update_tx_producer(txq);
 			return NETDEV_TX_OK;
 		}
 	}
@@ -701,20 +722,8 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	txq->tx_db.data.bd_prod =
 		cpu_to_le16(qed_chain_get_prod_idx(&txq->tx_pbl));
 
-	/* wmb makes sure that the BDs data is updated before updating the
-	 * producer, otherwise FW may read old data from the BDs.
-	 */
-	wmb();
-	barrier();
-	writel(txq->tx_db.raw, txq->doorbell_addr);
-
-	/* mmiowb is needed to synchronize doorbell writes from more than one
-	 * processor. It guarantees that the write arrives to the device before
-	 * the queue lock is released and another start_xmit is called (possibly
-	 * on another CPU). Without this barrier, the next doorbell can bypass
-	 * this doorbell. This is applicable to IA64/Altix systems.
-	 */
-	mmiowb();
+	if (!skb->xmit_more || netif_tx_queue_stopped(netdev_txq))
+		qede_update_tx_producer(txq);
 
 	if (unlikely(qed_chain_get_elem_left(&txq->tx_pbl)
 		      < (MAX_SKB_FRAGS + 1))) {
-- 
2.7.2
