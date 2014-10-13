From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net-next] tg3: Add skb->xmit_more support
Date: Mon, 13 Oct 2014 09:21:42 -0700
Message-ID: <1413217302-15396-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <dborkman@redhat.com>,
	<mchan@broadcom.com>, Prashant Sreedharan <prashant@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:53423 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbaJMQdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ring TX doorbell only if xmit_more is not set or the queue is stopped.

Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ba49948..dbb41c1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8099,9 +8099,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Sync BD data before updating mailbox */
 	wmb();
 
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox(tnapi->prodmbox, entry);
-
 	tnapi->tx_prod = entry;
 	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
 		netif_tx_stop_queue(txq);
@@ -8116,7 +8113,12 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_tx_wake_queue(txq);
 	}
 
-	mmiowb();
+	if (!skb->xmit_more || netif_xmit_stopped(txq)) {
+		/* Packets are ready, update Tx producer idx on card. */
+		tw32_tx_mbox(tnapi->prodmbox, entry);
+		mmiowb();
+	}
+
 	return NETDEV_TX_OK;
 
 dma_error:
-- 
1.7.1
