From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 07/21] RDMA/bnxt_re: Support for query and modify device verbs
Date: Wed, 21 Dec 2016 03:41:56 -0800
Message-ID: <1482320530-5344-8-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38632 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757466AbcLULnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:43:07 -0500
Received: by mail-wm0-f44.google.com with SMTP id g23so20037605wme.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:43:06 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements the query device and modify device verbs

v3: Fix sparse warnings related to endianness checks

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/bnxt_re.h   |  7 +++
 drivers/infiniband/hw/bnxt_re/ib_verbs.c  | 90 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h  |  6 +++
 drivers/infiniband/hw/bnxt_re/main.c      |  2 +
 drivers/infiniband/hw/bnxt_re/qplib_res.c | 17 ++++++
 drivers/infiniband/hw/bnxt_re/qplib_res.h |  1 +
 6 files changed, 123 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/bnxt_re.h b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
index 8d2f42f..cac1173 100644
--- a/drivers/infiniband/hw/bnxt_re/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
@@ -45,6 +45,13 @@
 #define BNXT_RE_REF_WAIT_COUNT		10
 #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
 
+#define BNXT_RE_PAGE_SIZE_4K		BIT(12)
+#define BNXT_RE_PAGE_SIZE_8K		BIT(13)
+#define BNXT_RE_PAGE_SIZE_64K		BIT(16)
+#define BNXT_RE_PAGE_SIZE_2M		BIT(21)
+#define BNXT_RE_PAGE_SIZE_8M		BIT(23)
+#define BNXT_RE_PAGE_SIZE_1G		BIT(30)
+
 #define BNXT_RE_MAX_QPC_COUNT		(64 * 1024)
 #define BNXT_RE_MAX_MRW_COUNT		(64 * 1024)
 #define BNXT_RE_MAX_SRQC_COUNT		(64 * 1024)
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index fed80ed..3c964d7 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -60,6 +60,96 @@
 #include "ib_verbs.h"
 #include <rdma/bnxt_re-abi.h>
 
+int bnxt_re_query_device(struct ib_device *ibdev,
+			 struct ib_device_attr *ib_attr,
+			 struct ib_udata *udata)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+
+	memset(ib_attr, 0, sizeof(*ib_attr));
+
+	ib_attr->fw_ver = (u64)(unsigned long)(dev_attr->fw_ver);
+	bnxt_qplib_get_guid(rdev->netdev->dev_addr,
+			    (u8 *)&ib_attr->sys_image_guid);
+	ib_attr->max_mr_size = ~0ull;
+	ib_attr->page_size_cap = BNXT_RE_PAGE_SIZE_4K | BNXT_RE_PAGE_SIZE_8K |
+				 BNXT_RE_PAGE_SIZE_64K | BNXT_RE_PAGE_SIZE_2M |
+				 BNXT_RE_PAGE_SIZE_8M | BNXT_RE_PAGE_SIZE_1G;
+
+	ib_attr->vendor_id = rdev->en_dev->pdev->vendor;
+	ib_attr->vendor_part_id = rdev->en_dev->pdev->device;
+	ib_attr->hw_ver = rdev->en_dev->pdev->subsystem_device;
+	ib_attr->max_qp = dev_attr->max_qp;
+	ib_attr->max_qp_wr = dev_attr->max_qp_wqes;
+	ib_attr->device_cap_flags =
+				    IB_DEVICE_CURR_QP_STATE_MOD
+				    | IB_DEVICE_RC_RNR_NAK_GEN
+				    | IB_DEVICE_SHUTDOWN_PORT
+				    | IB_DEVICE_SYS_IMAGE_GUID
+				    | IB_DEVICE_LOCAL_DMA_LKEY
+				    | IB_DEVICE_RESIZE_MAX_WR
+				    | IB_DEVICE_PORT_ACTIVE_EVENT
+				    | IB_DEVICE_N_NOTIFY_CQ
+				    | IB_DEVICE_MEM_WINDOW
+				    | IB_DEVICE_MEM_WINDOW_TYPE_2B
+				    | IB_DEVICE_MEM_MGT_EXTENSIONS;
+	ib_attr->max_sge = dev_attr->max_qp_sges;
+	ib_attr->max_sge_rd = dev_attr->max_qp_sges;
+	ib_attr->max_cq = dev_attr->max_cq;
+	ib_attr->max_cqe = dev_attr->max_cq_wqes;
+	ib_attr->max_mr = dev_attr->max_mr;
+	ib_attr->max_pd = dev_attr->max_pd;
+	ib_attr->max_qp_rd_atom = dev_attr->max_qp_rd_atom;
+	ib_attr->max_qp_init_rd_atom = dev_attr->max_qp_rd_atom;
+	ib_attr->atomic_cap = IB_ATOMIC_HCA;
+	ib_attr->masked_atomic_cap = IB_ATOMIC_HCA;
+
+	ib_attr->max_ee_rd_atom = 0;
+	ib_attr->max_res_rd_atom = 0;
+	ib_attr->max_ee_init_rd_atom = 0;
+	ib_attr->max_ee = 0;
+	ib_attr->max_rdd = 0;
+	ib_attr->max_mw = dev_attr->max_mw;
+	ib_attr->max_raw_ipv6_qp = 0;
+	ib_attr->max_raw_ethy_qp = dev_attr->max_raw_ethy_qp;
+	ib_attr->max_mcast_grp = 0;
+	ib_attr->max_mcast_qp_attach = 0;
+	ib_attr->max_total_mcast_qp_attach = 0;
+	ib_attr->max_ah = dev_attr->max_ah;
+
+	ib_attr->max_fmr = dev_attr->max_fmr;
+	ib_attr->max_map_per_fmr = 1;	/* ? */
+
+	ib_attr->max_srq = dev_attr->max_srq;
+	ib_attr->max_srq_wr = dev_attr->max_srq_wqes;
+	ib_attr->max_srq_sge = dev_attr->max_srq_sges;
+
+	ib_attr->max_fast_reg_page_list_len = MAX_PBL_LVL_1_PGS;
+
+	ib_attr->max_pkeys = 1;
+	ib_attr->local_ca_ack_delay = 0;
+	return 0;
+}
+
+int bnxt_re_modify_device(struct ib_device *ibdev,
+			  int device_modify_mask,
+			  struct ib_device_modify *device_modify)
+{
+	switch (device_modify_mask) {
+	case IB_DEVICE_MODIFY_SYS_IMAGE_GUID:
+		/* Modify the GUID requires the modification of the GID table */
+		/* GUID should be made as READ-ONLY */
+		break;
+	case IB_DEVICE_MODIFY_NODE_DESC:
+		/* Node Desc should be made as READ-ONLY */
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
 /* Protection Domains */
 int bnxt_re_dealloc_pd(struct ib_pd *ib_pd)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index a133d81..45f9253 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -54,6 +54,12 @@ struct bnxt_re_ucontext {
 	spinlock_t		sh_lock;	/* protect shpg */
 };
 
+int bnxt_re_query_device(struct ib_device *ibdev,
+			 struct ib_device_attr *ib_attr,
+			 struct ib_udata *udata);
+int bnxt_re_modify_device(struct ib_device *ibdev,
+			  int device_modify_mask,
+			  struct ib_device_modify *device_modify);
 struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 			       struct ib_ucontext *context,
 			       struct ib_udata *udata);
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 6f07657..038279b 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -436,6 +436,8 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 
 	ibdev->num_comp_vectors	= 1;
 	ibdev->dma_device = &rdev->en_dev->pdev->dev;
+	ibdev->query_device		= bnxt_re_query_device;
+	ibdev->modify_device		= bnxt_re_modify_device;
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_res.c b/drivers/infiniband/hw/bnxt_re/qplib_res.c
index 1648b45..3e85a22 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_res.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_res.c
@@ -445,6 +445,23 @@ int bnxt_qplib_alloc_ctx(struct pci_dev *pdev,
 	return rc;
 }
 
+/* GUID */
+void bnxt_qplib_get_guid(u8 *dev_addr, u8 *guid)
+{
+	u8 mac[ETH_ALEN];
+
+	/* MAC-48 to EUI-64 mapping */
+	memcpy(mac, dev_addr, ETH_ALEN);
+	guid[0] = mac[0] ^ 2;
+	guid[1] = mac[1];
+	guid[2] = mac[2];
+	guid[3] = 0xff;
+	guid[4] = 0xfe;
+	guid[5] = mac[3];
+	guid[6] = mac[4];
+	guid[7] = mac[5];
+}
+
 static void bnxt_qplib_free_sgid_tbl(struct bnxt_qplib_res *res,
 				     struct bnxt_qplib_sgid_tbl *sgid_tbl)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_res.h b/drivers/infiniband/hw/bnxt_re/qplib_res.h
index c9e376a..fc9c38c 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_res.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_res.h
@@ -194,6 +194,7 @@ int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
 			      struct scatterlist *sl, int nmap, u32 *elements,
 			      u32 elements_per_page, u32 aux, u32 pg_size,
 			      enum bnxt_qplib_hwq_type hwq_type);
+void bnxt_qplib_get_guid(u8 *dev_addr, u8 *guid);
 int bnxt_qplib_alloc_pd(struct bnxt_qplib_pd_tbl *pd_tbl,
 			struct bnxt_qplib_pd *pd);
 int bnxt_qplib_dealloc_pd(struct bnxt_qplib_res *res,
-- 
2.5.5
