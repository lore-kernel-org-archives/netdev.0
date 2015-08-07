From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH net-next] net: fec: fix the race between xmit and bdp reclaiming path
Date: Fri,  7 Aug 2015 13:52:37 +0800
Message-ID: <1438926757-24447-1-git-send-email-haokexin@gmail.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36283 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbHGFwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 01:52:49 -0400
Received: by ykeo23 with SMTP id o23so81013491yke.3
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 22:52:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we transmit a fragmented skb, we may run into a race like the
following scenario (assume txq->cur_tx is next to txq->dirty_tx):
           cpu 0                                          cpu 1
  fec_enet_txq_submit_skb
    reserve a bdp for the first fragment
    fec_enet_txq_submit_frag_skb
       update the bdp for the other fragment
       update txq->cur_tx
                                                   fec_enet_tx_queue
                                                     bdp = fec_enet_get_nextdesc(txq->dirty_tx, fep, queue_id);
                                                     This bdp is the bdp reserved for the first segment. Given
                                                     that this bdp BD_ENET_TX_READY bit is not set and txq->cur_tx
                                                     is already pointed to a bdp beyond this one. We think this is a
                                                     completed bdp and try to reclaim it.
    update the bdp for the first segment
    update txq->cur_tx

So we shouldn't update the txq->cur_tx until all the update to the
bdps used for fragments are performed. Also add the corresponding
memory barrier to guarantee that the update to the bdps, dirty_tx and
cur_tx performed in the proper order.

Signed-off-by: Kevin Hao <haokexin@gmail.com>
---
I have run into a kernel hang due to this race on a custom rt kernel. Even
I can't reproduce it on the vanilla kernel, it seems that the same race
window does exist. No difference in performance before or after this patch.

 drivers/net/ethernet/freescale/fec_main.c | 35 ++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 32e3807c650e..ca792368f5df 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -364,7 +364,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
-static int
+static struct bufdesc *
 fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			     struct sk_buff *skb,
 			     struct net_device *ndev)
@@ -439,10 +439,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		bdp->cbd_sc = status;
 	}
 
-	txq->cur_tx = bdp;
-
-	return 0;
-
+	return bdp;
 dma_mapping_error:
 	bdp = txq->cur_tx;
 	for (i = 0; i < frag; i++) {
@@ -450,7 +447,7 @@ dma_mapping_error:
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 				bdp->cbd_datlen, DMA_TO_DEVICE);
 	}
-	return NETDEV_TX_OK;
+	return ERR_PTR(-ENOMEM);
 }
 
 static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
@@ -467,7 +464,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	unsigned int estatus = 0;
 	unsigned int index;
 	int entries_free;
-	int ret;
 
 	entries_free = fec_enet_get_free_txdesc_num(fep, txq);
 	if (entries_free < MAX_SKB_FRAGS + 1) {
@@ -485,6 +481,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	/* Fill in a Tx ring entry */
 	bdp = txq->cur_tx;
+	last_bdp = bdp;
 	status = bdp->cbd_sc;
 	status &= ~BD_ENET_TX_STATS;
 
@@ -513,9 +510,9 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	}
 
 	if (nr_frags) {
-		ret = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
-		if (ret)
-			return ret;
+		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
+		if (IS_ERR(last_bdp))
+			return NETDEV_TX_OK;
 	} else {
 		status |= (BD_ENET_TX_INTR | BD_ENET_TX_LAST);
 		if (fep->bufdesc_ex) {
@@ -544,7 +541,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 		ebdp->cbd_esc = estatus;
 	}
 
-	last_bdp = txq->cur_tx;
 	index = fec_enet_get_bd_index(txq->tx_bd_base, last_bdp, fep);
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
@@ -563,6 +559,10 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	skb_tx_timestamp(skb);
 
+	/* Make sure the update to bdp and tx_skbuff are performed before
+	 * cur_tx.
+	 */
+	wmb();
 	txq->cur_tx = bdp;
 
 	/* Trigger transmission start */
@@ -1218,10 +1218,11 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 	/* get next bdp of dirty_tx */
 	bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
 
-	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
-
-		/* current queue is empty */
-		if (bdp == txq->cur_tx)
+	while (bdp != READ_ONCE(txq->cur_tx)) {
+		/* Order the load of cur_tx and cbd_sc */
+		rmb();
+		status = READ_ONCE(bdp->cbd_sc);
+		if (status & BD_ENET_TX_READY)
 			break;
 
 		index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
@@ -1275,6 +1276,10 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
 
+		/* Make sure the update to bdp and tx_skbuff are performed
+		 * before dirty_tx
+		 */
+		wmb();
 		txq->dirty_tx = bdp;
 
 		/* Update pointer to next buffer descriptor to be transmitted */
-- 
2.1.0
