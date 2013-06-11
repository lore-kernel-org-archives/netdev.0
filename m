From: Calvin Owens <jcalvinowens@gmail.com>
Subject: [PATCH] mac80211: ath9k: Use RCU protection calling
 ieee80211_get_tx_rates
Date: Tue, 11 Jun 2013 12:13:04 -0500
Message-ID: <20130611171304.GA2189@gmail.com>
References: <20130609225120.GA2789@gmail.com>
 <20130610042959.GA1902@gmail.com>
 <1370950926.8356.14.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	jcalvinowens@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52436 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab3FKRNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 13:13:21 -0400
Content-Disposition: inline
In-Reply-To: <1370950926.8356.14.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Calvin Owens <jcalvinowens@gmail.com>
---
 drivers/net/wireless/ath/ath9k/xmit.c | 2 ++
 drivers/net/wireless/mac80211_hwsim.c | 6 ++++++
 include/net/mac80211.h                | 3 ++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 1c9b1ba..1d57015 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -142,8 +142,10 @@ static void ath_send_bar(struct ath_atx_tid *tid, u16 seqno)
 static void ath_set_rates(struct ieee80211_vif *vif, struct ieee80211_sta *sta,
 			  struct ath_buf *bf)
 {
+	rcu_read_lock();
 	ieee80211_get_tx_rates(vif, sta, bf->bf_mpdu, bf->rates,
 			       ARRAY_SIZE(bf->rates));
+	rcu_read_unlock();
 }
 
 static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index cb34c78..468a5a6 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -900,9 +900,11 @@ static void mac80211_hwsim_tx(struct ieee80211_hw *hw,
 		hwsim_check_sta_magic(control->sta);
 
 	if (rctbl)
+		rcu_read_lock();
 		ieee80211_get_tx_rates(txi->control.vif, control->sta, skb,
 				       txi->control.rates,
 				       ARRAY_SIZE(txi->control.rates));
+		rcu_read_unlock();
 
 	txi->rate_driver_data[0] = channel;
 	mac80211_hwsim_monitor_rx(hw, skb, channel);
@@ -1008,9 +1010,11 @@ static void mac80211_hwsim_tx_frame(struct ieee80211_hw *hw,
 
 	if (rctbl) {
 		struct ieee80211_tx_info *txi = IEEE80211_SKB_CB(skb);
+		rcu_read_lock();
 		ieee80211_get_tx_rates(txi->control.vif, NULL, skb,
 				       txi->control.rates,
 				       ARRAY_SIZE(txi->control.rates));
+		rcu_read_unlock();
 	}
 
 	mac80211_hwsim_monitor_rx(hw, skb, chan);
@@ -1044,9 +1048,11 @@ static void mac80211_hwsim_beacon_tx(void *arg, u8 *mac,
 		return;
 	info = IEEE80211_SKB_CB(skb);
 	if (rctbl)
+		rcu_read_lock();
 		ieee80211_get_tx_rates(vif, NULL, skb,
 				       info->control.rates,
 				       ARRAY_SIZE(info->control.rates));
+		rcu_read_unlock();
 
 	txrate = ieee80211_get_tx_rate(hw, info);
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 885898a..df345c1 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -3175,7 +3175,8 @@ void ieee80211_sta_set_buffered(struct ieee80211_sta *sta,
  *
  * Call this function in a driver with per-packet rate selection support
  * to combine the rate info in the packet tx info with the most recent
- * rate selection table for the station entry.
+ * rate selection table for the station entry. Must be called with RCU
+ * protection.
  *
  * @vif: &struct ieee80211_vif pointer from the add_interface callback.
  * @sta: the receiver station to which this packet is sent.
-- 
1.8.2.1
