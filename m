From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 10/10] IB/hfi1: VNIC SDMA support
Date: Fri, 18 Nov 2016 14:42:18 -0800
Message-ID: <1479508938-63799-11-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI1 VNIC SDMA support enables transmission of VNIC packets over SDMA.
Map VNIC queues to SDMA engines and support halting and wakeup of the
VNIC queues.

Change-Id: I2d2d23bda9fb8a7194d9722e23bc69b110cdcf86
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/hw/hfi1/hfi.h         |   1 +
 drivers/infiniband/hw/hfi1/vnic.h        |  30 +++-
 drivers/infiniband/hw/hfi1/vnic_device.c |   2 +-
 drivers/infiniband/hw/hfi1/vnic_main.c   |  22 ++-
 drivers/infiniband/hw/hfi1/vnic_sdma.c   | 260 +++++++++++++++++++++++++++++++
 5 files changed, 311 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index 2ff3453..f476188 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -855,6 +855,7 @@ struct hfi1_asic_data {
 /* Virtual NIC information */
 struct hfi1_vnic_data {
 	struct hfi1_ctxtdata *ctxt[HFI1_NUM_VNIC_CTXT];
+	struct kmem_cache *txreq_cache;
 	u8 num_vports;
 	struct hfi_vnic_ctrl_device *ctrl_dev;
 	struct idr vesw_idr;
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
index d91c35b..4bdfe2b 100644
--- a/drivers/infiniband/hw/hfi1/vnic.h
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -49,6 +49,7 @@
 
 #include "hfi_vnic.h"
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
  * @notifier: vnic notifier
  * @skbq: Array of queues for received socket buffers
+ * @sdma: VNIC SDMA structure per TXQ
  */
 struct hfi1_vnic_vport_info {
 	struct hfi1_devdata *dd;
@@ -112,7 +134,8 @@ struct hfi1_vnic_vport_info {
 	DECLARE_BITMAP(event_flags, HFI_VNIC_NUM_EVTS);
 	struct hfi_vnic_device *vdev;
 
-	struct sk_buff_head skbq[HFI1_NUM_VNIC_CTXT];
+	struct sk_buff_head    skbq[HFI1_NUM_VNIC_CTXT];
+	struct hfi1_vnic_sdma  sdma[HFI1_VNIC_MAX_TXQ];
 };
 
 static inline struct hfi1_devdata *vnic_dev2dd(struct hfi_vnic_device *vdev)
@@ -131,10 +154,15 @@ static inline void hfi1_vnic_update_pad(unsigned char *pad, u8 plen)
 /* vnic hfi1 internal functions */
 int hfi1_vnic_setup(struct hfi1_devdata *dd);
 void hfi1_vnic_cleanup(struct hfi1_devdata *dd);
+int hfi1_vnic_txreq_init(struct hfi1_devdata *dd);
+void hfi1_vnic_txreq_deinit(struct hfi1_devdata *dd);
 int hfi1_vnic_add_ctrl_port(struct hfi1_devdata *dd, struct device *parent);
 void hfi1_vnic_rem_ctrl_port(struct hfi1_devdata *dd);
 
 void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet);
+void hfi1_vnic_sdma_init(struct hfi1_vnic_vport_info *vinfo);
+bool hfi1_vnic_sdma_write_avail(struct hfi1_vnic_vport_info *vinfo,
+				u8 q_idx);
 
 /* vnic device bus ops */
 int hfi1_vnic_init(struct hfi_vnic_device *vdev);
diff --git a/drivers/infiniband/hw/hfi1/vnic_device.c b/drivers/infiniband/hw/hfi1/vnic_device.c
index 468e197..5fb1a49 100644
--- a/drivers/infiniband/hw/hfi1/vnic_device.c
+++ b/drivers/infiniband/hw/hfi1/vnic_device.c
@@ -85,7 +85,7 @@ static int hfi1_vdev_create(struct hfi_vnic_ctrl_device *cdev,
 		return -ENOMEM;
 
 	vinfo->dd = dd;
-	hfi_info.num_tx_q = 1;
+	hfi_info.num_tx_q = dd->chip_sdma_engines;
 	hfi_info.num_rx_q = HFI1_NUM_VNIC_CTXT;
 	hfi_info.cap = HFI_VNIC_CAP_SG;
 	vdev = hfi_vnic_device_register(cdev, port_num, vport_num, vinfo,
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
index 82e30bd..a21e4cd 100644
--- a/drivers/infiniband/hw/hfi1/vnic_main.c
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -294,15 +294,21 @@ int hfi1_vnic_put_skb(struct hfi_vnic_device *vdev,
 
 u8 hfi1_vnic_select_queue(struct hfi_vnic_device *vdev, u8 vl, u8 entropy)
 {
-	return 0;
+	struct hfi1_devdata *dd = (struct hfi1_devdata *)vdev->cdev->hfi_priv;
+	struct sdma_engine *sde;
+
+	sde = sdma_select_engine_vl(dd, entropy, vl);
+	return sde->this_idx;
 }
 
 bool hfi1_vnic_get_write_avail(struct hfi_vnic_device *vdev, u8 q_idx)
 {
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+
 	if (q_idx >= vdev->hfi_info.num_tx_q)
 		return false;
 
-	return true;
+	return hfi1_vnic_sdma_write_avail(vinfo, q_idx);
 }
 
 void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet)
@@ -504,6 +510,13 @@ int hfi1_vnic_init(struct hfi_vnic_device *vdev)
 	int i, rc = 0;
 
 	mutex_lock(&hfi1_mutex);
+
+	if (!dd->vnic.num_vports) {
+		rc = hfi1_vnic_txreq_init(dd);
+		if (rc)
+			goto txreq_fail;
+	}
+
 	for (i = dd->vnic.num_ctxt; i < vdev->hfi_info.num_rx_q; i++) {
 		rc = hfi1_vnic_allot_ctxt(dd, &dd->vnic.ctxt[i]);
 		if (rc)
@@ -531,7 +544,11 @@ int hfi1_vnic_init(struct hfi_vnic_device *vdev)
 
 	dd->vnic.num_vports++;
 	vinfo->vdev = vdev;
+	hfi1_vnic_sdma_init(vinfo);
 alloc_fail:
+	if (!dd->vnic.num_vports)
+		hfi1_vnic_txreq_deinit(dd);
+txreq_fail:
 	mutex_unlock(&hfi1_mutex);
 	return rc;
 }
@@ -549,6 +566,7 @@ void hfi1_vnic_deinit(struct hfi_vnic_device *vdev)
 		}
 		hfi1_deinit_vnic_rsm(dd);
 		dd->vnic.num_ctxt = 0;
+		hfi1_vnic_txreq_deinit(dd);
 	}
 
 	mutex_unlock(&hfi1_mutex);
diff --git a/drivers/infiniband/hw/hfi1/vnic_sdma.c b/drivers/infiniband/hw/hfi1/vnic_sdma.c
index 66abad0..e9754dd 100644
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
+		notifier->cb(vinfo->vdev, evt);
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
+	for (i = 0; i < vinfo->vdev->hfi_info.num_tx_q; i++) {
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
