From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Add debugfs support to dump tid info
Date: Wed, 12 Aug 2015 16:55:07 +0530
Message-ID: <1439378707-14462-5-git-send-email-hariprasad@chelsio.com>
References: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5108 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751433AbbHLLZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 07:25:14 -0400
In-Reply-To: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add debugfs support to dump tid info like stid, sftid, tids, atid and
hwtids

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 68 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  9 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  4 ++
 3 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 15d58c3..ce075d1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2257,6 +2257,73 @@ static const struct file_operations mem_debugfs_fops = {
 	.llseek  = default_llseek,
 };
 
+static int tid_info_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adap = seq->private;
+	const struct tid_info *t = &adap->tids;
+	enum chip_type chip = CHELSIO_CHIP_VERSION(adap->params.chip);
+
+	if (t4_read_reg(adap, LE_DB_CONFIG_A) & HASHEN_F) {
+		unsigned int sb;
+
+		if (chip <= CHELSIO_T5)
+			sb = t4_read_reg(adap, LE_DB_SERVER_INDEX_A) / 4;
+		else
+			sb = t4_read_reg(adap, LE_DB_SRVR_START_INDEX_A);
+
+		if (sb) {
+			seq_printf(seq, "TID range: 0..%u/%u..%u", sb - 1,
+				   adap->tids.hash_base,
+				   t->ntids - 1);
+			seq_printf(seq, ", in use: %u/%u\n",
+				   atomic_read(&t->tids_in_use),
+				   atomic_read(&t->hash_tids_in_use));
+		} else if (adap->flags & FW_OFLD_CONN) {
+			seq_printf(seq, "TID range: %u..%u/%u..%u",
+				   t->aftid_base,
+				   t->aftid_end,
+				   adap->tids.hash_base,
+				   t->ntids - 1);
+			seq_printf(seq, ", in use: %u/%u\n",
+				   atomic_read(&t->tids_in_use),
+				   atomic_read(&t->hash_tids_in_use));
+		} else {
+			seq_printf(seq, "TID range: %u..%u",
+				   adap->tids.hash_base,
+				   t->ntids - 1);
+			seq_printf(seq, ", in use: %u\n",
+				   atomic_read(&t->hash_tids_in_use));
+		}
+	} else if (t->ntids) {
+		seq_printf(seq, "TID range: 0..%u", t->ntids - 1);
+		seq_printf(seq, ", in use: %u\n",
+			   atomic_read(&t->tids_in_use));
+	}
+
+	if (t->nstids)
+		seq_printf(seq, "STID range: %u..%u, in use: %u\n",
+			   (!t->stid_base &&
+			   (chip <= CHELSIO_T5)) ?
+			   t->stid_base + 1 : t->stid_base,
+			   t->stid_base + t->nstids - 1, t->stids_in_use);
+	if (t->natids)
+		seq_printf(seq, "ATID range: 0..%u, in use: %u\n",
+			   t->natids - 1, t->atids_in_use);
+	seq_printf(seq, "FTID range: %u..%u\n", t->ftid_base,
+		   t->ftid_base + t->nftids - 1);
+	if (t->nsftids)
+		seq_printf(seq, "SFTID range: %u..%u in use: %u\n",
+			   t->sftid_base, t->sftid_base + t->nsftids - 2,
+			   t->sftids_in_use);
+	if (t->ntids)
+		seq_printf(seq, "HW TID usage: %u IP users, %u IPv6 users\n",
+			   t4_read_reg(adap, LE_DB_ACT_CNT_IPV4_A),
+			   t4_read_reg(adap, LE_DB_ACT_CNT_IPV6_A));
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(tid_info);
+
 static void add_debugfs_mem(struct adapter *adap, const char *name,
 			    unsigned int idx, unsigned int size_mb)
 {
@@ -2670,6 +2737,7 @@ int t4_setup_debugfs(struct adapter *adap)
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
+		{ "tids", &tid_info_debugfs_fops, S_IRUSR, 0},
 		{ "blocked_fl", &blocked_fl_fops, S_IRUSR | S_IWUSR, 0 },
 		{ "meminfo", &meminfo_fops, S_IRUSR, 0 },
 	};
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index d4248d7..78f446c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1424,18 +1424,17 @@ static void restart_ctrlq(unsigned long data)
 		struct fw_wr_hdr *wr;
 		unsigned int ndesc = skb->priority;     /* previously saved */
 
-		/*
-		 * Write descriptors and free skbs outside the lock to limit
+		written += ndesc;
+		/* Write descriptors and free skbs outside the lock to limit
 		 * wait times.  q->full is still set so new skbs will be queued.
 		 */
+		wr = (struct fw_wr_hdr *)&q->q.desc[q->q.pidx];
+		txq_advance(&q->q, ndesc);
 		spin_unlock(&q->sendq.lock);
 
-		wr = (struct fw_wr_hdr *)&q->q.desc[q->q.pidx];
 		inline_tx_skb(skb, &q->q, wr);
 		kfree_skb(skb);
 
-		written += ndesc;
-		txq_advance(&q->q, ndesc);
 		if (unlikely(txq_avail(&q->q) < TXQ_STOP_THRES)) {
 			unsigned long old = q->q.stops;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 365ebd5..4d2c929 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2732,6 +2732,10 @@
 #define T6_LIPMISS_F    T6_LIPMISS_V(1U)
 
 #define LE_DB_CONFIG_A 0x19c04
+#define LE_DB_SERVER_INDEX_A 0x19c18
+#define LE_DB_SRVR_START_INDEX_A 0x19c18
+#define LE_DB_ACT_CNT_IPV4_A 0x19c20
+#define LE_DB_ACT_CNT_IPV6_A 0x19c24
 #define LE_DB_HASH_TID_BASE_A 0x19c30
 #define LE_DB_HASH_TBL_BASE_ADDR_A 0x19c30
 #define LE_DB_INT_CAUSE_A 0x19c3c
-- 
2.3.4
