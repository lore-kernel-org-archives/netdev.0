From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Add some more details to sge qinfo
Date: Wed, 12 Aug 2015 16:55:04 +0530
Message-ID: <1439378707-14462-2-git-send-email-hariprasad@chelsio.com>
References: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7303 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750767AbbHLLZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 07:25:07 -0400
In-Reply-To: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding more details to sge qinfo for debugging purpose.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 61 +++++++++++++++++++---
 1 file changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index f65ab64..15d58c3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1943,13 +1943,13 @@ static int sge_qinfo_show(struct seq_file *seq, void *v)
 {
 	struct adapter *adap = seq->private;
 	int eth_entries = DIV_ROUND_UP(adap->sge.ethqsets, 4);
-	int toe_entries = DIV_ROUND_UP(adap->sge.ofldqsets, 4);
+	int iscsi_entries = DIV_ROUND_UP(adap->sge.ofldqsets, 4);
 	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
 	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
 	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
 	int i, r = (uintptr_t)v - 1;
-	int toe_idx = r - eth_entries;
-	int rdma_idx = toe_idx - toe_entries;
+	int iscsi_idx = r - eth_entries;
+	int rdma_idx = iscsi_idx - iscsi_entries;
 	int ciq_idx = rdma_idx - rdma_entries;
 	int ctrl_idx =  ciq_idx - ciq_entries;
 	int fq_idx =  ctrl_idx - ctrl_entries;
@@ -1965,8 +1965,12 @@ do { \
 		seq_putc(seq, '\n'); \
 } while (0)
 #define S(s, v) S3("s", s, v)
+#define T3(fmt_spec, s, v) S3(fmt_spec, s, tx[i].v)
 #define T(s, v) S3("u", s, tx[i].v)
+#define TL(s, v) T3("lu", s, v)
+#define R3(fmt_spec, s, v) S3(fmt_spec, s, rx[i].v)
 #define R(s, v) S3("u", s, rx[i].v)
+#define RL(s, v) R3("lu", s, v)
 
 	if (r < eth_entries) {
 		int base_qset = r * 4;
@@ -2005,12 +2009,30 @@ do { \
 		R("FL avail:", fl.avail);
 		R("FL PIDX:", fl.pidx);
 		R("FL CIDX:", fl.cidx);
-	} else if (toe_idx < toe_entries) {
-		const struct sge_ofld_rxq *rx = &adap->sge.ofldrxq[toe_idx * 4];
-		const struct sge_ofld_txq *tx = &adap->sge.ofldtxq[toe_idx * 4];
-		int n = min(4, adap->sge.ofldqsets - 4 * toe_idx);
+		RL("RxPackets:", stats.pkts);
+		RL("RxCSO:", stats.rx_cso);
+		RL("VLANxtract:", stats.vlan_ex);
+		RL("LROmerged:", stats.lro_merged);
+		RL("LROpackets:", stats.lro_pkts);
+		RL("RxDrops:", stats.rx_drops);
+		TL("TSO:", tso);
+		TL("TxCSO:", tx_cso);
+		TL("VLANins:", vlan_ins);
+		TL("TxQFull:", q.stops);
+		TL("TxQRestarts:", q.restarts);
+		TL("TxMapErr:", mapping_err);
+		RL("FLAllocErr:", fl.alloc_failed);
+		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLStarving:", fl.starving);
+
+	} else if (iscsi_idx < iscsi_entries) {
+		const struct sge_ofld_rxq *rx =
+			&adap->sge.ofldrxq[iscsi_idx * 4];
+		const struct sge_ofld_txq *tx =
+			&adap->sge.ofldtxq[iscsi_idx * 4];
+		int n = min(4, adap->sge.ofldqsets - 4 * iscsi_idx);
 
-		S("QType:", "TOE");
+		S("QType:", "iSCSI");
 		T("TxQ ID:", q.cntxt_id);
 		T("TxQ size:", q.size);
 		T("TxQ inuse:", q.in_use);
@@ -2030,6 +2052,13 @@ do { \
 		R("FL avail:", fl.avail);
 		R("FL PIDX:", fl.pidx);
 		R("FL CIDX:", fl.cidx);
+		RL("RxPackets:", stats.pkts);
+		RL("RxImmPkts:", stats.imm);
+		RL("RxNoMem:", stats.nomem);
+		RL("FLAllocErr:", fl.alloc_failed);
+		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLStarving:", fl.starving);
+
 	} else if (rdma_idx < rdma_entries) {
 		const struct sge_ofld_rxq *rx =
 				&adap->sge.rdmarxq[rdma_idx * 4];
@@ -2052,6 +2081,13 @@ do { \
 		R("FL avail:", fl.avail);
 		R("FL PIDX:", fl.pidx);
 		R("FL CIDX:", fl.cidx);
+		RL("RxPackets:", stats.pkts);
+		RL("RxImmPkts:", stats.imm);
+		RL("RxNoMem:", stats.nomem);
+		RL("FLAllocErr:", fl.alloc_failed);
+		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLStarving:", fl.starving);
+
 	} else if (ciq_idx < ciq_entries) {
 		const struct sge_ofld_rxq *rx = &adap->sge.rdmaciq[ciq_idx * 4];
 		int n = min(4, adap->sge.rdmaciqs - 4 * ciq_idx);
@@ -2067,6 +2103,9 @@ do { \
 		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
 		S3("u", "Intr pktcnt:",
 		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
+		RL("RxAN:", stats.an);
+		RL("RxNoMem:", stats.nomem);
+
 	} else if (ctrl_idx < ctrl_entries) {
 		const struct sge_ctrl_txq *tx = &adap->sge.ctrlq[ctrl_idx * 4];
 		int n = min(4, adap->params.nports - 4 * ctrl_idx);
@@ -2077,6 +2116,8 @@ do { \
 		T("TxQ inuse:", q.in_use);
 		T("TxQ CIDX:", q.cidx);
 		T("TxQ PIDX:", q.pidx);
+		TL("TxQFull:", q.stops);
+		TL("TxQRestarts:", q.restarts);
 	} else if (fq_idx == 0) {
 		const struct sge_rspq *evtq = &adap->sge.fw_evtq;
 
@@ -2092,8 +2133,12 @@ do { \
 			   adap->sge.counter_val[evtq->pktcnt_idx]);
 	}
 #undef R
+#undef RL
 #undef T
+#undef TL
 #undef S
+#undef R3
+#undef T3
 #undef S3
 	return 0;
 }
-- 
2.3.4
