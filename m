From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V5 net-next 15/21] net-next/hinic: Add ceqs
Date: Thu, 17 Aug 2017 19:52:56 +0800
Message-ID: <ee9ce0a97f49fcc103e2793f7aedb440a3f12815.1502970631.git.aviad.krawczyk@huawei.com>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize the completion event queues and handle ceq events by calling
the registered handlers. Used for cmdq command completion.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c |  16 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h  |  29 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c  |   7 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c  | 291 +++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h  |  75 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c   |  15 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h   |   3 +
 7 files changed, 428 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
index 0dccbe6..ec24b95 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
@@ -27,6 +27,7 @@
 #include <asm/byteorder.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
 #include "hinic_hw_mgmt.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_cmdq.h"
@@ -110,6 +111,16 @@ int hinic_cmdq_direct_resp(struct hinic_cmdqs *cmdqs,
 }
 
 /**
+ * cmdq_ceq_handler - cmdq completion event handler
+ * @handle: private data for the handler(cmdqs)
+ * @ceqe_data: ceq element data
+ **/
+static void cmdq_ceq_handler(void *handle, u32 ceqe_data)
+{
+	/* should be implemented */
+}
+
+/**
  * cmdq_init_queue_ctxt - init the queue ctxt of a cmdq
  * @cmdq_ctxt: cmdq ctxt to initialize
  * @cmdq: the cmdq
@@ -320,6 +331,8 @@ int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
 		goto err_cmdq_ctxt;
 	}
 
+	hinic_ceq_register_cb(&func_to_io->ceqs, HINIC_CEQ_CMDQ, cmdqs,
+			      cmdq_ceq_handler);
 	return 0;
 
 err_cmdq_ctxt:
@@ -340,10 +353,13 @@ int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
  **/
 void hinic_free_cmdqs(struct hinic_cmdqs *cmdqs)
 {
+	struct hinic_func_to_io *func_to_io = cmdqs_to_func_to_io(cmdqs);
 	struct hinic_hwif *hwif = cmdqs->hwif;
 	struct pci_dev *pdev = hwif->pdev;
 	enum hinic_cmdq_type cmdq_type;
 
+	hinic_ceq_unregister_cb(&func_to_io->ceqs, HINIC_CEQ_CMDQ);
+
 	cmdq_type = HINIC_CMDQ_SYNC;
 	for (; cmdq_type < HINIC_MAX_CMDQ_TYPES; cmdq_type++)
 		free_cmdq(&cmdqs->cmdq[cmdq_type]);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index 1f57301..10b8c7b 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -81,27 +81,44 @@
 
 /* EQ registers */
 #define HINIC_AEQ_MTT_OFF_BASE_ADDR                     0x200
+#define HINIC_CEQ_MTT_OFF_BASE_ADDR                     0x400
 
 #define HINIC_EQ_MTT_OFF_STRIDE                         0x40
 
 #define HINIC_CSR_AEQ_MTT_OFF(id)                       \
 	(HINIC_AEQ_MTT_OFF_BASE_ADDR + (id) * HINIC_EQ_MTT_OFF_STRIDE)
 
+#define HINIC_CSR_CEQ_MTT_OFF(id)                       \
+	(HINIC_CEQ_MTT_OFF_BASE_ADDR + (id) * HINIC_EQ_MTT_OFF_STRIDE)
+
 #define HINIC_CSR_EQ_PAGE_OFF_STRIDE                    8
 
 #define HINIC_CSR_AEQ_HI_PHYS_ADDR_REG(q_id, pg_num)    \
 	(HINIC_CSR_AEQ_MTT_OFF(q_id) + \
 	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE)
 
+#define HINIC_CSR_CEQ_HI_PHYS_ADDR_REG(q_id, pg_num)    \
+	(HINIC_CSR_CEQ_MTT_OFF(q_id) +          \
+	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE)
+
 #define HINIC_CSR_AEQ_LO_PHYS_ADDR_REG(q_id, pg_num)    \
 	(HINIC_CSR_AEQ_MTT_OFF(q_id) + \
 	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE + 4)
 
+#define HINIC_CSR_CEQ_LO_PHYS_ADDR_REG(q_id, pg_num)    \
+	(HINIC_CSR_CEQ_MTT_OFF(q_id) +  \
+	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE + 4)
+
 #define HINIC_AEQ_CTRL_0_ADDR_BASE                      0xE00
 #define HINIC_AEQ_CTRL_1_ADDR_BASE                      0xE04
 #define HINIC_AEQ_CONS_IDX_ADDR_BASE                    0xE08
 #define HINIC_AEQ_PROD_IDX_ADDR_BASE                    0xE0C
 
+#define HINIC_CEQ_CTRL_0_ADDR_BASE                      0x1000
+#define HINIC_CEQ_CTRL_1_ADDR_BASE                      0x1004
+#define HINIC_CEQ_CONS_IDX_ADDR_BASE                    0x1008
+#define HINIC_CEQ_PROD_IDX_ADDR_BASE                    0x100C
+
 #define HINIC_EQ_OFF_STRIDE                             0x80
 
 #define HINIC_CSR_AEQ_CTRL_0_ADDR(idx)                  \
@@ -116,4 +133,16 @@
 #define HINIC_CSR_AEQ_PROD_IDX_ADDR(idx)                \
 	(HINIC_AEQ_PROD_IDX_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
 
+#define HINIC_CSR_CEQ_CTRL_0_ADDR(idx)                  \
+	(HINIC_CEQ_CTRL_0_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_CEQ_CTRL_1_ADDR(idx)                  \
+	(HINIC_CEQ_CTRL_1_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_CEQ_CONS_IDX_ADDR(idx)                \
+	(HINIC_CEQ_CONS_IDX_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_CEQ_PROD_IDX_ADDR(idx)                \
+	(HINIC_CEQ_PROD_IDX_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index cf0e165..cb4c472 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -277,6 +277,7 @@ int hinic_hwdev_ifup(struct hinic_hwdev *hwdev)
 	struct hinic_cap *nic_cap = &hwdev->nic_cap;
 	struct hinic_hwif *hwif = hwdev->hwif;
 	int err, num_aeqs, num_ceqs, num_qps;
+	struct msix_entry *ceq_msix_entries;
 	struct msix_entry *sq_msix_entries;
 	struct msix_entry *rq_msix_entries;
 	struct pci_dev *pdev = hwif->pdev;
@@ -290,7 +291,11 @@ int hinic_hwdev_ifup(struct hinic_hwdev *hwdev)
 
 	num_aeqs = HINIC_HWIF_NUM_AEQS(hwif);
 	num_ceqs = HINIC_HWIF_NUM_CEQS(hwif);
-	err = hinic_io_init(func_to_io, hwif, nic_cap->max_qps, 0, NULL);
+
+	ceq_msix_entries = &hwdev->msix_entries[num_aeqs];
+
+	err = hinic_io_init(func_to_io, hwif, nic_cap->max_qps, num_ceqs,
+			    ceq_msix_entries);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init IO channel\n");
 		return err;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
index a53d5b3..986ad93 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
@@ -37,14 +37,21 @@
 
 #define GET_EQ_NUM_ELEMS_IN_PG(eq, pg_size)     ((pg_size) / (eq)->elem_size)
 
-#define EQ_CONS_IDX_REG_ADDR(eq)        HINIC_CSR_AEQ_CONS_IDX_ADDR((eq)->q_id)
-#define EQ_PROD_IDX_REG_ADDR(eq)        HINIC_CSR_AEQ_PROD_IDX_ADDR((eq)->q_id)
+#define EQ_CONS_IDX_REG_ADDR(eq)        (((eq)->type == HINIC_AEQ) ? \
+			HINIC_CSR_AEQ_CONS_IDX_ADDR((eq)->q_id) : \
+			HINIC_CSR_CEQ_CONS_IDX_ADDR((eq)->q_id))
 
-#define EQ_HI_PHYS_ADDR_REG(eq, pg_num) \
-		HINIC_CSR_AEQ_HI_PHYS_ADDR_REG((eq)->q_id, pg_num)
+#define EQ_PROD_IDX_REG_ADDR(eq)        (((eq)->type == HINIC_AEQ) ? \
+			HINIC_CSR_AEQ_PROD_IDX_ADDR((eq)->q_id) : \
+			HINIC_CSR_CEQ_PROD_IDX_ADDR((eq)->q_id))
 
-#define EQ_LO_PHYS_ADDR_REG(eq, pg_num) \
-		HINIC_CSR_AEQ_LO_PHYS_ADDR_REG((eq)->q_id, pg_num)
+#define EQ_HI_PHYS_ADDR_REG(eq, pg_num) (((eq)->type == HINIC_AEQ) ? \
+			HINIC_CSR_AEQ_HI_PHYS_ADDR_REG((eq)->q_id, pg_num) : \
+			HINIC_CSR_CEQ_HI_PHYS_ADDR_REG((eq)->q_id, pg_num))
+
+#define EQ_LO_PHYS_ADDR_REG(eq, pg_num) (((eq)->type == HINIC_AEQ) ? \
+			HINIC_CSR_AEQ_LO_PHYS_ADDR_REG((eq)->q_id, pg_num) : \
+			HINIC_CSR_CEQ_LO_PHYS_ADDR_REG((eq)->q_id, pg_num))
 
 #define GET_EQ_ELEMENT(eq, idx)         \
 		((eq)->virt_addr[(idx) / (eq)->num_elem_in_pg] + \
@@ -53,8 +60,13 @@
 #define GET_AEQ_ELEM(eq, idx)           ((struct hinic_aeq_elem *) \
 					GET_EQ_ELEMENT(eq, idx))
 
+#define GET_CEQ_ELEM(eq, idx)           ((u32 *) \
+					 GET_EQ_ELEMENT(eq, idx))
+
 #define GET_CURR_AEQ_ELEM(eq)           GET_AEQ_ELEM(eq, (eq)->cons_idx)
 
+#define GET_CURR_CEQ_ELEM(eq)           GET_CEQ_ELEM(eq, (eq)->cons_idx)
+
 #define PAGE_IN_4K(page_size)           ((page_size) >> 12)
 #define EQ_SET_HW_PAGE_SIZE_VAL(eq)     (ilog2(PAGE_IN_4K((eq)->page_size)))
 
@@ -63,13 +75,29 @@
 
 #define EQ_MAX_PAGES                    8
 
+#define CEQE_TYPE_SHIFT                 23
+#define CEQE_TYPE_MASK                  0x7
+
+#define CEQE_TYPE(ceqe)                 (((ceqe) >> CEQE_TYPE_SHIFT) &  \
+					 CEQE_TYPE_MASK)
+
+#define CEQE_DATA_MASK                  0x3FFFFFF
+#define CEQE_DATA(ceqe)                 ((ceqe) & CEQE_DATA_MASK)
+
 #define aeq_to_aeqs(eq)                 \
 		container_of((eq) - (eq)->q_id, struct hinic_aeqs, aeq[0])
 
+#define ceq_to_ceqs(eq)                 \
+		container_of((eq) - (eq)->q_id, struct hinic_ceqs, ceq[0])
+
 #define work_to_aeq_work(work)          \
 		container_of(work, struct hinic_eq_work, work)
 
 #define DMA_ATTR_AEQ_DEFAULT            0
+#define DMA_ATTR_CEQ_DEFAULT            0
+
+/* No coalescence */
+#define THRESH_CEQ_DEFAULT              0
 
 enum eq_int_mode {
 	EQ_INT_MODE_ARMED,
@@ -118,6 +146,42 @@ void hinic_aeq_unregister_hw_cb(struct hinic_aeqs *aeqs,
 	hwe_cb->hwe_handler = NULL;
 }
 
+/**
+ * hinic_ceq_register_cb - register CEQ callback for specific event
+ * @ceqs: pointer to Completion eqs part of the chip
+ * @event: ceq event to register callback for it
+ * @handle: private data will be used by the callback
+ * @handler: callback function
+ **/
+void hinic_ceq_register_cb(struct hinic_ceqs *ceqs,
+			   enum hinic_ceq_type event, void *handle,
+			   void (*handler)(void *handle, u32 ceqe_data))
+{
+	struct hinic_ceq_cb *ceq_cb = &ceqs->ceq_cb[event];
+
+	ceq_cb->handler = handler;
+	ceq_cb->handle = handle;
+	ceq_cb->ceqe_state = HINIC_EQE_ENABLED;
+}
+
+/**
+ * hinic_ceq_unregister_cb - unregister the CEQ callback for specific event
+ * @ceqs: pointer to Completion eqs part of the chip
+ * @event: ceq event to unregister callback for it
+ **/
+void hinic_ceq_unregister_cb(struct hinic_ceqs *ceqs,
+			     enum hinic_ceq_type event)
+{
+	struct hinic_ceq_cb *ceq_cb = &ceqs->ceq_cb[event];
+
+	ceq_cb->ceqe_state &= ~HINIC_EQE_ENABLED;
+
+	while (ceq_cb->ceqe_state & HINIC_EQE_RUNNING)
+		schedule();
+
+	ceq_cb->handler = NULL;
+}
+
 static u8 eq_cons_idx_checksum_set(u32 val)
 {
 	u8 checksum = 0;
@@ -216,6 +280,70 @@ static void aeq_irq_handler(struct hinic_eq *eq)
 }
 
 /**
+ * ceq_event_handler - handler for the ceq events
+ * @ceqs: ceqs part of the chip
+ * @ceqe: ceq element that describes the event
+ **/
+static void ceq_event_handler(struct hinic_ceqs *ceqs, u32 ceqe)
+{
+	struct hinic_hwif *hwif = ceqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_ceq_cb *ceq_cb;
+	enum hinic_ceq_type event;
+	unsigned long eqe_state;
+
+	event = CEQE_TYPE(ceqe);
+	if (event >= HINIC_MAX_CEQ_EVENTS) {
+		dev_err(&pdev->dev, "Unknown CEQ event, event = %d\n", event);
+		return;
+	}
+
+	ceq_cb = &ceqs->ceq_cb[event];
+
+	eqe_state = cmpxchg(&ceq_cb->ceqe_state,
+			    HINIC_EQE_ENABLED,
+			    HINIC_EQE_ENABLED | HINIC_EQE_RUNNING);
+
+	if ((eqe_state == HINIC_EQE_ENABLED) && (ceq_cb->handler))
+		ceq_cb->handler(ceq_cb->handle, CEQE_DATA(ceqe));
+	else
+		dev_err(&pdev->dev, "Unhandled CEQ Event %d\n", event);
+
+	ceq_cb->ceqe_state &= ~HINIC_EQE_RUNNING;
+}
+
+/**
+ * ceq_irq_handler - handler for the CEQ event
+ * @eq: the Completion Event Queue that received the event
+ **/
+static void ceq_irq_handler(struct hinic_eq *eq)
+{
+	struct hinic_ceqs *ceqs = ceq_to_ceqs(eq);
+	u32 ceqe;
+	int i;
+
+	for (i = 0; i < eq->q_len; i++) {
+		ceqe = *(GET_CURR_CEQ_ELEM(eq));
+
+		/* Data in HW is in Big endian Format */
+		ceqe = be32_to_cpu(ceqe);
+
+		/* HW toggles the wrapped bit, when it adds eq element event */
+		if (HINIC_EQ_ELEM_DESC_GET(ceqe, WRAPPED) == eq->wrapped)
+			break;
+
+		ceq_event_handler(ceqs, ceqe);
+
+		eq->cons_idx++;
+
+		if (eq->cons_idx == eq->q_len) {
+			eq->cons_idx = 0;
+			eq->wrapped = !eq->wrapped;
+		}
+	}
+}
+
+/**
  * eq_irq_handler - handler for the EQ event
  * @data: the Event Queue that received the event
  **/
@@ -225,6 +353,8 @@ static void eq_irq_handler(void *data)
 
 	if (eq->type == HINIC_AEQ)
 		aeq_irq_handler(eq);
+	else if (eq->type == HINIC_CEQ)
+		ceq_irq_handler(eq);
 
 	eq_update_ci(eq);
 }
@@ -243,6 +373,17 @@ static void eq_irq_work(struct work_struct *work)
 }
 
 /**
+ * ceq_tasklet - the tasklet of the EQ that received the event
+ * @ceq_data: the eq
+ **/
+static void ceq_tasklet(unsigned long ceq_data)
+{
+	struct hinic_eq *ceq = (struct hinic_eq *)ceq_data;
+
+	eq_irq_handler(ceq);
+}
+
+/**
  * aeq_interrupt - aeq interrupt handler
  * @irq: irq number
  * @data: the Async Event Queue that collected the event
@@ -264,6 +405,24 @@ static irqreturn_t aeq_interrupt(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+/**
+ * ceq_interrupt - ceq interrupt handler
+ * @irq: irq number
+ * @data: the Completion Event Queue that collected the event
+ **/
+static irqreturn_t ceq_interrupt(int irq, void *data)
+{
+	struct hinic_eq *ceq = (struct hinic_eq *)data;
+	struct hinic_hwif *hwif = ceq->hwif;
+
+	/* clear resend timer cnt register */
+	hinic_msix_attr_cnt_clear(hwif, ceq->msix_entry.entry);
+
+	tasklet_schedule(&ceq->ceq_tasklet);
+
+	return IRQ_HANDLED;
+}
+
 void set_ctrl0(struct hinic_eq *eq)
 {
 	struct msix_entry *msix_entry = &eq->msix_entry;
@@ -291,6 +450,28 @@ void set_ctrl0(struct hinic_eq *eq)
 		val |= ctrl0;
 
 		hinic_hwif_write_reg(hwif, addr, val);
+	} else if (type == HINIC_CEQ) {
+		/* RMW Ctrl0 */
+		addr = HINIC_CSR_CEQ_CTRL_0_ADDR(eq->q_id);
+
+		val = hinic_hwif_read_reg(hwif, addr);
+
+		val = HINIC_CEQ_CTRL_0_CLEAR(val, INTR_IDX)     &
+		      HINIC_CEQ_CTRL_0_CLEAR(val, DMA_ATTR)     &
+		      HINIC_CEQ_CTRL_0_CLEAR(val, KICK_THRESH)  &
+		      HINIC_CEQ_CTRL_0_CLEAR(val, PCI_INTF_IDX) &
+		      HINIC_CEQ_CTRL_0_CLEAR(val, INTR_MODE);
+
+		ctrl0 = HINIC_CEQ_CTRL_0_SET(msix_entry->entry, INTR_IDX)     |
+			HINIC_CEQ_CTRL_0_SET(DMA_ATTR_CEQ_DEFAULT, DMA_ATTR)  |
+			HINIC_CEQ_CTRL_0_SET(THRESH_CEQ_DEFAULT, KICK_THRESH) |
+			HINIC_CEQ_CTRL_0_SET(HINIC_HWIF_PCI_INTF(hwif),
+					     PCI_INTF_IDX)                    |
+			HINIC_CEQ_CTRL_0_SET(EQ_INT_MODE_ARMED, INTR_MODE);
+
+		val |= ctrl0;
+
+		hinic_hwif_write_reg(hwif, addr, val);
 	}
 }
 
@@ -321,6 +502,23 @@ void set_ctrl1(struct hinic_eq *eq)
 		val |= ctrl1;
 
 		hinic_hwif_write_reg(hwif, addr, val);
+	} else if (type == HINIC_CEQ) {
+		/* RMW Ctrl1 */
+		addr = HINIC_CSR_CEQ_CTRL_1_ADDR(eq->q_id);
+
+		page_size_val = EQ_SET_HW_PAGE_SIZE_VAL(eq);
+
+		val = hinic_hwif_read_reg(hwif, addr);
+
+		val = HINIC_CEQ_CTRL_1_CLEAR(val, LEN) &
+		      HINIC_CEQ_CTRL_1_CLEAR(val, PAGE_SIZE);
+
+		ctrl1 = HINIC_CEQ_CTRL_1_SET(eq->q_len, LEN) |
+			HINIC_CEQ_CTRL_1_SET(page_size_val, PAGE_SIZE);
+
+		val |= ctrl1;
+
+		hinic_hwif_write_reg(hwif, addr, val);
 	}
 }
 
@@ -353,6 +551,24 @@ static void aeq_elements_init(struct hinic_eq *eq, u32 init_val)
 }
 
 /**
+ * ceq_elements_init - Initialize all the elements in the ceq
+ * @eq: the event queue
+ * @init_val: value to init with it the elements
+ **/
+static void ceq_elements_init(struct hinic_eq *eq, u32 init_val)
+{
+	u32 *ceqe;
+	int i;
+
+	for (i = 0; i < eq->q_len; i++) {
+		ceqe = GET_CEQ_ELEM(eq, i);
+		*(ceqe) = cpu_to_be32(init_val);
+	}
+
+	wmb();  /* Write the initilzation values */
+}
+
+/**
  * alloc_eq_pages - allocate the pages for the queue
  * @eq: the event queue
  *
@@ -403,6 +619,8 @@ static int alloc_eq_pages(struct hinic_eq *eq)
 
 	if (eq->type == HINIC_AEQ)
 		aeq_elements_init(eq, init_val);
+	else if (eq->type == HINIC_CEQ)
+		ceq_elements_init(eq, init_val);
 
 	return 0;
 
@@ -472,6 +690,8 @@ static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
 
 	if (type == HINIC_AEQ) {
 		eq->elem_size = HINIC_AEQE_SIZE;
+	} else if (type == HINIC_CEQ) {
+		eq->elem_size = HINIC_CEQE_SIZE;
 	} else {
 		dev_err(&pdev->dev, "Invalid EQ type\n");
 		return -EINVAL;
@@ -505,6 +725,9 @@ static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
 		struct hinic_eq_work *aeq_work = &eq->aeq_work;
 
 		INIT_WORK(&aeq_work->work, eq_irq_work);
+	} else if (type == HINIC_CEQ) {
+		tasklet_init(&eq->ceq_tasklet, ceq_tasklet,
+			     (unsigned long)eq);
 	}
 
 	/* set the attributes of the msix entry */
@@ -518,6 +741,9 @@ static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
 	if (type == HINIC_AEQ)
 		err = request_irq(entry.vector, aeq_interrupt, 0,
 				  "hinic_aeq", eq);
+	else if (type == HINIC_CEQ)
+		err = request_irq(entry.vector, ceq_interrupt, 0,
+				  "hinic_ceq", eq);
 
 	if (err) {
 		dev_err(&pdev->dev, "Failed to request irq for the EQ\n");
@@ -545,6 +771,8 @@ static void remove_eq(struct hinic_eq *eq)
 		struct hinic_eq_work *aeq_work = &eq->aeq_work;
 
 		cancel_work_sync(&aeq_work->work);
+	} else if (eq->type == HINIC_CEQ) {
+		tasklet_kill(&eq->ceq_tasklet);
 	}
 
 	free_eq_pages(eq);
@@ -607,3 +835,54 @@ void hinic_aeqs_free(struct hinic_aeqs *aeqs)
 
 	destroy_workqueue(aeqs->workq);
 }
+
+/**
+ * hinic_ceqs_init - init all the ceqs
+ * @ceqs: ceqs part of the chip
+ * @hwif: the hardware interface of a pci function device
+ * @num_ceqs: number of CEQs
+ * @q_len: number of EQ elements
+ * @page_size: the page size of the event queue
+ * @msix_entries: msix entries associated with the event queues
+ *
+ * Return 0 - Success, Negative - Failure
+ **/
+int hinic_ceqs_init(struct hinic_ceqs *ceqs, struct hinic_hwif *hwif,
+		    int num_ceqs, u32 q_len, u32 page_size,
+		    struct msix_entry *msix_entries)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	int i, q_id, err;
+
+	ceqs->hwif = hwif;
+	ceqs->num_ceqs = num_ceqs;
+
+	for (q_id = 0; q_id < num_ceqs; q_id++) {
+		err = init_eq(&ceqs->ceq[q_id], hwif, HINIC_CEQ, q_id, q_len,
+			      page_size, msix_entries[q_id]);
+		if (err) {
+			dev_err(&pdev->dev, "Failed to init ceq %d\n", q_id);
+			goto err_init_ceq;
+		}
+	}
+
+	return 0;
+
+err_init_ceq:
+	for (i = 0; i < q_id; i++)
+		remove_eq(&ceqs->ceq[i]);
+
+	return err;
+}
+
+/**
+ * hinic_ceqs_free - free all the ceqs
+ * @ceqs: ceqs part of the chip
+ **/
+void hinic_ceqs_free(struct hinic_ceqs *ceqs)
+{
+	int q_id;
+
+	for (q_id = 0; q_id < ceqs->num_ceqs; q_id++)
+		remove_eq(&ceqs->ceq[q_id]);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
index ca584c0..ecb9c2b 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
@@ -21,6 +21,7 @@
 #include <linux/pci.h>
 #include <linux/sizes.h>
 #include <linux/bitops.h>
+#include <linux/interrupt.h>
 
 #include "hinic_hw_if.h"
 
@@ -58,6 +59,40 @@
 			((val) & (~(HINIC_AEQ_CTRL_1_##member##_MASK \
 			 << HINIC_AEQ_CTRL_1_##member##_SHIFT)))
 
+#define HINIC_CEQ_CTRL_0_INTR_IDX_SHIFT         0
+#define HINIC_CEQ_CTRL_0_DMA_ATTR_SHIFT         12
+#define HINIC_CEQ_CTRL_0_KICK_THRESH_SHIFT      20
+#define HINIC_CEQ_CTRL_0_PCI_INTF_IDX_SHIFT     24
+#define HINIC_CEQ_CTRL_0_INTR_MODE_SHIFT        31
+
+#define HINIC_CEQ_CTRL_0_INTR_IDX_MASK          0x3FF
+#define HINIC_CEQ_CTRL_0_DMA_ATTR_MASK          0x3F
+#define HINIC_CEQ_CTRL_0_KICK_THRESH_MASK       0xF
+#define HINIC_CEQ_CTRL_0_PCI_INTF_IDX_MASK      0x3
+#define HINIC_CEQ_CTRL_0_INTR_MODE_MASK         0x1
+
+#define HINIC_CEQ_CTRL_0_SET(val, member)       \
+			(((u32)(val) & HINIC_CEQ_CTRL_0_##member##_MASK) << \
+			 HINIC_CEQ_CTRL_0_##member##_SHIFT)
+
+#define HINIC_CEQ_CTRL_0_CLEAR(val, member)     \
+			((val) & (~(HINIC_CEQ_CTRL_0_##member##_MASK \
+			 << HINIC_CEQ_CTRL_0_##member##_SHIFT)))
+
+#define HINIC_CEQ_CTRL_1_LEN_SHIFT              0
+#define HINIC_CEQ_CTRL_1_PAGE_SIZE_SHIFT        28
+
+#define HINIC_CEQ_CTRL_1_LEN_MASK               0x1FFFFF
+#define HINIC_CEQ_CTRL_1_PAGE_SIZE_MASK         0xF
+
+#define HINIC_CEQ_CTRL_1_SET(val, member)       \
+			(((u32)(val) & HINIC_CEQ_CTRL_1_##member##_MASK) << \
+			 HINIC_CEQ_CTRL_1_##member##_SHIFT)
+
+#define HINIC_CEQ_CTRL_1_CLEAR(val, member)     \
+			((val) & (~(HINIC_CEQ_CTRL_1_##member##_MASK \
+			 << HINIC_CEQ_CTRL_1_##member##_SHIFT)))
+
 #define HINIC_EQ_ELEM_DESC_TYPE_SHIFT           0
 #define HINIC_EQ_ELEM_DESC_SRC_SHIFT            7
 #define HINIC_EQ_ELEM_DESC_SIZE_SHIFT           8
@@ -95,14 +130,17 @@
 			 << HINIC_EQ_CI_##member##_SHIFT)))
 
 #define HINIC_MAX_AEQS                  4
+#define HINIC_MAX_CEQS                  32
 
 #define HINIC_AEQE_SIZE                 64
+#define HINIC_CEQE_SIZE                 4
 
 #define HINIC_AEQE_DESC_SIZE            4
 #define HINIC_AEQE_DATA_SIZE            \
 			(HINIC_AEQE_SIZE - HINIC_AEQE_DESC_SIZE)
 
 #define HINIC_DEFAULT_AEQ_LEN           64
+#define HINIC_DEFAULT_CEQ_LEN           1024
 
 #define HINIC_EQ_PAGE_SIZE              SZ_4K
 
@@ -110,6 +148,7 @@
 
 enum hinic_eq_type {
 	HINIC_AEQ,
+	HINIC_CEQ,
 };
 
 enum hinic_aeq_type {
@@ -118,6 +157,12 @@ enum hinic_aeq_type {
 	HINIC_MAX_AEQ_EVENTS,
 };
 
+enum hinic_ceq_type {
+	HINIC_CEQ_CMDQ = 3,
+
+	HINIC_MAX_CEQ_EVENTS,
+};
+
 enum hinic_eqe_state {
 	HINIC_EQE_ENABLED = BIT(0),
 	HINIC_EQE_RUNNING = BIT(1),
@@ -154,6 +199,8 @@ struct hinic_eq {
 	void                    **virt_addr;
 
 	struct hinic_eq_work    aeq_work;
+
+	struct tasklet_struct   ceq_tasklet;
 };
 
 struct hinic_hw_event_cb {
@@ -173,6 +220,21 @@ struct hinic_aeqs {
 	struct workqueue_struct *workq;
 };
 
+struct hinic_ceq_cb {
+	void    (*handler)(void *handle, u32 ceqe_data);
+	void                    *handle;
+	enum hinic_eqe_state    ceqe_state;
+};
+
+struct hinic_ceqs {
+	struct hinic_hwif       *hwif;
+
+	struct hinic_eq         ceq[HINIC_MAX_CEQS];
+	int                     num_ceqs;
+
+	struct hinic_ceq_cb     ceq_cb[HINIC_MAX_CEQ_EVENTS];
+};
+
 void hinic_aeq_register_hw_cb(struct hinic_aeqs *aeqs,
 			      enum hinic_aeq_type event, void *handle,
 			      void (*hwe_handler)(void *handle, void *data,
@@ -181,10 +243,23 @@ void hinic_aeq_register_hw_cb(struct hinic_aeqs *aeqs,
 void hinic_aeq_unregister_hw_cb(struct hinic_aeqs *aeqs,
 				enum hinic_aeq_type event);
 
+void hinic_ceq_register_cb(struct hinic_ceqs *ceqs,
+			   enum hinic_ceq_type event, void *handle,
+			   void (*ceq_cb)(void *handle, u32 ceqe_data));
+
+void hinic_ceq_unregister_cb(struct hinic_ceqs *ceqs,
+			     enum hinic_ceq_type event);
+
 int hinic_aeqs_init(struct hinic_aeqs *aeqs, struct hinic_hwif *hwif,
 		    int num_aeqs, u32 q_len, u32 page_size,
 		    struct msix_entry *msix_entries);
 
 void hinic_aeqs_free(struct hinic_aeqs *aeqs);
 
+int hinic_ceqs_init(struct hinic_ceqs *ceqs, struct hinic_hwif *hwif,
+		    int num_ceqs, u32 q_len, u32 page_size,
+		    struct msix_entry *msix_entries);
+
+void hinic_ceqs_free(struct hinic_ceqs *ceqs);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
index bb4b93f..8e58976 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -25,6 +25,7 @@
 #include <linux/err.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
 #include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_cmdq.h"
@@ -455,10 +456,18 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 	func_to_io->qps = NULL;
 	func_to_io->max_qps = max_qps;
 
+	err = hinic_ceqs_init(&func_to_io->ceqs, hwif, num_ceqs,
+			      HINIC_DEFAULT_CEQ_LEN, HINIC_EQ_PAGE_SIZE,
+			      ceq_msix_entries);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init CEQs\n");
+		return err;
+	}
+
 	err = hinic_wqs_alloc(&func_to_io->wqs, 2 * max_qps, hwif);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to allocate WQS for IO\n");
-		return err;
+		goto err_wqs_alloc;
 	}
 
 	func_to_io->db_base = pci_ioremap_bar(pdev, HINIC_PCI_DB_BAR);
@@ -499,6 +508,9 @@ int hinic_io_init(struct hinic_func_to_io *func_to_io,
 
 err_db_ioremap:
 	hinic_wqs_free(&func_to_io->wqs);
+
+err_wqs_alloc:
+	hinic_ceqs_free(&func_to_io->ceqs);
 	return err;
 }
 
@@ -517,4 +529,5 @@ void hinic_io_free(struct hinic_func_to_io *func_to_io)
 
 	iounmap(func_to_io->db_base);
 	hinic_wqs_free(&func_to_io->wqs);
+	hinic_ceqs_free(&func_to_io->ceqs);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
index 60d77b34..cfc21ba 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -22,6 +22,7 @@
 #include <linux/sizes.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_cmdq.h"
 #include "hinic_hw_qp.h"
@@ -46,6 +47,8 @@ struct hinic_free_db_area {
 struct hinic_func_to_io {
 	struct hinic_hwif       *hwif;
 
+	struct hinic_ceqs       ceqs;
+
 	struct hinic_wqs        wqs;
 
 	struct hinic_wq         *sq_wq;
-- 
1.9.1
