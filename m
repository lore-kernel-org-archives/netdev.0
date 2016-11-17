From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/5] sfc: Firmware-Assisted TSO version 2
Date: Thu, 17 Nov 2016 10:51:54 +0000
Message-ID: <45109b98-8d6d-dadf-c3fc-432ed16b3edc@solarflare.com>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:65444 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941075AbcKQKwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:52:03 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

Add support for FATSOv2 to the driver. FATSOv2 offloads far more of the task
 of TCP segmentation to the firmware, such that we now just pass a single
 super-packet to the NIC. This means TSO has a great deal in common with a
 normal DMA transmit, apart from adding a couple of option descriptors.
 NIC-specific checks have been moved off the fast path and in to
 initialisation where possible.

This also moves FATSOv1/SWTSO to a new file (tx_tso.c).  The end of transmit
 and some error handling is now outside TSO, since it is common with other
 code.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/Makefile     |    2 +-
 drivers/net/ethernet/sfc/ef10.c       |  123 +++-
 drivers/net/ethernet/sfc/ethtool.c    |    1 +
 drivers/net/ethernet/sfc/falcon.c     |    2 +
 drivers/net/ethernet/sfc/farch.c      |   15 +
 drivers/net/ethernet/sfc/net_driver.h |   47 +-
 drivers/net/ethernet/sfc/nic.h        |    2 +
 drivers/net/ethernet/sfc/siena.c      |    1 +
 drivers/net/ethernet/sfc/tx.c         | 1013 ++++++++-------------------------
 drivers/net/ethernet/sfc/tx.h         |   27 +
 drivers/net/ethernet/sfc/tx_tso.c     |  570 +++++++++++++++++++
 11 files changed, 1035 insertions(+), 768 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/tx.h
 create mode 100644 drivers/net/ethernet/sfc/tx_tso.c

diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index ce8470fe7..b3b620f 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -1,7 +1,7 @@
 sfc-y			+= efx.o nic.o farch.o falcon.o siena.o ef10.o tx.o \
 			   rx.o selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
-			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o
+			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o tx_tso.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o ef10_sriov.o
 
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e61807e..4b69ed9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2086,6 +2086,78 @@ static inline void efx_ef10_push_tx_desc(struct efx_tx_queue *tx_queue,
 			ER_DZ_TX_DESC_UPD, tx_queue->queue);
 }
 
+/* Add Firmware-Assisted TSO v2 option descriptors to a queue.
+ */
+static int efx_ef10_tx_tso_desc(struct efx_tx_queue *tx_queue,
+				struct sk_buff *skb,
+				bool *data_mapped)
+{
+	struct efx_tx_buffer *buffer;
+	struct tcphdr *tcp;
+	struct iphdr *ip;
+
+	u16 ipv4_id;
+	u32 seqnum;
+	u32 mss;
+
+	EFX_BUG_ON_PARANOID(tx_queue->tso_version != 2);
+
+	mss = skb_shinfo(skb)->gso_size;
+
+	if (unlikely(mss < 4)) {
+		WARN_ONCE(1, "MSS of %u is too small for TSO v2\n", mss);
+		return -EINVAL;
+	}
+
+	ip = ip_hdr(skb);
+	if (ip->version == 4) {
+		/* Modify IPv4 header if needed. */
+		ip->tot_len = 0;
+		ip->check = 0;
+		ipv4_id = ip->id;
+	} else {
+		/* Modify IPv6 header if needed. */
+		struct ipv6hdr *ipv6 = ipv6_hdr(skb);
+
+		ipv6->payload_len = 0;
+		ipv4_id = 0;
+	}
+
+	tcp = tcp_hdr(skb);
+	seqnum = ntohl(tcp->seq);
+
+	buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+
+	buffer->flags = EFX_TX_BUF_OPTION;
+	buffer->len = 0;
+	buffer->unmap_len = 0;
+	EFX_POPULATE_QWORD_5(buffer->option,
+			ESF_DZ_TX_DESC_IS_OPT, 1,
+			ESF_DZ_TX_OPTION_TYPE, ESE_DZ_TX_OPTION_DESC_TSO,
+			ESF_DZ_TX_TSO_OPTION_TYPE,
+			ESE_DZ_TX_TSO_OPTION_DESC_FATSO2A,
+			ESF_DZ_TX_TSO_IP_ID, ipv4_id,
+			ESF_DZ_TX_TSO_TCP_SEQNO, seqnum
+			);
+	++tx_queue->insert_count;
+
+	buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+
+	buffer->flags = EFX_TX_BUF_OPTION;
+	buffer->len = 0;
+	buffer->unmap_len = 0;
+	EFX_POPULATE_QWORD_4(buffer->option,
+			ESF_DZ_TX_DESC_IS_OPT, 1,
+			ESF_DZ_TX_OPTION_TYPE, ESE_DZ_TX_OPTION_DESC_TSO,
+			ESF_DZ_TX_TSO_OPTION_TYPE,
+			ESE_DZ_TX_TSO_OPTION_DESC_FATSO2B,
+			ESF_DZ_TX_TSO_TCP_MSS, mss
+			);
+	++tx_queue->insert_count;
+
+	return 0;
+}
+
 static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_INIT_TXQ_IN_LEN(EFX_MAX_DMAQ_SIZE * 8 /
@@ -2095,6 +2167,7 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	struct efx_channel *channel = tx_queue->channel;
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	bool tso_v2 = false;
 	size_t inlen;
 	dma_addr_t dma_addr;
 	efx_qword_t *txd;
@@ -2102,13 +2175,33 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	int i;
 	BUILD_BUG_ON(MC_CMD_INIT_TXQ_OUT_LEN != 0);
 
+	/* TSOv2 is a limited resource that can only be configured on a limited
+	 * number of queues. TSO without checksum offload is not really a thing,
+	 * so we only enable it for those queues.
+	 *
+	 * TODO: handle failure to allocate this in the case where we've used
+	 * all the queues.
+	 */
+	if (csum_offload && (nic_data->datapath_caps2 &
+			(1 << MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_LBN))) {
+		tso_v2 = true;
+		netif_dbg(efx, hw, efx->net_dev, "Using TSOv2 for channel %u\n",
+				channel->channel);
+	}
+
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_SIZE, tx_queue->ptr_mask + 1);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_TARGET_EVQ, channel->channel);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_LABEL, tx_queue->queue);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_INSTANCE, tx_queue->queue);
-	MCDI_POPULATE_DWORD_2(inbuf, INIT_TXQ_IN_FLAGS,
+	MCDI_POPULATE_DWORD_3(inbuf, INIT_TXQ_IN_FLAGS,
+			      /* This flag was removed from mcdi_pcol.h for
+			       * the non-_EXT version of INIT_TXQ.  However,
+			       * firmware still honours it.
+			       */
+			      INIT_TXQ_EXT_IN_FLAG_TSOV2_EN, tso_v2,
 			      INIT_TXQ_IN_FLAG_IP_CSUM_DIS, !csum_offload,
 			      INIT_TXQ_IN_FLAG_TCP_CSUM_DIS, !csum_offload);
+
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_OWNER_ID, 0);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_PORT_ID, nic_data->vport_id);
 
@@ -2146,8 +2239,11 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 			     ESF_DZ_TX_OPTION_IP_CSUM, csum_offload);
 	tx_queue->write_count = 1;
 
-	if (nic_data->datapath_caps &
-	    (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN)) {
+	if (tso_v2) {
+		tx_queue->handle_tso = efx_ef10_tx_tso_desc;
+		tx_queue->tso_version = 2;
+	} else if (nic_data->datapath_caps &
+			(1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN)) {
 		tx_queue->tso_version = 1;
 	}
 
@@ -2202,6 +2298,25 @@ static inline void efx_ef10_notify_tx_desc(struct efx_tx_queue *tx_queue)
 			ER_DZ_TX_DESC_UPD_DWORD, tx_queue->queue);
 }
 
+#define EFX_EF10_MAX_TX_DESCRIPTOR_LEN 0x3fff
+
+static unsigned int efx_ef10_tx_limit_len(struct efx_tx_queue *tx_queue,
+					  dma_addr_t dma_addr, unsigned int len)
+{
+	if (len > EFX_EF10_MAX_TX_DESCRIPTOR_LEN) {
+		/* If we need to break across multiple descriptors we should
+		 * stop at a page boundary. This assumes the length limit is
+		 * greater than the page size.
+		 */
+		dma_addr_t end = dma_addr + EFX_EF10_MAX_TX_DESCRIPTOR_LEN;
+
+		BUILD_BUG_ON(EFX_EF10_MAX_TX_DESCRIPTOR_LEN < EFX_PAGE_SIZE);
+		len = (end & (~(EFX_PAGE_SIZE - 1))) - dma_addr;
+	}
+
+	return len;
+}
+
 static void efx_ef10_tx_write(struct efx_tx_queue *tx_queue)
 {
 	unsigned int old_write_count = tx_queue->write_count;
@@ -5469,6 +5584,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.tx_init = efx_ef10_tx_init,
 	.tx_remove = efx_ef10_tx_remove,
 	.tx_write = efx_ef10_tx_write,
+	.tx_limit_len = efx_ef10_tx_limit_len,
 	.rx_push_rss_config = efx_ef10_vf_rx_push_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
@@ -5575,6 +5691,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.tx_init = efx_ef10_tx_init,
 	.tx_remove = efx_ef10_tx_remove,
 	.tx_write = efx_ef10_tx_write,
+	.tx_limit_len = efx_ef10_tx_limit_len,
 	.rx_push_rss_config = efx_ef10_pf_rx_push_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index bf126f9..bd5edd6 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -71,6 +71,7 @@ static const struct efx_sw_stat_desc efx_sw_stat_desc[] = {
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
 	EFX_ETHTOOL_UINT_TXQ_STAT(pushes),
 	EFX_ETHTOOL_UINT_TXQ_STAT(pio_packets),
+	EFX_ETHTOOL_UINT_TXQ_STAT(cb_packets),
 	EFX_ETHTOOL_ATOMIC_NIC_ERROR_STAT(rx_reset),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 1a70926..6a1e74b 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2750,6 +2750,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
+	.tx_limit_len = efx_farch_tx_limit_len,
 	.rx_push_rss_config = dummy_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
@@ -2849,6 +2850,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
+	.tx_limit_len = efx_farch_tx_limit_len,
 	.rx_push_rss_config = falcon_b0_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 4762ec4..3d5b91b 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -356,6 +356,21 @@ void efx_farch_tx_write(struct efx_tx_queue *tx_queue)
 	}
 }
 
+unsigned int efx_farch_tx_limit_len(struct efx_tx_queue *tx_queue,
+				    dma_addr_t dma_addr, unsigned int len)
+{
+	/* Don't cross 4K boundaries with descriptors. */
+	unsigned int limit = (~dma_addr & (EFX_PAGE_SIZE - 1)) + 1;
+
+	len = min(limit, len);
+
+	if (EFX_WORKAROUND_5391(tx_queue->efx) && (dma_addr & 0xf))
+		len = min_t(unsigned int, len, 512 - (dma_addr & 0xf));
+
+	return len;
+}
+
+
 /* Allocate hardware resources for a TX queue */
 int efx_farch_tx_probe(struct efx_tx_queue *tx_queue)
 {
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index fec51c4..2da3e8f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -189,13 +189,17 @@ struct efx_tx_buffer {
  * @channel: The associated channel
  * @core_txq: The networking core TX queue structure
  * @buffer: The software buffer ring
- * @tsoh_page: Array of pages of TSO header buffers
+ * @cb_page: Array of pages of copy buffers.  Carved up according to
+ *	%EFX_TX_CB_ORDER into %EFX_TX_CB_SIZE-sized chunks.
  * @txd: The hardware descriptor ring
  * @ptr_mask: The size of the ring minus 1.
  * @piobuf: PIO buffer region for this TX queue (shared with its partner).
  *	Size of the region is efx_piobuf_size.
  * @piobuf_offset: Buffer offset to be specified in PIO descriptors
  * @initialised: Has hardware queue been initialised?
+ * @tx_min_size: Minimum transmit size for this queue. Depends on HW.
+ * @handle_tso: TSO xmit preparation handler.  Sets up the TSO metadata and
+ *	may also map tx data, depending on the nature of the TSO implementation.
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
  * @old_write_count: The value of @write_count when last checked.
@@ -224,6 +228,7 @@ struct efx_tx_buffer {
  * @pushes: Number of times the TX push feature has been used
  * @pio_packets: Number of times the TX PIO feature has been used
  * @xmit_more_available: Are any packets waiting to be pushed to the NIC
+ * @cb_packets: Number of times the TX copybreak feature has been used
  * @empty_read_count: If the completion path has seen the queue as empty
  *	and the transmission path has not yet checked this, the value of
  *	@read_count bitwise-added to %EFX_EMPTY_COUNT_VALID; otherwise 0.
@@ -236,12 +241,16 @@ struct efx_tx_queue {
 	struct efx_channel *channel;
 	struct netdev_queue *core_txq;
 	struct efx_tx_buffer *buffer;
-	struct efx_buffer *tsoh_page;
+	struct efx_buffer *cb_page;
 	struct efx_special_buffer txd;
 	unsigned int ptr_mask;
 	void __iomem *piobuf;
 	unsigned int piobuf_offset;
 	bool initialised;
+	unsigned int tx_min_size;
+
+	/* Function pointers used in the fast path. */
+	int (*handle_tso)(struct efx_tx_queue*, struct sk_buff*, bool *);
 
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
@@ -260,6 +269,7 @@ struct efx_tx_queue {
 	unsigned int pushes;
 	unsigned int pio_packets;
 	bool xmit_more_available;
+	unsigned int cb_packets;
 	/* Statistics to supplement MAC stats */
 	unsigned long tx_packets;
 
@@ -269,6 +279,9 @@ struct efx_tx_queue {
 	atomic_t flush_outstanding;
 };
 
+#define EFX_TX_CB_ORDER	7
+#define EFX_TX_CB_SIZE	(1 << EFX_TX_CB_ORDER) - NET_IP_ALIGN
+
 /**
  * struct efx_rx_buffer - An Efx RX data buffer
  * @dma_addr: DMA base address of the buffer
@@ -1288,6 +1301,8 @@ struct efx_nic_type {
 	void (*tx_init)(struct efx_tx_queue *tx_queue);
 	void (*tx_remove)(struct efx_tx_queue *tx_queue);
 	void (*tx_write)(struct efx_tx_queue *tx_queue);
+	unsigned int (*tx_limit_len)(struct efx_tx_queue *tx_queue,
+				     dma_addr_t dma_addr, unsigned int len);
 	int (*rx_push_rss_config)(struct efx_nic *efx, bool user,
 				  const u32 *rx_indir_table);
 	int (*rx_probe)(struct efx_rx_queue *rx_queue);
@@ -1545,4 +1560,32 @@ static inline netdev_features_t efx_supported_features(const struct efx_nic *efx
 	return net_dev->features | net_dev->hw_features;
 }
 
+/* Get the current TX queue insert index. */
+static inline unsigned int
+efx_tx_queue_get_insert_index(const struct efx_tx_queue *tx_queue)
+{
+	return tx_queue->insert_count & tx_queue->ptr_mask;
+}
+
+/* Get a TX buffer. */
+static inline struct efx_tx_buffer *
+__efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
+{
+	return &tx_queue->buffer[efx_tx_queue_get_insert_index(tx_queue)];
+}
+
+/* Get a TX buffer, checking it's not currently in use. */
+static inline struct efx_tx_buffer *
+efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
+{
+	struct efx_tx_buffer *buffer =
+		__efx_tx_queue_get_insert_buffer(tx_queue);
+
+	EFX_BUG_ON_PARANOID(buffer->len);
+	EFX_BUG_ON_PARANOID(buffer->flags);
+	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+
+	return buffer;
+}
+
 #endif /* EFX_NET_DRIVER_H */
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 73bee7e..06dd96e 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -681,6 +681,8 @@ void efx_farch_tx_init(struct efx_tx_queue *tx_queue);
 void efx_farch_tx_fini(struct efx_tx_queue *tx_queue);
 void efx_farch_tx_remove(struct efx_tx_queue *tx_queue);
 void efx_farch_tx_write(struct efx_tx_queue *tx_queue);
+unsigned int efx_farch_tx_limit_len(struct efx_tx_queue *tx_queue,
+				    dma_addr_t dma_addr, unsigned int len);
 int efx_farch_rx_probe(struct efx_rx_queue *rx_queue);
 void efx_farch_rx_init(struct efx_rx_queue *rx_queue);
 void efx_farch_rx_fini(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 04ed1b4..3975cad 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -977,6 +977,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
+	.tx_limit_len = efx_farch_tx_limit_len,
 	.rx_push_rss_config = siena_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 2337789..3089e88 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -22,6 +22,7 @@
 #include "efx.h"
 #include "io.h"
 #include "nic.h"
+#include "tx.h"
 #include "workarounds.h"
 #include "ef10_regs.h"
 
@@ -33,29 +34,30 @@ unsigned int efx_piobuf_size __read_mostly = EFX_PIOBUF_SIZE_DEF;
 
 #endif /* EFX_USE_PIO */
 
-static inline unsigned int
-efx_tx_queue_get_insert_index(const struct efx_tx_queue *tx_queue)
+static inline u8 *efx_tx_get_copy_buffer(struct efx_tx_queue *tx_queue,
+					 struct efx_tx_buffer *buffer)
 {
-	return tx_queue->insert_count & tx_queue->ptr_mask;
-}
+	unsigned int index = efx_tx_queue_get_insert_index(tx_queue);
+	struct efx_buffer *page_buf =
+		&tx_queue->cb_page[index >> (PAGE_SHIFT - EFX_TX_CB_ORDER)];
+	unsigned int offset =
+		((index << EFX_TX_CB_ORDER) + NET_IP_ALIGN) & (PAGE_SIZE - 1);
 
-static inline struct efx_tx_buffer *
-__efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
-{
-	return &tx_queue->buffer[efx_tx_queue_get_insert_index(tx_queue)];
+	if (unlikely(!page_buf->addr) &&
+	    efx_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE,
+				 GFP_ATOMIC))
+		return NULL;
+	buffer->dma_addr = page_buf->dma_addr + offset;
+	buffer->unmap_len = 0;
+	return (u8 *)page_buf->addr + offset;
 }
 
-static inline struct efx_tx_buffer *
-efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
+u8 *efx_tx_get_copy_buffer_limited(struct efx_tx_queue *tx_queue,
+				   struct efx_tx_buffer *buffer, size_t len)
 {
-	struct efx_tx_buffer *buffer =
-		__efx_tx_queue_get_insert_buffer(tx_queue);
-
-	EFX_BUG_ON_PARANOID(buffer->len);
-	EFX_BUG_ON_PARANOID(buffer->flags);
-	EFX_BUG_ON_PARANOID(buffer->unmap_len);
-
-	return buffer;
+	if (len > EFX_TX_CB_SIZE)
+		return NULL;
+	return efx_tx_get_copy_buffer(tx_queue, buffer);
 }
 
 static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
@@ -90,27 +92,6 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	buffer->flags = 0;
 }
 
-static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       struct sk_buff *skb);
-
-static inline unsigned
-efx_max_tx_len(struct efx_nic *efx, dma_addr_t dma_addr)
-{
-	/* Depending on the NIC revision, we can use descriptor
-	 * lengths up to 8K or 8K-1.  However, since PCI Express
-	 * devices must split read requests at 4K boundaries, there is
-	 * little benefit from using descriptors that cross those
-	 * boundaries and we keep things simple by not doing so.
-	 */
-	unsigned len = (~dma_addr & (EFX_PAGE_SIZE - 1)) + 1;
-
-	/* Work around hardware bug for unaligned buffers. */
-	if (EFX_WORKAROUND_5391(efx) && (dma_addr & 0xf))
-		len = min_t(unsigned, len, 512 - (dma_addr & 0xf));
-
-	return len;
-}
-
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx)
 {
 	/* Header and payload descriptor for each output segment, plus
@@ -173,6 +154,39 @@ static void efx_tx_maybe_stop_queue(struct efx_tx_queue *txq1)
 	}
 }
 
+static int efx_enqueue_skb_copy(struct efx_tx_queue *tx_queue,
+				struct sk_buff *skb)
+{
+	unsigned int min_len = tx_queue->tx_min_size;
+	unsigned int copy_len = skb->len;
+	struct efx_tx_buffer *buffer;
+	u8 *copy_buffer;
+	int rc;
+
+	EFX_BUG_ON_PARANOID(copy_len > EFX_TX_CB_SIZE);
+
+	buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+
+	copy_buffer = efx_tx_get_copy_buffer(tx_queue, buffer);
+	if (unlikely(!copy_buffer))
+		return -ENOMEM;
+
+	rc = skb_copy_bits(skb, 0, copy_buffer, copy_len);
+	EFX_WARN_ON_PARANOID(rc);
+	if (unlikely(copy_len < min_len)) {
+		memset(copy_buffer + copy_len, 0, min_len - copy_len);
+		buffer->len = min_len;
+	} else {
+		buffer->len = copy_len;
+	}
+
+	buffer->skb = skb;
+	buffer->flags = EFX_TX_BUF_SKB;
+
+	++tx_queue->insert_count;
+	return rc;
+}
+
 #ifdef EFX_USE_PIO
 
 struct efx_short_copy_buffer {
@@ -267,8 +281,8 @@ static void efx_skb_copy_bits_to_pio(struct efx_nic *efx, struct sk_buff *skb,
 	EFX_BUG_ON_PARANOID(skb_shinfo(skb)->frag_list);
 }
 
-static struct efx_tx_buffer *
-efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+static int efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue,
+			       struct sk_buff *skb)
 {
 	struct efx_tx_buffer *buffer =
 		efx_tx_queue_get_insert_buffer(tx_queue);
@@ -292,7 +306,7 @@ efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		efx_flush_copy_buffer(tx_queue->efx, piobuf, &copy_buf);
 	} else {
 		/* Pad the write to the size of a cache line.
-		 * We can do this because we know the skb_shared_info sruct is
+		 * We can do this because we know the skb_shared_info struct is
 		 * after the source, and the destination buffer is big enough.
 		 */
 		BUILD_BUG_ON(L1_CACHE_BYTES >
@@ -301,6 +315,9 @@ efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 				 ALIGN(skb->len, L1_CACHE_BYTES) >> 3);
 	}
 
+	buffer->skb = skb;
+	buffer->flags = EFX_TX_BUF_SKB | EFX_TX_BUF_OPTION;
+
 	EFX_POPULATE_QWORD_5(buffer->option,
 			     ESF_DZ_TX_DESC_IS_OPT, 1,
 			     ESF_DZ_TX_OPTION_TYPE, ESE_DZ_TX_OPTION_DESC_PIO,
@@ -308,127 +325,192 @@ efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 			     ESF_DZ_TX_PIO_BYTE_CNT, skb->len,
 			     ESF_DZ_TX_PIO_BUF_ADDR,
 			     tx_queue->piobuf_offset);
-	++tx_queue->pio_packets;
 	++tx_queue->insert_count;
-	return buffer;
+	return 0;
 }
 #endif /* EFX_USE_PIO */
 
-/*
- * Add a socket buffer to a TX queue
- *
- * This maps all fragments of a socket buffer for DMA and adds them to
- * the TX queue.  The queue's insert pointer will be incremented by
- * the number of fragments in the socket buffer.
- *
- * If any DMA mapping fails, any mapped fragments will be unmapped,
- * the queue's insert pointer will be restored to its original value.
- *
- * This function is split out from efx_hard_start_xmit to allow the
- * loopback test to direct packets via specific TX queues.
- *
- * Returns NETDEV_TX_OK.
- * You must hold netif_tx_lock() to call this function.
- */
-netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+static struct efx_tx_buffer *efx_tx_map_chunk(struct efx_tx_queue *tx_queue,
+					      dma_addr_t dma_addr,
+					      size_t len)
 {
-	struct efx_nic *efx = tx_queue->efx;
-	struct device *dma_dev = &efx->pci_dev->dev;
+	const struct efx_nic_type *nic_type = tx_queue->efx->type;
 	struct efx_tx_buffer *buffer;
-	unsigned int old_insert_count = tx_queue->insert_count;
-	skb_frag_t *fragment;
-	unsigned int len, unmap_len = 0;
-	dma_addr_t dma_addr, unmap_addr = 0;
 	unsigned int dma_len;
-	unsigned short dma_flags;
-	int i = 0;
 
-	if (skb_shinfo(skb)->gso_size)
-		return efx_enqueue_skb_tso(tx_queue, skb);
+	/* Map the fragment taking account of NIC-dependent DMA limits. */
+	do {
+		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+		dma_len = nic_type->tx_limit_len(tx_queue, dma_addr, len);
 
-	/* Get size of the initial fragment */
-	len = skb_headlen(skb);
+		buffer->len = dma_len;
+		buffer->dma_addr = dma_addr;
+		buffer->flags = EFX_TX_BUF_CONT;
+		len -= dma_len;
+		dma_addr += dma_len;
+		++tx_queue->insert_count;
+	} while (len);
 
-	/* Pad if necessary */
-	if (EFX_WORKAROUND_15592(efx) && skb->len <= 32) {
-		EFX_BUG_ON_PARANOID(skb->data_len);
-		len = 32 + 1;
-		if (skb_pad(skb, len - skb->len))
-			return NETDEV_TX_OK;
-	}
+	return buffer;
+}
 
-	/* Consider using PIO for short packets */
-#ifdef EFX_USE_PIO
-	if (skb->len <= efx_piobuf_size && !skb->xmit_more &&
-	    efx_nic_may_tx_pio(tx_queue)) {
-		buffer = efx_enqueue_skb_pio(tx_queue, skb);
-		dma_flags = EFX_TX_BUF_OPTION;
-		goto finish_packet;
-	}
-#endif
+/* Map all data from an SKB for DMA and create descriptors on the queue.
+ */
+static int efx_tx_map_data(struct efx_tx_queue *tx_queue, struct sk_buff *skb,
+			   unsigned int segment_count)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct device *dma_dev = &efx->pci_dev->dev;
+	unsigned int frag_index, nr_frags;
+	dma_addr_t dma_addr, unmap_addr;
+	unsigned short dma_flags;
+	size_t len, unmap_len;
 
-	/* Map for DMA.  Use dma_map_single rather than dma_map_page
-	 * since this is more efficient on machines with sparse
-	 * memory.
-	 */
-	dma_flags = EFX_TX_BUF_MAP_SINGLE;
-	dma_addr = dma_map_single(dma_dev, skb->data, len, PCI_DMA_TODEVICE);
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	frag_index = 0;
 
-	/* Process all fragments */
-	while (1) {
-		if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
-			goto dma_err;
+	/* Map header data. */
+	len = skb_headlen(skb);
+	dma_addr = dma_map_single(dma_dev, skb->data, len, DMA_TO_DEVICE);
+	dma_flags = EFX_TX_BUF_MAP_SINGLE;
+	unmap_len = len;
+	unmap_addr = dma_addr;
 
-		/* Store fields for marking in the per-fragment final
-		 * descriptor */
-		unmap_len = len;
-		unmap_addr = dma_addr;
+	if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
+		return -EIO;
 
-		/* Add to TX queue, splitting across DMA boundaries */
-		do {
-			buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+	if (segment_count) {
+		/* For TSO we need to put the header in to a separate
+		 * descriptor. Map this separately if necessary.
+		 */
+		size_t header_len = skb_transport_header(skb) - skb->data +
+				(tcp_hdr(skb)->doff << 2u);
+
+		if (header_len != len) {
+			tx_queue->tso_long_headers++;
+			efx_tx_map_chunk(tx_queue, dma_addr, header_len);
+			len -= header_len;
+			dma_addr += header_len;
+		}
+	}
 
-			dma_len = efx_max_tx_len(efx, dma_addr);
-			if (likely(dma_len >= len))
-				dma_len = len;
+	/* Add descriptors for each fragment. */
+	do {
+		struct efx_tx_buffer *buffer;
+		skb_frag_t *fragment;
 
-			/* Fill out per descriptor fields */
-			buffer->len = dma_len;
-			buffer->dma_addr = dma_addr;
-			buffer->flags = EFX_TX_BUF_CONT;
-			len -= dma_len;
-			dma_addr += dma_len;
-			++tx_queue->insert_count;
-		} while (len);
+		buffer = efx_tx_map_chunk(tx_queue, dma_addr, len);
 
-		/* Transfer ownership of the unmapping to the final buffer */
+		/* The final descriptor for a fragment is responsible for
+		 * unmapping the whole fragment.
+		 */
 		buffer->flags = EFX_TX_BUF_CONT | dma_flags;
 		buffer->unmap_len = unmap_len;
 		buffer->dma_offset = buffer->dma_addr - unmap_addr;
-		unmap_len = 0;
 
-		/* Get address and size of next fragment */
-		if (i >= skb_shinfo(skb)->nr_frags)
-			break;
-		fragment = &skb_shinfo(skb)->frags[i];
+		if (frag_index >= nr_frags) {
+			/* Store SKB details with the final buffer for
+			 * the completion.
+			 */
+			buffer->skb = skb;
+			buffer->flags = EFX_TX_BUF_SKB | dma_flags;
+			return 0;
+		}
+
+		/* Move on to the next fragment. */
+		fragment = &skb_shinfo(skb)->frags[frag_index++];
 		len = skb_frag_size(fragment);
-		i++;
-		/* Map for DMA */
+		dma_addr = skb_frag_dma_map(dma_dev, fragment,
+				0, len, DMA_TO_DEVICE);
 		dma_flags = 0;
-		dma_addr = skb_frag_dma_map(dma_dev, fragment, 0, len,
-					    DMA_TO_DEVICE);
+		unmap_len = len;
+		unmap_addr = dma_addr;
+
+		if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
+			return -EIO;
+	} while (1);
+}
+
+/* Remove buffers put into a tx_queue.  None of the buffers must have
+ * an skb attached.
+ */
+static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
+{
+	struct efx_tx_buffer *buffer;
+
+	/* Work backwards until we hit the original insert pointer value */
+	while (tx_queue->insert_count != tx_queue->write_count) {
+		--tx_queue->insert_count;
+		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
+		efx_dequeue_buffer(tx_queue, buffer, NULL, NULL);
 	}
+}
+
+static int efx_tx_tso_sw(struct efx_tx_queue *tx_queue, struct sk_buff *skb,
+			 bool *data_mapped)
+{
+	return efx_enqueue_skb_tso(tx_queue, skb, data_mapped);
+}
+
+/*
+ * Add a socket buffer to a TX queue
+ *
+ * This maps all fragments of a socket buffer for DMA and adds them to
+ * the TX queue.  The queue's insert pointer will be incremented by
+ * the number of fragments in the socket buffer.
+ *
+ * If any DMA mapping fails, any mapped fragments will be unmapped,
+ * the queue's insert pointer will be restored to its original value.
+ *
+ * This function is split out from efx_hard_start_xmit to allow the
+ * loopback test to direct packets via specific TX queues.
+ *
+ * Returns NETDEV_TX_OK.
+ * You must hold netif_tx_lock() to call this function.
+ */
+netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+{
+	bool data_mapped = false;
+	unsigned int segments;
+	unsigned int skb_len;
 
-	/* Transfer ownership of the skb to the final buffer */
+	skb_len = skb->len;
+	segments = skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 0;
+	if (segments == 1)
+		segments = 0; /* Don't use TSO for a single segment. */
+
+	/* Handle TSO first - it's *possible* (although unlikely) that we might
+	 * be passed a packet to segment that's smaller than the copybreak/PIO
+	 * size limit.
+	 */
+	if (segments) {
+		EFX_BUG_ON_PARANOID(!tx_queue->handle_tso);
+		if (tx_queue->handle_tso(tx_queue, skb, &data_mapped))
+			goto err;
 #ifdef EFX_USE_PIO
-finish_packet:
+	} else if (skb_len <= efx_piobuf_size && !skb->xmit_more &&
+		   efx_nic_may_tx_pio(tx_queue)) {
+		/* Use PIO for short packets with an empty queue. */
+		if (efx_enqueue_skb_pio(tx_queue, skb))
+			goto err;
+		tx_queue->pio_packets++;
+		data_mapped = true;
 #endif
-	buffer->skb = skb;
-	buffer->flags = EFX_TX_BUF_SKB | dma_flags;
+	} else if (skb_len < tx_queue->tx_min_size ||
+			(skb->data_len && skb_len <= EFX_TX_CB_SIZE)) {
+		/* Pad short packets or coalesce short fragmented packets. */
+		if (efx_enqueue_skb_copy(tx_queue, skb))
+			goto err;
+		tx_queue->cb_packets++;
+		data_mapped = true;
+	}
 
-	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
+	/* Map for DMA and create descriptors if we haven't done so already. */
+	if (!data_mapped && (efx_tx_map_data(tx_queue, skb, segments)))
+		goto err;
 
-	efx_tx_maybe_stop_queue(tx_queue);
+	/* Update BQL */
+	netdev_tx_sent_queue(tx_queue->core_txq, skb_len);
 
 	/* Pass off to hardware */
 	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq)) {
@@ -446,37 +528,22 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		tx_queue->xmit_more_available = skb->xmit_more;
 	}
 
-	tx_queue->tx_packets++;
+	if (segments) {
+		tx_queue->tso_bursts++;
+		tx_queue->tso_packets += segments;
+		tx_queue->tx_packets  += segments;
+	} else {
+		tx_queue->tx_packets++;
+	}
+
+	efx_tx_maybe_stop_queue(tx_queue);
 
 	return NETDEV_TX_OK;
 
- dma_err:
-	netif_err(efx, tx_err, efx->net_dev,
-		  " TX queue %d could not map skb with %d bytes %d "
-		  "fragments for DMA\n", tx_queue->queue, skb->len,
-		  skb_shinfo(skb)->nr_frags + 1);
 
-	/* Mark the packet as transmitted, and free the SKB ourselves */
+err:
+	efx_enqueue_unwind(tx_queue);
 	dev_kfree_skb_any(skb);
-
-	/* Work backwards until we hit the original insert pointer value */
-	while (tx_queue->insert_count != old_insert_count) {
-		unsigned int pkts_compl = 0, bytes_compl = 0;
-		--tx_queue->insert_count;
-		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
-		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
-	}
-
-	/* Free the fragment we were mid-way through pushing */
-	if (unmap_len) {
-		if (dma_flags & EFX_TX_BUF_MAP_SINGLE)
-			dma_unmap_single(dma_dev, unmap_addr, unmap_len,
-					 DMA_TO_DEVICE);
-		else
-			dma_unmap_page(dma_dev, unmap_addr, unmap_len,
-				       DMA_TO_DEVICE);
-	}
-
 	return NETDEV_TX_OK;
 }
 
@@ -667,19 +734,9 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	}
 }
 
-/* Size of page-based TSO header buffers.  Larger blocks must be
- * allocated from the heap.
- */
-#define TSOH_STD_SIZE	128
-#define TSOH_PER_PAGE	(PAGE_SIZE / TSOH_STD_SIZE)
-
-/* At most half the descriptors in the queue at any time will refer to
- * a TSO header buffer, since they must always be followed by a
- * payload descriptor referring to an skb.
- */
-static unsigned int efx_tsoh_page_count(struct efx_tx_queue *tx_queue)
+static unsigned int efx_tx_cb_page_count(struct efx_tx_queue *tx_queue)
 {
-	return DIV_ROUND_UP(tx_queue->ptr_mask + 1, 2 * TSOH_PER_PAGE);
+	return DIV_ROUND_UP(tx_queue->ptr_mask + 1, PAGE_SIZE >> EFX_TX_CB_ORDER);
 }
 
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
@@ -703,14 +760,11 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	if (!tx_queue->buffer)
 		return -ENOMEM;
 
-	if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD) {
-		tx_queue->tsoh_page =
-			kcalloc(efx_tsoh_page_count(tx_queue),
-				sizeof(tx_queue->tsoh_page[0]), GFP_KERNEL);
-		if (!tx_queue->tsoh_page) {
-			rc = -ENOMEM;
-			goto fail1;
-		}
+	tx_queue->cb_page = kcalloc(efx_tx_cb_page_count(tx_queue),
+				    sizeof(tx_queue->cb_page[0]), GFP_KERNEL);
+	if (!tx_queue->cb_page) {
+		rc = -ENOMEM;
+		goto fail1;
 	}
 
 	/* Allocate hardware ring */
@@ -721,8 +775,8 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	return 0;
 
 fail2:
-	kfree(tx_queue->tsoh_page);
-	tx_queue->tsoh_page = NULL;
+	kfree(tx_queue->cb_page);
+	tx_queue->cb_page = NULL;
 fail1:
 	kfree(tx_queue->buffer);
 	tx_queue->buffer = NULL;
@@ -731,7 +785,9 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 
 void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 {
-	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+	struct efx_nic *efx = tx_queue->efx;
+
+	netif_dbg(efx, drv, efx->net_dev,
 		  "initialising TX queue %d\n", tx_queue->queue);
 
 	tx_queue->insert_count = 0;
@@ -742,6 +798,14 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	tx_queue->empty_read_count = 0 | EFX_EMPTY_COUNT_VALID;
 	tx_queue->xmit_more_available = false;
 
+	/* Set up default function pointers. These may get replaced by
+	 * efx_nic_init_tx() based off NIC/queue capabilities.
+	 */
+	tx_queue->handle_tso = efx_tx_tso_sw;
+
+	/* Some older hardware requires Tx writes larger than 32. */
+	tx_queue->tx_min_size = EFX_WORKAROUND_15592(efx) ? 33 : 0;
+
 	/* Set up TX descriptor ring */
 	efx_nic_init_tx(tx_queue);
 
@@ -781,589 +845,14 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 		  "destroying TX queue %d\n", tx_queue->queue);
 	efx_nic_remove_tx(tx_queue);
 
-	if (tx_queue->tsoh_page) {
-		for (i = 0; i < efx_tsoh_page_count(tx_queue); i++)
+	if (tx_queue->cb_page) {
+		for (i = 0; i < efx_tx_cb_page_count(tx_queue); i++)
 			efx_nic_free_buffer(tx_queue->efx,
-					    &tx_queue->tsoh_page[i]);
-		kfree(tx_queue->tsoh_page);
-		tx_queue->tsoh_page = NULL;
+					    &tx_queue->cb_page[i]);
+		kfree(tx_queue->cb_page);
+		tx_queue->cb_page = NULL;
 	}
 
 	kfree(tx_queue->buffer);
 	tx_queue->buffer = NULL;
 }
-
-
-/* Efx TCP segmentation acceleration.
- *
- * Why?  Because by doing it here in the driver we can go significantly
- * faster than the GSO.
- *
- * Requires TX checksum offload support.
- */
-
-#define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
-
-/**
- * struct tso_state - TSO state for an SKB
- * @out_len: Remaining length in current segment
- * @seqnum: Current sequence number
- * @ipv4_id: Current IPv4 ID, host endian
- * @packet_space: Remaining space in current packet
- * @dma_addr: DMA address of current position
- * @in_len: Remaining length in current SKB fragment
- * @unmap_len: Length of SKB fragment
- * @unmap_addr: DMA address of SKB fragment
- * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
- * @protocol: Network protocol (after any VLAN header)
- * @ip_off: Offset of IP header
- * @tcp_off: Offset of TCP header
- * @header_len: Number of bytes of header
- * @ip_base_len: IPv4 tot_len or IPv6 payload_len, before TCP payload
- * @header_dma_addr: Header DMA address, when using option descriptors
- * @header_unmap_len: Header DMA mapped length, or 0 if not using option
- *	descriptors
- *
- * The state used during segmentation.  It is put into this data structure
- * just to make it easy to pass into inline functions.
- */
-struct tso_state {
-	/* Output position */
-	unsigned out_len;
-	unsigned seqnum;
-	u16 ipv4_id;
-	unsigned packet_space;
-
-	/* Input position */
-	dma_addr_t dma_addr;
-	unsigned in_len;
-	unsigned unmap_len;
-	dma_addr_t unmap_addr;
-	unsigned short dma_flags;
-
-	__be16 protocol;
-	unsigned int ip_off;
-	unsigned int tcp_off;
-	unsigned header_len;
-	unsigned int ip_base_len;
-	dma_addr_t header_dma_addr;
-	unsigned int header_unmap_len;
-};
-
-
-/*
- * Verify that our various assumptions about sk_buffs and the conditions
- * under which TSO will be attempted hold true.  Return the protocol number.
- */
-static __be16 efx_tso_check_protocol(struct sk_buff *skb)
-{
-	__be16 protocol = skb->protocol;
-
-	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
-			    protocol);
-	if (protocol == htons(ETH_P_8021Q)) {
-		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
-		protocol = veh->h_vlan_encapsulated_proto;
-	}
-
-	if (protocol == htons(ETH_P_IP)) {
-		EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
-	} else {
-		EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IPV6));
-		EFX_BUG_ON_PARANOID(ipv6_hdr(skb)->nexthdr != NEXTHDR_TCP);
-	}
-	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
-			     + (tcp_hdr(skb)->doff << 2u)) >
-			    skb_headlen(skb));
-
-	return protocol;
-}
-
-static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
-			       struct efx_tx_buffer *buffer, unsigned int len)
-{
-	u8 *result;
-
-	EFX_BUG_ON_PARANOID(buffer->len);
-	EFX_BUG_ON_PARANOID(buffer->flags);
-	EFX_BUG_ON_PARANOID(buffer->unmap_len);
-
-	if (likely(len <= TSOH_STD_SIZE - NET_IP_ALIGN)) {
-		unsigned index =
-			(tx_queue->insert_count & tx_queue->ptr_mask) / 2;
-		struct efx_buffer *page_buf =
-			&tx_queue->tsoh_page[index / TSOH_PER_PAGE];
-		unsigned offset =
-			TSOH_STD_SIZE * (index % TSOH_PER_PAGE) + NET_IP_ALIGN;
-
-		if (unlikely(!page_buf->addr) &&
-		    efx_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE,
-					 GFP_ATOMIC))
-			return NULL;
-
-		result = (u8 *)page_buf->addr + offset;
-		buffer->dma_addr = page_buf->dma_addr + offset;
-		buffer->flags = EFX_TX_BUF_CONT;
-	} else {
-		tx_queue->tso_long_headers++;
-
-		buffer->heap_buf = kmalloc(NET_IP_ALIGN + len, GFP_ATOMIC);
-		if (unlikely(!buffer->heap_buf))
-			return NULL;
-		result = (u8 *)buffer->heap_buf + NET_IP_ALIGN;
-		buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_HEAP;
-	}
-
-	buffer->len = len;
-
-	return result;
-}
-
-/**
- * efx_tx_queue_insert - push descriptors onto the TX queue
- * @tx_queue:		Efx TX queue
- * @dma_addr:		DMA address of fragment
- * @len:		Length of fragment
- * @final_buffer:	The final buffer inserted into the queue
- *
- * Push descriptors onto the TX queue.
- */
-static void efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
-				dma_addr_t dma_addr, unsigned len,
-				struct efx_tx_buffer **final_buffer)
-{
-	struct efx_tx_buffer *buffer;
-	struct efx_nic *efx = tx_queue->efx;
-	unsigned dma_len;
-
-	EFX_BUG_ON_PARANOID(len <= 0);
-
-	while (1) {
-		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
-		++tx_queue->insert_count;
-
-		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
-				    tx_queue->read_count >=
-				    efx->txq_entries);
-
-		buffer->dma_addr = dma_addr;
-
-		dma_len = efx_max_tx_len(efx, dma_addr);
-
-		/* If there is enough space to send then do so */
-		if (dma_len >= len)
-			break;
-
-		buffer->len = dma_len;
-		buffer->flags = EFX_TX_BUF_CONT;
-		dma_addr += dma_len;
-		len -= dma_len;
-	}
-
-	EFX_BUG_ON_PARANOID(!len);
-	buffer->len = len;
-	*final_buffer = buffer;
-}
-
-
-/*
- * Put a TSO header into the TX queue.
- *
- * This is special-cased because we know that it is small enough to fit in
- * a single fragment, and we know it doesn't cross a page boundary.  It
- * also allows us to not worry about end-of-packet etc.
- */
-static int efx_tso_put_header(struct efx_tx_queue *tx_queue,
-			      struct efx_tx_buffer *buffer, u8 *header)
-{
-	if (unlikely(buffer->flags & EFX_TX_BUF_HEAP)) {
-		buffer->dma_addr = dma_map_single(&tx_queue->efx->pci_dev->dev,
-						  header, buffer->len,
-						  DMA_TO_DEVICE);
-		if (unlikely(dma_mapping_error(&tx_queue->efx->pci_dev->dev,
-					       buffer->dma_addr))) {
-			kfree(buffer->heap_buf);
-			buffer->len = 0;
-			buffer->flags = 0;
-			return -ENOMEM;
-		}
-		buffer->unmap_len = buffer->len;
-		buffer->dma_offset = 0;
-		buffer->flags |= EFX_TX_BUF_MAP_SINGLE;
-	}
-
-	++tx_queue->insert_count;
-	return 0;
-}
-
-
-/* Remove buffers put into a tx_queue.  None of the buffers must have
- * an skb attached.
- */
-static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue,
-			       unsigned int insert_count)
-{
-	struct efx_tx_buffer *buffer;
-
-	/* Work backwards until we hit the original insert pointer value */
-	while (tx_queue->insert_count != insert_count) {
-		--tx_queue->insert_count;
-		buffer = __efx_tx_queue_get_insert_buffer(tx_queue);
-		efx_dequeue_buffer(tx_queue, buffer, NULL, NULL);
-	}
-}
-
-
-/* Parse the SKB header and initialise state. */
-static int tso_start(struct tso_state *st, struct efx_nic *efx,
-		     struct efx_tx_queue *tx_queue,
-		     const struct sk_buff *skb)
-{
-	struct device *dma_dev = &efx->pci_dev->dev;
-	unsigned int header_len, in_len;
-	bool use_opt_desc = false;
-	dma_addr_t dma_addr;
-
-	if (tx_queue->tso_version == 1)
-		use_opt_desc = true;
-
-	st->ip_off = skb_network_header(skb) - skb->data;
-	st->tcp_off = skb_transport_header(skb) - skb->data;
-	header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
-	in_len = skb_headlen(skb) - header_len;
-	st->header_len = header_len;
-	st->in_len = in_len;
-	if (st->protocol == htons(ETH_P_IP)) {
-		st->ip_base_len = st->header_len - st->ip_off;
-		st->ipv4_id = ntohs(ip_hdr(skb)->id);
-	} else {
-		st->ip_base_len = st->header_len - st->tcp_off;
-		st->ipv4_id = 0;
-	}
-	st->seqnum = ntohl(tcp_hdr(skb)->seq);
-
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
-
-	st->out_len = skb->len - header_len;
-
-	if (!use_opt_desc) {
-		st->header_unmap_len = 0;
-
-		if (likely(in_len == 0)) {
-			st->dma_flags = 0;
-			st->unmap_len = 0;
-			return 0;
-		}
-
-		dma_addr = dma_map_single(dma_dev, skb->data + header_len,
-					  in_len, DMA_TO_DEVICE);
-		st->dma_flags = EFX_TX_BUF_MAP_SINGLE;
-		st->dma_addr = dma_addr;
-		st->unmap_addr = dma_addr;
-		st->unmap_len = in_len;
-	} else {
-		dma_addr = dma_map_single(dma_dev, skb->data,
-					  skb_headlen(skb), DMA_TO_DEVICE);
-		st->header_dma_addr = dma_addr;
-		st->header_unmap_len = skb_headlen(skb);
-		st->dma_flags = 0;
-		st->dma_addr = dma_addr + header_len;
-		st->unmap_len = 0;
-	}
-
-	return unlikely(dma_mapping_error(dma_dev, dma_addr)) ? -ENOMEM : 0;
-}
-
-static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
-			    skb_frag_t *frag)
-{
-	st->unmap_addr = skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
-					  skb_frag_size(frag), DMA_TO_DEVICE);
-	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
-		st->dma_flags = 0;
-		st->unmap_len = skb_frag_size(frag);
-		st->in_len = skb_frag_size(frag);
-		st->dma_addr = st->unmap_addr;
-		return 0;
-	}
-	return -ENOMEM;
-}
-
-
-/**
- * tso_fill_packet_with_fragment - form descriptors for the current fragment
- * @tx_queue:		Efx TX queue
- * @skb:		Socket buffer
- * @st:			TSO state
- *
- * Form descriptors for the current fragment, until we reach the end
- * of fragment or end-of-packet.
- */
-static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
-					  const struct sk_buff *skb,
-					  struct tso_state *st)
-{
-	struct efx_tx_buffer *buffer;
-	int n;
-
-	if (st->in_len == 0)
-		return;
-	if (st->packet_space == 0)
-		return;
-
-	EFX_BUG_ON_PARANOID(st->in_len <= 0);
-	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
-
-	n = min(st->in_len, st->packet_space);
-
-	st->packet_space -= n;
-	st->out_len -= n;
-	st->in_len -= n;
-
-	efx_tx_queue_insert(tx_queue, st->dma_addr, n, &buffer);
-
-	if (st->out_len == 0) {
-		/* Transfer ownership of the skb */
-		buffer->skb = skb;
-		buffer->flags = EFX_TX_BUF_SKB;
-	} else if (st->packet_space != 0) {
-		buffer->flags = EFX_TX_BUF_CONT;
-	}
-
-	if (st->in_len == 0) {
-		/* Transfer ownership of the DMA mapping */
-		buffer->unmap_len = st->unmap_len;
-		buffer->dma_offset = buffer->unmap_len - buffer->len;
-		buffer->flags |= st->dma_flags;
-		st->unmap_len = 0;
-	}
-
-	st->dma_addr += n;
-}
-
-
-/**
- * tso_start_new_packet - generate a new header and prepare for the new packet
- * @tx_queue:		Efx TX queue
- * @skb:		Socket buffer
- * @st:			TSO state
- *
- * Generate a new header and prepare for the new packet.  Return 0 on
- * success, or -%ENOMEM if failed to alloc header.
- */
-static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
-				const struct sk_buff *skb,
-				struct tso_state *st)
-{
-	struct efx_tx_buffer *buffer =
-		efx_tx_queue_get_insert_buffer(tx_queue);
-	bool is_last = st->out_len <= skb_shinfo(skb)->gso_size;
-	u8 tcp_flags_clear;
-
-	if (!is_last) {
-		st->packet_space = skb_shinfo(skb)->gso_size;
-		tcp_flags_clear = 0x09; /* mask out FIN and PSH */
-	} else {
-		st->packet_space = st->out_len;
-		tcp_flags_clear = 0x00;
-	}
-
-	if (!st->header_unmap_len) {
-		/* Allocate and insert a DMA-mapped header buffer. */
-		struct tcphdr *tsoh_th;
-		unsigned ip_length;
-		u8 *header;
-		int rc;
-
-		header = efx_tsoh_get_buffer(tx_queue, buffer, st->header_len);
-		if (!header)
-			return -ENOMEM;
-
-		tsoh_th = (struct tcphdr *)(header + st->tcp_off);
-
-		/* Copy and update the headers. */
-		memcpy(header, skb->data, st->header_len);
-
-		tsoh_th->seq = htonl(st->seqnum);
-		((u8 *)tsoh_th)[13] &= ~tcp_flags_clear;
-
-		ip_length = st->ip_base_len + st->packet_space;
-
-		if (st->protocol == htons(ETH_P_IP)) {
-			struct iphdr *tsoh_iph =
-				(struct iphdr *)(header + st->ip_off);
-
-			tsoh_iph->tot_len = htons(ip_length);
-			tsoh_iph->id = htons(st->ipv4_id);
-		} else {
-			struct ipv6hdr *tsoh_iph =
-				(struct ipv6hdr *)(header + st->ip_off);
-
-			tsoh_iph->payload_len = htons(ip_length);
-		}
-
-		rc = efx_tso_put_header(tx_queue, buffer, header);
-		if (unlikely(rc))
-			return rc;
-	} else {
-		/* Send the original headers with a TSO option descriptor
-		 * in front
-		 */
-		u8 tcp_flags = ((u8 *)tcp_hdr(skb))[13] & ~tcp_flags_clear;
-
-		buffer->flags = EFX_TX_BUF_OPTION;
-		buffer->len = 0;
-		buffer->unmap_len = 0;
-		EFX_POPULATE_QWORD_5(buffer->option,
-				     ESF_DZ_TX_DESC_IS_OPT, 1,
-				     ESF_DZ_TX_OPTION_TYPE,
-				     ESE_DZ_TX_OPTION_DESC_TSO,
-				     ESF_DZ_TX_TSO_TCP_FLAGS, tcp_flags,
-				     ESF_DZ_TX_TSO_IP_ID, st->ipv4_id,
-				     ESF_DZ_TX_TSO_TCP_SEQNO, st->seqnum);
-		++tx_queue->insert_count;
-
-		/* We mapped the headers in tso_start().  Unmap them
-		 * when the last segment is completed.
-		 */
-		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
-		buffer->dma_addr = st->header_dma_addr;
-		buffer->len = st->header_len;
-		if (is_last) {
-			buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_MAP_SINGLE;
-			buffer->unmap_len = st->header_unmap_len;
-			buffer->dma_offset = 0;
-			/* Ensure we only unmap them once in case of a
-			 * later DMA mapping error and rollback
-			 */
-			st->header_unmap_len = 0;
-		} else {
-			buffer->flags = EFX_TX_BUF_CONT;
-			buffer->unmap_len = 0;
-		}
-		++tx_queue->insert_count;
-	}
-
-	st->seqnum += skb_shinfo(skb)->gso_size;
-
-	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
-	++st->ipv4_id;
-
-	++tx_queue->tso_packets;
-
-	++tx_queue->tx_packets;
-
-	return 0;
-}
-
-
-/**
- * efx_enqueue_skb_tso - segment and transmit a TSO socket buffer
- * @tx_queue:		Efx TX queue
- * @skb:		Socket buffer
- *
- * Context: You must hold netif_tx_lock() to call this function.
- *
- * Add socket buffer @skb to @tx_queue, doing TSO or return != 0 if
- * @skb was not enqueued.  In all cases @skb is consumed.  Return
- * %NETDEV_TX_OK.
- */
-static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
-			       struct sk_buff *skb)
-{
-	struct efx_nic *efx = tx_queue->efx;
-	unsigned int old_insert_count = tx_queue->insert_count;
-	int frag_i, rc;
-	struct tso_state state;
-
-	/* Find the packet protocol and sanity-check it */
-	state.protocol = efx_tso_check_protocol(skb);
-
-	rc = tso_start(&state, efx, tx_queue, skb);
-	if (rc)
-		goto mem_err;
-
-	if (likely(state.in_len == 0)) {
-		/* Grab the first payload fragment. */
-		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
-		frag_i = 0;
-		rc = tso_get_fragment(&state, efx,
-				      skb_shinfo(skb)->frags + frag_i);
-		if (rc)
-			goto mem_err;
-	} else {
-		/* Payload starts in the header area. */
-		frag_i = -1;
-	}
-
-	if (tso_start_new_packet(tx_queue, skb, &state) < 0)
-		goto mem_err;
-
-	while (1) {
-		tso_fill_packet_with_fragment(tx_queue, skb, &state);
-
-		/* Move onto the next fragment? */
-		if (state.in_len == 0) {
-			if (++frag_i >= skb_shinfo(skb)->nr_frags)
-				/* End of payload reached. */
-				break;
-			rc = tso_get_fragment(&state, efx,
-					      skb_shinfo(skb)->frags + frag_i);
-			if (rc)
-				goto mem_err;
-		}
-
-		/* Start at new packet? */
-		if (state.packet_space == 0 &&
-		    tso_start_new_packet(tx_queue, skb, &state) < 0)
-			goto mem_err;
-	}
-
-	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
-
-	efx_tx_maybe_stop_queue(tx_queue);
-
-	/* Pass off to hardware */
-	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq)) {
-		struct efx_tx_queue *txq2 = efx_tx_queue_partner(tx_queue);
-
-		/* There could be packets left on the partner queue if those
-		 * SKBs had skb->xmit_more set. If we do not push those they
-		 * could be left for a long time and cause a netdev watchdog.
-		 */
-		if (txq2->xmit_more_available)
-			efx_nic_push_buffers(txq2);
-
-		efx_nic_push_buffers(tx_queue);
-	} else {
-		tx_queue->xmit_more_available = skb->xmit_more;
-	}
-
-	tx_queue->tso_bursts++;
-	return NETDEV_TX_OK;
-
- mem_err:
-	netif_err(efx, tx_err, efx->net_dev,
-		  "Out of memory for TSO headers, or DMA mapping error\n");
-	dev_kfree_skb_any(skb);
-
-	/* Free the DMA mapping we were in the process of writing out */
-	if (state.unmap_len) {
-		if (state.dma_flags & EFX_TX_BUF_MAP_SINGLE)
-			dma_unmap_single(&efx->pci_dev->dev, state.unmap_addr,
-					 state.unmap_len, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(&efx->pci_dev->dev, state.unmap_addr,
-				       state.unmap_len, DMA_TO_DEVICE);
-	}
-
-	/* Free the header DMA mapping, if using option descriptors */
-	if (state.header_unmap_len)
-		dma_unmap_single(&efx->pci_dev->dev, state.header_dma_addr,
-				 state.header_unmap_len, DMA_TO_DEVICE);
-
-	efx_enqueue_unwind(tx_queue, old_insert_count);
-	return NETDEV_TX_OK;
-}
diff --git a/drivers/net/ethernet/sfc/tx.h b/drivers/net/ethernet/sfc/tx.h
new file mode 100644
index 0000000..1cccc97
--- /dev/null
+++ b/drivers/net/ethernet/sfc/tx.h
@@ -0,0 +1,27 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_TX_H
+#define EFX_TX_H
+
+#include <linux/types.h>
+
+/* Driver internal tx-path related declarations. */
+
+unsigned int efx_tx_limit_len(struct efx_tx_queue *tx_queue,
+			      dma_addr_t dma_addr, unsigned int len);
+
+u8 *efx_tx_get_copy_buffer_limited(struct efx_tx_queue *tx_queue,
+				   struct efx_tx_buffer *buffer, size_t len);
+
+int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue, struct sk_buff *skb,
+			bool *data_mapped);
+
+#endif /* EFX_TX_H */
diff --git a/drivers/net/ethernet/sfc/tx_tso.c b/drivers/net/ethernet/sfc/tx_tso.c
new file mode 100644
index 0000000..99936d7
--- /dev/null
+++ b/drivers/net/ethernet/sfc/tx_tso.c
@@ -0,0 +1,570 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/pci.h>
+#include <linux/tcp.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/ipv6.h>
+#include <linux/slab.h>
+#include <net/ipv6.h>
+#include <linux/if_ether.h>
+#include <linux/highmem.h>
+#include <linux/moduleparam.h>
+#include <linux/cache.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "io.h"
+#include "nic.h"
+#include "tx.h"
+#include "workarounds.h"
+#include "ef10_regs.h"
+
+/* Efx legacy TCP segmentation acceleration.
+ *
+ * Why?  Because by doing it here in the driver we can go significantly
+ * faster than the GSO.
+ *
+ * Requires TX checksum offload support.
+ */
+
+#define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
+
+/**
+ * struct tso_state - TSO state for an SKB
+ * @out_len: Remaining length in current segment
+ * @seqnum: Current sequence number
+ * @ipv4_id: Current IPv4 ID, host endian
+ * @packet_space: Remaining space in current packet
+ * @dma_addr: DMA address of current position
+ * @in_len: Remaining length in current SKB fragment
+ * @unmap_len: Length of SKB fragment
+ * @unmap_addr: DMA address of SKB fragment
+ * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
+ * @protocol: Network protocol (after any VLAN header)
+ * @ip_off: Offset of IP header
+ * @tcp_off: Offset of TCP header
+ * @header_len: Number of bytes of header
+ * @ip_base_len: IPv4 tot_len or IPv6 payload_len, before TCP payload
+ * @header_dma_addr: Header DMA address, when using option descriptors
+ * @header_unmap_len: Header DMA mapped length, or 0 if not using option
+ *	descriptors
+ *
+ * The state used during segmentation.  It is put into this data structure
+ * just to make it easy to pass into inline functions.
+ */
+struct tso_state {
+	/* Output position */
+	unsigned int out_len;
+	unsigned int seqnum;
+	u16 ipv4_id;
+	unsigned int packet_space;
+
+	/* Input position */
+	dma_addr_t dma_addr;
+	unsigned int in_len;
+	unsigned int unmap_len;
+	dma_addr_t unmap_addr;
+	unsigned short dma_flags;
+
+	__be16 protocol;
+	unsigned int ip_off;
+	unsigned int tcp_off;
+	unsigned int header_len;
+	unsigned int ip_base_len;
+	dma_addr_t header_dma_addr;
+	unsigned int header_unmap_len;
+};
+
+static inline void prefetch_ptr(struct efx_tx_queue *tx_queue)
+{
+	unsigned int insert_ptr = efx_tx_queue_get_insert_index(tx_queue);
+	char *ptr;
+
+	ptr = (char *) (tx_queue->buffer + insert_ptr);
+	prefetch(ptr);
+	prefetch(ptr + 0x80);
+
+	ptr = (char *) (((efx_qword_t *)tx_queue->txd.buf.addr) + insert_ptr);
+	prefetch(ptr);
+	prefetch(ptr + 0x80);
+}
+
+/**
+ * efx_tx_queue_insert - push descriptors onto the TX queue
+ * @tx_queue:		Efx TX queue
+ * @dma_addr:		DMA address of fragment
+ * @len:		Length of fragment
+ * @final_buffer:	The final buffer inserted into the queue
+ *
+ * Push descriptors onto the TX queue.
+ */
+static void efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
+				dma_addr_t dma_addr, unsigned int len,
+				struct efx_tx_buffer **final_buffer)
+{
+	struct efx_tx_buffer *buffer;
+	unsigned int dma_len;
+
+	EFX_BUG_ON_PARANOID(len <= 0);
+
+	while (1) {
+		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+		++tx_queue->insert_count;
+
+		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
+				    tx_queue->read_count >=
+				    tx_queue->efx->txq_entries);
+
+		buffer->dma_addr = dma_addr;
+
+		dma_len = tx_queue->efx->type->tx_limit_len(tx_queue,
+				dma_addr, len);
+
+		/* If there's space for everything this is our last buffer. */
+		if (dma_len >= len)
+			break;
+
+		buffer->len = dma_len;
+		buffer->flags = EFX_TX_BUF_CONT;
+		dma_addr += dma_len;
+		len -= dma_len;
+	}
+
+	EFX_BUG_ON_PARANOID(!len);
+	buffer->len = len;
+	*final_buffer = buffer;
+}
+
+/*
+ * Verify that our various assumptions about sk_buffs and the conditions
+ * under which TSO will be attempted hold true.  Return the protocol number.
+ */
+static __be16 efx_tso_check_protocol(struct sk_buff *skb)
+{
+	__be16 protocol = skb->protocol;
+
+	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
+			    protocol);
+	if (protocol == htons(ETH_P_8021Q)) {
+		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
+
+		protocol = veh->h_vlan_encapsulated_proto;
+	}
+
+	if (protocol == htons(ETH_P_IP)) {
+		EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+	} else {
+		EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IPV6));
+		EFX_BUG_ON_PARANOID(ipv6_hdr(skb)->nexthdr != NEXTHDR_TCP);
+	}
+	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
+			     + (tcp_hdr(skb)->doff << 2u)) >
+			    skb_headlen(skb));
+
+	return protocol;
+}
+
+static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
+			       struct efx_tx_buffer *buffer, unsigned int len)
+{
+	u8 *result;
+
+	EFX_BUG_ON_PARANOID(buffer->len);
+	EFX_BUG_ON_PARANOID(buffer->flags);
+	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+
+	result = efx_tx_get_copy_buffer_limited(tx_queue, buffer, len);
+
+	if (result) {
+		buffer->flags = EFX_TX_BUF_CONT;
+	} else {
+		buffer->heap_buf = kmalloc(NET_IP_ALIGN + len, GFP_ATOMIC);
+		if (unlikely(!buffer->heap_buf))
+			return NULL;
+		tx_queue->tso_long_headers++;
+		result = (u8 *)buffer->heap_buf + NET_IP_ALIGN;
+		buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_HEAP;
+	}
+
+	buffer->len = len;
+
+	return result;
+}
+
+/*
+ * Put a TSO header into the TX queue.
+ *
+ * This is special-cased because we know that it is small enough to fit in
+ * a single fragment, and we know it doesn't cross a page boundary.  It
+ * also allows us to not worry about end-of-packet etc.
+ */
+static int efx_tso_put_header(struct efx_tx_queue *tx_queue,
+			      struct efx_tx_buffer *buffer, u8 *header)
+{
+	if (unlikely(buffer->flags & EFX_TX_BUF_HEAP)) {
+		buffer->dma_addr = dma_map_single(&tx_queue->efx->pci_dev->dev,
+						  header, buffer->len,
+						  DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(&tx_queue->efx->pci_dev->dev,
+					       buffer->dma_addr))) {
+			kfree(buffer->heap_buf);
+			buffer->len = 0;
+			buffer->flags = 0;
+			return -ENOMEM;
+		}
+		buffer->unmap_len = buffer->len;
+		buffer->dma_offset = 0;
+		buffer->flags |= EFX_TX_BUF_MAP_SINGLE;
+	}
+
+	++tx_queue->insert_count;
+	return 0;
+}
+
+
+/* Parse the SKB header and initialise state. */
+static int tso_start(struct tso_state *st, struct efx_nic *efx,
+		     struct efx_tx_queue *tx_queue,
+		     const struct sk_buff *skb)
+{
+	struct device *dma_dev = &efx->pci_dev->dev;
+	unsigned int header_len, in_len;
+	bool use_opt_desc = false;
+	dma_addr_t dma_addr;
+
+	if (tx_queue->tso_version == 1)
+		use_opt_desc = true;
+
+	st->ip_off = skb_network_header(skb) - skb->data;
+	st->tcp_off = skb_transport_header(skb) - skb->data;
+	header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
+	in_len = skb_headlen(skb) - header_len;
+	st->header_len = header_len;
+	st->in_len = in_len;
+	if (st->protocol == htons(ETH_P_IP)) {
+		st->ip_base_len = st->header_len - st->ip_off;
+		st->ipv4_id = ntohs(ip_hdr(skb)->id);
+	} else {
+		st->ip_base_len = st->header_len - st->tcp_off;
+		st->ipv4_id = 0;
+	}
+	st->seqnum = ntohl(tcp_hdr(skb)->seq);
+
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
+
+	st->out_len = skb->len - header_len;
+
+	if (!use_opt_desc) {
+		st->header_unmap_len = 0;
+
+		if (likely(in_len == 0)) {
+			st->dma_flags = 0;
+			st->unmap_len = 0;
+			return 0;
+		}
+
+		dma_addr = dma_map_single(dma_dev, skb->data + header_len,
+					  in_len, DMA_TO_DEVICE);
+		st->dma_flags = EFX_TX_BUF_MAP_SINGLE;
+		st->dma_addr = dma_addr;
+		st->unmap_addr = dma_addr;
+		st->unmap_len = in_len;
+	} else {
+		dma_addr = dma_map_single(dma_dev, skb->data,
+					  skb_headlen(skb), DMA_TO_DEVICE);
+		st->header_dma_addr = dma_addr;
+		st->header_unmap_len = skb_headlen(skb);
+		st->dma_flags = 0;
+		st->dma_addr = dma_addr + header_len;
+		st->unmap_len = 0;
+	}
+
+	return unlikely(dma_mapping_error(dma_dev, dma_addr)) ? -ENOMEM : 0;
+}
+
+static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
+			    skb_frag_t *frag)
+{
+	st->unmap_addr = skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
+					  skb_frag_size(frag), DMA_TO_DEVICE);
+	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
+		st->dma_flags = 0;
+		st->unmap_len = skb_frag_size(frag);
+		st->in_len = skb_frag_size(frag);
+		st->dma_addr = st->unmap_addr;
+		return 0;
+	}
+	return -ENOMEM;
+}
+
+
+/**
+ * tso_fill_packet_with_fragment - form descriptors for the current fragment
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Form descriptors for the current fragment, until we reach the end
+ * of fragment or end-of-packet.
+ */
+static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
+					  const struct sk_buff *skb,
+					  struct tso_state *st)
+{
+	struct efx_tx_buffer *buffer;
+	int n;
+
+	if (st->in_len == 0)
+		return;
+	if (st->packet_space == 0)
+		return;
+
+	EFX_BUG_ON_PARANOID(st->in_len <= 0);
+	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
+
+	n = min(st->in_len, st->packet_space);
+
+	st->packet_space -= n;
+	st->out_len -= n;
+	st->in_len -= n;
+
+	efx_tx_queue_insert(tx_queue, st->dma_addr, n, &buffer);
+
+	if (st->out_len == 0) {
+		/* Transfer ownership of the skb */
+		buffer->skb = skb;
+		buffer->flags = EFX_TX_BUF_SKB;
+	} else if (st->packet_space != 0) {
+		buffer->flags = EFX_TX_BUF_CONT;
+	}
+
+	if (st->in_len == 0) {
+		/* Transfer ownership of the DMA mapping */
+		buffer->unmap_len = st->unmap_len;
+		buffer->dma_offset = buffer->unmap_len - buffer->len;
+		buffer->flags |= st->dma_flags;
+		st->unmap_len = 0;
+	}
+
+	st->dma_addr += n;
+}
+
+
+#define TCP_FLAGS_OFFSET 13
+
+/**
+ * tso_start_new_packet - generate a new header and prepare for the new packet
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Generate a new header and prepare for the new packet.  Return 0 on
+ * success, or -%ENOMEM if failed to alloc header.
+ */
+static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
+				const struct sk_buff *skb,
+				struct tso_state *st)
+{
+	struct efx_tx_buffer *buffer =
+		efx_tx_queue_get_insert_buffer(tx_queue);
+	bool is_last = st->out_len <= skb_shinfo(skb)->gso_size;
+	u8 tcp_flags_mask;
+
+	if (!is_last) {
+		st->packet_space = skb_shinfo(skb)->gso_size;
+		tcp_flags_mask = 0x09; /* mask out FIN and PSH */
+	} else {
+		st->packet_space = st->out_len;
+		tcp_flags_mask = 0x00;
+	}
+
+	if (!st->header_unmap_len) {
+		/* Allocate and insert a DMA-mapped header buffer. */
+		struct tcphdr *tsoh_th;
+		unsigned int ip_length;
+		u8 *header;
+		int rc;
+
+		header = efx_tsoh_get_buffer(tx_queue, buffer, st->header_len);
+		if (!header)
+			return -ENOMEM;
+
+		tsoh_th = (struct tcphdr *)(header + st->tcp_off);
+
+		/* Copy and update the headers. */
+		memcpy(header, skb->data, st->header_len);
+
+		tsoh_th->seq = htonl(st->seqnum);
+		((u8 *)tsoh_th)[TCP_FLAGS_OFFSET] &= ~tcp_flags_mask;
+
+		ip_length = st->ip_base_len + st->packet_space;
+
+		if (st->protocol == htons(ETH_P_IP)) {
+			struct iphdr *tsoh_iph =
+				(struct iphdr *)(header + st->ip_off);
+
+			tsoh_iph->tot_len = htons(ip_length);
+			tsoh_iph->id = htons(st->ipv4_id);
+		} else {
+			struct ipv6hdr *tsoh_iph =
+				(struct ipv6hdr *)(header + st->ip_off);
+
+			tsoh_iph->payload_len = htons(ip_length);
+		}
+
+		rc = efx_tso_put_header(tx_queue, buffer, header);
+		if (unlikely(rc))
+			return rc;
+	} else {
+		/* Send the original headers with a TSO option descriptor
+		 * in front
+		 */
+		u8 tcp_flags = ((u8 *)tcp_hdr(skb))[TCP_FLAGS_OFFSET] &
+				~tcp_flags_mask;
+
+		buffer->flags = EFX_TX_BUF_OPTION;
+		buffer->len = 0;
+		buffer->unmap_len = 0;
+		EFX_POPULATE_QWORD_5(buffer->option,
+				     ESF_DZ_TX_DESC_IS_OPT, 1,
+				     ESF_DZ_TX_OPTION_TYPE,
+				     ESE_DZ_TX_OPTION_DESC_TSO,
+				     ESF_DZ_TX_TSO_TCP_FLAGS, tcp_flags,
+				     ESF_DZ_TX_TSO_IP_ID, st->ipv4_id,
+				     ESF_DZ_TX_TSO_TCP_SEQNO, st->seqnum);
+		++tx_queue->insert_count;
+
+		/* We mapped the headers in tso_start().  Unmap them
+		 * when the last segment is completed.
+		 */
+		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+		buffer->dma_addr = st->header_dma_addr;
+		buffer->len = st->header_len;
+		if (is_last) {
+			buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_MAP_SINGLE;
+			buffer->unmap_len = st->header_unmap_len;
+			buffer->dma_offset = 0;
+			/* Ensure we only unmap them once in case of a
+			 * later DMA mapping error and rollback
+			 */
+			st->header_unmap_len = 0;
+		} else {
+			buffer->flags = EFX_TX_BUF_CONT;
+			buffer->unmap_len = 0;
+		}
+		++tx_queue->insert_count;
+	}
+
+	st->seqnum += skb_shinfo(skb)->gso_size;
+
+	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
+	++st->ipv4_id;
+
+	return 0;
+}
+
+/**
+ * efx_enqueue_skb_tso - segment and transmit a TSO socket buffer
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @data_mapped:        Did we map the data? Always set to true
+ *                      by this on success.
+ *
+ * Context: You must hold netif_tx_lock() to call this function.
+ *
+ * Add socket buffer @skb to @tx_queue, doing TSO or return != 0 if
+ * @skb was not enqueued.  In all cases @skb is consumed.  Return
+ * %NETDEV_TX_OK.
+ */
+int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
+			struct sk_buff *skb,
+			bool *data_mapped)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	int frag_i, rc;
+	struct tso_state state;
+
+	prefetch(skb->data);
+
+	/* Find the packet protocol and sanity-check it */
+	state.protocol = efx_tso_check_protocol(skb);
+
+	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
+
+	rc = tso_start(&state, efx, tx_queue, skb);
+	if (rc)
+		goto mem_err;
+
+	if (likely(state.in_len == 0)) {
+		/* Grab the first payload fragment. */
+		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
+		frag_i = 0;
+		rc = tso_get_fragment(&state, efx,
+				      skb_shinfo(skb)->frags + frag_i);
+		if (rc)
+			goto mem_err;
+	} else {
+		/* Payload starts in the header area. */
+		frag_i = -1;
+	}
+
+	if (tso_start_new_packet(tx_queue, skb, &state) < 0)
+		goto mem_err;
+
+	prefetch_ptr(tx_queue);
+
+	while (1) {
+		tso_fill_packet_with_fragment(tx_queue, skb, &state);
+
+		/* Move onto the next fragment? */
+		if (state.in_len == 0) {
+			if (++frag_i >= skb_shinfo(skb)->nr_frags)
+				/* End of payload reached. */
+				break;
+			rc = tso_get_fragment(&state, efx,
+					      skb_shinfo(skb)->frags + frag_i);
+			if (rc)
+				goto mem_err;
+		}
+
+		/* Start at new packet? */
+		if (state.packet_space == 0 &&
+		    tso_start_new_packet(tx_queue, skb, &state) < 0)
+			goto mem_err;
+	}
+
+	*data_mapped = true;
+
+	return 0;
+
+ mem_err:
+	netif_err(efx, tx_err, efx->net_dev,
+		  "Out of memory for TSO headers, or DMA mapping error\n");
+
+	/* Free the DMA mapping we were in the process of writing out */
+	if (state.unmap_len) {
+		if (state.dma_flags & EFX_TX_BUF_MAP_SINGLE)
+			dma_unmap_single(&efx->pci_dev->dev, state.unmap_addr,
+					 state.unmap_len, DMA_TO_DEVICE);
+		else
+			dma_unmap_page(&efx->pci_dev->dev, state.unmap_addr,
+				       state.unmap_len, DMA_TO_DEVICE);
+	}
+
+	/* Free the header DMA mapping, if using option descriptors */
+	if (state.header_unmap_len)
+		dma_unmap_single(&efx->pci_dev->dev, state.header_dma_addr,
+				 state.header_unmap_len, DMA_TO_DEVICE);
+
+	return -ENOMEM;
+}
