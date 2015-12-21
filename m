From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/5] cxgb4: get naming correct for iscsi queues
Date: Mon, 21 Dec 2015 12:46:07 +0530
Message-ID: <1450682170-7106-3-git-send-email-hariprasad@chelsio.com>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:19925 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751199AbbLUHO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 02:14:57 -0500
In-Reply-To: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the upper level protocols like rdma, iscsi have their own offload rx
queues, so instead of using the generic naming convention be specific
while naming them. Improves code readability

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         | 13 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  8 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 53 +++++++++++-----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  2 +-
 4 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e01e722..3b59bc4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -398,11 +398,10 @@ struct link_config {
 
 enum {
 	MAX_ETH_QSETS = 32,           /* # of Ethernet Tx/Rx queue sets */
-	MAX_OFLD_QSETS = 16,          /* # of offload Tx/Rx queue sets */
+	MAX_OFLD_QSETS = 16,          /* # of offload Tx, iscsi Rx queue sets */
 	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
 	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
 	MAX_RDMA_CIQS = 32,        /* # of  RDMA concentrator IQs */
-	MAX_ISCSI_QUEUES = NCHAN,     /* # of streaming iSCSI Rx queues */
 };
 
 enum {
@@ -420,7 +419,7 @@ enum {
 	INGQ_EXTRAS = 2,        /* firmware event queue and */
 				/*   forwarded interrupts */
 	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES
-		   + MAX_RDMA_CIQS + MAX_ISCSI_QUEUES + INGQ_EXTRAS,
+		   + MAX_RDMA_CIQS + INGQ_EXTRAS,
 };
 
 struct adapter;
@@ -639,7 +638,7 @@ struct sge {
 	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
-	struct sge_ofld_rxq ofldrxq[MAX_OFLD_QSETS];
+	struct sge_ofld_rxq iscsirxq[MAX_OFLD_QSETS];
 	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
 	struct sge_ofld_rxq rdmaciq[MAX_RDMA_CIQS];
 	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
@@ -650,10 +649,10 @@ struct sge {
 	u16 max_ethqsets;           /* # of available Ethernet queue sets */
 	u16 ethqsets;               /* # of active Ethernet queue sets */
 	u16 ethtxq_rover;           /* Tx queue to clean up next */
-	u16 ofldqsets;              /* # of active offload queue sets */
+	u16 iscsiqsets;              /* # of active iSCSI queue sets */
 	u16 rdmaqs;                 /* # of available RDMA Rx queues */
 	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
-	u16 ofld_rxq[MAX_OFLD_QSETS];
+	u16 iscsi_rxq[MAX_OFLD_QSETS];
 	u16 rdma_rxq[MAX_RDMA_QUEUES];
 	u16 rdma_ciq[MAX_RDMA_CIQS];
 	u16 timer_val[SGE_NTIMERS];
@@ -679,7 +678,7 @@ struct sge {
 };
 
 #define for_each_ethrxq(sge, i) for (i = 0; i < (sge)->ethqsets; i++)
-#define for_each_ofldrxq(sge, i) for (i = 0; i < (sge)->ofldqsets; i++)
+#define for_each_iscsirxq(sge, i) for (i = 0; i < (sge)->iscsiqsets; i++)
 #define for_each_rdmarxq(sge, i) for (i = 0; i < (sge)->rdmaqs; i++)
 #define for_each_rdmaciq(sge, i) for (i = 0; i < (sge)->rdmaciqs; i++)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0d579b1..62a343f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2245,7 +2245,7 @@ static int sge_qinfo_show(struct seq_file *seq, void *v)
 {
 	struct adapter *adap = seq->private;
 	int eth_entries = DIV_ROUND_UP(adap->sge.ethqsets, 4);
-	int iscsi_entries = DIV_ROUND_UP(adap->sge.ofldqsets, 4);
+	int iscsi_entries = DIV_ROUND_UP(adap->sge.iscsiqsets, 4);
 	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
 	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
 	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
@@ -2331,10 +2331,10 @@ do { \
 
 	} else if (iscsi_idx < iscsi_entries) {
 		const struct sge_ofld_rxq *rx =
-			&adap->sge.ofldrxq[iscsi_idx * 4];
+			&adap->sge.iscsirxq[iscsi_idx * 4];
 		const struct sge_ofld_txq *tx =
 			&adap->sge.ofldtxq[iscsi_idx * 4];
-		int n = min(4, adap->sge.ofldqsets - 4 * iscsi_idx);
+		int n = min(4, adap->sge.iscsiqsets - 4 * iscsi_idx);
 
 		S("QType:", "iSCSI");
 		T("TxQ ID:", q.cntxt_id);
@@ -2454,7 +2454,7 @@ do { \
 static int sge_queue_entries(const struct adapter *adap)
 {
 	return DIV_ROUND_UP(adap->sge.ethqsets, 4) +
-	       DIV_ROUND_UP(adap->sge.ofldqsets, 4) +
+	       DIV_ROUND_UP(adap->sge.iscsiqsets, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaqs, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaciqs, 4) +
 	       DIV_ROUND_UP(MAX_CTRL_QUEUES, 4) + 1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8326a776..2642593 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -766,8 +766,8 @@ static void name_msix_vecs(struct adapter *adap)
 	}
 
 	/* offload queues */
-	for_each_ofldrxq(&adap->sge, i)
-		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-ofld%d",
+	for_each_iscsirxq(&adap->sge, i)
+		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-iscsi%d",
 			 adap->port[0]->name, i);
 
 	for_each_rdmarxq(&adap->sge, i)
@@ -782,7 +782,7 @@ static void name_msix_vecs(struct adapter *adap)
 static int request_msix_queue_irqs(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	int err, ethqidx, ofldqidx = 0, rdmaqidx = 0, rdmaciqqidx = 0;
+	int err, ethqidx, iscsiqidx = 0, rdmaqidx = 0, rdmaciqqidx = 0;
 	int msi_index = 2;
 
 	err = request_irq(adap->msix_info[1].vec, t4_sge_intr_msix, 0,
@@ -799,11 +799,11 @@ static int request_msix_queue_irqs(struct adapter *adap)
 			goto unwind;
 		msi_index++;
 	}
-	for_each_ofldrxq(s, ofldqidx) {
+	for_each_iscsirxq(s, iscsiqidx) {
 		err = request_irq(adap->msix_info[msi_index].vec,
 				  t4_sge_intr_msix, 0,
 				  adap->msix_info[msi_index].desc,
-				  &s->ofldrxq[ofldqidx].rspq);
+				  &s->iscsirxq[iscsiqidx].rspq);
 		if (err)
 			goto unwind;
 		msi_index++;
@@ -835,9 +835,9 @@ unwind:
 	while (--rdmaqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->rdmarxq[rdmaqidx].rspq);
-	while (--ofldqidx >= 0)
+	while (--iscsiqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
-			 &s->ofldrxq[ofldqidx].rspq);
+			 &s->iscsirxq[iscsiqidx].rspq);
 	while (--ethqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->ethrxq[ethqidx].rspq);
@@ -853,8 +853,9 @@ static void free_msix_queue_irqs(struct adapter *adap)
 	free_irq(adap->msix_info[1].vec, &s->fw_evtq);
 	for_each_ethrxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->ethrxq[i].rspq);
-	for_each_ofldrxq(s, i)
-		free_irq(adap->msix_info[msi_index++].vec, &s->ofldrxq[i].rspq);
+	for_each_iscsirxq(s, i)
+		free_irq(adap->msix_info[msi_index++].vec,
+			 &s->iscsirxq[i].rspq);
 	for_each_rdmarxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->rdmarxq[i].rspq);
 	for_each_rdmaciq(s, i)
@@ -1093,8 +1094,8 @@ freeout:	t4_free_sge_resources(adap);
 		}
 	}
 
-	j = s->ofldqsets / adap->params.nports; /* ofld queues per channel */
-	for_each_ofldrxq(s, i) {
+	j = s->iscsiqsets / adap->params.nports; /* iscsi queues per channel */
+	for_each_iscsirxq(s, i) {
 		err = t4_sge_alloc_ofld_txq(adap, &s->ofldtxq[i],
 					    adap->port[i / j],
 					    s->fw_evtq.cntxt_id);
@@ -1110,7 +1111,7 @@ freeout:	t4_free_sge_resources(adap);
 		msi_idx += nq; \
 } while (0)
 
-	ALLOC_OFLD_RXQS(s->ofldrxq, s->ofldqsets, j, s->ofld_rxq);
+	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq);
 	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
 	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
 	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq);
@@ -2277,7 +2278,7 @@ static void disable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		disable_txq_db(&adap->sge.ethtxq[i].q);
-	for_each_ofldrxq(&adap->sge, i)
+	for_each_iscsirxq(&adap->sge, i)
 		disable_txq_db(&adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		disable_txq_db(&adap->sge.ctrlq[i].q);
@@ -2289,7 +2290,7 @@ static void enable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		enable_txq_db(adap, &adap->sge.ethtxq[i].q);
-	for_each_ofldrxq(&adap->sge, i)
+	for_each_iscsirxq(&adap->sge, i)
 		enable_txq_db(adap, &adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		enable_txq_db(adap, &adap->sge.ctrlq[i].q);
@@ -2359,7 +2360,7 @@ static void recover_all_queues(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		sync_txq_pidx(adap, &adap->sge.ethtxq[i].q);
-	for_each_ofldrxq(&adap->sge, i)
+	for_each_iscsirxq(&adap->sge, i)
 		sync_txq_pidx(adap, &adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		sync_txq_pidx(adap, &adap->sge.ctrlq[i].q);
@@ -2443,10 +2444,10 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 		lli.nrxq = adap->sge.rdmaqs;
 		lli.nciq = adap->sge.rdmaciqs;
 	} else if (uld == CXGB4_ULD_ISCSI) {
-		lli.rxq_ids = adap->sge.ofld_rxq;
-		lli.nrxq = adap->sge.ofldqsets;
+		lli.rxq_ids = adap->sge.iscsi_rxq;
+		lli.nrxq = adap->sge.iscsiqsets;
 	}
-	lli.ntxq = adap->sge.ofldqsets;
+	lli.ntxq = adap->sge.iscsiqsets;
 	lli.nchan = adap->params.nports;
 	lli.nports = adap->params.nports;
 	lli.wr_cred = adap->params.ofldq_wr_cred;
@@ -4342,11 +4343,11 @@ static void cfg_queues(struct adapter *adap)
 		 * capped by the number of available cores.
 		 */
 		if (n10g) {
-			i = min_t(int, ARRAY_SIZE(s->ofldrxq),
+			i = min_t(int, ARRAY_SIZE(s->iscsirxq),
 				  num_online_cpus());
-			s->ofldqsets = roundup(i, adap->params.nports);
+			s->iscsiqsets = roundup(i, adap->params.nports);
 		} else
-			s->ofldqsets = adap->params.nports;
+			s->iscsiqsets = adap->params.nports;
 		/* For RDMA one Rx queue per channel suffices */
 		s->rdmaqs = adap->params.nports;
 		/* Try and allow at least 1 CIQ per cpu rounding down
@@ -4377,8 +4378,8 @@ static void cfg_queues(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(s->ofldtxq); i++)
 		s->ofldtxq[i].q.size = 1024;
 
-	for (i = 0; i < ARRAY_SIZE(s->ofldrxq); i++) {
-		struct sge_ofld_rxq *r = &s->ofldrxq[i];
+	for (i = 0; i < ARRAY_SIZE(s->iscsirxq); i++) {
+		struct sge_ofld_rxq *r = &s->iscsirxq[i];
 
 		init_rspq(adap, &r->rspq, 5, 1, 1024, 64);
 		r->rspq.uld = CXGB4_ULD_ISCSI;
@@ -4459,7 +4460,7 @@ static int enable_msix(struct adapter *adap)
 
 	want = s->max_ethqsets + EXTRA_VECS;
 	if (is_offload(adap)) {
-		want += s->rdmaqs + s->rdmaciqs + s->ofldqsets;
+		want += s->rdmaqs + s->rdmaciqs + s->iscsiqsets;
 		/* need nchan for each possible ULD */
 		ofld_need = 3 * nchan;
 	}
@@ -4498,13 +4499,13 @@ static int enable_msix(struct adapter *adap)
 		/* leftovers go to OFLD */
 		i = allocated - EXTRA_VECS - s->max_ethqsets -
 		    s->rdmaqs - s->rdmaciqs;
-		s->ofldqsets = (i / nchan) * nchan;  /* round down */
+		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
 	}
 	for (i = 0; i < allocated; ++i)
 		adap->msix_info[i].vec = entries[i].vector;
 	dev_info(adap->pdev_dev, "%d MSI-X vectors allocated, "
 		 "nic %d iscsi %d rdma cpl %d rdma ciq %d\n",
-		 allocated, s->max_ethqsets, s->ofldqsets, s->rdmaqs,
+		 allocated, s->max_ethqsets, s->iscsiqsets, s->rdmaqs,
 		 s->rdmaciqs);
 
 	kfree(entries);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 8d35ce3..0333435 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2978,7 +2978,7 @@ void t4_free_sge_resources(struct adapter *adap)
 	}
 
 	/* clean up RDMA and iSCSI Rx queues */
-	t4_free_ofld_rxqs(adap, adap->sge.ofldqsets, adap->sge.ofldrxq);
+	t4_free_ofld_rxqs(adap, adap->sge.iscsiqsets, adap->sge.iscsirxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaqs, adap->sge.rdmarxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaciqs, adap->sge.rdmaciq);
 
-- 
2.3.4
