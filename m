From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH RFC net-next] sfc: add support for skb->xmit_more
Date: Tue, 14 Oct 2014 19:41:37 +0100
Message-ID: <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com> <543C13AE.80606@solarflare.com> <543C2588.6060604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Edward Cree <ecree@solarflare.com>, <davem@davemloft.net>,
	<nikolay@redhat.com>, <netdev@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>,
	Jon Cooper <jcooper@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:1582 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754166AbaJNSlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:41:51 -0400
In-Reply-To: <543C2588.6060604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't ring the doorbell, and don't do PIO.  This will also prevent
 TX Push, because there will be more than one buffer waiting when
 the doorbell is rung.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---

 drivers/net/ethernet/sfc/nic.h | 29 +++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/tx.c  | 43 +++++++++++++++++-------------------------
 2 files changed, 41 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 60f8514..f77cce0 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -71,9 +71,17 @@ efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 	return ((efx_qword_t *) (tx_queue->txd.buf.addr)) + index;
 }
 
-/* Report whether the NIC considers this TX queue empty, given the
- * write_count used for the last doorbell push.  May return false
- * negative.
+/* Get partner of a TX queue, seen as part of the same net core queue */
+static struct efx_tx_queue *efx_tx_queue_partner(struct efx_tx_queue *tx_queue)
+{
+	if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD)
+		return tx_queue - EFX_TXQ_TYPE_OFFLOAD;
+	else
+		return tx_queue + EFX_TXQ_TYPE_OFFLOAD;
+}
+
+/* Report whether this TX queue would be empty for the given write_count.
+ * May return false negative.
  */
 static inline bool __efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue,
 					 unsigned int write_count)
@@ -86,9 +94,18 @@ static inline bool __efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue,
 	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
 }
 
-static inline bool efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue)
+/* Decide whether we can use TX PIO, ie. write packet data directly into
+ * a buffer on the device.  This can reduce latency at the expense of
+ * throughput, so we only do this if both hardware and software TX rings
+ * are empty.  This also ensures that only one packet at a time can be
+ * using the PIO buffer.
+ */
+static inline bool efx_nic_may_tx_pio(struct efx_tx_queue *tx_queue)
 {
-	return __efx_nic_tx_is_empty(tx_queue, tx_queue->write_count);
+	struct efx_tx_queue *partner = efx_tx_queue_partner(tx_queue);
+	return tx_queue->piobuf &&
+	       __efx_nic_tx_is_empty(tx_queue, tx_queue->insert_count) &&
+	       __efx_nic_tx_is_empty(partner, partner->insert_count);
 }
 
 /* Decide whether to push a TX descriptor to the NIC vs merely writing
@@ -96,6 +113,8 @@ static inline bool efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue)
  * descriptor to an empty queue, but is otherwise pointless.  Further,
  * Falcon and Siena have hardware bugs (SF bug 33851) that may be
  * triggered if we don't check this.
+ * We use the write_count used for the last doorbell push, to get the
+ * NIC's view of the tx queue.
  */
 static inline bool efx_nic_may_push_tx_desc(struct efx_tx_queue *tx_queue,
 					    unsigned int write_count)
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3206098..aaf2987 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -132,15 +132,6 @@ unsigned int efx_tx_max_skb_descs(struct efx_nic *efx)
 	return max_descs;
 }
 
-/* Get partner of a TX queue, seen as part of the same net core queue */
-static struct efx_tx_queue *efx_tx_queue_partner(struct efx_tx_queue *tx_queue)
-{
-	if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD)
-		return tx_queue - EFX_TXQ_TYPE_OFFLOAD;
-	else
-		return tx_queue + EFX_TXQ_TYPE_OFFLOAD;
-}
-
 static void efx_tx_maybe_stop_queue(struct efx_tx_queue *txq1)
 {
 	/* We need to consider both queues that the net core sees as one */
@@ -344,6 +335,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	struct efx_nic *efx = tx_queue->efx;
 	struct device *dma_dev = &efx->pci_dev->dev;
 	struct efx_tx_buffer *buffer;
+	unsigned int old_insert_count = tx_queue->insert_count;
 	skb_frag_t *fragment;
 	unsigned int len, unmap_len = 0;
 	dma_addr_t dma_addr, unmap_addr = 0;
@@ -351,8 +343,6 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	unsigned short dma_flags;
 	int i = 0;
 
-	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
-
 	if (skb_shinfo(skb)->gso_size)
 		return efx_enqueue_skb_tso(tx_queue, skb);
 
@@ -369,9 +359,8 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 
 	/* Consider using PIO for short packets */
 #ifdef EFX_USE_PIO
-	if (skb->len <= efx_piobuf_size && tx_queue->piobuf &&
-	    efx_nic_tx_is_empty(tx_queue) &&
-	    efx_nic_tx_is_empty(efx_tx_queue_partner(tx_queue))) {
+	if (skb->len <= efx_piobuf_size && !skb->xmit_more &&
+	    efx_nic_may_tx_pio(tx_queue)) {
 		buffer = efx_enqueue_skb_pio(tx_queue, skb);
 		dma_flags = EFX_TX_BUF_OPTION;
 		goto finish_packet;
@@ -439,13 +428,14 @@ finish_packet:
 
 	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
 
+	efx_tx_maybe_stop_queue(tx_queue);
+
 	/* Pass off to hardware */
-	efx_nic_push_buffers(tx_queue);
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
+		efx_nic_push_buffers(tx_queue);
 
 	tx_queue->tx_packets++;
 
-	efx_tx_maybe_stop_queue(tx_queue);
-
 	return NETDEV_TX_OK;
 
  dma_err:
@@ -458,7 +448,7 @@ finish_packet:
 	dev_kfree_skb_any(skb);
 
 	/* Work backwards until we hit the original insert pointer value */
-	while (tx_queue->insert_count != tx_queue->write_count) {
+	while (tx_queue->insert_count != old_insert_count) {
 		unsigned int pkts_compl = 0, bytes_compl = 0;
 		--tx_queue->insert_count;
 		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
@@ -989,12 +979,13 @@ static int efx_tso_put_header(struct efx_tx_queue *tx_queue,
 /* Remove buffers put into a tx_queue.  None of the buffers must have
  * an skb attached.
  */
-static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
+static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue,
+			       unsigned int insert_count)
 {
 	struct efx_tx_buffer *buffer;
 
 	/* Work backwards until we hit the original insert pointer value */
-	while (tx_queue->insert_count != tx_queue->write_count) {
+	while (tx_queue->insert_count != insert_count) {
 		--tx_queue->insert_count;
 		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
 		efx_dequeue_buffer(tx_queue, buffer, NULL, NULL);
@@ -1258,14 +1249,13 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			       struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
+	unsigned int old_insert_count = tx_queue->insert_count;
 	int frag_i, rc;
 	struct tso_state state;
 
 	/* Find the packet protocol and sanity-check it */
 	state.protocol = efx_tso_check_protocol(skb);
 
-	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
-
 	rc = tso_start(&state, efx, skb);
 	if (rc)
 		goto mem_err;
@@ -1308,11 +1298,12 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
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
 
@@ -1336,6 +1327,6 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 		dma_unmap_single(&efx->pci_dev->dev, state.header_dma_addr,
 				 state.header_unmap_len, DMA_TO_DEVICE);
 
-	efx_enqueue_unwind(tx_queue);
+	efx_enqueue_unwind(tx_queue, old_insert_count);
 	return NETDEV_TX_OK;
 }
-- 
1.7.11.7
