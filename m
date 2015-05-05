From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 5/6] cxgb4: Move SGE Ingress DMA state monitor code to a new routine
Date: Tue,  5 May 2015 14:59:55 +0530
Message-ID: <1430818196-26508-6-git-send-email-hariprasad@chelsio.com>
References: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2851 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751669AbbEEERd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:17:33 -0400
In-Reply-To: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  23 ++++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |  85 +++----------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 127 +++++++++++++++++++++++++++++
 3 files changed, 156 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b6fa958..1f52d9f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -328,6 +328,17 @@ struct adapter_params {
 	unsigned int max_ird_adapter;     /* Max read depth per adapter */
 };
 
+/* State needed to monitor the forward progress of SGE Ingress DMA activities
+ * and possible hangs.
+ */
+struct sge_idma_monitor_state {
+	unsigned int idma_1s_thresh;	/* 1s threshold in Core Clock ticks */
+	unsigned int idma_stalled[2];	/* synthesized stalled timers in HZ */
+	unsigned int idma_state[2];	/* IDMA Hang detect state */
+	unsigned int idma_qid[2];	/* IDMA Hung Ingress Queue ID */
+	unsigned int idma_warn[2];	/* time to warning in HZ */
+};
+
 #include "t4fw_api.h"
 
 #define FW_VERSION(chip) ( \
@@ -630,12 +641,7 @@ struct sge {
 	u32 fl_align;               /* response queue message alignment */
 	u32 fl_starve_thres;        /* Free List starvation threshold */
 
-	/* State variables for detecting an SGE Ingress DMA hang */
-	unsigned int idma_1s_thresh;/* SGE same State Counter 1s threshold */
-	unsigned int idma_stalled[2];/* SGE synthesized stalled timers in HZ */
-	unsigned int idma_state[2]; /* SGE IDMA Hang detect state */
-	unsigned int idma_qid[2];   /* SGE IDMA Hung Ingress Queue ID */
-
+	struct sge_idma_monitor_state idma_monitor;
 	unsigned int egr_start;
 	unsigned int egr_sz;
 	unsigned int ingr_start;
@@ -1311,4 +1317,9 @@ int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 			 u32 addr, u32 val);
 void t4_sge_decode_idma_state(struct adapter *adapter, int state);
 void t4_free_mem(void *addr);
+void t4_idma_monitor_init(struct adapter *adapter,
+			  struct sge_idma_monitor_state *idma);
+void t4_idma_monitor(struct adapter *adapter,
+		     struct sge_idma_monitor_state *idma,
+		     int hz, int ticks);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 354480d..ad504d0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -100,16 +100,6 @@
  */
 #define TX_QCHECK_PERIOD (HZ / 2)
 
-/* SGE Hung Ingress DMA Threshold Warning time (in Hz) and Warning Repeat Rate
- * (in RX_QCHECK_PERIOD multiples).  If we find one of the SGE Ingress DMA
- * State Machines in the same state for this amount of time (in HZ) then we'll
- * issue a warning about a potential hang.  We'll repeat the warning as the
- * SGE Ingress DMA Channel appears to be hung every N RX_QCHECK_PERIODs till
- * the situation clears.  If the situation clears, we'll note that as well.
- */
-#define SGE_IDMA_WARN_THRESH (1 * HZ)
-#define SGE_IDMA_WARN_REPEAT (20 * RX_QCHECK_PERIOD)
-
 /*
  * Max number of Tx descriptors to be reclaimed by the Tx timer.
  */
@@ -2279,7 +2269,7 @@ irq_handler_t t4_intr_handler(struct adapter *adap)
 static void sge_rx_timer_cb(unsigned long data)
 {
 	unsigned long m;
-	unsigned int i, idma_same_state_cnt[2];
+	unsigned int i;
 	struct adapter *adap = (struct adapter *)data;
 	struct sge *s = &adap->sge;
 
@@ -2300,67 +2290,16 @@ static void sge_rx_timer_cb(unsigned long data)
 					set_bit(id, s->starving_fl);
 			}
 		}
+	/* The remainder of the SGE RX Timer Callback routine is dedicated to
+	 * global Master PF activities like checking for chip ingress stalls,
+	 * etc.
+	 */
+	if (!(adap->flags & MASTER_PF))
+		goto done;
 
-	t4_write_reg(adap, SGE_DEBUG_INDEX_A, 13);
-	idma_same_state_cnt[0] = t4_read_reg(adap, SGE_DEBUG_DATA_HIGH_A);
-	idma_same_state_cnt[1] = t4_read_reg(adap, SGE_DEBUG_DATA_LOW_A);
-
-	for (i = 0; i < 2; i++) {
-		u32 debug0, debug11;
-
-		/* If the Ingress DMA Same State Counter ("timer") is less
-		 * than 1s, then we can reset our synthesized Stall Timer and
-		 * continue.  If we have previously emitted warnings about a
-		 * potential stalled Ingress Queue, issue a note indicating
-		 * that the Ingress Queue has resumed forward progress.
-		 */
-		if (idma_same_state_cnt[i] < s->idma_1s_thresh) {
-			if (s->idma_stalled[i] >= SGE_IDMA_WARN_THRESH)
-				CH_WARN(adap, "SGE idma%d, queue%u,resumed after %d sec\n",
-					i, s->idma_qid[i],
-					s->idma_stalled[i]/HZ);
-			s->idma_stalled[i] = 0;
-			continue;
-		}
-
-		/* Synthesize an SGE Ingress DMA Same State Timer in the Hz
-		 * domain.  The first time we get here it'll be because we
-		 * passed the 1s Threshold; each additional time it'll be
-		 * because the RX Timer Callback is being fired on its regular
-		 * schedule.
-		 *
-		 * If the stall is below our Potential Hung Ingress Queue
-		 * Warning Threshold, continue.
-		 */
-		if (s->idma_stalled[i] == 0)
-			s->idma_stalled[i] = HZ;
-		else
-			s->idma_stalled[i] += RX_QCHECK_PERIOD;
-
-		if (s->idma_stalled[i] < SGE_IDMA_WARN_THRESH)
-			continue;
-
-		/* We'll issue a warning every SGE_IDMA_WARN_REPEAT Hz */
-		if (((s->idma_stalled[i] - HZ) % SGE_IDMA_WARN_REPEAT) != 0)
-			continue;
-
-		/* Read and save the SGE IDMA State and Queue ID information.
-		 * We do this every time in case it changes across time ...
-		 */
-		t4_write_reg(adap, SGE_DEBUG_INDEX_A, 0);
-		debug0 = t4_read_reg(adap, SGE_DEBUG_DATA_LOW_A);
-		s->idma_state[i] = (debug0 >> (i * 9)) & 0x3f;
-
-		t4_write_reg(adap, SGE_DEBUG_INDEX_A, 11);
-		debug11 = t4_read_reg(adap, SGE_DEBUG_DATA_LOW_A);
-		s->idma_qid[i] = (debug11 >> (i * 16)) & 0xffff;
-
-		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",
-			i, s->idma_qid[i], s->idma_state[i],
-			s->idma_stalled[i]/HZ, debug0, debug11);
-		t4_sge_decode_idma_state(adap, s->idma_state[i]);
-	}
+	t4_idma_monitor(adap, &s->idma_monitor, HZ, RX_QCHECK_PERIOD);
 
+done:
 	mod_timer(&s->rx_timer, jiffies + RX_QCHECK_PERIOD);
 }
 
@@ -3121,11 +3060,11 @@ int t4_sge_init(struct adapter *adap)
 		egress_threshold = EGRTHRESHOLDPACKING_G(sge_conm_ctrl);
 	s->fl_starve_thres = 2*egress_threshold + 1;
 
+	t4_idma_monitor_init(adap, &s->idma_monitor);
+
 	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adap);
 	setup_timer(&s->tx_timer, sge_tx_timer_cb, (unsigned long)adap);
-	s->idma_1s_thresh = core_ticks_per_usec(adap) * 1000000;  /* 1 s */
-	s->idma_stalled[0] = 0;
-	s->idma_stalled[1] = 0;
+
 	spin_lock_init(&s->intrq_lock);
 
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 8ba91c3..6164ef3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5717,3 +5717,130 @@ void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr)
 		t4_write_reg(adap, TP_DBG_LA_CONFIG_A,
 			     cfg | adap->params.tp.la_mask);
 }
+
+/* SGE Hung Ingress DMA Warning Threshold time and Warning Repeat Rate (in
+ * seconds).  If we find one of the SGE Ingress DMA State Machines in the same
+ * state for more than the Warning Threshold then we'll issue a warning about
+ * a potential hang.  We'll repeat the warning as the SGE Ingress DMA Channel
+ * appears to be hung every Warning Repeat second till the situation clears.
+ * If the situation clears, we'll note that as well.
+ */
+#define SGE_IDMA_WARN_THRESH 1
+#define SGE_IDMA_WARN_REPEAT 300
+
+/**
+ *	t4_idma_monitor_init - initialize SGE Ingress DMA Monitor
+ *	@adapter: the adapter
+ *	@idma: the adapter IDMA Monitor state
+ *
+ *	Initialize the state of an SGE Ingress DMA Monitor.
+ */
+void t4_idma_monitor_init(struct adapter *adapter,
+			  struct sge_idma_monitor_state *idma)
+{
+	/* Initialize the state variables for detecting an SGE Ingress DMA
+	 * hang.  The SGE has internal counters which count up on each clock
+	 * tick whenever the SGE finds its Ingress DMA State Engines in the
+	 * same state they were on the previous clock tick.  The clock used is
+	 * the Core Clock so we have a limit on the maximum "time" they can
+	 * record; typically a very small number of seconds.  For instance,
+	 * with a 600MHz Core Clock, we can only count up to a bit more than
+	 * 7s.  So we'll synthesize a larger counter in order to not run the
+	 * risk of having the "timers" overflow and give us the flexibility to
+	 * maintain a Hung SGE State Machine of our own which operates across
+	 * a longer time frame.
+	 */
+	idma->idma_1s_thresh = core_ticks_per_usec(adapter) * 1000000; /* 1s */
+	idma->idma_stalled[0] = 0;
+	idma->idma_stalled[1] = 0;
+}
+
+/**
+ *	t4_idma_monitor - monitor SGE Ingress DMA state
+ *	@adapter: the adapter
+ *	@idma: the adapter IDMA Monitor state
+ *	@hz: number of ticks/second
+ *	@ticks: number of ticks since the last IDMA Monitor call
+ */
+void t4_idma_monitor(struct adapter *adapter,
+		     struct sge_idma_monitor_state *idma,
+		     int hz, int ticks)
+{
+	int i, idma_same_state_cnt[2];
+
+	 /* Read the SGE Debug Ingress DMA Same State Count registers.  These
+	  * are counters inside the SGE which count up on each clock when the
+	  * SGE finds its Ingress DMA State Engines in the same states they
+	  * were in the previous clock.  The counters will peg out at
+	  * 0xffffffff without wrapping around so once they pass the 1s
+	  * threshold they'll stay above that till the IDMA state changes.
+	  */
+	t4_write_reg(adapter, SGE_DEBUG_INDEX_A, 13);
+	idma_same_state_cnt[0] = t4_read_reg(adapter, SGE_DEBUG_DATA_HIGH_A);
+	idma_same_state_cnt[1] = t4_read_reg(adapter, SGE_DEBUG_DATA_LOW_A);
+
+	for (i = 0; i < 2; i++) {
+		u32 debug0, debug11;
+
+		/* If the Ingress DMA Same State Counter ("timer") is less
+		 * than 1s, then we can reset our synthesized Stall Timer and
+		 * continue.  If we have previously emitted warnings about a
+		 * potential stalled Ingress Queue, issue a note indicating
+		 * that the Ingress Queue has resumed forward progress.
+		 */
+		if (idma_same_state_cnt[i] < idma->idma_1s_thresh) {
+			if (idma->idma_stalled[i] >= SGE_IDMA_WARN_THRESH * hz)
+				dev_warn(adapter->pdev_dev, "SGE idma%d, queue %u, "
+					 "resumed after %d seconds\n",
+					 i, idma->idma_qid[i],
+					 idma->idma_stalled[i] / hz);
+			idma->idma_stalled[i] = 0;
+			continue;
+		}
+
+		/* Synthesize an SGE Ingress DMA Same State Timer in the Hz
+		 * domain.  The first time we get here it'll be because we
+		 * passed the 1s Threshold; each additional time it'll be
+		 * because the RX Timer Callback is being fired on its regular
+		 * schedule.
+		 *
+		 * If the stall is below our Potential Hung Ingress Queue
+		 * Warning Threshold, continue.
+		 */
+		if (idma->idma_stalled[i] == 0) {
+			idma->idma_stalled[i] = hz;
+			idma->idma_warn[i] = 0;
+		} else {
+			idma->idma_stalled[i] += ticks;
+			idma->idma_warn[i] -= ticks;
+		}
+
+		if (idma->idma_stalled[i] < SGE_IDMA_WARN_THRESH * hz)
+			continue;
+
+		/* We'll issue a warning every SGE_IDMA_WARN_REPEAT seconds.
+		 */
+		if (idma->idma_warn[i] > 0)
+			continue;
+		idma->idma_warn[i] = SGE_IDMA_WARN_REPEAT * hz;
+
+		/* Read and save the SGE IDMA State and Queue ID information.
+		 * We do this every time in case it changes across time ...
+		 * can't be too careful ...
+		 */
+		t4_write_reg(adapter, SGE_DEBUG_INDEX_A, 0);
+		debug0 = t4_read_reg(adapter, SGE_DEBUG_DATA_LOW_A);
+		idma->idma_state[i] = (debug0 >> (i * 9)) & 0x3f;
+
+		t4_write_reg(adapter, SGE_DEBUG_INDEX_A, 11);
+		debug11 = t4_read_reg(adapter, SGE_DEBUG_DATA_LOW_A);
+		idma->idma_qid[i] = (debug11 >> (i * 16)) & 0xffff;
+
+		dev_warn(adapter->pdev_dev, "SGE idma%u, queue %u, potentially stuck in "
+			 "state %u for %d seconds (debug0=%#x, debug11=%#x)\n",
+			 i, idma->idma_qid[i], idma->idma_state[i],
+			 idma->idma_stalled[i] / hz,
+			 debug0, debug11);
+		t4_sge_decode_idma_state(adapter, idma->idma_state[i]);
+	}
+}
-- 
2.3.4
