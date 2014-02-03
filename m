From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 04/13] sfc: Replace TSOH_OFFSET with the equivalent
 NET_IP_ALIGN
Date: Mon, 3 Feb 2014 23:34:05 +0000
Message-ID: <52F0276D.90905@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8166 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412AbaBCXeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:34:08 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined then NET_IP_ALIGN
will be defined as 0, so this macro is redundant.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index c49d1fb..aadeb61 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -785,15 +785,6 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
  * Requires TX checksum offload support.
  */
 
-/* Number of bytes inserted at the start of a TSO header buffer,
- * similar to NET_IP_ALIGN.
- */
-#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-#define TSOH_OFFSET	0
-#else
-#define TSOH_OFFSET	NET_IP_ALIGN
-#endif
-
 #define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
 
 /**
@@ -880,13 +871,13 @@ static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
 	EFX_BUG_ON_PARANOID(buffer->flags);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
 
-	if (likely(len <= TSOH_STD_SIZE - TSOH_OFFSET)) {
+	if (likely(len <= TSOH_STD_SIZE - NET_IP_ALIGN)) {
 		unsigned index =
 			(tx_queue->insert_count & tx_queue->ptr_mask) / 2;
 		struct efx_buffer *page_buf =
 			&tx_queue->tsoh_page[index / TSOH_PER_PAGE];
 		unsigned offset =
-			TSOH_STD_SIZE * (index % TSOH_PER_PAGE) + TSOH_OFFSET;
+			TSOH_STD_SIZE * (index % TSOH_PER_PAGE) + NET_IP_ALIGN;
 
 		if (unlikely(!page_buf->addr) &&
 		    efx_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE,
@@ -899,10 +890,10 @@ static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
 	} else {
 		tx_queue->tso_long_headers++;
 
-		buffer->heap_buf = kmalloc(TSOH_OFFSET + len, GFP_ATOMIC);
+		buffer->heap_buf = kmalloc(NET_IP_ALIGN + len, GFP_ATOMIC);
 		if (unlikely(!buffer->heap_buf))
 			return NULL;
-		result = (u8 *)buffer->heap_buf + TSOH_OFFSET;
+		result = (u8 *)buffer->heap_buf + NET_IP_ALIGN;
 		buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_HEAP;
 	}
 
