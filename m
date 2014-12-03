From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4/cxgb4vf: Use new interfaces to calculate BAR2 SGE Queue Register addresses
Date: Wed,  3 Dec 2014 19:32:53 +0530
Message-ID: <1417615374-12961-4-git-send-email-hariprasad@chelsio.com>
References: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57241
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751925AbaLCN5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:57:15 -0500
In-Reply-To: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BAR2 Going To Sleep (GTS) for T5 and later. Use new BAR2 User Doorbells for
T5 for both cxgb4 and cxgb4vf driver.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    9 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   60 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |    7 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  148 ++++++++--------
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    7 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   12 --
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  185 +++++++++++++++++---
 7 files changed, 288 insertions(+), 140 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 40905c6..c38a936 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -438,7 +438,8 @@ struct sge_fl {                     /* SGE free-buffer queue state */
 	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
 	__be64 *desc;               /* address of HW Rx descriptor ring */
 	dma_addr_t addr;            /* bus address of HW ring start */
-	u64 udb;                    /* BAR2 offset of User Doorbell area */
+	void __iomem *bar2_addr;    /* address of BAR2 Queue registers */
+	unsigned int bar2_qid;      /* Queue ID for BAR2 Queue registers */
 };
 
 /* A packet gather list */
@@ -468,7 +469,8 @@ struct sge_rspq {                   /* state for an SGE response queue */
 	u16 abs_id;                 /* absolute SGE id for the response q */
 	__be64 *desc;               /* address of HW response ring */
 	dma_addr_t phys_addr;       /* physical address of the ring */
-	u64 udb;                    /* BAR2 offset of User Doorbell area */
+	void __iomem *bar2_addr;    /* address of BAR2 Queue registers */
+	unsigned int bar2_qid;      /* Queue ID for BAR2 Queue registers */
 	unsigned int iqe_len;       /* entry size */
 	unsigned int size;          /* capacity of response queue */
 	struct adapter *adap;
@@ -526,7 +528,8 @@ struct sge_txq {
 	int db_disabled;
 	unsigned short db_pidx;
 	unsigned short db_pidx_inc;
-	u64 udb;                    /* BAR2 offset of User Doorbell area */
+	void __iomem *bar2_addr;    /* address of BAR2 Queue registers */
+	unsigned int bar2_qid;      /* Queue ID for BAR2 Queue registers */
 };
 
 struct sge_eth_txq {                /* state for an SGE Ethernet Tx queue */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3aea82b..c770cbf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3791,6 +3791,22 @@ u64 cxgb4_read_sge_timestamp(struct net_device *dev)
 }
 EXPORT_SYMBOL(cxgb4_read_sge_timestamp);
 
+int cxgb4_bar2_sge_qregs(struct net_device *dev,
+			 unsigned int qid,
+			 enum cxgb4_bar2_qtype qtype,
+			 u64 *pbar2_qoffset,
+			 unsigned int *pbar2_qid)
+{
+	return t4_bar2_sge_qregs(netdev2adap(dev),
+				 qid,
+				 (qtype == CXGB4_BAR2_QTYPE_EGRESS
+				  ? T4_BAR2_QTYPE_EGRESS
+				  : T4_BAR2_QTYPE_INGRESS),
+				 pbar2_qoffset,
+				 pbar2_qid);
+}
+EXPORT_SYMBOL(cxgb4_bar2_sge_qregs);
+
 static struct pci_driver cxgb4_driver;
 
 static void check_neigh_update(struct neighbour *neigh)
@@ -3973,31 +3989,18 @@ static void process_db_drop(struct work_struct *work)
 		u32 dropped_db = t4_read_reg(adap, 0x010ac);
 		u16 qid = (dropped_db >> 15) & 0x1ffff;
 		u16 pidx_inc = dropped_db & 0x1fff;
-		unsigned int s_qpp;
-		unsigned short udb_density;
-		unsigned long qpshift;
-		int page;
-		u32 udb;
-
-		dev_warn(adap->pdev_dev,
-			 "Dropped DB 0x%x qid %d bar2 %d coalesce %d pidx %d\n",
-			 dropped_db, qid,
-			 (dropped_db >> 14) & 1,
-			 (dropped_db >> 13) & 1,
-			 pidx_inc);
-
-		drain_db_fifo(adap, 1);
+		u64 bar2_qoffset;
+		unsigned int bar2_qid;
+		int ret;
 
-		s_qpp = QUEUESPERPAGEPF1 * adap->fn;
-		udb_density = 1 << QUEUESPERPAGEPF0_GET(t4_read_reg(adap,
-				SGE_EGRESS_QUEUES_PER_PAGE_PF) >> s_qpp);
-		qpshift = PAGE_SHIFT - ilog2(udb_density);
-		udb = qid << qpshift;
-		udb &= PAGE_MASK;
-		page = udb / PAGE_SIZE;
-		udb += (qid - (page * udb_density)) * 128;
-
-		writel(PIDX(pidx_inc),  adap->bar2 + udb + 8);
+		ret = t4_bar2_sge_qregs(adap, qid, T4_BAR2_QTYPE_EGRESS,
+					&bar2_qoffset, &bar2_qid);
+		if (ret)
+			dev_err(adap->pdev_dev, "doorbell drop recovery: "
+				"qid=%d, pidx_inc=%d\n", qid, pidx_inc);
+		else
+			writel(PIDX_T5(pidx_inc) | QID(bar2_qid),
+			       adap->bar2 + bar2_qoffset + SGE_UDB_KDOORBELL);
 
 		/* Re-enable BAR2 WC */
 		t4_set_reg_field(adap, 0x10b0, 1<<15, 1<<15);
@@ -4055,12 +4058,8 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.adapter_type = adap->params.chip;
 	lli.iscsi_iolen = MAXRXDATA_GET(t4_read_reg(adap, TP_PARA_REG2));
 	lli.cclk_ps = 1000000000 / adap->params.vpd.cclk;
-	lli.udb_density = 1 << QUEUESPERPAGEPF0_GET(
-			t4_read_reg(adap, SGE_EGRESS_QUEUES_PER_PAGE_PF) >>
-			(adap->fn * 4));
-	lli.ucq_density = 1 << QUEUESPERPAGEPF0_GET(
-			t4_read_reg(adap, SGE_INGRESS_QUEUES_PER_PAGE_PF) >>
-			(adap->fn * 4));
+	lli.udb_density = 1 << adap->params.sge.eq_qpp;
+	lli.ucq_density = 1 << adap->params.sge.iq_qpp;
 	lli.filt_mode = adap->params.tp.vlan_pri_map;
 	/* MODQ_REQ_MAP sets queues 0-3 to chan 0-3 */
 	for (i = 0; i < NCHAN; i++)
@@ -5912,6 +5911,7 @@ static int adap_init0(struct adapter *adap)
 		t4_load_mtus(adap, adap->params.mtus, adap->params.a_wnd,
 			     adap->params.b_wnd);
 	}
+	t4_init_sge_params(adap);
 	t4_init_tp_params(adap);
 	adap->flags |= FW_OK;
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 4eba7cb..152b4c4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -305,4 +305,11 @@ void cxgb4_enable_db_coalescing(struct net_device *dev);
 int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte);
 u64 cxgb4_read_sge_timestamp(struct net_device *dev);
 
+enum cxgb4_bar2_qtype { CXGB4_BAR2_QTYPE_EGRESS, CXGB4_BAR2_QTYPE_INGRESS };
+int cxgb4_bar2_sge_qregs(struct net_device *dev,
+			 unsigned int qid,
+			 enum cxgb4_bar2_qtype qtype,
+			 u64 *pbar2_qoffset,
+			 unsigned int *pbar2_qid);
+
 #endif  /* !__CXGB4_OFLD_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 433560b..f12debd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -527,14 +527,16 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 		val |= DBPRIO(1);
 		wmb();
 
-		/* If we're on T4, use the old doorbell mechanism; otherwise
-		 * use the new BAR2 mechanism.
+		/* If we don't have access to the new User Doorbell (T5+), use
+		 * the old doorbell mechanism; otherwise use the new BAR2
+		 * mechanism.
 		 */
-		if (is_t4(adap->params.chip)) {
+		if (unlikely(q->bar2_addr == NULL)) {
 			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
 				     val | QID(q->cntxt_id));
 		} else {
-			writel(val,  adap->bar2 + q->udb + SGE_UDB_KDOORBELL);
+			writel(val | QID(q->bar2_qid),
+			       q->bar2_addr + SGE_UDB_KDOORBELL);
 
 			/* This Write memory Barrier will force the write to
 			 * the User Doorbell area to be flushed.
@@ -850,14 +852,13 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		*end = 0;
 }
 
-/* This function copies a tx_desc struct to memory mapped BAR2 space(user space
- * writes). For coalesced WR SGE, fetches data from the FIFO instead of from
- * Host.
+/* This function copies 64 byte coalesced work request to
+ * memory mapped BAR2 space. For coalesced WR SGE fetches
+ * data from the FIFO instead of from Host.
  */
-static void cxgb_pio_copy(u64 __iomem *dst, struct tx_desc *desc)
+static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
 {
-	int count = sizeof(*desc) / sizeof(u64);
-	u64 *src = (u64 *)desc;
+	int count = 8;
 
 	while (count) {
 		writeq(*src, dst);
@@ -879,7 +880,10 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 {
 	wmb();            /* write descriptors before telling HW */
 
-	if (is_t4(adap->params.chip)) {
+	/* If we don't have access to the new User Doorbell (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(q->bar2_addr == NULL)) {
 		u32 val = PIDX(n);
 		unsigned long flags;
 
@@ -905,21 +909,22 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 		 */
 		WARN_ON(val & DBPRIO(1));
 
-		/* For T5 and later we use the Write-Combine mapped BAR2 User
-		 * Doorbell mechanism.  If we're only writing a single TX
-		 * Descriptor and TX Write Combining hasn't been disabled, we
-		 * can use the Write Combining Gather Buffer; otherwise we use
-		 * the simple doorbell.
+		/* If we're only writing a single TX Descriptor and we can use
+		 * Inferred QID registers, we can use the Write Combining
+		 * Gather Buffer; otherwise we use the simple doorbell.
 		 */
-		if (n == 1) {
+		if (n == 1 && q->bar2_qid == 0) {
 			int index = (q->pidx
 				     ? (q->pidx - 1)
 				     : (q->size - 1));
+			u64 *wr = (u64 *)&q->desc[index];
 
-			cxgb_pio_copy(adap->bar2 + q->udb + SGE_UDB_WCDOORBELL,
-				      q->desc + index);
+			cxgb_pio_copy((u64 __iomem *)
+				      (q->bar2_addr + SGE_UDB_WCDOORBELL),
+				      wr);
 		} else {
-			writel(val,  adap->bar2 + q->udb + SGE_UDB_KDOORBELL);
+			writel(val | QID(q->bar2_qid),
+			       q->bar2_addr + SGE_UDB_KDOORBELL);
 		}
 
 		/* This Write Memory Barrier will force the write to the User
@@ -1997,11 +2002,16 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		params = QINTR_TIMER_IDX(7);
 
 	val = CIDXINC(work_done) | SEINTARM(params);
-	if (is_t4(q->adap->params.chip)) {
+
+	/* If we don't have access to the new User GTS (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(q->bar2_addr == NULL)) {
 		t4_write_reg(q->adap, MYPF_REG(SGE_PF_GTS),
 			     val | INGRESSQID((u32)q->cntxt_id));
 	} else {
-		writel(val, q->adap->bar2 + q->udb + SGE_UDB_GTS);
+		writel(val | INGRESSQID(q->bar2_qid),
+		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
 	return work_done;
@@ -2047,11 +2057,16 @@ static unsigned int process_intrq(struct adapter *adap)
 	}
 
 	val =  CIDXINC(credits) | SEINTARM(q->intr_params);
-	if (is_t4(adap->params.chip)) {
+
+	/* If we don't have access to the new User GTS (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(q->bar2_addr == NULL)) {
 		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS),
 			     val | INGRESSQID(q->cntxt_id));
 	} else {
-		writel(val, adap->bar2 + q->udb + SGE_UDB_GTS);
+		writel(val | INGRESSQID(q->bar2_qid),
+		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
 	spin_unlock(&adap->sge.intrq_lock);
@@ -2235,48 +2250,32 @@ static void sge_tx_timer_cb(unsigned long data)
 }
 
 /**
- *      udb_address - return the BAR2 User Doorbell address for a Queue
- *      @adap: the adapter
- *      @cntxt_id: the Queue Context ID
- *      @qpp: Queues Per Page (for all PFs)
+ *	bar2_address - return the BAR2 address for an SGE Queue's Registers
+ *	@adapter: the adapter
+ *	@qid: the SGE Queue ID
+ *	@qtype: the SGE Queue Type (Egress or Ingress)
+ *	@pbar2_qid: BAR2 Queue ID or 0 for Queue ID inferred SGE Queues
  *
- *      Returns the BAR2 address of the user Doorbell associated with the
- *      indicated Queue Context ID.  Note that this is only applicable
- *      for T5 and later.
- */
-static u64 udb_address(struct adapter *adap, unsigned int cntxt_id,
-		       unsigned int qpp)
-{
-	u64 udb;
-	unsigned int s_qpp;
-	unsigned short udb_density;
-	unsigned long qpshift;
-	int page;
-
-	BUG_ON(is_t4(adap->params.chip));
-
-	s_qpp = (QUEUESPERPAGEPF0 +
-		(QUEUESPERPAGEPF1 - QUEUESPERPAGEPF0) * adap->fn);
-	udb_density = 1 << ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
-	qpshift = PAGE_SHIFT - ilog2(udb_density);
-	udb = (u64)cntxt_id << qpshift;
-	udb &= PAGE_MASK;
-	page = udb / PAGE_SIZE;
-	udb += (cntxt_id - (page * udb_density)) * SGE_UDB_SIZE;
-
-	return udb;
-}
+ *	Returns the BAR2 address for the SGE Queue Registers associated with
+ *	@qid.  If BAR2 SGE Registers aren't available, returns NULL.  Also
+ *	returns the BAR2 Queue ID to be used with writes to the BAR2 SGE
+ *	Queue Registers.  If the BAR2 Queue ID is 0, then "Inferred Queue ID"
+ *	Registers are supported (e.g. the Write Combining Doorbell Buffer).
+ */
+static void __iomem *bar2_address(struct adapter *adapter,
+				  unsigned int qid,
+				  enum t4_bar2_qtype qtype,
+				  unsigned int *pbar2_qid)
+{
+	u64 bar2_qoffset;
+	int ret;
 
-static u64 udb_address_eq(struct adapter *adap, unsigned int cntxt_id)
-{
-	return udb_address(adap, cntxt_id,
-			   t4_read_reg(adap, SGE_EGRESS_QUEUES_PER_PAGE_PF));
-}
+	ret = t4_bar2_sge_qregs(adapter, qid, qtype,
+				&bar2_qoffset, pbar2_qid);
+	if (ret)
+		return NULL;
 
-static u64 udb_address_iq(struct adapter *adap, unsigned int cntxt_id)
-{
-	return udb_address(adap, cntxt_id,
-			   t4_read_reg(adap, SGE_INGRESS_QUEUES_PER_PAGE_PF));
+	return adapter->bar2 + bar2_qoffset;
 }
 
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
@@ -2344,8 +2343,10 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	iq->next_intr_params = iq->intr_params;
 	iq->cntxt_id = ntohs(c.iqid);
 	iq->abs_id = ntohs(c.physiqid);
-	if (!is_t4(adap->params.chip))
-		iq->udb = udb_address_iq(adap, iq->cntxt_id);
+	iq->bar2_addr = bar2_address(adap,
+				     iq->cntxt_id,
+				     T4_BAR2_QTYPE_INGRESS,
+				     &iq->bar2_qid);
 	iq->size--;                           /* subtract status entry */
 	iq->netdev = dev;
 	iq->handler = hnd;
@@ -2362,11 +2363,13 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		fl->alloc_failed = fl->large_alloc_failed = fl->starving = 0;
 		adap->sge.egr_map[fl->cntxt_id - adap->sge.egr_start] = fl;
 
-		/* Note, we must initialize the Free List User Doorbell
-		 * address before refilling the Free List!
+		/* Note, we must initialize the BAR2 Free List User Doorbell
+		 * information before refilling the Free List!
 		 */
-		if (!is_t4(adap->params.chip))
-			fl->udb = udb_address_eq(adap, fl->cntxt_id);
+		fl->bar2_addr = bar2_address(adap,
+					     fl->cntxt_id,
+					     T4_BAR2_QTYPE_EGRESS,
+					     &fl->bar2_qid);
 		refill_fl(adap, fl, fl_cap(fl), GFP_KERNEL);
 	}
 	return 0;
@@ -2392,9 +2395,10 @@ err:
 static void init_txq(struct adapter *adap, struct sge_txq *q, unsigned int id)
 {
 	q->cntxt_id = id;
-	if (!is_t4(adap->params.chip))
-		q->udb = udb_address_eq(adap, q->cntxt_id);
-
+	q->bar2_addr = bar2_address(adap,
+				    q->cntxt_id,
+				    T4_BAR2_QTYPE_EGRESS,
+				    &q->bar2_qid);
 	q->in_use = 0;
 	q->cidx = q->pidx = 0;
 	q->stops = q->restarts = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 3d06e77..d00a751 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -138,6 +138,8 @@ struct sge_fl {
 	struct rx_sw_desc *sdesc;	/* address of SW RX descriptor ring */
 	__be64 *desc;			/* address of HW RX descriptor ring */
 	dma_addr_t addr;		/* PCI bus address of hardware ring */
+	void __iomem *bar2_addr;	/* address of BAR2 Queue registers */
+	unsigned int bar2_qid;		/* Queue ID for BAR2 Queue registers */
 };
 
 /*
@@ -178,6 +180,8 @@ struct sge_rspq {
 	u16 abs_id;			/* SGE abs QID for the response Q */
 	__be64 *desc;			/* address of hardware response ring */
 	dma_addr_t phys_addr;		/* PCI bus address of ring */
+	void __iomem *bar2_addr;	/* address of BAR2 Queue registers */
+	unsigned int bar2_qid;		/* Queue ID for BAR2 Queue registers */
 	unsigned int iqe_len;		/* entry size */
 	unsigned int size;		/* capcity of response Q */
 	struct adapter *adapter;	/* our adapter */
@@ -240,6 +244,8 @@ struct sge_txq {
 	struct tx_sw_desc *sdesc;	/* address of SW TX descriptor ring */
 	struct sge_qstat *stat;		/* queue status entry */
 	dma_addr_t phys_addr;		/* PCI bus address of hardware ring */
+	void __iomem *bar2_addr;	/* address of BAR2 Queue registers */
+	unsigned int bar2_qid;		/* Queue ID for BAR2 Queue registers */
 };
 
 /*
@@ -345,6 +351,7 @@ struct sge {
 struct adapter {
 	/* PCI resources */
 	void __iomem *regs;
+	void __iomem *bar2;
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index c5425f0..aa74ec3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2095,7 +2095,6 @@ static int adap_init0(struct adapter *adapter)
 	unsigned int ethqsets;
 	int err;
 	u32 param, val = 0;
-	unsigned int chipid;
 
 	/*
 	 * Wait for the device to become ready before proceeding ...
@@ -2123,17 +2122,6 @@ static int adap_init0(struct adapter *adapter)
 		return err;
 	}
 
-	adapter->params.chip = 0;
-	switch (adapter->pdev->device >> 12) {
-	case CHELSIO_T4:
-		adapter->params.chip = CHELSIO_CHIP_CODE(CHELSIO_T4, 0);
-		break;
-	case CHELSIO_T5:
-		chipid = G_REV(t4_read_reg(adapter, A_PL_VF_REV));
-		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, chipid);
-		break;
-	}
-
 	/*
 	 * Grab basic operational parameters.  These will predominantly have
 	 * been set up by the Physical Function Driver or will be hard coded
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 045301d..f7fd131 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -525,19 +525,40 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 {
 	u32 val;
 
-	/*
-	 * The SGE keeps track of its Producer and Consumer Indices in terms
+	/* The SGE keeps track of its Producer and Consumer Indices in terms
 	 * of Egress Queue Units so we can only tell it about integral numbers
 	 * of multiples of Free List Entries per Egress Queue Units ...
 	 */
 	if (fl->pend_cred >= FL_PER_EQ_UNIT) {
-		val = PIDX(fl->pend_cred / FL_PER_EQ_UNIT);
-		if (!is_t4(adapter->params.chip))
-			val |= DBTYPE(1);
+		if (is_t4(adapter->params.chip))
+			val = PIDX(fl->pend_cred / FL_PER_EQ_UNIT);
+		else
+			val = PIDX_T5(fl->pend_cred / FL_PER_EQ_UNIT) |
+			      DBTYPE(1);
+		val |= DBPRIO(1);
+
+		/* Make sure all memory writes to the Free List queue are
+		 * committed before we tell the hardware about them.
+		 */
 		wmb();
-		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
-			     DBPRIO(1) |
-			     QID(fl->cntxt_id) | val);
+
+		/* If we don't have access to the new User Doorbell (T5+), use
+		 * the old doorbell mechanism; otherwise use the new BAR2
+		 * mechanism.
+		 */
+		if (unlikely(fl->bar2_addr == NULL)) {
+			t4_write_reg(adapter,
+				     T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
+				     QID(fl->cntxt_id) | val);
+		} else {
+			writel(val | QID(fl->bar2_qid),
+			       fl->bar2_addr + SGE_UDB_KDOORBELL);
+
+			/* This Write memory Barrier will force the write to
+			 * the User Doorbell area to be flushed.
+			 */
+			wmb();
+		}
 		fl->pend_cred %= FL_PER_EQ_UNIT;
 	}
 }
@@ -949,14 +970,74 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 			      int n)
 {
-	/*
-	 * Warn if we write doorbells with the wrong priority and write
-	 * descriptors before telling HW.
+	/* Make sure that all writes to the TX Descriptors are committed
+	 * before we tell the hardware about them.
 	 */
-	WARN_ON((QID(tq->cntxt_id) | PIDX(n)) & DBPRIO(1));
 	wmb();
-	t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
-		     QID(tq->cntxt_id) | PIDX(n));
+
+	/* If we don't have access to the new User Doorbell (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(tq->bar2_addr == NULL)) {
+		u32 val = PIDX(n);
+
+		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
+			     QID(tq->cntxt_id) | val);
+	} else {
+		u32 val = PIDX_T5(n);
+
+		/* T4 and later chips share the same PIDX field offset within
+		 * the doorbell, but T5 and later shrank the field in order to
+		 * gain a bit for Doorbell Priority.  The field was absurdly
+		 * large in the first place (14 bits) so we just use the T5
+		 * and later limits and warn if a Queue ID is too large.
+		 */
+		WARN_ON(val & DBPRIO(1));
+
+		/* If we're only writing a single Egress Unit and the BAR2
+		 * Queue ID is 0, we can use the Write Combining Doorbell
+		 * Gather Buffer; otherwise we use the simple doorbell.
+		 */
+		if (n == 1 && tq->bar2_qid == 0) {
+			unsigned int index = (tq->pidx
+					      ? (tq->pidx - 1)
+					      : (tq->size - 1));
+			__be64 *src = (__be64 *)&tq->desc[index];
+			__be64 __iomem *dst = (__be64 *)(tq->bar2_addr +
+							 SGE_UDB_WCDOORBELL);
+			unsigned int count = EQ_UNIT / sizeof(__be64);
+
+			/* Copy the TX Descriptor in a tight loop in order to
+			 * try to get it to the adapter in a single Write
+			 * Combined transfer on the PCI-E Bus.  If the Write
+			 * Combine fails (say because of an interrupt, etc.)
+			 * the hardware will simply take the last write as a
+			 * simple doorbell write with a PIDX Increment of 1
+			 * and will fetch the TX Descriptor from memory via
+			 * DMA.
+			 */
+			while (count) {
+				writeq(*src, dst);
+				src++;
+				dst++;
+				count--;
+			}
+		} else
+			writel(val | QID(tq->bar2_qid),
+			       tq->bar2_addr + SGE_UDB_KDOORBELL);
+
+		/* This Write Memory Barrier will force the write to the User
+		 * Doorbell area to be flushed.  This is needed to prevent
+		 * writes on different CPUs for the same queue from hitting
+		 * the adapter out of order.  This is required when some Work
+		 * Requests take the Write Combine Gather Buffer path (user
+		 * doorbell area offset [SGE_UDB_WCDOORBELL..+63]) and some
+		 * take the traditional path where we simply increment the
+		 * PIDX (User Doorbell area SGE_UDB_KDOORBELL) and have the
+		 * hardware DMA read the actual Work Request.
+		 */
+		wmb();
+	}
 }
 
 /**
@@ -1782,6 +1863,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	unsigned int intr_params;
 	struct sge_rspq *rspq = container_of(napi, struct sge_rspq, napi);
 	int work_done = process_responses(rspq, budget);
+	u32 val;
 
 	if (likely(work_done < budget)) {
 		napi_complete(napi);
@@ -1793,11 +1875,16 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	if (unlikely(work_done == 0))
 		rspq->unhandled_irqs++;
 
-	t4_write_reg(rspq->adapter,
-		     T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-		     CIDXINC(work_done) |
-		     INGRESSQID((u32)rspq->cntxt_id) |
-		     SEINTARM(intr_params));
+	val = CIDXINC(work_done) | SEINTARM(intr_params);
+	if (is_t4(rspq->adapter->params.chip)) {
+		t4_write_reg(rspq->adapter,
+			     T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
+			     val | INGRESSQID((u32)rspq->cntxt_id));
+	} else {
+		writel(val | INGRESSQID(rspq->bar2_qid),
+		       rspq->bar2_addr + SGE_UDB_GTS);
+		wmb();
+	}
 	return work_done;
 }
 
@@ -1822,6 +1909,7 @@ static unsigned int process_intrq(struct adapter *adapter)
 	struct sge *s = &adapter->sge;
 	struct sge_rspq *intrq = &s->intrq;
 	unsigned int work_done;
+	u32 val;
 
 	spin_lock(&adapter->sge.intrq_lock);
 	for (work_done = 0; ; work_done++) {
@@ -1887,10 +1975,15 @@ static unsigned int process_intrq(struct adapter *adapter)
 		rspq_next(intrq);
 	}
 
-	t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-		     CIDXINC(work_done) |
-		     INGRESSQID(intrq->cntxt_id) |
-		     SEINTARM(intrq->intr_params));
+	val = CIDXINC(work_done) | SEINTARM(intrq->intr_params);
+	if (is_t4(adapter->params.chip))
+		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
+			     val | INGRESSQID(intrq->cntxt_id));
+	else {
+		writel(val | INGRESSQID(intrq->bar2_qid),
+		       intrq->bar2_addr + SGE_UDB_GTS);
+		wmb();
+	}
 
 	spin_unlock(&adapter->sge.intrq_lock);
 
@@ -2036,6 +2129,35 @@ static void sge_tx_timer_cb(unsigned long data)
 }
 
 /**
+ *	bar2_address - return the BAR2 address for an SGE Queue's Registers
+ *	@adapter: the adapter
+ *	@qid: the SGE Queue ID
+ *	@qtype: the SGE Queue Type (Egress or Ingress)
+ *	@pbar2_qid: BAR2 Queue ID or 0 for Queue ID inferred SGE Queues
+ *
+ *	Returns the BAR2 address for the SGE Queue Registers associated with
+ *	@qid.  If BAR2 SGE Registers aren't available, returns NULL.  Also
+ *	returns the BAR2 Queue ID to be used with writes to the BAR2 SGE
+ *	Queue Registers.  If the BAR2 Queue ID is 0, then "Inferred Queue ID"
+ *	Registers are supported (e.g. the Write Combining Doorbell Buffer).
+ */
+static void __iomem *bar2_address(struct adapter *adapter,
+				  unsigned int qid,
+				  enum t4_bar2_qtype qtype,
+				  unsigned int *pbar2_qid)
+{
+	u64 bar2_qoffset;
+	int ret;
+
+	ret = t4_bar2_sge_qregs(adapter, qid, qtype,
+				&bar2_qoffset, pbar2_qid);
+	if (ret)
+		return NULL;
+
+	return adapter->bar2 + bar2_qoffset;
+}
+
+/**
  *	t4vf_sge_alloc_rxq - allocate an SGE RX Queue
  *	@adapter: the adapter
  *	@rspq: pointer to to the new rxq's Response Queue to be filled in
@@ -2166,6 +2288,10 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 	rspq->gen = 1;
 	rspq->next_intr_params = rspq->intr_params;
 	rspq->cntxt_id = be16_to_cpu(rpl.iqid);
+	rspq->bar2_addr = bar2_address(adapter,
+				       rspq->cntxt_id,
+				       T4_BAR2_QTYPE_INGRESS,
+				       &rspq->bar2_qid);
 	rspq->abs_id = be16_to_cpu(rpl.physiqid);
 	rspq->size--;			/* subtract status entry */
 	rspq->adapter = adapter;
@@ -2184,6 +2310,15 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 		fl->alloc_failed = 0;
 		fl->large_alloc_failed = 0;
 		fl->starving = 0;
+
+		/* Note, we must initialize the BAR2 Free List User Doorbell
+		 * information before refilling the Free List!
+		 */
+		fl->bar2_addr = bar2_address(adapter,
+					     fl->cntxt_id,
+					     T4_BAR2_QTYPE_EGRESS,
+					     &fl->bar2_qid);
+
 		refill_fl(adapter, fl, fl_cap(fl), GFP_KERNEL);
 	}
 
@@ -2296,6 +2431,10 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	txq->q.pidx = 0;
 	txq->q.stat = (void *)&txq->q.desc[txq->q.size];
 	txq->q.cntxt_id = FW_EQ_ETH_CMD_EQID_G(be32_to_cpu(rpl.eqid_pkd));
+	txq->q.bar2_addr = bar2_address(adapter,
+					txq->q.cntxt_id,
+					T4_BAR2_QTYPE_EGRESS,
+					&txq->q.bar2_qid);
 	txq->q.abs_id =
 		FW_EQ_ETH_CMD_PHYSEQID_G(be32_to_cpu(rpl.physeqid_pkd));
 	txq->txq = devq;
-- 
1.7.1
