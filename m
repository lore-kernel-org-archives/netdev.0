From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCH net-next 1/2] net: mvneta: mvneta_tx_done_gbe() cleanups
Date: Wed, 15 Jan 2014 00:45:49 +0100
Message-ID: <5880b38afc5884f5ed57c26824cc37666bd60b99.1389742334.git.arno@natisbad.org>
References: <cover.1389742334.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:44410 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbaANXqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 18:46:01 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 3846B940091
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 00:45:53 +0100 (CET)
In-Reply-To: <cover.1389742334.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


mvneta_tx_done_gbe() return value and third parameter are no more
used. This patch changes the function prototype and removes a useless
variable where the function is called.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f5fc7a249880..8c5150124b5e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1704,30 +1704,23 @@ static void mvneta_txq_done_force(struct mvneta_port *pp,
 /* Handle tx done - called in softirq context. The <cause_tx_done> argument
  * must be a valid cause according to MVNETA_TXQ_INTR_MASK_ALL.
  */
-static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
-			      int *tx_todo)
+static void mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done)
 {
 	struct mvneta_tx_queue *txq;
-	u32 tx_done = 0;
 	struct netdev_queue *nq;
 
-	*tx_todo = 0;
 	while (cause_tx_done) {
 		txq = mvneta_tx_done_policy(pp, cause_tx_done);
 
 		nq = netdev_get_tx_queue(pp->dev, txq->id);
 		__netif_tx_lock(nq, smp_processor_id());
 
-		if (txq->count) {
-			tx_done += mvneta_txq_done(pp, txq);
-			*tx_todo += txq->count;
-		}
+		if (txq->count)
+			mvneta_txq_done(pp, txq);
 
 		__netif_tx_unlock(nq);
 		cause_tx_done &= ~((1 << txq->id));
 	}
-
-	return tx_done;
 }
 
 /* Compute crc8 of the specified address, using a unique algorithm ,
@@ -1961,9 +1954,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 
 	/* Release Tx descriptors */
 	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
-		int tx_todo = 0;
-
-		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL), &tx_todo);
+		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL));
 		cause_rx_tx &= ~MVNETA_TX_INTR_MASK_ALL;
 	}
 
-- 
1.8.5.2
