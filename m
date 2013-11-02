From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] sfc: Fix DMA unmapping issue with firmware
 assisted TSO
Date: Sat, 2 Nov 2013 01:38:57 +0000
Message-ID: <1383356337.1737.43.camel@bwh-desktop.uk.level5networks.com>
References: <1383356266.1737.42.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60215 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341Ab3KBBjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 21:39:01 -0400
In-Reply-To: <1383356266.1737.42.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

When using firmware assisted TSO, we use a single DMA mapping for
the linear area of a TSO skb.

We still have to segment the super-packet and insert a descriptor
containing the original headers before each segment of payload, so we
can unmap the linear area only after the last segment is completed.
The unmapping information for the linear area is therefore associated
with the last header descriptor.

We calculate the DMA address to unmap from using the map length and
the invariant that the end of the DMA mapping matches the end of
the data referenced by the last descriptor.  But this invariant is
broken when there is TCP payload in the linear area.

Fix this by adding and using an explicit dma_offset field.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 3 +++
 drivers/net/ethernet/sfc/tx.c         | 7 +++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index aac22a1..b14a717 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -141,6 +141,8 @@ struct efx_special_buffer {
  * @len: Length of this fragment.
  *	This field is zero when the queue slot is empty.
  * @unmap_len: Length of this fragment to unmap
+ * @dma_offset: Offset of @dma_addr from the address of the backing DMA mapping.
+ * Only valid if @unmap_len != 0.
  */
 struct efx_tx_buffer {
 	union {
@@ -154,6 +156,7 @@ struct efx_tx_buffer {
 	unsigned short flags;
 	unsigned short len;
 	unsigned short unmap_len;
+	unsigned short dma_offset;
 };
 #define EFX_TX_BUF_CONT		1	/* not last descriptor of packet */
 #define EFX_TX_BUF_SKB		2	/* buffer is last part of skb */
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 282692c..c49d1fb 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -65,8 +65,7 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 {
 	if (buffer->unmap_len) {
 		struct device *dma_dev = &tx_queue->efx->pci_dev->dev;
-		dma_addr_t unmap_addr = (buffer->dma_addr + buffer->len -
-					 buffer->unmap_len);
+		dma_addr_t unmap_addr = buffer->dma_addr - buffer->dma_offset;
 		if (buffer->flags & EFX_TX_BUF_MAP_SINGLE)
 			dma_unmap_single(dma_dev, unmap_addr, buffer->unmap_len,
 					 DMA_TO_DEVICE);
@@ -414,6 +413,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		/* Transfer ownership of the unmapping to the final buffer */
 		buffer->flags = EFX_TX_BUF_CONT | dma_flags;
 		buffer->unmap_len = unmap_len;
+		buffer->dma_offset = buffer->dma_addr - unmap_addr;
 		unmap_len = 0;
 
 		/* Get address and size of next fragment */
@@ -980,6 +980,7 @@ static int efx_tso_put_header(struct efx_tx_queue *tx_queue,
 			return -ENOMEM;
 		}
 		buffer->unmap_len = buffer->len;
+		buffer->dma_offset = 0;
 		buffer->flags |= EFX_TX_BUF_MAP_SINGLE;
 	}
 
@@ -1121,6 +1122,7 @@ static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 	if (st->in_len == 0) {
 		/* Transfer ownership of the DMA mapping */
 		buffer->unmap_len = st->unmap_len;
+		buffer->dma_offset = buffer->unmap_len - buffer->len;
 		buffer->flags |= st->dma_flags;
 		st->unmap_len = 0;
 	}
@@ -1219,6 +1221,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		if (is_last) {
 			buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_MAP_SINGLE;
 			buffer->unmap_len = st->header_unmap_len;
+			buffer->dma_offset = 0;
 			/* Ensure we only unmap them once in case of a
 			 * later DMA mapping error and rollback
 			 */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
