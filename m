From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net-next 1/2] net: mvneta: add xmit_more support
Date: Mon, 16 Jan 2017 18:08:31 +0100
Message-ID: <1484586512-16412-2-git-send-email-mw@semihalf.com>
References: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
        sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
        jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        jaz@semihalf.com, Simon Guinot <simon.guinot@sequanux.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Guinot <simon.guinot@sequanux.org>

Basing on xmit_more flag of the skb, TX descriptors can be concatenated
before flushing. This commit delay Tx descriptor flush if the queue is
running and if there is more skb's to send.

A maximum allowed number of descriptors for flushing at once due to
MVNETA_TXQ_UPDATE_REG(q) reqisters limitation, is 255. Because of that
a new macro was added (MVNETA_TXQ_DEC_SENT_MASK) in order to ensure that
concatenated amount of descriptor does not exceed that value.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3607d8f..9624537 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -224,6 +224,7 @@
 #define      MVNETA_TXQ_SENT_THRESH_MASK(coal)   ((coal) << 16)
 #define MVNETA_TXQ_UPDATE_REG(q)                 (0x3c60 + ((q) << 2))
 #define      MVNETA_TXQ_DEC_SENT_SHIFT           16
+#define      MVNETA_TXQ_DEC_SENT_MASK            0xff
 #define MVNETA_TXQ_STATUS_REG(q)                 (0x3c40 + ((q) << 2))
 #define      MVNETA_TXQ_SENT_DESC_SHIFT          16
 #define      MVNETA_TXQ_SENT_DESC_MASK           0x3fff0000
@@ -525,6 +526,7 @@ struct mvneta_tx_queue {
 	 * descriptor ring
 	 */
 	int count;
+	int pending;
 	int tx_stop_threshold;
 	int tx_wake_threshold;
 
@@ -818,8 +820,9 @@ static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
 	/* Only 255 descriptors can be added at once ; Assume caller
 	 * process TX desriptors in quanta less than 256
 	 */
-	val = pend_desc;
+	val = pend_desc + txq->pending;
 	mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
+	txq->pending = 0;
 }
 
 /* Get pointer to next TX descriptor to be processed (send) by HW */
@@ -2399,11 +2402,15 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 		struct netdev_queue *nq = netdev_get_tx_queue(dev, txq_id);
 
 		txq->count += frags;
-		mvneta_txq_pend_desc_add(pp, txq, frags);
-
 		if (txq->count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
 
+		if (!skb->xmit_more || netif_xmit_stopped(nq) ||
+		    txq->pending + frags > MVNETA_TXQ_DEC_SENT_MASK)
+			mvneta_txq_pend_desc_add(pp, txq, frags);
+		else
+			txq->pending += frags;
+
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes  += len;
-- 
1.8.3.1
