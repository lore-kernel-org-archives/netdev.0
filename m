From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] sfc: Add support for RX flow hash control
Date: Wed, 30 Jun 2010 16:06:28 +0100
Message-ID: <1277910388.2082.15.camel@achroite.uk.solarflarecom.com>
References: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8023 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105Ab0F3PGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 11:06:31 -0400
In-Reply-To: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow ethtool to query the number of RX rings, the fields used in RX
flow hashing and the hash indirection table.

Allow ethtool to update the RX flow hash indirection table.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    3 +
 drivers/net/sfc/ethtool.c    |   90 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/net_driver.h |    2 +
 drivers/net/sfc/nic.c        |   19 ++++-----
 drivers/net/sfc/nic.h        |    1 +
 5 files changed, 105 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 2a90bf9..35b3f29 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1121,6 +1121,7 @@ static void efx_set_channels(struct efx_nic *efx)
 
 static int efx_probe_nic(struct efx_nic *efx)
 {
+	size_t i;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "creating NIC\n");
@@ -1136,6 +1137,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
+	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
+		efx->rx_indir_table[i] = i % efx->n_rx_channels;
 
 	efx_set_channels(efx);
 	efx->net_dev->real_num_tx_queues = efx->n_tx_channels;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7693cfb..ab2510d 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -871,6 +871,93 @@ extern int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 	return efx_reset(efx, method);
 }
 
+static int
+efx_ethtool_get_rxnfc(struct net_device *net_dev,
+		      struct ethtool_rxnfc *info, void *rules __always_unused)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = efx->n_rx_channels;
+		return 0;
+
+	case ETHTOOL_GRXFH: {
+		unsigned min_revision = 0;
+
+		info->data = 0;
+		switch (info->flow_type) {
+		case TCP_V4_FLOW:
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			/* fall through */
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+		case AH_ESP_V4_FLOW:
+		case IPV4_FLOW:
+			info->data |= RXH_IP_SRC | RXH_IP_DST;
+			min_revision = EFX_REV_FALCON_B0;
+			break;
+		case TCP_V6_FLOW:
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+			/* fall through */
+		case UDP_V6_FLOW:
+		case SCTP_V6_FLOW:
+		case AH_ESP_V6_FLOW:
+		case IPV6_FLOW:
+			info->data |= RXH_IP_SRC | RXH_IP_DST;
+			min_revision = EFX_REV_SIENA_A0;
+			break;
+		default:
+			break;
+		}
+		if (efx_nic_rev(efx) < min_revision)
+			info->data = 0;
+		return 0;
+	}
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev,
+				      struct ethtool_rxfh_indir *indir)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	size_t copy_size =
+		min_t(size_t, indir->size, ARRAY_SIZE(efx->rx_indir_table));
+
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
+		return -EOPNOTSUPP;
+
+	indir->size = ARRAY_SIZE(efx->rx_indir_table);
+	memcpy(indir->ring_index, efx->rx_indir_table,
+	       copy_size * sizeof(indir->ring_index[0]));
+	return 0;
+}
+
+static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
+				      const struct ethtool_rxfh_indir *indir)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	size_t i;
+
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
+		return -EOPNOTSUPP;
+
+	/* Validate size and indices */
+	if (indir->size != ARRAY_SIZE(efx->rx_indir_table))
+		return -EINVAL;
+	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
+		if (indir->ring_index[i] >= efx->n_rx_channels)
+			return -EINVAL;
+
+	memcpy(efx->rx_indir_table, indir->ring_index,
+	       sizeof(efx->rx_indir_table));
+	efx_nic_push_rx_indir_table(efx);
+	return 0;
+}
+
 const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
@@ -908,4 +995,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_wol                = efx_ethtool_get_wol,
 	.set_wol                = efx_ethtool_set_wol,
 	.reset			= efx_ethtool_reset,
+	.get_rxnfc		= efx_ethtool_get_rxnfc,
+	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
+	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
 };
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ba272a4..64e7caa 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -647,6 +647,7 @@ union efx_multicast_hash {
  * @n_tx_channels: Number of channels used for TX
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
+ * @rx_indir_table: Indirection table for RSS
  * @int_error_count: Number of internal errors seen recently
  * @int_error_expire: Time at which error count will be expired
  * @irq_status: Interrupt status buffer
@@ -734,6 +735,7 @@ struct efx_nic {
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
 	u8 rx_hash_key[40];
+	u32 rx_indir_table[128];
 
 	unsigned int_error_count;
 	unsigned long int_error_expire;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 3083657..f595d92 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1484,22 +1484,21 @@ static irqreturn_t efx_msi_interrupt(int irq, void *dev_id)
 /* Setup RSS indirection table.
  * This maps from the hash value of the packet to RXQ
  */
-static void efx_setup_rss_indir_table(struct efx_nic *efx)
+void efx_nic_push_rx_indir_table(struct efx_nic *efx)
 {
-	int i = 0;
-	unsigned long offset;
+	size_t i = 0;
 	efx_dword_t dword;
 
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
 		return;
 
-	for (offset = FR_BZ_RX_INDIRECTION_TBL;
-	     offset < FR_BZ_RX_INDIRECTION_TBL + 0x800;
-	     offset += 0x10) {
+	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
+		     FR_BZ_RX_INDIRECTION_TBL_ROWS);
+
+	for (i = 0; i < FR_BZ_RX_INDIRECTION_TBL_ROWS; i++) {
 		EFX_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
-				     i % efx->n_rx_channels);
-		efx_writed(efx, &dword, offset);
-		i++;
+				     efx->rx_indir_table[i]);
+		efx_writed_table(efx, &dword, FR_BZ_RX_INDIRECTION_TBL, i);
 	}
 }
 
@@ -1634,7 +1633,7 @@ void efx_nic_init_common(struct efx_nic *efx)
 	EFX_INVERT_OWORD(temp);
 	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
-	efx_setup_rss_indir_table(efx);
+	efx_nic_push_rx_indir_table(efx);
 
 	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
 	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index a39822d..0438dc9 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -207,6 +207,7 @@ extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
 extern void efx_nic_init_common(struct efx_nic *efx);
+extern void efx_nic_push_rx_indir_table(struct efx_nic *efx);
 
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len);
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

