From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net 1/2] sfc: Delete EFX_PAGE_IP_ALIGN, equivalent to
 NET_IP_ALIGN
Date: Mon, 13 May 2013 22:58:31 +0100
Message-ID: <1368482311.3305.48.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	<linux-s390@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The two architectures that define CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
(powerpc and x86) now both define NET_IP_ALIGN as 0, so there is no
need for this optimisation any more.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    4 ++--
 drivers/net/ethernet/sfc/net_driver.h |   15 +--------------
 drivers/net/ethernet/sfc/rx.c         |    6 +++---
 3 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 01b9920..999289b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -638,13 +638,13 @@ static void efx_start_datapath(struct efx_nic *efx)
 			   EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
 			   efx->type->rx_buffer_padding);
 	rx_buf_len = (sizeof(struct efx_rx_page_state) +
-		      EFX_PAGE_IP_ALIGN + efx->rx_dma_len);
+		      NET_IP_ALIGN + efx->rx_dma_len);
 	if (rx_buf_len <= PAGE_SIZE) {
 		efx->rx_scatter = false;
 		efx->rx_buffer_order = 0;
 	} else if (efx->type->can_rx_scatter) {
 		BUILD_BUG_ON(sizeof(struct efx_rx_page_state) +
-			     EFX_PAGE_IP_ALIGN + EFX_RX_USR_BUF_SIZE >
+			     NET_IP_ALIGN + EFX_RX_USR_BUF_SIZE >
 			     PAGE_SIZE / 2);
 		efx->rx_scatter = true;
 		efx->rx_dma_len = EFX_RX_USR_BUF_SIZE;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9bd433a..5efddf3 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -468,24 +468,11 @@ enum nic_state {
 };
 
 /*
- * Alignment of page-allocated RX buffers
- *
- * Controls the number of bytes inserted at the start of an RX buffer.
- * This is the equivalent of NET_IP_ALIGN [which controls the alignment
- * of the skb->head for hardware DMA].
- */
-#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-#define EFX_PAGE_IP_ALIGN 0
-#else
-#define EFX_PAGE_IP_ALIGN NET_IP_ALIGN
-#endif
-
-/*
  * Alignment of the skb->head which wraps a page-allocated RX buffer
  *
  * The skb allocated to wrap an rx_buffer can have this alignment. Since
  * the data is memcpy'd from the rx_buf, it does not need to be equal to
- * EFX_PAGE_IP_ALIGN.
+ * NET_IP_ALIGN.
  */
 #define EFX_PAGE_SKB_ALIGN 2
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index e73e30b..99f70dd 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -93,7 +93,7 @@ static inline void efx_sync_rx_buffer(struct efx_nic *efx,
 
 void efx_rx_config_page_split(struct efx_nic *efx)
 {
-	efx->rx_page_buf_step = ALIGN(efx->rx_dma_len + EFX_PAGE_IP_ALIGN,
+	efx->rx_page_buf_step = ALIGN(efx->rx_dma_len + NET_IP_ALIGN,
 				      L1_CACHE_BYTES);
 	efx->rx_bufs_per_page = efx->rx_buffer_order ? 1 :
 		((PAGE_SIZE - sizeof(struct efx_rx_page_state)) /
@@ -188,9 +188,9 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 		do {
 			index = rx_queue->added_count & rx_queue->ptr_mask;
 			rx_buf = efx_rx_buffer(rx_queue, index);
-			rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
+			rx_buf->dma_addr = dma_addr + NET_IP_ALIGN;
 			rx_buf->page = page;
-			rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
+			rx_buf->page_offset = page_offset + NET_IP_ALIGN;
 			rx_buf->len = efx->rx_dma_len;
 			rx_buf->flags = 0;
 			++rx_queue->added_count;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
