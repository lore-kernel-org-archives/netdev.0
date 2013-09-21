From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/11] sfc: Introduce inline functions to simplify
 TX insertion
Date: Sat, 21 Sep 2013 19:35:34 +0100
Message-ID: <1379788534.1681.42.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32627 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab3IUSfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:35:37 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c | 53 +++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 8754347..6cecda3 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -33,6 +33,31 @@ unsigned int efx_piobuf_size __read_mostly = EFX_PIOBUF_SIZE_DEF;
 
 #endif /* EFX_USE_PIO */
 
+static inline unsigned int
+efx_tx_queue_get_insert_index(const struct efx_tx_queue *tx_queue)
+{
+	return tx_queue->insert_count & tx_queue->ptr_mask;
+}
+
+static inline struct efx_tx_buffer *
+__efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
+{
+	return &tx_queue->buffer[efx_tx_queue_get_insert_index(tx_queue)];
+}
+
+static inline struct efx_tx_buffer *
+efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
+{
+	struct efx_tx_buffer *buffer =
+		__efx_tx_queue_get_insert_buffer(tx_queue);
+
+	EFX_BUG_ON_PARANOID(buffer->len);
+	EFX_BUG_ON_PARANOID(buffer->flags);
+	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+
+	return buffer;
+}
+
 static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 			       struct efx_tx_buffer *buffer,
 			       unsigned int *pkts_compl,
@@ -180,7 +205,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	struct device *dma_dev = &efx->pci_dev->dev;
 	struct efx_tx_buffer *buffer;
 	skb_frag_t *fragment;
-	unsigned int len, unmap_len = 0, insert_ptr;
+	unsigned int len, unmap_len = 0;
 	dma_addr_t dma_addr, unmap_addr = 0;
 	unsigned int dma_len;
 	unsigned short dma_flags;
@@ -221,11 +246,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 
 		/* Add to TX queue, splitting across DMA boundaries */
 		do {
-			insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
-			buffer = &tx_queue->buffer[insert_ptr];
-			EFX_BUG_ON_PARANOID(buffer->flags);
-			EFX_BUG_ON_PARANOID(buffer->len);
-			EFX_BUG_ON_PARANOID(buffer->unmap_len);
+			buffer = efx_tx_queue_get_insert_buffer(tx_queue);
 
 			dma_len = efx_max_tx_len(efx, dma_addr);
 			if (likely(dma_len >= len))
@@ -283,8 +304,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		unsigned int pkts_compl = 0, bytes_compl = 0;
 		--tx_queue->insert_count;
-		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
-		buffer = &tx_queue->buffer[insert_ptr];
+		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
 		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
 	}
 
@@ -755,23 +775,18 @@ static void efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 {
 	struct efx_tx_buffer *buffer;
 	struct efx_nic *efx = tx_queue->efx;
-	unsigned dma_len, insert_ptr;
+	unsigned dma_len;
 
 	EFX_BUG_ON_PARANOID(len <= 0);
 
 	while (1) {
-		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
-		buffer = &tx_queue->buffer[insert_ptr];
+		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
 		++tx_queue->insert_count;
 
 		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
 				    tx_queue->read_count >=
 				    efx->txq_entries);
 
-		EFX_BUG_ON_PARANOID(buffer->len);
-		EFX_BUG_ON_PARANOID(buffer->unmap_len);
-		EFX_BUG_ON_PARANOID(buffer->flags);
-
 		buffer->dma_addr = dma_addr;
 
 		dma_len = efx_max_tx_len(efx, dma_addr);
@@ -832,8 +847,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		--tx_queue->insert_count;
-		buffer = &tx_queue->buffer[tx_queue->insert_count &
-					   tx_queue->ptr_mask];
+		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
 		efx_dequeue_buffer(tx_queue, buffer, NULL, NULL);
 	}
 }
@@ -978,7 +992,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 				struct tso_state *st)
 {
 	struct efx_tx_buffer *buffer =
-		&tx_queue->buffer[tx_queue->insert_count & tx_queue->ptr_mask];
+		efx_tx_queue_get_insert_buffer(tx_queue);
 	bool is_last = st->out_len <= skb_shinfo(skb)->gso_size;
 	u8 tcp_flags_clear;
 
@@ -1048,8 +1062,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		/* We mapped the headers in tso_start().  Unmap them
 		 * when the last segment is completed.
 		 */
-		buffer = &tx_queue->buffer[tx_queue->insert_count &
-					   tx_queue->ptr_mask];
+		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
 		buffer->dma_addr = st->header_dma_addr;
 		buffer->len = st->header_len;
 		if (is_last) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
