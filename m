From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] bna: Add synchronization for tx ring.
Date: Mon,  7 Nov 2016 17:57:56 +0800
Message-ID: <20161107095756.15343-1-bpoirier@suse.com>
Cc: Rasesh Mody <rasesh.mody@cavium.com>,
        Sudarsana Kalluru <sudarsana.kalluru@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36477 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbcKGKQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 05:16:22 -0500
Received: by mail-pf0-f195.google.com with SMTP id n85so15775783pfi.3
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 02:15:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We received two reports of BUG_ON in bnad_txcmpl_process() where
hw_consumer_index appeared to be ahead of producer_index. Out of order
write/read of these variables could explain these reports.

bnad_start_xmit(), as a producer of tx descriptors, has a few memory
barriers sprinkled around writes to producer_index and the device's
doorbell but they're not paired with anything in bnad_txcmpl_process(), a
consumer.

Since we are synchronizing with a device, we must use mandatory barriers,
not smp_*. Also, I didn't see the purpose of the last smp_mb() in
bnad_start_xmit().

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index f9df4b5a..f42f672 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -177,6 +177,7 @@ bnad_txcmpl_process(struct bnad *bnad, struct bna_tcb *tcb)
 		return 0;
 
 	hw_cons = *(tcb->hw_consumer_index);
+	rmb();
 	cons = tcb->consumer_index;
 	q_depth = tcb->q_depth;
 
@@ -3094,7 +3095,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	BNA_QE_INDX_INC(prod, q_depth);
 	tcb->producer_index = prod;
 
-	smp_mb();
+	wmb();
 
 	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags)))
 		return NETDEV_TX_OK;
@@ -3102,7 +3103,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	skb_tx_timestamp(skb);
 
 	bna_txq_prod_indx_doorbell(tcb);
-	smp_mb();
 
 	return NETDEV_TX_OK;
 }
-- 
2.9.3
