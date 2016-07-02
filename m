From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 18/22] IB/hns: Add CQ operations support
Date: Sat, 2 Jul 2016 17:39:20 +0800
Message-ID: <1467452364-66522-19-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch was implementing for Completion Queue(CQ) operations.
A CQ can be used to multiplex work completions from multiple work
queues across queue pairs on the same HCA. CQ as the notification
mechanism for Work Request completions.
CQ operations as follows:
    1. create CQ. CQ are created through the Channel Interface,
       The maximum number of Completion Queue Entries (CQEs) that
       may be outstanding on a CQ must be specified when the CQ
       is created.
    2. destroy CQ. Destroys the specified CQ. Resources allocated
       by the Channel Interface to implement the CQ must be
       deallocated during the destroy operation.
    3. request completion notification. Requests the CQ event handler
       be called when the next completion entry of the specified type
       is added to the specified CQ.
    4. poll CQ. Polls the specified CQ for a Work Completion.
       A Work Completion indicates that a Work Request for a Work
       Queue associated with the CQ is done.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11:
Remove the non-essential headers according to the Leon Romanovsky's
the same comments over the [PATCH v10 3/22]:
  Link: https://lkml.org/lkml/2016/6/24/276

PATCH v10/v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_cq.c     | 357 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_device.h |  33 +++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 345 +++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 117 +++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   9 +
 5 files changed, 861 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 89e91e6..875597b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -33,6 +33,363 @@
 #include <linux/platform_device.h>
 #include <rdma/ib_umem.h>
 #include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
+#include "hns_roce_hem.h"
+#include "hns_roce_user.h"
+#include "hns_roce_common.h"
+
+static void hns_roce_ib_cq_comp(struct hns_roce_cq *hr_cq)
+{
+	struct ib_cq *ibcq = &hr_cq->ib_cq;
+
+	ibcq->comp_handler(ibcq, ibcq->cq_context);
+}
+
+static void hns_roce_ib_cq_event(struct hns_roce_cq *hr_cq,
+				 enum hns_roce_event event_type)
+{
+	struct hns_roce_dev *hr_dev;
+	struct ib_event event;
+	struct ib_cq *ibcq;
+
+	ibcq = &hr_cq->ib_cq;
+	hr_dev = to_hr_dev(ibcq->device);
+
+	if (event_type != HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID &&
+	    event_type != HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR &&
+	    event_type != HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW) {
+		dev_err(&hr_dev->pdev->dev,
+			"hns_roce_ib: Unexpected event type 0x%x on CQ %06lx\n",
+			event_type, hr_cq->cqn);
+		return;
+	}
+
+	if (ibcq->event_handler) {
+		event.device = ibcq->device;
+		event.event = IB_EVENT_CQ_ERR;
+		event.element.cq = ibcq;
+		ibcq->event_handler(&event, ibcq->cq_context);
+	}
+}
+
+static int hns_roce_sw2hw_cq(struct hns_roce_dev *dev,
+			     struct hns_roce_cmd_mailbox *mailbox,
+			     unsigned long cq_num)
+{
+	return hns_roce_cmd_mbox(dev, mailbox->dma, 0, cq_num, 0,
+			    HNS_ROCE_CMD_SW2HW_CQ, HNS_ROCE_CMD_TIME_CLASS_A);
+}
+
+static int hns_roce_cq_alloc(struct hns_roce_dev *hr_dev, int nent,
+			     struct hns_roce_mtt *hr_mtt,
+			     struct hns_roce_uar *hr_uar,
+			     struct hns_roce_cq *hr_cq, int vector,
+			     int collapsed)
+{
+	struct hns_roce_cmd_mailbox *mailbox = NULL;
+	struct hns_roce_cq_table *cq_table = NULL;
+	struct device *dev = &hr_dev->pdev->dev;
+	dma_addr_t dma_handle;
+	u64 *mtts = NULL;
+	int ret = 0;
+
+	cq_table = &hr_dev->cq_table;
+
+	/* Get the physical address of cq buf */
+	mtts = hns_roce_table_find(&hr_dev->mr_table.mtt_table,
+				   hr_mtt->first_seg, &dma_handle);
+	if (!mtts) {
+		dev_err(dev, "CQ alloc.Failed to find cq buf addr.\n");
+		return -EINVAL;
+	}
+
+	if (vector >= hr_dev->caps.num_comp_vectors) {
+		dev_err(dev, "CQ alloc.Invalid vector.\n");
+		return -EINVAL;
+	}
+	hr_cq->vector = vector;
+
+	ret = hns_roce_bitmap_alloc(&cq_table->bitmap, &hr_cq->cqn);
+	if (ret == -1) {
+		dev_err(dev, "CQ alloc.Failed to alloc index.\n");
+		return -ENOMEM;
+	}
+
+	/* Get CQC memory HEM(Hardware Entry Memory) table */
+	ret = hns_roce_table_get(hr_dev, &cq_table->table, hr_cq->cqn);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to get context mem.\n");
+		goto err_out;
+	}
+
+	/* The cq insert radix tree */
+	spin_lock_irq(&cq_table->lock);
+	/* Radix_tree: The associated pointer and long integer key value like */
+	ret = radix_tree_insert(&cq_table->tree, hr_cq->cqn, hr_cq);
+	spin_unlock_irq(&cq_table->lock);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to radix_tree_insert.\n");
+		goto err_put;
+	}
+
+	/* Allocate mailbox memory */
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		ret = PTR_ERR(mailbox);
+		goto err_radix;
+	}
+
+	hr_dev->hw->write_cqc(hr_dev, hr_cq, mailbox->buf, mtts, dma_handle,
+			      nent, vector);
+
+	/* Send mailbox to hw */
+	ret = hns_roce_sw2hw_cq(hr_dev, mailbox, hr_cq->cqn);
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+	if (ret) {
+		dev_err(dev, "CQ alloc.Failed to cmd mailbox.\n");
+		goto err_radix;
+	}
+
+	hr_cq->cons_index = 0;
+	hr_cq->uar = hr_uar;
+
+	return 0;
+
+err_radix:
+	spin_lock_irq(&cq_table->lock);
+	radix_tree_delete(&cq_table->tree, hr_cq->cqn);
+	spin_unlock_irq(&cq_table->lock);
+
+err_put:
+	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
+
+err_out:
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+	return ret;
+}
+
+static int hns_roce_hw2sw_cq(struct hns_roce_dev *dev,
+			     struct hns_roce_cmd_mailbox *mailbox,
+			     unsigned long cq_num)
+{
+	return hns_roce_cmd_mbox(dev, 0, mailbox ? mailbox->dma : 0, cq_num,
+				 mailbox ? 0 : 1, HNS_ROCE_CMD_HW2SW_CQ,
+				 HNS_ROCE_CMD_TIME_CLASS_A);
+}
+
+static void hns_roce_free_cq(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_cq *hr_cq)
+{
+	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
+	struct device *dev = &hr_dev->pdev->dev;
+	int ret;
+
+	ret = hns_roce_hw2sw_cq(hr_dev, NULL, hr_cq->cqn);
+	if (ret)
+		dev_err(dev, "HW2SW_CQ failed (%d) for CQN %06lx\n", ret,
+			hr_cq->cqn);
+
+	/* Waiting interrupt process procedure carried out */
+	synchronize_irq(hr_dev->eq_table.eq[hr_cq->vector].irq);
+
+	spin_lock_irq(&cq_table->lock);
+	radix_tree_delete(&cq_table->tree, hr_cq->cqn);
+	spin_unlock_irq(&cq_table->lock);
+
+	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+}
+
+static int hns_roce_ib_get_cq_umem(struct hns_roce_dev *hr_dev,
+				   struct ib_ucontext *context,
+				   struct hns_roce_cq_buf *buf,
+				   struct ib_umem **umem, u64 buf_addr, int cqe)
+{
+	int ret;
+
+	*umem = ib_umem_get(context, buf_addr, cqe * hr_dev->caps.cq_entry_sz,
+			    IB_ACCESS_LOCAL_WRITE, 1);
+	if (IS_ERR(*umem))
+		return PTR_ERR(*umem);
+
+	ret = hns_roce_mtt_init(hr_dev, ib_umem_page_count(*umem),
+				ilog2((unsigned int)(*umem)->page_size),
+				&buf->hr_mtt);
+	if (ret)
+		goto err_buf;
+
+	ret = hns_roce_ib_umem_write_mtt(hr_dev, &buf->hr_mtt, *umem);
+	if (ret)
+		goto err_mtt;
+
+	return 0;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &buf->hr_mtt);
+
+err_buf:
+	ib_umem_release(*umem);
+	return ret;
+}
+
+static int hns_roce_ib_alloc_cq_buf(struct hns_roce_dev *hr_dev,
+				    struct hns_roce_cq_buf *buf, u32 nent)
+{
+	int ret;
+
+	ret = hns_roce_buf_alloc(hr_dev, nent * hr_dev->caps.cq_entry_sz,
+				 PAGE_SIZE * 2, &buf->hr_buf);
+	if (ret)
+		goto out;
+
+	ret = hns_roce_mtt_init(hr_dev, buf->hr_buf.npages,
+				buf->hr_buf.page_shift, &buf->hr_mtt);
+	if (ret)
+		goto err_buf;
+
+	ret = hns_roce_buf_write_mtt(hr_dev, &buf->hr_mtt, &buf->hr_buf);
+	if (ret)
+		goto err_mtt;
+
+	return 0;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &buf->hr_mtt);
+
+err_buf:
+	hns_roce_buf_free(hr_dev, nent * hr_dev->caps.cq_entry_sz,
+			  &buf->hr_buf);
+out:
+	return ret;
+}
+
+static void hns_roce_ib_free_cq_buf(struct hns_roce_dev *hr_dev,
+				    struct hns_roce_cq_buf *buf, int cqe)
+{
+	hns_roce_buf_free(hr_dev, (cqe + 1) * hr_dev->caps.cq_entry_sz,
+			  &buf->hr_buf);
+}
+
+struct ib_cq *hns_roce_ib_create_cq(struct ib_device *ib_dev,
+				    const struct ib_cq_init_attr *attr,
+				    struct ib_ucontext *context,
+				    struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_ib_create_cq ucmd;
+	struct hns_roce_cq *hr_cq = NULL;
+	struct hns_roce_uar *uar = NULL;
+	int vector = attr->comp_vector;
+	int cq_entries = attr->cqe;
+	int ret = 0;
+
+	if (cq_entries < 1 || cq_entries > hr_dev->caps.max_cqes) {
+		dev_err(dev, "Creat CQ failed. entries=%d, max=%d\n",
+			cq_entries, hr_dev->caps.max_cqes);
+		return ERR_PTR(-EINVAL);
+	}
+
+	hr_cq = kmalloc(sizeof(*hr_cq), GFP_KERNEL);
+	if (!hr_cq)
+		return ERR_PTR(-ENOMEM);
+
+	/* In v1 engine, parameter verification */
+	if (cq_entries < HNS_ROCE_MIN_CQE_NUM)
+		cq_entries = HNS_ROCE_MIN_CQE_NUM;
+
+	cq_entries = roundup_pow_of_two((unsigned int)cq_entries);
+	hr_cq->ib_cq.cqe = cq_entries - 1;
+	mutex_init(&hr_cq->resize_mutex);
+	spin_lock_init(&hr_cq->lock);
+	hr_cq->hr_resize_buf = NULL;
+	hr_cq->resize_umem = NULL;
+
+	if (context) {
+		if (ib_copy_from_udata(&ucmd, udata, sizeof(ucmd))) {
+			dev_err(dev, "Failed to copy_from_udata.\n");
+			ret = -EFAULT;
+			goto err_cq;
+		}
+
+		/* Get user space address, write it into mtt table */
+		ret = hns_roce_ib_get_cq_umem(hr_dev, context, &hr_cq->hr_buf,
+					      &hr_cq->umem, ucmd.buf_addr,
+					      cq_entries);
+		if (ret) {
+			dev_err(dev, "Failed to get_cq_umem.\n");
+			goto err_cq;
+		}
+
+		/* Get user space parameters */
+		uar = &to_hr_ucontext(context)->uar;
+	} else {
+		/* Init mmt table and write buff address to mtt table */
+		ret = hns_roce_ib_alloc_cq_buf(hr_dev, &hr_cq->hr_buf,
+					       cq_entries);
+		if (ret) {
+			dev_err(dev, "Failed to alloc_cq_buf.\n");
+			goto err_cq;
+		}
+
+		uar = &hr_dev->priv_uar;
+		hr_cq->cq_db_l = hr_dev->reg_base + ROCEE_DB_OTHERS_L_0_REG +
+				 0x1000 * uar->index;
+	}
+
+	/* Allocate cq index, fill cq_context */
+	ret = hns_roce_cq_alloc(hr_dev, cq_entries, &hr_cq->hr_buf.hr_mtt,
+				uar, hr_cq, vector, 0);
+	if (ret) {
+		dev_err(dev, "Creat CQ .Failed to cq_alloc.\n");
+		goto err_mtt;
+	}
+
+	/* Get created cq handler and carry out event */
+	hr_cq->comp = hns_roce_ib_cq_comp;
+	hr_cq->event = hns_roce_ib_cq_event;
+	hr_cq->cq_depth = cq_entries;
+
+	if (context) {
+		if (ib_copy_to_udata(udata, &hr_cq->cqn, sizeof(u64))) {
+			ret = -EFAULT;
+			goto err_mtt;
+		}
+	}
+
+	return &hr_cq->ib_cq;
+
+err_mtt:
+	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+	if (context)
+		ib_umem_release(hr_cq->umem);
+	else
+		hns_roce_ib_free_cq_buf(hr_dev, &hr_cq->hr_buf,
+					hr_cq->ib_cq.cqe);
+
+err_cq:
+	kfree(hr_cq);
+	return ERR_PTR(ret);
+}
+
+int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ib_cq->device);
+	struct hns_roce_cq *hr_cq = to_hr_cq(ib_cq);
+
+	hns_roce_free_cq(hr_dev, hr_cq);
+	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+
+	if (ib_cq->uobject)
+		ib_umem_release(hr_cq->umem);
+	else
+		/* Free the buff of stored cq */
+		hns_roce_ib_free_cq_buf(hr_dev, &hr_cq->hr_buf, ib_cq->cqe);
+
+	kfree(hr_cq);
+
+	return 0;
+}
 
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn)
 {
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 01b4031..03fc37e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -47,6 +47,7 @@
 #define HNS_ROCE_BA_SIZE			(32 * 4096)
 
 /* Hardware specification only for v1 engine */
+#define HNS_ROCE_MIN_CQE_NUM			0x40
 #define HNS_ROCE_MIN_WQE_NUM			0x20
 
 #define HNS_ROCE_MAX_IRQ_NUM			34
@@ -133,6 +134,12 @@ enum {
 	HNS_ROCE_DB_SUBTYPE_ODB_ALM_EMP		= 6,
 };
 
+enum {
+	/* RQ&SRQ related operations */
+	HNS_ROCE_OPCODE_SEND_DATA_RECEIVE	= 0x06,
+	HNS_ROCE_OPCODE_RDMA_WITH_IMM_RECEIVE	= 0x07,
+};
+
 #define HNS_ROCE_CMD_SUCCESS			1
 
 #define HNS_ROCE_PORT_DOWN			0
@@ -240,20 +247,33 @@ struct hns_roce_buf {
 
 struct hns_roce_cq_buf {
 	struct hns_roce_buf hr_buf;
+	struct hns_roce_mtt hr_mtt;
+};
+
+struct hns_roce_cq_resize {
+	struct hns_roce_cq_buf	hr_buf;
+	int			cqe;
 };
 
 struct hns_roce_cq {
 	struct ib_cq			ib_cq;
 	struct hns_roce_cq_buf		hr_buf;
 	/* pointer to store information after resize*/
+	struct hns_roce_cq_resize	*hr_resize_buf;
 	spinlock_t			lock;
+	struct mutex			resize_mutex;
+	struct ib_umem			*umem;
+	struct ib_umem			*resize_umem;
 	void (*comp)(struct hns_roce_cq *);
 	void (*event)(struct hns_roce_cq *, enum hns_roce_event);
 
+	struct hns_roce_uar		*uar;
 	u32				cq_depth;
 	u32				cons_index;
 	void __iomem			*cq_db_l;
+	void __iomem			*tptr_addr;
 	unsigned long			cqn;
+	u32				vector;
 	atomic_t			refcount;
 	struct completion		free;
 };
@@ -455,6 +475,9 @@ struct hns_roce_hw {
 	void (*set_mac)(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr);
 	void (*set_mtu)(struct hns_roce_dev *hr_dev, u8 phy_port,
 			enum ib_mtu mtu);
+	void (*write_cqc)(struct hns_roce_dev *hr_dev,
+			  struct hns_roce_cq *hr_cq, void *mb_buf, u64 *mtts,
+			  dma_addr_t dma_handle, int nent, u32 vector);
 	int (*query_qp)(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
 			int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr);
 	int (*modify_qp)(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
@@ -465,6 +488,8 @@ struct hns_roce_hw {
 			 struct ib_send_wr **bad_wr);
 	int (*post_recv)(struct ib_qp *qp, struct ib_recv_wr *recv_wr,
 			 struct ib_recv_wr **bad_recv_wr);
+	int (*req_notify_cq)(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
+	int (*poll_cq)(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
 	void	*priv;
 };
 
@@ -488,6 +513,7 @@ struct hns_roce_dev {
 	u32                     vendor_id;
 	u32                     vendor_part_id;
 	u32                     hw_rev;
+	void __iomem            *priv_addr;
 
 	struct hns_roce_cmdq	cmd;
 	struct hns_roce_bitmap    pd_bitmap;
@@ -646,6 +672,13 @@ void hns_roce_release_range_qp(struct hns_roce_dev *hr_dev, int base_qpn,
 __be32 send_ieth(struct ib_send_wr *wr);
 int to_hr_qp_type(int qp_type);
 
+struct ib_cq *hns_roce_ib_create_cq(struct ib_device *ib_dev,
+				    const struct ib_cq_init_attr *attr,
+				    struct ib_ucontext *context,
+				    struct ib_udata *udata);
+
+int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq);
+
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index fb39155..2e96dd9 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -1015,6 +1015,11 @@ static void *get_sw_cqe(struct hns_roce_cq *hr_cq, int n)
 		!!(n & (hr_cq->ib_cq.cqe + 1))) ? hr_cqe : NULL;
 }
 
+static struct hns_roce_cqe *next_cqe_sw(struct hns_roce_cq *hr_cq)
+{
+	return get_sw_cqe(hr_cq, hr_cq->cons_index);
+}
+
 void hns_roce_v1_cq_set_ci(struct hns_roce_cq *hr_cq, u32 cons_index,
 			   spinlock_t *doorbell_lock)
 
@@ -1090,6 +1095,343 @@ static void hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
 	spin_unlock_irq(&hr_cq->lock);
 }
 
+void hns_roce_v1_write_cqc(struct hns_roce_dev *hr_dev,
+			   struct hns_roce_cq *hr_cq, void *mb_buf, u64 *mtts,
+			   dma_addr_t dma_handle, int nent, u32 vector)
+{
+	struct hns_roce_cq_context *cq_context = NULL;
+	void __iomem *tptr_addr;
+
+	cq_context = mb_buf;
+	memset(cq_context, 0, sizeof(*cq_context));
+
+	tptr_addr = 0;
+	hr_dev->priv_addr = tptr_addr;
+	hr_cq->tptr_addr = tptr_addr;
+
+	/* Register cq_context members */
+	roce_set_field(cq_context->cqc_byte_4,
+		       CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_M,
+		       CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S, CQ_STATE_VALID);
+	roce_set_field(cq_context->cqc_byte_4, CQ_CONTEXT_CQC_BYTE_4_CQN_M,
+		       CQ_CONTEXT_CQC_BYTE_4_CQN_S, hr_cq->cqn);
+	cq_context->cqc_byte_4 = cpu_to_le32(cq_context->cqc_byte_4);
+
+	cq_context->cq_bt_l = (u32)dma_handle;
+	cq_context->cq_bt_l = cpu_to_le32(cq_context->cq_bt_l);
+
+	roce_set_field(cq_context->cqc_byte_12,
+		       CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_M,
+		       CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S,
+		       ((u64)dma_handle >> 32));
+	roce_set_field(cq_context->cqc_byte_12,
+		       CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_M,
+		       CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S,
+		       ilog2((unsigned int)nent));
+	roce_set_field(cq_context->cqc_byte_12, CQ_CONTEXT_CQC_BYTE_12_CEQN_M,
+		       CQ_CONTEXT_CQC_BYTE_12_CEQN_S, vector);
+	cq_context->cqc_byte_12 = cpu_to_le32(cq_context->cqc_byte_12);
+
+	cq_context->cur_cqe_ba0_l = (u32)(mtts[0]);
+	cq_context->cur_cqe_ba0_l = cpu_to_le32(cq_context->cur_cqe_ba0_l);
+
+	roce_set_field(cq_context->cqc_byte_20,
+		       CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_M,
+		       CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S,
+		       cpu_to_le32((mtts[0]) >> 32));
+	/* Dedicated hardware, directly set 0 */
+	roce_set_field(cq_context->cqc_byte_20,
+		       CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_M,
+		       CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S, 0);
+	/**
+	 * 44 = 32 + 12, When evaluating addr to hardware, shift 12 because of
+	 * using 4K page, and shift more 32 because of
+	 * caculating the high 32 bit value evaluated to hardware.
+	 */
+	roce_set_field(cq_context->cqc_byte_20,
+		       CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_M,
+		       CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S,
+		       (u64)tptr_addr >> 44);
+	cq_context->cqc_byte_20 = cpu_to_le32(cq_context->cqc_byte_20);
+
+	cq_context->cqe_tptr_addr_l = (u32)((u64)tptr_addr >> 12);
+
+	roce_set_field(cq_context->cqc_byte_32,
+		       CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_M,
+		       CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		     CQ_CONTEXT_CQC_BYTE_32_SE_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		     CQ_CONTEXT_CQC_BYTE_32_CE_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		     CQ_CONTEXT_CQC_BYTE_32_NOTIFICATION_FLAG_S, 0);
+	roce_set_bit(cq_context->cqc_byte_32,
+		     CQ_CQNTEXT_CQC_BYTE_32_TYPE_OF_COMPLETION_NOTIFICATION_S,
+		     0);
+	/*The initial value of cq's ci is 0 */
+	roce_set_field(cq_context->cqc_byte_32,
+		       CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_M,
+		       CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S, 0);
+	cq_context->cqc_byte_32 = cpu_to_le32(cq_context->cqc_byte_32);
+}
+
+int hns_roce_v1_req_notify_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
+{
+	struct hns_roce_cq *hr_cq = to_hr_cq(ibcq);
+	u32 notification_flag;
+	u32 doorbell[2];
+	int ret = 0;
+
+	notification_flag = (flags & IB_CQ_SOLICITED_MASK) ==
+			    IB_CQ_SOLICITED ? CQ_DB_REQ_NOT : CQ_DB_REQ_NOT_SOL;
+	/*
+	* flags = 0; Notification Flag = 1, next
+	* flags = 1; Notification Flag = 0, solocited
+	*/
+	doorbell[0] = hr_cq->cons_index & ((hr_cq->cq_depth << 1) - 1);
+	roce_set_bit(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S, 3);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_MDF_S, 1);
+	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_M,
+		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_INP_H_S,
+		       hr_cq->cqn | notification_flag);
+
+	hns_roce_write64_k(doorbell, hr_cq->cq_db_l);
+
+	return ret;
+}
+
+static int hns_roce_v1_poll_one(struct hns_roce_cq *hr_cq,
+				struct hns_roce_qp **cur_qp, struct ib_wc *wc)
+{
+	int qpn;
+	int is_send;
+	u16 wqe_ctr;
+	u32 status;
+	u32 opcode;
+	struct hns_roce_cqe *cqe;
+	struct hns_roce_qp *hr_qp;
+	struct hns_roce_wq *wq;
+	struct hns_roce_wqe_ctrl_seg *sq_wqe;
+	struct hns_roce_dev *hr_dev = to_hr_dev(hr_cq->ib_cq.device);
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Find cqe according consumer index */
+	cqe = next_cqe_sw(hr_cq);
+	if (!cqe)
+		return -EAGAIN;
+
+	++hr_cq->cons_index;
+	/* Memory barrier */
+	rmb();
+	/* 0->SQ, 1->RQ */
+	is_send  = !(roce_get_bit(cqe->cqe_byte_4, CQE_BYTE_4_SQ_RQ_FLAG_S));
+
+	/* Local_qpn in UD cqe is always 1, so it needs to compute new qpn */
+	if (roce_get_field(cqe->cqe_byte_16, CQE_BYTE_16_LOCAL_QPN_M,
+			   CQE_BYTE_16_LOCAL_QPN_S) <= 1) {
+		qpn = roce_get_field(cqe->cqe_byte_20, CQE_BYTE_20_PORT_NUM_M,
+				     CQE_BYTE_20_PORT_NUM_S) +
+		      roce_get_field(cqe->cqe_byte_16, CQE_BYTE_16_LOCAL_QPN_M,
+				     CQE_BYTE_16_LOCAL_QPN_S) *
+				     HNS_ROCE_MAX_PORTS;
+	} else {
+		qpn = roce_get_field(cqe->cqe_byte_16, CQE_BYTE_16_LOCAL_QPN_M,
+				     CQE_BYTE_16_LOCAL_QPN_S);
+	}
+
+	if (!*cur_qp || (qpn & HNS_ROCE_CQE_QPN_MASK) != (*cur_qp)->qpn) {
+		hr_qp = __hns_roce_qp_lookup(hr_dev, qpn);
+		if (unlikely(!hr_qp)) {
+			dev_err(dev, "CQ %06lx with entry for unknown QPN %06x\n",
+				hr_cq->cqn, (qpn & HNS_ROCE_CQE_QPN_MASK));
+			return -EINVAL;
+		}
+
+		*cur_qp = hr_qp;
+	}
+
+	wc->qp = &(*cur_qp)->ibqp;
+	wc->vendor_err = 0;
+
+	status = roce_get_field(cqe->cqe_byte_4,
+				CQE_BYTE_4_STATUS_OF_THE_OPERATION_M,
+				CQE_BYTE_4_STATUS_OF_THE_OPERATION_S) &
+				HNS_ROCE_CQE_STATUS_MASK;
+	switch (status) {
+	case HNS_ROCE_CQE_SUCCESS:
+		wc->status = IB_WC_SUCCESS;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_LENGTH_ERR:
+		wc->status = IB_WC_LOC_LEN_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_QP_OP_ERR:
+		wc->status = IB_WC_LOC_QP_OP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_PROT_ERR:
+		wc->status = IB_WC_LOC_PROT_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_WR_FLUSH_ERR:
+		wc->status = IB_WC_WR_FLUSH_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_MEM_MANAGE_OPERATE_ERR:
+		wc->status = IB_WC_MW_BIND_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_BAD_RESP_ERR:
+		wc->status = IB_WC_BAD_RESP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_LOCAL_ACCESS_ERR:
+		wc->status = IB_WC_LOC_ACCESS_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR:
+		wc->status = IB_WC_REM_INV_REQ_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_ACCESS_ERR:
+		wc->status = IB_WC_REM_ACCESS_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_REMOTE_OP_ERR:
+		wc->status = IB_WC_REM_OP_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR:
+		wc->status = IB_WC_RETRY_EXC_ERR;
+		break;
+	case HNS_ROCE_CQE_SYNDROME_RNR_RETRY_EXC_ERR:
+		wc->status = IB_WC_RNR_RETRY_EXC_ERR;
+		break;
+	default:
+		wc->status = IB_WC_GENERAL_ERR;
+		break;
+	}
+
+	/* CQE status error, directly return */
+	if (wc->status != IB_WC_SUCCESS)
+		return 0;
+
+	if (is_send) {
+		/* SQ conrespond to CQE */
+		sq_wqe = get_send_wqe(*cur_qp, roce_get_field(cqe->cqe_byte_4,
+						CQE_BYTE_4_WQE_INDEX_M,
+						CQE_BYTE_4_WQE_INDEX_S));
+		switch (sq_wqe->flag & HNS_ROCE_WQE_OPCODE_MASK) {
+		case HNS_ROCE_WQE_OPCODE_SEND:
+			wc->opcode = IB_WC_SEND;
+			break;
+		case HNS_ROCE_WQE_OPCODE_RDMA_READ:
+			wc->opcode = IB_WC_RDMA_READ;
+			wc->byte_len = le32_to_cpu(cqe->byte_cnt);
+			break;
+		case HNS_ROCE_WQE_OPCODE_RDMA_WRITE:
+			wc->opcode = IB_WC_RDMA_WRITE;
+			break;
+		case HNS_ROCE_WQE_OPCODE_LOCAL_INV:
+			wc->opcode = IB_WC_LOCAL_INV;
+			break;
+		case HNS_ROCE_WQE_OPCODE_UD_SEND:
+			wc->opcode = IB_WC_SEND;
+			break;
+		default:
+			wc->status = IB_WC_GENERAL_ERR;
+			break;
+		}
+		wc->wc_flags = (sq_wqe->flag & HNS_ROCE_WQE_IMM ?
+				IB_WC_WITH_IMM : 0);
+
+		wq = &(*cur_qp)->sq;
+		if ((*cur_qp)->sq_signal_bits) {
+			/*
+			* If sg_signal_bit is 1,
+			* firstly tail pointer updated to wqe
+			* which current cqe correspond to
+			*/
+			wqe_ctr = (u16)roce_get_field(cqe->cqe_byte_4,
+						      CQE_BYTE_4_WQE_INDEX_M,
+						      CQE_BYTE_4_WQE_INDEX_S);
+			wq->tail += (wqe_ctr - (u16)wq->tail) &
+				    (wq->wqe_cnt - 1);
+		}
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		++wq->tail;
+		} else {
+		/* RQ conrespond to CQE */
+		wc->byte_len = le32_to_cpu(cqe->byte_cnt);
+		opcode = roce_get_field(cqe->cqe_byte_4,
+					CQE_BYTE_4_OPERATION_TYPE_M,
+					CQE_BYTE_4_OPERATION_TYPE_S) &
+					HNS_ROCE_CQE_OPCODE_MASK;
+		switch (opcode) {
+		case HNS_ROCE_OPCODE_RDMA_WITH_IMM_RECEIVE:
+			wc->opcode = IB_WC_RECV_RDMA_WITH_IMM;
+			wc->wc_flags = IB_WC_WITH_IMM;
+			wc->ex.imm_data = le32_to_cpu(cqe->immediate_data);
+			break;
+		case HNS_ROCE_OPCODE_SEND_DATA_RECEIVE:
+			if (roce_get_bit(cqe->cqe_byte_4,
+					 CQE_BYTE_4_IMM_INDICATOR_S)) {
+				wc->opcode = IB_WC_RECV;
+				wc->wc_flags = IB_WC_WITH_IMM;
+				wc->ex.imm_data = le32_to_cpu(
+						  cqe->immediate_data);
+			} else {
+				wc->opcode = IB_WC_RECV;
+				wc->wc_flags = 0;
+			}
+			break;
+		default:
+			wc->status = IB_WC_GENERAL_ERR;
+			break;
+		}
+
+		/* Update tail pointer, record wr_id */
+		wq = &(*cur_qp)->rq;
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		++wq->tail;
+		wc->sl = (u8)roce_get_field(cqe->cqe_byte_20, CQE_BYTE_20_SL_M,
+					    CQE_BYTE_20_SL_S);
+		wc->src_qp = (u8)roce_get_field(cqe->cqe_byte_20,
+						CQE_BYTE_20_REMOTE_QPN_M,
+						CQE_BYTE_20_REMOTE_QPN_S);
+		wc->wc_flags |= (roce_get_bit(cqe->cqe_byte_20,
+					      CQE_BYTE_20_GRH_PRESENT_S) ?
+					      IB_WC_GRH : 0);
+		wc->pkey_index = (u16)roce_get_field(cqe->cqe_byte_28,
+						     CQE_BYTE_28_P_KEY_IDX_M,
+						     CQE_BYTE_28_P_KEY_IDX_S);
+	}
+
+	return 0;
+}
+
+int hns_roce_v1_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
+{
+	struct hns_roce_cq *hr_cq = to_hr_cq(ibcq);
+	struct hns_roce_qp *cur_qp = NULL;
+	unsigned long flags;
+	int npolled;
+	int ret = 0;
+
+	spin_lock_irqsave(&hr_cq->lock, flags);
+
+	for (npolled = 0; npolled < num_entries; ++npolled) {
+		ret = hns_roce_v1_poll_one(hr_cq, &cur_qp, wc + npolled);
+		if (ret)
+			break;
+	}
+
+	if (npolled) {
+		hns_roce_v1_cq_set_ci(hr_cq, hr_cq->cons_index,
+				      &to_hr_dev(ibcq->device)->cq_db_lock);
+	}
+
+	spin_unlock_irqrestore(&hr_cq->lock, flags);
+
+	if (ret == 0 || ret == -EAGAIN)
+		return npolled;
+	else
+		return ret;
+}
+
 static int hns_roce_v1_qp_modify(struct hns_roce_dev *hr_dev,
 				 struct hns_roce_mtt *mtt,
 				 enum hns_roce_qp_state cur_state,
@@ -2271,9 +2613,12 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.set_gid = hns_roce_v1_set_gid,
 	.set_mac = hns_roce_v1_set_mac,
 	.set_mtu = hns_roce_v1_set_mtu,
+	.write_cqc = hns_roce_v1_write_cqc,
 	.modify_qp = hns_roce_v1_modify_qp,
 	.query_qp = hns_roce_v1_query_qp,
 	.destroy_qp = hns_roce_v1_destroy_qp,
 	.post_send = hns_roce_v1_post_send,
 	.post_recv = hns_roce_v1_post_recv,
+	.req_notify_cq = hns_roce_v1_req_notify_cq,
+	.poll_cq = hns_roce_v1_poll_cq,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 912a727..e5d24ee 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -33,6 +33,8 @@
 #ifndef _HNS_ROCE_HW_V1_H
 #define _HNS_ROCE_HW_V1_H
 
+#define CQ_STATE_VALID					2
+
 #define HNS_ROCE_V1_MAX_PD_NUM				0x8000
 #define HNS_ROCE_V1_MAX_CQ_NUM				0x10000
 #define HNS_ROCE_V1_MAX_CQE_NUM				0x8000
@@ -108,6 +110,22 @@
 #define HNS_ROCE_ODB_EXTEND_MODE			1
 
 #define HNS_ROCE_CQE_QPN_MASK				0x3ffff
+#define HNS_ROCE_CQE_STATUS_MASK			0x1f
+#define HNS_ROCE_CQE_OPCODE_MASK			0xf
+
+#define HNS_ROCE_CQE_SUCCESS				0x00
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_LENGTH_ERR		0x01
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_QP_OP_ERR		0x02
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_PROT_ERR		0x03
+#define HNS_ROCE_CQE_SYNDROME_WR_FLUSH_ERR		0x04
+#define HNS_ROCE_CQE_SYNDROME_MEM_MANAGE_OPERATE_ERR	0x05
+#define HNS_ROCE_CQE_SYNDROME_BAD_RESP_ERR		0x06
+#define HNS_ROCE_CQE_SYNDROME_LOCAL_ACCESS_ERR		0x07
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR	0x08
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_ACCESS_ERR		0x09
+#define HNS_ROCE_CQE_SYNDROME_REMOTE_OP_ERR		0x0a
+#define HNS_ROCE_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR	0x0b
+#define HNS_ROCE_CQE_SYNDROME_RNR_RETRY_EXC_ERR		0x0c
 
 #define QP1C_CFGN_OFFSET				0x28
 #define PHY_PORT_OFFSET					0x8
@@ -118,17 +136,114 @@
 #define QKEY_VAL					0x80010000
 #define SDB_INV_CNT_OFFSET				8
 
+struct hns_roce_cq_context {
+	u32 cqc_byte_4;
+	u32 cq_bt_l;
+	u32 cqc_byte_12;
+	u32 cur_cqe_ba0_l;
+	u32 cqc_byte_20;
+	u32 cqe_tptr_addr_l;
+	u32 cur_cqe_ba1_l;
+	u32 cqc_byte_32;
+};
+
+#define CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S 0
+#define CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_M   \
+	(((1UL << 2) - 1) << CQ_CONTEXT_CQC_BYTE_4_CQC_STATE_S)
+
+#define CQ_CONTEXT_CQC_BYTE_4_CQN_S 16
+#define CQ_CONTEXT_CQC_BYTE_4_CQN_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_4_CQN_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_M   \
+	(((1UL << 17) - 1) << CQ_CONTEXT_CQC_BYTE_12_CQ_BT_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S 20
+#define CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_M   \
+	(((1UL << 4) - 1) << CQ_CONTEXT_CQC_BYTE_12_CQ_CQE_SHIFT_S)
+
+#define CQ_CONTEXT_CQC_BYTE_12_CEQN_S 24
+#define CQ_CONTEXT_CQC_BYTE_12_CEQN_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_12_CEQN_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_20_CUR_CQE_BA0_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S 16
+#define CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_20_CQ_CUR_INDEX_S)
+
+#define CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S 8
+#define CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S 0
+#define CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_M   \
+	(((1UL << 5) - 1) << CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_S)
+
+#define CQ_CONTEXT_CQC_BYTE_32_SE_FLAG_S 9
+
+#define CQ_CONTEXT_CQC_BYTE_32_CE_FLAG_S 8
+#define CQ_CONTEXT_CQC_BYTE_32_NOTIFICATION_FLAG_S 14
+#define CQ_CQNTEXT_CQC_BYTE_32_TYPE_OF_COMPLETION_NOTIFICATION_S 15
+
+#define CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S 16
+#define CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_M   \
+	(((1UL << 16) - 1) << CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S)
+
 struct hns_roce_cqe {
 	u32 cqe_byte_4;
+	union {
+		u32 r_key;
+		u32 immediate_data;
+	};
+	u32 byte_cnt;
 	u32 cqe_byte_16;
+	u32 cqe_byte_20;
+	u32 s_mac_l;
+	u32 cqe_byte_28;
+	u32 reserved;
 };
 
 #define CQE_BYTE_4_OWNER_S 7
 #define CQE_BYTE_4_SQ_RQ_FLAG_S 14
 
+#define CQE_BYTE_4_STATUS_OF_THE_OPERATION_S 8
+#define CQE_BYTE_4_STATUS_OF_THE_OPERATION_M   \
+	(((1UL << 5) - 1) << CQE_BYTE_4_STATUS_OF_THE_OPERATION_S)
+
+#define CQE_BYTE_4_WQE_INDEX_S 16
+#define CQE_BYTE_4_WQE_INDEX_M	(((1UL << 14) - 1) << CQE_BYTE_4_WQE_INDEX_S)
+
+#define CQE_BYTE_4_OPERATION_TYPE_S 0
+#define CQE_BYTE_4_OPERATION_TYPE_M   \
+	(((1UL << 4) - 1) << CQE_BYTE_4_OPERATION_TYPE_S)
+
+#define CQE_BYTE_4_IMM_INDICATOR_S 15
+
 #define CQE_BYTE_16_LOCAL_QPN_S 0
 #define CQE_BYTE_16_LOCAL_QPN_M	(((1UL << 24) - 1) << CQE_BYTE_16_LOCAL_QPN_S)
 
+#define CQE_BYTE_20_PORT_NUM_S 26
+#define CQE_BYTE_20_PORT_NUM_M	(((1UL << 3) - 1) << CQE_BYTE_20_PORT_NUM_S)
+
+#define CQE_BYTE_20_SL_S 24
+#define CQE_BYTE_20_SL_M	(((1UL << 2) - 1) << CQE_BYTE_20_SL_S)
+
+#define CQE_BYTE_20_REMOTE_QPN_S 0
+#define CQE_BYTE_20_REMOTE_QPN_M   \
+	(((1UL << 24) - 1) << CQE_BYTE_20_REMOTE_QPN_S)
+
+#define CQE_BYTE_20_GRH_PRESENT_S 29
+
+#define CQE_BYTE_28_P_KEY_IDX_S 16
+#define CQE_BYTE_28_P_KEY_IDX_M	(((1UL << 16) - 1) << CQE_BYTE_28_P_KEY_IDX_S)
+
+#define CQ_DB_REQ_NOT_SOL	0
+#define CQ_DB_REQ_NOT		(1 << 16)
+
 struct hns_roce_wqe_ctrl_seg {
 	__be32 sgl_pa_h;
 	__be32 flag;
@@ -337,6 +452,8 @@ struct hns_roce_sqp_context {
 #define HNS_ROCE_WQE_OPCODE_SEND	(0<<16)
 #define HNS_ROCE_WQE_OPCODE_RDMA_READ	(1<<16)
 #define HNS_ROCE_WQE_OPCODE_RDMA_WRITE	(2<<16)
+#define HNS_ROCE_WQE_OPCODE_LOCAL_INV	(4<<16)
+#define HNS_ROCE_WQE_OPCODE_UD_SEND	(7<<16)
 #define HNS_ROCE_WQE_OPCODE_MASK	(15<<16)
 
 struct hns_roce_qp_context {
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 2f8140b..75a8f29 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -583,6 +583,9 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
 		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
 		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
+		(1ULL << IB_USER_VERBS_CMD_CREATE_CQ) |
+		(1ULL << IB_USER_VERBS_CMD_DESTROY_CQ) |
 		(1ULL << IB_USER_VERBS_CMD_CREATE_QP) |
 		(1ULL << IB_USER_VERBS_CMD_MODIFY_QP) |
 		(1ULL << IB_USER_VERBS_CMD_QUERY_QP) |
@@ -617,6 +620,12 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->post_send		= hr_dev->hw->post_send;
 	ib_dev->post_recv		= hr_dev->hw->post_recv;
 
+	/* CQ */
+	ib_dev->create_cq		= hns_roce_ib_create_cq;
+	ib_dev->destroy_cq		= hns_roce_ib_destroy_cq;
+	ib_dev->req_notify_cq		= hr_dev->hw->req_notify_cq;
+	ib_dev->poll_cq			= hr_dev->hw->poll_cq;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
