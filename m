From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v1 11/12] IB/hfi1: Virtual Network Interface Controller (VNIC) HW support
Date: Tue, 11 Apr 2017 23:40:06 -0700
Message-ID: <1491979207-18686-12-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48736 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752737AbdDLGk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:40:26 -0400
In-Reply-To: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI1 HW specific support for VNIC functionality.
Dynamically allocate a set of contexts for VNIC when the first vnic
port is instantiated. Allocate VNIC contexts from user contexts pool
and return them back to the same pool while freeing up. Set aside
enough MSI-X interrupts for VNIC contexts and assign them when the
contexts are allocated. On the receive side, use an RSM rule to
spread TCP/UDP streams among VNIC contexts.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski@intel.com>
---
 drivers/infiniband/hw/hfi1/aspm.h         |  15 +-
 drivers/infiniband/hw/hfi1/chip.c         | 291 +++++++++++++++++++++++++-----
 drivers/infiniband/hw/hfi1/chip.h         |   2 +
 drivers/infiniband/hw/hfi1/debugfs.c      |   8 +-
 drivers/infiniband/hw/hfi1/driver.c       |  52 ++++--
 drivers/infiniband/hw/hfi1/file_ops.c     |  27 ++-
 drivers/infiniband/hw/hfi1/hfi.h          |  29 ++-
 drivers/infiniband/hw/hfi1/init.c         |  29 +--
 drivers/infiniband/hw/hfi1/mad.c          |  10 +-
 drivers/infiniband/hw/hfi1/pio.c          |  19 +-
 drivers/infiniband/hw/hfi1/pio.h          |   8 +-
 drivers/infiniband/hw/hfi1/sysfs.c        |   4 +-
 drivers/infiniband/hw/hfi1/user_exp_rcv.c |   8 +-
 drivers/infiniband/hw/hfi1/user_pages.c   |   5 +-
 drivers/infiniband/hw/hfi1/verbs.c        |   6 +-
 drivers/infiniband/hw/hfi1/vnic.h         |   3 +
 drivers/infiniband/hw/hfi1/vnic_main.c    | 245 ++++++++++++++++++++++++-
 include/rdma/opa_port_info.h              |   3 +-
 18 files changed, 660 insertions(+), 104 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/aspm.h b/drivers/infiniband/hw/hfi1/aspm.h
index 0d58fe3..794e681 100644
--- a/drivers/infiniband/hw/hfi1/aspm.h
+++ b/drivers/infiniband/hw/hfi1/aspm.h
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -229,14 +229,17 @@ static inline void aspm_ctx_timer_function(unsigned long data)
 	spin_unlock_irqrestore(&rcd->aspm_lock, flags);
 }
 
-/* Disable interrupt processing for verbs contexts when PSM contexts are open */
+/*
+ * Disable interrupt processing for verbs contexts when PSM or VNIC contexts
+ * are open.
+ */
 static inline void aspm_disable_all(struct hfi1_devdata *dd)
 {
 	struct hfi1_ctxtdata *rcd;
 	unsigned long flags;
 	unsigned i;
 
-	for (i = 0; i < dd->first_user_ctxt; i++) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; i++) {
 		rcd = dd->rcd[i];
 		del_timer_sync(&rcd->aspm_timer);
 		spin_lock_irqsave(&rcd->aspm_lock, flags);
@@ -260,7 +263,7 @@ static inline void aspm_enable_all(struct hfi1_devdata *dd)
 	if (aspm_mode != ASPM_MODE_DYNAMIC)
 		return;
 
-	for (i = 0; i < dd->first_user_ctxt; i++) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; i++) {
 		rcd = dd->rcd[i];
 		spin_lock_irqsave(&rcd->aspm_lock, flags);
 		rcd->aspm_intr_enable = true;
@@ -276,7 +279,7 @@ static inline void aspm_ctx_init(struct hfi1_ctxtdata *rcd)
 		    (unsigned long)rcd);
 	rcd->aspm_intr_supported = rcd->dd->aspm_supported &&
 		aspm_mode == ASPM_MODE_DYNAMIC &&
-		rcd->ctxt < rcd->dd->first_user_ctxt;
+		rcd->ctxt < rcd->dd->first_dyn_alloc_ctxt;
 }
 
 static inline void aspm_init(struct hfi1_devdata *dd)
@@ -286,7 +289,7 @@ static inline void aspm_init(struct hfi1_devdata *dd)
 	spin_lock_init(&dd->aspm_lock);
 	dd->aspm_supported = aspm_hw_l1_supported(dd);
 
-	for (i = 0; i < dd->first_user_ctxt; i++)
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; i++)
 		aspm_ctx_init(dd->rcd[i]);
 
 	/* Start with ASPM disabled */
diff --git a/drivers/infiniband/hw/hfi1/chip.c b/drivers/infiniband/hw/hfi1/chip.c
index 79a316a..e520929 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -126,9 +126,16 @@ struct flag_table {
 #define DEFAULT_KRCVQS		  2
 #define MIN_KERNEL_KCTXTS         2
 #define FIRST_KERNEL_KCTXT        1
-/* sizes for both the QP and RSM map tables */
-#define NUM_MAP_ENTRIES		256
-#define NUM_MAP_REGS             32
+
+/*
+ * RSM instance allocation
+ *   0 - Verbs
+ *   1 - User Fecn Handling
+ *   2 - Vnic
+ */
+#define RSM_INS_VERBS             0
+#define RSM_INS_FECN              1
+#define RSM_INS_VNIC              2
 
 /* Bit offset into the GUID which carries HFI id information */
 #define GUID_HFI_INDEX_SHIFT     39
@@ -139,8 +146,7 @@ struct flag_table {
 #define is_emulator_p(dd) ((((dd)->irev) & 0xf) == 3)
 #define is_emulator_s(dd) ((((dd)->irev) & 0xf) == 4)
 
-/* RSM fields */
-
+/* RSM fields for Verbs */
 /* packet type */
 #define IB_PACKET_TYPE         2ull
 #define QW_SHIFT               6ull
@@ -170,6 +176,28 @@ struct flag_table {
 /* QPN[m+n:1] QW 1, OFFSET 1 */
 #define QPN_SELECT_OFFSET      ((1ull << QW_SHIFT) | (1ull))
 
+/* RSM fields for Vnic */
+/* L2_TYPE: QW 0, OFFSET 61 - for match */
+#define L2_TYPE_QW             0ull
+#define L2_TYPE_BIT_OFFSET     61ull
+#define L2_TYPE_OFFSET(off)    ((L2_TYPE_QW << QW_SHIFT) | (off))
+#define L2_TYPE_MATCH_OFFSET   L2_TYPE_OFFSET(L2_TYPE_BIT_OFFSET)
+#define L2_TYPE_MASK           3ull
+#define L2_16B_VALUE           2ull
+
+/* L4_TYPE QW 1, OFFSET 0 - for match */
+#define L4_TYPE_QW              1ull
+#define L4_TYPE_BIT_OFFSET      0ull
+#define L4_TYPE_OFFSET(off)     ((L4_TYPE_QW << QW_SHIFT) | (off))
+#define L4_TYPE_MATCH_OFFSET    L4_TYPE_OFFSET(L4_TYPE_BIT_OFFSET)
+#define L4_16B_TYPE_MASK        0xFFull
+#define L4_16B_ETH_VALUE        0x78ull
+
+/* 16B VESWID - for select */
+#define L4_16B_HDR_VESWID_OFFSET  ((2 << QW_SHIFT) | (16ull))
+/* 16B ENTROPY - for select */
+#define L2_16B_ENTROPY_OFFSET     ((1 << QW_SHIFT) | (32ull))
+
 /* defines to build power on SC2VL table */
 #define SC2VL_VAL( \
 	num, \
@@ -1047,6 +1075,7 @@ static int qos_rmt_entries(struct hfi1_devdata *dd, unsigned int *mp,
 			   unsigned int *np);
 static void clear_full_mgmt_pkey(struct hfi1_pportdata *ppd);
 static int wait_link_transfer_active(struct hfi1_devdata *dd, int wait_ms);
+static void clear_rsm_rule(struct hfi1_devdata *dd, u8 rule_index);
 
 /*
  * Error interrupt table entry.  This is used as input to the interrupt
@@ -6703,7 +6732,13 @@ static void rxe_kernel_unfreeze(struct hfi1_devdata *dd)
 	int i;
 
 	/* enable all kernel contexts */
-	for (i = 0; i < dd->n_krcv_queues; i++) {
+	for (i = 0; i < dd->num_rcv_contexts; i++) {
+		struct hfi1_ctxtdata *rcd = dd->rcd[i];
+
+		/* Ensure all non-user contexts(including vnic) are enabled */
+		if (!rcd || !rcd->sc || (rcd->sc->type == SC_USER))
+			continue;
+
 		rcvmask = HFI1_RCVCTRL_CTXT_ENB;
 		/* HFI1_RCVCTRL_TAILUPD_[ENB|DIS] needs to be set explicitly */
 		rcvmask |= HFI1_CAP_KGET_MASK(dd->rcd[i]->flags, DMA_RTAIL) ?
@@ -8000,7 +8035,9 @@ static void is_rcv_avail_int(struct hfi1_devdata *dd, unsigned int source)
 	if (likely(source < dd->num_rcv_contexts)) {
 		rcd = dd->rcd[source];
 		if (rcd) {
-			if (source < dd->first_user_ctxt)
+			/* Check for non-user contexts, including vnic */
+			if ((source < dd->first_dyn_alloc_ctxt) ||
+			    (rcd->sc && (rcd->sc->type == SC_KERNEL)))
 				rcd->do_interrupt(rcd, 0);
 			else
 				handle_user_interrupt(rcd);
@@ -8028,7 +8065,8 @@ static void is_rcv_urgent_int(struct hfi1_devdata *dd, unsigned int source)
 		rcd = dd->rcd[source];
 		if (rcd) {
 			/* only pay attention to user urgent interrupts */
-			if (source >= dd->first_user_ctxt)
+			if ((source >= dd->first_dyn_alloc_ctxt) &&
+			    (!rcd->sc || (rcd->sc->type == SC_USER)))
 				handle_user_interrupt(rcd);
 			return;	/* OK */
 		}
@@ -12842,7 +12880,10 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 	first_sdma = last_general;
 	last_sdma = first_sdma + dd->num_sdma;
 	first_rx = last_sdma;
-	last_rx = first_rx + dd->n_krcv_queues;
+	last_rx = first_rx + dd->n_krcv_queues + HFI1_NUM_VNIC_CTXT;
+
+	/* VNIC MSIx interrupts get mapped when VNIC contexts are created */
+	dd->first_dyn_msix_idx = first_rx + dd->n_krcv_queues;
 
 	/*
 	 * Sanity check - the code expects all SDMA chip source
@@ -12856,7 +12897,7 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 		const char *err_info;
 		irq_handler_t handler;
 		irq_handler_t thread = NULL;
-		void *arg;
+		void *arg = NULL;
 		int idx;
 		struct hfi1_ctxtdata *rcd = NULL;
 		struct sdma_engine *sde = NULL;
@@ -12883,24 +12924,25 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 		} else if (first_rx <= i && i < last_rx) {
 			idx = i - first_rx;
 			rcd = dd->rcd[idx];
-			/* no interrupt if no rcd */
-			if (!rcd)
-				continue;
-			/*
-			 * Set the interrupt register and mask for this
-			 * context's interrupt.
-			 */
-			rcd->ireg = (IS_RCVAVAIL_START + idx) / 64;
-			rcd->imask = ((u64)1) <<
-					((IS_RCVAVAIL_START + idx) % 64);
-			handler = receive_context_interrupt;
-			thread = receive_context_thread;
-			arg = rcd;
-			snprintf(me->name, sizeof(me->name),
-				 DRIVER_NAME "_%d kctxt%d", dd->unit, idx);
-			err_info = "receive context";
-			remap_intr(dd, IS_RCVAVAIL_START + idx, i);
-			me->type = IRQ_RCVCTXT;
+			if (rcd) {
+				/*
+				 * Set the interrupt register and mask for this
+				 * context's interrupt.
+				 */
+				rcd->ireg = (IS_RCVAVAIL_START + idx) / 64;
+				rcd->imask = ((u64)1) <<
+					  ((IS_RCVAVAIL_START + idx) % 64);
+				handler = receive_context_interrupt;
+				thread = receive_context_thread;
+				arg = rcd;
+				snprintf(me->name, sizeof(me->name),
+					 DRIVER_NAME "_%d kctxt%d",
+					 dd->unit, idx);
+				err_info = "receive context";
+				remap_intr(dd, IS_RCVAVAIL_START + idx, i);
+				me->type = IRQ_RCVCTXT;
+				rcd->msix_intr = i;
+			}
 		} else {
 			/* not in our expected range - complain, then
 			 * ignore it
@@ -12938,6 +12980,84 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 	return ret;
 }
 
+void hfi1_vnic_synchronize_irq(struct hfi1_devdata *dd)
+{
+	int i;
+
+	if (!dd->num_msix_entries) {
+		synchronize_irq(dd->pcidev->irq);
+		return;
+	}
+
+	for (i = 0; i < dd->vnic.num_ctxt; i++) {
+		struct hfi1_ctxtdata *rcd = dd->vnic.ctxt[i];
+		struct hfi1_msix_entry *me = &dd->msix_entries[rcd->msix_intr];
+
+		synchronize_irq(me->msix.vector);
+	}
+}
+
+void hfi1_reset_vnic_msix_info(struct hfi1_ctxtdata *rcd)
+{
+	struct hfi1_devdata *dd = rcd->dd;
+	struct hfi1_msix_entry *me = &dd->msix_entries[rcd->msix_intr];
+
+	if (!me->arg) /* => no irq, no affinity */
+		return;
+
+	hfi1_put_irq_affinity(dd, me);
+	free_irq(me->msix.vector, me->arg);
+
+	me->arg = NULL;
+}
+
+void hfi1_set_vnic_msix_info(struct hfi1_ctxtdata *rcd)
+{
+	struct hfi1_devdata *dd = rcd->dd;
+	struct hfi1_msix_entry *me;
+	int idx = rcd->ctxt;
+	void *arg = rcd;
+	int ret;
+
+	rcd->msix_intr = dd->vnic.msix_idx++;
+	me = &dd->msix_entries[rcd->msix_intr];
+
+	/*
+	 * Set the interrupt register and mask for this
+	 * context's interrupt.
+	 */
+	rcd->ireg = (IS_RCVAVAIL_START + idx) / 64;
+	rcd->imask = ((u64)1) <<
+		  ((IS_RCVAVAIL_START + idx) % 64);
+
+	snprintf(me->name, sizeof(me->name),
+		 DRIVER_NAME "_%d kctxt%d", dd->unit, idx);
+	me->name[sizeof(me->name) - 1] = 0;
+	me->type = IRQ_RCVCTXT;
+
+	remap_intr(dd, IS_RCVAVAIL_START + idx, rcd->msix_intr);
+
+	ret = request_threaded_irq(me->msix.vector, receive_context_interrupt,
+				   receive_context_thread, 0, me->name, arg);
+	if (ret) {
+		dd_dev_err(dd, "vnic irq request (vector %d, idx %d) fail %d\n",
+			   me->msix.vector, idx, ret);
+		return;
+	}
+	/*
+	 * assign arg after request_irq call, so it will be
+	 * cleaned up
+	 */
+	me->arg = arg;
+
+	ret = hfi1_get_irq_affinity(dd, me);
+	if (ret) {
+		dd_dev_err(dd,
+			   "unable to pin IRQ %d\n", ret);
+		free_irq(me->msix.vector, me->arg);
+	}
+}
+
 /*
  * Set the general handler to accept all interrupts, remap all
  * chip interrupts back to MSI-X 0.
@@ -12969,7 +13089,7 @@ static int set_up_interrupts(struct hfi1_devdata *dd)
 	 *	N interrupts - one per used SDMA engine
 	 *	M interrupt - one per kernel receive context
 	 */
-	total = 1 + dd->num_sdma + dd->n_krcv_queues;
+	total = 1 + dd->num_sdma + dd->n_krcv_queues + HFI1_NUM_VNIC_CTXT;
 
 	entries = kcalloc(total, sizeof(*entries), GFP_KERNEL);
 	if (!entries) {
@@ -13034,7 +13154,8 @@ static int set_up_interrupts(struct hfi1_devdata *dd)
  *
  *	num_rcv_contexts - number of contexts being used
  *	n_krcv_queues - number of kernel contexts
- *	first_user_ctxt - first non-kernel context in array of contexts
+ *	first_dyn_alloc_ctxt - first dynamically allocated context
+ *                             in array of contexts
  *	freectxts  - number of free user contexts
  *	num_send_contexts - number of PIO send contexts being used
  */
@@ -13111,10 +13232,14 @@ static int set_up_context_variables(struct hfi1_devdata *dd)
 		total_contexts = num_kernel_contexts + num_user_contexts;
 	}
 
-	/* the first N are kernel contexts, the rest are user contexts */
+	/* Accommodate VNIC contexts */
+	if ((total_contexts + HFI1_NUM_VNIC_CTXT) <= dd->chip_rcv_contexts)
+		total_contexts += HFI1_NUM_VNIC_CTXT;
+
+	/* the first N are kernel contexts, the rest are user/vnic contexts */
 	dd->num_rcv_contexts = total_contexts;
 	dd->n_krcv_queues = num_kernel_contexts;
-	dd->first_user_ctxt = num_kernel_contexts;
+	dd->first_dyn_alloc_ctxt = num_kernel_contexts;
 	dd->num_user_contexts = num_user_contexts;
 	dd->freectxts = num_user_contexts;
 	dd_dev_info(dd,
@@ -13570,11 +13695,8 @@ static void reset_rxe_csrs(struct hfi1_devdata *dd)
 		write_csr(dd, RCV_COUNTER_ARRAY32 + (8 * i), 0);
 	for (i = 0; i < RXE_NUM_64_BIT_COUNTERS; i++)
 		write_csr(dd, RCV_COUNTER_ARRAY64 + (8 * i), 0);
-	for (i = 0; i < RXE_NUM_RSM_INSTANCES; i++) {
-		write_csr(dd, RCV_RSM_CFG + (8 * i), 0);
-		write_csr(dd, RCV_RSM_SELECT + (8 * i), 0);
-		write_csr(dd, RCV_RSM_MATCH + (8 * i), 0);
-	}
+	for (i = 0; i < RXE_NUM_RSM_INSTANCES; i++)
+		clear_rsm_rule(dd, i);
 	for (i = 0; i < 32; i++)
 		write_csr(dd, RCV_RSM_MAP_TABLE + (8 * i), 0);
 
@@ -13933,6 +14055,16 @@ static void add_rsm_rule(struct hfi1_devdata *dd, u8 rule_index,
 		  (u64)rrd->value2 << RCV_RSM_MATCH_VALUE2_SHIFT);
 }
 
+/*
+ * Clear a receive side mapping rule.
+ */
+static void clear_rsm_rule(struct hfi1_devdata *dd, u8 rule_index)
+{
+	write_csr(dd, RCV_RSM_CFG + (8 * rule_index), 0);
+	write_csr(dd, RCV_RSM_SELECT + (8 * rule_index), 0);
+	write_csr(dd, RCV_RSM_MATCH + (8 * rule_index), 0);
+}
+
 /* return the number of RSM map table entries that will be used for QOS */
 static int qos_rmt_entries(struct hfi1_devdata *dd, unsigned int *mp,
 			   unsigned int *np)
@@ -14048,7 +14180,7 @@ static void init_qos(struct hfi1_devdata *dd, struct rsm_map_table *rmt)
 	rrd.value2 = LRH_SC_VALUE;
 
 	/* add rule 0 */
-	add_rsm_rule(dd, 0, &rrd);
+	add_rsm_rule(dd, RSM_INS_VERBS, &rrd);
 
 	/* mark RSM map entries as used */
 	rmt->used += rmt_entries;
@@ -14078,7 +14210,7 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
 	/*
 	 * RSM will extract the destination context as an index into the
 	 * map table.  The destination contexts are a sequential block
-	 * in the range first_user_ctxt...num_rcv_contexts-1 (inclusive).
+	 * in the range first_dyn_alloc_ctxt...num_rcv_contexts-1 (inclusive).
 	 * Map entries are accessed as offset + extracted value.  Adjust
 	 * the added offset so this sequence can be placed anywhere in
 	 * the table - as long as the entries themselves do not wrap.
@@ -14086,9 +14218,9 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
 	 * start with that to allow for a "negative" offset.
 	 */
 	offset = (u8)(NUM_MAP_ENTRIES + (int)rmt->used -
-						(int)dd->first_user_ctxt);
+						(int)dd->first_dyn_alloc_ctxt);
 
-	for (i = dd->first_user_ctxt, idx = rmt->used;
+	for (i = dd->first_dyn_alloc_ctxt, idx = rmt->used;
 				i < dd->num_rcv_contexts; i++, idx++) {
 		/* replace with identity mapping */
 		regoff = (idx % 8) * 8;
@@ -14122,11 +14254,84 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
 	rrd.value2 = 1;
 
 	/* add rule 1 */
-	add_rsm_rule(dd, 1, &rrd);
+	add_rsm_rule(dd, RSM_INS_FECN, &rrd);
 
 	rmt->used += dd->num_user_contexts;
 }
 
+/* Initialize RSM for VNIC */
+void hfi1_init_vnic_rsm(struct hfi1_devdata *dd)
+{
+	u8 i, j;
+	u8 ctx_id = 0;
+	u64 reg;
+	u32 regoff;
+	struct rsm_rule_data rrd;
+
+	if (hfi1_vnic_is_rsm_full(dd, NUM_VNIC_MAP_ENTRIES)) {
+		dd_dev_err(dd, "Vnic RSM disabled, rmt entries used = %d\n",
+			   dd->vnic.rmt_start);
+		return;
+	}
+
+	dev_dbg(&(dd)->pcidev->dev, "Vnic rsm start = %d, end %d\n",
+		dd->vnic.rmt_start,
+		dd->vnic.rmt_start + NUM_VNIC_MAP_ENTRIES);
+
+	/* Update RSM mapping table, 32 regs, 256 entries - 1 ctx per byte */
+	regoff = RCV_RSM_MAP_TABLE + (dd->vnic.rmt_start / 8) * 8;
+	reg = read_csr(dd, regoff);
+	for (i = 0; i < NUM_VNIC_MAP_ENTRIES; i++) {
+		/* Update map register with vnic context */
+		j = (dd->vnic.rmt_start + i) % 8;
+		reg &= ~(0xffllu << (j * 8));
+		reg |= (u64)dd->vnic.ctxt[ctx_id++]->ctxt << (j * 8);
+		/* Wrap up vnic ctx index */
+		ctx_id %= dd->vnic.num_ctxt;
+		/* Write back map register */
+		if (j == 7 || ((i + 1) == NUM_VNIC_MAP_ENTRIES)) {
+			dev_dbg(&(dd)->pcidev->dev,
+				"Vnic rsm map reg[%d] =0x%llx\n",
+				regoff - RCV_RSM_MAP_TABLE, reg);
+
+			write_csr(dd, regoff, reg);
+			regoff += 8;
+			if (i < (NUM_VNIC_MAP_ENTRIES - 1))
+				reg = read_csr(dd, regoff);
+		}
+	}
+
+	/* Add rule for vnic */
+	rrd.offset = dd->vnic.rmt_start;
+	rrd.pkt_type = 4;
+	/* Match 16B packets */
+	rrd.field1_off = L2_TYPE_MATCH_OFFSET;
+	rrd.mask1 = L2_TYPE_MASK;
+	rrd.value1 = L2_16B_VALUE;
+	/* Match ETH L4 packets */
+	rrd.field2_off = L4_TYPE_MATCH_OFFSET;
+	rrd.mask2 = L4_16B_TYPE_MASK;
+	rrd.value2 = L4_16B_ETH_VALUE;
+	/* Calc context from veswid and entropy */
+	rrd.index1_off = L4_16B_HDR_VESWID_OFFSET;
+	rrd.index1_width = ilog2(NUM_VNIC_MAP_ENTRIES);
+	rrd.index2_off = L2_16B_ENTROPY_OFFSET;
+	rrd.index2_width = ilog2(NUM_VNIC_MAP_ENTRIES);
+	add_rsm_rule(dd, RSM_INS_VNIC, &rrd);
+
+	/* Enable RSM if not already enabled */
+	add_rcvctrl(dd, RCV_CTRL_RCV_RSM_ENABLE_SMASK);
+}
+
+void hfi1_deinit_vnic_rsm(struct hfi1_devdata *dd)
+{
+	clear_rsm_rule(dd, RSM_INS_VNIC);
+
+	/* Disable RSM if used only by vnic */
+	if (dd->vnic.rmt_start == 0)
+		clear_rcvctrl(dd, RCV_CTRL_RCV_RSM_ENABLE_SMASK);
+}
+
 static void init_rxe(struct hfi1_devdata *dd)
 {
 	struct rsm_map_table *rmt;
@@ -14139,6 +14344,8 @@ static void init_rxe(struct hfi1_devdata *dd)
 	init_qos(dd, rmt);
 	init_user_fecn_handling(dd, rmt);
 	complete_rsm_map_table(dd, rmt);
+	/* record number of used rsm map entries for vnic */
+	dd->vnic.rmt_start = rmt->used;
 	kfree(rmt);
 
 	/*
diff --git a/drivers/infiniband/hw/hfi1/chip.h b/drivers/infiniband/hw/hfi1/chip.h
index 24df45f..b9dbf16 100644
--- a/drivers/infiniband/hw/hfi1/chip.h
+++ b/drivers/infiniband/hw/hfi1/chip.h
@@ -1362,6 +1362,8 @@ void hfi1_put_tid(struct hfi1_devdata *dd, u32 index,
 int hfi1_set_ctxt_pkey(struct hfi1_devdata *dd, unsigned ctxt, u16 pkey);
 int hfi1_clear_ctxt_pkey(struct hfi1_devdata *dd, unsigned ctxt);
 void hfi1_read_link_quality(struct hfi1_devdata *dd, u8 *link_quality);
+void hfi1_init_vnic_rsm(struct hfi1_devdata *dd);
+void hfi1_deinit_vnic_rsm(struct hfi1_devdata *dd);
 
 /*
  * Interrupt source table.
diff --git a/drivers/infiniband/hw/hfi1/debugfs.c b/drivers/infiniband/hw/hfi1/debugfs.c
index dc2c1c9..5da0375 100644
--- a/drivers/infiniband/hw/hfi1/debugfs.c
+++ b/drivers/infiniband/hw/hfi1/debugfs.c
@@ -1,6 +1,6 @@
 #ifdef CONFIG_DEBUG_FS
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -174,7 +174,7 @@ static int _opcode_stats_seq_show(struct seq_file *s, void *v)
 	struct hfi1_ibdev *ibd = (struct hfi1_ibdev *)s->private;
 	struct hfi1_devdata *dd = dd_from_dev(ibd);
 
-	for (j = 0; j < dd->first_user_ctxt; j++) {
+	for (j = 0; j < dd->first_dyn_alloc_ctxt; j++) {
 		if (!dd->rcd[j])
 			continue;
 		n_packets += dd->rcd[j]->opstats->stats[i].n_packets;
@@ -200,7 +200,7 @@ static void *_ctx_stats_seq_start(struct seq_file *s, loff_t *pos)
 
 	if (!*pos)
 		return SEQ_START_TOKEN;
-	if (*pos >= dd->first_user_ctxt)
+	if (*pos >= dd->first_dyn_alloc_ctxt)
 		return NULL;
 	return pos;
 }
@@ -214,7 +214,7 @@ static void *_ctx_stats_seq_next(struct seq_file *s, void *v, loff_t *pos)
 		return pos;
 
 	++*pos;
-	if (*pos >= dd->first_user_ctxt)
+	if (*pos >= dd->first_dyn_alloc_ctxt)
 		return NULL;
 	return pos;
 }
diff --git a/drivers/infiniband/hw/hfi1/driver.c b/drivers/infiniband/hw/hfi1/driver.c
index e4dc6a5..6b38695 100644
--- a/drivers/infiniband/hw/hfi1/driver.c
+++ b/drivers/infiniband/hw/hfi1/driver.c
@@ -874,20 +874,42 @@ int handle_receive_interrupt_dma_rtail(struct hfi1_ctxtdata *rcd, int thread)
 	return last;
 }
 
-static inline void set_all_nodma_rtail(struct hfi1_devdata *dd)
+static inline void set_nodma_rtail(struct hfi1_devdata *dd, u8 ctxt)
 {
 	int i;
 
-	for (i = HFI1_CTRL_CTXT + 1; i < dd->first_user_ctxt; i++)
+	/*
+	 * For dynamically allocated kernel contexts (like vnic) switch
+	 * interrupt handler only for that context. Otherwise, switch
+	 * interrupt handler for all statically allocated kernel contexts.
+	 */
+	if (ctxt >= dd->first_dyn_alloc_ctxt) {
+		dd->rcd[ctxt]->do_interrupt =
+			&handle_receive_interrupt_nodma_rtail;
+		return;
+	}
+
+	for (i = HFI1_CTRL_CTXT + 1; i < dd->first_dyn_alloc_ctxt; i++)
 		dd->rcd[i]->do_interrupt =
 			&handle_receive_interrupt_nodma_rtail;
 }
 
-static inline void set_all_dma_rtail(struct hfi1_devdata *dd)
+static inline void set_dma_rtail(struct hfi1_devdata *dd, u8 ctxt)
 {
 	int i;
 
-	for (i = HFI1_CTRL_CTXT + 1; i < dd->first_user_ctxt; i++)
+	/*
+	 * For dynamically allocated kernel contexts (like vnic) switch
+	 * interrupt handler only for that context. Otherwise, switch
+	 * interrupt handler for all statically allocated kernel contexts.
+	 */
+	if (ctxt >= dd->first_dyn_alloc_ctxt) {
+		dd->rcd[ctxt]->do_interrupt =
+			&handle_receive_interrupt_dma_rtail;
+		return;
+	}
+
+	for (i = HFI1_CTRL_CTXT + 1; i < dd->first_dyn_alloc_ctxt; i++)
 		dd->rcd[i]->do_interrupt =
 			&handle_receive_interrupt_dma_rtail;
 }
@@ -897,8 +919,13 @@ void set_all_slowpath(struct hfi1_devdata *dd)
 	int i;
 
 	/* HFI1_CTRL_CTXT must always use the slow path interrupt handler */
-	for (i = HFI1_CTRL_CTXT + 1; i < dd->first_user_ctxt; i++)
-		dd->rcd[i]->do_interrupt = &handle_receive_interrupt;
+	for (i = HFI1_CTRL_CTXT + 1; i < dd->num_rcv_contexts; i++) {
+		struct hfi1_ctxtdata *rcd = dd->rcd[i];
+
+		if ((i < dd->first_dyn_alloc_ctxt) ||
+		    (rcd && rcd->sc && (rcd->sc->type == SC_KERNEL)))
+			rcd->do_interrupt = &handle_receive_interrupt;
+	}
 }
 
 static inline int set_armed_to_active(struct hfi1_ctxtdata *rcd,
@@ -1008,7 +1035,7 @@ int handle_receive_interrupt(struct hfi1_ctxtdata *rcd, int thread)
 				last = RCV_PKT_DONE;
 			if (needset) {
 				dd_dev_info(dd, "Switching to NO_DMA_RTAIL\n");
-				set_all_nodma_rtail(dd);
+				set_nodma_rtail(dd, rcd->ctxt);
 				needset = 0;
 			}
 		} else {
@@ -1030,7 +1057,7 @@ int handle_receive_interrupt(struct hfi1_ctxtdata *rcd, int thread)
 			if (needset) {
 				dd_dev_info(dd,
 					    "Switching to DMA_RTAIL\n");
-				set_all_dma_rtail(dd);
+				set_dma_rtail(dd, rcd->ctxt);
 				needset = 0;
 			}
 		}
@@ -1079,10 +1106,10 @@ void receive_interrupt_work(struct work_struct *work)
 	set_link_state(ppd, HLS_UP_ACTIVE);
 
 	/*
-	 * Interrupt all kernel contexts that could have had an
-	 * interrupt during auto activation.
+	 * Interrupt all statically allocated kernel contexts that could
+	 * have had an interrupt during auto activation.
 	 */
-	for (i = HFI1_CTRL_CTXT; i < dd->first_user_ctxt; i++)
+	for (i = HFI1_CTRL_CTXT; i < dd->first_dyn_alloc_ctxt; i++)
 		force_recv_intr(dd->rcd[i]);
 }
 
@@ -1296,7 +1323,8 @@ int hfi1_reset_device(int unit)
 
 	spin_lock_irqsave(&dd->uctxt_lock, flags);
 	if (dd->rcd)
-		for (i = dd->first_user_ctxt; i < dd->num_rcv_contexts; i++) {
+		for (i = dd->first_dyn_alloc_ctxt;
+		     i < dd->num_rcv_contexts; i++) {
 			if (!dd->rcd[i] || !dd->rcd[i]->cnt)
 				continue;
 			spin_unlock_irqrestore(&dd->uctxt_lock, flags);
diff --git a/drivers/infiniband/hw/hfi1/file_ops.c b/drivers/infiniband/hw/hfi1/file_ops.c
index f78c739..6059886 100644
--- a/drivers/infiniband/hw/hfi1/file_ops.c
+++ b/drivers/infiniband/hw/hfi1/file_ops.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -586,8 +586,8 @@ static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma)
 		 * knows where it's own bitmap is within the page.
 		 */
 		memaddr = (unsigned long)(dd->events +
-					  ((uctxt->ctxt - dd->first_user_ctxt) *
-					   HFI1_MAX_SHARED_CTXTS)) & PAGE_MASK;
+				  ((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
+				   HFI1_MAX_SHARED_CTXTS)) & PAGE_MASK;
 		memlen = PAGE_SIZE;
 		/*
 		 * v3.7 removes VM_RESERVED but the effect is kept by
@@ -756,7 +756,7 @@ static int hfi1_file_close(struct inode *inode, struct file *fp)
 	 * Clear any left over, unhandled events so the next process that
 	 * gets this context doesn't get confused.
 	 */
-	ev = dd->events + ((uctxt->ctxt - dd->first_user_ctxt) *
+	ev = dd->events + ((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 			   HFI1_MAX_SHARED_CTXTS) + fdata->subctxt;
 	*ev = 0;
 
@@ -909,12 +909,18 @@ static int find_shared_ctxt(struct file *fp,
 
 		if (!(dd && (dd->flags & HFI1_PRESENT) && dd->kregbase))
 			continue;
-		for (i = dd->first_user_ctxt; i < dd->num_rcv_contexts; i++) {
+		for (i = dd->first_dyn_alloc_ctxt;
+		     i < dd->num_rcv_contexts; i++) {
 			struct hfi1_ctxtdata *uctxt = dd->rcd[i];
 
 			/* Skip ctxts which are not yet open */
 			if (!uctxt || !uctxt->cnt)
 				continue;
+
+			/* Skip dynamically allocted kernel contexts */
+			if (uctxt->sc && (uctxt->sc->type == SC_KERNEL))
+				continue;
+
 			/* Skip ctxt if it doesn't match the requested one */
 			if (memcmp(uctxt->uuid, uinfo->uuid,
 				   sizeof(uctxt->uuid)) ||
@@ -960,7 +966,8 @@ static int allocate_ctxt(struct file *fp, struct hfi1_devdata *dd,
 		return -EIO;
 	}
 
-	for (ctxt = dd->first_user_ctxt; ctxt < dd->num_rcv_contexts; ctxt++)
+	for (ctxt = dd->first_dyn_alloc_ctxt;
+	     ctxt < dd->num_rcv_contexts; ctxt++)
 		if (!dd->rcd[ctxt])
 			break;
 
@@ -1306,7 +1313,7 @@ static int get_base_info(struct file *fp, void __user *ubase, __u32 len)
 	 */
 	binfo.user_regbase = HFI1_MMAP_TOKEN(UREGS, uctxt->ctxt,
 					    fd->subctxt, 0);
-	offset = offset_in_page((((uctxt->ctxt - dd->first_user_ctxt) *
+	offset = offset_in_page((((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 		    HFI1_MAX_SHARED_CTXTS) + fd->subctxt) *
 		  sizeof(*dd->events));
 	binfo.events_bufbase = HFI1_MMAP_TOKEN(EVENTS, uctxt->ctxt,
@@ -1400,12 +1407,12 @@ int hfi1_set_uevent_bits(struct hfi1_pportdata *ppd, const int evtbit)
 	}
 
 	spin_lock_irqsave(&dd->uctxt_lock, flags);
-	for (ctxt = dd->first_user_ctxt; ctxt < dd->num_rcv_contexts;
+	for (ctxt = dd->first_dyn_alloc_ctxt; ctxt < dd->num_rcv_contexts;
 	     ctxt++) {
 		uctxt = dd->rcd[ctxt];
 		if (uctxt) {
 			unsigned long *evs = dd->events +
-				(uctxt->ctxt - dd->first_user_ctxt) *
+				(uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 				HFI1_MAX_SHARED_CTXTS;
 			int i;
 			/*
@@ -1477,7 +1484,7 @@ static int user_event_ack(struct hfi1_ctxtdata *uctxt, int subctxt,
 	if (!dd->events)
 		return 0;
 
-	evs = dd->events + ((uctxt->ctxt - dd->first_user_ctxt) *
+	evs = dd->events + ((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 			    HFI1_MAX_SHARED_CTXTS) + subctxt;
 
 	for (i = 0; i <= _HFI1_MAX_EVENT_BIT; i++) {
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index f85e8f4..a12bb46 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -54,6 +54,7 @@
 #include <linux/list.h>
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
+#include <linux/idr.h>
 #include <linux/io.h>
 #include <linux/fs.h>
 #include <linux/completion.h>
@@ -66,6 +67,7 @@
 #include <linux/i2c-algo-bit.h>
 #include <rdma/ib_hdrs.h>
 #include <linux/rhashtable.h>
+#include <linux/netdevice.h>
 #include <rdma/rdma_vt.h>
 
 #include "chip_registers.h"
@@ -278,6 +280,8 @@ struct hfi1_ctxtdata {
 	struct hfi1_devdata *dd;
 	/* so functions that need physical port can get it easily */
 	struct hfi1_pportdata *ppd;
+	/* associated msix interrupt */
+	u32 msix_intr;
 	/* A page of memory for rcvhdrhead, rcvegrhead, rcvegrtail * N */
 	void *subctxt_uregbase;
 	/* An array of pages for the eager receive buffers * N */
@@ -814,15 +818,27 @@ struct hfi1_asic_data {
 	struct hfi1_i2c_bus *i2c_bus1;
 };
 
+/* sizes for both the QP and RSM map tables */
+#define NUM_MAP_ENTRIES	 256
+#define NUM_MAP_REGS      32
+
 /*
  * Number of VNIC contexts used. Ensure it is less than or equal to
  * max queues supported by VNIC (HFI1_VNIC_MAX_QUEUE).
  */
 #define HFI1_NUM_VNIC_CTXT   8
 
+/* Number of VNIC RSM entries */
+#define NUM_VNIC_MAP_ENTRIES 8
+
 /* Virtual NIC information */
 struct hfi1_vnic_data {
+	struct hfi1_ctxtdata *ctxt[HFI1_NUM_VNIC_CTXT];
+	u8 num_vports;
 	struct idr vesw_idr;
+	u8 rmt_start;
+	u8 num_ctxt;
+	u32 msix_idx;
 };
 
 struct hfi1_vnic_vport_info;
@@ -1050,6 +1066,7 @@ struct hfi1_devdata {
 	/* MSI-X information */
 	struct hfi1_msix_entry *msix_entries;
 	u32 num_msix_entries;
+	u32 first_dyn_msix_idx;
 
 	/* INTx information */
 	u32 requested_intx_irq;		/* did we request one? */
@@ -1148,8 +1165,8 @@ struct hfi1_devdata {
 	u16 flags;
 	/* Number of physical ports available */
 	u8 num_pports;
-	/* Lowest context number which can be used by user processes */
-	u8 first_user_ctxt;
+	/* Lowest context number which can be used by user processes or VNIC */
+	u8 first_dyn_alloc_ctxt;
 	/* adding a new field here would make it part of this cacheline */
 
 	/* seqlock for sc2vl */
@@ -1197,6 +1214,11 @@ struct hfi1_devdata {
 	struct hfi1_vnic_data vnic;
 };
 
+static inline bool hfi1_vnic_is_rsm_full(struct hfi1_devdata *dd, int spare)
+{
+	return (dd->vnic.rmt_start + spare) > NUM_MAP_ENTRIES;
+}
+
 /* 8051 firmware version helper */
 #define dc8051_ver(a, b, c) ((a) << 16 | (b) << 8 | (c))
 #define dc8051_ver_maj(a) (((a) & 0xff0000) >> 16)
@@ -1261,6 +1283,9 @@ void hfi1_init_pportdata(struct pci_dev *, struct hfi1_pportdata *,
 int handle_receive_interrupt_nodma_rtail(struct hfi1_ctxtdata *, int);
 int handle_receive_interrupt_dma_rtail(struct hfi1_ctxtdata *, int);
 void set_all_slowpath(struct hfi1_devdata *dd);
+void hfi1_vnic_synchronize_irq(struct hfi1_devdata *dd);
+void hfi1_set_vnic_msix_info(struct hfi1_ctxtdata *rcd);
+void hfi1_reset_vnic_msix_info(struct hfi1_ctxtdata *rcd);
 
 extern const struct pci_device_id hfi1_pci_tbl[];
 
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index e84f95d..de2eec4 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -140,7 +140,7 @@ int hfi1_create_ctxts(struct hfi1_devdata *dd)
 		goto nomem;
 
 	/* create one or more kernel contexts */
-	for (i = 0; i < dd->first_user_ctxt; ++i) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; ++i) {
 		struct hfi1_pportdata *ppd;
 		struct hfi1_ctxtdata *rcd;
 
@@ -215,9 +215,9 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 	u32 base;
 
 	if (dd->rcv_entries.nctxt_extra >
-	    dd->num_rcv_contexts - dd->first_user_ctxt)
+	    dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt)
 		kctxt_ngroups = (dd->rcv_entries.nctxt_extra -
-				 (dd->num_rcv_contexts - dd->first_user_ctxt));
+			 (dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt));
 	rcd = kzalloc_node(sizeof(*rcd), GFP_KERNEL, numa);
 	if (rcd) {
 		u32 rcvtids, max_entries;
@@ -239,10 +239,10 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 		 * Calculate the context's RcvArray entry starting point.
 		 * We do this here because we have to take into account all
 		 * the RcvArray entries that previous context would have
-		 * taken and we have to account for any extra groups
-		 * assigned to the kernel or user contexts.
+		 * taken and we have to account for any extra groups assigned
+		 * to the static (kernel) or dynamic (vnic/user) contexts.
 		 */
-		if (ctxt < dd->first_user_ctxt) {
+		if (ctxt < dd->first_dyn_alloc_ctxt) {
 			if (ctxt < kctxt_ngroups) {
 				base = ctxt * (dd->rcv_entries.ngroups + 1);
 				rcd->rcv_array_groups++;
@@ -250,7 +250,7 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 				base = kctxt_ngroups +
 					(ctxt * dd->rcv_entries.ngroups);
 		} else {
-			u16 ct = ctxt - dd->first_user_ctxt;
+			u16 ct = ctxt - dd->first_dyn_alloc_ctxt;
 
 			base = ((dd->n_krcv_queues * dd->rcv_entries.ngroups) +
 				kctxt_ngroups);
@@ -323,7 +323,8 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 		}
 		rcd->egrbufs.rcvtid_size = HFI1_MAX_EAGER_BUFFER_SIZE;
 
-		if (ctxt < dd->first_user_ctxt) { /* N/A for PSM contexts */
+		/* Applicable only for statically created kernel contexts */
+		if (ctxt < dd->first_dyn_alloc_ctxt) {
 			rcd->opstats = kzalloc_node(sizeof(*rcd->opstats),
 						    GFP_KERNEL, numa);
 			if (!rcd->opstats)
@@ -586,7 +587,7 @@ static void enable_chip(struct hfi1_devdata *dd)
 	 * Enable kernel ctxts' receive and receive interrupt.
 	 * Other ctxts done as user opens and initializes them.
 	 */
-	for (i = 0; i < dd->first_user_ctxt; ++i) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; ++i) {
 		rcvmask = HFI1_RCVCTRL_CTXT_ENB | HFI1_RCVCTRL_INTRAVAIL_ENB;
 		rcvmask |= HFI1_CAP_KGET_MASK(dd->rcd[i]->flags, DMA_RTAIL) ?
 			HFI1_RCVCTRL_TAILUPD_ENB : HFI1_RCVCTRL_TAILUPD_DIS;
@@ -715,7 +716,7 @@ int hfi1_init(struct hfi1_devdata *dd, int reinit)
 	}
 
 	/* dd->rcd can be NULL if early initialization failed */
-	for (i = 0; dd->rcd && i < dd->first_user_ctxt; ++i) {
+	for (i = 0; dd->rcd && i < dd->first_dyn_alloc_ctxt; ++i) {
 		/*
 		 * Set up the (kernel) rcvhdr queue and egr TIDs.  If doing
 		 * re-init, the simplest way to handle this is to free
@@ -1535,6 +1536,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			hfi1_device_remove(dd);
 		if (!ret)
 			hfi1_unregister_ib_device(dd);
+		hfi1_vnic_cleanup(dd);
 		postinit_cleanup(dd);
 		if (initfail)
 			ret = initfail;
@@ -1621,8 +1623,11 @@ int hfi1_create_rcvhdrq(struct hfi1_devdata *dd, struct hfi1_ctxtdata *rcd)
 		amt = PAGE_ALIGN(rcd->rcvhdrq_cnt * rcd->rcvhdrqentsize *
 				 sizeof(u32));
 
-		gfp_flags = (rcd->ctxt >= dd->first_user_ctxt) ?
-			GFP_USER : GFP_KERNEL;
+		if ((rcd->ctxt < dd->first_dyn_alloc_ctxt) ||
+		    (rcd->sc && (rcd->sc->type == SC_KERNEL)))
+			gfp_flags = GFP_KERNEL;
+		else
+			gfp_flags = GFP_USER;
 		rcd->rcvhdrq = dma_zalloc_coherent(
 			&dd->pcidev->dev, amt, &rcd->rcvhdrq_dma,
 			gfp_flags | __GFP_COMP);
diff --git a/drivers/infiniband/hw/hfi1/mad.c b/drivers/infiniband/hw/hfi1/mad.c
index 09cda3c..955e5fc 100644
--- a/drivers/infiniband/hw/hfi1/mad.c
+++ b/drivers/infiniband/hw/hfi1/mad.c
@@ -53,6 +53,7 @@
 #include "mad.h"
 #include "trace.h"
 #include "qp.h"
+#include "vnic.h"
 
 /* the reset value from the FM is supposed to be 0xffff, handle both */
 #define OPA_LINK_WIDTH_RESET_OLD 0x0fff
@@ -650,9 +651,11 @@ static int __subn_get_opa_portinfo(struct opa_smp *smp, u32 am, u8 *data,
 					OPA_PI_MASK_PORT_ACTIVE_OPTOMIZE : 0);
 
 	pi->port_packet_format.supported =
-		cpu_to_be16(OPA_PORT_PACKET_FORMAT_9B);
+		cpu_to_be16(OPA_PORT_PACKET_FORMAT_9B |
+			    OPA_PORT_PACKET_FORMAT_16B);
 	pi->port_packet_format.enabled =
-		cpu_to_be16(OPA_PORT_PACKET_FORMAT_9B);
+		cpu_to_be16(OPA_PORT_PACKET_FORMAT_9B |
+			    OPA_PORT_PACKET_FORMAT_16B);
 
 	/* flit_control.interleave is (OPA V1, version .76):
 	 * bits		use
@@ -701,7 +704,8 @@ static int __subn_get_opa_portinfo(struct opa_smp *smp, u32 am, u8 *data,
 	buffer_units |= (dd->vl15_init << 11) & OPA_PI_MASK_BUF_UNIT_VL15_INIT;
 	pi->buffer_units = cpu_to_be32(buffer_units);
 
-	pi->opa_cap_mask = cpu_to_be16(OPA_CAP_MASK3_IsSharedSpaceSupported);
+	pi->opa_cap_mask = cpu_to_be16(OPA_CAP_MASK3_IsSharedSpaceSupported |
+				       OPA_CAP_MASK3_IsEthOnFabricSupported);
 
 	/* HFI supports a replay buffer 128 LTPs in size */
 	pi->replay_depth.buffer = 0x80;
diff --git a/drivers/infiniband/hw/hfi1/pio.c b/drivers/infiniband/hw/hfi1/pio.c
index 615be68..ed72b5a 100644
--- a/drivers/infiniband/hw/hfi1/pio.c
+++ b/drivers/infiniband/hw/hfi1/pio.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -703,6 +703,7 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
 {
 	struct send_context_info *sci;
 	struct send_context *sc = NULL;
+	int req_type = type;
 	dma_addr_t dma;
 	unsigned long flags;
 	u64 reg;
@@ -729,6 +730,13 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
 		return NULL;
 	}
 
+	/*
+	 * VNIC contexts are dynamically allocated.
+	 * Hence, pick a user context for VNIC.
+	 */
+	if (type == SC_VNIC)
+		type = SC_USER;
+
 	spin_lock_irqsave(&dd->sc_lock, flags);
 	ret = sc_hw_alloc(dd, type, &sw_index, &hw_context);
 	if (ret) {
@@ -738,6 +746,15 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
 		return NULL;
 	}
 
+	/*
+	 * VNIC contexts are used by kernel driver.
+	 * Hence, mark them as kernel contexts.
+	 */
+	if (req_type == SC_VNIC) {
+		dd->send_contexts[sw_index].type = SC_KERNEL;
+		type = SC_KERNEL;
+	}
+
 	sci = &dd->send_contexts[sw_index];
 	sci->sc = sc;
 
diff --git a/drivers/infiniband/hw/hfi1/pio.h b/drivers/infiniband/hw/hfi1/pio.h
index 867e5ff..a6fb700 100644
--- a/drivers/infiniband/hw/hfi1/pio.h
+++ b/drivers/infiniband/hw/hfi1/pio.h
@@ -1,7 +1,7 @@
 #ifndef _PIO_H
 #define _PIO_H
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -54,6 +54,12 @@
 #define SC_USER   3	/* must be the last one: it may take all left */
 #define SC_MAX    4	/* count of send context types */
 
+/*
+ * SC_VNIC types are allocated (dynamically) from the user context pool,
+ * (SC_USER) and used by kernel driver as kernel contexts (SC_KERNEL).
+ */
+#define SC_VNIC   SC_MAX
+
 /* invalid send context index */
 #define INVALID_SCI 0xff
 
diff --git a/drivers/infiniband/hw/hfi1/sysfs.c b/drivers/infiniband/hw/hfi1/sysfs.c
index 919a547..50d140d 100644
--- a/drivers/infiniband/hw/hfi1/sysfs.c
+++ b/drivers/infiniband/hw/hfi1/sysfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -542,7 +542,7 @@ static ssize_t show_nctxts(struct device *device,
 	 * give a more accurate picture of total contexts available.
 	 */
 	return scnprintf(buf, PAGE_SIZE, "%u\n",
-			 min(dd->num_rcv_contexts - dd->first_user_ctxt,
+			 min(dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt,
 			     (u32)dd->sc_sizes[SC_USER].count));
 }
 
diff --git a/drivers/infiniband/hw/hfi1/user_exp_rcv.c b/drivers/infiniband/hw/hfi1/user_exp_rcv.c
index 4a82953..25a8698 100644
--- a/drivers/infiniband/hw/hfi1/user_exp_rcv.c
+++ b/drivers/infiniband/hw/hfi1/user_exp_rcv.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -607,7 +607,7 @@ int hfi1_user_exp_rcv_invalid(struct file *fp, struct hfi1_tid_info *tinfo)
 	struct hfi1_filedata *fd = fp->private_data;
 	struct hfi1_ctxtdata *uctxt = fd->uctxt;
 	unsigned long *ev = uctxt->dd->events +
-		(((uctxt->ctxt - uctxt->dd->first_user_ctxt) *
+		(((uctxt->ctxt - uctxt->dd->first_dyn_alloc_ctxt) *
 		  HFI1_MAX_SHARED_CTXTS) + fd->subctxt);
 	u32 *array;
 	int ret = 0;
@@ -1011,8 +1011,8 @@ static int tid_rb_invalidate(void *arg, struct mmu_rb_node *mnode)
 			 * process in question.
 			 */
 			ev = uctxt->dd->events +
-				(((uctxt->ctxt - uctxt->dd->first_user_ctxt) *
-				  HFI1_MAX_SHARED_CTXTS) + fdata->subctxt);
+			  (((uctxt->ctxt - uctxt->dd->first_dyn_alloc_ctxt) *
+			    HFI1_MAX_SHARED_CTXTS) + fdata->subctxt);
 			set_bit(_HFI1_EVENT_TID_MMU_NOTIFY_BIT, ev);
 		}
 		fdata->invalid_tid_idx++;
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 68295a1..e341e6d 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -73,7 +73,8 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 {
 	unsigned long ulimit = rlimit(RLIMIT_MEMLOCK), pinned, cache_limit,
 		size = (cache_size * (1UL << 20)); /* convert to bytes */
-	unsigned usr_ctxts = dd->num_rcv_contexts - dd->first_user_ctxt;
+	unsigned int usr_ctxts =
+			dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt;
 	bool can_lock = capable(CAP_IPC_LOCK);
 
 	/*
diff --git a/drivers/infiniband/hw/hfi1/verbs.c b/drivers/infiniband/hw/hfi1/verbs.c
index 070a349..239fa48 100644
--- a/drivers/infiniband/hw/hfi1/verbs.c
+++ b/drivers/infiniband/hw/hfi1/verbs.c
@@ -61,6 +61,7 @@
 #include "qp.h"
 #include "verbs_txreq.h"
 #include "debugfs.h"
+#include "vnic.h"
 
 static unsigned int hfi1_lkey_table_size = 16;
 module_param_named(lkey_table_size, hfi1_lkey_table_size, uint,
@@ -1289,7 +1290,8 @@ static void hfi1_fill_device_attr(struct hfi1_devdata *dd)
 			IB_DEVICE_BAD_QKEY_CNTR | IB_DEVICE_SHUTDOWN_PORT |
 			IB_DEVICE_SYS_IMAGE_GUID | IB_DEVICE_RC_RNR_NAK_GEN |
 			IB_DEVICE_PORT_ACTIVE_EVENT | IB_DEVICE_SRQ_RESIZE |
-			IB_DEVICE_MEM_MGT_EXTENSIONS;
+			IB_DEVICE_MEM_MGT_EXTENSIONS |
+			IB_DEVICE_RDMA_NETDEV_OPA_VNIC;
 	rdi->dparms.props.page_size_cap = PAGE_SIZE;
 	rdi->dparms.props.vendor_id = dd->oui1 << 16 | dd->oui2 << 8 | dd->oui3;
 	rdi->dparms.props.vendor_part_id = dd->pcidev->device;
@@ -1772,6 +1774,8 @@ int hfi1_register_ib_device(struct hfi1_devdata *dd)
 	ibdev->modify_device = modify_device;
 	ibdev->alloc_hw_stats = alloc_hw_stats;
 	ibdev->get_hw_stats = get_hw_stats;
+	ibdev->alloc_rdma_netdev = hfi1_vnic_alloc_rn;
+	ibdev->free_rdma_netdev = hfi1_vnic_free_rn;
 
 	/* keep process mad in the driver */
 	ibdev->process_mad = hfi1_process_mad;
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
index 04723b1..9bed40d 100644
--- a/drivers/infiniband/hw/hfi1/vnic.h
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -149,5 +149,8 @@ struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
 				      unsigned char name_assign_type,
 				      void (*setup)(struct net_device *));
 void hfi1_vnic_free_rn(struct net_device *netdev);
+int hfi1_vnic_send_dma(struct hfi1_devdata *dd, u8 q_idx,
+		       struct hfi1_vnic_vport_info *vinfo,
+		       struct sk_buff *skb, u64 pbc, u8 plen);
 
 #endif /* _HFI1_VNIC_H */
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
index 26effb2..1846d7c 100644
--- a/drivers/infiniband/hw/hfi1/vnic_main.c
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -62,6 +62,159 @@
 
 static DEFINE_SPINLOCK(vport_cntr_lock);
 
+static int setup_vnic_ctxt(struct hfi1_devdata *dd, struct hfi1_ctxtdata *uctxt)
+{
+	unsigned int rcvctrl_ops = 0;
+	int ret;
+
+	ret = hfi1_init_ctxt(uctxt->sc);
+	if (ret)
+		goto done;
+
+	uctxt->do_interrupt = &handle_receive_interrupt;
+
+	/* Now allocate the RcvHdr queue and eager buffers. */
+	ret = hfi1_create_rcvhdrq(dd, uctxt);
+	if (ret)
+		goto done;
+
+	ret = hfi1_setup_eagerbufs(uctxt);
+	if (ret)
+		goto done;
+
+	set_bit(HFI1_CTXT_SETUP_DONE, &uctxt->event_flags);
+
+	if (uctxt->rcvhdrtail_kvaddr)
+		clear_rcvhdrtail(uctxt);
+
+	rcvctrl_ops = HFI1_RCVCTRL_CTXT_ENB;
+	rcvctrl_ops |= HFI1_RCVCTRL_INTRAVAIL_ENB;
+
+	if (!HFI1_CAP_KGET_MASK(uctxt->flags, MULTI_PKT_EGR))
+		rcvctrl_ops |= HFI1_RCVCTRL_ONE_PKT_EGR_ENB;
+	if (HFI1_CAP_KGET_MASK(uctxt->flags, NODROP_EGR_FULL))
+		rcvctrl_ops |= HFI1_RCVCTRL_NO_EGR_DROP_ENB;
+	if (HFI1_CAP_KGET_MASK(uctxt->flags, NODROP_RHQ_FULL))
+		rcvctrl_ops |= HFI1_RCVCTRL_NO_RHQ_DROP_ENB;
+	if (HFI1_CAP_KGET_MASK(uctxt->flags, DMA_RTAIL))
+		rcvctrl_ops |= HFI1_RCVCTRL_TAILUPD_ENB;
+
+	hfi1_rcvctrl(uctxt->dd, rcvctrl_ops, uctxt->ctxt);
+
+	uctxt->is_vnic = true;
+done:
+	return ret;
+}
+
+static int allocate_vnic_ctxt(struct hfi1_devdata *dd,
+			      struct hfi1_ctxtdata **vnic_ctxt)
+{
+	struct hfi1_ctxtdata *uctxt;
+	unsigned int ctxt;
+	int ret;
+
+	if (dd->flags & HFI1_FROZEN)
+		return -EIO;
+
+	for (ctxt = dd->first_dyn_alloc_ctxt;
+	     ctxt < dd->num_rcv_contexts; ctxt++)
+		if (!dd->rcd[ctxt])
+			break;
+
+	if (ctxt == dd->num_rcv_contexts)
+		return -EBUSY;
+
+	uctxt = hfi1_create_ctxtdata(dd->pport, ctxt, dd->node);
+	if (!uctxt) {
+		dd_dev_err(dd, "Unable to create ctxtdata, failing open\n");
+		return -ENOMEM;
+	}
+
+	uctxt->flags = HFI1_CAP_KGET(MULTI_PKT_EGR) |
+			HFI1_CAP_KGET(NODROP_RHQ_FULL) |
+			HFI1_CAP_KGET(NODROP_EGR_FULL) |
+			HFI1_CAP_KGET(DMA_RTAIL);
+	uctxt->seq_cnt = 1;
+
+	/* Allocate and enable a PIO send context */
+	uctxt->sc = sc_alloc(dd, SC_VNIC, uctxt->rcvhdrqentsize,
+			     uctxt->numa_id);
+
+	ret = uctxt->sc ? 0 : -ENOMEM;
+	if (ret)
+		goto bail;
+
+	dd_dev_dbg(dd, "allocated vnic send context %u(%u)\n",
+		   uctxt->sc->sw_index, uctxt->sc->hw_context);
+	ret = sc_enable(uctxt->sc);
+	if (ret)
+		goto bail;
+
+	if (dd->num_msix_entries)
+		hfi1_set_vnic_msix_info(uctxt);
+
+	hfi1_stats.sps_ctxts++;
+	dd_dev_dbg(dd, "created vnic context %d\n", uctxt->ctxt);
+	*vnic_ctxt = uctxt;
+
+	return ret;
+bail:
+	/*
+	 * hfi1_free_ctxtdata() also releases send_context
+	 * structure if uctxt->sc is not null
+	 */
+	dd->rcd[uctxt->ctxt] = NULL;
+	hfi1_free_ctxtdata(dd, uctxt);
+	dd_dev_dbg(dd, "vnic allocation failed. rc %d\n", ret);
+	return ret;
+}
+
+static void deallocate_vnic_ctxt(struct hfi1_devdata *dd,
+				 struct hfi1_ctxtdata *uctxt)
+{
+	unsigned long flags;
+
+	dd_dev_dbg(dd, "closing vnic context %d\n", uctxt->ctxt);
+	flush_wc();
+
+	if (dd->num_msix_entries)
+		hfi1_reset_vnic_msix_info(uctxt);
+
+	spin_lock_irqsave(&dd->uctxt_lock, flags);
+	/*
+	 * Disable receive context and interrupt available, reset all
+	 * RcvCtxtCtrl bits to default values.
+	 */
+	hfi1_rcvctrl(dd, HFI1_RCVCTRL_CTXT_DIS |
+		     HFI1_RCVCTRL_TIDFLOW_DIS |
+		     HFI1_RCVCTRL_INTRAVAIL_DIS |
+		     HFI1_RCVCTRL_ONE_PKT_EGR_DIS |
+		     HFI1_RCVCTRL_NO_RHQ_DROP_DIS |
+		     HFI1_RCVCTRL_NO_EGR_DROP_DIS, uctxt->ctxt);
+	/*
+	 * VNIC contexts are allocated from user context pool.
+	 * Release them back to user context pool.
+	 *
+	 * Reset context integrity checks to default.
+	 * (writes to CSRs probably belong in chip.c)
+	 */
+	write_kctxt_csr(dd, uctxt->sc->hw_context, SEND_CTXT_CHECK_ENABLE,
+			hfi1_pkt_default_send_ctxt_mask(dd, SC_USER));
+	sc_disable(uctxt->sc);
+
+	dd->send_contexts[uctxt->sc->sw_index].type = SC_USER;
+	spin_unlock_irqrestore(&dd->uctxt_lock, flags);
+
+	dd->rcd[uctxt->ctxt] = NULL;
+	uctxt->event_flags = 0;
+
+	hfi1_clear_tids(uctxt);
+	hfi1_clear_ctxt_pkey(dd, uctxt->ctxt);
+
+	hfi1_stats.sps_ctxts--;
+	hfi1_free_ctxtdata(dd, uctxt);
+}
+
 void hfi1_vnic_setup(struct hfi1_devdata *dd)
 {
 	idr_init(&dd->vnic.vesw_idr);
@@ -519,6 +672,9 @@ static void hfi1_vnic_down(struct hfi1_vnic_vport_info *vinfo)
 	netif_tx_disable(vinfo->netdev);
 	idr_remove(&dd->vnic.vesw_idr, vinfo->vesw_id);
 
+	/* ensure irqs see the change */
+	hfi1_vnic_synchronize_irq(dd);
+
 	/* remove unread skbs */
 	for (i = 0; i < vinfo->num_rx_q; i++) {
 		struct hfi1_vnic_rx_queue *rxq = &vinfo->rxq[i];
@@ -550,6 +706,84 @@ static int hfi1_netdev_close(struct net_device *netdev)
 	return 0;
 }
 
+static int hfi1_vnic_allot_ctxt(struct hfi1_devdata *dd,
+				struct hfi1_ctxtdata **vnic_ctxt)
+{
+	int rc;
+
+	rc = allocate_vnic_ctxt(dd, vnic_ctxt);
+	if (rc) {
+		dd_dev_err(dd, "vnic ctxt alloc failed %d\n", rc);
+		return rc;
+	}
+
+	rc = setup_vnic_ctxt(dd, *vnic_ctxt);
+	if (rc) {
+		dd_dev_err(dd, "vnic ctxt setup failed %d\n", rc);
+		deallocate_vnic_ctxt(dd, *vnic_ctxt);
+		*vnic_ctxt = NULL;
+	}
+
+	return rc;
+}
+
+static int hfi1_vnic_init(struct hfi1_vnic_vport_info *vinfo)
+{
+	struct hfi1_devdata *dd = vinfo->dd;
+	int i, rc = 0;
+
+	mutex_lock(&hfi1_mutex);
+	if (!dd->vnic.num_vports)
+		dd->vnic.msix_idx = dd->first_dyn_msix_idx;
+
+	for (i = dd->vnic.num_ctxt; i < vinfo->num_rx_q; i++) {
+		rc = hfi1_vnic_allot_ctxt(dd, &dd->vnic.ctxt[i]);
+		if (rc)
+			break;
+		dd->vnic.ctxt[i]->vnic_q_idx = i;
+	}
+
+	if (i < vinfo->num_rx_q) {
+		/*
+		 * If required amount of contexts is not
+		 * allocated successfully then remaining contexts
+		 * are released.
+		 */
+		while (i-- > dd->vnic.num_ctxt) {
+			deallocate_vnic_ctxt(dd, dd->vnic.ctxt[i]);
+			dd->vnic.ctxt[i] = NULL;
+		}
+		goto alloc_fail;
+	}
+
+	if (dd->vnic.num_ctxt != i) {
+		dd->vnic.num_ctxt = i;
+		hfi1_init_vnic_rsm(dd);
+	}
+
+	dd->vnic.num_vports++;
+alloc_fail:
+	mutex_unlock(&hfi1_mutex);
+	return rc;
+}
+
+static void hfi1_vnic_deinit(struct hfi1_vnic_vport_info *vinfo)
+{
+	struct hfi1_devdata *dd = vinfo->dd;
+	int i;
+
+	mutex_lock(&hfi1_mutex);
+	if (--dd->vnic.num_vports == 0) {
+		for (i = 0; i < dd->vnic.num_ctxt; i++) {
+			deallocate_vnic_ctxt(dd, dd->vnic.ctxt[i]);
+			dd->vnic.ctxt[i] = NULL;
+		}
+		hfi1_deinit_vnic_rsm(dd);
+		dd->vnic.num_ctxt = 0;
+	}
+	mutex_unlock(&hfi1_mutex);
+}
+
 static void hfi1_vnic_set_vesw_id(struct net_device *netdev, int id)
 {
 	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
@@ -594,7 +828,7 @@ struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
 	struct hfi1_vnic_vport_info *vinfo;
 	struct net_device *netdev;
 	struct rdma_netdev *rn;
-	int i, size;
+	int i, size, rc;
 
 	if (!port_num || (port_num > dd->num_pports))
 		return ERR_PTR(-EINVAL);
@@ -632,13 +866,22 @@ struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
 		netif_napi_add(netdev, &rxq->napi, hfi1_vnic_napi, 64);
 	}
 
+	rc = hfi1_vnic_init(vinfo);
+	if (rc)
+		goto init_fail;
+
 	return netdev;
+init_fail:
+	mutex_destroy(&vinfo->lock);
+	free_netdev(netdev);
+	return ERR_PTR(rc);
 }
 
 void hfi1_vnic_free_rn(struct net_device *netdev)
 {
 	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
 
+	hfi1_vnic_deinit(vinfo);
 	mutex_destroy(&vinfo->lock);
 	free_netdev(netdev);
 }
diff --git a/include/rdma/opa_port_info.h b/include/rdma/opa_port_info.h
index 9303e0e..b4f0ac0 100644
--- a/include/rdma/opa_port_info.h
+++ b/include/rdma/opa_port_info.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Intel Corporation.  All rights reserved.
+ * Copyright (c) 2014-2017 Intel Corporation.  All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -127,6 +127,7 @@
 #define OPA_LINK_WIDTH_3X            0x0004
 #define OPA_LINK_WIDTH_4X            0x0008
 
+#define OPA_CAP_MASK3_IsEthOnFabricSupported      (1 << 13)
 #define OPA_CAP_MASK3_IsSnoopSupported            (1 << 7)
 #define OPA_CAP_MASK3_IsAsyncSC2VLSupported       (1 << 6)
 #define OPA_CAP_MASK3_IsAddrRangeConfigSupported  (1 << 5)
-- 
1.8.3.1
