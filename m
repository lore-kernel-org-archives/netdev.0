From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: allow PIO more often
Date: Fri, 13 Jan 2017 21:20:14 +0000
Message-ID: <c1f48c4b-234f-e7ac-ab66-08694d2e92c6@solarflare.com>
References: <eae20bb1-89d4-0e81-6c56-0c7058d06ada@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:26585 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751092AbdAMVUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 16:20:45 -0500
In-Reply-To: <eae20bb1-89d4-0e81-6c56-0c7058d06ada@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an option descriptor has been sent on a queue but not followed by a
 packet, there will have been no completion event, so the read and write
 counts won't match and we'll think we can't do PIO.  This combines with
 the fact that we have two TX queues (for en/disable checksum offload),
 and that both must be empty for PIO to happen.
This patch adds a separate "packet_write_count" that tracks the most
 recent write_count we expect to see a completion event for; this excludes
 option descriptors but _includes_ PIO descriptors (even though they look
 like option descriptors).  This is then used, rather than write_count,
 in efx_nic_tx_is_empty().
We only bother to maintain packet_write_count on EF10, since on Siena
 (a) there are no option descriptors and it always equals write_count, and
 (b) there's no PIO, so we don't need it anyway.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  5 +++++
 drivers/net/ethernet/sfc/net_driver.h |  9 +++++++++
 drivers/net/ethernet/sfc/nic.h        | 17 ++++++++++++++---
 drivers/net/ethernet/sfc/siena.c      |  1 +
 drivers/net/ethernet/sfc/tx.c         |  1 +
 5 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 208e004..f6e29a9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2358,7 +2358,11 @@ static void efx_ef10_tx_write(struct efx_tx_queue *tx_queue)
 		/* Create TX descriptor ring entry */
 		if (buffer->flags & EFX_TX_BUF_OPTION) {
 			*txd = buffer->option;
+			if (EFX_QWORD_FIELD(*txd, ESF_DZ_TX_OPTION_TYPE) == 1)
+				/* PIO descriptor */
+				tx_queue->packet_write_count = tx_queue->write_count;
 		} else {
+			tx_queue->packet_write_count = tx_queue->write_count;
 			BUILD_BUG_ON(EFX_TX_BUF_CONT != 1);
 			EFX_POPULATE_QWORD_3(
 				*txd,
@@ -5796,6 +5800,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.rx_ts_offset = ES_DZ_RX_PREFIX_TSTAMP_OFST,
 	.can_rx_scatter = true,
 	.always_rx_scatter = true,
+	.option_descriptors = true,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
 	.offload_features = EF10_OFFLOAD_FEATURES,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 49db9e8..b20fe43 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -208,6 +208,12 @@ struct efx_tx_buffer {
  * @write_count: Current write pointer
  *	This is the number of buffers that have been added to the
  *	hardware ring.
+ * @packet_write_count: Completable write pointer
+ *	This is the write pointer of the last packet written.
+ *	Normally this will equal @write_count, but as option descriptors
+ *	don't produce completion events, they won't update this.
+ *	Filled in iff @efx->type->option_descriptors; only used for PIO.
+ *	Thus, this is written and used on EF10, and neither on farch.
  * @old_read_count: The value of read_count when last checked.
  *	This is here for performance reasons.  The xmit path will
  *	only get the up-to-date value of read_count if this
@@ -255,6 +261,7 @@ struct efx_tx_queue {
 	/* Members used only on the xmit path */
 	unsigned int insert_count ____cacheline_aligned_in_smp;
 	unsigned int write_count;
+	unsigned int packet_write_count;
 	unsigned int old_read_count;
 	unsigned int tso_bursts;
 	unsigned int tso_long_headers;
@@ -1237,6 +1244,7 @@ struct efx_mtd_partition {
  * @rx_buffer_padding: Size of padding at end of RX packet
  * @can_rx_scatter: NIC is able to scatter packets to multiple buffers
  * @always_rx_scatter: NIC will always scatter packets to multiple buffers
+ * @option_descriptors: NIC supports TX option descriptors
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
  * @timer_period_max: Maximum period of interrupt timer (in ticks)
@@ -1395,6 +1403,7 @@ struct efx_nic_type {
 	unsigned int rx_buffer_padding;
 	bool can_rx_scatter;
 	bool always_rx_scatter;
+	bool option_descriptors;
 	unsigned int max_interrupt_mode;
 	unsigned int timer_period_max;
 	netdev_features_t offload_features;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 2237746..6a69aa3 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -85,6 +85,17 @@ static inline bool __efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue,
 	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
 }
 
+/* Report whether the NIC considers this TX queue empty, using
+ * packet_write_count (the write count recorded for the last completable
+ * doorbell push).  May return false negative.  EF10 only, which is OK
+ * because only EF10 supports PIO.
+ */
+static inline bool efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue)
+{
+	EFX_WARN_ON_ONCE_PARANOID(!tx_queue->efx->type->option_descriptors);
+	return __efx_nic_tx_is_empty(tx_queue, tx_queue->packet_write_count);
+}
+
 /* Decide whether we can use TX PIO, ie. write packet data directly into
  * a buffer on the device.  This can reduce latency at the expense of
  * throughput, so we only do this if both hardware and software TX rings
@@ -94,9 +105,9 @@ static inline bool __efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue,
 static inline bool efx_nic_may_tx_pio(struct efx_tx_queue *tx_queue)
 {
 	struct efx_tx_queue *partner = efx_tx_queue_partner(tx_queue);
-	return tx_queue->piobuf &&
-	       __efx_nic_tx_is_empty(tx_queue, tx_queue->insert_count) &&
-	       __efx_nic_tx_is_empty(partner, partner->insert_count);
+
+	return tx_queue->piobuf && efx_nic_tx_is_empty(tx_queue) &&
+	       efx_nic_tx_is_empty(partner);
 }
 
 /* Decide whether to push a TX descriptor to the NIC vs merely writing
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 4e54e5d..118ff56 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1044,6 +1044,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.rx_hash_offset = FS_BZ_RX_PREFIX_HASH_OFST,
 	.rx_buffer_padding = 0,
 	.can_rx_scatter = true,
+	.option_descriptors = false,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << FRF_CZ_TC_TIMER_VAL_WIDTH,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3c01514..beaf980 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -817,6 +817,7 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 
 	tx_queue->insert_count = 0;
 	tx_queue->write_count = 0;
+	tx_queue->packet_write_count = 0;
 	tx_queue->old_write_count = 0;
 	tx_queue->read_count = 0;
 	tx_queue->old_read_count = 0;
