From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4vf: Send Flush Work Request on a TX Queue
Date: Thu, 31 Jan 2013 19:36:27 +0530
Message-ID: <1359641187-17902-2-git-send-email-vipul@chelsio.com>
References: <1359641187-17902-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9484 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab3AaOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 09:11:42 -0500
In-Reply-To: <1359641187-17902-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send Flush Work Request on a TX Queue if it has unreclaimed TX Descriptors
and the last time anything was sent on the associated net device was more than
5 seconds in the past, issue a flush request on the TX Queue in order to get
any stranded skb's off the TX Queue.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |  104 ++++++++++++++++++++++++---
 1 files changed, 92 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 92170d5..be6ef40 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1969,8 +1969,69 @@ static void sge_rx_timer_cb(unsigned long data)
 	mod_timer(&s->rx_timer, jiffies + RX_QCHECK_PERIOD);
 }
 
-/**
- *	sge_tx_timer_cb - perform periodic maintenance of SGE Tx queues
+/*	send_flush_wr - send a Flush Work Request on a TX Queue
+ *	@adapter: the adapter
+ *	@txq: TX Queue to flush
+ *
+ *	Send a Flush Work Request on the indicated TX Queue with a request to
+ *	updated the Status Page of the TX Queue when the Flush Work Request
+ *	is processed.  This will allow us to determine when all of the
+ *	preceeding TX Requests have been processed.
+ */
+static void send_flush_wr(struct adapter *adapter, struct sge_eth_txq *txq)
+{
+	int  credits;
+	unsigned int ndesc;
+	struct fw_eq_flush_wr *fwr;
+	struct sk_buff *skb;
+	unsigned int len;
+
+	/* See if there's space in the TX Queue to fit the Flush Work Request.
+	 * If not, we simply return.
+	 */
+	len = sizeof(*fwr);
+	ndesc = DIV_ROUND_UP(len, sizeof(struct tx_desc));
+	credits = txq_avail(&txq->q) - ndesc;
+	if (unlikely(credits < 0))
+		return;
+
+	/* Allocate an skb to hold the Flush Work Request and initialize it
+	 * with the flush request.
+	 */
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return;
+	fwr = (struct fw_eq_flush_wr *)__skb_put(skb, len);
+	memset(fwr, 0, sizeof(*fwr));
+
+	fwr->opcode = (__force __u8) htonl(FW_WR_OP(FW_EQ_FLUSH_WR));
+	fwr->equiq_to_len16 = cpu_to_be32(FW_WR_EQUEQ |
+					  FW_WR_LEN16(len / 16));
+
+	/* If the Flush Work Request fills up the TX Queue to the point where
+	 * we don't have enough room for a maximum sized TX Request, then
+	 * we need to stop further TX Requests and request that the firmware
+	 * notify us with an interrupt when it processes this request.
+	 */
+	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
+		txq_stop(txq);
+		fwr->equiq_to_len16 |= cpu_to_be32(FW_WR_EQUIQ);
+	}
+
+	/* Copy the Flush Work Request into the TX Queue and notify the
+	 * hardware that we've given it some more to do ...
+	 */
+	inline_tx_skb(skb, &txq->q, &txq->q.desc[txq->q.pidx]);
+	txq_advance(&txq->q, ndesc);
+	ring_tx_db(adapter, &txq->q, ndesc);
+
+	/* Free up the skb and return ...
+	 */
+	kfree_skb(skb);
+	return;
+}
+
+/*	sge_tx_timer_cb - perform periodic maintenance of SGE Tx queues
  *	@data: the adapter
  *
  *	Runs periodically from a timer to perform maintenance of SGE TX queues.
@@ -1991,19 +2052,38 @@ static void sge_tx_timer_cb(unsigned long data)
 	do {
 		struct sge_eth_txq *txq = &s->ethtxq[i];
 
-		if (reclaimable(&txq->q) && __netif_tx_trylock(txq->txq)) {
-			int avail = reclaimable(&txq->q);
+		if (__netif_tx_trylock(txq->txq)) {
 
-			if (avail > budget)
-				avail = budget;
+			if (reclaimable(&txq->q)) {
+				int avail = reclaimable(&txq->q);
 
-			free_tx_desc(adapter, &txq->q, avail, true);
-			txq->q.in_use -= avail;
-			__netif_tx_unlock(txq->txq);
+				if (avail > budget)
+					avail = budget;
+
+				free_tx_desc(adapter, &txq->q, avail, true);
+				txq->q.in_use -= avail;
 
-			budget -= avail;
-			if (!budget)
-				break;
+				budget -= avail;
+				if (!budget) {
+					__netif_tx_unlock(txq->txq);
+					break;
+				}
+			}
+
+			/* If the TX Queue has unreclaimed TX Descriptors and
+			 * the last time anything was sent on the associated
+			 * net device was more than 5 seconds in the past,
+			 * issue a flush request on the TX Queue in order to
+			 * get any stranded skb's off the TX Queue.
+			 */
+			if (txq->q.in_use > 0 &&
+			    time_after(jiffies,
+				       txq->txq->dev->trans_start + HZ * 5)) {
+				local_bh_disable();
+				send_flush_wr(adapter, txq);
+				local_bh_enable();
+			}
+			__netif_tx_unlock(txq->txq);
 		}
 
 		i++;
-- 
1.7.1
