From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 19/22] IB/hns: Add memory region operations support
Date: Sat, 2 Jul 2016 17:39:21 +0800
Message-ID: <1467452364-66522-20-git-send-email-oulijun@huawei.com>
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

This patch was mainly for implementing of memory region.
Memory Registration provides mechanisms that allow consumers
to describe a set of virtually contiguous memory locations or
a set of physically contiguous memory locations.
MR operations includes as follows:
    1. get dma MR in kernel mode
    2. get MR in user mode
    3. deregister MR
And the locations of some functions was adjusted in
some files.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11/v10/v9/v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_cmd.h    |   9 +
 drivers/infiniband/hw/hns/hns_roce_device.h |  45 +++++
 drivers/infiniband/hw/hns/hns_roce_hem.h    |   1 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 157 +++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 103 +++++++++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   7 +
 drivers/infiniband/hw/hns/hns_roce_mr.c     | 260 ++++++++++++++++++++++++++++
 7 files changed, 582 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hns/hns_roce_cmd.h
index 20f0019..e3997d3 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.h
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -36,6 +36,14 @@
 #define HNS_ROCE_MAILBOX_SIZE		4096
 
 enum {
+	/* TPT commands */
+	HNS_ROCE_CMD_SW2HW_MPT		= 0xd,
+	HNS_ROCE_CMD_HW2SW_MPT		= 0xf,
+
+	/* CQ commands */
+	HNS_ROCE_CMD_SW2HW_CQ		= 0x16,
+	HNS_ROCE_CMD_HW2SW_CQ		= 0x17,
+
 	/* QP/EE commands */
 	HNS_ROCE_CMD_RST2INIT_QP	= 0x19,
 	HNS_ROCE_CMD_INIT2RTR_QP	= 0x1a,
@@ -51,6 +59,7 @@ enum {
 
 enum {
 	HNS_ROCE_CMD_TIME_CLASS_A	= 10000,
+	HNS_ROCE_CMD_TIME_CLASS_B	= 10000,
 	HNS_ROCE_CMD_TIME_CLASS_C	= 10000,
 };
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 03fc37e..00f01be 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -50,6 +50,10 @@
 #define HNS_ROCE_MIN_CQE_NUM			0x40
 #define HNS_ROCE_MIN_WQE_NUM			0x20
 
+/* Hardware specification only for v1 engine */
+#define HNS_ROCE_MAX_INNER_MTPT_NUM		0x7
+#define HNS_ROCE_MAX_MTPT_PBL_NUM		0x100000
+
 #define HNS_ROCE_MAX_IRQ_NUM			34
 
 #define HNS_ROCE_COMP_VEC_NUM			32
@@ -66,10 +70,21 @@
 #define HNS_ROCE_MAX_GID_NUM			16
 #define HNS_ROCE_GID_SIZE			16
 
+#define MR_TYPE_MR				0x00
+#define MR_TYPE_DMA				0x03
+
 #define PKEY_ID					0xffff
 #define NODE_DESC_SIZE				64
 
+#define SERV_TYPE_RC				0
+#define SERV_TYPE_RD				1
+#define SERV_TYPE_UC				2
+#define SERV_TYPE_UD				3
+
+#define PAGES_SHIFT_8				8
 #define PAGES_SHIFT_16				16
+#define PAGES_SHIFT_24				24
+#define PAGES_SHIFT_32				32
 
 enum hns_roce_qp_state {
 	HNS_ROCE_QP_STATE_RST,
@@ -212,6 +227,23 @@ struct hns_roce_mtt {
 	int		page_shift;
 };
 
+/* Only support 4K page size for mr register */
+#define MR_SIZE_4K 0
+
+struct hns_roce_mr {
+	struct ib_mr		ibmr;
+	struct ib_umem		*umem;
+	u64			iova; /* MR's virtual orignal addr */
+	u64			size; /* Address range of MR */
+	u32			key; /* Key of MR */
+	u32			pd;   /* PD num of MR */
+	u32			access;/* Access permission of MR */
+	int			enabled; /* MR's active status */
+	int			type;	/* MR's register type */
+	u64			*pbl_buf;/* MR's PBL space */
+	dma_addr_t		pbl_dma_addr;	/* MR's PBL space PA */
+};
+
 struct hns_roce_mr_table {
 	struct hns_roce_bitmap		mtpt_bitmap;
 	struct hns_roce_buddy		mtt_buddy;
@@ -475,6 +507,8 @@ struct hns_roce_hw {
 	void (*set_mac)(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr);
 	void (*set_mtu)(struct hns_roce_dev *hr_dev, u8 phy_port,
 			enum ib_mtu mtu);
+	int (*write_mtpt)(void *mb_buf, struct hns_roce_mr *mr,
+			  unsigned long mtpt_idx);
 	void (*write_cqc)(struct hns_roce_dev *hr_dev,
 			  struct hns_roce_cq *hr_cq, void *mb_buf, u64 *mtts,
 			  dma_addr_t dma_handle, int nent, u32 vector);
@@ -549,6 +583,11 @@ static inline struct hns_roce_ah *to_hr_ah(struct ib_ah *ibah)
 	return container_of(ibah, struct hns_roce_ah, ibah);
 }
 
+static inline struct hns_roce_mr *to_hr_mr(struct ib_mr *ibmr)
+{
+	return container_of(ibmr, struct hns_roce_mr, ibmr);
+}
+
 static inline struct hns_roce_qp *to_hr_qp(struct ib_qp *ibqp)
 {
 	return container_of(ibqp, struct hns_roce_qp, ibqp);
@@ -643,6 +682,12 @@ struct ib_pd *hns_roce_alloc_pd(struct ib_device *ib_dev,
 				struct ib_udata *udata);
 int hns_roce_dealloc_pd(struct ib_pd *pd);
 
+struct ib_mr *hns_roce_get_dma_mr(struct ib_pd *pd, int acc);
+struct ib_mr *hns_roce_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
+				   u64 virt_addr, int access_flags,
+				   struct ib_udata *udata);
+int hns_roce_dereg_mr(struct ib_mr *ibmr);
+
 void hns_roce_buf_free(struct hns_roce_dev *hr_dev, u32 size,
 		       struct hns_roce_buf *buf);
 int hns_roce_buf_alloc(struct hns_roce_dev *hr_dev, u32 size, u32 max_direct,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.h b/drivers/infiniband/hw/hns/hns_roce_hem.h
index 40cacd6..ad66175 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.h
@@ -52,6 +52,7 @@ enum {
 
 enum {
 	 HNS_ROCE_HEM_PAGE_SHIFT = 12,
+	 HNS_ROCE_HEM_PAGE_SIZE  = 1 << HNS_ROCE_HEM_PAGE_SHIFT,
 };
 
 struct hns_roce_hem_chunk {
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 2e96dd9..2d2decd 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -1000,6 +1000,159 @@ void hns_roce_v1_set_mtu(struct hns_roce_dev *hr_dev, u8 phy_port,
 		   val);
 }
 
+int hns_roce_v1_write_mtpt(void *mb_buf, struct hns_roce_mr *mr,
+			   unsigned long mtpt_idx)
+{
+	struct hns_roce_v1_mpt_entry *mpt_entry;
+	struct scatterlist *sg;
+	u64 *pages;
+	int entry;
+	int i;
+
+	/* MPT filled into mailbox buf */
+	mpt_entry = (struct hns_roce_v1_mpt_entry *)mb_buf;
+	memset(mpt_entry, 0, sizeof(*mpt_entry));
+
+	roce_set_field(mpt_entry->mpt_byte_4, MPT_BYTE_4_KEY_STATE_M,
+		       MPT_BYTE_4_KEY_STATE_S, KEY_VALID);
+	roce_set_field(mpt_entry->mpt_byte_4, MPT_BYTE_4_KEY_M,
+		       MPT_BYTE_4_KEY_S, mr->key);
+	roce_set_field(mpt_entry->mpt_byte_4, MPT_BYTE_4_PAGE_SIZE_M,
+		       MPT_BYTE_4_PAGE_SIZE_S, MR_SIZE_4K);
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_MW_TYPE_S, 0);
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_MW_BIND_ENABLE_S,
+		     (mr->access & IB_ACCESS_MW_BIND ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_OWN_S, 0);
+	roce_set_field(mpt_entry->mpt_byte_4, MPT_BYTE_4_MEMORY_LOCATION_TYPE_M,
+		       MPT_BYTE_4_MEMORY_LOCATION_TYPE_S, mr->type);
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_REMOTE_ATOMIC_S, 0);
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_LOCAL_WRITE_S,
+		     (mr->access & IB_ACCESS_LOCAL_WRITE ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_REMOTE_WRITE_S,
+		     (mr->access & IB_ACCESS_REMOTE_WRITE ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_REMOTE_READ_S,
+		     (mr->access & IB_ACCESS_REMOTE_READ ? 1 : 0));
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_REMOTE_INVAL_ENABLE_S,
+		     0);
+	roce_set_bit(mpt_entry->mpt_byte_4, MPT_BYTE_4_ADDRESS_TYPE_S, 0);
+
+	roce_set_field(mpt_entry->mpt_byte_12, MPT_BYTE_12_PBL_ADDR_H_M,
+		       MPT_BYTE_12_PBL_ADDR_H_S, 0);
+	roce_set_field(mpt_entry->mpt_byte_12, MPT_BYTE_12_MW_BIND_COUNTER_M,
+		       MPT_BYTE_12_MW_BIND_COUNTER_S, 0);
+
+	mpt_entry->virt_addr_l = (u32)mr->iova;
+	mpt_entry->virt_addr_h = (u32)(mr->iova >> 32);
+	mpt_entry->length = (u32)mr->size;
+
+	roce_set_field(mpt_entry->mpt_byte_28, MPT_BYTE_28_PD_M,
+		       MPT_BYTE_28_PD_S, mr->pd);
+	roce_set_field(mpt_entry->mpt_byte_28, MPT_BYTE_28_L_KEY_IDX_L_M,
+		       MPT_BYTE_28_L_KEY_IDX_L_S, mtpt_idx);
+	roce_set_field(mpt_entry->mpt_byte_64, MPT_BYTE_64_L_KEY_IDX_H_M,
+		       MPT_BYTE_64_L_KEY_IDX_H_S, mtpt_idx >> MTPT_IDX_SHIFT);
+
+	/* DMA momery regsiter */
+	if (mr->type == MR_TYPE_DMA)
+		return 0;
+
+	pages = (u64 *) __get_free_page(GFP_KERNEL);
+	if (!pages)
+		return -ENOMEM;
+
+	i = 0;
+	for_each_sg(mr->umem->sg_head.sgl, sg, mr->umem->nmap, entry) {
+		pages[i] = ((u64)sg_dma_address(sg)) >> 12;
+
+		/* Directly record to MTPT table firstly 7 entry */
+		if (i >= HNS_ROCE_MAX_INNER_MTPT_NUM)
+			break;
+		i++;
+	}
+
+	/* Register user mr */
+	for (i = 0; i < HNS_ROCE_MAX_INNER_MTPT_NUM; i++) {
+		switch (i) {
+		case 0:
+			mpt_entry->pa0_l = cpu_to_le32((u32)(pages[i]));
+			roce_set_field(mpt_entry->mpt_byte_36,
+				MPT_BYTE_36_PA0_H_M,
+				MPT_BYTE_36_PA0_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_32)));
+			break;
+		case 1:
+			roce_set_field(mpt_entry->mpt_byte_36,
+				       MPT_BYTE_36_PA1_L_M,
+				       MPT_BYTE_36_PA1_L_S,
+				       cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_40,
+				MPT_BYTE_40_PA1_H_M,
+				MPT_BYTE_40_PA1_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_24)));
+			break;
+		case 2:
+			roce_set_field(mpt_entry->mpt_byte_40,
+				       MPT_BYTE_40_PA2_L_M,
+				       MPT_BYTE_40_PA2_L_S,
+				       cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_44,
+				MPT_BYTE_44_PA2_H_M,
+				MPT_BYTE_44_PA2_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_16)));
+			break;
+		case 3:
+			roce_set_field(mpt_entry->mpt_byte_44,
+				       MPT_BYTE_44_PA3_L_M,
+				       MPT_BYTE_44_PA3_L_S,
+				       cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_48,
+				MPT_BYTE_48_PA3_H_M,
+				MPT_BYTE_48_PA3_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_8)));
+			break;
+		case 4:
+			mpt_entry->pa4_l = cpu_to_le32((u32)(pages[i]));
+			roce_set_field(mpt_entry->mpt_byte_56,
+				MPT_BYTE_56_PA4_H_M,
+				MPT_BYTE_56_PA4_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_32)));
+			break;
+		case 5:
+			roce_set_field(mpt_entry->mpt_byte_56,
+				       MPT_BYTE_56_PA5_L_M,
+				       MPT_BYTE_56_PA5_L_S,
+				       cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_60,
+				MPT_BYTE_60_PA5_H_M,
+				MPT_BYTE_60_PA5_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_24)));
+			break;
+		case 6:
+			roce_set_field(mpt_entry->mpt_byte_60,
+				       MPT_BYTE_60_PA6_L_M,
+				       MPT_BYTE_60_PA6_L_S,
+				       cpu_to_le32((u32)(pages[i])));
+			roce_set_field(mpt_entry->mpt_byte_64,
+				MPT_BYTE_64_PA6_H_M,
+				MPT_BYTE_64_PA6_H_S,
+				cpu_to_le32((u32)(pages[i] >> PAGES_SHIFT_16)));
+			break;
+		default:
+			break;
+		}
+	}
+
+	free_page((unsigned long) pages);
+
+	mpt_entry->pbl_addr_l = (u32)(mr->pbl_dma_addr);
+
+	roce_set_field(mpt_entry->mpt_byte_12, MPT_BYTE_12_PBL_ADDR_H_M,
+		       MPT_BYTE_12_PBL_ADDR_H_S,
+		       ((u32)(mr->pbl_dma_addr >> 32)));
+
+	return 0;
+}
+
 static void *get_cqe(struct hns_roce_cq *hr_cq, int n)
 {
 	return hns_roce_buf_offset(&hr_cq->hr_buf.hr_buf,
@@ -2605,6 +2758,8 @@ int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
 	return 0;
 }
 
+struct hns_roce_v1_priv hr_v1_priv;
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
 	.hw_profile = hns_roce_v1_profile,
@@ -2613,6 +2768,7 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.set_gid = hns_roce_v1_set_gid,
 	.set_mac = hns_roce_v1_set_mac,
 	.set_mtu = hns_roce_v1_set_mtu,
+	.write_mtpt = hns_roce_v1_write_mtpt,
 	.write_cqc = hns_roce_v1_write_cqc,
 	.modify_qp = hns_roce_v1_modify_qp,
 	.query_qp = hns_roce_v1_query_qp,
@@ -2621,4 +2777,5 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.post_recv = hns_roce_v1_post_recv,
 	.req_notify_cq = hns_roce_v1_req_notify_cq,
 	.poll_cq = hns_roce_v1_poll_cq,
+	.priv = &hr_v1_priv,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index e5d24ee..2b3bf21 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -109,6 +109,8 @@
 
 #define HNS_ROCE_ODB_EXTEND_MODE			1
 
+#define KEY_VALID					0x02
+
 #define HNS_ROCE_CQE_QPN_MASK				0x3ffff
 #define HNS_ROCE_CQE_STATUS_MASK			0x1f
 #define HNS_ROCE_CQE_OPCODE_MASK			0xf
@@ -129,6 +131,7 @@
 
 #define QP1C_CFGN_OFFSET				0x28
 #define PHY_PORT_OFFSET					0x8
+#define MTPT_IDX_SHIFT					16
 #define ALL_PORT_VAL_OPEN				0x3f
 #define POL_TIME_INTERVAL_VAL				0x80
 #define SLEEP_TIME_INTERVAL				20
@@ -244,6 +247,106 @@ struct hns_roce_cqe {
 #define CQ_DB_REQ_NOT_SOL	0
 #define CQ_DB_REQ_NOT		(1 << 16)
 
+struct hns_roce_v1_mpt_entry {
+	u32  mpt_byte_4;
+	u32  pbl_addr_l;
+	u32  mpt_byte_12;
+	u32  virt_addr_l;
+	u32  virt_addr_h;
+	u32  length;
+	u32  mpt_byte_28;
+	u32  pa0_l;
+	u32  mpt_byte_36;
+	u32  mpt_byte_40;
+	u32  mpt_byte_44;
+	u32  mpt_byte_48;
+	u32  pa4_l;
+	u32  mpt_byte_56;
+	u32  mpt_byte_60;
+	u32  mpt_byte_64;
+};
+
+#define MPT_BYTE_4_KEY_STATE_S 0
+#define MPT_BYTE_4_KEY_STATE_M	(((1UL << 2) - 1) << MPT_BYTE_4_KEY_STATE_S)
+
+#define MPT_BYTE_4_KEY_S 8
+#define MPT_BYTE_4_KEY_M	(((1UL << 8) - 1) << MPT_BYTE_4_KEY_S)
+
+#define MPT_BYTE_4_PAGE_SIZE_S 16
+#define MPT_BYTE_4_PAGE_SIZE_M	(((1UL << 2) - 1) << MPT_BYTE_4_PAGE_SIZE_S)
+
+#define MPT_BYTE_4_MW_TYPE_S 20
+
+#define MPT_BYTE_4_MW_BIND_ENABLE_S 21
+
+#define MPT_BYTE_4_OWN_S 22
+
+#define MPT_BYTE_4_MEMORY_LOCATION_TYPE_S 24
+#define MPT_BYTE_4_MEMORY_LOCATION_TYPE_M   \
+	(((1UL << 2) - 1) << MPT_BYTE_4_MEMORY_LOCATION_TYPE_S)
+
+#define MPT_BYTE_4_REMOTE_ATOMIC_S 26
+#define MPT_BYTE_4_LOCAL_WRITE_S 27
+#define MPT_BYTE_4_REMOTE_WRITE_S 28
+#define MPT_BYTE_4_REMOTE_READ_S 29
+#define MPT_BYTE_4_REMOTE_INVAL_ENABLE_S 30
+#define MPT_BYTE_4_ADDRESS_TYPE_S 31
+
+#define MPT_BYTE_12_PBL_ADDR_H_S 0
+#define MPT_BYTE_12_PBL_ADDR_H_M   \
+	(((1UL << 17) - 1) << MPT_BYTE_12_PBL_ADDR_H_S)
+
+#define MPT_BYTE_12_MW_BIND_COUNTER_S 17
+#define MPT_BYTE_12_MW_BIND_COUNTER_M   \
+	(((1UL << 15) - 1) << MPT_BYTE_12_MW_BIND_COUNTER_S)
+
+#define MPT_BYTE_28_PD_S 0
+#define MPT_BYTE_28_PD_M	(((1UL << 16) - 1) << MPT_BYTE_28_PD_S)
+
+#define MPT_BYTE_28_L_KEY_IDX_L_S 16
+#define MPT_BYTE_28_L_KEY_IDX_L_M   \
+	(((1UL << 16) - 1) << MPT_BYTE_28_L_KEY_IDX_L_S)
+
+#define MPT_BYTE_36_PA0_H_S 0
+#define MPT_BYTE_36_PA0_H_M	(((1UL << 5) - 1) << MPT_BYTE_36_PA0_H_S)
+
+#define MPT_BYTE_36_PA1_L_S 8
+#define MPT_BYTE_36_PA1_L_M	(((1UL << 24) - 1) << MPT_BYTE_36_PA1_L_S)
+
+#define MPT_BYTE_40_PA1_H_S 0
+#define MPT_BYTE_40_PA1_H_M	(((1UL << 13) - 1) << MPT_BYTE_40_PA1_H_S)
+
+#define MPT_BYTE_40_PA2_L_S 16
+#define MPT_BYTE_40_PA2_L_M	(((1UL << 16) - 1) << MPT_BYTE_40_PA2_L_S)
+
+#define MPT_BYTE_44_PA2_H_S 0
+#define MPT_BYTE_44_PA2_H_M	(((1UL << 21) - 1) << MPT_BYTE_44_PA2_H_S)
+
+#define MPT_BYTE_44_PA3_L_S 24
+#define MPT_BYTE_44_PA3_L_M	(((1UL << 8) - 1) << MPT_BYTE_44_PA3_L_S)
+
+#define MPT_BYTE_48_PA3_H_S 0
+#define MPT_BYTE_48_PA3_H_M	(((1UL << 29) - 1) << MPT_BYTE_48_PA3_H_S)
+
+#define MPT_BYTE_56_PA4_H_S 0
+#define MPT_BYTE_56_PA4_H_M	(((1UL << 5) - 1) << MPT_BYTE_56_PA4_H_S)
+
+#define MPT_BYTE_56_PA5_L_S 8
+#define MPT_BYTE_56_PA5_L_M	(((1UL << 24) - 1) << MPT_BYTE_56_PA5_L_S)
+
+#define MPT_BYTE_60_PA5_H_S 0
+#define MPT_BYTE_60_PA5_H_M	(((1UL << 13) - 1) << MPT_BYTE_60_PA5_H_S)
+
+#define MPT_BYTE_60_PA6_L_S 16
+#define MPT_BYTE_60_PA6_L_M	(((1UL << 16) - 1) << MPT_BYTE_60_PA6_L_S)
+
+#define MPT_BYTE_64_PA6_H_S 0
+#define MPT_BYTE_64_PA6_H_M	(((1UL << 21) - 1) << MPT_BYTE_64_PA6_H_S)
+
+#define MPT_BYTE_64_L_KEY_IDX_H_S 24
+#define MPT_BYTE_64_L_KEY_IDX_H_M   \
+	(((1UL << 8) - 1) << MPT_BYTE_64_L_KEY_IDX_H_S)
+
 struct hns_roce_wqe_ctrl_seg {
 	__be32 sgl_pa_h;
 	__be32 flag;
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 75a8f29..1b1ffc4 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -583,6 +583,8 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		(1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
 		(1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
 		(1ULL << IB_USER_VERBS_CMD_DEALLOC_PD) |
+		(1ULL << IB_USER_VERBS_CMD_REG_MR) |
+		(1ULL << IB_USER_VERBS_CMD_DEREG_MR) |
 		(1ULL << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
 		(1ULL << IB_USER_VERBS_CMD_CREATE_CQ) |
 		(1ULL << IB_USER_VERBS_CMD_DESTROY_CQ) |
@@ -626,6 +628,11 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->req_notify_cq		= hr_dev->hw->req_notify_cq;
 	ib_dev->poll_cq			= hr_dev->hw->poll_cq;
 
+	/* MR */
+	ib_dev->get_dma_mr		= hns_roce_get_dma_mr;
+	ib_dev->reg_user_mr		= hns_roce_reg_user_mr;
+	ib_dev->dereg_mr		= hns_roce_dereg_mr;
+
 	ret = ib_register_device(ib_dev, NULL);
 	if (ret) {
 		dev_err(dev, "ib_register_device failed!\n");
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index 04ae3ed..59f5e2b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -34,8 +34,37 @@
 #include <linux/platform_device.h>
 #include <rdma/ib_umem.h>
 #include "hns_roce_device.h"
+#include "hns_roce_cmd.h"
 #include "hns_roce_hem.h"
 
+static u32 hw_index_to_key(unsigned long ind)
+{
+	return (u32)(ind >> 24) | (ind << 8);
+}
+
+static unsigned long key_to_hw_index(u32 key)
+{
+	return (key << 24) | (key >> 8);
+}
+
+static int hns_roce_sw2hw_mpt(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_cmd_mailbox *mailbox,
+			      unsigned long mpt_index)
+{
+	return hns_roce_cmd_mbox(hr_dev, mailbox->dma, 0, mpt_index, 0,
+				 HNS_ROCE_CMD_SW2HW_MPT,
+				 HNS_ROCE_CMD_TIME_CLASS_B);
+}
+
+static int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_cmd_mailbox *mailbox,
+			      unsigned long mpt_index)
+{
+	return hns_roce_cmd_mbox(hr_dev, 0, mailbox ? mailbox->dma : 0,
+				 mpt_index, !mailbox, HNS_ROCE_CMD_HW2SW_MPT,
+				 HNS_ROCE_CMD_TIME_CLASS_B);
+}
+
 static int hns_roce_buddy_alloc(struct hns_roce_buddy *buddy, int order,
 				unsigned long *seg)
 {
@@ -201,6 +230,113 @@ void hns_roce_mtt_cleanup(struct hns_roce_dev *hr_dev, struct hns_roce_mtt *mtt)
 				 mtt->first_seg + (1 << mtt->order) - 1);
 }
 
+static int hns_roce_mr_alloc(struct hns_roce_dev *hr_dev, u32 pd, u64 iova,
+			     u64 size, u32 access, int npages,
+			     struct hns_roce_mr *mr)
+{
+	unsigned long index = 0;
+	int ret = 0;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* Allocate a key for mr from mr_table */
+	ret = hns_roce_bitmap_alloc(&hr_dev->mr_table.mtpt_bitmap, &index);
+	if (ret == -1)
+		return -ENOMEM;
+
+	mr->iova = iova;			/* MR va starting addr */
+	mr->size = size;			/* MR addr range */
+	mr->pd = pd;				/* MR num */
+	mr->access = access;			/* MR access permit */
+	mr->enabled = 0;			/* MR active status */
+	mr->key = hw_index_to_key(index);	/* MR key */
+
+	if (size == ~0ull) {
+		mr->type = MR_TYPE_DMA;
+		mr->pbl_buf = NULL;
+		mr->pbl_dma_addr = 0;
+	} else {
+		mr->type = MR_TYPE_MR;
+		mr->pbl_buf = dma_alloc_coherent(dev, npages * 8,
+						 &(mr->pbl_dma_addr),
+						 GFP_KERNEL);
+		if (!mr->pbl_buf)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void hns_roce_mr_free(struct hns_roce_dev *hr_dev,
+			     struct hns_roce_mr *mr)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	int npages = 0;
+	int ret;
+
+	if (mr->enabled) {
+		ret = hns_roce_hw2sw_mpt(hr_dev, NULL, key_to_hw_index(mr->key)
+					 & (hr_dev->caps.num_mtpts - 1));
+		if (ret)
+			dev_warn(dev, "HW2SW_MPT failed (%d)\n", ret);
+	}
+
+	if (mr->size != ~0ULL) {
+		npages = ib_umem_page_count(mr->umem);
+		dma_free_coherent(dev, (unsigned int)(npages * 8), mr->pbl_buf,
+				  mr->pbl_dma_addr);
+	}
+
+	hns_roce_bitmap_free(&hr_dev->mr_table.mtpt_bitmap,
+			     key_to_hw_index(mr->key));
+}
+
+static int hns_roce_mr_enable(struct hns_roce_dev *hr_dev,
+			      struct hns_roce_mr *mr)
+{
+	int ret;
+	unsigned long mtpt_idx = key_to_hw_index(mr->key);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_cmd_mailbox *mailbox;
+	struct hns_roce_mr_table *mr_table = &hr_dev->mr_table;
+
+	/* Prepare HEM entry memory */
+	ret = hns_roce_table_get(hr_dev, &mr_table->mtpt_table, mtpt_idx);
+	if (ret)
+		return ret;
+
+	/* Allocate mailbox memory */
+	mailbox = hns_roce_alloc_cmd_mailbox(hr_dev);
+	if (IS_ERR(mailbox)) {
+		ret = PTR_ERR(mailbox);
+		goto err_table;
+	}
+
+	ret = hr_dev->hw->write_mtpt(mailbox->buf, mr, mtpt_idx);
+	if (ret) {
+		dev_err(dev, "Write mtpt fail!\n");
+		goto err_page;
+	}
+
+	ret = hns_roce_sw2hw_mpt(hr_dev, mailbox,
+				 mtpt_idx & (hr_dev->caps.num_mtpts - 1));
+	if (ret) {
+		dev_err(dev, "SW2HW_MPT failed (%d)\n", ret);
+		goto err_page;
+	}
+
+	mr->enabled = 1;
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+	return 0;
+
+err_page:
+	hns_roce_free_cmd_mailbox(hr_dev, mailbox);
+
+err_table:
+	hns_roce_table_put(hr_dev, &mr_table->mtpt_table, mtpt_idx);
+	return ret;
+}
+
 static int hns_roce_write_mtt_chunk(struct hns_roce_dev *hr_dev,
 				    struct hns_roce_mtt *mtt, u32 start_index,
 				    u32 npages, u64 *page_list)
@@ -314,6 +450,38 @@ void hns_roce_cleanup_mr_table(struct hns_roce_dev *hr_dev)
 	hns_roce_bitmap_cleanup(&mr_table->mtpt_bitmap);
 }
 
+struct ib_mr *hns_roce_get_dma_mr(struct ib_pd *pd, int acc)
+{
+	int ret = 0;
+	struct hns_roce_mr *mr = NULL;
+
+	mr = kmalloc(sizeof(*mr), GFP_KERNEL);
+	if (mr == NULL)
+		return  ERR_PTR(-ENOMEM);
+
+	/* Allocate memory region key */
+	ret = hns_roce_mr_alloc(to_hr_dev(pd->device), to_hr_pd(pd)->pdn, 0,
+				~0ULL, acc, 0, mr);
+	if (ret)
+		goto err_free;
+
+	ret = hns_roce_mr_enable(to_hr_dev(pd->device), mr);
+	if (ret)
+		goto err_mr;
+
+	mr->ibmr.rkey = mr->ibmr.lkey = mr->key;
+	mr->umem = NULL;
+
+	return &mr->ibmr;
+
+err_mr:
+	hns_roce_mr_free(to_hr_dev(pd->device), mr);
+
+err_free:
+	kfree(mr);
+	return ERR_PTR(ret);
+}
+
 int hns_roce_ib_umem_write_mtt(struct hns_roce_dev *hr_dev,
 			       struct hns_roce_mtt *mtt, struct ib_umem *umem)
 {
@@ -352,3 +520,95 @@ out:
 	free_page((unsigned long) pages);
 	return ret;
 }
+
+static int hns_roce_ib_umem_write_mr(struct hns_roce_mr *mr,
+				     struct ib_umem *umem)
+{
+	int i = 0;
+	int entry;
+	struct scatterlist *sg;
+
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		mr->pbl_buf[i] = ((u64)sg_dma_address(sg)) >> 12;
+		i++;
+	}
+
+	/* Memory barrier */
+	mb();
+
+	return 0;
+}
+
+struct ib_mr *hns_roce_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
+				   u64 virt_addr, int access_flags,
+				   struct ib_udata *udata)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(pd->device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_mr *mr = NULL;
+	int ret = 0;
+	int n = 0;
+
+	mr = kmalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->umem = ib_umem_get(pd->uobject->context, start, length,
+			       access_flags, 0);
+	if (IS_ERR(mr->umem)) {
+		ret = PTR_ERR(mr->umem);
+		goto err_free;
+	}
+
+	n = ib_umem_page_count(mr->umem);
+	if (mr->umem->page_size != HNS_ROCE_HEM_PAGE_SIZE) {
+		dev_err(dev, "Just support 4K page size but is 0x%x now!\n",
+			mr->umem->page_size);
+	}
+
+	if (n > HNS_ROCE_MAX_MTPT_PBL_NUM) {
+		dev_err(dev, " MR len %lld err. MR is limited to 4G at most!\n",
+			length);
+		goto err_umem;
+	}
+
+	ret = hns_roce_mr_alloc(hr_dev, to_hr_pd(pd)->pdn, virt_addr, length,
+				access_flags, n, mr);
+	if (ret)
+		goto err_umem;
+
+	ret = hns_roce_ib_umem_write_mr(mr, mr->umem);
+	if (ret)
+		goto err_mr;
+
+	ret = hns_roce_mr_enable(hr_dev, mr);
+	if (ret)
+		goto err_mr;
+
+	mr->ibmr.rkey = mr->ibmr.lkey = mr->key;
+
+	return &mr->ibmr;
+
+err_mr:
+	hns_roce_mr_free(hr_dev, mr);
+
+err_umem:
+	ib_umem_release(mr->umem);
+
+err_free:
+	kfree(mr);
+	return ERR_PTR(ret);
+}
+
+int hns_roce_dereg_mr(struct ib_mr *ibmr)
+{
+	struct hns_roce_mr *mr = to_hr_mr(ibmr);
+
+	hns_roce_mr_free(to_hr_dev(ibmr->device), mr);
+	if (mr->umem)
+		ib_umem_release(mr->umem);
+
+	kfree(mr);
+
+	return 0;
+}
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
