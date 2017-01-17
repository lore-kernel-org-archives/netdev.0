From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: support setting RSS hash key through
 ethtool API
Date: Tue, 17 Jan 2017 12:01:53 +0000
Message-ID: <3fd85102-6094-1576-69b1-2d77e8601c60@solarflare.com>
References: <2b7fcd41-680f-460e-399a-6aa4ce102a04@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:2516 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750849AbdAQMCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 07:02:05 -0500
In-Reply-To: <2b7fcd41-680f-460e-399a-6aa4ce102a04@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 32 ++++++++++++++++++++++++--------
 drivers/net/ethernet/sfc/ethtool.c    | 24 +++++++++++++++++++-----
 drivers/net/ethernet/sfc/net_driver.h |  3 ++-
 drivers/net/ethernet/sfc/siena.c      |  7 +++++--
 4 files changed, 50 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 2ce5769..f117e0b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1325,7 +1325,7 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 	}
 
 	/* don't fail init if RSS setup doesn't work */
-	rc = efx->type->rx_push_rss_config(efx, false, efx->rx_indir_table);
+	rc = efx->type->rx_push_rss_config(efx, false, efx->rx_indir_table, NULL);
 	efx->rss_active = (rc == 0);
 
 	return 0;
@@ -2535,7 +2535,7 @@ static void efx_ef10_free_rss_context(struct efx_nic *efx, u32 context)
 }
 
 static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context,
-				       const u32 *rx_indir_table)
+				       const u32 *rx_indir_table, const u8 *key)
 {
 	MCDI_DECLARE_BUF(tablebuf, MC_CMD_RSS_CONTEXT_SET_TABLE_IN_LEN);
 	MCDI_DECLARE_BUF(keybuf, MC_CMD_RSS_CONTEXT_SET_KEY_IN_LEN);
@@ -2546,6 +2546,11 @@ static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context,
 	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
 		     MC_CMD_RSS_CONTEXT_SET_TABLE_IN_INDIRECTION_TABLE_LEN);
 
+	/* This iterates over the length of efx->rx_indir_table, but copies
+	 * bytes from rx_indir_table.  That's because the latter is a pointer
+	 * rather than an array, but should have the same length.
+	 * The efx->rx_hash_key loop below is similar.
+	 */
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); ++i)
 		MCDI_PTR(tablebuf,
 			 RSS_CONTEXT_SET_TABLE_IN_INDIRECTION_TABLE)[i] =
@@ -2561,8 +2566,7 @@ static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context,
 	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_hash_key) !=
 		     MC_CMD_RSS_CONTEXT_SET_KEY_IN_TOEPLITZ_KEY_LEN);
 	for (i = 0; i < ARRAY_SIZE(efx->rx_hash_key); ++i)
-		MCDI_PTR(keybuf, RSS_CONTEXT_SET_KEY_IN_TOEPLITZ_KEY)[i] =
-			efx->rx_hash_key[i];
+		MCDI_PTR(keybuf, RSS_CONTEXT_SET_KEY_IN_TOEPLITZ_KEY)[i] = key[i];
 
 	return efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_SET_KEY, keybuf,
 			    sizeof(keybuf), NULL, 0, NULL);
@@ -2595,7 +2599,8 @@ static int efx_ef10_rx_push_shared_rss_config(struct efx_nic *efx,
 }
 
 static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
-						 const u32 *rx_indir_table)
+						 const u32 *rx_indir_table,
+						 const u8 *key)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -2614,7 +2619,7 @@ static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
 	}
 
 	rc = efx_ef10_populate_rss_table(efx, new_rx_rss_context,
-					 rx_indir_table);
+					 rx_indir_table, key);
 	if (rc != 0)
 		goto fail2;
 
@@ -2625,6 +2630,9 @@ static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
 	if (rx_indir_table != efx->rx_indir_table)
 		memcpy(efx->rx_indir_table, rx_indir_table,
 		       sizeof(efx->rx_indir_table));
+	if (key != efx->rx_hash_key)
+		memcpy(efx->rx_hash_key, key, efx->type->rx_hash_key_size);
+
 	return 0;
 
 fail2:
@@ -2636,14 +2644,18 @@ static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
 }
 
 static int efx_ef10_pf_rx_push_rss_config(struct efx_nic *efx, bool user,
-					  const u32 *rx_indir_table)
+					  const u32 *rx_indir_table,
+					  const u8 *key)
 {
 	int rc;
 
 	if (efx->rss_spread == 1)
 		return 0;
 
-	rc = efx_ef10_rx_push_exclusive_rss_config(efx, rx_indir_table);
+	if (!key)
+		key = efx->rx_hash_key;
+
+	rc = efx_ef10_rx_push_exclusive_rss_config(efx, rx_indir_table, key);
 
 	if (rc == -ENOBUFS && !user) {
 		unsigned context_size;
@@ -2681,6 +2693,8 @@ static int efx_ef10_pf_rx_push_rss_config(struct efx_nic *efx, bool user,
 
 static int efx_ef10_vf_rx_push_rss_config(struct efx_nic *efx, bool user,
 					  const u32 *rx_indir_table
+					  __attribute__ ((unused)),
+					  const u8 *key
 					  __attribute__ ((unused)))
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -5686,6 +5700,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.max_rx_ip_filters = HUNT_FILTER_TBL_ROWS,
 	.hwtstamp_filters = 1 << HWTSTAMP_FILTER_NONE |
 			    1 << HWTSTAMP_FILTER_ALL,
+	.rx_hash_key_size = 40,
 };
 
 const struct efx_nic_type efx_hunt_a0_nic_type = {
@@ -5812,4 +5827,5 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.max_rx_ip_filters = HUNT_FILTER_TBL_ROWS,
 	.hwtstamp_filters = 1 << HWTSTAMP_FILTER_NONE |
 			    1 << HWTSTAMP_FILTER_ALL,
+	.rx_hash_key_size = 40,
 };
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 18ebaea..becdba3 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1278,6 +1278,13 @@ static u32 efx_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
 	return (efx->n_rx_channels == 1) ? 0 : ARRAY_SIZE(efx->rx_indir_table);
 }
 
+static u32 efx_ethtool_get_rxfh_key_size(struct net_device *net_dev)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	return efx->type->rx_hash_key_size;
+}
+
 static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
 				u8 *hfunc)
 {
@@ -1287,6 +1294,8 @@ static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
 		*hfunc = ETH_RSS_HASH_TOP;
 	if (indir)
 		memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
+	if (key)
+		memcpy(key, efx->rx_hash_key, efx->type->rx_hash_key_size);
 	return 0;
 }
 
@@ -1295,14 +1304,18 @@ static int efx_ethtool_set_rxfh(struct net_device *net_dev, const u32 *indir,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	/* We do not allow change in unsupported parameters */
-	if (key ||
-	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+	/* Hash function is Toeplitz, cannot be changed */
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
-	if (!indir)
+	if (!indir && !key)
 		return 0;
 
-	return efx->type->rx_push_rss_config(efx, true, indir);
+	if (!key)
+		key = efx->rx_hash_key;
+	if (!indir)
+		indir = efx->rx_indir_table;
+
+	return efx->type->rx_push_rss_config(efx, true, indir, key);
 }
 
 static int efx_ethtool_get_ts_info(struct net_device *net_dev,
@@ -1377,6 +1390,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_rxnfc		= efx_ethtool_get_rxnfc,
 	.set_rxnfc		= efx_ethtool_set_rxnfc,
 	.get_rxfh_indir_size	= efx_ethtool_get_rxfh_indir_size,
+	.get_rxfh_key_size	= efx_ethtool_get_rxfh_key_size,
 	.get_rxfh		= efx_ethtool_get_rxfh,
 	.set_rxfh		= efx_ethtool_set_rxfh,
 	.get_ts_info		= efx_ethtool_get_ts_info,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index b20fe43..ad53551 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1311,7 +1311,7 @@ struct efx_nic_type {
 	unsigned int (*tx_limit_len)(struct efx_tx_queue *tx_queue,
 				     dma_addr_t dma_addr, unsigned int len);
 	int (*rx_push_rss_config)(struct efx_nic *efx, bool user,
-				  const u32 *rx_indir_table);
+				  const u32 *rx_indir_table, const u8 *key);
 	int (*rx_probe)(struct efx_rx_queue *rx_queue);
 	void (*rx_init)(struct efx_rx_queue *rx_queue);
 	void (*rx_remove)(struct efx_rx_queue *rx_queue);
@@ -1410,6 +1410,7 @@ struct efx_nic_type {
 	int mcdi_max_ver;
 	unsigned int max_rx_ip_filters;
 	u32 hwtstamp_filters;
+	unsigned int rx_hash_key_size;
 };
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 118ff56..0606aa2 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -333,11 +333,13 @@ static int siena_probe_nic(struct efx_nic *efx)
 }
 
 static int siena_rx_push_rss_config(struct efx_nic *efx, bool user,
-				    const u32 *rx_indir_table)
+				    const u32 *rx_indir_table, const u8 *key)
 {
 	efx_oword_t temp;
 
 	/* Set hash key for IPv4 */
+	if (key)
+		memcpy(efx->rx_hash_key, key, sizeof(temp));
 	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
 	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
 
@@ -402,7 +404,7 @@ static int siena_init_nic(struct efx_nic *efx)
 			    EFX_RX_USR_BUF_SIZE >> 5);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
-	siena_rx_push_rss_config(efx, false, efx->rx_indir_table);
+	siena_rx_push_rss_config(efx, false, efx->rx_indir_table, NULL);
 	efx->rss_active = true;
 
 	/* Enable event logging */
@@ -1054,4 +1056,5 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.hwtstamp_filters = (1 << HWTSTAMP_FILTER_NONE |
 			     1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT |
 			     1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT),
+	.rx_hash_key_size = 16,
 };
