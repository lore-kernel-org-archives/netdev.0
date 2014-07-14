From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 1/4] iw_cxgb4: Detect Ing. Padding Boundary at run-time
Date: Mon, 14 Jul 2014 21:34:51 +0530
Message-ID: <1405353894-17495-2-git-send-email-hariprasad@chelsio.com>
References: <1405353894-17495-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405353894-17495-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Updates iw_cxgb4 to determine the Ingress Padding Boundary from
cxgb4_lld_info, and take subsequent actions.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cq.c                |    4 ++--
 drivers/infiniband/hw/cxgb4/device.c            |   21 +++++++++++++++++++++
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   12 ++++++++++++
 drivers/infiniband/hw/cxgb4/provider.c          |    4 ++--
 drivers/infiniband/hw/cxgb4/qp.c                |   10 ++++++----
 drivers/infiniband/hw/cxgb4/t4.h                |    8 --------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    2 ++
 8 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index c04292c..f04a838 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -895,7 +895,7 @@ struct ib_cq *c4iw_create_cq(struct ib_device *ibdev, int entries,
 	/*
 	 * Make actual HW queue 2x to avoid cdix_inc overflows.
 	 */
-	hwentries = min(entries * 2, T4_MAX_IQ_SIZE);
+	hwentries = min(entries * 2, rhp->rdev.hw_queue.t4_max_iq_size);
 
 	/*
 	 * Make HW queue at least 64 entries so GTS updates aren't too
@@ -912,7 +912,7 @@ struct ib_cq *c4iw_create_cq(struct ib_device *ibdev, int entries,
 	if (ucontext) {
 		memsize = roundup(memsize, PAGE_SIZE);
 		hwentries = memsize / sizeof *chp->cq.queue;
-		while (hwentries > T4_MAX_IQ_SIZE) {
+		while (hwentries > rhp->rdev.hw_queue.t4_max_iq_size) {
 			memsize -= PAGE_SIZE;
 			hwentries = memsize / sizeof *chp->cq.queue;
 		}
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index dd93aad..88291ef 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -768,6 +768,27 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 	}
 	devp->rdev.lldi = *infop;
 
+	/* init various hw-queue params based on lld info */
+	PDBG("%s: Ing. padding boundary is %d, egrsstatuspagesize = %d\n",
+	     __func__, devp->rdev.lldi.sge_ingpadboundary,
+	     devp->rdev.lldi.sge_egrstatuspagesize);
+
+	devp->rdev.hw_queue.t4_eq_status_entries =
+		devp->rdev.lldi.sge_ingpadboundary > 64 ? 2 : 1;
+	devp->rdev.hw_queue.t4_max_eq_size =
+		65520 - devp->rdev.hw_queue.t4_eq_status_entries;
+	devp->rdev.hw_queue.t4_max_iq_size = 65520 - 1;
+	devp->rdev.hw_queue.t4_max_rq_size =
+		8192 - devp->rdev.hw_queue.t4_eq_status_entries;
+	devp->rdev.hw_queue.t4_max_sq_size =
+		devp->rdev.hw_queue.t4_max_eq_size - 1;
+	devp->rdev.hw_queue.t4_max_qp_depth =
+		devp->rdev.hw_queue.t4_max_rq_size - 1;
+	devp->rdev.hw_queue.t4_max_cq_depth =
+		devp->rdev.hw_queue.t4_max_iq_size - 1;
+	devp->rdev.hw_queue.t4_stat_len =
+		devp->rdev.lldi.sge_egrstatuspagesize;
+
 	/*
 	 * For T5 devices, we map all of BAR2 with WC.
 	 * For T4 devices with onchip qp mem, we map only that part
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 125bc5d..9b9754c 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -139,6 +139,17 @@ struct c4iw_stats {
 	u64  pas_ofld_conn_fails;
 };
 
+struct c4iw_hw_queue {
+	int t4_eq_status_entries;
+	int t4_max_eq_size;
+	int t4_max_iq_size;
+	int t4_max_rq_size;
+	int t4_max_sq_size;
+	int t4_max_qp_depth;
+	int t4_max_cq_depth;
+	int t4_stat_len;
+};
+
 struct c4iw_rdev {
 	struct c4iw_resource resource;
 	unsigned long qpshift;
@@ -156,6 +167,7 @@ struct c4iw_rdev {
 	unsigned long oc_mw_pa;
 	void __iomem *oc_mw_kva;
 	struct c4iw_stats stats;
+	struct c4iw_hw_queue hw_queue;
 	struct t4_dev_status_page *status_page;
 };
 
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index b1d3053..1d41b92 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -319,13 +319,13 @@ static int c4iw_query_device(struct ib_device *ibdev,
 	props->vendor_part_id = (u32)dev->rdev.lldi.pdev->device;
 	props->max_mr_size = T4_MAX_MR_SIZE;
 	props->max_qp = T4_MAX_NUM_QP;
-	props->max_qp_wr = T4_MAX_QP_DEPTH;
+	props->max_qp_wr = dev->rdev.hw_queue.t4_max_qp_depth;
 	props->max_sge = T4_MAX_RECV_SGE;
 	props->max_sge_rd = 1;
 	props->max_qp_rd_atom = c4iw_max_read_depth;
 	props->max_qp_init_rd_atom = c4iw_max_read_depth;
 	props->max_cq = T4_MAX_NUM_CQ;
-	props->max_cqe = T4_MAX_CQ_DEPTH;
+	props->max_cqe = dev->rdev.hw_queue.t4_max_cq_depth;
 	props->max_mr = c4iw_num_stags(&dev->rdev);
 	props->max_pd = T4_MAX_NUM_PD;
 	props->local_ca_ack_delay = 0;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 086f62f..6f74e0e 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -258,7 +258,8 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	/*
 	 * eqsize is the number of 64B entries plus the status page size.
 	 */
-	eqsize = wq->sq.size * T4_SQ_NUM_SLOTS + T4_EQ_STATUS_ENTRIES;
+	eqsize = wq->sq.size * T4_SQ_NUM_SLOTS +
+		rdev->hw_queue.t4_eq_status_entries;
 
 	res->u.sqrq.fetchszm_to_iqid = cpu_to_be32(
 		V_FW_RI_RES_WR_HOSTFCMODE(0) |	/* no host cidx updates */
@@ -283,7 +284,8 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	/*
 	 * eqsize is the number of 64B entries plus the status page size.
 	 */
-	eqsize = wq->rq.size * T4_RQ_NUM_SLOTS + T4_EQ_STATUS_ENTRIES;
+	eqsize = wq->rq.size * T4_RQ_NUM_SLOTS +
+		rdev->hw_queue.t4_eq_status_entries;
 	res->u.sqrq.fetchszm_to_iqid = cpu_to_be32(
 		V_FW_RI_RES_WR_HOSTFCMODE(0) |	/* no host cidx updates */
 		V_FW_RI_RES_WR_CPRIO(0) |	/* don't keep in chip cache */
@@ -1570,11 +1572,11 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		return ERR_PTR(-EINVAL);
 
 	rqsize = roundup(attrs->cap.max_recv_wr + 1, 16);
-	if (rqsize > T4_MAX_RQ_SIZE)
+	if (rqsize > rhp->rdev.hw_queue.t4_max_rq_size)
 		return ERR_PTR(-E2BIG);
 
 	sqsize = roundup(attrs->cap.max_send_wr + 1, 16);
-	if (sqsize > T4_MAX_SQ_SIZE)
+	if (sqsize > rhp->rdev.hw_queue.t4_max_sq_size)
 		return ERR_PTR(-E2BIG);
 
 	ucontext = pd->uobject ? to_c4iw_ucontext(pd->uobject->context) : NULL;
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 68b0a6b..e64fa8b 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -39,19 +39,11 @@
 #define T4_MAX_NUM_QP 65536
 #define T4_MAX_NUM_CQ 65536
 #define T4_MAX_NUM_PD 65536
-#define T4_EQ_STATUS_ENTRIES (L1_CACHE_BYTES > 64 ? 2 : 1)
-#define T4_MAX_EQ_SIZE (65520 - T4_EQ_STATUS_ENTRIES)
-#define T4_MAX_IQ_SIZE (65520 - 1)
-#define T4_MAX_RQ_SIZE (8192 - T4_EQ_STATUS_ENTRIES)
-#define T4_MAX_SQ_SIZE (T4_MAX_EQ_SIZE - 1)
-#define T4_MAX_QP_DEPTH (T4_MAX_RQ_SIZE - 1)
-#define T4_MAX_CQ_DEPTH (T4_MAX_IQ_SIZE - 1)
 #define T4_MAX_NUM_STAG (1<<15)
 #define T4_MAX_MR_SIZE (~0ULL)
 #define T4_PAGESIZE_MASK 0xffff000  /* 4KB-128MB */
 #define T4_STAG_UNSET 0xffffffff
 #define T4_FW_MAJ 0
-#define T4_EQ_STATUS_ENTRIES (L1_CACHE_BYTES > 64 ? 2 : 1)
 #define A_PCIE_MA_SYNC 0x30b4
 
 struct t4_status_page {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2b438bd..a7ce996 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4109,6 +4109,8 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL);
 	lli.fw_vers = adap->params.fw_vers;
 	lli.dbfifo_int_thresh = dbfifo_int_thresh;
+	lli.sge_ingpadboundary = adap->sge.fl_align;
+	lli.sge_egrstatuspagesize = adap->sge.stat_len;
 	lli.sge_pktshift = adap->sge.pktshift;
 	lli.enable_fw_ofld_conn = adap->flags & FW_OFLD_CONN;
 	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 8f60851..962458f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -251,6 +251,8 @@ struct cxgb4_lld_info {
 	void __iomem *gts_reg;               /* address of GTS register */
 	void __iomem *db_reg;                /* address of kernel doorbell */
 	int dbfifo_int_thresh;		     /* doorbell fifo int threshold */
+	unsigned int sge_ingpadboundary;     /* SGE ingress padding boundary */
+	unsigned int sge_egrstatuspagesize;  /* SGE egress status page size */
 	unsigned int sge_pktshift;           /* Padding between CPL and */
 					     /*	packet data */
 	unsigned int pf;		     /* Physical Function we're using */
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
