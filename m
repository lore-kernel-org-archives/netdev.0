From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] sfc: efx: add support for skb->xmit_more
Date: Mon, 13 Oct 2014 18:59:45 +0200
Message-ID: <1413219585-15854-1-git-send-email-dborkman@redhat.com>
Cc: nikolay@redhat.com, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754160AbaJMQ7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 12:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for xmit_more batching: efx has BQL support, thus we need
to only move the queue hang check before the hw tail pointer write
and test for xmit_more bit resp. whether the queue/stack has stopped.
Thanks to Nikolay Aleksandrov who had a Solarflare NIC to test!

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3206098..566432c 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -439,13 +439,13 @@ finish_packet:
 
 	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
 
+	efx_tx_maybe_stop_queue(tx_queue);
+
 	/* Pass off to hardware */
-	efx_nic_push_buffers(tx_queue);
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
+		efx_nic_push_buffers(tx_queue);
 
 	tx_queue->tx_packets++;
-
-	efx_tx_maybe_stop_queue(tx_queue);
-
 	return NETDEV_TX_OK;
 
  dma_err:
@@ -1308,11 +1308,12 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
 
-	/* Pass off to hardware */
-	efx_nic_push_buffers(tx_queue);
-
 	efx_tx_maybe_stop_queue(tx_queue);
 
+	/* Pass off to hardware */
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
+		efx_nic_push_buffers(tx_queue);
+
 	tx_queue->tso_bursts++;
 	return NETDEV_TX_OK;
 
-- 
1.7.11.7
