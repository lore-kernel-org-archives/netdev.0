From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 1/4] cxgb4: Add support for dynamic allocation of resources for ULD
Date: Wed, 17 Aug 2016 12:33:03 +0530
Message-ID: <1471417386-14026-2-git-send-email-hariprasad@chelsio.com>
References: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	atul.gupta@chelsio.com, yeshaswi@chelsio.com, jlulla@chelsio.com,
	harsh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new commmon infrastructure to allocate reosurces dynamically to
Upper layer driver's(ULD) when they register with cxgb4 driver and free
them during unregistering. All the queues and the interrupts for
them will be allocated during ULD probe only and freed during remove.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   59 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  153 +++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c  |  555 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   34 ++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    2 +-
 7 files changed, 759 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index 85c9282..e955eda 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_CHELSIO_T4_UWIRE) +=  cxgb4_ppm.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 7ce076f..94d7592 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -53,6 +53,8 @@
 #include "cxgb4_uld.h"
 
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
+extern struct list_head adapter_list;
+extern struct mutex uld_mutex;
 
 enum {
 	MAX_NPORTS	= 4,     /* max # of ports */
@@ -338,6 +340,7 @@ struct adapter_params {
 	enum chip_type chip;               /* chip code */
 	struct arch_specific_params arch;  /* chip specific params */
 	unsigned char offload;
+	unsigned char crypto;		/* HW capability for crypto */
 
 	unsigned char bypass;
 
@@ -403,7 +406,6 @@ struct fw_info {
 	struct fw_hdr fw_hdr;
 };
 
-
 struct trace_params {
 	u32 data[TRACE_LEN / 4];
 	u32 mask[TRACE_LEN / 4];
@@ -509,6 +511,10 @@ enum {                                 /* adapter flags */
 	FW_OFLD_CONN       = (1 << 9),
 };
 
+enum {
+	ULP_CRYPTO_LOOKASIDE = 1 << 0,
+};
+
 struct rx_sw_desc;
 
 struct sge_fl {                     /* SGE free-buffer queue state */
@@ -679,6 +685,16 @@ struct sge_ctrl_txq {               /* state for an SGE control Tx queue */
 	u8 full;                    /* the Tx ring is full */
 } ____cacheline_aligned_in_smp;
 
+struct sge_uld_rxq_info {
+	char name[IFNAMSIZ];	/* name of ULD driver */
+	struct sge_ofld_rxq *uldrxq; /* Rxq's for ULD */
+	u16 *msix_tbl;		/* msix_tbl for uld */
+	u16 *rspq_id;		/* response queue id's of rxq */
+	u16 nrxq;		/* # of ingress uld queues */
+	u16 nciq;		/* # of completion queues */
+	u8 uld;			/* uld type */
+};
+
 struct sge {
 	struct sge_eth_txq ethtxq[MAX_ETH_QSETS];
 	struct sge_ofld_txq ofldtxq[MAX_OFLD_QSETS];
@@ -690,6 +706,7 @@ struct sge {
 	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
 	struct sge_ofld_rxq rdmaciq[MAX_RDMA_CIQS];
 	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
+	struct sge_uld_rxq_info **uld_rxq_info;
 
 	struct sge_rspq intrq ____cacheline_aligned_in_smp;
 	spinlock_t intrq_lock;
@@ -701,6 +718,7 @@ struct sge {
 	u16 niscsitq;               /* # of available iSCST Rx queues */
 	u16 rdmaqs;                 /* # of available RDMA Rx queues */
 	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
+	u16 nqs_per_uld;	    /* # of Rx queues per ULD */
 	u16 iscsi_rxq[MAX_OFLD_QSETS];
 	u16 iscsit_rxq[MAX_ISCSIT_QUEUES];
 	u16 rdma_rxq[MAX_RDMA_QUEUES];
@@ -756,6 +774,17 @@ struct hash_mac_addr {
 	u8 addr[ETH_ALEN];
 };
 
+struct uld_msix_bmap {
+	unsigned long *msix_bmap;
+	unsigned int mapsize;
+	spinlock_t lock; /* lock for acquiring bitmap */
+};
+
+struct uld_msix_info {
+	unsigned short vec;
+	char desc[IFNAMSIZ + 10];
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -778,6 +807,9 @@ struct adapter {
 		unsigned short vec;
 		char desc[IFNAMSIZ + 10];
 	} msix_info[MAX_INGQ + 1];
+	struct uld_msix_info *msix_info_ulds; /* msix info for uld's */
+	struct uld_msix_bmap msix_bmap_ulds; /* msix bitmap for all uld */
+	unsigned int msi_idx;
 
 	struct doorbell_stats db_stats;
 	struct sge sge;
@@ -792,7 +824,9 @@ struct adapter {
 	unsigned int clipt_start;
 	unsigned int clipt_end;
 	struct clip_tbl *clipt;
+	struct cxgb4_pci_uld_info *uld;
 	void *uld_handle[CXGB4_ULD_MAX];
+	unsigned int num_uld;
 	struct list_head list_node;
 	struct list_head rcu_node;
 	struct list_head mac_hlist; /* list of MAC addresses in MPS Hash */
@@ -951,6 +985,11 @@ static inline int is_offload(const struct adapter *adap)
 	return adap->params.offload;
 }
 
+static inline int is_pci_uld(const struct adapter *adap)
+{
+	return adap->params.crypto;
+}
+
 static inline u32 t4_read_reg(struct adapter *adap, u32 reg_addr)
 {
 	return readl(adap->regs + reg_addr);
@@ -1184,8 +1223,6 @@ int t4_sge_init(struct adapter *adap);
 void t4_sge_start(struct adapter *adap);
 void t4_sge_stop(struct adapter *adap);
 int cxgb_busy_poll(struct napi_struct *napi);
-int cxgb4_set_rspq_intr_params(struct sge_rspq *q, unsigned int us,
-			       unsigned int cnt);
 void cxgb4_set_ethtool_ops(struct net_device *netdev);
 int cxgb4_write_rss(const struct port_info *pi, const u16 *queues);
 extern int dbfifo_int_thresh;
@@ -1288,6 +1325,18 @@ static inline int hash_mac_addr(const u8 *addr)
 	return a & 0x3f;
 }
 
+int cxgb4_set_rspq_intr_params(struct sge_rspq *q, unsigned int us,
+			       unsigned int cnt);
+static inline void init_rspq(struct adapter *adap, struct sge_rspq *q,
+			     unsigned int us, unsigned int cnt,
+			     unsigned int size, unsigned int iqe_size)
+{
+	q->adap = adap;
+	cxgb4_set_rspq_intr_params(q, us, cnt);
+	q->iqe_len = iqe_size;
+	q->size = size;
+}
+
 void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
 		       unsigned int data_reg, const u32 *vals,
 		       unsigned int nregs, unsigned int start_idx);
@@ -1522,5 +1571,7 @@ void t4_idma_monitor(struct adapter *adapter,
 		     int hz, int ticks);
 int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
 		      unsigned int naddr, u8 *addr);
-
+void uld_mem_free(struct adapter *adap);
+int uld_mem_alloc(struct adapter *adap);
+void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a485abc..3d6dd45 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -223,8 +223,8 @@ MODULE_PARM_DESC(select_queue,
 
 static struct dentry *cxgb4_debugfs_root;
 
-static LIST_HEAD(adapter_list);
-static DEFINE_MUTEX(uld_mutex);
+LIST_HEAD(adapter_list);
+DEFINE_MUTEX(uld_mutex);
 /* Adapter list to be accessed from atomic context */
 static LIST_HEAD(adap_rcu_list);
 static DEFINE_SPINLOCK(adap_rcu_lock);
@@ -1066,20 +1066,20 @@ static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
  */
 static int setup_sge_queues(struct adapter *adap)
 {
-	int err, msi_idx, i, j;
+	int err, i, j;
 	struct sge *s = &adap->sge;
 
 	bitmap_zero(s->starving_fl, s->egr_sz);
 	bitmap_zero(s->txq_maperr, s->egr_sz);
 
 	if (adap->flags & USING_MSIX)
-		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
+		adap->msi_idx = 1;         /* vector 0 is for non-queue interrupts */
 	else {
 		err = t4_sge_alloc_rxq(adap, &s->intrq, false, adap->port[0], 0,
 				       NULL, NULL, NULL, -1);
 		if (err)
 			return err;
-		msi_idx = -((int)s->intrq.abs_id + 1);
+		adap->msi_idx = -((int)s->intrq.abs_id + 1);
 	}
 
 	/* NOTE: If you add/delete any Ingress/Egress Queue allocations in here,
@@ -1096,7 +1096,7 @@ static int setup_sge_queues(struct adapter *adap)
 	 *    new/deleted queues.
 	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
-			       msi_idx, NULL, fwevtq_handler, NULL, -1);
+			       adap->msi_idx, NULL, fwevtq_handler, NULL, -1);
 	if (err) {
 freeout:	t4_free_sge_resources(adap);
 		return err;
@@ -1109,10 +1109,10 @@ freeout:	t4_free_sge_resources(adap);
 		struct sge_eth_txq *t = &s->ethtxq[pi->first_qset];
 
 		for (j = 0; j < pi->nqsets; j++, q++) {
-			if (msi_idx > 0)
-				msi_idx++;
+			if (adap->msi_idx > 0)
+				adap->msi_idx++;
 			err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev,
-					       msi_idx, &q->fl,
+					       adap->msi_idx, &q->fl,
 					       t4_ethrx_handler,
 					       NULL,
 					       t4_get_mps_bg_map(adap,
@@ -1141,11 +1141,11 @@ freeout:	t4_free_sge_resources(adap);
 	}
 
 #define ALLOC_OFLD_RXQS(firstq, nq, per_chan, ids, lro) do { \
-	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, msi_idx, ids, lro); \
+	err = alloc_ofld_rxqs(adap, firstq, nq, per_chan, adap->msi_idx, ids, lro); \
 	if (err) \
 		goto freeout; \
-	if (msi_idx > 0) \
-		msi_idx += nq; \
+	if (adap->msi_idx > 0) \
+		adap->msi_idx += nq; \
 } while (0)
 
 	ALLOC_OFLD_RXQS(s->iscsirxq, s->iscsiqsets, j, s->iscsi_rxq, false);
@@ -2565,6 +2565,12 @@ static void detach_ulds(struct adapter *adap)
 					     CXGB4_STATE_DETACH);
 			adap->uld_handle[i] = NULL;
 		}
+	for (i = 0; i < CXGB4_PCI_ULD_MAX; i++)
+		if (adap->uld && adap->uld[i].handle) {
+			adap->uld[i].state_change(adap->uld[i].handle,
+					     CXGB4_STATE_DETACH);
+			adap->uld[i].handle = NULL;
+		}
 	if (netevent_registered && list_empty(&adapter_list)) {
 		unregister_netevent_notifier(&cxgb4_netevent_nb);
 		netevent_registered = false;
@@ -2584,6 +2590,10 @@ static void notify_ulds(struct adapter *adap, enum cxgb4_state new_state)
 	for (i = 0; i < CXGB4_ULD_MAX; i++)
 		if (adap->uld_handle[i])
 			ulds[i].state_change(adap->uld_handle[i], new_state);
+	for (i = 0; i < CXGB4_PCI_ULD_MAX; i++)
+		if (adap->uld && adap->uld[i].handle)
+			adap->uld[i].state_change(adap->uld[i].handle,
+						  new_state);
 	mutex_unlock(&uld_mutex);
 }
 
@@ -4170,6 +4180,11 @@ static int adap_init0(struct adapter *adap)
 		adap->vres.iscsi.start = val[0];
 		adap->vres.iscsi.size = val[1] - val[0] + 1;
 	}
+	if (caps_cmd.cryptocaps) {
+		/* Should query params here...TODO */
+		adap->params.crypto |= ULP_CRYPTO_LOOKASIDE;
+		adap->num_uld += 1;
+	}
 #undef FW_PARAM_PFVF
 #undef FW_PARAM_DEV
 
@@ -4351,16 +4366,6 @@ static inline bool is_x_10g_port(const struct link_config *lc)
 	       (lc->supported & FW_PORT_CAP_SPEED_40G) != 0;
 }
 
-static inline void init_rspq(struct adapter *adap, struct sge_rspq *q,
-			     unsigned int us, unsigned int cnt,
-			     unsigned int size, unsigned int iqe_size)
-{
-	q->adap = adap;
-	cxgb4_set_rspq_intr_params(q, us, cnt);
-	q->iqe_len = iqe_size;
-	q->size = size;
-}
-
 /*
  * Perform default configuration of DMA queues depending on the number and type
  * of ports we found and the number of available CPUs.  Most settings can be
@@ -4375,6 +4380,15 @@ static void cfg_queues(struct adapter *adap)
 #endif
 	int ciq_size;
 
+	/* Reduce memory usage in kdump environment, disable all offload.
+	 */
+	if (is_kdump_kernel()) {
+		adap->params.offload = 0;
+		adap->params.crypto = 0;
+	} else if (adap->num_uld && uld_mem_alloc(adap)) {
+		adap->params.crypto = 0;
+	}
+
 	for_each_port(adap, i)
 		n10g += is_x_10g_port(&adap2pinfo(adap, i)->link_cfg);
 #ifdef CONFIG_CHELSIO_T4_DCB
@@ -4405,11 +4419,6 @@ static void cfg_queues(struct adapter *adap)
 	if (q10g > netif_get_num_default_rss_queues())
 		q10g = netif_get_num_default_rss_queues();
 
-	/* Reduce memory usage in kdump environment, disable all offload.
-	 */
-	if (is_kdump_kernel())
-		adap->params.offload = 0;
-
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
 
@@ -4538,23 +4547,58 @@ static void reduce_ethqs(struct adapter *adap, int n)
 	}
 }
 
+static int get_msix_info(struct adapter *adap)
+{
+	struct uld_msix_info *msix_info;
+	int max_ingq = (MAX_OFLD_QSETS * adap->num_uld);
+
+	msix_info = kcalloc(max_ingq, sizeof(*msix_info), GFP_KERNEL);
+	if (!msix_info)
+		return -ENOMEM;
+
+	adap->msix_bmap_ulds.msix_bmap = kcalloc(BITS_TO_LONGS(max_ingq),
+						 sizeof(long), GFP_KERNEL);
+	if (!adap->msix_bmap_ulds.msix_bmap) {
+		kfree(msix_info);
+		return -ENOMEM;
+	}
+	spin_lock_init(&adap->msix_bmap_ulds.lock);
+	adap->msix_info_ulds = msix_info;
+	return 0;
+}
+
+static void free_msix_info(struct adapter *adap)
+{
+	if (!adap->num_uld)
+		return;
+
+	kfree(adap->msix_info_ulds);
+	kfree(adap->msix_bmap_ulds.msix_bmap);
+}
+
 /* 2 MSI-X vectors needed for the FW queue and non-data interrupts */
 #define EXTRA_VECS 2
 
 static int enable_msix(struct adapter *adap)
 {
-	int ofld_need = 0;
-	int i, want, need, allocated;
+	int ofld_need = 0, uld_need = 0;
+	int i, j, want, need, allocated;
 	struct sge *s = &adap->sge;
 	unsigned int nchan = adap->params.nports;
 	struct msix_entry *entries;
+	int max_ingq = MAX_INGQ;
 
-	entries = kmalloc(sizeof(*entries) * (MAX_INGQ + 1),
+	max_ingq += (MAX_OFLD_QSETS * adap->num_uld);
+	entries = kmalloc(sizeof(*entries) * (max_ingq + 1),
 			  GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
 
-	for (i = 0; i < MAX_INGQ + 1; ++i)
+	/* map for msix */
+	if (is_pci_uld(adap) && get_msix_info(adap))
+		adap->params.crypto = 0;
+
+	for (i = 0; i < max_ingq + 1; ++i)
 		entries[i].entry = i;
 
 	want = s->max_ethqsets + EXTRA_VECS;
@@ -4567,13 +4611,17 @@ static int enable_msix(struct adapter *adap)
 		else
 			ofld_need = 4 * nchan;
 	}
+	if (is_pci_uld(adap)) {
+		want += netif_get_num_default_rss_queues() * nchan;
+		uld_need = nchan;
+	}
 #ifdef CONFIG_CHELSIO_T4_DCB
 	/* For Data Center Bridging we need 8 Ethernet TX Priority Queues for
 	 * each port.
 	 */
-	need = 8 * adap->params.nports + EXTRA_VECS + ofld_need;
+	need = 8 * adap->params.nports + EXTRA_VECS + ofld_need + uld_need;
 #else
-	need = adap->params.nports + EXTRA_VECS + ofld_need;
+	need = adap->params.nports + EXTRA_VECS + ofld_need + uld_need;
 #endif
 	allocated = pci_enable_msix_range(adap->pdev, entries, need, want);
 	if (allocated < 0) {
@@ -4587,12 +4635,20 @@ static int enable_msix(struct adapter *adap)
 	 * Every group gets its minimum requirement and NIC gets top
 	 * priority for leftovers.
 	 */
-	i = allocated - EXTRA_VECS - ofld_need;
+	i = allocated - EXTRA_VECS - ofld_need - uld_need;
 	if (i < s->max_ethqsets) {
 		s->max_ethqsets = i;
 		if (i < s->ethqsets)
 			reduce_ethqs(adap, i);
 	}
+	if (is_pci_uld(adap)) {
+		if (allocated < want)
+			s->nqs_per_uld = nchan;
+		else
+			s->nqs_per_uld = netif_get_num_default_rss_queues() *
+					nchan;
+	}
+
 	if (is_offload(adap)) {
 		if (allocated < want) {
 			s->rdmaqs = nchan;
@@ -4604,16 +4660,24 @@ static int enable_msix(struct adapter *adap)
 
 		/* leftovers go to OFLD */
 		i = allocated - EXTRA_VECS - s->max_ethqsets -
-		    s->rdmaqs - s->rdmaciqs - s->niscsitq;
+			s->rdmaqs - s->rdmaciqs - s->niscsitq;
+		if (is_pci_uld(adap))
+			i -= s->nqs_per_uld * adap->num_uld;
 		s->iscsiqsets = (i / nchan) * nchan;  /* round down */
 
 	}
-	for (i = 0; i < allocated; ++i)
+
+	for (i = 0; i < (allocated - (s->nqs_per_uld * adap->num_uld)); ++i)
 		adap->msix_info[i].vec = entries[i].vector;
+	if (is_pci_uld(adap)) {
+		for (j = 0 ; i < allocated; ++i, j++)
+			adap->msix_info_ulds[j].vec = entries[i].vector;
+		adap->msix_bmap_ulds.mapsize = j;
+	}
 	dev_info(adap->pdev_dev, "%d MSI-X vectors allocated, "
-		 "nic %d iscsi %d rdma cpl %d rdma ciq %d\n",
+		 "nic %d iscsi %d rdma cpl %d rdma ciq %d uld %d\n",
 		 allocated, s->max_ethqsets, s->iscsiqsets, s->rdmaqs,
-		 s->rdmaciqs);
+		 s->rdmaciqs, s->nqs_per_uld);
 
 	kfree(entries);
 	return 0;
@@ -5212,8 +5276,11 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* See what interrupts we'll be using */
 	if (msi > 1 && enable_msix(adapter) == 0)
 		adapter->flags |= USING_MSIX;
-	else if (msi > 0 && pci_enable_msi(pdev) == 0)
+	else if (msi > 0 && pci_enable_msi(pdev) == 0) {
 		adapter->flags |= USING_MSI;
+		if (msi > 1)
+			free_msix_info(adapter);
+	}
 
 	/* check for PCI Express bandwidth capabiltites */
 	cxgb4_check_pcie_caps(adapter);
@@ -5328,6 +5395,10 @@ sriov:
 
  out_free_dev:
 	free_some_resources(adapter);
+	if (adapter->flags & USING_MSIX)
+		free_msix_info(adapter);
+	if (adapter->num_uld)
+		uld_mem_free(adapter);
  out_unmap_bar:
 	if (!is_t4(adapter->params.chip))
 		iounmap(adapter->bar2);
@@ -5389,6 +5460,10 @@ static void remove_one(struct pci_dev *pdev)
 		if (adapter->flags & FULL_INIT_DONE)
 			cxgb_down(adapter);
 
+		if (adapter->flags & USING_MSIX)
+			free_msix_info(adapter);
+		if (adapter->num_uld)
+			uld_mem_free(adapter);
 		free_some_resources(adapter);
 #if IS_ENABLED(CONFIG_IPV6)
 		t4_cleanup_clip_tbl(adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
new file mode 100644
index 0000000..aac6e44
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -0,0 +1,555 @@
+/*
+ * cxgb4_uld.c:Chelsio Upper Layer Driver Interface for T4/T5/T6 SGE management
+ *
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
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
+ *
+ *  Written by: Atul Gupta (atul.gupta@chelsio.com)
+ *  Written by: Hariprasad Shenai (hariprasad@chelsio.com)
+ */
+
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/debugfs.h>
+#include <linux/export.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/pci.h>
+
+#include "cxgb4.h"
+#include "cxgb4_uld.h"
+#include "t4_regs.h"
+#include "t4fw_api.h"
+#include "t4_msg.h"
+
+#define for_each_uldrxq(m, i) for (i = 0; i < ((m)->nrxq + (m)->nciq); i++)
+
+static int get_msix_idx_from_bmap(struct adapter *adap)
+{
+	struct uld_msix_bmap *bmap = &adap->msix_bmap_ulds;
+	unsigned long flags;
+	unsigned int msix_idx;
+
+	spin_lock_irqsave(&bmap->lock, flags);
+	msix_idx = find_first_zero_bit(bmap->msix_bmap, bmap->mapsize);
+	if (msix_idx < bmap->mapsize) {
+		__set_bit(msix_idx, bmap->msix_bmap);
+	} else {
+		spin_unlock_irqrestore(&bmap->lock, flags);
+		return -ENOSPC;
+	}
+
+	spin_unlock_irqrestore(&bmap->lock, flags);
+	return msix_idx;
+}
+
+static void free_msix_idx_in_bmap(struct adapter *adap, unsigned int msix_idx)
+{
+	struct uld_msix_bmap *bmap = &adap->msix_bmap_ulds;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bmap->lock, flags);
+	 __clear_bit(msix_idx, bmap->msix_bmap);
+	spin_unlock_irqrestore(&bmap->lock, flags);
+}
+
+static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
+			 const struct pkt_gl *gl)
+{
+	struct adapter *adap = q->adap;
+	struct sge_ofld_rxq *rxq = container_of(q, struct sge_ofld_rxq, rspq);
+	int ret;
+
+	/* FW can send CPLs encapsulated in a CPL_FW4_MSG */
+	if (((const struct rss_header *)rsp)->opcode == CPL_FW4_MSG &&
+	    ((const struct cpl_fw4_msg *)(rsp + 1))->type == FW_TYPE_RSSCPL)
+		rsp += 2;
+
+	if (q->flush_handler)
+		ret = adap->uld[q->uld].lro_rx_handler(adap->uld[q->uld].handle,
+				rsp, gl, &q->lro_mgr,
+				&q->napi);
+	else
+		ret = adap->uld[q->uld].rx_handler(adap->uld[q->uld].handle,
+				rsp, gl);
+
+	if (ret) {
+		rxq->stats.nomem++;
+		return -1;
+	}
+
+	if (!gl)
+		rxq->stats.imm++;
+	else if (gl == CXGB4_MSG_AN)
+		rxq->stats.an++;
+	else
+		rxq->stats.pkts++;
+	return 0;
+}
+
+static int alloc_uld_rxqs(struct adapter *adap,
+			  struct sge_uld_rxq_info *rxq_info,
+			  unsigned int nq, unsigned int offset, bool lro)
+{
+	struct sge *s = &adap->sge;
+	struct sge_ofld_rxq *q = rxq_info->uldrxq + offset;
+	unsigned short *ids = rxq_info->rspq_id + offset;
+	unsigned int per_chan = nq / adap->params.nports;
+	unsigned int msi_idx, bmap_idx;
+	int i, err;
+
+	if (adap->flags & USING_MSIX)
+		msi_idx = 1;
+	else
+		msi_idx = -((int)s->intrq.abs_id + 1);
+
+	for (i = 0; i < nq; i++, q++) {
+		if (msi_idx >= 0) {
+			bmap_idx = get_msix_idx_from_bmap(adap);
+			adap->msi_idx++;
+		}
+		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
+				       adap->port[i / per_chan],
+				       adap->msi_idx,
+				       q->fl.size ? &q->fl : NULL,
+				       uldrx_handler,
+				       NULL,
+				       0);
+		if (err)
+			goto freeout;
+		if (msi_idx >= 0)
+			rxq_info->msix_tbl[i + offset] = bmap_idx;
+		memset(&q->stats, 0, sizeof(q->stats));
+		if (ids)
+			ids[i] = q->rspq.abs_id;
+	}
+	return 0;
+freeout:
+	q = rxq_info->uldrxq + offset;
+	for ( ; i; i--, q++) {
+		if (q->rspq.desc)
+			free_rspq_fl(adap, &q->rspq,
+				     q->fl.size ? &q->fl : NULL);
+		adap->msi_idx--;
+	}
+
+	/* We need to free rxq also in case of ciq allocation failure */
+	if (offset) {
+		q = rxq_info->uldrxq + offset;
+		for ( ; i; i--, q++) {
+			if (q->rspq.desc)
+				free_rspq_fl(adap, &q->rspq,
+					     q->fl.size ? &q->fl : NULL);
+			adap->msi_idx--;
+		}
+	}
+	return err;
+}
+
+int setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+
+	if (adap->flags & USING_MSIX) {
+		rxq_info->msix_tbl = kzalloc(rxq_info->nrxq + rxq_info->nciq,
+					     GFP_KERNEL);
+		if (!rxq_info->msix_tbl)
+			return -ENOMEM;
+	}
+
+	return !(!alloc_uld_rxqs(adap, rxq_info, rxq_info->nrxq, 0, lro) &&
+		 !alloc_uld_rxqs(adap, rxq_info, rxq_info->nciq,
+				 rxq_info->nrxq, lro));
+}
+
+static void t4_free_uld_rxqs(struct adapter *adap, int n,
+			     struct sge_ofld_rxq *q)
+{
+	for ( ; n; n--, q++) {
+		if (q->rspq.desc)
+			free_rspq_fl(adap, &q->rspq,
+				     q->fl.size ? &q->fl : NULL);
+		adap->msi_idx--;
+	}
+}
+
+void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+
+	if (rxq_info->nciq)
+		t4_free_uld_rxqs(adap, rxq_info->nciq,
+				 rxq_info->uldrxq + rxq_info->nrxq);
+	t4_free_uld_rxqs(adap, rxq_info->nrxq, rxq_info->uldrxq);
+	if (adap->flags & USING_MSIX)
+		kfree(rxq_info->msix_tbl);
+}
+
+int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
+		   const struct cxgb4_pci_uld_info *uld_info)
+{
+	struct sge *s = &adap->sge;
+	struct sge_uld_rxq_info *rxq_info;
+	int i, nrxq;
+
+	rxq_info = kzalloc(sizeof(*rxq_info), GFP_KERNEL);
+	if (!rxq_info)
+		return -ENOMEM;
+
+	if (uld_info->nrxq > s->nqs_per_uld)
+		rxq_info->nrxq = s->nqs_per_uld;
+	else
+		rxq_info->nrxq = uld_info->nrxq;
+	if (!uld_info->nciq)
+		rxq_info->nciq = 0;
+	else if (uld_info->nciq && uld_info->nciq > s->nqs_per_uld)
+		rxq_info->nciq = s->nqs_per_uld;
+	else
+		rxq_info->nciq = uld_info->nciq;
+
+	nrxq = rxq_info->nrxq + rxq_info->nciq; /* total rxq's */
+	rxq_info->uldrxq = kcalloc(nrxq, sizeof(struct sge_ofld_rxq),
+				   GFP_KERNEL);
+	if (!rxq_info->uldrxq) {
+		kfree(rxq_info);
+		return -ENOMEM;
+	}
+
+	rxq_info->rspq_id = kcalloc(nrxq, sizeof(unsigned short), GFP_KERNEL);
+	if (!rxq_info->uldrxq) {
+		kfree(rxq_info->uldrxq);
+		kfree(rxq_info);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < rxq_info->nrxq; i++) {
+		struct sge_ofld_rxq *r = &rxq_info->uldrxq[i];
+
+		init_rspq(adap, &r->rspq, 5, 1, uld_info->rxq_size, 64);
+		r->rspq.uld = uld_type;
+		r->fl.size = 72;
+	}
+
+	for (i = rxq_info->nrxq; i < nrxq; i++) {
+		struct sge_ofld_rxq *r = &rxq_info->uldrxq[i];
+
+		init_rspq(adap, &r->rspq, 5, 1, uld_info->ciq_size, 64);
+		r->rspq.uld = uld_type;
+		r->fl.size = 72;
+	}
+
+	memcpy(rxq_info->name, uld_info->name, IFNAMSIZ);
+	adap->sge.uld_rxq_info[uld_type] = rxq_info;
+
+	return 0;
+}
+
+void free_queues_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+
+	kfree(rxq_info->rspq_id);
+	kfree(rxq_info->uldrxq);
+	kfree(rxq_info);
+}
+
+int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int idx, bmap_idx, err = 0;
+
+	for_each_uldrxq(rxq_info, idx) {
+		bmap_idx = rxq_info->msix_tbl[idx];
+		err = request_irq(adap->msix_info_ulds[bmap_idx].vec,
+				  t4_sge_intr_msix, 0,
+				  adap->msix_info_ulds[bmap_idx].desc,
+				  &rxq_info->uldrxq[idx].rspq);
+		if (err)
+			goto unwind;
+	}
+	return 0;
+unwind:
+	while (--idx >= 0) {
+		bmap_idx = rxq_info->msix_tbl[idx];
+		free_msix_idx_in_bmap(adap, bmap_idx);
+		free_irq(adap->msix_info_ulds[bmap_idx].vec,
+			 &rxq_info->uldrxq[idx].rspq);
+	}
+	return err;
+}
+
+void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int idx;
+
+	for_each_uldrxq(rxq_info, idx) {
+		unsigned int bmap_idx = rxq_info->msix_tbl[idx];
+
+		free_msix_idx_in_bmap(adap, bmap_idx);
+		free_irq(adap->msix_info_ulds[bmap_idx].vec,
+			 &rxq_info->uldrxq[idx].rspq);
+	}
+}
+
+void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int n = sizeof(adap->msix_info_ulds[0].desc);
+	int idx;
+
+	for_each_uldrxq(rxq_info, idx) {
+		unsigned int bmap_idx = rxq_info->msix_tbl[idx];
+
+		snprintf(adap->msix_info_ulds[bmap_idx].desc, n, "%s-%s%d",
+			 adap->port[0]->name, rxq_info->name, idx);
+	}
+}
+
+static void enable_rx(struct adapter *adap, struct sge_rspq *q)
+{
+	if (!q)
+		return;
+
+	if (q->handler) {
+		cxgb_busy_poll_init_lock(q);
+		napi_enable(&q->napi);
+	}
+	/* 0-increment GTS to start the timer and enable interrupts */
+	t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
+		     SEINTARM_V(q->intr_params) |
+		     INGRESSQID_V(q->cntxt_id));
+}
+
+static void quiesce_rx(struct adapter *adap, struct sge_rspq *q)
+{
+	if (q && q->handler) {
+		napi_disable(&q->napi);
+		local_bh_disable();
+		while (!cxgb_poll_lock_napi(q))
+			mdelay(1);
+		local_bh_enable();
+	}
+}
+
+void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int idx;
+
+	for_each_uldrxq(rxq_info, idx)
+		enable_rx(adap, &rxq_info->uldrxq[idx].rspq);
+}
+
+void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+	int idx;
+
+	for_each_uldrxq(rxq_info, idx)
+		quiesce_rx(adap, &rxq_info->uldrxq[idx].rspq);
+}
+
+static void uld_queue_init(struct adapter *adap, unsigned int uld_type,
+			   struct cxgb4_lld_info *lli)
+{
+	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
+
+	lli->rxq_ids = rxq_info->rspq_id;
+	lli->nrxq = rxq_info->nrxq;
+	lli->ciq_ids = rxq_info->rspq_id + rxq_info->nrxq;
+	lli->nciq = rxq_info->nciq;
+}
+
+int uld_mem_alloc(struct adapter *adap)
+{
+	struct sge *s = &adap->sge;
+
+	adap->uld = kcalloc(adap->num_uld, sizeof(*adap->uld), GFP_KERNEL);
+	if (!adap->uld)
+		return -ENOMEM;
+
+	s->uld_rxq_info = kzalloc(adap->num_uld *
+				  sizeof(struct sge_uld_rxq_info *),
+				  GFP_KERNEL);
+	if (!s->uld_rxq_info)
+		goto err_uld;
+
+	return 0;
+err_uld:
+	kfree(adap->uld);
+	return -ENOMEM;
+}
+
+void uld_mem_free(struct adapter *adap)
+{
+	struct sge *s = &adap->sge;
+
+	kfree(s->uld_rxq_info);
+	kfree(adap->uld);
+}
+
+static void uld_init(struct adapter *adap, struct cxgb4_lld_info *lld)
+{
+	int i;
+
+	lld->pdev = adap->pdev;
+	lld->pf = adap->pf;
+	lld->l2t = adap->l2t;
+	lld->tids = &adap->tids;
+	lld->ports = adap->port;
+	lld->vr = &adap->vres;
+	lld->mtus = adap->params.mtus;
+	lld->ntxq = adap->sge.iscsiqsets;
+	lld->nchan = adap->params.nports;
+	lld->nports = adap->params.nports;
+	lld->wr_cred = adap->params.ofldq_wr_cred;
+	lld->adapter_type = adap->params.chip;
+	lld->cclk_ps = 1000000000 / adap->params.vpd.cclk;
+	lld->udb_density = 1 << adap->params.sge.eq_qpp;
+	lld->ucq_density = 1 << adap->params.sge.iq_qpp;
+	lld->filt_mode = adap->params.tp.vlan_pri_map;
+	/* MODQ_REQ_MAP sets queues 0-3 to chan 0-3 */
+	for (i = 0; i < NCHAN; i++)
+		lld->tx_modq[i] = i;
+	lld->gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS_A);
+	lld->db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL_A);
+	lld->fw_vers = adap->params.fw_vers;
+	lld->dbfifo_int_thresh = dbfifo_int_thresh;
+	lld->sge_ingpadboundary = adap->sge.fl_align;
+	lld->sge_egrstatuspagesize = adap->sge.stat_len;
+	lld->sge_pktshift = adap->sge.pktshift;
+	lld->enable_fw_ofld_conn = adap->flags & FW_OFLD_CONN;
+	lld->max_ordird_qp = adap->params.max_ordird_qp;
+	lld->max_ird_adapter = adap->params.max_ird_adapter;
+	lld->ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
+	lld->nodeid = dev_to_node(adap->pdev_dev);
+}
+
+static void uld_attach(struct adapter *adap, unsigned int uld)
+{
+	void *handle;
+	struct cxgb4_lld_info lli;
+
+	uld_init(adap, &lli);
+	uld_queue_init(adap, uld, &lli);
+
+	handle = adap->uld[uld].add(&lli);
+	if (IS_ERR(handle)) {
+		dev_warn(adap->pdev_dev,
+			 "could not attach to the %s driver, error %ld\n",
+			 adap->uld[uld].name, PTR_ERR(handle));
+		return;
+	}
+
+	adap->uld[uld].handle = handle;
+
+	if (adap->flags & FULL_INIT_DONE)
+		adap->uld[uld].state_change(handle, CXGB4_STATE_UP);
+}
+
+int cxgb4_register_pci_uld(enum cxgb4_pci_uld type,
+			   struct cxgb4_pci_uld_info *p)
+{
+	int ret = 0;
+	struct adapter *adap;
+
+	if (type >= CXGB4_PCI_ULD_MAX)
+		return -EINVAL;
+
+	mutex_lock(&uld_mutex);
+	list_for_each_entry(adap, &adapter_list, list_node) {
+		if (!is_pci_uld(adap))
+			continue;
+		ret = cfg_queues_uld(adap, type, p);
+		if (ret)
+			goto out;
+		ret = setup_sge_queues_uld(adap, type, p->lro);
+		if (ret)
+			goto free_queues;
+		if (adap->flags & USING_MSIX) {
+			name_msix_vecs_uld(adap, type);
+			ret = request_msix_queue_irqs_uld(adap, type);
+			if (ret)
+				goto free_rxq;
+		}
+		if (adap->flags & FULL_INIT_DONE)
+			enable_rx_uld(adap, type);
+		if (adap->uld[type].add) {
+			ret = -EBUSY;
+			goto free_irq;
+		}
+		adap->uld[type] = *p;
+		uld_attach(adap, type);
+	}
+	mutex_unlock(&uld_mutex);
+	return 0;
+
+free_irq:
+	if (adap->flags & USING_MSIX)
+		free_msix_queue_irqs_uld(adap, type);
+free_rxq:
+	free_sge_queues_uld(adap, type);
+free_queues:
+	free_queues_uld(adap, type);
+out:
+	mutex_unlock(&uld_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(cxgb4_register_pci_uld);
+
+int cxgb4_unregister_pci_uld(enum cxgb4_pci_uld type)
+{
+	struct adapter *adap;
+
+	if (type >= CXGB4_PCI_ULD_MAX)
+		return -EINVAL;
+
+	mutex_lock(&uld_mutex);
+	list_for_each_entry(adap, &adapter_list, list_node) {
+		if (!is_pci_uld(adap))
+			continue;
+		adap->uld[type].handle = NULL;
+		adap->uld[type].add = NULL;
+		if (adap->flags & FULL_INIT_DONE)
+			quiesce_rx_uld(adap, type);
+		if (adap->flags & USING_MSIX)
+			free_msix_queue_irqs_uld(adap, type);
+		free_sge_queues_uld(adap, type);
+		free_queues_uld(adap, type);
+	}
+	mutex_unlock(&uld_mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL(cxgb4_unregister_pci_uld);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index f3c58aa..ab40372 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -32,8 +32,8 @@
  * SOFTWARE.
  */
 
-#ifndef __CXGB4_OFLD_H
-#define __CXGB4_OFLD_H
+#ifndef __CXGB4_ULD_H
+#define __CXGB4_ULD_H
 
 #include <linux/cache.h>
 #include <linux/spinlock.h>
@@ -296,8 +296,36 @@ struct cxgb4_uld_info {
 	void (*lro_flush)(struct t4_lro_mgr *);
 };
 
+enum cxgb4_pci_uld {
+	CXGB4_PCI_ULD1,
+	CXGB4_PCI_ULD_MAX
+};
+
+struct cxgb4_pci_uld_info {
+	const char *name;
+	bool lro;
+	void *handle;
+	unsigned int nrxq;
+	unsigned int nciq;
+	unsigned int rxq_size;
+	unsigned int ciq_size;
+	void *(*add)(const struct cxgb4_lld_info *p);
+	int (*rx_handler)(void *handle, const __be64 *rsp,
+			  const struct pkt_gl *gl);
+	int (*state_change)(void *handle, enum cxgb4_state new_state);
+	int (*control)(void *handle, enum cxgb4_control control, ...);
+	int (*lro_rx_handler)(void *handle, const __be64 *rsp,
+			      const struct pkt_gl *gl,
+			      struct t4_lro_mgr *lro_mgr,
+			      struct napi_struct *napi);
+	void (*lro_flush)(struct t4_lro_mgr *);
+};
+
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
 int cxgb4_unregister_uld(enum cxgb4_uld type);
+int cxgb4_register_pci_uld(enum cxgb4_pci_uld type,
+			   struct cxgb4_pci_uld_info *p);
+int cxgb4_unregister_pci_uld(enum cxgb4_pci_uld type);
 int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
@@ -330,4 +358,4 @@ int cxgb4_bar2_sge_qregs(struct net_device *dev,
 			 u64 *pbar2_qoffset,
 			 unsigned int *pbar2_qid);
 
-#endif  /* !__CXGB4_OFLD_H */
+#endif  /* !__CXGB4_ULD_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index bad253b..49d7190 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2928,8 +2928,8 @@ static void free_txq(struct adapter *adap, struct sge_txq *q)
 	q->desc = NULL;
 }
 
-static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
-			 struct sge_fl *fl)
+void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
+		  struct sge_fl *fl)
 {
 	struct sge *s = &adap->sge;
 	unsigned int fl_id = fl ? fl->cntxt_id : 0xffff;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 392d664..02e4d35a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1060,7 +1060,7 @@ struct fw_caps_config_cmd {
 	__be16 niccaps;
 	__be16 ofldcaps;
 	__be16 rdmacaps;
-	__be16 r4;
+	__be16 cryptocaps;
 	__be16 iscsicaps;
 	__be16 fcoecaps;
 	__be32 cfcsum;
-- 
1.7.3
