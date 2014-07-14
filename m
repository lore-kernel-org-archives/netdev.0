From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 4/4] cxgb4/iw_cxgb4: work request logging feature
Date: Mon, 14 Jul 2014 21:34:54 +0530
Message-ID: <1405353894-17495-5-git-send-email-hariprasad@chelsio.com>
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

This commit enhances the iwarp driver to optionally keep a log of rdma
work request timining data for kernel mode QPs.  If iw_cxgb4 module option
c4iw_wr_log is set to non-zero, each work request is tracked and timing
data maintained in a rolling log that is 4096 entries deep by default.
Module option c4iw_wr_log_size_order allows specifing a log2 size to use
instead of the default order of 12 (4096 entries). Both module options
are read-only and must be passed in at module load time to set them. IE:

modprobe iw_cxgb4 c4iw_wr_log=1 c4iw_wr_log_size_order=10

The timing data is viewable via the iw_cxgb4 debugfs file "wr_log".
Writing anything to this file will clear all the timing data.
Data tracked includes:

- The host time when the work request was posted, just before ringing
the doorbell.  The host time when the completion was polled by the
application.  This is also the time the log entry is created.  The delta
of these two times is the amount of time took processing the work request.

- The qid of the EQ used to post the work request.

- The work request opcode.

- The cqe wr_id field.  For sq completions requests this is the swsqe
index.  For recv completions this is the MSN of the ingress SEND.
This value can be used to match log entries from this log with firmware
flowc event entries.

- The sge timestamp value just before ringing the doorbell when
posting,  the sge timestamp value just after polling the completion,
and CQE.timestamp field from the completion itself.  With these three
timestamps we can track the latency from post to poll, and the amount
of time the completion resided in the CQ before being reaped by the
application.  With debug firmware, the sge timestamp is also logged by
firmware in its flowc history so that we can compute the latency from
posting the work request until the firmware sees it.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cq.c                |    4 +
 drivers/infiniband/hw/cxgb4/device.c            |  137 +++++++++++++++++++++++
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   17 +++
 drivers/infiniband/hw/cxgb4/qp.c                |   12 ++
 drivers/infiniband/hw/cxgb4/t4.h                |    4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   14 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    6 +
 8 files changed, 196 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index f04a838..de9bcf2 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -633,11 +633,15 @@ proc_cqe:
 		wq->sq.cidx = (uint16_t)idx;
 		PDBG("%s completing sq idx %u\n", __func__, wq->sq.cidx);
 		*cookie = wq->sq.sw_sq[wq->sq.cidx].wr_id;
+		if (c4iw_wr_log)
+			c4iw_log_wr_stats(wq, hw_cqe);
 		t4_sq_consume(wq);
 	} else {
 		PDBG("%s completing rq idx %u\n", __func__, wq->rq.cidx);
 		*cookie = wq->rq.sw_rq[wq->rq.cidx].wr_id;
 		BUG_ON(t4_rq_empty(wq));
+		if (c4iw_wr_log)
+			c4iw_log_wr_stats(wq, hw_cqe);
 		t4_rq_consume(wq);
 		goto skip_cqe;
 	}
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 8386678..df1f1b5 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -55,6 +55,15 @@ module_param(allow_db_coalescing_on_t5, int, 0644);
 MODULE_PARM_DESC(allow_db_coalescing_on_t5,
 		 "Allow DB Coalescing on T5 (default = 0)");
 
+int c4iw_wr_log = 0;
+module_param(c4iw_wr_log, int, 0444);
+MODULE_PARM_DESC(c4iw_wr_log, "Enables logging of work request timing data.");
+
+int c4iw_wr_log_size_order = 12;
+module_param(c4iw_wr_log_size_order, int, 0444);
+MODULE_PARM_DESC(c4iw_wr_log_size_order,
+		 "Number of entries (log2) in the work request timing log.");
+
 struct uld_ctx {
 	struct list_head entry;
 	struct cxgb4_lld_info lldi;
@@ -103,6 +112,117 @@ static ssize_t debugfs_read(struct file *file, char __user *buf, size_t count,
 	return simple_read_from_buffer(buf, count, ppos, d->buf, d->pos);
 }
 
+void c4iw_log_wr_stats(struct t4_wq *wq, struct t4_cqe *cqe)
+{
+	struct wr_log_entry le;
+	int idx;
+
+	if (!wq->rdev->wr_log)
+		return;
+
+	idx = (atomic_inc_return(&wq->rdev->wr_log_idx) - 1) &
+		(wq->rdev->wr_log_size - 1);
+	le.poll_sge_ts = cxgb4_read_sge_timestamp(wq->rdev->lldi.ports[0]);
+	getnstimeofday(&le.poll_host_ts);
+	le.valid = 1;
+	le.cqe_sge_ts = CQE_TS(cqe);
+	if (SQ_TYPE(cqe)) {
+		le.qid = wq->sq.qid;
+		le.opcode = CQE_OPCODE(cqe);
+		le.post_host_ts = wq->sq.sw_sq[wq->sq.cidx].host_ts;
+		le.post_sge_ts = wq->sq.sw_sq[wq->sq.cidx].sge_ts;
+		le.wr_id = CQE_WRID_SQ_IDX(cqe);
+	} else {
+		le.qid = wq->rq.qid;
+		le.opcode = FW_RI_RECEIVE;
+		le.post_host_ts = wq->rq.sw_rq[wq->rq.cidx].host_ts;
+		le.post_sge_ts = wq->rq.sw_rq[wq->rq.cidx].sge_ts;
+		le.wr_id = CQE_WRID_MSN(cqe);
+	}
+	wq->rdev->wr_log[idx] = le;
+}
+
+static int wr_log_show(struct seq_file *seq, void *v)
+{
+	struct c4iw_dev *dev = seq->private;
+	struct timespec prev_ts = {0, 0};
+	struct wr_log_entry *lep;
+	int prev_ts_set = 0;
+	int idx, end;
+
+#define ts2ns(ts) ((ts) * dev->rdev.lldi.cclk_ps / 1000)
+
+	idx = atomic_read(&dev->rdev.wr_log_idx) &
+		(dev->rdev.wr_log_size - 1);
+	end = idx - 1;
+	if (end < 0)
+		end = dev->rdev.wr_log_size - 1;
+	lep = &dev->rdev.wr_log[idx];
+	while (idx != end) {
+		if (lep->valid) {
+			if (!prev_ts_set) {
+				prev_ts_set = 1;
+				prev_ts = lep->poll_host_ts;
+			}
+			seq_printf(seq, "%04u: sec %lu nsec %lu qid %u opcode "
+				   "%u %s 0x%x host_wr_delta sec %lu nsec %lu "
+				   "post_sge_ts 0x%llx cqe_sge_ts 0x%llx "
+				   "poll_sge_ts 0x%llx post_poll_delta_ns %llu "
+				   "cqe_poll_delta_ns %llu\n",
+				   idx,
+				   timespec_sub(lep->poll_host_ts,
+						prev_ts).tv_sec,
+				   timespec_sub(lep->poll_host_ts,
+						prev_ts).tv_nsec,
+				   lep->qid, lep->opcode,
+				   lep->opcode == FW_RI_RECEIVE ?
+							"msn" : "wrid",
+				   lep->wr_id,
+				   timespec_sub(lep->poll_host_ts,
+						lep->post_host_ts).tv_sec,
+				   timespec_sub(lep->poll_host_ts,
+						lep->post_host_ts).tv_nsec,
+				   lep->post_sge_ts, lep->cqe_sge_ts,
+				   lep->poll_sge_ts,
+				   ts2ns(lep->poll_sge_ts - lep->post_sge_ts),
+				   ts2ns(lep->poll_sge_ts - lep->cqe_sge_ts));
+			prev_ts = lep->poll_host_ts;
+		}
+		idx++;
+		if (idx > (dev->rdev.wr_log_size - 1))
+			idx = 0;
+		lep = &dev->rdev.wr_log[idx];
+	}
+#undef ts2ns
+	return 0;
+}
+
+static int wr_log_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, wr_log_show, inode->i_private);
+}
+
+static ssize_t wr_log_clear(struct file *file, const char __user *buf,
+			    size_t count, loff_t *pos)
+{
+	struct c4iw_dev *dev = ((struct seq_file *)file->private_data)->private;
+	int i;
+
+	if (dev->rdev.wr_log)
+		for (i = 0; i < dev->rdev.wr_log_size; i++)
+			dev->rdev.wr_log[i].valid = 0;
+	return count;
+}
+
+static const struct file_operations wr_log_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = wr_log_open,
+	.release = single_release,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.write   = wr_log_clear,
+};
+
 static int dump_qp(int id, void *p, void *data)
 {
 	struct c4iw_qp *qp = p;
@@ -604,6 +724,12 @@ static int setup_debugfs(struct c4iw_dev *devp)
 	if (de && de->d_inode)
 		de->d_inode->i_size = 4096;
 
+	if (c4iw_wr_log) {
+		de = debugfs_create_file("wr_log", S_IWUSR, devp->debugfs_root,
+					 (void *)devp, &wr_log_debugfs_fops);
+		if (de && de->d_inode)
+			de->d_inode->i_size = 4096;
+	}
 	return 0;
 }
 
@@ -717,6 +843,16 @@ static int c4iw_rdev_open(struct c4iw_rdev *rdev)
 		pr_err(MOD "error allocating status page\n");
 		goto err4;
 	}
+	if (c4iw_wr_log) {
+		rdev->wr_log = kzalloc((1 << c4iw_wr_log_size_order) *
+				       sizeof(*rdev->wr_log), GFP_KERNEL);
+		if (rdev->wr_log) {
+			rdev->wr_log_size = 1 << c4iw_wr_log_size_order;
+			atomic_set(&rdev->wr_log_idx, 0);
+		} else {
+			pr_err(MOD "error allocating wr_log. Logging disabled\n");
+		}
+	}
 	return 0;
 err4:
 	c4iw_rqtpool_destroy(rdev);
@@ -730,6 +866,7 @@ err1:
 
 static void c4iw_rdev_close(struct c4iw_rdev *rdev)
 {
+	kfree(rdev->wr_log);
 	free_page((unsigned long)rdev->status_page);
 	c4iw_pblpool_destroy(rdev);
 	c4iw_rqtpool_destroy(rdev);
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 75541cb..69f047c 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -150,6 +150,18 @@ struct c4iw_hw_queue {
 	int t4_stat_len;
 };
 
+struct wr_log_entry {
+	struct timespec post_host_ts;
+	struct timespec poll_host_ts;
+	u64 post_sge_ts;
+	u64 cqe_sge_ts;
+	u64 poll_sge_ts;
+	u16 qid;
+	u16 wr_id;
+	u8 opcode;
+	u8 valid;
+};
+
 struct c4iw_rdev {
 	struct c4iw_resource resource;
 	unsigned long qpshift;
@@ -169,6 +181,9 @@ struct c4iw_rdev {
 	struct c4iw_stats stats;
 	struct c4iw_hw_queue hw_queue;
 	struct t4_dev_status_page *status_page;
+	atomic_t wr_log_idx;
+	struct wr_log_entry *wr_log;
+	int wr_log_size;
 };
 
 static inline int c4iw_fatal_error(struct c4iw_rdev *rdev)
@@ -1011,6 +1026,8 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe);
 
 extern struct cxgb4_client t4c_client;
 extern c4iw_handler_func c4iw_handlers[NUM_CPL_CMDS];
+extern void c4iw_log_wr_stats(struct t4_wq *wq, struct t4_cqe *cqe);
+extern int c4iw_wr_log;
 extern int db_fc_threshold;
 extern int db_coalescing_threshold;
 extern int use_dsgl;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 0de3cf6..fd66bd9 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -823,6 +823,11 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				  qhp->sq_sig_all;
 		swsqe->flushed = 0;
 		swsqe->wr_id = wr->wr_id;
+		if (c4iw_wr_log) {
+			swsqe->sge_ts = cxgb4_read_sge_timestamp(
+					qhp->rhp->rdev.lldi.ports[0]);
+			getnstimeofday(&swsqe->host_ts);
+		}
 
 		init_wr_hdr(wqe, qhp->wq.sq.pidx, fw_opcode, fw_flags, len16);
 
@@ -886,6 +891,13 @@ int c4iw_post_receive(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 		}
 
 		qhp->wq.rq.sw_rq[qhp->wq.rq.pidx].wr_id = wr->wr_id;
+		if (c4iw_wr_log) {
+			qhp->wq.rq.sw_rq[qhp->wq.rq.pidx].sge_ts =
+				cxgb4_read_sge_timestamp(
+						qhp->rhp->rdev.lldi.ports[0]);
+			getnstimeofday(
+				&qhp->wq.rq.sw_rq[qhp->wq.rq.pidx].host_ts);
+		}
 
 		wqe->recv.opcode = FW_RI_RECV_WR;
 		wqe->recv.r1 = 0;
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index dd45186..c9f7034 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -269,6 +269,8 @@ struct t4_swsqe {
 	int			signaled;
 	u16			idx;
 	int                     flushed;
+	struct timespec         host_ts;
+	u64                     sge_ts;
 };
 
 static inline pgprot_t t4_pgprot_wc(pgprot_t prot)
@@ -306,6 +308,8 @@ struct t4_sq {
 
 struct t4_swrqe {
 	u64 wr_id;
+	struct timespec host_ts;
+	u64 sge_ts;
 };
 
 struct t4_rq {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ba7d13d..9c7e4f0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3898,6 +3898,19 @@ err:
 }
 EXPORT_SYMBOL(cxgb4_read_tpte);
 
+u64 cxgb4_read_sge_timestamp(struct net_device *dev)
+{
+	u32 hi, lo;
+	struct adapter *adap;
+
+	adap = netdev2adap(dev);
+	lo = t4_read_reg(adap, SGE_TIMESTAMP_LO);
+	hi = GET_TSVAL(t4_read_reg(adap, SGE_TIMESTAMP_HI));
+
+	return ((u64)hi << 32) | (u64)lo;
+}
+EXPORT_SYMBOL(cxgb4_read_sge_timestamp);
+
 static struct pci_driver cxgb4_driver;
 
 static void check_neigh_update(struct neighbour *neigh)
@@ -4161,6 +4174,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.wr_cred = adap->params.ofldq_wr_cred;
 	lli.adapter_type = adap->params.chip;
 	lli.iscsi_iolen = MAXRXDATA_GET(t4_read_reg(adap, TP_PARA_REG2));
+	lli.cclk_ps = 1000000000 / adap->params.vpd.cclk;
 	lli.udb_density = 1 << QUEUESPERPAGEPF0_GET(
 			t4_read_reg(adap, SGE_EGRESS_QUEUES_PER_PAGE_PF) >>
 			(adap->fn * 4));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index c7170d6..79a84de 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -243,6 +243,7 @@ struct cxgb4_lld_info {
 	unsigned char fw_api_ver;            /* FW API version */
 	unsigned int fw_vers;                /* FW version */
 	unsigned int iscsi_iolen;            /* iSCSI max I/O length */
+	unsigned int cclk_ps;                /* Core clock period in psec */
 	unsigned short udb_density;          /* # of user DB/page */
 	unsigned short ucq_density;          /* # of user CQs/page */
 	unsigned short filt_mode;            /* filter optional components */
@@ -297,5 +298,6 @@ int cxgb4_flush_eq_cache(struct net_device *dev);
 void cxgb4_disable_db_coalescing(struct net_device *dev);
 void cxgb4_enable_db_coalescing(struct net_device *dev);
 int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte);
+u64 cxgb4_read_sge_timestamp(struct net_device *dev);
 
 #endif  /* !__CXGB4_OFLD_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index ae77764..3b244ab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -251,6 +251,12 @@
 #define V_NOCOALESCE(x) ((x) << S_NOCOALESCE)
 #define F_NOCOALESCE    V_NOCOALESCE(1U)
 
+#define SGE_TIMESTAMP_LO 0x1098
+#define SGE_TIMESTAMP_HI 0x109c
+#define S_TSVAL    0
+#define M_TSVAL    0xfffffffU
+#define GET_TSVAL(x) (((x) >> S_TSVAL) & M_TSVAL)
+
 #define SGE_TIMER_VALUE_0_AND_1 0x10b8
 #define  TIMERVALUE0_MASK   0xffff0000U
 #define  TIMERVALUE0_SHIFT  16
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
