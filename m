From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: read back RX hash config from the NIC when
 querying it with ethtool -x
Date: Tue, 17 Jan 2017 12:02:12 +0000
Message-ID: <1d4b3388-dde6-2ab6-f91d-1db8c5ba4b1a@solarflare.com>
References: <2b7fcd41-680f-460e-399a-6aa4ce102a04@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:61405 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751069AbdAQMHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 07:07:40 -0500
In-Reply-To: <2b7fcd41-680f-460e-399a-6aa4ce102a04@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensures that we report the key and indirection table the NIC is using,
 rather than (if setting them failed earlier) what we wanted it to use.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 52 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ethtool.c    |  5 ++++
 drivers/net/ethernet/sfc/farch.c      | 16 +++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/nic.h        |  1 +
 drivers/net/ethernet/sfc/siena.c      | 20 ++++++++++++++
 6 files changed, 96 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index f117e0b..dccbbd3 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2643,6 +2643,56 @@ static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
 	return rc;
 }
 
+static int efx_ef10_rx_pull_rss_config(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_RSS_CONTEXT_GET_TABLE_IN_LEN);
+	MCDI_DECLARE_BUF(tablebuf, MC_CMD_RSS_CONTEXT_GET_TABLE_OUT_LEN);
+	MCDI_DECLARE_BUF(keybuf, MC_CMD_RSS_CONTEXT_GET_KEY_OUT_LEN);
+	size_t outlen;
+	int rc, i;
+
+	BUILD_BUG_ON(MC_CMD_RSS_CONTEXT_GET_TABLE_IN_LEN !=
+		     MC_CMD_RSS_CONTEXT_GET_KEY_IN_LEN);
+
+	if (nic_data->rx_rss_context == EFX_EF10_RSS_CONTEXT_INVALID)
+		return -ENOENT;
+
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_GET_TABLE_IN_RSS_CONTEXT_ID,
+		       nic_data->rx_rss_context);
+	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
+		     MC_CMD_RSS_CONTEXT_GET_TABLE_OUT_INDIRECTION_TABLE_LEN);
+	rc = efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_GET_TABLE, inbuf, sizeof(inbuf),
+			  tablebuf, sizeof(tablebuf), &outlen);
+	if (rc != 0)
+		return rc;
+
+	if (WARN_ON(outlen != MC_CMD_RSS_CONTEXT_GET_TABLE_OUT_LEN))
+		return -EIO;
+
+	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
+		efx->rx_indir_table[i] = MCDI_PTR(tablebuf,
+				RSS_CONTEXT_GET_TABLE_OUT_INDIRECTION_TABLE)[i];
+
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_GET_KEY_IN_RSS_CONTEXT_ID,
+		       nic_data->rx_rss_context);
+	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_hash_key) !=
+		     MC_CMD_RSS_CONTEXT_SET_KEY_IN_TOEPLITZ_KEY_LEN);
+	rc = efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_GET_KEY, inbuf, sizeof(inbuf),
+			  keybuf, sizeof(keybuf), &outlen);
+	if (rc != 0)
+		return rc;
+
+	if (WARN_ON(outlen != MC_CMD_RSS_CONTEXT_GET_KEY_OUT_LEN))
+		return -EIO;
+
+	for (i = 0; i < ARRAY_SIZE(efx->rx_hash_key); ++i)
+		efx->rx_hash_key[i] = MCDI_PTR(
+				keybuf, RSS_CONTEXT_GET_KEY_OUT_TOEPLITZ_KEY)[i];
+
+	return 0;
+}
+
 static int efx_ef10_pf_rx_push_rss_config(struct efx_nic *efx, bool user,
 					  const u32 *rx_indir_table,
 					  const u8 *key)
@@ -5643,6 +5693,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.tx_write = efx_ef10_tx_write,
 	.tx_limit_len = efx_ef10_tx_limit_len,
 	.rx_push_rss_config = efx_ef10_vf_rx_push_rss_config,
+	.rx_pull_rss_config = efx_ef10_rx_pull_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
 	.rx_remove = efx_ef10_rx_remove,
@@ -5751,6 +5802,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.tx_write = efx_ef10_tx_write,
 	.tx_limit_len = efx_ef10_tx_limit_len,
 	.rx_push_rss_config = efx_ef10_pf_rx_push_rss_config,
+	.rx_pull_rss_config = efx_ef10_rx_pull_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
 	.rx_remove = efx_ef10_rx_remove,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index becdba3..adddf70 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1289,6 +1289,11 @@ static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
 				u8 *hfunc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	rc = efx->type->rx_pull_rss_config(efx);
+	if (rc)
+		return rc;
 
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index e4ca216..ba45150 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1649,6 +1649,22 @@ void efx_farch_rx_push_indir_table(struct efx_nic *efx)
 	}
 }
 
+void efx_farch_rx_pull_indir_table(struct efx_nic *efx)
+{
+	size_t i = 0;
+	efx_dword_t dword;
+
+	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
+		     FR_BZ_RX_INDIRECTION_TBL_ROWS);
+
+	for (i = 0; i < FR_BZ_RX_INDIRECTION_TBL_ROWS; i++) {
+		efx_readd(efx, &dword,
+			   FR_BZ_RX_INDIRECTION_TBL +
+			   FR_BZ_RX_INDIRECTION_TBL_STEP * i);
+		efx->rx_indir_table[i] = EFX_DWORD_FIELD(dword, FRF_BZ_IT_QUEUE);
+	}
+}
+
 /* Looks at available SRAM resources and works out how many queues we
  * can support, and where things like descriptor caches should live.
  *
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index ad53551..5927c20 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1181,6 +1181,7 @@ struct efx_mtd_partition {
  * @tx_remove: Free resources for TX queue
  * @tx_write: Write TX descriptors and doorbell
  * @rx_push_rss_config: Write RSS hash key and indirection table to the NIC
+ * @rx_pull_rss_config: Read RSS hash key and indirection table back from the NIC
  * @rx_probe: Allocate resources for RX queue
  * @rx_init: Initialise RX queue on the NIC
  * @rx_remove: Free resources for RX queue
@@ -1312,6 +1313,7 @@ struct efx_nic_type {
 				     dma_addr_t dma_addr, unsigned int len);
 	int (*rx_push_rss_config)(struct efx_nic *efx, bool user,
 				  const u32 *rx_indir_table, const u8 *key);
+	int (*rx_pull_rss_config)(struct efx_nic *efx);
 	int (*rx_probe)(struct efx_rx_queue *rx_queue);
 	void (*rx_init)(struct efx_rx_queue *rx_queue);
 	void (*rx_remove)(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 383ff6e..85cf131 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -626,6 +626,7 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw);
 void efx_farch_init_common(struct efx_nic *efx);
 void efx_ef10_handle_drain_event(struct efx_nic *efx);
 void efx_farch_rx_push_indir_table(struct efx_nic *efx);
+void efx_farch_rx_pull_indir_table(struct efx_nic *efx);
 
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len, gfp_t gfp_flags);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 0606aa2..af7cd85 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -332,6 +332,25 @@ static int siena_probe_nic(struct efx_nic *efx)
 	return rc;
 }
 
+static int siena_rx_pull_rss_config(struct efx_nic *efx)
+{
+	efx_oword_t temp;
+
+	/* Read from IPv6 RSS key as that's longer (the IPv4 key is just the
+	 * first 128 bits of the same key, assuming it's been set by
+	 * siena_rx_push_rss_config, below)
+	 */
+	efx_reado(efx, &temp, FR_CZ_RX_RSS_IPV6_REG1);
+	memcpy(efx->rx_hash_key, &temp, sizeof(temp));
+	efx_reado(efx, &temp, FR_CZ_RX_RSS_IPV6_REG2);
+	memcpy(efx->rx_hash_key + sizeof(temp), &temp, sizeof(temp));
+	efx_reado(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
+	memcpy(efx->rx_hash_key + 2 * sizeof(temp), &temp,
+	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
+	efx_farch_rx_pull_indir_table(efx);
+	return 0;
+}
+
 static int siena_rx_push_rss_config(struct efx_nic *efx, bool user,
 				    const u32 *rx_indir_table, const u8 *key)
 {
@@ -981,6 +1000,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.tx_write = efx_farch_tx_write,
 	.tx_limit_len = efx_farch_tx_limit_len,
 	.rx_push_rss_config = siena_rx_push_rss_config,
+	.rx_pull_rss_config = siena_rx_pull_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
 	.rx_remove = efx_farch_rx_remove,
