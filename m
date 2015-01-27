From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4: Added support in debugfs to dump sge_qinfo
Date: Tue, 27 Jan 2015 13:47:45 +0530
Message-ID: <1422346669-26913-2-git-send-email-hariprasad@chelsio.com>
References: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16726 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753524AbbA0IMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:13 -0500
In-Reply-To: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  211 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    4 +-
 3 files changed, 215 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 24fc162..533a691 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1029,6 +1029,8 @@ int cxgb4_t4_bar2_sge_qregs(struct adapter *adapter,
 		      u64 *pbar2_qoffset,
 		      unsigned int *pbar2_qid);
 
+unsigned int qtimer_val(const struct adapter *adap,
+			const struct sge_rspq *q);
 int t4_init_sge_params(struct adapter *adapter);
 int t4_init_tp_params(struct adapter *adap);
 int t4_filter_field_shift(const struct adapter *adap, int filter_sel);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 714cc70..eb420e1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1026,6 +1026,216 @@ static const struct file_operations rss_vf_config_debugfs_fops = {
 	.release = seq_release_private
 };
 
+static int sge_qinfo_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adap = seq->private;
+	int eth_entries = DIV_ROUND_UP(adap->sge.ethqsets, 4);
+	int toe_entries = DIV_ROUND_UP(adap->sge.ofldqsets, 4);
+	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
+	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
+	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
+	int i, r = (uintptr_t)v - 1;
+	int toe_idx = r - eth_entries;
+	int rdma_idx = toe_idx - toe_entries;
+	int ciq_idx = rdma_idx - rdma_entries;
+	int ctrl_idx =  ciq_idx - ciq_entries;
+	int fq_idx =  ctrl_idx - ctrl_entries;
+
+	if (r)
+		seq_putc(seq, '\n');
+
+#define S3(fmt_spec, s, v) \
+do { \
+	seq_printf(seq, "%-12s", s); \
+	for (i = 0; i < n; ++i) \
+		seq_printf(seq, " %16" fmt_spec, v); \
+		seq_putc(seq, '\n'); \
+} while (0)
+#define S(s, v) S3("s", s, v)
+#define T(s, v) S3("u", s, tx[i].v)
+#define R(s, v) S3("u", s, rx[i].v)
+
+	if (r < eth_entries) {
+		int base_qset = r * 4;
+		const struct sge_eth_rxq *rx = &adap->sge.ethrxq[base_qset];
+		const struct sge_eth_txq *tx = &adap->sge.ethtxq[base_qset];
+		int n = min(4, adap->sge.ethqsets - 4 * r);
+
+		S("QType:", "Ethernet");
+		S("Interface:",
+		  rx[i].rspq.netdev ? rx[i].rspq.netdev->name : "N/A");
+		T("TxQ ID:", q.cntxt_id);
+		T("TxQ size:", q.size);
+		T("TxQ inuse:", q.in_use);
+		T("TxQ CIDX:", q.cidx);
+		T("TxQ PIDX:", q.pidx);
+#ifdef CONFIG_CXGB4_DCB
+		T("DCB Prio:", dcb_prio);
+		S3("u", "DCB PGID:",
+		   (ethqset2pinfo(adap, base_qset + i)->dcb.pgid >>
+		    4*(7-tx[i].dcb_prio)) & 0xf);
+		S3("u", "DCB PFC:",
+		   (ethqset2pinfo(adap, base_qset + i)->dcb.pfcen >>
+		    1*(7-tx[i].dcb_prio)) & 0x1);
+#endif
+		R("RspQ ID:", rspq.abs_id);
+		R("RspQ size:", rspq.size);
+		R("RspQE size:", rspq.iqe_len);
+		R("RspQ CIDX:", rspq.cidx);
+		R("RspQ Gen:", rspq.gen);
+		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
+		S3("u", "Intr pktcnt:",
+		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
+		R("FL ID:", fl.cntxt_id);
+		R("FL size:", fl.size - 8);
+		R("FL pend:", fl.pend_cred);
+		R("FL avail:", fl.avail);
+		R("FL PIDX:", fl.pidx);
+		R("FL CIDX:", fl.cidx);
+	} else if (toe_idx < toe_entries) {
+		const struct sge_ofld_rxq *rx = &adap->sge.ofldrxq[toe_idx * 4];
+		const struct sge_ofld_txq *tx = &adap->sge.ofldtxq[toe_idx * 4];
+		int n = min(4, adap->sge.ofldqsets - 4 * toe_idx);
+
+		S("QType:", "TOE");
+		T("TxQ ID:", q.cntxt_id);
+		T("TxQ size:", q.size);
+		T("TxQ inuse:", q.in_use);
+		T("TxQ CIDX:", q.cidx);
+		T("TxQ PIDX:", q.pidx);
+		R("RspQ ID:", rspq.abs_id);
+		R("RspQ size:", rspq.size);
+		R("RspQE size:", rspq.iqe_len);
+		R("RspQ CIDX:", rspq.cidx);
+		R("RspQ Gen:", rspq.gen);
+		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
+		S3("u", "Intr pktcnt:",
+		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
+		R("FL ID:", fl.cntxt_id);
+		R("FL size:", fl.size - 8);
+		R("FL pend:", fl.pend_cred);
+		R("FL avail:", fl.avail);
+		R("FL PIDX:", fl.pidx);
+		R("FL CIDX:", fl.cidx);
+	} else if (rdma_idx < rdma_entries) {
+		const struct sge_ofld_rxq *rx =
+				&adap->sge.rdmarxq[rdma_idx * 4];
+		int n = min(4, adap->sge.rdmaqs - 4 * rdma_idx);
+
+		S("QType:", "RDMA-CPL");
+		R("RspQ ID:", rspq.abs_id);
+		R("RspQ size:", rspq.size);
+		R("RspQE size:", rspq.iqe_len);
+		R("RspQ CIDX:", rspq.cidx);
+		R("RspQ Gen:", rspq.gen);
+		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
+		S3("u", "Intr pktcnt:",
+		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
+		R("FL ID:", fl.cntxt_id);
+		R("FL size:", fl.size - 8);
+		R("FL pend:", fl.pend_cred);
+		R("FL avail:", fl.avail);
+		R("FL PIDX:", fl.pidx);
+		R("FL CIDX:", fl.cidx);
+	} else if (ciq_idx < ciq_entries) {
+		const struct sge_ofld_rxq *rx = &adap->sge.rdmaciq[ciq_idx * 4];
+		int n = min(4, adap->sge.rdmaciqs - 4 * ciq_idx);
+
+		S("QType:", "RDMA-CIQ");
+		R("RspQ ID:", rspq.abs_id);
+		R("RspQ size:", rspq.size);
+		R("RspQE size:", rspq.iqe_len);
+		R("RspQ CIDX:", rspq.cidx);
+		R("RspQ Gen:", rspq.gen);
+		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
+		S3("u", "Intr pktcnt:",
+		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
+	} else if (ctrl_idx < ctrl_entries) {
+		const struct sge_ctrl_txq *tx = &adap->sge.ctrlq[ctrl_idx * 4];
+		int n = min(4, adap->params.nports - 4 * ctrl_idx);
+
+		S("QType:", "Control");
+		T("TxQ ID:", q.cntxt_id);
+		T("TxQ size:", q.size);
+		T("TxQ inuse:", q.in_use);
+		T("TxQ CIDX:", q.cidx);
+		T("TxQ PIDX:", q.pidx);
+	} else if (fq_idx == 0) {
+		const struct sge_rspq *evtq = &adap->sge.fw_evtq;
+
+		seq_printf(seq, "%-12s %16s\n", "QType:", "FW event queue");
+		seq_printf(seq, "%-12s %16u\n", "RspQ ID:", evtq->abs_id);
+		seq_printf(seq, "%-12s %16u\n", "RspQ size:", evtq->size);
+		seq_printf(seq, "%-12s %16u\n", "RspQE size:", evtq->iqe_len);
+		seq_printf(seq, "%-12s %16u\n", "RspQ CIDX:", evtq->cidx);
+		seq_printf(seq, "%-12s %16u\n", "RspQ Gen:", evtq->gen);
+		seq_printf(seq, "%-12s %16u\n", "Intr delay:",
+			   qtimer_val(adap, evtq));
+		seq_printf(seq, "%-12s %16u\n", "Intr pktcnt:",
+			   adap->sge.counter_val[evtq->pktcnt_idx]);
+	}
+#undef R
+#undef T
+#undef S
+#undef S3
+return 0;
+}
+
+static int sge_queue_entries(const struct adapter *adap)
+{
+	return DIV_ROUND_UP(adap->sge.ethqsets, 4) +
+	       DIV_ROUND_UP(adap->sge.ofldqsets, 4) +
+	       DIV_ROUND_UP(adap->sge.rdmaqs, 4) +
+	       DIV_ROUND_UP(adap->sge.rdmaciqs, 4) +
+	       DIV_ROUND_UP(MAX_CTRL_QUEUES, 4) + 1;
+}
+
+static void *sge_queue_start(struct seq_file *seq, loff_t *pos)
+{
+	int entries = sge_queue_entries(seq->private);
+
+	return *pos < entries ? (void *)((uintptr_t)*pos + 1) : NULL;
+}
+
+static void sge_queue_stop(struct seq_file *seq, void *v)
+{
+}
+
+static void *sge_queue_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	int entries = sge_queue_entries(seq->private);
+
+	++*pos;
+	return *pos < entries ? (void *)((uintptr_t)*pos + 1) : NULL;
+}
+
+static const struct seq_operations sge_qinfo_seq_ops = {
+	.start = sge_queue_start,
+	.next  = sge_queue_next,
+	.stop  = sge_queue_stop,
+	.show  = sge_qinfo_show
+};
+
+static int sge_qinfo_open(struct inode *inode, struct file *file)
+{
+	int res = seq_open(file, &sge_qinfo_seq_ops);
+
+	if (!res) {
+		struct seq_file *seq = file->private_data;
+
+		seq->private = inode->i_private;
+	}
+	return res;
+}
+
+static const struct file_operations sge_qinfo_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = sge_qinfo_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 int mem_open(struct inode *inode, struct file *file)
 {
 	unsigned int mem;
@@ -1135,6 +1345,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "rss_key", &rss_key_debugfs_fops, S_IRUSR, 0 },
 		{ "rss_pf_config", &rss_pf_config_debugfs_fops, S_IRUSR, 0 },
 		{ "rss_vf_config", &rss_vf_config_debugfs_fops, S_IRUSR, 0 },
+		{ "sge_qinfo", &sge_qinfo_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 12c1a3f..c27dcd9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2500,8 +2500,8 @@ static int closest_thres(const struct sge *s, int thres)
 /*
  * Return a queue's interrupt hold-off time in us.  0 means no timer.
  */
-static unsigned int qtimer_val(const struct adapter *adap,
-			       const struct sge_rspq *q)
+unsigned int qtimer_val(const struct adapter *adap,
+			const struct sge_rspq *q)
 {
 	unsigned int idx = q->intr_params >> 1;
 
-- 
1.7.1
