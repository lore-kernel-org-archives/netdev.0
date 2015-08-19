From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/4] ath5k: use DECLARE_EWMA
Date: Wed, 19 Aug 2015 09:46:20 +0200
Message-ID: <1439970382-6170-3-git-send-email-johannes@sipsolutions.net>
References: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56384 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730AbbHSHq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 03:46:26 -0400
In-Reply-To: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This reduces code size slightly (at least on x86/64) while also
removing memory consumption by two unsigned long values for each
ath5k device.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/wireless/ath/ath5k/Kconfig | 1 -
 drivers/net/wireless/ath/ath5k/ani.c   | 4 ++--
 drivers/net/wireless/ath/ath5k/ath5k.h | 4 +++-
 drivers/net/wireless/ath/ath5k/base.c  | 4 ++--
 drivers/net/wireless/ath/ath5k/debug.c | 2 +-
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index 2399a3921762..b1278f9f24ba 100644
--- a/drivers/net/wireless/ath/ath5k/Kconfig
+++ b/drivers/net/wireless/ath/ath5k/Kconfig
@@ -5,7 +5,6 @@ config ATH5K
 	select MAC80211_LEDS
 	select LEDS_CLASS
 	select NEW_LEDS
-	select AVERAGE
 	select ATH5K_AHB if ATH25
 	select ATH5K_PCI if !ATH25
 	---help---
diff --git a/drivers/net/wireless/ath/ath5k/ani.c b/drivers/net/wireless/ath/ath5k/ani.c
index 5c008757662b..38be2702c0e2 100644
--- a/drivers/net/wireless/ath/ath5k/ani.c
+++ b/drivers/net/wireless/ath/ath5k/ani.c
@@ -223,7 +223,7 @@ static void
 ath5k_ani_raise_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as,
 			 bool ofdm_trigger)
 {
-	int rssi = ewma_read(&ah->ah_beacon_rssi_avg);
+	int rssi = ewma_beacon_rssi_read(&ah->ah_beacon_rssi_avg);
 
 	ATH5K_DBG_UNLIMIT(ah, ATH5K_DEBUG_ANI, "raise immunity (%s)",
 		ofdm_trigger ? "ODFM" : "CCK");
@@ -309,7 +309,7 @@ ath5k_ani_raise_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as,
 static void
 ath5k_ani_lower_immunity(struct ath5k_hw *ah, struct ath5k_ani_state *as)
 {
-	int rssi = ewma_read(&ah->ah_beacon_rssi_avg);
+	int rssi = ewma_beacon_rssi_read(&ah->ah_beacon_rssi_avg);
 
 	ATH5K_DBG_UNLIMIT(ah, ATH5K_DEBUG_ANI, "lower immunity");
 
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index e22b0e778927..fa6e89e5c421 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1252,6 +1252,8 @@ struct ath5k_statistics {
 #define ATH5K_TXQ_LEN_MAX	(ATH_TXBUF / 4)		/* bufs per queue */
 #define ATH5K_TXQ_LEN_LOW	(ATH5K_TXQ_LEN_MAX / 2)	/* low mark */
 
+DECLARE_EWMA(beacon_rssi, 1024, 8)
+
 /* Driver state associated with an instance of a device */
 struct ath5k_hw {
 	struct ath_common       common;
@@ -1432,7 +1434,7 @@ struct ath5k_hw {
 	struct ath5k_nfcal_hist ah_nfcal_hist;
 
 	/* average beacon RSSI in our BSS (used by ANI) */
-	struct ewma		ah_beacon_rssi_avg;
+	struct ewma_beacon_rssi	ah_beacon_rssi_avg;
 
 	/* noise floor from last periodic calibration */
 	s32			ah_noise_floor;
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 23552f43d125..342563a3706f 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1430,7 +1430,7 @@ ath5k_receive_frame(struct ath5k_hw *ah, struct sk_buff *skb,
 	trace_ath5k_rx(ah, skb);
 
 	if (ath_is_mybeacon(common, (struct ieee80211_hdr *)skb->data)) {
-		ewma_add(&ah->ah_beacon_rssi_avg, rs->rs_rssi);
+		ewma_beacon_rssi_add(&ah->ah_beacon_rssi_avg, rs->rs_rssi);
 
 		/* check beacons in IBSS mode */
 		if (ah->opmode == NL80211_IFTYPE_ADHOC)
@@ -2936,7 +2936,7 @@ ath5k_reset(struct ath5k_hw *ah, struct ieee80211_channel *chan,
 	ah->ah_cal_next_short = jiffies +
 		msecs_to_jiffies(ATH5K_TUNE_CALIBRATION_INTERVAL_SHORT);
 
-	ewma_init(&ah->ah_beacon_rssi_avg, 1024, 8);
+	ewma_beacon_rssi_init(&ah->ah_beacon_rssi_avg);
 
 	/* clear survey data and cycle counters */
 	memset(&ah->survey, 0, sizeof(ah->survey));
diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index c70782e8f07b..654a1e33f827 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -722,7 +722,7 @@ static ssize_t read_file_ani(struct file *file, char __user *user_buf,
 			st->mib_intr);
 	len += snprintf(buf + len, sizeof(buf) - len,
 			"beacon RSSI average:\t%d\n",
-			(int)ewma_read(&ah->ah_beacon_rssi_avg));
+			(int)ewma_beacon_rssi_read(&ah->ah_beacon_rssi_avg));
 
 #define CC_PRINT(_struct, _field) \
 	_struct._field, \
-- 
2.1.4
