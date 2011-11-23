From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 10/10] sfc: Support for byte queue limits
Date: Tue, 22 Nov 2011 21:53:34 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222142440.17133@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:47585 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564Ab1KWGAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:00:44 -0500
Received: by mail-ww0-f74.google.com with SMTP id 5so34178wwe.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 22:00:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to sfc to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/sfc/tx.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index df88c543..60bcbe1 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -31,7 +31,9 @@
 #define EFX_TXQ_THRESHOLD(_efx) ((_efx)->txq_entries / 2u)
 
 static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
-			       struct efx_tx_buffer *buffer)
+			       struct efx_tx_buffer *buffer,
+			       unsigned int *pkts_compl,
+			       unsigned int *bytes_compl)
 {
 	if (buffer->unmap_len) {
 		struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
@@ -48,6 +50,8 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	}
 
 	if (buffer->skb) {
+		(*pkts_compl)++;
+		(*bytes_compl) += buffer->skb->len;
 		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
 		buffer->skb = NULL;
 		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
@@ -250,6 +254,8 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	buffer->skb = skb;
 	buffer->continuation = false;
 
+	netdev_tx_sent_queue(tx_queue->core_txq, 1, skb->len);
+
 	/* Pass off to hardware */
 	efx_nic_push_buffers(tx_queue);
 
@@ -267,10 +273,11 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
  unwind:
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count != tx_queue->write_count) {
+		unsigned int pkts_compl = 0, bytes_compl = 0;
 		--tx_queue->insert_count;
 		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
 		buffer = &tx_queue->buffer[insert_ptr];
-		efx_dequeue_buffer(tx_queue, buffer);
+		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
 		buffer->len = 0;
 	}
 
@@ -293,7 +300,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
  * specified index.
  */
 static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
-				unsigned int index)
+				unsigned int index,
+				unsigned int *pkts_compl,
+				unsigned int *bytes_compl)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	unsigned int stop_index, read_ptr;
@@ -311,7 +320,7 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 			return;
 		}
 
-		efx_dequeue_buffer(tx_queue, buffer);
+		efx_dequeue_buffer(tx_queue, buffer, pkts_compl, bytes_compl);
 		buffer->continuation = true;
 		buffer->len = 0;
 
@@ -422,10 +431,12 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 {
 	unsigned fill_level;
 	struct efx_nic *efx = tx_queue->efx;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
 
-	efx_dequeue_buffers(tx_queue, index);
+	efx_dequeue_buffers(tx_queue, index, &pkts_compl, &bytes_compl);
+	netdev_tx_completed_queue(tx_queue->core_txq, pkts_compl, bytes_compl);
 
 	/* See if we need to restart the netif queue.  This barrier
 	 * separates the update of read_count from the test of the
@@ -515,13 +526,15 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 
 	/* Free any buffers left in the ring */
 	while (tx_queue->read_count != tx_queue->write_count) {
+		unsigned int pkts_compl = 0, bytes_compl = 0;
 		buffer = &tx_queue->buffer[tx_queue->read_count & tx_queue->ptr_mask];
-		efx_dequeue_buffer(tx_queue, buffer);
+		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
 		buffer->continuation = true;
 		buffer->len = 0;
 
 		++tx_queue->read_count;
 	}
+	netdev_tx_reset_queue(tx_queue->core_txq);
 }
 
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
@@ -1163,6 +1176,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	/* Pass off to hardware */
 	efx_nic_push_buffers(tx_queue);
 
+	netdev_tx_sent_queue(tx_queue->core_txq, 1, skb->len);
+
 	tx_queue->tso_bursts++;
 	return NETDEV_TX_OK;
 
-- 
1.7.3.1
