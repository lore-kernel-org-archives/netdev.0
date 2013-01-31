From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Send Flush Work Request on a TX Queue
Date: Thu, 31 Jan 2013 19:36:26 +0530
Message-ID: <1359641187-17902-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15094 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab3AaOLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 09:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send Flush Work Request on a TX Queue if it has unreclaimed TX Descriptors
and the last time anything was sent on the associated net device was more than
5 seconds in the past, issue a flush request on the TX Queue in order to get
any stranded skb's off the TX Queue.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c      |  112 +++++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |    8 ++
 2 files changed, 113 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index fe9a2ea..d6cfdd5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1994,6 +1994,81 @@ static void sge_rx_timer_cb(unsigned long data)
 	mod_timer(&s->rx_timer, jiffies + RX_QCHECK_PERIOD);
 }
 
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
+		eth_txq_stop(txq);
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
+ *	@data: the adapter
+ *
+ *	Runs periodically from a timer to perform maintenance of SGE Tx queues.
+ *	It performs two tasks:
+ *
+ *	a) Restarts offload Tx queues stopped due to I/O MMU mapping errors.
+ *
+ *	b) Reclaims completed Tx packets for the Ethernet queues.  Normally
+ *	packets are cleaned up by new Tx packets, this timer cleans up packets
+ *	when no new packets are being submitted.  This is essential for pktgen,
+ *	at least.
+ */
 static void sge_tx_timer_cb(unsigned long data)
 {
 	unsigned long m;
@@ -2015,26 +2090,49 @@ static void sge_tx_timer_cb(unsigned long data)
 	do {
 		struct sge_eth_txq *q = &s->ethtxq[i];
 
-		if (q->q.in_use &&
-		    time_after_eq(jiffies, q->txq->trans_start + HZ / 100) &&
-		    __netif_tx_trylock(q->txq)) {
-			int avail = reclaimable(&q->q);
+		if (__netif_tx_trylock(q->txq)) {
 
-			if (avail) {
+			if (reclaimable(&q->q)) {
+				int avail = reclaimable(&q->q);
 				if (avail > budget)
 					avail = budget;
 
 				free_tx_desc(adap, &q->q, avail, true);
 				q->q.in_use -= avail;
+
 				budget -= avail;
+				if (!budget) {
+					__netif_tx_unlock(q->txq);
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
+			if (q->q.in_use > 0 &&
+			    time_after(jiffies,
+				       q->txq->dev->trans_start + HZ * 5)) {
+				local_bh_disable();
+				send_flush_wr(adap, q);
+				local_bh_enable();
 			}
 			__netif_tx_unlock(q->txq);
 		}
 
-		if (++i >= s->ethqsets)
+		i++;
+		if (i >= s->ethqsets)
 			i = 0;
-	} while (budget && i != s->ethtxq_rover);
+	} while (i != s->ethtxq_rover);
 	s->ethtxq_rover = i;
+
+	/* If we found too many reclaimable packets schedule a timer in the
+	 * near future to continue where we left off.  Otherwise the next timer
+	 * will be at its normal interval.
+	 */
 	mod_timer(&s->tx_timer, jiffies + (budget ? TX_QCHECK_PERIOD : 2));
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index a0dcccd..db31bd6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -85,6 +85,7 @@ enum fw_wr_opcodes {
 	FW_ULPTX_WR                    = 0x04,
 	FW_TP_WR                       = 0x05,
 	FW_ETH_TX_PKT_WR               = 0x08,
+	FW_EQ_FLUSH_WR                 = 0x1b,
 	FW_OFLD_CONNECTION_WR          = 0x2f,
 	FW_FLOWC_WR                    = 0x0a,
 	FW_OFLD_TX_DATA_WR             = 0x0b,
@@ -416,6 +417,13 @@ struct fw_eth_tx_pkt_wr {
 	__be64 r3;
 };
 
+struct fw_eq_flush_wr {
+	__u8   opcode;
+	__u8   r1[3];
+	__be32 equiq_to_len16;
+	__be64 r3;
+};
+
 struct fw_ofld_connection_wr {
 	__be32 op_compl;
 	__be32 len16_pkd;
-- 
1.7.1
