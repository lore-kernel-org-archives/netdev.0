From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v1 12/12] IB/hfi1: VNIC SDMA support
Date: Tue, 11 Apr 2017 23:40:07 -0700
Message-ID: <1491979207-18686-13-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:16281 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752302AbdDLGkd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:40:33 -0400
In-Reply-To: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI1 VNIC SDMA support enables transmission of VNIC packets over SDMA.
Map VNIC queues to SDMA engines and support halting and wakeup of the
VNIC queues.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 drivers/infiniband/hw/hfi1/Makefile    |   2 +-
 drivers/infiniband/hw/hfi1/hfi.h       |   1 +
 drivers/infiniband/hw/hfi1/init.c      |   1 +
 drivers/infiniband/hw/hfi1/vnic.h      |  28 +++
 drivers/infiniband/hw/hfi1/vnic_main.c |  24 ++-
 drivers/infiniband/hw/hfi1/vnic_sdma.c | 323 +++++++++++++++++++++++++++++++++
 6 files changed, 376 insertions(+), 3 deletions(-)
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c

diff --git a/drivers/infiniband/hw/hfi1/Makefile b/drivers/infiniband/hw/hfi1/Makefile
index 2280538..88085f6 100644
--- a/drivers/infiniband/hw/hfi1/Makefile
+++ b/drivers/infiniband/hw/hfi1/Makefile
@@ -12,7 +12,7 @@ hfi1-y := affinity.o chip.o device.o driver.o efivar.o \
 	init.o intr.o mad.o mmu_rb.o pcie.o pio.o pio_copy.o platform.o \
 	qp.o qsfp.o rc.o ruc.o sdma.o sysfs.o trace.o \
 	uc.o ud.o user_exp_rcv.o user_pages.o user_sdma.o verbs.o \
-	verbs_txreq.o vnic_main.o
+	verbs_txreq.o vnic_main.o vnic_sdma.o
 hfi1-$(CONFIG_DEBUG_FS) += debugfs.o
 
 CFLAGS_trace.o = -I$(src)
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index a12bb46..2862b14 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -834,6 +834,7 @@ struct hfi1_asic_data {
 /* Virtual NIC information */
 struct hfi1_vnic_data {
 	struct hfi1_ctxtdata *ctxt[HFI1_NUM_VNIC_CTXT];
+	struct kmem_cache *txreq_cache;
 	u8 num_vports;
 	struct idr vesw_idr;
 	u8 rmt_start;
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index de2eec4..b4c7e04 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -681,6 +681,7 @@ int hfi1_init(struct hfi1_devdata *dd, int reinit)
 	dd->process_pio_send = hfi1_verbs_send_pio;
 	dd->process_dma_send = hfi1_verbs_send_dma;
 	dd->pio_inline_send = pio_copy;
+	dd->process_vnic_dma_send = hfi1_vnic_send_dma;
 
 	if (is_ax(dd)) {
 		atomic_set(&dd->drop_packet, DROP_PACKET_ON);
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
index 9bed40d..e2c4552 100644
--- a/drivers/infiniband/hw/hfi1/vnic.h
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -49,6 +49,7 @@
 
 #include <rdma/opa_vnic.h>
 #include "hfi.h"
+#include "sdma.h"
 
 #define HFI1_VNIC_MAX_TXQ     16
 #define HFI1_VNIC_MAX_PAD     12
@@ -85,6 +86,26 @@
 #define HFI1_VNIC_MAX_QUEUE 16
 
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
  * struct hfi1_vnic_rx_queue - HFI1 VNIC receive queue
  * @idx: queue index
  * @vinfo: pointer to vport information
@@ -111,6 +132,7 @@ struct hfi1_vnic_rx_queue {
  * @vesw_id: virtual switch id
  * @rxq: Array of receive queues
  * @stats: per queue stats
+ * @sdma: VNIC SDMA structure per TXQ
  */
 struct hfi1_vnic_vport_info {
 	struct hfi1_devdata *dd;
@@ -126,6 +148,7 @@ struct hfi1_vnic_vport_info {
 	struct hfi1_vnic_rx_queue rxq[HFI1_NUM_VNIC_CTXT];
 
 	struct opa_vnic_stats  stats[HFI1_VNIC_MAX_QUEUE];
+	struct hfi1_vnic_sdma  sdma[HFI1_VNIC_MAX_TXQ];
 };
 
 #define v_dbg(format, arg...) \
@@ -138,8 +161,13 @@ struct hfi1_vnic_vport_info {
 /* vnic hfi1 internal functions */
 void hfi1_vnic_setup(struct hfi1_devdata *dd);
 void hfi1_vnic_cleanup(struct hfi1_devdata *dd);
+int hfi1_vnic_txreq_init(struct hfi1_devdata *dd);
+void hfi1_vnic_txreq_deinit(struct hfi1_devdata *dd);
 
 void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet);
+void hfi1_vnic_sdma_init(struct hfi1_vnic_vport_info *vinfo);
+bool hfi1_vnic_sdma_write_avail(struct hfi1_vnic_vport_info *vinfo,
+				u8 q_idx);
 
 /* vnic rdma netdev operations */
 struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
index 1846d7c..6d0a4b1 100644
--- a/drivers/infiniband/hw/hfi1/vnic_main.c
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -406,6 +406,10 @@ static void hfi1_vnic_maybe_stop_tx(struct hfi1_vnic_vport_info *vinfo,
 				    u8 q_idx)
 {
 	netif_stop_subqueue(vinfo->netdev, q_idx);
+	if (!hfi1_vnic_sdma_write_avail(vinfo, q_idx))
+		return;
+
+	netif_start_subqueue(vinfo->netdev, q_idx);
 }
 
 static netdev_tx_t hfi1_netdev_start_xmit(struct sk_buff *skb,
@@ -477,7 +481,13 @@ static u16 hfi1_vnic_select_queue(struct net_device *netdev,
 				  void *accel_priv,
 				  select_queue_fallback_t fallback)
 {
-	return 0;
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+	struct opa_vnic_skb_mdata *mdata;
+	struct sdma_engine *sde;
+
+	mdata = (struct opa_vnic_skb_mdata *)skb->data;
+	sde = sdma_select_engine_vl(vinfo->dd, mdata->entropy, mdata->vl);
+	return sde->this_idx;
 }
 
 /* hfi1_vnic_decap_skb - strip OPA header from the skb (ethernet) packet */
@@ -733,8 +743,13 @@ static int hfi1_vnic_init(struct hfi1_vnic_vport_info *vinfo)
 	int i, rc = 0;
 
 	mutex_lock(&hfi1_mutex);
-	if (!dd->vnic.num_vports)
+	if (!dd->vnic.num_vports) {
+		rc = hfi1_vnic_txreq_init(dd);
+		if (rc)
+			goto txreq_fail;
+
 		dd->vnic.msix_idx = dd->first_dyn_msix_idx;
+	}
 
 	for (i = dd->vnic.num_ctxt; i < vinfo->num_rx_q; i++) {
 		rc = hfi1_vnic_allot_ctxt(dd, &dd->vnic.ctxt[i]);
@@ -762,7 +777,11 @@ static int hfi1_vnic_init(struct hfi1_vnic_vport_info *vinfo)
 	}
 
 	dd->vnic.num_vports++;
+	hfi1_vnic_sdma_init(vinfo);
 alloc_fail:
+	if (!dd->vnic.num_vports)
+		hfi1_vnic_txreq_deinit(dd);
+txreq_fail:
 	mutex_unlock(&hfi1_mutex);
 	return rc;
 }
@@ -780,6 +799,7 @@ static void hfi1_vnic_deinit(struct hfi1_vnic_vport_info *vinfo)
 		}
 		hfi1_deinit_vnic_rsm(dd);
 		dd->vnic.num_ctxt = 0;
+		hfi1_vnic_txreq_deinit(dd);
 	}
 	mutex_unlock(&hfi1_mutex);
 }
diff --git a/drivers/infiniband/hw/hfi1/vnic_sdma.c b/drivers/infiniband/hw/hfi1/vnic_sdma.c
new file mode 100644
index 0000000..51a817d
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic_sdma.c
@@ -0,0 +1,323 @@
+/*
+ * Copyright(c) 2017 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI1 support for VNIC SDMA functionality
+ */
+
+#include "sdma.h"
+#include "vnic.h"
+
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
+	if (unlikely(ret))
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
+		if (unlikely(ret))
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
+	if (unlikely(ret))
+		goto bail_txadd;
+
+	/* add pbc */
+	tx->pbc_val = cpu_to_le64(pbc);
+	ret = sdma_txadd_kvaddr(
+		sde->dd,
+		&tx->txreq,
+		&tx->pbc_val,
+		hdrbytes);
+	if (unlikely(ret))
+		goto bail_txadd;
+
+	/* add the ulp payload */
+	ret = build_vnic_ulp_payload(sde, tx);
+bail_txadd:
+	return ret;
+}
+
+/* setup the last plen bypes of pad */
+static inline void hfi1_vnic_update_pad(unsigned char *pad, u8 plen)
+{
+	pad[HFI1_VNIC_MAX_PAD - 1] = plen - OPA_VNIC_ICRC_TAIL_LEN;
+}
+
+int hfi1_vnic_send_dma(struct hfi1_devdata *dd, u8 q_idx,
+		       struct hfi1_vnic_vport_info *vinfo,
+		       struct sk_buff *skb, u64 pbc, u8 plen)
+{
+	struct hfi1_vnic_sdma *vnic_sdma = &vinfo->sdma[q_idx];
+	struct sdma_engine *sde = vnic_sdma->sde;
+	struct vnic_txreq *tx;
+	int ret = -ECOMM;
+
+	if (unlikely(READ_ONCE(vnic_sdma->state) != HFI1_VNIC_SDMA_Q_ACTIVE))
+		goto tx_err;
+
+	if (unlikely(!sde || !sdma_running(sde)))
+		goto tx_err;
+
+	tx = kmem_cache_alloc(dd->vnic.txreq_cache, GFP_ATOMIC);
+	if (unlikely(!tx)) {
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
+	if (unlikely(ret && unlikely(ret != -ECOMM)))
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
+
+	vnic_sdma->state = HFI1_VNIC_SDMA_Q_ACTIVE;
+	if (__netif_subqueue_stopped(vinfo->netdev, vnic_sdma->q_idx))
+		netif_wake_subqueue(vinfo->netdev, vnic_sdma->q_idx);
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
+	for (i = 0; i < vinfo->num_tx_q; i++) {
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
+		if (vnic_sdma->sde->descq_cnt > HFI1_VNIC_SDMA_DESC_WTRMRK) {
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
+	return 0;
+}
+
+void hfi1_vnic_txreq_deinit(struct hfi1_devdata *dd)
+{
+	kmem_cache_destroy(dd->vnic.txreq_cache);
+	dd->vnic.txreq_cache = NULL;
+}
-- 
1.8.3.1
