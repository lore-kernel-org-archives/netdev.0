From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 02/14] sfc: Move and rename efx_vf struct to siena_vf
Date: Wed, 6 May 2015 00:55:36 +0100
Message-ID: <55495878.3010104@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:20542 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541AbbEEXzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:55:42 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The efx_vf struct contains Siena-specific fields for VFs,
so rename to siena_vf.
Also move it into the siena_nic_data struct, as EF10 will
track its VFs in its own ef10_nic_data, storing much less
information about them since VFDI is no longer used.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h  |   3 -
 drivers/net/ethernet/sfc/nic.h         |   2 +
 drivers/net/ethernet/sfc/siena_sriov.c | 119 ++++++++++++++++++---------------
 3 files changed, 67 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index ae0d145..e3054b2 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -793,7 +793,6 @@ union efx_multicast_hash {
 	efx_oword_t oword[EFX_MCAST_HASH_ENTRIES / sizeof(efx_oword_t) / 8];
 };
 
-struct efx_vf;
 struct vfdi_status;
 
 /**
@@ -909,7 +908,6 @@ struct vfdi_status;
  *	completed (either success or failure). Not used when MCDI is used to
  *	flush receive queues.
  * @flush_wq: wait queue used by efx_nic_flush_queues() to wait for flush completions.
- * @vf: Array of &struct efx_vf objects.
  * @vf_count: Number of VFs intended to be enabled.
  * @vf_init_count: Number of VFs that have been fully initialised.
  * @vi_scale: log2 number of vnics per VF.
@@ -1053,7 +1051,6 @@ struct efx_nic {
 	wait_queue_head_t flush_wq;
 
 #ifdef CONFIG_SFC_SRIOV
-	struct efx_vf *vf;
 	unsigned vf_count;
 	unsigned vf_init_count;
 	unsigned vi_scale;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index ea4ca18..65dcbc7 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -381,6 +381,7 @@ enum {
  * @efx: Pointer back to main interface structure
  * @wol_filter_id: Wake-on-LAN packet filter id
  * @stats: Hardware statistics
+ * @vf: Array of &struct siena_vf objects
  * @vf_buftbl_base: The zeroth buffer table index used to back VF queues.
  * @vfdi_status: Common VFDI status page to be dmad to VF address space.
  * @local_addr_list: List of local addresses. Protected by %local_lock.
@@ -394,6 +395,7 @@ struct siena_nic_data {
 	int wol_filter_id;
 	u64 stats[SIENA_STAT_COUNT];
 #ifdef CONFIG_SFC_SRIOV
+	struct siena_vf *vf;
 	struct efx_channel *vfdi_channel;
 	unsigned vf_buftbl_base;
 	struct efx_buffer vfdi_status;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index b7c2816..2044e92 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -39,7 +39,7 @@ enum efx_vf_tx_filter_mode {
 };
 
 /**
- * struct efx_vf - Back-end resource and protocol state for a PCI VF
+ * struct siena_vf - Back-end resource and protocol state for a PCI VF
  * @efx: The Efx NIC owning this VF
  * @pci_rid: The PCI requester ID for this VF
  * @pci_name: The PCI name (formatted address) of this VF
@@ -84,7 +84,7 @@ enum efx_vf_tx_filter_mode {
  * @rxq_retry_count: Number of receive queues in @rxq_retry_mask.
  * @reset_work: Work item to schedule a VF reset.
  */
-struct efx_vf {
+struct siena_vf {
 	struct efx_nic *efx;
 	unsigned int pci_rid;
 	char pci_name[13]; /* dddd:bb:dd.f */
@@ -190,7 +190,7 @@ MODULE_PARM_DESC(max_vfs,
  */
 static struct workqueue_struct *vfdi_workqueue;
 
-static unsigned abs_index(struct efx_vf *vf, unsigned index)
+static unsigned abs_index(struct siena_vf *vf, unsigned index)
 {
 	return EFX_VI_BASE + vf->index * efx_vf_size(vf->efx) + index;
 }
@@ -300,7 +300,7 @@ out:
 /* The TX filter is entirely controlled by this driver, and is modified
  * underneath the feet of the VF
  */
-static void efx_siena_sriov_reset_tx_filter(struct efx_vf *vf)
+static void efx_siena_sriov_reset_tx_filter(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct efx_filter_spec filter;
@@ -344,7 +344,7 @@ static void efx_siena_sriov_reset_tx_filter(struct efx_vf *vf)
 }
 
 /* The RX filter is managed here on behalf of the VF driver */
-static void efx_siena_sriov_reset_rx_filter(struct efx_vf *vf)
+static void efx_siena_sriov_reset_rx_filter(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct efx_filter_spec filter;
@@ -383,7 +383,7 @@ static void efx_siena_sriov_reset_rx_filter(struct efx_vf *vf)
 	}
 }
 
-static void __efx_siena_sriov_update_vf_addr(struct efx_vf *vf)
+static void __efx_siena_sriov_update_vf_addr(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -398,7 +398,7 @@ static void __efx_siena_sriov_update_vf_addr(struct efx_vf *vf)
  * local_page_list, either by acquiring local_lock or by running from
  * efx_siena_sriov_peer_work()
  */
-static void __efx_siena_sriov_push_vf_status(struct efx_vf *vf)
+static void __efx_siena_sriov_push_vf_status(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -510,8 +510,9 @@ static bool bad_buf_count(unsigned buf_count, unsigned max_entry_count)
  * Optionally set VF index and VI index within the VF.
  */
 static bool map_vi_index(struct efx_nic *efx, unsigned abs_index,
-			 struct efx_vf **vf_out, unsigned *rel_index_out)
+			 struct siena_vf **vf_out, unsigned *rel_index_out)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
 	unsigned vf_i;
 
 	if (abs_index < EFX_VI_BASE)
@@ -521,13 +522,13 @@ static bool map_vi_index(struct efx_nic *efx, unsigned abs_index,
 		return true;
 
 	if (vf_out)
-		*vf_out = efx->vf + vf_i;
+		*vf_out = nic_data->vf + vf_i;
 	if (rel_index_out)
 		*rel_index_out = abs_index % efx_vf_size(efx);
 	return false;
 }
 
-static int efx_vfdi_init_evq(struct efx_vf *vf)
+static int efx_vfdi_init_evq(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct vfdi_req *req = vf->buf.addr;
@@ -568,7 +569,7 @@ static int efx_vfdi_init_evq(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-static int efx_vfdi_init_rxq(struct efx_vf *vf)
+static int efx_vfdi_init_rxq(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct vfdi_req *req = vf->buf.addr;
@@ -609,7 +610,7 @@ static int efx_vfdi_init_rxq(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-static int efx_vfdi_init_txq(struct efx_vf *vf)
+static int efx_vfdi_init_txq(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct vfdi_req *req = vf->buf.addr;
@@ -656,7 +657,7 @@ static int efx_vfdi_init_txq(struct efx_vf *vf)
 }
 
 /* Returns true when efx_vfdi_fini_all_queues should wake */
-static bool efx_vfdi_flush_wake(struct efx_vf *vf)
+static bool efx_vfdi_flush_wake(struct siena_vf *vf)
 {
 	/* Ensure that all updates are visible to efx_vfdi_fini_all_queues() */
 	smp_mb();
@@ -665,7 +666,7 @@ static bool efx_vfdi_flush_wake(struct efx_vf *vf)
 		atomic_read(&vf->rxq_retry_count);
 }
 
-static void efx_vfdi_flush_clear(struct efx_vf *vf)
+static void efx_vfdi_flush_clear(struct siena_vf *vf)
 {
 	memset(vf->txq_mask, 0, sizeof(vf->txq_mask));
 	vf->txq_count = 0;
@@ -675,7 +676,7 @@ static void efx_vfdi_flush_clear(struct efx_vf *vf)
 	atomic_set(&vf->rxq_retry_count, 0);
 }
 
-static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
+static int efx_vfdi_fini_all_queues(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	efx_oword_t reg;
@@ -758,7 +759,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 	return timeout ? 0 : VFDI_RC_ETIMEDOUT;
 }
 
-static int efx_vfdi_insert_filter(struct efx_vf *vf)
+static int efx_vfdi_insert_filter(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -790,7 +791,7 @@ static int efx_vfdi_insert_filter(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-static int efx_vfdi_remove_all_filters(struct efx_vf *vf)
+static int efx_vfdi_remove_all_filters(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -802,7 +803,7 @@ static int efx_vfdi_remove_all_filters(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-static int efx_vfdi_set_status_page(struct efx_vf *vf)
+static int efx_vfdi_set_status_page(struct siena_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -847,7 +848,7 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-static int efx_vfdi_clear_status_page(struct efx_vf *vf)
+static int efx_vfdi_clear_status_page(struct siena_vf *vf)
 {
 	mutex_lock(&vf->status_lock);
 	vf->status_addr = 0;
@@ -856,7 +857,7 @@ static int efx_vfdi_clear_status_page(struct efx_vf *vf)
 	return VFDI_RC_SUCCESS;
 }
 
-typedef int (*efx_vfdi_op_t)(struct efx_vf *vf);
+typedef int (*efx_vfdi_op_t)(struct siena_vf *vf);
 
 static const efx_vfdi_op_t vfdi_ops[VFDI_OP_LIMIT] = {
 	[VFDI_OP_INIT_EVQ] = efx_vfdi_init_evq,
@@ -871,7 +872,7 @@ static const efx_vfdi_op_t vfdi_ops[VFDI_OP_LIMIT] = {
 
 static void efx_siena_sriov_vfdi(struct work_struct *work)
 {
-	struct efx_vf *vf = container_of(work, struct efx_vf, req);
+	struct siena_vf *vf = container_of(work, struct siena_vf, req);
 	struct efx_nic *efx = vf->efx;
 	struct vfdi_req *req = vf->buf.addr;
 	struct efx_memcpy_req copy[2];
@@ -937,7 +938,8 @@ static void efx_siena_sriov_vfdi(struct work_struct *work)
  * event ring in guest memory with VFDI reset events, then (re-initialise) the
  * event queue to raise an interrupt. The guest driver will then recover.
  */
-static void efx_siena_sriov_reset_vf(struct efx_vf *vf,
+
+static void efx_siena_sriov_reset_vf(struct siena_vf *vf,
 				     struct efx_buffer *buffer)
 {
 	struct efx_nic *efx = vf->efx;
@@ -1007,7 +1009,7 @@ static void efx_siena_sriov_reset_vf(struct efx_vf *vf,
 
 static void efx_siena_sriov_reset_vf_work(struct work_struct *work)
 {
-	struct efx_vf *vf = container_of(work, struct efx_vf, req);
+	struct siena_vf *vf = container_of(work, struct siena_vf, req);
 	struct efx_nic *efx = vf->efx;
 	struct efx_buffer buf;
 
@@ -1078,7 +1080,7 @@ static void efx_siena_sriov_peer_work(struct work_struct *data)
 						       peer_work);
 	struct efx_nic *efx = nic_data->efx;
 	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	struct efx_local_addr *local_addr;
 	struct vfdi_endpoint *peer;
 	struct efx_endpoint_page *epp;
@@ -1100,7 +1102,7 @@ static void efx_siena_sriov_peer_work(struct work_struct *data)
 	peer_space = ARRAY_SIZE(vfdi_status->peers) - 1;
 	peer_count = 1;
 	for (pos = 0; pos < efx->vf_count; ++pos) {
-		vf = efx->vf + pos;
+		vf = nic_data->vf + pos;
 
 		mutex_lock(&vf->status_lock);
 		if (vf->rx_filtering && !is_zero_ether_addr(vf->addr.mac_addr)) {
@@ -1156,7 +1158,7 @@ static void efx_siena_sriov_peer_work(struct work_struct *data)
 
 	/* Finally, push the pages */
 	for (pos = 0; pos < efx->vf_count; ++pos) {
-		vf = efx->vf + pos;
+		vf = nic_data->vf + pos;
 
 		mutex_lock(&vf->status_lock);
 		if (vf->status_addr)
@@ -1191,14 +1193,16 @@ static void efx_siena_sriov_free_local(struct efx_nic *efx)
 static int efx_siena_sriov_vf_alloc(struct efx_nic *efx)
 {
 	unsigned index;
-	struct efx_vf *vf;
+	struct siena_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
 
-	efx->vf = kzalloc(sizeof(struct efx_vf) * efx->vf_count, GFP_KERNEL);
-	if (!efx->vf)
+	nic_data->vf = kcalloc(efx->vf_count, sizeof(*nic_data->vf),
+			       GFP_KERNEL);
+	if (!nic_data->vf)
 		return -ENOMEM;
 
 	for (index = 0; index < efx->vf_count; ++index) {
-		vf = efx->vf + index;
+		vf = nic_data->vf + index;
 
 		vf->efx = efx;
 		vf->index = index;
@@ -1217,11 +1221,12 @@ static int efx_siena_sriov_vf_alloc(struct efx_nic *efx)
 
 static void efx_siena_sriov_vfs_fini(struct efx_nic *efx)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 	unsigned int pos;
 
 	for (pos = 0; pos < efx->vf_count; ++pos) {
-		vf = efx->vf + pos;
+		vf = nic_data->vf + pos;
 
 		efx_nic_free_buffer(efx, &vf->buf);
 		kfree(vf->peer_page_addrs);
@@ -1238,7 +1243,7 @@ static int efx_siena_sriov_vfs_init(struct efx_nic *efx)
 	struct siena_nic_data *nic_data = efx->nic_data;
 	unsigned index, devfn, sriov, buftbl_base;
 	u16 offset, stride;
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	int rc;
 
 	sriov = pci_find_ext_capability(pci_dev, PCI_EXT_CAP_ID_SRIOV);
@@ -1251,7 +1256,7 @@ static int efx_siena_sriov_vfs_init(struct efx_nic *efx)
 	buftbl_base = nic_data->vf_buftbl_base;
 	devfn = pci_dev->devfn + offset;
 	for (index = 0; index < efx->vf_count; ++index) {
-		vf = efx->vf + index;
+		vf = nic_data->vf + index;
 
 		/* Reserve buffer entries */
 		vf->buftbl_base = buftbl_base;
@@ -1351,7 +1356,7 @@ fail_pci:
 fail_vfs:
 	cancel_work_sync(&nic_data->peer_work);
 	efx_siena_sriov_free_local(efx);
-	kfree(efx->vf);
+	kfree(nic_data->vf);
 fail_alloc:
 	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 fail_status:
@@ -1362,7 +1367,7 @@ fail_cmd:
 
 void efx_siena_sriov_fini(struct efx_nic *efx)
 {
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	unsigned int pos;
 	struct siena_nic_data *nic_data = efx->nic_data;
 
@@ -1378,7 +1383,7 @@ void efx_siena_sriov_fini(struct efx_nic *efx)
 
 	/* Flush all reconfiguration work */
 	for (pos = 0; pos < efx->vf_count; ++pos) {
-		vf = efx->vf + pos;
+		vf = nic_data->vf + pos;
 		cancel_work_sync(&vf->req);
 		cancel_work_sync(&vf->reset_work);
 	}
@@ -1389,7 +1394,7 @@ void efx_siena_sriov_fini(struct efx_nic *efx)
 	/* Tear down back-end state */
 	efx_siena_sriov_vfs_fini(efx);
 	efx_siena_sriov_free_local(efx);
-	kfree(efx->vf);
+	kfree(nic_data->vf);
 	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 	efx_siena_sriov_cmd(efx, false, NULL, NULL);
 }
@@ -1397,7 +1402,7 @@ void efx_siena_sriov_fini(struct efx_nic *efx)
 void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	unsigned qid, seq, type, data;
 
 	qid = EFX_QWORD_FIELD(*event, FSF_CZ_USER_QID);
@@ -1453,11 +1458,12 @@ error:
 
 void efx_siena_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 
 	if (vf_i > efx->vf_init_count)
 		return;
-	vf = efx->vf + vf_i;
+	vf = nic_data->vf + vf_i;
 	netif_info(efx, hw, efx->net_dev,
 		   "FLR on VF %s\n", vf->pci_name);
 
@@ -1482,7 +1488,7 @@ void efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
 
 void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	unsigned queue, qid;
 
 	queue = EFX_QWORD_FIELD(*event,  FSF_AZ_DRIVER_EV_SUBDATA);
@@ -1501,7 +1507,7 @@ void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 
 void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	unsigned ev_failed, queue, qid;
 
 	queue = EFX_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_RX_DESCQ_ID);
@@ -1526,7 +1532,7 @@ void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 /* Called from napi. Schedule the reset work item */
 void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 {
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 	unsigned int rel;
 
 	if (map_vi_index(efx, dmaq, &vf, &rel))
@@ -1542,9 +1548,10 @@ void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 /* Reset all VFs */
 void efx_siena_sriov_reset(struct efx_nic *efx)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
 	unsigned int vf_i;
 	struct efx_buffer buf;
-	struct efx_vf *vf;
+	struct siena_vf *vf;
 
 	ASSERT_RTNL();
 
@@ -1558,7 +1565,7 @@ void efx_siena_sriov_reset(struct efx_nic *efx)
 		return;
 
 	for (vf_i = 0; vf_i < efx->vf_init_count; ++vf_i) {
-		vf = efx->vf + vf_i;
+		vf = nic_data->vf + vf_i;
 		efx_siena_sriov_reset_vf(vf, &buf);
 	}
 
@@ -1584,11 +1591,12 @@ void efx_fini_sriov(void)
 
 int efx_siena_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 
 	if (vf_i >= efx->vf_init_count)
 		return -EINVAL;
-	vf = efx->vf + vf_i;
+	vf = nic_data->vf + vf_i;
 
 	mutex_lock(&vf->status_lock);
 	ether_addr_copy(vf->addr.mac_addr, mac);
@@ -1601,12 +1609,13 @@ int efx_siena_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 int efx_siena_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i,
 				u16 vlan, u8 qos)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 	u16 tci;
 
 	if (vf_i >= efx->vf_init_count)
 		return -EINVAL;
-	vf = efx->vf + vf_i;
+	vf = nic_data->vf + vf_i;
 
 	mutex_lock(&vf->status_lock);
 	tci = (vlan & VLAN_VID_MASK) | ((qos & 0x7) << VLAN_PRIO_SHIFT);
@@ -1620,12 +1629,13 @@ int efx_siena_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i,
 int efx_siena_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf_i,
 				    bool spoofchk)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 	int rc;
 
 	if (vf_i >= efx->vf_init_count)
 		return -EINVAL;
-	vf = efx->vf + vf_i;
+	vf = nic_data->vf + vf_i;
 
 	mutex_lock(&vf->txq_lock);
 	if (vf->txq_count == 0) {
@@ -1643,12 +1653,13 @@ int efx_siena_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf_i,
 int efx_siena_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				  struct ifla_vf_info *ivi)
 {
-	struct efx_vf *vf;
+	struct siena_nic_data *nic_data = efx->nic_data;
+	struct siena_vf *vf;
 	u16 tci;
 
 	if (vf_i >= efx->vf_init_count)
 		return -EINVAL;
-	vf = efx->vf + vf_i;
+	vf = nic_data->vf + vf_i;
 
 	ivi->vf = vf_i;
 	ether_addr_copy(ivi->mac, vf->addr.mac_addr);
