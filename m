From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V2 7/9] IB/mlx5: Mellanox Connect-IB, IB driver part 3/5
Date: Wed,  3 Jul 2013 20:13:10 +0300
Message-ID: <1372871592-32033-8-git-send-email-ogerlitz@mellanox.com>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372871592-32033-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  547 ++++++++++++++++++
 drivers/infiniband/hw/mlx5/mr.c      | 1021 ++++++++++++++++++++++++++++++++++
 2 files changed, 1568 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/mlx5_ib.h
 create mode 100644 drivers/infiniband/hw/mlx5/mr.c

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
new file mode 100644
index 0000000..d2067c3
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -0,0 +1,547 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef MLX5_IB_H
+#define MLX5_IB_H
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_smi.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cq.h>
+#include <linux/mlx5/qp.h>
+#include <linux/mlx5/srq.h>
+#include <linux/types.h>
+
+#define mlx5_ib_dbg(dev, format, arg...)				\
+do {									\
+	pr_debug("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name,	\
+		 __func__, __LINE__, current->pid, ##arg);		\
+} while (0)
+
+#define mlx5_ib_err(dev, format, arg...)				\
+pr_err("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name, __func__,	\
+	__LINE__, current->pid, ##arg)
+
+#define mlx5_ib_warn(dev, format, arg...)				\
+pr_warn("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name, __func__,	\
+	__LINE__, current->pid, ##arg)
+
+enum {
+	MLX5_IB_MMAP_CMD_SHIFT	= 8,
+	MLX5_IB_MMAP_CMD_MASK	= 0xff,
+};
+
+enum mlx5_ib_mmap_cmd {
+	MLX5_IB_MMAP_REGULAR_PAGE		= 0,
+	MLX5_IB_MMAP_GET_CONTIGUOUS_PAGES	= 1, /* always last */
+};
+
+enum {
+	MLX5_RES_SCAT_DATA32_CQE	= 0x1,
+	MLX5_RES_SCAT_DATA64_CQE	= 0x2,
+	MLX5_REQ_SCAT_DATA32_CQE	= 0x11,
+	MLX5_REQ_SCAT_DATA64_CQE	= 0x22,
+};
+
+enum mlx5_ib_latency_class {
+	MLX5_IB_LATENCY_CLASS_LOW,
+	MLX5_IB_LATENCY_CLASS_MEDIUM,
+	MLX5_IB_LATENCY_CLASS_HIGH,
+	MLX5_IB_LATENCY_CLASS_FAST_PATH
+};
+
+enum mlx5_ib_mad_ifc_flags {
+	MLX5_MAD_IFC_IGNORE_MKEY	= 1,
+	MLX5_MAD_IFC_IGNORE_BKEY	= 2,
+	MLX5_MAD_IFC_NET_VIEW		= 4,
+};
+
+struct mlx5_ib_ucontext {
+	struct ib_ucontext	ibucontext;
+	struct list_head	db_page_list;
+
+	/* protect doorbell record alloc/free
+	 */
+	struct mutex		db_page_mutex;
+	struct mlx5_uuar_info	uuari;
+};
+
+static inline struct mlx5_ib_ucontext *to_mucontext(struct ib_ucontext *ibucontext)
+{
+	return container_of(ibucontext, struct mlx5_ib_ucontext, ibucontext);
+}
+
+struct mlx5_ib_pd {
+	struct ib_pd		ibpd;
+	u32			pdn;
+	u32			pa_lkey;
+};
+
+/* Use macros here so that don't have to duplicate
+ * enum ib_send_flags and enum ib_qp_type for low-level driver
+ */
+
+#define MLX5_IB_SEND_UMR_UNREG	IB_SEND_RESERVED_START
+#define MLX5_IB_QPT_REG_UMR	IB_QPT_RESERVED1
+#define MLX5_IB_WR_UMR		IB_WR_RESERVED1
+
+struct wr_list {
+	u16	opcode;
+	u16	next;
+};
+
+struct mlx5_ib_wq {
+	u64		       *wrid;
+	u32		       *wr_data;
+	struct wr_list	       *w_list;
+	unsigned	       *wqe_head;
+	u16		        unsig_count;
+
+	/* serialize post to the work queue
+	 */
+	spinlock_t		lock;
+	int			wqe_cnt;
+	int			max_post;
+	int			max_gs;
+	int			offset;
+	int			wqe_shift;
+	unsigned		head;
+	unsigned		tail;
+	u16			cur_post;
+	u16			last_poll;
+	void		       *qend;
+};
+
+enum {
+	MLX5_QP_USER,
+	MLX5_QP_KERNEL,
+	MLX5_QP_EMPTY
+};
+
+struct mlx5_ib_qp {
+	struct ib_qp		ibqp;
+	struct mlx5_core_qp	mqp;
+	struct mlx5_buf		buf;
+
+	struct mlx5_db		db;
+	struct mlx5_ib_wq	rq;
+
+	u32			doorbell_qpn;
+	u8			sq_signal_bits;
+	u8			fm_cache;
+	int			sq_max_wqes_per_wr;
+	int			sq_spare_wqes;
+	struct mlx5_ib_wq	sq;
+
+	struct ib_umem	       *umem;
+	int			buf_size;
+
+	/* serialize qp state modifications
+	 */
+	struct mutex		mutex;
+	u16			xrcdn;
+	u32			flags;
+	u8			port;
+	u8			alt_port;
+	u8			atomic_rd_en;
+	u8			resp_depth;
+	u8			state;
+	int			mlx_type;
+	int			wq_sig;
+	int			scat_cqe;
+	int			max_inline_data;
+	struct mlx5_bf	       *bf;
+	int			has_rq;
+
+	/* only for user space QPs. For kernel
+	 * we have it from the bf object
+	 */
+	int			uuarn;
+
+	int			create_type;
+	u32			pa_lkey;
+};
+
+struct mlx5_ib_cq_buf {
+	struct mlx5_buf		buf;
+	struct ib_umem		*umem;
+	int			cqe_size;
+};
+
+enum mlx5_ib_qp_flags {
+	MLX5_IB_QP_BLOCK_MULTICAST_LOOPBACK     = 1 << 0,
+	MLX5_IB_QP_SIGNATURE_HANDLING           = 1 << 1,
+};
+
+struct mlx5_shared_mr_info {
+	int mr_id;
+	struct ib_umem		*umem;
+};
+
+struct mlx5_ib_cq {
+	struct ib_cq		ibcq;
+	struct mlx5_core_cq	mcq;
+	struct mlx5_ib_cq_buf	buf;
+	struct mlx5_db		db;
+
+	/* serialize access to the CQ
+	 */
+	spinlock_t		lock;
+
+	/* protect resize cq
+	 */
+	struct mutex		resize_mutex;
+	struct mlx5_ib_cq_resize *resize_buf;
+	struct ib_umem	       *resize_umem;
+	int			cqe_size;
+};
+
+struct mlx5_ib_srq {
+	struct ib_srq		ibsrq;
+	struct mlx5_core_srq	msrq;
+	struct mlx5_buf		buf;
+	struct mlx5_db		db;
+	u64		       *wrid;
+	/* protect SRQ hanlding
+	 */
+	spinlock_t		lock;
+	int			head;
+	int			tail;
+	u16			wqe_ctr;
+	struct ib_umem	       *umem;
+	/* serialize arming a SRQ
+	 */
+	struct mutex		mutex;
+	int			wq_sig;
+};
+
+struct mlx5_ib_xrcd {
+	struct ib_xrcd		ibxrcd;
+	u32			xrcdn;
+};
+
+struct mlx5_ib_mr {
+	struct ib_mr		ibmr;
+	struct mlx5_core_mr	mmr;
+	struct ib_umem	       *umem;
+	struct mlx5_shared_mr_info	*smr_info;
+	struct list_head	list;
+	int			order;
+	int			umred;
+	__be64			*pas;
+	dma_addr_t		dma;
+	int			npages;
+	struct completion	done;
+	enum ib_wc_status	status;
+};
+
+struct mlx5_ib_fast_reg_page_list {
+	struct ib_fast_reg_page_list	ibfrpl;
+	__be64			       *mapped_page_list;
+	dma_addr_t			map;
+};
+
+struct umr_common {
+	struct ib_pd	*pd;
+	struct ib_cq	*cq;
+	struct ib_qp	*qp;
+	struct ib_mr	*mr;
+	/* control access to UMR QP
+	 */
+	struct semaphore	sem;
+};
+
+enum {
+	MLX5_FMR_INVALID,
+	MLX5_FMR_VALID,
+	MLX5_FMR_BUSY,
+};
+
+struct mlx5_ib_fmr {
+	struct ib_fmr			ibfmr;
+	struct mlx5_core_mr		mr;
+	int				access_flags;
+	int				state;
+	/* protect fmr state
+	 */
+	spinlock_t			lock;
+	u64				wrid;
+	struct ib_send_wr		wr[2];
+	u8				page_shift;
+	struct ib_fast_reg_page_list	page_list;
+};
+
+struct mlx5_cache_ent {
+	struct list_head	head;
+	/* sync access to the cahce entry
+	 */
+	spinlock_t		lock;
+
+
+	struct dentry	       *dir;
+	char                    name[4];
+	u32                     order;
+	u32			size;
+	u32                     cur;
+	u32                     miss;
+	u32			limit;
+
+	struct dentry          *fsize;
+	struct dentry          *fcur;
+	struct dentry          *fmiss;
+	struct dentry          *flimit;
+
+	struct mlx5_ib_dev     *dev;
+	struct work_struct	work;
+	struct delayed_work	dwork;
+};
+
+struct mlx5_mr_cache {
+	struct workqueue_struct *wq;
+	struct mlx5_cache_ent	ent[MAX_MR_CACHE_ENTRIES];
+	int			stopped;
+	struct dentry		*root;
+	unsigned long		last_add;
+};
+
+struct mlx5_ib_resources {
+	struct ib_cq	*c0;
+	struct ib_xrcd	*x0;
+	struct ib_xrcd	*x1;
+	struct ib_pd	*p0;
+	struct ib_srq	*s0;
+};
+
+struct mlx5_ib_dev {
+	struct ib_device		ib_dev;
+	struct mlx5_core_dev		mdev;
+	MLX5_DECLARE_DOORBELL_LOCK(uar_lock);
+	struct list_head		eqs_list;
+	int				num_ports;
+	int				num_comp_vectors;
+	/* serialize update of capability mask
+	 */
+	struct mutex			cap_mask_mutex;
+	bool				ib_active;
+	struct umr_common		umrc;
+	/* sync used page count stats
+	 */
+	spinlock_t			mr_lock;
+	struct mlx5_ib_resources	devr;
+	struct mlx5_mr_cache		cache;
+};
+
+static inline struct mlx5_ib_cq *to_mibcq(struct mlx5_core_cq *mcq)
+{
+	return container_of(mcq, struct mlx5_ib_cq, mcq);
+}
+
+static inline struct mlx5_ib_xrcd *to_mxrcd(struct ib_xrcd *ibxrcd)
+{
+	return container_of(ibxrcd, struct mlx5_ib_xrcd, ibxrcd);
+}
+
+static inline struct mlx5_ib_dev *to_mdev(struct ib_device *ibdev)
+{
+	return container_of(ibdev, struct mlx5_ib_dev, ib_dev);
+}
+
+static inline struct mlx5_ib_fmr *to_mfmr(struct ib_fmr *ibfmr)
+{
+	return container_of(ibfmr, struct mlx5_ib_fmr, ibfmr);
+}
+
+static inline struct mlx5_ib_cq *to_mcq(struct ib_cq *ibcq)
+{
+	return container_of(ibcq, struct mlx5_ib_cq, ibcq);
+}
+
+static inline struct mlx5_ib_qp *to_mibqp(struct mlx5_core_qp *mqp)
+{
+	return container_of(mqp, struct mlx5_ib_qp, mqp);
+}
+
+static inline struct mlx5_ib_pd *to_mpd(struct ib_pd *ibpd)
+{
+	return container_of(ibpd, struct mlx5_ib_pd, ibpd);
+}
+
+static inline struct mlx5_ib_srq *to_msrq(struct ib_srq *ibsrq)
+{
+	return container_of(ibsrq, struct mlx5_ib_srq, ibsrq);
+}
+
+static inline struct mlx5_ib_qp *to_mqp(struct ib_qp *ibqp)
+{
+	return container_of(ibqp, struct mlx5_ib_qp, ibqp);
+}
+
+static inline struct mlx5_ib_srq *to_mibsrq(struct mlx5_core_srq *msrq)
+{
+	return container_of(msrq, struct mlx5_ib_srq, msrq);
+}
+
+static inline struct mlx5_ib_mr *to_mmr(struct ib_mr *ibmr)
+{
+	return container_of(ibmr, struct mlx5_ib_mr, ibmr);
+}
+
+static inline struct mlx5_ib_fast_reg_page_list *to_mfrpl(struct ib_fast_reg_page_list *ibfrpl)
+{
+	return container_of(ibfrpl, struct mlx5_ib_fast_reg_page_list, ibfrpl);
+}
+
+struct mlx5_ib_ah {
+	struct ib_ah		ibah;
+	struct mlx5_av		av;
+};
+
+static inline struct mlx5_ib_ah *to_mah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct mlx5_ib_ah, ibah);
+}
+
+static inline struct mlx5_ib_dev *mlx5_core2ibdev(struct mlx5_core_dev *dev)
+{
+	return container_of(dev, struct mlx5_ib_dev, mdev);
+}
+
+static inline struct mlx5_ib_dev *mlx5_pci2ibdev(struct pci_dev *pdev)
+{
+	return mlx5_core2ibdev(pci2mlx5_core_dev(pdev));
+}
+
+int mlx5_ib_db_map_user(struct mlx5_ib_ucontext *context, unsigned long virt,
+			struct mlx5_db *db);
+void mlx5_ib_db_unmap_user(struct mlx5_ib_ucontext *context, struct mlx5_db *db);
+void __mlx5_ib_cq_clean(struct mlx5_ib_cq *cq, u32 qpn, struct mlx5_ib_srq *srq);
+void mlx5_ib_cq_clean(struct mlx5_ib_cq *cq, u32 qpn, struct mlx5_ib_srq *srq);
+void mlx5_ib_free_srq_wqe(struct mlx5_ib_srq *srq, int wqe_index);
+int mlx5_MAD_IFC(struct mlx5_ib_dev *dev, int ignore_mkey, int ignore_bkey,
+		 int port, struct ib_wc *in_wc, struct ib_grh *in_grh,
+		 void *in_mad, void *response_mad);
+struct ib_ah *create_ib_ah(struct ib_ah_attr *ah_attr,
+			   struct mlx5_ib_ah *ah);
+struct ib_ah *mlx5_ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr);
+int mlx5_ib_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr);
+int mlx5_ib_destroy_ah(struct ib_ah *ah);
+struct ib_srq *mlx5_ib_create_srq(struct ib_pd *pd,
+				  struct ib_srq_init_attr *init_attr,
+				  struct ib_udata *udata);
+int mlx5_ib_modify_srq(struct ib_srq *ibsrq, struct ib_srq_attr *attr,
+		       enum ib_srq_attr_mask attr_mask, struct ib_udata *udata);
+int mlx5_ib_query_srq(struct ib_srq *ibsrq, struct ib_srq_attr *srq_attr);
+int mlx5_ib_destroy_srq(struct ib_srq *srq);
+int mlx5_ib_post_srq_recv(struct ib_srq *ibsrq, struct ib_recv_wr *wr,
+			  struct ib_recv_wr **bad_wr);
+struct ib_qp *mlx5_ib_create_qp(struct ib_pd *pd,
+				struct ib_qp_init_attr *init_attr,
+				struct ib_udata *udata);
+int mlx5_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		      int attr_mask, struct ib_udata *udata);
+int mlx5_ib_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr, int qp_attr_mask,
+		     struct ib_qp_init_attr *qp_init_attr);
+int mlx5_ib_destroy_qp(struct ib_qp *qp);
+int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
+		      struct ib_send_wr **bad_wr);
+int mlx5_ib_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
+		      struct ib_recv_wr **bad_wr);
+void *mlx5_get_send_wqe(struct mlx5_ib_qp *qp, int n);
+struct ib_cq *mlx5_ib_create_cq(struct ib_device *ibdev, int entries,
+				int vector, struct ib_ucontext *context,
+				struct ib_udata *udata);
+int mlx5_ib_destroy_cq(struct ib_cq *cq);
+int mlx5_ib_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
+int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
+int mlx5_ib_modify_cq(struct ib_cq *cq, u16 cq_count, u16 cq_period);
+int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata);
+struct ib_mr *mlx5_ib_get_dma_mr(struct ib_pd *pd, int acc);
+struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
+				  u64 virt_addr, int access_flags,
+				  struct ib_udata *udata);
+int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
+struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
+					int max_page_list_len);
+struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
+							       int page_list_len);
+void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list);
+struct ib_fmr *mlx5_ib_fmr_alloc(struct ib_pd *pd, int acc,
+				 struct ib_fmr_attr *fmr_attr);
+int mlx5_ib_map_phys_fmr(struct ib_fmr *ibfmr, u64 *page_list,
+		      int npages, u64 iova);
+int mlx5_ib_unmap_fmr(struct list_head *fmr_list);
+int mlx5_ib_fmr_dealloc(struct ib_fmr *ibfmr);
+int mlx5_ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
+			struct ib_wc *in_wc, struct ib_grh *in_grh,
+			struct ib_mad *in_mad, struct ib_mad *out_mad);
+struct ib_xrcd *mlx5_ib_alloc_xrcd(struct ib_device *ibdev,
+					  struct ib_ucontext *context,
+					  struct ib_udata *udata);
+int mlx5_ib_dealloc_xrcd(struct ib_xrcd *xrcd);
+int mlx5_vector2eqn(struct mlx5_ib_dev *dev, int vector, int *eqn, int *irqn);
+int mlx5_ib_get_buf_offset(u64 addr, int page_shift, u32 *offset);
+int mlx5_query_ext_port_caps(struct mlx5_ib_dev *dev, u8 port);
+int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
+		       struct ib_port_attr *props);
+int mlx5_ib_init_fmr(struct mlx5_ib_dev *dev);
+void mlx5_ib_cleanup_fmr(struct mlx5_ib_dev *dev);
+void mlx5_ib_cont_pages(struct ib_umem *umem, u64 addr, int *count, int *shift,
+			int *ncont, int *order);
+void mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
+			  int page_shift, __be64 *pas, int umr);
+void mlx5_ib_copy_pas(u64 *old, u64 *new, int step, int num);
+int mlx5_ib_get_cqe_size(struct mlx5_ib_dev *dev, struct ib_cq *ibcq);
+int mlx5_mr_cache_init(struct mlx5_ib_dev *dev);
+int mlx5_mr_cache_cleanup(struct mlx5_ib_dev *dev);
+int mlx5_mr_ib_cont_pages(struct ib_umem *umem, u64 addr, int *count, int *shift);
+void mlx5_umr_cq_handler(struct ib_cq *cq, void *cq_context);
+
+static inline void init_query_mad(struct ib_smp *mad)
+{
+	mad->base_version  = 1;
+	mad->mgmt_class    = IB_MGMT_CLASS_SUBN_LID_ROUTED;
+	mad->class_version = 1;
+	mad->method	   = IB_MGMT_METHOD_GET;
+}
+
+static inline u8 convert_access(int acc)
+{
+	return (acc & IB_ACCESS_REMOTE_ATOMIC ? MLX5_PERM_ATOMIC       : 0) |
+	       (acc & IB_ACCESS_REMOTE_WRITE  ? MLX5_PERM_REMOTE_WRITE : 0) |
+	       (acc & IB_ACCESS_REMOTE_READ   ? MLX5_PERM_REMOTE_READ  : 0) |
+	       (acc & IB_ACCESS_LOCAL_WRITE   ? MLX5_PERM_LOCAL_WRITE  : 0) |
+	       MLX5_PERM_LOCAL_READ;
+}
+
+#endif /* MLX5_IB_H */
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
new file mode 100644
index 0000000..f03eb95
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -0,0 +1,1021 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+
+#include <linux/kref.h>
+#include <linux/vmalloc.h>
+#include <linux/random.h>
+#include <linux/debugfs.h>
+#include <linux/export.h>
+#include <rdma/ib_umem.h>
+#include "mlx5_ib.h"
+
+enum {
+	DEF_CACHE_SIZE	= 10,
+};
+
+static __be64 *mr_align(__be64 *ptr, int align)
+{
+	unsigned long mask = align - 1;
+
+	return (__be64 *)(((unsigned long)ptr + mask) & ~mask);
+}
+
+static int file_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+
+	return 0;
+}
+
+static int order2idx(struct mlx5_ib_dev *dev, int order)
+{
+	struct mlx5_mr_cache *cache = &dev->cache;
+
+	if (order < cache->ent[0].order)
+		return 0;
+	else
+		return order - cache->ent[0].order;
+}
+
+static int add_keys(struct mlx5_ib_dev *dev, int c, int num)
+{
+	struct device *ddev = dev->ib_dev.dma_device;
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent = &cache->ent[c];
+	struct mlx5_create_mkey_mbox_in *in;
+	struct mlx5_ib_mr *mr;
+	int npages = 1 << ent->order;
+	int size = sizeof(u64) * npages;
+	int err = 0;
+	int i;
+
+	in = kzalloc(sizeof(*in), GFP_KERNEL);
+	if (!in) {
+		mlx5_ib_warn(dev, "allocation failed\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < num; i++) {
+		mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+		if (!mr) {
+			mlx5_ib_warn(dev, "allocation failed\n");
+			err = -ENOMEM;
+			goto out;
+		}
+		mr->order = ent->order;
+		mr->umred = 1;
+		mr->pas = kmalloc(size + 0x3f, GFP_KERNEL);
+		if (!mr->pas) {
+			kfree(mr);
+			err = -ENOMEM;
+			goto out;
+		}
+		mr->dma = dma_map_single(ddev, mr_align(mr->pas, 0x40), size,
+					 DMA_TO_DEVICE);
+		if (dma_mapping_error(ddev, mr->dma)) {
+			kfree(mr->pas);
+			kfree(mr);
+			err = -ENOMEM;
+			goto out;
+		}
+
+		in->seg.status = 1 << 6;
+		in->seg.xlt_oct_size = cpu_to_be32((npages + 1) / 2);
+		in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
+		in->seg.flags = MLX5_ACCESS_MODE_MTT | MLX5_PERM_UMR_EN;
+		in->seg.log2_page_size = 12;
+
+		err = mlx5_core_create_mkey(&dev->mdev, &mr->mmr, in,
+					    sizeof(*in));
+		if (err) {
+			mlx5_ib_warn(dev, "create mkey failed %d\n", err);
+			dma_unmap_single(ddev, mr->dma, size, DMA_TO_DEVICE);
+			kfree(mr->pas);
+			kfree(mr);
+			goto out;
+		}
+		cache->last_add = jiffies;
+
+		spin_lock(&ent->lock);
+		list_add_tail(&mr->list, &ent->head);
+		ent->cur++;
+		ent->size++;
+		spin_unlock(&ent->lock);
+	}
+
+out:
+	kfree(in);
+	return err;
+}
+
+static void remove_keys(struct mlx5_ib_dev *dev, int c, int num)
+{
+	struct device *ddev = dev->ib_dev.dma_device;
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent = &cache->ent[c];
+	struct mlx5_ib_mr *mr;
+	int size;
+	int err;
+	int i;
+
+	for (i = 0; i < num; i++) {
+		spin_lock(&ent->lock);
+		if (list_empty(&ent->head)) {
+			spin_unlock(&ent->lock);
+			return;
+		}
+		mr = list_first_entry(&ent->head, struct mlx5_ib_mr, list);
+		list_del(&mr->list);
+		ent->cur--;
+		ent->size--;
+		spin_unlock(&ent->lock);
+		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
+		if (err) {
+			mlx5_ib_warn(dev, "failed destroy mkey\n");
+		} else {
+			size = ALIGN(sizeof(u64) * (1 << mr->order), 0x40);
+			dma_unmap_single(ddev, mr->dma, size, DMA_TO_DEVICE);
+			kfree(mr->pas);
+			kfree(mr);
+		}
+	};
+}
+
+static ssize_t size_write(struct file *filp, const char __user *buf,
+			  size_t count, loff_t *pos)
+{
+	struct mlx5_cache_ent *ent = filp->private_data;
+	struct mlx5_ib_dev *dev = ent->dev;
+	char lbuf[20];
+	u32 var;
+	int err;
+	int c;
+
+	if (copy_from_user(lbuf, buf, sizeof(lbuf)))
+		return -EPERM;
+
+	c = order2idx(dev, ent->order);
+	lbuf[sizeof(lbuf) - 1] = 0;
+
+	if (sscanf(lbuf, "%u", &var) != 1)
+		return -EINVAL;
+
+	if (var < ent->limit)
+		return -EINVAL;
+
+	if (var > ent->size) {
+		err = add_keys(dev, c, var - ent->size);
+		if (err)
+			return err;
+	} else if (var < ent->size) {
+		remove_keys(dev, c, ent->size - var);
+	}
+
+	return count;
+}
+
+static ssize_t size_read(struct file *filp, char __user *buf, size_t count,
+			 loff_t *pos)
+{
+	struct mlx5_cache_ent *ent = filp->private_data;
+	char lbuf[20];
+	int err;
+
+	if (*pos)
+		return 0;
+
+	err = snprintf(lbuf, sizeof(lbuf), "%d\n", ent->size);
+	if (err < 0)
+		return err;
+
+	if (copy_to_user(buf, lbuf, err))
+		return -EPERM;
+
+	*pos += err;
+
+	return err;
+}
+
+static const struct file_operations size_fops = {
+	.owner	= THIS_MODULE,
+	.open	= file_open,
+	.write	= size_write,
+	.read	= size_read,
+};
+
+static ssize_t limit_write(struct file *filp, const char __user *buf,
+			   size_t count, loff_t *pos)
+{
+	struct mlx5_cache_ent *ent = filp->private_data;
+	struct mlx5_ib_dev *dev = ent->dev;
+	char lbuf[20];
+	u32 var;
+	int err;
+	int c;
+
+	if (copy_from_user(lbuf, buf, sizeof(lbuf)))
+		return -EPERM;
+
+	c = order2idx(dev, ent->order);
+	lbuf[sizeof(lbuf) - 1] = 0;
+
+	if (sscanf(lbuf, "%u", &var) != 1)
+		return -EINVAL;
+
+	if (var > ent->size)
+		return -EINVAL;
+
+	ent->limit = var;
+
+	if (ent->cur < ent->limit) {
+		err = add_keys(dev, c, 2 * ent->limit - ent->cur);
+		if (err)
+			return err;
+	}
+
+	return count;
+}
+
+static ssize_t limit_read(struct file *filp, char __user *buf, size_t count,
+			  loff_t *pos)
+{
+	struct mlx5_cache_ent *ent = filp->private_data;
+	char lbuf[20];
+	int err;
+
+	if (*pos)
+		return 0;
+
+	err = snprintf(lbuf, sizeof(lbuf), "%d\n", ent->limit);
+	if (err < 0)
+		return err;
+
+	if (copy_to_user(buf, lbuf, err))
+		return -EPERM;
+
+	*pos += err;
+
+	return err;
+}
+
+static const struct file_operations limit_fops = {
+	.owner	= THIS_MODULE,
+	.open	= file_open,
+	.write	= limit_write,
+	.read	= limit_read,
+};
+
+static int someone_adding(struct mlx5_mr_cache *cache)
+{
+	int i;
+
+	for (i = 0; i < MAX_MR_CACHE_ENTRIES; i++) {
+		if (cache->ent[i].cur < cache->ent[i].limit)
+			return 1;
+	}
+
+	return 0;
+}
+
+static void __cache_work_func(struct mlx5_cache_ent *ent)
+{
+	struct mlx5_ib_dev *dev = ent->dev;
+	struct mlx5_mr_cache *cache = &dev->cache;
+	int i = order2idx(dev, ent->order);
+
+	if (cache->stopped)
+		return;
+
+	ent = &dev->cache.ent[i];
+	if (ent->cur < 2 * ent->limit) {
+		add_keys(dev, i, 1);
+		if (ent->cur < 2 * ent->limit)
+			queue_work(cache->wq, &ent->work);
+	} else if (ent->cur > 2 * ent->limit) {
+		if (!someone_adding(cache) &&
+		    time_after(jiffies, cache->last_add + 60 * HZ)) {
+			remove_keys(dev, i, 1);
+			if (ent->cur > ent->limit)
+				queue_work(cache->wq, &ent->work);
+		} else {
+			queue_delayed_work(cache->wq, &ent->dwork, 60 * HZ);
+		}
+	}
+}
+
+static void delayed_cache_work_func(struct work_struct *work)
+{
+	struct mlx5_cache_ent *ent;
+
+	ent = container_of(work, struct mlx5_cache_ent, dwork.work);
+	__cache_work_func(ent);
+}
+
+static void cache_work_func(struct work_struct *work)
+{
+	struct mlx5_cache_ent *ent;
+
+	ent = container_of(work, struct mlx5_cache_ent, work);
+	__cache_work_func(ent);
+}
+
+static struct mlx5_ib_mr *alloc_cached_mr(struct mlx5_ib_dev *dev, int order)
+{
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_ib_mr *mr = NULL;
+	struct mlx5_cache_ent *ent;
+	int c;
+	int i;
+
+	c = order2idx(dev, order);
+	if (c < 0 || c >= MAX_MR_CACHE_ENTRIES) {
+		mlx5_ib_warn(dev, "order %d, cache index %d\n", order, c);
+		return NULL;
+	}
+
+	for (i = c; i < MAX_MR_CACHE_ENTRIES; i++) {
+		ent = &cache->ent[i];
+
+		mlx5_ib_dbg(dev, "order %d, cache index %d\n", ent->order, i);
+
+		spin_lock(&ent->lock);
+		if (!list_empty(&ent->head)) {
+			mr = list_first_entry(&ent->head, struct mlx5_ib_mr,
+					      list);
+			list_del(&mr->list);
+			ent->cur--;
+			spin_unlock(&ent->lock);
+			if (ent->cur < ent->limit)
+				queue_work(cache->wq, &ent->work);
+			break;
+		}
+		spin_unlock(&ent->lock);
+
+		queue_work(cache->wq, &ent->work);
+
+		if (mr)
+			break;
+	}
+
+	if (!mr)
+		cache->ent[c].miss++;
+
+	return mr;
+}
+
+static void free_cached_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
+{
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent;
+	int shrink = 0;
+	int c;
+
+	c = order2idx(dev, mr->order);
+	if (c < 0 || c >= MAX_MR_CACHE_ENTRIES) {
+		mlx5_ib_warn(dev, "order %d, cache index %d\n", mr->order, c);
+		return;
+	}
+	ent = &cache->ent[c];
+	spin_lock(&ent->lock);
+	list_add_tail(&mr->list, &ent->head);
+	ent->cur++;
+	if (ent->cur > 2 * ent->limit)
+		shrink = 1;
+	spin_unlock(&ent->lock);
+
+	if (shrink)
+		queue_work(cache->wq, &ent->work);
+}
+
+static void clean_keys(struct mlx5_ib_dev *dev, int c)
+{
+	struct device *ddev = dev->ib_dev.dma_device;
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent = &cache->ent[c];
+	struct mlx5_ib_mr *mr;
+	int size;
+	int err;
+
+	while (1) {
+		spin_lock(&ent->lock);
+		if (list_empty(&ent->head)) {
+			spin_unlock(&ent->lock);
+			return;
+		}
+		mr = list_first_entry(&ent->head, struct mlx5_ib_mr, list);
+		list_del(&mr->list);
+		ent->cur--;
+		ent->size--;
+		spin_unlock(&ent->lock);
+		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
+		if (err) {
+			mlx5_ib_warn(dev, "failed destroy mkey\n");
+		} else {
+			size = ALIGN(sizeof(u64) * (1 << mr->order), 0x40);
+			dma_unmap_single(ddev, mr->dma, size, DMA_TO_DEVICE);
+			kfree(mr->pas);
+			kfree(mr);
+		}
+	};
+}
+
+static int mlx5_mr_cache_debugfs_init(struct mlx5_ib_dev *dev)
+{
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent;
+	int i;
+
+	if (!mlx5_debugfs_root)
+		return 0;
+
+	cache->root = debugfs_create_dir("mr_cache", dev->mdev.priv.dbg_root);
+	if (!cache->root)
+		return -ENOMEM;
+
+	for (i = 0; i < MAX_MR_CACHE_ENTRIES; i++) {
+		ent = &cache->ent[i];
+		sprintf(ent->name, "%d", ent->order);
+		ent->dir = debugfs_create_dir(ent->name,  cache->root);
+		if (!ent->dir)
+			return -ENOMEM;
+
+		ent->fsize = debugfs_create_file("size", 0600, ent->dir, ent,
+						 &size_fops);
+		if (!ent->fsize)
+			return -ENOMEM;
+
+		ent->flimit = debugfs_create_file("limit", 0600, ent->dir, ent,
+						  &limit_fops);
+		if (!ent->flimit)
+			return -ENOMEM;
+
+		ent->fcur = debugfs_create_u32("cur", 0400, ent->dir,
+					       &ent->cur);
+		if (!ent->fcur)
+			return -ENOMEM;
+
+		ent->fmiss = debugfs_create_u32("miss", 0600, ent->dir,
+						&ent->miss);
+		if (!ent->fmiss)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void mlx5_mr_cache_debugfs_cleanup(struct mlx5_ib_dev *dev)
+{
+	if (!mlx5_debugfs_root)
+		return;
+
+	debugfs_remove_recursive(dev->cache.root);
+}
+
+int mlx5_mr_cache_init(struct mlx5_ib_dev *dev)
+{
+	struct mlx5_mr_cache *cache = &dev->cache;
+	struct mlx5_cache_ent *ent;
+	int limit;
+	int size;
+	int err;
+	int i;
+
+	cache->wq = create_singlethread_workqueue("mkey_cache");
+	if (!cache->wq) {
+		mlx5_ib_warn(dev, "failed to create work queue\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < MAX_MR_CACHE_ENTRIES; i++) {
+		INIT_LIST_HEAD(&cache->ent[i].head);
+		spin_lock_init(&cache->ent[i].lock);
+
+		ent = &cache->ent[i];
+		INIT_LIST_HEAD(&ent->head);
+		spin_lock_init(&ent->lock);
+		ent->order = i + 2;
+		ent->dev = dev;
+
+		if (dev->mdev.profile->mask & MLX5_PROF_MASK_MR_CACHE) {
+			size = dev->mdev.profile->mr_cache[i].size;
+			limit = dev->mdev.profile->mr_cache[i].limit;
+		} else {
+			size = DEF_CACHE_SIZE;
+			limit = 0;
+		}
+		INIT_WORK(&ent->work, cache_work_func);
+		INIT_DELAYED_WORK(&ent->dwork, delayed_cache_work_func);
+		ent->limit = limit;
+		queue_work(cache->wq, &ent->work);
+	}
+
+	err = mlx5_mr_cache_debugfs_init(dev);
+	if (err)
+		mlx5_ib_warn(dev, "cache debugfs failure\n");
+
+	return 0;
+}
+
+int mlx5_mr_cache_cleanup(struct mlx5_ib_dev *dev)
+{
+	int i;
+
+	dev->cache.stopped = 1;
+	destroy_workqueue(dev->cache.wq);
+
+	mlx5_mr_cache_debugfs_cleanup(dev);
+
+	for (i = 0; i < MAX_MR_CACHE_ENTRIES; i++)
+		clean_keys(dev, i);
+
+	return 0;
+}
+
+struct ib_mr *mlx5_ib_get_dma_mr(struct ib_pd *pd, int acc)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct mlx5_core_dev *mdev = &dev->mdev;
+	struct mlx5_create_mkey_mbox_in *in;
+	struct mlx5_mkey_seg *seg;
+	struct mlx5_ib_mr *mr;
+	int err;
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	in = kzalloc(sizeof(*in), GFP_KERNEL);
+	if (!in) {
+		err = -ENOMEM;
+		goto err_free;
+	}
+
+	seg = &in->seg;
+	seg->flags = convert_access(acc) | MLX5_ACCESS_MODE_PA;
+	seg->flags_pd = cpu_to_be32(to_mpd(pd)->pdn | MLX5_MKEY_LEN64);
+	seg->qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
+	seg->start_addr = 0;
+
+	err = mlx5_core_create_mkey(mdev, &mr->mmr, in, sizeof(*in));
+	if (err)
+		goto err_in;
+
+	kfree(in);
+	mr->ibmr.lkey = mr->mmr.key;
+	mr->ibmr.rkey = mr->mmr.key;
+	mr->umem = NULL;
+
+	return &mr->ibmr;
+
+err_in:
+	kfree(in);
+
+err_free:
+	kfree(mr);
+
+	return ERR_PTR(err);
+}
+
+static int get_octo_len(u64 addr, u64 len, int page_size)
+{
+	u64 offset;
+	int npages;
+
+	offset = addr & (page_size - 1);
+	npages = ALIGN(len + offset, page_size) >> ilog2(page_size);
+	return (npages + 1) / 2;
+}
+
+static int use_umr(int order)
+{
+	return order <= 17;
+}
+
+static void prep_umr_reg_wqe(struct ib_pd *pd, struct ib_send_wr *wr,
+			     struct ib_sge *sg, u64 dma, int n, u32 key,
+			     int page_shift, u64 virt_addr, u64 len,
+			     int access_flags)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct ib_mr *mr = dev->umrc.mr;
+
+	sg->addr = dma;
+	sg->length = ALIGN(sizeof(u64) * n, 64);
+	sg->lkey = mr->lkey;
+
+	wr->next = NULL;
+	wr->send_flags = 0;
+	wr->sg_list = sg;
+	if (n)
+		wr->num_sge = 1;
+	else
+		wr->num_sge = 0;
+
+	wr->opcode = MLX5_IB_WR_UMR;
+	wr->wr.fast_reg.page_list_len = n;
+	wr->wr.fast_reg.page_shift = page_shift;
+	wr->wr.fast_reg.rkey = key;
+	wr->wr.fast_reg.iova_start = virt_addr;
+	wr->wr.fast_reg.length = len;
+	wr->wr.fast_reg.access_flags = access_flags;
+	wr->wr.fast_reg.page_list = (struct ib_fast_reg_page_list *)pd;
+}
+
+static void prep_umr_unreg_wqe(struct mlx5_ib_dev *dev,
+			       struct ib_send_wr *wr, u32 key)
+{
+	wr->send_flags = MLX5_IB_SEND_UMR_UNREG;
+	wr->opcode = MLX5_IB_WR_UMR;
+	wr->wr.fast_reg.rkey = key;
+}
+
+void mlx5_umr_cq_handler(struct ib_cq *cq, void *cq_context)
+{
+	struct mlx5_ib_mr *mr;
+	struct ib_wc wc;
+	int err;
+
+	while (1) {
+		err = ib_poll_cq(cq, 1, &wc);
+		if (err < 0) {
+			pr_warn("poll cq error %d\n", err);
+			return;
+		}
+		if (err == 0)
+			break;
+
+		mr = (struct mlx5_ib_mr *)(unsigned long)wc.wr_id;
+		mr->status = wc.status;
+		complete(&mr->done);
+	}
+	ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
+}
+
+static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
+				  u64 virt_addr, u64 len, int npages,
+				  int page_shift, int order, int access_flags)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct umr_common *umrc = &dev->umrc;
+	struct ib_send_wr wr, *bad;
+	struct mlx5_ib_mr *mr;
+	struct ib_sge sg;
+	int err;
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		mr = alloc_cached_mr(dev, order);
+		if (mr)
+			break;
+
+		err = add_keys(dev, order2idx(dev, order), 1);
+		if (err) {
+			mlx5_ib_warn(dev, "add_keys failed\n");
+			break;
+		}
+	}
+
+	if (!mr)
+		return ERR_PTR(-EAGAIN);
+
+	mlx5_ib_populate_pas(dev, umem, page_shift, mr_align(mr->pas, 0x40), 1);
+
+	memset(&wr, 0, sizeof(wr));
+	wr.wr_id = (u64)(unsigned long)mr;
+	prep_umr_reg_wqe(pd, &wr, &sg, mr->dma, npages, mr->mmr.key, page_shift, virt_addr, len, access_flags);
+
+	/* We serialize polls so one process does not kidnap another's
+	 * completion. This is not a problem since wr is completed in
+	 * around 1 usec
+	 */
+	down(&umrc->sem);
+	init_completion(&mr->done);
+	err = ib_post_send(umrc->qp, &wr, &bad);
+	if (err) {
+		mlx5_ib_warn(dev, "post send failed, err %d\n", err);
+		up(&umrc->sem);
+		goto error;
+	}
+	wait_for_completion(&mr->done);
+	up(&umrc->sem);
+
+	if (mr->status != IB_WC_SUCCESS) {
+		mlx5_ib_warn(dev, "reg umr failed\n");
+		err = -EFAULT;
+		goto error;
+	}
+
+	return mr;
+
+error:
+	free_cached_mr(dev, mr);
+	return ERR_PTR(err);
+}
+
+static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
+				     u64 length, struct ib_umem *umem,
+				     int npages, int page_shift,
+				     int access_flags)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct mlx5_create_mkey_mbox_in *in;
+	struct mlx5_ib_mr *mr;
+	int inlen;
+	int err;
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr) {
+		mlx5_ib_warn(dev, "allocation failed\n");
+		mr = ERR_PTR(-ENOMEM);
+	}
+
+	inlen = sizeof(*in) + sizeof(*in->pas) * ((npages + 1) / 2) * 2;
+	in = vzalloc(inlen);
+	if (!in) {
+		mlx5_ib_warn(dev, "alloc failed\n");
+		err = -ENOMEM;
+		goto err_1;
+	}
+	mlx5_ib_populate_pas(dev, umem, page_shift, in->pas, 0);
+
+	in->seg.flags = convert_access(access_flags) |
+		MLX5_ACCESS_MODE_MTT;
+	in->seg.flags_pd = cpu_to_be32(to_mpd(pd)->pdn);
+	in->seg.start_addr = cpu_to_be64(virt_addr);
+	in->seg.len = cpu_to_be64(length);
+	in->seg.bsfs_octo_size = 0;
+	in->seg.xlt_oct_size = cpu_to_be32(get_octo_len(virt_addr, length, 1 << page_shift));
+	in->seg.log2_page_size = page_shift;
+	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
+	in->xlat_oct_act_size = cpu_to_be32(get_octo_len(virt_addr, length, 1 << page_shift));
+	err = mlx5_core_create_mkey(&dev->mdev, &mr->mmr, in, inlen);
+	if (err) {
+		mlx5_ib_warn(dev, "create mkey failed\n");
+		goto err_2;
+	}
+	mr->umem = umem;
+	vfree(in);
+
+	mlx5_ib_dbg(dev, "mkey = 0x%x\n", mr->mmr.key);
+
+	return mr;
+
+err_2:
+	vfree(in);
+
+err_1:
+	kfree(mr);
+
+	return ERR_PTR(err);
+}
+
+struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
+				  u64 virt_addr, int access_flags,
+				  struct ib_udata *udata)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct mlx5_ib_mr *mr = NULL;
+	struct ib_umem *umem;
+	int page_shift;
+	int npages;
+	int ncont;
+	int order;
+	int err;
+
+	mlx5_ib_dbg(dev, "start 0x%llx, virt_addr 0x%llx, length 0x%llx\n",
+		    start, virt_addr, length);
+	umem = ib_umem_get(pd->uobject->context, start, length, access_flags,
+			   0);
+	if (IS_ERR(umem)) {
+		mlx5_ib_dbg(dev, "umem get failed\n");
+		return (void *)umem;
+	}
+
+	mlx5_ib_cont_pages(umem, start, &npages, &page_shift, &ncont, &order);
+	if (!npages) {
+		mlx5_ib_warn(dev, "avoid zero region\n");
+		err = -EINVAL;
+		goto error;
+	}
+
+	mlx5_ib_dbg(dev, "npages %d, ncont %d, order %d, page_shift %d\n",
+		    npages, ncont, order, page_shift);
+
+	if (use_umr(order)) {
+		mr = reg_umr(pd, umem, virt_addr, length, ncont, page_shift,
+			     order, access_flags);
+		if (PTR_ERR(mr) == -EAGAIN) {
+			mlx5_ib_dbg(dev, "cache empty for order %d", order);
+			mr = NULL;
+		}
+	}
+
+	if (!mr)
+		mr = reg_create(pd, virt_addr, length, umem, ncont, page_shift,
+				access_flags);
+
+	if (IS_ERR(mr)) {
+		err = PTR_ERR(mr);
+		goto error;
+	}
+
+	mlx5_ib_dbg(dev, "mkey 0x%x\n", mr->mmr.key);
+
+	mr->umem = umem;
+	mr->npages = npages;
+	spin_lock(&dev->mr_lock);
+	dev->mdev.priv.reg_pages += npages;
+	spin_unlock(&dev->mr_lock);
+	mr->ibmr.lkey = mr->mmr.key;
+	mr->ibmr.rkey = mr->mmr.key;
+
+	return &mr->ibmr;
+
+error:
+	ib_umem_release(umem);
+	return ERR_PTR(err);
+}
+
+static int unreg_umr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
+{
+	struct umr_common *umrc = &dev->umrc;
+	struct ib_send_wr wr, *bad;
+	int err;
+
+	memset(&wr, 0, sizeof(wr));
+	wr.wr_id = (u64)(unsigned long)mr;
+	prep_umr_unreg_wqe(dev, &wr, mr->mmr.key);
+
+	down(&umrc->sem);
+	init_completion(&mr->done);
+	err = ib_post_send(umrc->qp, &wr, &bad);
+	if (err) {
+		up(&umrc->sem);
+		mlx5_ib_dbg(dev, "err %d\n", err);
+		goto error;
+	}
+	wait_for_completion(&mr->done);
+	up(&umrc->sem);
+	if (mr->status != IB_WC_SUCCESS) {
+		mlx5_ib_warn(dev, "unreg umr failed\n");
+		err = -EFAULT;
+		goto error;
+	}
+	return 0;
+
+error:
+	return err;
+}
+
+int mlx5_ib_dereg_mr(struct ib_mr *ibmr)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibmr->device);
+	struct mlx5_ib_mr *mr = to_mmr(ibmr);
+	struct ib_umem *umem = mr->umem;
+	int npages = mr->npages;
+	int umred = mr->umred;
+	int err;
+
+	if (!umred) {
+		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
+		if (err) {
+			mlx5_ib_warn(dev, "failed to destroy mkey 0x%x (%d)\n",
+				     mr->mmr.key, err);
+			return err;
+		}
+	} else {
+		err = unreg_umr(dev, mr);
+		if (err) {
+			mlx5_ib_warn(dev, "failed unregister\n");
+			return err;
+		}
+		free_cached_mr(dev, mr);
+	}
+
+	if (umem) {
+		ib_umem_release(umem);
+		spin_lock(&dev->mr_lock);
+		dev->mdev.priv.reg_pages -= npages;
+		spin_unlock(&dev->mr_lock);
+	}
+
+	if (!umred)
+		kfree(mr);
+
+	return 0;
+}
+
+struct ib_mr *mlx5_ib_alloc_fast_reg_mr(struct ib_pd *pd,
+					int max_page_list_len)
+{
+	struct mlx5_ib_dev *dev = to_mdev(pd->device);
+	struct mlx5_create_mkey_mbox_in *in;
+	struct mlx5_ib_mr *mr;
+	int err;
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	in = kzalloc(sizeof(*in), GFP_KERNEL);
+	if (!in) {
+		err = -ENOMEM;
+		goto err_free;
+	}
+
+	in->seg.status = 1 << 6; /* free */
+	in->seg.xlt_oct_size = cpu_to_be32((max_page_list_len + 1) / 2);
+	in->seg.qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
+	in->seg.flags = MLX5_PERM_UMR_EN | MLX5_ACCESS_MODE_MTT;
+	in->seg.flags_pd = cpu_to_be32(to_mpd(pd)->pdn);
+	/*
+	 * TBD not needed - issue 197292 */
+	in->seg.log2_page_size = PAGE_SHIFT;
+
+	err = mlx5_core_create_mkey(&dev->mdev, &mr->mmr, in, sizeof(*in));
+	kfree(in);
+	if (err)
+		goto err_free;
+
+	mr->ibmr.lkey = mr->mmr.key;
+	mr->ibmr.rkey = mr->mmr.key;
+	mr->umem = NULL;
+
+	return &mr->ibmr;
+
+err_free:
+	kfree(mr);
+	return ERR_PTR(err);
+}
+
+struct ib_fast_reg_page_list *mlx5_ib_alloc_fast_reg_page_list(struct ib_device *ibdev,
+							       int page_list_len)
+{
+	struct mlx5_ib_fast_reg_page_list *mfrpl;
+	int size = page_list_len * sizeof(u64);
+
+	mfrpl = kmalloc(sizeof(*mfrpl), GFP_KERNEL);
+	if (!mfrpl)
+		return ERR_PTR(-ENOMEM);
+
+	mfrpl->ibfrpl.page_list = kmalloc(size, GFP_KERNEL);
+	if (!mfrpl->ibfrpl.page_list)
+		goto err_free;
+
+	mfrpl->mapped_page_list = dma_alloc_coherent(ibdev->dma_device,
+						     size, &mfrpl->map,
+						     GFP_KERNEL);
+	if (!mfrpl->mapped_page_list)
+		goto err_free;
+
+	WARN_ON(mfrpl->map & 0x3f);
+
+	return &mfrpl->ibfrpl;
+
+err_free:
+	kfree(mfrpl->ibfrpl.page_list);
+	kfree(mfrpl);
+	return ERR_PTR(-ENOMEM);
+}
+
+void mlx5_ib_free_fast_reg_page_list(struct ib_fast_reg_page_list *page_list)
+{
+	struct mlx5_ib_fast_reg_page_list *mfrpl = to_mfrpl(page_list);
+	struct mlx5_ib_dev *dev = to_mdev(page_list->device);
+	int size = page_list->max_page_list_len * sizeof(u64);
+
+	dma_free_coherent(&dev->mdev.pdev->dev, size, mfrpl->mapped_page_list,
+			  mfrpl->map);
+	kfree(mfrpl->ibfrpl.page_list);
+	kfree(mfrpl);
+}
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
