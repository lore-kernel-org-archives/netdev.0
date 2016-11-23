From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 02/11] IB/hns: Add code for refreshing CQ CI using TPTR
Date: Wed, 23 Nov 2016 19:41:00 +0000
Message-ID: <20161123194109.420760-3-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Dongdong Huang <hdd.huang@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>

This patch added the code for refreshing CQ CI using TPTR in hip06
SoC.

We will send a doorbell to hardware for refreshing CQ CI when user
succeed to poll a cqe. But it will be failed if the doorbell has
been blocked. So hardware will read a special buffer called TPTR
to get the lastest CI value when the cq is almost full.

This patch support the special CI buffer as follows:
a) Alloc the memory for TPTR in the hns_roce_tptr_init function and
   free it in hns_roce_tptr_free function, these two functions will
   be called in probe function and in the remove function.
b) Add the code for computing offset(every cq need 2 bytes) and
   write the dma addr to every cq context to notice hardware in the
   function named hns_roce_v1_write_cqc.
c) Add code for mapping TPTR buffer to user space in function named
   hns_roce_mmap. The mapping distinguish TPTR and UAR of user mode
   by vm_pgoff(0: UAR, 1: TPTR, others:invaild) in hip06.
d) Alloc the code for refreshing CQ CI using TPTR in the function
   named hns_roce_v1_poll_cq.
e) Add some variable definitions to the related structure.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Dongdong Huang(Donald) <hdd.huang@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_common.h |    2 -
 drivers/infiniband/hw/hns/hns_roce_cq.c     |    9 +++
 drivers/infiniband/hw/hns/hns_roce_device.h |    6 +-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |   79 ++++++++++++++++++++++++---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |    9 +++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   13 ++++-
 6 files changed, 103 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 2970161..0dcb620 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -253,8 +253,6 @@
 #define ROCEE_VENDOR_ID_REG			0x0
 #define ROCEE_VENDOR_PART_ID_REG		0x4
 
-#define ROCEE_HW_VERSION_REG			0x8
-
 #define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
 #define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 0973659..5dc8d92 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -349,6 +349,15 @@ struct ib_cq *hns_roce_ib_create_cq(struct ib_device *ib_dev,
 		goto err_mtt;
 	}
 
+	/*
+	 * For the QP created by kernel space, tptr value should be initialized
+	 * to zero; For the QP created by user space, it will cause synchronous
+	 * problems if tptr is set to zero here, so we initialze it in user
+	 * space.
+	 */
+	if (!context)
+		*hr_cq->tptr_addr = 0;
+
 	/* Get created cq handler and carry out event */
 	hr_cq->comp = hns_roce_ib_cq_comp;
 	hr_cq->event = hns_roce_ib_cq_event;
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 3417315..7242b14 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -37,6 +37,8 @@
 
 #define DRV_NAME "hns_roce"
 
+#define HNS_ROCE_HW_VER1	('h' << 24 | 'i' << 16 | '0' << 8 | '6')
+
 #define MAC_ADDR_OCTET_NUM			6
 #define HNS_ROCE_MAX_MSG_LEN			0x80000000
 
@@ -296,7 +298,7 @@ struct hns_roce_cq {
 	u32				cq_depth;
 	u32				cons_index;
 	void __iomem			*cq_db_l;
-	void __iomem			*tptr_addr;
+	u16				*tptr_addr;
 	unsigned long			cqn;
 	u32				vector;
 	atomic_t			refcount;
@@ -553,6 +555,8 @@ struct hns_roce_dev {
 
 	int			cmd_mod;
 	int			loop_idc;
+	dma_addr_t		tptr_dma_addr; /*only for hw v1*/
+	u32			tptr_size; /*only for hw v1*/
 	struct hns_roce_hw	*hw;
 };
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 7485514..959d5ca 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -849,6 +849,45 @@ static void hns_roce_bt_free(struct hns_roce_dev *hr_dev)
 		priv->bt_table.qpc_buf.buf, priv->bt_table.qpc_buf.map);
 }
 
+static int hns_roce_tptr_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_buf_list *tptr_buf;
+	struct hns_roce_v1_priv *priv;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	tptr_buf = &priv->tptr_table.tptr_buf;
+
+	/*
+	 * This buffer will be used for CQ's tptr(tail pointer), also
+	 * named ci(customer index). Every CQ will use 2 bytes to save
+	 * cqe ci in hip06. Hardware will read this area to get new ci
+	 * when the queue is almost full.
+	 */
+	tptr_buf->buf = dma_alloc_coherent(dev, HNS_ROCE_V1_TPTR_BUF_SIZE,
+					   &tptr_buf->map, GFP_KERNEL);
+	if (!tptr_buf->buf)
+		return -ENOMEM;
+
+	hr_dev->tptr_dma_addr = tptr_buf->map;
+	hr_dev->tptr_size = HNS_ROCE_V1_TPTR_BUF_SIZE;
+
+	return 0;
+}
+
+static void hns_roce_tptr_free(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_buf_list *tptr_buf;
+	struct hns_roce_v1_priv *priv;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	tptr_buf = &priv->tptr_table.tptr_buf;
+
+	dma_free_coherent(dev, HNS_ROCE_V1_TPTR_BUF_SIZE,
+			  tptr_buf->buf, tptr_buf->map);
+}
+
 /**
  * hns_roce_v1_reset - reset RoCE
  * @hr_dev: RoCE device struct pointer
@@ -906,12 +945,11 @@ void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
 	hr_dev->vendor_id = le32_to_cpu(roce_read(hr_dev, ROCEE_VENDOR_ID_REG));
 	hr_dev->vendor_part_id = le32_to_cpu(roce_read(hr_dev,
 					     ROCEE_VENDOR_PART_ID_REG));
-	hr_dev->hw_rev = le32_to_cpu(roce_read(hr_dev, ROCEE_HW_VERSION_REG));
-
 	hr_dev->sys_image_guid = le32_to_cpu(roce_read(hr_dev,
 					     ROCEE_SYS_IMAGE_GUID_L_REG)) |
 				((u64)le32_to_cpu(roce_read(hr_dev,
 					    ROCEE_SYS_IMAGE_GUID_H_REG)) << 32);
+	hr_dev->hw_rev		= HNS_ROCE_HW_VER1;
 
 	caps->num_qps		= HNS_ROCE_V1_MAX_QP_NUM;
 	caps->max_wqes		= HNS_ROCE_V1_MAX_WQE_NUM;
@@ -1009,8 +1047,17 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 		goto error_failed_bt_init;
 	}
 
+	ret = hns_roce_tptr_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "tptr init failed!\n");
+		goto error_failed_tptr_init;
+	}
+
 	return 0;
 
+error_failed_tptr_init:
+	hns_roce_bt_free(hr_dev);
+
 error_failed_bt_init:
 	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
 	hns_roce_raq_free(hr_dev);
@@ -1022,6 +1069,7 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 
 void hns_roce_v1_exit(struct hns_roce_dev *hr_dev)
 {
+	hns_roce_tptr_free(hr_dev);
 	hns_roce_bt_free(hr_dev);
 	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
 	hns_roce_raq_free(hr_dev);
@@ -1339,14 +1387,21 @@ void hns_roce_v1_write_cqc(struct hns_roce_dev *hr_dev,
 			   dma_addr_t dma_handle, int nent, u32 vector)
 {
 	struct hns_roce_cq_context *cq_context = NULL;
-	void __iomem *tptr_addr;
+	struct hns_roce_buf_list *tptr_buf;
+	struct hns_roce_v1_priv *priv;
+	dma_addr_t tptr_dma_addr;
+	int offset;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	tptr_buf = &priv->tptr_table.tptr_buf;
 
 	cq_context = mb_buf;
 	memset(cq_context, 0, sizeof(*cq_context));
 
-	tptr_addr = 0;
-	hr_dev->priv_addr = tptr_addr;
-	hr_cq->tptr_addr = tptr_addr;
+	/* Get the tptr for this CQ. */
+	offset = hr_cq->cqn * HNS_ROCE_V1_TPTR_ENTRY_SIZE;
+	tptr_dma_addr = tptr_buf->map + offset;
+	hr_cq->tptr_addr = (u16 *)(tptr_buf->buf + offset);
 
 	/* Register cq_context members */
 	roce_set_field(cq_context->cqc_byte_4,
@@ -1390,10 +1445,10 @@ void hns_roce_v1_write_cqc(struct hns_roce_dev *hr_dev,
 	roce_set_field(cq_context->cqc_byte_20,
 		       CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_M,
 		       CQ_CONTEXT_CQC_BYTE_20_CQE_TPTR_ADDR_H_S,
-		       (u64)tptr_addr >> 44);
+		       tptr_dma_addr >> 44);
 	cq_context->cqc_byte_20 = cpu_to_le32(cq_context->cqc_byte_20);
 
-	cq_context->cqe_tptr_addr_l = (u32)((u64)tptr_addr >> 12);
+	cq_context->cqe_tptr_addr_l = (u32)(tptr_dma_addr >> 12);
 
 	roce_set_field(cq_context->cqc_byte_32,
 		       CQ_CONTEXT_CQC_BYTE_32_CUR_CQE_BA1_H_M,
@@ -1659,8 +1714,14 @@ int hns_roce_v1_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 			break;
 	}
 
-	if (npolled)
+	if (npolled) {
+		*hr_cq->tptr_addr = hr_cq->cons_index &
+			((hr_cq->cq_depth << 1) - 1);
+
+		/* Memroy barrier */
+		wmb();
 		hns_roce_v1_cq_set_ci(hr_cq, hr_cq->cons_index);
+	}
 
 	spin_unlock_irqrestore(&hr_cq->lock, flags);
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 2e1878b..6004c7f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -104,6 +104,10 @@
 
 #define HNS_ROCE_BT_RSV_BUF_SIZE			(1 << 17)
 
+#define HNS_ROCE_V1_TPTR_ENTRY_SIZE			2
+#define HNS_ROCE_V1_TPTR_BUF_SIZE	\
+	(HNS_ROCE_V1_TPTR_ENTRY_SIZE * HNS_ROCE_V1_MAX_CQ_NUM)
+
 #define HNS_ROCE_ODB_POLL_MODE				0
 
 #define HNS_ROCE_SDB_NORMAL_MODE			0
@@ -983,10 +987,15 @@ struct hns_roce_bt_table {
 	struct hns_roce_buf_list cqc_buf;
 };
 
+struct hns_roce_tptr_table {
+	struct hns_roce_buf_list tptr_buf;
+};
+
 struct hns_roce_v1_priv {
 	struct hns_roce_db_table  db_table;
 	struct hns_roce_raq_table raq_table;
 	struct hns_roce_bt_table  bt_table;
+	struct hns_roce_tptr_table tptr_table;
 };
 
 int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset);
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 764e35a..6770171 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -549,6 +549,8 @@ static int hns_roce_dealloc_ucontext(struct ib_ucontext *ibcontext)
 static int hns_roce_mmap(struct ib_ucontext *context,
 			 struct vm_area_struct *vma)
 {
+	struct hns_roce_dev *hr_dev = to_hr_dev(context->device);
+
 	if (((vma->vm_end - vma->vm_start) % PAGE_SIZE) != 0)
 		return -EINVAL;
 
@@ -558,10 +560,15 @@ static int hns_roce_mmap(struct ib_ucontext *context,
 				       to_hr_ucontext(context)->uar.pfn,
 				       PAGE_SIZE, vma->vm_page_prot))
 			return -EAGAIN;
-
-	} else {
+	} else if (vma->vm_pgoff == 1 && hr_dev->hw_rev == HNS_ROCE_HW_VER1) {
+		/* vm_pgoff: 1 -- TPTR */
+		if (io_remap_pfn_range(vma, vma->vm_start,
+				       hr_dev->tptr_dma_addr >> PAGE_SHIFT,
+				       hr_dev->tptr_size,
+				       vma->vm_page_prot))
+			return -EAGAIN;
+	} else
 		return -EINVAL;
-	}
 
 	return 0;
 }
-- 
1.7.9.5
