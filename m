From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: Add NIC type operations to replace direct
 calls from efx.c into siena_sriov.c
Date: Wed, 5 Nov 2014 12:16:46 +0000
Message-ID: <545A152E.4050606@solarflare.com>
References: <545A14CD.6040809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:1131 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753916AbaKEMU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 07:20:29 -0500
In-Reply-To: <545A14CD.6040809@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also add dummy functions where required to avoid NULL pointer dereference.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  5 +++++
 drivers/net/ethernet/sfc/efx.c        | 13 +++++++------
 drivers/net/ethernet/sfc/falcon.c     | 10 ++++++++++
 drivers/net/ethernet/sfc/farch.c      |  2 +-
 drivers/net/ethernet/sfc/net_driver.h |  5 +++++
 drivers/net/ethernet/sfc/nic.h        | 24 +++++++++++++++++++++++-
 drivers/net/ethernet/sfc/siena.c      |  5 +++++
 7 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 002d4cd..ff55a19 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3688,6 +3688,11 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.ptp_write_host_time = efx_ef10_ptp_write_host_time,
 	.ptp_set_ts_sync_events = efx_ef10_ptp_set_ts_sync_events,
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config,
+	.sriov_init = efx_ef10_sriov_init,
+	.sriov_fini = efx_ef10_sriov_fini,
+	.sriov_mac_address_changed = efx_ef10_sriov_mac_address_changed,
+	.sriov_wanted = efx_ef10_sriov_wanted,
+	.sriov_reset = efx_ef10_sriov_reset,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2236ffc..b49d048 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1314,7 +1314,7 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 	/* If RSS is requested for the PF *and* VFs then we can't write RSS
 	 * table entries that are inaccessible to VFs
 	 */
-	if (efx_siena_sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
+	if (efx->type->sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
 	    count > efx_vf_size(efx)) {
 		netif_warn(efx, probe, efx->net_dev,
 			   "Reducing number of RSS channels from %u to %u for "
@@ -1426,8 +1426,9 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	}
 
 	/* RSS might be usable on VFs even if it is disabled on the PF */
+
 	efx->rss_spread = ((efx->n_rx_channels > 1 ||
-			    !efx_siena_sriov_wanted(efx)) ?
+			    !efx->type->sriov_wanted(efx)) ?
 			   efx->n_rx_channels : efx_vf_size(efx));
 
 	return 0;
@@ -2167,7 +2168,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	}
 
 	ether_addr_copy(net_dev->dev_addr, new_addr);
-	efx_siena_sriov_mac_address_changed(efx);
+	efx->type->sriov_mac_address_changed(efx);
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
@@ -2434,7 +2435,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	if (rc)
 		goto fail;
 	efx_restore_filters(efx);
-	efx_siena_sriov_reset(efx);
+	efx->type->sriov_reset(efx);
 
 	mutex_unlock(&efx->mac_lock);
 
@@ -2827,7 +2828,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_disable_interrupts(efx);
 	rtnl_unlock();
 
-	efx_siena_sriov_fini(efx);
+	efx->type->sriov_fini(efx);
 	efx_unregister_netdev(efx);
 
 	efx_mtd_remove(efx);
@@ -3024,7 +3025,7 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail4;
 
-	rc = efx_siena_sriov_init(efx);
+	rc = efx->type->sriov_init(efx);
 	if (rc)
 		netif_err(efx, probe, efx->net_dev,
 			  "SR-IOV can't be enabled rc %d\n", rc);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 1570375..f166c8e 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2766,6 +2766,11 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.mtd_write = falcon_mtd_write,
 	.mtd_sync = falcon_mtd_sync,
 #endif
+	.sriov_init = efx_falcon_sriov_init,
+	.sriov_fini = efx_falcon_sriov_fini,
+	.sriov_mac_address_changed = efx_falcon_sriov_mac_address_changed,
+	.sriov_wanted = efx_falcon_sriov_wanted,
+	.sriov_reset = efx_falcon_sriov_reset,
 
 	.revision = EFX_REV_FALCON_A1,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
@@ -2862,6 +2867,11 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.mtd_write = falcon_mtd_write,
 	.mtd_sync = falcon_mtd_sync,
 #endif
+	.sriov_init = efx_falcon_sriov_init,
+	.sriov_fini = efx_falcon_sriov_fini,
+	.sriov_mac_address_changed = efx_falcon_sriov_mac_address_changed,
+	.sriov_wanted = efx_falcon_sriov_wanted,
+	.sriov_reset = efx_falcon_sriov_reset,
 
 	.revision = EFX_REV_FALCON_B0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index f5549a9..7597532 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1685,7 +1685,7 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
 	vi_count = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
 
 #ifdef CONFIG_SFC_SRIOV
-	if (efx_siena_sriov_wanted(efx)) {
+	if (efx->type->sriov_wanted(efx)) {
 		unsigned vi_dc_entries, buftbl_free, entries_per_vf, vf_limit;
 
 		nic_data->vf_buftbl_base = buftbl_min;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 779a1f5..325dd94 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1330,6 +1330,11 @@ struct efx_nic_type {
 	int (*ptp_set_ts_sync_events)(struct efx_nic *efx, bool en, bool temp);
 	int (*ptp_set_ts_config)(struct efx_nic *efx,
 				 struct hwtstamp_config *init);
+	int (*sriov_init)(struct efx_nic *efx);
+	void (*sriov_fini)(struct efx_nic *efx);
+	void (*sriov_mac_address_changed)(struct efx_nic *efx);
+	bool (*sriov_wanted)(struct efx_nic *efx);
+	void (*sriov_reset)(struct efx_nic *efx);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 1ab3eda..93d10cbb 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -540,6 +540,7 @@ struct efx_ef10_nic_data {
 
 #ifdef CONFIG_SFC_SRIOV
 
+/* SIENA */
 static inline bool efx_siena_sriov_wanted(struct efx_nic *efx)
 {
 	return efx->vf_count != 0;
@@ -568,12 +569,19 @@ void efx_siena_sriov_reset(struct efx_nic *efx);
 void efx_siena_sriov_fini(struct efx_nic *efx);
 void efx_fini_sriov(void);
 
+/* EF10 */
+static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx) { return false; }
+static inline int efx_ef10_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
+static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
+
 #else
 
+/* SIENA */
 static inline bool efx_siena_sriov_wanted(struct efx_nic *efx) { return false; }
 static inline bool efx_siena_sriov_enabled(struct efx_nic *efx) { return false; }
 static inline unsigned int efx_vf_size(struct efx_nic *efx) { return 0; }
-
 static inline int efx_init_sriov(void) { return 0; }
 static inline void efx_siena_sriov_probe(struct efx_nic *efx) {}
 static inline int efx_siena_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
@@ -591,8 +599,22 @@ static inline void efx_siena_sriov_reset(struct efx_nic *efx) {}
 static inline void efx_siena_sriov_fini(struct efx_nic *efx) {}
 static inline void efx_fini_sriov(void) {}
 
+/* EF10 */
+static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx) { return false; }
+static inline int efx_ef10_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
+static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
+
 #endif
 
+/* FALCON */
+static inline bool efx_falcon_sriov_wanted(struct efx_nic *efx) { return false; }
+static inline int efx_falcon_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
+static inline void efx_falcon_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline void efx_falcon_sriov_reset(struct efx_nic *efx) {}
+static inline void efx_falcon_sriov_fini(struct efx_nic *efx) {}
+
 int efx_siena_sriov_set_vf_mac(struct net_device *dev, int vf, u8 *mac);
 int efx_siena_sriov_set_vf_vlan(struct net_device *dev, int vf,
 				u16 vlan, u8 qos);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index cf40d60..3583f02 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -997,6 +997,11 @@ const struct efx_nic_type siena_a0_nic_type = {
 #endif
 	.ptp_write_host_time = siena_ptp_write_host_time,
 	.ptp_set_ts_config = siena_ptp_set_ts_config,
+	.sriov_init = efx_siena_sriov_init,
+	.sriov_fini = efx_siena_sriov_fini,
+	.sriov_mac_address_changed = efx_siena_sriov_mac_address_changed,
+	.sriov_wanted = efx_siena_sriov_wanted,
+	.sriov_reset = efx_siena_sriov_reset,
 
 	.revision = EFX_REV_SIENA_A0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
