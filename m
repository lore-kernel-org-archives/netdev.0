From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: Rename implementations in siena_sriov.c
 to have a 'siena' prefix
Date: Wed, 5 Nov 2014 12:16:32 +0000
Message-ID: <545A1520.6090307@solarflare.com>
References: <545A14CD.6040809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:61501 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbaKEMYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 07:24:49 -0500
In-Reply-To: <545A14CD.6040809@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch in preparation for the upcoming EF10 sriov support.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c         |  21 ++--
 drivers/net/ethernet/sfc/farch.c       |  16 +--
 drivers/net/ethernet/sfc/mcdi.c        |   2 +-
 drivers/net/ethernet/sfc/nic.h         |  70 +++++++------
 drivers/net/ethernet/sfc/siena.c       |   2 +-
 drivers/net/ethernet/sfc/siena_sriov.c | 179 +++++++++++++++++----------------
 6 files changed, 149 insertions(+), 141 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b2cc590..2236ffc 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1314,7 +1314,7 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 	/* If RSS is requested for the PF *and* VFs then we can't write RSS
 	 * table entries that are inaccessible to VFs
 	 */
-	if (efx_sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
+	if (efx_siena_sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
 	    count > efx_vf_size(efx)) {
 		netif_warn(efx, probe, efx->net_dev,
 			   "Reducing number of RSS channels from %u to %u for "
@@ -1426,7 +1426,8 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	}
 
 	/* RSS might be usable on VFs even if it is disabled on the PF */
-	efx->rss_spread = ((efx->n_rx_channels > 1 || !efx_sriov_wanted(efx)) ?
+	efx->rss_spread = ((efx->n_rx_channels > 1 ||
+			    !efx_siena_sriov_wanted(efx)) ?
 			   efx->n_rx_channels : efx_vf_size(efx));
 
 	return 0;
@@ -2166,7 +2167,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	}
 
 	ether_addr_copy(net_dev->dev_addr, new_addr);
-	efx_sriov_mac_address_changed(efx);
+	efx_siena_sriov_mac_address_changed(efx);
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
@@ -2210,10 +2211,10 @@ static const struct net_device_ops efx_farch_netdev_ops = {
 	.ndo_set_rx_mode	= efx_set_rx_mode,
 	.ndo_set_features	= efx_set_features,
 #ifdef CONFIG_SFC_SRIOV
-	.ndo_set_vf_mac		= efx_sriov_set_vf_mac,
-	.ndo_set_vf_vlan	= efx_sriov_set_vf_vlan,
-	.ndo_set_vf_spoofchk	= efx_sriov_set_vf_spoofchk,
-	.ndo_get_vf_config	= efx_sriov_get_vf_config,
+	.ndo_set_vf_mac		= efx_siena_sriov_set_vf_mac,
+	.ndo_set_vf_vlan	= efx_siena_sriov_set_vf_vlan,
+	.ndo_set_vf_spoofchk	= efx_siena_sriov_set_vf_spoofchk,
+	.ndo_get_vf_config	= efx_siena_sriov_get_vf_config,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
@@ -2433,7 +2434,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	if (rc)
 		goto fail;
 	efx_restore_filters(efx);
-	efx_sriov_reset(efx);
+	efx_siena_sriov_reset(efx);
 
 	mutex_unlock(&efx->mac_lock);
 
@@ -2826,7 +2827,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_disable_interrupts(efx);
 	rtnl_unlock();
 
-	efx_sriov_fini(efx);
+	efx_siena_sriov_fini(efx);
 	efx_unregister_netdev(efx);
 
 	efx_mtd_remove(efx);
@@ -3023,7 +3024,7 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail4;
 
-	rc = efx_sriov_init(efx);
+	rc = efx_siena_sriov_init(efx);
 	if (rc)
 		netif_err(efx, probe, efx->net_dev,
 			  "SR-IOV can't be enabled rc %d\n", rc);
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 0274401..f5549a9 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -240,7 +240,7 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 	buffer->index = efx->next_buffer_table;
 	efx->next_buffer_table += buffer->entries;
 #ifdef CONFIG_SFC_SRIOV
-	BUG_ON(efx_sriov_enabled(efx) &&
+	BUG_ON(efx_siena_sriov_enabled(efx) &&
 	       nic_data->vf_buftbl_base < efx->next_buffer_table);
 #endif
 
@@ -670,7 +670,7 @@ static int efx_farch_do_flush(struct efx_nic *efx)
 		 * the firmware (though we will still have to poll for
 		 * completion). If that fails, fall back to the old scheme.
 		 */
-		if (efx_sriov_enabled(efx)) {
+		if (efx_siena_sriov_enabled(efx)) {
 			rc = efx_mcdi_flush_rxqs(efx);
 			if (!rc)
 				goto wait;
@@ -1198,13 +1198,13 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 		netif_vdbg(efx, hw, efx->net_dev, "channel %d TXQ %d flushed\n",
 			   channel->channel, ev_sub_data);
 		efx_farch_handle_tx_flush_done(efx, event);
-		efx_sriov_tx_flush_done(efx, event);
+		efx_siena_sriov_tx_flush_done(efx, event);
 		break;
 	case FSE_AZ_RX_DESCQ_FLS_DONE_EV:
 		netif_vdbg(efx, hw, efx->net_dev, "channel %d RXQ %d flushed\n",
 			   channel->channel, ev_sub_data);
 		efx_farch_handle_rx_flush_done(efx, event);
-		efx_sriov_rx_flush_done(efx, event);
+		efx_siena_sriov_rx_flush_done(efx, event);
 		break;
 	case FSE_AZ_EVQ_INIT_DONE_EV:
 		netif_dbg(efx, hw, efx->net_dev,
@@ -1243,7 +1243,7 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 				  ev_sub_data);
 			efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 		} else
-			efx_sriov_desc_fetch_err(efx, ev_sub_data);
+			efx_siena_sriov_desc_fetch_err(efx, ev_sub_data);
 		break;
 	case FSE_BZ_TX_DSC_ERROR_EV:
 		if (ev_sub_data < EFX_VI_BASE) {
@@ -1253,7 +1253,7 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 				  ev_sub_data);
 			efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 		} else
-			efx_sriov_desc_fetch_err(efx, ev_sub_data);
+			efx_siena_sriov_desc_fetch_err(efx, ev_sub_data);
 		break;
 	default:
 		netif_vdbg(efx, hw, efx->net_dev,
@@ -1318,7 +1318,7 @@ int efx_farch_ev_process(struct efx_channel *channel, int budget)
 			efx_farch_handle_driver_event(channel, &event);
 			break;
 		case FSE_CZ_EV_CODE_USER_EV:
-			efx_sriov_event(channel, &event);
+			efx_siena_sriov_event(channel, &event);
 			break;
 		case FSE_CZ_EV_CODE_MCDI_EV:
 			efx_mcdi_process_event(channel, &event);
@@ -1685,7 +1685,7 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
 	vi_count = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
 
 #ifdef CONFIG_SFC_SRIOV
-	if (efx_sriov_wanted(efx)) {
+	if (efx_siena_sriov_wanted(efx)) {
 		unsigned vi_dc_entries, buftbl_free, entries_per_vf, vf_limit;
 
 		nic_data->vf_buftbl_base = buftbl_min;
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 5239cf9..d37928f 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1035,7 +1035,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		/* MAC stats are gather lazily.  We can ignore this. */
 		break;
 	case MCDI_EVENT_CODE_FLR:
-		efx_sriov_flr(efx, MCDI_EVENT_FIELD(*event, FLR_VF));
+		efx_siena_sriov_flr(efx, MCDI_EVENT_FIELD(*event, FLR_VF));
 		break;
 	case MCDI_EVENT_CODE_PTP_RX:
 	case MCDI_EVENT_CODE_PTP_FAULT:
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index b5fe1f2..1ab3eda 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -540,62 +540,66 @@ struct efx_ef10_nic_data {
 
 #ifdef CONFIG_SFC_SRIOV
 
-static inline bool efx_sriov_wanted(struct efx_nic *efx)
+static inline bool efx_siena_sriov_wanted(struct efx_nic *efx)
 {
 	return efx->vf_count != 0;
 }
-static inline bool efx_sriov_enabled(struct efx_nic *efx)
+
+static inline bool efx_siena_sriov_enabled(struct efx_nic *efx)
 {
 	return efx->vf_init_count != 0;
 }
+
 static inline unsigned int efx_vf_size(struct efx_nic *efx)
 {
 	return 1 << efx->vi_scale;
 }
 
 int efx_init_sriov(void);
-void efx_sriov_probe(struct efx_nic *efx);
-int efx_sriov_init(struct efx_nic *efx);
-void efx_sriov_mac_address_changed(struct efx_nic *efx);
-void efx_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event);
-void efx_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event);
-void efx_sriov_event(struct efx_channel *channel, efx_qword_t *event);
-void efx_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq);
-void efx_sriov_flr(struct efx_nic *efx, unsigned flr);
-void efx_sriov_reset(struct efx_nic *efx);
-void efx_sriov_fini(struct efx_nic *efx);
+void efx_siena_sriov_probe(struct efx_nic *efx);
+int efx_siena_sriov_init(struct efx_nic *efx);
+void efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
+void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event);
+void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event);
+void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event);
+void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq);
+void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr);
+void efx_siena_sriov_reset(struct efx_nic *efx);
+void efx_siena_sriov_fini(struct efx_nic *efx);
 void efx_fini_sriov(void);
 
 #else
 
-static inline bool efx_sriov_wanted(struct efx_nic *efx) { return false; }
-static inline bool efx_sriov_enabled(struct efx_nic *efx) { return false; }
+static inline bool efx_siena_sriov_wanted(struct efx_nic *efx) { return false; }
+static inline bool efx_siena_sriov_enabled(struct efx_nic *efx) { return false; }
 static inline unsigned int efx_vf_size(struct efx_nic *efx) { return 0; }
 
 static inline int efx_init_sriov(void) { return 0; }
-static inline void efx_sriov_probe(struct efx_nic *efx) {}
-static inline int efx_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
-static inline void efx_sriov_mac_address_changed(struct efx_nic *efx) {}
-static inline void efx_sriov_tx_flush_done(struct efx_nic *efx,
-					   efx_qword_t *event) {}
-static inline void efx_sriov_rx_flush_done(struct efx_nic *efx,
-					   efx_qword_t *event) {}
-static inline void efx_sriov_event(struct efx_channel *channel,
-				   efx_qword_t *event) {}
-static inline void efx_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq) {}
-static inline void efx_sriov_flr(struct efx_nic *efx, unsigned flr) {}
-static inline void efx_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_sriov_fini(struct efx_nic *efx) {}
+static inline void efx_siena_sriov_probe(struct efx_nic *efx) {}
+static inline int efx_siena_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
+static inline void efx_siena_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline void efx_siena_sriov_tx_flush_done(struct efx_nic *efx,
+						 efx_qword_t *event) {}
+static inline void efx_siena_sriov_rx_flush_done(struct efx_nic *efx,
+						 efx_qword_t *event) {}
+static inline void efx_siena_sriov_event(struct efx_channel *channel,
+					 efx_qword_t *event) {}
+static inline void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx,
+						  unsigned dmaq) {}
+static inline void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr) {}
+static inline void efx_siena_sriov_reset(struct efx_nic *efx) {}
+static inline void efx_siena_sriov_fini(struct efx_nic *efx) {}
 static inline void efx_fini_sriov(void) {}
 
 #endif
 
-int efx_sriov_set_vf_mac(struct net_device *dev, int vf, u8 *mac);
-int efx_sriov_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos);
-int efx_sriov_get_vf_config(struct net_device *dev, int vf,
-			    struct ifla_vf_info *ivf);
-int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
-			      bool spoofchk);
+int efx_siena_sriov_set_vf_mac(struct net_device *dev, int vf, u8 *mac);
+int efx_siena_sriov_set_vf_vlan(struct net_device *dev, int vf,
+				u16 vlan, u8 qos);
+int efx_siena_sriov_get_vf_config(struct net_device *dev, int vf,
+				  struct ifla_vf_info *ivf);
+int efx_siena_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
+				    bool spoofchk);
 
 struct ethtool_ts_info;
 int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index ffce06d..cf40d60 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -307,7 +307,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail5;
 
-	efx_sriov_probe(efx);
+	efx_siena_sriov_probe(efx);
 	efx_ptp_defer_probe_with_channel(efx);
 
 	return 0;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 2b75eee..a8bbbad 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -66,7 +66,7 @@ enum efx_vf_tx_filter_mode {
  * @status_lock: Mutex protecting @msg_seqno, @status_addr, @addr,
  *	@peer_page_addrs and @peer_page_count from simultaneous
  *	updates by the VM and consumption by
- *	efx_sriov_update_vf_addr()
+ *	efx_siena_sriov_update_vf_addr()
  * @peer_page_addrs: Pointer to an array of guest pages for local addresses.
  * @peer_page_count: Number of entries in @peer_page_count.
  * @evq0_addrs: Array of guest pages backing evq0.
@@ -194,8 +194,8 @@ static unsigned abs_index(struct efx_vf *vf, unsigned index)
 	return EFX_VI_BASE + vf->index * efx_vf_size(vf->efx) + index;
 }
 
-static int efx_sriov_cmd(struct efx_nic *efx, bool enable,
-			 unsigned *vi_scale_out, unsigned *vf_total_out)
+static int efx_siena_sriov_cmd(struct efx_nic *efx, bool enable,
+			       unsigned *vi_scale_out, unsigned *vf_total_out)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_SRIOV_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_SRIOV_OUT_LEN);
@@ -227,7 +227,7 @@ static int efx_sriov_cmd(struct efx_nic *efx, bool enable,
 	return 0;
 }
 
-static void efx_sriov_usrev(struct efx_nic *efx, bool enabled)
+static void efx_siena_sriov_usrev(struct efx_nic *efx, bool enabled)
 {
 	struct siena_nic_data *nic_data = efx->nic_data;
 	efx_oword_t reg;
@@ -238,8 +238,9 @@ static void efx_sriov_usrev(struct efx_nic *efx, bool enabled)
 	efx_writeo(efx, &reg, FR_CZ_USR_EV_CFG);
 }
 
-static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
-			    unsigned int count)
+static int efx_siena_sriov_memcpy(struct efx_nic *efx,
+				  struct efx_memcpy_req *req,
+				  unsigned int count)
 {
 	MCDI_DECLARE_BUF(inbuf, MCDI_CTL_SDU_LEN_MAX_V1);
 	MCDI_DECLARE_STRUCT_PTR(record);
@@ -298,7 +299,7 @@ out:
 /* The TX filter is entirely controlled by this driver, and is modified
  * underneath the feet of the VF
  */
-static void efx_sriov_reset_tx_filter(struct efx_vf *vf)
+static void efx_siena_sriov_reset_tx_filter(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct efx_filter_spec filter;
@@ -342,7 +343,7 @@ static void efx_sriov_reset_tx_filter(struct efx_vf *vf)
 }
 
 /* The RX filter is managed here on behalf of the VF driver */
-static void efx_sriov_reset_rx_filter(struct efx_vf *vf)
+static void efx_siena_sriov_reset_rx_filter(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct efx_filter_spec filter;
@@ -381,22 +382,22 @@ static void efx_sriov_reset_rx_filter(struct efx_vf *vf)
 	}
 }
 
-static void __efx_sriov_update_vf_addr(struct efx_vf *vf)
+static void __efx_siena_sriov_update_vf_addr(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
 
-	efx_sriov_reset_tx_filter(vf);
-	efx_sriov_reset_rx_filter(vf);
+	efx_siena_sriov_reset_tx_filter(vf);
+	efx_siena_sriov_reset_rx_filter(vf);
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
 }
 
 /* Push the peer list to this VF. The caller must hold status_lock to interlock
  * with VFDI requests, and they must be serialised against manipulation of
  * local_page_list, either by acquiring local_lock or by running from
- * efx_sriov_peer_work()
+ * efx_siena_sriov_peer_work()
  */
-static void __efx_sriov_push_vf_status(struct efx_vf *vf)
+static void __efx_siena_sriov_push_vf_status(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -449,7 +450,7 @@ static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 		copy[pos].length = EFX_PAGE_SIZE;
 
 		if (++pos == ARRAY_SIZE(copy)) {
-			efx_sriov_memcpy(efx, copy, ARRAY_SIZE(copy));
+			efx_siena_sriov_memcpy(efx, copy, ARRAY_SIZE(copy));
 			pos = 0;
 		}
 		++count;
@@ -461,7 +462,7 @@ static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 	copy[pos].to_addr = vf->status_addr + offsetof(struct vfdi_status,
 						       generation_end);
 	copy[pos].length = sizeof(status->generation_end);
-	efx_sriov_memcpy(efx, copy, pos + 1);
+	efx_siena_sriov_memcpy(efx, copy, pos + 1);
 
 	/* Notify the guest */
 	EFX_POPULATE_QWORD_3(event,
@@ -474,8 +475,8 @@ static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 				 &event);
 }
 
-static void efx_sriov_bufs(struct efx_nic *efx, unsigned offset,
-			   u64 *addr, unsigned count)
+static void efx_siena_sriov_bufs(struct efx_nic *efx, unsigned offset,
+				 u64 *addr, unsigned count)
 {
 	efx_qword_t buf;
 	unsigned pos;
@@ -544,7 +545,7 @@ static int efx_vfdi_init_evq(struct efx_vf *vf)
 		return VFDI_RC_EINVAL;
 	}
 
-	efx_sriov_bufs(efx, buftbl, req->u.init_evq.addr, buf_count);
+	efx_siena_sriov_bufs(efx, buftbl, req->u.init_evq.addr, buf_count);
 
 	EFX_POPULATE_OWORD_3(reg,
 			     FRF_CZ_TIMER_Q_EN, 1,
@@ -589,7 +590,7 @@ static int efx_vfdi_init_rxq(struct efx_vf *vf)
 	}
 	if (__test_and_set_bit(req->u.init_rxq.index, vf->rxq_mask))
 		++vf->rxq_count;
-	efx_sriov_bufs(efx, buftbl, req->u.init_rxq.addr, buf_count);
+	efx_siena_sriov_bufs(efx, buftbl, req->u.init_rxq.addr, buf_count);
 
 	label = req->u.init_rxq.label & EFX_FIELD_MASK(FRF_AZ_RX_DESCQ_LABEL);
 	EFX_POPULATE_OWORD_6(reg,
@@ -633,7 +634,7 @@ static int efx_vfdi_init_txq(struct efx_vf *vf)
 	if (__test_and_set_bit(req->u.init_txq.index, vf->txq_mask))
 		++vf->txq_count;
 	mutex_unlock(&vf->txq_lock);
-	efx_sriov_bufs(efx, buftbl, req->u.init_txq.addr, buf_count);
+	efx_siena_sriov_bufs(efx, buftbl, req->u.init_txq.addr, buf_count);
 
 	eth_filt_en = vf->tx_filter_mode == VF_TX_FILTER_ON;
 
@@ -747,8 +748,8 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 		efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL,
 				 vf_offset + index);
 	}
-	efx_sriov_bufs(efx, vf->buftbl_base, NULL,
-		       EFX_VF_BUFTBL_PER_VI * efx_vf_size(efx));
+	efx_siena_sriov_bufs(efx, vf->buftbl_base, NULL,
+			     EFX_VF_BUFTBL_PER_VI * efx_vf_size(efx));
 	efx_vfdi_flush_clear(vf);
 
 	vf->evq0_count = 0;
@@ -782,7 +783,7 @@ static int efx_vfdi_insert_filter(struct efx_vf *vf)
 	vf->rx_filter_qid = vf_rxq;
 	vf->rx_filtering = true;
 
-	efx_sriov_reset_rx_filter(vf);
+	efx_siena_sriov_reset_rx_filter(vf);
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
 
 	return VFDI_RC_SUCCESS;
@@ -794,7 +795,7 @@ static int efx_vfdi_remove_all_filters(struct efx_vf *vf)
 	struct siena_nic_data *nic_data = efx->nic_data;
 
 	vf->rx_filtering = false;
-	efx_sriov_reset_rx_filter(vf);
+	efx_siena_sriov_reset_rx_filter(vf);
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
 
 	return VFDI_RC_SUCCESS;
@@ -838,7 +839,7 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 		}
 	}
 
-	__efx_sriov_push_vf_status(vf);
+	__efx_siena_sriov_push_vf_status(vf);
 	mutex_unlock(&vf->status_lock);
 	mutex_unlock(&nic_data->local_lock);
 
@@ -867,7 +868,7 @@ static const efx_vfdi_op_t vfdi_ops[VFDI_OP_LIMIT] = {
 	[VFDI_OP_CLEAR_STATUS_PAGE] = efx_vfdi_clear_status_page,
 };
 
-static void efx_sriov_vfdi(struct work_struct *work)
+static void efx_siena_sriov_vfdi(struct work_struct *work)
 {
 	struct efx_vf *vf = container_of(work, struct efx_vf, req);
 	struct efx_nic *efx = vf->efx;
@@ -882,7 +883,7 @@ static void efx_sriov_vfdi(struct work_struct *work)
 	copy[0].to_rid = efx->pci_dev->devfn;
 	copy[0].to_addr = vf->buf.dma_addr;
 	copy[0].length = EFX_PAGE_SIZE;
-	rc = efx_sriov_memcpy(efx, copy, 1);
+	rc = efx_siena_sriov_memcpy(efx, copy, 1);
 	if (rc) {
 		/* If we can't get the request, we can't reply to the caller */
 		if (net_ratelimit())
@@ -926,7 +927,7 @@ static void efx_sriov_vfdi(struct work_struct *work)
 	copy[1].to_addr = vf->req_addr + offsetof(struct vfdi_req, op);
 	copy[1].length = sizeof(req->op);
 
-	(void) efx_sriov_memcpy(efx, copy, ARRAY_SIZE(copy));
+	(void)efx_siena_sriov_memcpy(efx, copy, ARRAY_SIZE(copy));
 }
 
 
@@ -935,7 +936,8 @@ static void efx_sriov_vfdi(struct work_struct *work)
  * event ring in guest memory with VFDI reset events, then (re-initialise) the
  * event queue to raise an interrupt. The guest driver will then recover.
  */
-static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
+static void efx_siena_sriov_reset_vf(struct efx_vf *vf,
+				     struct efx_buffer *buffer)
 {
 	struct efx_nic *efx = vf->efx;
 	struct efx_memcpy_req copy_req[4];
@@ -971,7 +973,7 @@ static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
 			copy_req[k].to_addr = vf->evq0_addrs[pos + k];
 			copy_req[k].length = EFX_PAGE_SIZE;
 		}
-		rc = efx_sriov_memcpy(efx, copy_req, count);
+		rc = efx_siena_sriov_memcpy(efx, copy_req, count);
 		if (rc) {
 			if (net_ratelimit())
 				netif_err(efx, hw, efx->net_dev,
@@ -984,7 +986,7 @@ static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
 	/* Reinitialise, arm and trigger evq0 */
 	abs_evq = abs_index(vf, 0);
 	buftbl = EFX_BUFTBL_EVQ_BASE(vf, 0);
-	efx_sriov_bufs(efx, buftbl, vf->evq0_addrs, vf->evq0_count);
+	efx_siena_sriov_bufs(efx, buftbl, vf->evq0_addrs, vf->evq0_count);
 
 	EFX_POPULATE_OWORD_3(reg,
 			     FRF_CZ_TIMER_Q_EN, 1,
@@ -1002,19 +1004,19 @@ static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
 	mutex_unlock(&vf->status_lock);
 }
 
-static void efx_sriov_reset_vf_work(struct work_struct *work)
+static void efx_siena_sriov_reset_vf_work(struct work_struct *work)
 {
 	struct efx_vf *vf = container_of(work, struct efx_vf, req);
 	struct efx_nic *efx = vf->efx;
 	struct efx_buffer buf;
 
 	if (!efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE, GFP_NOIO)) {
-		efx_sriov_reset_vf(vf, &buf);
+		efx_siena_sriov_reset_vf(vf, &buf);
 		efx_nic_free_buffer(efx, &buf);
 	}
 }
 
-static void efx_sriov_handle_no_channel(struct efx_nic *efx)
+static void efx_siena_sriov_handle_no_channel(struct efx_nic *efx)
 {
 	netif_err(efx, drv, efx->net_dev,
 		  "ERROR: IOV requires MSI-X and 1 additional interrupt"
@@ -1022,7 +1024,7 @@ static void efx_sriov_handle_no_channel(struct efx_nic *efx)
 	efx->vf_count = 0;
 }
 
-static int efx_sriov_probe_channel(struct efx_channel *channel)
+static int efx_siena_sriov_probe_channel(struct efx_channel *channel)
 {
 	struct siena_nic_data *nic_data = channel->efx->nic_data;
 	nic_data->vfdi_channel = channel;
@@ -1031,28 +1033,29 @@ static int efx_sriov_probe_channel(struct efx_channel *channel)
 }
 
 static void
-efx_sriov_get_channel_name(struct efx_channel *channel, char *buf, size_t len)
+efx_siena_sriov_get_channel_name(struct efx_channel *channel,
+				 char *buf, size_t len)
 {
 	snprintf(buf, len, "%s-iov", channel->efx->name);
 }
 
-static const struct efx_channel_type efx_sriov_channel_type = {
-	.handle_no_channel	= efx_sriov_handle_no_channel,
-	.pre_probe		= efx_sriov_probe_channel,
+static const struct efx_channel_type efx_siena_sriov_channel_type = {
+	.handle_no_channel	= efx_siena_sriov_handle_no_channel,
+	.pre_probe		= efx_siena_sriov_probe_channel,
 	.post_remove		= efx_channel_dummy_op_void,
-	.get_name		= efx_sriov_get_channel_name,
+	.get_name		= efx_siena_sriov_get_channel_name,
 	/* no copy operation; channel must not be reallocated */
 	.keep_eventq		= true,
 };
 
-void efx_sriov_probe(struct efx_nic *efx)
+void efx_siena_sriov_probe(struct efx_nic *efx)
 {
 	unsigned count;
 
 	if (!max_vfs)
 		return;
 
-	if (efx_sriov_cmd(efx, false, &efx->vi_scale, &count))
+	if (efx_siena_sriov_cmd(efx, false, &efx->vi_scale, &count))
 		return;
 	if (count > 0 && count > max_vfs)
 		count = max_vfs;
@@ -1060,14 +1063,14 @@ void efx_sriov_probe(struct efx_nic *efx)
 	/* efx_nic_dimension_resources() will reduce vf_count as appopriate */
 	efx->vf_count = count;
 
-	efx->extra_channel_type[EFX_EXTRA_CHANNEL_IOV] = &efx_sriov_channel_type;
+	efx->extra_channel_type[EFX_EXTRA_CHANNEL_IOV] = &efx_siena_sriov_channel_type;
 }
 
 /* Copy the list of individual addresses into the vfdi_status.peers
  * array and auxillary pages, protected by %local_lock. Drop that lock
  * and then broadcast the address list to every VF.
  */
-static void efx_sriov_peer_work(struct work_struct *data)
+static void efx_siena_sriov_peer_work(struct work_struct *data)
 {
 	struct siena_nic_data *nic_data = container_of(data,
 						       struct siena_nic_data,
@@ -1156,12 +1159,12 @@ static void efx_sriov_peer_work(struct work_struct *data)
 
 		mutex_lock(&vf->status_lock);
 		if (vf->status_addr)
-			__efx_sriov_push_vf_status(vf);
+			__efx_siena_sriov_push_vf_status(vf);
 		mutex_unlock(&vf->status_lock);
 	}
 }
 
-static void efx_sriov_free_local(struct efx_nic *efx)
+static void efx_siena_sriov_free_local(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data = efx->nic_data;
 	struct efx_local_addr *local_addr;
@@ -1184,7 +1187,7 @@ static void efx_sriov_free_local(struct efx_nic *efx)
 	}
 }
 
-static int efx_sriov_vf_alloc(struct efx_nic *efx)
+static int efx_siena_sriov_vf_alloc(struct efx_nic *efx)
 {
 	unsigned index;
 	struct efx_vf *vf;
@@ -1201,8 +1204,8 @@ static int efx_sriov_vf_alloc(struct efx_nic *efx)
 		vf->rx_filter_id = -1;
 		vf->tx_filter_mode = VF_TX_FILTER_AUTO;
 		vf->tx_filter_id = -1;
-		INIT_WORK(&vf->req, efx_sriov_vfdi);
-		INIT_WORK(&vf->reset_work, efx_sriov_reset_vf_work);
+		INIT_WORK(&vf->req, efx_siena_sriov_vfdi);
+		INIT_WORK(&vf->reset_work, efx_siena_sriov_reset_vf_work);
 		init_waitqueue_head(&vf->flush_waitq);
 		mutex_init(&vf->status_lock);
 		mutex_init(&vf->txq_lock);
@@ -1211,7 +1214,7 @@ static int efx_sriov_vf_alloc(struct efx_nic *efx)
 	return 0;
 }
 
-static void efx_sriov_vfs_fini(struct efx_nic *efx)
+static void efx_siena_sriov_vfs_fini(struct efx_nic *efx)
 {
 	struct efx_vf *vf;
 	unsigned int pos;
@@ -1228,7 +1231,7 @@ static void efx_sriov_vfs_fini(struct efx_nic *efx)
 	}
 }
 
-static int efx_sriov_vfs_init(struct efx_nic *efx)
+static int efx_siena_sriov_vfs_init(struct efx_nic *efx)
 {
 	struct pci_dev *pci_dev = efx->pci_dev;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -1270,11 +1273,11 @@ static int efx_sriov_vfs_init(struct efx_nic *efx)
 	return 0;
 
 fail:
-	efx_sriov_vfs_fini(efx);
+	efx_siena_sriov_vfs_fini(efx);
 	return rc;
 }
 
-int efx_sriov_init(struct efx_nic *efx)
+int efx_siena_sriov_init(struct efx_nic *efx)
 {
 	struct net_device *net_dev = efx->net_dev;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -1289,7 +1292,7 @@ int efx_sriov_init(struct efx_nic *efx)
 	if (efx->vf_count == 0)
 		return 0;
 
-	rc = efx_sriov_cmd(efx, true, NULL, NULL);
+	rc = efx_siena_sriov_cmd(efx, true, NULL, NULL);
 	if (rc)
 		goto fail_cmd;
 
@@ -1307,16 +1310,16 @@ int efx_sriov_init(struct efx_nic *efx)
 	vfdi_status->peer_count = 1 + efx->vf_count;
 	vfdi_status->timer_quantum_ns = efx->timer_quantum_ns;
 
-	rc = efx_sriov_vf_alloc(efx);
+	rc = efx_siena_sriov_vf_alloc(efx);
 	if (rc)
 		goto fail_alloc;
 
 	mutex_init(&nic_data->local_lock);
-	INIT_WORK(&nic_data->peer_work, efx_sriov_peer_work);
+	INIT_WORK(&nic_data->peer_work, efx_siena_sriov_peer_work);
 	INIT_LIST_HEAD(&nic_data->local_addr_list);
 	INIT_LIST_HEAD(&nic_data->local_page_list);
 
-	rc = efx_sriov_vfs_init(efx);
+	rc = efx_siena_sriov_vfs_init(efx);
 	if (rc)
 		goto fail_vfs;
 
@@ -1325,7 +1328,7 @@ int efx_sriov_init(struct efx_nic *efx)
 	efx->vf_init_count = efx->vf_count;
 	rtnl_unlock();
 
-	efx_sriov_usrev(efx, true);
+	efx_siena_sriov_usrev(efx, true);
 
 	/* At this point we must be ready to accept VFDI requests */
 
@@ -1339,24 +1342,24 @@ int efx_sriov_init(struct efx_nic *efx)
 	return 0;
 
 fail_pci:
-	efx_sriov_usrev(efx, false);
+	efx_siena_sriov_usrev(efx, false);
 	rtnl_lock();
 	efx->vf_init_count = 0;
 	rtnl_unlock();
-	efx_sriov_vfs_fini(efx);
+	efx_siena_sriov_vfs_fini(efx);
 fail_vfs:
 	cancel_work_sync(&nic_data->peer_work);
-	efx_sriov_free_local(efx);
+	efx_siena_sriov_free_local(efx);
 	kfree(efx->vf);
 fail_alloc:
 	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 fail_status:
-	efx_sriov_cmd(efx, false, NULL, NULL);
+	efx_siena_sriov_cmd(efx, false, NULL, NULL);
 fail_cmd:
 	return rc;
 }
 
-void efx_sriov_fini(struct efx_nic *efx)
+void efx_siena_sriov_fini(struct efx_nic *efx)
 {
 	struct efx_vf *vf;
 	unsigned int pos;
@@ -1367,7 +1370,7 @@ void efx_sriov_fini(struct efx_nic *efx)
 
 	/* Disable all interfaces to reconfiguration */
 	BUG_ON(nic_data->vfdi_channel->enabled);
-	efx_sriov_usrev(efx, false);
+	efx_siena_sriov_usrev(efx, false);
 	rtnl_lock();
 	efx->vf_init_count = 0;
 	rtnl_unlock();
@@ -1383,14 +1386,14 @@ void efx_sriov_fini(struct efx_nic *efx)
 	pci_disable_sriov(efx->pci_dev);
 
 	/* Tear down back-end state */
-	efx_sriov_vfs_fini(efx);
-	efx_sriov_free_local(efx);
+	efx_siena_sriov_vfs_fini(efx);
+	efx_siena_sriov_free_local(efx);
 	kfree(efx->vf);
 	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
-	efx_sriov_cmd(efx, false, NULL, NULL);
+	efx_siena_sriov_cmd(efx, false, NULL, NULL);
 }
 
-void efx_sriov_event(struct efx_channel *channel, efx_qword_t *event)
+void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
 	struct efx_vf *vf;
@@ -1447,7 +1450,7 @@ error:
 	vf->req_seqno = seq + 1;
 }
 
-void efx_sriov_flr(struct efx_nic *efx, unsigned vf_i)
+void efx_siena_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 {
 	struct efx_vf *vf;
 
@@ -1464,7 +1467,7 @@ void efx_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 	vf->evq0_count = 0;
 }
 
-void efx_sriov_mac_address_changed(struct efx_nic *efx)
+void efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
@@ -1476,7 +1479,7 @@ void efx_sriov_mac_address_changed(struct efx_nic *efx)
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
 }
 
-void efx_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
+void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
 	struct efx_vf *vf;
 	unsigned queue, qid;
@@ -1495,7 +1498,7 @@ void efx_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 		wake_up(&vf->flush_waitq);
 }
 
-void efx_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
+void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
 	struct efx_vf *vf;
 	unsigned ev_failed, queue, qid;
@@ -1520,7 +1523,7 @@ void efx_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 }
 
 /* Called from napi. Schedule the reset work item */
-void efx_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
+void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 {
 	struct efx_vf *vf;
 	unsigned int rel;
@@ -1536,7 +1539,7 @@ void efx_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 }
 
 /* Reset all VFs */
-void efx_sriov_reset(struct efx_nic *efx)
+void efx_siena_sriov_reset(struct efx_nic *efx)
 {
 	unsigned int vf_i;
 	struct efx_buffer buf;
@@ -1547,15 +1550,15 @@ void efx_sriov_reset(struct efx_nic *efx)
 	if (efx->vf_init_count == 0)
 		return;
 
-	efx_sriov_usrev(efx, true);
-	(void)efx_sriov_cmd(efx, true, NULL, NULL);
+	efx_siena_sriov_usrev(efx, true);
+	(void)efx_siena_sriov_cmd(efx, true, NULL, NULL);
 
 	if (efx_nic_alloc_buffer(efx, &buf, EFX_PAGE_SIZE, GFP_NOIO))
 		return;
 
 	for (vf_i = 0; vf_i < efx->vf_init_count; ++vf_i) {
 		vf = efx->vf + vf_i;
-		efx_sriov_reset_vf(vf, &buf);
+		efx_siena_sriov_reset_vf(vf, &buf);
 	}
 
 	efx_nic_free_buffer(efx, &buf);
@@ -1563,8 +1566,8 @@ void efx_sriov_reset(struct efx_nic *efx)
 
 int efx_init_sriov(void)
 {
-	/* A single threaded workqueue is sufficient. efx_sriov_vfdi() and
-	 * efx_sriov_peer_work() spend almost all their time sleeping for
+	/* A single threaded workqueue is sufficient. efx_siena_sriov_vfdi() and
+	 * efx_siena_sriov_peer_work() spend almost all their time sleeping for
 	 * MCDI to complete anyway
 	 */
 	vfdi_workqueue = create_singlethread_workqueue("sfc_vfdi");
@@ -1579,7 +1582,7 @@ void efx_fini_sriov(void)
 	destroy_workqueue(vfdi_workqueue);
 }
 
-int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
+int efx_siena_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
@@ -1590,14 +1593,14 @@ int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
 
 	mutex_lock(&vf->status_lock);
 	ether_addr_copy(vf->addr.mac_addr, mac);
-	__efx_sriov_update_vf_addr(vf);
+	__efx_siena_sriov_update_vf_addr(vf);
 	mutex_unlock(&vf->status_lock);
 
 	return 0;
 }
 
-int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i,
-			  u16 vlan, u8 qos)
+int efx_siena_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i,
+				u16 vlan, u8 qos)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
@@ -1610,14 +1613,14 @@ int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i,
 	mutex_lock(&vf->status_lock);
 	tci = (vlan & VLAN_VID_MASK) | ((qos & 0x7) << VLAN_PRIO_SHIFT);
 	vf->addr.tci = htons(tci);
-	__efx_sriov_update_vf_addr(vf);
+	__efx_siena_sriov_update_vf_addr(vf);
 	mutex_unlock(&vf->status_lock);
 
 	return 0;
 }
 
-int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
-			      bool spoofchk)
+int efx_siena_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
+				    bool spoofchk)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
@@ -1640,8 +1643,8 @@ int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
 	return rc;
 }
 
-int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
-			    struct ifla_vf_info *ivi)
+int efx_siena_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
+				  struct ifla_vf_info *ivi)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
