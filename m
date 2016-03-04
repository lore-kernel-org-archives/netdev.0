From: Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
Subject: [PATCH RFC/RFT 1/2] ath9k: rename struct ath_txq to struct ath_hwq
Date: Thu, 03 Mar 2016 20:17:43 -0500
Message-ID: <E1abeND-0007xj-00@www.xplot.org>
Cc: michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, apenwarr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Also use hwq instead of txq to refer to it throughout ath9k/*.  This
is prep work for using mac80211's new intermediate queues, which are
called txq, and it would be too confusing if both are called txq.
---
 drivers/net/wireless/ath/ath9k/ath9k.h     |   50 +--
 drivers/net/wireless/ath/ath9k/beacon.c    |   10 +-
 drivers/net/wireless/ath/ath9k/debug.c     |   34 +-
 drivers/net/wireless/ath/ath9k/debug.h     |    8 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c |    8 +-
 drivers/net/wireless/ath/ath9k/gpio.c      |    6 +-
 drivers/net/wireless/ath/ath9k/init.c      |   18 +-
 drivers/net/wireless/ath/ath9k/link.c      |   18 +-
 drivers/net/wireless/ath/ath9k/main.c      |   42 +--
 drivers/net/wireless/ath/ath9k/xmit.c      |  512 ++++++++++++++--------------
 10 files changed, 353 insertions(+), 353 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 5294595..1118b3d 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -80,7 +80,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 /* RX / TX */
 /***********/
 
-#define	ATH_TXQ_SETUP(sc, i) ((sc)->tx.txqsetup & (1<<i))
+#define	ATH_HWQ_SETUP(sc, i) ((sc)->tx.hwqsetup & (1<<i))
 
 /* increment with wrap-around */
 #define INCR(_l, _sz)   do {			\
@@ -156,7 +156,7 @@ enum {
        WLAN_RC_PHY_CCK,
 };
 
-struct ath_txq {
+struct ath_hwq {
 	int mac80211_qnum; /* mac80211 queue number, -1 means not mac80211 Q */
 	u32 axq_qnum; /* ath9k hardware queue number */
 	void *axq_link;
@@ -166,9 +166,9 @@ struct ath_txq {
 	u32 axq_ampdu_depth;
 	bool stopped;
 	bool axq_tx_inprogress;
-	struct list_head txq_fifo[ATH_TXFIFO_DEPTH];
-	u8 txq_headidx;
-	u8 txq_tailidx;
+	struct list_head hwq_fifo[ATH_TXFIFO_DEPTH];
+	u8 hwq_headidx;
+	u8 hwq_tailidx;
 	int pending_frames;
 	struct sk_buff_head complete_q;
 };
@@ -176,7 +176,7 @@ struct ath_txq {
 struct ath_frame_info {
 	struct ath_buf *bf;
 	u16 framelen;
-	s8 txq;
+	s8 hwq;
 	u8 keyix;
 	u8 rtscts_rate;
 	u8 retries : 7;
@@ -235,7 +235,7 @@ struct ath_atx_tid {
 	struct sk_buff_head buf_q;
 	struct sk_buff_head retry_q;
 	struct ath_node *an;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	unsigned long tx_buf[BITS_TO_LONGS(ATH_TID_MAX_BUFS)];
 	u16 seq_start;
 	u16 seq_next;
@@ -272,7 +272,7 @@ struct ath_node {
 };
 
 struct ath_tx_control {
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	struct ath_node *an;
 	struct ieee80211_sta *sta;
 	u8 paprd;
@@ -281,19 +281,19 @@ struct ath_tx_control {
 
 
 /**
- * @txq_map:  Index is mac80211 queue number.  This is
+ * @hwq_map:  Index is mac80211 queue number.  This is
  *  not necessarily the same as the hardware queue number
  *  (axq_qnum).
  */
 struct ath_tx {
-	u32 txqsetup;
+	u32 hwqsetup;
 	spinlock_t txbuflock;
 	struct list_head txbuf;
-	struct ath_txq txq[ATH9K_NUM_TX_QUEUES];
+	struct ath_hwq hwq[ATH9K_NUM_TX_QUEUES];
 	struct ath_descdma txdma;
-	struct ath_txq *txq_map[IEEE80211_NUM_ACS];
-	struct ath_txq *uapsdq;
-	u32 txq_max_pending[IEEE80211_NUM_ACS];
+	struct ath_hwq *hwq_map[IEEE80211_NUM_ACS];
+	struct ath_hwq *uapsdq;
+	u32 hwq_max_pending[IEEE80211_NUM_ACS];
 	u16 max_aggr_framelen[IEEE80211_NUM_ACS][4][32];
 };
 
@@ -550,19 +550,19 @@ u32 ath_calcrxfilter(struct ath_softc *sc);
 int ath_rx_init(struct ath_softc *sc, int nbufs);
 void ath_rx_cleanup(struct ath_softc *sc);
 int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp);
-struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype);
-void ath_txq_lock(struct ath_softc *sc, struct ath_txq *txq);
-void ath_txq_unlock(struct ath_softc *sc, struct ath_txq *txq);
-void ath_txq_unlock_complete(struct ath_softc *sc, struct ath_txq *txq);
-void ath_tx_cleanupq(struct ath_softc *sc, struct ath_txq *txq);
-bool ath_drain_all_txq(struct ath_softc *sc);
-void ath_draintxq(struct ath_softc *sc, struct ath_txq *txq);
+struct ath_hwq *ath_hwq_setup(struct ath_softc *sc, int qtype, int subtype);
+void ath_hwq_lock(struct ath_softc *sc, struct ath_hwq *hwq);
+void ath_hwq_unlock(struct ath_softc *sc, struct ath_hwq *hwq);
+void ath_hwq_unlock_complete(struct ath_softc *sc, struct ath_hwq *hwq);
+void ath_tx_cleanupq(struct ath_softc *sc, struct ath_hwq *hwq);
+bool ath_drain_all_hwq(struct ath_softc *sc);
+void ath_drainhwq(struct ath_softc *sc, struct ath_hwq *hwq);
 void ath_tx_node_init(struct ath_softc *sc, struct ath_node *an);
 void ath_tx_node_cleanup(struct ath_softc *sc, struct ath_node *an);
-void ath_txq_schedule(struct ath_softc *sc, struct ath_txq *txq);
-void ath_txq_schedule_all(struct ath_softc *sc);
+void ath_hwq_schedule(struct ath_softc *sc, struct ath_hwq *hwq);
+void ath_hwq_schedule_all(struct ath_softc *sc);
 int ath_tx_init(struct ath_softc *sc, int nbufs);
-int ath_txq_update(struct ath_softc *sc, int qnum,
+int ath_hwq_update(struct ath_softc *sc, int qnum,
 		   struct ath9k_tx_queue_info *q);
 void ath_update_max_aggr_framelen(struct ath_softc *sc, int queue, int txop);
 void ath_assign_seq(struct ath_common *common, struct sk_buff *skb);
@@ -677,7 +677,7 @@ struct ath_beacon {
 	int slottime;
 	int slotupdate;
 	struct ath_descdma bdma;
-	struct ath_txq *cabq;
+	struct ath_hwq *cabq;
 	struct list_head bbuf;
 
 	bool tx_processed;
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 5cf0cd7..ee0cf5d 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -35,7 +35,7 @@ static void ath9k_beaconq_config(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath9k_tx_queue_info qi, qi_be;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 
 	ath9k_hw_get_txq_props(ah, sc->beacon.beaconq, &qi);
 
@@ -47,8 +47,8 @@ static void ath9k_beaconq_config(struct ath_softc *sc)
 		qi.tqi_cwmax = 0;
 	} else {
 		/* Adhoc mode; important thing is to use 2x cwmin. */
-		txq = sc->tx.txq_map[IEEE80211_AC_BE];
-		ath9k_hw_get_txq_props(ah, txq->axq_qnum, &qi_be);
+		hwq = sc->tx.hwq_map[IEEE80211_AC_BE];
+		ath9k_hw_get_txq_props(ah, hwq->axq_qnum, &qi_be);
 		qi.tqi_aifs = qi_be.tqi_aifs;
 		if (ah->slottime == ATH9K_SLOT_TIME_20)
 			qi.tqi_cwmin = 2*qi_be.tqi_cwmin;
@@ -117,7 +117,7 @@ static struct ath_buf *ath9k_beacon_generate(struct ieee80211_hw *hw,
 	struct ath_buf *bf;
 	struct ath_vif *avp = (void *)vif->drv_priv;
 	struct sk_buff *skb;
-	struct ath_txq *cabq = sc->beacon.cabq;
+	struct ath_hwq *cabq = sc->beacon.cabq;
 	struct ieee80211_tx_info *info;
 	struct ieee80211_mgmt *mgmt_hdr;
 	int cabq_depth;
@@ -180,7 +180,7 @@ static struct ath_buf *ath9k_beacon_generate(struct ieee80211_hw *hw,
 		if (sc->cur_chan->nvifs > 1) {
 			ath_dbg(common, BEACON,
 				"Flushing previous cabq traffic\n");
-			ath_draintxq(sc, cabq);
+			ath_drainhwq(sc, cabq);
 		}
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 6de64cf..5e9dda8 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -621,34 +621,34 @@ static int read_file_xmit(struct seq_file *file, void *data)
 	return 0;
 }
 
-static void print_queue(struct ath_softc *sc, struct ath_txq *txq,
+static void print_queue(struct ath_softc *sc, struct ath_hwq *hwq,
 			struct seq_file *file)
 {
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 
-	seq_printf(file, "%s: %d ", "qnum", txq->axq_qnum);
-	seq_printf(file, "%s: %2d ", "qdepth", txq->axq_depth);
-	seq_printf(file, "%s: %2d ", "ampdu-depth", txq->axq_ampdu_depth);
-	seq_printf(file, "%s: %3d ", "pending", txq->pending_frames);
-	seq_printf(file, "%s: %d\n", "stopped", txq->stopped);
+	seq_printf(file, "%s: %d ", "qnum", hwq->axq_qnum);
+	seq_printf(file, "%s: %2d ", "qdepth", hwq->axq_depth);
+	seq_printf(file, "%s: %2d ", "ampdu-depth", hwq->axq_ampdu_depth);
+	seq_printf(file, "%s: %3d ", "pending", hwq->pending_frames);
+	seq_printf(file, "%s: %d\n", "stopped", hwq->stopped);
 
-	ath_txq_unlock(sc, txq);
+	ath_hwq_unlock(sc, hwq);
 }
 
 static int read_file_queues(struct seq_file *file, void *data)
 {
 	struct ieee80211_hw *hw = dev_get_drvdata(file->private);
 	struct ath_softc *sc = hw->priv;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int i;
 	static const char *qname[4] = {
 		"VO", "VI", "BE", "BK"
 	};
 
 	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
-		txq = sc->tx.txq_map[i];
+		hwq = sc->tx.hwq_map[i];
 		seq_printf(file, "(%s):  ", qname[i]);
-		print_queue(sc, txq, file);
+		print_queue(sc, hwq, file);
 	}
 
 	seq_puts(file, "(CAB): ");
@@ -782,10 +782,10 @@ static int read_file_reset(struct seq_file *file, void *data)
 }
 
 void ath_debug_stat_tx(struct ath_softc *sc, struct ath_buf *bf,
-		       struct ath_tx_status *ts, struct ath_txq *txq,
+		       struct ath_tx_status *ts, struct ath_hwq *hwq,
 		       unsigned int flags)
 {
-	int qnum = txq->axq_qnum;
+	int qnum = hwq->axq_qnum;
 
 	TX_STAT_INC(qnum, tx_pkts_all);
 	sc->debug.stats.txstats[qnum].tx_bytes_all += bf->bf_mpdu->len;
@@ -1329,13 +1329,13 @@ int ath9k_init_debug(struct ath_hw *ah)
 	debugfs_create_devm_seqfile(sc->dev, "queues", sc->debug.debugfs_phy,
 				    read_file_queues);
 	debugfs_create_u32("qlen_bk", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
-			   &sc->tx.txq_max_pending[IEEE80211_AC_BK]);
+			   &sc->tx.hwq_max_pending[IEEE80211_AC_BK]);
 	debugfs_create_u32("qlen_be", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
-			   &sc->tx.txq_max_pending[IEEE80211_AC_BE]);
+			   &sc->tx.hwq_max_pending[IEEE80211_AC_BE]);
 	debugfs_create_u32("qlen_vi", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
-			   &sc->tx.txq_max_pending[IEEE80211_AC_VI]);
+			   &sc->tx.hwq_max_pending[IEEE80211_AC_VI]);
 	debugfs_create_u32("qlen_vo", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
-			   &sc->tx.txq_max_pending[IEEE80211_AC_VO]);
+			   &sc->tx.hwq_max_pending[IEEE80211_AC_VO]);
 	debugfs_create_devm_seqfile(sc->dev, "misc", sc->debug.debugfs_phy,
 				    read_file_misc);
 	debugfs_create_devm_seqfile(sc->dev, "reset", sc->debug.debugfs_phy,
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/ath/ath9k/debug.h
index cd68c5f..ed64c16 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -20,7 +20,7 @@
 #include "hw.h"
 #include "dfs_debug.h"
 
-struct ath_txq;
+struct ath_hwq;
 struct ath_buf;
 struct fft_sample_tlv;
 
@@ -194,7 +194,7 @@ struct ath_tx_stats {
 /*
  * Various utility macros to print TX/Queue counters.
  */
-#define PR_QNUM(_n) sc->tx.txq_map[_n]->axq_qnum
+#define PR_QNUM(_n) sc->tx.hwq_map[_n]->axq_qnum
 #define TXSTATS sc->debug.stats.txstats
 #define PR(str, elem)							\
 	do {								\
@@ -253,7 +253,7 @@ void ath9k_deinit_debug(struct ath_softc *sc);
 
 void ath_debug_stat_interrupt(struct ath_softc *sc, enum ath9k_int status);
 void ath_debug_stat_tx(struct ath_softc *sc, struct ath_buf *bf,
-		       struct ath_tx_status *ts, struct ath_txq *txq,
+		       struct ath_tx_status *ts, struct ath_hwq *hwq,
 		       unsigned int flags);
 void ath_debug_stat_rx(struct ath_softc *sc, struct ath_rx_status *rs);
 int ath9k_get_et_sset_count(struct ieee80211_hw *hw,
@@ -290,7 +290,7 @@ static inline void ath_debug_stat_interrupt(struct ath_softc *sc,
 static inline void ath_debug_stat_tx(struct ath_softc *sc,
 				     struct ath_buf *bf,
 				     struct ath_tx_status *ts,
-				     struct ath_txq *txq,
+				     struct ath_hwq *hwq,
 				     unsigned int flags)
 {
 }
diff --git a/drivers/net/wireless/ath/ath9k/debug_sta.c b/drivers/net/wireless/ath/ath9k/debug_sta.c
index c2ca57a..a9f4a92 100644
--- a/drivers/net/wireless/ath/ath9k/debug_sta.c
+++ b/drivers/net/wireless/ath/ath9k/debug_sta.c
@@ -26,7 +26,7 @@ static ssize_t read_file_node_aggr(struct file *file, char __user *user_buf,
 	struct ath_node *an = file->private_data;
 	struct ath_softc *sc = an->sc;
 	struct ath_atx_tid *tid;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	u32 len = 0, size = 4096;
 	char *buf;
 	size_t retval;
@@ -54,8 +54,8 @@ static ssize_t read_file_node_aggr(struct file *file, char __user *user_buf,
 
 	for (tidno = 0, tid = &an->tid[tidno];
 	     tidno < IEEE80211_NUM_TIDS; tidno++, tid++) {
-		txq = tid->txq;
-		ath_txq_lock(sc, txq);
+		hwq = tid->hwq;
+		ath_hwq_lock(sc, hwq);
 		if (tid->active) {
 			len += scnprintf(buf + len, size - len,
 					 "%3d%11d%10d%10d%10d%10d%9d%6d\n",
@@ -68,7 +68,7 @@ static ssize_t read_file_node_aggr(struct file *file, char __user *user_buf,
 					 tid->bar_index,
 					 !list_empty(&tid->list));
 		}
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 	}
 exit:
 	retval = simple_read_from_buffer(user_buf, count, ppos, buf, len);
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 2847067..7ecc0e3 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -406,7 +406,7 @@ void ath9k_deinit_btcoex(struct ath_softc *sc)
 
 int ath9k_init_btcoex(struct ath_softc *sc)
 {
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	struct ath_hw *ah = sc->sc_ah;
 	int r;
 
@@ -421,8 +421,8 @@ int ath9k_init_btcoex(struct ath_softc *sc)
 	case ATH_BTCOEX_CFG_3WIRE:
 		ath9k_hw_btcoex_init_3wire(sc->sc_ah);
 		ath_init_btcoex_timer(sc);
-		txq = sc->tx.txq_map[IEEE80211_AC_BE];
-		ath9k_hw_init_btcoex_hw(sc->sc_ah, txq->axq_qnum);
+		hwq = sc->tx.hwq_map[IEEE80211_AC_BE];
+		ath9k_hw_init_btcoex_hw(sc->sc_ah, hwq->axq_qnum);
 		break;
 	case ATH_BTCOEX_CFG_MCI:
 		ath_init_btcoex_timer(sc);
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index ab7a1ac..d96055f 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -346,15 +346,15 @@ static int ath9k_init_queues(struct ath_softc *sc)
 	int i = 0;
 
 	sc->beacon.beaconq = ath9k_hw_beaconq_setup(sc->sc_ah);
-	sc->beacon.cabq = ath_txq_setup(sc, ATH9K_TX_QUEUE_CAB, 0);
+	sc->beacon.cabq = ath_hwq_setup(sc, ATH9K_TX_QUEUE_CAB, 0);
 	ath_cabq_update(sc);
 
-	sc->tx.uapsdq = ath_txq_setup(sc, ATH9K_TX_QUEUE_UAPSD, 0);
+	sc->tx.uapsdq = ath_hwq_setup(sc, ATH9K_TX_QUEUE_UAPSD, 0);
 
 	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
-		sc->tx.txq_map[i] = ath_txq_setup(sc, ATH9K_TX_QUEUE_DATA, i);
-		sc->tx.txq_map[i]->mac80211_qnum = i;
-		sc->tx.txq_max_pending[i] = ATH_MAX_QDEPTH;
+		sc->tx.hwq_map[i] = ath_hwq_setup(sc, ATH9K_TX_QUEUE_DATA, i);
+		sc->tx.hwq_map[i]->mac80211_qnum = i;
+		sc->tx.hwq_max_pending[i] = ATH_MAX_QDEPTH;
 	}
 	return 0;
 }
@@ -671,8 +671,8 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
 
 err_btcoex:
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++)
-		if (ATH_TXQ_SETUP(sc, i))
-			ath_tx_cleanupq(sc, &sc->tx.txq[i]);
+		if (ATH_HWQ_SETUP(sc, i))
+			ath_tx_cleanupq(sc, &sc->tx.hwq[i]);
 err_queues:
 	ath9k_hw_deinit(ah);
 err_hw:
@@ -1001,8 +1001,8 @@ static void ath9k_deinit_softc(struct ath_softc *sc)
 	ath9k_deinit_btcoex(sc);
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++)
-		if (ATH_TXQ_SETUP(sc, i))
-			ath_tx_cleanupq(sc, &sc->tx.txq[i]);
+		if (ATH_HWQ_SETUP(sc, i))
+			ath_tx_cleanupq(sc, &sc->tx.hwq[i]);
 
 	del_timer_sync(&sc->sleep_timer);
 	ath9k_hw_deinit(sc->sc_ah);
diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/ath/ath9k/link.c
index 5ad0fee..2808b72 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -24,7 +24,7 @@ void ath_tx_complete_poll_work(struct work_struct *work)
 {
 	struct ath_softc *sc = container_of(work, struct ath_softc,
 					    tx_complete_work.work);
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int i;
 	bool needreset = false;
 
@@ -36,19 +36,19 @@ void ath_tx_complete_poll_work(struct work_struct *work)
 	}
 
 	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
-		txq = sc->tx.txq_map[i];
+		hwq = sc->tx.hwq_map[i];
 
-		ath_txq_lock(sc, txq);
-		if (txq->axq_depth) {
-			if (txq->axq_tx_inprogress) {
+		ath_hwq_lock(sc, hwq);
+		if (hwq->axq_depth) {
+			if (hwq->axq_tx_inprogress) {
 				needreset = true;
-				ath_txq_unlock(sc, txq);
+				ath_hwq_unlock(sc, hwq);
 				break;
 			} else {
-				txq->axq_tx_inprogress = true;
+				hwq->axq_tx_inprogress = true;
 			}
 		}
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 	}
 
 	if (needreset) {
@@ -175,7 +175,7 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 	unsigned long time_left;
 
 	memset(&txctl, 0, sizeof(txctl));
-	txctl.txq = sc->tx.txq_map[IEEE80211_AC_BE];
+	txctl.hwq = sc->tx.hwq_map[IEEE80211_AC_BE];
 
 	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->band = sc->cur_chandef.chan->band;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index c1b33fd..d39eec8 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -54,14 +54,14 @@ u8 ath9k_parse_mpdudensity(u8 mpdudensity)
 	}
 }
 
-static bool ath9k_has_pending_frames(struct ath_softc *sc, struct ath_txq *txq,
+static bool ath9k_has_pending_frames(struct ath_softc *sc, struct ath_hwq *hwq,
 				     bool sw_pending)
 {
 	bool pending = false;
 
-	spin_lock_bh(&txq->axq_lock);
+	spin_lock_bh(&hwq->axq_lock);
 
-	if (txq->axq_depth) {
+	if (hwq->axq_depth) {
 		pending = true;
 		goto out;
 	}
@@ -69,15 +69,15 @@ static bool ath9k_has_pending_frames(struct ath_softc *sc, struct ath_txq *txq,
 	if (!sw_pending)
 		goto out;
 
-	if (txq->mac80211_qnum >= 0) {
+	if (hwq->mac80211_qnum >= 0) {
 		struct list_head *list;
 
-		list = &sc->cur_chan->acq[txq->mac80211_qnum];
+		list = &sc->cur_chan->acq[hwq->mac80211_qnum];
 		if (!list_empty(list))
 			pending = true;
 	}
 out:
-	spin_unlock_bh(&txq->axq_lock);
+	spin_unlock_bh(&hwq->axq_lock);
 	return pending;
 }
 
@@ -218,9 +218,9 @@ static bool ath_prepare_reset(struct ath_softc *sc)
 
 	if (AR_SREV_9300_20_OR_LATER(ah)) {
 		ret &= ath_stoprecv(sc);
-		ret &= ath_drain_all_txq(sc);
+		ret &= ath_drain_all_hwq(sc);
 	} else {
-		ret &= ath_drain_all_txq(sc);
+		ret &= ath_drain_all_hwq(sc);
 		ret &= ath_stoprecv(sc);
 	}
 
@@ -264,7 +264,7 @@ static bool ath_complete_reset(struct ath_softc *sc, bool start)
 		}
 	work:
 		ath_restart_work(sc);
-		ath_txq_schedule_all(sc);
+		ath_hwq_schedule_all(sc);
 	}
 
 	sc->gtt_cnt = 0;
@@ -805,14 +805,14 @@ static void ath9k_tx(struct ieee80211_hw *hw,
 	}
 
 	memset(&txctl, 0, sizeof(struct ath_tx_control));
-	txctl.txq = sc->tx.txq_map[skb_get_queue_mapping(skb)];
+	txctl.hwq = sc->tx.hwq_map[skb_get_queue_mapping(skb)];
 	txctl.sta = control->sta;
 
 	ath_dbg(common, XMIT, "transmitting packet, skb: %p\n", skb);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
 		ath_dbg(common, XMIT, "TX failed\n");
-		TX_STAT_INC(txctl.txq->axq_qnum, txfailed);
+		TX_STAT_INC(txctl.hwq->axq_qnum, txfailed);
 		goto exit;
 	}
 
@@ -1619,14 +1619,14 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw,
 {
 	struct ath_softc *sc = hw->priv;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	struct ath9k_tx_queue_info qi;
 	int ret = 0;
 
 	if (queue >= IEEE80211_NUM_ACS)
 		return 0;
 
-	txq = sc->tx.txq_map[queue];
+	hwq = sc->tx.hwq_map[queue];
 
 	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
@@ -1640,13 +1640,13 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw,
 
 	ath_dbg(common, CONFIG,
 		"Configure tx [queue/halq] [%d/%d], aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
-		queue, txq->axq_qnum, params->aifs, params->cw_min,
+		queue, hwq->axq_qnum, params->aifs, params->cw_min,
 		params->cw_max, params->txop);
 
 	ath_update_max_aggr_framelen(sc, queue, qi.tqi_burstTime);
-	ret = ath_txq_update(sc, txq->axq_qnum, &qi);
+	ret = ath_hwq_update(sc, hwq->axq_qnum, &qi);
 	if (ret)
-		ath_err(common, "TXQ Update failed\n");
+		ath_err(common, "HWQ Update failed\n");
 
 	mutex_unlock(&sc->mutex);
 	ath9k_ps_restore(sc);
@@ -2006,10 +2006,10 @@ static bool ath9k_has_tx_pending(struct ath_softc *sc,
 	int i, npend = 0;
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (!ATH_TXQ_SETUP(sc, i))
+		if (!ATH_HWQ_SETUP(sc, i))
 			continue;
 
-		npend = ath9k_has_pending_frames(sc, &sc->tx.txq[i],
+		npend = ath9k_has_pending_frames(sc, &sc->tx.hwq[i],
 						 sw_pending);
 		if (npend)
 			break;
@@ -2054,7 +2054,7 @@ void __ath9k_flush(struct ieee80211_hw *hw, u32 queues, bool drop,
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	int timeout;
-	bool drain_txq;
+	bool drain_hwq;
 
 	cancel_delayed_work_sync(&sc->tx_complete_work);
 
@@ -2085,10 +2085,10 @@ void __ath9k_flush(struct ieee80211_hw *hw, u32 queues, bool drop,
 	if (drop) {
 		ath9k_ps_wakeup(sc);
 		spin_lock_bh(&sc->sc_pcu_lock);
-		drain_txq = ath_drain_all_txq(sc);
+		drain_hwq = ath_drain_all_hwq(sc);
 		spin_unlock_bh(&sc->sc_pcu_lock);
 
-		if (!drain_txq)
+		if (!drain_hwq)
 			ath_reset(sc, NULL);
 
 		ath9k_ps_restore(sc);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index fe795fc..4732965 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -47,14 +47,14 @@ static u16 bits_per_symbol[][2] = {
 	{   260,  540 },     /*  7: 64-QAM 5/6 */
 };
 
-static void ath_tx_send_normal(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_send_normal(struct ath_softc *sc, struct ath_hwq *hwq,
 			       struct ath_atx_tid *tid, struct sk_buff *skb);
 static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
-			    int tx_flags, struct ath_txq *txq);
+			    int tx_flags, struct ath_hwq *hwq);
 static void ath_tx_complete_buf(struct ath_softc *sc, struct ath_buf *bf,
-				struct ath_txq *txq, struct list_head *bf_q,
+				struct ath_hwq *hwq, struct list_head *bf_q,
 				struct ath_tx_status *ts, int txok);
-static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_hwqaddbuf(struct ath_softc *sc, struct ath_hwq *hwq,
 			     struct list_head *head, bool internal);
 static void ath_tx_rc_status(struct ath_softc *sc, struct ath_buf *bf,
 			     struct ath_tx_status *ts, int nframes, int nbad,
@@ -62,7 +62,7 @@ static void ath_tx_rc_status(struct ath_softc *sc, struct ath_buf *bf,
 static void ath_tx_update_baw(struct ath_softc *sc, struct ath_atx_tid *tid,
 			      int seqno);
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
-					   struct ath_txq *txq,
+					   struct ath_hwq *hwq,
 					   struct ath_atx_tid *tid,
 					   struct sk_buff *skb);
 
@@ -77,33 +77,33 @@ enum {
 /* Aggregation logic */
 /*********************/
 
-void ath_txq_lock(struct ath_softc *sc, struct ath_txq *txq)
-	__acquires(&txq->axq_lock)
+void ath_hwq_lock(struct ath_softc *sc, struct ath_hwq *hwq)
+	__acquires(&hwq->axq_lock)
 {
-	spin_lock_bh(&txq->axq_lock);
+	spin_lock_bh(&hwq->axq_lock);
 }
 
-void ath_txq_unlock(struct ath_softc *sc, struct ath_txq *txq)
-	__releases(&txq->axq_lock)
+void ath_hwq_unlock(struct ath_softc *sc, struct ath_hwq *hwq)
+	__releases(&hwq->axq_lock)
 {
-	spin_unlock_bh(&txq->axq_lock);
+	spin_unlock_bh(&hwq->axq_lock);
 }
 
-void ath_txq_unlock_complete(struct ath_softc *sc, struct ath_txq *txq)
-	__releases(&txq->axq_lock)
+void ath_hwq_unlock_complete(struct ath_softc *sc, struct ath_hwq *hwq)
+	__releases(&hwq->axq_lock)
 {
 	struct sk_buff_head q;
 	struct sk_buff *skb;
 
 	__skb_queue_head_init(&q);
-	skb_queue_splice_init(&txq->complete_q, &q);
-	spin_unlock_bh(&txq->axq_lock);
+	skb_queue_splice_init(&hwq->complete_q, &q);
+	spin_unlock_bh(&hwq->axq_lock);
 
 	while ((skb = __skb_dequeue(&q)))
 		ieee80211_tx_status(sc->hw, skb);
 }
 
-static void ath_tx_queue_tid(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_queue_tid(struct ath_softc *sc, struct ath_hwq *hwq,
 			     struct ath_atx_tid *tid)
 {
 	struct list_head *list;
@@ -142,27 +142,27 @@ static void ath_set_rates(struct ieee80211_vif *vif, struct ieee80211_sta *sta,
 			       ARRAY_SIZE(bf->rates));
 }
 
-static void ath_txq_skb_done(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_hwq_skb_done(struct ath_softc *sc, struct ath_hwq *hwq,
 			     struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ath_frame_info *fi = get_frame_info(skb);
-	int q = fi->txq;
+	int q = fi->hwq;
 
 	if (q < 0)
 		return;
 
-	txq = sc->tx.txq_map[q];
-	if (WARN_ON(--txq->pending_frames < 0))
-		txq->pending_frames = 0;
+	hwq = sc->tx.hwq_map[q];
+	if (WARN_ON(--hwq->pending_frames < 0))
+		hwq->pending_frames = 0;
 
-	if (txq->stopped &&
-	    txq->pending_frames < sc->tx.txq_max_pending[q]) {
+	if (hwq->stopped &&
+	    hwq->pending_frames < sc->tx.hwq_max_pending[q]) {
 		if (ath9k_is_chanctx_enabled())
 			ieee80211_wake_queue(sc->hw, info->hw_queue);
 		else
 			ieee80211_wake_queue(sc->hw, q);
-		txq->stopped = false;
+		hwq->stopped = false;
 	}
 }
 
@@ -197,7 +197,7 @@ static struct sk_buff *ath_tid_dequeue(struct ath_atx_tid *tid)
 static void
 ath_tx_tid_change_state(struct ath_softc *sc, struct ath_atx_tid *tid)
 {
-	struct ath_txq *txq = tid->txq;
+	struct ath_hwq *hwq = tid->hwq;
 	struct ieee80211_tx_info *tx_info;
 	struct sk_buff *skb, *tskb;
 	struct ath_buf *bf;
@@ -213,10 +213,10 @@ ath_tx_tid_change_state(struct ath_softc *sc, struct ath_atx_tid *tid)
 		if (bf)
 			continue;
 
-		bf = ath_tx_setup_buffer(sc, txq, tid, skb);
+		bf = ath_tx_setup_buffer(sc, hwq, tid, skb);
 		if (!bf) {
 			__skb_unlink(skb, &tid->buf_q);
-			ath_txq_skb_done(sc, txq, skb);
+			ath_hwq_skb_done(sc, hwq, skb);
 			ieee80211_free_txskb(sc->hw, skb);
 			continue;
 		}
@@ -226,7 +226,7 @@ ath_tx_tid_change_state(struct ath_softc *sc, struct ath_atx_tid *tid)
 
 static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 {
-	struct ath_txq *txq = tid->txq;
+	struct ath_hwq *hwq = tid->hwq;
 	struct sk_buff *skb;
 	struct ath_buf *bf;
 	struct list_head bf_head;
@@ -242,7 +242,7 @@ static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 		fi = get_frame_info(skb);
 		bf = fi->bf;
 		if (!bf) {
-			ath_txq_skb_done(sc, txq, skb);
+			ath_hwq_skb_done(sc, hwq, skb);
 			ieee80211_free_txskb(sc->hw, skb);
 			continue;
 		}
@@ -253,13 +253,13 @@ static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 		}
 
 		list_add_tail(&bf->list, &bf_head);
-		ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
+		ath_tx_complete_buf(sc, bf, hwq, &bf_head, &ts, 0);
 	}
 
 	if (sendbar) {
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 		ath_send_bar(tid, tid->seq_start);
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 	}
 }
 
@@ -300,7 +300,7 @@ static void ath_tx_addto_baw(struct ath_softc *sc, struct ath_atx_tid *tid,
 	}
 }
 
-static void ath_tid_drain(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tid_drain(struct ath_softc *sc, struct ath_hwq *hwq,
 			  struct ath_atx_tid *tid)
 
 {
@@ -318,16 +318,16 @@ static void ath_tid_drain(struct ath_softc *sc, struct ath_txq *txq,
 		bf = fi->bf;
 
 		if (!bf) {
-			ath_tx_complete(sc, skb, ATH_TX_ERROR, txq);
+			ath_tx_complete(sc, skb, ATH_TX_ERROR, hwq);
 			continue;
 		}
 
 		list_add_tail(&bf->list, &bf_head);
-		ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
+		ath_tx_complete_buf(sc, bf, hwq, &bf_head, &ts, 0);
 	}
 }
 
-static void ath_tx_set_retry(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_set_retry(struct ath_softc *sc, struct ath_hwq *hwq,
 			     struct sk_buff *skb, int count)
 {
 	struct ath_frame_info *fi = get_frame_info(skb);
@@ -335,7 +335,7 @@ static void ath_tx_set_retry(struct ath_softc *sc, struct ath_txq *txq,
 	struct ieee80211_hdr *hdr;
 	int prev = fi->retries;
 
-	TX_STAT_INC(txq->axq_qnum, a_retries);
+	TX_STAT_INC(hwq->axq_qnum, a_retries);
 	fi->retries += count;
 
 	if (prev > 0)
@@ -424,7 +424,7 @@ static void ath_tx_count_frames(struct ath_softc *sc, struct ath_buf *bf,
 }
 
 
-static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_hwq *hwq,
 				 struct ath_buf *bf, struct list_head *bf_q,
 				 struct ath_tx_status *ts, int txok)
 {
@@ -473,7 +473,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 			if (!bf->bf_state.stale || bf_next != NULL)
 				list_move_tail(&bf->list, &bf_head);
 
-			ath_tx_complete_buf(sc, bf, txq, &bf_head, ts, 0);
+			ath_tx_complete_buf(sc, bf, hwq, &bf_head, ts, 0);
 
 			bf = bf_next;
 		}
@@ -547,7 +547,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 			txpending = 1;
 		} else if (fi->retries < ATH_MAX_SW_RETRIES) {
 			if (txok || !an->sleeping)
-				ath_tx_set_retry(sc, txq, bf->bf_mpdu,
+				ath_tx_set_retry(sc, hwq, bf->bf_mpdu,
 						 retries);
 
 			txpending = 1;
@@ -583,7 +583,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 								ts);
 			}
 
-			ath_tx_complete_buf(sc, bf, txq, &bf_head, ts,
+			ath_tx_complete_buf(sc, bf, hwq, &bf_head, ts,
 				!txfail);
 		} else {
 			if (tx_info->flags & IEEE80211_TX_STATUS_EOSP) {
@@ -603,7 +603,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 				if (!tbf) {
 					ath_tx_update_baw(sc, tid, seqno);
 
-					ath_tx_complete_buf(sc, bf, txq,
+					ath_tx_complete_buf(sc, bf, hwq,
 							    &bf_head, ts, 0);
 					bar_index = max_t(int, bar_index,
 						ATH_BA_INDEX(seq_first, seqno));
@@ -630,7 +630,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 
 		skb_queue_splice_tail(&bf_pending, &tid->retry_q);
 		if (!an->sleeping) {
-			ath_tx_queue_tid(sc, txq, tid);
+			ath_tx_queue_tid(sc, hwq, tid);
 
 			if (ts->ts_status & (ATH9K_TXERR_FILT | ATH9K_TXERR_XRETRY))
 				tid->clear_ps_filter = true;
@@ -643,9 +643,9 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, struct ath_txq *txq,
 		if (BAW_WITHIN(tid->seq_start, tid->baw_size, bar_seq))
 			tid->bar_index = ATH_BA_INDEX(tid->seq_start, bar_seq);
 
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 		ath_send_bar(tid, ATH_BA_INDEX2SEQ(seq_first, bar_index + 1));
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 	}
 
 	rcu_read_unlock();
@@ -660,7 +660,7 @@ static bool bf_is_ampdu_not_probing(struct ath_buf *bf)
     return bf_isampdu(bf) && !(info->flags & IEEE80211_TX_CTL_RATE_CTRL_PROBE);
 }
 
-static void ath_tx_process_buffer(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_process_buffer(struct ath_softc *sc, struct ath_hwq *hwq,
 				  struct ath_tx_status *ts, struct ath_buf *bf,
 				  struct list_head *bf_head)
 {
@@ -669,11 +669,11 @@ static void ath_tx_process_buffer(struct ath_softc *sc, struct ath_txq *txq,
 
 	txok = !(ts->ts_status & ATH9K_TXERR_MASK);
 	flush = !!(ts->ts_status & ATH9K_TX_FLUSH);
-	txq->axq_tx_inprogress = false;
+	hwq->axq_tx_inprogress = false;
 
-	txq->axq_depth--;
+	hwq->axq_depth--;
 	if (bf_is_ampdu_not_probing(bf))
-		txq->axq_ampdu_depth--;
+		hwq->axq_ampdu_depth--;
 
 	ts->duration = ath9k_hw_get_duration(sc->sc_ah, bf->bf_desc,
 					     ts->ts_rateindex);
@@ -685,12 +685,12 @@ static void ath_tx_process_buffer(struct ath_softc *sc, struct ath_txq *txq,
 			ath_tx_rc_status(sc, bf, ts, 1, txok ? 0 : 1, txok);
 			ath_dynack_sample_tx_ts(sc->sc_ah, bf->bf_mpdu, ts);
 		}
-		ath_tx_complete_buf(sc, bf, txq, bf_head, ts, txok);
+		ath_tx_complete_buf(sc, bf, hwq, bf_head, ts, txok);
 	} else
-		ath_tx_complete_aggr(sc, txq, bf, bf_head, ts, txok);
+		ath_tx_complete_aggr(sc, hwq, bf, bf_head, ts, txok);
 
 	if (!flush)
-		ath_txq_schedule(sc, txq);
+		ath_hwq_schedule(sc, hwq);
 }
 
 static bool ath_lookup_legacy(struct ath_buf *bf)
@@ -723,7 +723,7 @@ static u32 ath_lookup_rate(struct ath_softc *sc, struct ath_buf *bf,
 	struct ieee80211_tx_rate *rates;
 	u32 max_4ms_framelen, frmlen;
 	u16 aggr_limit, bt_aggr_limit, legacy = 0;
-	int q = tid->txq->mac80211_qnum;
+	int q = tid->hwq->mac80211_qnum;
 	int i;
 
 	skb = bf->bf_mpdu;
@@ -857,7 +857,7 @@ static int ath_compute_num_delims(struct ath_softc *sc, struct ath_atx_tid *tid,
 }
 
 static struct ath_buf *
-ath_tx_get_tid_subframe(struct ath_softc *sc, struct ath_txq *txq,
+ath_tx_get_tid_subframe(struct ath_softc *sc, struct ath_hwq *hwq,
 			struct ath_atx_tid *tid, struct sk_buff_head **q)
 {
 	struct ieee80211_tx_info *tx_info;
@@ -878,13 +878,13 @@ ath_tx_get_tid_subframe(struct ath_softc *sc, struct ath_txq *txq,
 		fi = get_frame_info(skb);
 		bf = fi->bf;
 		if (!fi->bf)
-			bf = ath_tx_setup_buffer(sc, txq, tid, skb);
+			bf = ath_tx_setup_buffer(sc, hwq, tid, skb);
 		else
 			bf->bf_state.stale = false;
 
 		if (!bf) {
 			__skb_unlink(skb, *q);
-			ath_txq_skb_done(sc, txq, skb);
+			ath_hwq_skb_done(sc, hwq, skb);
 			ieee80211_free_txskb(sc->hw, skb);
 			continue;
 		}
@@ -923,7 +923,7 @@ ath_tx_get_tid_subframe(struct ath_softc *sc, struct ath_txq *txq,
 			list_add(&bf->list, &bf_head);
 			__skb_unlink(skb, *q);
 			ath_tx_update_baw(sc, tid, seqno);
-			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
+			ath_tx_complete_buf(sc, bf, hwq, &bf_head, &ts, 0);
 			continue;
 		}
 
@@ -934,7 +934,7 @@ ath_tx_get_tid_subframe(struct ath_softc *sc, struct ath_txq *txq,
 }
 
 static bool
-ath_tx_form_aggr(struct ath_softc *sc, struct ath_txq *txq,
+ath_tx_form_aggr(struct ath_softc *sc, struct ath_hwq *hwq,
 		 struct ath_atx_tid *tid, struct list_head *bf_q,
 		 struct ath_buf *bf_first, struct sk_buff_head *tid_q,
 		 int *aggr_len)
@@ -995,7 +995,7 @@ ath_tx_form_aggr(struct ath_softc *sc, struct ath_txq *txq,
 
 		bf_prev = bf;
 
-		bf = ath_tx_get_tid_subframe(sc, txq, tid, &tid_q);
+		bf = ath_tx_get_tid_subframe(sc, hwq, tid, &tid_q);
 		if (!bf) {
 			closed = true;
 			break;
@@ -1009,7 +1009,7 @@ ath_tx_form_aggr(struct ath_softc *sc, struct ath_txq *txq,
 		al = get_frame_info(bf->bf_mpdu)->framelen;
 		bf->bf_state.bf_type = BUF_AMPDU;
 	} else {
-		TX_STAT_INC(txq->axq_qnum, a_aggr);
+		TX_STAT_INC(hwq->axq_qnum, a_aggr);
 	}
 
 	*aggr_len = al;
@@ -1297,7 +1297,7 @@ static enum ath9k_pkt_type get_hw_packet_type(struct sk_buff *skb)
 }
 
 static void ath_tx_fill_desc(struct ath_softc *sc, struct ath_buf *bf,
-			     struct ath_txq *txq, int len)
+			     struct ath_hwq *hwq, int len)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_buf *bf_first = NULL;
@@ -1308,7 +1308,7 @@ static void ath_tx_fill_desc(struct ath_softc *sc, struct ath_buf *bf,
 	memset(&info, 0, sizeof(info));
 	info.is_first = true;
 	info.is_last = true;
-	info.qcu = txq->axq_qnum;
+	info.qcu = hwq->axq_qnum;
 
 	while (bf) {
 		struct sk_buff *skb = bf->bf_mpdu;
@@ -1328,7 +1328,7 @@ static void ath_tx_fill_desc(struct ath_softc *sc, struct ath_buf *bf,
 			if (!sc->tx99_state)
 				info.flags = ATH9K_TXDESC_INTREQ;
 			if ((tx_info->flags & IEEE80211_TX_CTL_CLEAR_PS_FILT) ||
-			    txq == sc->tx.uapsdq)
+			    hwq == sc->tx.uapsdq)
 				info.flags |= ATH9K_TXDESC_CLRDMASK;
 
 			if (tx_info->flags & IEEE80211_TX_CTL_NO_ACK)
@@ -1389,7 +1389,7 @@ static void ath_tx_fill_desc(struct ath_softc *sc, struct ath_buf *bf,
 }
 
 static void
-ath_tx_form_burst(struct ath_softc *sc, struct ath_txq *txq,
+ath_tx_form_burst(struct ath_softc *sc, struct ath_hwq *hwq,
 		  struct ath_atx_tid *tid, struct list_head *bf_q,
 		  struct ath_buf *bf_first, struct sk_buff_head *tid_q)
 {
@@ -1411,7 +1411,7 @@ ath_tx_form_burst(struct ath_softc *sc, struct ath_txq *txq,
 		if (nframes >= 2)
 			break;
 
-		bf = ath_tx_get_tid_subframe(sc, txq, tid, &tid_q);
+		bf = ath_tx_get_tid_subframe(sc, hwq, tid, &tid_q);
 		if (!bf)
 			break;
 
@@ -1423,7 +1423,7 @@ ath_tx_form_burst(struct ath_softc *sc, struct ath_txq *txq,
 	} while (1);
 }
 
-static bool ath_tx_sched_aggr(struct ath_softc *sc, struct ath_txq *txq,
+static bool ath_tx_sched_aggr(struct ath_softc *sc, struct ath_hwq *hwq,
 			      struct ath_atx_tid *tid, bool *stop)
 {
 	struct ath_buf *bf;
@@ -1438,24 +1438,24 @@ static bool ath_tx_sched_aggr(struct ath_softc *sc, struct ath_txq *txq,
 
 	INIT_LIST_HEAD(&bf_q);
 
-	bf = ath_tx_get_tid_subframe(sc, txq, tid, &tid_q);
+	bf = ath_tx_get_tid_subframe(sc, hwq, tid, &tid_q);
 	if (!bf)
 		return false;
 
 	tx_info = IEEE80211_SKB_CB(bf->bf_mpdu);
 	aggr = !!(tx_info->flags & IEEE80211_TX_CTL_AMPDU);
-	if ((aggr && txq->axq_ampdu_depth >= ATH_AGGR_MIN_QDEPTH) ||
-		(!aggr && txq->axq_depth >= ATH_NON_AGGR_MIN_QDEPTH)) {
+	if ((aggr && hwq->axq_ampdu_depth >= ATH_AGGR_MIN_QDEPTH) ||
+		(!aggr && hwq->axq_depth >= ATH_NON_AGGR_MIN_QDEPTH)) {
 		*stop = true;
 		return false;
 	}
 
 	ath_set_rates(tid->an->vif, tid->an->sta, bf);
 	if (aggr)
-		last = ath_tx_form_aggr(sc, txq, tid, &bf_q, bf,
+		last = ath_tx_form_aggr(sc, hwq, tid, &bf_q, bf,
 					tid_q, &aggr_len);
 	else
-		ath_tx_form_burst(sc, txq, tid, &bf_q, bf, tid_q);
+		ath_tx_form_burst(sc, hwq, tid, &bf_q, bf, tid_q);
 
 	if (list_empty(&bf_q))
 		return false;
@@ -1465,8 +1465,8 @@ static bool ath_tx_sched_aggr(struct ath_softc *sc, struct ath_txq *txq,
 		tx_info->flags |= IEEE80211_TX_CTL_CLEAR_PS_FILT;
 	}
 
-	ath_tx_fill_desc(sc, bf, txq, aggr_len);
-	ath_tx_txqaddbuf(sc, txq, &bf_q, false);
+	ath_tx_fill_desc(sc, bf, hwq, aggr_len);
+	ath_tx_hwqaddbuf(sc, hwq, &bf_q, false);
 	return true;
 }
 
@@ -1475,7 +1475,7 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_atx_tid *txtid;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	struct ath_node *an;
 	u8 density;
 
@@ -1483,9 +1483,9 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 
 	an = (struct ath_node *)sta->drv_priv;
 	txtid = ATH_AN_2_TID(an, tid);
-	txq = txtid->txq;
+	hwq = txtid->hwq;
 
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 
 	/* update ampdu factor/density, they may have changed. This may happen
 	 * in HT IBSS when a beacon with HT-info is received after the station
@@ -1508,7 +1508,7 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 	memset(txtid->tx_buf, 0, sizeof(txtid->tx_buf));
 	txtid->baw_head = txtid->baw_tail = 0;
 
-	ath_txq_unlock_complete(sc, txq);
+	ath_hwq_unlock_complete(sc, hwq);
 
 	return 0;
 }
@@ -1518,15 +1518,15 @@ void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16 tid)
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_node *an = (struct ath_node *)sta->drv_priv;
 	struct ath_atx_tid *txtid = ATH_AN_2_TID(an, tid);
-	struct ath_txq *txq = txtid->txq;
+	struct ath_hwq *hwq = txtid->hwq;
 
 	ath_dbg(common, XMIT, "%s called\n", __func__);
 
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 	txtid->active = false;
 	ath_tx_flush_tid(sc, txtid);
 	ath_tx_tid_change_state(sc, txtid);
-	ath_txq_unlock_complete(sc, txq);
+	ath_hwq_unlock_complete(sc, hwq);
 }
 
 void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
@@ -1534,7 +1534,7 @@ void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_atx_tid *tid;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	bool buffered;
 	int tidno;
 
@@ -1543,12 +1543,12 @@ void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
 	for (tidno = 0, tid = &an->tid[tidno];
 	     tidno < IEEE80211_NUM_TIDS; tidno++, tid++) {
 
-		txq = tid->txq;
+		hwq = tid->hwq;
 
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 
 		if (list_empty(&tid->list)) {
-			ath_txq_unlock(sc, txq);
+			ath_hwq_unlock(sc, hwq);
 			continue;
 		}
 
@@ -1556,7 +1556,7 @@ void ath_tx_aggr_sleep(struct ieee80211_sta *sta, struct ath_softc *sc,
 
 		list_del_init(&tid->list);
 
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 
 		ieee80211_sta_set_buffered(sta, tidno, buffered);
 	}
@@ -1566,7 +1566,7 @@ void ath_tx_aggr_wakeup(struct ath_softc *sc, struct ath_node *an)
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_atx_tid *tid;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int tidno;
 
 	ath_dbg(common, XMIT, "%s called\n", __func__);
@@ -1574,17 +1574,17 @@ void ath_tx_aggr_wakeup(struct ath_softc *sc, struct ath_node *an)
 	for (tidno = 0, tid = &an->tid[tidno];
 	     tidno < IEEE80211_NUM_TIDS; tidno++, tid++) {
 
-		txq = tid->txq;
+		hwq = tid->hwq;
 
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 		tid->clear_ps_filter = true;
 
 		if (ath_tid_has_buffered(tid)) {
-			ath_tx_queue_tid(sc, txq, tid);
-			ath_txq_schedule(sc, txq);
+			ath_tx_queue_tid(sc, hwq, tid);
+			ath_hwq_schedule(sc, hwq);
 		}
 
-		ath_txq_unlock_complete(sc, txq);
+		ath_hwq_unlock_complete(sc, hwq);
 	}
 }
 
@@ -1594,24 +1594,24 @@ void ath_tx_aggr_resume(struct ath_softc *sc, struct ieee80211_sta *sta,
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_atx_tid *tid;
 	struct ath_node *an;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 
 	ath_dbg(common, XMIT, "%s called\n", __func__);
 
 	an = (struct ath_node *)sta->drv_priv;
 	tid = ATH_AN_2_TID(an, tidno);
-	txq = tid->txq;
+	hwq = tid->hwq;
 
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 
 	tid->baw_size = IEEE80211_MIN_AMPDU_BUF << sta->ht_cap.ampdu_factor;
 
 	if (ath_tid_has_buffered(tid)) {
-		ath_tx_queue_tid(sc, txq, tid);
-		ath_txq_schedule(sc, txq);
+		ath_tx_queue_tid(sc, hwq, tid);
+		ath_hwq_schedule(sc, hwq);
 	}
 
-	ath_txq_unlock_complete(sc, txq);
+	ath_hwq_unlock_complete(sc, hwq);
 }
 
 void ath9k_release_buffered_frames(struct ieee80211_hw *hw,
@@ -1622,7 +1622,7 @@ void ath9k_release_buffered_frames(struct ieee80211_hw *hw,
 {
 	struct ath_softc *sc = hw->priv;
 	struct ath_node *an = (struct ath_node *)sta->drv_priv;
-	struct ath_txq *txq = sc->tx.uapsdq;
+	struct ath_hwq *hwq = sc->tx.uapsdq;
 	struct ieee80211_tx_info *info;
 	struct list_head bf_q;
 	struct ath_buf *bf_tail = NULL, *bf;
@@ -1639,7 +1639,7 @@ void ath9k_release_buffered_frames(struct ieee80211_hw *hw,
 
 		tid = ATH_AN_2_TID(an, i);
 
-		ath_txq_lock(sc, tid->txq);
+		ath_hwq_lock(sc, tid->hwq);
 		while (nframes > 0) {
 			bf = ath_tx_get_tid_subframe(sc, sc->tx.uapsdq, tid, &tid_q);
 			if (!bf)
@@ -1658,12 +1658,12 @@ void ath9k_release_buffered_frames(struct ieee80211_hw *hw,
 			bf_tail = bf;
 			nframes--;
 			sent++;
-			TX_STAT_INC(txq->axq_qnum, a_queued_hw);
+			TX_STAT_INC(hwq->axq_qnum, a_queued_hw);
 
 			if (an->sta && !ath_tid_has_buffered(tid))
 				ieee80211_sta_set_buffered(an->sta, i, false);
 		}
-		ath_txq_unlock_complete(sc, tid->txq);
+		ath_hwq_unlock_complete(sc, tid->hwq);
 	}
 
 	if (list_empty(&bf_q))
@@ -1673,17 +1673,17 @@ void ath9k_release_buffered_frames(struct ieee80211_hw *hw,
 	info->flags |= IEEE80211_TX_STATUS_EOSP;
 
 	bf = list_first_entry(&bf_q, struct ath_buf, list);
-	ath_txq_lock(sc, txq);
-	ath_tx_fill_desc(sc, bf, txq, 0);
-	ath_tx_txqaddbuf(sc, txq, &bf_q, false);
-	ath_txq_unlock(sc, txq);
+	ath_hwq_lock(sc, hwq);
+	ath_tx_fill_desc(sc, bf, hwq, 0);
+	ath_tx_hwqaddbuf(sc, hwq, &bf_q, false);
+	ath_hwq_unlock(sc, hwq);
 }
 
 /********************/
 /* Queue Management */
 /********************/
 
-struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype)
+struct ath_hwq *ath_hwq_setup(struct ath_softc *sc, int qtype, int subtype)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath9k_tx_queue_info qi;
@@ -1734,35 +1734,35 @@ struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype)
 		 */
 		return NULL;
 	}
-	if (!ATH_TXQ_SETUP(sc, axq_qnum)) {
-		struct ath_txq *txq = &sc->tx.txq[axq_qnum];
-
-		txq->axq_qnum = axq_qnum;
-		txq->mac80211_qnum = -1;
-		txq->axq_link = NULL;
-		__skb_queue_head_init(&txq->complete_q);
-		INIT_LIST_HEAD(&txq->axq_q);
-		spin_lock_init(&txq->axq_lock);
-		txq->axq_depth = 0;
-		txq->axq_ampdu_depth = 0;
-		txq->axq_tx_inprogress = false;
-		sc->tx.txqsetup |= 1<<axq_qnum;
-
-		txq->txq_headidx = txq->txq_tailidx = 0;
+	if (!ATH_HWQ_SETUP(sc, axq_qnum)) {
+		struct ath_hwq *hwq = &sc->tx.hwq[axq_qnum];
+
+		hwq->axq_qnum = axq_qnum;
+		hwq->mac80211_qnum = -1;
+		hwq->axq_link = NULL;
+		__skb_queue_head_init(&hwq->complete_q);
+		INIT_LIST_HEAD(&hwq->axq_q);
+		spin_lock_init(&hwq->axq_lock);
+		hwq->axq_depth = 0;
+		hwq->axq_ampdu_depth = 0;
+		hwq->axq_tx_inprogress = false;
+		sc->tx.hwqsetup |= 1<<axq_qnum;
+
+		hwq->hwq_headidx = hwq->hwq_tailidx = 0;
 		for (i = 0; i < ATH_TXFIFO_DEPTH; i++)
-			INIT_LIST_HEAD(&txq->txq_fifo[i]);
+			INIT_LIST_HEAD(&hwq->hwq_fifo[i]);
 	}
-	return &sc->tx.txq[axq_qnum];
+	return &sc->tx.hwq[axq_qnum];
 }
 
-int ath_txq_update(struct ath_softc *sc, int qnum,
+int ath_hwq_update(struct ath_softc *sc, int qnum,
 		   struct ath9k_tx_queue_info *qinfo)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	int error = 0;
 	struct ath9k_tx_queue_info qi;
 
-	BUG_ON(sc->tx.txq[qnum].axq_qnum != qnum);
+	BUG_ON(sc->tx.hwq[qnum].axq_qnum != qnum);
 
 	ath9k_hw_get_txq_props(ah, qnum, &qi);
 	qi.tqi_aifs = qinfo->tqi_aifs;
@@ -1792,12 +1792,12 @@ int ath_cabq_update(struct ath_softc *sc)
 
 	qi.tqi_readyTime = (TU_TO_USEC(cur_conf->beacon_interval) *
 			    ATH_CABQ_READY_TIME) / 100;
-	ath_txq_update(sc, qnum, &qi);
+	ath_hwq_update(sc, qnum, &qi);
 
 	return 0;
 }
 
-static void ath_drain_txq_list(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_drain_hwq_list(struct ath_softc *sc, struct ath_hwq *hwq,
 			       struct list_head *list)
 {
 	struct ath_buf *bf, *lastbf;
@@ -1820,7 +1820,7 @@ static void ath_drain_txq_list(struct ath_softc *sc, struct ath_txq *txq,
 
 		lastbf = bf->bf_lastbf;
 		list_cut_position(&bf_head, list, &lastbf->list);
-		ath_tx_process_buffer(sc, txq, &ts, bf, &bf_head);
+		ath_tx_process_buffer(sc, hwq, &ts, bf, &bf_head);
 	}
 }
 
@@ -1830,33 +1830,33 @@ static void ath_drain_txq_list(struct ath_softc *sc, struct ath_txq *txq,
  * This assumes output has been stopped and
  * we do not need to block ath_tx_tasklet.
  */
-void ath_draintxq(struct ath_softc *sc, struct ath_txq *txq)
+void ath_drainhwq(struct ath_softc *sc, struct ath_hwq *hwq)
 {
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
-		int idx = txq->txq_tailidx;
+		int idx = hwq->hwq_tailidx;
 
-		while (!list_empty(&txq->txq_fifo[idx])) {
-			ath_drain_txq_list(sc, txq, &txq->txq_fifo[idx]);
+		while (!list_empty(&hwq->hwq_fifo[idx])) {
+			ath_drain_hwq_list(sc, hwq, &hwq->hwq_fifo[idx]);
 
 			INCR(idx, ATH_TXFIFO_DEPTH);
 		}
-		txq->txq_tailidx = idx;
+		hwq->hwq_tailidx = idx;
 	}
 
-	txq->axq_link = NULL;
-	txq->axq_tx_inprogress = false;
-	ath_drain_txq_list(sc, txq, &txq->axq_q);
+	hwq->axq_link = NULL;
+	hwq->axq_tx_inprogress = false;
+	ath_drain_hwq_list(sc, hwq, &hwq->axq_q);
 
-	ath_txq_unlock_complete(sc, txq);
+	ath_hwq_unlock_complete(sc, hwq);
 }
 
-bool ath_drain_all_txq(struct ath_softc *sc)
+bool ath_drain_all_hwq(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int i;
 	u32 npend = 0;
 
@@ -1867,13 +1867,13 @@ bool ath_drain_all_txq(struct ath_softc *sc)
 
 	/* Check if any queue remains active */
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (!ATH_TXQ_SETUP(sc, i))
+		if (!ATH_HWQ_SETUP(sc, i))
 			continue;
 
-		if (!sc->tx.txq[i].axq_depth)
+		if (!sc->tx.hwq[i].axq_depth)
 			continue;
 
-		if (ath9k_hw_numtxpending(ah, sc->tx.txq[i].axq_qnum))
+		if (ath9k_hw_numtxpending(ah, sc->tx.hwq[i].axq_qnum))
 			npend |= BIT(i);
 	}
 
@@ -1884,7 +1884,7 @@ bool ath_drain_all_txq(struct ath_softc *sc)
 	}
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (!ATH_TXQ_SETUP(sc, i))
+		if (!ATH_HWQ_SETUP(sc, i))
 			continue;
 
 		/*
@@ -1892,38 +1892,38 @@ bool ath_drain_all_txq(struct ath_softc *sc)
 		 * Mark the queue as not stopped to prevent ath_tx_complete
 		 * from waking the queue too early.
 		 */
-		txq = &sc->tx.txq[i];
-		txq->stopped = false;
-		ath_draintxq(sc, txq);
+		hwq = &sc->tx.hwq[i];
+		hwq->stopped = false;
+		ath_drainhwq(sc, hwq);
 	}
 
 	return !npend;
 }
 
-void ath_tx_cleanupq(struct ath_softc *sc, struct ath_txq *txq)
+void ath_tx_cleanupq(struct ath_softc *sc, struct ath_hwq *hwq)
 {
-	ath9k_hw_releasetxqueue(sc->sc_ah, txq->axq_qnum);
-	sc->tx.txqsetup &= ~(1<<txq->axq_qnum);
+	ath9k_hw_releasetxqueue(sc->sc_ah, hwq->axq_qnum);
+	sc->tx.hwqsetup &= ~(1<<hwq->axq_qnum);
 }
 
 /* For each acq entry, for each tid, try to schedule packets
  * for transmit until ampdu_depth has reached min Q depth.
  */
-void ath_txq_schedule(struct ath_softc *sc, struct ath_txq *txq)
+void ath_hwq_schedule(struct ath_softc *sc, struct ath_hwq *hwq)
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_atx_tid *tid, *last_tid;
 	struct list_head *tid_list;
 	bool sent = false;
 
-	if (txq->mac80211_qnum < 0)
+	if (hwq->mac80211_qnum < 0)
 		return;
 
 	if (test_bit(ATH_OP_HW_RESET, &common->op_flags))
 		return;
 
 	spin_lock_bh(&sc->chan_lock);
-	tid_list = &sc->cur_chan->acq[txq->mac80211_qnum];
+	tid_list = &sc->cur_chan->acq[hwq->mac80211_qnum];
 
 	if (list_empty(tid_list)) {
 		spin_unlock_bh(&sc->chan_lock);
@@ -1942,7 +1942,7 @@ void ath_txq_schedule(struct ath_softc *sc, struct ath_txq *txq)
 		tid = list_first_entry(tid_list, struct ath_atx_tid, list);
 		list_del_init(&tid->list);
 
-		if (ath_tx_sched_aggr(sc, txq, tid, &stop))
+		if (ath_tx_sched_aggr(sc, hwq, tid, &stop))
 			sent = true;
 
 		/*
@@ -1950,7 +1950,7 @@ void ath_txq_schedule(struct ath_softc *sc, struct ath_txq *txq)
 		 * are pending for the tid
 		 */
 		if (ath_tid_has_buffered(tid))
-			ath_tx_queue_tid(sc, txq, tid);
+			ath_tx_queue_tid(sc, hwq, tid);
 
 		if (stop)
 			break;
@@ -1969,17 +1969,17 @@ void ath_txq_schedule(struct ath_softc *sc, struct ath_txq *txq)
 	spin_unlock_bh(&sc->chan_lock);
 }
 
-void ath_txq_schedule_all(struct ath_softc *sc)
+void ath_hwq_schedule_all(struct ath_softc *sc)
 {
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int i;
 
 	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
-		txq = sc->tx.txq_map[i];
+		hwq = sc->tx.hwq_map[i];
 
-		spin_lock_bh(&txq->axq_lock);
-		ath_txq_schedule(sc, txq);
-		spin_unlock_bh(&txq->axq_lock);
+		spin_lock_bh(&hwq->axq_lock);
+		ath_hwq_schedule(sc, hwq);
+		spin_unlock_bh(&hwq->axq_lock);
 	}
 }
 
@@ -1988,10 +1988,10 @@ void ath_txq_schedule_all(struct ath_softc *sc)
 /***********/
 
 /*
- * Insert a chain of ath_buf (descriptors) on a txq and
+ * Insert a chain of ath_buf (descriptors) on a hwq and
  * assume the descriptors are already chained together by caller.
  */
-static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_hwqaddbuf(struct ath_softc *sc, struct ath_hwq *hwq,
 			     struct list_head *head, bool internal)
 {
 	struct ath_hw *ah = sc->sc_ah;
@@ -2012,44 +2012,44 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 	bf = list_first_entry(head, struct ath_buf, list);
 	bf_last = list_entry(head->prev, struct ath_buf, list);
 
-	ath_dbg(common, QUEUE, "qnum: %d, txq depth: %d\n",
-		txq->axq_qnum, txq->axq_depth);
+	ath_dbg(common, QUEUE, "qnum: %d, hwq depth: %d\n",
+		hwq->axq_qnum, hwq->axq_depth);
 
-	if (edma && list_empty(&txq->txq_fifo[txq->txq_headidx])) {
-		list_splice_tail_init(head, &txq->txq_fifo[txq->txq_headidx]);
-		INCR(txq->txq_headidx, ATH_TXFIFO_DEPTH);
+	if (edma && list_empty(&hwq->hwq_fifo[hwq->hwq_headidx])) {
+		list_splice_tail_init(head, &hwq->hwq_fifo[hwq->hwq_headidx]);
+		INCR(hwq->hwq_headidx, ATH_TXFIFO_DEPTH);
 		puttxbuf = true;
 	} else {
-		list_splice_tail_init(head, &txq->axq_q);
+		list_splice_tail_init(head, &hwq->axq_q);
 
-		if (txq->axq_link) {
-			ath9k_hw_set_desc_link(ah, txq->axq_link, bf->bf_daddr);
+		if (hwq->axq_link) {
+			ath9k_hw_set_desc_link(ah, hwq->axq_link, bf->bf_daddr);
 			ath_dbg(common, XMIT, "link[%u] (%p)=%llx (%p)\n",
-				txq->axq_qnum, txq->axq_link,
+				hwq->axq_qnum, hwq->axq_link,
 				ito64(bf->bf_daddr), bf->bf_desc);
 		} else if (!edma)
 			puttxbuf = true;
 
-		txq->axq_link = bf_last->bf_desc;
+		hwq->axq_link = bf_last->bf_desc;
 	}
 
 	if (puttxbuf) {
-		TX_STAT_INC(txq->axq_qnum, puttxbuf);
-		ath9k_hw_puttxbuf(ah, txq->axq_qnum, bf->bf_daddr);
+		TX_STAT_INC(hwq->axq_qnum, puttxbuf);
+		ath9k_hw_puttxbuf(ah, hwq->axq_qnum, bf->bf_daddr);
 		ath_dbg(common, XMIT, "TXDP[%u] = %llx (%p)\n",
-			txq->axq_qnum, ito64(bf->bf_daddr), bf->bf_desc);
+			hwq->axq_qnum, ito64(bf->bf_daddr), bf->bf_desc);
 	}
 
 	if (!edma || sc->tx99_state) {
-		TX_STAT_INC(txq->axq_qnum, txstart);
-		ath9k_hw_txstart(ah, txq->axq_qnum);
+		TX_STAT_INC(hwq->axq_qnum, txstart);
+		ath9k_hw_txstart(ah, hwq->axq_qnum);
 	}
 
 	if (!internal) {
 		while (bf) {
-			txq->axq_depth++;
+			hwq->axq_depth++;
 			if (bf_is_ampdu_not_probing(bf))
-				txq->axq_ampdu_depth++;
+				hwq->axq_ampdu_depth++;
 
 			bf_last = bf->bf_lastbf;
 			bf = bf_last->bf_next;
@@ -2058,7 +2058,7 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 	}
 }
 
-static void ath_tx_send_normal(struct ath_softc *sc, struct ath_txq *txq,
+static void ath_tx_send_normal(struct ath_softc *sc, struct ath_hwq *hwq,
 			       struct ath_atx_tid *tid, struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
@@ -2076,9 +2076,9 @@ static void ath_tx_send_normal(struct ath_softc *sc, struct ath_txq *txq,
 
 	bf->bf_next = NULL;
 	bf->bf_lastbf = bf;
-	ath_tx_fill_desc(sc, bf, txq, fi->framelen);
-	ath_tx_txqaddbuf(sc, txq, &bf_head, false);
-	TX_STAT_INC(txq->axq_qnum, queued);
+	ath_tx_fill_desc(sc, bf, hwq, fi->framelen);
+	ath_tx_hwqaddbuf(sc, hwq, &bf_head, false);
+	TX_STAT_INC(hwq->axq_qnum, queued);
 }
 
 static void setup_frame_info(struct ieee80211_hw *hw,
@@ -2122,7 +2122,7 @@ static void setup_frame_info(struct ieee80211_hw *hw,
 	}
 
 	memset(fi, 0, sizeof(*fi));
-	fi->txq = -1;
+	fi->hwq = -1;
 	if (hw_key)
 		fi->keyix = hw_key->hw_key_idx;
 	else if (an && ieee80211_is_data(hdr->frame_control) && an->ps_key > 0)
@@ -2160,7 +2160,7 @@ u8 ath_txchainmask_reduction(struct ath_softc *sc, u8 chainmask, u32 rate)
  * and map buffer for DMA. Frees skb on error
  */
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
-					   struct ath_txq *txq,
+					   struct ath_hwq *hwq,
 					   struct ath_atx_tid *tid,
 					   struct sk_buff *skb)
 {
@@ -2290,7 +2290,7 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ath_frame_info *fi = get_frame_info(skb);
 	struct ath_vif *avp = NULL;
 	struct ath_softc *sc = hw->priv;
-	struct ath_txq *txq = txctl->txq;
+	struct ath_hwq *hwq = txctl->hwq;
 	struct ath_atx_tid *tid = NULL;
 	struct ath_buf *bf;
 	bool queue, skip_uapsd = false, ps_resp;
@@ -2316,16 +2316,16 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	q = skb_get_queue_mapping(skb);
 
-	ath_txq_lock(sc, txq);
-	if (txq == sc->tx.txq_map[q]) {
-		fi->txq = q;
-		if (++txq->pending_frames > sc->tx.txq_max_pending[q] &&
-		    !txq->stopped) {
+	ath_hwq_lock(sc, hwq);
+	if (hwq == sc->tx.hwq_map[q]) {
+		fi->hwq = q;
+		if (++hwq->pending_frames > sc->tx.hwq_max_pending[q] &&
+		    !hwq->stopped) {
 			if (ath9k_is_chanctx_enabled())
 				ieee80211_stop_queue(sc->hw, info->hw_queue);
 			else
 				ieee80211_stop_queue(sc->hw, q);
-			txq->stopped = true;
+			hwq->stopped = true;
 		}
 	}
 
@@ -2353,11 +2353,11 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 		tid = ath_get_skb_tid(sc, txctl->an, skb);
 
 	if (!skip_uapsd && ps_resp) {
-		ath_txq_unlock(sc, txq);
-		txq = sc->tx.uapsdq;
-		ath_txq_lock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
+		hwq = sc->tx.uapsdq;
+		ath_hwq_lock(sc, hwq);
 	} else if (txctl->an && queue) {
-		WARN_ON(tid->txq != txctl->txq);
+		WARN_ON(tid->hwq != txctl->hwq);
 
 		if (info->flags & IEEE80211_TX_CTL_CLEAR_PS_FILT)
 			tid->clear_ps_filter = true;
@@ -2366,18 +2366,18 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 		 * Add this frame to software queue for scheduling later
 		 * for aggregation.
 		 */
-		TX_STAT_INC(txq->axq_qnum, a_queued_sw);
+		TX_STAT_INC(hwq->axq_qnum, a_queued_sw);
 		__skb_queue_tail(&tid->buf_q, skb);
 		if (!txctl->an->sleeping)
-			ath_tx_queue_tid(sc, txq, tid);
+			ath_tx_queue_tid(sc, hwq, tid);
 
-		ath_txq_schedule(sc, txq);
+		ath_hwq_schedule(sc, hwq);
 		goto out;
 	}
 
-	bf = ath_tx_setup_buffer(sc, txq, tid, skb);
+	bf = ath_tx_setup_buffer(sc, hwq, tid, skb);
 	if (!bf) {
-		ath_txq_skb_done(sc, txq, skb);
+		ath_hwq_skb_done(sc, hwq, skb);
 		if (txctl->paprd)
 			dev_kfree_skb_any(skb);
 		else
@@ -2391,10 +2391,10 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 		bf->bf_state.bfs_paprd_timestamp = jiffies;
 
 	ath_set_rates(vif, sta, bf);
-	ath_tx_send_normal(sc, txq, tid, skb);
+	ath_tx_send_normal(sc, hwq, tid, skb);
 
 out:
-	ath_txq_unlock(sc, txq);
+	ath_hwq_unlock(sc, hwq);
 
 	return 0;
 }
@@ -2404,7 +2404,7 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 {
 	struct ath_softc *sc = hw->priv;
 	struct ath_tx_control txctl = {
-		.txq = sc->beacon.cabq
+		.hwq = sc->beacon.cabq
 	};
 	struct ath_tx_info info = {};
 	struct ieee80211_hdr *hdr;
@@ -2424,7 +2424,7 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 		if (ath_tx_prepare(hw, skb, &txctl))
 			break;
 
-		bf = ath_tx_setup_buffer(sc, txctl.txq, NULL, skb);
+		bf = ath_tx_setup_buffer(sc, txctl.hwq, NULL, skb);
 		if (!bf)
 			break;
 
@@ -2460,11 +2460,11 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 			sizeof(*hdr), DMA_TO_DEVICE);
 	}
 
-	ath_txq_lock(sc, txctl.txq);
-	ath_tx_fill_desc(sc, bf, txctl.txq, 0);
-	ath_tx_txqaddbuf(sc, txctl.txq, &bf_q, false);
-	TX_STAT_INC(txctl.txq->axq_qnum, queued);
-	ath_txq_unlock(sc, txctl.txq);
+	ath_hwq_lock(sc, txctl.hwq);
+	ath_tx_fill_desc(sc, bf, txctl.hwq, 0);
+	ath_tx_hwqaddbuf(sc, txctl.hwq, &bf_q, false);
+	TX_STAT_INC(txctl.hwq->axq_qnum, queued);
+	ath_hwq_unlock(sc, txctl.hwq);
 }
 
 /*****************/
@@ -2472,7 +2472,7 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 /*****************/
 
 static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
-			    int tx_flags, struct ath_txq *txq)
+			    int tx_flags, struct ath_hwq *hwq)
 {
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
@@ -2504,7 +2504,7 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 	}
 
 	spin_lock_irqsave(&sc->sc_pm_lock, flags);
-	if ((sc->ps_flags & PS_WAIT_FOR_TX_ACK) && !txq->axq_depth) {
+	if ((sc->ps_flags & PS_WAIT_FOR_TX_ACK) && !hwq->axq_depth) {
 		sc->ps_flags &= ~PS_WAIT_FOR_TX_ACK;
 		ath_dbg(common, PS,
 			"Going back to sleep after having received TX status (0x%lx)\n",
@@ -2515,12 +2515,12 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 	}
 	spin_unlock_irqrestore(&sc->sc_pm_lock, flags);
 
-	__skb_queue_tail(&txq->complete_q, skb);
-	ath_txq_skb_done(sc, txq, skb);
+	__skb_queue_tail(&hwq->complete_q, skb);
+	ath_hwq_skb_done(sc, hwq, skb);
 }
 
 static void ath_tx_complete_buf(struct ath_softc *sc, struct ath_buf *bf,
-				struct ath_txq *txq, struct list_head *bf_q,
+				struct ath_hwq *hwq, struct list_head *bf_q,
 				struct ath_tx_status *ts, int txok)
 {
 	struct sk_buff *skb = bf->bf_mpdu;
@@ -2547,8 +2547,8 @@ static void ath_tx_complete_buf(struct ath_softc *sc, struct ath_buf *bf,
 		else
 			complete(&sc->paprd_complete);
 	} else {
-		ath_debug_stat_tx(sc, bf, ts, txq, tx_flags);
-		ath_tx_complete(sc, skb, tx_flags, txq);
+		ath_debug_stat_tx(sc, bf, ts, hwq, tx_flags);
+		ath_tx_complete(sc, skb, tx_flags, hwq);
 	}
 skip_tx_complete:
 	/* At this point, skb (bf->bf_mpdu) is consumed...make sure we don't
@@ -2619,7 +2619,7 @@ static void ath_tx_rc_status(struct ath_softc *sc, struct ath_buf *bf,
 	tx_info->status.rates[tx_rateindex].count = ts->ts_longretry + 1;
 }
 
-static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
+static void ath_tx_processq(struct ath_softc *sc, struct ath_hwq *hwq)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
@@ -2630,20 +2630,20 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 	int status;
 
 	ath_dbg(common, QUEUE, "tx queue %d (%x), link %p\n",
-		txq->axq_qnum, ath9k_hw_gettxbuf(sc->sc_ah, txq->axq_qnum),
-		txq->axq_link);
+		hwq->axq_qnum, ath9k_hw_gettxbuf(sc->sc_ah, hwq->axq_qnum),
+		hwq->axq_link);
 
-	ath_txq_lock(sc, txq);
+	ath_hwq_lock(sc, hwq);
 	for (;;) {
 		if (test_bit(ATH_OP_HW_RESET, &common->op_flags))
 			break;
 
-		if (list_empty(&txq->axq_q)) {
-			txq->axq_link = NULL;
-			ath_txq_schedule(sc, txq);
+		if (list_empty(&hwq->axq_q)) {
+			hwq->axq_link = NULL;
+			ath_hwq_schedule(sc, hwq);
 			break;
 		}
-		bf = list_first_entry(&txq->axq_q, struct ath_buf, list);
+		bf = list_first_entry(&hwq->axq_q, struct ath_buf, list);
 
 		/*
 		 * There is a race condition that a BH gets scheduled
@@ -2656,7 +2656,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 		bf_held = NULL;
 		if (bf->bf_state.stale) {
 			bf_held = bf;
-			if (list_is_last(&bf_held->list, &txq->axq_q))
+			if (list_is_last(&bf_held->list, &hwq->axq_q))
 				break;
 
 			bf = list_entry(bf_held->list.next, struct ath_buf,
@@ -2671,10 +2671,10 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 		if (status == -EINPROGRESS)
 			break;
 
-		TX_STAT_INC(txq->axq_qnum, txprocdesc);
+		TX_STAT_INC(hwq->axq_qnum, txprocdesc);
 
 		/*
-		 * Remove ath_buf's of the same transmit unit from txq,
+		 * Remove ath_buf's of the same transmit unit from hwq,
 		 * however leave the last descriptor back as the holding
 		 * descriptor for hw.
 		 */
@@ -2682,16 +2682,16 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 		INIT_LIST_HEAD(&bf_head);
 		if (!list_is_singular(&lastbf->list))
 			list_cut_position(&bf_head,
-				&txq->axq_q, lastbf->list.prev);
+				&hwq->axq_q, lastbf->list.prev);
 
 		if (bf_held) {
 			list_del(&bf_held->list);
 			ath_tx_return_buffer(sc, bf_held);
 		}
 
-		ath_tx_process_buffer(sc, txq, &ts, bf, &bf_head);
+		ath_tx_process_buffer(sc, hwq, &ts, bf, &bf_head);
 	}
-	ath_txq_unlock_complete(sc, txq);
+	ath_hwq_unlock_complete(sc, hwq);
 }
 
 void ath_tx_tasklet(struct ath_softc *sc)
@@ -2701,8 +2701,8 @@ void ath_tx_tasklet(struct ath_softc *sc)
 	int i;
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (ATH_TXQ_SETUP(sc, i) && (qcumask & (1 << i)))
-			ath_tx_processq(sc, &sc->tx.txq[i]);
+		if (ATH_HWQ_SETUP(sc, i) && (qcumask & (1 << i)))
+			ath_tx_processq(sc, &sc->tx.hwq[i]);
 	}
 }
 
@@ -2711,7 +2711,7 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 	struct ath_tx_status ts;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_hw *ah = sc->sc_ah;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	struct ath_buf *bf, *lastbf;
 	struct list_head bf_head;
 	struct list_head *fifo_list;
@@ -2743,15 +2743,15 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 			continue;
 		}
 
-		txq = &sc->tx.txq[ts.qid];
+		hwq = &sc->tx.hwq[ts.qid];
 
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 
-		TX_STAT_INC(txq->axq_qnum, txprocdesc);
+		TX_STAT_INC(hwq->axq_qnum, txprocdesc);
 
-		fifo_list = &txq->txq_fifo[txq->txq_tailidx];
+		fifo_list = &hwq->hwq_fifo[hwq->hwq_tailidx];
 		if (list_empty(fifo_list)) {
-			ath_txq_unlock(sc, txq);
+			ath_hwq_unlock(sc, hwq);
 			return;
 		}
 
@@ -2767,15 +2767,15 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 		INIT_LIST_HEAD(&bf_head);
 		if (list_is_last(&lastbf->list, fifo_list)) {
 			list_splice_tail_init(fifo_list, &bf_head);
-			INCR(txq->txq_tailidx, ATH_TXFIFO_DEPTH);
+			INCR(hwq->hwq_tailidx, ATH_TXFIFO_DEPTH);
 
-			if (!list_empty(&txq->axq_q)) {
+			if (!list_empty(&hwq->axq_q)) {
 				struct list_head bf_q;
 
 				INIT_LIST_HEAD(&bf_q);
-				txq->axq_link = NULL;
-				list_splice_tail_init(&txq->axq_q, &bf_q);
-				ath_tx_txqaddbuf(sc, txq, &bf_q, true);
+				hwq->axq_link = NULL;
+				list_splice_tail_init(&hwq->axq_q, &bf_q);
+				ath_tx_hwqaddbuf(sc, hwq, &bf_q, true);
 			}
 		} else {
 			lastbf->bf_state.stale = true;
@@ -2784,8 +2784,8 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 						  lastbf->list.prev);
 		}
 
-		ath_tx_process_buffer(sc, txq, &ts, bf, &bf_head);
-		ath_txq_unlock_complete(sc, txq);
+		ath_tx_process_buffer(sc, hwq, &ts, bf, &bf_head);
+		ath_hwq_unlock_complete(sc, hwq);
 	}
 }
 
@@ -2870,30 +2870,30 @@ void ath_tx_node_init(struct ath_softc *sc, struct ath_node *an)
 		__skb_queue_head_init(&tid->retry_q);
 		INIT_LIST_HEAD(&tid->list);
 		acno = TID_TO_WME_AC(tidno);
-		tid->txq = sc->tx.txq_map[acno];
+		tid->hwq = sc->tx.hwq_map[acno];
 	}
 }
 
 void ath_tx_node_cleanup(struct ath_softc *sc, struct ath_node *an)
 {
 	struct ath_atx_tid *tid;
-	struct ath_txq *txq;
+	struct ath_hwq *hwq;
 	int tidno;
 
 	for (tidno = 0, tid = &an->tid[tidno];
 	     tidno < IEEE80211_NUM_TIDS; tidno++, tid++) {
 
-		txq = tid->txq;
+		hwq = tid->hwq;
 
-		ath_txq_lock(sc, txq);
+		ath_hwq_lock(sc, hwq);
 
 		if (!list_empty(&tid->list))
 			list_del_init(&tid->list);
 
-		ath_tid_drain(sc, txq, tid);
+		ath_tid_drain(sc, hwq, tid);
 		tid->active = false;
 
-		ath_txq_unlock(sc, txq);
+		ath_hwq_unlock(sc, hwq);
 	}
 }
 
@@ -2926,7 +2926,7 @@ int ath9k_tx99_send(struct ath_softc *sc, struct sk_buff *skb,
 	fi->framelen = skb->len + FCS_LEN;
 	fi->keytype = ATH9K_KEY_TYPE_CLEAR;
 
-	bf = ath_tx_setup_buffer(sc, txctl->txq, NULL, skb);
+	bf = ath_tx_setup_buffer(sc, txctl->hwq, NULL, skb);
 	if (!bf) {
 		ath_dbg(common, XMIT, "tx99 buffer setup failed\n");
 		return -EINVAL;
@@ -2935,9 +2935,9 @@ int ath9k_tx99_send(struct ath_softc *sc, struct sk_buff *skb,
 	ath_set_rates(sc->tx99_vif, NULL, bf);
 
 	ath9k_hw_set_desc_link(sc->sc_ah, bf->bf_desc, bf->bf_daddr);
-	ath9k_hw_tx99_start(sc->sc_ah, txctl->txq->axq_qnum);
+	ath9k_hw_tx99_start(sc->sc_ah, txctl->hwq->axq_qnum);
 
-	ath_tx_send_normal(sc, txctl->txq, NULL, skb);
+	ath_tx_send_normal(sc, txctl->hwq, NULL, skb);
 
 	return 0;
 }
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
