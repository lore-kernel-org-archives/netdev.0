From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 13/14] sfc: Add use of shared RSS contexts.
Date: Wed, 6 May 2015 00:59:38 +0100
Message-ID: <5549596A.5000805@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:54134 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932101AbbEEX7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:59:44 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Allow PFs to allocate shared RSS contexts if we exhaust our
exclusive RSS contexts. Make VFs use shared RSS contexts in
all cases.
Spruce up error handling so that the shadow copy of the RSS
table is updated after successful update, rather than in all
cases, so that we report the actual contents of the RSS table
after a failure to set it, rather than what we'd like it to be.

Populate context_size parameter when vacuously allocating RSS
context of size 1.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 157 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/efx.c        |  17 ++--
 drivers/net/ethernet/sfc/efx.h        |   1 +
 drivers/net/ethernet/sfc/ethtool.c    |   5 +-
 drivers/net/ethernet/sfc/falcon.c     |  19 +++-
 drivers/net/ethernet/sfc/net_driver.h |   3 +-
 drivers/net/ethernet/sfc/nic.h        |   2 +
 drivers/net/ethernet/sfc/siena.c      |   9 +-
 8 files changed, 177 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ae0ed2a..7a67202 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -31,6 +31,9 @@ enum {
 
 /* The reserved RSS context value */
 #define EFX_EF10_RSS_CONTEXT_INVALID	0xffffffff
+/* The maximum size of a shared RSS context */
+/* TODO: this should really be from the mcdi protocol export */
+#define EFX_EF10_MAX_SHARED_RSS_CONTEXT_SIZE 64UL
 
 /* The filter table(s) are managed by firmware and we have write-only
  * access.  When removing filters we must identify them to the
@@ -78,7 +81,6 @@ struct efx_ef10_filter_table {
 /* An arbitrary search limit for the software hash table */
 #define EFX_EF10_FILTER_SEARCH_LIMIT 200
 
-static void efx_ef10_rx_push_rss_config(struct efx_nic *efx);
 static void efx_ef10_rx_free_indir_table(struct efx_nic *efx);
 static void efx_ef10_filter_table_remove(struct efx_nic *efx);
 
@@ -751,7 +753,9 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 		nic_data->must_restore_piobufs = false;
 	}
 
-	efx_ef10_rx_push_rss_config(efx);
+	/* don't fail init if RSS setup doesn't work */
+	efx->type->rx_push_rss_config(efx, false, efx->rx_indir_table);
+
 	return 0;
 }
 
@@ -1455,20 +1459,33 @@ static void efx_ef10_tx_write(struct efx_tx_queue *tx_queue)
 	}
 }
 
-static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context)
+static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context,
+				      bool exclusive, unsigned *context_size)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_RSS_CONTEXT_ALLOC_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_RSS_CONTEXT_ALLOC_OUT_LEN);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	size_t outlen;
 	int rc;
+	u32 alloc_type = exclusive ?
+				MC_CMD_RSS_CONTEXT_ALLOC_IN_TYPE_EXCLUSIVE :
+				MC_CMD_RSS_CONTEXT_ALLOC_IN_TYPE_SHARED;
+	unsigned rss_spread = exclusive ?
+				efx->rss_spread :
+				min(rounddown_pow_of_two(efx->rss_spread),
+				    EFX_EF10_MAX_SHARED_RSS_CONTEXT_SIZE);
+
+	if (!exclusive && rss_spread == 1) {
+		*context = EFX_EF10_RSS_CONTEXT_INVALID;
+		if (context_size)
+			*context_size = 1;
+		return 0;
+	}
 
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_UPSTREAM_PORT_ID,
 		       nic_data->vport_id);
-	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_TYPE,
-		       MC_CMD_RSS_CONTEXT_ALLOC_IN_TYPE_EXCLUSIVE);
-	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_NUM_QUEUES,
-		       EFX_MAX_CHANNELS);
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_TYPE, alloc_type);
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_NUM_QUEUES, rss_spread);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_ALLOC, inbuf, sizeof(inbuf),
 		outbuf, sizeof(outbuf), &outlen);
@@ -1480,6 +1497,9 @@ static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context)
 
 	*context = MCDI_DWORD(outbuf, RSS_CONTEXT_ALLOC_OUT_RSS_CONTEXT_ID);
 
+	if (context_size)
+		*context_size = rss_spread;
+
 	return 0;
 }
 
@@ -1496,7 +1516,8 @@ static void efx_ef10_free_rss_context(struct efx_nic *efx, u32 context)
 	WARN_ON(rc != 0);
 }
 
-static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context)
+static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context,
+				       const u32 *rx_indir_table)
 {
 	MCDI_DECLARE_BUF(tablebuf, MC_CMD_RSS_CONTEXT_SET_TABLE_IN_LEN);
 	MCDI_DECLARE_BUF(keybuf, MC_CMD_RSS_CONTEXT_SET_KEY_IN_LEN);
@@ -1510,7 +1531,7 @@ static int efx_ef10_populate_rss_table(struct efx_nic *efx, u32 context)
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); ++i)
 		MCDI_PTR(tablebuf,
 			 RSS_CONTEXT_SET_TABLE_IN_INDIRECTION_TABLE)[i] =
-				(u8) efx->rx_indir_table[i];
+				(u8) rx_indir_table[i];
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_SET_TABLE, tablebuf,
 			  sizeof(tablebuf), NULL, 0, NULL);
@@ -1538,27 +1559,119 @@ static void efx_ef10_rx_free_indir_table(struct efx_nic *efx)
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 }
 
-static void efx_ef10_rx_push_rss_config(struct efx_nic *efx)
+static int efx_ef10_rx_push_shared_rss_config(struct efx_nic *efx,
+					      unsigned *context_size)
 {
+	u32 new_rx_rss_context;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	int rc;
+	int rc = efx_ef10_alloc_rss_context(efx, &new_rx_rss_context,
+					    false, context_size);
+
+	if (rc != 0)
+		return rc;
 
-	netif_dbg(efx, drv, efx->net_dev, "pushing RSS config\n");
+	nic_data->rx_rss_context = new_rx_rss_context;
+	nic_data->rx_rss_context_exclusive = false;
+	efx_set_default_rx_indir_table(efx);
+	return 0;
+}
 
-	if (nic_data->rx_rss_context == EFX_EF10_RSS_CONTEXT_INVALID) {
-		rc = efx_ef10_alloc_rss_context(efx, &nic_data->rx_rss_context);
-		if (rc != 0)
-			goto fail;
+static int efx_ef10_rx_push_exclusive_rss_config(struct efx_nic *efx,
+						 const u32 *rx_indir_table)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc;
+	u32 new_rx_rss_context;
+
+	if (nic_data->rx_rss_context == EFX_EF10_RSS_CONTEXT_INVALID ||
+	    !nic_data->rx_rss_context_exclusive) {
+		rc = efx_ef10_alloc_rss_context(efx, &new_rx_rss_context,
+						true, NULL);
+		if (rc == -EOPNOTSUPP)
+			return rc;
+		else if (rc != 0)
+			goto fail1;
+	} else {
+		new_rx_rss_context = nic_data->rx_rss_context;
 	}
 
-	rc = efx_ef10_populate_rss_table(efx, nic_data->rx_rss_context);
+	rc = efx_ef10_populate_rss_table(efx, new_rx_rss_context,
+					 rx_indir_table);
 	if (rc != 0)
-		goto fail;
+		goto fail2;
 
-	return;
+	if (nic_data->rx_rss_context != new_rx_rss_context)
+		efx_ef10_rx_free_indir_table(efx);
+	nic_data->rx_rss_context = new_rx_rss_context;
+	nic_data->rx_rss_context_exclusive = true;
+	if (rx_indir_table != efx->rx_indir_table)
+		memcpy(efx->rx_indir_table, rx_indir_table,
+		       sizeof(efx->rx_indir_table));
+	return 0;
 
-fail:
+fail2:
+	if (new_rx_rss_context != nic_data->rx_rss_context)
+		efx_ef10_free_rss_context(efx, new_rx_rss_context);
+fail1:
 	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
+static int efx_ef10_pf_rx_push_rss_config(struct efx_nic *efx, bool user,
+					  const u32 *rx_indir_table)
+{
+	int rc;
+
+	if (efx->rss_spread == 1)
+		return 0;
+
+	rc = efx_ef10_rx_push_exclusive_rss_config(efx, rx_indir_table);
+
+	if (rc == -ENOBUFS && !user) {
+		unsigned context_size;
+		bool mismatch = false;
+		size_t i;
+
+		for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table) && !mismatch;
+		     i++)
+			mismatch = rx_indir_table[i] !=
+				ethtool_rxfh_indir_default(i, efx->rss_spread);
+
+		rc = efx_ef10_rx_push_shared_rss_config(efx, &context_size);
+		if (rc == 0) {
+			if (context_size != efx->rss_spread)
+				netif_warn(efx, probe, efx->net_dev,
+					   "Could not allocate an exclusive RSS"
+					   " context; allocated a shared one of"
+					   " different size."
+					   " Wanted %u, got %u.\n",
+					   efx->rss_spread, context_size);
+			else if (mismatch)
+				netif_warn(efx, probe, efx->net_dev,
+					   "Could not allocate an exclusive RSS"
+					   " context; allocated a shared one but"
+					   " could not apply custom"
+					   " indirection.\n");
+			else
+				netif_info(efx, probe, efx->net_dev,
+					   "Could not allocate an exclusive RSS"
+					   " context; allocated a shared one.\n");
+		}
+	}
+	return rc;
+}
+
+static int efx_ef10_vf_rx_push_rss_config(struct efx_nic *efx, bool user,
+					  const u32 *rx_indir_table
+					  __attribute__ ((unused)))
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	if (user)
+		return -EOPNOTSUPP;
+	if (nic_data->rx_rss_context != EFX_EF10_RSS_CONTEXT_INVALID)
+		return 0;
+	return efx_ef10_rx_push_shared_rss_config(efx, NULL);
 }
 
 static int efx_ef10_rx_probe(struct efx_rx_queue *rx_queue)
@@ -3738,7 +3851,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.tx_init = efx_ef10_tx_init,
 	.tx_remove = efx_ef10_tx_remove,
 	.tx_write = efx_ef10_tx_write,
-	.rx_push_rss_config = efx_ef10_rx_push_rss_config,
+	.rx_push_rss_config = efx_ef10_vf_rx_push_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
 	.rx_remove = efx_ef10_rx_remove,
@@ -3837,7 +3950,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.tx_init = efx_ef10_tx_init,
 	.tx_remove = efx_ef10_tx_remove,
 	.tx_write = efx_ef10_tx_write,
-	.rx_push_rss_config = efx_ef10_rx_push_rss_config,
+	.rx_push_rss_config = efx_ef10_pf_rx_push_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
 	.rx_remove = efx_ef10_rx_remove,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 78f7760..706b936 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1290,6 +1290,15 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
+void efx_set_default_rx_indir_table(struct efx_nic *efx)
+{
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
+		efx->rx_indir_table[i] =
+			ethtool_rxfh_indir_default(i, efx->rss_spread);
+}
+
 static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 {
 	cpumask_var_t thread_mask;
@@ -1607,7 +1616,6 @@ static void efx_set_channels(struct efx_nic *efx)
 
 static int efx_probe_nic(struct efx_nic *efx)
 {
-	size_t i;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "creating NIC\n");
@@ -1630,10 +1638,9 @@ static int efx_probe_nic(struct efx_nic *efx)
 		goto fail2;
 
 	if (efx->n_channels > 1)
-		netdev_rss_key_fill(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
-	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
-		efx->rx_indir_table[i] =
-			ethtool_rxfh_indir_default(i, efx->rss_spread);
+		netdev_rss_key_fill(&efx->rx_hash_key,
+				    sizeof(efx->rx_hash_key));
+	efx_set_default_rx_indir_table(efx);
 
 	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
 	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 946607f..9097906 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -34,6 +34,7 @@ unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 
 /* RX */
+void efx_set_default_rx_indir_table(struct efx_nic *efx);
 void efx_rx_config_page_split(struct efx_nic *efx);
 int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 4835bc0..03829b4 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1109,9 +1109,8 @@ static int efx_ethtool_set_rxfh(struct net_device *net_dev, const u32 *indir,
 		return -EOPNOTSUPP;
 	if (!indir)
 		return 0;
-	memcpy(efx->rx_indir_table, indir, sizeof(efx->rx_indir_table));
-	efx->type->rx_push_rss_config(efx);
-	return 0;
+
+	return efx->type->rx_push_rss_config(efx, true, indir);
 }
 
 static int efx_ethtool_get_ts_info(struct net_device *net_dev,
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 5a23435..3bb1da8 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -477,16 +477,29 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
  *
  **************************************************************************
  */
+static int dummy_rx_push_rss_config(struct efx_nic *efx, bool user,
+				    const u32 *rx_indir_table)
+{
+	(void) efx;
+	(void) user;
+	(void) rx_indir_table;
+	return -ENOSYS;
+}
 
-static void falcon_b0_rx_push_rss_config(struct efx_nic *efx)
+static int falcon_b0_rx_push_rss_config(struct efx_nic *efx, bool user,
+					const u32 *rx_indir_table)
 {
 	efx_oword_t temp;
 
+	(void) user;
 	/* Set hash key for IPv4 */
 	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
 	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
 
+	memcpy(efx->rx_indir_table, rx_indir_table,
+	       sizeof(efx->rx_indir_table));
 	efx_farch_rx_push_indir_table(efx);
+	return 0;
 }
 
 /**************************************************************************
@@ -2507,7 +2520,7 @@ static int falcon_init_nic(struct efx_nic *efx)
 	falcon_init_rx_cfg(efx);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		falcon_b0_rx_push_rss_config(efx);
+		falcon_b0_rx_push_rss_config(efx, false, efx->rx_indir_table);
 
 		/* Set destination of both TX and RX Flush events */
 		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
@@ -2730,7 +2743,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
-	.rx_push_rss_config = efx_port_dummy_op_void,
+	.rx_push_rss_config = dummy_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
 	.rx_remove = efx_farch_rx_remove,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index dd7134e..9498a42 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1276,7 +1276,8 @@ struct efx_nic_type {
 	void (*tx_init)(struct efx_tx_queue *tx_queue);
 	void (*tx_remove)(struct efx_tx_queue *tx_queue);
 	void (*tx_write)(struct efx_tx_queue *tx_queue);
-	void (*rx_push_rss_config)(struct efx_nic *efx);
+	int (*rx_push_rss_config)(struct efx_nic *efx, bool user,
+				  const u32 *rx_indir_table);
 	int (*rx_probe)(struct efx_rx_queue *rx_queue);
 	void (*rx_init)(struct efx_rx_queue *rx_queue);
 	void (*rx_remove)(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index e833e97..2fd3055 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -485,6 +485,7 @@ enum {
  * @must_restore_piobufs: Flag: PIO buffers have yet to be restored after MC
  *	reboot
  * @rx_rss_context: Firmware handle for our RSS context
+ * @rx_rss_context_exclusive: Whether our RSS context is exclusive or shared
  * @stats: Hardware statistics
  * @workaround_35388: Flag: firmware supports workaround for bug 35388
  * @must_check_datapath_caps: Flag: @datapath_caps needs to be revalidated
@@ -513,6 +514,7 @@ struct efx_ef10_nic_data {
 	unsigned int piobuf_handle[EF10_TX_PIOBUF_COUNT];
 	bool must_restore_piobufs;
 	u32 rx_rss_context;
+	bool rx_rss_context_exclusive;
 	u64 stats[EF10_STAT_COUNT];
 	bool workaround_35388;
 	bool must_check_datapath_caps;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 95babe2..a36ed1b 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -324,7 +324,8 @@ fail1:
 	return rc;
 }
 
-static void siena_rx_push_rss_config(struct efx_nic *efx)
+static int siena_rx_push_rss_config(struct efx_nic *efx, bool user,
+				    const u32 *rx_indir_table)
 {
 	efx_oword_t temp;
 
@@ -346,7 +347,11 @@ static void siena_rx_push_rss_config(struct efx_nic *efx)
 	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
 	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
 
+	memcpy(efx->rx_indir_table, rx_indir_table,
+	       sizeof(efx->rx_indir_table));
 	efx_farch_rx_push_indir_table(efx);
+
+	return 0;
 }
 
 /* This call performs hardware-specific global initialisation, such as
@@ -389,7 +394,7 @@ static int siena_init_nic(struct efx_nic *efx)
 			    EFX_RX_USR_BUF_SIZE >> 5);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
-	siena_rx_push_rss_config(efx);
+	siena_rx_push_rss_config(efx, false, efx->rx_indir_table);
 
 	/* Enable event logging */
 	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
