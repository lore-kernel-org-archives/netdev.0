From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [RFC 09/10] IB/hfi1: Virtual Network Interface Controller (VNIC) support
Date: Fri, 18 Nov 2016 14:42:17 -0800
Message-ID: <1479508938-63799-10-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29165 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752993AbcKRWnB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 17:43:01 -0500
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI1 HW specific support for VNIC functionality. Add support to create
VNIC devices on HFI VNIC Bus. Also implement the bus operations to
allocate resources, transmit and receive of Omni-Path encapsulated
Ethernet packets.

Dynamically allocate a set of contexts for VNIC when the first vnic
port is instantiated. Allocate VNIC contexts from user contexts pool
and return them back to the same pool while freeing up. Set aside
enough MSI-X interrupts for VNIC contexts and assign them when the
contexts are allocated. On the receive side, use an RSM rule to
spread TCP/UDP streams among VNIC contexts.

Change-Id: I1b275a7585d6c2e3573039a9137014031f1f5c7e
Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski@intel.com>
---
 drivers/infiniband/hw/hfi1/Kconfig        |   2 +-
 drivers/infiniband/hw/hfi1/Makefile       |   3 +-
 drivers/infiniband/hw/hfi1/aspm.h         |  13 +-
 drivers/infiniband/hw/hfi1/chip.c         | 270 ++++++++++++---
 drivers/infiniband/hw/hfi1/chip.h         |   2 +
 drivers/infiniband/hw/hfi1/debugfs.c      |   6 +-
 drivers/infiniband/hw/hfi1/driver.c       |  78 ++++-
 drivers/infiniband/hw/hfi1/file_ops.c     |  25 +-
 drivers/infiniband/hw/hfi1/hfi.h          |  50 ++-
 drivers/infiniband/hw/hfi1/init.c         |  44 ++-
 drivers/infiniband/hw/hfi1/mad.c          |   8 +-
 drivers/infiniband/hw/hfi1/pio.c          |  17 +
 drivers/infiniband/hw/hfi1/pio.h          |   6 +
 drivers/infiniband/hw/hfi1/sysfs.c        |   2 +-
 drivers/infiniband/hw/hfi1/user_exp_rcv.c |   6 +-
 drivers/infiniband/hw/hfi1/user_pages.c   |   3 +-
 drivers/infiniband/hw/hfi1/vnic.h         | 155 +++++++++
 drivers/infiniband/hw/hfi1/vnic_device.c  | 168 +++++++++
 drivers/infiniband/hw/hfi1/vnic_main.c    | 555 ++++++++++++++++++++++++++++++
 drivers/infiniband/hw/hfi1/vnic_sdma.c    |  60 ++++
 include/rdma/opa_port_info.h              |   2 +-
 21 files changed, 1376 insertions(+), 99 deletions(-)
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_device.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_sdma.c

diff --git a/drivers/infiniband/hw/hfi1/Kconfig b/drivers/infiniband/hw/hfi1/Kconfig
index f6ea088..6c07117 100644
--- a/drivers/infiniband/hw/hfi1/Kconfig
+++ b/drivers/infiniband/hw/hfi1/Kconfig
@@ -1,6 +1,6 @@
 config INFINIBAND_HFI1
 	tristate "Intel OPA Gen1 support"
-	depends on X86_64 && INFINIBAND_RDMAVT && I2C
+	depends on X86_64 && INFINIBAND_RDMAVT && I2C && HFI_VNIC_BUS
 	select MMU_NOTIFIER
 	select CRC32
 	select I2C_ALGOBIT
diff --git a/drivers/infiniband/hw/hfi1/Makefile b/drivers/infiniband/hw/hfi1/Makefile
index 0cf97a0..c579f98 100644
--- a/drivers/infiniband/hw/hfi1/Makefile
+++ b/drivers/infiniband/hw/hfi1/Makefile
@@ -6,13 +6,14 @@
 # Called from the kernel module build system.
 #
 obj-$(CONFIG_INFINIBAND_HFI1) += hfi1.o
+ccflags-y += -I$(src)/../../sw/intel/vnic/include
 
 hfi1-y := affinity.o chip.o device.o driver.o efivar.o \
 	eprom.o file_ops.o firmware.o \
 	init.o intr.o mad.o mmu_rb.o pcie.o pio.o pio_copy.o platform.o \
 	qp.o qsfp.o rc.o ruc.o sdma.o sysfs.o trace.o \
 	uc.o ud.o user_exp_rcv.o user_pages.o user_sdma.o verbs.o \
-	verbs_txreq.o
+	verbs_txreq.o vnic_main.o vnic_device.o vnic_sdma.o
 hfi1-$(CONFIG_DEBUG_FS) += debugfs.o
 
 CFLAGS_trace.o = -I$(src)
diff --git a/drivers/infiniband/hw/hfi1/aspm.h b/drivers/infiniband/hw/hfi1/aspm.h
index 0d58fe3..3a01b69 100644
--- a/drivers/infiniband/hw/hfi1/aspm.h
+++ b/drivers/infiniband/hw/hfi1/aspm.h
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
index f87d805..ceb472b 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -125,9 +125,16 @@ struct flag_table {
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
@@ -138,8 +145,7 @@ struct flag_table {
 #define is_emulator_p(dd) ((((dd)->irev) & 0xf) == 3)
 #define is_emulator_s(dd) ((((dd)->irev) & 0xf) == 4)
 
-/* RSM fields */
-
+/* RSM fields for Verbs */
 /* packet type */
 #define IB_PACKET_TYPE         2ull
 #define QW_SHIFT               6ull
@@ -169,6 +175,28 @@ struct flag_table {
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
@@ -1045,6 +1073,7 @@ static int wait_logical_linkstate(struct hfi1_pportdata *ppd, u32 state,
 static int qos_rmt_entries(struct hfi1_devdata *dd, unsigned int *mp,
 			   unsigned int *np);
 static void clear_full_mgmt_pkey(struct hfi1_pportdata *ppd);
+static void clear_rsm_rule(struct hfi1_devdata *dd, u8 rule_index);
 
 /*
  * Error interrupt table entry.  This is used as input to the interrupt
@@ -6712,7 +6741,13 @@ static void rxe_kernel_unfreeze(struct hfi1_devdata *dd)
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
@@ -8004,7 +8039,9 @@ static void is_rcv_avail_int(struct hfi1_devdata *dd, unsigned int source)
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
@@ -8032,7 +8069,8 @@ static void is_rcv_urgent_int(struct hfi1_devdata *dd, unsigned int source)
 		rcd = dd->rcd[source];
 		if (rcd) {
 			/* only pay attention to user urgent interrupts */
-			if (source >= dd->first_user_ctxt)
+			if ((source >= dd->first_dyn_alloc_ctxt) &&
+			    (!rcd->sc || (rcd->sc->type == SC_USER)))
 				handle_user_interrupt(rcd);
 			return;	/* OK */
 		}
@@ -12733,7 +12771,7 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 	first_sdma = last_general;
 	last_sdma = first_sdma + dd->num_sdma;
 	first_rx = last_sdma;
-	last_rx = first_rx + dd->n_krcv_queues;
+	last_rx = first_rx + dd->n_krcv_queues + HFI1_NUM_VNIC_CTXT;
 
 	/*
 	 * Sanity check - the code expects all SDMA chip source
@@ -12747,7 +12785,7 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 		const char *err_info;
 		irq_handler_t handler;
 		irq_handler_t thread = NULL;
-		void *arg;
+		void *arg = NULL;
 		int idx;
 		struct hfi1_ctxtdata *rcd = NULL;
 		struct sdma_engine *sde = NULL;
@@ -12774,24 +12812,24 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
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
+			}
 		} else {
 			/* not in our expected range - complain, then
 			 * ignore it
@@ -12829,6 +12867,67 @@ static int request_msix_irqs(struct hfi1_devdata *dd)
 	return ret;
 }
 
+void hfi1_reset_vnic_msix_info(struct hfi1_ctxtdata *rcd)
+{
+	int idx = rcd->ctxt;
+	struct hfi1_devdata *dd = rcd->dd;
+	int i = 1 + dd->num_sdma + idx;
+	struct hfi1_msix_entry *me = &dd->msix_entries[i];
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
+	int idx = rcd->ctxt;
+	void *arg = rcd;
+	int ret;
+	struct hfi1_devdata *dd = rcd->dd;
+	int i = 1 + dd->num_sdma + idx;
+	struct hfi1_msix_entry *me = &dd->msix_entries[i];
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
+	remap_intr(dd, IS_RCVAVAIL_START + idx, i);
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
@@ -12860,7 +12959,7 @@ static int set_up_interrupts(struct hfi1_devdata *dd)
 	 *	N interrupts - one per used SDMA engine
 	 *	M interrupt - one per kernel receive context
 	 */
-	total = 1 + dd->num_sdma + dd->n_krcv_queues;
+	total = 1 + dd->num_sdma + dd->n_krcv_queues + HFI1_NUM_VNIC_CTXT;
 
 	entries = kcalloc(total, sizeof(*entries), GFP_KERNEL);
 	if (!entries) {
@@ -12925,7 +13024,8 @@ static int set_up_interrupts(struct hfi1_devdata *dd)
  *
  *	num_rcv_contexts - number of contexts being used
  *	n_krcv_queues - number of kernel contexts
- *	first_user_ctxt - first non-kernel context in array of contexts
+ *	first_dyn_alloc_ctxt - first dynamically allocated context
+ *                             in array of contexts
  *	freectxts  - number of free user contexts
  *	num_send_contexts - number of PIO send contexts being used
  */
@@ -13002,10 +13102,14 @@ static int set_up_context_variables(struct hfi1_devdata *dd)
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
@@ -13461,11 +13565,8 @@ static void reset_rxe_csrs(struct hfi1_devdata *dd)
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
 
@@ -13824,6 +13925,16 @@ static void add_rsm_rule(struct hfi1_devdata *dd, u8 rule_index,
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
@@ -13939,7 +14050,7 @@ static void init_qos(struct hfi1_devdata *dd, struct rsm_map_table *rmt)
 	rrd.value2 = LRH_SC_VALUE;
 
 	/* add rule 0 */
-	add_rsm_rule(dd, 0, &rrd);
+	add_rsm_rule(dd, RSM_INS_VERBS, &rrd);
 
 	/* mark RSM map entries as used */
 	rmt->used += rmt_entries;
@@ -13969,7 +14080,7 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
 	/*
 	 * RSM will extract the destination context as an index into the
 	 * map table.  The destination contexts are a sequential block
-	 * in the range first_user_ctxt...num_rcv_contexts-1 (inclusive).
+	 * in the range first_dyn_alloc_ctxt...num_rcv_contexts-1 (inclusive).
 	 * Map entries are accessed as offset + extracted value.  Adjust
 	 * the added offset so this sequence can be placed anywhere in
 	 * the table - as long as the entries themselves do not wrap.
@@ -13977,9 +14088,9 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
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
@@ -14013,11 +14124,84 @@ static void init_user_fecn_handling(struct hfi1_devdata *dd,
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
@@ -14030,6 +14214,8 @@ static void init_rxe(struct hfi1_devdata *dd)
 	init_qos(dd, rmt);
 	init_user_fecn_handling(dd, rmt);
 	complete_rsm_map_table(dd, rmt);
+	/* record number of used rsm map entries for vnic */
+	dd->vnic.rmt_start = rmt->used;
 	kfree(rmt);
 
 	/*
diff --git a/drivers/infiniband/hw/hfi1/chip.h b/drivers/infiniband/hw/hfi1/chip.h
index 9234525..1e177f5 100644
--- a/drivers/infiniband/hw/hfi1/chip.h
+++ b/drivers/infiniband/hw/hfi1/chip.h
@@ -1355,6 +1355,8 @@ void hfi1_put_tid(struct hfi1_devdata *dd, u32 index,
 int hfi1_set_ctxt_pkey(struct hfi1_devdata *dd, unsigned ctxt, u16 pkey);
 int hfi1_clear_ctxt_pkey(struct hfi1_devdata *dd, unsigned ctxt);
 void hfi1_read_link_quality(struct hfi1_devdata *dd, u8 *link_quality);
+void hfi1_init_vnic_rsm(struct hfi1_devdata *dd);
+void hfi1_deinit_vnic_rsm(struct hfi1_devdata *dd);
 
 /*
  * Interrupt source table.
diff --git a/drivers/infiniband/hw/hfi1/debugfs.c b/drivers/infiniband/hw/hfi1/debugfs.c
index 632ba21..a088151 100644
--- a/drivers/infiniband/hw/hfi1/debugfs.c
+++ b/drivers/infiniband/hw/hfi1/debugfs.c
@@ -169,7 +169,7 @@ static int _opcode_stats_seq_show(struct seq_file *s, void *v)
 	struct hfi1_ibdev *ibd = (struct hfi1_ibdev *)s->private;
 	struct hfi1_devdata *dd = dd_from_dev(ibd);
 
-	for (j = 0; j < dd->first_user_ctxt; j++) {
+	for (j = 0; j < dd->first_dyn_alloc_ctxt; j++) {
 		if (!dd->rcd[j])
 			continue;
 		n_packets += dd->rcd[j]->opstats->stats[i].n_packets;
@@ -195,7 +195,7 @@ static void *_ctx_stats_seq_start(struct seq_file *s, loff_t *pos)
 
 	if (!*pos)
 		return SEQ_START_TOKEN;
-	if (*pos >= dd->first_user_ctxt)
+	if (*pos >= dd->first_dyn_alloc_ctxt)
 		return NULL;
 	return pos;
 }
@@ -209,7 +209,7 @@ static void *_ctx_stats_seq_next(struct seq_file *s, void *v, loff_t *pos)
 		return pos;
 
 	++*pos;
-	if (*pos >= dd->first_user_ctxt)
+	if (*pos >= dd->first_dyn_alloc_ctxt)
 		return NULL;
 	return pos;
 }
diff --git a/drivers/infiniband/hw/hfi1/driver.c b/drivers/infiniband/hw/hfi1/driver.c
index 6563e4d..c60db8f 100644
--- a/drivers/infiniband/hw/hfi1/driver.c
+++ b/drivers/infiniband/hw/hfi1/driver.c
@@ -59,6 +59,7 @@
 #include "trace.h"
 #include "qp.h"
 #include "sdma.h"
+#include "vnic.h"
 
 #undef pr_fmt
 #define pr_fmt(fmt) DRIVER_NAME ": " fmt
@@ -859,20 +860,42 @@ int handle_receive_interrupt_dma_rtail(struct hfi1_ctxtdata *rcd, int thread)
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
@@ -882,8 +905,13 @@ void set_all_slowpath(struct hfi1_devdata *dd)
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
@@ -993,7 +1021,7 @@ int handle_receive_interrupt(struct hfi1_ctxtdata *rcd, int thread)
 				last = RCV_PKT_DONE;
 			if (needset) {
 				dd_dev_info(dd, "Switching to NO_DMA_RTAIL\n");
-				set_all_nodma_rtail(dd);
+				set_nodma_rtail(dd, rcd->ctxt);
 				needset = 0;
 			}
 		} else {
@@ -1015,7 +1043,7 @@ int handle_receive_interrupt(struct hfi1_ctxtdata *rcd, int thread)
 			if (needset) {
 				dd_dev_info(dd,
 					    "Switching to DMA_RTAIL\n");
-				set_all_dma_rtail(dd);
+				set_dma_rtail(dd, rcd->ctxt);
 				needset = 0;
 			}
 		}
@@ -1063,10 +1091,10 @@ void receive_interrupt_work(struct work_struct *work)
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
 
@@ -1280,7 +1308,8 @@ int hfi1_reset_device(int unit)
 
 	spin_lock_irqsave(&dd->uctxt_lock, flags);
 	if (dd->rcd)
-		for (i = dd->first_user_ctxt; i < dd->num_rcv_contexts; i++) {
+		for (i = dd->first_dyn_alloc_ctxt;
+		     i < dd->num_rcv_contexts; i++) {
 			if (!dd->rcd[i] || !dd->rcd[i]->cnt)
 				continue;
 			spin_unlock_irqrestore(&dd->uctxt_lock, flags);
@@ -1358,13 +1387,34 @@ int process_receive_ib(struct hfi1_packet *packet)
 	return RHF_RCV_CONTINUE;
 }
 
+/*
+ * Check if packet is for VNIC
+ */
+static inline bool hfi1_is_vnic_packet(struct hfi1_packet *packet)
+{
+	/* Packet received in VNIC context via RSM */
+	if (packet->rcd->is_vnic)
+		return true;
+
+	if ((HFI1_GET_L2_TYPE(packet->ebuf) == HFI1_L2_TYPE_HDR_16B) &&
+	    (HFI1_GET_L4_TYPE(packet->ebuf) == HFI1_VNIC_L4_ETHR))
+		return true;
+
+	/* Not a VNIC packet */
+	return false;
+}
+
 int process_receive_bypass(struct hfi1_packet *packet)
 {
-	if (unlikely(rhf_err_flags(packet->rhf)))
+	if (unlikely(rhf_err_flags(packet->rhf))) {
 		handle_eflags(packet);
+	} else if (hfi1_is_vnic_packet(packet)) {
+		hfi1_vnic_bypass_rcv(packet);
+		return RHF_RCV_CONTINUE;
+	}
 
 	dd_dev_err(packet->rcd->dd,
-		   "Bypass packets are not supported in normal operation. Dropping\n");
+		   "Unsupported bypass packet. Dropping\n");
 	incr_cntr64(&packet->rcd->dd->sw_rcv_bypass_packet_errors);
 	return RHF_RCV_CONTINUE;
 }
diff --git a/drivers/infiniband/hw/hfi1/file_ops.c b/drivers/infiniband/hw/hfi1/file_ops.c
index 677efa0..863fbbb 100644
--- a/drivers/infiniband/hw/hfi1/file_ops.c
+++ b/drivers/infiniband/hw/hfi1/file_ops.c
@@ -576,8 +576,8 @@ static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma)
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
@@ -746,7 +746,7 @@ static int hfi1_file_close(struct inode *inode, struct file *fp)
 	 * Clear any left over, unhandled events so the next process that
 	 * gets this context doesn't get confused.
 	 */
-	ev = dd->events + ((uctxt->ctxt - dd->first_user_ctxt) *
+	ev = dd->events + ((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 			   HFI1_MAX_SHARED_CTXTS) + fdata->subctxt;
 	*ev = 0;
 
@@ -895,12 +895,18 @@ static int find_shared_ctxt(struct file *fp,
 
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
@@ -946,7 +952,8 @@ static int allocate_ctxt(struct file *fp, struct hfi1_devdata *dd,
 		return -EIO;
 	}
 
-	for (ctxt = dd->first_user_ctxt; ctxt < dd->num_rcv_contexts; ctxt++)
+	for (ctxt = dd->first_dyn_alloc_ctxt;
+	     ctxt < dd->num_rcv_contexts; ctxt++)
 		if (!dd->rcd[ctxt])
 			break;
 
@@ -1292,7 +1299,7 @@ static int get_base_info(struct file *fp, void __user *ubase, __u32 len)
 	 */
 	binfo.user_regbase = HFI1_MMAP_TOKEN(UREGS, uctxt->ctxt,
 					    fd->subctxt, 0);
-	offset = offset_in_page((((uctxt->ctxt - dd->first_user_ctxt) *
+	offset = offset_in_page((((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 		    HFI1_MAX_SHARED_CTXTS) + fd->subctxt) *
 		  sizeof(*dd->events));
 	binfo.events_bufbase = HFI1_MMAP_TOKEN(EVENTS, uctxt->ctxt,
@@ -1386,12 +1393,12 @@ int hfi1_set_uevent_bits(struct hfi1_pportdata *ppd, const int evtbit)
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
@@ -1463,7 +1470,7 @@ static int user_event_ack(struct hfi1_ctxtdata *uctxt, int subctxt,
 	if (!dd->events)
 		return 0;
 
-	evs = dd->events + ((uctxt->ctxt - dd->first_user_ctxt) *
+	evs = dd->events + ((uctxt->ctxt - dd->first_dyn_alloc_ctxt) *
 			    HFI1_MAX_SHARED_CTXTS) + subctxt;
 
 	for (i = 0; i <= _HFI1_MAX_EVENT_BIT; i++) {
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index a66d198..2ff3453 100644
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
@@ -337,6 +339,12 @@ struct hfi1_ctxtdata {
 	 * packets with the wrong interrupt handler.
 	 */
 	int (*do_interrupt)(struct hfi1_ctxtdata *rcd, int threaded);
+
+	/* Indicates that this is vnic context */
+	bool is_vnic;
+
+	/* vnic queue index this context is mapped to */
+	u8 vnic_q_idx;
 };
 
 /*
@@ -831,6 +839,31 @@ struct hfi1_asic_data {
 	struct hfi1_i2c_bus *i2c_bus1;
 };
 
+/* sizes for both the QP and RSM map tables */
+#define NUM_MAP_ENTRIES	 256
+#define NUM_MAP_REGS      32
+
+/*
+ * Number of VNIC contexts used. Ensure it is less than or equal to
+ * max queues supported by VNIC (HFI_VNIC_MAX_QUEUE).
+ */
+#define HFI1_NUM_VNIC_CTXT   8
+
+/* Number of VNIC RSM entries */
+#define NUM_VNIC_MAP_ENTRIES     8
+
+/* Virtual NIC information */
+struct hfi1_vnic_data {
+	struct hfi1_ctxtdata *ctxt[HFI1_NUM_VNIC_CTXT];
+	u8 num_vports;
+	struct hfi_vnic_ctrl_device *ctrl_dev;
+	struct idr vesw_idr;
+	u8 rmt_start;
+	u8 num_ctxt;
+};
+
+struct hfi1_vnic_vport_info;
+
 /* device data struct now contains only "general per-device" info.
  * fields related to a physical IB port are in a hfi1_pportdata struct.
  */
@@ -1140,6 +1173,9 @@ struct hfi1_devdata {
 	send_routine process_dma_send;
 	void (*pio_inline_send)(struct hfi1_devdata *dd, struct pio_buf *pbuf,
 				u64 pbc, const void *from, size_t count);
+	int (*process_vnic_dma_send)(struct hfi1_devdata *dd, u8 q_idx,
+				     struct hfi1_vnic_vport_info *vinfo,
+				     struct sk_buff *skb, u64 pbc, u8 plen);
 	/* hfi1_pportdata, points to array of (physical) port-specific
 	 * data structs, indexed by pidx (0..n-1)
 	 */
@@ -1151,8 +1187,8 @@ struct hfi1_devdata {
 	u16 flags;
 	/* Number of physical ports available */
 	u8 num_pports;
-	/* Lowest context number which can be used by user processes */
-	u8 first_user_ctxt;
+	/* Lowest context number which can be used by user processes or VNIC */
+	u8 first_dyn_alloc_ctxt;
 	/* adding a new field here would make it part of this cacheline */
 
 	/* seqlock for sc2vl */
@@ -1192,8 +1228,16 @@ struct hfi1_devdata {
 	struct rhashtable sdma_rht;
 
 	struct kobject kobj;
+
+	/* vnic data */
+	struct hfi1_vnic_data vnic;
 };
 
+static inline bool hfi1_vnic_is_rsm_full(struct hfi1_devdata *dd, int spare)
+{
+	return (dd->vnic.rmt_start + spare) > NUM_MAP_ENTRIES;
+}
+
 /* 8051 firmware version helper */
 #define dc8051_ver(a, b) ((a) << 8 | (b))
 #define dc8051_ver_maj(a) ((a & 0xff00) >> 8)
@@ -1259,6 +1303,8 @@ void hfi1_init_pportdata(struct pci_dev *, struct hfi1_pportdata *,
 int handle_receive_interrupt_nodma_rtail(struct hfi1_ctxtdata *, int);
 int handle_receive_interrupt_dma_rtail(struct hfi1_ctxtdata *, int);
 void set_all_slowpath(struct hfi1_devdata *dd);
+void hfi1_set_vnic_msix_info(struct hfi1_ctxtdata *rcd);
+void hfi1_reset_vnic_msix_info(struct hfi1_ctxtdata *rcd);
 
 extern const struct pci_device_id hfi1_pci_tbl[];
 
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 60db615..b897c94 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -65,6 +65,7 @@
 #include "verbs.h"
 #include "aspm.h"
 #include "affinity.h"
+#include "vnic.h"
 
 #undef pr_fmt
 #define pr_fmt(fmt) DRIVER_NAME ": " fmt
@@ -139,7 +140,7 @@ int hfi1_create_ctxts(struct hfi1_devdata *dd)
 		goto nomem;
 
 	/* create one or more kernel contexts */
-	for (i = 0; i < dd->first_user_ctxt; ++i) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; ++i) {
 		struct hfi1_pportdata *ppd;
 		struct hfi1_ctxtdata *rcd;
 
@@ -213,9 +214,9 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 	u32 base;
 
 	if (dd->rcv_entries.nctxt_extra >
-	    dd->num_rcv_contexts - dd->first_user_ctxt)
+	    dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt)
 		kctxt_ngroups = (dd->rcv_entries.nctxt_extra -
-				 (dd->num_rcv_contexts - dd->first_user_ctxt));
+			 (dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt));
 	rcd = kzalloc(sizeof(*rcd), GFP_KERNEL);
 	if (rcd) {
 		u32 rcvtids, max_entries;
@@ -237,10 +238,10 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
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
@@ -248,7 +249,7 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 				base = kctxt_ngroups +
 					(ctxt * dd->rcv_entries.ngroups);
 		} else {
-			u16 ct = ctxt - dd->first_user_ctxt;
+			u16 ct = ctxt - dd->first_dyn_alloc_ctxt;
 
 			base = ((dd->n_krcv_queues * dd->rcv_entries.ngroups) +
 				kctxt_ngroups);
@@ -327,7 +328,8 @@ struct hfi1_ctxtdata *hfi1_create_ctxtdata(struct hfi1_pportdata *ppd, u32 ctxt,
 		}
 		rcd->egrbufs.rcvtid_size = HFI1_MAX_EAGER_BUFFER_SIZE;
 
-		if (ctxt < dd->first_user_ctxt) { /* N/A for PSM contexts */
+		/* Applicable only for statically created kernel contexts */
+		if (ctxt < dd->first_dyn_alloc_ctxt) {
 			rcd->opstats = kzalloc(sizeof(*rcd->opstats),
 				GFP_KERNEL);
 			if (!rcd->opstats)
@@ -591,7 +593,7 @@ static void enable_chip(struct hfi1_devdata *dd)
 	 * Enable kernel ctxts' receive and receive interrupt.
 	 * Other ctxts done as user opens and initializes them.
 	 */
-	for (i = 0; i < dd->first_user_ctxt; ++i) {
+	for (i = 0; i < dd->first_dyn_alloc_ctxt; ++i) {
 		rcvmask = HFI1_RCVCTRL_CTXT_ENB | HFI1_RCVCTRL_INTRAVAIL_ENB;
 		rcvmask |= HFI1_CAP_KGET_MASK(dd->rcd[i]->flags, DMA_RTAIL) ?
 			HFI1_RCVCTRL_TAILUPD_ENB : HFI1_RCVCTRL_TAILUPD_DIS;
@@ -685,6 +687,7 @@ int hfi1_init(struct hfi1_devdata *dd, int reinit)
 	dd->process_pio_send = hfi1_verbs_send_pio;
 	dd->process_dma_send = hfi1_verbs_send_dma;
 	dd->pio_inline_send = pio_copy;
+	dd->process_vnic_dma_send = hfi1_vnic_send_dma;
 
 	if (is_ax(dd)) {
 		atomic_set(&dd->drop_packet, DROP_PACKET_ON);
@@ -720,7 +723,7 @@ int hfi1_init(struct hfi1_devdata *dd, int reinit)
 	}
 
 	/* dd->rcd can be NULL if early initialization failed */
-	for (i = 0; dd->rcd && i < dd->first_user_ctxt; ++i) {
+	for (i = 0; dd->rcd && i < dd->first_dyn_alloc_ctxt; ++i) {
 		/*
 		 * Set up the (kernel) rcvhdr queue and egr TIDs.  If doing
 		 * re-init, the simplest way to handle this is to free
@@ -1401,7 +1404,7 @@ static void postinit_cleanup(struct hfi1_devdata *dd)
 
 static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	int ret = 0, j, pidx, initfail;
+	int ret = 0, j, pidx, initfail, vnicfail;
 	struct hfi1_devdata *dd = ERR_PTR(-EINVAL);
 	struct hfi1_pportdata *ppd;
 
@@ -1507,7 +1510,12 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (j)
 		dd_dev_err(dd, "Failed to create /dev devices: %d\n", -j);
 
-	if (initfail || ret) {
+	/* setup vnic */
+	vnicfail = hfi1_vnic_setup(dd);
+	if (vnicfail)
+		dd_dev_err(dd, "vnic setup failed %d\n", vnicfail);
+
+	if (initfail || ret || vnicfail) {
 		stop_timers(dd);
 		flush_workqueue(ib_wq);
 		for (pidx = 0; pidx < dd->num_pports; ++pidx) {
@@ -1518,6 +1526,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				ppd->hfi1_wq = NULL;
 			}
 		}
+		if (!vnicfail)
+			hfi1_vnic_cleanup(dd);
 		if (!j)
 			hfi1_device_remove(dd);
 		if (!ret)
@@ -1542,6 +1552,9 @@ static void remove_one(struct pci_dev *pdev)
 {
 	struct hfi1_devdata *dd = pci_get_drvdata(pdev);
 
+	/* cleanup vnic */
+	hfi1_vnic_cleanup(dd);
+
 	/* close debugfs files before ib unregister */
 	hfi1_dbg_ibdev_exit(&dd->verbs_dev);
 	/* unregister from IB core */
@@ -1588,8 +1601,11 @@ int hfi1_create_rcvhdrq(struct hfi1_devdata *dd, struct hfi1_ctxtdata *rcd)
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
index 0ef62e6..7e90442 100644
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
@@ -678,6 +681,7 @@ static int __subn_get_opa_portinfo(struct opa_smp *smp, u32 am, u8 *data,
 	pi->resptimevalue = 3;
 
 	pi->local_port_num = port;
+	pi->num_vesw_port_supported = HFI_MAX_NUM_VNICS;
 
 	/* buffer info for FM */
 	pi->overall_buffer_space = cpu_to_be16(dd->link_credits);
diff --git a/drivers/infiniband/hw/hfi1/pio.c b/drivers/infiniband/hw/hfi1/pio.c
index 86a7f36..45e36b0 100644
--- a/drivers/infiniband/hw/hfi1/pio.c
+++ b/drivers/infiniband/hw/hfi1/pio.c
@@ -710,6 +710,7 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
 {
 	struct send_context_info *sci;
 	struct send_context *sc = NULL;
+	int req_type = type;
 	dma_addr_t dma;
 	unsigned long flags;
 	u64 reg;
@@ -736,6 +737,13 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
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
@@ -745,6 +753,15 @@ struct send_context *sc_alloc(struct hfi1_devdata *dd, int type,
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
index 867e5ff..22e19d5 100644
--- a/drivers/infiniband/hw/hfi1/pio.h
+++ b/drivers/infiniband/hw/hfi1/pio.h
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
index edba224..916ce94 100644
--- a/drivers/infiniband/hw/hfi1/sysfs.c
+++ b/drivers/infiniband/hw/hfi1/sysfs.c
@@ -543,7 +543,7 @@ static ssize_t show_nctxts(struct device *device,
 	 * give a more accurate picture of total contexts available.
 	 */
 	return scnprintf(buf, PAGE_SIZE, "%u\n",
-			 min(dd->num_rcv_contexts - dd->first_user_ctxt,
+			 min(dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt,
 			     (u32)dd->sc_sizes[SC_USER].count));
 }
 
diff --git a/drivers/infiniband/hw/hfi1/user_exp_rcv.c b/drivers/infiniband/hw/hfi1/user_exp_rcv.c
index 64d2652..fdcd686 100644
--- a/drivers/infiniband/hw/hfi1/user_exp_rcv.c
+++ b/drivers/infiniband/hw/hfi1/user_exp_rcv.c
@@ -612,7 +612,7 @@ int hfi1_user_exp_rcv_invalid(struct file *fp, struct hfi1_tid_info *tinfo)
 	struct hfi1_filedata *fd = fp->private_data;
 	struct hfi1_ctxtdata *uctxt = fd->uctxt;
 	unsigned long *ev = uctxt->dd->events +
-		(((uctxt->ctxt - uctxt->dd->first_user_ctxt) *
+		(((uctxt->ctxt - uctxt->dd->first_dyn_alloc_ctxt) *
 		  HFI1_MAX_SHARED_CTXTS) + fd->subctxt);
 	u32 *array;
 	int ret = 0;
@@ -1016,8 +1016,8 @@ static int tid_rb_invalidate(void *arg, struct mmu_rb_node *mnode)
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
index 20f4ddc..7238a34 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -73,7 +73,8 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 {
 	unsigned long ulimit = rlimit(RLIMIT_MEMLOCK), pinned, cache_limit,
 		size = (cache_size * (1UL << 20)); /* convert to bytes */
-	unsigned usr_ctxts = dd->num_rcv_contexts - dd->first_user_ctxt;
+	unsigned int usr_ctxts =
+			dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt;
 	bool can_lock = capable(CAP_IPC_LOCK);
 
 	/*
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
new file mode 100644
index 0000000..d91c35b
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -0,0 +1,155 @@
+#ifndef _HFI1_VNIC_H
+#define _HFI1_VNIC_H
+/*
+ * Copyright(c) 2016 Intel Corporation.
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
+#include "hfi_vnic.h"
+#include "hfi.h"
+
+#define HFI1_VNIC_ICRC_LEN   4
+#define HFI1_VNIC_TAIL_LEN   1
+#define HFI1_VNIC_ICRC_TAIL_LEN  (HFI1_VNIC_ICRC_LEN + HFI1_VNIC_TAIL_LEN)
+
+#define HFI1_VNIC_MAX_TXQ     16
+#define HFI1_VNIC_MAX_PAD     12
+
+/* L2 header definitions */
+#define HFI1_L2_TYPE_OFFSET     0x7
+#define HFI1_L2_TYPE_SHFT       0x5
+#define HFI1_L2_TYPE_MASK       0x3
+#define HFI1_L2_TYPE_HDR_16B    0x2
+
+#define HFI1_GET_L2_TYPE(hdr)                                            \
+	((*((u8 *)(hdr) + HFI1_L2_TYPE_OFFSET) >> HFI1_L2_TYPE_SHFT) &   \
+	 HFI1_L2_TYPE_MASK)
+
+/* L4 type definitions */
+#define HFI1_L4_TYPE_OFFSET 8
+
+#define HFI1_GET_L4_TYPE(data)   \
+	(*((u8 *)(data) + HFI1_L4_TYPE_OFFSET))
+
+#define HFI1_VNIC_L4_ETHR  0x78
+
+/* L4 header definitions */
+#define HFI1_VNIC_L4_HDR_OFFSET  18
+
+#define HFI1_VNIC_GET_L4_HDR(data)   \
+	(*((u16 *)((u8 *)(data) + HFI1_VNIC_L4_HDR_OFFSET)))
+
+#define HFI1_VNIC_GET_VESWID(data)   \
+	(HFI1_VNIC_GET_L4_HDR(data) & 0xFF)
+
+/* Service class */
+#define HFI1_VNIC_SC_OFFSET_LOW 6
+#define HFI1_VNIC_SC_OFFSET_HI  7
+#define HFI1_VNIC_SC_SHIFT      4
+
+/**
+ * struct hfi1_vnic_notifier - VNIC notifer structure
+ * @cb - vnic callback function
+ */
+struct hfi1_vnic_notifier {
+	hfi_vnic_evt_cb_fn  cb;
+};
+
+/**
+ * struct hfi1_vnic_vport_info - HFI1 VNIC virtual port information
+ * @dd: device data pointer
+ * @vnic_cb: vnic callback function
+ * @event_flags: event notification flags
+ * @notifier: vnic notifier
+ * @skbq: Array of queues for received socket buffers
+ */
+struct hfi1_vnic_vport_info {
+	struct hfi1_devdata *dd;
+
+	struct hfi1_vnic_notifier __rcu *notifier;
+	DECLARE_BITMAP(event_flags, HFI_VNIC_NUM_EVTS);
+	struct hfi_vnic_device *vdev;
+
+	struct sk_buff_head skbq[HFI1_NUM_VNIC_CTXT];
+};
+
+static inline struct hfi1_devdata *vnic_dev2dd(struct hfi_vnic_device *vdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+
+	return vinfo->dd;
+}
+
+/* setup the last plen bypes of pad */
+static inline void hfi1_vnic_update_pad(unsigned char *pad, u8 plen)
+{
+	pad[HFI1_VNIC_MAX_PAD - 1] = plen - HFI1_VNIC_ICRC_TAIL_LEN;
+}
+
+/* vnic hfi1 internal functions */
+int hfi1_vnic_setup(struct hfi1_devdata *dd);
+void hfi1_vnic_cleanup(struct hfi1_devdata *dd);
+int hfi1_vnic_add_ctrl_port(struct hfi1_devdata *dd, struct device *parent);
+void hfi1_vnic_rem_ctrl_port(struct hfi1_devdata *dd);
+
+void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet);
+
+/* vnic device bus ops */
+int hfi1_vnic_init(struct hfi_vnic_device *vdev);
+void hfi1_vnic_deinit(struct hfi_vnic_device *vdev);
+int hfi1_vnic_open(struct hfi_vnic_device *vdev, hfi_vnic_evt_cb_fn cb);
+void hfi1_vnic_close(struct hfi_vnic_device *vdev);
+int hfi1_vnic_put_skb(struct hfi_vnic_device *vdev,
+		      u8 q_idx, struct sk_buff *skb);
+u8 hfi1_vnic_select_queue(struct hfi_vnic_device *vdev, u8 vl, u8 entropy);
+struct sk_buff *hfi1_vnic_get_skb(struct hfi_vnic_device *vdev, u8 q_idx);
+u16 hfi1_vnic_get_read_avail(struct hfi_vnic_device *vdev, u8 q_idx);
+bool hfi1_vnic_get_write_avail(struct hfi_vnic_device *vdev, u8 q_idx);
+void hfi1_vnic_config_notify(struct hfi_vnic_device *vdev, u8 evt, bool enable);
+int hfi1_vnic_send_dma(struct hfi1_devdata *dd, u8 q_idx,
+		       struct hfi1_vnic_vport_info *vinfo,
+		       struct sk_buff *skb, u64 pbc, u8 plen);
+
+#endif /* _HFI1_VNIC_H */
diff --git a/drivers/infiniband/hw/hfi1/vnic_device.c b/drivers/infiniband/hw/hfi1/vnic_device.c
new file mode 100644
index 0000000..468e197
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic_device.c
@@ -0,0 +1,168 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
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
+ * This file contains HFI1 VNIC device handling functions
+ */
+
+#include <linux/idr.h>
+#include <linux/module.h>
+
+#include "vnic.h"
+
+/* vnic operations */
+static struct hfi_vnic_ops hfi1_vnic_ops = {
+	.init = hfi1_vnic_init,
+	.deinit = hfi1_vnic_deinit,
+	.open = hfi1_vnic_open,
+	.close = hfi1_vnic_close,
+	.put_skb = hfi1_vnic_put_skb,
+	.get_skb = hfi1_vnic_get_skb,
+	.get_read_avail = hfi1_vnic_get_read_avail,
+	.get_write_avail = hfi1_vnic_get_write_avail,
+	.select_queue = hfi1_vnic_select_queue,
+	.config_notify = hfi1_vnic_config_notify
+};
+
+/* hfi1_vdev_create - add vnic device on vnic bus */
+static int hfi1_vdev_create(struct hfi_vnic_ctrl_device *cdev,
+			    u8 port_num, u8 vport_num)
+{
+	struct hfi1_devdata *dd = (struct hfi1_devdata *)cdev->hfi_priv;
+	struct hfi1_vnic_vport_info *vinfo;
+	struct hfi_vnic_device *vdev;
+	struct hfi_vnic_info hfi_info;
+
+	if (!port_num || (port_num > dd->num_pports))
+		return -EINVAL;
+
+	vinfo = kzalloc(sizeof(*vinfo), GFP_KERNEL);
+	if (!vinfo)
+		return -ENOMEM;
+
+	vinfo->dd = dd;
+	hfi_info.num_tx_q = 1;
+	hfi_info.num_rx_q = HFI1_NUM_VNIC_CTXT;
+	hfi_info.cap = HFI_VNIC_CAP_SG;
+	vdev = hfi_vnic_device_register(cdev, port_num, vport_num, vinfo,
+					&hfi1_vnic_ops, hfi_info);
+	if (IS_ERR(vdev)) {
+		kfree(vinfo);
+		return PTR_ERR(vdev);
+	}
+	return 0;
+}
+
+/* hfi1_vdev_destroy - remove vnic device from vnic bus */
+static void hfi1_vdev_destroy(struct hfi_vnic_ctrl_device *cdev,
+			      u8 port_num, u8 vport_num)
+{
+	struct hfi1_vnic_vport_info *vinfo;
+	struct hfi_vnic_device *vdev;
+
+	vdev = hfi_vnic_get_dev(cdev, port_num, vport_num);
+	if (!vdev)
+		return;
+
+	vinfo = vdev->hfi_priv;
+	hfi_vnic_device_unregister(vdev);
+	kfree(vinfo);
+}
+
+/* hfi1_vnic_add_vport - add vnic port */
+static int hfi1_vnic_add_vport(struct hfi_vnic_ctrl_device *cdev,
+			       u8 port_num, u8 vport_num)
+{
+	int rc;
+
+	rc = hfi1_vdev_create(cdev, port_num, vport_num);
+	if (rc)
+		dev_err(&cdev->dev, "error adding vnic port (%d:%d): %d\n",
+			port_num, vport_num, rc);
+
+	return rc;
+}
+
+/* hfi1_vnic_rem_vport - remove vnic port */
+static void hfi1_vnic_rem_vport(struct hfi_vnic_ctrl_device *cdev,
+				u8 port_num, u8 vport_num)
+{
+	hfi1_vdev_destroy(cdev, port_num, vport_num);
+}
+
+/* vnic control operations */
+static struct hfi_vnic_ctrl_ops hfi1_vnic_ctrl_ops = {
+	.add_vport = hfi1_vnic_add_vport,
+	.rem_vport = hfi1_vnic_rem_vport
+};
+
+/* hfi1_vnic_add_ctrl_port - add vnic control port */
+int hfi1_vnic_add_ctrl_port(struct hfi1_devdata *dd, struct device *parent)
+{
+	struct ib_device *ibdev = &dd->verbs_dev.rdi.ibdev;
+	struct hfi_vnic_ctrl_device *cdev;
+	int rc;
+
+	cdev = hfi_vnic_ctrl_device_register(parent, ibdev, dd->num_pports,
+					     dd, &hfi1_vnic_ctrl_ops);
+	if (IS_ERR(cdev)) {
+		rc = PTR_ERR(cdev);
+		dev_err(parent, "error adding vnic control port %d: %d\n",
+			dd->unit, rc);
+		return rc;
+	}
+
+	dd->vnic.ctrl_dev = cdev;
+	return 0;
+}
+
+/* hfi1_vnic_rem_ctrl_port - remove vnic control port */
+void hfi1_vnic_rem_ctrl_port(struct hfi1_devdata *dd)
+{
+	hfi_vnic_ctrl_device_unregister(dd->vnic.ctrl_dev);
+	dd->vnic.ctrl_dev = NULL;
+}
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
new file mode 100644
index 0000000..82e30bd
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -0,0 +1,555 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
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
+ * This file contains HFI1 support for VNIC functionality
+ */
+
+#include <linux/io.h>
+
+#include "vnic.h"
+
+#define HFI1_VNIC_RCV_Q_SIZE   1024
+
+static DEFINE_SPINLOCK(vdev_cntr_lock);
+
+static inline u8 hfi1_vnic_get_sc5(u8 *hdr)
+{
+	return  (((*(hdr + HFI1_VNIC_SC_OFFSET_LOW)) >> HFI1_VNIC_SC_SHIFT) |
+		 (((*(hdr + HFI1_VNIC_SC_OFFSET_HI)) & 0x1) <<
+		  HFI1_VNIC_SC_SHIFT));
+}
+
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
+	dev_dbg(&dd->vnic.ctrl_dev->dev,
+		"allocated send context %u(%u)\n",
+		uctxt->sc->sw_index, uctxt->sc->hw_context);
+	ret = sc_enable(uctxt->sc);
+	if (ret)
+		goto bail;
+
+	if (dd->num_msix_entries)
+		hfi1_set_vnic_msix_info(uctxt);
+
+	hfi1_stats.sps_ctxts++;
+	dev_dbg(&dd->vnic.ctrl_dev->dev, "created vnic context %d\n",
+		uctxt->ctxt);
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
+	dev_dbg(&dd->vnic.ctrl_dev->dev, "allocation failed. rc %d\n", ret);
+	return ret;
+}
+
+static void deallocate_vnic_ctxt(struct hfi1_devdata *dd,
+				 struct hfi1_ctxtdata *uctxt)
+{
+	unsigned long flags;
+
+	dev_dbg(&dd->vnic.ctrl_dev->dev, "closing vnic context %d\n",
+		uctxt->ctxt);
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
+int hfi1_vnic_setup(struct hfi1_devdata *dd)
+{
+	idr_init(&dd->vnic.vesw_idr);
+	return hfi1_vnic_add_ctrl_port(dd, &dd->pcidev->dev);
+}
+
+void hfi1_vnic_cleanup(struct hfi1_devdata *dd)
+{
+	hfi1_vnic_rem_ctrl_port(dd);
+	idr_destroy(&dd->vnic.vesw_idr);
+}
+
+static u64 create_bypass_pbc(u32 vl, u32 dw_len)
+{
+	u64 pbc;
+
+	pbc = ((u64)PBC_IHCRC_NONE << PBC_INSERT_HCRC_SHIFT)
+		| PBC_INSERT_BYPASS_ICRC | PBC_CREDIT_RETURN
+		| PBC_PACKET_BYPASS
+		| ((vl & PBC_VL_MASK) << PBC_VL_SHIFT)
+		| (dw_len & PBC_LENGTH_DWS_MASK) << PBC_LENGTH_DWS_SHIFT;
+
+	return pbc;
+}
+
+int hfi1_vnic_put_skb(struct hfi_vnic_device *vdev,
+		      u8 q_idx, struct sk_buff *skb)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+	struct hfi1_devdata *dd = vinfo->dd;
+	u32 vl, pkt_len, total_len;
+	u8 sc5, pad_len;
+	int ret = 0;
+	u64 pbc;
+
+	if (q_idx >= vdev->hfi_info.num_tx_q) {
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
+
+	/* add tail padding (for 8 bytes size alignment) and icrc */
+	pad_len = -(skb->len + HFI1_VNIC_ICRC_TAIL_LEN) & 0x7;
+	pad_len += HFI1_VNIC_ICRC_TAIL_LEN;
+
+	/*
+	 * pkt_len is how much data we have to write, includes header and data.
+	 * total_len is length of the packet in Dwords plus the PBC should not
+	 * include the CRC.
+	 */
+	pkt_len = (skb->len + pad_len) >> 2;
+	total_len = pkt_len + 2; /* PBC + packet */
+
+	sc5 = hfi1_vnic_get_sc5(skb->data);
+	vl = sc_to_vlt(dd, sc5);
+	pbc = create_bypass_pbc(vl, total_len);
+
+	dev_dbg(&vdev->dev, "%s: pbc 0x%016llX len %d pad_len %d\n",
+		__func__, pbc, skb->len, pad_len);
+
+	ret = dd->process_vnic_dma_send(dd, q_idx, vinfo, skb,
+					pbc, pad_len);
+
+	if (ret) {
+		if (ret == -ENOMEM)
+			vdev->hfi_stats[q_idx].tx_fifo_errors++;
+		else if (ret != -EBUSY)
+			vdev->hfi_stats[q_idx].tx_logic_errors++;
+	}
+
+	return ret;
+}
+
+u8 hfi1_vnic_select_queue(struct hfi_vnic_device *vdev, u8 vl, u8 entropy)
+{
+	return 0;
+}
+
+bool hfi1_vnic_get_write_avail(struct hfi_vnic_device *vdev, u8 q_idx)
+{
+	if (q_idx >= vdev->hfi_info.num_tx_q)
+		return false;
+
+	return true;
+}
+
+void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet)
+{
+	struct hfi1_devdata *dd = packet->rcd->dd;
+	struct hfi1_vnic_vport_info *vinfo;
+	struct hfi_vnic_device *vdev = NULL;
+	struct hfi1_vnic_notifier *notifier;
+	struct sk_buff *skb;
+	int l4_type, vesw_id = -1;
+	u8 q_idx;
+
+	rcu_read_lock();
+	l4_type = HFI1_GET_L4_TYPE(packet->ebuf);
+	if (l4_type == HFI1_VNIC_L4_ETHR) {
+		vesw_id = HFI1_VNIC_GET_VESWID(packet->ebuf);
+		vdev = idr_find(&dd->vnic.vesw_idr, vesw_id);
+
+		/*
+		 * In case of invalid vesw id, update the rx_bad_veswid
+		 * error count of first available vdev.
+		 */
+		if (unlikely(!vdev)) {
+			struct hfi_vnic_device *vdev_tmp;
+			int id_tmp = 0;
+
+			vdev_tmp =  idr_get_next(&dd->vnic.vesw_idr, &id_tmp);
+			if (vdev_tmp) {
+				spin_lock(&vdev_cntr_lock);
+				vdev_tmp->hfi_stats[0].rx_bad_veswid++;
+				spin_unlock(&vdev_cntr_lock);
+			}
+		}
+	}
+
+	if (unlikely(!vdev)) {
+		dev_warn(&dd->vnic.ctrl_dev->dev,
+			 "Invalid packet received, l4 %d vesw id %d, ctx %d\n",
+			 l4_type, vesw_id, packet->rcd->ctxt);
+		goto rcv_done;
+	}
+
+	vinfo = vdev->hfi_priv;
+	q_idx = packet->rcd->vnic_q_idx;
+	notifier = rcu_dereference(vinfo->notifier);
+	if (!notifier || !notifier->cb) {
+		vdev->hfi_stats[q_idx].rx_logic_errors++;
+		goto rcv_done;
+	}
+
+	if (skb_queue_len(&vinfo->skbq[q_idx]) > HFI1_VNIC_RCV_Q_SIZE) {
+		vdev->hfi_stats[q_idx].rx_fifo_errors++;
+		goto rcv_done;
+	}
+
+	skb = netdev_alloc_skb(vdev->netdev, packet->tlen);
+	if (!skb) {
+		vdev->hfi_stats[q_idx].rx_missed_errors++;
+		goto rcv_done;
+	}
+	memcpy(skb->data, packet->ebuf, packet->tlen);
+	skb_put(skb, packet->tlen);
+
+	skb_queue_tail(&vinfo->skbq[q_idx], skb);
+	if (test_bit((HFI_VNIC_EVT_RX0 + q_idx), vinfo->event_flags))
+		notifier->cb(vdev, HFI_VNIC_EVT_RX0 + q_idx);
+
+rcv_done:
+	rcu_read_unlock();
+}
+
+u16 hfi1_vnic_get_read_avail(struct hfi_vnic_device *vdev, u8 q_idx)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+
+	if (q_idx >= vdev->hfi_info.num_rx_q)
+		return 0;
+
+	return skb_queue_len(&vinfo->skbq[q_idx]);
+}
+
+struct sk_buff *hfi1_vnic_get_skb(struct hfi_vnic_device *vdev, u8 q_idx)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+	unsigned char *pad_info;
+	struct sk_buff *skb;
+
+	if (q_idx >= vdev->hfi_info.num_rx_q)
+		return NULL;
+
+	skb = skb_dequeue(&vinfo->skbq[q_idx]);
+	if (!skb)
+		return NULL;
+
+	/* remove tail padding and icrc */
+	pad_info = skb->data + skb->len - 1;
+	skb_trim(skb, (skb->len - HFI1_VNIC_ICRC_TAIL_LEN -
+		       ((*pad_info) & 0x7)));
+
+	return skb;
+}
+
+void hfi1_vnic_config_notify(struct hfi_vnic_device *vdev, u8 evt, bool enable)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+
+	if (enable)
+		set_bit(evt, vinfo->event_flags);
+	else
+		clear_bit(evt, vinfo->event_flags);
+}
+
+int hfi1_vnic_open(struct hfi_vnic_device *vdev, hfi_vnic_evt_cb_fn cb)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+	struct hfi1_devdata *dd = vinfo->dd;
+	struct hfi1_vnic_notifier *notifier;
+	int i, rc;
+
+	if (!cb)
+		return -EINVAL;
+
+	notifier = kmalloc(sizeof(*notifier), GFP_KERNEL);
+	if (!notifier)
+		return -ENOMEM;
+
+	notifier->cb = cb;
+
+	/* ensure virtual eth switch id is valid */
+	if (!vdev->vesw_id) {
+		rc = -EINVAL;
+		goto open_fail;
+	}
+
+	rc = idr_alloc(&dd->vnic.vesw_idr, vdev, vdev->vesw_id,
+		       vdev->vesw_id + 1, GFP_NOWAIT);
+	if (rc < 0)
+		goto open_fail;
+
+	for (i = 0; i < HFI1_NUM_VNIC_CTXT; i++)
+		skb_queue_head_init(&vinfo->skbq[i]);
+
+	/* Enable all events */
+	for (i = 0; i < HFI_VNIC_NUM_EVTS; i++)
+		set_bit(i, vinfo->event_flags);
+
+	rcu_assign_pointer(vinfo->notifier, notifier);
+	synchronize_rcu();
+	return 0;
+
+open_fail:
+	kfree(notifier);
+	return rc;
+}
+
+void hfi1_vnic_close(struct hfi_vnic_device *vdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+	struct hfi1_devdata *dd = vinfo->dd;
+	struct hfi1_vnic_notifier *notifier;
+	u8 i;
+
+	idr_remove(&dd->vnic.vesw_idr, vdev->vesw_id);
+	notifier = rcu_access_pointer(vinfo->notifier);
+	rcu_assign_pointer(vinfo->notifier, NULL);
+	synchronize_rcu();
+	kfree(notifier);
+
+	/* remove unread skbs */
+	for (i = 0; i < HFI1_NUM_VNIC_CTXT; i++)
+		skb_queue_purge(&vinfo->skbq[i]);
+}
+
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
+int hfi1_vnic_init(struct hfi_vnic_device *vdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = vdev->hfi_priv;
+	struct hfi1_devdata *dd = vinfo->dd;
+	int i, rc = 0;
+
+	mutex_lock(&hfi1_mutex);
+	for (i = dd->vnic.num_ctxt; i < vdev->hfi_info.num_rx_q; i++) {
+		rc = hfi1_vnic_allot_ctxt(dd, &dd->vnic.ctxt[i]);
+		if (rc)
+			break;
+		dd->vnic.ctxt[i]->vnic_q_idx = i;
+	}
+
+	if (i < vdev->hfi_info.num_rx_q) {
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
+	vinfo->vdev = vdev;
+alloc_fail:
+	mutex_unlock(&hfi1_mutex);
+	return rc;
+}
+
+void hfi1_vnic_deinit(struct hfi_vnic_device *vdev)
+{
+	struct hfi1_devdata *dd = vnic_dev2dd(vdev);
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
+
+	mutex_unlock(&hfi1_mutex);
+}
diff --git a/drivers/infiniband/hw/hfi1/vnic_sdma.c b/drivers/infiniband/hw/hfi1/vnic_sdma.c
new file mode 100644
index 0000000..66abad0
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic_sdma.c
@@ -0,0 +1,60 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
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
+int hfi1_vnic_send_dma(struct hfi1_devdata *dd, u8 q_idx,
+		       struct hfi1_vnic_vport_info *vinfo,
+		       struct sk_buff *skb, u64 pbc, u8 plen)
+{
+	return 0;
+}
diff --git a/include/rdma/opa_port_info.h b/include/rdma/opa_port_info.h
index 9303e0e..84caa5b 100644
--- a/include/rdma/opa_port_info.h
+++ b/include/rdma/opa_port_info.h
@@ -410,7 +410,7 @@ struct opa_port_info {
 
 	u8     resptimevalue;		        /* 3 res, 5 bits */
 	u8     local_port_num;
-	u8     reserved12;
+	u8     num_vesw_port_supported;
 	u8     reserved13;                       /* was guid_cap */
 } __attribute__ ((packed));
 
-- 
1.8.3.1
