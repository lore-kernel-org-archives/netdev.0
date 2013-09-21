From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/11] sfc: Use TX PIO for sufficiently small
 packets
Date: Sat, 21 Sep 2013 19:35:56 +0100
Message-ID: <1379788556.1681.43.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32635 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3IUSf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:35:59 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Sufficiently small linear packets can be copied into the PIO buffer
with a single call to memcpy_toio().  Non-linear packets require an
intermediate cache-line-sized buffer.

[bwh: I wrote the first version of this, but Jon did the hard work to
 handle non-linear packets.]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_regs.h  |   1 +
 drivers/net/ethernet/sfc/ethtool.c    |   1 +
 drivers/net/ethernet/sfc/net_driver.h |   2 +
 drivers/net/ethernet/sfc/tx.c         | 151 ++++++++++++++++++++++++++++++++++
 4 files changed, 155 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10_regs.h b/drivers/net/ethernet/sfc/ef10_regs.h
index b3f4e37..207ac9a 100644
--- a/drivers/net/ethernet/sfc/ef10_regs.h
+++ b/drivers/net/ethernet/sfc/ef10_regs.h
@@ -315,6 +315,7 @@
 #define	ESF_DZ_TX_PIO_TYPE_WIDTH 1
 #define	ESF_DZ_TX_PIO_OPT_LBN 60
 #define	ESF_DZ_TX_PIO_OPT_WIDTH 3
+#define	ESE_DZ_TX_OPTION_DESC_PIO 1
 #define	ESF_DZ_TX_PIO_CONT_LBN 59
 #define	ESF_DZ_TX_PIO_CONT_WIDTH 1
 #define	ESF_DZ_TX_PIO_BYTE_CNT_LBN 32
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index c8dc407..1f529fa 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -70,6 +70,7 @@ static const struct efx_sw_stat_desc efx_sw_stat_desc[] = {
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_long_headers),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
 	EFX_ETHTOOL_UINT_TXQ_STAT(pushes),
+	EFX_ETHTOOL_UINT_TXQ_STAT(pio_packets),
 	EFX_ETHTOOL_ATOMIC_NIC_ERROR_STAT(rx_reset),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 6febecc..aac22a1 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -212,6 +212,7 @@ struct efx_tx_buffer {
  *	blocks
  * @tso_packets: Number of packets via the TSO xmit path
  * @pushes: Number of times the TX push feature has been used
+ * @pio_packets: Number of times the TX PIO feature has been used
  * @empty_read_count: If the completion path has seen the queue as empty
  *	and the transmission path has not yet checked this, the value of
  *	@read_count bitwise-added to %EFX_EMPTY_COUNT_VALID; otherwise 0.
@@ -243,6 +244,7 @@ struct efx_tx_queue {
 	unsigned int tso_long_headers;
 	unsigned int tso_packets;
 	unsigned int pushes;
+	unsigned int pio_packets;
 
 	/* Members shared between paths and sometimes updated */
 	unsigned int empty_read_count ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 6cecda3..282692c 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -183,6 +183,145 @@ static void efx_tx_maybe_stop_queue(struct efx_tx_queue *txq1)
 	}
 }
 
+#ifdef EFX_USE_PIO
+
+struct efx_short_copy_buffer {
+	int used;
+	u8 buf[L1_CACHE_BYTES];
+};
+
+/* Copy to PIO, respecting that writes to PIO buffers must be dword aligned.
+ * Advances piobuf pointer. Leaves additional data in the copy buffer.
+ */
+static void efx_memcpy_toio_aligned(struct efx_nic *efx, u8 __iomem **piobuf,
+				    u8 *data, int len,
+				    struct efx_short_copy_buffer *copy_buf)
+{
+	int block_len = len & ~(sizeof(copy_buf->buf) - 1);
+
+	memcpy_toio(*piobuf, data, block_len);
+	*piobuf += block_len;
+	len -= block_len;
+
+	if (len) {
+		data += block_len;
+		BUG_ON(copy_buf->used);
+		BUG_ON(len > sizeof(copy_buf->buf));
+		memcpy(copy_buf->buf, data, len);
+		copy_buf->used = len;
+	}
+}
+
+/* Copy to PIO, respecting dword alignment, popping data from copy buffer first.
+ * Advances piobuf pointer. Leaves additional data in the copy buffer.
+ */
+static void efx_memcpy_toio_aligned_cb(struct efx_nic *efx, u8 __iomem **piobuf,
+				       u8 *data, int len,
+				       struct efx_short_copy_buffer *copy_buf)
+{
+	if (copy_buf->used) {
+		/* if the copy buffer is partially full, fill it up and write */
+		int copy_to_buf =
+			min_t(int, sizeof(copy_buf->buf) - copy_buf->used, len);
+
+		memcpy(copy_buf->buf + copy_buf->used, data, copy_to_buf);
+		copy_buf->used += copy_to_buf;
+
+		/* if we didn't fill it up then we're done for now */
+		if (copy_buf->used < sizeof(copy_buf->buf))
+			return;
+
+		memcpy_toio(*piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+		*piobuf += sizeof(copy_buf->buf);
+		data += copy_to_buf;
+		len -= copy_to_buf;
+		copy_buf->used = 0;
+	}
+
+	efx_memcpy_toio_aligned(efx, piobuf, data, len, copy_buf);
+}
+
+static void efx_flush_copy_buffer(struct efx_nic *efx, u8 __iomem *piobuf,
+				  struct efx_short_copy_buffer *copy_buf)
+{
+	/* if there's anything in it, write the whole buffer, including junk */
+	if (copy_buf->used)
+		memcpy_toio(piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+}
+
+/* Traverse skb structure and copy fragments in to PIO buffer.
+ * Advances piobuf pointer.
+ */
+static void efx_skb_copy_bits_to_pio(struct efx_nic *efx, struct sk_buff *skb,
+				     u8 __iomem **piobuf,
+				     struct efx_short_copy_buffer *copy_buf)
+{
+	int i;
+
+	efx_memcpy_toio_aligned(efx, piobuf, skb->data, skb_headlen(skb),
+				copy_buf);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		u8 *vaddr;
+
+		vaddr = kmap_atomic(skb_frag_page(f));
+
+		efx_memcpy_toio_aligned_cb(efx, piobuf, vaddr + f->page_offset,
+					   skb_frag_size(f), copy_buf);
+		kunmap_atomic(vaddr);
+	}
+
+	EFX_BUG_ON_PARANOID(skb_shinfo(skb)->frag_list);
+}
+
+static struct efx_tx_buffer *
+efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+{
+	struct efx_tx_buffer *buffer =
+		efx_tx_queue_get_insert_buffer(tx_queue);
+	u8 __iomem *piobuf = tx_queue->piobuf;
+
+	/* Copy to PIO buffer. Ensure the writes are padded to the end
+	 * of a cache line, as this is required for write-combining to be
+	 * effective on at least x86.
+	 */
+
+	if (skb_shinfo(skb)->nr_frags) {
+		/* The size of the copy buffer will ensure all writes
+		 * are the size of a cache line.
+		 */
+		struct efx_short_copy_buffer copy_buf;
+
+		copy_buf.used = 0;
+
+		efx_skb_copy_bits_to_pio(tx_queue->efx, skb,
+					 &piobuf, &copy_buf);
+		efx_flush_copy_buffer(tx_queue->efx, piobuf, &copy_buf);
+	} else {
+		/* Pad the write to the size of a cache line.
+		 * We can do this because we know the skb_shared_info sruct is
+		 * after the source, and the destination buffer is big enough.
+		 */
+		BUILD_BUG_ON(L1_CACHE_BYTES >
+			     SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
+		memcpy_toio(tx_queue->piobuf, skb->data,
+			    ALIGN(skb->len, L1_CACHE_BYTES));
+	}
+
+	EFX_POPULATE_QWORD_5(buffer->option,
+			     ESF_DZ_TX_DESC_IS_OPT, 1,
+			     ESF_DZ_TX_OPTION_TYPE, ESE_DZ_TX_OPTION_DESC_PIO,
+			     ESF_DZ_TX_PIO_CONT, 0,
+			     ESF_DZ_TX_PIO_BYTE_CNT, skb->len,
+			     ESF_DZ_TX_PIO_BUF_ADDR,
+			     tx_queue->piobuf_offset);
+	++tx_queue->pio_packets;
+	++tx_queue->insert_count;
+	return buffer;
+}
+#endif /* EFX_USE_PIO */
+
 /*
  * Add a socket buffer to a TX queue
  *
@@ -227,6 +366,17 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 			return NETDEV_TX_OK;
 	}
 
+	/* Consider using PIO for short packets */
+#ifdef EFX_USE_PIO
+	if (skb->len <= efx_piobuf_size && tx_queue->piobuf &&
+	    efx_nic_tx_is_empty(tx_queue) &&
+	    efx_nic_tx_is_empty(efx_tx_queue_partner(tx_queue))) {
+		buffer = efx_enqueue_skb_pio(tx_queue, skb);
+		dma_flags = EFX_TX_BUF_OPTION;
+		goto finish_packet;
+	}
+#endif
+
 	/* Map for DMA.  Use dma_map_single rather than dma_map_page
 	 * since this is more efficient on machines with sparse
 	 * memory.
@@ -279,6 +429,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	}
 
 	/* Transfer ownership of the skb to the final buffer */
+finish_packet:
 	buffer->skb = skb;
 	buffer->flags = EFX_TX_BUF_SKB | dma_flags;
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
