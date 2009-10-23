From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/27] sfc: Move all TX DMA length limiting into tx.c
Date: Fri, 23 Oct 2009 19:31:20 +0100
Message-ID: <1256322680.2785.27.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8749 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbZJWSbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:18 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the duplicated logic in efx_enqueue_skb() and
efx_tx_queue_insert() with an inline function, efx_max_tx_len().

Remove the failed attempt at abstracting hardware-specifics and put
all the magic numbers in efx_max_tx_len().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |    7 -------
 drivers/net/sfc/net_driver.h  |    4 ----
 drivers/net/sfc/tx.c          |   37 +++++++++++++++++++++++--------------
 drivers/net/sfc/workarounds.h |    2 ++
 4 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 47507b6..34b475e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -127,9 +127,6 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
  **************************************************************************
  */
 
-/* TX DMA length mask (13-bit) */
-#define FALCON_TX_DMA_MASK (4096 - 1)
-
 /* Size and alignment of special buffers (4KB) */
 #define FALCON_BUF_SIZE 4096
 
@@ -3146,8 +3143,6 @@ struct efx_nic_type falcon_a_nic_type = {
 	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
 	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
 	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
-	.tx_dma_mask = FALCON_TX_DMA_MASK,
-	.bug5391_mask = 0xf,
 	.rx_buffer_padding = 0x24,
 	.max_interrupt_mode = EFX_INT_MODE_MSI,
 	.phys_addr_channels = 4,
@@ -3167,8 +3162,6 @@ struct efx_nic_type falcon_b_nic_type = {
 	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
 	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
 	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
-	.tx_dma_mask = FALCON_TX_DMA_MASK,
-	.bug5391_mask = 0,
 	.rx_buffer_padding = 0,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 3afadc6..91d8952 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -870,8 +870,6 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @evq_ptr_tbl_base: Event queue pointer table base address
  * @evq_rptr_tbl_base: Event queue read-pointer table base address
  * @max_dma_mask: Maximum possible DMA mask
- * @tx_dma_mask: TX DMA mask
- * @bug5391_mask: Address mask for bug 5391 workaround
  * @rx_buffer_padding: Padding added to each RX buffer
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
@@ -888,8 +886,6 @@ struct efx_nic_type {
 	unsigned int evq_rptr_tbl_base;
 
 	u64 max_dma_mask;
-	unsigned int tx_dma_mask;
-	unsigned bug5391_mask;
 
 	unsigned int rx_buffer_padding;
 	unsigned int max_interrupt_mode;
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index ae554ee..303919a 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -124,6 +124,24 @@ static void efx_tsoh_free(struct efx_tx_queue *tx_queue,
 }
 

+static inline unsigned
+efx_max_tx_len(struct efx_nic *efx, dma_addr_t dma_addr)
+{
+	/* Depending on the NIC revision, we can use descriptor
+	 * lengths up to 8K or 8K-1.  However, since PCI Express
+	 * devices must split read requests at 4K boundaries, there is
+	 * little benefit from using descriptors that cross those
+	 * boundaries and we keep things simple by not doing so.
+	 */
+	unsigned len = (~dma_addr & 0xfff) + 1;
+
+	/* Work around hardware bug for unaligned buffers. */
+	if (EFX_WORKAROUND_5391(efx) && (dma_addr & 0xf))
+		len = min_t(unsigned, len, 512 - (dma_addr & 0xf));
+
+	return len;
+}
+
 /*
  * Add a socket buffer to a TX queue
  *
@@ -146,7 +164,7 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	skb_frag_t *fragment;
 	struct page *page;
 	int page_offset;
-	unsigned int len, unmap_len = 0, fill_level, insert_ptr, misalign;
+	unsigned int len, unmap_len = 0, fill_level, insert_ptr;
 	dma_addr_t dma_addr, unmap_addr = 0;
 	unsigned int dma_len;
 	bool unmap_single;
@@ -223,14 +241,10 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 			EFX_BUG_ON_PARANOID(!buffer->continuation);
 			EFX_BUG_ON_PARANOID(buffer->unmap_len);
 
-			dma_len = (((~dma_addr) & efx->type->tx_dma_mask) + 1);
-			if (likely(dma_len > len))
+			dma_len = efx_max_tx_len(efx, dma_addr);
+			if (likely(dma_len >= len))
 				dma_len = len;
 
-			misalign = (unsigned)dma_addr & efx->type->bug5391_mask;
-			if (misalign && dma_len + misalign > 512)
-				dma_len = 512 - misalign;
-
 			/* Fill out per descriptor fields */
 			buffer->len = dma_len;
 			buffer->dma_addr = dma_addr;
@@ -703,7 +717,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 {
 	struct efx_tx_buffer *buffer;
 	struct efx_nic *efx = tx_queue->efx;
-	unsigned dma_len, fill_level, insert_ptr, misalign;
+	unsigned dma_len, fill_level, insert_ptr;
 	int q_space;
 
 	EFX_BUG_ON_PARANOID(len <= 0);
@@ -752,12 +766,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 
 		buffer->dma_addr = dma_addr;
 
-		/* Ensure we do not cross a boundary unsupported by H/W */
-		dma_len = (~dma_addr & efx->type->tx_dma_mask) + 1;
-
-		misalign = (unsigned)dma_addr & efx->type->bug5391_mask;
-		if (misalign && dma_len + misalign > 512)
-			dma_len = 512 - misalign;
+		dma_len = efx_max_tx_len(efx, dma_addr);
 
 		/* If there is enough space to send then do so */
 		if (dma_len >= len)
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index c821c15..3250299 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -41,6 +41,8 @@
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A
+/* Unaligned read request >512 bytes after aligning may break TSORT */
+#define EFX_WORKAROUND_5391 EFX_WORKAROUND_FALCON_A
 /* iSCSI parsing errors */
 #define EFX_WORKAROUND_5583 EFX_WORKAROUND_FALCON_A
 /* RX events go missing */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

