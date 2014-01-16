From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 06/13] net: mvneta: remove tests for impossible cases in the tx_done path
Date: Thu, 16 Jan 2014 08:20:12 +0100
Message-ID: <1389856819-6503-7-git-send-email-w@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55485 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbaAPHUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:20:47 -0500
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, mvneta_txq_bufs_free() calls mvneta_tx_done_policy() with
a non-null cause to retrieve the pointer to the next queue to process.
There are useless tests on the return queue number and on the pointer,
all of which are well defined within a known limited set. This code
path is fast, although not critical. Removing 3 tests here that the
compiler could not optimize (verified) is always desirable.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Tested-by: Arnaud Ebalard <arno@natisbad.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index df75a23..2fb9559 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1276,13 +1276,16 @@ static void mvneta_rx_csum(struct mvneta_port *pp,
 	skb->ip_summed = CHECKSUM_NONE;
 }
 
-/* Return tx queue pointer (find last set bit) according to causeTxDone reg */
+/* Return tx queue pointer (find last set bit) according to <cause> returned
+ * form tx_done reg. <cause> must not be null. The return value is always a
+ * valid queue for matching the first one found in <cause>.
+ */
 static struct mvneta_tx_queue *mvneta_tx_done_policy(struct mvneta_port *pp,
 						     u32 cause)
 {
 	int queue = fls(cause) - 1;
 
-	return (queue < 0 || queue >= txq_number) ? NULL : &pp->txqs[queue];
+	return &pp->txqs[queue];
 }
 
 /* Free tx queue skbuffs */
@@ -1651,7 +1654,9 @@ static void mvneta_txq_done_force(struct mvneta_port *pp,
 	txq->txq_get_index = 0;
 }
 
-/* handle tx done - called from tx done timer callback */
+/* Handle tx done - called in softirq context. The <cause_tx_done> argument
+ * must be a valid cause according to MVNETA_TXQ_INTR_MASK_ALL.
+ */
 static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
 			      int *tx_todo)
 {
@@ -1660,10 +1665,8 @@ static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
 	struct netdev_queue *nq;
 
 	*tx_todo = 0;
-	while (cause_tx_done != 0) {
+	while (cause_tx_done) {
 		txq = mvneta_tx_done_policy(pp, cause_tx_done);
-		if (!txq)
-			break;
 
 		nq = netdev_get_tx_queue(pp->dev, txq->id);
 		__netif_tx_lock(nq, smp_processor_id());
-- 
1.7.12.2.21.g234cd45.dirty
