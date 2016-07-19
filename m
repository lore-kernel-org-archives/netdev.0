From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Subject: [Patch-V2 1/3] cxgb4: Add Chelsio LLD support Chelsio Crypto ULD
Date: Mon, 18 Jul 2016 22:42:13 -0700
Message-ID: <1468906935-6770-2-git-send-email-yeshaswi@chelsio.com>
References: <1468906935-6770-1-git-send-email-yeshaswi@chelsio.com>
Cc: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linux-crypto@vger.kernel.org, jlulla@chelsio.ccom,
	harsh@chelsio.com, atul.gupta@chelsio.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:52462 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752195AbcGSFny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 01:43:54 -0400
In-Reply-To: <1468906935-6770-1-git-send-email-yeshaswi@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Chelsio crypto driver is an Upper Layer Driver (ULD), making use
of the Chelsio Lower Layer Driver (LLD - cxgb4). The LLD facilitates
the basic infrastructure services of the ULD. These services include
queue allocation, deallocation and registration with LLD. The queues
are used for sending the crypto requests to the Chelsio's hardware
and for receiving the responses from the hardware.

This patch enables the services mentioned for the Chelsio's crypto
driver.

Signed-off-by: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   18 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   41 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   80 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   10 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   64 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  437 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  131 +++++-
 7 files changed, 770 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b4fceb9..4de1e39 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -346,6 +346,8 @@ struct adapter_params {
 
 	unsigned int max_ordird_qp;       /* Max read depth per RDMA QP */
 	unsigned int max_ird_adapter;     /* Max read depth per adapter */
+
+	unsigned char ulp_crypto_lookaside;     /* crypto lookaside support */
 };
 
 /* State needed to monitor the forward progress of SGE Ingress DMA activities
@@ -435,7 +437,7 @@ enum {
 	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
 	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
 	MAX_RDMA_CIQS = 32,        /* # of  RDMA concentrator IQs */
-
+	MAX_CRYPTO_QUEUES = 32,       /* # of crypto queues */
 	/* # of streaming iSCSIT Rx queues */
 	MAX_ISCSIT_QUEUES = MAX_OFLD_QSETS,
 };
@@ -455,7 +457,8 @@ enum {
 	INGQ_EXTRAS = 2,        /* firmware event queue and */
 				/*   forwarded interrupts */
 	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES +
-		   MAX_RDMA_CIQS + MAX_ISCSIT_QUEUES + INGQ_EXTRAS,
+		   MAX_RDMA_CIQS + MAX_ISCSIT_QUEUES + INGQ_EXTRAS +
+		   MAX_CRYPTO_QUEUES,
 };
 
 struct adapter;
@@ -509,6 +512,10 @@ enum {                                 /* adapter flags */
 	FW_OFLD_CONN       = (1 << 9),
 };
 
+enum {
+	ULP_CRYPTO_LOOKASIDE = 1 << 0,
+};
+
 struct rx_sw_desc;
 
 struct sge_fl {                     /* SGE free-buffer queue state */
@@ -682,10 +689,12 @@ struct sge_ctrl_txq {               /* state for an SGE control Tx queue */
 struct sge {
 	struct sge_eth_txq ethtxq[MAX_ETH_QSETS];
 	struct sge_ofld_txq ofldtxq[MAX_OFLD_QSETS];
+	struct sge_ofld_txq cryptotxq[MAX_CRYPTO_QUEUES];
 	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
 	struct sge_ofld_rxq iscsirxq[MAX_OFLD_QSETS];
+	struct sge_ofld_rxq cryptorxq[MAX_CRYPTO_QUEUES];
 	struct sge_ofld_rxq iscsitrxq[MAX_ISCSIT_QUEUES];
 	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
 	struct sge_ofld_rxq rdmaciq[MAX_RDMA_CIQS];
@@ -699,10 +708,12 @@ struct sge {
 	u16 ethtxq_rover;           /* Tx queue to clean up next */
 	u16 iscsiqsets;              /* # of active iSCSI queue sets */
 	u16 niscsitq;               /* # of available iSCST Rx queues */
+	u16 ncryptoq;               /* # of available lookaside crypto queues */
 	u16 rdmaqs;                 /* # of available RDMA Rx queues */
 	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
 	u16 iscsi_rxq[MAX_OFLD_QSETS];
 	u16 iscsit_rxq[MAX_ISCSIT_QUEUES];
+	u16 crypto_rxq[MAX_CRYPTO_QUEUES];
 	u16 rdma_rxq[MAX_RDMA_QUEUES];
 	u16 rdma_ciq[MAX_RDMA_CIQS];
 	u16 timer_val[SGE_NTIMERS];
@@ -732,6 +743,7 @@ struct sge {
 #define for_each_iscsitrxq(sge, i) for (i = 0; i < (sge)->niscsitq; i++)
 #define for_each_rdmarxq(sge, i) for (i = 0; i < (sge)->rdmaqs; i++)
 #define for_each_rdmaciq(sge, i) for (i = 0; i < (sge)->rdmaciqs; i++)
+#define for_each_cryptorxq(sge, i) for (i = 0; i < (sge)->ncryptoq; i++)
 
 struct l2t_data;
 
@@ -1441,7 +1453,7 @@ int t4_fw_bye(struct adapter *adap, unsigned int mbox);
 int t4_early_init(struct adapter *adap, unsigned int mbox);
 int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset);
 int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
-			  unsigned int cache_line_size);
+			 unsigned int cache_line_size);
 int t4_fw_initialize(struct adapter *adap, unsigned int mbox);
 int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int nparams, const u32 *params,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 91fb508..ade6eba 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2436,13 +2436,15 @@ static int sge_qinfo_show(struct seq_file *seq, void *v)
 	int iscsit_entries = DIV_ROUND_UP(adap->sge.niscsitq, 4);
 	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
 	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
+	int crypto_entries = DIV_ROUND_UP(adap->sge.ncryptoq, 4);
 	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
 	int i, r = (uintptr_t)v - 1;
 	int iscsi_idx = r - eth_entries;
 	int iscsit_idx = iscsi_idx - iscsi_entries;
 	int rdma_idx = iscsit_idx - iscsit_entries;
 	int ciq_idx = rdma_idx - rdma_entries;
-	int ctrl_idx =  ciq_idx - ciq_entries;
+	int crypto_idx = ciq_idx - ciq_entries;
+	int ctrl_idx =  crypto_idx - crypto_entries;
 	int fq_idx =  ctrl_idx - ctrl_entries;
 
 	if (r)
@@ -2632,6 +2634,42 @@ do { \
 		RL("RxAN:", stats.an);
 		RL("RxNoMem:", stats.nomem);
 
+	} else if (crypto_idx < crypto_entries) {
+		const struct sge_ofld_rxq *rx =
+			&adap->sge.cryptorxq[crypto_idx * 4];
+		const struct sge_ofld_txq *tx =
+			&adap->sge.cryptotxq[crypto_idx * 4];
+		int n = min(4, adap->sge.ncryptoq - 4 * crypto_idx);
+
+		S("QType:", "Crypto");
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
+		RL("RxPackets:", stats.pkts);
+		RL("RxImmPkts:", stats.imm);
+		RL("RxNoMem:", stats.nomem);
+		RL("FLAllocErr:", fl.alloc_failed);
+		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLMapErr:", fl.mapping_err);
+		RL("FLLow:", fl.low);
+		RL("FLStarving:", fl.starving);
+
 	} else if (ctrl_idx < ctrl_entries) {
 		const struct sge_ctrl_txq *tx = &adap->sge.ctrlq[ctrl_idx * 4];
 		int n = min(4, adap->params.nports - 4 * ctrl_idx);
@@ -2676,6 +2714,7 @@ static int sge_queue_entries(const struct adapter *adap)
 	       DIV_ROUND_UP(adap->sge.niscsitq, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaqs, 4) +
 	       DIV_ROUND_UP(adap->sge.rdmaciqs, 4) +
+	       DIV_ROUND_UP(adap->sge.ncryptoq, 4) +
 	       DIV_ROUND_UP(MAX_CTRL_QUEUES, 4) + 1;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 477db47..92d437c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -228,7 +228,7 @@ static DEFINE_MUTEX(uld_mutex);
 static LIST_HEAD(adap_rcu_list);
 static DEFINE_SPINLOCK(adap_rcu_lock);
 static struct cxgb4_uld_info ulds[CXGB4_ULD_MAX];
-static const char *const uld_str[] = { "RDMA", "iSCSI", "iSCSIT" };
+static const char *const uld_str[] = { "RDMA", "iSCSI", "iSCSIT", "CRYPTO" };
 
 static void link_report(struct net_device *dev)
 {
@@ -797,13 +797,17 @@ static void name_msix_vecs(struct adapter *adap)
 	for_each_rdmaciq(&adap->sge, i)
 		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-rdma-ciq%d",
 			 adap->port[0]->name, i);
+
+	for_each_cryptorxq(&adap->sge, i)
+		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-crypto%d",
+			 adap->port[0]->name, i);
 }
 
 static int request_msix_queue_irqs(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 	int err, ethqidx, iscsiqidx = 0, rdmaqidx = 0, rdmaciqqidx = 0;
-	int iscsitqidx = 0;
+	int iscsitqidx = 0, cryptoqidx = 0;
 	int msi_index = 2;
 
 	err = request_irq(adap->msix_info[1].vec, t4_sge_intr_msix, 0,
@@ -856,9 +860,20 @@ static int request_msix_queue_irqs(struct adapter *adap)
 			goto unwind;
 		msi_index++;
 	}
+	for_each_cryptorxq(s, cryptoqidx) {
+		err = request_irq(adap->msix_info[msi_index].vec,
+				  t4_sge_intr_msix, 0,
+				  adap->msix_info[msi_index].desc,
+				  &s->cryptorxq[cryptoqidx].rspq);
+		if (err)
+			goto unwind;
+		msi_index++;
+	}
 	return 0;
-
 unwind:
+	while (--cryptoqidx >= 0)
+		free_irq(adap->msix_info[--msi_index].vec,
+			 &s->cryptorxq[cryptoqidx].rspq);
 	while (--rdmaciqqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->rdmaciq[rdmaciqqidx].rspq);
@@ -882,7 +897,6 @@ static void free_msix_queue_irqs(struct adapter *adap)
 {
 	int i, msi_index = 2;
 	struct sge *s = &adap->sge;
-
 	free_irq(adap->msix_info[1].vec, &s->fw_evtq);
 	for_each_ethrxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->ethrxq[i].rspq);
@@ -896,6 +910,9 @@ static void free_msix_queue_irqs(struct adapter *adap)
 		free_irq(adap->msix_info[msi_index++].vec, &s->rdmarxq[i].rspq);
 	for_each_rdmaciq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->rdmaciq[i].rspq);
+	for_each_cryptorxq(s, i)
+		free_irq(adap->msix_info[msi_index++].vec,
+			 &s->cryptorxq[i].rspq);
 }
 
 /**
@@ -1155,6 +1172,8 @@ freeout:	t4_free_sge_resources(adap);
 	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq, false);
 	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
 	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq, false);
+	j = s->ncryptoq / adap->params.nports;
+	ALLOC_OFLD_RXQS(s->cryptorxq, s->ncryptoq, j, s->crypto_rxq, 0);
 
 #undef ALLOC_OFLD_RXQS
 
@@ -1170,6 +1189,18 @@ freeout:	t4_free_sge_resources(adap);
 			goto freeout;
 	}
 
+	j = s->ncryptoq / adap->params.nports;
+	for_each_cryptorxq(s, i) {
+		struct sge_eth_txq *t;
+
+		t = (struct sge_eth_txq *)&s->cryptotxq[i];
+		err = t4_sge_alloc_ofld_txq(adap, &s->cryptotxq[i],
+					    adap->port[i / j],
+					    s->fw_evtq.cntxt_id);
+		if (err)
+			goto freeout;
+	}
+
 	t4_write_reg(adap, is_t4(adap->params.chip) ?
 				MPS_TRC_RSS_CONTROL_A :
 				MPS_T5_TRC_RSS_CONTROL_A,
@@ -2489,6 +2520,9 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	} else if (uld == CXGB4_ULD_ISCSIT) {
 		lli.rxq_ids = adap->sge.iscsit_rxq;
 		lli.nrxq = adap->sge.niscsitq;
+	} else if (uld == CXGB4_ULD_CRYPTO) {
+		lli.rxq_ids = adap->sge.crypto_rxq;
+		lli.nrxq = adap->sge.ncryptoq;
 	}
 	lli.ntxq = adap->sge.iscsiqsets;
 	lli.nchan = adap->params.nports;
@@ -2518,6 +2552,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.max_ordird_qp = adap->params.max_ordird_qp;
 	lli.max_ird_adapter = adap->params.max_ird_adapter;
 	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
+	lli.ulp_crypto = adap->params.ulp_crypto_lookaside;
 	lli.nodeid = dev_to_node(adap->pdev_dev);
 
 	handle = ulds[uld].add(&lli);
@@ -2601,7 +2636,7 @@ static void notify_ulds(struct adapter *adap, enum cxgb4_state new_state)
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p)
 {
 	int ret = 0;
-	struct adapter *adap;
+	struct adapter *adap = NULL;
 
 	if (type >= CXGB4_ULD_MAX)
 		return -EINVAL;
@@ -4131,6 +4166,8 @@ static int adap_init0(struct adapter *adap)
 		adap->vres.iscsi.start = val[0];
 		adap->vres.iscsi.size = val[1] - val[0] + 1;
 	}
+	if (caps_cmd.cryptocaps)
+		adap->params.ulp_crypto_lookaside |= ULP_CRYPTO_LOOKASIDE;
 #undef FW_PARAM_PFVF
 #undef FW_PARAM_DEV
 
@@ -4406,6 +4443,12 @@ static void cfg_queues(struct adapter *adap)
 		if (!is_t4(adap->params.chip))
 			s->niscsitq = s->iscsiqsets;
 	}
+	if (adap->params.ulp_crypto_lookaside & ULP_CRYPTO_LOOKASIDE) {
+		s->ncryptoq = min_t(int, MAX_CRYPTO_QUEUES, num_online_cpus());
+		s->ncryptoq = (s->ncryptoq / adap->params.nports) *
+			adap->params.nports;
+		s->ncryptoq = max_t(int, s->ncryptoq, adap->params.nports);
+	}
 
 	for (i = 0; i < ARRAY_SIZE(s->ethrxq); i++) {
 		struct sge_eth_rxq *r = &s->ethrxq[i];
@@ -4420,6 +4463,9 @@ static void cfg_queues(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(s->ctrlq); i++)
 		s->ctrlq[i].q.size = 512;
 
+	for (i = 0; i < ARRAY_SIZE(s->cryptotxq); i++)
+		s->cryptotxq[i].q.size = 1024;
+
 	for (i = 0; i < ARRAY_SIZE(s->ofldtxq); i++)
 		s->ofldtxq[i].q.size = 1024;
 
@@ -4462,6 +4508,14 @@ static void cfg_queues(struct adapter *adap)
 		r->rspq.uld = CXGB4_ULD_RDMA;
 	}
 
+	for (i = 0; i < ARRAY_SIZE(s->cryptorxq); i++) {
+		struct sge_ofld_rxq *r = &s->cryptorxq[i];
+
+		init_rspq(adap, &r->rspq, 5, 1, 1024, 64);
+		r->rspq.uld = CXGB4_ULD_CRYPTO;
+		r->fl.size = 72;
+	}
+
 	init_rspq(adap, &s->fw_evtq, 0, 1, 1024, 64);
 	init_rspq(adap, &s->intrq, 0, 1, 2 * MAX_INGQ, 64);
 }
@@ -4520,9 +4574,14 @@ static int enable_msix(struct adapter *adap)
 		/* need nchan for each possible ULD */
 		if (is_t4(adap->params.chip))
 			ofld_need = 3 * nchan;
+		else if (is_t6(adap->params.chip))
+			ofld_need = 5 * nchan;
 		else
 			ofld_need = 4 * nchan;
 	}
+	if (adap->params.ulp_crypto_lookaside & ULP_CRYPTO_LOOKASIDE)
+		want += s->ncryptoq;
+
 #ifdef CONFIG_CHELSIO_T4_DCB
 	/* For Data Center Bridging we need 8 Ethernet TX Priority Queues for
 	 * each port.
@@ -4549,6 +4608,10 @@ static int enable_msix(struct adapter *adap)
 		if (i < s->ethqsets)
 			reduce_ethqs(adap, i);
 	}
+	if (adap->params.ulp_crypto_lookaside & ULP_CRYPTO_LOOKASIDE) {
+		if (allocated < want)
+			s->ncryptoq = nchan;
+	}
 	if (is_offload(adap)) {
 		if (allocated < want) {
 			s->rdmaqs = nchan;
@@ -4561,8 +4624,11 @@ static int enable_msix(struct adapter *adap)
 		/* leftovers go to OFLD */
 		i = allocated - EXTRA_VECS - s->max_ethqsets -
 		    s->rdmaqs - s->rdmaciqs - s->niscsitq;
-		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
 
+		if (adap->params.ulp_crypto_lookaside & ULP_CRYPTO_LOOKASIDE)
+			i -= s->ncryptoq;
+
+		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
 	}
 	for (i = 0; i < allocated; ++i)
 		adap->msix_info[i].vec = entries[i].vector;
@@ -4570,6 +4636,8 @@ static int enable_msix(struct adapter *adap)
 		 "nic %d iscsi %d rdma cpl %d rdma ciq %d\n",
 		 allocated, s->max_ethqsets, s->iscsiqsets, s->rdmaqs,
 		 s->rdmaciqs);
+	if (adap->params.ulp_crypto_lookaside & ULP_CRYPTO_LOOKASIDE)
+		dev_info(adap->pdev_dev, " crypto %d\n", s->ncryptoq);
 
 	kfree(entries);
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index f3c58aa..963e03b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -40,6 +40,7 @@
 #include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/atomic.h>
+#include <linux/pci.h>
 #include "cxgb4.h"
 
 /* CPL message priority levels */
@@ -192,6 +193,7 @@ enum cxgb4_uld {
 	CXGB4_ULD_RDMA,
 	CXGB4_ULD_ISCSI,
 	CXGB4_ULD_ISCSIT,
+	CXGB4_ULD_CRYPTO,
 	CXGB4_ULD_MAX
 };
 
@@ -280,6 +282,11 @@ struct cxgb4_lld_info {
 	unsigned int iscsi_llimit;	     /* chip's iscsi region llimit */
 	void **iscsi_ppm;		     /* iscsi page pod manager */
 	int nodeid;			     /* device numa node id */
+	unsigned int ulp_crypto;	     /* crypto lookaside support */
+};
+
+enum {
+	ULD_CRYPTO_LOOKASIDE = 1 << 0,
 };
 
 struct cxgb4_uld_info {
@@ -322,6 +329,9 @@ int cxgb4_flush_eq_cache(struct net_device *dev);
 int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte);
 u64 cxgb4_read_sge_timestamp(struct net_device *dev);
 
+int cxgb4_is_crypto_q_full(struct net_device *dev, unsigned int idx);
+int cxgb4_crypto_send(struct net_device *dev, struct sk_buff *skb);
+
 enum cxgb4_bar2_qtype { CXGB4_BAR2_QTYPE_EGRESS, CXGB4_BAR2_QTYPE_INGRESS };
 int cxgb4_bar2_sge_qregs(struct net_device *dev,
 			 unsigned int qid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index bad253b..6ce1362 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1813,6 +1813,48 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
 
+static inline int crypto_send(struct adapter *adap, struct sk_buff *skb)
+{
+	unsigned int idx = skb_txq(skb);
+
+	if (unlikely(is_ctrl_pkt(skb)))
+		return ctrl_xmit(&adap->sge.ctrlq[idx], skb);
+	return ofld_xmit(&adap->sge.cryptotxq[idx], skb);
+}
+
+int t4_crypto_send(struct adapter *adap, struct sk_buff *skb)
+{
+	int ret;
+
+	local_bh_disable();
+	ret = crypto_send(adap, skb);
+	local_bh_enable();
+	return ret;
+}
+
+int cxgb4_crypto_send(struct net_device *dev, struct sk_buff *skb)
+{
+	return t4_crypto_send(netdev2adap(dev), skb);
+}
+EXPORT_SYMBOL(cxgb4_crypto_send);
+
+int cxgb4_is_crypto_q_full(struct net_device *dev, unsigned int idx)
+{
+	int ret = 0;
+	struct sge_ofld_txq *q;
+	struct adapter *adap = netdev2adap(dev);
+
+	local_bh_disable();
+	q = &adap->sge.cryptotxq[idx];
+	spin_lock(&q->sendq.lock);
+	if (q->full)
+		ret = -1;
+	spin_unlock(&q->sendq.lock);
+	local_bh_enable();
+	return ret;
+}
+EXPORT_SYMBOL(cxgb4_is_crypto_q_full);
+
 static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
@@ -3019,6 +3061,7 @@ void t4_free_sge_resources(struct adapter *adap)
 	t4_free_ofld_rxqs(adap, adap->sge.niscsitq, adap->sge.iscsitrxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaqs, adap->sge.rdmarxq);
 	t4_free_ofld_rxqs(adap, adap->sge.rdmaciqs, adap->sge.rdmaciq);
+	t4_free_ofld_rxqs(adap, adap->sge.ncryptoq, adap->sge.cryptorxq);
 
 	/* clean up offload Tx queues */
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ofldtxq); i++) {
@@ -3035,6 +3078,21 @@ void t4_free_sge_resources(struct adapter *adap)
 		}
 	}
 
+	/* clean up crypto queues */
+	for (i = 0; i < ARRAY_SIZE(adap->sge.cryptotxq); i++) {
+		struct sge_ofld_txq *q = &adap->sge.cryptotxq[i];
+
+		if (q->q.desc) {
+			tasklet_kill(&q->qresume_tsk);
+			t4_ctrl_eq_free(adap, adap->mbox, adap->pf,
+					0, q->q.cntxt_id);
+			free_tx_desc(adap, &q->q, q->q.in_use, false);
+			kfree(q->q.sdesc);
+			__skb_queue_purge(&q->sendq);
+			free_txq(adap, &q->q);
+		}
+	}
+
 	/* clean up control Tx queues */
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ctrlq); i++) {
 		struct sge_ctrl_txq *cq = &adap->sge.ctrlq[i];
@@ -3093,6 +3151,12 @@ void t4_sge_stop(struct adapter *adap)
 		if (q->q.desc)
 			tasklet_kill(&q->qresume_tsk);
 	}
+	for (i = 0; i < ARRAY_SIZE(s->cryptotxq); i++)  {
+		struct sge_ofld_txq *q = &s->cryptotxq[i];
+
+		if (q->q.desc)
+			tasklet_kill(&q->qresume_tsk);
+	}
 	for (i = 0; i < ARRAY_SIZE(s->ctrlq); i++) {
 		struct sge_ctrl_txq *cq = &s->ctrlq[i];
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 4705e2d..cf0cc6c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -61,6 +61,7 @@ enum {
 	CPL_ABORT_REQ_RSS     = 0x2B,
 	CPL_ABORT_RPL_RSS     = 0x2D,
 
+	CPL_RX_PHYS_ADDR      = 0x30,
 	CPL_CLOSE_CON_RPL     = 0x32,
 	CPL_ISCSI_HDR         = 0x33,
 	CPL_RDMA_CQE          = 0x35,
@@ -83,6 +84,10 @@ enum {
 	CPL_PASS_OPEN_REQ6    = 0x81,
 	CPL_ACT_OPEN_REQ6     = 0x83,
 
+	CPL_TX_TLS_PDU     =    0x88,
+	CPL_TX_SEC_PDU        = 0x8A,
+	CPL_TX_TLS_ACK        = 0x8B,
+
 	CPL_RDMA_TERMINATE    = 0xA2,
 	CPL_RDMA_WRITE        = 0xA4,
 	CPL_SGE_EGR_UPDATE    = 0xA5,
@@ -94,6 +99,8 @@ enum {
 	CPL_FW4_PLD           = 0xC1,
 	CPL_FW4_ACK           = 0xC3,
 
+	CPL_RX_PHYS_DSGL      = 0xD0,
+
 	CPL_FW6_MSG           = 0xE0,
 	CPL_FW6_PLD           = 0xE1,
 	CPL_TX_PKT_LSO        = 0xED,
@@ -1360,6 +1367,15 @@ struct ulptx_idata {
 	__be32 len;
 };
 
+struct ulp_txpkt {
+	__be32 cmd_dest;
+	__be32 len;
+};
+
+#define S_ULPTX_CMD    24
+#define M_ULPTX_CMD    0xFF
+#define V_ULPTX_CMD(x) ((x) << S_ULPTX_CMD)
+
 #define ULPTX_NSGE_S    0
 #define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
 
@@ -1367,6 +1383,22 @@ struct ulptx_idata {
 #define ULPTX_MORE_V(x)	((x) << ULPTX_MORE_S)
 #define ULPTX_MORE_F	ULPTX_MORE_V(1U)
 
+#define S_ULP_TXPKT_DEST    16
+#define M_ULP_TXPKT_DEST    0x3
+#define V_ULP_TXPKT_DEST(x) ((x) << S_ULP_TXPKT_DEST)
+
+#define S_ULP_TXPKT_FID     4
+#define M_ULP_TXPKT_FID     0x7ff
+#define V_ULP_TXPKT_FID(x)  ((x) << S_ULP_TXPKT_FID)
+
+#define S_ULP_TXPKT_RO      3
+#define V_ULP_TXPKT_RO(x) ((x) << S_ULP_TXPKT_RO)
+#define F_ULP_TXPKT_RO V_ULP_TXPKT_RO(1U)
+
+#define S_ULP_TX_SC_MORE 23
+#define V_ULP_TX_SC_MORE(x) ((x) << S_ULP_TX_SC_MORE)
+#define F_ULP_TX_SC_MORE  V_ULP_TX_SC_MORE(1U)
+
 struct ulp_mem_io {
 	WR_HDR;
 	__be32 cmd;
@@ -1404,4 +1436,409 @@ struct ulp_mem_io {
 #define ULP_MEMIO_DATA_LEN_S    0
 #define ULP_MEMIO_DATA_LEN_V(x) ((x) << ULP_MEMIO_DATA_LEN_S)
 
+#define S_ULPTX_NSGE    0
+#define M_ULPTX_NSGE    0xFFFF
+#define V_ULPTX_NSGE(x) ((x) << S_ULPTX_NSGE)
+#define G_ULPTX_NSGE(x) (((x) >> S_ULPTX_NSGE) & M_ULPTX_NSGE)
+
+struct ulptx_sc_memrd {
+	__be32 cmd_to_len;
+	__be32 addr;
+};
+
+#define S_ULP_TXPKT_DATAMODIFY       23
+#define M_ULP_TXPKT_DATAMODIFY       0x1
+#define V_ULP_TXPKT_DATAMODIFY(x)    ((x) << S_ULP_TXPKT_DATAMODIFY)
+#define G_ULP_TXPKT_DATAMODIFY(x)    \
+	(((x) >> S_ULP_TXPKT_DATAMODIFY) & M_ULP_TXPKT_DATAMODIFY_)
+#define F_ULP_TXPKT_DATAMODIFY       V_ULP_TXPKT_DATAMODIFY(1U)
+
+#define S_ULP_TXPKT_CHANNELID        22
+#define M_ULP_TXPKT_CHANNELID        0x1
+#define V_ULP_TXPKT_CHANNELID(x)     ((x) << S_ULP_TXPKT_CHANNELID)
+#define G_ULP_TXPKT_CHANNELID(x)     \
+	(((x) >> S_ULP_TXPKT_CHANNELID) & M_ULP_TXPKT_CHANNELID)
+#define F_ULP_TXPKT_CHANNELID        V_ULP_TXPKT_CHANNELID(1U)
+
+#define S_SCMD_SEQ_NO_CTRL      29
+#define M_SCMD_SEQ_NO_CTRL      0x3
+#define V_SCMD_SEQ_NO_CTRL(x)   ((x) << S_SCMD_SEQ_NO_CTRL)
+#define G_SCMD_SEQ_NO_CTRL(x)   \
+	(((x) >> S_SCMD_SEQ_NO_CTRL) & M_SCMD_SEQ_NO_CTRL)
+
+/* StsFieldPrsnt- Status field at the end of the TLS PDU */
+#define S_SCMD_STATUS_PRESENT   28
+#define M_SCMD_STATUS_PRESENT   0x1
+#define V_SCMD_STATUS_PRESENT(x)    ((x) << S_SCMD_STATUS_PRESENT)
+#define G_SCMD_STATUS_PRESENT(x)    \
+	(((x) >> S_SCMD_STATUS_PRESENT) & M_SCMD_STATUS_PRESENT)
+#define F_SCMD_STATUS_PRESENT   V_SCMD_STATUS_PRESENT(1U)
+
+/* ProtoVersion - Protocol Version 0: 1.2, 1:1.1, 2:DTLS, 3:Generic,
+ * 3-15: Reserved.
+ */
+#define S_SCMD_PROTO_VERSION    24
+#define M_SCMD_PROTO_VERSION    0xf
+#define V_SCMD_PROTO_VERSION(x) ((x) << S_SCMD_PROTO_VERSION)
+#define G_SCMD_PROTO_VERSION(x) \
+	(((x) >> S_SCMD_PROTO_VERSION) & M_SCMD_PROTO_VERSION)
+
+/* EncDecCtrl - Encryption/Decryption Control. 0: Encrypt, 1: Decrypt */
+#define S_SCMD_ENC_DEC_CTRL     23
+#define M_SCMD_ENC_DEC_CTRL     0x1
+#define V_SCMD_ENC_DEC_CTRL(x)  ((x) << S_SCMD_ENC_DEC_CTRL)
+#define G_SCMD_ENC_DEC_CTRL(x)  \
+	(((x) >> S_SCMD_ENC_DEC_CTRL) & M_SCMD_ENC_DEC_CTRL)
+#define F_SCMD_ENC_DEC_CTRL V_SCMD_ENC_DEC_CTRL(1U)
+
+/* CipherAuthSeqCtrl - Cipher Authentication Sequence Control. */
+#define S_SCMD_CIPH_AUTH_SEQ_CTRL       22
+#define M_SCMD_CIPH_AUTH_SEQ_CTRL       0x1
+#define V_SCMD_CIPH_AUTH_SEQ_CTRL(x)    \
+	((x) << S_SCMD_CIPH_AUTH_SEQ_CTRL)
+#define G_SCMD_CIPH_AUTH_SEQ_CTRL(x)    \
+	(((x) >> S_SCMD_CIPH_AUTH_SEQ_CTRL) & M_SCMD_CIPH_AUTH_SEQ_CTRL)
+#define F_SCMD_CIPH_AUTH_SEQ_CTRL   V_SCMD_CIPH_AUTH_SEQ_CTRL(1U)
+
+/* CiphMode -  Cipher Mode. 0: NOP, 1:AES-CBC, 2:AES-GCM, 3:AES-CTR,
+ * 4:Generic-AES, 5-15: Reserved.
+ */
+#define S_SCMD_CIPH_MODE    18
+#define M_SCMD_CIPH_MODE    0xf
+#define V_SCMD_CIPH_MODE(x) ((x) << S_SCMD_CIPH_MODE)
+#define G_SCMD_CIPH_MODE(x) \
+	(((x) >> S_SCMD_CIPH_MODE) & M_SCMD_CIPH_MODE)
+
+/* AuthMode - Auth Mode. 0: NOP, 1:SHA1, 2:SHA2-224, 3:SHA2-256
+ * 4-15: Reserved
+ */
+#define S_SCMD_AUTH_MODE    14
+#define M_SCMD_AUTH_MODE    0xf
+#define V_SCMD_AUTH_MODE(x) ((x) << S_SCMD_AUTH_MODE)
+#define G_SCMD_AUTH_MODE(x) \
+	(((x) >> S_SCMD_AUTH_MODE) & M_SCMD_AUTH_MODE)
+
+/* HmacCtrl - HMAC Control. 0:NOP, 1:No truncation, 2:Support HMAC Truncation
+ * per RFC 4366, 3:IPSec 96 bits, 4-7:Reserved
+ */
+#define S_SCMD_HMAC_CTRL    11
+#define M_SCMD_HMAC_CTRL    0x7
+#define V_SCMD_HMAC_CTRL(x) ((x) << S_SCMD_HMAC_CTRL)
+#define G_SCMD_HMAC_CTRL(x) \
+	(((x) >> S_SCMD_HMAC_CTRL) & M_SCMD_HMAC_CTRL)
+
+/* IvSize - IV size in units of 2 bytes */
+#define S_SCMD_IV_SIZE  7
+#define M_SCMD_IV_SIZE  0xf
+#define V_SCMD_IV_SIZE(x)   ((x) << S_SCMD_IV_SIZE)
+#define G_SCMD_IV_SIZE(x)   \
+	(((x) >> S_SCMD_IV_SIZE) & M_SCMD_IV_SIZE)
+
+/* NumIVs - Number of IVs */
+#define S_SCMD_NUM_IVS  0
+#define M_SCMD_NUM_IVS  0x7f
+#define V_SCMD_NUM_IVS(x)   ((x) << S_SCMD_NUM_IVS)
+#define G_SCMD_NUM_IVS(x)   \
+	(((x) >> S_SCMD_NUM_IVS) & M_SCMD_NUM_IVS)
+
+/* EnbDbgId - If this is enabled upper 20 (63:44) bits if SeqNumber
+ * (below) are used as Cid (connection id for debug status), these
+ * bits are padded to zero for forming the 64 bit
+ * sequence number for TLS
+ */
+#define S_SCMD_ENB_DBGID  31
+#define M_SCMD_ENB_DBGID  0x1
+#define V_SCMD_ENB_DBGID(x)   ((x) << S_SCMD_ENB_DBGID)
+#define G_SCMD_ENB_DBGID(x)   \
+	(((x) >> S_SCMD_ENB_DBGID) & M_SCMD_ENB_DBGID)
+
+/* IV generation in SW. */
+#define S_SCMD_IV_GEN_CTRL      30
+#define M_SCMD_IV_GEN_CTRL      0x1
+#define V_SCMD_IV_GEN_CTRL(x)   ((x) << S_SCMD_IV_GEN_CTRL)
+#define G_SCMD_IV_GEN_CTRL(x)   \
+	(((x) >> S_SCMD_IV_GEN_CTRL) & M_SCMD_IV_GEN_CTRL)
+#define F_SCMD_IV_GEN_CTRL  V_SCMD_IV_GEN_CTRL(1U)
+
+/* More frags */
+#define S_SCMD_MORE_FRAGS   20
+#define M_SCMD_MORE_FRAGS   0x1
+#define V_SCMD_MORE_FRAGS(x)    ((x) << S_SCMD_MORE_FRAGS)
+#define G_SCMD_MORE_FRAGS(x)    (((x) >> S_SCMD_MORE_FRAGS) & M_SCMD_MORE_FRAGS)
+
+/*last frag */
+#define S_SCMD_LAST_FRAG    19
+#define M_SCMD_LAST_FRAG    0x1
+#define V_SCMD_LAST_FRAG(x) ((x) << S_SCMD_LAST_FRAG)
+#define G_SCMD_LAST_FRAG(x) (((x) >> S_SCMD_LAST_FRAG) & M_SCMD_LAST_FRAG)
+
+/* TlsCompPdu */
+#define S_SCMD_TLS_COMPPDU    18
+#define M_SCMD_TLS_COMPPDU    0x1
+#define V_SCMD_TLS_COMPPDU(x) ((x) << S_SCMD_TLS_COMPPDU)
+#define G_SCMD_TLS_COMPPDU(x) (((x) >> S_SCMD_TLS_COMPPDU) & M_SCMD_TLS_COMPPDU)
+
+/* KeyCntxtInline - Key context inline after the scmd  OR PayloadOnly*/
+#define S_SCMD_KEY_CTX_INLINE   17
+#define M_SCMD_KEY_CTX_INLINE   0x1
+#define V_SCMD_KEY_CTX_INLINE(x)    ((x) << S_SCMD_KEY_CTX_INLINE)
+#define G_SCMD_KEY_CTX_INLINE(x)    \
+	(((x) >> S_SCMD_KEY_CTX_INLINE) & M_SCMD_KEY_CTX_INLINE)
+#define F_SCMD_KEY_CTX_INLINE   V_SCMD_KEY_CTX_INLINE(1U)
+
+/* TLSFragEnable - 0: Host created TLS PDUs, 1: TLS Framgmentation in ASIC */
+#define S_SCMD_TLS_FRAG_ENABLE  16
+#define M_SCMD_TLS_FRAG_ENABLE  0x1
+#define V_SCMD_TLS_FRAG_ENABLE(x)   ((x) << S_SCMD_TLS_FRAG_ENABLE)
+#define G_SCMD_TLS_FRAG_ENABLE(x)   \
+	(((x) >> S_SCMD_TLS_FRAG_ENABLE) & M_SCMD_TLS_FRAG_ENABLE)
+#define F_SCMD_TLS_FRAG_ENABLE  V_SCMD_TLS_FRAG_ENABLE(1U)
+
+/* MacOnly - Only send the MAC and discard PDU. This is valid for hash only
+ * modes, in this case TLS_TX  will drop the PDU and only
+ * send back the MAC bytes.
+ */
+#define S_SCMD_MAC_ONLY 15
+#define M_SCMD_MAC_ONLY 0x1
+#define V_SCMD_MAC_ONLY(x)  ((x) << S_SCMD_MAC_ONLY)
+#define G_SCMD_MAC_ONLY(x)  \
+	(((x) >> S_SCMD_MAC_ONLY) & M_SCMD_MAC_ONLY)
+#define F_SCMD_MAC_ONLY V_SCMD_MAC_ONLY(1U)
+
+/* AadIVDrop - Drop the AAD and IV fields. Useful in protocols
+ * which have complex AAD and IV formations Eg:AES-CCM
+ */
+#define S_SCMD_AADIVDROP 14
+#define M_SCMD_AADIVDROP 0x1
+#define V_SCMD_AADIVDROP(x)  ((x) << S_SCMD_AADIVDROP)
+#define G_SCMD_AADIVDROP(x)  \
+	(((x) >> S_SCMD_AADIVDROP) & M_SCMD_AADIVDROP)
+#define F_SCMD_AADIVDROP V_SCMD_AADIVDROP(1U)
+
+/* HdrLength - Length of all headers excluding TLS header
+ * present before start of crypto PDU/payload.
+ */
+#define S_SCMD_HDR_LEN  0
+#define M_SCMD_HDR_LEN  0x3fff
+#define V_SCMD_HDR_LEN(x)   ((x) << S_SCMD_HDR_LEN)
+#define G_SCMD_HDR_LEN(x)   \
+	(((x) >> S_SCMD_HDR_LEN) & M_SCMD_HDR_LEN)
+
+struct cpl_tx_sec_pdu {
+	__be32 op_ivinsrtofst;
+	__be32 pldlen;
+	__be32 aadstart_cipherstop_hi;
+	__be32 cipherstop_lo_authinsert;
+	__be32 seqno_numivs;
+	__be32 ivgen_hdrlen;
+	__be64 scmd1;
+};
+
+#define S_CPL_TX_SEC_PDU_OPCODE     24
+#define M_CPL_TX_SEC_PDU_OPCODE     0xff
+#define V_CPL_TX_SEC_PDU_OPCODE(x)  ((x) << S_CPL_TX_SEC_PDU_OPCODE)
+#define G_CPL_TX_SEC_PDU_OPCODE(x)  \
+	(((x) >> S_CPL_TX_SEC_PDU_OPCODE) & M_CPL_TX_SEC_PDU_OPCODE)
+
+/* RX Channel Id */
+#define S_CPL_TX_SEC_PDU_RXCHID  22
+#define M_CPL_TX_SEC_PDU_RXCHID  0x1
+#define V_CPL_TX_SEC_PDU_RXCHID(x)   ((x) << S_CPL_TX_SEC_PDU_RXCHID)
+#define G_CPL_TX_SEC_PDU_RXCHID(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_RXCHID) & M_CPL_TX_SEC_PDU_RXCHID)
+#define F_CPL_TX_SEC_PDU_RXCHID  V_CPL_TX_SEC_PDU_RXCHID(1U)
+
+/* Ack Follows */
+#define S_CPL_TX_SEC_PDU_ACKFOLLOWS  21
+#define M_CPL_TX_SEC_PDU_ACKFOLLOWS  0x1
+#define V_CPL_TX_SEC_PDU_ACKFOLLOWS(x)   ((x) << S_CPL_TX_SEC_PDU_ACKFOLLOWS)
+#define G_CPL_TX_SEC_PDU_ACKFOLLOWS(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_ACKFOLLOWS) & M_CPL_TX_SEC_PDU_ACKFOLLOWS)
+#define F_CPL_TX_SEC_PDU_ACKFOLLOWS  V_CPL_TX_SEC_PDU_ACKFOLLOWS(1U)
+
+/* Loopback bit in cpl_tx_sec_pdu */
+#define S_CPL_TX_SEC_PDU_ULPTXLPBK  20
+#define M_CPL_TX_SEC_PDU_ULPTXLPBK  0x1
+#define V_CPL_TX_SEC_PDU_ULPTXLPBK(x)   ((x) << S_CPL_TX_SEC_PDU_ULPTXLPBK)
+#define G_CPL_TX_SEC_PDU_ULPTXLPBK(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_ULPTXLPBK) & M_CPL_TX_SEC_PDU_ULPTXLPBK)
+#define F_CPL_TX_SEC_PDU_ULPTXLPBK  V_CPL_TX_SEC_PDU_ULPTXLPBK(1U)
+
+/* Length of cpl header encapsulated */
+#define S_CPL_TX_SEC_PDU_CPLLEN     16
+#define M_CPL_TX_SEC_PDU_CPLLEN     0xf
+#define V_CPL_TX_SEC_PDU_CPLLEN(x)  ((x) << S_CPL_TX_SEC_PDU_CPLLEN)
+#define G_CPL_TX_SEC_PDU_CPLLEN(x)  \
+	(((x) >> S_CPL_TX_SEC_PDU_CPLLEN) & M_CPL_TX_SEC_PDU_CPLLEN)
+
+/* PlaceHolder */
+#define S_CPL_TX_SEC_PDU_PLACEHOLDER    10
+#define M_CPL_TX_SEC_PDU_PLACEHOLDER    0x1
+#define V_CPL_TX_SEC_PDU_PLACEHOLDER(x) ((x) << S_CPL_TX_SEC_PDU_PLACEHOLDER)
+#define G_CPL_TX_SEC_PDU_PLACEHOLDER(x) \
+	(((x) >> S_CPL_TX_SEC_PDU_PLACEHOLDER) & \
+	 M_CPL_TX_SEC_PDU_PLACEHOLDER)
+
+/* IvInsrtOffset: Insertion location for IV */
+#define S_CPL_TX_SEC_PDU_IVINSRTOFST    0
+#define M_CPL_TX_SEC_PDU_IVINSRTOFST    0x3ff
+#define V_CPL_TX_SEC_PDU_IVINSRTOFST(x) ((x) << S_CPL_TX_SEC_PDU_IVINSRTOFST)
+#define G_CPL_TX_SEC_PDU_IVINSRTOFST(x) \
+	(((x) >> S_CPL_TX_SEC_PDU_IVINSRTOFST) & \
+	 M_CPL_TX_SEC_PDU_IVINSRTOFST)
+
+/* AadStartOffset: Offset in bytes for AAD start from
+ * the first byte following the pkt headers (0-255 bytes)
+ */
+#define S_CPL_TX_SEC_PDU_AADSTART   24
+#define M_CPL_TX_SEC_PDU_AADSTART   0xff
+#define V_CPL_TX_SEC_PDU_AADSTART(x)    ((x) << S_CPL_TX_SEC_PDU_AADSTART)
+#define G_CPL_TX_SEC_PDU_AADSTART(x)    \
+	(((x) >> S_CPL_TX_SEC_PDU_AADSTART) & \
+	 M_CPL_TX_SEC_PDU_AADSTART)
+
+/* AadStopOffset: offset in bytes for AAD stop/end from the first byte following
+ * the pkt headers (0-511 bytes)
+ */
+#define S_CPL_TX_SEC_PDU_AADSTOP    15
+#define M_CPL_TX_SEC_PDU_AADSTOP    0x1ff
+#define V_CPL_TX_SEC_PDU_AADSTOP(x) ((x) << S_CPL_TX_SEC_PDU_AADSTOP)
+#define G_CPL_TX_SEC_PDU_AADSTOP(x) \
+	(((x) >> S_CPL_TX_SEC_PDU_AADSTOP) & M_CPL_TX_SEC_PDU_AADSTOP)
+
+/* CipherStartOffset: offset in bytes for encryption/decryption start from the
+ * first byte following the pkt headers (0-1023 bytes)
+ */
+#define S_CPL_TX_SEC_PDU_CIPHERSTART    5
+#define M_CPL_TX_SEC_PDU_CIPHERSTART    0x3ff
+#define V_CPL_TX_SEC_PDU_CIPHERSTART(x) ((x) << S_CPL_TX_SEC_PDU_CIPHERSTART)
+#define G_CPL_TX_SEC_PDU_CIPHERSTART(x) \
+	(((x) >> S_CPL_TX_SEC_PDU_CIPHERSTART) & \
+	 M_CPL_TX_SEC_PDU_CIPHERSTART)
+
+/* CipherStopOffset: offset in bytes for encryption/decryption end
+ * from end of the payload of this command (0-511 bytes)
+ */
+#define S_CPL_TX_SEC_PDU_CIPHERSTOP_HI      0
+#define M_CPL_TX_SEC_PDU_CIPHERSTOP_HI      0x1f
+#define V_CPL_TX_SEC_PDU_CIPHERSTOP_HI(x)   \
+	((x) << S_CPL_TX_SEC_PDU_CIPHERSTOP_HI)
+#define G_CPL_TX_SEC_PDU_CIPHERSTOP_HI(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_CIPHERSTOP_HI) & \
+	 M_CPL_TX_SEC_PDU_CIPHERSTOP_HI)
+
+#define S_CPL_TX_SEC_PDU_CIPHERSTOP_LO      28
+#define M_CPL_TX_SEC_PDU_CIPHERSTOP_LO      0xf
+#define V_CPL_TX_SEC_PDU_CIPHERSTOP_LO(x)   \
+	((x) << S_CPL_TX_SEC_PDU_CIPHERSTOP_LO)
+#define G_CPL_TX_SEC_PDU_CIPHERSTOP_LO(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_CIPHERSTOP_LO) & \
+	 M_CPL_TX_SEC_PDU_CIPHERSTOP_LO)
+
+/* AuthStartOffset: offset in bytes for authentication start from
+ * the first byte following the pkt headers (0-1023)
+ */
+#define S_CPL_TX_SEC_PDU_AUTHSTART  18
+#define M_CPL_TX_SEC_PDU_AUTHSTART  0x3ff
+#define V_CPL_TX_SEC_PDU_AUTHSTART(x)   ((x) << S_CPL_TX_SEC_PDU_AUTHSTART)
+#define G_CPL_TX_SEC_PDU_AUTHSTART(x)   \
+	(((x) >> S_CPL_TX_SEC_PDU_AUTHSTART) & \
+	 M_CPL_TX_SEC_PDU_AUTHSTART)
+
+/* AuthStopOffset: offset in bytes for authentication
+ * end from end of the payload of this command (0-511 Bytes)
+ */
+#define S_CPL_TX_SEC_PDU_AUTHSTOP   9
+#define M_CPL_TX_SEC_PDU_AUTHSTOP   0x1ff
+#define V_CPL_TX_SEC_PDU_AUTHSTOP(x)    ((x) << S_CPL_TX_SEC_PDU_AUTHSTOP)
+#define G_CPL_TX_SEC_PDU_AUTHSTOP(x)    \
+	(((x) >> S_CPL_TX_SEC_PDU_AUTHSTOP) & \
+	 M_CPL_TX_SEC_PDU_AUTHSTOP)
+
+/* AuthInsrtOffset: offset in bytes for authentication insertion
+ * from end of the payload of this command (0-511 bytes)
+ */
+#define S_CPL_TX_SEC_PDU_AUTHINSERT 0
+#define M_CPL_TX_SEC_PDU_AUTHINSERT 0x1ff
+#define V_CPL_TX_SEC_PDU_AUTHINSERT(x)  ((x) << S_CPL_TX_SEC_PDU_AUTHINSERT)
+#define G_CPL_TX_SEC_PDU_AUTHINSERT(x)  \
+	(((x) >> S_CPL_TX_SEC_PDU_AUTHINSERT) & \
+	 M_CPL_TX_SEC_PDU_AUTHINSERT)
+
+struct cpl_rx_phys_dsgl {
+	__be32 op_to_tid;
+	__be32 pcirlxorder_to_noofsgentr;
+	struct rss_header rss_hdr_int;
+};
+
+#define S_CPL_RX_PHYS_DSGL_OPCODE       24
+#define M_CPL_RX_PHYS_DSGL_OPCODE       0xff
+#define V_CPL_RX_PHYS_DSGL_OPCODE(x)    ((x) << S_CPL_RX_PHYS_DSGL_OPCODE)
+#define G_CPL_RX_PHYS_DSGL_OPCODE(x)    \
+	(((x) >> S_CPL_RX_PHYS_DSGL_OPCODE) & M_CPL_RX_PHYS_DSGL_OPCODE)
+
+#define S_CPL_RX_PHYS_DSGL_ISRDMA       23
+#define M_CPL_RX_PHYS_DSGL_ISRDMA       0x1
+#define V_CPL_RX_PHYS_DSGL_ISRDMA(x)    ((x) << S_CPL_RX_PHYS_DSGL_ISRDMA)
+#define G_CPL_RX_PHYS_DSGL_ISRDMA(x)    \
+	(((x) >> S_CPL_RX_PHYS_DSGL_ISRDMA) & M_CPL_RX_PHYS_DSGL_ISRDMA)
+#define F_CPL_RX_PHYS_DSGL_ISRDMA       V_CPL_RX_PHYS_DSGL_ISRDMA(1U)
+
+#define S_CPL_RX_PHYS_DSGL_RSVD1        20
+#define M_CPL_RX_PHYS_DSGL_RSVD1        0x7
+#define V_CPL_RX_PHYS_DSGL_RSVD1(x)     ((x) << S_CPL_RX_PHYS_DSGL_RSVD1)
+#define G_CPL_RX_PHYS_DSGL_RSVD1(x)     \
+	(((x) >> S_CPL_RX_PHYS_DSGL_RSVD1) & \
+	 M_CPL_RX_PHYS_DSGL_RSVD1)
+
+#define S_CPL_RX_PHYS_DSGL_PCIRLXORDER          31
+#define M_CPL_RX_PHYS_DSGL_PCIRLXORDER          0x1
+#define V_CPL_RX_PHYS_DSGL_PCIRLXORDER(x)       \
+	((x) << S_CPL_RX_PHYS_DSGL_PCIRLXORDER)
+#define G_CPL_RX_PHYS_DSGL_PCIRLXORDER(x)       \
+	(((x) >> S_CPL_RX_PHYS_DSGL_PCIRLXORDER) & \
+	 M_CPL_RX_PHYS_DSGL_PCIRLXORDER)
+#define F_CPL_RX_PHYS_DSGL_PCIRLXORDER  V_CPL_RX_PHYS_DSGL_PCIRLXORDER(1U)
+
+#define S_CPL_RX_PHYS_DSGL_PCINOSNOOP           30
+#define M_CPL_RX_PHYS_DSGL_PCINOSNOOP           0x1
+#define V_CPL_RX_PHYS_DSGL_PCINOSNOOP(x)        \
+	((x) << S_CPL_RX_PHYS_DSGL_PCINOSNOOP)
+#define G_CPL_RX_PHYS_DSGL_PCINOSNOOP(x)        \
+	(((x) >> S_CPL_RX_PHYS_DSGL_PCINOSNOOP) & \
+	 M_CPL_RX_PHYS_DSGL_PCINOSNOOP)
+
+#define F_CPL_RX_PHYS_DSGL_PCINOSNOOP   V_CPL_RX_PHYS_DSGL_PCINOSNOOP(1U)
+
+#define S_CPL_RX_PHYS_DSGL_PCITPHNTENB          29
+#define M_CPL_RX_PHYS_DSGL_PCITPHNTENB          0x1
+#define V_CPL_RX_PHYS_DSGL_PCITPHNTENB(x)       \
+	((x) << S_CPL_RX_PHYS_DSGL_PCITPHNTENB)
+#define G_CPL_RX_PHYS_DSGL_PCITPHNTENB(x)       \
+	(((x) >> S_CPL_RX_PHYS_DSGL_PCITPHNTENB) & \
+	 M_CPL_RX_PHYS_DSGL_PCITPHNTENB)
+#define F_CPL_RX_PHYS_DSGL_PCITPHNTENB  V_CPL_RX_PHYS_DSGL_PCITPHNTENB(1U)
+
+#define S_CPL_RX_PHYS_DSGL_PCITPHNT     27
+#define M_CPL_RX_PHYS_DSGL_PCITPHNT     0x3
+#define V_CPL_RX_PHYS_DSGL_PCITPHNT(x)  ((x) << S_CPL_RX_PHYS_DSGL_PCITPHNT)
+#define G_CPL_RX_PHYS_DSGL_PCITPHNT(x)  \
+	(((x) >> S_CPL_RX_PHYS_DSGL_PCITPHNT) & \
+	 M_CPL_RX_PHYS_DSGL_PCITPHNT)
+
+#define S_CPL_RX_PHYS_DSGL_DCAID        16
+#define M_CPL_RX_PHYS_DSGL_DCAID        0x7ff
+#define V_CPL_RX_PHYS_DSGL_DCAID(x)     ((x) << S_CPL_RX_PHYS_DSGL_DCAID)
+#define G_CPL_RX_PHYS_DSGL_DCAID(x)     \
+	(((x) >> S_CPL_RX_PHYS_DSGL_DCAID) & \
+	 M_CPL_RX_PHYS_DSGL_DCAID)
+
+#define S_CPL_RX_PHYS_DSGL_NOOFSGENTR           0
+#define M_CPL_RX_PHYS_DSGL_NOOFSGENTR           0xffff
+#define V_CPL_RX_PHYS_DSGL_NOOFSGENTR(x)        \
+	((x) << S_CPL_RX_PHYS_DSGL_NOOFSGENTR)
+#define G_CPL_RX_PHYS_DSGL_NOOFSGENTR(x)        \
+	(((x) >> S_CPL_RX_PHYS_DSGL_NOOFSGENTR) & \
+	 M_CPL_RX_PHYS_DSGL_NOOFSGENTR)
+
 #endif  /* __T4_MSG_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 392d664..76008f3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -102,6 +102,7 @@ enum fw_wr_opcodes {
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
 	FW_ISCSI_TX_DATA_WR	       = 0x45,
+	FW_CRYPTO_LOOKASIDE_WR         = 0X6d,
 	FW_LASTC2E_WR                  = 0x70
 };
 
@@ -1033,6 +1034,11 @@ enum fw_caps_config_iscsi {
 	FW_CAPS_CONFIG_ISCSI_TARGET_CNXOFLD = 0x00000008,
 };
 
+enum fw_caps_config_crypto {
+	FW_CAPS_CONFIG_CRYPTO_LOOKASIDE = 0x00000001,
+	FW_CAPS_CONFIG_TLSKEYS = 0x00000002,
+};
+
 enum fw_caps_config_fcoe {
 	FW_CAPS_CONFIG_FCOE_INITIATOR	= 0x00000001,
 	FW_CAPS_CONFIG_FCOE_TARGET	= 0x00000002,
@@ -1060,7 +1066,7 @@ struct fw_caps_config_cmd {
 	__be16 niccaps;
 	__be16 ofldcaps;
 	__be16 rdmacaps;
-	__be16 r4;
+	__be16 cryptocaps;
 	__be16 iscsicaps;
 	__be16 fcoecaps;
 	__be32 cfcsum;
@@ -3243,4 +3249,127 @@ struct fw_devlog_cmd {
 #define PCIE_FW_PF_DEVLOG_MEMTYPE_G(x) \
 	(((x) >> PCIE_FW_PF_DEVLOG_MEMTYPE_S) & PCIE_FW_PF_DEVLOG_MEMTYPE_M)
 
+#define MAX_IMM_OFLD_TX_DATA_WR_LEN (0xff + sizeof(struct fw_ofld_tx_data_wr))
+
+struct fw_crypto_lookaside_wr {
+	__be32 op_to_cctx_size;
+	__be32 len16_pkd;
+	__be32 session_id;
+	__be32 rx_chid_to_rx_q_id;
+	__be32 key_addr;
+	__be32 pld_size_hash_size;
+	__be64 cookie;
+};
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_OPCODE 24
+#define M_FW_CRYPTO_LOOKASIDE_WR_OPCODE 0xff
+#define V_FW_CRYPTO_LOOKASIDE_WR_OPCODE(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_OPCODE)
+#define G_FW_CRYPTO_LOOKASIDE_WR_OPCODE(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_OPCODE) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_OPCODE)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_COMPL 23
+#define M_FW_CRYPTO_LOOKASIDE_WR_COMPL 0x1
+#define V_FW_CRYPTO_LOOKASIDE_WR_COMPL(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_COMPL)
+#define G_FW_CRYPTO_LOOKASIDE_WR_COMPL(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_COMPL) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_COMPL)
+#define F_FW_CRYPTO_LOOKASIDE_WR_COMPL V_FW_CRYPTO_LOOKASIDE_WR_COMPL(1U)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN 15
+#define M_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN 0xff
+#define V_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN)
+#define G_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC 5
+#define M_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC 0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC)
+#define G_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE 0
+#define M_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE 0x1f
+#define V_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE)
+#define G_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_LEN16 0
+#define M_FW_CRYPTO_LOOKASIDE_WR_LEN16 0xff
+#define V_FW_CRYPTO_LOOKASIDE_WR_LEN16(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_LEN16)
+#define G_FW_CRYPTO_LOOKASIDE_WR_LEN16(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_LEN16) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_LEN16)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_RX_CHID 29
+#define M_FW_CRYPTO_LOOKASIDE_WR_RX_CHID 0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_RX_CHID(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_RX_CHID)
+#define G_FW_CRYPTO_LOOKASIDE_WR_RX_CHID(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_RX_CHID) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_RX_CHID)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_LCB  27
+#define M_FW_CRYPTO_LOOKASIDE_WR_LCB  0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_LCB(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_LCB)
+#define G_FW_CRYPTO_LOOKASIDE_WR_LCB(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_LCB) & M_FW_CRYPTO_LOOKASIDE_WR_LCB)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_PHASH 25
+#define M_FW_CRYPTO_LOOKASIDE_WR_PHASH 0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_PHASH(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_PHASH)
+#define G_FW_CRYPTO_LOOKASIDE_WR_PHASH(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_PHASH) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_PHASH)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_IV   23
+#define M_FW_CRYPTO_LOOKASIDE_WR_IV   0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_IV(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_IV)
+#define G_FW_CRYPTO_LOOKASIDE_WR_IV(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_IV) & M_FW_CRYPTO_LOOKASIDE_WR_IV)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_TX_CH 10
+#define M_FW_CRYPTO_LOOKASIDE_WR_TX_CH 0x3
+#define V_FW_CRYPTO_LOOKASIDE_WR_TX_CH(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_TX_CH)
+#define G_FW_CRYPTO_LOOKASIDE_WR_TX_CH(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_TX_CH) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_TX_CH)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID 0
+#define M_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID 0x3ff
+#define V_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID)
+#define G_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE 24
+#define M_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE 0xff
+#define V_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE)
+#define G_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE)
+
+#define S_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE 17
+#define M_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE 0x7f
+#define V_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE(x) \
+	((x) << S_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE)
+#define G_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE(x) \
+	(((x) >> S_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE) & \
+	 M_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE)
+
 #endif /* _T4FW_INTERFACE_H_ */
-- 
1.7.10.1
