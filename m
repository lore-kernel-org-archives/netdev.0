From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 5/5] sfc: remove Software TSO
Date: Thu, 17 Nov 2016 10:52:36 +0000
Message-ID: <d74326a2-af17-0cb2-67f3-5216ea04e61a@solarflare.com>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:57273 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941793AbcKQKwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:52:46 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It gives no advantage over GSO now that xmit_more exists.  If we find
 ourselves unable to handle a TSO skb (because our TXQ doesn't have a
 TSOv2 context and the NIC doesn't support TSOv1), hand it back to GSO.
 Also do that if the TSO handler fails with EINVAL for any other reason.
As Falcon-architecture NICs don't support any firmware-assisted TSO,
 they no longer advertise TSO feature flags at all.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  15 ++
 drivers/net/ethernet/sfc/efx.c        |  38 ++---
 drivers/net/ethernet/sfc/ethtool.c    |   1 +
 drivers/net/ethernet/sfc/net_driver.h |   5 +
 drivers/net/ethernet/sfc/tx.c         |  46 +++++-
 drivers/net/ethernet/sfc/tx_tso.c     | 260 ++++++++++------------------------
 6 files changed, 154 insertions(+), 211 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9cbe573..0f58ea8 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2158,6 +2158,20 @@ static int efx_ef10_tx_tso_desc(struct efx_tx_queue *tx_queue,
 	return 0;
 }
 
+static u32 efx_ef10_tso_versions(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	u32 tso_versions = 0;
+
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))
+		tso_versions |= BIT(1);
+	if (nic_data->datapath_caps2 &
+	    (1 << MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_LBN))
+		tso_versions |= BIT(2);
+	return tso_versions;
+}
+
 static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_INIT_TXQ_IN_LEN(EFX_MAX_DMAQ_SIZE * 8 /
@@ -5759,6 +5773,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 #endif
 	.get_mac_address = efx_ef10_get_mac_address_pf,
 	.set_mac_address = efx_ef10_set_mac_address,
+	.tso_versions = efx_ef10_tso_versions,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 52ca040..756a0964 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3200,23 +3200,6 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	efx = netdev_priv(net_dev);
 	efx->type = (const struct efx_nic_type *) entry->driver_data;
 	efx->fixed_features |= NETIF_F_HIGHDMA;
-	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
-			      NETIF_F_TSO | NETIF_F_RXCSUM);
-	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
-		net_dev->features |= NETIF_F_TSO6;
-	/* Mask for features that also apply to VLAN devices */
-	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
-				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
-				   NETIF_F_RXCSUM);
-
-	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
-
-	/* Disable VLAN filtering by default.  It may be enforced if
-	 * the feature is fixed (i.e. VLAN filters are required to
-	 * receive VLAN tagged packets due to vPort restrictions).
-	 */
-	net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
-	net_dev->features |= efx->fixed_features;
 
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
@@ -3239,6 +3222,27 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail3;
 
+	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
+			      NETIF_F_TSO | NETIF_F_RXCSUM);
+	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
+		net_dev->features |= NETIF_F_TSO6;
+	/* Check whether device supports TSO */
+	if (!efx->type->tso_versions || !efx->type->tso_versions(efx))
+		net_dev->features &= ~NETIF_F_ALL_TSO;
+	/* Mask for features that also apply to VLAN devices */
+	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
+				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
+				   NETIF_F_RXCSUM);
+
+	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
+
+	/* Disable VLAN filtering by default.  It may be enforced if
+	 * the feature is fixed (i.e. VLAN filters are required to
+	 * receive VLAN tagged packets due to vPort restrictions).
+	 */
+	net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+	net_dev->features |= efx->fixed_features;
+
 	rc = efx_register_netdev(efx);
 	if (rc)
 		goto fail4;
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index bd5edd6..740cdf0 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -69,6 +69,7 @@ static const struct efx_sw_stat_desc efx_sw_stat_desc[] = {
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_bursts),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_long_headers),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
+	EFX_ETHTOOL_UINT_TXQ_STAT(tso_fallbacks),
 	EFX_ETHTOOL_UINT_TXQ_STAT(pushes),
 	EFX_ETHTOOL_UINT_TXQ_STAT(pio_packets),
 	EFX_ETHTOOL_UINT_TXQ_STAT(cb_packets),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 2da3e8f..f97f828 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -225,6 +225,7 @@ struct efx_tx_buffer {
  * @tso_long_headers: Number of packets with headers too long for standard
  *	blocks
  * @tso_packets: Number of packets via the TSO xmit path
+ * @tso_fallbacks: Number of times TSO fallback used
  * @pushes: Number of times the TX push feature has been used
  * @pio_packets: Number of times the TX PIO feature has been used
  * @xmit_more_available: Are any packets waiting to be pushed to the NIC
@@ -266,6 +267,7 @@ struct efx_tx_queue {
 	unsigned int tso_bursts;
 	unsigned int tso_long_headers;
 	unsigned int tso_packets;
+	unsigned int tso_fallbacks;
 	unsigned int pushes;
 	unsigned int pio_packets;
 	bool xmit_more_available;
@@ -1225,6 +1227,8 @@ struct efx_mtd_partition {
  *	and tx_type will already have been validated but this operation
  *	must validate and update rx_filter.
  * @set_mac_address: Set the MAC address of the device
+ * @tso_versions: Returns mask of firmware-assisted TSO versions supported.
+ *	If %NULL, then device does not support any TSO version.
  * @revision: Hardware architecture revision
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -1381,6 +1385,7 @@ struct efx_nic_type {
 	void (*vswitching_remove)(struct efx_nic *efx);
 	int (*get_mac_address)(struct efx_nic *efx, unsigned char *perm_addr);
 	int (*set_mac_address)(struct efx_nic *efx);
+	u32 (*tso_versions)(struct efx_nic *efx);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3089e88..1aa728c 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -446,10 +446,38 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 	}
 }
 
-static int efx_tx_tso_sw(struct efx_tx_queue *tx_queue, struct sk_buff *skb,
-			 bool *data_mapped)
+/*
+ * Fallback to software TSO.
+ *
+ * This is used if we are unable to send a GSO packet through hardware TSO.
+ * This should only ever happen due to per-queue restrictions - unsupported
+ * packets should first be filtered by the feature flags.
+ *
+ * Returns 0 on success, error code otherwise.
+ */
+static int efx_tx_tso_fallback(struct efx_tx_queue *tx_queue,
+			       struct sk_buff *skb)
 {
-	return efx_enqueue_skb_tso(tx_queue, skb, data_mapped);
+	struct sk_buff *segments, *next;
+
+	segments = skb_gso_segment(skb, 0);
+	if (IS_ERR(segments))
+		return PTR_ERR(segments);
+
+	dev_kfree_skb_any(skb);
+	skb = segments;
+
+	while (skb) {
+		next = skb->next;
+		skb->next = NULL;
+
+		if (next)
+			skb->xmit_more = true;
+		efx_enqueue_skb(tx_queue, skb);
+		skb = next;
+	}
+
+	return 0;
 }
 
 /*
@@ -473,6 +501,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	bool data_mapped = false;
 	unsigned int segments;
 	unsigned int skb_len;
+	int rc;
 
 	skb_len = skb->len;
 	segments = skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 0;
@@ -485,7 +514,14 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	 */
 	if (segments) {
 		EFX_BUG_ON_PARANOID(!tx_queue->handle_tso);
-		if (tx_queue->handle_tso(tx_queue, skb, &data_mapped))
+		rc = tx_queue->handle_tso(tx_queue, skb, &data_mapped);
+		if (rc == -EINVAL) {
+			rc = efx_tx_tso_fallback(tx_queue, skb);
+			tx_queue->tso_fallbacks++;
+			if (rc == 0)
+				return 0;
+		}
+		if (rc)
 			goto err;
 #ifdef EFX_USE_PIO
 	} else if (skb_len <= efx_piobuf_size && !skb->xmit_more &&
@@ -801,7 +837,7 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	/* Set up default function pointers. These may get replaced by
 	 * efx_nic_init_tx() based off NIC/queue capabilities.
 	 */
-	tx_queue->handle_tso = efx_tx_tso_sw;
+	tx_queue->handle_tso = efx_enqueue_skb_tso;
 
 	/* Some older hardware requires Tx writes larger than 32. */
 	tx_queue->tx_min_size = EFX_WORKAROUND_15592(efx) ? 33 : 0;
diff --git a/drivers/net/ethernet/sfc/tx_tso.c b/drivers/net/ethernet/sfc/tx_tso.c
index 99936d7..6032887 100644
--- a/drivers/net/ethernet/sfc/tx_tso.c
+++ b/drivers/net/ethernet/sfc/tx_tso.c
@@ -29,8 +29,7 @@
 
 /* Efx legacy TCP segmentation acceleration.
  *
- * Why?  Because by doing it here in the driver we can go significantly
- * faster than the GSO.
+ * Utilises firmware support to go faster than GSO (but not as fast as TSOv2).
  *
  * Requires TX checksum offload support.
  */
@@ -47,15 +46,13 @@
  * @in_len: Remaining length in current SKB fragment
  * @unmap_len: Length of SKB fragment
  * @unmap_addr: DMA address of SKB fragment
- * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
  * @protocol: Network protocol (after any VLAN header)
  * @ip_off: Offset of IP header
  * @tcp_off: Offset of TCP header
  * @header_len: Number of bytes of header
  * @ip_base_len: IPv4 tot_len or IPv6 payload_len, before TCP payload
- * @header_dma_addr: Header DMA address, when using option descriptors
- * @header_unmap_len: Header DMA mapped length, or 0 if not using option
- *	descriptors
+ * @header_dma_addr: Header DMA address
+ * @header_unmap_len: Header DMA mapped length
  *
  * The state used during segmentation.  It is put into this data structure
  * just to make it easy to pass into inline functions.
@@ -72,7 +69,6 @@ struct tso_state {
 	unsigned int in_len;
 	unsigned int unmap_len;
 	dma_addr_t unmap_addr;
-	unsigned short dma_flags;
 
 	__be16 protocol;
 	unsigned int ip_off;
@@ -172,63 +168,6 @@ static __be16 efx_tso_check_protocol(struct sk_buff *skb)
 	return protocol;
 }
 
-static u8 *efx_tsoh_get_buffer(struct efx_tx_queue *tx_queue,
-			       struct efx_tx_buffer *buffer, unsigned int len)
-{
-	u8 *result;
-
-	EFX_BUG_ON_PARANOID(buffer->len);
-	EFX_BUG_ON_PARANOID(buffer->flags);
-	EFX_BUG_ON_PARANOID(buffer->unmap_len);
-
-	result = efx_tx_get_copy_buffer_limited(tx_queue, buffer, len);
-
-	if (result) {
-		buffer->flags = EFX_TX_BUF_CONT;
-	} else {
-		buffer->heap_buf = kmalloc(NET_IP_ALIGN + len, GFP_ATOMIC);
-		if (unlikely(!buffer->heap_buf))
-			return NULL;
-		tx_queue->tso_long_headers++;
-		result = (u8 *)buffer->heap_buf + NET_IP_ALIGN;
-		buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_HEAP;
-	}
-
-	buffer->len = len;
-
-	return result;
-}
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
 
 /* Parse the SKB header and initialise state. */
 static int tso_start(struct tso_state *st, struct efx_nic *efx,
@@ -237,12 +176,8 @@ static int tso_start(struct tso_state *st, struct efx_nic *efx,
 {
 	struct device *dma_dev = &efx->pci_dev->dev;
 	unsigned int header_len, in_len;
-	bool use_opt_desc = false;
 	dma_addr_t dma_addr;
 
-	if (tx_queue->tso_version == 1)
-		use_opt_desc = true;
-
 	st->ip_off = skb_network_header(skb) - skb->data;
 	st->tcp_off = skb_transport_header(skb) - skb->data;
 	header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
@@ -264,30 +199,12 @@ static int tso_start(struct tso_state *st, struct efx_nic *efx,
 
 	st->out_len = skb->len - header_len;
 
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
+	dma_addr = dma_map_single(dma_dev, skb->data,
+				  skb_headlen(skb), DMA_TO_DEVICE);
+	st->header_dma_addr = dma_addr;
+	st->header_unmap_len = skb_headlen(skb);
+	st->dma_addr = dma_addr + header_len;
+	st->unmap_len = 0;
 
 	return unlikely(dma_mapping_error(dma_dev, dma_addr)) ? -ENOMEM : 0;
 }
@@ -298,7 +215,6 @@ static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 	st->unmap_addr = skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
 					  skb_frag_size(frag), DMA_TO_DEVICE);
 	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
-		st->dma_flags = 0;
 		st->unmap_len = skb_frag_size(frag);
 		st->in_len = skb_frag_size(frag);
 		st->dma_addr = st->unmap_addr;
@@ -352,7 +268,6 @@ static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 		/* Transfer ownership of the DMA mapping */
 		buffer->unmap_len = st->unmap_len;
 		buffer->dma_offset = buffer->unmap_len - buffer->len;
-		buffer->flags |= st->dma_flags;
 		st->unmap_len = 0;
 	}
 
@@ -369,7 +284,7 @@ static void tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
  * @st:			TSO state
  *
  * Generate a new header and prepare for the new packet.  Return 0 on
- * success, or -%ENOMEM if failed to alloc header.
+ * success, or -%ENOMEM if failed to alloc header, or other negative error.
  */
 static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 				const struct sk_buff *skb,
@@ -378,7 +293,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	struct efx_tx_buffer *buffer =
 		efx_tx_queue_get_insert_buffer(tx_queue);
 	bool is_last = st->out_len <= skb_shinfo(skb)->gso_size;
-	u8 tcp_flags_mask;
+	u8 tcp_flags_mask, tcp_flags;
 
 	if (!is_last) {
 		st->packet_space = skb_shinfo(skb)->gso_size;
@@ -388,82 +303,44 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		tcp_flags_mask = 0x00;
 	}
 
-	if (!st->header_unmap_len) {
-		/* Allocate and insert a DMA-mapped header buffer. */
-		struct tcphdr *tsoh_th;
-		unsigned int ip_length;
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
-		((u8 *)tsoh_th)[TCP_FLAGS_OFFSET] &= ~tcp_flags_mask;
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
+	if (WARN_ON(!st->header_unmap_len))
+		return -EINVAL;
+	/* Send the original headers with a TSO option descriptor
+	 * in front
+	 */
+	tcp_flags = ((u8 *)tcp_hdr(skb))[TCP_FLAGS_OFFSET] & ~tcp_flags_mask;
+
+	buffer->flags = EFX_TX_BUF_OPTION;
+	buffer->len = 0;
+	buffer->unmap_len = 0;
+	EFX_POPULATE_QWORD_5(buffer->option,
+			     ESF_DZ_TX_DESC_IS_OPT, 1,
+			     ESF_DZ_TX_OPTION_TYPE,
+			     ESE_DZ_TX_OPTION_DESC_TSO,
+			     ESF_DZ_TX_TSO_TCP_FLAGS, tcp_flags,
+			     ESF_DZ_TX_TSO_IP_ID, st->ipv4_id,
+			     ESF_DZ_TX_TSO_TCP_SEQNO, st->seqnum);
+	++tx_queue->insert_count;
 
-		rc = efx_tso_put_header(tx_queue, buffer, header);
-		if (unlikely(rc))
-			return rc;
-	} else {
-		/* Send the original headers with a TSO option descriptor
-		 * in front
+	/* We mapped the headers in tso_start().  Unmap them
+	 * when the last segment is completed.
+	 */
+	buffer = efx_tx_queue_get_insert_buffer(tx_queue);
+	buffer->dma_addr = st->header_dma_addr;
+	buffer->len = st->header_len;
+	if (is_last) {
+		buffer->flags = EFX_TX_BUF_CONT | EFX_TX_BUF_MAP_SINGLE;
+		buffer->unmap_len = st->header_unmap_len;
+		buffer->dma_offset = 0;
+		/* Ensure we only unmap them once in case of a
+		 * later DMA mapping error and rollback
 		 */
-		u8 tcp_flags = ((u8 *)tcp_hdr(skb))[TCP_FLAGS_OFFSET] &
-				~tcp_flags_mask;
-
-		buffer->flags = EFX_TX_BUF_OPTION;
-		buffer->len = 0;
+		st->header_unmap_len = 0;
+	} else {
+		buffer->flags = EFX_TX_BUF_CONT;
 		buffer->unmap_len = 0;
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
 	}
+	++tx_queue->insert_count;
 
 	st->seqnum += skb_shinfo(skb)->gso_size;
 
@@ -483,8 +360,8 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
  * Context: You must hold netif_tx_lock() to call this function.
  *
  * Add socket buffer @skb to @tx_queue, doing TSO or return != 0 if
- * @skb was not enqueued.  In all cases @skb is consumed.  Return
- * %NETDEV_TX_OK.
+ * @skb was not enqueued.  @skb is consumed unless return value is
+ * %EINVAL.
  */
 int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			struct sk_buff *skb,
@@ -494,6 +371,9 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	int frag_i, rc;
 	struct tso_state state;
 
+	if (tx_queue->tso_version != 1)
+		return -EINVAL;
+
 	prefetch(skb->data);
 
 	/* Find the packet protocol and sanity-check it */
@@ -503,7 +383,7 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	rc = tso_start(&state, efx, tx_queue, skb);
 	if (rc)
-		goto mem_err;
+		goto fail;
 
 	if (likely(state.in_len == 0)) {
 		/* Grab the first payload fragment. */
@@ -512,14 +392,15 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 		rc = tso_get_fragment(&state, efx,
 				      skb_shinfo(skb)->frags + frag_i);
 		if (rc)
-			goto mem_err;
+			goto fail;
 	} else {
 		/* Payload starts in the header area. */
 		frag_i = -1;
 	}
 
-	if (tso_start_new_packet(tx_queue, skb, &state) < 0)
-		goto mem_err;
+	rc = tso_start_new_packet(tx_queue, skb, &state);
+	if (rc)
+		goto fail;
 
 	prefetch_ptr(tx_queue);
 
@@ -534,37 +415,38 @@ int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			rc = tso_get_fragment(&state, efx,
 					      skb_shinfo(skb)->frags + frag_i);
 			if (rc)
-				goto mem_err;
+				goto fail;
 		}
 
 		/* Start at new packet? */
-		if (state.packet_space == 0 &&
-		    tso_start_new_packet(tx_queue, skb, &state) < 0)
-			goto mem_err;
+		if (state.packet_space == 0) {
+			rc = tso_start_new_packet(tx_queue, skb, &state);
+			if (rc)
+				goto fail;
+		}
 	}
 
 	*data_mapped = true;
 
 	return 0;
 
- mem_err:
-	netif_err(efx, tx_err, efx->net_dev,
-		  "Out of memory for TSO headers, or DMA mapping error\n");
+fail:
+	if (rc == -ENOMEM)
+		netif_err(efx, tx_err, efx->net_dev,
+			  "Out of memory for TSO headers, or DMA mapping error\n");
+	else
+		netif_err(efx, tx_err, efx->net_dev, "TSO failed, rc = %d\n", rc);
 
 	/* Free the DMA mapping we were in the process of writing out */
 	if (state.unmap_len) {
-		if (state.dma_flags & EFX_TX_BUF_MAP_SINGLE)
-			dma_unmap_single(&efx->pci_dev->dev, state.unmap_addr,
-					 state.unmap_len, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(&efx->pci_dev->dev, state.unmap_addr,
-				       state.unmap_len, DMA_TO_DEVICE);
+		dma_unmap_page(&efx->pci_dev->dev, state.unmap_addr,
+			       state.unmap_len, DMA_TO_DEVICE);
 	}
 
-	/* Free the header DMA mapping, if using option descriptors */
+	/* Free the header DMA mapping */
 	if (state.header_unmap_len)
 		dma_unmap_single(&efx->pci_dev->dev, state.header_dma_addr,
 				 state.header_unmap_len, DMA_TO_DEVICE);
 
-	return -ENOMEM;
+	return rc;
 }
