From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [RFC v2 10/10] IB/hfi1: VNIC SDMA support
Date: Wed, 14 Dec 2016 23:59:42 -0800
Message-ID: <1481788782-89964-11-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:44491 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933120AbcLOIAc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 03:00:32 -0500
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI1 VNIC SDMA support enables transmission of VNIC packets over SDMA.
Map VNIC queues to SDMA engines and support halting and wakeup of the
VNIC queues.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 drivers/infiniband/hw/hfi1/hfi.h       |   1 +
 drivers/infiniband/hw/hfi1/vnic.h      |  30 +++-
 drivers/infiniband/hw/hfi1/vnic_main.c |  21 ++-
 drivers/infiniband/hw/hfi1/vnic_sdma.c | 260 +++++++++++++++++++++++++++++++++
 4 files changed, 309 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index 78d1726..8d5949f 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -855,6 +855,7 @@ struct hfi1_asic_data {
 /* Virtual NIC information */
 struct hfi1_vnic_data {
 	struct hfi1_ctxtdata *ctxt[HFI1_NUM_VNIC_CTXT];
+	struct kmem_cache *txreq_cache;
 	u8 num_vports;
 	struct idr vesw_idr;
 	u8 rmt_start;
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
index 047845e..2d4eb8f 100644
--- a/drivers/infiniband/hw/hfi1/vnic.h
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -49,6 +49,7 @@
 
 #include <rdma/opa_hfi.h>
 #include "hfi.h"
+#include "sdma.h"
 
 #define HFI1_VNIC_ICRC_LEN   4
 #define HFI1_VNIC_TAIL_LEN   1
@@ -90,6 +91,26 @@
 #define HFI1_VNIC_SC_SHIFT      4
 
 /**
+ * struct hfi1_vnic_sdma - VNIC per Tx ring SDMA information
+ * @dd - device data pointer
+ * @sde - sdma engine
+ * @vinfo - vnic info pointer
+ * @wait - iowait structure
+ * @stx - sdma tx request
+ * @state - vnic Tx ring SDMA state
+ * @q_idx - vnic Tx queue index
+ */
+struct hfi1_vnic_sdma {
+	struct hfi1_devdata *dd;
+	struct sdma_engine  *sde;
+	struct hfi1_vnic_vport_info *vinfo;
+	struct iowait wait;
+	struct sdma_txreq stx;
+	unsigned int state;
+	u8 q_idx;
+};
+
+/**
  * struct hfi1_vnic_notifier - VNIC notifer structure
  * @cb - vnic callback function
  */
@@ -104,6 +125,7 @@ struct hfi1_vnic_notifier {
  * @event_flags: event notification flags
  * @vport: vnic port pointer
  * @skbq: Array of queues for received socket buffers
+ * @sdma: VNIC SDMA structure per TXQ
  */
 struct hfi1_vnic_vport_info {
 	struct hfi1_devdata *dd;
@@ -112,7 +134,8 @@ struct hfi1_vnic_vport_info {
 	DECLARE_BITMAP(event_flags, HFI_VNIC_NUM_EVTS);
 	struct hfi_vnic_port *vport;
 
-	struct sk_buff_head skbq[HFI1_NUM_VNIC_CTXT];
+	struct sk_buff_head    skbq[HFI1_NUM_VNIC_CTXT];
+	struct hfi1_vnic_sdma  sdma[HFI1_VNIC_MAX_TXQ];
 };
 
 static inline struct hfi1_devdata *vnic_dev2dd(struct hfi_vnic_port *vport)
@@ -131,8 +154,13 @@ static inline void hfi1_vnic_update_pad(unsigned char *pad, u8 plen)
 /* vnic hfi1 internal functions */
 void hfi1_vnic_setup(struct hfi1_devdata *dd);
 void hfi1_vnic_cleanup(struct hfi1_devdata *dd);
+int hfi1_vnic_txreq_init(struct hfi1_devdata *dd);
+void hfi1_vnic_txreq_deinit(struct hfi1_devdata *dd);
 
 void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet);
+void hfi1_vnic_sdma_init(struct hfi1_vnic_vport_info *vinfo);
+bool hfi1_vnic_sdma_write_avail(struct hfi1_vnic_vport_info *vinfo,
+				u8 q_idx);
 
 /* vnic port operations */
 struct hfi_vnic_port *hfi1_vnic_add_vport(struct ib_device *device,
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
index 1e237f3..19843a4 100644
--- a/drivers/infiniband/hw/hfi1/vnic_main.c
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -289,15 +289,21 @@ static int hfi1_vnic_put_skb(struct hfi_vnic_port *vport,
 
 static u8 hfi1_vnic_select_queue(struct hfi_vnic_port *vport, u8 vl, u8 entropy)
 {
-	return 0;
+	struct hfi1_vnic_vport_info *vinfo = vport->hfi_priv;
+	struct sdma_engine *sde;
+
+	sde = sdma_select_engine_vl(vinfo->dd, entropy, vl);
+	return sde->this_idx;
 }
 
 static bool hfi1_vnic_get_write_avail(struct hfi_vnic_port *vport, u8 q_idx)
 {
+	struct hfi1_vnic_vport_info *vinfo = vport->hfi_priv;
+
 	if (q_idx >= vport->hfi_info.num_tx_q)
 		return false;
 
-	return true;
+	return hfi1_vnic_sdma_write_avail(vinfo, q_idx);
 }
 
 void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet)
@@ -499,6 +505,12 @@ static int hfi1_vnic_init(struct hfi_vnic_port *vport)
 	int i, rc = 0;
 
 	mutex_lock(&hfi1_mutex);
+	if (!dd->vnic.num_vports) {
+		rc = hfi1_vnic_txreq_init(dd);
+		if (rc)
+			goto txreq_fail;
+	}
+
 	for (i = dd->vnic.num_ctxt; i < vport->hfi_info.num_rx_q; i++) {
 		rc = hfi1_vnic_allot_ctxt(dd, &dd->vnic.ctxt[i]);
 		if (rc)
@@ -526,7 +538,11 @@ static int hfi1_vnic_init(struct hfi_vnic_port *vport)
 
 	dd->vnic.num_vports++;
 	vinfo->vport = vport;
+	hfi1_vnic_sdma_init(vinfo);
 alloc_fail:
+	if (!dd->vnic.num_vports)
+		hfi1_vnic_txreq_deinit(dd);
+txreq_fail:
 	mutex_unlock(&hfi1_mutex);
 	return rc;
 }
@@ -544,6 +560,7 @@ static void hfi1_vnic_deinit(struct hfi_vnic_port *vport)
 		}
 		hfi1_deinit_vnic_rsm(dd);
 		dd->vnic.num_ctxt = 0;
+		hfi1_vnic_txreq_deinit(dd);
 	}
 	mutex_unlock(&hfi1_mutex);
 }
diff --git a/drivers/infiniband/hw/hfi1/vnic_sdma.c b/drivers/infiniband/hw/hfi1/vnic_sdma.c
index 66abad0..cb1f9ce 100644
--- a/drivers/infiniband/hw/hfi1/vnic_sdma.c
+++ b/drivers/infiniband/hw/hfi1/vnic_sdma.c
@@ -52,9 +52,269 @@
 #include "sdma.h"
 #include "vnic.h"
 
+#define HFI1_VNIC_SDMA_Q_ACTIVE   BIT(0)
+#define HFI1_VNIC_SDMA_Q_DEFERRED BIT(1)
+
+#define HFI1_VNIC_TXREQ_NAME_LEN   32
+#define HFI1_VNIC_SDMA_DESC_WTRMRK 64
+#define HFI1_VNIC_SDMA_RETRY_COUNT 1
+
+/*
+ * struct vnic_txreq - VNIC transmit descriptor
+ * @txreq: sdma transmit request
+ * @sdma: vnic sdma pointer
+ * @skb: skb to send
+ * @pad: pad buffer
+ * @plen: pad length
+ * @pbc_val: pbc value
+ * @retry_count: tx retry count
+ */
+struct vnic_txreq {
+	struct sdma_txreq       txreq;
+	struct hfi1_vnic_sdma   *sdma;
+
+	struct sk_buff         *skb;
+	unsigned char           pad[HFI1_VNIC_MAX_PAD];
+	u16                     plen;
+	__le64                  pbc_val;
+
+	u32                     retry_count;
+};
+
+static void vnic_sdma_complete(struct sdma_txreq *txreq,
+			       int status)
+{
+	struct vnic_txreq *tx = container_of(txreq, struct vnic_txreq, txreq);
+	struct hfi1_vnic_sdma *vnic_sdma = tx->sdma;
+
+	sdma_txclean(vnic_sdma->dd, txreq);
+	dev_kfree_skb_any(tx->skb);
+	kmem_cache_free(vnic_sdma->dd->vnic.txreq_cache, tx);
+}
+
+static noinline int build_vnic_ulp_payload(struct sdma_engine *sde,
+					   struct vnic_txreq *tx)
+{
+	int i, ret = 0;
+
+	ret = sdma_txadd_kvaddr(
+		sde->dd,
+		&tx->txreq,
+		tx->skb->data,
+		skb_headlen(tx->skb));
+	if (ret)
+		goto bail_txadd;
+
+	for (i = 0; i < skb_shinfo(tx->skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(tx->skb)->frags[i];
+
+		/* combine physically continuous fragments later? */
+		ret = sdma_txadd_page(sde->dd,
+				      &tx->txreq,
+				      skb_frag_page(frag),
+				      frag->page_offset,
+				      skb_frag_size(frag));
+		if (ret)
+			goto bail_txadd;
+	}
+
+	if (tx->plen)
+		ret = sdma_txadd_kvaddr(sde->dd, &tx->txreq,
+					tx->pad + HFI1_VNIC_MAX_PAD - tx->plen,
+					tx->plen);
+
+bail_txadd:
+	return ret;
+}
+
+static int build_vnic_tx_desc(struct sdma_engine *sde,
+			      struct vnic_txreq *tx,
+			      u64 pbc)
+{
+	int ret = 0;
+	u16 hdrbytes = 2 << 2;  /* PBC */
+
+	ret = sdma_txinit_ahg(
+		&tx->txreq,
+		0,
+		hdrbytes + tx->skb->len + tx->plen,
+		0,
+		0,
+		NULL,
+		0,
+		vnic_sdma_complete);
+	if (ret)
+		goto bail_txadd;
+
+	/* add pbc */
+	tx->pbc_val = cpu_to_le64(pbc);
+	ret = sdma_txadd_kvaddr(
+		sde->dd,
+		&tx->txreq,
+		&tx->pbc_val,
+		hdrbytes);
+	if (ret)
+		goto bail_txadd;
+
+	/* add the ulp payload */
+	ret = build_vnic_ulp_payload(sde, tx);
+bail_txadd:
+	return ret;
+}
+
 int hfi1_vnic_send_dma(struct hfi1_devdata *dd, u8 q_idx,
 		       struct hfi1_vnic_vport_info *vinfo,
 		       struct sk_buff *skb, u64 pbc, u8 plen)
 {
+	struct hfi1_vnic_sdma *vnic_sdma = &vinfo->sdma[q_idx];
+	struct sdma_engine *sde = vnic_sdma->sde;
+	struct vnic_txreq *tx;
+	int ret = -ECOMM;
+
+	if (READ_ONCE(vnic_sdma->state) != HFI1_VNIC_SDMA_Q_ACTIVE)
+		goto tx_err;
+
+	if (!sde || !sdma_running(sde))
+		goto tx_err;
+
+	tx = kmem_cache_alloc(dd->vnic.txreq_cache, GFP_ATOMIC);
+	if (!tx) {
+		ret = -ENOMEM;
+		goto tx_err;
+	}
+
+	tx->sdma = vnic_sdma;
+	tx->skb = skb;
+	hfi1_vnic_update_pad(tx->pad, plen);
+	tx->plen = plen;
+	ret = build_vnic_tx_desc(sde, tx, pbc);
+	if (unlikely(ret))
+		goto free_desc;
+	tx->retry_count = 0;
+
+	ret = sdma_send_txreq(sde, &vnic_sdma->wait, &tx->txreq);
+	/* When -ECOMM, sdma callback will be called with ABORT status */
+	if (ret && unlikely(ret != -ECOMM))
+		goto free_desc;
+
+	return ret;
+
+free_desc:
+	sdma_txclean(dd, &tx->txreq);
+	kmem_cache_free(dd->vnic.txreq_cache, tx);
+tx_err:
+	if (ret != -EBUSY)
+		dev_kfree_skb_any(skb);
+	return ret;
+}
+
+/*
+ * hfi1_vnic_sdma_sleep - vnic sdma sleep function
+ *
+ * This function gets called from sdma_send_txreq() when there are not enough
+ * sdma descriptors available to send the packet. It adds Tx queue's wait
+ * structure to sdma engine's dmawait list to be woken up when descriptors
+ * become available.
+ */
+static int hfi1_vnic_sdma_sleep(struct sdma_engine *sde,
+				struct iowait *wait,
+				struct sdma_txreq *txreq,
+				unsigned int seq)
+{
+	struct hfi1_vnic_sdma *vnic_sdma =
+		container_of(wait, struct hfi1_vnic_sdma, wait);
+	struct hfi1_ibdev *dev = &vnic_sdma->dd->verbs_dev;
+	struct vnic_txreq *tx = container_of(txreq, struct vnic_txreq, txreq);
+
+	if (sdma_progress(sde, seq, txreq))
+		if (tx->retry_count++ < HFI1_VNIC_SDMA_RETRY_COUNT)
+			return -EAGAIN;
+
+	vnic_sdma->state = HFI1_VNIC_SDMA_Q_DEFERRED;
+	write_seqlock(&dev->iowait_lock);
+	if (list_empty(&vnic_sdma->wait.list))
+		list_add_tail(&vnic_sdma->wait.list, &sde->dmawait);
+	write_sequnlock(&dev->iowait_lock);
+	return -EBUSY;
+}
+
+/*
+ * hfi1_vnic_sdma_wakeup - vnic sdma wakeup function
+ *
+ * This function gets called when SDMA descriptors becomes available and Tx
+ * queue's wait structure was previously added to sdma engine's dmawait list.
+ * It notifies the upper driver about Tx queue wakeup.
+ */
+static void hfi1_vnic_sdma_wakeup(struct iowait *wait, int reason)
+{
+	struct hfi1_vnic_sdma *vnic_sdma =
+		container_of(wait, struct hfi1_vnic_sdma, wait);
+	struct hfi1_vnic_vport_info *vinfo = vnic_sdma->vinfo;
+	u8 evt = HFI_VNIC_EVT_TX0 + vnic_sdma->q_idx;
+	struct hfi1_vnic_notifier *notifier;
+
+	vnic_sdma->state = HFI1_VNIC_SDMA_Q_ACTIVE;
+	notifier = rcu_dereference(vinfo->notifier);
+	if (notifier && notifier->cb && test_bit(evt, vinfo->event_flags))
+		notifier->cb(vinfo->vport, evt);
+};
+
+inline bool hfi1_vnic_sdma_write_avail(struct hfi1_vnic_vport_info *vinfo,
+				       u8 q_idx)
+{
+	struct hfi1_vnic_sdma *vnic_sdma = &vinfo->sdma[q_idx];
+
+	return (READ_ONCE(vnic_sdma->state) == HFI1_VNIC_SDMA_Q_ACTIVE);
+}
+
+void hfi1_vnic_sdma_init(struct hfi1_vnic_vport_info *vinfo)
+{
+	int i;
+
+	for (i = 0; i < vinfo->vport->hfi_info.num_tx_q; i++) {
+		struct hfi1_vnic_sdma *vnic_sdma = &vinfo->sdma[i];
+
+		iowait_init(&vnic_sdma->wait, 0, NULL, hfi1_vnic_sdma_sleep,
+			    hfi1_vnic_sdma_wakeup, NULL);
+		vnic_sdma->sde = &vinfo->dd->per_sdma[i];
+		vnic_sdma->dd = vinfo->dd;
+		vnic_sdma->vinfo = vinfo;
+		vnic_sdma->q_idx = i;
+		vnic_sdma->state = HFI1_VNIC_SDMA_Q_ACTIVE;
+
+		/* Add a free descriptor watermark for wakeups */
+		if (vnic_sdma->sde->descq_cnt >= HFI1_VNIC_SDMA_DESC_WTRMRK) {
+			INIT_LIST_HEAD(&vnic_sdma->stx.list);
+			vnic_sdma->stx.num_desc = HFI1_VNIC_SDMA_DESC_WTRMRK;
+			list_add_tail(&vnic_sdma->stx.list,
+				      &vnic_sdma->wait.tx_head);
+		}
+	}
+}
+
+static void hfi1_vnic_txreq_kmem_cache_ctor(void *obj)
+{
+	struct vnic_txreq *tx = (struct vnic_txreq *)obj;
+
+	memset(tx, 0, sizeof(*tx));
+}
+
+int hfi1_vnic_txreq_init(struct hfi1_devdata *dd)
+{
+	char buf[HFI1_VNIC_TXREQ_NAME_LEN];
+
+	snprintf(buf, sizeof(buf), "hfi1_%u_vnic_txreq_cache", dd->unit);
+	dd->vnic.txreq_cache = kmem_cache_create(buf,
+					  sizeof(struct vnic_txreq),
+					  0, SLAB_HWCACHE_ALIGN,
+					  hfi1_vnic_txreq_kmem_cache_ctor);
+	if (!dd->vnic.txreq_cache)
+		return -ENOMEM;
 	return 0;
 }
+
+void hfi1_vnic_txreq_deinit(struct hfi1_devdata *dd)
+{
+	kmem_cache_destroy(dd->vnic.txreq_cache);
+	dd->vnic.txreq_cache = NULL;
+}
-- 
1.8.3.1
