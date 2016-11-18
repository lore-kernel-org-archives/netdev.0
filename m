From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next] cxgb4: Allocate Tx queues dynamically
Date: Fri, 18 Nov 2016 16:37:40 +0530
Message-ID: <1479467260-6509-1-git-send-email-atul.gupta@chelsio.com>
Cc: davem@davemloft.net, nab@linux-iscsi.org, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, dledford@redhat.com,
        herbert@gondor.apana.org.au, leedom@chelsio.com,
        nirranjan@chelsio.com, varun@chelsio.com,
        swise@opengridcomputing.com, hariprasad@chelsio.com,
        Atul Gupta <atul.gupta@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>

Allocate resources dynamically for Upper layer driver's (ULD) like
cxgbit, iw_cxgb4, cxgb4i and chcr. The resources allocated include Tx
queues which are allocated when ULD register with cxgb4 driver and freed
while un-registering. The Tx queues which are shared by ULD shall be
allocated by first registering driver and un-allocated by last
unregistering driver.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c                 |  16 +--
 drivers/crypto/chelsio/chcr_core.c                 |   3 +-
 drivers/infiniband/hw/cxgb4/device.c               |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  19 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  12 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  64 +++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c     | 114 +++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  17 +++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 121 +++++++++++++++------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |   1 +
 drivers/target/iscsi/cxgbit/cxgbit_main.c          |   1 +
 11 files changed, 287 insertions(+), 82 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index e4ddb921d7b3..56b153805462 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -592,16 +592,18 @@ static int chcr_aes_cbc_setkey(struct crypto_ablkcipher *tfm, const u8 *key,
 
 static int cxgb4_is_crypto_q_full(struct net_device *dev, unsigned int idx)
 {
-	int ret = 0;
-	struct sge_ofld_txq *q;
 	struct adapter *adap = netdev2adap(dev);
+	struct sge_uld_txq_info *txq_info =
+		adap->sge.uld_txq_info[CXGB4_TX_CRYPTO];
+	struct sge_uld_txq *txq;
+	int ret = 0;
 
 	local_bh_disable();
-	q = &adap->sge.ofldtxq[idx];
-	spin_lock(&q->sendq.lock);
-	if (q->full)
+	txq = &txq_info->uldtxq[idx];
+	spin_lock(&txq->sendq.lock);
+	if (txq->full)
 		ret = -1;
-	spin_unlock(&q->sendq.lock);
+	spin_unlock(&txq->sendq.lock);
 	local_bh_enable();
 	return ret;
 }
@@ -674,11 +676,11 @@ static int chcr_device_init(struct chcr_context *ctx)
 		}
 		u_ctx = ULD_CTX(ctx);
 		rxq_perchan = u_ctx->lldi.nrxq / u_ctx->lldi.nchan;
-		ctx->dev->tx_channel_id = 0;
 		rxq_idx = ctx->dev->tx_channel_id * rxq_perchan;
 		rxq_idx += id % rxq_perchan;
 		spin_lock(&ctx->dev->lock_chcr_dev);
 		ctx->tx_channel_id = rxq_idx;
+		ctx->dev->tx_channel_id = !ctx->dev->tx_channel_id;
 		spin_unlock(&ctx->dev->lock_chcr_dev);
 	}
 out:
diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index fb5f9bbfa09c..4d7f6700fd7e 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -42,6 +42,7 @@ static chcr_handler_func work_handlers[NUM_CPL_CMDS] = {
 static struct cxgb4_uld_info chcr_uld_info = {
 	.name = DRV_MODULE_NAME,
 	.nrxq = MAX_ULD_QSETS,
+	.ntxq = MAX_ULD_QSETS,
 	.rxq_size = 1024,
 	.add = chcr_uld_add,
 	.state_change = chcr_uld_state_change,
@@ -126,7 +127,7 @@ static int cpl_fw6_pld_handler(struct chcr_dev *dev,
 
 int chcr_send_wr(struct sk_buff *skb)
 {
-	return cxgb4_ofld_send(skb->dev, skb);
+	return cxgb4_crypto_send(skb->dev, skb);
 }
 
 static void *chcr_uld_add(const struct cxgb4_lld_info *lld)
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 93e3d270a98a..4e5baf4fe15e 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -1481,6 +1481,7 @@ static int c4iw_uld_control(void *handle, enum cxgb4_control control, ...)
 static struct cxgb4_uld_info c4iw_uld_info = {
 	.name = DRV_NAME,
 	.nrxq = MAX_ULD_QSETS,
+	.ntxq = MAX_ULD_QSETS,
 	.rxq_size = 511,
 	.ciq = true,
 	.lro = false,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 2125903043fb..0bce1bf9ca0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -635,6 +635,7 @@ struct tx_sw_desc;
 
 struct sge_txq {
 	unsigned int  in_use;       /* # of in-use Tx descriptors */
+	unsigned int  q_type;	    /* Q type Eth/Ctrl/Ofld */
 	unsigned int  size;         /* # of descriptors */
 	unsigned int  cidx;         /* SW consumer index */
 	unsigned int  pidx;         /* producer index */
@@ -665,7 +666,7 @@ struct sge_eth_txq {                /* state for an SGE Ethernet Tx queue */
 	unsigned long mapping_err;  /* # of I/O MMU packet mapping errors */
 } ____cacheline_aligned_in_smp;
 
-struct sge_ofld_txq {               /* state for an SGE offload Tx queue */
+struct sge_uld_txq {               /* state for an SGE offload Tx queue */
 	struct sge_txq q;
 	struct adapter *adap;
 	struct sk_buff_head sendq;  /* list of backpressured packets */
@@ -693,14 +694,20 @@ struct sge_uld_rxq_info {
 	u8 uld;			/* uld type */
 };
 
+struct sge_uld_txq_info {
+	struct sge_uld_txq *uldtxq; /* Txq's for ULD */
+	atomic_t users;		/* num users */
+	u16 ntxq;		/* # of egress uld queues */
+};
+
 struct sge {
 	struct sge_eth_txq ethtxq[MAX_ETH_QSETS];
-	struct sge_ofld_txq ofldtxq[MAX_OFLD_QSETS];
 	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
 	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
 	struct sge_uld_rxq_info **uld_rxq_info;
+	struct sge_uld_txq_info **uld_txq_info;
 
 	struct sge_rspq intrq ____cacheline_aligned_in_smp;
 	spinlock_t intrq_lock;
@@ -1298,8 +1305,9 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 			  unsigned int cmplqid);
 int t4_sge_mod_ctrl_txq(struct adapter *adap, unsigned int eqid,
 			unsigned int cmplqid);
-int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
-			  struct net_device *dev, unsigned int iqid);
+int t4_sge_alloc_uld_txq(struct adapter *adap, struct sge_uld_txq *txq,
+			 struct net_device *dev, unsigned int iqid,
+			 unsigned int uld_type);
 irqreturn_t t4_sge_intr_msix(int irq, void *cookie);
 int t4_sge_init(struct adapter *adap);
 void t4_sge_start(struct adapter *adap);
@@ -1661,4 +1669,7 @@ int t4_uld_mem_alloc(struct adapter *adap);
 void t4_uld_clean_up(struct adapter *adap);
 void t4_register_netevent_notifier(void);
 void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
+void free_tx_desc(struct adapter *adap, struct sge_txq *q,
+		  unsigned int n, bool unmap);
+void free_txq(struct adapter *adap, struct sge_txq *q);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 20455d082cb8..acc231293e4d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2512,18 +2512,6 @@ do { \
 		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
-	} else if (ofld_idx < ofld_entries) {
-		const struct sge_ofld_txq *tx =
-			&adap->sge.ofldtxq[ofld_idx * 4];
-		int n = min(4, adap->sge.ofldqsets - 4 * ofld_idx);
-
-		S("QType:", "OFLD-Txq");
-		T("TxQ ID:", q.cntxt_id);
-		T("TxQ size:", q.size);
-		T("TxQ inuse:", q.in_use);
-		T("TxQ CIDX:", q.cidx);
-		T("TxQ PIDX:", q.pidx);
-
 	} else if (ctrl_idx < ctrl_entries) {
 		const struct sge_ctrl_txq *tx = &adap->sge.ctrlq[ctrl_idx * 4];
 		int n = min(4, adap->params.nports - 4 * ctrl_idx);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c0cc2ee77be7..449884f8dd67 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -530,15 +530,15 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 
 		txq = q->adap->sge.egr_map[qid - q->adap->sge.egr_start];
 		txq->restarts++;
-		if ((u8 *)txq < (u8 *)q->adap->sge.ofldtxq) {
+		if (txq->q_type == CXGB4_TXQ_ETH) {
 			struct sge_eth_txq *eq;
 
 			eq = container_of(txq, struct sge_eth_txq, q);
 			netif_tx_wake_queue(eq->txq);
 		} else {
-			struct sge_ofld_txq *oq;
+			struct sge_uld_txq *oq;
 
-			oq = container_of(txq, struct sge_ofld_txq, q);
+			oq = container_of(txq, struct sge_uld_txq, q);
 			tasklet_schedule(&oq->qresume_tsk);
 		}
 	} else if (opcode == CPL_FW6_MSG || opcode == CPL_FW4_MSG) {
@@ -885,15 +885,6 @@ static int setup_sge_queues(struct adapter *adap)
 		}
 	}
 
-	j = s->ofldqsets / adap->params.nports; /* iscsi queues per channel */
-	for_each_ofldtxq(s, i) {
-		err = t4_sge_alloc_ofld_txq(adap, &s->ofldtxq[i],
-					    adap->port[i / j],
-					    s->fw_evtq.cntxt_id);
-		if (err)
-			goto freeout;
-	}
-
 	for_each_port(adap, i) {
 		/* Note that cmplqid below is 0 if we don't
 		 * have RDMA queues, and that's the right value.
@@ -1922,8 +1913,18 @@ static void disable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		disable_txq_db(&adap->sge.ethtxq[i].q);
-	for_each_ofldtxq(&adap->sge, i)
-		disable_txq_db(&adap->sge.ofldtxq[i].q);
+	if (is_offload(adap)) {
+		struct sge_uld_txq_info *txq_info =
+			adap->sge.uld_txq_info[CXGB4_TX_OFLD];
+
+		if (txq_info) {
+			for_each_ofldtxq(&adap->sge, i) {
+				struct sge_uld_txq *txq = &txq_info->uldtxq[i];
+
+				disable_txq_db(&txq->q);
+			}
+		}
+	}
 	for_each_port(adap, i)
 		disable_txq_db(&adap->sge.ctrlq[i].q);
 }
@@ -1934,8 +1935,18 @@ static void enable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		enable_txq_db(adap, &adap->sge.ethtxq[i].q);
-	for_each_ofldtxq(&adap->sge, i)
-		enable_txq_db(adap, &adap->sge.ofldtxq[i].q);
+	if (is_offload(adap)) {
+		struct sge_uld_txq_info *txq_info =
+			adap->sge.uld_txq_info[CXGB4_TX_OFLD];
+
+		if (txq_info) {
+			for_each_ofldtxq(&adap->sge, i) {
+				struct sge_uld_txq *txq = &txq_info->uldtxq[i];
+
+				enable_txq_db(adap, &txq->q);
+			}
+		}
+	}
 	for_each_port(adap, i)
 		enable_txq_db(adap, &adap->sge.ctrlq[i].q);
 }
@@ -2006,8 +2017,17 @@ static void recover_all_queues(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		sync_txq_pidx(adap, &adap->sge.ethtxq[i].q);
-	for_each_ofldtxq(&adap->sge, i)
-		sync_txq_pidx(adap, &adap->sge.ofldtxq[i].q);
+	if (is_offload(adap)) {
+		struct sge_uld_txq_info *txq_info =
+			adap->sge.uld_txq_info[CXGB4_TX_OFLD];
+		if (txq_info) {
+			for_each_ofldtxq(&adap->sge, i) {
+				struct sge_uld_txq *txq = &txq_info->uldtxq[i];
+
+				sync_txq_pidx(adap, &txq->q);
+			}
+		}
+	}
 	for_each_port(adap, i)
 		sync_txq_pidx(adap, &adap->sge.ctrlq[i].q);
 }
@@ -3991,7 +4011,7 @@ static inline bool is_x_10g_port(const struct link_config *lc)
 static void cfg_queues(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	int i, n10g = 0, qidx = 0;
+	int i = 0, n10g = 0, qidx = 0;
 #ifndef CONFIG_CHELSIO_T4_DCB
 	int q10g = 0;
 #endif
@@ -4006,8 +4026,7 @@ static void cfg_queues(struct adapter *adap)
 		adap->params.crypto = 0;
 	}
 
-	for_each_port(adap, i)
-		n10g += is_x_10g_port(&adap2pinfo(adap, i)->link_cfg);
+	n10g += is_x_10g_port(&adap2pinfo(adap, i)->link_cfg);
 #ifdef CONFIG_CHELSIO_T4_DCB
 	/* For Data Center Bridging support we need to be able to support up
 	 * to 8 Traffic Priorities; each of which will be assigned to its
@@ -4075,9 +4094,6 @@ static void cfg_queues(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(s->ctrlq); i++)
 		s->ctrlq[i].q.size = 512;
 
-	for (i = 0; i < ARRAY_SIZE(s->ofldtxq); i++)
-		s->ofldtxq[i].q.size = 1024;
-
 	init_rspq(adap, &s->fw_evtq, 0, 1, 1024, 64);
 	init_rspq(adap, &s->intrq, 0, 1, 512, 64);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 2471ff465d5c..565a6c6bfeaf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -447,6 +447,106 @@ static void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
 		quiesce_rx(adap, &rxq_info->uldrxq[idx].rspq);
 }
 
+static void
+free_sge_txq_uld(struct adapter *adap, struct sge_uld_txq_info *txq_info)
+{
+	int nq = txq_info->ntxq;
+	int i;
+
+	for (i = 0; i < nq; i++) {
+		struct sge_uld_txq *txq = &txq_info->uldtxq[i];
+
+		if (txq && txq->q.desc) {
+			tasklet_kill(&txq->qresume_tsk);
+			t4_ofld_eq_free(adap, adap->mbox, adap->pf, 0,
+					txq->q.cntxt_id);
+			free_tx_desc(adap, &txq->q, txq->q.in_use, false);
+			kfree(txq->q.sdesc);
+			__skb_queue_purge(&txq->sendq);
+			free_txq(adap, &txq->q);
+		}
+	}
+}
+
+static int
+alloc_sge_txq_uld(struct adapter *adap, struct sge_uld_txq_info *txq_info,
+		  unsigned int uld_type)
+{
+	struct sge *s = &adap->sge;
+	int nq = txq_info->ntxq;
+	int i, j, err;
+
+	j = nq / adap->params.nports;
+	for (i = 0; i < nq; i++) {
+		struct sge_uld_txq *txq = &txq_info->uldtxq[i];
+
+		txq->q.size = 1024;
+		err = t4_sge_alloc_uld_txq(adap, txq, adap->port[i / j],
+					   s->fw_evtq.cntxt_id, uld_type);
+		if (err)
+			goto freeout;
+	}
+	return 0;
+freeout:
+	free_sge_txq_uld(adap, txq_info);
+	return err;
+}
+
+static void
+release_sge_txq_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_txq_info *txq_info = NULL;
+	int tx_uld_type = TX_ULD(uld_type);
+
+	txq_info = adap->sge.uld_txq_info[tx_uld_type];
+
+	if (txq_info && atomic_dec_and_test(&txq_info->users)) {
+		free_sge_txq_uld(adap, txq_info);
+		kfree(txq_info->uldtxq);
+		kfree(txq_info);
+		adap->sge.uld_txq_info[tx_uld_type] = NULL;
+	}
+}
+
+static int
+setup_sge_txq_uld(struct adapter *adap, unsigned int uld_type,
+		  const struct cxgb4_uld_info *uld_info)
+{
+	struct sge_uld_txq_info *txq_info = NULL;
+	int tx_uld_type, i;
+
+	tx_uld_type = TX_ULD(uld_type);
+	txq_info = adap->sge.uld_txq_info[tx_uld_type];
+
+	if ((tx_uld_type == CXGB4_TX_OFLD) && txq_info &&
+	    (atomic_inc_return(&txq_info->users) > 1))
+		return 0;
+
+	txq_info = kzalloc(sizeof(*txq_info), GFP_KERNEL);
+	if (!txq_info)
+		return -ENOMEM;
+
+	i = min_t(int, uld_info->ntxq, num_online_cpus());
+	txq_info->ntxq = roundup(i, adap->params.nports);
+
+	txq_info->uldtxq = kcalloc(txq_info->ntxq, sizeof(struct sge_uld_txq),
+				   GFP_KERNEL);
+	if (!txq_info->uldtxq) {
+		kfree(txq_info->uldtxq);
+		return -ENOMEM;
+	}
+
+	if (alloc_sge_txq_uld(adap, txq_info, tx_uld_type)) {
+		kfree(txq_info->uldtxq);
+		kfree(txq_info);
+		return -ENOMEM;
+	}
+
+	atomic_inc(&txq_info->users);
+	adap->sge.uld_txq_info[tx_uld_type] = txq_info;
+	return 0;
+}
+
 static void uld_queue_init(struct adapter *adap, unsigned int uld_type,
 			   struct cxgb4_lld_info *lli)
 {
@@ -472,7 +572,15 @@ int t4_uld_mem_alloc(struct adapter *adap)
 	if (!s->uld_rxq_info)
 		goto err_uld;
 
+	s->uld_txq_info = kzalloc(CXGB4_TX_MAX *
+				  sizeof(struct sge_uld_txq_info *),
+				  GFP_KERNEL);
+	if (!s->uld_txq_info)
+		goto err_uld_rx;
 	return 0;
+
+err_uld_rx:
+	kfree(s->uld_rxq_info);
 err_uld:
 	kfree(adap->uld);
 	return -ENOMEM;
@@ -482,6 +590,7 @@ void t4_uld_mem_free(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 
+	kfree(s->uld_txq_info);
 	kfree(s->uld_rxq_info);
 	kfree(adap->uld);
 }
@@ -616,6 +725,9 @@ int cxgb4_register_uld(enum cxgb4_uld type,
 			ret = -EBUSY;
 			goto free_irq;
 		}
+		ret = setup_sge_txq_uld(adap, type, p);
+		if (ret)
+			goto free_irq;
 		adap->uld[type] = *p;
 		uld_attach(adap, type);
 		adap_idx++;
@@ -644,6 +756,7 @@ int cxgb4_register_uld(enum cxgb4_uld type,
 			break;
 		adap->uld[type].handle = NULL;
 		adap->uld[type].add = NULL;
+		release_sge_txq_uld(adap, type);
 		if (adap->flags & FULL_INIT_DONE)
 			quiesce_rx_uld(adap, type);
 		if (adap->flags & USING_MSIX)
@@ -679,6 +792,7 @@ int cxgb4_unregister_uld(enum cxgb4_uld type)
 			continue;
 		adap->uld[type].handle = NULL;
 		adap->uld[type].add = NULL;
+		release_sge_txq_uld(adap, type);
 		if (adap->flags & FULL_INIT_DONE)
 			quiesce_rx_uld(adap, type);
 		if (adap->flags & USING_MSIX)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 2996793b1aaa..4c856605fdfa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -77,6 +77,8 @@ enum {
 
 /* Special asynchronous notification message */
 #define CXGB4_MSG_AN ((void *)1)
+#define TX_ULD(uld)(((uld) != CXGB4_ULD_CRYPTO) ? CXGB4_TX_OFLD :\
+		      CXGB4_TX_CRYPTO)
 
 struct serv_entry {
 	void *data;
@@ -223,6 +225,19 @@ enum cxgb4_uld {
 	CXGB4_ULD_MAX
 };
 
+enum cxgb4_tx_uld {
+	CXGB4_TX_OFLD,
+	CXGB4_TX_CRYPTO,
+	CXGB4_TX_MAX
+};
+
+enum cxgb4_txq_type {
+	CXGB4_TXQ_ETH,
+	CXGB4_TXQ_ULD,
+	CXGB4_TXQ_CTRL,
+	CXGB4_TXQ_MAX
+};
+
 enum cxgb4_state {
 	CXGB4_STATE_UP,
 	CXGB4_STATE_START_RECOVERY,
@@ -316,6 +331,7 @@ struct cxgb4_uld_info {
 	void *handle;
 	unsigned int nrxq;
 	unsigned int rxq_size;
+	unsigned int ntxq;
 	bool ciq;
 	bool lro;
 	void *(*add)(const struct cxgb4_lld_info *p);
@@ -333,6 +349,7 @@ struct cxgb4_uld_info {
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
 int cxgb4_unregister_uld(enum cxgb4_uld type);
 int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
+int cxgb4_crypto_send(struct net_device *dev, struct sk_buff *skb);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
 unsigned int cxgb4_port_viid(const struct net_device *dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 1e74fd6085df..b7d0753b9242 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -377,8 +377,8 @@ unmap:			dma_unmap_page(dev, be64_to_cpu(p->addr[0]),
  *	Reclaims Tx descriptors from an SGE Tx queue and frees the associated
  *	Tx buffers.  Called with the Tx queue lock held.
  */
-static void free_tx_desc(struct adapter *adap, struct sge_txq *q,
-			 unsigned int n, bool unmap)
+void free_tx_desc(struct adapter *adap, struct sge_txq *q,
+		  unsigned int n, bool unmap)
 {
 	struct tx_sw_desc *d;
 	unsigned int cidx = q->cidx;
@@ -1543,7 +1543,7 @@ static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
  *	inability to map packets.  A periodic timer attempts to restart
  *	queues so marked.
  */
-static void txq_stop_maperr(struct sge_ofld_txq *q)
+static void txq_stop_maperr(struct sge_uld_txq *q)
 {
 	q->mapping_err++;
 	q->q.stops++;
@@ -1559,7 +1559,7 @@ static void txq_stop_maperr(struct sge_ofld_txq *q)
  *	Stops an offload Tx queue that has become full and modifies the packet
  *	being written to request a wakeup.
  */
-static void ofldtxq_stop(struct sge_ofld_txq *q, struct sk_buff *skb)
+static void ofldtxq_stop(struct sge_uld_txq *q, struct sk_buff *skb)
 {
 	struct fw_wr_hdr *wr = (struct fw_wr_hdr *)skb->data;
 
@@ -1586,7 +1586,7 @@ static void ofldtxq_stop(struct sge_ofld_txq *q, struct sk_buff *skb)
  *	boolean "service_ofldq_running" to make sure that only one instance
  *	is ever running at a time ...
  */
-static void service_ofldq(struct sge_ofld_txq *q)
+static void service_ofldq(struct sge_uld_txq *q)
 {
 	u64 *pos, *before, *end;
 	int credits;
@@ -1706,7 +1706,7 @@ static void service_ofldq(struct sge_ofld_txq *q)
  *
  *	Send an offload packet through an SGE offload queue.
  */
-static int ofld_xmit(struct sge_ofld_txq *q, struct sk_buff *skb)
+static int ofld_xmit(struct sge_uld_txq *q, struct sk_buff *skb)
 {
 	skb->priority = calc_tx_flits_ofld(skb);       /* save for restart */
 	spin_lock(&q->sendq.lock);
@@ -1735,7 +1735,7 @@ static int ofld_xmit(struct sge_ofld_txq *q, struct sk_buff *skb)
  */
 static void restart_ofldq(unsigned long data)
 {
-	struct sge_ofld_txq *q = (struct sge_ofld_txq *)data;
+	struct sge_uld_txq *q = (struct sge_uld_txq *)data;
 
 	spin_lock(&q->sendq.lock);
 	q->full = 0;            /* the queue actually is completely empty now */
@@ -1767,17 +1767,23 @@ static inline unsigned int is_ctrl_pkt(const struct sk_buff *skb)
 	return skb->queue_mapping & 1;
 }
 
-static inline int ofld_send(struct adapter *adap, struct sk_buff *skb)
+static inline int uld_send(struct adapter *adap, struct sk_buff *skb,
+			   unsigned int tx_uld_type)
 {
+	struct sge_uld_txq_info *txq_info;
+	struct sge_uld_txq *txq;
 	unsigned int idx = skb_txq(skb);
 
+	txq_info = adap->sge.uld_txq_info[tx_uld_type];
+	txq = &txq_info->uldtxq[idx];
+
 	if (unlikely(is_ctrl_pkt(skb))) {
 		/* Single ctrl queue is a requirement for LE workaround path */
 		if (adap->tids.nsftids)
 			idx = 0;
 		return ctrl_xmit(&adap->sge.ctrlq[idx], skb);
 	}
-	return ofld_xmit(&adap->sge.ofldtxq[idx], skb);
+	return ofld_xmit(txq, skb);
 }
 
 /**
@@ -1794,7 +1800,7 @@ int t4_ofld_send(struct adapter *adap, struct sk_buff *skb)
 	int ret;
 
 	local_bh_disable();
-	ret = ofld_send(adap, skb);
+	ret = uld_send(adap, skb, CXGB4_TX_OFLD);
 	local_bh_enable();
 	return ret;
 }
@@ -1813,6 +1819,39 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
 
+/**
+ *	t4_crypto_send - send crypto packet
+ *	@adap: the adapter
+ *	@skb: the packet
+ *
+ *	Sends crypto packet.  We use the packet queue_mapping to select the
+ *	appropriate Tx queue as follows: bit 0 indicates whether the packet
+ *	should be sent as regular or control, bits 1-15 select the queue.
+ */
+static int t4_crypto_send(struct adapter *adap, struct sk_buff *skb)
+{
+	int ret;
+
+	local_bh_disable();
+	ret = uld_send(adap, skb, CXGB4_TX_CRYPTO);
+	local_bh_enable();
+	return ret;
+}
+
+/**
+ *	cxgb4_crypto_send - send crypto packet
+ *	@dev: the net device
+ *	@skb: the packet
+ *
+ *	Sends crypto packet.  This is an exported version of @t4_crypto_send,
+ *	intended for ULDs.
+ */
+int cxgb4_crypto_send(struct net_device *dev, struct sk_buff *skb)
+{
+	return t4_crypto_send(netdev2adap(dev), skb);
+}
+EXPORT_SYMBOL(cxgb4_crypto_send);
+
 static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
@@ -2479,7 +2518,7 @@ static void sge_tx_timer_cb(unsigned long data)
 	for (i = 0; i < BITS_TO_LONGS(s->egr_sz); i++)
 		for (m = s->txq_maperr[i]; m; m &= m - 1) {
 			unsigned long id = __ffs(m) + i * BITS_PER_LONG;
-			struct sge_ofld_txq *txq = s->egr_map[id];
+			struct sge_uld_txq *txq = s->egr_map[id];
 
 			clear_bit(id, s->txq_maperr);
 			tasklet_schedule(&txq->qresume_tsk);
@@ -2799,6 +2838,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 		return ret;
 	}
 
+	txq->q.q_type = CXGB4_TXQ_ETH;
 	init_txq(adap, &txq->q, FW_EQ_ETH_CMD_EQID_G(ntohl(c.eqid_pkd)));
 	txq->txq = netdevq;
 	txq->tso = txq->tx_cso = txq->vlan_ins = 0;
@@ -2852,6 +2892,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 		return ret;
 	}
 
+	txq->q.q_type = CXGB4_TXQ_CTRL;
 	init_txq(adap, &txq->q, FW_EQ_CTRL_CMD_EQID_G(ntohl(c.cmpliqid_eqid)));
 	txq->adap = adap;
 	skb_queue_head_init(&txq->sendq);
@@ -2872,13 +2913,15 @@ int t4_sge_mod_ctrl_txq(struct adapter *adap, unsigned int eqid,
 	return t4_set_params(adap, adap->mbox, adap->pf, 0, 1, &param, &val);
 }
 
-int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
-			  struct net_device *dev, unsigned int iqid)
+int t4_sge_alloc_uld_txq(struct adapter *adap, struct sge_uld_txq *txq,
+			 struct net_device *dev, unsigned int iqid,
+			 unsigned int uld_type)
 {
 	int ret, nentries;
 	struct fw_eq_ofld_cmd c;
 	struct sge *s = &adap->sge;
 	struct port_info *pi = netdev_priv(dev);
+	int cmd = FW_EQ_OFLD_CMD;
 
 	/* Add status entries */
 	nentries = txq->q.size + s->stat_len / sizeof(struct tx_desc);
@@ -2891,7 +2934,9 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 		return -ENOMEM;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
+	if (unlikely(uld_type == CXGB4_TX_CRYPTO))
+		cmd = FW_EQ_CTRL_CMD;
+	c.op_to_vfn = htonl(FW_CMD_OP_V(cmd) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
 			    FW_EQ_OFLD_CMD_PFN_V(adap->pf) |
 			    FW_EQ_OFLD_CMD_VFN_V(0));
@@ -2919,6 +2964,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 		return ret;
 	}
 
+	txq->q.q_type = CXGB4_TXQ_ULD;
 	init_txq(adap, &txq->q, FW_EQ_OFLD_CMD_EQID_G(ntohl(c.eqid_pkd)));
 	txq->adap = adap;
 	skb_queue_head_init(&txq->sendq);
@@ -2928,7 +2974,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 	return 0;
 }
 
-static void free_txq(struct adapter *adap, struct sge_txq *q)
+void free_txq(struct adapter *adap, struct sge_txq *q)
 {
 	struct sge *s = &adap->sge;
 
@@ -3026,21 +3072,6 @@ void t4_free_sge_resources(struct adapter *adap)
 		}
 	}
 
-	/* clean up offload Tx queues */
-	for (i = 0; i < ARRAY_SIZE(adap->sge.ofldtxq); i++) {
-		struct sge_ofld_txq *q = &adap->sge.ofldtxq[i];
-
-		if (q->q.desc) {
-			tasklet_kill(&q->qresume_tsk);
-			t4_ofld_eq_free(adap, adap->mbox, adap->pf, 0,
-					q->q.cntxt_id);
-			free_tx_desc(adap, &q->q, q->q.in_use, false);
-			kfree(q->q.sdesc);
-			__skb_queue_purge(&q->sendq);
-			free_txq(adap, &q->q);
-		}
-	}
-
 	/* clean up control Tx queues */
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ctrlq); i++) {
 		struct sge_ctrl_txq *cq = &adap->sge.ctrlq[i];
@@ -3093,12 +3124,34 @@ void t4_sge_stop(struct adapter *adap)
 	if (s->tx_timer.function)
 		del_timer_sync(&s->tx_timer);
 
-	for (i = 0; i < ARRAY_SIZE(s->ofldtxq); i++) {
-		struct sge_ofld_txq *q = &s->ofldtxq[i];
+	if (is_offload(adap)) {
+		struct sge_uld_txq_info *txq_info;
+
+		txq_info = adap->sge.uld_txq_info[CXGB4_TX_OFLD];
+		if (txq_info) {
+			struct sge_uld_txq *txq = txq_info->uldtxq;
 
-		if (q->q.desc)
-			tasklet_kill(&q->qresume_tsk);
+			for_each_ofldtxq(&adap->sge, i) {
+				if (txq->q.desc)
+					tasklet_kill(&txq->qresume_tsk);
+			}
+		}
 	}
+
+	if (is_pci_uld(adap)) {
+		struct sge_uld_txq_info *txq_info;
+
+		txq_info = adap->sge.uld_txq_info[CXGB4_TX_CRYPTO];
+		if (txq_info) {
+			struct sge_uld_txq *txq = txq_info->uldtxq;
+
+			for_each_ofldtxq(&adap->sge, i) {
+				if (txq->q.desc)
+					tasklet_kill(&txq->qresume_tsk);
+			}
+		}
+	}
+
 	for (i = 0; i < ARRAY_SIZE(s->ctrlq); i++) {
 		struct sge_ctrl_txq *cq = &s->ctrlq[i];
 
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 0039bebaa9e2..4655a9f9dcea 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -85,6 +85,7 @@ static inline int send_tx_flowc_wr(struct cxgbi_sock *);
 static const struct cxgb4_uld_info cxgb4i_uld_info = {
 	.name = DRV_MODULE_NAME,
 	.nrxq = MAX_ULD_QSETS,
+	.ntxq = MAX_ULD_QSETS,
 	.rxq_size = 1024,
 	.lro = false,
 	.add = t4_uld_add,
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_main.c b/drivers/target/iscsi/cxgbit/cxgbit_main.c
index ad26b9372f10..96eedfc49c94 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_main.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_main.c
@@ -653,6 +653,7 @@ static struct iscsit_transport cxgbit_transport = {
 static struct cxgb4_uld_info cxgbit_uld_info = {
 	.name		= DRV_NAME,
 	.nrxq		= MAX_ULD_QSETS,
+	.ntxq		= MAX_ULD_QSETS,
 	.rxq_size	= 1024,
 	.lro		= true,
 	.add		= cxgbit_uld_add,
-- 
2.3.4
