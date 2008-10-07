From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-10-06
Date: Mon, 6 Oct 2008 23:00:23 -0400
Message-ID: <20081007030013.GQ3448@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44857 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbYJGDBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 23:01:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest round of wireless updates intended for 2.6.28.  There
are a couple of merge damage fixups, a new rate scaling algorithm for
mac80211, and some miscellaneous drivers fixes and such.

Let me know if there are problems!

Thanks,

John

P.S.  One of the merge fixups shows-up as from Linus -- I guess this
is technically correct since I just cherry-picked the original revert
which had been lost...

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit c7004482e8dcb7c3c72666395cfa98a216a4fb70:
  David S. Miller (1):
        tcp: Respect SO_RCVLOWAT in tcp_poll().

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Christian Lamparter (1):
      p54: report appropriate rate and band values for 802.11a

Davide Pesavento (1):
      wireless: fix typo in Kconfig.

Felix Fietkau (4):
      mac80211: free up 2 bytes in skb->cb
      mac80211: add multi-rate retry support
      ath5k: implement multi-rate retry support, fix tx status reporting
      mac80211: add the 'minstrel' rate control algorithm

Gertjan van Wingerde (1):
      rt2x00: Fix rfkill structure initialization to prevent rfkill WARN_ON.

Henrique de Moraes Holschuh (1):
      rfkill: update LEDs for all state changes

John W. Linville (2):
      ath9k: fixup some merge damage
      mac80211: avoid "Wireless Event too big" message for assoc response

Linus Torvalds (1):
      wireless: restore revert lost to merge damage

Luis R. Rodriguez (3):
      ath9k: kill ath9k's memzero() and use memset() instead
      ath9k: fix oops on trying to hold the wrong spinlock
      ath9k: enable ANI to help with noisy environments

Rami Rosen (1):
      mac80211: remove redundant check in ieee80211_master_start_xmit (net/mac80211/tx.c)

Tomas Winkler (4):
      mac80211: remove shadowed variables in ieee80211_master_start_xmit
      iwlwifi: scan correct setting of valid rx_chains
      iwlwifi: scan fix comment
      iwlwifi: remove STATUS_CONF_PENDING in scanning

 drivers/net/wireless/ath5k/ath5k.h         |    4 +-
 drivers/net/wireless/ath5k/base.c          |   50 +++-
 drivers/net/wireless/ath5k/desc.c          |   69 +++-
 drivers/net/wireless/ath9k/ath9k.h         |    2 +-
 drivers/net/wireless/ath9k/beacon.c        |    8 +-
 drivers/net/wireless/ath9k/core.c          |  145 ++++++-
 drivers/net/wireless/ath9k/core.h          |   32 ++-
 drivers/net/wireless/ath9k/hw.c            |   35 ++-
 drivers/net/wireless/ath9k/main.c          |   18 +-
 drivers/net/wireless/ath9k/recv.c          |   17 +-
 drivers/net/wireless/ath9k/xmit.c          |   12 +-
 drivers/net/wireless/b43/main.c            |    1 +
 drivers/net/wireless/b43/xmit.c            |    6 +-
 drivers/net/wireless/b43legacy/main.c      |    1 +
 drivers/net/wireless/b43legacy/xmit.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c     |   28 --
 drivers/net/wireless/iwlwifi/iwl-core.h    |    3 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c    |   28 ++-
 drivers/net/wireless/p54/p54common.c       |    5 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c  |    7 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c |    9 +-
 drivers/net/wireless/rtl8180_dev.c         |    5 +-
 include/net/mac80211.h                     |   33 ++-
 net/mac80211/Kconfig                       |   13 +
 net/mac80211/Makefile                      |    4 +
 net/mac80211/key.c                         |   14 +
 net/mac80211/main.c                        |    5 +
 net/mac80211/mlme.c                        |   47 ++-
 net/mac80211/rate.h                        |   14 +
 net/mac80211/rc80211_minstrel.c            |  583 ++++++++++++++++++++++++++++
 net/mac80211/rc80211_minstrel.h            |   85 ++++
 net/mac80211/rc80211_minstrel_debugfs.c    |  164 ++++++++
 net/mac80211/tx.c                          |   36 +-
 net/mac80211/wep.c                         |    3 -
 net/mac80211/wpa.c                         |    6 -
 net/rfkill/rfkill.c                        |    5 +-
 net/wireless/Kconfig                       |    2 +-
 38 files changed, 1335 insertions(+), 174 deletions(-)
 create mode 100644 net/mac80211/rc80211_minstrel.c
 create mode 100644 net/mac80211/rc80211_minstrel.h
 create mode 100644 net/mac80211/rc80211_minstrel_debugfs.c

diff --git a/drivers/net/wireless/ath5k/ath5k.h b/drivers/net/wireless/ath5k/ath5k.h
index 7134c40..53ea439 100644
--- a/drivers/net/wireless/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath5k/ath5k.h
@@ -431,7 +431,9 @@ struct ath5k_tx_status {
 	u16	ts_seqnum;
 	u16	ts_tstamp;
 	u8	ts_status;
-	u8	ts_rate;
+	u8	ts_rate[4];
+	u8	ts_retry[4];
+	u8	ts_final_idx;
 	s8	ts_rssi;
 	u8	ts_shortretry;
 	u8	ts_longretry;
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index c151588..9b95c40 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -541,6 +541,12 @@ ath5k_pci_probe(struct pci_dev *pdev,
 		goto err_irq;
 	}
 
+	/* set up multi-rate retry capabilities */
+	if (sc->ah->ah_version == AR5K_AR5212) {
+		hw->max_altrates = 3;
+		hw->max_altrate_tries = 11;
+	}
+
 	/* Finish private driver data initialization */
 	ret = ath5k_attach(pdev, hw);
 	if (ret)
@@ -1173,7 +1179,9 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 	struct sk_buff *skb = bf->skb;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	unsigned int pktlen, flags, keyidx = AR5K_TXKEYIX_INVALID;
-	int ret;
+	struct ieee80211_rate *rate;
+	unsigned int mrr_rate[3], mrr_tries[3];
+	int i, ret;
 
 	flags = AR5K_TXDESC_INTREQ | AR5K_TXDESC_CLRDMASK;
 
@@ -1188,7 +1196,7 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 
 	if (info->control.hw_key) {
 		keyidx = info->control.hw_key->hw_key_idx;
-		pktlen += info->control.icv_len;
+		pktlen += info->control.hw_key->icv_len;
 	}
 	ret = ah->ah_setup_tx_desc(ah, ds, pktlen,
 		ieee80211_get_hdrlen_from_skb(skb), AR5K_PKT_TYPE_NORMAL,
@@ -1198,6 +1206,22 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 	if (ret)
 		goto err_unmap;
 
+	memset(mrr_rate, 0, sizeof(mrr_rate));
+	memset(mrr_tries, 0, sizeof(mrr_tries));
+	for (i = 0; i < 3; i++) {
+		rate = ieee80211_get_alt_retry_rate(sc->hw, info, i);
+		if (!rate)
+			break;
+
+		mrr_rate[i] = rate->hw_value;
+		mrr_tries[i] = info->control.retries[i].limit;
+	}
+
+	ah->ah_setup_mrr_tx_desc(ah, ds,
+		mrr_rate[0], mrr_tries[0],
+		mrr_rate[1], mrr_tries[1],
+		mrr_rate[2], mrr_tries[2]);
+
 	ds->ds_link = 0;
 	ds->ds_data = bf->skbaddr;
 
@@ -1814,7 +1838,7 @@ ath5k_tx_processq(struct ath5k_softc *sc, struct ath5k_txq *txq)
 	struct ath5k_desc *ds;
 	struct sk_buff *skb;
 	struct ieee80211_tx_info *info;
-	int ret;
+	int i, ret;
 
 	spin_lock(&txq->lock);
 	list_for_each_entry_safe(bf, bf0, &txq->q, list) {
@@ -1836,7 +1860,25 @@ ath5k_tx_processq(struct ath5k_softc *sc, struct ath5k_txq *txq)
 		pci_unmap_single(sc->pdev, bf->skbaddr, skb->len,
 				PCI_DMA_TODEVICE);
 
-		info->status.retry_count = ts.ts_shortretry + ts.ts_longretry / 6;
+		memset(&info->status, 0, sizeof(info->status));
+		info->tx_rate_idx = ath5k_hw_to_driver_rix(sc,
+				ts.ts_rate[ts.ts_final_idx]);
+		info->status.retry_count = ts.ts_longretry;
+
+		for (i = 0; i < 4; i++) {
+			struct ieee80211_tx_altrate *r =
+				&info->status.retries[i];
+
+			if (ts.ts_rate[i]) {
+				r->rate_idx = ath5k_hw_to_driver_rix(sc, ts.ts_rate[i]);
+				r->limit = ts.ts_retry[i];
+			} else {
+				r->rate_idx = -1;
+				r->limit = 0;
+			}
+		}
+
+		info->status.excessive_retries = 0;
 		if (unlikely(ts.ts_status)) {
 			sc->ll_stats.dot11ACKFailureCount++;
 			if (ts.ts_status & AR5K_TXERR_XRETRY)
diff --git a/drivers/net/wireless/ath5k/desc.c b/drivers/net/wireless/ath5k/desc.c
index d45b90a..dd13740 100644
--- a/drivers/net/wireless/ath5k/desc.c
+++ b/drivers/net/wireless/ath5k/desc.c
@@ -318,6 +318,15 @@ ath5k_hw_setup_mrr_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
 	return 0;
 }
 
+/* no mrr support for cards older than 5212 */
+static int
+ath5k_hw_setup_no_mrr(struct ath5k_hw *ah, struct ath5k_desc *desc,
+	unsigned int tx_rate1, u_int tx_tries1, u_int tx_rate2,
+	u_int tx_tries2, unsigned int tx_rate3, u_int tx_tries3)
+{
+	return 0;
+}
+
 /*
  * Proccess the tx status descriptor on 5210/5211
  */
@@ -352,8 +361,10 @@ static int ath5k_hw_proc_2word_tx_status(struct ath5k_hw *ah,
 		AR5K_DESC_TX_STATUS1_ACK_SIG_STRENGTH);
 	ts->ts_antenna = 1;
 	ts->ts_status = 0;
-	ts->ts_rate = AR5K_REG_MS(tx_ctl->tx_control_0,
+	ts->ts_rate[0] = AR5K_REG_MS(tx_ctl->tx_control_0,
 		AR5K_2W_TX_DESC_CTL0_XMIT_RATE);
+	ts->ts_retry[0] = ts->ts_longretry;
+	ts->ts_final_idx = 0;
 
 	if (!(tx_status->tx_status_0 & AR5K_DESC_TX_STATUS0_FRAME_XMIT_OK)) {
 		if (tx_status->tx_status_0 &
@@ -405,29 +416,43 @@ static int ath5k_hw_proc_4word_tx_status(struct ath5k_hw *ah,
 		AR5K_DESC_TX_STATUS1_XMIT_ANTENNA) ? 2 : 1;
 	ts->ts_status = 0;
 
-	switch (AR5K_REG_MS(tx_status->tx_status_1,
-			AR5K_DESC_TX_STATUS1_FINAL_TS_INDEX)) {
-	case 0:
-		ts->ts_rate = tx_ctl->tx_control_3 &
-			AR5K_4W_TX_DESC_CTL3_XMIT_RATE0;
-		break;
+	ts->ts_final_idx = AR5K_REG_MS(tx_status->tx_status_1,
+			AR5K_DESC_TX_STATUS1_FINAL_TS_INDEX);
+
+	/* The longretry counter has the number of un-acked retries
+	 * for the final rate. To get the total number of retries
+	 * we have to add the retry counters for the other rates
+	 * as well
+	 */
+	ts->ts_retry[ts->ts_final_idx] = ts->ts_longretry;
+	switch (ts->ts_final_idx) {
+	case 3:
+		ts->ts_rate[3] = AR5K_REG_MS(tx_ctl->tx_control_3,
+			AR5K_4W_TX_DESC_CTL3_XMIT_RATE3);
+
+		ts->ts_retry[2] = AR5K_REG_MS(tx_ctl->tx_control_2,
+			AR5K_4W_TX_DESC_CTL2_XMIT_TRIES2);
+		ts->ts_longretry += ts->ts_retry[2];
+		/* fall through */
+	case 2:
+		ts->ts_rate[2] = AR5K_REG_MS(tx_ctl->tx_control_3,
+			AR5K_4W_TX_DESC_CTL3_XMIT_RATE2);
+
+		ts->ts_retry[1] = AR5K_REG_MS(tx_ctl->tx_control_2,
+			AR5K_4W_TX_DESC_CTL2_XMIT_TRIES1);
+		ts->ts_longretry += ts->ts_retry[1];
+		/* fall through */
 	case 1:
-		ts->ts_rate = AR5K_REG_MS(tx_ctl->tx_control_3,
+		ts->ts_rate[1] = AR5K_REG_MS(tx_ctl->tx_control_3,
 			AR5K_4W_TX_DESC_CTL3_XMIT_RATE1);
-		ts->ts_longretry += AR5K_REG_MS(tx_ctl->tx_control_2,
+
+		ts->ts_retry[0] = AR5K_REG_MS(tx_ctl->tx_control_2,
 			AR5K_4W_TX_DESC_CTL2_XMIT_TRIES1);
-		break;
-	case 2:
-		ts->ts_rate = AR5K_REG_MS(tx_ctl->tx_control_3,
-			AR5K_4W_TX_DESC_CTL3_XMIT_RATE2);
-		ts->ts_longretry += AR5K_REG_MS(tx_ctl->tx_control_2,
-			AR5K_4W_TX_DESC_CTL2_XMIT_TRIES2);
-		break;
-	case 3:
-		ts->ts_rate = AR5K_REG_MS(tx_ctl->tx_control_3,
-			AR5K_4W_TX_DESC_CTL3_XMIT_RATE3);
-		ts->ts_longretry += AR5K_REG_MS(tx_ctl->tx_control_2,
-			AR5K_4W_TX_DESC_CTL2_XMIT_TRIES3);
+		ts->ts_longretry += ts->ts_retry[0];
+		/* fall through */
+	case 0:
+		ts->ts_rate[0] = tx_ctl->tx_control_3 &
+			AR5K_4W_TX_DESC_CTL3_XMIT_RATE0;
 		break;
 	}
 
@@ -653,7 +678,7 @@ int ath5k_hw_init_desc_functions(struct ath5k_hw *ah)
 	} else {
 		ah->ah_setup_rx_desc = ath5k_hw_setup_rx_desc;
 		ah->ah_setup_tx_desc = ath5k_hw_setup_2word_tx_desc;
-		ah->ah_setup_mrr_tx_desc = ath5k_hw_setup_mrr_tx_desc;
+		ah->ah_setup_mrr_tx_desc = ath5k_hw_setup_no_mrr;
 		ah->ah_proc_tx_desc = ath5k_hw_proc_2word_tx_status;
 	}
 
diff --git a/drivers/net/wireless/ath9k/ath9k.h b/drivers/net/wireless/ath9k/ath9k.h
index 0e897c2..accace5 100644
--- a/drivers/net/wireless/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath9k/ath9k.h
@@ -854,7 +854,7 @@ bool ath9k_hw_calibrate(struct ath_hal *ah,
 			u8 rxchainmask,
 			bool longcal,
 			bool *isCalDone);
-int16_t ath9k_hw_getchan_noise(struct ath_hal *ah,
+s16 ath9k_hw_getchan_noise(struct ath_hal *ah,
 			       struct ath9k_channel *chan);
 void ath9k_hw_write_associd(struct ath_hal *ah, const u8 *bssid,
 			    u16 assocId);
diff --git a/drivers/net/wireless/ath9k/beacon.c b/drivers/net/wireless/ath9k/beacon.c
index eedb465..9e15c30 100644
--- a/drivers/net/wireless/ath9k/beacon.c
+++ b/drivers/net/wireless/ath9k/beacon.c
@@ -129,7 +129,7 @@ static void ath_beacon_setup(struct ath_softc *sc,
 			    ds                    /* first descriptor */
 		);
 
-	memzero(series, sizeof(struct ath9k_11n_rate_series) * 4);
+	memset(series, 0, sizeof(struct ath9k_11n_rate_series) * 4);
 	series[0].Tries = 1;
 	series[0].Rate = rate;
 	series[0].ChSel = sc->sc_tx_chainmask;
@@ -282,7 +282,7 @@ int ath_beaconq_setup(struct ath_hal *ah)
 {
 	struct ath9k_tx_queue_info qi;
 
-	memzero(&qi, sizeof(qi));
+	memset(&qi, 0, sizeof(qi));
 	qi.tqi_aifs = 1;
 	qi.tqi_cwmin = 0;
 	qi.tqi_cwmax = 0;
@@ -662,7 +662,7 @@ void ath_beacon_config(struct ath_softc *sc, int if_id)
 	else
 		av_opmode = sc->sc_ah->ah_opmode;
 
-	memzero(&conf, sizeof(struct ath_beacon_config));
+	memset(&conf, 0, sizeof(struct ath_beacon_config));
 
 	conf.beacon_interval = sc->hw->conf.beacon_int ?
 		sc->hw->conf.beacon_int : ATH_DEFAULT_BINTVAL;
@@ -738,7 +738,7 @@ void ath_beacon_config(struct ath_softc *sc, int if_id)
 			}
 		} while (nexttbtt < tsftu);
 #undef FUDGE
-		memzero(&bs, sizeof(bs));
+		memset(&bs, 0, sizeof(bs));
 		bs.bs_intval = intval;
 		bs.bs_nexttbtt = nexttbtt;
 		bs.bs_dtimperiod = dtimperiod*intval;
diff --git a/drivers/net/wireless/ath9k/core.c b/drivers/net/wireless/ath9k/core.c
index 6c433a4..c5033f6 100644
--- a/drivers/net/wireless/ath9k/core.c
+++ b/drivers/net/wireless/ath9k/core.c
@@ -65,7 +65,7 @@ static void ath_setcurmode(struct ath_softc *sc, enum wireless_mode mode)
 	for (i = 0; i < rt->rateCount; i++)
 		sc->sc_rixmap[rt->info[i].rateCode] = (u8) i;
 
-	memzero(sc->sc_hwmap, sizeof(sc->sc_hwmap));
+	memset(sc->sc_hwmap, 0, sizeof(sc->sc_hwmap));
 	for (i = 0; i < 256; i++) {
 		u8 ix = rt->rateCodeToIndex[i];
 
@@ -288,8 +288,6 @@ static int ath_stop(struct ath_softc *sc)
 	 * hardware is gone (invalid).
 	 */
 
-	if (!(sc->sc_flags & SC_OP_INVALID))
-		ath9k_hw_set_interrupts(ah, 0);
 	ath_draintxq(sc, false);
 	if (!(sc->sc_flags & SC_OP_INVALID)) {
 		ath_stoprecv(sc);
@@ -419,7 +417,7 @@ static void ath_chainmask_sel_init(struct ath_softc *sc, struct ath_node *an)
 {
 	struct ath_chainmask_sel *cm = &an->an_chainmask_sel;
 
-	memzero(cm, sizeof(struct ath_chainmask_sel));
+	memset(cm, 0, sizeof(struct ath_chainmask_sel));
 
 	cm->cur_tx_mask = sc->sc_tx_chainmask;
 	cm->cur_rx_mask = sc->sc_rx_chainmask;
@@ -492,6 +490,122 @@ void ath_update_chainmask(struct ath_softc *sc, int is_ht)
 		__func__, sc->sc_tx_chainmask, sc->sc_rx_chainmask);
 }
 
+/*******/
+/* ANI */
+/*******/
+
+/*
+ *  This routine performs the periodic noise floor calibration function
+ *  that is used to adjust and optimize the chip performance.  This
+ *  takes environmental changes (location, temperature) into account.
+ *  When the task is complete, it reschedules itself depending on the
+ *  appropriate interval that was calculated.
+ */
+
+static void ath_ani_calibrate(unsigned long data)
+{
+	struct ath_softc *sc;
+	struct ath_hal *ah;
+	bool longcal = false;
+	bool shortcal = false;
+	bool aniflag = false;
+	unsigned int timestamp = jiffies_to_msecs(jiffies);
+	u32 cal_interval;
+
+	sc = (struct ath_softc *)data;
+	ah = sc->sc_ah;
+
+	/*
+	* don't calibrate when we're scanning.
+	* we are most likely not on our home channel.
+	*/
+	if (sc->rx_filter & FIF_BCN_PRBRESP_PROMISC)
+		return;
+
+	/* Long calibration runs independently of short calibration. */
+	if ((timestamp - sc->sc_ani.sc_longcal_timer) >= ATH_LONG_CALINTERVAL) {
+		longcal = true;
+		DPRINTF(sc, ATH_DBG_ANI, "%s: longcal @%lu\n",
+			__func__, jiffies);
+		sc->sc_ani.sc_longcal_timer = timestamp;
+	}
+
+	/* Short calibration applies only while sc_caldone is false */
+	if (!sc->sc_ani.sc_caldone) {
+		if ((timestamp - sc->sc_ani.sc_shortcal_timer) >=
+		    ATH_SHORT_CALINTERVAL) {
+			shortcal = true;
+			DPRINTF(sc, ATH_DBG_ANI, "%s: shortcal @%lu\n",
+			       __func__, jiffies);
+			sc->sc_ani.sc_shortcal_timer = timestamp;
+			sc->sc_ani.sc_resetcal_timer = timestamp;
+		}
+	} else {
+		if ((timestamp - sc->sc_ani.sc_resetcal_timer) >=
+		    ATH_RESTART_CALINTERVAL) {
+			ath9k_hw_reset_calvalid(ah, ah->ah_curchan,
+						&sc->sc_ani.sc_caldone);
+			if (sc->sc_ani.sc_caldone)
+				sc->sc_ani.sc_resetcal_timer = timestamp;
+		}
+	}
+
+	/* Verify whether we must check ANI */
+	if ((timestamp - sc->sc_ani.sc_checkani_timer) >=
+	   ATH_ANI_POLLINTERVAL) {
+		aniflag = true;
+		sc->sc_ani.sc_checkani_timer = timestamp;
+	}
+
+	/* Skip all processing if there's nothing to do. */
+	if (longcal || shortcal || aniflag) {
+		/* Call ANI routine if necessary */
+		if (aniflag)
+			ath9k_hw_ani_monitor(ah, &sc->sc_halstats,
+					     ah->ah_curchan);
+
+		/* Perform calibration if necessary */
+		if (longcal || shortcal) {
+			bool iscaldone = false;
+
+			if (ath9k_hw_calibrate(ah, ah->ah_curchan,
+					       sc->sc_rx_chainmask, longcal,
+					       &iscaldone)) {
+				if (longcal)
+					sc->sc_ani.sc_noise_floor =
+						ath9k_hw_getchan_noise(ah,
+							       ah->ah_curchan);
+
+				DPRINTF(sc, ATH_DBG_ANI,
+					"%s: calibrate chan %u/%x nf: %d\n",
+					 __func__,
+					ah->ah_curchan->channel,
+					ah->ah_curchan->channelFlags,
+					sc->sc_ani.sc_noise_floor);
+			} else {
+				DPRINTF(sc, ATH_DBG_ANY,
+					"%s: calibrate chan %u/%x failed\n",
+					 __func__,
+					ah->ah_curchan->channel,
+					ah->ah_curchan->channelFlags);
+			}
+			sc->sc_ani.sc_caldone = iscaldone;
+		}
+	}
+
+	/*
+	* Set timer interval based on previous results.
+	* The interval must be the shortest necessary to satisfy ANI,
+	* short calibration and long calibration.
+	*/
+
+	cal_interval = ATH_ANI_POLLINTERVAL;
+	if (!sc->sc_ani.sc_caldone)
+		cal_interval = min(cal_interval, (u32)ATH_SHORT_CALINTERVAL);
+
+	mod_timer(&sc->sc_ani.timer, jiffies + msecs_to_jiffies(cal_interval));
+}
+
 /******************/
 /* VAP management */
 /******************/
@@ -528,7 +642,7 @@ int ath_vap_attach(struct ath_softc *sc,
 	if (avp == NULL)
 		return -ENOMEM;
 
-	memzero(avp, sizeof(struct ath_vap));
+	memset(avp, 0, sizeof(struct ath_vap));
 	avp->av_if_data = if_data;
 	/* Set the VAP opmode */
 	avp->av_opmode = opmode;
@@ -678,12 +792,6 @@ int ath_open(struct ath_softc *sc, struct ath9k_channel *initial_chan)
 	if (ah->ah_caps.hw_caps & ATH9K_HW_CAP_HT)
 		sc->sc_imask |= ATH9K_INT_CST;
 
-	/* Note: We disable MIB interrupts for now as we don't yet
-	 * handle processing ANI, otherwise you will get an interrupt
-	 * storm after about 7 hours of usage making the system unusable
-	 * with huge latency. Once we do have ANI processing included
-	 * we can re-enable this interrupt. */
-#if 0
 	/*
 	 * Enable MIB interrupts when there are hardware phy counters.
 	 * Note we only do this (at the moment) for station mode.
@@ -692,7 +800,6 @@ int ath_open(struct ath_softc *sc, struct ath9k_channel *initial_chan)
 	    ((sc->sc_ah->ah_opmode == ATH9K_M_STA) ||
 	     (sc->sc_ah->ah_opmode == ATH9K_M_IBSS)))
 		sc->sc_imask |= ATH9K_INT_MIB;
-#endif
 	/*
 	 * Some hardware processes the TIM IE and fires an
 	 * interrupt when the TIM bit is set.  For hardware
@@ -993,6 +1100,10 @@ int ath_init(u16 devid, struct ath_softc *sc)
 	}
 	sc->sc_ah = ah;
 
+	/* Initializes the noise floor to a reasonable default value.
+	 * Later on this will be updated during ANI processing. */
+	sc->sc_ani.sc_noise_floor = ATH_DEFAULT_NOISE_FLOOR;
+
 	/* Get the hardware key cache size. */
 	sc->sc_keymax = ah->ah_caps.keycache_size;
 	if (sc->sc_keymax > ATH_KEYMAX) {
@@ -1100,6 +1211,8 @@ int ath_init(u16 devid, struct ath_softc *sc)
 		goto bad2;
 	}
 
+	setup_timer(&sc->sc_ani.timer, ath_ani_calibrate, (unsigned long)sc);
+
 	sc->sc_rc = ath_rate_attach(ah);
 	if (sc->sc_rc == NULL) {
 		error = -EIO;
@@ -1221,7 +1334,7 @@ struct ath_node *ath_node_attach(struct ath_softc *sc, u8 *addr, int if_id)
 	an = kmalloc(sizeof(struct ath_node), GFP_ATOMIC);
 	if (an == NULL)
 		return NULL;
-	memzero(an, sizeof(*an));
+	memset(an, 0, sizeof(*an));
 
 	an->an_sc = sc;
 	memcpy(an->an_addr, addr, ETH_ALEN);
@@ -1608,7 +1721,7 @@ int ath_descdma_setup(struct ath_softc *sc,
 		error = -ENOMEM;
 		goto fail2;
 	}
-	memzero(bf, bsize);
+	memset(bf, 0, bsize);
 	dd->dd_bufptr = bf;
 
 	INIT_LIST_HEAD(head);
@@ -1640,7 +1753,7 @@ fail2:
 	pci_free_consistent(sc->pdev,
 		dd->dd_desc_len, dd->dd_desc, dd->dd_desc_paddr);
 fail:
-	memzero(dd, sizeof(*dd));
+	memset(dd, 0, sizeof(*dd));
 	return error;
 #undef ATH_DESC_4KB_BOUND_CHECK
 #undef ATH_DESC_4KB_BOUND_NUM_SKIPPED
@@ -1665,7 +1778,7 @@ void ath_descdma_cleanup(struct ath_softc *sc,
 
 	INIT_LIST_HEAD(head);
 	kfree(dd->dd_bufptr);
-	memzero(dd, sizeof(*dd));
+	memset(dd, 0, sizeof(*dd));
 }
 
 /*************/
diff --git a/drivers/net/wireless/ath9k/core.h b/drivers/net/wireless/ath9k/core.h
index 872f0c5..cb3e61e 100644
--- a/drivers/net/wireless/ath9k/core.h
+++ b/drivers/net/wireless/ath9k/core.h
@@ -84,9 +84,6 @@ struct ath_node;
 #define TSF_TO_TU(_h,_l) \
 	((((u32)(_h)) << 22) | (((u32)(_l)) >> 10))
 
-/* XXX: remove */
-#define memzero(_buf, _len) memset(_buf, 0, _len)
-
 #define ATH9K_BH_STATUS_INTACT		0
 #define ATH9K_BH_STATUS_CHANGE		1
 
@@ -184,7 +181,7 @@ void ath_update_chainmask(struct ath_softc *sc, int is_ht);
 		(_bf)->bf_lastbf = NULL;			\
 		(_bf)->bf_lastfrm = NULL;			\
 		(_bf)->bf_next = NULL;				\
-		memzero(&((_bf)->bf_state),			\
+		memset(&((_bf)->bf_state), 0,			\
 			    sizeof(struct ath_buf_state));	\
 	} while (0)
 
@@ -312,7 +309,7 @@ void ath_descdma_cleanup(struct ath_softc *sc,
 #define ATH_RX_TIMEOUT           40      /* 40 milliseconds */
 #define WME_NUM_TID              16
 #define IEEE80211_BAR_CTL_TID_M  0xF000  /* tid mask */
-#define IEEE80211_BAR_CTL_TID_S  2       /* tid shift */
+#define IEEE80211_BAR_CTL_TID_S  12      /* tid shift */
 
 enum ATH_RX_TYPE {
 	ATH_RX_NON_CONSUMED = 0,
@@ -803,6 +800,28 @@ void ath_slow_ant_div(struct ath_antdiv *antdiv,
 		      struct ath_rx_status *rx_stats);
 void ath_setdefantenna(void *sc, u32 antenna);
 
+/*******/
+/* ANI */
+/*******/
+
+/* ANI values for STA only.
+   FIXME: Add appropriate values for AP later */
+
+#define ATH_ANI_POLLINTERVAL    100     /* 100 milliseconds between ANI poll */
+#define ATH_SHORT_CALINTERVAL   1000    /* 1 second between calibrations */
+#define ATH_LONG_CALINTERVAL    30000   /* 30 seconds between calibrations */
+#define ATH_RESTART_CALINTERVAL 1200000 /* 20 minutes between calibrations */
+
+struct ath_ani {
+	bool sc_caldone;
+	int16_t sc_noise_floor;
+	unsigned int sc_longcal_timer;
+	unsigned int sc_shortcal_timer;
+	unsigned int sc_resetcal_timer;
+	unsigned int sc_checkani_timer;
+	struct timer_list timer;
+};
+
 /********************/
 /*   LED Control    */
 /********************/
@@ -1031,6 +1050,9 @@ struct ath_softc {
 
 	/* Rfkill */
 	struct ath_rfkill rf_kill;
+
+	/* ANI */
+	struct ath_ani sc_ani;
 };
 
 int ath_init(u16 devid, struct ath_softc *sc);
diff --git a/drivers/net/wireless/ath9k/hw.c b/drivers/net/wireless/ath9k/hw.c
index 272c758..62e44a0 100644
--- a/drivers/net/wireless/ath9k/hw.c
+++ b/drivers/net/wireless/ath9k/hw.c
@@ -329,7 +329,7 @@ static void ath9k_hw_set_defaults(struct ath_hal *ah)
 	ah->ah_config.ofdm_trig_high = 500;
 	ah->ah_config.cck_trig_high = 200;
 	ah->ah_config.cck_trig_low = 100;
-	ah->ah_config.enable_ani = 0;
+	ah->ah_config.enable_ani = 1;
 	ah->ah_config.noise_immunity_level = 4;
 	ah->ah_config.ofdm_weaksignal_det = 1;
 	ah->ah_config.cck_weaksignal_thr = 0;
@@ -8405,23 +8405,48 @@ u32 ath9k_hw_mhz2ieee(struct ath_hal *ah, u32 freq, u32 flags)
 	}
 }
 
-int16_t
+/* We can tune this as we go by monitoring really low values */
+#define ATH9K_NF_TOO_LOW	-60
+
+/* AR5416 may return very high value (like -31 dBm), in those cases the nf
+ * is incorrect and we should use the static NF value. Later we can try to
+ * find out why they are reporting these values */
+static bool ath9k_hw_nf_in_range(struct ath_hal *ah, s16 nf)
+{
+	if (nf > ATH9K_NF_TOO_LOW) {
+		DPRINTF(ah->ah_sc, ATH_DBG_NF_CAL,
+			 "%s: noise floor value detected (%d) is "
+			"lower than what we think is a "
+			"reasonable value (%d)\n",
+			 __func__, nf, ATH9K_NF_TOO_LOW);
+		return false;
+	}
+	return true;
+}
+
+s16
 ath9k_hw_getchan_noise(struct ath_hal *ah, struct ath9k_channel *chan)
 {
 	struct ath9k_channel *ichan;
+	s16 nf;
 
 	ichan = ath9k_regd_check_channel(ah, chan);
 	if (ichan == NULL) {
 		DPRINTF(ah->ah_sc, ATH_DBG_NF_CAL,
 			 "%s: invalid channel %u/0x%x; no mapping\n",
 			 __func__, chan->channel, chan->channelFlags);
-		return 0;
+		return ATH_DEFAULT_NOISE_FLOOR;
 	}
 	if (ichan->rawNoiseFloor == 0) {
 		enum wireless_mode mode = ath9k_hw_chan2wmode(ah, chan);
-		return NOISE_FLOOR[mode];
+		nf = NOISE_FLOOR[mode];
 	} else
-		return ichan->rawNoiseFloor;
+		nf = ichan->rawNoiseFloor;
+
+	if (!ath9k_hw_nf_in_range(ah, nf))
+		nf = ATH_DEFAULT_NOISE_FLOOR;
+
+	return nf;
 }
 
 bool ath9k_hw_set_tsfadjust(struct ath_hal *ah, u32 setting)
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 2caba44..7472699 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -274,10 +274,12 @@ static void ath9k_rx_prepare(struct ath_softc *sc,
 	rx_status->mactime = status->tsf;
 	rx_status->band = curchan->band;
 	rx_status->freq =  curchan->center_freq;
-	rx_status->noise = ATH_DEFAULT_NOISE_FLOOR;
+	rx_status->noise = sc->sc_ani.sc_noise_floor;
 	rx_status->signal = rx_status->noise + status->rssi;
 	rx_status->rate_idx = ath_rate2idx(sc, (status->rateKbps / 100));
 	rx_status->antenna = status->antenna;
+
+	/* XXX Fix me, 64 cannot be the max rssi value, rigure it out */
 	rx_status->qual = status->rssi * 100 / 64;
 
 	if (status->flags & ATH_RX_MIC_ERROR)
@@ -427,6 +429,11 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 		ath_rate_newstate(sc, avp);
 		/* Update ratectrl about the new state */
 		ath_rc_node_update(hw, avp->rc_node);
+
+		/* Start ANI */
+		mod_timer(&sc->sc_ani.timer,
+			jiffies + msecs_to_jiffies(ATH_ANI_POLLINTERVAL));
+
 	} else {
 		DPRINTF(sc, ATH_DBG_CONFIG,
 		"%s: Bss Info DISSOC\n", __func__);
@@ -1173,6 +1180,13 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 		return error;
 	}
 
+	if (conf->type == NL80211_IFTYPE_AP) {
+		/* TODO: is this a suitable place to start ANI for AP mode? */
+		/* Start ANI */
+		mod_timer(&sc->sc_ani.timer,
+			  jiffies + msecs_to_jiffies(ATH_ANI_POLLINTERVAL));
+	}
+
 	return 0;
 }
 
@@ -1195,6 +1209,8 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 #ifdef CONFIG_SLOW_ANT_DIV
 	ath_slow_ant_div_stop(&sc->sc_antdiv);
 #endif
+	/* Stop ANI */
+	del_timer_sync(&sc->sc_ani.timer);
 
 	/* Update ratectrl */
 	ath_rate_newstate(sc, avp);
diff --git a/drivers/net/wireless/ath9k/recv.c b/drivers/net/wireless/ath9k/recv.c
index 4982563..4983402 100644
--- a/drivers/net/wireless/ath9k/recv.c
+++ b/drivers/net/wireless/ath9k/recv.c
@@ -892,7 +892,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 
 		hdr = (struct ieee80211_hdr *)skb->data;
 		fc = hdr->frame_control;
-		memzero(&rx_status, sizeof(struct ath_recv_status));
+		memset(&rx_status, 0, sizeof(struct ath_recv_status));
 
 		if (ds->ds_rxstat.rs_more) {
 			/*
@@ -999,20 +999,11 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 				rx_status.flags |= ATH_RX_SHORT_GI;
 		}
 
-		/* sc->sc_noise_floor is only available when the station
+		/* sc_noise_floor is only available when the station
 		   attaches to an AP, so we use a default value
 		   if we are not yet attached. */
-
-		/* XXX we should use either sc->sc_noise_floor or
-		 * ath_hal_getChanNoise(ah, &sc->sc_curchan)
-		 * to calculate the noise floor.
-		 * However, the value returned by ath_hal_getChanNoise
-		 * seems to be incorrect (-31dBm on the last test),
-		 * so we will use a hard-coded value until we
-		 * figure out what is going on.
-		 */
 		rx_status.abs_rssi =
-			ds->ds_rxstat.rs_rssi + ATH_DEFAULT_NOISE_FLOOR;
+			ds->ds_rxstat.rs_rssi + sc->sc_ani.sc_noise_floor;
 
 		pci_dma_sync_single_for_cpu(sc->pdev,
 					    bf->bf_buf_addr,
@@ -1166,7 +1157,7 @@ int ath_rx_aggr_start(struct ath_softc *sc,
 		} else {
 			/* Ensure the memory is zeroed out (all internal
 			 * pointers are null) */
-			memzero(rxtid->rxbuf, ATH_TID_MAX_BUFS *
+			memset(rxtid->rxbuf, 0, ATH_TID_MAX_BUFS *
 				sizeof(struct ath_rxbuf));
 			DPRINTF(sc, ATH_DBG_AGGR,
 				"%s: Allocated @%p\n", __func__, rxtid->rxbuf);
diff --git a/drivers/net/wireless/ath9k/xmit.c b/drivers/net/wireless/ath9k/xmit.c
index 2592905..3a47579 100644
--- a/drivers/net/wireless/ath9k/xmit.c
+++ b/drivers/net/wireless/ath9k/xmit.c
@@ -237,7 +237,7 @@ static int ath_tx_prepare(struct ath_softc *sc,
 
 	if (tx_info->control.hw_key) {
 		txctl->keyix = tx_info->control.hw_key->hw_key_idx;
-		txctl->frmlen += tx_info->control.icv_len;
+		txctl->frmlen += tx_info->control.hw_key->icv_len;
 
 		if (tx_info->control.hw_key->alg == ALG_WEP)
 			txctl->keytype = ATH9K_KEY_TYPE_WEP;
@@ -729,7 +729,7 @@ static void ath_buf_set_rate(struct ath_softc *sc, struct ath_buf *bf)
 	/*
 	 * Setup HAL rate series
 	 */
-	memzero(series, sizeof(struct ath9k_11n_rate_series) * 4);
+	memset(series, 0, sizeof(struct ath9k_11n_rate_series) * 4);
 
 	for (i = 0; i < 4; i++) {
 		if (!bf->bf_rcs[i].tries)
@@ -817,7 +817,7 @@ static void ath_buf_set_rate(struct ath_softc *sc, struct ath_buf *bf)
 		 * Disable multi-rate retry when using RTS/CTS by clearing
 		 * series 1, 2 and 3.
 		 */
-		memzero(&series[1], sizeof(struct ath9k_11n_rate_series) * 3);
+		memset(&series[1], 0, sizeof(struct ath9k_11n_rate_series) * 3);
 	}
 
 	/*
@@ -930,7 +930,7 @@ static void ath_tx_complete_aggr_rifs(struct ath_softc *sc,
 					ATH_DS_BA_BITMAP(ds),
 					WME_BA_BMP_SIZE >> 3);
 			} else {
-				memzero(ba, WME_BA_BMP_SIZE >> 3);
+				memset(ba, 0, WME_BA_BMP_SIZE >> 3);
 
 				/*
 				 * AR5416 can become deaf/mute when BA
@@ -943,7 +943,7 @@ static void ath_tx_complete_aggr_rifs(struct ath_softc *sc,
 					needreset = 1;
 			}
 		} else {
-			memzero(ba, WME_BA_BMP_SIZE >> 3);
+			memset(ba, 0, WME_BA_BMP_SIZE >> 3);
 		}
 	}
 
@@ -2098,7 +2098,7 @@ struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype)
 	struct ath9k_tx_queue_info qi;
 	int qnum;
 
-	memzero(&qi, sizeof(qi));
+	memset(&qi, 0, sizeof(qi));
 	qi.tqi_subtype = subtype;
 	qi.tqi_aifs = ATH9K_TXQ_USEDEFAULT;
 	qi.tqi_cwmin = ATH9K_TXQ_USEDEFAULT;
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 3bf74e2..14c44df 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4588,6 +4588,7 @@ static int b43_wireless_init(struct ssb_device *dev)
 		BIT(NL80211_IFTYPE_ADHOC);
 
 	hw->queues = b43_modparam_qos ? 4 : 1;
+	hw->max_altrates = 1;
 	SET_IEEE80211_DEV(hw, dev->dev);
 	if (is_valid_ether_addr(sprom->et1mac))
 		SET_IEEE80211_PERM_ADDR(hw, sprom->et1mac);
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index 5e0b71c..2fabcf8 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -208,7 +208,7 @@ int b43_generate_txhdr(struct b43_wldev *dev,
 	txrate = ieee80211_get_tx_rate(dev->wl->hw, info);
 	rate = txrate ? txrate->hw_value : B43_CCK_RATE_1MB;
 	rate_ofdm = b43_is_ofdm_rate(rate);
-	fbrate = ieee80211_get_alt_retry_rate(dev->wl->hw, info) ? : txrate;
+	fbrate = ieee80211_get_alt_retry_rate(dev->wl->hw, info, 0) ? : txrate;
 	rate_fb = fbrate->hw_value;
 	rate_fb_ofdm = b43_is_ofdm_rate(rate_fb);
 
@@ -252,7 +252,7 @@ int b43_generate_txhdr(struct b43_wldev *dev,
 		}
 
 		/* Hardware appends ICV. */
-		plcp_fragment_len += info->control.icv_len;
+		plcp_fragment_len += info->control.hw_key->icv_len;
 
 		key_idx = b43_kidx_to_fw(dev, key_idx);
 		mac_ctl |= (key_idx << B43_TXH_MAC_KEYIDX_SHIFT) &
@@ -260,7 +260,7 @@ int b43_generate_txhdr(struct b43_wldev *dev,
 		mac_ctl |= (key->algorithm << B43_TXH_MAC_KEYALG_SHIFT) &
 			   B43_TXH_MAC_KEYALG;
 		wlhdr_len = ieee80211_hdrlen(fctl);
-		iv_len = min((size_t) info->control.iv_len,
+		iv_len = min((size_t) info->control.hw_key->iv_len,
 			     ARRAY_SIZE(txhdr->iv));
 		memcpy(txhdr->iv, ((u8 *) wlhdr) + wlhdr_len, iv_len);
 	}
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 9fb1421..c66d575 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3710,6 +3710,7 @@ static int b43legacy_wireless_init(struct ssb_device *dev)
 		BIT(NL80211_IFTYPE_WDS) |
 		BIT(NL80211_IFTYPE_ADHOC);
 	hw->queues = 1; /* FIXME: hardware has more queues */
+	hw->max_altrates = 1;
 	SET_IEEE80211_DEV(hw, dev->dev);
 	if (is_valid_ether_addr(sprom->et1mac))
 		SET_IEEE80211_PERM_ADDR(hw, sprom->et1mac);
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index 6835064..65e8337 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -210,7 +210,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 
 	rate = tx_rate->hw_value;
 	rate_ofdm = b43legacy_is_ofdm_rate(rate);
-	rate_fb = ieee80211_get_alt_retry_rate(dev->wl->hw, info) ? : tx_rate;
+	rate_fb = ieee80211_get_alt_retry_rate(dev->wl->hw, info, 0) ? : tx_rate;
 	rate_fb_ofdm = b43legacy_is_ofdm_rate(rate_fb->hw_value);
 
 	txhdr->mac_frame_ctl = wlhdr->frame_control;
@@ -243,7 +243,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 
 		if (key->enabled) {
 			/* Hardware appends ICV. */
-			plcp_fragment_len += info->control.icv_len;
+			plcp_fragment_len += info->control.hw_key->icv_len;
 
 			key_idx = b43legacy_kidx_to_fw(dev, key_idx);
 			mac_ctl |= (key_idx << B43legacy_TX4_MAC_KEYIDX_SHIFT) &
@@ -252,7 +252,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 				   B43legacy_TX4_MAC_KEYALG_SHIFT) &
 				   B43legacy_TX4_MAC_KEYALG;
 			wlhdr_len = ieee80211_hdrlen(wlhdr->frame_control);
-			iv_len = min((size_t)info->control.iv_len,
+			iv_len = min((size_t)info->control.hw_key->iv_len,
 				     ARRAY_SIZE(txhdr->iv));
 			memcpy(txhdr->iv, ((u8 *)wlhdr) + wlhdr_len, iv_len);
 		} else {
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 204abab..24a1aeb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2569,30 +2569,6 @@ static void iwl4965_post_associate(struct iwl_priv *priv)
 
 }
 
-static int iwl4965_mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *conf);
-
-static void iwl_bg_scan_completed(struct work_struct *work)
-{
-	struct iwl_priv *priv =
-	    container_of(work, struct iwl_priv, scan_completed);
-
-	IWL_DEBUG_SCAN("SCAN complete scan\n");
-
-	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
-		return;
-
-	if (test_bit(STATUS_CONF_PENDING, &priv->status))
-		iwl4965_mac_config(priv->hw, ieee80211_get_hw_conf(priv->hw));
-
-	ieee80211_scan_completed(priv->hw);
-
-	/* Since setting the TXPOWER may have been deferred while
-	 * performing the scan, fire one off */
-	mutex_lock(&priv->mutex);
-	iwl_set_tx_power(priv, priv->tx_power_user_lmt, true);
-	mutex_unlock(&priv->mutex);
-}
-
 /*****************************************************************************
  *
  * mac80211 entry point functions
@@ -2812,7 +2788,6 @@ static int iwl4965_mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *co
 	if (unlikely(!priv->cfg->mod_params->disable_hw_scan &&
 		     test_bit(STATUS_SCANNING, &priv->status))) {
 		IWL_DEBUG_MAC80211("leave - scanning\n");
-		set_bit(STATUS_CONF_PENDING, &priv->status);
 		mutex_unlock(&priv->mutex);
 		return 0;
 	}
@@ -2898,7 +2873,6 @@ static int iwl4965_mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *co
 	IWL_DEBUG_MAC80211("leave\n");
 
 out:
-	clear_bit(STATUS_CONF_PENDING, &priv->status);
 	mutex_unlock(&priv->mutex);
 	return ret;
 }
@@ -4117,8 +4091,6 @@ static void iwl_setup_deferred_work(struct iwl_priv *priv)
 	INIT_DELAYED_WORK(&priv->init_alive_start, iwl_bg_init_alive_start);
 	INIT_DELAYED_WORK(&priv->alive_start, iwl_bg_alive_start);
 
-	/* FIXME : remove when resolved PENDING */
-	INIT_WORK(&priv->scan_completed, iwl_bg_scan_completed);
 	iwl_setup_scan_deferred_work(priv);
 	iwl_setup_power_deferred_work(priv);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 55a4b58..288b6a8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -333,8 +333,7 @@ void iwl_dump_nic_event_log(struct iwl_priv *priv);
 #define STATUS_SCAN_HW		15
 #define STATUS_POWER_PMI	16
 #define STATUS_FW_ERROR		17
-#define STATUS_CONF_PENDING	18
-#define STATUS_MODE_PENDING	19
+#define STATUS_MODE_PENDING	18
 
 
 static inline int iwl_is_ready(struct iwl_priv *priv)
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index bf855c3..3b0bee3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -703,7 +703,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 	u16 cmd_len;
 	enum ieee80211_band band;
 	u8 n_probes = 2;
-	u8 rx_chain = 0x7; /* bitmap: ABC chains */
+	u8 rx_chain = priv->hw_params.valid_rx_ant;
 
 	conf = ieee80211_get_hw_conf(priv->hw);
 
@@ -843,7 +843,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 
 		/* Force use of chains B and C (0x6) for scan Rx for 4965
 		 * Avoid A (0x1) because of its off-channel reception on A-band.
-		 * MIMO is not used here, but value is required */
+		 */
 		if ((priv->hw_rev & CSR_HW_REV_TYPE_MSK) == CSR_HW_REV_TYPE_4965)
 			rx_chain = 0x6;
 	} else {
@@ -851,6 +851,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		goto done;
 	}
 
+	/* MIMO is not used here, but value is required */
 	scan->rx_chain = RXON_RX_CHAIN_DRIVER_FORCE_MSK |
 				cpu_to_le16((0x7 << RXON_RX_CHAIN_VALID_POS) |
 				(rx_chain << RXON_RX_CHAIN_FORCE_SEL_POS) |
@@ -915,10 +916,29 @@ static void iwl_bg_abort_scan(struct work_struct *work)
 	mutex_unlock(&priv->mutex);
 }
 
+static void iwl_bg_scan_completed(struct work_struct *work)
+{
+	struct iwl_priv *priv =
+	    container_of(work, struct iwl_priv, scan_completed);
+
+	IWL_DEBUG_SCAN("SCAN complete scan\n");
+
+	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
+		return;
+
+	ieee80211_scan_completed(priv->hw);
+
+	/* Since setting the TXPOWER may have been deferred while
+	 * performing the scan, fire one off */
+	mutex_lock(&priv->mutex);
+	iwl_set_tx_power(priv, priv->tx_power_user_lmt, true);
+	mutex_unlock(&priv->mutex);
+}
+
+
 void iwl_setup_scan_deferred_work(struct iwl_priv *priv)
 {
-	/*  FIXME: move here when resolved PENDING
-	 *  INIT_WORK(&priv->scan_completed, iwl_bg_scan_completed); */
+	INIT_WORK(&priv->scan_completed, iwl_bg_scan_completed);
 	INIT_WORK(&priv->request_scan, iwl_bg_request_scan);
 	INIT_WORK(&priv->abort_scan, iwl_bg_abort_scan);
 	INIT_DELAYED_WORK(&priv->scan_check, iwl_bg_scan_check);
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index de5e8f4..1994aa1 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -507,9 +507,10 @@ static int p54_rx_data(struct ieee80211_hw *dev, struct sk_buff *skb)
 	rx_status.noise = priv->noise;
 	/* XX correct? */
 	rx_status.qual = (100 * hdr->rssi) / 127;
-	rx_status.rate_idx = hdr->rate & 0xf;
+	rx_status.rate_idx = (dev->conf.channel->band == IEEE80211_BAND_2GHZ ?
+			hdr->rate : (hdr->rate - 4)) & 0xf;
 	rx_status.freq = freq;
-	rx_status.band = IEEE80211_BAND_2GHZ;
+	rx_status.band =  dev->conf.channel->band;
 	rx_status.antenna = hdr->antenna;
 
 	tsf32 = le32_to_cpu(hdr->tsf32);
diff --git a/drivers/net/wireless/rt2x00/rt2x00crypto.c b/drivers/net/wireless/rt2x00/rt2x00crypto.c
index e1448cf..5a858e5 100644
--- a/drivers/net/wireless/rt2x00/rt2x00crypto.c
+++ b/drivers/net/wireless/rt2x00/rt2x00crypto.c
@@ -56,10 +56,10 @@ unsigned int rt2x00crypto_tx_overhead(struct ieee80211_tx_info *tx_info)
 	 * note that these lengths should only be added when
 	 * mac80211 does not generate it.
 	 */
-	overhead += tx_info->control.icv_len;
+	overhead += key->icv_len;
 
 	if (!(key->flags & IEEE80211_KEY_FLAG_GENERATE_IV))
-		overhead += tx_info->control.iv_len;
+		overhead += key->iv_len;
 
 	if (!(key->flags & IEEE80211_KEY_FLAG_GENERATE_MMIC)) {
 		if (key->alg == ALG_TKIP)
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index b7f4fe8..1676ac4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -374,7 +374,7 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb)
 	struct queue_entry *entry = rt2x00queue_get_entry(queue, Q_INDEX);
 	struct txentry_desc txdesc;
 	struct skb_frame_desc *skbdesc;
-	unsigned int iv_len = IEEE80211_SKB_CB(skb)->control.iv_len;
+	unsigned int iv_len;
 
 	if (unlikely(rt2x00queue_full(queue)))
 		return -EINVAL;
@@ -410,8 +410,11 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb)
 	 * the frame so we can provide it to the driver seperately.
 	 */
 	if (test_bit(ENTRY_TXD_ENCRYPT, &txdesc.flags) &&
-	    !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc.flags))
+	    !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc.flags) &&
+		(IEEE80211_SKB_CB(skb)->control.hw_key != NULL)) {
+		iv_len = IEEE80211_SKB_CB(skb)->control.hw_key->iv_len;
 		rt2x00crypto_tx_remove_iv(skb, iv_len);
+	}
 
 	/*
 	 * It could be possible that the queue was corrupted and this
diff --git a/drivers/net/wireless/rt2x00/rt2x00rfkill.c b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
index 55eff58..c3f53a9 100644
--- a/drivers/net/wireless/rt2x00/rt2x00rfkill.c
+++ b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
@@ -145,10 +145,15 @@ void rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
 
 	rt2x00dev->rfkill->name = rt2x00dev->ops->name;
 	rt2x00dev->rfkill->data = rt2x00dev;
-	rt2x00dev->rfkill->state = -1;
 	rt2x00dev->rfkill->toggle_radio = rt2x00rfkill_toggle_radio;
-	if (test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags))
+	if (test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags)) {
 		rt2x00dev->rfkill->get_state = rt2x00rfkill_get_state;
+		rt2x00dev->rfkill->state =
+			rt2x00dev->ops->lib->rfkill_poll(rt2x00dev) ?
+			    RFKILL_STATE_SOFT_BLOCKED : RFKILL_STATE_UNBLOCKED;
+	} else {
+		rt2x00dev->rfkill->state = RFKILL_STATE_UNBLOCKED;
+	}
 
 	INIT_DELAYED_WORK(&rt2x00dev->rfkill_work, rt2x00rfkill_poll);
 
diff --git a/drivers/net/wireless/rtl8180_dev.c b/drivers/net/wireless/rtl8180_dev.c
index abcd641..df7e78e 100644
--- a/drivers/net/wireless/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl8180_dev.c
@@ -292,8 +292,8 @@ static int rtl8180_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 	entry->plcp_len = cpu_to_le16(plcp_len);
 	entry->tx_buf = cpu_to_le32(mapping);
 	entry->frame_len = cpu_to_le32(skb->len);
-	entry->flags2 = info->control.alt_retry_rate_idx >= 0 ?
-		ieee80211_get_alt_retry_rate(dev, info)->bitrate << 4 : 0;
+	entry->flags2 = info->control.retries[0].rate_idx >= 0 ?
+		ieee80211_get_alt_retry_rate(dev, info, 0)->bitrate << 4 : 0;
 	entry->retry_limit = info->control.retry_limit;
 	entry->flags = cpu_to_le32(tx_flags);
 	__skb_queue_tail(&ring->queue, skb);
@@ -855,6 +855,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 	priv = dev->priv;
 	priv->pdev = pdev;
 
+	dev->max_altrates = 1;
 	SET_IEEE80211_DEV(dev, &pdev->dev);
 	pci_set_drvdata(pdev, dev);
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index f5f5b1f..5617a16 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -292,6 +292,20 @@ enum mac80211_tx_control_flags {
 #define IEEE80211_TX_INFO_DRIVER_DATA_PTRS \
 	(IEEE80211_TX_INFO_DRIVER_DATA_SIZE / sizeof(void *))
 
+/* maximum number of alternate rate retry stages */
+#define IEEE80211_TX_MAX_ALTRATE	3
+
+/**
+ * struct ieee80211_tx_altrate - alternate rate selection/status
+ *
+ * @rate_idx: rate index to attempt to send with
+ * @limit: number of retries before fallback
+ */
+struct ieee80211_tx_altrate {
+	s8 rate_idx;
+	u8 limit;
+};
+
 /**
  * struct ieee80211_tx_info - skb transmit information
  *
@@ -335,14 +349,14 @@ struct ieee80211_tx_info {
 			struct ieee80211_key_conf *hw_key;
 			struct ieee80211_sta *sta;
 			unsigned long jiffies;
-			s8 rts_cts_rate_idx, alt_retry_rate_idx;
+			s8 rts_cts_rate_idx;
 			u8 retry_limit;
-			u8 icv_len;
-			u8 iv_len;
+			struct ieee80211_tx_altrate retries[IEEE80211_TX_MAX_ALTRATE];
 		} control;
 		struct {
 			u64 ampdu_ack_map;
 			int ack_signal;
+			struct ieee80211_tx_altrate retries[IEEE80211_TX_MAX_ALTRATE + 1];
 			u8 retry_count;
 			bool excessive_retries;
 			u8 ampdu_ack_len;
@@ -635,6 +649,8 @@ enum ieee80211_key_flags {
  */
 struct ieee80211_key_conf {
 	enum ieee80211_key_alg alg;
+	u8 icv_len;
+	u8 iv_len;
 	u8 hw_key_idx;
 	u8 flags;
 	s8 keyidx;
@@ -828,6 +844,9 @@ enum ieee80211_hw_flags {
  *	within &struct ieee80211_vif.
  * @sta_data_size: size (in bytes) of the drv_priv data area
  *	within &struct ieee80211_sta.
+ *
+ * @max_altrates: maximum number of alternate rate retry stages
+ * @max_altrate_tries: maximum number of tries for each stage
  */
 struct ieee80211_hw {
 	struct ieee80211_conf conf;
@@ -844,6 +863,8 @@ struct ieee80211_hw {
 	u16 ampdu_queues;
 	u16 max_listen_interval;
 	s8 max_signal;
+	u8 max_altrates;
+	u8 max_altrate_tries;
 };
 
 struct ieee80211_hw *wiphy_to_hw(struct wiphy *wiphy);
@@ -900,11 +921,11 @@ ieee80211_get_rts_cts_rate(const struct ieee80211_hw *hw,
 
 static inline struct ieee80211_rate *
 ieee80211_get_alt_retry_rate(const struct ieee80211_hw *hw,
-			     const struct ieee80211_tx_info *c)
+			     const struct ieee80211_tx_info *c, int idx)
 {
-	if (c->control.alt_retry_rate_idx < 0)
+	if (c->control.retries[idx].rate_idx < 0)
 		return NULL;
-	return &hw->wiphy->bands[c->band]->bitrates[c->control.alt_retry_rate_idx];
+	return &hw->wiphy->bands[c->band]->bitrates[c->control.retries[idx].rate_idx];
 }
 
 /**
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 8427518..7f710a2 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -22,6 +22,11 @@ config MAC80211_RC_PID
 	  mac80211 that uses a PID controller to select the TX
 	  rate.
 
+config MAC80211_RC_MINSTREL
+	bool "Minstrel"
+	---help---
+	  This option enables the 'minstrel' TX rate control algorithm
+
 choice
 	prompt "Default rate control algorithm"
 	default MAC80211_RC_DEFAULT_PID
@@ -39,11 +44,19 @@ config MAC80211_RC_DEFAULT_PID
 	  default rate control algorithm. You should choose
 	  this unless you know what you are doing.
 
+config MAC80211_RC_DEFAULT_MINSTREL
+	bool "Minstrel"
+	depends on MAC80211_RC_MINSTREL
+	---help---
+	  Select Minstrel as the default rate control algorithm.
+
+
 endchoice
 
 config MAC80211_RC_DEFAULT
 	string
 	default "pid" if MAC80211_RC_DEFAULT_PID
+	default "minstrel" if MAC80211_RC_DEFAULT_MINSTREL
 	default ""
 
 endmenu
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 2dc8f2b..31cfd1f 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -41,4 +41,8 @@ mac80211-$(CONFIG_MAC80211_MESH) += \
 rc80211_pid-y := rc80211_pid_algo.o
 rc80211_pid-$(CONFIG_MAC80211_DEBUGFS) += rc80211_pid_debugfs.o
 
+rc80211_minstrel-y := rc80211_minstrel.o
+rc80211_minstrel-$(CONFIG_MAC80211_DEBUGFS) += rc80211_minstrel_debugfs.o
+
 mac80211-$(CONFIG_MAC80211_RC_PID) += $(rc80211_pid-y)
+mac80211-$(CONFIG_MAC80211_RC_MINSTREL) += $(rc80211_minstrel-y)
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 57afcd3..a5b06fe 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -281,6 +281,20 @@ struct ieee80211_key *ieee80211_key_alloc(enum ieee80211_key_alg alg,
 	key->conf.alg = alg;
 	key->conf.keyidx = idx;
 	key->conf.keylen = key_len;
+	switch (alg) {
+	case ALG_WEP:
+		key->conf.iv_len = WEP_IV_LEN;
+		key->conf.icv_len = WEP_ICV_LEN;
+		break;
+	case ALG_TKIP:
+		key->conf.iv_len = TKIP_IV_LEN;
+		key->conf.icv_len = TKIP_ICV_LEN;
+		break;
+	case ALG_CCMP:
+		key->conf.iv_len = CCMP_HDR_LEN;
+		key->conf.icv_len = CCMP_MIC_LEN;
+		break;
+	}
 	memcpy(key->conf.key, key_data, key_len);
 	INIT_LIST_HEAD(&key->list);
 	INIT_LIST_HEAD(&key->todo);
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index d608c44..ae62ad4 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1015,6 +1015,10 @@ static int __init ieee80211_init(void)
 	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, driver_data) +
 	             IEEE80211_TX_INFO_DRIVER_DATA_SIZE > sizeof(skb->cb));
 
+	ret = rc80211_minstrel_init();
+	if (ret)
+		return ret;
+
 	ret = rc80211_pid_init();
 	if (ret)
 		return ret;
@@ -1027,6 +1031,7 @@ static int __init ieee80211_init(void)
 static void __exit ieee80211_exit(void)
 {
 	rc80211_pid_exit();
+	rc80211_minstrel_exit();
 
 	/*
 	 * For key todo, it'll be empty by now but the work
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e859a0a..49f86fa 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -650,20 +650,53 @@ static void ieee80211_sta_send_apinfo(struct ieee80211_sub_if_data *sdata,
 static void ieee80211_sta_send_associnfo(struct ieee80211_sub_if_data *sdata,
 					 struct ieee80211_if_sta *ifsta)
 {
+	char *buf;
+	size_t len;
+	int i;
 	union iwreq_data wrqu;
 
+	if (!ifsta->assocreq_ies && !ifsta->assocresp_ies)
+		return;
+
+	buf = kmalloc(50 + 2 * (ifsta->assocreq_ies_len +
+				ifsta->assocresp_ies_len), GFP_KERNEL);
+	if (!buf)
+		return;
+
+	len = sprintf(buf, "ASSOCINFO(");
 	if (ifsta->assocreq_ies) {
-		memset(&wrqu, 0, sizeof(wrqu));
-		wrqu.data.length = ifsta->assocreq_ies_len;
-		wireless_send_event(sdata->dev, IWEVASSOCREQIE, &wrqu,
-				    ifsta->assocreq_ies);
+		len += sprintf(buf + len, "ReqIEs=");
+		for (i = 0; i < ifsta->assocreq_ies_len; i++) {
+			len += sprintf(buf + len, "%02x",
+				       ifsta->assocreq_ies[i]);
+		}
 	}
 	if (ifsta->assocresp_ies) {
+		if (ifsta->assocreq_ies)
+			len += sprintf(buf + len, " ");
+		len += sprintf(buf + len, "RespIEs=");
+		for (i = 0; i < ifsta->assocresp_ies_len; i++) {
+			len += sprintf(buf + len, "%02x",
+				       ifsta->assocresp_ies[i]);
+		}
+	}
+	len += sprintf(buf + len, ")");
+
+	if (len > IW_CUSTOM_MAX) {
+		len = sprintf(buf, "ASSOCRESPIE=");
+		for (i = 0; i < ifsta->assocresp_ies_len; i++) {
+			len += sprintf(buf + len, "%02x",
+				       ifsta->assocresp_ies[i]);
+		}
+	}
+
+	if (len <= IW_CUSTOM_MAX) {
 		memset(&wrqu, 0, sizeof(wrqu));
-		wrqu.data.length = ifsta->assocresp_ies_len;
-		wireless_send_event(sdata->dev, IWEVASSOCRESPIE, &wrqu,
-				    ifsta->assocresp_ies);
+		wrqu.data.length = len;
+		wireless_send_event(sdata->dev, IWEVCUSTOM, &wrqu, buf);
 	}
+
+	kfree(buf);
 }
 
 
diff --git a/net/mac80211/rate.h b/net/mac80211/rate.h
index eb94e58..d0092f8 100644
--- a/net/mac80211/rate.h
+++ b/net/mac80211/rate.h
@@ -125,4 +125,18 @@ static inline void rc80211_pid_exit(void)
 }
 #endif
 
+#ifdef CONFIG_MAC80211_RC_MINSTREL
+extern int rc80211_minstrel_init(void);
+extern void rc80211_minstrel_exit(void);
+#else
+static inline int rc80211_minstrel_init(void)
+{
+	return 0;
+}
+static inline void rc80211_minstrel_exit(void)
+{
+}
+#endif
+
+
 #endif /* IEEE80211_RATE_H */
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
new file mode 100644
index 0000000..f6d69da
--- /dev/null
+++ b/net/mac80211/rc80211_minstrel.c
@@ -0,0 +1,583 @@
+/*
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on minstrel.c:
+ *   Copyright (C) 2005-2007 Derek Smithies <derek@indranet.co.nz>
+ *   Sponsored by Indranet Technologies Ltd
+ *
+ * Based on sample.c:
+ *   Copyright (c) 2005 John Bicket
+ *   All rights reserved.
+ *
+ *   Redistribution and use in source and binary forms, with or without
+ *   modification, are permitted provided that the following conditions
+ *   are met:
+ *   1. Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer,
+ *      without modification.
+ *   2. Redistributions in binary form must reproduce at minimum a disclaimer
+ *      similar to the "NO WARRANTY" disclaimer below ("Disclaimer") and any
+ *      redistribution must be conditioned upon including a substantially
+ *      similar Disclaimer requirement for further binary redistribution.
+ *   3. Neither the names of the above-listed copyright holders nor the names
+ *      of any contributors may be used to endorse or promote products derived
+ *      from this software without specific prior written permission.
+ *
+ *   Alternatively, this software may be distributed under the terms of the
+ *   GNU General Public License ("GPL") version 2 as published by the Free
+ *   Software Foundation.
+ *
+ *   NO WARRANTY
+ *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ *   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ *   LIMITED TO, THE IMPLIED WARRANTIES OF NONINFRINGEMENT, MERCHANTIBILITY
+ *   AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
+ *   THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY,
+ *   OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
+ *   IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *   THE POSSIBILITY OF SUCH DAMAGES.
+ */
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/debugfs.h>
+#include <linux/random.h>
+#include <linux/ieee80211.h>
+#include <net/mac80211.h>
+#include "rate.h"
+#include "rc80211_minstrel.h"
+
+#define SAMPLE_COLUMNS	10
+#define SAMPLE_TBL(_mi, _idx, _col) \
+		_mi->sample_table[(_idx * SAMPLE_COLUMNS) + _col]
+
+/* convert mac80211 rate index to local array index */
+static inline int
+rix_to_ndx(struct minstrel_sta_info *mi, int rix)
+{
+	int i = rix;
+	for (i = rix; i >= 0; i--)
+		if (mi->r[i].rix == rix)
+			break;
+	WARN_ON(mi->r[i].rix != rix);
+	return i;
+}
+
+static inline bool
+use_low_rate(struct sk_buff *skb)
+{
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	u16 fc;
+
+	fc = le16_to_cpu(hdr->frame_control);
+
+	return ((info->flags & IEEE80211_TX_CTL_NO_ACK) ||
+		(fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
+		is_multicast_ether_addr(hdr->addr1));
+}
+
+
+static void
+minstrel_update_stats(struct minstrel_priv *mp, struct minstrel_sta_info *mi)
+{
+	u32 max_tp = 0, index_max_tp = 0, index_max_tp2 = 0;
+	u32 max_prob = 0, index_max_prob = 0;
+	u32 usecs;
+	u32 p;
+	int i;
+
+	mi->stats_update = jiffies;
+	for (i = 0; i < mi->n_rates; i++) {
+		struct minstrel_rate *mr = &mi->r[i];
+
+		usecs = mr->perfect_tx_time;
+		if (!usecs)
+			usecs = 1000000;
+
+		/* To avoid rounding issues, probabilities scale from 0 (0%)
+		 * to 18000 (100%) */
+		if (mr->attempts) {
+			p = (mr->success * 18000) / mr->attempts;
+			mr->succ_hist += mr->success;
+			mr->att_hist += mr->attempts;
+			mr->cur_prob = p;
+			p = ((p * (100 - mp->ewma_level)) + (mr->probability *
+				mp->ewma_level)) / 100;
+			mr->probability = p;
+			mr->cur_tp = p * (1000000 / usecs);
+		}
+
+		mr->last_success = mr->success;
+		mr->last_attempts = mr->attempts;
+		mr->success = 0;
+		mr->attempts = 0;
+
+		/* Sample less often below the 10% chance of success.
+		 * Sample less often above the 95% chance of success. */
+		if ((mr->probability > 17100) || (mr->probability < 1800)) {
+			mr->adjusted_retry_count = mr->retry_count >> 1;
+			if (mr->adjusted_retry_count > 2)
+				mr->adjusted_retry_count = 2;
+		} else {
+			mr->adjusted_retry_count = mr->retry_count;
+		}
+		if (!mr->adjusted_retry_count)
+			mr->adjusted_retry_count = 2;
+	}
+
+	for (i = 0; i < mi->n_rates; i++) {
+		struct minstrel_rate *mr = &mi->r[i];
+		if (max_tp < mr->cur_tp) {
+			index_max_tp = i;
+			max_tp = mr->cur_tp;
+		}
+		if (max_prob < mr->probability) {
+			index_max_prob = i;
+			max_prob = mr->probability;
+		}
+	}
+
+	max_tp = 0;
+	for (i = 0; i < mi->n_rates; i++) {
+		struct minstrel_rate *mr = &mi->r[i];
+
+		if (i == index_max_tp)
+			continue;
+
+		if (max_tp < mr->cur_tp) {
+			index_max_tp2 = i;
+			max_tp = mr->cur_tp;
+		}
+	}
+	mi->max_tp_rate = index_max_tp;
+	mi->max_tp_rate2 = index_max_tp2;
+	mi->max_prob_rate = index_max_prob;
+}
+
+static void
+minstrel_tx_status(void *priv, struct ieee80211_supported_band *sband,
+                   struct ieee80211_sta *sta, void *priv_sta,
+		   struct sk_buff *skb)
+{
+	struct minstrel_sta_info *mi = priv_sta;
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct ieee80211_tx_altrate *ar = info->status.retries;
+	struct minstrel_priv *mp = priv;
+	int i, ndx, tries;
+	int success = 0;
+
+	if (!info->status.excessive_retries)
+		success = 1;
+
+	if (!mp->has_mrr || (ar[0].rate_idx < 0)) {
+		ndx = rix_to_ndx(mi, info->tx_rate_idx);
+		tries = info->status.retry_count + 1;
+		mi->r[ndx].success += success;
+		mi->r[ndx].attempts += tries;
+		return;
+	}
+
+	for (i = 0; i < 4; i++) {
+		if (ar[i].rate_idx < 0)
+			break;
+
+		ndx = rix_to_ndx(mi, ar[i].rate_idx);
+		mi->r[ndx].attempts += ar[i].limit + 1;
+
+		if ((i != 3) && (ar[i + 1].rate_idx < 0))
+			mi->r[ndx].success += success;
+	}
+
+	if ((info->flags & IEEE80211_TX_CTL_RATE_CTRL_PROBE) && (i >= 0))
+		mi->sample_count++;
+
+	if (mi->sample_deferred > 0)
+		mi->sample_deferred--;
+}
+
+
+static inline unsigned int
+minstrel_get_retry_count(struct minstrel_rate *mr,
+                         struct ieee80211_tx_info *info)
+{
+	unsigned int retry = mr->adjusted_retry_count;
+
+	if (info->flags & IEEE80211_TX_CTL_USE_RTS_CTS)
+		retry = max(2U, min(mr->retry_count_rtscts, retry));
+	else if (info->flags & IEEE80211_TX_CTL_USE_CTS_PROTECT)
+		retry = max(2U, min(mr->retry_count_cts, retry));
+	return retry;
+}
+
+
+static int
+minstrel_get_next_sample(struct minstrel_sta_info *mi)
+{
+	unsigned int sample_ndx;
+	sample_ndx = SAMPLE_TBL(mi, mi->sample_idx, mi->sample_column);
+	mi->sample_idx++;
+	if (mi->sample_idx > (mi->n_rates - 2)) {
+		mi->sample_idx = 0;
+		mi->sample_column++;
+		if (mi->sample_column >= SAMPLE_COLUMNS)
+			mi->sample_column = 0;
+	}
+	return sample_ndx;
+}
+
+void
+minstrel_get_rate(void *priv, struct ieee80211_supported_band *sband,
+                  struct ieee80211_sta *sta, void *priv_sta,
+                  struct sk_buff *skb, struct rate_selection *sel)
+{
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct minstrel_sta_info *mi = priv_sta;
+	struct minstrel_priv *mp = priv;
+	struct ieee80211_tx_altrate *ar = info->control.retries;
+	unsigned int ndx, sample_ndx = 0;
+	bool mrr;
+	bool sample_slower = false;
+	bool sample = false;
+	int i, delta;
+	int mrr_ndx[3];
+	int sample_rate;
+
+	if (!sta || !mi || use_low_rate(skb)) {
+		sel->rate_idx = rate_lowest_index(sband, sta);
+		return;
+	}
+
+	mrr = mp->has_mrr;
+
+	/* mac80211 does not allow mrr for RTS/CTS */
+	if ((info->flags & IEEE80211_TX_CTL_USE_RTS_CTS) ||
+	    (info->flags & IEEE80211_TX_CTL_USE_CTS_PROTECT))
+		mrr = false;
+
+	if (time_after(jiffies, mi->stats_update + (mp->update_interval *
+			HZ) / 1000))
+		minstrel_update_stats(mp, mi);
+
+	ndx = mi->max_tp_rate;
+
+	if (mrr)
+		sample_rate = mp->lookaround_rate_mrr;
+	else
+		sample_rate = mp->lookaround_rate;
+
+	mi->packet_count++;
+	delta = (mi->packet_count * sample_rate / 100) -
+			(mi->sample_count + mi->sample_deferred / 2);
+
+	/* delta > 0: sampling required */
+	if (delta > 0) {
+		if (mi->packet_count >= 10000) {
+			mi->sample_deferred = 0;
+			mi->sample_count = 0;
+			mi->packet_count = 0;
+		} else if (delta > mi->n_rates * 2) {
+			/* With multi-rate retry, not every planned sample
+			 * attempt actually gets used, due to the way the retry
+			 * chain is set up - [max_tp,sample,prob,lowest] for
+			 * sample_rate < max_tp.
+			 *
+			 * If there's too much sampling backlog and the link
+			 * starts getting worse, minstrel would start bursting
+			 * out lots of sampling frames, which would result
+			 * in a large throughput loss. */
+			mi->sample_count += (delta - mi->n_rates * 2);
+		}
+
+		sample_ndx = minstrel_get_next_sample(mi);
+		sample = true;
+		sample_slower = mrr && (mi->r[sample_ndx].perfect_tx_time >
+			mi->r[ndx].perfect_tx_time);
+
+		if (!sample_slower) {
+			ndx = sample_ndx;
+			mi->sample_count++;
+		} else {
+			/* Only use IEEE80211_TX_CTL_RATE_CTRL_PROBE to mark
+			 * packets that have the sampling rate deferred to the
+			 * second MRR stage. Increase the sample counter only
+			 * if the deferred sample rate was actually used.
+			 * Use the sample_deferred counter to make sure that
+			 * the sampling is not done in large bursts */
+			info->flags |= IEEE80211_TX_CTL_RATE_CTRL_PROBE;
+			mi->sample_deferred++;
+		}
+	}
+	sel->rate_idx = mi->r[ndx].rix;
+	info->control.retry_limit = minstrel_get_retry_count(&mi->r[ndx], info);
+
+	if (!mrr) {
+		ar[0].rate_idx = mi->lowest_rix;
+		ar[0].limit = mp->max_retry;
+		ar[1].rate_idx = -1;
+		return;
+	}
+
+	/* MRR setup */
+	if (sample) {
+		if (sample_slower)
+			mrr_ndx[0] = sample_ndx;
+		else
+			mrr_ndx[0] = mi->max_tp_rate;
+	} else {
+		mrr_ndx[0] = mi->max_tp_rate2;
+	}
+	mrr_ndx[1] = mi->max_prob_rate;
+	mrr_ndx[2] = 0;
+	for (i = 0; i < 3; i++) {
+		ar[i].rate_idx = mi->r[mrr_ndx[i]].rix;
+		ar[i].limit = mi->r[mrr_ndx[i]].adjusted_retry_count;
+	}
+}
+
+
+static void
+calc_rate_durations(struct minstrel_sta_info *mi, struct ieee80211_local *local,
+                    struct minstrel_rate *d, struct ieee80211_rate *rate)
+{
+	int erp = !!(rate->flags & IEEE80211_RATE_ERP_G);
+
+	d->perfect_tx_time = ieee80211_frame_duration(local, 1200,
+			rate->bitrate, erp, 1);
+	d->ack_time = ieee80211_frame_duration(local, 10,
+			rate->bitrate, erp, 1);
+}
+
+static void
+init_sample_table(struct minstrel_sta_info *mi)
+{
+	unsigned int i, col, new_idx;
+	unsigned int n_srates = mi->n_rates - 1;
+	u8 rnd[8];
+
+	mi->sample_column = 0;
+	mi->sample_idx = 0;
+	memset(mi->sample_table, 0, SAMPLE_COLUMNS * mi->n_rates);
+
+	for (col = 0; col < SAMPLE_COLUMNS; col++) {
+		for (i = 0; i < n_srates; i++) {
+			get_random_bytes(rnd, sizeof(rnd));
+			new_idx = (i + rnd[i & 7]) % n_srates;
+
+			while (SAMPLE_TBL(mi, new_idx, col) != 0)
+				new_idx = (new_idx + 1) % n_srates;
+
+			/* Don't sample the slowest rate (i.e. slowest base
+			 * rate). We must presume that the slowest rate works
+			 * fine, or else other management frames will also be
+			 * failing and the link will break */
+			SAMPLE_TBL(mi, new_idx, col) = i + 1;
+		}
+	}
+}
+
+static void
+minstrel_rate_init(void *priv, struct ieee80211_supported_band *sband,
+               struct ieee80211_sta *sta, void *priv_sta)
+{
+	struct minstrel_sta_info *mi = priv_sta;
+	struct minstrel_priv *mp = priv;
+	struct minstrel_rate *mr_ctl;
+	unsigned int i, n = 0;
+	unsigned int t_slot = 9; /* FIXME: get real slot time */
+
+	mi->lowest_rix = rate_lowest_index(sband, sta);
+	mr_ctl = &mi->r[rix_to_ndx(mi, mi->lowest_rix)];
+	mi->sp_ack_dur = mr_ctl->ack_time;
+
+	for (i = 0; i < sband->n_bitrates; i++) {
+		struct minstrel_rate *mr = &mi->r[n];
+		unsigned int tx_time = 0, tx_time_cts = 0, tx_time_rtscts = 0;
+		unsigned int tx_time_single;
+		unsigned int cw = mp->cw_min;
+
+		if (!rate_supported(sta, sband->band, i))
+			continue;
+		n++;
+		memset(mr, 0, sizeof(*mr));
+
+		mr->rix = i;
+		mr->bitrate = sband->bitrates[i].bitrate / 5;
+		calc_rate_durations(mi, hw_to_local(mp->hw), mr,
+				&sband->bitrates[i]);
+
+		/* calculate maximum number of retransmissions before
+		 * fallback (based on maximum segment size) */
+		mr->retry_count = 1;
+		mr->retry_count_cts = 1;
+		mr->retry_count_rtscts = 1;
+		tx_time = mr->perfect_tx_time + mi->sp_ack_dur;
+		do {
+			/* add one retransmission */
+			tx_time_single = mr->ack_time + mr->perfect_tx_time;
+
+			/* contention window */
+			tx_time_single += t_slot + min(cw, mp->cw_max);
+			cw = (cw + 1) << 1;
+
+			tx_time += tx_time_single;
+			tx_time_cts += tx_time_single + mi->sp_ack_dur;
+			tx_time_rtscts += tx_time_single + 2 * mi->sp_ack_dur;
+			if ((tx_time_cts < mp->segment_size) &&
+				(mr->retry_count_cts < mp->max_retry))
+				mr->retry_count_cts++;
+			if ((tx_time_rtscts < mp->segment_size) &&
+				(mr->retry_count_rtscts < mp->max_retry))
+				mr->retry_count_rtscts++;
+		} while ((tx_time < mp->segment_size) &&
+				(++mr->retry_count < mp->max_retry));
+		mr->adjusted_retry_count = mr->retry_count;
+	}
+
+	for (i = n; i < sband->n_bitrates; i++) {
+		struct minstrel_rate *mr = &mi->r[i];
+		mr->rix = -1;
+	}
+
+	mi->n_rates = n;
+	mi->stats_update = jiffies;
+
+	init_sample_table(mi);
+}
+
+static void *
+minstrel_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
+{
+	struct ieee80211_supported_band *sband;
+	struct minstrel_sta_info *mi;
+	struct minstrel_priv *mp = priv;
+	struct ieee80211_hw *hw = mp->hw;
+	int max_rates = 0;
+	int i;
+
+	mi = kzalloc(sizeof(struct minstrel_sta_info), gfp);
+	if (!mi)
+		return NULL;
+
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		sband = hw->wiphy->bands[hw->conf.channel->band];
+		if (sband->n_bitrates > max_rates)
+			max_rates = sband->n_bitrates;
+	}
+
+	mi->r = kzalloc(sizeof(struct minstrel_rate) * max_rates, gfp);
+	if (!mi->r)
+		goto error;
+
+	mi->sample_table = kmalloc(SAMPLE_COLUMNS * max_rates, gfp);
+	if (!mi->sample_table)
+		goto error1;
+
+	mi->stats_update = jiffies;
+	return mi;
+
+error1:
+	kfree(mi->r);
+error:
+	kfree(mi);
+	return NULL;
+}
+
+static void
+minstrel_free_sta(void *priv, struct ieee80211_sta *sta, void *priv_sta)
+{
+	struct minstrel_sta_info *mi = priv_sta;
+
+	kfree(mi->sample_table);
+	kfree(mi->r);
+	kfree(mi);
+}
+
+static void
+minstrel_clear(void *priv)
+{
+}
+
+static void *
+minstrel_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
+{
+	struct minstrel_priv *mp;
+
+	mp = kzalloc(sizeof(struct minstrel_priv), GFP_ATOMIC);
+	if (!mp)
+		return NULL;
+
+	/* contention window settings
+	 * Just an approximation. Using the per-queue values would complicate
+	 * the calculations and is probably unnecessary */
+	mp->cw_min = 15;
+	mp->cw_max = 1023;
+
+	/* number of packets (in %) to use for sampling other rates
+	 * sample less often for non-mrr packets, because the overhead
+	 * is much higher than with mrr */
+	mp->lookaround_rate = 5;
+	mp->lookaround_rate_mrr = 10;
+
+	/* moving average weight for EWMA */
+	mp->ewma_level = 75;
+
+	/* maximum time that the hw is allowed to stay in one MRR segment */
+	mp->segment_size = 6000;
+
+	if (hw->max_altrate_tries > 0)
+		mp->max_retry = hw->max_altrate_tries;
+	else
+		/* safe default, does not necessarily have to match hw properties */
+		mp->max_retry = 7;
+
+	if (hw->max_altrates >= 3)
+		mp->has_mrr = true;
+
+	mp->hw = hw;
+	mp->update_interval = 100;
+
+	return mp;
+}
+
+static void
+minstrel_free(void *priv)
+{
+	kfree(priv);
+}
+
+static struct rate_control_ops mac80211_minstrel = {
+	.name = "minstrel",
+	.tx_status = minstrel_tx_status,
+	.get_rate = minstrel_get_rate,
+	.rate_init = minstrel_rate_init,
+	.clear = minstrel_clear,
+	.alloc = minstrel_alloc,
+	.free = minstrel_free,
+	.alloc_sta = minstrel_alloc_sta,
+	.free_sta = minstrel_free_sta,
+#ifdef CONFIG_MAC80211_DEBUGFS
+	.add_sta_debugfs = minstrel_add_sta_debugfs,
+	.remove_sta_debugfs = minstrel_remove_sta_debugfs,
+#endif
+};
+
+int __init
+rc80211_minstrel_init(void)
+{
+	return ieee80211_rate_control_register(&mac80211_minstrel);
+}
+
+void
+rc80211_minstrel_exit(void)
+{
+	ieee80211_rate_control_unregister(&mac80211_minstrel);
+}
+
diff --git a/net/mac80211/rc80211_minstrel.h b/net/mac80211/rc80211_minstrel.h
new file mode 100644
index 0000000..9a90a6a
--- /dev/null
+++ b/net/mac80211/rc80211_minstrel.h
@@ -0,0 +1,85 @@
+/*
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __RC_MINSTREL_H
+#define __RC_MINSTREL_H
+
+struct minstrel_rate {
+	int bitrate;
+	int rix;
+
+	unsigned int perfect_tx_time;
+	unsigned int ack_time;
+
+	unsigned int retry_count;
+	unsigned int retry_count_cts;
+	unsigned int retry_count_rtscts;
+	unsigned int adjusted_retry_count;
+
+	u32 success;
+	u32 attempts;
+	u32 last_attempts;
+	u32 last_success;
+
+	/* parts per thousand */
+	u32 cur_prob;
+	u32 probability;
+
+	/* per-rate throughput */
+	u32 cur_tp;
+	u32 throughput;
+
+	u64 succ_hist;
+	u64 att_hist;
+};
+
+struct minstrel_sta_info {
+	unsigned long stats_update;
+	unsigned int sp_ack_dur;
+	unsigned int rate_avg;
+
+	unsigned int lowest_rix;
+
+	unsigned int max_tp_rate;
+	unsigned int max_tp_rate2;
+	unsigned int max_prob_rate;
+	unsigned int packet_count;
+	unsigned int sample_count;
+	int sample_deferred;
+
+	unsigned int sample_idx;
+	unsigned int sample_column;
+
+	int n_rates;
+	struct minstrel_rate *r;
+
+	/* sampling table */
+	u8 *sample_table;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct dentry *dbg_stats;
+#endif
+};
+
+struct minstrel_priv {
+	struct ieee80211_hw *hw;
+	bool has_mrr;
+	unsigned int cw_min;
+	unsigned int cw_max;
+	unsigned int max_retry;
+	unsigned int ewma_level;
+	unsigned int segment_size;
+	unsigned int update_interval;
+	unsigned int lookaround_rate;
+	unsigned int lookaround_rate_mrr;
+};
+
+void minstrel_add_sta_debugfs(void *priv, void *priv_sta, struct dentry *dir);
+void minstrel_remove_sta_debugfs(void *priv, void *priv_sta);
+
+#endif
diff --git a/net/mac80211/rc80211_minstrel_debugfs.c b/net/mac80211/rc80211_minstrel_debugfs.c
new file mode 100644
index 0000000..0b024cd
--- /dev/null
+++ b/net/mac80211/rc80211_minstrel_debugfs.c
@@ -0,0 +1,164 @@
+/*
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on minstrel.c:
+ *   Copyright (C) 2005-2007 Derek Smithies <derek@indranet.co.nz>
+ *   Sponsored by Indranet Technologies Ltd
+ *
+ * Based on sample.c:
+ *   Copyright (c) 2005 John Bicket
+ *   All rights reserved.
+ *
+ *   Redistribution and use in source and binary forms, with or without
+ *   modification, are permitted provided that the following conditions
+ *   are met:
+ *   1. Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer,
+ *      without modification.
+ *   2. Redistributions in binary form must reproduce at minimum a disclaimer
+ *      similar to the "NO WARRANTY" disclaimer below ("Disclaimer") and any
+ *      redistribution must be conditioned upon including a substantially
+ *      similar Disclaimer requirement for further binary redistribution.
+ *   3. Neither the names of the above-listed copyright holders nor the names
+ *      of any contributors may be used to endorse or promote products derived
+ *      from this software without specific prior written permission.
+ *
+ *   Alternatively, this software may be distributed under the terms of the
+ *   GNU General Public License ("GPL") version 2 as published by the Free
+ *   Software Foundation.
+ *
+ *   NO WARRANTY
+ *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ *   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ *   LIMITED TO, THE IMPLIED WARRANTIES OF NONINFRINGEMENT, MERCHANTIBILITY
+ *   AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
+ *   THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY,
+ *   OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
+ *   IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *   THE POSSIBILITY OF SUCH DAMAGES.
+ */
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/debugfs.h>
+#include <linux/ieee80211.h>
+#include <net/mac80211.h>
+#include "rc80211_minstrel.h"
+
+struct minstrel_stats_info {
+	struct minstrel_sta_info *mi;
+	char buf[4096];
+	size_t len;
+};
+
+static int
+minstrel_stats_open(struct inode *inode, struct file *file)
+{
+	struct minstrel_sta_info *mi = inode->i_private;
+	struct minstrel_stats_info *ms;
+	unsigned int i, tp, prob, eprob;
+	char *p;
+
+	ms = kmalloc(sizeof(*ms), GFP_KERNEL);
+	if (!ms)
+		return -ENOMEM;
+
+	file->private_data = ms;
+	p = ms->buf;
+	p += sprintf(p, "rate     throughput  ewma prob   this prob  "
+			"this succ/attempt   success    attempts\n");
+	for (i = 0; i < mi->n_rates; i++) {
+		struct minstrel_rate *mr = &mi->r[i];
+
+		*(p++) = (i == mi->max_tp_rate) ? 'T' : ' ';
+		*(p++) = (i == mi->max_tp_rate2) ? 't' : ' ';
+		*(p++) = (i == mi->max_prob_rate) ? 'P' : ' ';
+		p += sprintf(p, "%3u%s", mr->bitrate / 2,
+				(mr->bitrate & 1 ? ".5" : "  "));
+
+		tp = ((mr->cur_tp * 96) / 18000) >> 10;
+		prob = mr->cur_prob / 18;
+		eprob = mr->probability / 18;
+
+		p += sprintf(p, "  %6u.%1u   %6u.%1u   %6u.%1u        "
+				"%3u(%3u)   %8llu    %8llu\n",
+				tp / 10, tp % 10,
+				eprob / 10, eprob % 10,
+				prob / 10, prob % 10,
+				mr->last_success,
+				mr->last_attempts,
+				mr->succ_hist,
+				mr->att_hist);
+	}
+	p += sprintf(p, "\nTotal packet count::    ideal %d      "
+			"lookaround %d\n\n",
+			mi->packet_count - mi->sample_count,
+			mi->sample_count);
+	ms->len = p - ms->buf;
+
+	return 0;
+}
+
+static int
+minstrel_stats_read(struct file *file, char __user *buf, size_t len, loff_t *o)
+{
+	struct minstrel_stats_info *ms;
+	char *src;
+
+	ms = file->private_data;
+	src = ms->buf;
+
+	len = min(len, ms->len);
+	if (len <= *o)
+		return 0;
+
+	src += *o;
+	len -= *o;
+	*o += len;
+
+	if (copy_to_user(buf, src, len))
+		return -EFAULT;
+
+	return len;
+}
+
+static int
+minstrel_stats_release(struct inode *inode, struct file *file)
+{
+	struct minstrel_stats_info *ms = file->private_data;
+
+	kfree(ms);
+
+	return 0;
+}
+
+static struct file_operations minstrel_stat_fops = {
+	.owner = THIS_MODULE,
+	.open = minstrel_stats_open,
+	.read = minstrel_stats_read,
+	.release = minstrel_stats_release,
+};
+
+void
+minstrel_add_sta_debugfs(void *priv, void *priv_sta, struct dentry *dir)
+{
+	struct minstrel_sta_info *mi = priv_sta;
+
+	mi->dbg_stats = debugfs_create_file("rc_stats", S_IRUGO, dir, mi,
+			&minstrel_stat_fops);
+}
+
+void
+minstrel_remove_sta_debugfs(void *priv, void *priv_sta)
+{
+	struct minstrel_sta_info *mi = priv_sta;
+
+	debugfs_remove(mi->dbg_stats);
+}
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 0cc2e23..1460537 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -454,15 +454,16 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_tx_data *tx)
 		if (unlikely(rsel.probe_idx >= 0)) {
 			info->flags |= IEEE80211_TX_CTL_RATE_CTRL_PROBE;
 			tx->flags |= IEEE80211_TX_PROBE_LAST_FRAG;
-			info->control.alt_retry_rate_idx = tx->rate_idx;
+			info->control.retries[0].rate_idx = tx->rate_idx;
+			info->control.retries[0].limit = tx->local->hw.max_altrate_tries;
 			tx->rate_idx = rsel.probe_idx;
-		} else
-			info->control.alt_retry_rate_idx = -1;
+		} else if (info->control.retries[0].limit == 0)
+			info->control.retries[0].rate_idx = -1;
 
 		if (unlikely(tx->rate_idx < 0))
 			return TX_DROP;
 	} else
-		info->control.alt_retry_rate_idx = -1;
+		info->control.retries[0].rate_idx = -1;
 
 	if (tx->sdata->bss_conf.use_cts_prot &&
 	    (tx->flags & IEEE80211_TX_FRAGMENTED) && (rsel.nonerp_idx >= 0)) {
@@ -521,7 +522,7 @@ ieee80211_tx_h_misc(struct ieee80211_tx_data *tx)
 		 * frames.
 		 * TODO: The last fragment could still use multiple retry
 		 * rates. */
-		info->control.alt_retry_rate_idx = -1;
+		info->control.retries[0].rate_idx = -1;
 	}
 
 	/* Use CTS protection for unicast frames sent using extended rates if
@@ -551,7 +552,7 @@ ieee80211_tx_h_misc(struct ieee80211_tx_data *tx)
 		int idx;
 
 		/* Do not use multiple retry rates when using RTS/CTS */
-		info->control.alt_retry_rate_idx = -1;
+		info->control.retries[0].rate_idx = -1;
 
 		/* Use min(data rate, max base rate) as CTS/RTS rate */
 		rate = &sband->bitrates[tx->rate_idx];
@@ -1255,8 +1256,7 @@ static int ieee80211_skb_resize(struct ieee80211_local *local,
 	return 0;
 }
 
-int ieee80211_master_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+int ieee80211_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ieee80211_master_priv *mpriv = netdev_priv(dev);
 	struct ieee80211_local *local = mpriv->local;
@@ -1296,20 +1296,16 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 
 	if (ieee80211_vif_is_mesh(&osdata->vif) &&
 	    ieee80211_is_data(hdr->frame_control)) {
-		if (ieee80211_is_data(hdr->frame_control)) {
-			if (is_multicast_ether_addr(hdr->addr3))
-				memcpy(hdr->addr1, hdr->addr3, ETH_ALEN);
-			else
-				if (mesh_nexthop_lookup(skb, osdata))
-					return  0;
-			if (memcmp(odev->dev_addr, hdr->addr4, ETH_ALEN) != 0)
-				IEEE80211_IFSTA_MESH_CTR_INC(&osdata->u.mesh,
-							     fwded_frames);
-		}
+		if (is_multicast_ether_addr(hdr->addr3))
+			memcpy(hdr->addr1, hdr->addr3, ETH_ALEN);
+		else
+			if (mesh_nexthop_lookup(skb, osdata))
+				return  0;
+		if (memcmp(odev->dev_addr, hdr->addr4, ETH_ALEN) != 0)
+			IEEE80211_IFSTA_MESH_CTR_INC(&osdata->u.mesh,
+							    fwded_frames);
 	} else if (unlikely(osdata->vif.type == NL80211_IFTYPE_MONITOR)) {
 		struct ieee80211_sub_if_data *sdata;
-		struct ieee80211_local *local = osdata->local;
-		struct ieee80211_hdr *hdr;
 		int hdrlen;
 		u16 len_rthdr;
 
diff --git a/net/mac80211/wep.c b/net/mac80211/wep.c
index 376c849..f0e2d3e 100644
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -313,9 +313,6 @@ static int wep_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
-	info->control.iv_len = WEP_IV_LEN;
-	info->control.icv_len = WEP_ICV_LEN;
-
 	if (!(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
 		if (ieee80211_wep_encrypt(tx->local, skb, tx->key))
 			return -1;
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 37ae9a9..6db6494 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -152,9 +152,6 @@ static int tkip_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	int len, tail;
 	u8 *pos;
 
-	info->control.icv_len = TKIP_ICV_LEN;
-	info->control.iv_len = TKIP_IV_LEN;
-
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
 	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
@@ -374,9 +371,6 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos, *pn;
 	int i;
 
-	info->control.icv_len = CCMP_MIC_LEN;
-	info->control.iv_len = CCMP_HDR_LEN;
-
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
 	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index ea0dc04..f949a48 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -125,6 +125,7 @@ static void rfkill_led_trigger_activate(struct led_classdev *led)
 
 static void notify_rfkill_state_change(struct rfkill *rfkill)
 {
+	rfkill_led_trigger(rfkill, rfkill->state);
 	blocking_notifier_call_chain(&rfkill_notifier_list,
 			RFKILL_STATE_CHANGED,
 			rfkill);
@@ -217,10 +218,8 @@ static int rfkill_toggle_radio(struct rfkill *rfkill,
 			rfkill->state = state;
 	}
 
-	if (force || rfkill->state != oldstate) {
-		rfkill_led_trigger(rfkill, rfkill->state);
+	if (force || rfkill->state != oldstate)
 		notify_rfkill_state_change(rfkill);
-	}
 
 	return retval;
 }
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index b97bd9f..7d82be0 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -15,7 +15,7 @@ config NL80211
 	  If unsure, say Y.
 
 config WIRELESS_OLD_REGULATORY
-	bool "Old wireless static regulatory defintions"
+	bool "Old wireless static regulatory definitions"
 	default n
 	---help---
 	  This option enables the old static regulatory information
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
