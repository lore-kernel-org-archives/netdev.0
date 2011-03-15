From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-03-15
Date: Tue, 15 Mar 2011 15:31:22 -0400
Message-ID: <20110315193122.GD2542@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33254 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab1COTgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:36:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

One last non-fix pull for 2.6.39 -- hooray!

Not a lot here, since we just had a pull towards the end of last week.
There are a handfule of ath9k bits, a couple of wl1251 patches,
a couple of mac80211 bits, etc.  Nothing too troublesome. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0c0217b016ba8a970a6f6ab62ad0d858f39881ca:

  net: dcbnl: Add IEEE app selector value definitions (2011-03-14 17:02:43 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Dan Carpenter (1):
      libertas: fix write past end of array in mesh_id_get()

Felix Fietkau (7):
      ath9k: remove support for the FIF_PROMISC_IN_BSS filter flag
      ath9k_hw: fix REG_SET_BIT and REG_CLR_BIT for multiple bits
      ath9k: fix stopping tx dma on reset
      ath9k: fix the .flush driver op implementation
      ath9k: improve reliability of beacon transmission and stuck beacon handling
      mac80211: fix channel type recalculation with HT and non-HT interfaces
      ath9k: fix aggregation related interoperability issues

Grazvydas Ignotas (2):
      wl1251: remove wl1251_ps_set_elp function
      wl1251: fix elp_work race condition

Helmut Schaa (1):
      mac80211: Shortcut minstrel_ht rate setup for non-MRR capable devices

Jason Young (1):
      mac80211: do not enable ps if 802.1x controlled port is unblocked

Johannes Berg (1):
      iwlagn: support off-channel TX

John W. Linville (4):
      wireless: add support for ethtool_ops->{get,set}_ringparam
      mac80211: implement support for cfg80211_ops->{get,set}_ringparam
      ath5k: implement ieee80211_ops->{get,set}_ringparam
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Vivek Natarajan (3):
      ath9k_hw: Improve idle power consumption for AR9485.
      ath9k_hw: Fix PLL initialization for AR9485.
      ath9k_hw: Increase the wait count for nf load.

 drivers/net/wireless/ath/ath5k/base.c            |    3 +-
 drivers/net/wireless/ath/ath5k/base.h            |    1 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c    |   43 +++++++
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h |    2 +
 drivers/net/wireless/ath/ath9k/ath9k.h           |    1 -
 drivers/net/wireless/ath/ath9k/beacon.c          |   13 +--
 drivers/net/wireless/ath/ath9k/calib.c           |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c              |    4 +-
 drivers/net/wireless/ath/ath9k/hw.h              |    4 +-
 drivers/net/wireless/ath/ath9k/mac.c             |   91 ++++++---------
 drivers/net/wireless/ath/ath9k/mac.h             |    3 +-
 drivers/net/wireless/ath/ath9k/main.c            |   56 ++++------
 drivers/net/wireless/ath/ath9k/recv.c            |    4 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |   44 +++----
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c       |  135 ++++++++++++++++-----
 drivers/net/wireless/iwlwifi/iwl-agn.c           |   87 ++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-commands.h      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-core.h          |    6 +
 drivers/net/wireless/iwlwifi/iwl-dev.h           |   12 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c          |   41 ++++---
 drivers/net/wireless/libertas/mesh.c             |   11 +-
 drivers/net/wireless/wl1251/ps.c                 |   41 +------
 include/net/cfg80211.h                           |    8 ++
 include/net/mac80211.h                           |    7 +
 net/mac80211/cfg.c                               |   21 ++++
 net/mac80211/chan.c                              |    3 +
 net/mac80211/driver-ops.h                        |   26 ++++
 net/mac80211/driver-trace.h                      |   52 ++++++++
 net/mac80211/mlme.c                              |   37 +++++-
 net/mac80211/rc80211_minstrel_ht.c               |   41 ++++++-
 net/wireless/ethtool.c                           |   33 ++++++
 31 files changed, 597 insertions(+), 245 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index e6ff62e..4d7f21e 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -943,6 +943,7 @@ ath5k_txq_setup(struct ath5k_softc *sc,
 		spin_lock_init(&txq->lock);
 		txq->setup = true;
 		txq->txq_len = 0;
+		txq->txq_max = ATH5K_TXQ_LEN_MAX;
 		txq->txq_poll_mark = false;
 		txq->txq_stuck = 0;
 	}
@@ -1534,7 +1535,7 @@ ath5k_tx_queue(struct ieee80211_hw *hw, struct sk_buff *skb,
 		goto drop_packet;
 	}
 
-	if (txq->txq_len >= ATH5K_TXQ_LEN_MAX)
+	if (txq->txq_len >= txq->txq_max)
 		ieee80211_stop_queue(hw, txq->qnum);
 
 	spin_lock_irqsave(&sc->txbuflock, flags);
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index 8d1df1f..978f1f4 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -86,6 +86,7 @@ struct ath5k_txq {
 	spinlock_t		lock;	/* lock on q and link */
 	bool			setup;
 	int			txq_len; /* number of queued buffers */
+	int			txq_max; /* max allowed num of queued buffers */
 	bool			txq_poll_mark;
 	unsigned int		txq_stuck;	/* informational counter */
 };
diff --git a/drivers/net/wireless/ath/ath5k/mac80211-ops.c b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
index c9b0b67..9be29b7 100644
--- a/drivers/net/wireless/ath/ath5k/mac80211-ops.c
+++ b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
@@ -740,6 +740,47 @@ ath5k_get_antenna(struct ieee80211_hw *hw, u32 *tx_ant, u32 *rx_ant)
 }
 
 
+static void ath5k_get_ringparam(struct ieee80211_hw *hw,
+				u32 *tx, u32 *tx_max, u32 *rx, u32 *rx_max)
+{
+	struct ath5k_softc *sc = hw->priv;
+
+	*tx = sc->txqs[AR5K_TX_QUEUE_ID_DATA_MIN].txq_max;
+
+	*tx_max = ATH5K_TXQ_LEN_MAX;
+	*rx = *rx_max = ATH_RXBUF;
+}
+
+
+static int ath5k_set_ringparam(struct ieee80211_hw *hw, u32 tx, u32 rx)
+{
+	struct ath5k_softc *sc = hw->priv;
+	u16 qnum;
+
+	/* only support setting tx ring size for now */
+	if (rx != ATH_RXBUF)
+		return -EINVAL;
+
+	/* restrict tx ring size min/max */
+	if (!tx || tx > ATH5K_TXQ_LEN_MAX)
+		return -EINVAL;
+
+	for (qnum = 0; qnum < ARRAY_SIZE(sc->txqs); qnum++) {
+		if (!sc->txqs[qnum].setup)
+			continue;
+		if (sc->txqs[qnum].qnum < AR5K_TX_QUEUE_ID_DATA_MIN ||
+		    sc->txqs[qnum].qnum > AR5K_TX_QUEUE_ID_DATA_MAX)
+			continue;
+
+		sc->txqs[qnum].txq_max = tx;
+		if (sc->txqs[qnum].txq_len >= sc->txqs[qnum].txq_max)
+			ieee80211_stop_queue(hw, sc->txqs[qnum].qnum);
+	}
+
+	return 0;
+}
+
+
 const struct ieee80211_ops ath5k_hw_ops = {
 	.tx			= ath5k_tx,
 	.start			= ath5k_start,
@@ -778,4 +819,6 @@ const struct ieee80211_ops ath5k_hw_ops = {
 	/* .napi_poll		= not implemented */
 	.set_antenna		= ath5k_set_antenna,
 	.get_antenna		= ath5k_get_antenna,
+	.set_ringparam		= ath5k_set_ringparam,
+	.get_ringparam		= ath5k_get_ringparam,
 };
diff --git a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h b/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
index eac4d8526..71cc0a3 100644
--- a/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9485_initvals.h
@@ -667,6 +667,7 @@ static const u32 ar9485_1_0_pcie_phy_clkreq_enable_L1[][2] = {
 
 static const u32 ar9485_1_0_soc_preamble[][2] = {
 	/*   Addr     allmodes */
+	{0x00004090, 0x00aa10aa},
 	{0x000040a4, 0x00a0c9c9},
 	{0x00007048, 0x00000004},
 };
@@ -1708,6 +1709,7 @@ static const u32 ar9485_1_1_pcie_phy_clkreq_disable_L1[][2] = {
 static const u32 ar9485_1_1_soc_preamble[][2] = {
 	/* Addr        allmodes */
 	{0x00004014, 0xba280400},
+	{0x00004090, 0x00aa10aa},
 	{0x000040a4, 0x00a0c9c9},
 	{0x00007010, 0x00000022},
 	{0x00007020, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index c718ab5..099bd41 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -189,7 +189,6 @@ struct ath_txq {
 	u32 axq_ampdu_depth;
 	bool stopped;
 	bool axq_tx_inprogress;
-	bool txq_flush_inprogress;
 	struct list_head axq_acq;
 	struct list_head txq_fifo[ATH_TXFIFO_DEPTH];
 	struct list_head txq_fifo_pending;
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index a4bdfdb..6d2a545f 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -373,6 +373,7 @@ void ath_beacon_tasklet(unsigned long data)
 			ath_dbg(common, ATH_DBG_BSTUCK,
 				"missed %u consecutive beacons\n",
 				sc->beacon.bmisscnt);
+			ath9k_hw_stop_dma_queue(ah, sc->beacon.beaconq);
 			ath9k_hw_bstuck_nfcal(ah);
 		} else if (sc->beacon.bmisscnt >= BSTUCK_THRESH) {
 			ath_dbg(common, ATH_DBG_BSTUCK,
@@ -450,16 +451,6 @@ void ath_beacon_tasklet(unsigned long data)
 		sc->beacon.updateslot = OK;
 	}
 	if (bfaddr != 0) {
-		/*
-		 * Stop any current dma and put the new frame(s) on the queue.
-		 * This should never fail since we check above that no frames
-		 * are still pending on the queue.
-		 */
-		if (!ath9k_hw_stoptxdma(ah, sc->beacon.beaconq)) {
-			ath_err(common, "beacon queue %u did not stop?\n",
-				sc->beacon.beaconq);
-		}
-
 		/* NB: cabq traffic should already be queued and primed */
 		ath9k_hw_puttxbuf(ah, sc->beacon.beaconq, bfaddr);
 		ath9k_hw_txstart(ah, sc->beacon.beaconq);
@@ -780,7 +771,7 @@ void ath9k_set_beaconing_status(struct ath_softc *sc, bool status)
 		ah->imask &= ~ATH9K_INT_SWBA;
 		ath9k_hw_set_interrupts(ah, ah->imask);
 		tasklet_kill(&sc->bcon_tasklet);
-		ath9k_hw_stoptxdma(ah, sc->beacon.beaconq);
+		ath9k_hw_stop_dma_queue(ah, sc->beacon.beaconq);
 	}
 	ath9k_ps_restore(sc);
 }
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index b4a92a4..8649581 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -262,7 +262,7 @@ void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	 * since 250us often results in NF load timeout and causes deaf
 	 * condition during stress testing 12/12/2009
 	 */
-	for (j = 0; j < 1000; j++) {
+	for (j = 0; j < 10000; j++) {
 		if ((REG_READ(ah, AR_PHY_AGC_CONTROL) &
 		     AR_PHY_AGC_CONTROL_NF) == 0)
 			break;
@@ -278,7 +278,7 @@ void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	 * here, the baseband nf cal will just be capped by our present
 	 * noisefloor until the next calibration timer.
 	 */
-	if (j == 1000) {
+	if (j == 10000) {
 		ath_dbg(common, ATH_DBG_ANY,
 			"Timeout while waiting for nf to load: AR_PHY_AGC_CONTROL=0x%x\n",
 			REG_READ(ah, AR_PHY_AGC_CONTROL));
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 9a34381..338b075 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -701,7 +701,7 @@ static void ath9k_hw_init_pll(struct ath_hw *ah,
 			      AR_CH0_DPLL3_PHASE_SHIFT, DPLL3_PHASE_SHIFT_VAL);
 
 		REG_WRITE(ah, AR_RTC_PLL_CONTROL, 0x1142c);
-		udelay(100);
+		udelay(1000);
 
 		REG_WRITE(ah, AR_RTC_PLL_CONTROL2, 0x886666);
 
@@ -713,7 +713,7 @@ static void ath9k_hw_init_pll(struct ath_hw *ah,
 		REG_RMW_FIELD(ah, AR_CH0_BB_DPLL3,
 			      AR_CH0_DPLL3_PHASE_SHIFT, DPLL3_PHASE_SHIFT_VAL);
 		REG_WRITE(ah, AR_RTC_PLL_CONTROL, 0x142c);
-		udelay(110);
+		udelay(1000);
 	}
 
 	pll = ath9k_hw_compute_pll_control(ah, chan);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index ef79f4c..6650fd4 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -95,9 +95,9 @@
 #define REG_READ_FIELD(_a, _r, _f) \
 	(((REG_READ(_a, _r) & _f) >> _f##_S))
 #define REG_SET_BIT(_a, _r, _f) \
-	REG_WRITE(_a, _r, REG_READ(_a, _r) | _f)
+	REG_WRITE(_a, _r, REG_READ(_a, _r) | (_f))
 #define REG_CLR_BIT(_a, _r, _f) \
-	REG_WRITE(_a, _r, REG_READ(_a, _r) & ~_f)
+	REG_WRITE(_a, _r, REG_READ(_a, _r) & ~(_f))
 
 #define DO_DELAY(x) do {			\
 		if ((++(x) % 64) == 0)          \
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 5efc869..562257a 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -143,84 +143,59 @@ bool ath9k_hw_updatetxtriglevel(struct ath_hw *ah, bool bIncTrigLevel)
 }
 EXPORT_SYMBOL(ath9k_hw_updatetxtriglevel);
 
-bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
+void ath9k_hw_abort_tx_dma(struct ath_hw *ah)
 {
-#define ATH9K_TX_STOP_DMA_TIMEOUT	4000    /* usec */
-#define ATH9K_TIME_QUANTUM		100     /* usec */
-	struct ath_common *common = ath9k_hw_common(ah);
-	struct ath9k_hw_capabilities *pCap = &ah->caps;
-	struct ath9k_tx_queue_info *qi;
-	u32 tsfLow, j, wait;
-	u32 wait_time = ATH9K_TX_STOP_DMA_TIMEOUT / ATH9K_TIME_QUANTUM;
+	int i, q;
 
-	if (q >= pCap->total_queues) {
-		ath_dbg(common, ATH_DBG_QUEUE,
-			"Stopping TX DMA, invalid queue: %u\n", q);
-		return false;
-	}
+	REG_WRITE(ah, AR_Q_TXD, AR_Q_TXD_M);
 
-	qi = &ah->txq[q];
-	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_dbg(common, ATH_DBG_QUEUE,
-			"Stopping TX DMA, inactive queue: %u\n", q);
-		return false;
-	}
+	REG_SET_BIT(ah, AR_PCU_MISC, AR_PCU_FORCE_QUIET_COLL | AR_PCU_CLEAR_VMF);
+	REG_SET_BIT(ah, AR_DIAG_SW, AR_DIAG_FORCE_CH_IDLE_HIGH);
+	REG_SET_BIT(ah, AR_D_GBL_IFS_MISC, AR_D_GBL_IFS_MISC_IGNORE_BACKOFF);
 
-	REG_WRITE(ah, AR_Q_TXD, 1 << q);
+	for (q = 0; q < AR_NUM_QCU; q++) {
+		for (i = 0; i < 1000; i++) {
+			if (i)
+				udelay(5);
 
-	for (wait = wait_time; wait != 0; wait--) {
-		if (ath9k_hw_numtxpending(ah, q) == 0)
-			break;
-		udelay(ATH9K_TIME_QUANTUM);
+			if (!ath9k_hw_numtxpending(ah, q))
+				break;
+		}
 	}
 
-	if (ath9k_hw_numtxpending(ah, q)) {
-		ath_dbg(common, ATH_DBG_QUEUE,
-			"%s: Num of pending TX Frames %d on Q %d\n",
-			__func__, ath9k_hw_numtxpending(ah, q), q);
-
-		for (j = 0; j < 2; j++) {
-			tsfLow = REG_READ(ah, AR_TSF_L32);
-			REG_WRITE(ah, AR_QUIET2,
-				  SM(10, AR_QUIET2_QUIET_DUR));
-			REG_WRITE(ah, AR_QUIET_PERIOD, 100);
-			REG_WRITE(ah, AR_NEXT_QUIET_TIMER, tsfLow >> 10);
-			REG_SET_BIT(ah, AR_TIMER_MODE,
-				       AR_QUIET_TIMER_EN);
-
-			if ((REG_READ(ah, AR_TSF_L32) >> 10) == (tsfLow >> 10))
-				break;
+	REG_CLR_BIT(ah, AR_PCU_MISC, AR_PCU_FORCE_QUIET_COLL | AR_PCU_CLEAR_VMF);
+	REG_CLR_BIT(ah, AR_DIAG_SW, AR_DIAG_FORCE_CH_IDLE_HIGH);
+	REG_CLR_BIT(ah, AR_D_GBL_IFS_MISC, AR_D_GBL_IFS_MISC_IGNORE_BACKOFF);
 
-			ath_dbg(common, ATH_DBG_QUEUE,
-				"TSF has moved while trying to set quiet time TSF: 0x%08x\n",
-				tsfLow);
-		}
+	REG_WRITE(ah, AR_Q_TXD, 0);
+}
+EXPORT_SYMBOL(ath9k_hw_abort_tx_dma);
 
-		REG_SET_BIT(ah, AR_DIAG_SW, AR_DIAG_FORCE_CH_IDLE_HIGH);
+bool ath9k_hw_stop_dma_queue(struct ath_hw *ah, u32 q)
+{
+#define ATH9K_TX_STOP_DMA_TIMEOUT	1000    /* usec */
+#define ATH9K_TIME_QUANTUM		100     /* usec */
+	int wait_time = ATH9K_TX_STOP_DMA_TIMEOUT / ATH9K_TIME_QUANTUM;
+	int wait;
 
-		udelay(200);
-		REG_CLR_BIT(ah, AR_TIMER_MODE, AR_QUIET_TIMER_EN);
+	REG_WRITE(ah, AR_Q_TXD, 1 << q);
 
-		wait = wait_time;
-		while (ath9k_hw_numtxpending(ah, q)) {
-			if ((--wait) == 0) {
-				ath_err(common,
-					"Failed to stop TX DMA in 100 msec after killing last frame\n");
-				break;
-			}
+	for (wait = wait_time; wait != 0; wait--) {
+		if (wait != wait_time)
 			udelay(ATH9K_TIME_QUANTUM);
-		}
 
-		REG_CLR_BIT(ah, AR_DIAG_SW, AR_DIAG_FORCE_CH_IDLE_HIGH);
+		if (ath9k_hw_numtxpending(ah, q) == 0)
+			break;
 	}
 
 	REG_WRITE(ah, AR_Q_TXD, 0);
+
 	return wait != 0;
 
 #undef ATH9K_TX_STOP_DMA_TIMEOUT
 #undef ATH9K_TIME_QUANTUM
 }
-EXPORT_SYMBOL(ath9k_hw_stoptxdma);
+EXPORT_SYMBOL(ath9k_hw_stop_dma_queue);
 
 void ath9k_hw_gettxintrtxqs(struct ath_hw *ah, u32 *txqs)
 {
diff --git a/drivers/net/wireless/ath/ath9k/mac.h b/drivers/net/wireless/ath/ath9k/mac.h
index 04d58ae..b2b2ff8 100644
--- a/drivers/net/wireless/ath/ath9k/mac.h
+++ b/drivers/net/wireless/ath/ath9k/mac.h
@@ -676,7 +676,8 @@ void ath9k_hw_txstart(struct ath_hw *ah, u32 q);
 void ath9k_hw_cleartxdesc(struct ath_hw *ah, void *ds);
 u32 ath9k_hw_numtxpending(struct ath_hw *ah, u32 q);
 bool ath9k_hw_updatetxtriglevel(struct ath_hw *ah, bool bIncTrigLevel);
-bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q);
+bool ath9k_hw_stop_dma_queue(struct ath_hw *ah, u32 q);
+void ath9k_hw_abort_tx_dma(struct ath_hw *ah);
 void ath9k_hw_gettxintrtxqs(struct ath_hw *ah, u32 *txqs);
 bool ath9k_hw_set_txq_props(struct ath_hw *ah, int q,
 			    const struct ath9k_tx_queue_info *qinfo);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 2e228aa..115f162 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2128,56 +2128,42 @@ static void ath9k_set_coverage_class(struct ieee80211_hw *hw, u8 coverage_class)
 
 static void ath9k_flush(struct ieee80211_hw *hw, bool drop)
 {
-#define ATH_FLUSH_TIMEOUT	60 /* ms */
 	struct ath_softc *sc = hw->priv;
-	struct ath_txq *txq = NULL;
-	struct ath_hw *ah = sc->sc_ah;
-	struct ath_common *common = ath9k_hw_common(ah);
-	int i, j, npend = 0;
+	int timeout = 200; /* ms */
+	int i, j;
 
+	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
 
 	cancel_delayed_work_sync(&sc->tx_complete_work);
 
-	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (!ATH_TXQ_SETUP(sc, i))
-			continue;
-		txq = &sc->tx.txq[i];
+	if (drop)
+		timeout = 1;
 
-		if (!drop) {
-			for (j = 0; j < ATH_FLUSH_TIMEOUT; j++) {
-				if (!ath9k_has_pending_frames(sc, txq))
-					break;
-				usleep_range(1000, 2000);
-			}
-		}
+	for (j = 0; j < timeout; j++) {
+		int npend = 0;
+
+		if (j)
+			usleep_range(1000, 2000);
 
-		if (drop || ath9k_has_pending_frames(sc, txq)) {
-			ath_dbg(common, ATH_DBG_QUEUE, "Drop frames from hw queue:%d\n",
-				txq->axq_qnum);
-			spin_lock_bh(&txq->axq_lock);
-			txq->txq_flush_inprogress = true;
-			spin_unlock_bh(&txq->axq_lock);
-
-			ath9k_ps_wakeup(sc);
-			ath9k_hw_stoptxdma(ah, txq->axq_qnum);
-			npend = ath9k_hw_numtxpending(ah, txq->axq_qnum);
-			ath9k_ps_restore(sc);
-			if (npend)
-				break;
-
-			ath_draintxq(sc, txq, false);
-			txq->txq_flush_inprogress = false;
+		for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
+			if (!ATH_TXQ_SETUP(sc, i))
+				continue;
+
+			npend += ath9k_has_pending_frames(sc, &sc->tx.txq[i]);
 		}
+
+		if (!npend)
+		    goto out;
 	}
 
-	if (npend) {
+	if (!ath_drain_all_txq(sc, false))
 		ath_reset(sc, false);
-		txq->txq_flush_inprogress = false;
-	}
 
+out:
 	ieee80211_queue_delayed_work(hw, &sc->tx_complete_work, 0);
 	mutex_unlock(&sc->mutex);
+	ath9k_ps_restore(sc);
 }
 
 struct ieee80211_ops ath9k_ops = {
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index cb559e3..a9c3f46 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -413,9 +413,7 @@ u32 ath_calcrxfilter(struct ath_softc *sc)
 	 * mode interface or when in monitor mode. AP mode does not need this
 	 * since it receives all in-BSS frames anyway.
 	 */
-	if (((sc->sc_ah->opmode != NL80211_IFTYPE_AP) &&
-	     (sc->rx.rxfilter & FIF_PROMISC_IN_BSS)) ||
-	    (sc->sc_ah->is_monitoring))
+	if (sc->sc_ah->is_monitoring)
 		rfilt |= ATH9K_RX_FILTER_PROM;
 
 	if (sc->rx.rxfilter & FIF_CONTROL)
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index e16136d..ef22096 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -166,7 +166,7 @@ static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 		fi = get_frame_info(bf->bf_mpdu);
 		if (fi->retries) {
 			ath_tx_update_baw(sc, tid, fi->seqno);
-			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0, 0);
+			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0, 1);
 		} else {
 			ath_tx_send_normal(sc, txq, NULL, &bf_head);
 		}
@@ -1194,16 +1194,14 @@ bool ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 	if (sc->sc_flags & SC_OP_INVALID)
 		return true;
 
-	/* Stop beacon queue */
-	ath9k_hw_stoptxdma(sc->sc_ah, sc->beacon.beaconq);
+	ath9k_hw_abort_tx_dma(ah);
 
-	/* Stop data queues */
+	/* Check if any queue remains active */
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (ATH_TXQ_SETUP(sc, i)) {
-			txq = &sc->tx.txq[i];
-			ath9k_hw_stoptxdma(ah, txq->axq_qnum);
-			npend += ath9k_hw_numtxpending(ah, txq->axq_qnum);
-		}
+		if (!ATH_TXQ_SETUP(sc, i))
+			continue;
+
+		npend += ath9k_hw_numtxpending(ah, sc->tx.txq[i].axq_qnum);
 	}
 
 	if (npend)
@@ -2014,8 +2012,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 		spin_lock_bh(&txq->axq_lock);
 		if (list_empty(&txq->axq_q)) {
 			txq->axq_link = NULL;
-			if (sc->sc_flags & SC_OP_TXAGGR &&
-			    !txq->txq_flush_inprogress)
+			if (sc->sc_flags & SC_OP_TXAGGR)
 				ath_txq_schedule(sc, txq);
 			spin_unlock_bh(&txq->axq_lock);
 			break;
@@ -2096,7 +2093,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 
 		spin_lock_bh(&txq->axq_lock);
 
-		if (sc->sc_flags & SC_OP_TXAGGR && !txq->txq_flush_inprogress)
+		if (sc->sc_flags & SC_OP_TXAGGR)
 			ath_txq_schedule(sc, txq);
 		spin_unlock_bh(&txq->axq_lock);
 	}
@@ -2267,18 +2264,17 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 
 		spin_lock_bh(&txq->axq_lock);
 
-		if (!txq->txq_flush_inprogress) {
-			if (!list_empty(&txq->txq_fifo_pending)) {
-				INIT_LIST_HEAD(&bf_head);
-				bf = list_first_entry(&txq->txq_fifo_pending,
-						      struct ath_buf, list);
-				list_cut_position(&bf_head,
-						  &txq->txq_fifo_pending,
-						  &bf->bf_lastbf->list);
-				ath_tx_txqaddbuf(sc, txq, &bf_head);
-			} else if (sc->sc_flags & SC_OP_TXAGGR)
-				ath_txq_schedule(sc, txq);
-		}
+		if (!list_empty(&txq->txq_fifo_pending)) {
+			INIT_LIST_HEAD(&bf_head);
+			bf = list_first_entry(&txq->txq_fifo_pending,
+					      struct ath_buf, list);
+			list_cut_position(&bf_head,
+					  &txq->txq_fifo_pending,
+					  &bf->bf_lastbf->list);
+			ath_tx_txqaddbuf(sc, txq, &bf_head);
+		} else if (sc->sc_flags & SC_OP_TXAGGR)
+			ath_txq_schedule(sc, txq);
+
 		spin_unlock_bh(&txq->axq_lock);
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 25fccf9..2003c1d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1115,6 +1115,18 @@ static int iwl_get_channels_for_scan(struct iwl_priv *priv,
 	return added;
 }
 
+static int iwl_fill_offch_tx(struct iwl_priv *priv, void *data, size_t maxlen)
+{
+	struct sk_buff *skb = priv->_agn.offchan_tx_skb;
+
+	if (skb->len < maxlen)
+		maxlen = skb->len;
+
+	memcpy(data, skb->data, maxlen);
+
+	return maxlen;
+}
+
 int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 {
 	struct iwl_host_cmd cmd = {
@@ -1157,17 +1169,25 @@ int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	scan->quiet_plcp_th = IWL_PLCP_QUIET_THRESH;
 	scan->quiet_time = IWL_ACTIVE_QUIET_TIME;
 
-	if (iwl_is_any_associated(priv)) {
+	if (priv->scan_type != IWL_SCAN_OFFCH_TX &&
+	    iwl_is_any_associated(priv)) {
 		u16 interval = 0;
 		u32 extra;
 		u32 suspend_time = 100;
 		u32 scan_suspend_time = 100;
 
 		IWL_DEBUG_INFO(priv, "Scanning while associated...\n");
-		if (priv->is_internal_short_scan)
+		switch (priv->scan_type) {
+		case IWL_SCAN_OFFCH_TX:
+			WARN_ON(1);
+			break;
+		case IWL_SCAN_RADIO_RESET:
 			interval = 0;
-		else
+			break;
+		case IWL_SCAN_NORMAL:
 			interval = vif->bss_conf.beacon_int;
+			break;
+		}
 
 		scan->suspend_time = 0;
 		scan->max_out_time = cpu_to_le32(200 * 1024);
@@ -1180,29 +1200,41 @@ int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 		scan->suspend_time = cpu_to_le32(scan_suspend_time);
 		IWL_DEBUG_SCAN(priv, "suspend_time 0x%X beacon interval %d\n",
 			       scan_suspend_time, interval);
+	} else if (priv->scan_type == IWL_SCAN_OFFCH_TX) {
+		scan->suspend_time = 0;
+		scan->max_out_time =
+			cpu_to_le32(1024 * priv->_agn.offchan_tx_timeout);
 	}
 
-	if (priv->is_internal_short_scan) {
+	switch (priv->scan_type) {
+	case IWL_SCAN_RADIO_RESET:
 		IWL_DEBUG_SCAN(priv, "Start internal passive scan.\n");
-	} else if (priv->scan_request->n_ssids) {
-		int i, p = 0;
-		IWL_DEBUG_SCAN(priv, "Kicking off active scan\n");
-		for (i = 0; i < priv->scan_request->n_ssids; i++) {
-			/* always does wildcard anyway */
-			if (!priv->scan_request->ssids[i].ssid_len)
-				continue;
-			scan->direct_scan[p].id = WLAN_EID_SSID;
-			scan->direct_scan[p].len =
-				priv->scan_request->ssids[i].ssid_len;
-			memcpy(scan->direct_scan[p].ssid,
-			       priv->scan_request->ssids[i].ssid,
-			       priv->scan_request->ssids[i].ssid_len);
-			n_probes++;
-			p++;
-		}
-		is_active = true;
-	} else
-		IWL_DEBUG_SCAN(priv, "Start passive scan.\n");
+		break;
+	case IWL_SCAN_NORMAL:
+		if (priv->scan_request->n_ssids) {
+			int i, p = 0;
+			IWL_DEBUG_SCAN(priv, "Kicking off active scan\n");
+			for (i = 0; i < priv->scan_request->n_ssids; i++) {
+				/* always does wildcard anyway */
+				if (!priv->scan_request->ssids[i].ssid_len)
+					continue;
+				scan->direct_scan[p].id = WLAN_EID_SSID;
+				scan->direct_scan[p].len =
+					priv->scan_request->ssids[i].ssid_len;
+				memcpy(scan->direct_scan[p].ssid,
+				       priv->scan_request->ssids[i].ssid,
+				       priv->scan_request->ssids[i].ssid_len);
+				n_probes++;
+				p++;
+			}
+			is_active = true;
+		} else
+			IWL_DEBUG_SCAN(priv, "Start passive scan.\n");
+		break;
+	case IWL_SCAN_OFFCH_TX:
+		IWL_DEBUG_SCAN(priv, "Start offchannel TX scan.\n");
+		break;
+	}
 
 	scan->tx_cmd.tx_flags = TX_CMD_FLG_SEQ_CTL_MSK;
 	scan->tx_cmd.sta_id = ctx->bcast_sta_id;
@@ -1300,38 +1332,77 @@ int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	rx_chain |= rx_ant << RXON_RX_CHAIN_FORCE_SEL_POS;
 	rx_chain |= 0x1 << RXON_RX_CHAIN_DRIVER_FORCE_POS;
 	scan->rx_chain = cpu_to_le16(rx_chain);
-	if (!priv->is_internal_short_scan) {
+	switch (priv->scan_type) {
+	case IWL_SCAN_NORMAL:
 		cmd_len = iwl_fill_probe_req(priv,
 					(struct ieee80211_mgmt *)scan->data,
 					vif->addr,
 					priv->scan_request->ie,
 					priv->scan_request->ie_len,
 					IWL_MAX_SCAN_SIZE - sizeof(*scan));
-	} else {
+		break;
+	case IWL_SCAN_RADIO_RESET:
 		/* use bcast addr, will not be transmitted but must be valid */
 		cmd_len = iwl_fill_probe_req(priv,
 					(struct ieee80211_mgmt *)scan->data,
 					iwl_bcast_addr, NULL, 0,
 					IWL_MAX_SCAN_SIZE - sizeof(*scan));
-
+		break;
+	case IWL_SCAN_OFFCH_TX:
+		cmd_len = iwl_fill_offch_tx(priv, scan->data,
+					    IWL_MAX_SCAN_SIZE
+					     - sizeof(*scan)
+					     - sizeof(struct iwl_scan_channel));
+		scan->scan_flags |= IWL_SCAN_FLAGS_ACTION_FRAME_TX;
+		break;
+	default:
+		BUG();
 	}
 	scan->tx_cmd.len = cpu_to_le16(cmd_len);
 
 	scan->filter_flags |= (RXON_FILTER_ACCEPT_GRP_MSK |
 			       RXON_FILTER_BCON_AWARE_MSK);
 
-	if (priv->is_internal_short_scan) {
+	switch (priv->scan_type) {
+	case IWL_SCAN_RADIO_RESET:
 		scan->channel_count =
 			iwl_get_single_channel_for_scan(priv, vif, band,
-				(void *)&scan->data[le16_to_cpu(
-				scan->tx_cmd.len)]);
-	} else {
+				(void *)&scan->data[cmd_len]);
+		break;
+	case IWL_SCAN_NORMAL:
 		scan->channel_count =
 			iwl_get_channels_for_scan(priv, vif, band,
 				is_active, n_probes,
-				(void *)&scan->data[le16_to_cpu(
-				scan->tx_cmd.len)]);
+				(void *)&scan->data[cmd_len]);
+		break;
+	case IWL_SCAN_OFFCH_TX: {
+		struct iwl_scan_channel *scan_ch;
+
+		scan->channel_count = 1;
+
+		scan_ch = (void *)&scan->data[cmd_len];
+		scan_ch->type = SCAN_CHANNEL_TYPE_ACTIVE;
+		scan_ch->channel =
+			cpu_to_le16(priv->_agn.offchan_tx_chan->hw_value);
+		scan_ch->active_dwell =
+			cpu_to_le16(priv->_agn.offchan_tx_timeout);
+		scan_ch->passive_dwell = 0;
+
+		/* Set txpower levels to defaults */
+		scan_ch->dsp_atten = 110;
+
+		/* NOTE: if we were doing 6Mb OFDM for scans we'd use
+		 * power level:
+		 * scan_ch->tx_gain = ((1 << 5) | (2 << 3)) | 3;
+		 */
+		if (priv->_agn.offchan_tx_chan->band == IEEE80211_BAND_5GHZ)
+			scan_ch->tx_gain = ((1 << 5) | (3 << 3)) | 3;
+		else
+			scan_ch->tx_gain = ((1 << 5) | (5 << 3));
+		}
+		break;
 	}
+
 	if (scan->channel_count == 0) {
 		IWL_DEBUG_SCAN(priv, "channel count %d\n", scan->channel_count);
 		return -EIO;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index e0cd3e2..581dc9f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2937,6 +2937,91 @@ static void iwl_bg_rx_replenish(struct work_struct *data)
 	mutex_unlock(&priv->mutex);
 }
 
+static int iwl_mac_offchannel_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
+				 struct ieee80211_channel *chan,
+				 enum nl80211_channel_type channel_type,
+				 unsigned int wait)
+{
+	struct iwl_priv *priv = hw->priv;
+	int ret;
+
+	/* Not supported if we don't have PAN */
+	if (!(priv->valid_contexts & BIT(IWL_RXON_CTX_PAN))) {
+		ret = -EOPNOTSUPP;
+		goto free;
+	}
+
+	/* Not supported on pre-P2P firmware */
+	if (!(priv->contexts[IWL_RXON_CTX_PAN].interface_modes &
+					BIT(NL80211_IFTYPE_P2P_CLIENT))) {
+		ret = -EOPNOTSUPP;
+		goto free;
+	}
+
+	mutex_lock(&priv->mutex);
+
+	if (!priv->contexts[IWL_RXON_CTX_PAN].is_active) {
+		/*
+		 * If the PAN context is free, use the normal
+		 * way of doing remain-on-channel offload + TX.
+		 */
+		ret = 1;
+		goto out;
+	}
+
+	/* TODO: queue up if scanning? */
+	if (test_bit(STATUS_SCANNING, &priv->status) ||
+	    priv->_agn.offchan_tx_skb) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	/*
+	 * max_scan_ie_len doesn't include the blank SSID or the header,
+	 * so need to add that again here.
+	 */
+	if (skb->len > hw->wiphy->max_scan_ie_len + 24 + 2) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	priv->_agn.offchan_tx_skb = skb;
+	priv->_agn.offchan_tx_timeout = wait;
+	priv->_agn.offchan_tx_chan = chan;
+
+	ret = iwl_scan_initiate(priv, priv->contexts[IWL_RXON_CTX_PAN].vif,
+				IWL_SCAN_OFFCH_TX, chan->band);
+	if (ret)
+		priv->_agn.offchan_tx_skb = NULL;
+ out:
+	mutex_unlock(&priv->mutex);
+ free:
+	if (ret < 0)
+		kfree_skb(skb);
+
+	return ret;
+}
+
+static int iwl_mac_offchannel_tx_cancel_wait(struct ieee80211_hw *hw)
+{
+	struct iwl_priv *priv = hw->priv;
+	int ret;
+
+	mutex_lock(&priv->mutex);
+
+	if (!priv->_agn.offchan_tx_skb)
+		return -EINVAL;
+
+	priv->_agn.offchan_tx_skb = NULL;
+
+	ret = iwl_scan_cancel_timeout(priv, 200);
+	if (ret)
+		ret = -EIO;
+	mutex_unlock(&priv->mutex);
+
+	return ret;
+}
+
 /*****************************************************************************
  *
  * mac80211 entry point functions
@@ -3815,6 +3900,8 @@ struct ieee80211_ops iwlagn_hw_ops = {
 	.tx_last_beacon = iwl_mac_tx_last_beacon,
 	.remain_on_channel = iwl_mac_remain_on_channel,
 	.cancel_remain_on_channel = iwl_mac_cancel_remain_on_channel,
+	.offchannel_tx = iwl_mac_offchannel_tx,
+	.offchannel_tx_cancel_wait = iwl_mac_offchannel_tx_cancel_wait,
 };
 
 static void iwl_hw_detect(struct iwl_priv *priv)
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index 03cfb74..ca42ffa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -2964,9 +2964,15 @@ struct iwl3945_scan_cmd {
 	u8 data[0];
 } __packed;
 
+enum iwl_scan_flags {
+	/* BIT(0) currently unused */
+	IWL_SCAN_FLAGS_ACTION_FRAME_TX	= BIT(1),
+	/* bits 2-7 reserved */
+};
+
 struct iwl_scan_cmd {
 	__le16 len;
-	u8 reserved0;
+	u8 scan_flags;		/* scan flags: see enum iwl_scan_flags */
 	u8 channel_count;	/* # channels in channel list */
 	__le16 quiet_time;	/* dwell only this # millisecs on quiet channel
 				 * (only for active scan) */
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index af47750..b316d83 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -63,6 +63,8 @@
 #ifndef __iwl_core_h__
 #define __iwl_core_h__
 
+#include "iwl-dev.h"
+
 /************************
  * forward declarations *
  ************************/
@@ -551,6 +553,10 @@ u16 iwl_get_passive_dwell_time(struct iwl_priv *priv,
 			       struct ieee80211_vif *vif);
 void iwl_setup_scan_deferred_work(struct iwl_priv *priv);
 void iwl_cancel_scan_deferred_work(struct iwl_priv *priv);
+int __must_check iwl_scan_initiate(struct iwl_priv *priv,
+				   struct ieee80211_vif *vif,
+				   enum iwl_scan_type scan_type,
+				   enum ieee80211_band band);
 
 /* For faster active scanning, scan will move to the next channel if fewer than
  * PLCP_QUIET_THRESH packets are heard on this channel within
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 6a41deb..68b953f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1230,6 +1230,12 @@ struct iwl_rxon_context {
 	} ht;
 };
 
+enum iwl_scan_type {
+	IWL_SCAN_NORMAL,
+	IWL_SCAN_RADIO_RESET,
+	IWL_SCAN_OFFCH_TX,
+};
+
 struct iwl_priv {
 
 	/* ieee device used by generic ieee processing code */
@@ -1290,7 +1296,7 @@ struct iwl_priv {
 	enum ieee80211_band scan_band;
 	struct cfg80211_scan_request *scan_request;
 	struct ieee80211_vif *scan_vif;
-	bool is_internal_short_scan;
+	enum iwl_scan_type scan_type;
 	u8 scan_tx_ant[IEEE80211_NUM_BANDS];
 	u8 mgmt_tx_ant;
 
@@ -1504,6 +1510,10 @@ struct iwl_priv {
 			struct delayed_work hw_roc_work;
 			enum nl80211_channel_type hw_roc_chantype;
 			int hw_roc_duration;
+
+			struct sk_buff *offchan_tx_skb;
+			int offchan_tx_timeout;
+			struct ieee80211_channel *offchan_tx_chan;
 		} _agn;
 #endif
 	};
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index faa6d34..3a4d9e6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -101,7 +101,7 @@ static void iwl_complete_scan(struct iwl_priv *priv, bool aborted)
 		ieee80211_scan_completed(priv->hw, aborted);
 	}
 
-	priv->is_internal_short_scan = false;
+	priv->scan_type = IWL_SCAN_NORMAL;
 	priv->scan_vif = NULL;
 	priv->scan_request = NULL;
 }
@@ -339,10 +339,10 @@ void iwl_init_scan_params(struct iwl_priv *priv)
 		priv->scan_tx_ant[IEEE80211_BAND_2GHZ] = ant_idx;
 }
 
-static int __must_check iwl_scan_initiate(struct iwl_priv *priv,
-					  struct ieee80211_vif *vif,
-					  bool internal,
-					  enum ieee80211_band band)
+int __must_check iwl_scan_initiate(struct iwl_priv *priv,
+				   struct ieee80211_vif *vif,
+				   enum iwl_scan_type scan_type,
+				   enum ieee80211_band band)
 {
 	int ret;
 
@@ -370,17 +370,19 @@ static int __must_check iwl_scan_initiate(struct iwl_priv *priv,
 	}
 
 	IWL_DEBUG_SCAN(priv, "Starting %sscan...\n",
-			internal ? "internal short " : "");
+			scan_type == IWL_SCAN_NORMAL ? "" :
+			scan_type == IWL_SCAN_OFFCH_TX ? "offchan TX " :
+			"internal short ");
 
 	set_bit(STATUS_SCANNING, &priv->status);
-	priv->is_internal_short_scan = internal;
+	priv->scan_type = scan_type;
 	priv->scan_start = jiffies;
 	priv->scan_band = band;
 
 	ret = priv->cfg->ops->utils->request_scan(priv, vif);
 	if (ret) {
 		clear_bit(STATUS_SCANNING, &priv->status);
-		priv->is_internal_short_scan = false;
+		priv->scan_type = IWL_SCAN_NORMAL;
 		return ret;
 	}
 
@@ -405,7 +407,7 @@ int iwl_mac_hw_scan(struct ieee80211_hw *hw,
 	mutex_lock(&priv->mutex);
 
 	if (test_bit(STATUS_SCANNING, &priv->status) &&
-	    !priv->is_internal_short_scan) {
+	    priv->scan_type != IWL_SCAN_NORMAL) {
 		IWL_DEBUG_SCAN(priv, "Scan already in progress.\n");
 		ret = -EAGAIN;
 		goto out_unlock;
@@ -419,11 +421,11 @@ int iwl_mac_hw_scan(struct ieee80211_hw *hw,
 	 * If an internal scan is in progress, just set
 	 * up the scan_request as per above.
 	 */
-	if (priv->is_internal_short_scan) {
+	if (priv->scan_type != IWL_SCAN_NORMAL) {
 		IWL_DEBUG_SCAN(priv, "SCAN request during internal scan\n");
 		ret = 0;
 	} else
-		ret = iwl_scan_initiate(priv, vif, false,
+		ret = iwl_scan_initiate(priv, vif, IWL_SCAN_NORMAL,
 					req->channels[0]->band);
 
 	IWL_DEBUG_MAC80211(priv, "leave\n");
@@ -452,7 +454,7 @@ static void iwl_bg_start_internal_scan(struct work_struct *work)
 
 	mutex_lock(&priv->mutex);
 
-	if (priv->is_internal_short_scan == true) {
+	if (priv->scan_type == IWL_SCAN_RADIO_RESET) {
 		IWL_DEBUG_SCAN(priv, "Internal scan already in progress\n");
 		goto unlock;
 	}
@@ -462,7 +464,7 @@ static void iwl_bg_start_internal_scan(struct work_struct *work)
 		goto unlock;
 	}
 
-	if (iwl_scan_initiate(priv, NULL, true, priv->band))
+	if (iwl_scan_initiate(priv, NULL, IWL_SCAN_RADIO_RESET, priv->band))
 		IWL_DEBUG_SCAN(priv, "failed to start internal short scan\n");
  unlock:
 	mutex_unlock(&priv->mutex);
@@ -549,8 +551,7 @@ static void iwl_bg_scan_completed(struct work_struct *work)
 	    container_of(work, struct iwl_priv, scan_completed);
 	bool aborted;
 
-	IWL_DEBUG_SCAN(priv, "Completed %sscan.\n",
-		       priv->is_internal_short_scan ? "internal short " : "");
+	IWL_DEBUG_SCAN(priv, "Completed scan.\n");
 
 	cancel_delayed_work(&priv->scan_check);
 
@@ -565,7 +566,13 @@ static void iwl_bg_scan_completed(struct work_struct *work)
 		goto out_settings;
 	}
 
-	if (priv->is_internal_short_scan && !aborted) {
+	if (priv->scan_type == IWL_SCAN_OFFCH_TX && priv->_agn.offchan_tx_skb) {
+		ieee80211_tx_status_irqsafe(priv->hw,
+					    priv->_agn.offchan_tx_skb);
+		priv->_agn.offchan_tx_skb = NULL;
+	}
+
+	if (priv->scan_type != IWL_SCAN_NORMAL && !aborted) {
 		int err;
 
 		/* Check if mac80211 requested scan during our internal scan */
@@ -573,7 +580,7 @@ static void iwl_bg_scan_completed(struct work_struct *work)
 			goto out_complete;
 
 		/* If so request a new scan */
-		err = iwl_scan_initiate(priv, priv->scan_vif, false,
+		err = iwl_scan_initiate(priv, priv->scan_vif, IWL_SCAN_NORMAL,
 					priv->scan_request->channels[0]->band);
 		if (err) {
 			IWL_DEBUG_SCAN(priv,
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index acf3bf6..9d097b9 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -918,7 +918,6 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
 			   char *buf)
 {
 	struct mrvl_mesh_defaults defs;
-	int maxlen;
 	int ret;
 
 	ret = mesh_get_default_parameters(dev, &defs);
@@ -931,13 +930,11 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
 		defs.meshie.val.mesh_id_len = IEEE80211_MAX_SSID_LEN;
 	}
 
-	/* SSID not null terminated: reserve room for \0 + \n */
-	maxlen = defs.meshie.val.mesh_id_len + 2;
-	maxlen = (PAGE_SIZE > maxlen) ? maxlen : PAGE_SIZE;
+	memcpy(buf, defs.meshie.val.mesh_id, defs.meshie.val.mesh_id_len);
+	buf[defs.meshie.val.mesh_id_len] = '\n';
+	buf[defs.meshie.val.mesh_id_len + 1] = '\0';
 
-	defs.meshie.val.mesh_id[defs.meshie.val.mesh_id_len] = '\0';
-
-	return snprintf(buf, maxlen, "%s\n", defs.meshie.val.mesh_id);
+	return defs.meshie.val.mesh_id_len + 1;
 }
 
 /**
diff --git a/drivers/net/wireless/wl1251/ps.c b/drivers/net/wireless/wl1251/ps.c
index 9ba23ed..9cc5147 100644
--- a/drivers/net/wireless/wl1251/ps.c
+++ b/drivers/net/wireless/wl1251/ps.c
@@ -58,7 +58,6 @@ void wl1251_ps_elp_sleep(struct wl1251 *wl)
 	unsigned long delay;
 
 	if (wl->psm) {
-		cancel_delayed_work(&wl->elp_work);
 		delay = msecs_to_jiffies(ELP_ENTRY_DELAY);
 		ieee80211_queue_delayed_work(wl->hw, &wl->elp_work, delay);
 	}
@@ -69,6 +68,9 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	unsigned long timeout, start;
 	u32 elp_reg;
 
+	if (delayed_work_pending(&wl->elp_work))
+		cancel_delayed_work(&wl->elp_work);
+
 	if (!wl->elp)
 		return 0;
 
@@ -102,38 +104,6 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	return 0;
 }
 
-static int wl1251_ps_set_elp(struct wl1251 *wl, bool enable)
-{
-	int ret;
-
-	if (enable) {
-		wl1251_debug(DEBUG_PSM, "sleep auth psm/elp");
-
-		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_ELP);
-		if (ret < 0)
-			return ret;
-
-		wl1251_ps_elp_sleep(wl);
-	} else {
-		wl1251_debug(DEBUG_PSM, "sleep auth cam");
-
-		/*
-		 * When the target is in ELP, we can only
-		 * access the ELP control register. Thus,
-		 * we have to wake the target up before
-		 * changing the power authorization.
-		 */
-
-		wl1251_ps_elp_wakeup(wl);
-
-		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_CAM);
-		if (ret < 0)
-			return ret;
-	}
-
-	return 0;
-}
-
 int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_cmd_ps_mode mode)
 {
 	int ret;
@@ -162,7 +132,7 @@ int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_cmd_ps_mode mode)
 		if (ret < 0)
 			return ret;
 
-		ret = wl1251_ps_set_elp(wl, true);
+		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_ELP);
 		if (ret < 0)
 			return ret;
 
@@ -171,7 +141,8 @@ int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_cmd_ps_mode mode)
 	case STATION_ACTIVE_MODE:
 	default:
 		wl1251_debug(DEBUG_PSM, "leaving psm");
-		ret = wl1251_ps_set_elp(wl, false);
+
+		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_CAM);
 		if (ret < 0)
 			return ret;
 
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 1ac5786..60f7876 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1197,6 +1197,10 @@ struct cfg80211_pmksa {
  *	(also see nl80211.h @NL80211_ATTR_WIPHY_ANTENNA_TX).
  *
  * @get_antenna: Get current antenna configuration from device (tx_ant, rx_ant).
+ *
+ * @set_ringparam: Set tx and rx ring sizes.
+ *
+ * @get_ringparam: Get tx and rx ring current and maximum sizes.
  */
 struct cfg80211_ops {
 	int	(*suspend)(struct wiphy *wiphy);
@@ -1364,6 +1368,10 @@ struct cfg80211_ops {
 
 	int	(*set_antenna)(struct wiphy *wiphy, u32 tx_ant, u32 rx_ant);
 	int	(*get_antenna)(struct wiphy *wiphy, u32 *tx_ant, u32 *rx_ant);
+
+	int	(*set_ringparam)(struct wiphy *wiphy, u32 tx, u32 rx);
+	void	(*get_ringparam)(struct wiphy *wiphy,
+				 u32 *tx, u32 *tx_max, u32 *rx, u32 *rx_max);
 };
 
 /*
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 2b072fa..8650e7b 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1804,6 +1804,10 @@ enum ieee80211_ampdu_mlme_action {
  *	return value is 1, then the @remain_on_channel will be used with a
  *	regular transmission (if supported.)
  * @offchannel_tx_cancel_wait: cancel wait associated with offchannel TX
+ *
+ * @set_ringparam: Set tx and rx ring sizes.
+ *
+ * @get_ringparam: Get tx and rx ring current and maximum sizes.
  */
 struct ieee80211_ops {
 	void (*tx)(struct ieee80211_hw *hw, struct sk_buff *skb);
@@ -1888,6 +1892,9 @@ struct ieee80211_ops {
 			     enum nl80211_channel_type channel_type,
 			     unsigned int wait);
 	int (*offchannel_tx_cancel_wait)(struct ieee80211_hw *hw);
+	int (*set_ringparam)(struct ieee80211_hw *hw, u32 tx, u32 rx);
+	void (*get_ringparam)(struct ieee80211_hw *hw,
+			      u32 *tx, u32 *tx_max, u32 *rx, u32 *rx_max);
 };
 
 /**
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 7b701dc..3342135 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -834,6 +834,10 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 
 	rcu_read_unlock();
 
+	if (sdata->vif.type == NL80211_IFTYPE_STATION &&
+	    params->sta_flags_mask & BIT(NL80211_STA_FLAG_AUTHORIZED))
+		ieee80211_recalc_ps(local, -1);
+
 	return 0;
 }
 
@@ -2008,6 +2012,21 @@ static int ieee80211_get_antenna(struct wiphy *wiphy, u32 *tx_ant, u32 *rx_ant)
 	return drv_get_antenna(local, tx_ant, rx_ant);
 }
 
+static int ieee80211_set_ringparam(struct wiphy *wiphy, u32 tx, u32 rx)
+{
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+
+	return drv_set_ringparam(local, tx, rx);
+}
+
+static void ieee80211_get_ringparam(struct wiphy *wiphy,
+				    u32 *tx, u32 *tx_max, u32 *rx, u32 *rx_max)
+{
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+
+	drv_get_ringparam(local, tx, tx_max, rx, rx_max);
+}
+
 struct cfg80211_ops mac80211_config_ops = {
 	.add_virtual_intf = ieee80211_add_iface,
 	.del_virtual_intf = ieee80211_del_iface,
@@ -2065,4 +2084,6 @@ struct cfg80211_ops mac80211_config_ops = {
 	.mgmt_frame_register = ieee80211_mgmt_frame_register,
 	.set_antenna = ieee80211_set_antenna,
 	.get_antenna = ieee80211_get_antenna,
+	.set_ringparam = ieee80211_set_ringparam,
+	.get_ringparam = ieee80211_get_ringparam,
 };
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index 5b24740..889c3e9 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -77,6 +77,9 @@ bool ieee80211_set_channel_type(struct ieee80211_local *local,
 		switch (tmp->vif.bss_conf.channel_type) {
 		case NL80211_CHAN_NO_HT:
 		case NL80211_CHAN_HT20:
+			if (superchan > tmp->vif.bss_conf.channel_type)
+				break;
+
 			superchan = tmp->vif.bss_conf.channel_type;
 			break;
 		case NL80211_CHAN_HT40PLUS:
diff --git a/net/mac80211/driver-ops.h b/net/mac80211/driver-ops.h
index 3729296..9c0d62b 100644
--- a/net/mac80211/driver-ops.h
+++ b/net/mac80211/driver-ops.h
@@ -526,4 +526,30 @@ static inline int drv_offchannel_tx_cancel_wait(struct ieee80211_local *local)
 	return ret;
 }
 
+static inline int drv_set_ringparam(struct ieee80211_local *local,
+				    u32 tx, u32 rx)
+{
+	int ret = -ENOTSUPP;
+
+	might_sleep();
+
+	trace_drv_set_ringparam(local, tx, rx);
+	if (local->ops->set_ringparam)
+		ret = local->ops->set_ringparam(&local->hw, tx, rx);
+	trace_drv_return_int(local, ret);
+
+	return ret;
+}
+
+static inline void drv_get_ringparam(struct ieee80211_local *local,
+				     u32 *tx, u32 *tx_max, u32 *rx, u32 *rx_max)
+{
+	might_sleep();
+
+	trace_drv_get_ringparam(local, tx, tx_max, rx, rx_max);
+	if (local->ops->get_ringparam)
+		local->ops->get_ringparam(&local->hw, tx, tx_max, rx, rx_max);
+	trace_drv_return_void(local);
+}
+
 #endif /* __MAC80211_DRIVER_OPS */
diff --git a/net/mac80211/driver-trace.h b/net/mac80211/driver-trace.h
index 520fe24..45aab80 100644
--- a/net/mac80211/driver-trace.h
+++ b/net/mac80211/driver-trace.h
@@ -912,6 +912,58 @@ TRACE_EVENT(drv_offchannel_tx,
 	)
 );
 
+TRACE_EVENT(drv_set_ringparam,
+	TP_PROTO(struct ieee80211_local *local, u32 tx, u32 rx),
+
+	TP_ARGS(local, tx, rx),
+
+	TP_STRUCT__entry(
+		LOCAL_ENTRY
+		__field(u32, tx)
+		__field(u32, rx)
+	),
+
+	TP_fast_assign(
+		LOCAL_ASSIGN;
+		__entry->tx = tx;
+		__entry->rx = rx;
+	),
+
+	TP_printk(
+		LOCAL_PR_FMT " tx:%d rx %d",
+		LOCAL_PR_ARG, __entry->tx, __entry->rx
+	)
+);
+
+TRACE_EVENT(drv_get_ringparam,
+	TP_PROTO(struct ieee80211_local *local, u32 *tx, u32 *tx_max,
+		 u32 *rx, u32 *rx_max),
+
+	TP_ARGS(local, tx, tx_max, rx, rx_max),
+
+	TP_STRUCT__entry(
+		LOCAL_ENTRY
+		__field(u32, tx)
+		__field(u32, tx_max)
+		__field(u32, rx)
+		__field(u32, rx_max)
+	),
+
+	TP_fast_assign(
+		LOCAL_ASSIGN;
+		__entry->tx = *tx;
+		__entry->tx_max = *tx_max;
+		__entry->rx = *rx;
+		__entry->rx_max = *rx_max;
+	),
+
+	TP_printk(
+		LOCAL_PR_FMT " tx:%d tx_max %d rx %d rx_max %d",
+		LOCAL_PR_ARG,
+		__entry->tx, __entry->tx_max, __entry->rx, __entry->rx_max
+	)
+);
+
 DEFINE_EVENT(local_only_evt, drv_offchannel_tx_cancel_wait,
 	TP_PROTO(struct ieee80211_local *local),
 	TP_ARGS(local)
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index cc984bd..64d92d5 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -613,6 +613,37 @@ static void ieee80211_change_ps(struct ieee80211_local *local)
 	}
 }
 
+static bool ieee80211_powersave_allowed(struct ieee80211_sub_if_data *sdata)
+{
+	struct ieee80211_if_managed *mgd = &sdata->u.mgd;
+	struct sta_info *sta = NULL;
+	u32 sta_flags = 0;
+
+	if (!mgd->powersave)
+		return false;
+
+	if (!mgd->associated)
+		return false;
+
+	if (!mgd->associated->beacon_ies)
+		return false;
+
+	if (mgd->flags & (IEEE80211_STA_BEACON_POLL |
+			  IEEE80211_STA_CONNECTION_POLL))
+		return false;
+
+	rcu_read_lock();
+	sta = sta_info_get(sdata, mgd->bssid);
+	if (sta)
+		sta_flags = get_sta_flags(sta);
+	rcu_read_unlock();
+
+	if (!(sta_flags & WLAN_STA_AUTHORIZED))
+		return false;
+
+	return true;
+}
+
 /* need to hold RTNL or interface lock */
 void ieee80211_recalc_ps(struct ieee80211_local *local, s32 latency)
 {
@@ -647,11 +678,7 @@ void ieee80211_recalc_ps(struct ieee80211_local *local, s32 latency)
 		count++;
 	}
 
-	if (count == 1 && found->u.mgd.powersave &&
-	    found->u.mgd.associated &&
-	    found->u.mgd.associated->beacon_ies &&
-	    !(found->u.mgd.flags & (IEEE80211_STA_BEACON_POLL |
-				    IEEE80211_STA_CONNECTION_POLL))) {
+	if (count == 1 && ieee80211_powersave_allowed(found)) {
 		struct ieee80211_conf *conf = &local->hw.conf;
 		s32 beaconint_us;
 
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index bce14fb..8212a8b 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -598,19 +598,46 @@ minstrel_ht_get_rate(void *priv, struct ieee80211_sta *sta, void *priv_sta,
 		sample = true;
 		minstrel_ht_set_rate(mp, mi, &ar[0], sample_idx,
 			txrc, true, false);
-		minstrel_ht_set_rate(mp, mi, &ar[1], mi->max_tp_rate,
-			txrc, false, false);
 		info->flags |= IEEE80211_TX_CTL_RATE_CTRL_PROBE;
 	} else {
 		minstrel_ht_set_rate(mp, mi, &ar[0], mi->max_tp_rate,
 			txrc, false, false);
-		minstrel_ht_set_rate(mp, mi, &ar[1], mi->max_tp_rate2,
-			txrc, false, true);
 	}
-	minstrel_ht_set_rate(mp, mi, &ar[2], mi->max_prob_rate, txrc, false, !sample);
 
-	ar[3].count = 0;
-	ar[3].idx = -1;
+	if (mp->hw->max_rates >= 3) {
+		/*
+		 * At least 3 tx rates supported, use
+		 * sample_rate -> max_tp_rate -> max_prob_rate for sampling and
+		 * max_tp_rate -> max_tp_rate2 -> max_prob_rate by default.
+		 */
+		if (sample_idx >= 0)
+			minstrel_ht_set_rate(mp, mi, &ar[1], mi->max_tp_rate,
+				txrc, false, false);
+		else
+			minstrel_ht_set_rate(mp, mi, &ar[1], mi->max_tp_rate2,
+				txrc, false, true);
+
+		minstrel_ht_set_rate(mp, mi, &ar[2], mi->max_prob_rate,
+				     txrc, false, !sample);
+
+		ar[3].count = 0;
+		ar[3].idx = -1;
+	} else if (mp->hw->max_rates == 2) {
+		/*
+		 * Only 2 tx rates supported, use
+		 * sample_rate -> max_prob_rate for sampling and
+		 * max_tp_rate -> max_prob_rate by default.
+		 */
+		minstrel_ht_set_rate(mp, mi, &ar[1], mi->max_prob_rate,
+				     txrc, false, !sample);
+
+		ar[2].count = 0;
+		ar[2].idx = -1;
+	} else {
+		/* Not using MRR, only use the first rate */
+		ar[1].count = 0;
+		ar[1].idx = -1;
+	}
 
 	mi->total_packets++;
 
diff --git a/net/wireless/ethtool.c b/net/wireless/ethtool.c
index ca4c825..9bde4d1 100644
--- a/net/wireless/ethtool.c
+++ b/net/wireless/ethtool.c
@@ -1,5 +1,6 @@
 #include <linux/utsname.h>
 #include <net/cfg80211.h>
+#include "core.h"
 #include "ethtool.h"
 
 static void cfg80211_get_drvinfo(struct net_device *dev,
@@ -37,9 +38,41 @@ static void cfg80211_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs->len = 0;
 }
 
+static void cfg80211_get_ringparam(struct net_device *dev,
+				   struct ethtool_ringparam *rp)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+
+	memset(rp, 0, sizeof(*rp));
+
+	if (rdev->ops->get_ringparam)
+		rdev->ops->get_ringparam(wdev->wiphy,
+					 &rp->tx_pending, &rp->tx_max_pending,
+					 &rp->rx_pending, &rp->rx_max_pending);
+}
+
+static int cfg80211_set_ringparam(struct net_device *dev,
+				  struct ethtool_ringparam *rp)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+
+	if (rp->rx_mini_pending != 0 || rp->rx_jumbo_pending != 0)
+		return -EINVAL;
+
+	if (rdev->ops->set_ringparam)
+		return rdev->ops->set_ringparam(wdev->wiphy,
+						rp->tx_pending, rp->rx_pending);
+
+	return -ENOTSUPP;
+}
+
 const struct ethtool_ops cfg80211_ethtool_ops = {
 	.get_drvinfo = cfg80211_get_drvinfo,
 	.get_regs_len = cfg80211_get_regs_len,
 	.get_regs = cfg80211_get_regs,
 	.get_link = ethtool_op_get_link,
+	.get_ringparam = cfg80211_get_ringparam,
+	.set_ringparam = cfg80211_set_ringparam,
 };
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
