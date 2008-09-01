From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/52] sfc: Reduce the size of struct efx_tx_buffer
Date: Mon, 1 Sep 2008 12:46:43 +0100
Message-ID: <20080901114643.GJ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34622 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755964AbYIALqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:45 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unmap_addr since it can be calculated from dma_addr, len and
unmap_len.  This saves 4-16 bytes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 drivers/net/sfc/tx.c         |   20 +++++++++++---------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index f539e2e..6369f92 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -130,7 +130,6 @@ struct efx_special_buffer {
  *	This field is zero when the queue slot is empty.
  * @continuation: True if this fragment is not the end of a packet.
  * @unmap_single: True if pci_unmap_single should be used.
- * @unmap_addr: DMA address to unmap
  * @unmap_len: Length of this fragment to unmap
  */
 struct efx_tx_buffer {
@@ -140,7 +139,6 @@ struct efx_tx_buffer {
 	unsigned short len;
 	unsigned char continuation;
 	unsigned char unmap_single;
-	dma_addr_t unmap_addr;
 	unsigned short unmap_len;
 };
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 1112775..5f01371 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -64,12 +64,14 @@ static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 {
 	if (buffer->unmap_len) {
 		struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+		dma_addr_t unmap_addr = (buffer->dma_addr + buffer->len -
+					 buffer->unmap_len);
 		if (buffer->unmap_single)
-			pci_unmap_single(pci_dev, buffer->unmap_addr,
-					 buffer->unmap_len, PCI_DMA_TODEVICE);
+			pci_unmap_single(pci_dev, unmap_addr, buffer->unmap_len,
+					 PCI_DMA_TODEVICE);
 		else
-			pci_unmap_page(pci_dev, buffer->unmap_addr,
-				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			pci_unmap_page(pci_dev, unmap_addr, buffer->unmap_len,
+				       PCI_DMA_TODEVICE);
 		buffer->unmap_len = 0;
 		buffer->unmap_single = 0;
 	}
@@ -233,7 +235,6 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 		} while (len);
 
 		/* Transfer ownership of the unmapping to the final buffer */
-		buffer->unmap_addr = unmap_addr;
 		buffer->unmap_single = unmap_single;
 		buffer->unmap_len = unmap_len;
 		unmap_len = 0;
@@ -805,6 +806,7 @@ static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
 static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 {
 	struct efx_tx_buffer *buffer;
+	dma_addr_t unmap_addr;
 
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count != tx_queue->write_count) {
@@ -816,15 +818,15 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 		buffer->len = 0;
 		buffer->continuation = 1;
 		if (buffer->unmap_len) {
+			unmap_addr = (buffer->dma_addr + buffer->len -
+				      buffer->unmap_len);
 			if (buffer->unmap_single)
 				pci_unmap_single(tx_queue->efx->pci_dev,
-						 buffer->unmap_addr,
-						 buffer->unmap_len,
+						 unmap_addr, buffer->unmap_len,
 						 PCI_DMA_TODEVICE);
 			else
 				pci_unmap_page(tx_queue->efx->pci_dev,
-					       buffer->unmap_addr,
-					       buffer->unmap_len,
+					       unmap_addr, buffer->unmap_len,
 					       PCI_DMA_TODEVICE);
 			buffer->unmap_len = 0;
 		}
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

