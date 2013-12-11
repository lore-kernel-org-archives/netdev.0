From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 6/8] sfc: RX buffer allocation takes prefix size into
 account in IP header alignment
Date: Wed, 11 Dec 2013 01:57:19 +0000
Message-ID: <1386727039.1516.244.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41022 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKB5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:57:23 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

rx_prefix_size is 4-bytes aligned on Falcon/Siena (16 bytes), but it is equal
to 14 on EF10. So, it should be taken into account if arch requires IP header
to be 4-bytes aligned (via NET_IP_ALIGN).

Fixes: 8127d661e77f ('sfc: Add support for Solarflare SFC9100 family')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 4 +++-
 drivers/net/ethernet/sfc/net_driver.h | 3 +++
 drivers/net/ethernet/sfc/rx.c         | 6 +++---
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8bd5b485f1bc..fd844b53e385 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -585,7 +585,7 @@ static void efx_start_datapath(struct efx_nic *efx)
 			   EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
 			   efx->type->rx_buffer_padding);
 	rx_buf_len = (sizeof(struct efx_rx_page_state) +
-		      NET_IP_ALIGN + efx->rx_dma_len);
+		      efx->rx_ip_align + efx->rx_dma_len);
 	if (rx_buf_len <= PAGE_SIZE) {
 		efx->rx_scatter = efx->type->always_rx_scatter;
 		efx->rx_buffer_order = 0;
@@ -2544,6 +2544,8 @@ static int efx_init_struct(struct efx_nic *efx,
 
 	efx->net_dev = net_dev;
 	efx->rx_prefix_size = efx->type->rx_prefix_size;
+	efx->rx_ip_align =
+		NET_IP_ALIGN ? (efx->rx_prefix_size + NET_IP_ALIGN) % 4 : 0;
 	efx->rx_packet_hash_offset =
 		efx->type->rx_hash_offset - efx->type->rx_prefix_size;
 	spin_lock_init(&efx->stats_lock);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index b14a717ac3e8..542a0d252ae0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -683,6 +683,8 @@ struct vfdi_status;
  * @n_channels: Number of channels in use
  * @n_rx_channels: Number of channels used for RX (= number of RX queues)
  * @n_tx_channels: Number of channels used for TX
+ * @rx_ip_align: RX DMA address offset to have IP header aligned in
+ *	in accordance with NET_IP_ALIGN
  * @rx_dma_len: Current maximum RX DMA length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @rx_buffer_truesize: Amortised allocation size of an RX buffer,
@@ -816,6 +818,7 @@ struct efx_nic {
 	unsigned rss_spread;
 	unsigned tx_channel_offset;
 	unsigned n_tx_channels;
+	unsigned int rx_ip_align;
 	unsigned int rx_dma_len;
 	unsigned int rx_buffer_order;
 	unsigned int rx_buffer_truesize;
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8f09e686fc23..42488df1f4ec 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -94,7 +94,7 @@ static inline void efx_sync_rx_buffer(struct efx_nic *efx,
 
 void efx_rx_config_page_split(struct efx_nic *efx)
 {
-	efx->rx_page_buf_step = ALIGN(efx->rx_dma_len + NET_IP_ALIGN,
+	efx->rx_page_buf_step = ALIGN(efx->rx_dma_len + efx->rx_ip_align,
 				      EFX_RX_BUF_ALIGNMENT);
 	efx->rx_bufs_per_page = efx->rx_buffer_order ? 1 :
 		((PAGE_SIZE - sizeof(struct efx_rx_page_state)) /
@@ -189,9 +189,9 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 		do {
 			index = rx_queue->added_count & rx_queue->ptr_mask;
 			rx_buf = efx_rx_buffer(rx_queue, index);
-			rx_buf->dma_addr = dma_addr + NET_IP_ALIGN;
+			rx_buf->dma_addr = dma_addr + efx->rx_ip_align;
 			rx_buf->page = page;
-			rx_buf->page_offset = page_offset + NET_IP_ALIGN;
+			rx_buf->page_offset = page_offset + efx->rx_ip_align;
 			rx_buf->len = efx->rx_dma_len;
 			rx_buf->flags = 0;
 			++rx_queue->added_count;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
