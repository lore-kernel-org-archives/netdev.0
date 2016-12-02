From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: remove EFX_BUG_ON_PARANOID, use
 EFX_WARN_ON_[ONCE_]PARANOID instead
Date: Fri, 2 Dec 2016 15:51:33 +0000
Message-ID: <9435baa4-b9b5-955e-eac2-3106feb87136@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:51818 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752087AbcLBPvz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:51:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Logically, EFX_BUG_ON_PARANOID can never be correct.  For, BUG_ON should
 only be used if it is not possible to continue without potential harm;
 and since the non-DEBUG driver will continue regardless (as the BUG_ON is
 compiled out), clearly the BUG_ON cannot be needed in the DEBUG driver.
So, replace every EFX_BUG_ON_PARANOID with either an EFX_WARN_ON_PARANOID
 or the newly defined EFX_WARN_ON_ONCE_PARANOID.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  2 +-
 drivers/net/ethernet/sfc/efx.c        |  2 +-
 drivers/net/ethernet/sfc/ethtool.c    |  4 ++--
 drivers/net/ethernet/sfc/farch.c      |  6 ++---
 drivers/net/ethernet/sfc/mcdi.h       |  4 ++--
 drivers/net/ethernet/sfc/mcdi_mon.c   |  4 ++--
 drivers/net/ethernet/sfc/mcdi_port.c  |  2 +-
 drivers/net/ethernet/sfc/net_driver.h | 22 +++++++++----------
 drivers/net/ethernet/sfc/ptp.c        |  2 +-
 drivers/net/ethernet/sfc/rx.c         |  8 +++----
 drivers/net/ethernet/sfc/siena.c      |  2 +-
 drivers/net/ethernet/sfc/tx.c         | 12 +++++-----
 drivers/net/ethernet/sfc/tx_tso.c     | 41 +++++++++++++++++------------------
 13 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 0f58ea8..de2947c 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2100,7 +2100,7 @@ static int efx_ef10_tx_tso_desc(struct efx_tx_queue *tx_queue,
 	u32 seqnum;
 	u32 mss;
 
-	EFX_BUG_ON_PARANOID(tx_queue->tso_version != 2);
+	EFX_WARN_ON_ONCE_PARANOID(tx_queue->tso_version != 2);
 
 	mss = skb_shinfo(skb)->gso_size;
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index da7028d..5a5dcad 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -355,7 +355,7 @@ static int efx_probe_eventq(struct efx_channel *channel)
 	/* Build an event queue with room for one event per tx and rx buffer,
 	 * plus some extra for link state events and MCDI completions. */
 	entries = roundup_pow_of_two(efx->rxq_entries + efx->txq_entries + 128);
-	EFX_BUG_ON_PARANOID(entries > EFX_MAX_EVQ_SIZE);
+	EFX_WARN_ON_PARANOID(entries > EFX_MAX_EVQ_SIZE);
 	channel->eventq_mask = max(entries, EFX_MIN_EVQ_SIZE) - 1;
 
 	return efx_nic_probe_eventq(channel);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index ca29d3d..f644216 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -333,12 +333,12 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 		      "core", 0, "registers", NULL);
 
 	if (efx->phy_op->run_tests != NULL) {
-		EFX_BUG_ON_PARANOID(efx->phy_op->test_name == NULL);
+		EFX_WARN_ON_PARANOID(efx->phy_op->test_name == NULL);
 
 		for (i = 0; true; ++i) {
 			const char *name;
 
-			EFX_BUG_ON_PARANOID(i >= EFX_MAX_PHY_TESTS);
+			EFX_WARN_ON_PARANOID(i >= EFX_MAX_PHY_TESTS);
 			name = efx->phy_op->test_name(efx, i);
 			if (name == NULL)
 				break;
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 91aa3ec..e4ca216 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -177,7 +177,7 @@ efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	dma_addr_t dma_addr;
 	int i;
 
-	EFX_BUG_ON_PARANOID(!buffer->buf.addr);
+	EFX_WARN_ON_PARANOID(!buffer->buf.addr);
 
 	/* Write buffer descriptors to NIC */
 	for (i = 0; i < buffer->entries; i++) {
@@ -332,7 +332,7 @@ void efx_farch_tx_write(struct efx_tx_queue *tx_queue)
 		txd = efx_tx_desc(tx_queue, write_ptr);
 		++tx_queue->write_count;
 
-		EFX_BUG_ON_PARANOID(buffer->flags & EFX_TX_BUF_OPTION);
+		EFX_WARN_ON_ONCE_PARANOID(buffer->flags & EFX_TX_BUF_OPTION);
 
 		/* Create TX descriptor ring entry */
 		BUILD_BUG_ON(EFX_TX_BUF_CONT != 1);
@@ -2041,7 +2041,7 @@ efx_farch_filter_from_gen_spec(struct efx_farch_filter_spec *spec,
 		__be32 rhost, host1, host2;
 		__be16 rport, port1, port2;
 
-		EFX_BUG_ON_PARANOID(!(gen_spec->flags & EFX_FILTER_FLAG_RX));
+		EFX_WARN_ON_PARANOID(!(gen_spec->flags & EFX_FILTER_FLAG_RX));
 
 		if (gen_spec->ether_type != htons(ETH_P_IP))
 			return -EPROTONOSUPPORT;
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index c9aeb07..4472107 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -129,14 +129,14 @@ struct efx_mcdi_data {
 
 static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
 {
-	EFX_BUG_ON_PARANOID(!efx->mcdi);
+	EFX_WARN_ON_PARANOID(!efx->mcdi);
 	return &efx->mcdi->iface;
 }
 
 #ifdef CONFIG_SFC_MCDI_MON
 static inline struct efx_mcdi_mon *efx_mcdi_mon(struct efx_nic *efx)
 {
-	EFX_BUG_ON_PARANOID(!efx->mcdi);
+	EFX_WARN_ON_PARANOID(!efx->mcdi);
 	return &efx->mcdi->hwmon;
 }
 #endif
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index bc27d5b..f97da05 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -121,9 +121,9 @@ void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
 	}
 	if (!name)
 		name = "No sensor name available";
-	EFX_BUG_ON_PARANOID(state >= ARRAY_SIZE(sensor_status_names));
+	EFX_WARN_ON_PARANOID(state >= ARRAY_SIZE(sensor_status_names));
 	state_txt = sensor_status_names[state];
-	EFX_BUG_ON_PARANOID(hwmon_type >= EFX_HWMON_TYPES_COUNT);
+	EFX_WARN_ON_PARANOID(hwmon_type >= EFX_HWMON_TYPES_COUNT);
 	unit = efx_hwmon_unit[hwmon_type];
 	if (!unit)
 		unit = "";
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 0f0eb27..9dcd396 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -840,7 +840,7 @@ void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)
 	u32 flags, fcntl, speed, lpa;
 
 	speed = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_SPEED);
-	EFX_BUG_ON_PARANOID(speed >= ARRAY_SIZE(efx_mcdi_event_link_speed));
+	EFX_WARN_ON_PARANOID(speed >= ARRAY_SIZE(efx_mcdi_event_link_speed));
 	speed = efx_mcdi_event_link_speed[speed];
 
 	flags = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LINK_FLAGS);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0bbd7e2..8692e82 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -44,10 +44,10 @@
 #define EFX_DRIVER_VERSION	"4.1"
 
 #ifdef DEBUG
-#define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
+#define EFX_WARN_ON_ONCE_PARANOID(x) WARN_ON_ONCE(x)
 #define EFX_WARN_ON_PARANOID(x) WARN_ON(x)
 #else
-#define EFX_BUG_ON_PARANOID(x) do {} while (0)
+#define EFX_WARN_ON_ONCE_PARANOID(x) do {} while (0)
 #define EFX_WARN_ON_PARANOID(x) do {} while (0)
 #endif
 
@@ -1409,7 +1409,7 @@ struct efx_nic_type {
 static inline struct efx_channel *
 efx_get_channel(struct efx_nic *efx, unsigned index)
 {
-	EFX_BUG_ON_PARANOID(index >= efx->n_channels);
+	EFX_WARN_ON_ONCE_PARANOID(index >= efx->n_channels);
 	return efx->channel[index];
 }
 
@@ -1430,8 +1430,8 @@ efx_get_channel(struct efx_nic *efx, unsigned index)
 static inline struct efx_tx_queue *
 efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
 {
-	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
-			    type >= EFX_TXQ_TYPES);
+	EFX_WARN_ON_ONCE_PARANOID(index >= efx->n_tx_channels ||
+				  type >= EFX_TXQ_TYPES);
 	return &efx->channel[efx->tx_channel_offset + index]->tx_queue[type];
 }
 
@@ -1444,8 +1444,8 @@ static inline bool efx_channel_has_tx_queues(struct efx_channel *channel)
 static inline struct efx_tx_queue *
 efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
 {
-	EFX_BUG_ON_PARANOID(!efx_channel_has_tx_queues(channel) ||
-			    type >= EFX_TXQ_TYPES);
+	EFX_WARN_ON_ONCE_PARANOID(!efx_channel_has_tx_queues(channel) ||
+				  type >= EFX_TXQ_TYPES);
 	return &channel->tx_queue[type];
 }
 
@@ -1482,7 +1482,7 @@ static inline bool efx_channel_has_rx_queue(struct efx_channel *channel)
 static inline struct efx_rx_queue *
 efx_channel_get_rx_queue(struct efx_channel *channel)
 {
-	EFX_BUG_ON_PARANOID(!efx_channel_has_rx_queue(channel));
+	EFX_WARN_ON_ONCE_PARANOID(!efx_channel_has_rx_queue(channel));
 	return &channel->rx_queue;
 }
 
@@ -1578,9 +1578,9 @@ efx_tx_queue_get_insert_buffer(const struct efx_tx_queue *tx_queue)
 	struct efx_tx_buffer *buffer =
 		__efx_tx_queue_get_insert_buffer(tx_queue);
 
-	EFX_BUG_ON_PARANOID(buffer->len);
-	EFX_BUG_ON_PARANOID(buffer->flags);
-	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+	EFX_WARN_ON_ONCE_PARANOID(buffer->len);
+	EFX_WARN_ON_ONCE_PARANOID(buffer->flags);
+	EFX_WARN_ON_ONCE_PARANOID(buffer->unmap_len);
 
 	return buffer;
 }
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 77a5364..60cdb97 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -835,7 +835,7 @@ static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 	ACCESS_ONCE(*start) = 0;
 	rc = efx_mcdi_rpc_start(efx, MC_CMD_PTP, synch_buf,
 				MC_CMD_PTP_IN_SYNCHRONIZE_LEN);
-	EFX_BUG_ON_PARANOID(rc);
+	EFX_WARN_ON_ONCE_PARANOID(rc);
 
 	/* Wait for start from MCDI (or timeout) */
 	timeout = jiffies + msecs_to_jiffies(MAX_SYNCHRONISE_WAIT_MS);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 7893a73..5f4ad4f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -335,7 +335,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic)
 
 	/* Calculate current fill level, and exit if we don't need to fill */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
-	EFX_BUG_ON_PARANOID(fill_level > rx_queue->efx->rxq_entries);
+	EFX_WARN_ON_ONCE_PARANOID(fill_level > rx_queue->efx->rxq_entries);
 	if (fill_level >= rx_queue->fast_fill_trigger)
 		goto out;
 
@@ -347,7 +347,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic)
 
 	batch_size = efx->rx_pages_per_batch * efx->rx_bufs_per_page;
 	space = rx_queue->max_fill - fill_level;
-	EFX_BUG_ON_PARANOID(space < batch_size);
+	EFX_WARN_ON_ONCE_PARANOID(space < batch_size);
 
 	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
 		   "RX queue %d fast-filling descriptor ring from"
@@ -475,7 +475,7 @@ static struct sk_buff *efx_rx_mk_skb(struct efx_channel *channel,
 		return NULL;
 	}
 
-	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
+	EFX_WARN_ON_ONCE_PARANOID(rx_buf->len < hdr_len);
 
 	memcpy(skb->data + efx->rx_ip_align, eh - efx->rx_prefix_size,
 	       efx->rx_prefix_size + hdr_len);
@@ -682,7 +682,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 
 	/* Create the smallest power-of-two aligned ring */
 	entries = max(roundup_pow_of_two(efx->rxq_entries), EFX_MIN_DMAQ_SIZE);
-	EFX_BUG_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
+	EFX_WARN_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
 	rx_queue->ptr_mask = entries - 1;
 
 	netif_dbg(efx, probe, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 0c4a8dd..a3901bc 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -717,7 +717,7 @@ static void siena_mcdi_request(struct efx_nic *efx,
 	unsigned int i;
 	unsigned int inlen_dw = DIV_ROUND_UP(sdu_len, 4);
 
-	EFX_BUG_ON_PARANOID(hdr_len != 4);
+	EFX_WARN_ON_PARANOID(hdr_len != 4);
 
 	efx_writed(efx, hdr, pdu);
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index f11a36a..3c01514 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -142,7 +142,7 @@ static void efx_tx_maybe_stop_queue(struct efx_tx_queue *txq1)
 
 	fill_level = max(txq1->insert_count - txq1->old_read_count,
 			 txq2->insert_count - txq2->old_read_count);
-	EFX_BUG_ON_PARANOID(fill_level >= efx->txq_entries);
+	EFX_WARN_ON_ONCE_PARANOID(fill_level >= efx->txq_entries);
 	if (likely(fill_level < efx->txq_stop_thresh)) {
 		smp_mb();
 		if (likely(!efx->loopback_selftest))
@@ -158,7 +158,7 @@ static int efx_enqueue_skb_copy(struct efx_tx_queue *tx_queue,
 	u8 *copy_buffer;
 	int rc;
 
-	EFX_BUG_ON_PARANOID(copy_len > EFX_TX_CB_SIZE);
+	EFX_WARN_ON_ONCE_PARANOID(copy_len > EFX_TX_CB_SIZE);
 
 	buffer = efx_tx_queue_get_insert_buffer(tx_queue);
 
@@ -268,7 +268,7 @@ static void efx_skb_copy_bits_to_pio(struct efx_nic *efx, struct sk_buff *skb,
 		kunmap_atomic(vaddr);
 	}
 
-	EFX_BUG_ON_PARANOID(skb_shinfo(skb)->frag_list);
+	EFX_WARN_ON_ONCE_PARANOID(skb_shinfo(skb)->frag_list);
 }
 
 static int efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue,
@@ -503,7 +503,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	 * size limit.
 	 */
 	if (segments) {
-		EFX_BUG_ON_PARANOID(!tx_queue->handle_tso);
+		EFX_WARN_ON_ONCE_PARANOID(!tx_queue->handle_tso);
 		rc = tx_queue->handle_tso(tx_queue, skb, &data_mapped);
 		if (rc == -EINVAL) {
 			rc = efx_tx_tso_fallback(tx_queue, skb);
@@ -724,7 +724,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	struct efx_tx_queue *txq2;
 	unsigned int pkts_compl = 0, bytes_compl = 0;
 
-	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
+	EFX_WARN_ON_ONCE_PARANOID(index > tx_queue->ptr_mask);
 
 	efx_dequeue_buffers(tx_queue, index, &pkts_compl, &bytes_compl);
 	tx_queue->pkts_compl += pkts_compl;
@@ -772,7 +772,7 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 
 	/* Create the smallest power-of-two aligned ring */
 	entries = max(roundup_pow_of_two(efx->txq_entries), EFX_MIN_DMAQ_SIZE);
-	EFX_BUG_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
+	EFX_WARN_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
 	tx_queue->ptr_mask = entries - 1;
 
 	netif_dbg(efx, probe, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/tx_tso.c b/drivers/net/ethernet/sfc/tx_tso.c
index 6032887..e0cbda9 100644
--- a/drivers/net/ethernet/sfc/tx_tso.c
+++ b/drivers/net/ethernet/sfc/tx_tso.c
@@ -109,15 +109,15 @@ static void efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 	struct efx_tx_buffer *buffer;
 	unsigned int dma_len;
 
-	EFX_BUG_ON_PARANOID(len <= 0);
+	EFX_WARN_ON_ONCE_PARANOID(len <= 0);
 
 	while (1) {
 		buffer = efx_tx_queue_get_insert_buffer(tx_queue);
 		++tx_queue->insert_count;
 
-		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
-				    tx_queue->read_count >=
-				    tx_queue->efx->txq_entries);
+		EFX_WARN_ON_ONCE_PARANOID(tx_queue->insert_count -
+					  tx_queue->read_count >=
+					  tx_queue->efx->txq_entries);
 
 		buffer->dma_addr = dma_addr;
 
@@ -134,7 +134,7 @@ static void efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 		len -= dma_len;
 	}
 
-	EFX_BUG_ON_PARANOID(!len);
+	EFX_WARN_ON_ONCE_PARANOID(!len);
 	buffer->len = len;
 	*final_buffer = buffer;
 }
@@ -147,8 +147,8 @@ static __be16 efx_tso_check_protocol(struct sk_buff *skb)
 {
 	__be16 protocol = skb->protocol;
 
-	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
-			    protocol);
+	EFX_WARN_ON_ONCE_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
+				  protocol);
 	if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 
@@ -156,19 +156,18 @@ static __be16 efx_tso_check_protocol(struct sk_buff *skb)
 	}
 
 	if (protocol == htons(ETH_P_IP)) {
-		EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+		EFX_WARN_ON_ONCE_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
 	} else {
-		EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IPV6));
-		EFX_BUG_ON_PARANOID(ipv6_hdr(skb)->nexthdr != NEXTHDR_TCP);
+		EFX_WARN_ON_ONCE_PARANOID(protocol != htons(ETH_P_IPV6));
+		EFX_WARN_ON_ONCE_PARANOID(ipv6_hdr(skb)->nexthdr != NEXTHDR_TCP);
 	}
-	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
-			     + (tcp_hdr(skb)->doff << 2u)) >
-			    skb_headlen(skb));
+	EFX_WARN_ON_ONCE_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data) +
+				   (tcp_hdr(skb)->doff << 2u)) >
+				  skb_headlen(skb));
 
 	return protocol;
 }
 
-
 /* Parse the SKB header and initialise state. */
 static int tso_start(struct tso_state *st, struct efx_nic *efx,
 		     struct efx_tx_queue *tx_queue,
@@ -193,9 +192,9 @@ static int tso_start(struct tso_state *st, struct efx_nic *efx,
 	}
 	st->seqnum = ntohl(tcp_hdr(skb)->seq);
 
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
-	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
+	EFX_WARN_ON_ONCE_PARANOID(tcp_hdr(skb)->urg);
+	EFX_WARN_ON_ONCE_PARANOID(tcp_hdr(skb)->syn);
+	EFX_WARN_ON_ONCE_PARANOID(tcp_hdr(skb)->rst);
 
 	st->out_len = skb->len - header_len;
 
@@ -245,8 +244,8 @@ static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 	if (st->packet_space == 0)
 		return;
 
-	EFX_BUG_ON_PARANOID(st->in_len <= 0);
-	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
+	EFX_WARN_ON_ONCE_PARANOID(st->in_len <= 0);
+	EFX_WARN_ON_ONCE_PARANOID(st->packet_space <= 0);
 
 	n = min(st->in_len, st->packet_space);
 
@@ -379,7 +378,7 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	/* Find the packet protocol and sanity-check it */
 	state.protocol = efx_tso_check_protocol(skb);
 
-	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
+	EFX_WARN_ON_ONCE_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
 	rc = tso_start(&state, efx, tx_queue, skb);
 	if (rc)
@@ -387,7 +386,7 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	if (likely(state.in_len == 0)) {
 		/* Grab the first payload fragment. */
-		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
+		EFX_WARN_ON_ONCE_PARANOID(skb_shinfo(skb)->nr_frags < 1);
 		frag_i = 0;
 		rc = tso_get_fragment(&state, efx,
 				      skb_shinfo(skb)->frags + frag_i);
