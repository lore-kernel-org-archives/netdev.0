From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/3] sfc: Move the current VF state from efx_nic
 into siena_nic_data
Date: Wed, 5 Nov 2014 12:16:18 +0000
Message-ID: <545A1512.4080204@solarflare.com>
References: <545A14CD.6040809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:61497 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbaKEMYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 07:24:46 -0500
In-Reply-To: <545A14CD.6040809@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provides a base and cleanup for the
upcoming EF10 SRIOV support.

This patch moves the VF state into siena_nic_data as a basis to
save the VF state based on nic type.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/farch.c       | 11 +++-
 drivers/net/ethernet/sfc/net_driver.h  | 14 ------
 drivers/net/ethernet/sfc/nic.h         | 18 +++++++
 drivers/net/ethernet/sfc/siena.c       |  1 +
 drivers/net/ethernet/sfc/siena_sriov.c | 92 +++++++++++++++++++++-------------
 5 files changed, 84 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 6859437..0274401 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -226,6 +226,9 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 				    struct efx_special_buffer *buffer,
 				    unsigned int len)
 {
+#ifdef CONFIG_SFC_SRIOV
+	struct siena_nic_data *nic_data = efx->nic_data;
+#endif
 	len = ALIGN(len, EFX_BUF_SIZE);
 
 	if (efx_nic_alloc_buffer(efx, &buffer->buf, len, GFP_KERNEL))
@@ -238,7 +241,7 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 	efx->next_buffer_table += buffer->entries;
 #ifdef CONFIG_SFC_SRIOV
 	BUG_ON(efx_sriov_enabled(efx) &&
-	       efx->vf_buftbl_base < efx->next_buffer_table);
+	       nic_data->vf_buftbl_base < efx->next_buffer_table);
 #endif
 
 	netif_dbg(efx, probe, efx->net_dev,
@@ -1668,6 +1671,10 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
 {
 	unsigned vi_count, buftbl_min;
 
+#ifdef CONFIG_SFC_SRIOV
+	struct siena_nic_data *nic_data = efx->nic_data;
+#endif
+
 	/* Account for the buffer table entries backing the datapath channels
 	 * and the descriptor caches for those channels.
 	 */
@@ -1681,7 +1688,7 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
 	if (efx_sriov_wanted(efx)) {
 		unsigned vi_dc_entries, buftbl_free, entries_per_vf, vf_limit;
 
-		efx->vf_buftbl_base = buftbl_min;
+		nic_data->vf_buftbl_base = buftbl_min;
 
 		vi_dc_entries = RX_DC_ENTRIES + TX_DC_ENTRIES;
 		vi_count = max(vi_count, EFX_VI_BASE);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9ede320..779a1f5 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -913,13 +913,6 @@ struct vfdi_status;
  * @vf_count: Number of VFs intended to be enabled.
  * @vf_init_count: Number of VFs that have been fully initialised.
  * @vi_scale: log2 number of vnics per VF.
- * @vf_buftbl_base: The zeroth buffer table index used to back VF queues.
- * @vfdi_status: Common VFDI status page to be dmad to VF address space.
- * @local_addr_list: List of local addresses. Protected by %local_lock.
- * @local_page_list: List of DMA addressable pages used to broadcast
- *	%local_addr_list. Protected by %local_lock.
- * @local_lock: Mutex protecting %local_addr_list and %local_page_list.
- * @peer_work: Work item to broadcast peer addresses to VMs.
  * @ptp_data: PTP state data
  * @vpd_sn: Serial number read from VPD
  * @monitor_work: Hardware monitor workitem
@@ -1060,17 +1053,10 @@ struct efx_nic {
 	wait_queue_head_t flush_wq;
 
 #ifdef CONFIG_SFC_SRIOV
-	struct efx_channel *vfdi_channel;
 	struct efx_vf *vf;
 	unsigned vf_count;
 	unsigned vf_init_count;
 	unsigned vi_scale;
-	unsigned vf_buftbl_base;
-	struct efx_buffer vfdi_status;
-	struct list_head local_addr_list;
-	struct list_head local_page_list;
-	struct mutex local_lock;
-	struct work_struct peer_work;
 #endif
 
 	struct efx_ptp_data *ptp_data;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index f77cce0..b5fe1f2 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -378,12 +378,30 @@ enum {
 
 /**
  * struct siena_nic_data - Siena NIC state
+ * @efx: Pointer back to main interface structure
  * @wol_filter_id: Wake-on-LAN packet filter id
  * @stats: Hardware statistics
+ * @vf_buftbl_base: The zeroth buffer table index used to back VF queues.
+ * @vfdi_status: Common VFDI status page to be dmad to VF address space.
+ * @local_addr_list: List of local addresses. Protected by %local_lock.
+ * @local_page_list: List of DMA addressable pages used to broadcast
+ *	%local_addr_list. Protected by %local_lock.
+ * @local_lock: Mutex protecting %local_addr_list and %local_page_list.
+ * @peer_work: Work item to broadcast peer addresses to VMs.
  */
 struct siena_nic_data {
+	struct efx_nic *efx;
 	int wol_filter_id;
 	u64 stats[SIENA_STAT_COUNT];
+#ifdef CONFIG_SFC_SRIOV
+	struct efx_channel *vfdi_channel;
+	unsigned vf_buftbl_base;
+	struct efx_buffer vfdi_status;
+	struct list_head local_addr_list;
+	struct list_head local_page_list;
+	struct mutex local_lock;
+	struct work_struct peer_work;
+#endif
 };
 
 enum {
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index ae69685..ffce06d 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -251,6 +251,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	nic_data = kzalloc(sizeof(struct siena_nic_data), GFP_KERNEL);
 	if (!nic_data)
 		return -ENOMEM;
+	nic_data->efx = efx;
 	efx->nic_data = nic_data;
 
 	if (efx_farch_fpga_ver(efx) != 0) {
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 43d2e64..2b75eee 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -229,11 +229,12 @@ static int efx_sriov_cmd(struct efx_nic *efx, bool enable,
 
 static void efx_sriov_usrev(struct efx_nic *efx, bool enabled)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
 	efx_oword_t reg;
 
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_CZ_USREV_DIS, enabled ? 0 : 1,
-			     FRF_CZ_DFLT_EVQ, efx->vfdi_channel->channel);
+			     FRF_CZ_DFLT_EVQ, nic_data->vfdi_channel->channel);
 	efx_writeo(efx, &reg, FR_CZ_USR_EV_CFG);
 }
 
@@ -382,9 +383,12 @@ static void efx_sriov_reset_rx_filter(struct efx_vf *vf)
 
 static void __efx_sriov_update_vf_addr(struct efx_vf *vf)
 {
+	struct efx_nic *efx = vf->efx;
+	struct siena_nic_data *nic_data = efx->nic_data;
+
 	efx_sriov_reset_tx_filter(vf);
 	efx_sriov_reset_rx_filter(vf);
-	queue_work(vfdi_workqueue, &vf->efx->peer_work);
+	queue_work(vfdi_workqueue, &nic_data->peer_work);
 }
 
 /* Push the peer list to this VF. The caller must hold status_lock to interlock
@@ -395,7 +399,8 @@ static void __efx_sriov_update_vf_addr(struct efx_vf *vf)
 static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
-	struct vfdi_status *status = efx->vfdi_status.addr;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct vfdi_status *status = nic_data->vfdi_status.addr;
 	struct efx_memcpy_req copy[4];
 	struct efx_endpoint_page *epp;
 	unsigned int pos, count;
@@ -421,7 +426,7 @@ static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 	 */
 	data_offset = offsetof(struct vfdi_status, version);
 	copy[1].from_rid = efx->pci_dev->devfn;
-	copy[1].from_addr = efx->vfdi_status.dma_addr + data_offset;
+	copy[1].from_addr = nic_data->vfdi_status.dma_addr + data_offset;
 	copy[1].to_rid = vf->pci_rid;
 	copy[1].to_addr = vf->status_addr + data_offset;
 	copy[1].length =  status->length - data_offset;
@@ -429,7 +434,7 @@ static void __efx_sriov_push_vf_status(struct efx_vf *vf)
 	/* Copy the peer pages */
 	pos = 2;
 	count = 0;
-	list_for_each_entry(epp, &efx->local_page_list, link) {
+	list_for_each_entry(epp, &nic_data->local_page_list, link) {
 		if (count == vf->peer_page_count) {
 			/* The VF driver will know they need to provide more
 			 * pages because peer_addr_count is too large.
@@ -754,6 +759,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 static int efx_vfdi_insert_filter(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
+	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_req *req = vf->buf.addr;
 	unsigned vf_rxq = req->u.mac_filter.rxq;
 	unsigned flags;
@@ -777,16 +783,19 @@ static int efx_vfdi_insert_filter(struct efx_vf *vf)
 	vf->rx_filtering = true;
 
 	efx_sriov_reset_rx_filter(vf);
-	queue_work(vfdi_workqueue, &efx->peer_work);
+	queue_work(vfdi_workqueue, &nic_data->peer_work);
 
 	return VFDI_RC_SUCCESS;
 }
 
 static int efx_vfdi_remove_all_filters(struct efx_vf *vf)
 {
+	struct efx_nic *efx = vf->efx;
+	struct siena_nic_data *nic_data = efx->nic_data;
+
 	vf->rx_filtering = false;
 	efx_sriov_reset_rx_filter(vf);
-	queue_work(vfdi_workqueue, &vf->efx->peer_work);
+	queue_work(vfdi_workqueue, &nic_data->peer_work);
 
 	return VFDI_RC_SUCCESS;
 }
@@ -794,6 +803,7 @@ static int efx_vfdi_remove_all_filters(struct efx_vf *vf)
 static int efx_vfdi_set_status_page(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
+	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_req *req = vf->buf.addr;
 	u64 page_count = req->u.set_status_page.peer_page_count;
 	u64 max_page_count =
@@ -809,7 +819,7 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 		return VFDI_RC_EINVAL;
 	}
 
-	mutex_lock(&efx->local_lock);
+	mutex_lock(&nic_data->local_lock);
 	mutex_lock(&vf->status_lock);
 	vf->status_addr = req->u.set_status_page.dma_addr;
 
@@ -830,7 +840,7 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 
 	__efx_sriov_push_vf_status(vf);
 	mutex_unlock(&vf->status_lock);
-	mutex_unlock(&efx->local_lock);
+	mutex_unlock(&nic_data->local_lock);
 
 	return VFDI_RC_SUCCESS;
 }
@@ -1014,7 +1024,9 @@ static void efx_sriov_handle_no_channel(struct efx_nic *efx)
 
 static int efx_sriov_probe_channel(struct efx_channel *channel)
 {
-	channel->efx->vfdi_channel = channel;
+	struct siena_nic_data *nic_data = channel->efx->nic_data;
+	nic_data->vfdi_channel = channel;
+
 	return 0;
 }
 
@@ -1057,8 +1069,11 @@ void efx_sriov_probe(struct efx_nic *efx)
  */
 static void efx_sriov_peer_work(struct work_struct *data)
 {
-	struct efx_nic *efx = container_of(data, struct efx_nic, peer_work);
-	struct vfdi_status *vfdi_status = efx->vfdi_status.addr;
+	struct siena_nic_data *nic_data = container_of(data,
+						       struct siena_nic_data,
+						       peer_work);
+	struct efx_nic *efx = nic_data->efx;
+	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
 	struct efx_vf *vf;
 	struct efx_local_addr *local_addr;
 	struct vfdi_endpoint *peer;
@@ -1068,11 +1083,11 @@ static void efx_sriov_peer_work(struct work_struct *data)
 	unsigned int peer_count;
 	unsigned int pos;
 
-	mutex_lock(&efx->local_lock);
+	mutex_lock(&nic_data->local_lock);
 
 	/* Move the existing peer pages off %local_page_list */
 	INIT_LIST_HEAD(&pages);
-	list_splice_tail_init(&efx->local_page_list, &pages);
+	list_splice_tail_init(&nic_data->local_page_list, &pages);
 
 	/* Populate the VF addresses starting from entry 1 (entry 0 is
 	 * the PF address)
@@ -1094,7 +1109,7 @@ static void efx_sriov_peer_work(struct work_struct *data)
 	}
 
 	/* Fill the remaining addresses */
-	list_for_each_entry(local_addr, &efx->local_addr_list, link) {
+	list_for_each_entry(local_addr, &nic_data->local_addr_list, link) {
 		ether_addr_copy(peer->mac_addr, local_addr->addr);
 		peer->tci = 0;
 		++peer;
@@ -1117,13 +1132,13 @@ static void efx_sriov_peer_work(struct work_struct *data)
 				list_del(&epp->link);
 			}
 
-			list_add_tail(&epp->link, &efx->local_page_list);
+			list_add_tail(&epp->link, &nic_data->local_page_list);
 			peer = (struct vfdi_endpoint *)epp->ptr;
 			peer_space = EFX_PAGE_SIZE / sizeof(struct vfdi_endpoint);
 		}
 	}
 	vfdi_status->peer_count = peer_count;
-	mutex_unlock(&efx->local_lock);
+	mutex_unlock(&nic_data->local_lock);
 
 	/* Free any now unused endpoint pages */
 	while (!list_empty(&pages)) {
@@ -1148,18 +1163,19 @@ static void efx_sriov_peer_work(struct work_struct *data)
 
 static void efx_sriov_free_local(struct efx_nic *efx)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
 	struct efx_local_addr *local_addr;
 	struct efx_endpoint_page *epp;
 
-	while (!list_empty(&efx->local_addr_list)) {
-		local_addr = list_first_entry(&efx->local_addr_list,
+	while (!list_empty(&nic_data->local_addr_list)) {
+		local_addr = list_first_entry(&nic_data->local_addr_list,
 					      struct efx_local_addr, link);
 		list_del(&local_addr->link);
 		kfree(local_addr);
 	}
 
-	while (!list_empty(&efx->local_page_list)) {
-		epp = list_first_entry(&efx->local_page_list,
+	while (!list_empty(&nic_data->local_page_list)) {
+		epp = list_first_entry(&nic_data->local_page_list,
 				       struct efx_endpoint_page, link);
 		list_del(&epp->link);
 		dma_free_coherent(&efx->pci_dev->dev, EFX_PAGE_SIZE,
@@ -1215,6 +1231,7 @@ static void efx_sriov_vfs_fini(struct efx_nic *efx)
 static int efx_sriov_vfs_init(struct efx_nic *efx)
 {
 	struct pci_dev *pci_dev = efx->pci_dev;
+	struct siena_nic_data *nic_data = efx->nic_data;
 	unsigned index, devfn, sriov, buftbl_base;
 	u16 offset, stride;
 	struct efx_vf *vf;
@@ -1227,7 +1244,7 @@ static int efx_sriov_vfs_init(struct efx_nic *efx)
 	pci_read_config_word(pci_dev, sriov + PCI_SRIOV_VF_OFFSET, &offset);
 	pci_read_config_word(pci_dev, sriov + PCI_SRIOV_VF_STRIDE, &stride);
 
-	buftbl_base = efx->vf_buftbl_base;
+	buftbl_base = nic_data->vf_buftbl_base;
 	devfn = pci_dev->devfn + offset;
 	for (index = 0; index < efx->vf_count; ++index) {
 		vf = efx->vf + index;
@@ -1260,6 +1277,7 @@ fail:
 int efx_sriov_init(struct efx_nic *efx)
 {
 	struct net_device *net_dev = efx->net_dev;
+	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_status *vfdi_status;
 	int rc;
 
@@ -1275,11 +1293,11 @@ int efx_sriov_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_cmd;
 
-	rc = efx_nic_alloc_buffer(efx, &efx->vfdi_status, sizeof(*vfdi_status),
-				  GFP_KERNEL);
+	rc = efx_nic_alloc_buffer(efx, &nic_data->vfdi_status,
+				  sizeof(*vfdi_status), GFP_KERNEL);
 	if (rc)
 		goto fail_status;
-	vfdi_status = efx->vfdi_status.addr;
+	vfdi_status = nic_data->vfdi_status.addr;
 	memset(vfdi_status, 0, sizeof(*vfdi_status));
 	vfdi_status->version = 1;
 	vfdi_status->length = sizeof(*vfdi_status);
@@ -1293,10 +1311,10 @@ int efx_sriov_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_alloc;
 
-	mutex_init(&efx->local_lock);
-	INIT_WORK(&efx->peer_work, efx_sriov_peer_work);
-	INIT_LIST_HEAD(&efx->local_addr_list);
-	INIT_LIST_HEAD(&efx->local_page_list);
+	mutex_init(&nic_data->local_lock);
+	INIT_WORK(&nic_data->peer_work, efx_sriov_peer_work);
+	INIT_LIST_HEAD(&nic_data->local_addr_list);
+	INIT_LIST_HEAD(&nic_data->local_page_list);
 
 	rc = efx_sriov_vfs_init(efx);
 	if (rc)
@@ -1327,11 +1345,11 @@ fail_pci:
 	rtnl_unlock();
 	efx_sriov_vfs_fini(efx);
 fail_vfs:
-	cancel_work_sync(&efx->peer_work);
+	cancel_work_sync(&nic_data->peer_work);
 	efx_sriov_free_local(efx);
 	kfree(efx->vf);
 fail_alloc:
-	efx_nic_free_buffer(efx, &efx->vfdi_status);
+	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 fail_status:
 	efx_sriov_cmd(efx, false, NULL, NULL);
 fail_cmd:
@@ -1342,12 +1360,13 @@ void efx_sriov_fini(struct efx_nic *efx)
 {
 	struct efx_vf *vf;
 	unsigned int pos;
+	struct siena_nic_data *nic_data = efx->nic_data;
 
 	if (efx->vf_init_count == 0)
 		return;
 
 	/* Disable all interfaces to reconfiguration */
-	BUG_ON(efx->vfdi_channel->enabled);
+	BUG_ON(nic_data->vfdi_channel->enabled);
 	efx_sriov_usrev(efx, false);
 	rtnl_lock();
 	efx->vf_init_count = 0;
@@ -1359,7 +1378,7 @@ void efx_sriov_fini(struct efx_nic *efx)
 		cancel_work_sync(&vf->req);
 		cancel_work_sync(&vf->reset_work);
 	}
-	cancel_work_sync(&efx->peer_work);
+	cancel_work_sync(&nic_data->peer_work);
 
 	pci_disable_sriov(efx->pci_dev);
 
@@ -1367,7 +1386,7 @@ void efx_sriov_fini(struct efx_nic *efx)
 	efx_sriov_vfs_fini(efx);
 	efx_sriov_free_local(efx);
 	kfree(efx->vf);
-	efx_nic_free_buffer(efx, &efx->vfdi_status);
+	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 	efx_sriov_cmd(efx, false, NULL, NULL);
 }
 
@@ -1447,13 +1466,14 @@ void efx_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 
 void efx_sriov_mac_address_changed(struct efx_nic *efx)
 {
-	struct vfdi_status *vfdi_status = efx->vfdi_status.addr;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
 
 	if (!efx->vf_init_count)
 		return;
 	ether_addr_copy(vfdi_status->peers[0].mac_addr,
 			efx->net_dev->dev_addr);
-	queue_work(vfdi_workqueue, &efx->peer_work);
+	queue_work(vfdi_workqueue, &nic_data->peer_work);
 }
 
 void efx_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
