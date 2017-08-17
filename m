From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V5 net-next 07/21] net-next/hinic: Add aeqs
Date: Thu, 17 Aug 2017 19:52:48 +0800
Message-ID: <6da7c3a8dd75eef2537f600dcd926e6b0c186e37.1502970631.git.aviad.krawczyk@huawei.com>
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

Handle aeq elements that are accumulated on the aeq by calling the
registered handler for the specific event.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h |  49 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c | 464 ++++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h |  81 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c  |  91 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h  |  46 +++
 5 files changed, 729 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index ebbf054..52eb89c 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -65,4 +65,53 @@
 #define HINIC_CSR_API_CMD_STATUS_ADDR(idx)              \
 	(HINIC_CSR_API_CMD_BASE + 0x30 + (idx) * HINIC_CSR_API_CMD_STRIDE)
 
+/* MSI-X registers */
+#define HINIC_CSR_MSIX_CTRL_BASE                        0x2000
+#define HINIC_CSR_MSIX_CNT_BASE                         0x2004
+
+#define HINIC_CSR_MSIX_STRIDE                           0x8
+
+#define HINIC_CSR_MSIX_CTRL_ADDR(idx)                   \
+	(HINIC_CSR_MSIX_CTRL_BASE + (idx) * HINIC_CSR_MSIX_STRIDE)
+
+#define HINIC_CSR_MSIX_CNT_ADDR(idx)                    \
+	(HINIC_CSR_MSIX_CNT_BASE + (idx) * HINIC_CSR_MSIX_STRIDE)
+
+/* EQ registers */
+#define HINIC_AEQ_MTT_OFF_BASE_ADDR                     0x200
+
+#define HINIC_EQ_MTT_OFF_STRIDE                         0x40
+
+#define HINIC_CSR_AEQ_MTT_OFF(id)                       \
+	(HINIC_AEQ_MTT_OFF_BASE_ADDR + (id) * HINIC_EQ_MTT_OFF_STRIDE)
+
+#define HINIC_CSR_EQ_PAGE_OFF_STRIDE                    8
+
+#define HINIC_CSR_AEQ_HI_PHYS_ADDR_REG(q_id, pg_num)    \
+	(HINIC_CSR_AEQ_MTT_OFF(q_id) + \
+	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE)
+
+#define HINIC_CSR_AEQ_LO_PHYS_ADDR_REG(q_id, pg_num)    \
+	(HINIC_CSR_AEQ_MTT_OFF(q_id) + \
+	 (pg_num) * HINIC_CSR_EQ_PAGE_OFF_STRIDE + 4)
+
+#define HINIC_AEQ_CTRL_0_ADDR_BASE                      0xE00
+#define HINIC_AEQ_CTRL_1_ADDR_BASE                      0xE04
+#define HINIC_AEQ_CONS_IDX_ADDR_BASE                    0xE08
+#define HINIC_AEQ_PROD_IDX_ADDR_BASE                    0xE0C
+
+#define HINIC_EQ_OFF_STRIDE                             0x80
+
+#define HINIC_CSR_AEQ_CTRL_0_ADDR(idx)                  \
+	(HINIC_AEQ_CTRL_0_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_AEQ_CTRL_1_ADDR(idx)                  \
+	(HINIC_AEQ_CTRL_1_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_AEQ_CONS_IDX_ADDR(idx)                \
+	(HINIC_AEQ_CONS_IDX_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
+#define HINIC_CSR_AEQ_PROD_IDX_ADDR(idx)                \
+	(HINIC_AEQ_PROD_IDX_ADDR_BASE + (idx) * HINIC_EQ_OFF_STRIDE)
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
index a099d20..a53d5b3 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
@@ -13,17 +13,74 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
 #include <linux/device.h>
 #include <linux/workqueue.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/dma-mapping.h>
+#include <linux/log2.h>
+#include <asm/byteorder.h>
+#include <asm/barrier.h>
 
+#include "hinic_hw_csr.h"
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
 
 #define HINIC_EQS_WQ_NAME                       "hinic_eqs"
 
+#define GET_EQ_NUM_PAGES(eq, pg_size)           \
+		(ALIGN((eq)->q_len * (eq)->elem_size, pg_size) / (pg_size))
+
+#define GET_EQ_NUM_ELEMS_IN_PG(eq, pg_size)     ((pg_size) / (eq)->elem_size)
+
+#define EQ_CONS_IDX_REG_ADDR(eq)        HINIC_CSR_AEQ_CONS_IDX_ADDR((eq)->q_id)
+#define EQ_PROD_IDX_REG_ADDR(eq)        HINIC_CSR_AEQ_PROD_IDX_ADDR((eq)->q_id)
+
+#define EQ_HI_PHYS_ADDR_REG(eq, pg_num) \
+		HINIC_CSR_AEQ_HI_PHYS_ADDR_REG((eq)->q_id, pg_num)
+
+#define EQ_LO_PHYS_ADDR_REG(eq, pg_num) \
+		HINIC_CSR_AEQ_LO_PHYS_ADDR_REG((eq)->q_id, pg_num)
+
+#define GET_EQ_ELEMENT(eq, idx)         \
+		((eq)->virt_addr[(idx) / (eq)->num_elem_in_pg] + \
+		 (((idx) & ((eq)->num_elem_in_pg - 1)) * (eq)->elem_size))
+
+#define GET_AEQ_ELEM(eq, idx)           ((struct hinic_aeq_elem *) \
+					GET_EQ_ELEMENT(eq, idx))
+
+#define GET_CURR_AEQ_ELEM(eq)           GET_AEQ_ELEM(eq, (eq)->cons_idx)
+
+#define PAGE_IN_4K(page_size)           ((page_size) >> 12)
+#define EQ_SET_HW_PAGE_SIZE_VAL(eq)     (ilog2(PAGE_IN_4K((eq)->page_size)))
+
+#define ELEMENT_SIZE_IN_32B(eq)         (((eq)->elem_size) >> 5)
+#define EQ_SET_HW_ELEM_SIZE_VAL(eq)     (ilog2(ELEMENT_SIZE_IN_32B(eq)))
+
+#define EQ_MAX_PAGES                    8
+
+#define aeq_to_aeqs(eq)                 \
+		container_of((eq) - (eq)->q_id, struct hinic_aeqs, aeq[0])
+
+#define work_to_aeq_work(work)          \
+		container_of(work, struct hinic_eq_work, work)
+
+#define DMA_ATTR_AEQ_DEFAULT            0
+
+enum eq_int_mode {
+	EQ_INT_MODE_ARMED,
+	EQ_INT_MODE_ALWAYS
+};
+
+enum eq_arm_state {
+	EQ_NOT_ARMED,
+	EQ_ARMED
+};
+
 /**
  * hinic_aeq_register_hw_cb - register AEQ callback for specific event
  * @aeqs: pointer to Async eqs of the chip
@@ -61,6 +118,326 @@ void hinic_aeq_unregister_hw_cb(struct hinic_aeqs *aeqs,
 	hwe_cb->hwe_handler = NULL;
 }
 
+static u8 eq_cons_idx_checksum_set(u32 val)
+{
+	u8 checksum = 0;
+	int idx;
+
+	for (idx = 0; idx < 32; idx += 4)
+		checksum ^= ((val >> idx) & 0xF);
+
+	return (checksum & 0xF);
+}
+
+/**
+ * eq_update_ci - update the HW cons idx of event queue
+ * @eq: the event queue to update the cons idx for
+ **/
+static void eq_update_ci(struct hinic_eq *eq)
+{
+	u32 val, addr = EQ_CONS_IDX_REG_ADDR(eq);
+
+	/* Read Modify Write */
+	val = hinic_hwif_read_reg(eq->hwif, addr);
+
+	val = HINIC_EQ_CI_CLEAR(val, IDX)       &
+	      HINIC_EQ_CI_CLEAR(val, WRAPPED)   &
+	      HINIC_EQ_CI_CLEAR(val, INT_ARMED) &
+	      HINIC_EQ_CI_CLEAR(val, XOR_CHKSUM);
+
+	val |= HINIC_EQ_CI_SET(eq->cons_idx, IDX)    |
+	       HINIC_EQ_CI_SET(eq->wrapped, WRAPPED) |
+	       HINIC_EQ_CI_SET(EQ_ARMED, INT_ARMED);
+
+	val |= HINIC_EQ_CI_SET(eq_cons_idx_checksum_set(val), XOR_CHKSUM);
+
+	hinic_hwif_write_reg(eq->hwif, addr, val);
+}
+
+/**
+ * aeq_irq_handler - handler for the AEQ event
+ * @eq: the Async Event Queue that received the event
+ **/
+static void aeq_irq_handler(struct hinic_eq *eq)
+{
+	struct hinic_aeqs *aeqs = aeq_to_aeqs(eq);
+	struct hinic_hwif *hwif = aeqs->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_aeq_elem *aeqe_curr;
+	struct hinic_hw_event_cb *hwe_cb;
+	enum hinic_aeq_type event;
+	unsigned long eqe_state;
+	u32 aeqe_desc;
+	int i, size;
+
+	for (i = 0; i < eq->q_len; i++) {
+		aeqe_curr = GET_CURR_AEQ_ELEM(eq);
+
+		/* Data in HW is in Big endian Format */
+		aeqe_desc = be32_to_cpu(aeqe_curr->desc);
+
+		/* HW toggles the wrapped bit, when it adds eq element */
+		if (HINIC_EQ_ELEM_DESC_GET(aeqe_desc, WRAPPED) == eq->wrapped)
+			break;
+
+		event = HINIC_EQ_ELEM_DESC_GET(aeqe_desc, TYPE);
+		if (event >= HINIC_MAX_AEQ_EVENTS) {
+			dev_err(&pdev->dev, "Unknown AEQ Event %d\n", event);
+			return;
+		}
+
+		if (!HINIC_EQ_ELEM_DESC_GET(aeqe_desc, SRC)) {
+			hwe_cb = &aeqs->hwe_cb[event];
+
+			size = HINIC_EQ_ELEM_DESC_GET(aeqe_desc, SIZE);
+
+			eqe_state = cmpxchg(&hwe_cb->hwe_state,
+					    HINIC_EQE_ENABLED,
+					    HINIC_EQE_ENABLED |
+					    HINIC_EQE_RUNNING);
+			if ((eqe_state == HINIC_EQE_ENABLED) &&
+			    (hwe_cb->hwe_handler))
+				hwe_cb->hwe_handler(hwe_cb->handle,
+						    aeqe_curr->data, size);
+			else
+				dev_err(&pdev->dev, "Unhandled AEQ Event %d\n",
+					event);
+
+			hwe_cb->hwe_state &= ~HINIC_EQE_RUNNING;
+		}
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
+ * eq_irq_handler - handler for the EQ event
+ * @data: the Event Queue that received the event
+ **/
+static void eq_irq_handler(void *data)
+{
+	struct hinic_eq *eq = (struct hinic_eq *)data;
+
+	if (eq->type == HINIC_AEQ)
+		aeq_irq_handler(eq);
+
+	eq_update_ci(eq);
+}
+
+/**
+ * eq_irq_work - the work of the EQ that received the event
+ * @work: the work struct that is associated with the EQ
+ **/
+static void eq_irq_work(struct work_struct *work)
+{
+	struct hinic_eq_work *aeq_work = work_to_aeq_work(work);
+	struct hinic_eq *aeq;
+
+	aeq = (struct hinic_eq *)aeq_work->data;
+	eq_irq_handler(aeq);
+}
+
+/**
+ * aeq_interrupt - aeq interrupt handler
+ * @irq: irq number
+ * @data: the Async Event Queue that collected the event
+ **/
+static irqreturn_t aeq_interrupt(int irq, void *data)
+{
+	struct hinic_eq *aeq = (struct hinic_eq *)data;
+	struct hinic_aeqs *aeqs = aeq_to_aeqs(aeq);
+	struct hinic_eq_work *aeq_work;
+
+	/* clear resend timer cnt register */
+	hinic_msix_attr_cnt_clear(aeq->hwif, aeq->msix_entry.entry);
+
+	aeq_work = &aeq->aeq_work;
+	aeq_work->data = aeq;
+
+	queue_work(aeqs->workq, &aeq_work->work);
+
+	return IRQ_HANDLED;
+}
+
+void set_ctrl0(struct hinic_eq *eq)
+{
+	struct msix_entry *msix_entry = &eq->msix_entry;
+	struct  hinic_hwif *hwif = eq->hwif;
+	enum hinic_eq_type type = eq->type;
+	u32 addr, val, ctrl0;
+
+	if (type == HINIC_AEQ) {
+		/* RMW Ctrl0 */
+		addr = HINIC_CSR_AEQ_CTRL_0_ADDR(eq->q_id);
+
+		val = hinic_hwif_read_reg(hwif, addr);
+
+		val = HINIC_AEQ_CTRL_0_CLEAR(val, INT_IDX)      &
+		      HINIC_AEQ_CTRL_0_CLEAR(val, DMA_ATTR)     &
+		      HINIC_AEQ_CTRL_0_CLEAR(val, PCI_INTF_IDX) &
+		      HINIC_AEQ_CTRL_0_CLEAR(val, INT_MODE);
+
+		ctrl0 = HINIC_AEQ_CTRL_0_SET(msix_entry->entry, INT_IDX)     |
+			HINIC_AEQ_CTRL_0_SET(DMA_ATTR_AEQ_DEFAULT, DMA_ATTR) |
+			HINIC_AEQ_CTRL_0_SET(HINIC_HWIF_PCI_INTF(hwif),
+					     PCI_INTF_IDX)                   |
+			HINIC_AEQ_CTRL_0_SET(EQ_INT_MODE_ARMED, INT_MODE);
+
+		val |= ctrl0;
+
+		hinic_hwif_write_reg(hwif, addr, val);
+	}
+}
+
+void set_ctrl1(struct hinic_eq *eq)
+{
+	struct  hinic_hwif *hwif = eq->hwif;
+	enum hinic_eq_type type = eq->type;
+	u32 page_size_val, elem_size;
+	u32 addr, val, ctrl1;
+
+	if (type == HINIC_AEQ) {
+		/* RMW Ctrl1 */
+		addr = HINIC_CSR_AEQ_CTRL_1_ADDR(eq->q_id);
+
+		page_size_val = EQ_SET_HW_PAGE_SIZE_VAL(eq);
+		elem_size = EQ_SET_HW_ELEM_SIZE_VAL(eq);
+
+		val = hinic_hwif_read_reg(hwif, addr);
+
+		val = HINIC_AEQ_CTRL_1_CLEAR(val, LEN)          &
+		      HINIC_AEQ_CTRL_1_CLEAR(val, ELEM_SIZE)    &
+		      HINIC_AEQ_CTRL_1_CLEAR(val, PAGE_SIZE);
+
+		ctrl1 = HINIC_AEQ_CTRL_1_SET(eq->q_len, LEN)            |
+			HINIC_AEQ_CTRL_1_SET(elem_size, ELEM_SIZE)      |
+			HINIC_AEQ_CTRL_1_SET(page_size_val, PAGE_SIZE);
+
+		val |= ctrl1;
+
+		hinic_hwif_write_reg(hwif, addr, val);
+	}
+}
+
+/**
+ * set_eq_ctrls - setting eq's ctrl registers
+ * @eq: the Event Queue for setting
+ **/
+static void set_eq_ctrls(struct hinic_eq *eq)
+{
+	set_ctrl0(eq);
+	set_ctrl1(eq);
+}
+
+/**
+ * aeq_elements_init - initialize all the elements in the aeq
+ * @eq: the Async Event Queue
+ * @init_val: value to initialize the elements with it
+ **/
+static void aeq_elements_init(struct hinic_eq *eq, u32 init_val)
+{
+	struct hinic_aeq_elem *aeqe;
+	int i;
+
+	for (i = 0; i < eq->q_len; i++) {
+		aeqe = GET_AEQ_ELEM(eq, i);
+		aeqe->desc = cpu_to_be32(init_val);
+	}
+
+	wmb();  /* Write the initilzation values */
+}
+
+/**
+ * alloc_eq_pages - allocate the pages for the queue
+ * @eq: the event queue
+ *
+ * Return 0 - Success, Negative - Failure
+ **/
+static int alloc_eq_pages(struct hinic_eq *eq)
+{
+	struct hinic_hwif *hwif = eq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u32 init_val, addr, val;
+	size_t addr_size;
+	int err, pg;
+
+	addr_size = eq->num_pages * sizeof(*eq->dma_addr);
+	eq->dma_addr = devm_kzalloc(&pdev->dev, addr_size, GFP_KERNEL);
+	if (!eq->dma_addr)
+		return -ENOMEM;
+
+	addr_size = eq->num_pages * sizeof(*eq->virt_addr);
+	eq->virt_addr = devm_kzalloc(&pdev->dev, addr_size, GFP_KERNEL);
+	if (!eq->virt_addr) {
+		err = -ENOMEM;
+		goto err_virt_addr_alloc;
+	}
+
+	for (pg = 0; pg < eq->num_pages; pg++) {
+		eq->virt_addr[pg] = dma_zalloc_coherent(&pdev->dev,
+							eq->page_size,
+							&eq->dma_addr[pg],
+							GFP_KERNEL);
+		if (!eq->virt_addr[pg]) {
+			err = -ENOMEM;
+			goto err_dma_alloc;
+		}
+
+		addr = EQ_HI_PHYS_ADDR_REG(eq, pg);
+		val = upper_32_bits(eq->dma_addr[pg]);
+
+		hinic_hwif_write_reg(hwif, addr, val);
+
+		addr = EQ_LO_PHYS_ADDR_REG(eq, pg);
+		val = lower_32_bits(eq->dma_addr[pg]);
+
+		hinic_hwif_write_reg(hwif, addr, val);
+	}
+
+	init_val = HINIC_EQ_ELEM_DESC_SET(eq->wrapped, WRAPPED);
+
+	if (eq->type == HINIC_AEQ)
+		aeq_elements_init(eq, init_val);
+
+	return 0;
+
+err_dma_alloc:
+	while (--pg >= 0)
+		dma_free_coherent(&pdev->dev, eq->page_size,
+				  eq->virt_addr[pg],
+				  eq->dma_addr[pg]);
+
+	devm_kfree(&pdev->dev, eq->virt_addr);
+
+err_virt_addr_alloc:
+	devm_kfree(&pdev->dev, eq->dma_addr);
+	return err;
+}
+
+/**
+ * free_eq_pages - free the pages of the queue
+ * @eq: the Event Queue
+ **/
+static void free_eq_pages(struct hinic_eq *eq)
+{
+	struct hinic_hwif *hwif = eq->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int pg;
+
+	for (pg = 0; pg < eq->num_pages; pg++)
+		dma_free_coherent(&pdev->dev, eq->page_size,
+				  eq->virt_addr[pg],
+				  eq->dma_addr[pg]);
+
+	devm_kfree(&pdev->dev, eq->virt_addr);
+	devm_kfree(&pdev->dev, eq->dma_addr);
+}
+
 /**
  * init_eq - initialize Event Queue
  * @eq: the event queue
@@ -77,8 +454,81 @@ static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
 		   enum hinic_eq_type type, int q_id, u32 q_len, u32 page_size,
 		   struct msix_entry entry)
 {
-	/* should be implemented */
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	eq->hwif = hwif;
+	eq->type = type;
+	eq->q_id = q_id;
+	eq->q_len = q_len;
+	eq->page_size = page_size;
+
+	/* Clear PI and CI, also clear the ARM bit */
+	hinic_hwif_write_reg(eq->hwif, EQ_CONS_IDX_REG_ADDR(eq), 0);
+	hinic_hwif_write_reg(eq->hwif, EQ_PROD_IDX_REG_ADDR(eq), 0);
+
+	eq->cons_idx = 0;
+	eq->wrapped = 0;
+
+	if (type == HINIC_AEQ) {
+		eq->elem_size = HINIC_AEQE_SIZE;
+	} else {
+		dev_err(&pdev->dev, "Invalid EQ type\n");
+		return -EINVAL;
+	}
+
+	eq->num_pages = GET_EQ_NUM_PAGES(eq, page_size);
+	eq->num_elem_in_pg = GET_EQ_NUM_ELEMS_IN_PG(eq, page_size);
+
+	eq->msix_entry = entry;
+
+	if (eq->num_elem_in_pg & (eq->num_elem_in_pg - 1)) {
+		dev_err(&pdev->dev, "num elements in eq page != power of 2\n");
+		return -EINVAL;
+	}
+
+	if (eq->num_pages > EQ_MAX_PAGES) {
+		dev_err(&pdev->dev, "too many pages for eq\n");
+		return -EINVAL;
+	}
+
+	set_eq_ctrls(eq);
+	eq_update_ci(eq);
+
+	err = alloc_eq_pages(eq);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate pages for eq\n");
+		return err;
+	}
+
+	if (type == HINIC_AEQ) {
+		struct hinic_eq_work *aeq_work = &eq->aeq_work;
+
+		INIT_WORK(&aeq_work->work, eq_irq_work);
+	}
+
+	/* set the attributes of the msix entry */
+	hinic_msix_attr_set(eq->hwif, eq->msix_entry.entry,
+			    HINIC_EQ_MSIX_PENDING_LIMIT_DEFAULT,
+			    HINIC_EQ_MSIX_COALESC_TIMER_DEFAULT,
+			    HINIC_EQ_MSIX_LLI_TIMER_DEFAULT,
+			    HINIC_EQ_MSIX_LLI_CREDIT_LIMIT_DEFAULT,
+			    HINIC_EQ_MSIX_RESEND_TIMER_DEFAULT);
+
+	if (type == HINIC_AEQ)
+		err = request_irq(entry.vector, aeq_interrupt, 0,
+				  "hinic_aeq", eq);
+
+	if (err) {
+		dev_err(&pdev->dev, "Failed to request irq for the EQ\n");
+		goto err_req_irq;
+	}
+
 	return 0;
+
+err_req_irq:
+	free_eq_pages(eq);
+	return err;
 }
 
 /**
@@ -87,7 +537,17 @@ static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
  **/
 static void remove_eq(struct hinic_eq *eq)
 {
-	/* should be implemented */
+	struct msix_entry *entry = &eq->msix_entry;
+
+	free_irq(entry->vector, eq);
+
+	if (eq->type == HINIC_AEQ) {
+		struct hinic_eq_work *aeq_work = &eq->aeq_work;
+
+		cancel_work_sync(&aeq_work->work);
+	}
+
+	free_eq_pages(eq);
 }
 
 /**
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
index 1580127..7f50b2f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
@@ -24,8 +24,84 @@
 
 #include "hinic_hw_if.h"
 
+#define HINIC_AEQ_CTRL_0_INT_IDX_SHIFT          0
+#define HINIC_AEQ_CTRL_0_DMA_ATTR_SHIFT         12
+#define HINIC_AEQ_CTRL_0_PCI_INTF_IDX_SHIFT     20
+#define HINIC_AEQ_CTRL_0_INT_MODE_SHIFT         31
+
+#define HINIC_AEQ_CTRL_0_INT_IDX_MASK           0x3FF
+#define HINIC_AEQ_CTRL_0_DMA_ATTR_MASK          0x3F
+#define HINIC_AEQ_CTRL_0_PCI_INTF_IDX_MASK      0x3
+#define HINIC_AEQ_CTRL_0_INT_MODE_MASK          0x1
+
+#define HINIC_AEQ_CTRL_0_SET(val, member)       \
+			(((u32)(val) & HINIC_AEQ_CTRL_0_##member##_MASK) << \
+			 HINIC_AEQ_CTRL_0_##member##_SHIFT)
+
+#define HINIC_AEQ_CTRL_0_CLEAR(val, member)     \
+			((val) & (~(HINIC_AEQ_CTRL_0_##member##_MASK \
+			 << HINIC_AEQ_CTRL_0_##member##_SHIFT)))
+
+#define HINIC_AEQ_CTRL_1_LEN_SHIFT              0
+#define HINIC_AEQ_CTRL_1_ELEM_SIZE_SHIFT        24
+#define HINIC_AEQ_CTRL_1_PAGE_SIZE_SHIFT        28
+
+#define HINIC_AEQ_CTRL_1_LEN_MASK               0x1FFFFF
+#define HINIC_AEQ_CTRL_1_ELEM_SIZE_MASK         0x3
+#define HINIC_AEQ_CTRL_1_PAGE_SIZE_MASK         0xF
+
+#define HINIC_AEQ_CTRL_1_SET(val, member)       \
+			(((u32)(val) & HINIC_AEQ_CTRL_1_##member##_MASK) << \
+			 HINIC_AEQ_CTRL_1_##member##_SHIFT)
+
+#define HINIC_AEQ_CTRL_1_CLEAR(val, member)     \
+			((val) & (~(HINIC_AEQ_CTRL_1_##member##_MASK \
+			 << HINIC_AEQ_CTRL_1_##member##_SHIFT)))
+
+#define HINIC_EQ_ELEM_DESC_TYPE_SHIFT           0
+#define HINIC_EQ_ELEM_DESC_SRC_SHIFT            7
+#define HINIC_EQ_ELEM_DESC_SIZE_SHIFT           8
+#define HINIC_EQ_ELEM_DESC_WRAPPED_SHIFT        31
+
+#define HINIC_EQ_ELEM_DESC_TYPE_MASK            0x7F
+#define HINIC_EQ_ELEM_DESC_SRC_MASK             0x1
+#define HINIC_EQ_ELEM_DESC_SIZE_MASK            0xFF
+#define HINIC_EQ_ELEM_DESC_WRAPPED_MASK         0x1
+
+#define HINIC_EQ_ELEM_DESC_SET(val, member)     \
+			(((u32)(val) & HINIC_EQ_ELEM_DESC_##member##_MASK) << \
+			 HINIC_EQ_ELEM_DESC_##member##_SHIFT)
+
+#define HINIC_EQ_ELEM_DESC_GET(val, member)     \
+			(((val) >> HINIC_EQ_ELEM_DESC_##member##_SHIFT) & \
+			 HINIC_EQ_ELEM_DESC_##member##_MASK)
+
+#define HINIC_EQ_CI_IDX_SHIFT                   0
+#define HINIC_EQ_CI_WRAPPED_SHIFT               20
+#define HINIC_EQ_CI_XOR_CHKSUM_SHIFT            24
+#define HINIC_EQ_CI_INT_ARMED_SHIFT             31
+
+#define HINIC_EQ_CI_IDX_MASK                    0xFFFFF
+#define HINIC_EQ_CI_WRAPPED_MASK                0x1
+#define HINIC_EQ_CI_XOR_CHKSUM_MASK             0xF
+#define HINIC_EQ_CI_INT_ARMED_MASK              0x1
+
+#define HINIC_EQ_CI_SET(val, member)            \
+			(((u32)(val) & HINIC_EQ_CI_##member##_MASK) << \
+			 HINIC_EQ_CI_##member##_SHIFT)
+
+#define HINIC_EQ_CI_CLEAR(val, member)          \
+			((val) & (~(HINIC_EQ_CI_##member##_MASK \
+			 << HINIC_EQ_CI_##member##_SHIFT)))
+
 #define HINIC_MAX_AEQS                  4
 
+#define HINIC_AEQE_SIZE                 64
+
+#define HINIC_AEQE_DESC_SIZE            4
+#define HINIC_AEQE_DATA_SIZE            \
+			(HINIC_AEQE_SIZE - HINIC_AEQE_DESC_SIZE)
+
 #define HINIC_DEFAULT_AEQ_LEN           64
 
 #define HINIC_EQ_PAGE_SIZE              SZ_4K
@@ -45,6 +121,11 @@ enum hinic_eqe_state {
 	HINIC_EQE_RUNNING = BIT(1),
 };
 
+struct hinic_aeq_elem {
+	u8      data[HINIC_AEQE_DATA_SIZE];
+	u32     desc;
+};
+
 struct hinic_eq_work {
 	struct work_struct      work;
 	void                    *data;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
index edf1842..2b9410c 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
@@ -25,6 +25,97 @@
 
 #define PCIE_ATTR_ENTRY         0
 
+#define VALID_MSIX_IDX(attr, msix_index) ((msix_index) < (attr)->num_irqs)
+
+/**
+ * hinic_msix_attr_set - set message attribute for msix entry
+ * @hwif: the HW interface of a pci function device
+ * @msix_index: msix_index
+ * @pending_limit: the maximum pending interrupt events (unit 8)
+ * @coalesc_timer: coalesc period for interrupt (unit 8 us)
+ * @lli_timer: replenishing period for low latency credit (unit 8 us)
+ * @lli_credit_limit: maximum credits for low latency msix messages (unit 8)
+ * @resend_timer: maximum wait for resending msix (unit coalesc period)
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_msix_attr_set(struct hinic_hwif *hwif, u16 msix_index,
+			u8 pending_limit, u8 coalesc_timer,
+			u8 lli_timer, u8 lli_credit_limit,
+			u8 resend_timer)
+{
+	u32 msix_ctrl, addr;
+
+	if (!VALID_MSIX_IDX(&hwif->attr, msix_index))
+		return -EINVAL;
+
+	msix_ctrl = HINIC_MSIX_ATTR_SET(pending_limit, PENDING_LIMIT)   |
+		    HINIC_MSIX_ATTR_SET(coalesc_timer, COALESC_TIMER)   |
+		    HINIC_MSIX_ATTR_SET(lli_timer, LLI_TIMER)           |
+		    HINIC_MSIX_ATTR_SET(lli_credit_limit, LLI_CREDIT)   |
+		    HINIC_MSIX_ATTR_SET(resend_timer, RESEND_TIMER);
+
+	addr = HINIC_CSR_MSIX_CTRL_ADDR(msix_index);
+
+	hinic_hwif_write_reg(hwif, addr, msix_ctrl);
+	return 0;
+}
+
+/**
+ * hinic_msix_attr_get - get message attribute of msix entry
+ * @hwif: the HW interface of a pci function device
+ * @msix_index: msix_index
+ * @pending_limit: the maximum pending interrupt events (unit 8)
+ * @coalesc_timer: coalesc period for interrupt (unit 8 us)
+ * @lli_timer: replenishing period for low latency credit (unit 8 us)
+ * @lli_credit_limit: maximum credits for low latency msix messages (unit 8)
+ * @resend_timer: maximum wait for resending msix (unit coalesc period)
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_msix_attr_get(struct hinic_hwif *hwif, u16 msix_index,
+			u8 *pending_limit, u8 *coalesc_timer,
+			u8 *lli_timer, u8 *lli_credit_limit,
+			u8 *resend_timer)
+{
+	u32 addr, val;
+
+	if (!VALID_MSIX_IDX(&hwif->attr, msix_index))
+		return -EINVAL;
+
+	addr = HINIC_CSR_MSIX_CTRL_ADDR(msix_index);
+	val  = hinic_hwif_read_reg(hwif, addr);
+
+	*pending_limit    = HINIC_MSIX_ATTR_GET(val, PENDING_LIMIT);
+	*coalesc_timer    = HINIC_MSIX_ATTR_GET(val, COALESC_TIMER);
+	*lli_timer        = HINIC_MSIX_ATTR_GET(val, LLI_TIMER);
+	*lli_credit_limit = HINIC_MSIX_ATTR_GET(val, LLI_CREDIT);
+	*resend_timer     = HINIC_MSIX_ATTR_GET(val, RESEND_TIMER);
+	return 0;
+}
+
+/**
+ * hinic_msix_attr_cnt_clear - clear message attribute counters for msix entry
+ * @hwif: the HW interface of a pci function device
+ * @msix_index: msix_index
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_msix_attr_cnt_clear(struct hinic_hwif *hwif, u16 msix_index)
+{
+	u32 msix_ctrl, addr;
+
+	if (!VALID_MSIX_IDX(&hwif->attr, msix_index))
+		return -EINVAL;
+
+	msix_ctrl = HINIC_MSIX_CNT_SET(1, RESEND_TIMER);
+
+	addr = HINIC_CSR_MSIX_CNT_ADDR(msix_index);
+
+	hinic_hwif_write_reg(hwif, addr, msix_ctrl);
+	return 0;
+}
+
 /**
  * hwif_ready - test if the HW is ready for use
  * @hwif: the HW interface of a pci function device
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index 98623d6..707a046 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -88,6 +88,34 @@
 	((val) & (~(HINIC_PPF_ELECTION_##member##_MASK          \
 	 << HINIC_PPF_ELECTION_##member##_SHIFT)))
 
+#define HINIC_MSIX_PENDING_LIMIT_SHIFT                          0
+#define HINIC_MSIX_COALESC_TIMER_SHIFT                          8
+#define HINIC_MSIX_LLI_TIMER_SHIFT                              16
+#define HINIC_MSIX_LLI_CREDIT_SHIFT                             24
+#define HINIC_MSIX_RESEND_TIMER_SHIFT                           29
+
+#define HINIC_MSIX_PENDING_LIMIT_MASK                           0xFF
+#define HINIC_MSIX_COALESC_TIMER_MASK                           0xFF
+#define HINIC_MSIX_LLI_TIMER_MASK                               0xFF
+#define HINIC_MSIX_LLI_CREDIT_MASK                              0x1F
+#define HINIC_MSIX_RESEND_TIMER_MASK                            0x7
+
+#define HINIC_MSIX_ATTR_SET(val, member)                        \
+	(((u32)(val) & HINIC_MSIX_##member##_MASK) <<           \
+	 HINIC_MSIX_##member##_SHIFT)
+
+#define HINIC_MSIX_ATTR_GET(val, member)                        \
+	(((val) >> HINIC_MSIX_##member##_SHIFT) &               \
+	 HINIC_MSIX_##member##_MASK)
+
+#define HINIC_MSIX_CNT_RESEND_TIMER_SHIFT                       29
+
+#define HINIC_MSIX_CNT_RESEND_TIMER_MASK                        0x1
+
+#define HINIC_MSIX_CNT_SET(val, member)                         \
+	(((u32)(val) & HINIC_MSIX_CNT_##member##_MASK) <<       \
+	 HINIC_MSIX_CNT_##member##_SHIFT)
+
 #define HINIC_HWIF_NUM_AEQS(hwif)       ((hwif)->attr.num_aeqs)
 #define HINIC_HWIF_NUM_CEQS(hwif)       ((hwif)->attr.num_ceqs)
 #define HINIC_HWIF_NUM_IRQS(hwif)       ((hwif)->attr.num_irqs)
@@ -105,6 +133,12 @@
 #define HINIC_PCIE_AT_DISABLE           0
 #define HINIC_PCIE_PH_DISABLE           0
 
+#define HINIC_EQ_MSIX_PENDING_LIMIT_DEFAULT     0       /* Disabled */
+#define HINIC_EQ_MSIX_COALESC_TIMER_DEFAULT     0xFF    /* max */
+#define HINIC_EQ_MSIX_LLI_TIMER_DEFAULT         0       /* Disabled */
+#define HINIC_EQ_MSIX_LLI_CREDIT_LIMIT_DEFAULT  0       /* Disabled */
+#define HINIC_EQ_MSIX_RESEND_TIMER_DEFAULT      7       /* max */
+
 enum hinic_pcie_nosnoop {
 	HINIC_PCIE_SNOOP        = 0,
 	HINIC_PCIE_NO_SNOOP     = 1,
@@ -166,6 +200,18 @@ static inline void hinic_hwif_write_reg(struct hinic_hwif *hwif, u32 reg,
 	writel(cpu_to_be32(val), hwif->cfg_regs_bar + reg);
 }
 
+int hinic_msix_attr_set(struct hinic_hwif *hwif, u16 msix_index,
+			u8 pending_limit, u8 coalesc_timer,
+			u8 lli_timer_cfg, u8 lli_credit_limit,
+			u8 resend_timer);
+
+int hinic_msix_attr_get(struct hinic_hwif *hwif, u16 msix_index,
+			u8 *pending_limit, u8 *coalesc_timer_cfg,
+			u8 *lli_timer, u8 *lli_credit_limit,
+			u8 *resend_timer);
+
+int hinic_msix_attr_cnt_clear(struct hinic_hwif *hwif, u16 msix_index);
+
 int hinic_init_hwif(struct hinic_hwif *hwif, struct pci_dev *pdev);
 
 void hinic_free_hwif(struct hinic_hwif *hwif);
-- 
1.9.1
