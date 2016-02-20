From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [net-next][PATCH 13/13] RDS: IB: Support Fastreg MR (FRMR) memory registration mode
Date: Sat, 20 Feb 2016 03:30:04 -0800
Message-ID: <1455967804-27644-14-git-send-email-santosh.shilimkar@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455967804-27644-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Fastreg MR(FRMR) is another method with which one can
register memory to HCA. Some of the newer HCAs supports only fastreg
mr mode, so we need to add support for it to RDS to have RDS functional
on them.

Some of the older HCAs support both FMR and FRMR modes. So to try out
FRMR on older HCAs, one can use module parameter 'prefer_frmr'

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
RDS IB RDMA performance with FRMR is not yet as good as FMR and I do have
some patches in progress to address that. But they are not ready for 4.6
so I left them out of this series. 

 net/rds/Makefile  |   2 +-
 net/rds/ib.h      |   1 +
 net/rds/ib_cm.c   |   7 +-
 net/rds/ib_frmr.c | 376 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/ib_mr.h   |  24 ++++
 net/rds/ib_rdma.c |  17 ++-
 6 files changed, 422 insertions(+), 5 deletions(-)
 create mode 100644 net/rds/ib_frmr.c

diff --git a/net/rds/Makefile b/net/rds/Makefile
index bcf5591..0e72bec 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -6,7 +6,7 @@ rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
 obj-$(CONFIG_RDS_RDMA) += rds_rdma.o
 rds_rdma-y :=	rdma_transport.o \
 			ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
-			ib_sysctl.o ib_rdma.o ib_fmr.o
+			ib_sysctl.o ib_rdma.o ib_fmr.o ib_frmr.o
 
 
 obj-$(CONFIG_RDS_TCP) += rds_tcp.o
diff --git a/net/rds/ib.h b/net/rds/ib.h
index eeb0d6c..627fb79 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -349,6 +349,7 @@ int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr);
 void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
 void rds_ib_remove_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
 void rds_ib_destroy_nodev_conns(void);
+void rds_ib_mr_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc);
 
 /* ib_recv.c */
 int rds_ib_recv_init(void);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 83f4673..8764970 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -249,7 +249,12 @@ static void poll_scq(struct rds_ib_connection *ic, struct ib_cq *cq,
 				 (unsigned long long)wc->wr_id, wc->status,
 				 wc->byte_len, be32_to_cpu(wc->ex.imm_data));
 
-			rds_ib_send_cqe_handler(ic, wc);
+			if (wc->wr_id <= ic->i_send_ring.w_nr ||
+			    wc->wr_id == RDS_IB_ACK_WR_ID)
+				rds_ib_send_cqe_handler(ic, wc);
+			else
+				rds_ib_mr_cqe_handler(ic, wc);
+
 		}
 	}
 }
diff --git a/net/rds/ib_frmr.c b/net/rds/ib_frmr.c
new file mode 100644
index 0000000..a86de13
--- /dev/null
+++ b/net/rds/ib_frmr.c
@@ -0,0 +1,376 @@
+/*
+ * Copyright (c) 2016 Oracle.  All rights reserved.
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
+#include "ib_mr.h"
+
+static struct rds_ib_mr *rds_ib_alloc_frmr(struct rds_ib_device *rds_ibdev,
+					   int npages)
+{
+	struct rds_ib_mr_pool *pool;
+	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_frmr *frmr;
+	int err = 0;
+
+	if (npages <= RDS_MR_8K_MSG_SIZE)
+		pool = rds_ibdev->mr_8k_pool;
+	else
+		pool = rds_ibdev->mr_1m_pool;
+
+	ibmr = rds_ib_try_reuse_ibmr(pool);
+	if (ibmr)
+		return ibmr;
+
+	ibmr = kzalloc_node(sizeof(*ibmr), GFP_KERNEL,
+			    rdsibdev_to_node(rds_ibdev));
+	if (!ibmr) {
+		err = -ENOMEM;
+		goto out_no_cigar;
+	}
+
+	frmr = &ibmr->u.frmr;
+	frmr->mr = ib_alloc_mr(rds_ibdev->pd, IB_MR_TYPE_MEM_REG,
+			 pool->fmr_attr.max_pages);
+	if (IS_ERR(frmr->mr)) {
+		pr_warn("RDS/IB: %s failed to allocate MR", __func__);
+		goto out_no_cigar;
+	}
+
+	ibmr->pool = pool;
+	if (pool->pool_type == RDS_IB_MR_8K_POOL)
+		rds_ib_stats_inc(s_ib_rdma_mr_8k_alloc);
+	else
+		rds_ib_stats_inc(s_ib_rdma_mr_1m_alloc);
+
+	if (atomic_read(&pool->item_count) > pool->max_items_soft)
+		pool->max_items_soft = pool->max_items;
+
+	frmr->fr_state = FRMR_IS_FREE;
+	return ibmr;
+
+out_no_cigar:
+	kfree(ibmr);
+	atomic_dec(&pool->item_count);
+	return ERR_PTR(err);
+}
+
+static void rds_ib_free_frmr(struct rds_ib_mr *ibmr, bool drop)
+{
+	struct rds_ib_mr_pool *pool = ibmr->pool;
+
+	if (drop)
+		llist_add(&ibmr->llnode, &pool->drop_list);
+	else
+		llist_add(&ibmr->llnode, &pool->free_list);
+	atomic_add(ibmr->sg_len, &pool->free_pinned);
+	atomic_inc(&pool->dirty_count);
+
+	/* If we've pinned too many pages, request a flush */
+	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned ||
+	    atomic_read(&pool->dirty_count) >= pool->max_items / 5)
+		queue_delayed_work(rds_ib_mr_wq, &pool->flush_worker, 10);
+}
+
+static int rds_ib_post_reg_frmr(struct rds_ib_mr *ibmr)
+{
+	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
+	struct ib_send_wr *failed_wr;
+	struct ib_reg_wr reg_wr;
+	int ret;
+
+	while (atomic_dec_return(&ibmr->ic->i_fastreg_wrs) <= 0) {
+		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+		cpu_relax();
+	}
+
+	ret = ib_map_mr_sg_zbva(frmr->mr, ibmr->sg, ibmr->sg_len, PAGE_SIZE);
+	if (unlikely(ret != ibmr->sg_len))
+		return ret < 0 ? ret : -EINVAL;
+
+	/* Perform a WR for the fast_reg_mr. Each individual page
+	 * in the sg list is added to the fast reg page list and placed
+	 * inside the fast_reg_mr WR.  The key used is a rolling 8bit
+	 * counter, which should guarantee uniqueness.
+	 */
+	ib_update_fast_reg_key(frmr->mr, ibmr->remap_count++);
+	frmr->fr_state = FRMR_IS_INUSE;
+
+	memset(&reg_wr, 0, sizeof(reg_wr));
+	reg_wr.wr.wr_id = (unsigned long)(void *)ibmr;
+	reg_wr.wr.opcode = IB_WR_REG_MR;
+	reg_wr.wr.num_sge = 0;
+	reg_wr.mr = frmr->mr;
+	reg_wr.key = frmr->mr->rkey;
+	reg_wr.access = IB_ACCESS_LOCAL_WRITE |
+			IB_ACCESS_REMOTE_READ |
+			IB_ACCESS_REMOTE_WRITE;
+	reg_wr.wr.send_flags = IB_SEND_SIGNALED;
+
+	failed_wr = &reg_wr.wr;
+	ret = ib_post_send(ibmr->ic->i_cm_id->qp, &reg_wr.wr, &failed_wr);
+	WARN_ON(failed_wr != &reg_wr.wr);
+	if (unlikely(ret)) {
+		/* Failure here can be because of -ENOMEM as well */
+		frmr->fr_state = FRMR_IS_STALE;
+		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+		if (printk_ratelimit())
+			pr_warn("RDS/IB: %s returned error(%d)\n",
+				__func__, ret);
+	}
+	return ret;
+}
+
+static int rds_ib_map_frmr(struct rds_ib_device *rds_ibdev,
+			   struct rds_ib_mr_pool *pool,
+			   struct rds_ib_mr *ibmr,
+			   struct scatterlist *sg, unsigned int sg_len)
+{
+	struct ib_device *dev = rds_ibdev->dev;
+	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
+	int i;
+	u32 len;
+	int ret = 0;
+
+	/* We want to teardown old ibmr values here and fill it up with
+	 * new sg values
+	 */
+	rds_ib_teardown_mr(ibmr);
+
+	ibmr->sg = sg;
+	ibmr->sg_len = sg_len;
+	ibmr->sg_dma_len = 0;
+	frmr->sg_byte_len = 0;
+	WARN_ON(ibmr->sg_dma_len);
+	ibmr->sg_dma_len = ib_dma_map_sg(dev, ibmr->sg, ibmr->sg_len,
+					 DMA_BIDIRECTIONAL);
+	if (unlikely(!ibmr->sg_dma_len)) {
+		pr_warn("RDS/IB: %s failed!\n", __func__);
+		return -EBUSY;
+	}
+
+	frmr->sg_byte_len = 0;
+	frmr->dma_npages = 0;
+	len = 0;
+
+	ret = -EINVAL;
+	for (i = 0; i < ibmr->sg_dma_len; ++i) {
+		unsigned int dma_len = ib_sg_dma_len(dev, &ibmr->sg[i]);
+		u64 dma_addr = ib_sg_dma_address(dev, &ibmr->sg[i]);
+
+		frmr->sg_byte_len += dma_len;
+		if (dma_addr & ~PAGE_MASK) {
+			if (i > 0)
+				goto out_unmap;
+			else
+				++frmr->dma_npages;
+		}
+
+		if ((dma_addr + dma_len) & ~PAGE_MASK) {
+			if (i < ibmr->sg_dma_len - 1)
+				goto out_unmap;
+			else
+				++frmr->dma_npages;
+		}
+
+		len += dma_len;
+	}
+	frmr->dma_npages += len >> PAGE_SHIFT;
+
+	if (frmr->dma_npages > ibmr->pool->fmr_attr.max_pages) {
+		ret = -EMSGSIZE;
+		goto out_unmap;
+	}
+
+	ret = rds_ib_post_reg_frmr(ibmr);
+	if (ret)
+		goto out_unmap;
+
+	if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
+		rds_ib_stats_inc(s_ib_rdma_mr_8k_used);
+	else
+		rds_ib_stats_inc(s_ib_rdma_mr_1m_used);
+
+	return ret;
+
+out_unmap:
+	ib_dma_unmap_sg(rds_ibdev->dev, ibmr->sg, ibmr->sg_len,
+			DMA_BIDIRECTIONAL);
+	ibmr->sg_dma_len = 0;
+	return ret;
+}
+
+static int rds_ib_post_inv(struct rds_ib_mr *ibmr)
+{
+	struct ib_send_wr *s_wr, *failed_wr;
+	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
+	struct rdma_cm_id *i_cm_id = ibmr->ic->i_cm_id;
+	int ret = -EINVAL;
+
+	if (!i_cm_id || !i_cm_id->qp || !frmr->mr)
+		goto out;
+
+	if (frmr->fr_state != FRMR_IS_INUSE)
+		goto out;
+
+	while (atomic_dec_return(&ibmr->ic->i_fastreg_wrs) <= 0) {
+		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+		cpu_relax();
+	}
+
+	frmr->fr_inv = true;
+	s_wr = &frmr->fr_wr;
+
+	memset(s_wr, 0, sizeof(*s_wr));
+	s_wr->wr_id = (unsigned long)(void *)ibmr;
+	s_wr->opcode = IB_WR_LOCAL_INV;
+	s_wr->ex.invalidate_rkey = frmr->mr->rkey;
+	s_wr->send_flags = IB_SEND_SIGNALED;
+
+	failed_wr = s_wr;
+	ret = ib_post_send(i_cm_id->qp, s_wr, &failed_wr);
+	WARN_ON(failed_wr != s_wr);
+	if (unlikely(ret)) {
+		frmr->fr_state = FRMR_IS_STALE;
+		frmr->fr_inv = false;
+		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+		pr_err("RDS/IB: %s returned error(%d)\n", __func__, ret);
+		goto out;
+	}
+out:
+	return ret;
+}
+
+void rds_ib_mr_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc)
+{
+	struct rds_ib_mr *ibmr = (void *)wc->wr_id;
+	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
+
+	if (wc->status != IB_WC_SUCCESS) {
+		frmr->fr_state = FRMR_IS_STALE;
+		if (rds_conn_up(ic->conn))
+			rds_ib_conn_error(ic->conn,
+					  "frmr completion <%pI4,%pI4> status %u(%s), vendor_err 0x%x, disconnecting and reconnecting\n",
+					  &ic->conn->c_laddr,
+					  &ic->conn->c_faddr,
+					  wc->status,
+					  ib_wc_status_msg(wc->status),
+					  wc->vendor_err);
+	}
+
+	if (frmr->fr_inv) {
+		frmr->fr_state = FRMR_IS_FREE;
+		frmr->fr_inv = false;
+	}
+
+	atomic_inc(&ic->i_fastreg_wrs);
+}
+
+void rds_ib_unreg_frmr(struct list_head *list, unsigned int *nfreed,
+		       unsigned long *unpinned, unsigned int goal)
+{
+	struct rds_ib_mr *ibmr, *next;
+	struct rds_ib_frmr *frmr;
+	int ret = 0;
+	unsigned int freed = *nfreed;
+
+	/* String all ib_mr's onto one list and hand them to ib_unmap_fmr */
+	list_for_each_entry(ibmr, list, unmap_list) {
+		if (ibmr->sg_dma_len)
+			ret |= rds_ib_post_inv(ibmr);
+	}
+	if (ret)
+		pr_warn("RDS/IB: %s failed (err=%d)\n", __func__, ret);
+
+	/* Now we can destroy the DMA mapping and unpin any pages */
+	list_for_each_entry_safe(ibmr, next, list, unmap_list) {
+		*unpinned += ibmr->sg_len;
+		frmr = &ibmr->u.frmr;
+		__rds_ib_teardown_mr(ibmr);
+		if (freed < goal || frmr->fr_state == FRMR_IS_STALE) {
+			/* Don't de-allocate if the MR is not free yet */
+			if (frmr->fr_state == FRMR_IS_INUSE)
+				continue;
+
+			if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
+				rds_ib_stats_inc(s_ib_rdma_mr_8k_free);
+			else
+				rds_ib_stats_inc(s_ib_rdma_mr_1m_free);
+			list_del(&ibmr->unmap_list);
+			if (frmr->mr)
+				ib_dereg_mr(frmr->mr);
+			kfree(ibmr);
+			freed++;
+		}
+	}
+	*nfreed = freed;
+}
+
+struct rds_ib_mr *rds_ib_reg_frmr(struct rds_ib_device *rds_ibdev,
+				  struct rds_ib_connection *ic,
+				  struct scatterlist *sg,
+				  unsigned long nents, u32 *key)
+{
+	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_frmr *frmr;
+	int ret;
+
+	do {
+		if (ibmr)
+			rds_ib_free_frmr(ibmr, true);
+		ibmr = rds_ib_alloc_frmr(rds_ibdev, nents);
+		if (IS_ERR(ibmr))
+			return ibmr;
+		frmr = &ibmr->u.frmr;
+	} while (frmr->fr_state != FRMR_IS_FREE);
+
+	ibmr->ic = ic;
+	ibmr->device = rds_ibdev;
+	ret = rds_ib_map_frmr(rds_ibdev, ibmr->pool, ibmr, sg, nents);
+	if (ret == 0) {
+		*key = frmr->mr->rkey;
+	} else {
+		rds_ib_free_frmr(ibmr, false);
+		ibmr = ERR_PTR(ret);
+	}
+
+	return ibmr;
+}
+
+void rds_ib_free_frmr_list(struct rds_ib_mr *ibmr)
+{
+	struct rds_ib_mr_pool *pool = ibmr->pool;
+	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
+
+	if (frmr->fr_state == FRMR_IS_STALE)
+		llist_add(&ibmr->llnode, &pool->drop_list);
+	else
+		llist_add(&ibmr->llnode, &pool->free_list);
+}
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 2f9b9c3..1c754f4 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -48,6 +48,21 @@ struct rds_ib_fmr {
 	u64			*dma;
 };
 
+enum rds_ib_fr_state {
+	FRMR_IS_FREE,	/* mr invalidated & ready for use */
+	FRMR_IS_INUSE,	/* mr is in use or used & can be invalidated */
+	FRMR_IS_STALE,	/* Stale MR and needs to be dropped  */
+};
+
+struct rds_ib_frmr {
+	struct ib_mr		*mr;
+	enum rds_ib_fr_state	fr_state;
+	bool			fr_inv;
+	struct ib_send_wr	fr_wr;
+	unsigned int		dma_npages;
+	unsigned int		sg_byte_len;
+};
+
 /* This is stored as mr->r_trans_private. */
 struct rds_ib_mr {
 	struct rds_ib_device		*device;
@@ -66,6 +81,7 @@ struct rds_ib_mr {
 
 	union {
 		struct rds_ib_fmr	fmr;
+		struct rds_ib_frmr	frmr;
 	} u;
 };
 
@@ -88,6 +104,7 @@ struct rds_ib_mr_pool {
 	unsigned long		max_items_soft;
 	unsigned long		max_free_pinned;
 	struct ib_fmr_attr	fmr_attr;
+	bool			use_fastreg;
 };
 
 extern struct workqueue_struct *rds_ib_mr_wq;
@@ -121,4 +138,11 @@ struct rds_ib_mr *rds_ib_try_reuse_ibmr(struct rds_ib_mr_pool *);
 void rds_ib_unreg_fmr(struct list_head *, unsigned int *,
 		      unsigned long *, unsigned int);
 void rds_ib_free_fmr_list(struct rds_ib_mr *);
+struct rds_ib_mr *rds_ib_reg_frmr(struct rds_ib_device *rds_ibdev,
+				  struct rds_ib_connection *ic,
+				  struct scatterlist *sg,
+				  unsigned long nents, u32 *key);
+void rds_ib_unreg_frmr(struct list_head *list, unsigned int *nfreed,
+		       unsigned long *unpinned, unsigned int goal);
+void rds_ib_free_frmr_list(struct rds_ib_mr *);
 #endif
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 00e9064..6e9ccbd 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -398,7 +398,10 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	if (list_empty(&unmap_list))
 		goto out;
 
-	rds_ib_unreg_fmr(&unmap_list, &nfreed, &unpinned, free_goal);
+	if (pool->use_fastreg)
+		rds_ib_unreg_frmr(&unmap_list, &nfreed, &unpinned, free_goal);
+	else
+		rds_ib_unreg_fmr(&unmap_list, &nfreed, &unpinned, free_goal);
 
 	if (!list_empty(&unmap_list)) {
 		/* we have to make sure that none of the things we're about
@@ -490,7 +493,10 @@ void rds_ib_free_mr(void *trans_private, int invalidate)
 	rdsdebug("RDS/IB: free_mr nents %u\n", ibmr->sg_len);
 
 	/* Return it to the pool's free list */
-	rds_ib_free_fmr_list(ibmr);
+	if (rds_ibdev->use_fastreg)
+		rds_ib_free_frmr_list(ibmr);
+	else
+		rds_ib_free_fmr_list(ibmr);
 
 	atomic_add(ibmr->sg_len, &pool->free_pinned);
 	atomic_inc(&pool->dirty_count);
@@ -535,6 +541,7 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 {
 	struct rds_ib_device *rds_ibdev;
 	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_connection *ic = rs->rs_conn->c_transport_data;
 	int ret;
 
 	rds_ibdev = rds_ib_get_device(rs->rs_bound_addr);
@@ -548,7 +555,10 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 		goto out;
 	}
 
-	ibmr = rds_ib_reg_fmr(rds_ibdev, sg, nents, key_ret);
+	if (rds_ibdev->use_fastreg)
+		ibmr = rds_ib_reg_frmr(rds_ibdev, ic, sg, nents, key_ret);
+	else
+		ibmr = rds_ib_reg_fmr(rds_ibdev, sg, nents, key_ret);
 	if (ibmr)
 		rds_ibdev = NULL;
 
@@ -602,6 +612,7 @@ struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev,
 	pool->fmr_attr.max_maps = rds_ibdev->fmr_max_remaps;
 	pool->fmr_attr.page_shift = PAGE_SHIFT;
 	pool->max_items_soft = rds_ibdev->max_mrs * 3 / 4;
+	pool->use_fastreg = rds_ibdev->use_fastreg;
 
 	return pool;
 }
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
