From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/5] sfc: Record hardware RX hash on each skb
 where possible
Date: Wed, 23 Jun 2010 22:31:28 +0100
Message-ID: <1277328688.2101.12.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18625 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0FWVbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:31:31 -0400
In-Reply-To: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    1 +
 drivers/net/sfc/ethtool.c    |   12 ++++++++++++
 drivers/net/sfc/falcon.c     |    4 +++-
 drivers/net/sfc/net_driver.h |    4 +++-
 drivers/net/sfc/rx.c         |   23 +++++++++++++++++++++++
 drivers/net/sfc/selftest.c   |    3 +++
 drivers/net/sfc/siena.c      |    5 ++++-
 7 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ad35911..d68f061 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -480,6 +480,7 @@ static void efx_init_channels(struct efx_nic *efx)
 	 */
 	efx->rx_buffer_len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
 			      EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
+			      efx->type->rx_buffer_hash_size +
 			      efx->type->rx_buffer_padding);
 	efx->rx_buffer_order = get_order(efx->rx_buffer_len +
 					 sizeof(struct efx_rx_page_state));
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index dde21a8..7693cfb 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -546,6 +546,17 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 	return efx->rx_checksum_enabled;
 }
 
+static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	u32 supported = efx->type->offload_features & ETH_FLAG_RXHASH;
+
+	if (data & ~supported)
+		return -EOPNOTSUPP;
+
+	return ethtool_op_set_flags(net_dev, data);
+}
+
 static void efx_ethtool_self_test(struct net_device *net_dev,
 				  struct ethtool_test *test, u64 *data)
 {
@@ -888,6 +899,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	/* Need to enable/disable TSO-IPv6 too */
 	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
+	.set_flags		= efx_ethtool_set_flags,
 	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 92d38ed..5a40145 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1581,6 +1581,7 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, data_xoff_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_INSRT_HDR, 1);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
 	}
 	/* Always enable XOFF signal from RX FIFO.  We enable
@@ -1861,6 +1862,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
 	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
 	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_buffer_hash_size = 0x10,
 	.rx_buffer_padding = 0,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
@@ -1868,7 +1870,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
-	.offload_features = NETIF_F_IP_CSUM,
+	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH,
 	.reset_world_flags = ETH_RESET_IRQ,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6a901c8..8b17c92 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -845,7 +845,8 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @evq_ptr_tbl_base: Event queue pointer table base address
  * @evq_rptr_tbl_base: Event queue read-pointer table base address
  * @max_dma_mask: Maximum possible DMA mask
- * @rx_buffer_padding: Padding added to each RX buffer
+ * @rx_buffer_hash_size: Size of hash at start of RX buffer
+ * @rx_buffer_padding: Size of padding at end of RX buffer
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
  * @phys_addr_channels: Number of channels with physically addressed
@@ -889,6 +890,7 @@ struct efx_nic_type {
 	unsigned int evq_ptr_tbl_base;
 	unsigned int evq_rptr_tbl_base;
 	u64 max_dma_mask;
+	unsigned int rx_buffer_hash_size;
 	unsigned int rx_buffer_padding;
 	unsigned int max_interrupt_mode;
 	unsigned int phys_addr_channels;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index d9ed20e..0fb9835 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -101,6 +101,19 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 	return PAGE_SIZE << efx->rx_buffer_order;
 }
 
+static inline u32 efx_rx_buf_hash(struct efx_rx_buffer *buf)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) || NET_IP_ALIGN % 4 == 0
+	return __le32_to_cpup((const __le32 *)buf->data);
+#else
+	const u8 *data = (const u8 *)buf->data;
+	return ((u32)data[0]       |
+		(u32)data[1] << 8  |
+		(u32)data[2] << 16 |
+		(u32)data[3] << 24);
+#endif
+}
+
 /**
  * efx_init_rx_buffers_skb - create EFX_RX_BATCH skb-based RX buffers
  *
@@ -441,6 +454,7 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 
 	/* Pass the skb/page into the LRO engine */
 	if (rx_buf->page) {
+		struct efx_nic *efx = channel->efx;
 		struct page *page = rx_buf->page;
 		struct sk_buff *skb;
 
@@ -453,6 +467,11 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 			return;
 		}
 
+		if (efx->net_dev->features & NETIF_F_RXHASH)
+			skb->rxhash = efx_rx_buf_hash(rx_buf);
+		rx_buf->data += efx->type->rx_buffer_hash_size;
+		rx_buf->len -= efx->type->rx_buffer_hash_size;
+
 		skb_shinfo(skb)->frags[0].page = page;
 		skb_shinfo(skb)->frags[0].page_offset =
 			efx_rx_buf_offset(rx_buf);
@@ -572,6 +591,10 @@ void __efx_rx_packet(struct efx_channel *channel,
 
 		skb_put(rx_buf->skb, rx_buf->len);
 
+		if (efx->net_dev->features & NETIF_F_RXHASH)
+			rx_buf->skb->rxhash = efx_rx_buf_hash(rx_buf);
+		skb_pull(rx_buf->skb, efx->type->rx_buffer_hash_size);
+
 		/* Move past the ethernet header. rx_buf->data still points
 		 * at the ethernet header */
 		rx_buf->skb->protocol = eth_type_trans(rx_buf->skb,
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 85f015f..0399be2 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -258,6 +258,9 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 
 	payload = &state->payload;
 
+	buf_ptr += efx->type->rx_buffer_hash_size;
+	pkt_len -= efx->type->rx_buffer_hash_size;
+
 	received = (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr = payload->ip.saddr;
 	if (state->offload_csum)
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 59d1dc6..f1741b4 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -331,6 +331,7 @@ static int siena_init_nic(struct efx_nic *efx)
 
 	efx_reado(efx, &temp, FR_AZ_RX_CFG);
 	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_DESC_PUSH_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_HASH_INSRT_HDR, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_INGR_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
@@ -636,6 +637,7 @@ struct efx_nic_type siena_a0_nic_type = {
 	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
 	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
 	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_buffer_hash_size = 0x10,
 	.rx_buffer_padding = 0,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
@@ -643,6 +645,7 @@ struct efx_nic_type siena_a0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x88000,
 	.rx_dc_base = 0x68000,
-	.offload_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM,
+	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			     NETIF_F_RXHASH),
 	.reset_world_flags = ETH_RESET_MGMT << ETH_RESET_SHARED_SHIFT,
 };
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

