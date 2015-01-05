From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] RDMA/cxgb4/cxgb4vf/csiostor: Cleanup SGE register defines
Date: Mon,  5 Jan 2015 16:30:43 +0530
Message-ID: <1420455647-23094-2-git-send-email-hariprasad@chelsio.com>
References: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15901 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753348AbbAEK4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 05:56:20 -0500
In-Reply-To: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanups all SGE related macros/register defines that are
defined in t4_regs.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/t4.h                   |   26 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   76 ++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   96 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  118 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  498 +++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   81 ++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   24 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   47 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   17 +-
 drivers/scsi/csiostor/csio_hw.c                    |   58 ++--
 drivers/scsi/csiostor/csio_hw_chip.h               |    8 +-
 drivers/scsi/csiostor/csio_wr.c                    |  112 +++---
 12 files changed, 670 insertions(+), 491 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_values.h

diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index c04e513..29e764e 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -465,14 +465,14 @@ static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, u8 t5,
 		} else {
 			PDBG("%s: DB wq->sq.pidx = %d\n",
 			     __func__, wq->sq.pidx);
-			writel(PIDX_T5(inc), wq->sq.udb);
+			writel(PIDX_T5_V(inc), wq->sq.udb);
 		}
 
 		/* Flush user doorbell area writes. */
 		wmb();
 		return;
 	}
-	writel(QID(wq->sq.qid) | PIDX(inc), wq->db);
+	writel(QID_V(wq->sq.qid) | PIDX_V(inc), wq->db);
 }
 
 static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc, u8 t5,
@@ -489,14 +489,14 @@ static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc, u8 t5,
 		} else {
 			PDBG("%s: DB wq->rq.pidx = %d\n",
 			     __func__, wq->rq.pidx);
-			writel(PIDX_T5(inc), wq->rq.udb);
+			writel(PIDX_T5_V(inc), wq->rq.udb);
 		}
 
 		/* Flush user doorbell area writes. */
 		wmb();
 		return;
 	}
-	writel(QID(wq->rq.qid) | PIDX(inc), wq->db);
+	writel(QID_V(wq->rq.qid) | PIDX_V(inc), wq->db);
 }
 
 static inline int t4_wq_in_error(struct t4_wq *wq)
@@ -561,14 +561,14 @@ static inline int t4_arm_cq(struct t4_cq *cq, int se)
 	u32 val;
 
 	set_bit(CQ_ARMED, &cq->flags);
-	while (cq->cidx_inc > CIDXINC_MASK) {
-		val = SEINTARM(0) | CIDXINC(CIDXINC_MASK) | TIMERREG(7) |
-		      INGRESSQID(cq->cqid);
+	while (cq->cidx_inc > CIDXINC_M) {
+		val = SEINTARM_V(0) | CIDXINC_V(CIDXINC_M) | TIMERREG_V(7) |
+		      INGRESSQID_V(cq->cqid);
 		writel(val, cq->gts);
-		cq->cidx_inc -= CIDXINC_MASK;
+		cq->cidx_inc -= CIDXINC_M;
 	}
-	val = SEINTARM(se) | CIDXINC(cq->cidx_inc) | TIMERREG(6) |
-	      INGRESSQID(cq->cqid);
+	val = SEINTARM_V(se) | CIDXINC_V(cq->cidx_inc) | TIMERREG_V(6) |
+	      INGRESSQID_V(cq->cqid);
 	writel(val, cq->gts);
 	cq->cidx_inc = 0;
 	return 0;
@@ -597,11 +597,11 @@ static inline void t4_swcq_consume(struct t4_cq *cq)
 static inline void t4_hwcq_consume(struct t4_cq *cq)
 {
 	cq->bits_type_ts = cq->queue[cq->cidx].bits_type_ts;
-	if (++cq->cidx_inc == (cq->size >> 4) || cq->cidx_inc == CIDXINC_MASK) {
+	if (++cq->cidx_inc == (cq->size >> 4) || cq->cidx_inc == CIDXINC_M) {
 		u32 val;
 
-		val = SEINTARM(0) | CIDXINC(cq->cidx_inc) | TIMERREG(7) |
-		      INGRESSQID(cq->cqid);
+		val = SEINTARM_V(0) | CIDXINC_V(cq->cidx_inc) | TIMERREG_V(7) |
+		      INGRESSQID_V(cq->cqid);
 		writel(val, cq->gts);
 		cq->cidx_inc = 0;
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ccf3436..5e0d57a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -66,6 +66,7 @@
 
 #include "cxgb4.h"
 #include "t4_regs.h"
+#include "t4_values.h"
 #include "t4_msg.h"
 #include "t4fw_api.h"
 #include "cxgb4_dcb.h"
@@ -1050,9 +1051,9 @@ static void enable_rx(struct adapter *adap)
 		if (q->handler)
 			napi_enable(&q->napi);
 		/* 0-increment GTS to start the timer and enable interrupts */
-		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS),
-			     SEINTARM(q->intr_params) |
-			     INGRESSQID(q->cntxt_id));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
+			     SEINTARM_V(q->intr_params) |
+			     INGRESSQID_V(q->cntxt_id));
 	}
 }
 
@@ -3702,14 +3703,20 @@ int cxgb4_sync_txq_pidx(struct net_device *dev, u16 qid, u16 pidx,
 
 	if (pidx != hw_pidx) {
 		u16 delta;
+		u32 val;
 
 		if (pidx >= hw_pidx)
 			delta = pidx - hw_pidx;
 		else
 			delta = size - hw_pidx + pidx;
+
+		if (is_t4(adap->params.chip))
+			val = PIDX_V(delta);
+		else
+			val = PIDX_T5_V(delta);
 		wmb();
-		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-			     QID(qid) | PIDX(delta));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL_A),
+			     QID_V(qid) | val);
 	}
 out:
 	return ret;
@@ -3721,8 +3728,8 @@ void cxgb4_disable_db_coalescing(struct net_device *dev)
 	struct adapter *adap;
 
 	adap = netdev2adap(dev);
-	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_NOCOALESCE,
-			 F_NOCOALESCE);
+	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, NOCOALESCE_F,
+			 NOCOALESCE_F);
 }
 EXPORT_SYMBOL(cxgb4_disable_db_coalescing);
 
@@ -3731,7 +3738,7 @@ void cxgb4_enable_db_coalescing(struct net_device *dev)
 	struct adapter *adap;
 
 	adap = netdev2adap(dev);
-	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_NOCOALESCE, 0);
+	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, NOCOALESCE_F, 0);
 }
 EXPORT_SYMBOL(cxgb4_enable_db_coalescing);
 
@@ -3809,8 +3816,8 @@ u64 cxgb4_read_sge_timestamp(struct net_device *dev)
 	struct adapter *adap;
 
 	adap = netdev2adap(dev);
-	lo = t4_read_reg(adap, SGE_TIMESTAMP_LO);
-	hi = GET_TSVAL(t4_read_reg(adap, SGE_TIMESTAMP_HI));
+	lo = t4_read_reg(adap, SGE_TIMESTAMP_LO_A);
+	hi = TSVAL_G(t4_read_reg(adap, SGE_TIMESTAMP_HI_A));
 
 	return ((u64)hi << 32) | (u64)lo;
 }
@@ -3904,8 +3911,8 @@ static void enable_txq_db(struct adapter *adap, struct sge_txq *q)
 		 * are committed before we tell HW about them.
 		 */
 		wmb();
-		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-			     QID(q->cntxt_id) | PIDX(q->db_pidx_inc));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL_A),
+			     QID_V(q->cntxt_id) | PIDX_V(q->db_pidx_inc));
 		q->db_pidx_inc = 0;
 	}
 	q->db_disabled = 0;
@@ -3952,9 +3959,9 @@ static void process_db_full(struct work_struct *work)
 	drain_db_fifo(adap, dbfifo_drain_delay);
 	enable_dbs(adap);
 	notify_rdma_uld(adap, CXGB4_CONTROL_DB_EMPTY);
-	t4_set_reg_field(adap, SGE_INT_ENABLE3,
-			 DBFIFO_HP_INT | DBFIFO_LP_INT,
-			 DBFIFO_HP_INT | DBFIFO_LP_INT);
+	t4_set_reg_field(adap, SGE_INT_ENABLE3_A,
+			 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F,
+			 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F);
 }
 
 static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
@@ -3968,14 +3975,20 @@ static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
 		goto out;
 	if (q->db_pidx != hw_pidx) {
 		u16 delta;
+		u32 val;
 
 		if (q->db_pidx >= hw_pidx)
 			delta = q->db_pidx - hw_pidx;
 		else
 			delta = q->size - hw_pidx + q->db_pidx;
+
+		if (is_t4(adap->params.chip))
+			val = PIDX_V(delta);
+		else
+			val = PIDX_T5_V(delta);
 		wmb();
-		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-			     QID(q->cntxt_id) | PIDX(delta));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL_A),
+			     QID_V(q->cntxt_id) | val);
 	}
 out:
 	q->db_disabled = 0;
@@ -4024,7 +4037,7 @@ static void process_db_drop(struct work_struct *work)
 			dev_err(adap->pdev_dev, "doorbell drop recovery: "
 				"qid=%d, pidx_inc=%d\n", qid, pidx_inc);
 		else
-			writel(PIDX_T5(pidx_inc) | QID(bar2_qid),
+			writel(PIDX_T5_V(pidx_inc) | QID_V(bar2_qid),
 			       adap->bar2 + bar2_qoffset + SGE_UDB_KDOORBELL);
 
 		/* Re-enable BAR2 WC */
@@ -4039,8 +4052,8 @@ void t4_db_full(struct adapter *adap)
 	if (is_t4(adap->params.chip)) {
 		disable_dbs(adap);
 		notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
-		t4_set_reg_field(adap, SGE_INT_ENABLE3,
-				 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
+		t4_set_reg_field(adap, SGE_INT_ENABLE3_A,
+				 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F, 0);
 		queue_work(adap->workq, &adap->db_full_task);
 	}
 }
@@ -4089,8 +4102,8 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	/* MODQ_REQ_MAP sets queues 0-3 to chan 0-3 */
 	for (i = 0; i < NCHAN; i++)
 		lli.tx_modq[i] = i;
-	lli.gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS);
-	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL);
+	lli.gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS_A);
+	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL_A);
 	lli.fw_vers = adap->params.fw_vers;
 	lli.dbfifo_int_thresh = dbfifo_int_thresh;
 	lli.sge_ingpadboundary = adap->sge.fl_align;
@@ -4783,7 +4796,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 
 void t4_fatal_err(struct adapter *adap)
 {
-	t4_set_reg_field(adap, SGE_CONTROL, GLOBALENABLE, 0);
+	t4_set_reg_field(adap, SGE_CONTROL_A, GLOBALENABLE_F, 0);
 	t4_intr_disable(adap);
 	dev_alert(adap->pdev_dev, "encountered fatal error, adapter stopped\n");
 }
@@ -5013,9 +5026,9 @@ static int adap_init0_tweaks(struct adapter *adapter)
 			rx_dma_offset);
 		rx_dma_offset = 2;
 	}
-	t4_set_reg_field(adapter, SGE_CONTROL,
-			 PKTSHIFT_MASK,
-			 PKTSHIFT(rx_dma_offset));
+	t4_set_reg_field(adapter, SGE_CONTROL_A,
+			 PKTSHIFT_V(PKTSHIFT_M),
+			 PKTSHIFT_V(rx_dma_offset));
 
 	/*
 	 * Don't include the "IP Pseudo Header" in CPL_RX_PKT checksums: Linux
@@ -5332,8 +5345,7 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	s->timer_val[SGE_NTIMERS - 1] = MAX_SGE_TIMERVAL;
 	s->counter_val[0] = 1;
 	for (i = 1; i < SGE_NCOUNTERS; i++)
-		s->counter_val[i] = min(intr_cnt[i - 1],
-					THRESHOLD_0_GET(THRESHOLD_0_MASK));
+		s->counter_val[i] = min(intr_cnt[i - 1], THRESHOLD_0_M);
 	t4_sge_init(adapter);
 
 #ifdef CONFIG_PCI_IOV
@@ -6467,9 +6479,11 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 
 	if (!is_t4(adapter->params.chip)) {
-		s_qpp = QUEUESPERPAGEPF1 * adapter->fn;
-		qpp = 1 << QUEUESPERPAGEPF0_GET(t4_read_reg(adapter,
-		      SGE_EGRESS_QUEUES_PER_PAGE_PF) >> s_qpp);
+		s_qpp = (QUEUESPERPAGEPF0_S +
+			(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) *
+			adapter->fn);
+		qpp = 1 << QUEUESPERPAGEPF0_G(t4_read_reg(adapter,
+		      SGE_EGRESS_QUEUES_PER_PAGE_PF_A) >> s_qpp);
 		num_seg = PAGE_SIZE / SEGMENT_SIZE;
 
 		/* Each segment size is 128B. Write coalescing is enabled only
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index ebf935a..4449fc7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -45,6 +45,7 @@
 #include <net/tcp.h>
 #include "cxgb4.h"
 #include "t4_regs.h"
+#include "t4_values.h"
 #include "t4_msg.h"
 #include "t4fw_api.h"
 
@@ -521,10 +522,12 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 {
 	u32 val;
 	if (q->pend_cred >= 8) {
-		val = PIDX(q->pend_cred / 8);
-		if (!is_t4(adap->params.chip))
-			val |= DBTYPE(1);
-		val |= DBPRIO(1);
+		if (is_t4(adap->params.chip))
+			val = PIDX_V(q->pend_cred / 8);
+		else
+			val = PIDX_T5_V(q->pend_cred / 8) |
+				DBTYPE_F;
+		val |= DBPRIO_F;
 		wmb();
 
 		/* If we don't have access to the new User Doorbell (T5+), use
@@ -532,10 +535,10 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 		 * mechanism.
 		 */
 		if (unlikely(q->bar2_addr == NULL)) {
-			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-				     val | QID(q->cntxt_id));
+			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL_A),
+				     val | QID_V(q->cntxt_id));
 		} else {
-			writel(val | QID(q->bar2_qid),
+			writel(val | QID_V(q->bar2_qid),
 			       q->bar2_addr + SGE_UDB_KDOORBELL);
 
 			/* This Write memory Barrier will force the write to
@@ -884,7 +887,7 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
 	 */
 	if (unlikely(q->bar2_addr == NULL)) {
-		u32 val = PIDX(n);
+		u32 val = PIDX_V(n);
 		unsigned long flags;
 
 		/* For T4 we need to participate in the Doorbell Recovery
@@ -892,14 +895,14 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 		 */
 		spin_lock_irqsave(&q->db_lock, flags);
 		if (!q->db_disabled)
-			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
-				     QID(q->cntxt_id) | val);
+			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL_A),
+				     QID_V(q->cntxt_id) | val);
 		else
 			q->db_pidx_inc += n;
 		q->db_pidx = q->pidx;
 		spin_unlock_irqrestore(&q->db_lock, flags);
 	} else {
-		u32 val = PIDX_T5(n);
+		u32 val = PIDX_T5_V(n);
 
 		/* T4 and later chips share the same PIDX field offset within
 		 * the doorbell, but T5 and later shrank the field in order to
@@ -907,7 +910,7 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 		 * large in the first place (14 bits) so we just use the T5
 		 * and later limits and warn if a Queue ID is too large.
 		 */
-		WARN_ON(val & DBPRIO(1));
+		WARN_ON(val & DBPRIO_F);
 
 		/* If we're only writing a single TX Descriptor and we can use
 		 * Inferred QID registers, we can use the Write Combining
@@ -923,7 +926,7 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 				      (q->bar2_addr + SGE_UDB_WCDOORBELL),
 				      wr);
 		} else {
-			writel(val | QID(q->bar2_qid),
+			writel(val | QID_V(q->bar2_qid),
 			       q->bar2_addr + SGE_UDB_KDOORBELL);
 		}
 
@@ -2001,16 +2004,16 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	} else
 		params = QINTR_TIMER_IDX(7);
 
-	val = CIDXINC(work_done) | SEINTARM(params);
+	val = CIDXINC_V(work_done) | SEINTARM_V(params);
 
 	/* If we don't have access to the new User GTS (T5+), use the old
 	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
 	 */
 	if (unlikely(q->bar2_addr == NULL)) {
-		t4_write_reg(q->adap, MYPF_REG(SGE_PF_GTS),
-			     val | INGRESSQID((u32)q->cntxt_id));
+		t4_write_reg(q->adap, MYPF_REG(SGE_PF_GTS_A),
+			     val | INGRESSQID_V((u32)q->cntxt_id));
 	} else {
-		writel(val | INGRESSQID(q->bar2_qid),
+		writel(val | INGRESSQID_V(q->bar2_qid),
 		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
@@ -2056,16 +2059,16 @@ static unsigned int process_intrq(struct adapter *adap)
 		rspq_next(q);
 	}
 
-	val =  CIDXINC(credits) | SEINTARM(q->intr_params);
+	val =  CIDXINC_V(credits) | SEINTARM_V(q->intr_params);
 
 	/* If we don't have access to the new User GTS (T5+), use the old
 	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
 	 */
 	if (unlikely(q->bar2_addr == NULL)) {
-		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS),
-			     val | INGRESSQID(q->cntxt_id));
+		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
+			     val | INGRESSQID_V(q->cntxt_id));
 	} else {
-		writel(val | INGRESSQID(q->bar2_qid),
+		writel(val | INGRESSQID_V(q->bar2_qid),
 		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
@@ -2770,8 +2773,8 @@ static int t4_sge_init_soft(struct adapter *adap)
 	 * process_responses() and that only packet data is going to the
 	 * Free Lists.
 	 */
-	if ((t4_read_reg(adap, SGE_CONTROL) & RXPKTCPLMODE_MASK) !=
-	    RXPKTCPLMODE(X_RXPKTCPLMODE_SPLIT)) {
+	if ((t4_read_reg(adap, SGE_CONTROL_A) & RXPKTCPLMODE_F) !=
+	    RXPKTCPLMODE_V(RXPKTCPLMODE_SPLIT_X)) {
 		dev_err(adap->pdev_dev, "bad SGE CPL MODE\n");
 		return -EINVAL;
 	}
@@ -2785,7 +2788,7 @@ static int t4_sge_init_soft(struct adapter *adap)
 	 * XXX meet our needs!
 	 */
 	#define READ_FL_BUF(x) \
-		t4_read_reg(adap, SGE_FL_BUFFER_SIZE0+(x)*sizeof(u32))
+		t4_read_reg(adap, SGE_FL_BUFFER_SIZE0_A+(x)*sizeof(u32))
 
 	fl_small_pg = READ_FL_BUF(RX_SMALL_PG_BUF);
 	fl_large_pg = READ_FL_BUF(RX_LARGE_PG_BUF);
@@ -2839,11 +2842,11 @@ static int t4_sge_init_soft(struct adapter *adap)
 	s->timer_val[5] = core_ticks_to_us(adap,
 		TIMERVALUE5_GET(timer_value_4_and_5));
 
-	ingress_rx_threshold = t4_read_reg(adap, SGE_INGRESS_RX_THRESHOLD);
-	s->counter_val[0] = THRESHOLD_0_GET(ingress_rx_threshold);
-	s->counter_val[1] = THRESHOLD_1_GET(ingress_rx_threshold);
-	s->counter_val[2] = THRESHOLD_2_GET(ingress_rx_threshold);
-	s->counter_val[3] = THRESHOLD_3_GET(ingress_rx_threshold);
+	ingress_rx_threshold = t4_read_reg(adap, SGE_INGRESS_RX_THRESHOLD_A);
+	s->counter_val[0] = THRESHOLD_0_G(ingress_rx_threshold);
+	s->counter_val[1] = THRESHOLD_1_G(ingress_rx_threshold);
+	s->counter_val[2] = THRESHOLD_2_G(ingress_rx_threshold);
+	s->counter_val[3] = THRESHOLD_3_G(ingress_rx_threshold);
 
 	return 0;
 }
@@ -2856,8 +2859,7 @@ static int t4_sge_init_hard(struct adapter *adap)
 	 * Set up our basic SGE mode to deliver CPL messages to our Ingress
 	 * Queue and Packet Date to the Free List.
 	 */
-	t4_set_reg_field(adap, SGE_CONTROL, RXPKTCPLMODE_MASK,
-			 RXPKTCPLMODE_MASK);
+	t4_set_reg_field(adap, SGE_CONTROL_A, RXPKTCPLMODE_F, RXPKTCPLMODE_F);
 
 	/*
 	 * Set up to drop DOORBELL writes when the DOORBELL FIFO overflows
@@ -2887,22 +2889,22 @@ static int t4_sge_init_hard(struct adapter *adap)
 	s->fl_pg_order = FL_PG_ORDER;
 	if (s->fl_pg_order)
 		t4_write_reg(adap,
-			     SGE_FL_BUFFER_SIZE0+RX_LARGE_PG_BUF*sizeof(u32),
+			     SGE_FL_BUFFER_SIZE0_A+RX_LARGE_PG_BUF*sizeof(u32),
 			     PAGE_SIZE << FL_PG_ORDER);
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0+RX_SMALL_MTU_BUF*sizeof(u32),
+	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0_A+RX_SMALL_MTU_BUF*sizeof(u32),
 		     FL_MTU_SMALL_BUFSIZE(adap));
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0+RX_LARGE_MTU_BUF*sizeof(u32),
+	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0_A+RX_LARGE_MTU_BUF*sizeof(u32),
 		     FL_MTU_LARGE_BUFSIZE(adap));
 
 	/*
 	 * Note that the SGE Ingress Packet Count Interrupt Threshold and
 	 * Timer Holdoff values must be supplied by our caller.
 	 */
-	t4_write_reg(adap, SGE_INGRESS_RX_THRESHOLD,
-		     THRESHOLD_0(s->counter_val[0]) |
-		     THRESHOLD_1(s->counter_val[1]) |
-		     THRESHOLD_2(s->counter_val[2]) |
-		     THRESHOLD_3(s->counter_val[3]));
+	t4_write_reg(adap, SGE_INGRESS_RX_THRESHOLD_A,
+		     THRESHOLD_0_V(s->counter_val[0]) |
+		     THRESHOLD_1_V(s->counter_val[1]) |
+		     THRESHOLD_2_V(s->counter_val[2]) |
+		     THRESHOLD_3_V(s->counter_val[3]));
 	t4_write_reg(adap, SGE_TIMER_VALUE_0_AND_1,
 		     TIMERVALUE0(us_to_core_ticks(adap, s->timer_val[0])) |
 		     TIMERVALUE1(us_to_core_ticks(adap, s->timer_val[1])));
@@ -2927,9 +2929,9 @@ int t4_sge_init(struct adapter *adap)
 	 * Ingress Padding Boundary and Egress Status Page Size are set up by
 	 * t4_fixup_host_params().
 	 */
-	sge_control = t4_read_reg(adap, SGE_CONTROL);
-	s->pktshift = PKTSHIFT_GET(sge_control);
-	s->stat_len = (sge_control & EGRSTATUSPAGESIZE_MASK) ? 128 : 64;
+	sge_control = t4_read_reg(adap, SGE_CONTROL_A);
+	s->pktshift = PKTSHIFT_G(sge_control);
+	s->stat_len = (sge_control & EGRSTATUSPAGESIZE_F) ? 128 : 64;
 
 	/* T4 uses a single control field to specify both the PCIe Padding and
 	 * Packing Boundary.  T5 introduced the ability to specify these
@@ -2937,8 +2939,8 @@ int t4_sge_init(struct adapter *adap)
 	 * within Packed Buffer Mode is the maximum of these two
 	 * specifications.
 	 */
-	ingpadboundary = 1 << (INGPADBOUNDARY_GET(sge_control) +
-			       X_INGPADBOUNDARY_SHIFT);
+	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_control) +
+			       INGPADBOUNDARY_SHIFT_X);
 	if (is_t4(adap->params.chip)) {
 		s->fl_align = ingpadboundary;
 	} else {
@@ -2975,11 +2977,11 @@ int t4_sge_init(struct adapter *adap)
 	 * buffers and a new field which only applies to Packed Mode Free List
 	 * buffers.
 	 */
-	sge_conm_ctrl = t4_read_reg(adap, SGE_CONM_CTRL);
+	sge_conm_ctrl = t4_read_reg(adap, SGE_CONM_CTRL_A);
 	if (is_t4(adap->params.chip))
-		egress_threshold = EGRTHRESHOLD_GET(sge_conm_ctrl);
+		egress_threshold = EGRTHRESHOLD_G(sge_conm_ctrl);
 	else
-		egress_threshold = EGRTHRESHOLDPACKING_GET(sge_conm_ctrl);
+		egress_threshold = EGRTHRESHOLDPACKING_G(sge_conm_ctrl);
 	s->fl_starve_thres = 2*egress_threshold + 1;
 
 	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adap);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c132d90..ac00cab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -35,6 +35,7 @@
 #include <linux/delay.h>
 #include "cxgb4.h"
 #include "t4_regs.h"
+#include "t4_values.h"
 #include "t4fw_api.h"
 
 /**
@@ -1499,43 +1500,43 @@ static void sge_intr_handler(struct adapter *adapter)
 	u64 v;
 
 	static const struct intr_info sge_intr_info[] = {
-		{ ERR_CPL_EXCEED_IQE_SIZE,
+		{ ERR_CPL_EXCEED_IQE_SIZE_F,
 		  "SGE received CPL exceeding IQE size", -1, 1 },
-		{ ERR_INVALID_CIDX_INC,
+		{ ERR_INVALID_CIDX_INC_F,
 		  "SGE GTS CIDX increment too large", -1, 0 },
-		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
-		{ DBFIFO_LP_INT, NULL, -1, 0, t4_db_full },
-		{ DBFIFO_HP_INT, NULL, -1, 0, t4_db_full },
-		{ ERR_DROPPED_DB, NULL, -1, 0, t4_db_dropped },
-		{ ERR_DATA_CPL_ON_HIGH_QID1 | ERR_DATA_CPL_ON_HIGH_QID0,
+		{ ERR_CPL_OPCODE_0_F, "SGE received 0-length CPL", -1, 0 },
+		{ DBFIFO_LP_INT_F, NULL, -1, 0, t4_db_full },
+		{ DBFIFO_HP_INT_F, NULL, -1, 0, t4_db_full },
+		{ ERR_DROPPED_DB_F, NULL, -1, 0, t4_db_dropped },
+		{ ERR_DATA_CPL_ON_HIGH_QID1_F | ERR_DATA_CPL_ON_HIGH_QID0_F,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
-		{ ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX3_F, "SGE DBP 3 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX2, "SGE DBP 2 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX2_F, "SGE DBP 2 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX1, "SGE DBP 1 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX1_F, "SGE DBP 1 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX0, "SGE DBP 0 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX0_F, "SGE DBP 0 pidx increment too large", -1,
 		  0 },
-		{ ERR_ING_CTXT_PRIO,
+		{ ERR_ING_CTXT_PRIO_F,
 		  "SGE too many priority ingress contexts", -1, 0 },
-		{ ERR_EGR_CTXT_PRIO,
+		{ ERR_EGR_CTXT_PRIO_F,
 		  "SGE too many priority egress contexts", -1, 0 },
-		{ INGRESS_SIZE_ERR, "SGE illegal ingress QID", -1, 0 },
-		{ EGRESS_SIZE_ERR, "SGE illegal egress QID", -1, 0 },
+		{ INGRESS_SIZE_ERR_F, "SGE illegal ingress QID", -1, 0 },
+		{ EGRESS_SIZE_ERR_F, "SGE illegal egress QID", -1, 0 },
 		{ 0 }
 	};
 
-	v = (u64)t4_read_reg(adapter, SGE_INT_CAUSE1) |
-		((u64)t4_read_reg(adapter, SGE_INT_CAUSE2) << 32);
+	v = (u64)t4_read_reg(adapter, SGE_INT_CAUSE1_A) |
+		((u64)t4_read_reg(adapter, SGE_INT_CAUSE2_A) << 32);
 	if (v) {
 		dev_alert(adapter->pdev_dev, "SGE parity error (%#llx)\n",
 				(unsigned long long)v);
-		t4_write_reg(adapter, SGE_INT_CAUSE1, v);
-		t4_write_reg(adapter, SGE_INT_CAUSE2, v >> 32);
+		t4_write_reg(adapter, SGE_INT_CAUSE1_A, v);
+		t4_write_reg(adapter, SGE_INT_CAUSE2_A, v >> 32);
 	}
 
-	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3, sge_intr_info) ||
+	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3_A, sge_intr_info) ||
 	    v != 0)
 		t4_fatal_err(adapter);
 }
@@ -2025,15 +2026,15 @@ void t4_intr_enable(struct adapter *adapter)
 {
 	u32 pf = SOURCEPF_GET(t4_read_reg(adapter, PL_WHOAMI));
 
-	t4_write_reg(adapter, SGE_INT_ENABLE3, ERR_CPL_EXCEED_IQE_SIZE |
-		     ERR_INVALID_CIDX_INC | ERR_CPL_OPCODE_0 |
-		     ERR_DROPPED_DB | ERR_DATA_CPL_ON_HIGH_QID1 |
-		     ERR_DATA_CPL_ON_HIGH_QID0 | ERR_BAD_DB_PIDX3 |
-		     ERR_BAD_DB_PIDX2 | ERR_BAD_DB_PIDX1 |
-		     ERR_BAD_DB_PIDX0 | ERR_ING_CTXT_PRIO |
-		     ERR_EGR_CTXT_PRIO | INGRESS_SIZE_ERR |
-		     DBFIFO_HP_INT | DBFIFO_LP_INT |
-		     EGRESS_SIZE_ERR);
+	t4_write_reg(adapter, SGE_INT_ENABLE3_A, ERR_CPL_EXCEED_IQE_SIZE_F |
+		     ERR_INVALID_CIDX_INC_F | ERR_CPL_OPCODE_0_F |
+		     ERR_DROPPED_DB_F | ERR_DATA_CPL_ON_HIGH_QID1_F |
+		     ERR_DATA_CPL_ON_HIGH_QID0_F | ERR_BAD_DB_PIDX3_F |
+		     ERR_BAD_DB_PIDX2_F | ERR_BAD_DB_PIDX1_F |
+		     ERR_BAD_DB_PIDX0_F | ERR_ING_CTXT_PRIO_F |
+		     ERR_EGR_CTXT_PRIO_F | INGRESS_SIZE_ERR_F |
+		     DBFIFO_HP_INT_F | DBFIFO_LP_INT_F |
+		     EGRESS_SIZE_ERR_F);
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE), PF_INTR_MASK);
 	t4_set_reg_field(adapter, PL_INT_MAP0, 0, 1 << pf);
 }
@@ -3148,22 +3149,23 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 	unsigned int fl_align = cache_line_size < 32 ? 32 : cache_line_size;
 	unsigned int fl_align_log = fls(fl_align) - 1;
 
-	t4_write_reg(adap, SGE_HOST_PAGE_SIZE,
-		     HOSTPAGESIZEPF0(sge_hps) |
-		     HOSTPAGESIZEPF1(sge_hps) |
-		     HOSTPAGESIZEPF2(sge_hps) |
-		     HOSTPAGESIZEPF3(sge_hps) |
-		     HOSTPAGESIZEPF4(sge_hps) |
-		     HOSTPAGESIZEPF5(sge_hps) |
-		     HOSTPAGESIZEPF6(sge_hps) |
-		     HOSTPAGESIZEPF7(sge_hps));
+	t4_write_reg(adap, SGE_HOST_PAGE_SIZE_A,
+		     HOSTPAGESIZEPF0_V(sge_hps) |
+		     HOSTPAGESIZEPF1_V(sge_hps) |
+		     HOSTPAGESIZEPF2_V(sge_hps) |
+		     HOSTPAGESIZEPF3_V(sge_hps) |
+		     HOSTPAGESIZEPF4_V(sge_hps) |
+		     HOSTPAGESIZEPF5_V(sge_hps) |
+		     HOSTPAGESIZEPF6_V(sge_hps) |
+		     HOSTPAGESIZEPF7_V(sge_hps));
 
 	if (is_t4(adap->params.chip)) {
-		t4_set_reg_field(adap, SGE_CONTROL,
-				 INGPADBOUNDARY_MASK |
-				 EGRSTATUSPAGESIZE_MASK,
-				 INGPADBOUNDARY(fl_align_log - 5) |
-				 EGRSTATUSPAGESIZE(stat_len != 64));
+		t4_set_reg_field(adap, SGE_CONTROL_A,
+				 INGPADBOUNDARY_V(INGPADBOUNDARY_M) |
+				 EGRSTATUSPAGESIZE_F,
+				 INGPADBOUNDARY_V(fl_align_log -
+						  INGPADBOUNDARY_SHIFT_X) |
+				 EGRSTATUSPAGESIZE_V(stat_len != 64));
 	} else {
 		/* T5 introduced the separation of the Free List Padding and
 		 * Packing Boundaries.  Thus, we can select a smaller Padding
@@ -3193,15 +3195,15 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 			fl_align = 64;
 			fl_align_log = 6;
 		}
-		t4_set_reg_field(adap, SGE_CONTROL,
-				 INGPADBOUNDARY_MASK |
-				 EGRSTATUSPAGESIZE_MASK,
-				 INGPADBOUNDARY(INGPCIEBOUNDARY_32B_X) |
-				 EGRSTATUSPAGESIZE(stat_len != 64));
+		t4_set_reg_field(adap, SGE_CONTROL_A,
+				 INGPADBOUNDARY_V(INGPADBOUNDARY_M) |
+				 EGRSTATUSPAGESIZE_F,
+				 INGPADBOUNDARY_V(INGPCIEBOUNDARY_32B_X) |
+				 EGRSTATUSPAGESIZE_V(stat_len != 64));
 		t4_set_reg_field(adap, SGE_CONTROL2_A,
 				 INGPACKBOUNDARY_V(INGPACKBOUNDARY_M),
 				 INGPACKBOUNDARY_V(fl_align_log -
-						 INGPACKBOUNDARY_SHIFT_X));
+						   INGPACKBOUNDARY_SHIFT_X));
 	}
 	/*
 	 * Adjust various SGE Free List Host Buffer Sizes.
@@ -3224,12 +3226,12 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 	 * Default Firmware Configuration File but we need to adjust it for
 	 * this host's cache line size.
 	 */
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0, page_size);
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE2,
-		     (t4_read_reg(adap, SGE_FL_BUFFER_SIZE2) + fl_align-1)
+	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0_A, page_size);
+	t4_write_reg(adap, SGE_FL_BUFFER_SIZE2_A,
+		     (t4_read_reg(adap, SGE_FL_BUFFER_SIZE2_A) + fl_align-1)
 		     & ~(fl_align-1));
-	t4_write_reg(adap, SGE_FL_BUFFER_SIZE3,
-		     (t4_read_reg(adap, SGE_FL_BUFFER_SIZE3) + fl_align-1)
+	t4_write_reg(adap, SGE_FL_BUFFER_SIZE3_A,
+		     (t4_read_reg(adap, SGE_FL_BUFFER_SIZE3_A) + fl_align-1)
 		     & ~(fl_align-1));
 
 	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(page_shift - 12));
@@ -4133,7 +4135,7 @@ int t4_init_sge_params(struct adapter *adapter)
 
 	/* Extract the SGE Page Size for our PF.
 	 */
-	hps = t4_read_reg(adapter, SGE_HOST_PAGE_SIZE);
+	hps = t4_read_reg(adapter, SGE_HOST_PAGE_SIZE_A);
 	s_hps = (HOSTPAGESIZEPF0_S +
 		 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * adapter->fn);
 	sge_params->hps = ((hps >> s_hps) & HOSTPAGESIZEPF0_M);
@@ -4142,10 +4144,10 @@ int t4_init_sge_params(struct adapter *adapter)
 	 */
 	s_qpp = (QUEUESPERPAGEPF0_S +
 		(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * adapter->fn);
-	qpp = t4_read_reg(adapter, SGE_EGRESS_QUEUES_PER_PAGE_PF);
-	sge_params->eq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
+	qpp = t4_read_reg(adapter, SGE_EGRESS_QUEUES_PER_PAGE_PF_A);
+	sge_params->eq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_M);
 	qpp = t4_read_reg(adapter, SGE_INGRESS_QUEUES_PER_PAGE_PF);
-	sge_params->iq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
+	sge_params->iq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_M);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index d7bd34e..29c0911 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -63,233 +63,311 @@
 #define MC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
 #define EDC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
 
-#define SGE_PF_KDOORBELL 0x0
-#define  QID_MASK    0xffff8000U
-#define  QID_SHIFT   15
-#define  QID(x)      ((x) << QID_SHIFT)
-#define  DBPRIO(x)   ((x) << 14)
-#define  DBTYPE(x)   ((x) << 13)
-#define  PIDX_MASK   0x00003fffU
-#define  PIDX_SHIFT  0
-#define  PIDX(x)     ((x) << PIDX_SHIFT)
-#define  PIDX_SHIFT_T5   0
-#define  PIDX_T5(x)  ((x) << PIDX_SHIFT_T5)
-
-
-#define SGE_TIMERREGS	6
-#define SGE_PF_GTS 0x4
-#define  INGRESSQID_MASK   0xffff0000U
-#define  INGRESSQID_SHIFT  16
-#define  INGRESSQID(x)     ((x) << INGRESSQID_SHIFT)
-#define  TIMERREG_MASK     0x0000e000U
-#define  TIMERREG_SHIFT    13
-#define  TIMERREG(x)       ((x) << TIMERREG_SHIFT)
-#define  SEINTARM_MASK     0x00001000U
-#define  SEINTARM_SHIFT    12
-#define  SEINTARM(x)       ((x) << SEINTARM_SHIFT)
-#define  CIDXINC_MASK      0x00000fffU
-#define  CIDXINC_SHIFT     0
-#define  CIDXINC(x)        ((x) << CIDXINC_SHIFT)
-
-#define X_RXPKTCPLMODE_SPLIT     1
-#define X_INGPADBOUNDARY_SHIFT 5
-
-#define SGE_CONTROL 0x1008
-#define SGE_CONTROL2_A		0x1124
-#define  DCASYSTYPE             0x00080000U
-#define  RXPKTCPLMODE_MASK      0x00040000U
-#define  RXPKTCPLMODE_SHIFT     18
-#define  RXPKTCPLMODE(x)        ((x) << RXPKTCPLMODE_SHIFT)
-#define  EGRSTATUSPAGESIZE_MASK  0x00020000U
-#define  EGRSTATUSPAGESIZE_SHIFT 17
-#define  EGRSTATUSPAGESIZE(x)    ((x) << EGRSTATUSPAGESIZE_SHIFT)
-#define  PKTSHIFT_MASK          0x00001c00U
-#define  PKTSHIFT_SHIFT         10
-#define  PKTSHIFT(x)            ((x) << PKTSHIFT_SHIFT)
-#define  PKTSHIFT_GET(x)	(((x) & PKTSHIFT_MASK) >> PKTSHIFT_SHIFT)
-#define  INGPCIEBOUNDARY_32B_X	0
-#define  INGPCIEBOUNDARY_MASK   0x00000380U
-#define  INGPCIEBOUNDARY_SHIFT  7
-#define  INGPCIEBOUNDARY(x)     ((x) << INGPCIEBOUNDARY_SHIFT)
-#define  INGPADBOUNDARY_MASK    0x00000070U
-#define  INGPADBOUNDARY_SHIFT   4
-#define  INGPADBOUNDARY(x)      ((x) << INGPADBOUNDARY_SHIFT)
-#define  INGPADBOUNDARY_GET(x)	(((x) & INGPADBOUNDARY_MASK) \
-				 >> INGPADBOUNDARY_SHIFT)
-#define  INGPACKBOUNDARY_16B_X	0
-#define  INGPACKBOUNDARY_SHIFT_X 5
+#define SGE_PF_KDOORBELL_A 0x0
 
-#define  INGPACKBOUNDARY_S	16
-#define  INGPACKBOUNDARY_M	0x7U
-#define  INGPACKBOUNDARY_V(x)	((x) << INGPACKBOUNDARY_S)
-#define  INGPACKBOUNDARY_G(x)	(((x) >> INGPACKBOUNDARY_S) \
-				 & INGPACKBOUNDARY_M)
-#define  EGRPCIEBOUNDARY_MASK   0x0000000eU
-#define  EGRPCIEBOUNDARY_SHIFT  1
-#define  EGRPCIEBOUNDARY(x)     ((x) << EGRPCIEBOUNDARY_SHIFT)
-#define  GLOBALENABLE           0x00000001U
+#define QID_S    15
+#define QID_V(x) ((x) << QID_S)
+
+#define DBPRIO_S    14
+#define DBPRIO_V(x) ((x) << DBPRIO_S)
+#define DBPRIO_F    DBPRIO_V(1U)
+
+#define PIDX_S    0
+#define PIDX_V(x) ((x) << PIDX_S)
+
+#define SGE_VF_KDOORBELL_A 0x0
+
+#define DBTYPE_S    13
+#define DBTYPE_V(x) ((x) << DBTYPE_S)
+#define DBTYPE_F    DBTYPE_V(1U)
+
+#define PIDX_T5_S    0
+#define PIDX_T5_M    0x1fffU
+#define PIDX_T5_V(x) ((x) << PIDX_T5_S)
+#define PIDX_T5_G(x) (((x) >> PIDX_T5_S) & PIDX_T5_M)
+
+#define SGE_PF_GTS_A 0x4
 
-#define SGE_HOST_PAGE_SIZE 0x100c
+#define INGRESSQID_S    16
+#define INGRESSQID_V(x) ((x) << INGRESSQID_S)
 
-#define  HOSTPAGESIZEPF7_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF7_SHIFT  28
-#define  HOSTPAGESIZEPF7(x)     ((x) << HOSTPAGESIZEPF7_SHIFT)
+#define TIMERREG_S    13
+#define TIMERREG_V(x) ((x) << TIMERREG_S)
 
-#define  HOSTPAGESIZEPF6_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF6_SHIFT  24
-#define  HOSTPAGESIZEPF6(x)     ((x) << HOSTPAGESIZEPF6_SHIFT)
+#define SEINTARM_S    12
+#define SEINTARM_V(x) ((x) << SEINTARM_S)
 
-#define  HOSTPAGESIZEPF5_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF5_SHIFT  20
-#define  HOSTPAGESIZEPF5(x)     ((x) << HOSTPAGESIZEPF5_SHIFT)
+#define CIDXINC_S    0
+#define CIDXINC_M    0xfffU
+#define CIDXINC_V(x) ((x) << CIDXINC_S)
 
-#define  HOSTPAGESIZEPF4_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF4_SHIFT  16
-#define  HOSTPAGESIZEPF4(x)     ((x) << HOSTPAGESIZEPF4_SHIFT)
+#define SGE_CONTROL_A	0x1008
+#define SGE_CONTROL2_A	0x1124
 
-#define  HOSTPAGESIZEPF3_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF3_SHIFT  12
-#define  HOSTPAGESIZEPF3(x)     ((x) << HOSTPAGESIZEPF3_SHIFT)
+#define RXPKTCPLMODE_S    18
+#define RXPKTCPLMODE_V(x) ((x) << RXPKTCPLMODE_S)
+#define RXPKTCPLMODE_F    RXPKTCPLMODE_V(1U)
 
-#define  HOSTPAGESIZEPF2_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF2_SHIFT  8
-#define  HOSTPAGESIZEPF2(x)     ((x) << HOSTPAGESIZEPF2_SHIFT)
+#define EGRSTATUSPAGESIZE_S    17
+#define EGRSTATUSPAGESIZE_V(x) ((x) << EGRSTATUSPAGESIZE_S)
+#define EGRSTATUSPAGESIZE_F    EGRSTATUSPAGESIZE_V(1U)
 
-#define  HOSTPAGESIZEPF1_M	0x0000000fU
-#define  HOSTPAGESIZEPF1_S	4
-#define  HOSTPAGESIZEPF1(x)     ((x) << HOSTPAGESIZEPF1_S)
+#define PKTSHIFT_S    10
+#define PKTSHIFT_M    0x7U
+#define PKTSHIFT_V(x) ((x) << PKTSHIFT_S)
+#define PKTSHIFT_G(x) (((x) >> PKTSHIFT_S) & PKTSHIFT_M)
 
-#define  HOSTPAGESIZEPF0_M	0x0000000fU
-#define  HOSTPAGESIZEPF0_S	0
-#define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_S)
+#define INGPCIEBOUNDARY_S    7
+#define INGPCIEBOUNDARY_V(x) ((x) << INGPCIEBOUNDARY_S)
 
-#define SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
+#define INGPADBOUNDARY_S    4
+#define INGPADBOUNDARY_M    0x7U
+#define INGPADBOUNDARY_V(x) ((x) << INGPADBOUNDARY_S)
+#define INGPADBOUNDARY_G(x) (((x) >> INGPADBOUNDARY_S) & INGPADBOUNDARY_M)
+
+#define EGRPCIEBOUNDARY_S    1
+#define EGRPCIEBOUNDARY_V(x) ((x) << EGRPCIEBOUNDARY_S)
+
+#define  INGPACKBOUNDARY_S	16
+#define  INGPACKBOUNDARY_M	0x7U
+#define  INGPACKBOUNDARY_V(x)	((x) << INGPACKBOUNDARY_S)
+#define  INGPACKBOUNDARY_G(x)	(((x) >> INGPACKBOUNDARY_S) \
+				 & INGPACKBOUNDARY_M)
+
+#define GLOBALENABLE_S    0
+#define GLOBALENABLE_V(x) ((x) << GLOBALENABLE_S)
+#define GLOBALENABLE_F    GLOBALENABLE_V(1U)
+
+#define SGE_HOST_PAGE_SIZE_A 0x100c
+
+#define HOSTPAGESIZEPF7_S    28
+#define HOSTPAGESIZEPF7_M    0xfU
+#define HOSTPAGESIZEPF7_V(x) ((x) << HOSTPAGESIZEPF7_S)
+#define HOSTPAGESIZEPF7_G(x) (((x) >> HOSTPAGESIZEPF7_S) & HOSTPAGESIZEPF7_M)
+
+#define HOSTPAGESIZEPF6_S    24
+#define HOSTPAGESIZEPF6_M    0xfU
+#define HOSTPAGESIZEPF6_V(x) ((x) << HOSTPAGESIZEPF6_S)
+#define HOSTPAGESIZEPF6_G(x) (((x) >> HOSTPAGESIZEPF6_S) & HOSTPAGESIZEPF6_M)
+
+#define HOSTPAGESIZEPF5_S    20
+#define HOSTPAGESIZEPF5_M    0xfU
+#define HOSTPAGESIZEPF5_V(x) ((x) << HOSTPAGESIZEPF5_S)
+#define HOSTPAGESIZEPF5_G(x) (((x) >> HOSTPAGESIZEPF5_S) & HOSTPAGESIZEPF5_M)
+
+#define HOSTPAGESIZEPF4_S    16
+#define HOSTPAGESIZEPF4_M    0xfU
+#define HOSTPAGESIZEPF4_V(x) ((x) << HOSTPAGESIZEPF4_S)
+#define HOSTPAGESIZEPF4_G(x) (((x) >> HOSTPAGESIZEPF4_S) & HOSTPAGESIZEPF4_M)
+
+#define HOSTPAGESIZEPF3_S    12
+#define HOSTPAGESIZEPF3_M    0xfU
+#define HOSTPAGESIZEPF3_V(x) ((x) << HOSTPAGESIZEPF3_S)
+#define HOSTPAGESIZEPF3_G(x) (((x) >> HOSTPAGESIZEPF3_S) & HOSTPAGESIZEPF3_M)
+
+#define HOSTPAGESIZEPF2_S    8
+#define HOSTPAGESIZEPF2_M    0xfU
+#define HOSTPAGESIZEPF2_V(x) ((x) << HOSTPAGESIZEPF2_S)
+#define HOSTPAGESIZEPF2_G(x) (((x) >> HOSTPAGESIZEPF2_S) & HOSTPAGESIZEPF2_M)
+
+#define HOSTPAGESIZEPF1_S    4
+#define HOSTPAGESIZEPF1_M    0xfU
+#define HOSTPAGESIZEPF1_V(x) ((x) << HOSTPAGESIZEPF1_S)
+#define HOSTPAGESIZEPF1_G(x) (((x) >> HOSTPAGESIZEPF1_S) & HOSTPAGESIZEPF1_M)
+
+#define HOSTPAGESIZEPF0_S    0
+#define HOSTPAGESIZEPF0_M    0xfU
+#define HOSTPAGESIZEPF0_V(x) ((x) << HOSTPAGESIZEPF0_S)
+#define HOSTPAGESIZEPF0_G(x) (((x) >> HOSTPAGESIZEPF0_S) & HOSTPAGESIZEPF0_M)
+
+#define SGE_EGRESS_QUEUES_PER_PAGE_PF_A 0x1010
 #define SGE_EGRESS_QUEUES_PER_PAGE_VF_A 0x1014
 
 #define QUEUESPERPAGEPF1_S    4
 
 #define QUEUESPERPAGEPF0_S    0
-#define QUEUESPERPAGEPF0_MASK   0x0000000fU
-#define QUEUESPERPAGEPF0_GET(x) ((x) & QUEUESPERPAGEPF0_MASK)
-
-#define QUEUESPERPAGEPF0    0
-#define QUEUESPERPAGEPF1    4
+#define QUEUESPERPAGEPF0_M    0xfU
+#define QUEUESPERPAGEPF0_V(x) ((x) << QUEUESPERPAGEPF0_S)
+#define QUEUESPERPAGEPF0_G(x) (((x) >> QUEUESPERPAGEPF0_S) & QUEUESPERPAGEPF0_M)
 
-/* T5 and later support a new BAR2-based doorbell mechanism for Egress Queues.
- * The User Doorbells are each 128 bytes in length with a Simple Doorbell at
- * offsets 8x and a Write Combining single 64-byte Egress Queue Unit
- * (X_IDXSIZE_UNIT) Gather Buffer interface at offset 64.  For Ingress Queues,
- * we have a Going To Sleep register at offsets 8x+4.
- *
- * As noted above, we have many instances of the Simple Doorbell and Going To
- * Sleep registers at offsets 8x and 8x+4, respectively.  We want to use a
- * non-64-byte aligned offset for the Simple Doorbell in order to attempt to
- * avoid buffering of the writes to the Simple Doorbell and we want to use a
- * non-contiguous offset for the Going To Sleep writes in order to avoid
- * possible combining between them.
- */
-#define SGE_UDB_SIZE            128
-#define SGE_UDB_KDOORBELL       8
-#define SGE_UDB_GTS             20
-#define SGE_UDB_WCDOORBELL      64
-
-#define SGE_INT_CAUSE1 0x1024
-#define SGE_INT_CAUSE2 0x1030
-#define SGE_INT_CAUSE3 0x103c
-#define  ERR_FLM_DBP               0x80000000U
-#define  ERR_FLM_IDMA1             0x40000000U
-#define  ERR_FLM_IDMA0             0x20000000U
-#define  ERR_FLM_HINT              0x10000000U
-#define  ERR_PCIE_ERROR3           0x08000000U
-#define  ERR_PCIE_ERROR2           0x04000000U
-#define  ERR_PCIE_ERROR1           0x02000000U
-#define  ERR_PCIE_ERROR0           0x01000000U
-#define  ERR_TIMER_ABOVE_MAX_QID   0x00800000U
-#define  ERR_CPL_EXCEED_IQE_SIZE   0x00400000U
-#define  ERR_INVALID_CIDX_INC      0x00200000U
-#define  ERR_ITP_TIME_PAUSED       0x00100000U
-#define  ERR_CPL_OPCODE_0          0x00080000U
-#define  ERR_DROPPED_DB            0x00040000U
-#define  ERR_DATA_CPL_ON_HIGH_QID1 0x00020000U
-#define  ERR_DATA_CPL_ON_HIGH_QID0 0x00010000U
-#define  ERR_BAD_DB_PIDX3          0x00008000U
-#define  ERR_BAD_DB_PIDX2          0x00004000U
-#define  ERR_BAD_DB_PIDX1          0x00002000U
-#define  ERR_BAD_DB_PIDX0          0x00001000U
-#define  ERR_ING_PCIE_CHAN         0x00000800U
-#define  ERR_ING_CTXT_PRIO         0x00000400U
-#define  ERR_EGR_CTXT_PRIO         0x00000200U
-#define  DBFIFO_HP_INT             0x00000100U
-#define  DBFIFO_LP_INT             0x00000080U
-#define  REG_ADDRESS_ERR           0x00000040U
-#define  INGRESS_SIZE_ERR          0x00000020U
-#define  EGRESS_SIZE_ERR           0x00000010U
-#define  ERR_INV_CTXT3             0x00000008U
-#define  ERR_INV_CTXT2             0x00000004U
-#define  ERR_INV_CTXT1             0x00000002U
-#define  ERR_INV_CTXT0             0x00000001U
-
-#define SGE_INT_ENABLE3 0x1040
-#define SGE_FL_BUFFER_SIZE0 0x1044
-#define SGE_FL_BUFFER_SIZE1 0x1048
-#define SGE_FL_BUFFER_SIZE2 0x104c
-#define SGE_FL_BUFFER_SIZE3 0x1050
-#define SGE_FL_BUFFER_SIZE4 0x1054
-#define SGE_FL_BUFFER_SIZE5 0x1058
-#define SGE_FL_BUFFER_SIZE6 0x105c
-#define SGE_FL_BUFFER_SIZE7 0x1060
-#define SGE_FL_BUFFER_SIZE8 0x1064
-
-#define SGE_INGRESS_RX_THRESHOLD 0x10a0
-#define  THRESHOLD_0_MASK   0x3f000000U
-#define  THRESHOLD_0_SHIFT  24
-#define  THRESHOLD_0(x)     ((x) << THRESHOLD_0_SHIFT)
-#define  THRESHOLD_0_GET(x) (((x) & THRESHOLD_0_MASK) >> THRESHOLD_0_SHIFT)
-#define  THRESHOLD_1_MASK   0x003f0000U
-#define  THRESHOLD_1_SHIFT  16
-#define  THRESHOLD_1(x)     ((x) << THRESHOLD_1_SHIFT)
-#define  THRESHOLD_1_GET(x) (((x) & THRESHOLD_1_MASK) >> THRESHOLD_1_SHIFT)
-#define  THRESHOLD_2_MASK   0x00003f00U
-#define  THRESHOLD_2_SHIFT  8
-#define  THRESHOLD_2(x)     ((x) << THRESHOLD_2_SHIFT)
-#define  THRESHOLD_2_GET(x) (((x) & THRESHOLD_2_MASK) >> THRESHOLD_2_SHIFT)
-#define  THRESHOLD_3_MASK   0x0000003fU
-#define  THRESHOLD_3_SHIFT  0
-#define  THRESHOLD_3(x)     ((x) << THRESHOLD_3_SHIFT)
-#define  THRESHOLD_3_GET(x) (((x) & THRESHOLD_3_MASK) >> THRESHOLD_3_SHIFT)
-
-#define SGE_CONM_CTRL 0x1094
-#define  EGRTHRESHOLD_MASK   0x00003f00U
-#define  EGRTHRESHOLDshift   8
-#define  EGRTHRESHOLD(x)     ((x) << EGRTHRESHOLDshift)
-#define  EGRTHRESHOLD_GET(x) (((x) & EGRTHRESHOLD_MASK) >> EGRTHRESHOLDshift)
-
-#define EGRTHRESHOLDPACKING_MASK	0x3fU
-#define EGRTHRESHOLDPACKING_SHIFT	14
-#define EGRTHRESHOLDPACKING(x)		((x) << EGRTHRESHOLDPACKING_SHIFT)
-#define EGRTHRESHOLDPACKING_GET(x)	(((x) >> EGRTHRESHOLDPACKING_SHIFT) & \
-					  EGRTHRESHOLDPACKING_MASK)
-
-#define SGE_DBFIFO_STATUS 0x10a4
-#define  HP_INT_THRESH_SHIFT 28
-#define  HP_INT_THRESH_MASK  0xfU
-#define  HP_INT_THRESH(x)    ((x) << HP_INT_THRESH_SHIFT)
-#define  LP_INT_THRESH_SHIFT 12
-#define  LP_INT_THRESH_MASK  0xfU
-#define  LP_INT_THRESH(x)    ((x) << LP_INT_THRESH_SHIFT)
-
-#define SGE_DOORBELL_CONTROL 0x10a8
-#define  ENABLE_DROP        (1 << 13)
-
-#define S_NOCOALESCE    26
-#define V_NOCOALESCE(x) ((x) << S_NOCOALESCE)
-#define F_NOCOALESCE    V_NOCOALESCE(1U)
-
-#define SGE_TIMESTAMP_LO 0x1098
-#define SGE_TIMESTAMP_HI 0x109c
-#define S_TSVAL    0
-#define M_TSVAL    0xfffffffU
-#define GET_TSVAL(x) (((x) >> S_TSVAL) & M_TSVAL)
+#define SGE_INT_CAUSE1_A	0x1024
+#define SGE_INT_CAUSE2_A	0x1030
+#define SGE_INT_CAUSE3_A	0x103c
+
+#define ERR_FLM_DBP_S    31
+#define ERR_FLM_DBP_V(x) ((x) << ERR_FLM_DBP_S)
+#define ERR_FLM_DBP_F    ERR_FLM_DBP_V(1U)
+
+#define ERR_FLM_IDMA1_S    30
+#define ERR_FLM_IDMA1_V(x) ((x) << ERR_FLM_IDMA1_S)
+#define ERR_FLM_IDMA1_F    ERR_FLM_IDMA1_V(1U)
+
+#define ERR_FLM_IDMA0_S    29
+#define ERR_FLM_IDMA0_V(x) ((x) << ERR_FLM_IDMA0_S)
+#define ERR_FLM_IDMA0_F    ERR_FLM_IDMA0_V(1U)
+
+#define ERR_FLM_HINT_S    28
+#define ERR_FLM_HINT_V(x) ((x) << ERR_FLM_HINT_S)
+#define ERR_FLM_HINT_F    ERR_FLM_HINT_V(1U)
+
+#define ERR_PCIE_ERROR3_S    27
+#define ERR_PCIE_ERROR3_V(x) ((x) << ERR_PCIE_ERROR3_S)
+#define ERR_PCIE_ERROR3_F    ERR_PCIE_ERROR3_V(1U)
+
+#define ERR_PCIE_ERROR2_S    26
+#define ERR_PCIE_ERROR2_V(x) ((x) << ERR_PCIE_ERROR2_S)
+#define ERR_PCIE_ERROR2_F    ERR_PCIE_ERROR2_V(1U)
+
+#define ERR_PCIE_ERROR1_S    25
+#define ERR_PCIE_ERROR1_V(x) ((x) << ERR_PCIE_ERROR1_S)
+#define ERR_PCIE_ERROR1_F    ERR_PCIE_ERROR1_V(1U)
+
+#define ERR_PCIE_ERROR0_S    24
+#define ERR_PCIE_ERROR0_V(x) ((x) << ERR_PCIE_ERROR0_S)
+#define ERR_PCIE_ERROR0_F    ERR_PCIE_ERROR0_V(1U)
+
+#define ERR_CPL_EXCEED_IQE_SIZE_S    22
+#define ERR_CPL_EXCEED_IQE_SIZE_V(x) ((x) << ERR_CPL_EXCEED_IQE_SIZE_S)
+#define ERR_CPL_EXCEED_IQE_SIZE_F    ERR_CPL_EXCEED_IQE_SIZE_V(1U)
+
+#define ERR_INVALID_CIDX_INC_S    21
+#define ERR_INVALID_CIDX_INC_V(x) ((x) << ERR_INVALID_CIDX_INC_S)
+#define ERR_INVALID_CIDX_INC_F    ERR_INVALID_CIDX_INC_V(1U)
+
+#define ERR_CPL_OPCODE_0_S    19
+#define ERR_CPL_OPCODE_0_V(x) ((x) << ERR_CPL_OPCODE_0_S)
+#define ERR_CPL_OPCODE_0_F    ERR_CPL_OPCODE_0_V(1U)
+
+#define ERR_DROPPED_DB_S    18
+#define ERR_DROPPED_DB_V(x) ((x) << ERR_DROPPED_DB_S)
+#define ERR_DROPPED_DB_F    ERR_DROPPED_DB_V(1U)
+
+#define ERR_DATA_CPL_ON_HIGH_QID1_S    17
+#define ERR_DATA_CPL_ON_HIGH_QID1_V(x) ((x) << ERR_DATA_CPL_ON_HIGH_QID1_S)
+#define ERR_DATA_CPL_ON_HIGH_QID1_F    ERR_DATA_CPL_ON_HIGH_QID1_V(1U)
+
+#define ERR_DATA_CPL_ON_HIGH_QID0_S    16
+#define ERR_DATA_CPL_ON_HIGH_QID0_V(x) ((x) << ERR_DATA_CPL_ON_HIGH_QID0_S)
+#define ERR_DATA_CPL_ON_HIGH_QID0_F    ERR_DATA_CPL_ON_HIGH_QID0_V(1U)
+
+#define ERR_BAD_DB_PIDX3_S    15
+#define ERR_BAD_DB_PIDX3_V(x) ((x) << ERR_BAD_DB_PIDX3_S)
+#define ERR_BAD_DB_PIDX3_F    ERR_BAD_DB_PIDX3_V(1U)
+
+#define ERR_BAD_DB_PIDX2_S    14
+#define ERR_BAD_DB_PIDX2_V(x) ((x) << ERR_BAD_DB_PIDX2_S)
+#define ERR_BAD_DB_PIDX2_F    ERR_BAD_DB_PIDX2_V(1U)
+
+#define ERR_BAD_DB_PIDX1_S    13
+#define ERR_BAD_DB_PIDX1_V(x) ((x) << ERR_BAD_DB_PIDX1_S)
+#define ERR_BAD_DB_PIDX1_F    ERR_BAD_DB_PIDX1_V(1U)
+
+#define ERR_BAD_DB_PIDX0_S    12
+#define ERR_BAD_DB_PIDX0_V(x) ((x) << ERR_BAD_DB_PIDX0_S)
+#define ERR_BAD_DB_PIDX0_F    ERR_BAD_DB_PIDX0_V(1U)
+
+#define ERR_ING_CTXT_PRIO_S    10
+#define ERR_ING_CTXT_PRIO_V(x) ((x) << ERR_ING_CTXT_PRIO_S)
+#define ERR_ING_CTXT_PRIO_F    ERR_ING_CTXT_PRIO_V(1U)
+
+#define ERR_EGR_CTXT_PRIO_S    9
+#define ERR_EGR_CTXT_PRIO_V(x) ((x) << ERR_EGR_CTXT_PRIO_S)
+#define ERR_EGR_CTXT_PRIO_F    ERR_EGR_CTXT_PRIO_V(1U)
+
+#define DBFIFO_HP_INT_S    8
+#define DBFIFO_HP_INT_V(x) ((x) << DBFIFO_HP_INT_S)
+#define DBFIFO_HP_INT_F    DBFIFO_HP_INT_V(1U)
+
+#define DBFIFO_LP_INT_S    7
+#define DBFIFO_LP_INT_V(x) ((x) << DBFIFO_LP_INT_S)
+#define DBFIFO_LP_INT_F    DBFIFO_LP_INT_V(1U)
+
+#define INGRESS_SIZE_ERR_S    5
+#define INGRESS_SIZE_ERR_V(x) ((x) << INGRESS_SIZE_ERR_S)
+#define INGRESS_SIZE_ERR_F    INGRESS_SIZE_ERR_V(1U)
+
+#define EGRESS_SIZE_ERR_S    4
+#define EGRESS_SIZE_ERR_V(x) ((x) << EGRESS_SIZE_ERR_S)
+#define EGRESS_SIZE_ERR_F    EGRESS_SIZE_ERR_V(1U)
+
+#define SGE_INT_ENABLE3_A 0x1040
+#define SGE_FL_BUFFER_SIZE0_A 0x1044
+#define SGE_FL_BUFFER_SIZE1_A 0x1048
+#define SGE_FL_BUFFER_SIZE2_A 0x104c
+#define SGE_FL_BUFFER_SIZE3_A 0x1050
+#define SGE_FL_BUFFER_SIZE4_A 0x1054
+#define SGE_FL_BUFFER_SIZE5_A 0x1058
+#define SGE_FL_BUFFER_SIZE6_A 0x105c
+#define SGE_FL_BUFFER_SIZE7_A 0x1060
+#define SGE_FL_BUFFER_SIZE8_A 0x1064
+
+#define SGE_INGRESS_RX_THRESHOLD_A 0x10a0
+
+#define THRESHOLD_0_S    24
+#define THRESHOLD_0_M    0x3fU
+#define THRESHOLD_0_V(x) ((x) << THRESHOLD_0_S)
+#define THRESHOLD_0_G(x) (((x) >> THRESHOLD_0_S) & THRESHOLD_0_M)
+
+#define THRESHOLD_1_S    16
+#define THRESHOLD_1_M    0x3fU
+#define THRESHOLD_1_V(x) ((x) << THRESHOLD_1_S)
+#define THRESHOLD_1_G(x) (((x) >> THRESHOLD_1_S) & THRESHOLD_1_M)
+
+#define THRESHOLD_2_S    8
+#define THRESHOLD_2_M    0x3fU
+#define THRESHOLD_2_V(x) ((x) << THRESHOLD_2_S)
+#define THRESHOLD_2_G(x) (((x) >> THRESHOLD_2_S) & THRESHOLD_2_M)
+
+#define THRESHOLD_3_S    0
+#define THRESHOLD_3_M    0x3fU
+#define THRESHOLD_3_V(x) ((x) << THRESHOLD_3_S)
+#define THRESHOLD_3_G(x) (((x) >> THRESHOLD_3_S) & THRESHOLD_3_M)
+
+#define SGE_CONM_CTRL_A 0x1094
+
+#define EGRTHRESHOLD_S    8
+#define EGRTHRESHOLD_M    0x3fU
+#define EGRTHRESHOLD_V(x) ((x) << EGRTHRESHOLD_S)
+#define EGRTHRESHOLD_G(x) (((x) >> EGRTHRESHOLD_S) & EGRTHRESHOLD_M)
+
+#define EGRTHRESHOLDPACKING_S    14
+#define EGRTHRESHOLDPACKING_M    0x3fU
+#define EGRTHRESHOLDPACKING_V(x) ((x) << EGRTHRESHOLDPACKING_S)
+#define EGRTHRESHOLDPACKING_G(x) \
+	(((x) >> EGRTHRESHOLDPACKING_S) & EGRTHRESHOLDPACKING_M)
+
+#define SGE_TIMESTAMP_LO_A 0x1098
+#define SGE_TIMESTAMP_HI_A 0x109c
+
+#define TSOP_S    28
+#define TSOP_M    0x3U
+#define TSOP_V(x) ((x) << TSOP_S)
+#define TSOP_G(x) (((x) >> TSOP_S) & TSOP_M)
+
+#define TSVAL_S    0
+#define TSVAL_M    0xfffffffU
+#define TSVAL_V(x) ((x) << TSVAL_S)
+#define TSVAL_G(x) (((x) >> TSVAL_S) & TSVAL_M)
+
+#define SGE_DBFIFO_STATUS_A 0x10a4
+
+#define HP_INT_THRESH_S    28
+#define HP_INT_THRESH_M    0xfU
+#define HP_INT_THRESH_V(x) ((x) << HP_INT_THRESH_S)
+
+#define LP_INT_THRESH_S    12
+#define LP_INT_THRESH_M    0xfU
+#define LP_INT_THRESH_V(x) ((x) << LP_INT_THRESH_S)
+
+#define SGE_DOORBELL_CONTROL_A 0x10a8
+
+#define NOCOALESCE_S    26
+#define NOCOALESCE_V(x) ((x) << NOCOALESCE_S)
+#define NOCOALESCE_F    NOCOALESCE_V(1U)
+
+#define ENABLE_DROP_S    13
+#define ENABLE_DROP_V(x) ((x) << ENABLE_DROP_S)
+#define ENABLE_DROP_F    ENABLE_DROP_V(1U)
 
 #define SGE_TIMER_VALUE_0_AND_1 0x10b8
 #define  TIMERVALUE0_MASK   0xffff0000U
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
new file mode 100644
index 0000000..7699686
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -0,0 +1,81 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
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
+ */
+
+#ifndef __T4_VALUES_H__
+#define __T4_VALUES_H__
+
+/* This file contains definitions for various T4 register value hardware
+ * constants.  The types of values encoded here are predominantly those for
+ * register fields which control "modal" behavior.  For the most part, we do
+ * not include definitions for register fields which are simple numeric
+ * metrics, etc.
+ */
+
+/* SGE register field values.
+ */
+
+/* CONTROL1 register */
+#define RXPKTCPLMODE_SPLIT_X		1
+
+#define INGPCIEBOUNDARY_SHIFT_X		5
+#define INGPCIEBOUNDARY_32B_X		0
+
+#define INGPADBOUNDARY_SHIFT_X		5
+
+/* CONTROL2 register */
+#define INGPACKBOUNDARY_SHIFT_X		5
+#define INGPACKBOUNDARY_16B_X		0
+
+/* GTS register */
+#define SGE_TIMERREGS			6
+
+/* T5 and later support a new BAR2-based doorbell mechanism for Egress Queues.
+ * The User Doorbells are each 128 bytes in length with a Simple Doorbell at
+ * offsets 8x and a Write Combining single 64-byte Egress Queue Unit
+ * (IDXSIZE_UNIT_X) Gather Buffer interface at offset 64.  For Ingress Queues,
+ * we have a Going To Sleep register at offsets 8x+4.
+ *
+ * As noted above, we have many instances of the Simple Doorbell and Going To
+ * Sleep registers at offsets 8x and 8x+4, respectively.  We want to use a
+ * non-64-byte aligned offset for the Simple Doorbell in order to attempt to
+ * avoid buffering of the writes to the Simple Doorbell and we want to use a
+ * non-contiguous offset for the Going To Sleep writes in order to avoid
+ * possible combining between them.
+ */
+#define SGE_UDB_SIZE		128
+#define SGE_UDB_KDOORBELL	8
+#define SGE_UDB_GTS		20
+#define SGE_UDB_WCDOORBELL	64
+
+#endif /* __T4_VALUES_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 2215d43..b645e33 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -380,9 +380,9 @@ static void qenable(struct sge_rspq *rspq)
 	 * enable interrupts.
 	 */
 	t4_write_reg(rspq->adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-		     CIDXINC(0) |
-		     SEINTARM(rspq->intr_params) |
-		     INGRESSQID(rspq->cntxt_id));
+		     CIDXINC_V(0) |
+		     SEINTARM_V(rspq->intr_params) |
+		     INGRESSQID_V(rspq->cntxt_id));
 }
 
 /*
@@ -403,9 +403,9 @@ static void enable_rx(struct adapter *adapter)
 	 */
 	if (adapter->flags & USING_MSI)
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-			     CIDXINC(0) |
-			     SEINTARM(s->intrq.intr_params) |
-			     INGRESSQID(s->intrq.cntxt_id));
+			     CIDXINC_V(0) |
+			     SEINTARM_V(s->intrq.intr_params) |
+			     INGRESSQID_V(s->intrq.cntxt_id));
 
 }
 
@@ -2306,14 +2306,10 @@ static int adap_init0(struct adapter *adapter)
 	s->timer_val[5] = core_ticks_to_us(adapter,
 		TIMERVALUE1_GET(sge_params->sge_timer_value_4_and_5));
 
-	s->counter_val[0] =
-		THRESHOLD_0_GET(sge_params->sge_ingress_rx_threshold);
-	s->counter_val[1] =
-		THRESHOLD_1_GET(sge_params->sge_ingress_rx_threshold);
-	s->counter_val[2] =
-		THRESHOLD_2_GET(sge_params->sge_ingress_rx_threshold);
-	s->counter_val[3] =
-		THRESHOLD_3_GET(sge_params->sge_ingress_rx_threshold);
+	s->counter_val[0] = THRESHOLD_0_G(sge_params->sge_ingress_rx_threshold);
+	s->counter_val[1] = THRESHOLD_1_G(sge_params->sge_ingress_rx_threshold);
+	s->counter_val[2] = THRESHOLD_2_G(sge_params->sge_ingress_rx_threshold);
+	s->counter_val[3] = THRESHOLD_3_G(sge_params->sge_ingress_rx_threshold);
 
 	/*
 	 * Grab our Virtual Interface resource allocation, extract the
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index f7fd131..ef4da3e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -47,6 +47,7 @@
 #include "t4vf_defs.h"
 
 #include "../cxgb4/t4_regs.h"
+#include "../cxgb4/t4_values.h"
 #include "../cxgb4/t4fw_api.h"
 #include "../cxgb4/t4_msg.h"
 
@@ -531,11 +532,11 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 	 */
 	if (fl->pend_cred >= FL_PER_EQ_UNIT) {
 		if (is_t4(adapter->params.chip))
-			val = PIDX(fl->pend_cred / FL_PER_EQ_UNIT);
+			val = PIDX_V(fl->pend_cred / FL_PER_EQ_UNIT);
 		else
-			val = PIDX_T5(fl->pend_cred / FL_PER_EQ_UNIT) |
-			      DBTYPE(1);
-		val |= DBPRIO(1);
+			val = PIDX_T5_V(fl->pend_cred / FL_PER_EQ_UNIT) |
+			      DBTYPE_F;
+		val |= DBPRIO_F;
 
 		/* Make sure all memory writes to the Free List queue are
 		 * committed before we tell the hardware about them.
@@ -549,9 +550,9 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 		if (unlikely(fl->bar2_addr == NULL)) {
 			t4_write_reg(adapter,
 				     T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
-				     QID(fl->cntxt_id) | val);
+				     QID_V(fl->cntxt_id) | val);
 		} else {
-			writel(val | QID(fl->bar2_qid),
+			writel(val | QID_V(fl->bar2_qid),
 			       fl->bar2_addr + SGE_UDB_KDOORBELL);
 
 			/* This Write memory Barrier will force the write to
@@ -979,12 +980,12 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
 	 */
 	if (unlikely(tq->bar2_addr == NULL)) {
-		u32 val = PIDX(n);
+		u32 val = PIDX_V(n);
 
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
-			     QID(tq->cntxt_id) | val);
+			     QID_V(tq->cntxt_id) | val);
 	} else {
-		u32 val = PIDX_T5(n);
+		u32 val = PIDX_T5_V(n);
 
 		/* T4 and later chips share the same PIDX field offset within
 		 * the doorbell, but T5 and later shrank the field in order to
@@ -992,7 +993,7 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 		 * large in the first place (14 bits) so we just use the T5
 		 * and later limits and warn if a Queue ID is too large.
 		 */
-		WARN_ON(val & DBPRIO(1));
+		WARN_ON(val & DBPRIO_F);
 
 		/* If we're only writing a single Egress Unit and the BAR2
 		 * Queue ID is 0, we can use the Write Combining Doorbell
@@ -1023,7 +1024,7 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 				count--;
 			}
 		} else
-			writel(val | QID(tq->bar2_qid),
+			writel(val | QID_V(tq->bar2_qid),
 			       tq->bar2_addr + SGE_UDB_KDOORBELL);
 
 		/* This Write Memory Barrier will force the write to the User
@@ -1875,13 +1876,13 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	if (unlikely(work_done == 0))
 		rspq->unhandled_irqs++;
 
-	val = CIDXINC(work_done) | SEINTARM(intr_params);
+	val = CIDXINC_V(work_done) | SEINTARM_V(intr_params);
 	if (is_t4(rspq->adapter->params.chip)) {
 		t4_write_reg(rspq->adapter,
 			     T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-			     val | INGRESSQID((u32)rspq->cntxt_id));
+			     val | INGRESSQID_V((u32)rspq->cntxt_id));
 	} else {
-		writel(val | INGRESSQID(rspq->bar2_qid),
+		writel(val | INGRESSQID_V(rspq->bar2_qid),
 		       rspq->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
@@ -1975,12 +1976,12 @@ static unsigned int process_intrq(struct adapter *adapter)
 		rspq_next(intrq);
 	}
 
-	val = CIDXINC(work_done) | SEINTARM(intrq->intr_params);
+	val = CIDXINC_V(work_done) | SEINTARM_V(intrq->intr_params);
 	if (is_t4(adapter->params.chip))
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
-			     val | INGRESSQID(intrq->cntxt_id));
+			     val | INGRESSQID_V(intrq->cntxt_id));
 	else {
-		writel(val | INGRESSQID(intrq->bar2_qid),
+		writel(val | INGRESSQID_V(intrq->bar2_qid),
 		       intrq->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
@@ -2583,7 +2584,7 @@ int t4vf_sge_init(struct adapter *adapter)
 			fl0, fl1);
 		return -EINVAL;
 	}
-	if ((sge_params->sge_control & RXPKTCPLMODE_MASK) == 0) {
+	if ((sge_params->sge_control & RXPKTCPLMODE_F) == 0) {
 		dev_err(adapter->pdev_dev, "bad SGE CPL MODE\n");
 		return -EINVAL;
 	}
@@ -2593,9 +2594,9 @@ int t4vf_sge_init(struct adapter *adapter)
 	 */
 	if (fl1)
 		s->fl_pg_order = ilog2(fl1) - PAGE_SHIFT;
-	s->stat_len = ((sge_params->sge_control & EGRSTATUSPAGESIZE_MASK)
+	s->stat_len = ((sge_params->sge_control & EGRSTATUSPAGESIZE_F)
 			? 128 : 64);
-	s->pktshift = PKTSHIFT_GET(sge_params->sge_control);
+	s->pktshift = PKTSHIFT_G(sge_params->sge_control);
 
 	/* T4 uses a single control field to specify both the PCIe Padding and
 	 * Packing Boundary.  T5 introduced the ability to specify these
@@ -2607,8 +2608,8 @@ int t4vf_sge_init(struct adapter *adapter)
 	 * end doing this because it would initialize the Padding Boundary and
 	 * leave the Packing Boundary initialized to 0 (16 bytes).)
 	 */
-	ingpadboundary = 1 << (INGPADBOUNDARY_GET(sge_params->sge_control) +
-			       X_INGPADBOUNDARY_SHIFT);
+	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_params->sge_control) +
+			       INGPADBOUNDARY_SHIFT_X);
 	if (is_t4(adapter->params.chip)) {
 		s->fl_align = ingpadboundary;
 	} else {
@@ -2633,7 +2634,7 @@ int t4vf_sge_init(struct adapter *adapter)
 	 * Congestion Threshold is in units of 2 Free List pointers.)
 	 */
 	s->fl_starve_thres
-		= EGRTHRESHOLD_GET(sge_params->sge_congestion_control)*2 + 1;
+		= EGRTHRESHOLD_G(sge_params->sge_congestion_control)*2 + 1;
 
 	/*
 	 * Set up tasklet timers.
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 21dc9a2..6929d1f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -39,6 +39,7 @@
 #include "t4vf_defs.h"
 
 #include "../cxgb4/t4_regs.h"
+#include "../cxgb4/t4_values.h"
 #include "../cxgb4/t4fw_api.h"
 
 /*
@@ -528,13 +529,13 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	int v;
 
 	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_CONTROL));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_CONTROL_A));
 	params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_HOST_PAGE_SIZE));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_HOST_PAGE_SIZE_A));
 	params[2] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE0));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE0_A));
 	params[3] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE1));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE1_A));
 	params[4] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
 		     FW_PARAMS_PARAM_XYZ_V(SGE_TIMER_VALUE_0_AND_1));
 	params[5] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
@@ -576,9 +577,9 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	}
 
 	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_INGRESS_RX_THRESHOLD));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_INGRESS_RX_THRESHOLD_A));
 	params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ_V(SGE_CONM_CTRL));
+		     FW_PARAMS_PARAM_XYZ_V(SGE_CONM_CTRL_A));
 	v = t4vf_query_params(adapter, 2, params, vals);
 	if (v)
 		return v;
@@ -628,10 +629,10 @@ int t4vf_get_sge_params(struct adapter *adapter)
 			 (QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * pf);
 		sge_params->sge_vf_eq_qpp =
 			((sge_params->sge_egress_queues_per_page >> s_qpp)
-			 & QUEUESPERPAGEPF0_MASK);
+			 & QUEUESPERPAGEPF0_M);
 		sge_params->sge_vf_iq_qpp =
 			((sge_params->sge_ingress_queues_per_page >> s_qpp)
-			 & QUEUESPERPAGEPF0_MASK);
+			 & QUEUESPERPAGEPF0_M);
 	}
 
 	return 0;
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 9ab997e..890d93a 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -2256,15 +2256,15 @@ csio_hw_intr_enable(struct csio_hw *hw)
 		pl &= (~SF);
 		csio_wr_reg32(hw, pl, PL_INT_ENABLE);
 
-		csio_wr_reg32(hw, ERR_CPL_EXCEED_IQE_SIZE |
-			      EGRESS_SIZE_ERR | ERR_INVALID_CIDX_INC |
-			      ERR_CPL_OPCODE_0 | ERR_DROPPED_DB |
-			      ERR_DATA_CPL_ON_HIGH_QID1 |
-			      ERR_DATA_CPL_ON_HIGH_QID0 | ERR_BAD_DB_PIDX3 |
-			      ERR_BAD_DB_PIDX2 | ERR_BAD_DB_PIDX1 |
-			      ERR_BAD_DB_PIDX0 | ERR_ING_CTXT_PRIO |
-			      ERR_EGR_CTXT_PRIO | INGRESS_SIZE_ERR,
-			      SGE_INT_ENABLE3);
+		csio_wr_reg32(hw, ERR_CPL_EXCEED_IQE_SIZE_F |
+			      EGRESS_SIZE_ERR_F | ERR_INVALID_CIDX_INC_F |
+			      ERR_CPL_OPCODE_0_F | ERR_DROPPED_DB_F |
+			      ERR_DATA_CPL_ON_HIGH_QID1_F |
+			      ERR_DATA_CPL_ON_HIGH_QID0_F | ERR_BAD_DB_PIDX3_F |
+			      ERR_BAD_DB_PIDX2_F | ERR_BAD_DB_PIDX1_F |
+			      ERR_BAD_DB_PIDX0_F | ERR_ING_CTXT_PRIO_F |
+			      ERR_EGR_CTXT_PRIO_F | INGRESS_SIZE_ERR_F,
+			      SGE_INT_ENABLE3_A);
 		csio_set_reg_field(hw, PL_INT_MAP0, 0, 1 << pf);
 	}
 
@@ -2300,7 +2300,7 @@ csio_hw_intr_disable(struct csio_hw *hw)
 void
 csio_hw_fatal_err(struct csio_hw *hw)
 {
-	csio_set_reg_field(hw, SGE_CONTROL, GLOBALENABLE, 0);
+	csio_set_reg_field(hw, SGE_CONTROL_A, GLOBALENABLE_F, 0);
 	csio_hw_intr_disable(hw);
 
 	/* Do not reset HW, we may need FW state for debugging */
@@ -2698,44 +2698,44 @@ static void csio_sge_intr_handler(struct csio_hw *hw)
 	uint64_t v;
 
 	static struct intr_info sge_intr_info[] = {
-		{ ERR_CPL_EXCEED_IQE_SIZE,
+		{ ERR_CPL_EXCEED_IQE_SIZE_F,
 		  "SGE received CPL exceeding IQE size", -1, 1 },
-		{ ERR_INVALID_CIDX_INC,
+		{ ERR_INVALID_CIDX_INC_F,
 		  "SGE GTS CIDX increment too large", -1, 0 },
-		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
-		{ ERR_DROPPED_DB, "SGE doorbell dropped", -1, 0 },
-		{ ERR_DATA_CPL_ON_HIGH_QID1 | ERR_DATA_CPL_ON_HIGH_QID0,
+		{ ERR_CPL_OPCODE_0_F, "SGE received 0-length CPL", -1, 0 },
+		{ ERR_DROPPED_DB_F, "SGE doorbell dropped", -1, 0 },
+		{ ERR_DATA_CPL_ON_HIGH_QID1_F | ERR_DATA_CPL_ON_HIGH_QID0_F,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
-		{ ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX3_F, "SGE DBP 3 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX2, "SGE DBP 2 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX2_F, "SGE DBP 2 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX1, "SGE DBP 1 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX1_F, "SGE DBP 1 pidx increment too large", -1,
 		  0 },
-		{ ERR_BAD_DB_PIDX0, "SGE DBP 0 pidx increment too large", -1,
+		{ ERR_BAD_DB_PIDX0_F, "SGE DBP 0 pidx increment too large", -1,
 		  0 },
-		{ ERR_ING_CTXT_PRIO,
+		{ ERR_ING_CTXT_PRIO_F,
 		  "SGE too many priority ingress contexts", -1, 0 },
-		{ ERR_EGR_CTXT_PRIO,
+		{ ERR_EGR_CTXT_PRIO_F,
 		  "SGE too many priority egress contexts", -1, 0 },
-		{ INGRESS_SIZE_ERR, "SGE illegal ingress QID", -1, 0 },
-		{ EGRESS_SIZE_ERR, "SGE illegal egress QID", -1, 0 },
+		{ INGRESS_SIZE_ERR_F, "SGE illegal ingress QID", -1, 0 },
+		{ EGRESS_SIZE_ERR_F, "SGE illegal egress QID", -1, 0 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	v = (uint64_t)csio_rd_reg32(hw, SGE_INT_CAUSE1) |
-	    ((uint64_t)csio_rd_reg32(hw, SGE_INT_CAUSE2) << 32);
+	v = (uint64_t)csio_rd_reg32(hw, SGE_INT_CAUSE1_A) |
+	    ((uint64_t)csio_rd_reg32(hw, SGE_INT_CAUSE2_A) << 32);
 	if (v) {
 		csio_fatal(hw, "SGE parity error (%#llx)\n",
 			    (unsigned long long)v);
 		csio_wr_reg32(hw, (uint32_t)(v & 0xFFFFFFFF),
-						SGE_INT_CAUSE1);
-		csio_wr_reg32(hw, (uint32_t)(v >> 32), SGE_INT_CAUSE2);
+						SGE_INT_CAUSE1_A);
+		csio_wr_reg32(hw, (uint32_t)(v >> 32), SGE_INT_CAUSE2_A);
 	}
 
-	v |= csio_handle_intr_status(hw, SGE_INT_CAUSE3, sge_intr_info);
+	v |= csio_handle_intr_status(hw, SGE_INT_CAUSE3_A, sge_intr_info);
 
-	if (csio_handle_intr_status(hw, SGE_INT_CAUSE3, sge_intr_info) ||
+	if (csio_handle_intr_status(hw, SGE_INT_CAUSE3_A, sge_intr_info) ||
 	    v != 0)
 		csio_hw_fatal_err(hw);
 }
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index 4752fed..3bc9cf4 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -66,15 +66,15 @@ static inline int csio_is_t5(uint16_t chip)
 	{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
 
 #define CSIO_HW_PIDX(hw, index)						\
-	(csio_is_t4(hw->chip_id) ? (PIDX(index)) :			\
-					(PIDX_T5(index) | DBTYPE(1U)))
+	(csio_is_t4(hw->chip_id) ? (PIDX_V(index)) :			\
+					(PIDX_T5_G(index) | DBTYPE_F))
 
 #define CSIO_HW_LP_INT_THRESH(hw, val)					\
-	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH(val)) :		\
+	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_V(val)) :		\
 					(V_LP_INT_THRESH_T5(val)))
 
 #define CSIO_HW_M_LP_INT_THRESH(hw)					\
-	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_MASK) : (M_LP_INT_THRESH_T5))
+	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_M) : (M_LP_INT_THRESH_T5))
 
 #define CSIO_MAC_INT_CAUSE_REG(hw, port)				\
 	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE)) : \
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index 773da14..221433f 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -51,12 +51,12 @@ int csio_intr_coalesce_time = 10;	/* value:SGE_TIMER_VALUE_1 */
 static int csio_sge_timer_reg = 1;
 
 #define CSIO_SET_FLBUF_SIZE(_hw, _reg, _val)				\
-	csio_wr_reg32((_hw), (_val), SGE_FL_BUFFER_SIZE##_reg)
+	csio_wr_reg32((_hw), (_val), SGE_FL_BUFFER_SIZE##_reg##_A)
 
 static void
 csio_get_flbuf_size(struct csio_hw *hw, struct csio_sge *sge, uint32_t reg)
 {
-	sge->sge_fl_buf_size[reg] = csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE0 +
+	sge->sge_fl_buf_size[reg] = csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE0_A +
 							reg * sizeof(uint32_t));
 }
 
@@ -71,7 +71,7 @@ csio_wr_fl_bufsz(struct csio_sge *sge, struct csio_dma_buf *buf)
 static inline uint32_t
 csio_wr_qstat_pgsz(struct csio_hw *hw)
 {
-	return (hw->wrm.sge.sge_control & EGRSTATUSPAGESIZE(1)) ?  128 : 64;
+	return (hw->wrm.sge.sge_control & EGRSTATUSPAGESIZE_F) ?  128 : 64;
 }
 
 /* Ring freelist doorbell */
@@ -84,9 +84,9 @@ csio_wr_ring_fldb(struct csio_hw *hw, struct csio_q *flq)
 	 * 8 freelist buffer pointers (since each pointer is 8 bytes).
 	 */
 	if (flq->inc_idx >= 8) {
-		csio_wr_reg32(hw, DBPRIO(1) | QID(flq->un.fl.flid) |
+		csio_wr_reg32(hw, DBPRIO_F | QID_V(flq->un.fl.flid) |
 				  CSIO_HW_PIDX(hw, flq->inc_idx / 8),
-				  MYPF_REG(SGE_PF_KDOORBELL));
+				  MYPF_REG(SGE_PF_KDOORBELL_A));
 		flq->inc_idx &= 7;
 	}
 }
@@ -95,10 +95,10 @@ csio_wr_ring_fldb(struct csio_hw *hw, struct csio_q *flq)
 static void
 csio_wr_sge_intr_enable(struct csio_hw *hw, uint16_t iqid)
 {
-	csio_wr_reg32(hw, CIDXINC(0)		|
-			  INGRESSQID(iqid)	|
-			  TIMERREG(X_TIMERREG_RESTART_COUNTER),
-			  MYPF_REG(SGE_PF_GTS));
+	csio_wr_reg32(hw, CIDXINC_V(0)		|
+			  INGRESSQID_V(iqid)	|
+			  TIMERREG_V(X_TIMERREG_RESTART_COUNTER),
+			  MYPF_REG(SGE_PF_GTS_A));
 }
 
 /*
@@ -982,9 +982,9 @@ csio_wr_issue(struct csio_hw *hw, int qidx, bool prio)
 
 	wmb();
 	/* Ring SGE Doorbell writing q->pidx into it */
-	csio_wr_reg32(hw, DBPRIO(prio) | QID(q->un.eq.physeqid) |
+	csio_wr_reg32(hw, DBPRIO_V(prio) | QID_V(q->un.eq.physeqid) |
 			  CSIO_HW_PIDX(hw, q->inc_idx),
-			  MYPF_REG(SGE_PF_KDOORBELL));
+			  MYPF_REG(SGE_PF_KDOORBELL_A));
 	q->inc_idx = 0;
 
 	return 0;
@@ -1242,10 +1242,10 @@ csio_wr_process_iq(struct csio_hw *hw, struct csio_q *q,
 
 restart:
 	/* Now inform SGE about our incremental index value */
-	csio_wr_reg32(hw, CIDXINC(q->inc_idx)		|
-			  INGRESSQID(q->un.iq.physiqid)	|
-			  TIMERREG(csio_sge_timer_reg),
-			  MYPF_REG(SGE_PF_GTS));
+	csio_wr_reg32(hw, CIDXINC_V(q->inc_idx)		|
+			  INGRESSQID_V(q->un.iq.physiqid)	|
+			  TIMERREG_V(csio_sge_timer_reg),
+			  MYPF_REG(SGE_PF_GTS_A));
 	q->stats.n_tot_rsps += q->inc_idx;
 
 	q->inc_idx = 0;
@@ -1310,22 +1310,23 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 	uint32_t ingpad = 0;
 	uint32_t stat_len = clsz > 64 ? 128 : 64;
 
-	csio_wr_reg32(hw, HOSTPAGESIZEPF0(s_hps) | HOSTPAGESIZEPF1(s_hps) |
-		      HOSTPAGESIZEPF2(s_hps) | HOSTPAGESIZEPF3(s_hps) |
-		      HOSTPAGESIZEPF4(s_hps) | HOSTPAGESIZEPF5(s_hps) |
-		      HOSTPAGESIZEPF6(s_hps) | HOSTPAGESIZEPF7(s_hps),
-		      SGE_HOST_PAGE_SIZE);
+	csio_wr_reg32(hw, HOSTPAGESIZEPF0_V(s_hps) | HOSTPAGESIZEPF1_V(s_hps) |
+		      HOSTPAGESIZEPF2_V(s_hps) | HOSTPAGESIZEPF3_V(s_hps) |
+		      HOSTPAGESIZEPF4_V(s_hps) | HOSTPAGESIZEPF5_V(s_hps) |
+		      HOSTPAGESIZEPF6_V(s_hps) | HOSTPAGESIZEPF7_V(s_hps),
+		      SGE_HOST_PAGE_SIZE_A);
 
 	sge->csio_fl_align = clsz < 32 ? 32 : clsz;
 	ingpad = ilog2(sge->csio_fl_align) - 5;
 
-	csio_set_reg_field(hw, SGE_CONTROL, INGPADBOUNDARY_MASK |
-					    EGRSTATUSPAGESIZE(1),
-			   INGPADBOUNDARY(ingpad) |
-			   EGRSTATUSPAGESIZE(stat_len != 64));
+	csio_set_reg_field(hw, SGE_CONTROL_A,
+			   INGPADBOUNDARY_V(INGPADBOUNDARY_M) |
+			   EGRSTATUSPAGESIZE_F,
+			   INGPADBOUNDARY_V(ingpad) |
+			   EGRSTATUSPAGESIZE_V(stat_len != 64));
 
 	/* FL BUFFER SIZE#0 is Page size i,e already aligned to cache line */
-	csio_wr_reg32(hw, PAGE_SIZE, SGE_FL_BUFFER_SIZE0);
+	csio_wr_reg32(hw, PAGE_SIZE, SGE_FL_BUFFER_SIZE0_A);
 
 	/*
 	 * If using hard params, the following will get set correctly
@@ -1333,20 +1334,21 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 	 */
 	if (hw->flags & CSIO_HWF_USING_SOFT_PARAMS) {
 		csio_wr_reg32(hw,
-			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE2) +
+			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE2_A) +
 			sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
-			SGE_FL_BUFFER_SIZE2);
+			SGE_FL_BUFFER_SIZE2_A);
 		csio_wr_reg32(hw,
-			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE3) +
+			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE3_A) +
 			sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
-			SGE_FL_BUFFER_SIZE3);
+			SGE_FL_BUFFER_SIZE3_A);
 	}
 
 	csio_wr_reg32(hw, HPZ0(PAGE_SHIFT - 12), ULP_RX_TDDP_PSZ);
 
 	/* default value of rx_dma_offset of the NIC driver */
-	csio_set_reg_field(hw, SGE_CONTROL, PKTSHIFT_MASK,
-			   PKTSHIFT(CSIO_SGE_RX_DMA_OFFSET));
+	csio_set_reg_field(hw, SGE_CONTROL_A,
+			   PKTSHIFT_V(PKTSHIFT_M),
+			   PKTSHIFT_V(CSIO_SGE_RX_DMA_OFFSET));
 
 	csio_hw_tp_wr_bits_indirect(hw, TP_INGRESS_CONFIG,
 				    CSUM_HAS_PSEUDO_HDR, 0);
@@ -1384,9 +1386,9 @@ csio_wr_get_sge(struct csio_hw *hw)
 	u32 timer_value_0_and_1, timer_value_2_and_3, timer_value_4_and_5;
 	u32 ingress_rx_threshold;
 
-	sge->sge_control = csio_rd_reg32(hw, SGE_CONTROL);
+	sge->sge_control = csio_rd_reg32(hw, SGE_CONTROL_A);
 
-	ingpad = INGPADBOUNDARY_GET(sge->sge_control);
+	ingpad = INGPADBOUNDARY_G(sge->sge_control);
 
 	switch (ingpad) {
 	case X_INGPCIEBOUNDARY_32B:
@@ -1427,11 +1429,11 @@ csio_wr_get_sge(struct csio_hw *hw)
 	sge->timer_val[5] = (uint16_t)csio_core_ticks_to_us(hw,
 					TIMERVALUE5_GET(timer_value_4_and_5));
 
-	ingress_rx_threshold = csio_rd_reg32(hw, SGE_INGRESS_RX_THRESHOLD);
-	sge->counter_val[0] = THRESHOLD_0_GET(ingress_rx_threshold);
-	sge->counter_val[1] = THRESHOLD_1_GET(ingress_rx_threshold);
-	sge->counter_val[2] = THRESHOLD_2_GET(ingress_rx_threshold);
-	sge->counter_val[3] = THRESHOLD_3_GET(ingress_rx_threshold);
+	ingress_rx_threshold = csio_rd_reg32(hw, SGE_INGRESS_RX_THRESHOLD_A);
+	sge->counter_val[0] = THRESHOLD_0_G(ingress_rx_threshold);
+	sge->counter_val[1] = THRESHOLD_1_G(ingress_rx_threshold);
+	sge->counter_val[2] = THRESHOLD_2_G(ingress_rx_threshold);
+	sge->counter_val[3] = THRESHOLD_3_G(ingress_rx_threshold);
 
 	csio_init_intr_coalesce_parms(hw);
 }
@@ -1454,9 +1456,9 @@ csio_wr_set_sge(struct csio_hw *hw)
 	 * Set up our basic SGE mode to deliver CPL messages to our Ingress
 	 * Queue and Packet Date to the Free List.
 	 */
-	csio_set_reg_field(hw, SGE_CONTROL, RXPKTCPLMODE(1), RXPKTCPLMODE(1));
+	csio_set_reg_field(hw, SGE_CONTROL_A, RXPKTCPLMODE_F, RXPKTCPLMODE_F);
 
-	sge->sge_control = csio_rd_reg32(hw, SGE_CONTROL);
+	sge->sge_control = csio_rd_reg32(hw, SGE_CONTROL_A);
 
 	/* sge->csio_fl_align is set up by csio_wr_fixup_host_params(). */
 
@@ -1464,22 +1466,24 @@ csio_wr_set_sge(struct csio_hw *hw)
 	 * Set up to drop DOORBELL writes when the DOORBELL FIFO overflows
 	 * and generate an interrupt when this occurs so we can recover.
 	 */
-	csio_set_reg_field(hw, SGE_DBFIFO_STATUS,
-		   HP_INT_THRESH(HP_INT_THRESH_MASK) |
-		   CSIO_HW_LP_INT_THRESH(hw, CSIO_HW_M_LP_INT_THRESH(hw)),
-		   HP_INT_THRESH(CSIO_SGE_DBFIFO_INT_THRESH) |
-		   CSIO_HW_LP_INT_THRESH(hw, CSIO_SGE_DBFIFO_INT_THRESH));
+	csio_set_reg_field(hw, SGE_DBFIFO_STATUS_A,
+			   HP_INT_THRESH_V(HP_INT_THRESH_M) |
+			   CSIO_HW_LP_INT_THRESH(hw,
+						 CSIO_HW_M_LP_INT_THRESH(hw)),
+			   HP_INT_THRESH_V(CSIO_SGE_DBFIFO_INT_THRESH) |
+			   CSIO_HW_LP_INT_THRESH(hw,
+						 CSIO_SGE_DBFIFO_INT_THRESH));
 
-	csio_set_reg_field(hw, SGE_DOORBELL_CONTROL, ENABLE_DROP,
-			   ENABLE_DROP);
+	csio_set_reg_field(hw, SGE_DOORBELL_CONTROL_A, ENABLE_DROP_F,
+			   ENABLE_DROP_F);
 
 	/* SGE_FL_BUFFER_SIZE0 is set up by csio_wr_fixup_host_params(). */
 
 	CSIO_SET_FLBUF_SIZE(hw, 1, CSIO_SGE_FLBUF_SIZE1);
 	csio_wr_reg32(hw, (CSIO_SGE_FLBUF_SIZE2 + sge->csio_fl_align - 1)
-		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE2);
+		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE2_A);
 	csio_wr_reg32(hw, (CSIO_SGE_FLBUF_SIZE3 + sge->csio_fl_align - 1)
-		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE3);
+		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE3_A);
 	CSIO_SET_FLBUF_SIZE(hw, 4, CSIO_SGE_FLBUF_SIZE4);
 	CSIO_SET_FLBUF_SIZE(hw, 5, CSIO_SGE_FLBUF_SIZE5);
 	CSIO_SET_FLBUF_SIZE(hw, 6, CSIO_SGE_FLBUF_SIZE6);
@@ -1502,11 +1506,11 @@ csio_wr_set_sge(struct csio_hw *hw)
 	sge->counter_val[2] = CSIO_SGE_INT_CNT_VAL_2;
 	sge->counter_val[3] = CSIO_SGE_INT_CNT_VAL_3;
 
-	csio_wr_reg32(hw, THRESHOLD_0(sge->counter_val[0]) |
-		      THRESHOLD_1(sge->counter_val[1]) |
-		      THRESHOLD_2(sge->counter_val[2]) |
-		      THRESHOLD_3(sge->counter_val[3]),
-		      SGE_INGRESS_RX_THRESHOLD);
+	csio_wr_reg32(hw, THRESHOLD_0_V(sge->counter_val[0]) |
+		      THRESHOLD_1_V(sge->counter_val[1]) |
+		      THRESHOLD_2_V(sge->counter_val[2]) |
+		      THRESHOLD_3_V(sge->counter_val[3]),
+		      SGE_INGRESS_RX_THRESHOLD_A);
 
 	csio_wr_reg32(hw,
 		   TIMERVALUE0(csio_us_to_core_ticks(hw, sge->timer_val[0])) |
-- 
1.7.1
