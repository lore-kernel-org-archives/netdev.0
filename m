From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 05/13] net: mvneta: add xmit_more support
Date: Sun, 22 Nov 2015 08:53:51 +0100
Message-ID: <1448178839-3541-6-git-send-email-mw@semihalf.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Guinot <simon.guinot@sequanux.org>

Basing on xmit_more flag of the skb, TX descriptors can be concatenated
before flushing. This commit delay Tx descriptor flush if the queue is
running and if there is more skb's to send.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f079b13..9c9e858 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -467,6 +467,7 @@ struct mvneta_tx_queue {
 	 * descriptor ring
 	 */
 	int count;
+	int pending;
 	int tx_stop_threshold;
 	int tx_wake_threshold;
 
@@ -751,8 +752,9 @@ static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
 	/* Only 255 descriptors can be added at once ; Assume caller
 	 * process TX desriptors in quanta less than 256
 	 */
-	val = pend_desc;
+	val = pend_desc + txq->pending;
 	mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
+	txq->pending = 0;
 }
 
 /* Get pointer to next TX descriptor to be processed (send) by HW */
@@ -1857,11 +1859,14 @@ out:
 		struct netdev_queue *nq = netdev_get_tx_queue(dev, txq_id);
 
 		txq->count += frags;
-		mvneta_txq_pend_desc_add(pp, txq, frags);
-
 		if (txq->count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
 
+		if (!skb->xmit_more || netif_xmit_stopped(nq))
+			mvneta_txq_pend_desc_add(pp, txq, frags);
+		else
+			txq->pending += frags;
+
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes  += len;
-- 
1.8.3.1
