From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] qede: Fix Tx timeout due to xmit_more
Date: Tue, 16 Aug 2016 18:40:18 +0300
Message-ID: <1471362018-12152-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:25351 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbcHPPk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:40:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver uses netif_tx_queue_stopped() to make sure the xmit_more
indication will be honored, but that only checks for DRV_XOFF.

At the same time, it's possible that during transmission the DQL will
close the transmission queue with STACK_XOFF indication.
In re-configuration flows, when the threshold is relatively low, it's
possible that the device has no pending tranmissions, and during
tranmission the driver would miss doorbelling the HW.
Since there are no pending transmission, there will never be a Tx
completion [and thus the DQL would not remove the STACK_XOFF indication],
eventually causing the Tx queue to timeout.

While we're at it - also doorbell in case driver has to close the
transmission queue on its own [although this one is less important -
if the ring is full, we're bound to receive completion eventually,
which means the doorbell would only be postponed and not indefinetly
blocked].

Fixes: 312e06761c99 ("qede: Utilize xmit_more")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Do notice that we have pending patch intended for 'net-next'
("qede: Add support for per-queue stats") that might cause a merge
conflict with this one - although it should be trivial to resolve.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e4bd02e..a6eb6af 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -722,11 +722,14 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	txq->tx_db.data.bd_prod =
 		cpu_to_le16(qed_chain_get_prod_idx(&txq->tx_pbl));
 
-	if (!skb->xmit_more || netif_tx_queue_stopped(netdev_txq))
+	if (!skb->xmit_more || netif_xmit_stopped(netdev_txq))
 		qede_update_tx_producer(txq);
 
 	if (unlikely(qed_chain_get_elem_left(&txq->tx_pbl)
 		      < (MAX_SKB_FRAGS + 1))) {
+		if (skb->xmit_more)
+			qede_update_tx_producer(txq);
+
 		netif_tx_stop_queue(netdev_txq);
 		DP_VERBOSE(edev, NETIF_MSG_TX_QUEUED,
 			   "Stop queue was called\n");
-- 
1.9.3
