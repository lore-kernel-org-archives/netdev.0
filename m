From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v4 2/4] mac80211: filter multicast data packets on AP / AP_VLAN
Date: Fri,  7 Oct 2016 15:12:22 +0200
Message-ID: <1475845944-27680-2-git-send-email-michael-dev@fami-braun.de>
References: <1475845944-27680-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        linux-wireless@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:43509 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756172AbcJGNMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 09:12:32 -0400
In-Reply-To: <1475845944-27680-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds filtering for multicast data packets on AP_VLAN interfaces
that have no authorized station connected and changes filtering on AP
interfaces to not count stations assigned to AP_VLAN interfaces.

This saves airtime and avoids waking up other stations currently authorized
in this BSS. When using WPA, the packets dropped could not be decrypted by
any station.

The behaviour when there are no AP_VLAN interfaces is left unchanged.
When there are AP_VLAN interfaces, this patch
1. adds filtering multicast data packets sent on AP_VLAN interfaces that
   have no authorized station connected.
   No filtering happens on 4addr AP_VLAN interfaces.
2. makes filtering of multicast data packets sent on AP interfaces depend
   on the number of authorized stations in this bss not assigned to an
   AP_VLAN interface.

Therefore, a new num_mcast_sta counter is added for AP_VLAN interfaces.
The existing one for AP interfaces is altered to not track stations
assigned to an AP_VLAN interface.

The new counter is exposed in debugfs.

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

--
v4:
 - update description
v3:
 - reuse existing num_mcast_sta
v2:
 - use separate function to inc/dec mcast_sta counters
 - do not filter in 4addr mode
 - change description
 - change filtering on AP interface (do not count AP_VLAN sta)
 - use new counters regardless of 4addr or not
 - simplify cfg.c:change_station
 - remove no-op change in __cleanup_single_sta
---
 net/mac80211/cfg.c            | 20 ++++++--------------
 net/mac80211/debugfs_netdev.c | 11 +++++++++++
 net/mac80211/ieee80211_i.h    | 33 +++++++++++++++++++++++++++++++++
 net/mac80211/rx.c             |  5 +++--
 net/mac80211/sta_info.c       | 10 ++--------
 net/mac80211/tx.c             |  5 ++---
 6 files changed, 57 insertions(+), 27 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 24133f5..1edb017 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1357,9 +1357,6 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 		goto out_err;
 
 	if (params->vlan && params->vlan != sta->sdata->dev) {
-		bool prev_4addr = false;
-		bool new_4addr = false;
-
 		vlansdata = IEEE80211_DEV_TO_SUB_IF(params->vlan);
 
 		if (params->vlan->ieee80211_ptr->use_4addr) {
@@ -1369,26 +1366,21 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 			}
 
 			rcu_assign_pointer(vlansdata->u.vlan.sta, sta);
-			new_4addr = true;
 			__ieee80211_check_fast_rx_iface(vlansdata);
 		}
 
 		if (sta->sdata->vif.type == NL80211_IFTYPE_AP_VLAN &&
-		    sta->sdata->u.vlan.sta) {
+		    sta->sdata->u.vlan.sta)
 			RCU_INIT_POINTER(sta->sdata->u.vlan.sta, NULL);
-			prev_4addr = true;
-		}
+
+		if (test_sta_flag(sta, WLAN_STA_AUTHORIZED))
+			ieee80211_vif_dec_num_mcast(sta->sdata);
 
 		sta->sdata = vlansdata;
 		ieee80211_check_fast_xmit(sta);
 
-		if (sta->sta_state == IEEE80211_STA_AUTHORIZED &&
-		    prev_4addr != new_4addr) {
-			if (new_4addr)
-				atomic_dec(&sta->sdata->bss->num_mcast_sta);
-			else
-				atomic_inc(&sta->sdata->bss->num_mcast_sta);
-		}
+		if (test_sta_flag(sta, WLAN_STA_AUTHORIZED))
+			ieee80211_vif_inc_num_mcast(sta->sdata);
 
 		ieee80211_send_layer2_update(sta);
 	}
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index a5ba739..ed7bff4 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -477,6 +477,7 @@ IEEE80211_IF_FILE_RW(tdls_wider_bw);
 IEEE80211_IF_FILE(num_mcast_sta, u.ap.num_mcast_sta, ATOMIC);
 IEEE80211_IF_FILE(num_sta_ps, u.ap.ps.num_sta_ps, ATOMIC);
 IEEE80211_IF_FILE(dtim_count, u.ap.ps.dtim_count, DEC);
+IEEE80211_IF_FILE(num_mcast_sta_vlan, u.vlan.num_mcast_sta, ATOMIC);
 
 static ssize_t ieee80211_if_fmt_num_buffered_multicast(
 	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
@@ -643,6 +644,13 @@ static void add_ap_files(struct ieee80211_sub_if_data *sdata)
 	DEBUGFS_ADD_MODE(tkip_mic_test, 0200);
 }
 
+static void add_vlan_files(struct ieee80211_sub_if_data *sdata)
+{
+	/* add num_mcast_sta_vlan using name num_mcast_sta */
+	debugfs_create_file("num_mcast_sta", 0400, sdata->vif.debugfs_dir,
+			    sdata, &num_mcast_sta_vlan_ops);
+}
+
 static void add_ibss_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD_MODE(tsf, 0600);
@@ -746,6 +754,9 @@ static void add_files(struct ieee80211_sub_if_data *sdata)
 	case NL80211_IFTYPE_AP:
 		add_ap_files(sdata);
 		break;
+	case NL80211_IFTYPE_AP_VLAN:
+		add_vlan_files(sdata);
+		break;
 	case NL80211_IFTYPE_WDS:
 		add_wds_files(sdata);
 		break;
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index f56d342..70c0963 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -305,6 +305,7 @@ struct ieee80211_if_vlan {
 
 	/* used for all tx if the VLAN is configured to 4-addr mode */
 	struct sta_info __rcu *sta;
+	atomic_t num_mcast_sta; /* number of stations receiving multicast */
 };
 
 struct mesh_stats {
@@ -1496,6 +1497,38 @@ ieee80211_have_rx_timestamp(struct ieee80211_rx_status *status)
 	return false;
 }
 
+static inline void
+ieee80211_vif_inc_num_mcast(struct ieee80211_sub_if_data *sdata)
+{
+	if (sdata->vif.type == NL80211_IFTYPE_AP)
+		atomic_inc(&sdata->u.ap.num_mcast_sta);
+	else if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN)
+		atomic_inc(&sdata->u.vlan.num_mcast_sta);
+}
+
+static inline void
+ieee80211_vif_dec_num_mcast(struct ieee80211_sub_if_data *sdata)
+{
+	if (sdata->vif.type == NL80211_IFTYPE_AP)
+		atomic_dec(&sdata->u.ap.num_mcast_sta);
+	else if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN)
+		atomic_dec(&sdata->u.vlan.num_mcast_sta);
+}
+
+/* This function returns the number of multicast stations connected to this
+ * interface. It returns -1 if that number is not tracked, that is for netdevs
+ * not in AP or AP_VLAN mode or when using 4addr.
+ */
+static inline int
+ieee80211_vif_get_num_mcast_if(struct ieee80211_sub_if_data *sdata)
+{
+	if (sdata->vif.type == NL80211_IFTYPE_AP)
+		return atomic_read(&sdata->u.ap.num_mcast_sta);
+	if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN && !sdata->u.vlan.sta)
+		return atomic_read(&sdata->u.vlan.num_mcast_sta);
+	return -1;
+}
+
 u64 ieee80211_calculate_rx_timestamp(struct ieee80211_local *local,
 				     struct ieee80211_rx_status *status,
 				     unsigned int mpdu_len,
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 3d8d889..7e5086a 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2161,7 +2161,8 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 	     sdata->vif.type == NL80211_IFTYPE_AP_VLAN) &&
 	    !(sdata->flags & IEEE80211_SDATA_DONT_BRIDGE_PACKETS) &&
 	    (sdata->vif.type != NL80211_IFTYPE_AP_VLAN || !sdata->u.vlan.sta)) {
-		if (is_multicast_ether_addr(ehdr->h_dest)) {
+		if (is_multicast_ether_addr(ehdr->h_dest) &&
+		    ieee80211_vif_get_num_mcast_if(sdata) != 0) {
 			/*
 			 * send multicast frames both to higher layers in
 			 * local net stack and back to the wireless medium
@@ -2170,7 +2171,7 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 			if (!xmit_skb)
 				net_info_ratelimited("%s: failed to clone multicast frame\n",
 						    dev->name);
-		} else {
+		} else if (!is_multicast_ether_addr(ehdr->h_dest)) {
 			dsta = sta_info_get(sdata, skb->data);
 			if (dsta) {
 				/*
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 76b737d..216ef65 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1882,10 +1882,7 @@ int sta_info_move_state(struct sta_info *sta,
 			if (!sta->sta.support_p2p_ps)
 				ieee80211_recalc_p2p_go_ps_allowed(sta->sdata);
 		} else if (sta->sta_state == IEEE80211_STA_AUTHORIZED) {
-			if (sta->sdata->vif.type == NL80211_IFTYPE_AP ||
-			    (sta->sdata->vif.type == NL80211_IFTYPE_AP_VLAN &&
-			     !sta->sdata->u.vlan.sta))
-				atomic_dec(&sta->sdata->bss->num_mcast_sta);
+			ieee80211_vif_dec_num_mcast(sta->sdata);
 			clear_bit(WLAN_STA_AUTHORIZED, &sta->_flags);
 			ieee80211_clear_fast_xmit(sta);
 			ieee80211_clear_fast_rx(sta);
@@ -1893,10 +1890,7 @@ int sta_info_move_state(struct sta_info *sta,
 		break;
 	case IEEE80211_STA_AUTHORIZED:
 		if (sta->sta_state == IEEE80211_STA_ASSOC) {
-			if (sta->sdata->vif.type == NL80211_IFTYPE_AP ||
-			    (sta->sdata->vif.type == NL80211_IFTYPE_AP_VLAN &&
-			     !sta->sdata->u.vlan.sta))
-				atomic_inc(&sta->sdata->bss->num_mcast_sta);
+			ieee80211_vif_inc_num_mcast(sta->sdata);
 			set_bit(WLAN_STA_AUTHORIZED, &sta->_flags);
 			ieee80211_check_fast_xmit(sta);
 			ieee80211_check_fast_rx(sta);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5023966..c3ce86e 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -331,9 +331,8 @@ ieee80211_tx_h_check_assoc(struct ieee80211_tx_data *tx)
 			I802_DEBUG_INC(tx->local->tx_handlers_drop_not_assoc);
 			return TX_DROP;
 		}
-	} else if (unlikely(tx->sdata->vif.type == NL80211_IFTYPE_AP &&
-			    ieee80211_is_data(hdr->frame_control) &&
-			    !atomic_read(&tx->sdata->u.ap.num_mcast_sta))) {
+	} else if (unlikely(ieee80211_is_data(hdr->frame_control) &&
+			    ieee80211_vif_get_num_mcast_if(tx->sdata) == 0)) {
 		/*
 		 * No associated STAs - no need to send multicast
 		 * frames.
-- 
2.1.4
