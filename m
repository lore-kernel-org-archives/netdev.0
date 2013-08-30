From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] sfc: Extend struct efx_tx_buffer to allow
 pushing option descriptors
Date: Fri, 30 Aug 2013 04:42:11 +0100
Message-ID: <1377834131.2552.37.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35042 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab3H3DmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:42:15 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX path firmware for EF10 supports 'option descriptors' to control
offloads and various other features.  Add a flag and field for these
in struct efx_tx_buffer, and don't treat them as DMA descriptors on
completion.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/farch.c      |    2 ++
 drivers/net/ethernet/sfc/net_driver.h |    7 ++++++-
 drivers/net/ethernet/sfc/tx.c         |    4 +++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 842f92e..65073aa 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -325,6 +325,8 @@ void efx_farch_tx_write(struct efx_tx_queue *tx_queue)
 		txd = efx_tx_desc(tx_queue, write_ptr);
 		++tx_queue->write_count;
 
+		EFX_BUG_ON_PARANOID(buffer->flags & EFX_TX_BUF_OPTION);
+
 		/* Create TX descriptor ring entry */
 		BUILD_BUG_ON(EFX_TX_BUF_CONT != 1);
 		EFX_POPULATE_QWORD_4(*txd,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c9b6f2d..d1aa5dc 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -135,6 +135,7 @@ struct efx_special_buffer {
  *	freed when descriptor completes
  * @heap_buf: When @flags & %EFX_TX_BUF_HEAP, the associated heap buffer to be
  *	freed when descriptor completes.
+ * @option: When @flags & %EFX_TX_BUF_OPTION, a NIC-specific option descriptor.
  * @dma_addr: DMA address of the fragment.
  * @flags: Flags for allocation and DMA mapping type
  * @len: Length of this fragment.
@@ -146,7 +147,10 @@ struct efx_tx_buffer {
 		const struct sk_buff *skb;
 		void *heap_buf;
 	};
-	dma_addr_t dma_addr;
+	union {
+		efx_qword_t option;
+		dma_addr_t dma_addr;
+	};
 	unsigned short flags;
 	unsigned short len;
 	unsigned short unmap_len;
@@ -155,6 +159,7 @@ struct efx_tx_buffer {
 #define EFX_TX_BUF_SKB		2	/* buffer is last part of skb */
 #define EFX_TX_BUF_HEAP		4	/* buffer was allocated with kmalloc() */
 #define EFX_TX_BUF_MAP_SINGLE	8	/* buffer was mapped with dma_map_single() */
+#define EFX_TX_BUF_OPTION	0x10	/* empty buffer for option descriptor */
 
 /**
  * struct efx_tx_queue - An Efx TX queue
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 85ee647..82075f9 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -306,7 +306,9 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 
 	while (read_ptr != stop_index) {
 		struct efx_tx_buffer *buffer = &tx_queue->buffer[read_ptr];
-		if (unlikely(buffer->len == 0)) {
+
+		if (!(buffer->flags & EFX_TX_BUF_OPTION) &&
+		    unlikely(buffer->len == 0)) {
 			netif_err(efx, tx_err, efx->net_dev,
 				  "TX queue %d spurious TX completion id %x\n",
 				  tx_queue->queue, read_ptr);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
