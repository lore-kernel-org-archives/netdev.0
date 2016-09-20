From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC v2 05/12] qedr: Add support for PD,PKEY and CQ verbs
Date: Tue, 20 Sep 2016 13:35:57 +0300
Message-ID: <1474367764-9555-6-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Add support for protection domain and completion queue verbs.

Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/qedr/main.c          |  18 +-
 drivers/infiniband/hw/qedr/qedr.h          |  78 +++++
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h |  79 +++++
 drivers/infiniband/hw/qedr/verbs.c         | 543 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.h         |  14 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 313 +++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h |  20 ++
 include/linux/qed/qed_roce_if.h            |  29 ++
 include/uapi/rdma/providers/qedr-abi.h     |  19 +
 9 files changed, 1112 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index aa2832f..c99dd6a 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -93,7 +93,13 @@ static int qedr_register_device(struct qedr_dev *dev)
 
 	dev->ibdev.uverbs_cmd_mask = QEDR_UVERBS(GET_CONTEXT) |
 				     QEDR_UVERBS(QUERY_DEVICE) |
-				     QEDR_UVERBS(QUERY_PORT);
+				     QEDR_UVERBS(QUERY_PORT) |
+				     QEDR_UVERBS(ALLOC_PD) |
+				     QEDR_UVERBS(DEALLOC_PD) |
+				     QEDR_UVERBS(CREATE_CQ) |
+				     QEDR_UVERBS(RESIZE_CQ) |
+				     QEDR_UVERBS(DESTROY_CQ) |
+				     QEDR_UVERBS(REQ_NOTIFY_CQ);
 
 	dev->ibdev.phys_port_cnt = 1;
 	dev->ibdev.num_comp_vectors = dev->num_cnq;
@@ -110,6 +116,16 @@ static int qedr_register_device(struct qedr_dev *dev)
 	dev->ibdev.dealloc_ucontext = qedr_dealloc_ucontext;
 	dev->ibdev.mmap = qedr_mmap;
 
+	dev->ibdev.alloc_pd = qedr_alloc_pd;
+	dev->ibdev.dealloc_pd = qedr_dealloc_pd;
+
+	dev->ibdev.create_cq = qedr_create_cq;
+	dev->ibdev.destroy_cq = qedr_destroy_cq;
+	dev->ibdev.resize_cq = qedr_resize_cq;
+	dev->ibdev.req_notify_cq = qedr_arm_cq;
+
+	dev->ibdev.query_pkey = qedr_query_pkey;
+
 	dev->ibdev.dma_device = &dev->pdev->dev;
  
 	dev->ibdev.get_link_layer = qedr_link_layer;
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 9fde4ee..dd974d5 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -44,8 +44,12 @@
 #define QEDR_NODE_DESC "QLogic 579xx RoCE HCA"
 #define DP_NAME(dev) ((dev)->ibdev.name)
 
+#define QEDR_CQ_MAGIC_NUMBER	(0x11223344)
+
 enum DP_QEDR_MODULE {
 	QEDR_MSG_INIT = 0x10000,
+	QEDR_MSG_CQ = 0x20000,
+	QEDR_MSG_MR = 0x100000,
 	QEDR_MSG_MISC = 0x400000,
 };
 
@@ -179,6 +183,12 @@ struct qedr_dev {
 #define QEDR_ROCE_PKEY_TABLE_LEN 1
 #define QEDR_ROCE_PKEY_DEFAULT 0xffff
 
+struct qedr_pbl {
+	struct list_head list_entry;
+	void *va;
+	dma_addr_t pa;
+};
+
 struct qedr_ucontext {
 	struct ib_ucontext ibucontext;
 	struct qedr_dev *dev;
@@ -194,6 +204,64 @@ struct qedr_ucontext {
 	struct mutex mm_list_lock;
 };
 
+union db_prod64 {
+	struct rdma_pwm_val32_data data;
+	u64 raw;
+};
+
+enum qedr_cq_type {
+	QEDR_CQ_TYPE_GSI,
+	QEDR_CQ_TYPE_KERNEL,
+	QEDR_CQ_TYPE_USER
+};
+
+struct qedr_pbl_info {
+	u32 num_pbls;
+	u32 num_pbes;
+	u32 pbl_size;
+	u32 pbe_size;
+	bool two_layered;
+};
+
+struct qedr_userq {
+	struct ib_umem *umem;
+	struct qedr_pbl_info pbl_info;
+	struct qedr_pbl *pbl_tbl;
+	u64 buf_addr;
+	size_t buf_len;
+};
+
+struct qedr_cq {
+	struct ib_cq ibcq;
+
+	enum qedr_cq_type cq_type;
+	u32 sig;
+
+	u16 icid;
+
+	/* Lock to protect multiplem CQ's */
+	spinlock_t cq_lock;
+	u8 arm_flags;
+	struct qed_chain pbl;
+
+	void __iomem *db_addr;
+	union db_prod64 db;
+
+	u8 pbl_toggle;
+	union rdma_cqe *latest_cqe;
+	union rdma_cqe *toggle_cqe;
+
+	u32 cq_cons;
+
+	struct qedr_userq q;
+};
+
+struct qedr_pd {
+	struct ib_pd ibpd;
+	u32 pd_id;
+	struct qedr_ucontext *uctx;
+};
+
 struct qedr_mm {
 	struct {
 		u64 phy_addr;
@@ -213,4 +281,14 @@ static inline struct qedr_dev *get_qedr_dev(struct ib_device *ibdev)
 	return container_of(ibdev, struct qedr_dev, ibdev);
 }
 
+static inline struct qedr_pd *get_qedr_pd(struct ib_pd *ibpd)
+{
+	return container_of(ibpd, struct qedr_pd, ibpd);
+}
+
+static inline struct qedr_cq *get_qedr_cq(struct ib_cq *ibcq)
+{
+	return container_of(ibcq, struct qedr_cq, ibcq);
+}
+
 #endif
diff --git a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
index 3e508fb..84f6520 100644
--- a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
+++ b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
@@ -47,6 +47,19 @@ struct rdma_cqe_responder {
 	__le32 imm_data_hi;
 	__le16 rq_cons;
 	u8 flags;
+#define RDMA_CQE_RESPONDER_TOGGLE_BIT_MASK  0x1
+#define RDMA_CQE_RESPONDER_TOGGLE_BIT_SHIFT 0
+#define RDMA_CQE_RESPONDER_TYPE_MASK        0x3
+#define RDMA_CQE_RESPONDER_TYPE_SHIFT       1
+#define RDMA_CQE_RESPONDER_INV_FLG_MASK     0x1
+#define RDMA_CQE_RESPONDER_INV_FLG_SHIFT    3
+#define RDMA_CQE_RESPONDER_IMM_FLG_MASK     0x1
+#define RDMA_CQE_RESPONDER_IMM_FLG_SHIFT    4
+#define RDMA_CQE_RESPONDER_RDMA_FLG_MASK    0x1
+#define RDMA_CQE_RESPONDER_RDMA_FLG_SHIFT   5
+#define RDMA_CQE_RESPONDER_RESERVED2_MASK   0x3
+#define RDMA_CQE_RESPONDER_RESERVED2_SHIFT  6
+	u8 status;
 };
 
 struct rdma_cqe_requester {
@@ -58,6 +71,12 @@ struct rdma_cqe_requester {
 	__le32 reserved3;
 	__le16 reserved4;
 	u8 flags;
+#define RDMA_CQE_REQUESTER_TOGGLE_BIT_MASK  0x1
+#define RDMA_CQE_REQUESTER_TOGGLE_BIT_SHIFT 0
+#define RDMA_CQE_REQUESTER_TYPE_MASK        0x3
+#define RDMA_CQE_REQUESTER_TYPE_SHIFT       1
+#define RDMA_CQE_REQUESTER_RESERVED5_MASK   0x1F
+#define RDMA_CQE_REQUESTER_RESERVED5_SHIFT  3
 	u8 status;
 };
 
@@ -66,6 +85,12 @@ struct rdma_cqe_common {
 	struct regpair qp_handle;
 	__le16 reserved1[7];
 	u8 flags;
+#define RDMA_CQE_COMMON_TOGGLE_BIT_MASK  0x1
+#define RDMA_CQE_COMMON_TOGGLE_BIT_SHIFT 0
+#define RDMA_CQE_COMMON_TYPE_MASK        0x3
+#define RDMA_CQE_COMMON_TYPE_SHIFT       1
+#define RDMA_CQE_COMMON_RESERVED2_MASK   0x1F
+#define RDMA_CQE_COMMON_RESERVED2_SHIFT  3
 	u8 status;
 };
 
@@ -76,6 +101,45 @@ union rdma_cqe {
 	struct rdma_cqe_common cmn;
 };
 
+/* * CQE requester status enumeration */
+enum rdma_cqe_requester_status_enum {
+	RDMA_CQE_REQ_STS_OK,
+	RDMA_CQE_REQ_STS_BAD_RESPONSE_ERR,
+	RDMA_CQE_REQ_STS_LOCAL_LENGTH_ERR,
+	RDMA_CQE_REQ_STS_LOCAL_QP_OPERATION_ERR,
+	RDMA_CQE_REQ_STS_LOCAL_PROTECTION_ERR,
+	RDMA_CQE_REQ_STS_MEMORY_MGT_OPERATION_ERR,
+	RDMA_CQE_REQ_STS_REMOTE_INVALID_REQUEST_ERR,
+	RDMA_CQE_REQ_STS_REMOTE_ACCESS_ERR,
+	RDMA_CQE_REQ_STS_REMOTE_OPERATION_ERR,
+	RDMA_CQE_REQ_STS_RNR_NAK_RETRY_CNT_ERR,
+	RDMA_CQE_REQ_STS_TRANSPORT_RETRY_CNT_ERR,
+	RDMA_CQE_REQ_STS_WORK_REQUEST_FLUSHED_ERR,
+	MAX_RDMA_CQE_REQUESTER_STATUS_ENUM
+};
+
+/* CQE responder status enumeration */
+enum rdma_cqe_responder_status_enum {
+	RDMA_CQE_RESP_STS_OK,
+	RDMA_CQE_RESP_STS_LOCAL_ACCESS_ERR,
+	RDMA_CQE_RESP_STS_LOCAL_LENGTH_ERR,
+	RDMA_CQE_RESP_STS_LOCAL_QP_OPERATION_ERR,
+	RDMA_CQE_RESP_STS_LOCAL_PROTECTION_ERR,
+	RDMA_CQE_RESP_STS_MEMORY_MGT_OPERATION_ERR,
+	RDMA_CQE_RESP_STS_REMOTE_INVALID_REQUEST_ERR,
+	RDMA_CQE_RESP_STS_WORK_REQUEST_FLUSHED_ERR,
+	MAX_RDMA_CQE_RESPONDER_STATUS_ENUM
+};
+
+/* CQE type enumeration */
+enum rdma_cqe_type {
+	RDMA_CQE_TYPE_REQUESTER,
+	RDMA_CQE_TYPE_RESPONDER_RQ,
+	RDMA_CQE_TYPE_RESPONDER_SRQ,
+	RDMA_CQE_TYPE_INVALID,
+	MAX_RDMA_CQE_TYPE
+};
+
 struct rdma_sq_sge {
 	__le32 length;
 	struct regpair	addr;
@@ -93,4 +157,19 @@ struct rdma_srq_sge {
 	__le32 length;
 	__le32 l_key;
 };
+
+/* Rdma doorbell data for CQ */
+struct rdma_pwm_val32_data {
+	__le16 icid;
+	u8 agg_flags;
+	u8 params;
+#define RDMA_PWM_VAL32_DATA_AGG_CMD_MASK    0x3
+#define RDMA_PWM_VAL32_DATA_AGG_CMD_SHIFT   0
+#define RDMA_PWM_VAL32_DATA_BYPASS_EN_MASK  0x1
+#define RDMA_PWM_VAL32_DATA_BYPASS_EN_SHIFT 2
+#define RDMA_PWM_VAL32_DATA_RESERVED_MASK   0x1F
+#define RDMA_PWM_VAL32_DATA_RESERVED_SHIFT  3
+	__le32 value;
+};
+
 #endif /* __QED_HSI_RDMA__ */
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index c37158c..e5c4aa1 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -25,6 +25,17 @@
 #include "verbs.h"
 #include <rdma/providers/qedr-abi.h> 
 
+#define DB_ADDR_SHIFT(addr)		((addr) << DB_PWM_ADDR_OFFSET_SHIFT)
+
+int qedr_query_pkey(struct ib_device *ibdev, u8 port, u16 index, u16 *pkey)
+{
+	if (index > QEDR_ROCE_PKEY_TABLE_LEN)
+		return -EINVAL;
+
+	*pkey = QEDR_ROCE_PKEY_DEFAULT;
+	return 0;
+}
+
 int qedr_query_gid(struct ib_device *ibdev, u8 port, int index,
 		   union ib_gid *sgid)
 {
@@ -415,3 +426,535 @@ int qedr_mmap(struct ib_ucontext *context, struct vm_area_struct *vma)
 	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr_mmap return code: %d\n", rc);
 	return rc;
 }
+
+struct ib_pd *qedr_alloc_pd(struct ib_device *ibdev,
+			    struct ib_ucontext *context, struct ib_udata *udata)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibdev);
+	struct qedr_ucontext *uctx = NULL;
+	struct qedr_alloc_pd_uresp uresp;
+	struct qedr_pd *pd;
+	u16 pd_id;
+	int rc;
+
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "Function called from: %s\n",
+		   (udata && context) ? "User Lib" : "Kernel");
+	if (udata && context)
+		uctx = get_qedr_ucontext(context);
+
+	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
+	if (!pd) {
+		DP_ERR(dev, "failed to alloce PD\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (!dev->rdma_ctx) {
+		DP_ERR(dev, "invlaid RDMA context\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	dev->ops->rdma_alloc_pd(dev->rdma_ctx, &pd_id);
+
+	uresp.pd_id = pd_id;
+	pd->pd_id = pd_id;
+
+	if (uctx) {
+		rc = ib_copy_to_udata(udata, &uresp, sizeof(uresp));
+		if (rc)
+			DP_ERR(dev, "copy error pd_id=0x%x.\n", pd_id);
+		uctx->pd = pd;
+		pd->uctx = uctx;
+	}
+
+	return &pd->ibpd;
+}
+
+int qedr_dealloc_pd(struct ib_pd *ibpd)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
+	struct qedr_pd *pd = get_qedr_pd(ibpd);
+
+	if (!pd)
+		pr_err("Invalid PD received in dealloc_pd\n");
+
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "Deallocating PD %d\n", pd->pd_id);
+	dev->ops->rdma_dealloc_pd(dev->rdma_ctx, pd->pd_id);
+
+	kfree(pd);
+
+	return 0;
+}
+
+static void qedr_free_pbl(struct qedr_dev *dev,
+			  struct qedr_pbl_info *pbl_info, struct qedr_pbl *pbl)
+{
+	struct pci_dev *pdev = dev->pdev;
+	int i;
+
+	for (i = 0; i < pbl_info->num_pbls; i++) {
+		if (!pbl[i].va)
+			continue;
+		dma_free_coherent(&pdev->dev, pbl_info->pbl_size,
+				  pbl[i].va, pbl[i].pa);
+	}
+
+	kfree(pbl);
+}
+
+#define MIN_FW_PBL_PAGE_SIZE (4 * 1024)
+#define MAX_FW_PBL_PAGE_SIZE (64 * 1024)
+
+#define NUM_PBES_ON_PAGE(_page_size) (_page_size / sizeof(u64))
+#define MAX_PBES_ON_PAGE NUM_PBES_ON_PAGE(MAX_FW_PBL_PAGE_SIZE)
+#define MAX_PBES_TWO_LAYER (MAX_PBES_ON_PAGE * MAX_PBES_ON_PAGE)
+
+static struct qedr_pbl *qedr_alloc_pbl_tbl(struct qedr_dev *dev,
+					   struct qedr_pbl_info *pbl_info,
+					   gfp_t flags)
+{
+	struct pci_dev *pdev = dev->pdev;
+	struct qedr_pbl *pbl_table;
+	dma_addr_t *pbl_main_tbl;
+	dma_addr_t pa;
+	int rc = 0;
+	void *va;
+	int i;
+
+	pbl_table = kcalloc(pbl_info->num_pbls, sizeof(*pbl_table), flags);
+
+	if (!pbl_table) {
+		DP_ERR(dev, "pbl table is NULL\n");
+		return NULL;
+	}
+
+	for (i = 0; i < pbl_info->num_pbls; i++) {
+		va = dma_alloc_coherent(&pdev->dev, pbl_info->pbl_size,
+					&pa, flags);
+		if (!va) {
+			DP_ERR(dev, "Failed to allocate pbl#%d\n", i);
+			rc = -ENOMEM;
+			goto err;
+		}
+		memset(va, 0, pbl_info->pbl_size);
+		pbl_table[i].va = va;
+		pbl_table[i].pa = pa;
+	}
+
+	/* Two-Layer PBLs, if we have more than one pbl we need to initialize
+	 * the first one with physical pointers to all of the rest
+	 */
+	pbl_main_tbl = (dma_addr_t *)pbl_table[0].va;
+	for (i = 0; i < pbl_info->num_pbls - 1; i++)
+		pbl_main_tbl[i] = pbl_table[i + 1].pa;
+
+	return pbl_table;
+
+err:
+	qedr_free_pbl(dev, pbl_info, pbl_table);
+	return NULL;
+}
+
+static int qedr_prepare_pbl_tbl(struct qedr_dev *dev,
+				struct qedr_pbl_info *pbl_info,
+				u32 num_pbes, int two_layer_capable)
+{
+	u32 pbl_capacity;
+	u32 pbl_size;
+	u32 num_pbls;
+
+	if ((num_pbes > MAX_PBES_ON_PAGE) && two_layer_capable) {
+		if (num_pbes > MAX_PBES_TWO_LAYER) {
+			DP_ERR(dev, "prepare pbl table: too many pages %d\n",
+			       num_pbes);
+			return -EINVAL;
+		}
+
+		/* calculate required pbl page size */
+		pbl_size = MIN_FW_PBL_PAGE_SIZE;
+		pbl_capacity = NUM_PBES_ON_PAGE(pbl_size) *
+			       NUM_PBES_ON_PAGE(pbl_size);
+
+		while (pbl_capacity < num_pbes) {
+			pbl_size *= 2;
+			pbl_capacity = pbl_size / sizeof(u64);
+			pbl_capacity = pbl_capacity * pbl_capacity;
+		}
+
+		num_pbls = DIV_ROUND_UP(num_pbes, NUM_PBES_ON_PAGE(pbl_size));
+		num_pbls++;	/* One for the layer0 ( points to the pbls) */
+		pbl_info->two_layered = true;
+	} else {
+		/* One layered PBL */
+		num_pbls = 1;
+		pbl_size = max_t(u32, MIN_FW_PBL_PAGE_SIZE,
+				 roundup_pow_of_two((num_pbes * sizeof(u64))));
+		pbl_info->two_layered = false;
+	}
+
+	pbl_info->num_pbls = num_pbls;
+	pbl_info->pbl_size = pbl_size;
+	pbl_info->num_pbes = num_pbes;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR,
+		   "prepare pbl table: num_pbes=%d, num_pbls=%d, pbl_size=%d\n",
+		   pbl_info->num_pbes, pbl_info->num_pbls, pbl_info->pbl_size);
+
+	return 0;
+}
+
+static void qedr_populate_pbls(struct qedr_dev *dev, struct ib_umem *umem,
+			       struct qedr_pbl *pbl,
+			       struct qedr_pbl_info *pbl_info)
+{
+	int shift, pg_cnt, pages, pbe_cnt, total_num_pbes = 0;
+	struct qedr_pbl *pbl_tbl;
+	struct scatterlist *sg;
+	struct regpair *pbe;
+	int entry;
+	u32 addr;
+
+	if (!pbl_info->num_pbes)
+		return;
+
+	/* If we have a two layered pbl, the first pbl points to the rest
+	 * of the pbls and the first entry lays on the second pbl in the table
+	 */
+	if (pbl_info->two_layered)
+		pbl_tbl = &pbl[1];
+	else
+		pbl_tbl = pbl;
+
+	pbe = (struct regpair *)pbl_tbl->va;
+	if (!pbe) {
+		DP_ERR(dev, "pbe is NULL\n");
+		return;
+	}
+
+	pbe_cnt = 0;
+
+	shift = ilog2(umem->page_size);
+
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		pages = sg_dma_len(sg) >> shift;
+		for (pg_cnt = 0; pg_cnt < pages; pg_cnt++) {
+			/* store the page address in pbe */
+			pbe->lo = cpu_to_le32(sg_dma_address(sg) +
+					      umem->page_size * pg_cnt);
+			addr = upper_32_bits(sg_dma_address(sg) +
+					     umem->page_size * pg_cnt);
+			pbe->hi = cpu_to_le32(addr);
+			pbe_cnt++;
+			total_num_pbes++;
+			pbe++;
+
+			if (total_num_pbes == pbl_info->num_pbes)
+				return;
+
+			/* If the given pbl is full storing the pbes,
+			 * move to next pbl.
+			 */
+			if (pbe_cnt == (pbl_info->pbl_size / sizeof(u64))) {
+				pbl_tbl++;
+				pbe = (struct regpair *)pbl_tbl->va;
+				pbe_cnt = 0;
+			}
+		}
+	}
+}
+
+static int qedr_copy_cq_uresp(struct qedr_dev *dev,
+			      struct qedr_cq *cq, struct ib_udata *udata)
+{
+	struct qedr_create_cq_uresp uresp;
+	int rc;
+
+	memset(&uresp, 0, sizeof(uresp));
+
+	uresp.db_offset = DB_ADDR_SHIFT(DQ_PWM_OFFSET_UCM_RDMA_CQ_CONS_32BIT);
+	uresp.icid = cq->icid;
+
+	rc = ib_copy_to_udata(udata, &uresp, sizeof(uresp));
+	if (rc)
+		DP_ERR(dev, "copy error cqid=0x%x.\n", cq->icid);
+
+	return rc;
+}
+
+static void consume_cqe(struct qedr_cq *cq)
+{
+	if (cq->latest_cqe == cq->toggle_cqe)
+		cq->pbl_toggle ^= RDMA_CQE_REQUESTER_TOGGLE_BIT_MASK;
+
+	cq->latest_cqe = qed_chain_consume(&cq->pbl);
+}
+
+static inline int qedr_align_cq_entries(int entries)
+{
+	u64 size, aligned_size;
+
+	/* We allocate an extra entry that we don't report to the FW. */
+	size = (entries + 1) * QEDR_CQE_SIZE;
+	aligned_size = ALIGN(size, PAGE_SIZE);
+
+	return aligned_size / QEDR_CQE_SIZE;
+}
+
+static inline int qedr_init_user_queue(struct ib_ucontext *ib_ctx,
+				       struct qedr_dev *dev,
+				       struct qedr_userq *q,
+				       u64 buf_addr, size_t buf_len,
+				       int access, int dmasync)
+{
+	int page_cnt;
+	int rc;
+
+	q->buf_addr = buf_addr;
+	q->buf_len = buf_len;
+	q->umem = ib_umem_get(ib_ctx, q->buf_addr, q->buf_len, access, dmasync);
+	if (IS_ERR(q->umem)) {
+		DP_ERR(dev, "create user queue: failed ib_umem_get, got %ld\n",
+		       PTR_ERR(q->umem));
+		return PTR_ERR(q->umem);
+	}
+
+	page_cnt = ib_umem_page_count(q->umem);
+	rc = qedr_prepare_pbl_tbl(dev, &q->pbl_info, page_cnt, 0);
+	if (rc)
+		goto err0;
+
+	q->pbl_tbl = qedr_alloc_pbl_tbl(dev, &q->pbl_info, GFP_KERNEL);
+	if (!q->pbl_tbl)
+		goto err0;
+
+	qedr_populate_pbls(dev, q->umem, q->pbl_tbl, &q->pbl_info);
+
+	return 0;
+
+err0:
+	ib_umem_release(q->umem);
+
+	return rc;
+}
+
+static inline void qedr_init_cq_params(struct qedr_cq *cq,
+				       struct qedr_ucontext *ctx,
+				       struct qedr_dev *dev, int vector,
+				       int chain_entries, int page_cnt,
+				       u64 pbl_ptr,
+				       struct qed_rdma_create_cq_in_params
+				       *params)
+{
+	memset(params, 0, sizeof(*params));
+	params->cq_handle_hi = upper_32_bits((uintptr_t)cq);
+	params->cq_handle_lo = lower_32_bits((uintptr_t)cq);
+	params->cnq_id = vector;
+	params->cq_size = chain_entries - 1;
+	params->dpi = (ctx) ? ctx->dpi : dev->dpi;
+	params->pbl_num_pages = page_cnt;
+	params->pbl_ptr = pbl_ptr;
+	params->pbl_two_level = 0;
+}
+
+static void doorbell_cq(struct qedr_cq *cq, u32 cons, u8 flags)
+{
+	/* Flush data before signalling doorbell */
+	wmb();
+	cq->db.data.agg_flags = flags;
+	cq->db.data.value = cpu_to_le32(cons);
+	writeq(cq->db.raw, cq->db_addr);
+
+	/* Make sure write would stick */
+	mmiowb();
+}
+
+int qedr_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
+{
+	struct qedr_cq *cq = get_qedr_cq(ibcq);
+	unsigned long sflags;
+
+	if (cq->cq_type == QEDR_CQ_TYPE_GSI)
+		return 0;
+
+	spin_lock_irqsave(&cq->cq_lock, sflags);
+
+	cq->arm_flags = 0;
+
+	if (flags & IB_CQ_SOLICITED)
+		cq->arm_flags |= DQ_UCM_ROCE_CQ_ARM_SE_CF_CMD;
+
+	if (flags & IB_CQ_NEXT_COMP)
+		cq->arm_flags |= DQ_UCM_ROCE_CQ_ARM_CF_CMD;
+
+	doorbell_cq(cq, cq->cq_cons - 1, cq->arm_flags);
+
+	spin_unlock_irqrestore(&cq->cq_lock, sflags);
+
+	return 0;
+}
+
+struct ib_cq *qedr_create_cq(struct ib_device *ibdev,
+			     const struct ib_cq_init_attr *attr,
+			     struct ib_ucontext *ib_ctx, struct ib_udata *udata)
+{
+	struct qedr_ucontext *ctx = get_qedr_ucontext(ib_ctx);
+	struct qed_rdma_destroy_cq_out_params destroy_oparams;
+	struct qed_rdma_destroy_cq_in_params destroy_iparams;
+	struct qedr_dev *dev = get_qedr_dev(ibdev);
+	struct qed_rdma_create_cq_in_params params;
+	struct qedr_create_cq_ureq ureq;
+	int vector = attr->comp_vector;
+	int entries = attr->cqe;
+	struct qedr_cq *cq;
+	int chain_entries;
+	int page_cnt;
+	u64 pbl_ptr;
+	u16 icid;
+	int rc;
+
+	DP_VERBOSE(dev, QEDR_MSG_INIT,
+		   "create_cq: called from %s. entries=%d, vector=%d\n",
+		   udata ? "User Lib" : "Kernel", entries, vector);
+
+	if (entries > QEDR_MAX_CQES) {
+		DP_ERR(dev,
+		       "create cq: the number of entries %d is too high. Must be equal or below %d.\n",
+		       entries, QEDR_MAX_CQES);
+		return ERR_PTR(-EINVAL);
+	}
+
+	chain_entries = qedr_align_cq_entries(entries);
+	chain_entries = min_t(int, chain_entries, QEDR_MAX_CQES);
+
+	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+	if (!cq)
+		return ERR_PTR(-ENOMEM);
+
+	if (udata) {
+		memset(&ureq, 0, sizeof(ureq));
+		if (ib_copy_from_udata(&ureq, udata, sizeof(ureq))) {
+			DP_ERR(dev,
+			       "create cq: problem copying data from user space\n");
+			goto err0;
+		}
+
+		if (!ureq.len) {
+			DP_ERR(dev,
+			       "create cq: cannot create a cq with 0 entries\n");
+			goto err0;
+		}
+
+		cq->cq_type = QEDR_CQ_TYPE_USER;
+
+		rc = qedr_init_user_queue(ib_ctx, dev, &cq->q, ureq.addr, ureq.len,
+					  IB_ACCESS_LOCAL_WRITE, 1);
+		if (rc)
+			goto err0;
+
+		pbl_ptr = cq->q.pbl_tbl->pa;
+		page_cnt = cq->q.pbl_info.num_pbes;
+	} else {
+		cq->cq_type = QEDR_CQ_TYPE_KERNEL;
+
+		rc = dev->ops->common->chain_alloc(dev->cdev,
+						   QED_CHAIN_USE_TO_CONSUME,
+						   QED_CHAIN_MODE_PBL,
+						   QED_CHAIN_CNT_TYPE_U32,
+						   chain_entries,
+						   sizeof(union rdma_cqe),
+						   &cq->pbl);
+		if (rc)
+			goto err1;
+
+		page_cnt = qed_chain_get_page_cnt(&cq->pbl);
+		pbl_ptr = qed_chain_get_pbl_phys(&cq->pbl);
+	}
+
+	qedr_init_cq_params(cq, ctx, dev, vector, chain_entries, page_cnt,
+			    pbl_ptr, &params);
+
+	rc = dev->ops->rdma_create_cq(dev->rdma_ctx, &params, &icid);
+	if (rc)
+		goto err2;
+
+	cq->icid = icid;
+	cq->sig = QEDR_CQ_MAGIC_NUMBER;
+	spin_lock_init(&cq->cq_lock);
+
+	if (ib_ctx) {
+		rc = qedr_copy_cq_uresp(dev, cq, udata);
+		if (rc)
+			goto err3;
+	} else {
+		/* Generate doorbell address. */
+		cq->db_addr = dev->db_addr +
+		    DB_ADDR_SHIFT(DQ_PWM_OFFSET_UCM_RDMA_CQ_CONS_32BIT);
+		cq->db.data.icid = cq->icid;
+		cq->db.data.params = DB_AGG_CMD_SET <<
+		    RDMA_PWM_VAL32_DATA_AGG_CMD_SHIFT;
+
+		/* point to the very last element, passing it we will toggle */
+		cq->toggle_cqe = qed_chain_get_last_elem(&cq->pbl);
+		cq->pbl_toggle = RDMA_CQE_REQUESTER_TOGGLE_BIT_MASK;
+		cq->latest_cqe = NULL;
+		consume_cqe(cq);
+		cq->cq_cons = qed_chain_get_cons_idx_u32(&cq->pbl);
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_CQ,
+		   "create cq: icid=0x%0x, addr=%p, size(entries)=0x%0x\n",
+		   cq->icid, cq, params.cq_size);
+
+	return &cq->ibcq;
+
+err3:
+	destroy_iparams.icid = cq->icid;
+	dev->ops->rdma_destroy_cq(dev->rdma_ctx, &destroy_iparams,
+				  &destroy_oparams);
+err2:
+	if (udata)
+		qedr_free_pbl(dev, &cq->q.pbl_info, cq->q.pbl_tbl);
+	else
+		dev->ops->common->chain_free(dev->cdev, &cq->pbl);
+err1:
+	if (udata)
+		ib_umem_release(cq->q.umem);
+err0:
+	kfree(cq);
+	return ERR_PTR(-EINVAL);
+}
+
+int qedr_resize_cq(struct ib_cq *ibcq, int new_cnt, struct ib_udata *udata)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibcq->device);
+	struct qedr_cq *cq = get_qedr_cq(ibcq);
+
+	DP_ERR(dev, "cq %p RESIZE NOT SUPPORTED\n", cq);
+
+	return 0;
+}
+
+int qedr_destroy_cq(struct ib_cq *ibcq)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibcq->device);
+	struct qed_rdma_destroy_cq_out_params oparams;
+	struct qed_rdma_destroy_cq_in_params iparams;
+	struct qedr_cq *cq = get_qedr_cq(ibcq);
+
+	DP_VERBOSE(dev, QEDR_MSG_CQ, "destroy cq: cq_id %d", cq->icid);
+
+	/* GSIs CQs are handled by driver, so they don't exist in the FW */
+	if (cq->cq_type != QEDR_CQ_TYPE_GSI) {
+		iparams.icid = cq->icid;
+		dev->ops->rdma_destroy_cq(dev->rdma_ctx, &iparams, &oparams);
+		dev->ops->common->chain_free(dev->cdev, &cq->pbl);
+	}
+
+	if (ibcq->uobject && ibcq->uobject->context) {
+		qedr_free_pbl(dev, &cq->q.pbl_info, cq->q.pbl_tbl);
+		ib_umem_release(cq->q.umem);
+	}
+
+	kfree(cq);
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/qedr/verbs.h b/drivers/infiniband/hw/qedr/verbs.h
index f731063..d5e1017 100644
--- a/drivers/infiniband/hw/qedr/verbs.h
+++ b/drivers/infiniband/hw/qedr/verbs.h
@@ -14,6 +14,8 @@ int qedr_query_port(struct ib_device *, u8 port, struct ib_port_attr *props);
 
 int qedr_query_gid(struct ib_device *, u8 port, int index, union ib_gid *gid);
 
+int qedr_query_pkey(struct ib_device *, u8 port, u16 index, u16 *pkey);
+
 struct ib_ucontext *qedr_alloc_ucontext(struct ib_device *, struct ib_udata *);
 int qedr_dealloc_ucontext(struct ib_ucontext *);
 
@@ -23,4 +25,16 @@ int qedr_del_gid(struct ib_device *device, u8 port_num,
 int qedr_add_gid(struct ib_device *device, u8 port_num,
 		 unsigned int index, const union ib_gid *gid,
 		 const struct ib_gid_attr *attr, void **context);
+struct ib_pd *qedr_alloc_pd(struct ib_device *,
+			    struct ib_ucontext *, struct ib_udata *);
+int qedr_dealloc_pd(struct ib_pd *pd);
+
+struct ib_cq *qedr_create_cq(struct ib_device *ibdev,
+			     const struct ib_cq_init_attr *attr,
+			     struct ib_ucontext *ib_ctx,
+			     struct ib_udata *udata);
+int qedr_resize_cq(struct ib_cq *, int cqe, struct ib_udata *);
+int qedr_destroy_cq(struct ib_cq *);
+int qedr_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 9cdb472..7b489f0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -805,6 +805,315 @@ static int qed_rdma_get_int(struct qed_dev *cdev, struct qed_int_info *info)
 	return 0;
 }
 
+int qed_rdma_alloc_pd(void *rdma_cxt, u16 *pd)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	u32 returned_id;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Alloc PD\n");
+
+	/* Allocates an unused protection domain */
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn,
+				    &p_hwfn->p_rdma_info->pd_map, &returned_id);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+
+	*pd = (u16)returned_id;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Alloc PD - done, rc = %d\n", rc);
+	return rc;
+}
+
+void qed_rdma_free_pd(void *rdma_cxt, u16 pd)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "pd = %08x\n", pd);
+
+	/* Returns a previously allocated protection domain for reuse */
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->pd_map, pd);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+}
+
+static enum qed_rdma_toggle_bit
+qed_rdma_toggle_bit_create_resize_cq(struct qed_hwfn *p_hwfn, u16 icid)
+{
+	struct qed_rdma_info *p_info = p_hwfn->p_rdma_info;
+	enum qed_rdma_toggle_bit toggle_bit;
+	u32 bmap_id;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", icid);
+
+	/* the function toggle the bit that is related to a given icid
+	 * and returns the new toggle bit's value
+	 */
+	bmap_id = icid - qed_cxt_get_proto_cid_start(p_hwfn, p_info->proto);
+
+	spin_lock_bh(&p_info->lock);
+	toggle_bit = !test_and_change_bit(bmap_id,
+					  p_info->toggle_bits.bitmap);
+	spin_unlock_bh(&p_info->lock);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "QED_RDMA_TOGGLE_BIT_= %d\n",
+		   toggle_bit);
+
+	return toggle_bit;
+}
+
+int qed_rdma_create_cq(void *rdma_cxt,
+		       struct qed_rdma_create_cq_in_params *params, u16 *icid)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct qed_rdma_info *p_info = p_hwfn->p_rdma_info;
+	struct rdma_create_cq_ramrod_data *p_ramrod;
+	enum qed_rdma_toggle_bit toggle_bit;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	u32 returned_id, start_cid;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "cq_handle = %08x%08x\n",
+		   params->cq_handle_hi, params->cq_handle_lo);
+
+	/* Allocate icid */
+	spin_lock_bh(&p_info->lock);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn,
+				    &p_info->cq_map, &returned_id);
+	spin_unlock_bh(&p_info->lock);
+
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Can't create CQ, rc = %d\n", rc);
+		return rc;
+	}
+
+	start_cid = qed_cxt_get_proto_cid_start(p_hwfn,
+						p_info->proto);
+	*icid = returned_id + start_cid;
+
+	/* Check if icid requires a page allocation */
+	rc = qed_cxt_dynamic_ilt_alloc(p_hwfn, QED_ELEM_CXT, *icid);
+	if (rc)
+		goto err;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = *icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	/* Send create CQ ramrod */
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 RDMA_RAMROD_CREATE_CQ,
+				 p_info->proto, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.rdma_create_cq;
+
+	p_ramrod->cq_handle.hi = cpu_to_le32(params->cq_handle_hi);
+	p_ramrod->cq_handle.lo = cpu_to_le32(params->cq_handle_lo);
+	p_ramrod->dpi = cpu_to_le16(params->dpi);
+	p_ramrod->is_two_level_pbl = params->pbl_two_level;
+	p_ramrod->max_cqes = cpu_to_le32(params->cq_size);
+	p_ramrod->pbl_addr.hi = DMA_HI_LE(params->pbl_ptr);
+	p_ramrod->pbl_addr.lo = DMA_LO_LE(params->pbl_ptr);
+	p_ramrod->pbl_num_pages = cpu_to_le16(params->pbl_num_pages);
+	p_ramrod->cnq_id = (u8)RESC_START(p_hwfn, QED_RDMA_CNQ_RAM) +
+			   params->cnq_id;
+	p_ramrod->int_timeout = params->int_timeout;
+
+	/* toggle the bit for every resize or create cq for a given icid */
+	toggle_bit = qed_rdma_toggle_bit_create_resize_cq(p_hwfn, *icid);
+
+	p_ramrod->toggle_bit = toggle_bit;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc) {
+		/* restore toggle bit */
+		qed_rdma_toggle_bit_create_resize_cq(p_hwfn, *icid);
+		goto err;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Created CQ, rc = %d\n", rc);
+	return rc;
+
+err:
+	/* release allocated icid */
+	qed_bmap_release_id(p_hwfn, &p_info->cq_map, returned_id);
+	DP_NOTICE(p_hwfn, "Create CQ failed, rc = %d\n", rc);
+
+	return rc;
+}
+
+int qed_rdma_resize_cq(void *rdma_cxt,
+		       struct qed_rdma_resize_cq_in_params *in_params,
+		       struct qed_rdma_resize_cq_out_params *out_params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct rdma_resize_cq_output_params *p_ramrod_res;
+	struct rdma_resize_cq_ramrod_data *p_ramrod;
+	enum qed_rdma_toggle_bit toggle_bit;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	dma_addr_t ramrod_res_phys;
+	u8 fw_return_code;
+	int rc = -ENOMEM;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", in_params->icid);
+
+	p_ramrod_res =
+	    (struct rdma_resize_cq_output_params *)
+	    dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+			       sizeof(struct rdma_resize_cq_output_params),
+			       &ramrod_res_phys, GFP_KERNEL);
+	if (!p_ramrod_res) {
+		DP_NOTICE(p_hwfn,
+			  "qed resize cq failed: cannot allocate memory (ramrod)\n");
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = in_params->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 RDMA_RAMROD_RESIZE_CQ,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.rdma_resize_cq;
+
+	p_ramrod->flags = 0;
+
+	/* toggle the bit for every resize or create cq for a given icid */
+	toggle_bit = qed_rdma_toggle_bit_create_resize_cq(p_hwfn,
+							  in_params->icid);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_RESIZE_CQ_RAMROD_DATA_TOGGLE_BIT, toggle_bit);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_RESIZE_CQ_RAMROD_DATA_IS_TWO_LEVEL_PBL,
+		  in_params->pbl_two_level);
+
+	p_ramrod->pbl_log_page_size = in_params->pbl_page_size_log - 12;
+	p_ramrod->pbl_num_pages = cpu_to_le16(in_params->pbl_num_pages);
+	p_ramrod->max_cqes = cpu_to_le32(in_params->cq_size);
+	p_ramrod->pbl_addr.hi = DMA_HI_LE(in_params->pbl_ptr);
+	p_ramrod->pbl_addr.lo = DMA_LO_LE(in_params->pbl_ptr);
+
+	p_ramrod->output_params_addr.hi = DMA_HI_LE(ramrod_res_phys);
+	p_ramrod->output_params_addr.lo = DMA_LO_LE(ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, &fw_return_code);
+	if (rc)
+		goto err;
+
+	if (fw_return_code != RDMA_RETURN_OK) {
+		DP_NOTICE(p_hwfn, "fw_return_code = %d\n", fw_return_code);
+		DP_NOTICE(p_hwfn, "fw_return_code = %d\n", fw_return_code);
+		rc = -EINVAL;
+		goto err;
+	}
+
+	out_params->prod = le32_to_cpu(p_ramrod_res->old_cq_prod);
+	out_params->cons = le32_to_cpu(p_ramrod_res->old_cq_cons);
+
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct rdma_resize_cq_output_params),
+			  p_ramrod_res, ramrod_res_phys);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Resized CQ, rc = %d\n", rc);
+
+	return rc;
+
+err:	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct rdma_resize_cq_output_params),
+			  p_ramrod_res, ramrod_res_phys);
+	DP_NOTICE(p_hwfn, "Resized CQ, Failed - rc = %d\n", rc);
+
+	return rc;
+}
+
+int qed_rdma_destroy_cq(void *rdma_cxt,
+			struct qed_rdma_destroy_cq_in_params *in_params,
+			struct qed_rdma_destroy_cq_out_params *out_params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct rdma_destroy_cq_output_params *p_ramrod_res;
+	struct rdma_destroy_cq_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	dma_addr_t ramrod_res_phys;
+	int rc = -ENOMEM;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", in_params->icid);
+
+	p_ramrod_res =
+	    (struct rdma_destroy_cq_output_params *)
+	    dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+			       sizeof(struct rdma_destroy_cq_output_params),
+			       &ramrod_res_phys, GFP_KERNEL);
+	if (!p_ramrod_res) {
+		DP_NOTICE(p_hwfn,
+			  "qed destroy cq failed: cannot allocate memory (ramrod)\n");
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = in_params->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	/* Send destroy CQ ramrod */
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 RDMA_RAMROD_DESTROY_CQ,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.rdma_destroy_cq;
+	p_ramrod->output_params_addr.hi = DMA_HI_LE(ramrod_res_phys);
+	p_ramrod->output_params_addr.lo = DMA_LO_LE(ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		goto err;
+
+	out_params->num_cq_notif = le16_to_cpu(p_ramrod_res->cnq_num);
+
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct rdma_destroy_cq_output_params),
+			  p_ramrod_res, ramrod_res_phys);
+
+	/* Free icid */
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+
+	qed_bmap_release_id(p_hwfn,
+			    &p_hwfn->p_rdma_info->cq_map,
+			    (in_params->icid -
+			     qed_cxt_get_proto_cid_start(p_hwfn,
+							 p_hwfn->
+							 p_rdma_info->proto)));
+
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Destroyed CQ, rc = %d\n", rc);
+	return rc;
+
+err:	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct rdma_destroy_cq_output_params),
+			  p_ramrod_res, ramrod_res_phys);
+
+	return rc;
+}
+
 static void *qed_rdma_get_rdma_ctx(struct qed_dev *cdev)
 {
 	return QED_LEADING_HWFN(cdev);
@@ -895,6 +1204,10 @@ static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.rdma_set_rdma_int = &qed_rdma_set_int,
 	.rdma_get_min_cnq_msix = &qed_rdma_get_min_cnq_msix,
 	.rdma_cnq_prod_update = &qed_rdma_cnq_prod_update,
+	.rdma_alloc_pd = &qed_rdma_alloc_pd,
+	.rdma_dealloc_pd = &qed_rdma_free_pd,
+	.rdma_create_cq = &qed_rdma_create_cq,
+	.rdma_destroy_cq = &qed_rdma_destroy_cq,
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops()
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index c94c39e..6802cd0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -94,6 +94,26 @@ struct qed_rdma_info {
 	enum protocol_type proto;
 };
 
+struct qed_rdma_resize_cq_in_params {
+	u16 icid;
+	u32 cq_size;
+	bool pbl_two_level;
+	u64 pbl_ptr;
+	u16 pbl_num_pages;
+	u8 pbl_page_size_log;
+};
+
+struct qed_rdma_resize_cq_out_params {
+	u32 prod;
+	u32 cons;
+};
+
+struct qed_rdma_resize_cnq_in_params {
+	u32 cnq_id;
+	u32 pbl_page_size_log;
+	u64 pbl_ptr;
+};
+
 int
 qed_rdma_add_user(void *rdma_cxt,
 		  struct qed_rdma_add_user_out_params *out_params);
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
index e99470c..b559b1c 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_roce_if.h
@@ -263,6 +263,19 @@ struct qed_rdma_register_tid_in_params {
 	u64 dif_runt_addr;
 };
 
+struct qed_rdma_create_cq_in_params {
+	u32 cq_handle_lo;
+	u32 cq_handle_hi;
+	u32 cq_size;
+	u16 dpi;
+	bool pbl_two_level;
+	u64 pbl_ptr;
+	u16 pbl_num_pages;
+	u8 pbl_page_size_log;
+	u8 cnq_id;
+	u16 int_timeout;
+};
+
 struct qed_rdma_create_srq_in_params {
 	u64 pbl_base_addr;
 	u64 prod_pair_addr;
@@ -271,6 +284,14 @@ struct qed_rdma_create_srq_in_params {
 	u16 page_size;
 };
 
+struct qed_rdma_destroy_cq_in_params {
+	u16 icid;
+};
+
+struct qed_rdma_destroy_cq_out_params {
+	u16 num_cq_notif;
+};
+
 struct qed_rdma_create_srq_out_params {
 	u16 srq_id;
 };
@@ -339,6 +360,14 @@ struct qed_rdma_ops {
 	int (*rdma_get_rdma_int)(struct qed_dev *cdev,
 				 struct qed_int_info *info);
 	int (*rdma_set_rdma_int)(struct qed_dev *cdev, u16 cnt);
+	int (*rdma_alloc_pd)(void *rdma_cxt, u16 *pd);
+	void (*rdma_dealloc_pd)(void *rdma_cxt, u16 pd);
+	int (*rdma_create_cq)(void *rdma_cxt,
+			      struct qed_rdma_create_cq_in_params *params,
+			      u16 *icid);
+	int (*rdma_destroy_cq)(void *rdma_cxt,
+			       struct qed_rdma_destroy_cq_in_params *iparams,
+			       struct qed_rdma_destroy_cq_out_params *oparams);
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops(void);
diff --git a/include/uapi/rdma/providers/qedr-abi.h b/include/uapi/rdma/providers/qedr-abi.h
index 45288dc..16f3f60 100644
--- a/include/uapi/rdma/providers/qedr-abi.h
+++ b/include/uapi/rdma/providers/qedr-abi.h
@@ -24,4 +24,23 @@ struct qedr_alloc_ucontext_resp {
 	u32 sges_per_srq_wr;
 	int max_cqes;
 };
+
+struct qedr_alloc_pd_ureq {
+       u64 rsvd1;
+};
+
+struct qedr_alloc_pd_uresp {
+       u32 pd_id;
+};
+
+struct qedr_create_cq_ureq {
+       uint64_t addr;
+       size_t len;
+};
+
+struct qedr_create_cq_uresp {
+       u32 db_offset;
+       u16 icid;
+};
+
 #endif /* __QEDR_USER_H__ */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
