From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/16] sfc: Add support for reading packet length
 from prefix
Date: Wed, 28 Aug 2013 16:22:08 +0100
Message-ID: <1377703328.2264.36.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17326 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab3H1PWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:22:11 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define a flag for struct efx_rx_buffer and efx_rx_packet() that
indicates packet length must be read from the prefix.  If this
is set, read the length in __efx_rx_packet() (when the prefix
should have arrived in cache).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |  4 ++++
 drivers/net/ethernet/sfc/rx.c         | 12 ++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f52b38c..e85bed0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -263,6 +263,7 @@ struct efx_rx_buffer {
 #define EFX_RX_PKT_CSUMMED	0x0002
 #define EFX_RX_PKT_DISCARD	0x0004
 #define EFX_RX_PKT_TCP		0x0040
+#define EFX_RX_PKT_PREFIX_LEN	0x0080	/* length is in prefix only */
 
 /**
  * struct efx_rx_page_state - Page-based rx buffer state
@@ -668,6 +669,8 @@ struct vfdi_status;
  * @rx_prefix_size: Size of RX prefix before packet data
  * @rx_packet_hash_offset: Offset of RX flow hash from start of packet data
  *	(valid only if @rx_prefix_size != 0; always negative)
+ * @rx_packet_len_offset: Offset of RX packet length from start of packet data
+ *	(valid only for NICs that set %EFX_RX_PKT_PREFIX_LEN; always negative)
  * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
  * @rx_scatter: Scatter mode enabled for receives
@@ -800,6 +803,7 @@ struct efx_nic {
 	unsigned int rx_pages_per_batch;
 	unsigned int rx_prefix_size;
 	int rx_packet_hash_offset;
+	int rx_packet_len_offset;
 	u8 rx_hash_key[40];
 	u32 rx_indir_table[128];
 	bool rx_scatter;
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 7646bb3..864b6ff 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -526,7 +526,8 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 
 	/* Validate the number of fragments and completed length */
 	if (n_frags == 1) {
-		efx_rx_packet__check_len(rx_queue, rx_buf, len);
+		if (!(flags & EFX_RX_PKT_PREFIX_LEN))
+			efx_rx_packet__check_len(rx_queue, rx_buf, len);
 	} else if (unlikely(n_frags > EFX_RX_MAX_FRAGS) ||
 		   unlikely(len <= (n_frags - 1) * EFX_RX_USR_BUF_SIZE) ||
 		   unlikely(len > n_frags * EFX_RX_USR_BUF_SIZE) ||
@@ -554,7 +555,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		return;
 	}
 
-	if (n_frags == 1)
+	if (n_frags == 1 && !(flags & EFX_RX_PKT_PREFIX_LEN))
 		rx_buf->len = len;
 
 	/* Release and/or sync the DMA mapping - assumes all RX buffers
@@ -633,6 +634,13 @@ void __efx_rx_packet(struct efx_channel *channel)
 		efx_rx_buffer(&channel->rx_queue, channel->rx_pkt_index);
 	u8 *eh = efx_rx_buf_va(rx_buf);
 
+	/* Read length from the prefix if necessary.  This already
+	 * excludes the length of the prefix itself.
+	 */
+	if (rx_buf->flags & EFX_RX_PKT_PREFIX_LEN)
+		rx_buf->len = le16_to_cpup((__le16 *)
+					   (eh + efx->rx_packet_len_offset));
+
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
 	 */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
