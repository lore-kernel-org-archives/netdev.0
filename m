From: John Stultz <john.stultz@linaro.org>
Subject: [RFC][PATCH v2] wireless: ath9k: Convert from timespecs to ktime_t
Date: Wed, 30 Jul 2014 17:48:00 -0700
Message-ID: <1406767680-716-1-git-send-email-john.stultz@linaro.org>
References: <20140731102750.4a4c1315@canb.auug.org.au>
Cc: John Stultz <john.stultz@linaro.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Rajkumar Manoharan <rmanohar@qti.qualcomm.com>,
	<netdev@vger.kernel.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-next@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140731102750.4a4c1315@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert from using timespecs to ktime_t for internal timekeeping
needs. This simplifies the logic and avoids extra math required to
convert from timespec to usecs.

Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: David Miller <davem@davemloft.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Felix Fietkau <nbd@openwrt.org>
Cc: Rajkumar Manoharan <rmanohar@qti.qualcomm.com>
Cc: <netdev@vger.kernel.org>
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Cc: linux-next@vger.kernel.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---

Thomas made an earlier version of this patch which I queued,
but it collided badly in -next with the timestamping rework in
ath9k code. So this is my swing at fixing it up again.

v2: Fix an embarasing null pointer assignment Stephen pointed out

Compile tested only. Would apprecate feedback, testing, and review.

 drivers/net/wireless/ath/ath9k/ath9k.h   |  2 +-
 drivers/net/wireless/ath/ath9k/channel.c | 18 +++++++++---------
 drivers/net/wireless/ath/ath9k/hw.c      | 19 ++++++++-----------
 drivers/net/wireless/ath/ath9k/hw.h      |  2 +-
 drivers/net/wireless/ath/ath9k/main.c    |  2 +-
 5 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 7fc13a8..5553c0f 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -335,7 +335,7 @@ struct ath_chanctx {
 
 	struct ath_beacon_config beacon;
 	struct ath9k_hw_cal_data caldata;
-	struct timespec tsf_ts;
+	ktime_t tsf_kt;
 	u64 tsf_val;
 	u32 last_beacon;
 
diff --git a/drivers/net/wireless/ath/ath9k/channel.c b/drivers/net/wireless/ath/ath9k/channel.c
index ba214eb..2b37f8d 100644
--- a/drivers/net/wireless/ath/ath9k/channel.c
+++ b/drivers/net/wireless/ath/ath9k/channel.c
@@ -228,9 +228,9 @@ static bool ath_chanctx_defer_switch(struct ath_softc *sc)
 
 static void ath_chanctx_set_next(struct ath_softc *sc, bool force)
 {
-	struct timespec ts;
 	bool measure_time = false;
 	bool send_ps = false;
+	ktime_t now;
 
 	spin_lock_bh(&sc->chan_lock);
 	if (!sc->next_chan) {
@@ -248,7 +248,7 @@ static void ath_chanctx_set_next(struct ath_softc *sc, bool force)
 		spin_unlock_bh(&sc->chan_lock);
 
 		if (sc->next_chan == &sc->offchannel.chan) {
-			getrawmonotonic(&ts);
+			now = ktime_get_raw();
 			measure_time = true;
 		}
 		__ath9k_flush(sc->hw, ~0, true);
@@ -260,7 +260,7 @@ static void ath_chanctx_set_next(struct ath_softc *sc, bool force)
 		spin_lock_bh(&sc->chan_lock);
 
 		if (sc->cur_chan != &sc->offchannel.chan) {
-			getrawmonotonic(&sc->cur_chan->tsf_ts);
+			sc->cur_chan->tsf_kt = ktime_get_raw();
 			sc->cur_chan->tsf_val = ath9k_hw_gettsf64(sc->sc_ah);
 		}
 	}
@@ -279,7 +279,7 @@ static void ath_chanctx_set_next(struct ath_softc *sc, bool force)
 		ath_set_channel(sc);
 		if (measure_time)
 			sc->sched.channel_switch_time =
-				ath9k_hw_get_tsf_offset(&ts, NULL);
+				ath9k_hw_get_tsf_offset(&now, NULL);
 	}
 	if (send_ps)
 		ath_chanctx_send_ps_frame(sc, false);
@@ -440,8 +440,8 @@ ath_chanctx_get_next(struct ath_softc *sc, struct ath_chanctx *ctx)
 static void ath_chanctx_adjust_tbtt_delta(struct ath_softc *sc)
 {
 	struct ath_chanctx *prev, *cur;
-	struct timespec ts;
 	u32 cur_tsf, prev_tsf, beacon_int;
+	ktime_t now;
 	s32 offset;
 
 	beacon_int = TU_TO_USEC(sc->cur_chan->beacon.beacon_interval);
@@ -449,12 +449,12 @@ static void ath_chanctx_adjust_tbtt_delta(struct ath_softc *sc)
 	cur = sc->cur_chan;
 	prev = ath_chanctx_get_next(sc, cur);
 
-	getrawmonotonic(&ts);
+	now = ktime_get_raw();
 	cur_tsf = (u32) cur->tsf_val +
-		  ath9k_hw_get_tsf_offset(&cur->tsf_ts, &ts);
+		  ath9k_hw_get_tsf_offset(&cur->tsf_kt, &now);
 
 	prev_tsf = prev->last_beacon - (u32) prev->tsf_val + cur_tsf;
-	prev_tsf -= ath9k_hw_get_tsf_offset(&prev->tsf_ts, &ts);
+	prev_tsf -= ath9k_hw_get_tsf_offset(&prev->tsf_kt, &now);
 
 	/* Adjust the TSF time of the AP chanctx to keep its beacons
 	 * at half beacon interval offset relative to the STA chanctx.
@@ -614,7 +614,7 @@ void ath_chanctx_event(struct ath_softc *sc, struct ieee80211_vif *vif,
 		 */
 		tsf_time = sc->sched.switch_start_time;
 		tsf_time -= (u32) sc->cur_chan->tsf_val +
-			ath9k_hw_get_tsf_offset(&sc->cur_chan->tsf_ts, NULL);
+			ath9k_hw_get_tsf_offset(&sc->cur_chan->tsf_kt, NULL);
 		tsf_time += ath9k_hw_gettsf32(ah);
 
 
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index fd0158f..1a0a556 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1731,19 +1731,16 @@ fail:
 	return -EINVAL;
 }
 
-u32 ath9k_hw_get_tsf_offset(struct timespec *last, struct timespec *cur)
+u32 ath9k_hw_get_tsf_offset(ktime_t *last, ktime_t *cur)
 {
-	struct timespec ts;
+	ktime_t tmp;
 	s64 usec;
 
 	if (!cur) {
-		getrawmonotonic(&ts);
-		cur = &ts;
+		tmp = ktime_get_raw();
+		cur = &tmp;
 	}
-
-	usec = cur->tv_sec * 1000000ULL + cur->tv_nsec / 1000;
-	usec -= last->tv_sec * 1000000ULL + last->tv_nsec / 1000;
-
+	usec = ktime_to_us(ktime_sub(*cur, *last));
 	return (u32) usec;
 }
 EXPORT_SYMBOL(ath9k_hw_get_tsf_offset);
@@ -1752,7 +1749,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 		   struct ath9k_hw_cal_data *caldata, bool fastcc)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
-	struct timespec ts;
+	ktime_t now;
 	u32 saveLedState;
 	u32 saveDefAntenna;
 	u32 macStaId1;
@@ -1801,7 +1798,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 
 	/* Save TSF before chip reset, a cold reset clears it */
 	tsf = ath9k_hw_gettsf64(ah);
-	getrawmonotonic(&ts);
+	now = ktime_get_raw();
 
 	saveLedState = REG_READ(ah, AR_CFG_LED) &
 		(AR_CFG_LED_ASSOC_CTL | AR_CFG_LED_MODE_SEL |
@@ -1834,7 +1831,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	}
 
 	/* Restore TSF */
-	ath9k_hw_settsf64(ah, tsf + ath9k_hw_get_tsf_offset(&ts, NULL));
+	ath9k_hw_settsf64(ah, tsf + ath9k_hw_get_tsf_offset(&now, NULL));
 
 	if (AR_SREV_9280_20_OR_LATER(ah))
 		REG_SET_BIT(ah, AR_GPIO_INPUT_EN_VAL, AR_GPIO_JTAG_DISABLE);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 51b4ebe..a57b4e2 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -1000,7 +1000,7 @@ u32 ath9k_hw_gettsf32(struct ath_hw *ah);
 u64 ath9k_hw_gettsf64(struct ath_hw *ah);
 void ath9k_hw_settsf64(struct ath_hw *ah, u64 tsf64);
 void ath9k_hw_reset_tsf(struct ath_hw *ah);
-u32 ath9k_hw_get_tsf_offset(struct timespec *last, struct timespec *cur);
+u32 ath9k_hw_get_tsf_offset(ktime_t *last, ktime_t *cur);
 void ath9k_hw_set_tsfadjust(struct ath_hw *ah, bool set);
 void ath9k_hw_init_global_settings(struct ath_hw *ah);
 u32 ar9003_get_pll_sqsum_dvc(struct ath_hw *ah);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index e6ac8d2..e47dbd3 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -241,7 +241,7 @@ static bool ath_complete_reset(struct ath_softc *sc, bool start)
 		if (sc->cur_chan->tsf_val) {
 			u32 offset;
 
-			offset = ath9k_hw_get_tsf_offset(&sc->cur_chan->tsf_ts,
+			offset = ath9k_hw_get_tsf_offset(&sc->cur_chan->tsf_kt,
 							 NULL);
 			ath9k_hw_settsf64(ah, sc->cur_chan->tsf_val + offset);
 		}
-- 
1.9.1
