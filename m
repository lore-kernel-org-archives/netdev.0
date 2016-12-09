From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V2  07/22] bnxt_re: Support for query and modify device verbs
Date: Thu,  8 Dec 2016 22:48:01 -0800
Message-ID: <1481266096-23331-8-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding implementation for the query device and modify device verbs

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c   | 17 +++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h   |  1 +
 drivers/infiniband/hw/bnxtre/bnxt_re.h          |  7 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 90 +++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |  6 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |  2 +
 6 files changed, 123 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
index 9ba1d20..9cb1b7a 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
@@ -447,6 +447,23 @@ int bnxt_qplib_alloc_ctx(struct pci_dev *pdev,
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
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
index c9e376a..fc9c38c 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_res.h
@@ -194,6 +194,7 @@ int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
 			      struct scatterlist *sl, int nmap, u32 *elements,
 			      u32 elements_per_page, u32 aux, u32 pg_size,
 			      enum bnxt_qplib_hwq_type hwq_type);
+void bnxt_qplib_get_guid(u8 *dev_addr, u8 *guid);
 int bnxt_qplib_alloc_pd(struct bnxt_qplib_pd_tbl *pd_tbl,
 			struct bnxt_qplib_pd *pd);
 int bnxt_qplib_dealloc_pd(struct bnxt_qplib_res *res,
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index 3137a26..3a93a88 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
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
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
index 71eb1f3..a0fbc24 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -60,6 +60,96 @@
 #include "bnxt_re_ib_verbs.h"
 #include <rdma/bnxt_re_uverbs_abi.h>
 
+int bnxt_re_query_device(struct ib_device *ibdev,
+			 struct ib_device_attr *ib_attr,
+			 struct ib_udata *udata)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+
+	memset(ib_attr, 0, sizeof(*ib_attr));
+
+	ib_attr->fw_ver = (u64)dev_attr->fw_ver;
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
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
index a133d81..45f9253 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
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
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 3549d3a..7dfdaef 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -425,6 +425,8 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 
 	ibdev->num_comp_vectors	= 1;
 	ibdev->dma_device = &rdev->en_dev->pdev->dev;
+	ibdev->query_device		= bnxt_re_query_device;
+	ibdev->modify_device		= bnxt_re_modify_device;
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
