From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 02/12] cxgb4: allocate resources for CXGB4_ULD_ISCSIT
Date: Sun, 13 Mar 2016 18:58:52 +0530
Message-ID: <9a45174b054b4bcbfeb5b83c80d6029065ec53c2.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

allocate rxqs for non T4 adapters,
dump rxqs sge qinfo through debugfs.

Signed-off-by: Varun Prakash <varun@chelsio.com>
Signed-off-by: Nicholas Bellinger <nab@linux-iscsi.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         | 11 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 34 +++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 53 ++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  1 +
 4 files changed, 92 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ec6e849..6206de9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -404,6 +404,9 @@ enum {
 	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
 	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
 	MAX_RDMA_CIQS = 32,        /* # of  RDMA concentrator IQs */
+
+	/* # of streaming iSCSIT Rx queues */
+	MAX_ISCSIT_QUEUES = MAX_OFLD_QSETS,
 };
 
 enum {
@@ -420,8 +423,8 @@ enum {
 enum {
 	INGQ_EXTRAS = 2,        /* firmware event queue and */
 				/*   forwarded interrupts */
-	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES
-		   + MAX_RDMA_CIQS + INGQ_EXTRAS,
+	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES +
+		   MAX_RDMA_CIQS + MAX_ISCSIT_QUEUES + INGQ_EXTRAS,
 };
 
 struct adapter;
@@ -641,6 +644,7 @@ struct sge {
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
 	struct sge_ofld_rxq iscsirxq[MAX_OFLD_QSETS];
+	struct sge_ofld_rxq iscsitrxq[MAX_ISCSIT_QUEUES];
 	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
 	struct sge_ofld_rxq rdmaciq[MAX_RDMA_CIQS];
 	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
@@ -652,9 +656,11 @@ struct sge {
 	u16 ethqsets;               /* # of active Ethernet queue sets */
 	u16 ethtxq_rover;           /* Tx queue to clean up next */
 	u16 iscsiqsets;              /* # of active iSCSI queue sets */
+	u16 niscsitq;               /* # of available iSCST Rx queues */
 	u16 rdmaqs;                 /* # of available RDMA Rx queues */
 	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
 	u16 iscsi_rxq[MAX_OFLD_QSETS];
+	u16 iscsit_rxq[MAX_ISCSIT_QUEUES];
 	u16 rdma_rxq[MAX_RDMA_QUEUES];
 	u16 rdma_ciq[MAX_RDMA_CIQS];
 	u16 timer_val[SGE_NTIMERS];
@@ -681,6 +687,7 @@ struct sge {
 
 #define for_each_ethrxq(sge, i) for (i = 0; i < (sge)->ethqsets; i++)
 #define for_each_iscsirxq(sge, i) for (i = 0; i < (sge)->iscsiqsets; i++)
+#define for_each_iscsitrxq(sge, i) for (i = 0; i < (sge)->niscsitq; i++)
 #define for_each_rdmarxq(sge, i) for (i = 0; i < (sge)->rdmaqs; i++)
 #define for_each_rdmaciq(sge, i) for (i = 0; i < (sge)->rdmaciqs; i++)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index e6a4072..0bb41e9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2334,12 +2334,14 @@ static int sge_qinfo_show(struct seq_file *seq, void *v)
 	struct adapter *adap = seq->private;
 	int eth_entries = DIV_ROUND_UP(adap->sge.ethqsets, 4);
 	int iscsi_entries = DIV_ROUND_UP(adap->sge.iscsiqsets, 4);
+	int iscsit_entries = DIV_ROUND_UP(adap->sge.niscsitq, 4);
 	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
 	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
 	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
 	int i, r = (uintptr_t)v - 1;
 	int iscsi_idx = r - eth_entries;
-	int rdma_idx = iscsi_idx - iscsi_entries;
+	int iscsit_idx = iscsi_idx - iscsi_entries;
+	int rdma_idx = iscsit_idx - iscsit_entries;
 	int ciq_idx = rdma_idx - rdma_entries;
 	int ctrl_idx =  ciq_idx - ciq_entries;
 	int fq_idx =  ctrl_idx - ctrl_entries;
@@ -2453,6 +2455,35 @@ do { \
 		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
+	} else if (iscsit_idx < iscsit_entries) {
+		const struct sge_ofld_rxq *rx =
+			&adap->sge.iscsitrxq[iscsit_idx * 4];
+		int n = min(4, adap->sge.niscsitq - 4 * iscsit_idx);
+
+		S("QType:", "iSCSIT");
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
+		RL("RxPackets:", stats.pkts);
+		RL("RxImmPkts:", stats.imm);
+		RL("RxNoMem:", stats.nomem);
+		RL("FLAllocErr:", fl.alloc_failed);
+		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLMapErr:", fl.mapping_err);
+		RL("FLLow:", fl.low);
+		RL("FLStarving:", fl.starving);
+
 	} else if (rdma_idx < rdma_entries) {
 		const struct sge_ofld_rxq *rx =
 				&adap->sge.rdmarxq[rdma_idx * 4];
@@ -2543,6 +2574,7 @@ static int sge_queue_entries(const struct adapter *adap)
 {
 	return DIV_ROUND_UP(adap->sge.ethqsets, 4) +
 	       DIV_ROUND_UP(adap->sge.iscsiqsets, 4) +
+	       DIV_ROUND_UP(adap->sge.niscsitq, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaqs, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaciqs, 4) +
 	       DIV_ROUND_UP(MAX_CTRL_QUEUES, 4) + 1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b8a5fb0..d6cfa90 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -227,7 +227,7 @@ static DEFINE_MUTEX(uld_mutex);
 static LIST_HEAD(adap_rcu_list);
 static DEFINE_SPINLOCK(adap_rcu_lock);
 static struct cxgb4_uld_info ulds[CXGB4_ULD_MAX];
-static const char *uld_str[] = { "RDMA", "iSCSI" };
+static const char *const uld_str[] = { "RDMA", "iSCSI", "iSCSIT" };
 
 static void link_report(struct net_device *dev)
 {
@@ -730,6 +730,10 @@ static void name_msix_vecs(struct adapter *adap)
 		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-iscsi%d",
 			 adap->port[0]->name, i);
 
+	for_each_iscsitrxq(&adap->sge, i)
+		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-iSCSIT%d",
+			 adap->port[0]->name, i);
+
 	for_each_rdmarxq(&adap->sge, i)
 		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-rdma%d",
 			 adap->port[0]->name, i);
@@ -743,6 +747,7 @@ static int request_msix_queue_irqs(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 	int err, ethqidx, iscsiqidx = 0, rdmaqidx = 0, rdmaciqqidx = 0;
+	int iscsitqidx = 0;
 	int msi_index = 2;
 
 	err = request_irq(adap->msix_info[1].vec, t4_sge_intr_msix, 0,
@@ -768,6 +773,15 @@ static int request_msix_queue_irqs(struct adapter *adap)
 			goto unwind;
 		msi_index++;
 	}
+	for_each_iscsitrxq(s, iscsitqidx) {
+		err = request_irq(adap->msix_info[msi_index].vec,
+				  t4_sge_intr_msix, 0,
+				  adap->msix_info[msi_index].desc,
+				  &s->iscsitrxq[iscsitqidx].rspq);
+		if (err)
+			goto unwind;
+		msi_index++;
+	}
 	for_each_rdmarxq(s, rdmaqidx) {
 		err = request_irq(adap->msix_info[msi_index].vec,
 				  t4_sge_intr_msix, 0,
@@ -795,6 +809,9 @@ unwind:
 	while (--rdmaqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->rdmarxq[rdmaqidx].rspq);
+	while (--iscsitqidx >= 0)
+		free_irq(adap->msix_info[--msi_index].vec,
+			 &s->iscsitrxq[iscsitqidx].rspq);
 	while (--iscsiqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->iscsirxq[iscsiqidx].rspq);
@@ -816,6 +833,9 @@ static void free_msix_queue_irqs(struct adapter *adap)
 	for_each_iscsirxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec,
 			 &s->iscsirxq[i].rspq);
+	for_each_iscsitrxq(s, i)
+		free_irq(adap->msix_info[msi_index++].vec,
+			 &s->iscsitrxq[i].rspq);
 	for_each_rdmarxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->rdmarxq[i].rspq);
 	for_each_rdmaciq(s, i)
@@ -1072,6 +1092,7 @@ freeout:	t4_free_sge_resources(adap);
 } while (0)
 
 	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq);
+	ALLOC_OFLD_RXQS(s->iscsitrxq, s->niscsitq, j, s->iscsit_rxq);
 	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
 	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
 	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq);
@@ -2406,6 +2427,9 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	} else if (uld == CXGB4_ULD_ISCSI) {
 		lli.rxq_ids = adap->sge.iscsi_rxq;
 		lli.nrxq = adap->sge.iscsiqsets;
+	} else if (uld == CXGB4_ULD_ISCSIT) {
+		lli.rxq_ids = adap->sge.iscsit_rxq;
+		lli.nrxq = adap->sge.niscsitq;
 	}
 	lli.ntxq = adap->sge.iscsiqsets;
 	lli.nchan = adap->params.nports;
@@ -4310,6 +4334,9 @@ static void cfg_queues(struct adapter *adap)
 		s->rdmaciqs = (s->rdmaciqs / adap->params.nports) *
 				adap->params.nports;
 		s->rdmaciqs = max_t(int, s->rdmaciqs, adap->params.nports);
+
+		if (!is_t4(adap->params.chip))
+			s->niscsitq = s->iscsiqsets;
 	}
 
 	for (i = 0; i < ARRAY_SIZE(s->ethrxq); i++) {
@@ -4336,6 +4363,16 @@ static void cfg_queues(struct adapter *adap)
 		r->fl.size = 72;
 	}
 
+	if (!is_t4(adap->params.chip)) {
+		for (i = 0; i < ARRAY_SIZE(s->iscsitrxq); i++) {
+			struct sge_ofld_rxq *r = &s->iscsitrxq[i];
+
+			init_rspq(adap, &r->rspq, 5, 1, 1024, 64);
+			r->rspq.uld = CXGB4_ULD_ISCSIT;
+			r->fl.size = 72;
+		}
+	}
+
 	for (i = 0; i < ARRAY_SIZE(s->rdmarxq); i++) {
 		struct sge_ofld_rxq *r = &s->rdmarxq[i];
 
@@ -4410,9 +4447,13 @@ static int enable_msix(struct adapter *adap)
 
 	want = s->max_ethqsets + EXTRA_VECS;
 	if (is_offload(adap)) {
-		want += s->rdmaqs + s->rdmaciqs + s->iscsiqsets;
+		want += s->rdmaqs + s->rdmaciqs + s->iscsiqsets	+
+			s->niscsitq;
 		/* need nchan for each possible ULD */
-		ofld_need = 3 * nchan;
+		if (is_t4(adap->params.chip))
+			ofld_need = 3 * nchan;
+		else
+			ofld_need = 4 * nchan;
 	}
 #ifdef CONFIG_CHELSIO_T4_DCB
 	/* For Data Center Bridging we need 8 Ethernet TX Priority Queues for
@@ -4444,12 +4485,16 @@ static int enable_msix(struct adapter *adap)
 		if (allocated < want) {
 			s->rdmaqs = nchan;
 			s->rdmaciqs = nchan;
+
+			if (!is_t4(adap->params.chip))
+				s->niscsitq = nchan;
 		}
 
 		/* leftovers go to OFLD */
 		i = allocated - EXTRA_VECS - s->max_ethqsets -
-		    s->rdmaqs - s->rdmaciqs;
+		    s->rdmaqs - s->rdmaciqs - s->niscsitq;
 		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
+
 	}
 	for (i = 0; i < allocated; ++i)
 		adap->msix_info[i].vec = entries[i].vector;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b4eb468..b3a31af 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2982,6 +2982,7 @@ void t4_free_sge_resources(struct adapter *adap)
 
 	/* clean up RDMA and iSCSI Rx queues */
 	t4_free_ofld_rxqs(adap, adap->sge.iscsiqsets, adap->sge.iscsirxq);
+	t4_free_ofld_rxqs(adap, adap->sge.niscsitq, adap->sge.iscsitrxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaqs, adap->sge.rdmarxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaciqs, adap->sge.rdmaciq);
 
-- 
2.0.2
