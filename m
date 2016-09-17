From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] chcr/cxgb4i/cxgbit/RDMA/cxgb4: Allocate resources dynamically for all cxgb4 ULD's
Date: Sat, 17 Sep 2016 08:12:39 +0530
Message-ID: <1474080159-14980-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nab@linux-iscsi.org, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, dledford@redhat.com,
        herbert@gondor.apana.org.au, varun@chelsio.com,
        nirranjan@chelsio.com, swise@opengridcomputing.com,
        atul.gupta@chelsio.com, rahul.lakkireddy@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate resources dynamically to cxgb4's Upper layer driver's(ULD) like
cxgbit, iw_cxgb4 and cxgb4i. Allocate resources when they register with
cxgb4 driver and free them while unregistering. All the queues and the
interrupts for them will be allocated during ULD probe only and freed
during remove.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/crypto/chelsio/chcr_core.c                 |   10 +-
 drivers/infiniband/hw/cxgb4/device.c               |    4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   47 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  127 +----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  613 +++++---------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c     |  223 ++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   31 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   18 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |    3 +
 drivers/target/iscsi/cxgbit/cxgbit_main.c          |    3 +
 10 files changed, 385 insertions(+), 694 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index 2f6156b..fb5f9bb 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -39,12 +39,10 @@ static chcr_handler_func work_handlers[NUM_CPL_CMDS] = {
 	[CPL_FW6_PLD] = cpl_fw6_pld_handler,
 };
 
-static struct cxgb4_pci_uld_info chcr_uld_info = {
+static struct cxgb4_uld_info chcr_uld_info = {
 	.name = DRV_MODULE_NAME,
-	.nrxq = 4,
+	.nrxq = MAX_ULD_QSETS,
 	.rxq_size = 1024,
-	.nciq = 0,
-	.ciq_size = 0,
 	.add = chcr_uld_add,
 	.state_change = chcr_uld_state_change,
 	.rx_handler = chcr_uld_rx_handler,
@@ -205,7 +203,7 @@ static int chcr_uld_state_change(void *handle, enum cxgb4_state state)
 
 static int __init chcr_crypto_init(void)
 {
-	if (cxgb4_register_pci_uld(CXGB4_PCI_ULD1, &chcr_uld_info)) {
+	if (cxgb4_register_uld(CXGB4_ULD_CRYPTO, &chcr_uld_info)) {
 		pr_err("ULD register fail: No chcr crypto support in cxgb4");
 		return -1;
 	}
@@ -228,7 +226,7 @@ static void __exit chcr_crypto_exit(void)
 		kfree(u_ctx);
 	}
 	mutex_unlock(&dev_mutex);
-	cxgb4_unregister_pci_uld(CXGB4_PCI_ULD1);
+	cxgb4_unregister_uld(CXGB4_ULD_CRYPTO);
 }
 
 module_init(chcr_crypto_init);
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 071d733..f170b63 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -1475,6 +1475,10 @@ static int c4iw_uld_control(void *handle, enum cxgb4_control control, ...)
 
 static struct cxgb4_uld_info c4iw_uld_info = {
 	.name = DRV_NAME,
+	.nrxq = MAX_ULD_QSETS,
+	.rxq_size = 511,
+	.ciq = true,
+	.lro = false,
 	.add = c4iw_uld_add,
 	.rx_handler = c4iw_uld_rx_handler,
 	.state_change = c4iw_uld_state_change,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4595569..1f9867d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -437,11 +437,6 @@ enum {
 	MAX_ETH_QSETS = 32,           /* # of Ethernet Tx/Rx queue sets */
 	MAX_OFLD_QSETS = 16,          /* # of offload Tx, iscsi Rx queue sets */
 	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
-	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
-	MAX_RDMA_CIQS = 32,        /* # of  RDMA concentrator IQs */
-
-	/* # of streaming iSCSIT Rx queues */
-	MAX_ISCSIT_QUEUES = MAX_OFLD_QSETS,
 };
 
 enum {
@@ -458,8 +453,7 @@ enum {
 enum {
 	INGQ_EXTRAS = 2,        /* firmware event queue and */
 				/*   forwarded interrupts */
-	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES +
-		   MAX_RDMA_CIQS + MAX_ISCSIT_QUEUES + INGQ_EXTRAS,
+	MAX_INGQ = MAX_ETH_QSETS + INGQ_EXTRAS,
 };
 
 struct adapter;
@@ -704,10 +698,6 @@ struct sge {
 	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
-	struct sge_ofld_rxq iscsirxq[MAX_OFLD_QSETS];
-	struct sge_ofld_rxq iscsitrxq[MAX_ISCSIT_QUEUES];
-	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
-	struct sge_ofld_rxq rdmaciq[MAX_RDMA_CIQS];
 	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
 	struct sge_uld_rxq_info **uld_rxq_info;
 
@@ -717,15 +707,8 @@ struct sge {
 	u16 max_ethqsets;           /* # of available Ethernet queue sets */
 	u16 ethqsets;               /* # of active Ethernet queue sets */
 	u16 ethtxq_rover;           /* Tx queue to clean up next */
-	u16 iscsiqsets;              /* # of active iSCSI queue sets */
-	u16 niscsitq;               /* # of available iSCST Rx queues */
-	u16 rdmaqs;                 /* # of available RDMA Rx queues */
-	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
+	u16 ofldqsets;              /* # of active ofld queue sets */
 	u16 nqs_per_uld;	    /* # of Rx queues per ULD */
-	u16 iscsi_rxq[MAX_OFLD_QSETS];
-	u16 iscsit_rxq[MAX_ISCSIT_QUEUES];
-	u16 rdma_rxq[MAX_RDMA_QUEUES];
-	u16 rdma_ciq[MAX_RDMA_CIQS];
 	u16 timer_val[SGE_NTIMERS];
 	u8 counter_val[SGE_NCOUNTERS];
 	u32 fl_pg_order;            /* large page allocation size */
@@ -749,10 +732,7 @@ struct sge {
 };
 
 #define for_each_ethrxq(sge, i) for (i = 0; i < (sge)->ethqsets; i++)
-#define for_each_iscsirxq(sge, i) for (i = 0; i < (sge)->iscsiqsets; i++)
-#define for_each_iscsitrxq(sge, i) for (i = 0; i < (sge)->niscsitq; i++)
-#define for_each_rdmarxq(sge, i) for (i = 0; i < (sge)->rdmaqs; i++)
-#define for_each_rdmaciq(sge, i) for (i = 0; i < (sge)->rdmaciqs; i++)
+#define for_each_ofldtxq(sge, i) for (i = 0; i < (sge)->ofldqsets; i++)
 
 struct l2t_data;
 
@@ -786,6 +766,7 @@ struct uld_msix_bmap {
 struct uld_msix_info {
 	unsigned short vec;
 	char desc[IFNAMSIZ + 10];
+	unsigned int idx;
 };
 
 struct vf_info {
@@ -818,7 +799,7 @@ struct adapter {
 	} msix_info[MAX_INGQ + 1];
 	struct uld_msix_info *msix_info_ulds; /* msix info for uld's */
 	struct uld_msix_bmap msix_bmap_ulds; /* msix bitmap for all uld */
-	unsigned int msi_idx;
+	int msi_idx;
 
 	struct doorbell_stats db_stats;
 	struct sge sge;
@@ -836,9 +817,10 @@ struct adapter {
 	unsigned int clipt_start;
 	unsigned int clipt_end;
 	struct clip_tbl *clipt;
-	struct cxgb4_pci_uld_info *uld;
+	struct cxgb4_uld_info *uld;
 	void *uld_handle[CXGB4_ULD_MAX];
 	unsigned int num_uld;
+	unsigned int num_ofld_uld;
 	struct list_head list_node;
 	struct list_head rcu_node;
 	struct list_head mac_hlist; /* list of MAC addresses in MPS Hash */
@@ -858,6 +840,8 @@ struct adapter {
 #define T4_OS_LOG_MBOX_CMDS 256
 	struct mbox_cmd_log *mbox_log;
 
+	struct mutex uld_mutex;
+
 	struct dentry *debugfs_root;
 	bool use_bd;     /* Use SGE Back Door intfc for reading SGE Contexts */
 	bool trace_rss;	/* 1 implies that different RSS flit per filter is
@@ -1051,6 +1035,11 @@ static inline int is_pci_uld(const struct adapter *adap)
 	return adap->params.crypto;
 }
 
+static inline int is_uld(const struct adapter *adap)
+{
+	return (adap->params.offload || adap->params.crypto);
+}
+
 static inline u32 t4_read_reg(struct adapter *adap, u32 reg_addr)
 {
 	return readl(adap->regs + reg_addr);
@@ -1277,6 +1266,8 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 			  struct net_device *dev, unsigned int iqid,
 			  unsigned int cmplqid);
+int t4_sge_mod_ctrl_txq(struct adapter *adap, unsigned int eqid,
+			unsigned int cmplqid);
 int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 			  struct net_device *dev, unsigned int iqid);
 irqreturn_t t4_sge_intr_msix(int irq, void *cookie);
@@ -1635,7 +1626,9 @@ void t4_idma_monitor(struct adapter *adapter,
 		     int hz, int ticks);
 int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
 		      unsigned int naddr, u8 *addr);
-void uld_mem_free(struct adapter *adap);
-int uld_mem_alloc(struct adapter *adap);
+void t4_uld_mem_free(struct adapter *adap);
+int t4_uld_mem_alloc(struct adapter *adap);
+void t4_uld_clean_up(struct adapter *adap);
+void t4_register_netevent_notifier(void);
 void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 91fb508..52be9a4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2432,17 +2432,11 @@ static int sge_qinfo_show(struct seq_file *seq, void *v)
 {
 	struct adapter *adap = seq->private;
 	int eth_entries = DIV_ROUND_UP(adap->sge.ethqsets, 4);
-	int iscsi_entries = DIV_ROUND_UP(adap->sge.iscsiqsets, 4);
-	int iscsit_entries = DIV_ROUND_UP(adap->sge.niscsitq, 4);
-	int rdma_entries = DIV_ROUND_UP(adap->sge.rdmaqs, 4);
-	int ciq_entries = DIV_ROUND_UP(adap->sge.rdmaciqs, 4);
+	int ofld_entries = DIV_ROUND_UP(adap->sge.ofldqsets, 4);
 	int ctrl_entries = DIV_ROUND_UP(MAX_CTRL_QUEUES, 4);
 	int i, r = (uintptr_t)v - 1;
-	int iscsi_idx = r - eth_entries;
-	int iscsit_idx = iscsi_idx - iscsi_entries;
-	int rdma_idx = iscsit_idx - iscsit_entries;
-	int ciq_idx = rdma_idx - rdma_entries;
-	int ctrl_idx =  ciq_idx - ciq_entries;
+	int ofld_idx = r - eth_entries;
+	int ctrl_idx =  ofld_idx - ofld_entries;
 	int fq_idx =  ctrl_idx - ctrl_entries;
 
 	if (r)
@@ -2518,119 +2512,17 @@ do { \
 		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
-	} else if (iscsi_idx < iscsi_entries) {
-		const struct sge_ofld_rxq *rx =
-			&adap->sge.iscsirxq[iscsi_idx * 4];
+	} else if (ofld_idx < ofld_entries) {
 		const struct sge_ofld_txq *tx =
-			&adap->sge.ofldtxq[iscsi_idx * 4];
-		int n = min(4, adap->sge.iscsiqsets - 4 * iscsi_idx);
+			&adap->sge.ofldtxq[ofld_idx * 4];
+		int n = min(4, adap->sge.ofldqsets - 4 * ofld_idx);
 
-		S("QType:", "iSCSI");
+		S("QType:", "OFLD-Txq");
 		T("TxQ ID:", q.cntxt_id);
 		T("TxQ size:", q.size);
 		T("TxQ inuse:", q.in_use);
 		T("TxQ CIDX:", q.cidx);
 		T("TxQ PIDX:", q.pidx);
-		R("RspQ ID:", rspq.abs_id);
-		R("RspQ size:", rspq.size);
-		R("RspQE size:", rspq.iqe_len);
-		R("RspQ CIDX:", rspq.cidx);
-		R("RspQ Gen:", rspq.gen);
-		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
-		S3("u", "Intr pktcnt:",
-		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
-		R("FL ID:", fl.cntxt_id);
-		R("FL size:", fl.size - 8);
-		R("FL pend:", fl.pend_cred);
-		R("FL avail:", fl.avail);
-		R("FL PIDX:", fl.pidx);
-		R("FL CIDX:", fl.cidx);
-		RL("RxPackets:", stats.pkts);
-		RL("RxImmPkts:", stats.imm);
-		RL("RxNoMem:", stats.nomem);
-		RL("FLAllocErr:", fl.alloc_failed);
-		RL("FLLrgAlcErr:", fl.large_alloc_failed);
-		RL("FLMapErr:", fl.mapping_err);
-		RL("FLLow:", fl.low);
-		RL("FLStarving:", fl.starving);
-
-	} else if (iscsit_idx < iscsit_entries) {
-		const struct sge_ofld_rxq *rx =
-			&adap->sge.iscsitrxq[iscsit_idx * 4];
-		int n = min(4, adap->sge.niscsitq - 4 * iscsit_idx);
-
-		S("QType:", "iSCSIT");
-		R("RspQ ID:", rspq.abs_id);
-		R("RspQ size:", rspq.size);
-		R("RspQE size:", rspq.iqe_len);
-		R("RspQ CIDX:", rspq.cidx);
-		R("RspQ Gen:", rspq.gen);
-		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
-		S3("u", "Intr pktcnt:",
-		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
-		R("FL ID:", fl.cntxt_id);
-		R("FL size:", fl.size - 8);
-		R("FL pend:", fl.pend_cred);
-		R("FL avail:", fl.avail);
-		R("FL PIDX:", fl.pidx);
-		R("FL CIDX:", fl.cidx);
-		RL("RxPackets:", stats.pkts);
-		RL("RxImmPkts:", stats.imm);
-		RL("RxNoMem:", stats.nomem);
-		RL("FLAllocErr:", fl.alloc_failed);
-		RL("FLLrgAlcErr:", fl.large_alloc_failed);
-		RL("FLMapErr:", fl.mapping_err);
-		RL("FLLow:", fl.low);
-		RL("FLStarving:", fl.starving);
-
-	} else if (rdma_idx < rdma_entries) {
-		const struct sge_ofld_rxq *rx =
-				&adap->sge.rdmarxq[rdma_idx * 4];
-		int n = min(4, adap->sge.rdmaqs - 4 * rdma_idx);
-
-		S("QType:", "RDMA-CPL");
-		S("Interface:",
-		  rx[i].rspq.netdev ? rx[i].rspq.netdev->name : "N/A");
-		R("RspQ ID:", rspq.abs_id);
-		R("RspQ size:", rspq.size);
-		R("RspQE size:", rspq.iqe_len);
-		R("RspQ CIDX:", rspq.cidx);
-		R("RspQ Gen:", rspq.gen);
-		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
-		S3("u", "Intr pktcnt:",
-		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
-		R("FL ID:", fl.cntxt_id);
-		R("FL size:", fl.size - 8);
-		R("FL pend:", fl.pend_cred);
-		R("FL avail:", fl.avail);
-		R("FL PIDX:", fl.pidx);
-		R("FL CIDX:", fl.cidx);
-		RL("RxPackets:", stats.pkts);
-		RL("RxImmPkts:", stats.imm);
-		RL("RxNoMem:", stats.nomem);
-		RL("FLAllocErr:", fl.alloc_failed);
-		RL("FLLrgAlcErr:", fl.large_alloc_failed);
-		RL("FLMapErr:", fl.mapping_err);
-		RL("FLLow:", fl.low);
-		RL("FLStarving:", fl.starving);
-
-	} else if (ciq_idx < ciq_entries) {
-		const struct sge_ofld_rxq *rx = &adap->sge.rdmaciq[ciq_idx * 4];
-		int n = min(4, adap->sge.rdmaciqs - 4 * ciq_idx);
-
-		S("QType:", "RDMA-CIQ");
-		S("Interface:",
-		  rx[i].rspq.netdev ? rx[i].rspq.netdev->name : "N/A");
-		R("RspQ ID:", rspq.abs_id);
-		R("RspQ size:", rspq.size);
-		R("RspQE size:", rspq.iqe_len);
-		R("RspQ CIDX:", rspq.cidx);
-		R("RspQ Gen:", rspq.gen);
-		S3("u", "Intr delay:", qtimer_val(adap, &rx[i].rspq));
-		S3("u", "Intr pktcnt:",
-		   adap->sge.counter_val[rx[i].rspq.pktcnt_idx]);
-		RL("RxAN:", stats.an);
-		RL("RxNoMem:", stats.nomem);
 
 	} else if (ctrl_idx < ctrl_entries) {
 		const struct sge_ctrl_txq *tx = &adap->sge.ctrlq[ctrl_idx * 4];
@@ -2672,10 +2564,7 @@ do { \
 static int sge_queue_entries(const struct adapter *adap)
 {
 	return DIV_ROUND_UP(adap->sge.ethqsets, 4) +
-	       DIV_ROUND_UP(adap->sge.iscsiqsets, 4) +
-	       DIV_ROUND_UP(adap->sge.niscsitq, 4) +
-	       DIV_ROUND_UP(adap->sge.rdmaqs, 4) +
-	       DIV_ROUND_UP(adap->sge.rdmaciqs, 4) +
+	       DIV_ROUND_UP(adap->sge.ofldqsets, 4) +
 	       DIV_ROUND_UP(MAX_CTRL_QUEUES, 4) + 1;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 44cc976..d1ebb84 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -226,11 +226,6 @@ static struct dentry *cxgb4_debugfs_root;
 
 LIST_HEAD(adapter_list);
 DEFINE_MUTEX(uld_mutex);
-/* Adapter list to be accessed from atomic context */
-static LIST_HEAD(adap_rcu_list);
-static DEFINE_SPINLOCK(adap_rcu_lock);
-static struct cxgb4_uld_info ulds[CXGB4_ULD_MAX];
-static const char *const uld_str[] = { "RDMA", "iSCSI", "iSCSIT" };
 
 static void link_report(struct net_device *dev)
 {
@@ -678,56 +673,6 @@ out:
 	return 0;
 }
 
-/* Flush the aggregated lro sessions */
-static void uldrx_flush_handler(struct sge_rspq *q)
-{
-	if (ulds[q->uld].lro_flush)
-		ulds[q->uld].lro_flush(&q->lro_mgr);
-}
-
-/**
- *	uldrx_handler - response queue handler for ULD queues
- *	@q: the response queue that received the packet
- *	@rsp: the response queue descriptor holding the offload message
- *	@gl: the gather list of packet fragments
- *
- *	Deliver an ingress offload packet to a ULD.  All processing is done by
- *	the ULD, we just maintain statistics.
- */
-static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
-			 const struct pkt_gl *gl)
-{
-	struct sge_ofld_rxq *rxq = container_of(q, struct sge_ofld_rxq, rspq);
-	int ret;
-
-	/* FW can send CPLs encapsulated in a CPL_FW4_MSG.
-	 */
-	if (((const struct rss_header *)rsp)->opcode == CPL_FW4_MSG &&
-	    ((const struct cpl_fw4_msg *)(rsp + 1))->type == FW_TYPE_RSSCPL)
-		rsp += 2;
-
-	if (q->flush_handler)
-		ret = ulds[q->uld].lro_rx_handler(q->adap->uld_handle[q->uld],
-						  rsp, gl, &q->lro_mgr,
-						  &q->napi);
-	else
-		ret = ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld],
-					      rsp, gl);
-
-	if (ret) {
-		rxq->stats.nomem++;
-		return -1;
-	}
-
-	if (gl == NULL)
-		rxq->stats.imm++;
-	else if (gl == CXGB4_MSG_AN)
-		rxq->stats.an++;
-	else
-		rxq->stats.pkts++;
-	return 0;
-}
-
 static void disable_msi(struct adapter *adapter)
 {
 	if (adapter->flags & USING_MSIX) {
@@ -779,30 +724,12 @@ static void name_msix_vecs(struct adapter *adap)
 			snprintf(adap->msix_info[msi_idx].desc, n, "%s-Rx%d",
 				 d->name, i);
 	}
-
-	/* offload queues */
-	for_each_iscsirxq(&adap->sge, i)
-		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-iscsi%d",
-			 adap->port[0]->name, i);
-
-	for_each_iscsitrxq(&adap->sge, i)
-		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-iSCSIT%d",
-			 adap->port[0]->name, i);
-
-	for_each_rdmarxq(&adap->sge, i)
-		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-rdma%d",
-			 adap->port[0]->name, i);
-
-	for_each_rdmaciq(&adap->sge, i)
-		snprintf(adap->msix_info[msi_idx++].desc, n, "%s-rdma-ciq%d",
-			 adap->port[0]->name, i);
 }
 
 static int request_msix_queue_irqs(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	int err, ethqidx, iscsiqidx = 0, rdmaqidx = 0, rdmaciqqidx = 0;
-	int iscsitqidx = 0;
+	int err, ethqidx;
 	int msi_index = 2;
 
 	err = request_irq(adap->msix_info[1].vec, t4_sge_intr_msix, 0,
@@ -819,57 +746,9 @@ static int request_msix_queue_irqs(struct adapter *adap)
 			goto unwind;
 		msi_index++;
 	}
-	for_each_iscsirxq(s, iscsiqidx) {
-		err = request_irq(adap->msix_info[msi_index].vec,
-				  t4_sge_intr_msix, 0,
-				  adap->msix_info[msi_index].desc,
-				  &s->iscsirxq[iscsiqidx].rspq);
-		if (err)
-			goto unwind;
-		msi_index++;
-	}
-	for_each_iscsitrxq(s, iscsitqidx) {
-		err = request_irq(adap->msix_info[msi_index].vec,
-				  t4_sge_intr_msix, 0,
-				  adap->msix_info[msi_index].desc,
-				  &s->iscsitrxq[iscsitqidx].rspq);
-		if (err)
-			goto unwind;
-		msi_index++;
-	}
-	for_each_rdmarxq(s, rdmaqidx) {
-		err = request_irq(adap->msix_info[msi_index].vec,
-				  t4_sge_intr_msix, 0,
-				  adap->msix_info[msi_index].desc,
-				  &s->rdmarxq[rdmaqidx].rspq);
-		if (err)
-			goto unwind;
-		msi_index++;
-	}
-	for_each_rdmaciq(s, rdmaciqqidx) {
-		err = request_irq(adap->msix_info[msi_index].vec,
-				  t4_sge_intr_msix, 0,
-				  adap->msix_info[msi_index].desc,
-				  &s->rdmaciq[rdmaciqqidx].rspq);
-		if (err)
-			goto unwind;
-		msi_index++;
-	}
 	return 0;
 
 unwind:
-	while (--rdmaciqqidx >= 0)
-		free_irq(adap->msix_info[--msi_index].vec,
-			 &s->rdmaciq[rdmaciqqidx].rspq);
-	while (--rdmaqidx >= 0)
-		free_irq(adap->msix_info[--msi_index].vec,
-			 &s->rdmarxq[rdmaqidx].rspq);
-	while (--iscsitqidx >= 0)
-		free_irq(adap->msix_info[--msi_index].vec,
-			 &s->iscsitrxq[iscsitqidx].rspq);
-	while (--iscsiqidx >= 0)
-		free_irq(adap->msix_info[--msi_index].vec,
-			 &s->iscsirxq[iscsiqidx].rspq);
 	while (--ethqidx >= 0)
 		free_irq(adap->msix_info[--msi_index].vec,
 			 &s->ethrxq[ethqidx].rspq);
@@ -885,16 +764,6 @@ static void free_msix_queue_irqs(struct adapter *adap)
 	free_irq(adap->msix_info[1].vec, &s->fw_evtq);
 	for_each_ethrxq(s, i)
 		free_irq(adap->msix_info[msi_index++].vec, &s->ethrxq[i].rspq);
-	for_each_iscsirxq(s, i)
-		free_irq(adap->msix_info[msi_index++].vec,
-			 &s->iscsirxq[i].rspq);
-	for_each_iscsitrxq(s, i)
-		free_irq(adap->msix_info[msi_index++].vec,
-			 &s->iscsitrxq[i].rspq);
-	for_each_rdmarxq(s, i)
-		free_irq(adap->msix_info[msi_index++].vec, &s->rdmarxq[i].rspq);
-	for_each_rdmaciq(s, i)
-		free_irq(adap->msix_info[msi_index++].vec, &s->rdmaciq[i].rspq);
 }
 
 /**
@@ -1033,42 +902,11 @@ static void enable_rx(struct adapter *adap)
 	}
 }
 
-static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
-			   unsigned int nq, unsigned int per_chan, int msi_idx,
-			   u16 *ids, bool lro)
-{
-	int i, err;
-
-	for (i = 0; i < nq; i++, q++) {
-		if (msi_idx > 0)
-			msi_idx++;
-		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
-				       adap->port[i / per_chan],
-				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler,
-				       lro ? uldrx_flush_handler : NULL,
-				       0);
-		if (err)
-			return err;
-		memset(&q->stats, 0, sizeof(q->stats));
-		if (ids)
-			ids[i] = q->rspq.abs_id;
-	}
-	return 0;
-}
 
-/**
- *	setup_sge_queues - configure SGE Tx/Rx/response queues
- *	@adap: the adapter
- *
- *	Determines how many sets of SGE queues to use and initializes them.
- *	We support multiple queue sets per port if we have MSI-X, otherwise
- *	just one queue set per port.
- */
-static int setup_sge_queues(struct adapter *adap)
+static int setup_fw_sge_queues(struct adapter *adap)
 {
-	int err, i, j;
 	struct sge *s = &adap->sge;
+	int err = 0;
 
 	bitmap_zero(s->starving_fl, s->egr_sz);
 	bitmap_zero(s->txq_maperr, s->egr_sz);
@@ -1083,25 +921,27 @@ static int setup_sge_queues(struct adapter *adap)
 		adap->msi_idx = -((int)s->intrq.abs_id + 1);
 	}
 
-	/* NOTE: If you add/delete any Ingress/Egress Queue allocations in here,
-	 * don't forget to update the following which need to be
-	 * synchronized to and changes here.
-	 *
-	 * 1. The calculations of MAX_INGQ in cxgb4.h.
-	 *
-	 * 2. Update enable_msix/name_msix_vecs/request_msix_queue_irqs
-	 *    to accommodate any new/deleted Ingress Queues
-	 *    which need MSI-X Vectors.
-	 *
-	 * 3. Update sge_qinfo_show() to include information on the
-	 *    new/deleted queues.
-	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
 			       adap->msi_idx, NULL, fwevtq_handler, NULL, -1);
-	if (err) {
-freeout:	t4_free_sge_resources(adap);
-		return err;
-	}
+	if (err)
+		t4_free_sge_resources(adap);
+	return err;
+}
+
+/**
+ *	setup_sge_queues - configure SGE Tx/Rx/response queues
+ *	@adap: the adapter
+ *
+ *	Determines how many sets of SGE queues to use and initializes them.
+ *	We support multiple queue sets per port if we have MSI-X, otherwise
+ *	just one queue set per port.
+ */
+static int setup_sge_queues(struct adapter *adap)
+{
+	int err, i, j;
+	struct sge *s = &adap->sge;
+	struct sge_uld_rxq_info *rxq_info = s->uld_rxq_info[CXGB4_ULD_RDMA];
+	unsigned int cmplqid = 0;
 
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
@@ -1132,8 +972,8 @@ freeout:	t4_free_sge_resources(adap);
 		}
 	}
 
-	j = s->iscsiqsets / adap->params.nports; /* iscsi queues per channel */
-	for_each_iscsirxq(s, i) {
+	j = s->ofldqsets / adap->params.nports; /* iscsi queues per channel */
+	for_each_ofldtxq(s, i) {
 		err = t4_sge_alloc_ofld_txq(adap, &s->ofldtxq[i],
 					    adap->port[i / j],
 					    s->fw_evtq.cntxt_id);
@@ -1141,30 +981,15 @@ freeout:	t4_free_sge_resources(adap);
 			goto freeout;
 	}
 
-#define ALLOC_OFLD_RXQS(firstq, nq, per_chan, ids, lro) do { \
-	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, adap->msi_idx, ids, lro); \
-	if (err) \
-		goto freeout; \
-	if (adap->msi_idx > 0) \
-		adap->msi_idx += nq; \
-} while (0)
-
-	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq, false);
-	ALLOC_OFLD_RXQS(s->iscsitrxq, s->niscsitq, j, s->iscsit_rxq, true);
-	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq, false);
-	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
-	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq, false);
-
-#undef ALLOC_OFLD_RXQS
-
 	for_each_port(adap, i) {
-		/*
-		 * Note that ->rdmarxq[i].rspq.cntxt_id below is 0 if we don't
+		/* Note that cmplqid below is 0 if we don't
 		 * have RDMA queues, and that's the right value.
 		 */
+		if (rxq_info)
+			cmplqid	= rxq_info->uldrxq[i].rspq.cntxt_id;
+
 		err = t4_sge_alloc_ctrl_txq(adap, &s->ctrlq[i], adap->port[i],
-					    s->fw_evtq.cntxt_id,
-					    s->rdmarxq[i].rspq.cntxt_id);
+					    s->fw_evtq.cntxt_id, cmplqid);
 		if (err)
 			goto freeout;
 	}
@@ -1175,6 +1000,9 @@ freeout:	t4_free_sge_resources(adap);
 		     RSSCONTROL_V(netdev2pinfo(adap->port[0])->tx_chan) |
 		     QUEUENUMBER_V(s->ethrxq[0].rspq.abs_id));
 	return 0;
+freeout:
+	t4_free_sge_resources(adap);
+	return err;
 }
 
 /*
@@ -2317,7 +2145,7 @@ static void disable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		disable_txq_db(&adap->sge.ethtxq[i].q);
-	for_each_iscsirxq(&adap->sge, i)
+	for_each_ofldtxq(&adap->sge, i)
 		disable_txq_db(&adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		disable_txq_db(&adap->sge.ctrlq[i].q);
@@ -2329,7 +2157,7 @@ static void enable_dbs(struct adapter *adap)
 
 	for_each_ethrxq(&adap->sge, i)
 		enable_txq_db(adap, &adap->sge.ethtxq[i].q);
-	for_each_iscsirxq(&adap->sge, i)
+	for_each_ofldtxq(&adap->sge, i)
 		enable_txq_db(adap, &adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		enable_txq_db(adap, &adap->sge.ctrlq[i].q);
@@ -2337,9 +2165,10 @@ static void enable_dbs(struct adapter *adap)
 
 static void notify_rdma_uld(struct adapter *adap, enum cxgb4_control cmd)
 {
-	if (adap->uld_handle[CXGB4_ULD_RDMA])
-		ulds[CXGB4_ULD_RDMA].control(adap->uld_handle[CXGB4_ULD_RDMA],
-				cmd);
+	enum cxgb4_uld type = CXGB4_ULD_RDMA;
+
+	if (adap->uld && adap->uld[type].handle)
+		adap->uld[type].control(adap->uld[type].handle, cmd);
 }
 
 static void process_db_full(struct work_struct *work)
@@ -2393,13 +2222,14 @@ out:
 	if (ret)
 		CH_WARN(adap, "DB drop recovery failed.\n");
 }
+
 static void recover_all_queues(struct adapter *adap)
 {
 	int i;
 
 	for_each_ethrxq(&adap->sge, i)
 		sync_txq_pidx(adap, &adap->sge.ethtxq[i].q);
-	for_each_iscsirxq(&adap->sge, i)
+	for_each_ofldtxq(&adap->sge, i)
 		sync_txq_pidx(adap, &adap->sge.ofldtxq[i].q);
 	for_each_port(adap, i)
 		sync_txq_pidx(adap, &adap->sge.ctrlq[i].q);
@@ -2464,94 +2294,12 @@ void t4_db_dropped(struct adapter *adap)
 	queue_work(adap->workq, &adap->db_drop_task);
 }
 
-static void uld_attach(struct adapter *adap, unsigned int uld)
-{
-	void *handle;
-	struct cxgb4_lld_info lli;
-	unsigned short i;
-
-	lli.pdev = adap->pdev;
-	lli.pf = adap->pf;
-	lli.l2t = adap->l2t;
-	lli.tids = &adap->tids;
-	lli.ports = adap->port;
-	lli.vr = &adap->vres;
-	lli.mtus = adap->params.mtus;
-	if (uld == CXGB4_ULD_RDMA) {
-		lli.rxq_ids = adap->sge.rdma_rxq;
-		lli.ciq_ids = adap->sge.rdma_ciq;
-		lli.nrxq = adap->sge.rdmaqs;
-		lli.nciq = adap->sge.rdmaciqs;
-	} else if (uld == CXGB4_ULD_ISCSI) {
-		lli.rxq_ids = adap->sge.iscsi_rxq;
-		lli.nrxq = adap->sge.iscsiqsets;
-	} else if (uld == CXGB4_ULD_ISCSIT) {
-		lli.rxq_ids = adap->sge.iscsit_rxq;
-		lli.nrxq = adap->sge.niscsitq;
-	}
-	lli.ntxq = adap->sge.iscsiqsets;
-	lli.nchan = adap->params.nports;
-	lli.nports = adap->params.nports;
-	lli.wr_cred = adap->params.ofldq_wr_cred;
-	lli.adapter_type = adap->params.chip;
-	lli.iscsi_iolen = MAXRXDATA_G(t4_read_reg(adap, TP_PARA_REG2_A));
-	lli.iscsi_tagmask = t4_read_reg(adap, ULP_RX_ISCSI_TAGMASK_A);
-	lli.iscsi_pgsz_order = t4_read_reg(adap, ULP_RX_ISCSI_PSZ_A);
-	lli.iscsi_llimit = t4_read_reg(adap, ULP_RX_ISCSI_LLIMIT_A);
-	lli.iscsi_ppm = &adap->iscsi_ppm;
-	lli.cclk_ps = 1000000000 / adap->params.vpd.cclk;
-	lli.udb_density = 1 << adap->params.sge.eq_qpp;
-	lli.ucq_density = 1 << adap->params.sge.iq_qpp;
-	lli.filt_mode = adap->params.tp.vlan_pri_map;
-	/* MODQ_REQ_MAP sets queues 0-3 to chan 0-3 */
-	for (i = 0; i < NCHAN; i++)
-		lli.tx_modq[i] = i;
-	lli.gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS_A);
-	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL_A);
-	lli.fw_vers = adap->params.fw_vers;
-	lli.dbfifo_int_thresh = dbfifo_int_thresh;
-	lli.sge_ingpadboundary = adap->sge.fl_align;
-	lli.sge_egrstatuspagesize = adap->sge.stat_len;
-	lli.sge_pktshift = adap->sge.pktshift;
-	lli.enable_fw_ofld_conn = adap->flags & FW_OFLD_CONN;
-	lli.max_ordird_qp = adap->params.max_ordird_qp;
-	lli.max_ird_adapter = adap->params.max_ird_adapter;
-	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
-	lli.nodeid = dev_to_node(adap->pdev_dev);
-
-	handle = ulds[uld].add(&lli);
-	if (IS_ERR(handle)) {
-		dev_warn(adap->pdev_dev,
-			 "could not attach to the %s driver, error %ld\n",
-			 uld_str[uld], PTR_ERR(handle));
-		return;
-	}
-
-	adap->uld_handle[uld] = handle;
-
+void t4_register_netevent_notifier(void)
+{
 	if (!netevent_registered) {
 		register_netevent_notifier(&cxgb4_netevent_nb);
 		netevent_registered = true;
 	}
-
-	if (adap->flags & FULL_INIT_DONE)
-		ulds[uld].state_change(handle, CXGB4_STATE_UP);
-}
-
-static void attach_ulds(struct adapter *adap)
-{
-	unsigned int i;
-
-	spin_lock(&adap_rcu_lock);
-	list_add_tail_rcu(&adap->rcu_node, &adap_rcu_list);
-	spin_unlock(&adap_rcu_lock);
-
-	mutex_lock(&uld_mutex);
-	list_add_tail(&adap->list_node, &adapter_list);
-	for (i = 0; i < CXGB4_ULD_MAX; i++)
-		if (ulds[i].add)
-			uld_attach(adap, i);
-	mutex_unlock(&uld_mutex);
 }
 
 static void detach_ulds(struct adapter *adap)
@@ -2561,12 +2309,6 @@ static void detach_ulds(struct adapter *adap)
 	mutex_lock(&uld_mutex);
 	list_del(&adap->list_node);
 	for (i = 0; i < CXGB4_ULD_MAX; i++)
-		if (adap->uld_handle[i]) {
-			ulds[i].state_change(adap->uld_handle[i],
-					     CXGB4_STATE_DETACH);
-			adap->uld_handle[i] = NULL;
-		}
-	for (i = 0; i < CXGB4_PCI_ULD_MAX; i++)
 		if (adap->uld && adap->uld[i].handle) {
 			adap->uld[i].state_change(adap->uld[i].handle,
 					     CXGB4_STATE_DETACH);
@@ -2577,10 +2319,6 @@ static void detach_ulds(struct adapter *adap)
 		netevent_registered = false;
 	}
 	mutex_unlock(&uld_mutex);
-
-	spin_lock(&adap_rcu_lock);
-	list_del_rcu(&adap->rcu_node);
-	spin_unlock(&adap_rcu_lock);
 }
 
 static void notify_ulds(struct adapter *adap, enum cxgb4_state new_state)
@@ -2589,65 +2327,12 @@ static void notify_ulds(struct adapter *adap, enum cxgb4_state new_state)
 
 	mutex_lock(&uld_mutex);
 	for (i = 0; i < CXGB4_ULD_MAX; i++)
-		if (adap->uld_handle[i])
-			ulds[i].state_change(adap->uld_handle[i], new_state);
-	for (i = 0; i < CXGB4_PCI_ULD_MAX; i++)
 		if (adap->uld && adap->uld[i].handle)
 			adap->uld[i].state_change(adap->uld[i].handle,
 						  new_state);
 	mutex_unlock(&uld_mutex);
 }
 
-/**
- *	cxgb4_register_uld - register an upper-layer driver
- *	@type: the ULD type
- *	@p: the ULD methods
- *
- *	Registers an upper-layer driver with this driver and notifies the ULD
- *	about any presently available devices that support its type.  Returns
- *	%-EBUSY if a ULD of the same type is already registered.
- */
-int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p)
-{
-	int ret = 0;
-	struct adapter *adap;
-
-	if (type >= CXGB4_ULD_MAX)
-		return -EINVAL;
-	mutex_lock(&uld_mutex);
-	if (ulds[type].add) {
-		ret = -EBUSY;
-		goto out;
-	}
-	ulds[type] = *p;
-	list_for_each_entry(adap, &adapter_list, list_node)
-		uld_attach(adap, type);
-out:	mutex_unlock(&uld_mutex);
-	return ret;
-}
-EXPORT_SYMBOL(cxgb4_register_uld);
-
-/**
- *	cxgb4_unregister_uld - unregister an upper-layer driver
- *	@type: the ULD type
- *
- *	Unregisters an existing upper-layer driver.
- */
-int cxgb4_unregister_uld(enum cxgb4_uld type)
-{
-	struct adapter *adap;
-
-	if (type >= CXGB4_ULD_MAX)
-		return -EINVAL;
-	mutex_lock(&uld_mutex);
-	list_for_each_entry(adap, &adapter_list, list_node)
-		adap->uld_handle[type] = NULL;
-	ulds[type].add = NULL;
-	mutex_unlock(&uld_mutex);
-	return 0;
-}
-EXPORT_SYMBOL(cxgb4_unregister_uld);
-
 #if IS_ENABLED(CONFIG_IPV6)
 static int cxgb4_inet6addr_handler(struct notifier_block *this,
 				   unsigned long event, void *data)
@@ -2752,7 +2437,6 @@ static int cxgb_up(struct adapter *adap)
 				  adap->msix_info[0].desc, adap);
 		if (err)
 			goto irq_err;
-
 		err = request_msix_queue_irqs(adap);
 		if (err) {
 			free_irq(adap->msix_info[0].vec, adap);
@@ -4262,6 +3946,7 @@ static int adap_init0(struct adapter *adap)
 		adap->params.ofldq_wr_cred = val[5];
 
 		adap->params.offload = 1;
+		adap->num_ofld_uld += 1;
 	}
 	if (caps_cmd.rdmacaps) {
 		params[0] = FW_PARAM_PFVF(STAG_START);
@@ -4314,6 +3999,7 @@ static int adap_init0(struct adapter *adap)
 			 "max_ordird_qp %d max_ird_adapter %d\n",
 			 adap->params.max_ordird_qp,
 			 adap->params.max_ird_adapter);
+		adap->num_ofld_uld += 2;
 	}
 	if (caps_cmd.iscsicaps) {
 		params[0] = FW_PARAM_PFVF(ISCSI_START);
@@ -4324,6 +4010,8 @@ static int adap_init0(struct adapter *adap)
 			goto bye;
 		adap->vres.iscsi.start = val[0];
 		adap->vres.iscsi.size = val[1] - val[0] + 1;
+		/* LIO target and cxgb4i initiaitor */
+		adap->num_ofld_uld += 2;
 	}
 	if (caps_cmd.cryptocaps) {
 		/* Should query params here...TODO */
@@ -4523,14 +4211,14 @@ static void cfg_queues(struct adapter *adap)
 #ifndef CONFIG_CHELSIO_T4_DCB
 	int q10g = 0;
 #endif
-	int ciq_size;
 
 	/* Reduce memory usage in kdump environment, disable all offload.
 	 */
 	if (is_kdump_kernel()) {
 		adap->params.offload = 0;
 		adap->params.crypto = 0;
-	} else if (adap->num_uld && uld_mem_alloc(adap)) {
+	} else if (is_uld(adap) && t4_uld_mem_alloc(adap)) {
+		adap->params.offload = 0;
 		adap->params.crypto = 0;
 	}
 
@@ -4576,33 +4264,18 @@ static void cfg_queues(struct adapter *adap)
 	s->ethqsets = qidx;
 	s->max_ethqsets = qidx;   /* MSI-X may lower it later */
 
-	if (is_offload(adap)) {
+	if (is_uld(adap)) {
 		/*
 		 * For offload we use 1 queue/channel if all ports are up to 1G,
 		 * otherwise we divide all available queues amongst the channels
 		 * capped by the number of available cores.
 		 */
 		if (n10g) {
-			i = min_t(int, ARRAY_SIZE(s->iscsirxq),
-				  num_online_cpus());
-			s->iscsiqsets = roundup(i, adap->params.nports);
-		} else
-			s->iscsiqsets = adap->params.nports;
-		/* For RDMA one Rx queue per channel suffices */
-		s->rdmaqs = adap->params.nports;
-		/* Try and allow at least 1 CIQ per cpu rounding down
-		 * to the number of ports, with a minimum of 1 per port.
-		 * A 2 port card in a 6 cpu system: 6 CIQs, 3 / port.
-		 * A 4 port card in a 6 cpu system: 4 CIQs, 1 / port.
-		 * A 4 port card in a 2 cpu system: 4 CIQs, 1 / port.
-		 */
-		s->rdmaciqs = min_t(int, MAX_RDMA_CIQS, num_online_cpus());
-		s->rdmaciqs = (s->rdmaciqs / adap->params.nports) *
-				adap->params.nports;
-		s->rdmaciqs = max_t(int, s->rdmaciqs, adap->params.nports);
-
-		if (!is_t4(adap->params.chip))
-			s->niscsitq = s->iscsiqsets;
+			i = num_online_cpus();
+			s->ofldqsets = roundup(i, adap->params.nports);
+		} else {
+			s->ofldqsets = adap->params.nports;
+		}
 	}
 
 	for (i = 0; i < ARRAY_SIZE(s->ethrxq); i++) {
@@ -4621,47 +4294,8 @@ static void cfg_queues(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(s->ofldtxq); i++)
 		s->ofldtxq[i].q.size = 1024;
 
-	for (i = 0; i < ARRAY_SIZE(s->iscsirxq); i++) {
-		struct sge_ofld_rxq *r = &s->iscsirxq[i];
-
-		init_rspq(adap, &r->rspq, 5, 1, 1024, 64);
-		r->rspq.uld = CXGB4_ULD_ISCSI;
-		r->fl.size = 72;
-	}
-
-	if (!is_t4(adap->params.chip)) {
-		for (i = 0; i < ARRAY_SIZE(s->iscsitrxq); i++) {
-			struct sge_ofld_rxq *r = &s->iscsitrxq[i];
-
-			init_rspq(adap, &r->rspq, 5, 1, 1024, 64);
-			r->rspq.uld = CXGB4_ULD_ISCSIT;
-			r->fl.size = 72;
-		}
-	}
-
-	for (i = 0; i < ARRAY_SIZE(s->rdmarxq); i++) {
-		struct sge_ofld_rxq *r = &s->rdmarxq[i];
-
-		init_rspq(adap, &r->rspq, 5, 1, 511, 64);
-		r->rspq.uld = CXGB4_ULD_RDMA;
-		r->fl.size = 72;
-	}
-
-	ciq_size = 64 + adap->vres.cq.size + adap->tids.nftids;
-	if (ciq_size > SGE_MAX_IQ_SIZE) {
-		CH_WARN(adap, "CIQ size too small for available IQs\n");
-		ciq_size = SGE_MAX_IQ_SIZE;
-	}
-
-	for (i = 0; i < ARRAY_SIZE(s->rdmaciq); i++) {
-		struct sge_ofld_rxq *r = &s->rdmaciq[i];
-
-		init_rspq(adap, &r->rspq, 5, 1, ciq_size, 64);
-		r->rspq.uld = CXGB4_ULD_RDMA;
-	}
-
 	init_rspq(adap, &s->fw_evtq, 0, 1, 1024, 64);
-	init_rspq(adap, &s->intrq, 0, 1, 2 * MAX_INGQ, 64);
+	init_rspq(adap, &s->intrq, 0, 1, 512, 64);
 }
 
 /*
@@ -4695,7 +4329,15 @@ static void reduce_ethqs(struct adapter *adap, int n)
 static int get_msix_info(struct adapter *adap)
 {
 	struct uld_msix_info *msix_info;
-	int max_ingq = (MAX_OFLD_QSETS * adap->num_uld);
+	unsigned int max_ingq = 0;
+
+	if (is_offload(adap))
+		max_ingq += MAX_OFLD_QSETS * adap->num_ofld_uld;
+	if (is_pci_uld(adap))
+		max_ingq += MAX_OFLD_QSETS * adap->num_uld;
+
+	if (!max_ingq)
+		goto out;
 
 	msix_info = kcalloc(max_ingq, sizeof(*msix_info), GFP_KERNEL);
 	if (!msix_info)
@@ -4709,12 +4351,13 @@ static int get_msix_info(struct adapter *adap)
 	}
 	spin_lock_init(&adap->msix_bmap_ulds.lock);
 	adap->msix_info_ulds = msix_info;
+out:
 	return 0;
 }
 
 static void free_msix_info(struct adapter *adap)
 {
-	if (!adap->num_uld)
+	if (!(adap->num_uld && adap->num_ofld_uld))
 		return;
 
 	kfree(adap->msix_info_ulds);
@@ -4733,32 +4376,32 @@ static int enable_msix(struct adapter *adap)
 	struct msix_entry *entries;
 	int max_ingq = MAX_INGQ;
 
-	max_ingq += (MAX_OFLD_QSETS * adap->num_uld);
+	if (is_pci_uld(adap))
+		max_ingq += (MAX_OFLD_QSETS * adap->num_uld);
+	if (is_offload(adap))
+		max_ingq += (MAX_OFLD_QSETS * adap->num_ofld_uld);
 	entries = kmalloc(sizeof(*entries) * (max_ingq + 1),
 			  GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
 
 	/* map for msix */
-	if (is_pci_uld(adap) && get_msix_info(adap))
+	if (get_msix_info(adap)) {
+		adap->params.offload = 0;
 		adap->params.crypto = 0;
+	}
 
 	for (i = 0; i < max_ingq + 1; ++i)
 		entries[i].entry = i;
 
 	want = s->max_ethqsets + EXTRA_VECS;
 	if (is_offload(adap)) {
-		want += s->rdmaqs + s->rdmaciqs + s->iscsiqsets	+
-			s->niscsitq;
-		/* need nchan for each possible ULD */
-		if (is_t4(adap->params.chip))
-			ofld_need = 3 * nchan;
-		else
-			ofld_need = 4 * nchan;
+		want += adap->num_ofld_uld * s->ofldqsets;
+		ofld_need = adap->num_ofld_uld * nchan;
 	}
 	if (is_pci_uld(adap)) {
-		want += netif_get_num_default_rss_queues() * nchan;
-		uld_need = nchan;
+		want += adap->num_uld * s->ofldqsets;
+		uld_need = adap->num_uld * nchan;
 	}
 #ifdef CONFIG_CHELSIO_T4_DCB
 	/* For Data Center Bridging we need 8 Ethernet TX Priority Queues for
@@ -4786,43 +4429,25 @@ static int enable_msix(struct adapter *adap)
 		if (i < s->ethqsets)
 			reduce_ethqs(adap, i);
 	}
-	if (is_pci_uld(adap)) {
+	if (is_uld(adap)) {
 		if (allocated < want)
 			s->nqs_per_uld = nchan;
 		else
-			s->nqs_per_uld = netif_get_num_default_rss_queues() *
-					nchan;
+			s->nqs_per_uld = s->ofldqsets;
 	}
 
-	if (is_offload(adap)) {
-		if (allocated < want) {
-			s->rdmaqs = nchan;
-			s->rdmaciqs = nchan;
-
-			if (!is_t4(adap->params.chip))
-				s->niscsitq = nchan;
-		}
-
-		/* leftovers go to OFLD */
-		i = allocated - EXTRA_VECS - s->max_ethqsets -
-			s->rdmaqs - s->rdmaciqs - s->niscsitq;
-		if (is_pci_uld(adap))
-			i -= s->nqs_per_uld * adap->num_uld;
-		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
-
-	}
-
-	for (i = 0; i < (allocated - (s->nqs_per_uld * adap->num_uld)); ++i)
+	for (i = 0; i < (s->max_ethqsets + EXTRA_VECS); ++i)
 		adap->msix_info[i].vec = entries[i].vector;
-	if (is_pci_uld(adap)) {
-		for (j = 0 ; i < allocated; ++i, j++)
+	if (is_uld(adap)) {
+		for (j = 0 ; i < allocated; ++i, j++) {
 			adap->msix_info_ulds[j].vec = entries[i].vector;
+			adap->msix_info_ulds[j].idx = i;
+		}
 		adap->msix_bmap_ulds.mapsize = j;
 	}
 	dev_info(adap->pdev_dev, "%d MSI-X vectors allocated, "
-		 "nic %d iscsi %d rdma cpl %d rdma ciq %d uld %d\n",
-		 allocated, s->max_ethqsets, s->iscsiqsets, s->rdmaqs,
-		 s->rdmaciqs, s->nqs_per_uld);
+		 "nic %d per uld %d\n",
+		 allocated, s->max_ethqsets, s->nqs_per_uld);
 
 	kfree(entries);
 	return 0;
@@ -5535,10 +5160,14 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* PCIe EEH recovery on powerpc platforms needs fundamental reset */
 	pdev->needs_freset = 1;
 
-	if (is_offload(adapter))
-		attach_ulds(adapter);
+	if (is_uld(adapter)) {
+		mutex_lock(&uld_mutex);
+		list_add_tail(&adapter->list_node, &adapter_list);
+		mutex_unlock(&uld_mutex);
+	}
 
 	print_adapter_info(adapter);
+	setup_fw_sge_queues(adapter);
 	return 0;
 
 sriov:
@@ -5593,8 +5222,8 @@ sriov:
 	free_some_resources(adapter);
 	if (adapter->flags & USING_MSIX)
 		free_msix_info(adapter);
-	if (adapter->num_uld)
-		uld_mem_free(adapter);
+	if (adapter->num_uld || adapter->num_ofld_uld)
+		t4_uld_mem_free(adapter);
  out_unmap_bar:
 	if (!is_t4(adapter->params.chip))
 		iounmap(adapter->bar2);
@@ -5631,7 +5260,7 @@ static void remove_one(struct pci_dev *pdev)
 		 */
 		destroy_workqueue(adapter->workq);
 
-		if (is_offload(adapter))
+		if (is_uld(adapter))
 			detach_ulds(adapter);
 
 		disable_interrupts(adapter);
@@ -5658,8 +5287,8 @@ static void remove_one(struct pci_dev *pdev)
 
 		if (adapter->flags & USING_MSIX)
 			free_msix_info(adapter);
-		if (adapter->num_uld)
-			uld_mem_free(adapter);
+		if (adapter->num_uld || adapter->num_ofld_uld)
+			t4_uld_mem_free(adapter);
 		free_some_resources(adapter);
 #if IS_ENABLED(CONFIG_IPV6)
 		t4_cleanup_clip_tbl(adapter);
@@ -5690,12 +5319,58 @@ static void remove_one(struct pci_dev *pdev)
 #endif
 }
 
+/* "Shutdown" quiesces the device, stopping Ingress Packet and Interrupt
+ * delivery.  This is essentially a stripped down version of the PCI remove()
+ * function where we do the minimal amount of work necessary to shutdown any
+ * further activity.
+ */
+static void shutdown_one(struct pci_dev *pdev)
+{
+	struct adapter *adapter = pci_get_drvdata(pdev);
+
+	/* As with remove_one() above (see extended comment), we only want do
+	 * do cleanup on PCI Devices which went all the way through init_one()
+	 * ...
+	 */
+	if (!adapter) {
+		pci_release_regions(pdev);
+		return;
+	}
+
+	if (adapter->pf == 4) {
+		int i;
+
+		for_each_port(adapter, i)
+			if (adapter->port[i]->reg_state == NETREG_REGISTERED)
+				cxgb_close(adapter->port[i]);
+
+		t4_uld_clean_up(adapter);
+		disable_interrupts(adapter);
+		disable_msi(adapter);
+
+		t4_sge_stop(adapter);
+		if (adapter->flags & FW_OK)
+			t4_fw_bye(adapter, adapter->mbox);
+	}
+#ifdef CONFIG_PCI_IOV
+	else {
+		if (adapter->port[0])
+			unregister_netdev(adapter->port[0]);
+		iounmap(adapter->regs);
+		kfree(adapter->vfinfo);
+		kfree(adapter);
+		pci_disable_sriov(pdev);
+		pci_release_regions(pdev);
+	}
+#endif
+}
+
 static struct pci_driver cxgb4_driver = {
 	.name     = KBUILD_MODNAME,
 	.id_table = cxgb4_pci_tbl,
 	.probe    = init_one,
 	.remove   = remove_one,
-	.shutdown = remove_one,
+	.shutdown = shutdown_one,
 #ifdef CONFIG_PCI_IOV
 	.sriov_configure = cxgb4_iov_configure,
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 5d402ba..fc04e3b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -82,6 +82,24 @@ static void free_msix_idx_in_bmap(struct adapter *adap, unsigned int msix_idx)
 	spin_unlock_irqrestore(&bmap->lock, flags);
 }
 
+/* Flush the aggregated lro sessions */
+static void uldrx_flush_handler(struct sge_rspq *q)
+{
+	struct adapter *adap = q->adap;
+
+	if (adap->uld[q->uld].lro_flush)
+		adap->uld[q->uld].lro_flush(&q->lro_mgr);
+}
+
+/**
+ *	uldrx_handler - response queue handler for ULD queues
+ *	@q: the response queue that received the packet
+ *	@rsp: the response queue descriptor holding the offload message
+ *	@gl: the gather list of packet fragments
+ *
+ *	Deliver an ingress offload packet to a ULD.  All processing is done by
+ *	the ULD, we just maintain statistics.
+ */
 static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 			 const struct pkt_gl *gl)
 {
@@ -124,8 +142,8 @@ static int alloc_uld_rxqs(struct adapter *adap,
 	struct sge_ofld_rxq *q = rxq_info->uldrxq + offset;
 	unsigned short *ids = rxq_info->rspq_id + offset;
 	unsigned int per_chan = nq / adap->params.nports;
-	unsigned int msi_idx, bmap_idx;
-	int i, err;
+	unsigned int bmap_idx = 0;
+	int i, err, msi_idx;
 
 	if (adap->flags & USING_MSIX)
 		msi_idx = 1;
@@ -135,14 +153,14 @@ static int alloc_uld_rxqs(struct adapter *adap,
 	for (i = 0; i < nq; i++, q++) {
 		if (msi_idx >= 0) {
 			bmap_idx = get_msix_idx_from_bmap(adap);
-			adap->msi_idx++;
+			msi_idx = adap->msix_info_ulds[bmap_idx].idx;
 		}
 		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
 				       adap->port[i / per_chan],
-				       adap->msi_idx,
+				       msi_idx,
 				       q->fl.size ? &q->fl : NULL,
 				       uldrx_handler,
-				       NULL,
+				       lro ? uldrx_flush_handler : NULL,
 				       0);
 		if (err)
 			goto freeout;
@@ -159,7 +177,6 @@ freeout:
 		if (q->rspq.desc)
 			free_rspq_fl(adap, &q->rspq,
 				     q->fl.size ? &q->fl : NULL);
-		adap->msi_idx--;
 	}
 
 	/* We need to free rxq also in case of ciq allocation failure */
@@ -169,7 +186,6 @@ freeout:
 			if (q->rspq.desc)
 				free_rspq_fl(adap, &q->rspq,
 					     q->fl.size ? &q->fl : NULL);
-			adap->msi_idx--;
 		}
 	}
 	return err;
@@ -178,17 +194,38 @@ freeout:
 int setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int i, ret = 0;
 
 	if (adap->flags & USING_MSIX) {
-		rxq_info->msix_tbl = kzalloc(rxq_info->nrxq + rxq_info->nciq,
+		rxq_info->msix_tbl = kcalloc((rxq_info->nrxq + rxq_info->nciq),
+					     sizeof(unsigned short),
 					     GFP_KERNEL);
 		if (!rxq_info->msix_tbl)
 			return -ENOMEM;
 	}
 
-	return !(!alloc_uld_rxqs(adap, rxq_info, rxq_info->nrxq, 0, lro) &&
+	ret = !(!alloc_uld_rxqs(adap, rxq_info, rxq_info->nrxq, 0, lro) &&
 		 !alloc_uld_rxqs(adap, rxq_info, rxq_info->nciq,
 				 rxq_info->nrxq, lro));
+
+	/* Tell uP to route control queue completions to rdma rspq */
+	if (adap->flags & FULL_INIT_DONE &&
+	    !ret && uld_type == CXGB4_ULD_RDMA) {
+		struct sge *s = &adap->sge;
+		unsigned int cmplqid;
+		u32 param, cmdop;
+
+		cmdop = FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_CTRL;
+		for_each_port(adap, i) {
+			cmplqid = rxq_info->uldrxq[i].rspq.cntxt_id;
+			param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+				 FW_PARAMS_PARAM_X_V(cmdop) |
+				 FW_PARAMS_PARAM_YZ_V(s->ctrlq[i].q.cntxt_id));
+			ret = t4_set_params(adap, adap->mbox, adap->pf,
+					    0, 1, &param, &cmplqid);
+		}
+	}
+	return ret;
 }
 
 static void t4_free_uld_rxqs(struct adapter *adap, int n,
@@ -198,7 +235,6 @@ static void t4_free_uld_rxqs(struct adapter *adap, int n,
 		if (q->rspq.desc)
 			free_rspq_fl(adap, &q->rspq,
 				     q->fl.size ? &q->fl : NULL);
-		adap->msi_idx--;
 	}
 }
 
@@ -206,6 +242,21 @@ void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
+	if (adap->flags & FULL_INIT_DONE && uld_type == CXGB4_ULD_RDMA) {
+		struct sge *s = &adap->sge;
+		u32 param, cmdop, cmplqid = 0;
+		int i;
+
+		cmdop = FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_CTRL;
+		for_each_port(adap, i) {
+			param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+				 FW_PARAMS_PARAM_X_V(cmdop) |
+				 FW_PARAMS_PARAM_YZ_V(s->ctrlq[i].q.cntxt_id));
+			t4_set_params(adap, adap->mbox, adap->pf,
+				      0, 1, &param, &cmplqid);
+		}
+	}
+
 	if (rxq_info->nciq)
 		t4_free_uld_rxqs(adap, rxq_info->nciq,
 				 rxq_info->uldrxq + rxq_info->nrxq);
@@ -215,26 +266,38 @@ void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 }
 
 int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
-		   const struct cxgb4_pci_uld_info *uld_info)
+		   const struct cxgb4_uld_info *uld_info)
 {
 	struct sge *s = &adap->sge;
 	struct sge_uld_rxq_info *rxq_info;
-	int i, nrxq;
+	int i, nrxq, ciq_size;
 
 	rxq_info = kzalloc(sizeof(*rxq_info), GFP_KERNEL);
 	if (!rxq_info)
 		return -ENOMEM;
 
-	if (uld_info->nrxq > s->nqs_per_uld)
-		rxq_info->nrxq = s->nqs_per_uld;
-	else
-		rxq_info->nrxq = uld_info->nrxq;
-	if (!uld_info->nciq)
+	if (adap->flags & USING_MSIX && uld_info->nrxq > s->nqs_per_uld) {
+		i = s->nqs_per_uld;
+		rxq_info->nrxq = roundup(i, adap->params.nports);
+	} else {
+		i = min_t(int, uld_info->nrxq,
+			  num_online_cpus());
+		rxq_info->nrxq = roundup(i, adap->params.nports);
+	}
+	if (!uld_info->ciq) {
 		rxq_info->nciq = 0;
-	else if (uld_info->nciq && uld_info->nciq > s->nqs_per_uld)
-		rxq_info->nciq = s->nqs_per_uld;
-	else
-		rxq_info->nciq = uld_info->nciq;
+	} else  {
+		if (adap->flags & USING_MSIX)
+			rxq_info->nciq = min_t(int, s->nqs_per_uld,
+					       num_online_cpus());
+		else
+			rxq_info->nciq = min_t(int, MAX_OFLD_QSETS,
+					       num_online_cpus());
+		rxq_info->nciq = ((rxq_info->nciq / adap->params.nports) *
+				  adap->params.nports);
+		rxq_info->nciq = max_t(int, rxq_info->nciq,
+				       adap->params.nports);
+	}
 
 	nrxq = rxq_info->nrxq + rxq_info->nciq; /* total rxq's */
 	rxq_info->uldrxq = kcalloc(nrxq, sizeof(struct sge_ofld_rxq),
@@ -259,12 +322,17 @@ int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
 		r->fl.size = 72;
 	}
 
+	ciq_size = 64 + adap->vres.cq.size + adap->tids.nftids;
+	if (ciq_size > SGE_MAX_IQ_SIZE) {
+		dev_warn(adap->pdev_dev, "CIQ size too small for available IQs\n");
+		ciq_size = SGE_MAX_IQ_SIZE;
+	}
+
 	for (i = rxq_info->nrxq; i < nrxq; i++) {
 		struct sge_ofld_rxq *r = &rxq_info->uldrxq[i];
 
-		init_rspq(adap, &r->rspq, 5, 1, uld_info->ciq_size, 64);
+		init_rspq(adap, &r->rspq, 5, 1, ciq_size, 64);
 		r->rspq.uld = uld_type;
-		r->fl.size = 72;
 	}
 
 	memcpy(rxq_info->name, uld_info->name, IFNAMSIZ);
@@ -285,7 +353,8 @@ void free_queues_uld(struct adapter *adap, unsigned int uld_type)
 int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
-	int idx, bmap_idx, err = 0;
+	int err = 0;
+	unsigned int idx, bmap_idx;
 
 	for_each_uldrxq(rxq_info, idx) {
 		bmap_idx = rxq_info->msix_tbl[idx];
@@ -310,10 +379,10 @@ unwind:
 void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
-	int idx;
+	unsigned int idx, bmap_idx;
 
 	for_each_uldrxq(rxq_info, idx) {
-		unsigned int bmap_idx = rxq_info->msix_tbl[idx];
+		bmap_idx = rxq_info->msix_tbl[idx];
 
 		free_msix_idx_in_bmap(adap, bmap_idx);
 		free_irq(adap->msix_info_ulds[bmap_idx].vec,
@@ -325,10 +394,10 @@ void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int n = sizeof(adap->msix_info_ulds[0].desc);
-	int idx;
+	unsigned int idx, bmap_idx;
 
 	for_each_uldrxq(rxq_info, idx) {
-		unsigned int bmap_idx = rxq_info->msix_tbl[idx];
+		bmap_idx = rxq_info->msix_tbl[idx];
 
 		snprintf(adap->msix_info_ulds[bmap_idx].desc, n, "%s-%s%d",
 			 adap->port[0]->name, rxq_info->name, idx);
@@ -390,15 +459,15 @@ static void uld_queue_init(struct adapter *adap, unsigned int uld_type,
 	lli->nciq = rxq_info->nciq;
 }
 
-int uld_mem_alloc(struct adapter *adap)
+int t4_uld_mem_alloc(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 
-	adap->uld = kcalloc(adap->num_uld, sizeof(*adap->uld), GFP_KERNEL);
+	adap->uld = kcalloc(CXGB4_ULD_MAX, sizeof(*adap->uld), GFP_KERNEL);
 	if (!adap->uld)
 		return -ENOMEM;
 
-	s->uld_rxq_info = kzalloc(adap->num_uld *
+	s->uld_rxq_info = kzalloc(CXGB4_ULD_MAX *
 				  sizeof(struct sge_uld_rxq_info *),
 				  GFP_KERNEL);
 	if (!s->uld_rxq_info)
@@ -410,7 +479,7 @@ err_uld:
 	return -ENOMEM;
 }
 
-void uld_mem_free(struct adapter *adap)
+void t4_uld_mem_free(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 
@@ -418,6 +487,26 @@ void uld_mem_free(struct adapter *adap)
 	kfree(adap->uld);
 }
 
+void t4_uld_clean_up(struct adapter *adap)
+{
+	struct sge_uld_rxq_info *rxq_info;
+	unsigned int i;
+
+	if (!adap->uld)
+		return;
+	for (i = 0; i < CXGB4_ULD_MAX; i++) {
+		if (!adap->uld[i].handle)
+			continue;
+		rxq_info = adap->sge.uld_rxq_info[i];
+		if (adap->flags & FULL_INIT_DONE)
+			quiesce_rx_uld(adap, i);
+		if (adap->flags & USING_MSIX)
+			free_msix_queue_irqs_uld(adap, i);
+		free_sge_queues_uld(adap, i);
+		free_queues_uld(adap, i);
+	}
+}
+
 static void uld_init(struct adapter *adap, struct cxgb4_lld_info *lld)
 {
 	int i;
@@ -429,10 +518,15 @@ static void uld_init(struct adapter *adap, struct cxgb4_lld_info *lld)
 	lld->ports = adap->port;
 	lld->vr = &adap->vres;
 	lld->mtus = adap->params.mtus;
-	lld->ntxq = adap->sge.iscsiqsets;
+	lld->ntxq = adap->sge.ofldqsets;
 	lld->nchan = adap->params.nports;
 	lld->nports = adap->params.nports;
 	lld->wr_cred = adap->params.ofldq_wr_cred;
+	lld->iscsi_iolen = MAXRXDATA_G(t4_read_reg(adap, TP_PARA_REG2_A));
+	lld->iscsi_tagmask = t4_read_reg(adap, ULP_RX_ISCSI_TAGMASK_A);
+	lld->iscsi_pgsz_order = t4_read_reg(adap, ULP_RX_ISCSI_PSZ_A);
+	lld->iscsi_llimit = t4_read_reg(adap, ULP_RX_ISCSI_LLIMIT_A);
+	lld->iscsi_ppm = &adap->iscsi_ppm;
 	lld->adapter_type = adap->params.chip;
 	lld->cclk_ps = 1000000000 / adap->params.vpd.cclk;
 	lld->udb_density = 1 << adap->params.sge.eq_qpp;
@@ -472,23 +566,37 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	}
 
 	adap->uld[uld].handle = handle;
+	t4_register_netevent_notifier();
 
 	if (adap->flags & FULL_INIT_DONE)
 		adap->uld[uld].state_change(handle, CXGB4_STATE_UP);
 }
 
-int cxgb4_register_pci_uld(enum cxgb4_pci_uld type,
-			   struct cxgb4_pci_uld_info *p)
+/**
+ *	cxgb4_register_uld - register an upper-layer driver
+ *	@type: the ULD type
+ *	@p: the ULD methods
+ *
+ *	Registers an upper-layer driver with this driver and notifies the ULD
+ *	about any presently available devices that support its type.  Returns
+ *	%-EBUSY if a ULD of the same type is already registered.
+ */
+int cxgb4_register_uld(enum cxgb4_uld type,
+		       const struct cxgb4_uld_info *p)
 {
 	int ret = 0;
+	unsigned int adap_idx = 0;
 	struct adapter *adap;
 
-	if (type >= CXGB4_PCI_ULD_MAX)
+	if (type >= CXGB4_ULD_MAX)
 		return -EINVAL;
 
 	mutex_lock(&uld_mutex);
 	list_for_each_entry(adap, &adapter_list, list_node) {
-		if (!is_pci_uld(adap))
+		if ((type == CXGB4_ULD_CRYPTO && !is_pci_uld(adap)) ||
+		    (type != CXGB4_ULD_CRYPTO && !is_offload(adap)))
+			continue;
+		if (type == CXGB4_ULD_ISCSIT && is_t4(adap->params.chip))
 			continue;
 		ret = cfg_queues_uld(adap, type, p);
 		if (ret)
@@ -510,11 +618,14 @@ int cxgb4_register_pci_uld(enum cxgb4_pci_uld type,
 		}
 		adap->uld[type] = *p;
 		uld_attach(adap, type);
+		adap_idx++;
 	}
 	mutex_unlock(&uld_mutex);
 	return 0;
 
 free_irq:
+	if (adap->flags & FULL_INIT_DONE)
+		quiesce_rx_uld(adap, type);
 	if (adap->flags & USING_MSIX)
 		free_msix_queue_irqs_uld(adap, type);
 free_rxq:
@@ -522,21 +633,49 @@ free_rxq:
 free_queues:
 	free_queues_uld(adap, type);
 out:
+
+	list_for_each_entry(adap, &adapter_list, list_node) {
+		if ((type == CXGB4_ULD_CRYPTO && !is_pci_uld(adap)) ||
+		    (type != CXGB4_ULD_CRYPTO && !is_offload(adap)))
+			continue;
+		if (type == CXGB4_ULD_ISCSIT && is_t4(adap->params.chip))
+			continue;
+		if (!adap_idx)
+			break;
+		adap->uld[type].handle = NULL;
+		adap->uld[type].add = NULL;
+		if (adap->flags & FULL_INIT_DONE)
+			quiesce_rx_uld(adap, type);
+		if (adap->flags & USING_MSIX)
+			free_msix_queue_irqs_uld(adap, type);
+		free_sge_queues_uld(adap, type);
+		free_queues_uld(adap, type);
+		adap_idx--;
+	}
 	mutex_unlock(&uld_mutex);
 	return ret;
 }
-EXPORT_SYMBOL(cxgb4_register_pci_uld);
+EXPORT_SYMBOL(cxgb4_register_uld);
 
-int cxgb4_unregister_pci_uld(enum cxgb4_pci_uld type)
+/**
+ *	cxgb4_unregister_uld - unregister an upper-layer driver
+ *	@type: the ULD type
+ *
+ *	Unregisters an existing upper-layer driver.
+ */
+int cxgb4_unregister_uld(enum cxgb4_uld type)
 {
 	struct adapter *adap;
 
-	if (type >= CXGB4_PCI_ULD_MAX)
+	if (type >= CXGB4_ULD_MAX)
 		return -EINVAL;
 
 	mutex_lock(&uld_mutex);
 	list_for_each_entry(adap, &adapter_list, list_node) {
-		if (!is_pci_uld(adap))
+		if ((type == CXGB4_ULD_CRYPTO && !is_pci_uld(adap)) ||
+		    (type != CXGB4_ULD_CRYPTO && !is_offload(adap)))
+			continue;
+		if (type == CXGB4_ULD_ISCSIT && is_t4(adap->params.chip))
 			continue;
 		adap->uld[type].handle = NULL;
 		adap->uld[type].add = NULL;
@@ -551,4 +690,4 @@ int cxgb4_unregister_pci_uld(enum cxgb4_pci_uld type)
 
 	return 0;
 }
-EXPORT_SYMBOL(cxgb4_unregister_pci_uld);
+EXPORT_SYMBOL(cxgb4_unregister_uld);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index ab40372..b3544f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -42,6 +42,8 @@
 #include <linux/atomic.h>
 #include "cxgb4.h"
 
+#define MAX_ULD_QSETS 16
+
 /* CPL message priority levels */
 enum {
 	CPL_PRIORITY_DATA     = 0,  /* data messages */
@@ -189,9 +191,11 @@ static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 }
 
 enum cxgb4_uld {
+	CXGB4_ULD_INIT,
 	CXGB4_ULD_RDMA,
 	CXGB4_ULD_ISCSI,
 	CXGB4_ULD_ISCSIT,
+	CXGB4_ULD_CRYPTO,
 	CXGB4_ULD_MAX
 };
 
@@ -284,31 +288,11 @@ struct cxgb4_lld_info {
 
 struct cxgb4_uld_info {
 	const char *name;
-	void *(*add)(const struct cxgb4_lld_info *p);
-	int (*rx_handler)(void *handle, const __be64 *rsp,
-			  const struct pkt_gl *gl);
-	int (*state_change)(void *handle, enum cxgb4_state new_state);
-	int (*control)(void *handle, enum cxgb4_control control, ...);
-	int (*lro_rx_handler)(void *handle, const __be64 *rsp,
-			      const struct pkt_gl *gl,
-			      struct t4_lro_mgr *lro_mgr,
-			      struct napi_struct *napi);
-	void (*lro_flush)(struct t4_lro_mgr *);
-};
-
-enum cxgb4_pci_uld {
-	CXGB4_PCI_ULD1,
-	CXGB4_PCI_ULD_MAX
-};
-
-struct cxgb4_pci_uld_info {
-	const char *name;
-	bool lro;
 	void *handle;
 	unsigned int nrxq;
-	unsigned int nciq;
 	unsigned int rxq_size;
-	unsigned int ciq_size;
+	bool ciq;
+	bool lro;
 	void *(*add)(const struct cxgb4_lld_info *p);
 	int (*rx_handler)(void *handle, const __be64 *rsp,
 			  const struct pkt_gl *gl);
@@ -323,9 +307,6 @@ struct cxgb4_pci_uld_info {
 
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
 int cxgb4_unregister_uld(enum cxgb4_uld type);
-int cxgb4_register_pci_uld(enum cxgb4_pci_uld type,
-			   struct cxgb4_pci_uld_info *p);
-int cxgb4_unregister_pci_uld(enum cxgb4_pci_uld type);
 int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 9a607db..1e74fd6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2860,6 +2860,18 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 	return 0;
 }
 
+int t4_sge_mod_ctrl_txq(struct adapter *adap, unsigned int eqid,
+			unsigned int cmplqid)
+{
+	u32 param, val;
+
+	param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+		 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_CTRL) |
+		 FW_PARAMS_PARAM_YZ_V(eqid));
+	val = cmplqid;
+	return t4_set_params(adap, adap->mbox, adap->pf, 0, 1, &param, &val);
+}
+
 int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 			  struct net_device *dev, unsigned int iqid)
 {
@@ -3014,12 +3026,6 @@ void t4_free_sge_resources(struct adapter *adap)
 		}
 	}
 
-	/* clean up RDMA and iSCSI Rx queues */
-	t4_free_ofld_rxqs(adap, adap->sge.iscsiqsets, adap->sge.iscsirxq);
-	t4_free_ofld_rxqs(adap, adap->sge.niscsitq, adap->sge.iscsitrxq);
-	t4_free_ofld_rxqs(adap, adap->sge.rdmaqs, adap->sge.rdmarxq);
-	t4_free_ofld_rxqs(adap, adap->sge.rdmaciqs, adap->sge.rdmaciq);
-
 	/* clean up offload Tx queues */
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ofldtxq); i++) {
 		struct sge_ofld_txq *q = &adap->sge.ofldtxq[i];
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index e4ba2d2..7c0d7af 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -84,6 +84,9 @@ static inline int send_tx_flowc_wr(struct cxgbi_sock *);
 
 static const struct cxgb4_uld_info cxgb4i_uld_info = {
 	.name = DRV_MODULE_NAME,
+	.nrxq = MAX_ULD_QSETS,
+	.rxq_size = 1024,
+	.lro = false,
 	.add = t4_uld_add,
 	.rx_handler = t4_uld_rx_handler,
 	.state_change = t4_uld_state_change,
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_main.c b/drivers/target/iscsi/cxgbit/cxgbit_main.c
index 27dd11a..ad26b93 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_main.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_main.c
@@ -652,6 +652,9 @@ static struct iscsit_transport cxgbit_transport = {
 
 static struct cxgb4_uld_info cxgbit_uld_info = {
 	.name		= DRV_NAME,
+	.nrxq		= MAX_ULD_QSETS,
+	.rxq_size	= 1024,
+	.lro		= true,
 	.add		= cxgbit_uld_add,
 	.state_change	= cxgbit_uld_state_change,
 	.lro_rx_handler = cxgbit_uld_lro_rx_handler,
-- 
1.7.3
