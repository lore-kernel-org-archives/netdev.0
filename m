From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] mac80211: Deinline rate_control_rate_init, rate_control_rate_update
Date: Wed, 15 Jul 2015 14:56:06 +0200
Message-ID: <1436964966-2441-2-git-send-email-dvlasenk@redhat.com>
References: <1436964966-2441-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Michal Kazior <michal.kazior@tieto.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436964966-2441-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this .config: http://busybox.net/~vda/kernel_config,
after deinlining these functions have sizes and callsite counts
as follows:

rate_control_rate_init: 554 bytes, 8 calls
rate_control_rate_update: 1596 bytes, 5 calls

Total size reduction: about 11 kbytes.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: John Linville <linville@tuxdriver.com>
CC: Michal Kazior <michal.kazior@tieto.com>
CC: Johannes Berg <johannes.berg@intel.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 net/mac80211/rate.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/mac80211/rate.h | 60 +++--------------------------------------------------
 2 files changed, 62 insertions(+), 57 deletions(-)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index fda33f9..03687d2 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -29,6 +29,65 @@ module_param(ieee80211_default_rc_algo, charp, 0644);
 MODULE_PARM_DESC(ieee80211_default_rc_algo,
 		 "Default rate control algorithm for mac80211 to use");
 
+void rate_control_rate_init(struct sta_info *sta)
+{
+	struct ieee80211_local *local = sta->sdata->local;
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	struct ieee80211_sta *ista = &sta->sta;
+	void *priv_sta = sta->rate_ctrl_priv;
+	struct ieee80211_supported_band *sband;
+	struct ieee80211_chanctx_conf *chanctx_conf;
+
+	ieee80211_sta_set_rx_nss(sta);
+
+	if (!ref)
+		return;
+
+	rcu_read_lock();
+
+	chanctx_conf = rcu_dereference(sta->sdata->vif.chanctx_conf);
+	if (WARN_ON(!chanctx_conf)) {
+		rcu_read_unlock();
+		return;
+	}
+
+	sband = local->hw.wiphy->bands[chanctx_conf->def.chan->band];
+
+	spin_lock_bh(&sta->rate_ctrl_lock);
+	ref->ops->rate_init(ref->priv, sband, &chanctx_conf->def, ista,
+			    priv_sta);
+	spin_unlock_bh(&sta->rate_ctrl_lock);
+	rcu_read_unlock();
+	set_sta_flag(sta, WLAN_STA_RATE_CONTROL);
+}
+
+void rate_control_rate_update(struct ieee80211_local *local,
+				    struct ieee80211_supported_band *sband,
+				    struct sta_info *sta, u32 changed)
+{
+	struct rate_control_ref *ref = local->rate_ctrl;
+	struct ieee80211_sta *ista = &sta->sta;
+	void *priv_sta = sta->rate_ctrl_priv;
+	struct ieee80211_chanctx_conf *chanctx_conf;
+
+	if (ref && ref->ops->rate_update) {
+		rcu_read_lock();
+
+		chanctx_conf = rcu_dereference(sta->sdata->vif.chanctx_conf);
+		if (WARN_ON(!chanctx_conf)) {
+			rcu_read_unlock();
+			return;
+		}
+
+		spin_lock_bh(&sta->rate_ctrl_lock);
+		ref->ops->rate_update(ref->priv, sband, &chanctx_conf->def,
+				      ista, priv_sta, changed);
+		spin_unlock_bh(&sta->rate_ctrl_lock);
+		rcu_read_unlock();
+	}
+	drv_sta_rc_update(local, sta->sdata, &sta->sta, changed);
+}
+
 int ieee80211_rate_control_register(const struct rate_control_ops *ops)
 {
 	struct rate_control_alg *alg;
diff --git a/net/mac80211/rate.h b/net/mac80211/rate.h
index 25c9be5..624fe5b 100644
--- a/net/mac80211/rate.h
+++ b/net/mac80211/rate.h
@@ -71,64 +71,10 @@ rate_control_tx_status_noskb(struct ieee80211_local *local,
 	spin_unlock_bh(&sta->rate_ctrl_lock);
 }
 
-static inline void rate_control_rate_init(struct sta_info *sta)
-{
-	struct ieee80211_local *local = sta->sdata->local;
-	struct rate_control_ref *ref = sta->rate_ctrl;
-	struct ieee80211_sta *ista = &sta->sta;
-	void *priv_sta = sta->rate_ctrl_priv;
-	struct ieee80211_supported_band *sband;
-	struct ieee80211_chanctx_conf *chanctx_conf;
-
-	ieee80211_sta_set_rx_nss(sta);
-
-	if (!ref)
-		return;
-
-	rcu_read_lock();
-
-	chanctx_conf = rcu_dereference(sta->sdata->vif.chanctx_conf);
-	if (WARN_ON(!chanctx_conf)) {
-		rcu_read_unlock();
-		return;
-	}
-
-	sband = local->hw.wiphy->bands[chanctx_conf->def.chan->band];
-
-	spin_lock_bh(&sta->rate_ctrl_lock);
-	ref->ops->rate_init(ref->priv, sband, &chanctx_conf->def, ista,
-			    priv_sta);
-	spin_unlock_bh(&sta->rate_ctrl_lock);
-	rcu_read_unlock();
-	set_sta_flag(sta, WLAN_STA_RATE_CONTROL);
-}
-
-static inline void rate_control_rate_update(struct ieee80211_local *local,
+void rate_control_rate_init(struct sta_info *sta);
+void rate_control_rate_update(struct ieee80211_local *local,
 				    struct ieee80211_supported_band *sband,
-				    struct sta_info *sta, u32 changed)
-{
-	struct rate_control_ref *ref = local->rate_ctrl;
-	struct ieee80211_sta *ista = &sta->sta;
-	void *priv_sta = sta->rate_ctrl_priv;
-	struct ieee80211_chanctx_conf *chanctx_conf;
-
-	if (ref && ref->ops->rate_update) {
-		rcu_read_lock();
-
-		chanctx_conf = rcu_dereference(sta->sdata->vif.chanctx_conf);
-		if (WARN_ON(!chanctx_conf)) {
-			rcu_read_unlock();
-			return;
-		}
-
-		spin_lock_bh(&sta->rate_ctrl_lock);
-		ref->ops->rate_update(ref->priv, sband, &chanctx_conf->def,
-				      ista, priv_sta, changed);
-		spin_unlock_bh(&sta->rate_ctrl_lock);
-		rcu_read_unlock();
-	}
-	drv_sta_rc_update(local, sta->sdata, &sta->sta, changed);
-}
+				    struct sta_info *sta, u32 changed);
 
 static inline void *rate_control_alloc_sta(struct rate_control_ref *ref,
 					   struct sta_info *sta, gfp_t gfp)
-- 
1.8.1.4
