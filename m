From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/4] Net: mac80211, remove bitfields from struct ieee80211_sub_if_data
Date: Sun, 12 Aug 2007 15:09:01 +0200 (CEST)
Message-ID: <273295396119720924@wsc.cz>
References: <32694265142306417777@wsc.cz>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <32694265142306417777-2EuRcrBQ8V0@public.gmane.org>
Cc: <jbenc-AlSwsSmVLrQ@public.gmane.org>
Cc: <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Cc: <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

mac80211, remove bitfields from struct ieee80211_sub_if_data

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
commit 086d27164f6a040ea24efe6baab3e6b9075942a5
tree 61fb84b9bb528c8321a86a6afbf980eafb28ee3f
parent 3fe2e620fcc758be03b87e3ca5265b10fbd60e1a
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sun, 12 Aug 2007 13:41:55 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sun, 12 Aug 2007 13:41:55 +0200

 net/mac80211/debugfs_netdev.c  |    2 +-
 net/mac80211/ieee80211.c       |   30 ++++++++++++++----------------
 net/mac80211/ieee80211_i.h     |   10 +++++-----
 net/mac80211/ieee80211_ioctl.c |   20 ++++++++++++++------
 net/mac80211/ieee80211_sta.c   |   19 +++++++++++++------
 net/mac80211/rx.c              |    4 ++--
 net/mac80211/tx.c              |   18 ++++++++++--------
 net/mac80211/util.c            |    6 +++---
 8 files changed, 62 insertions(+), 47 deletions(-)

diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index fa3b153..588f71b 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -379,7 +379,7 @@ static ssize_t ieee80211_if_fmt_flags(
 		 sdata->u.sta.flags & IEEE80211_STA_AUTHENTICATED ? "AUTH\n" : "",
 		 sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED ? "ASSOC\n" : "",
 		 sdata->u.sta.flags & IEEE80211_STA_PROBEREQ_POLL ? "PROBEREQ POLL\n" : "",
-		 sdata->use_protection ? "CTS prot\n" : "");
+		 sdata->flags & IEEE80211_SDATA_USE_PROTECTION ? "CTS prot\n" : "");
 }
 __IEEE80211_IF_FILE(flags);
 
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 8a6e66f..136410c 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -575,23 +575,21 @@ static void ieee80211_set_multicast_list(struct net_device *dev)
 	unsigned short flags;
 
 	netif_tx_lock_nested(local->mdev, TX_LOCK_MASTER);
-	if (((dev->flags & IFF_ALLMULTI) != 0) ^ (sdata->allmulti != 0)) {
-		if (sdata->allmulti) {
-			sdata->allmulti = 0;
+	if (((dev->flags & IFF_ALLMULTI) != 0) ^
+	    ((sdata->flags & IEEE80211_SDATA_ALLMULTI) != 0)) {
+		if (sdata->flags & IEEE80211_SDATA_ALLMULTI)
 			local->iff_allmultis--;
-		} else {
-			sdata->allmulti = 1;
+		else
 			local->iff_allmultis++;
-		}
+		sdata->flags ^= IEEE80211_SDATA_ALLMULTI;
 	}
-	if (((dev->flags & IFF_PROMISC) != 0) ^ (sdata->promisc != 0)) {
-		if (sdata->promisc) {
-			sdata->promisc = 0;
+	if (((dev->flags & IFF_PROMISC) != 0) ^
+	    ((sdata->flags & IEEE80211_SDATA_PROMISC) != 0)) {
+		if (sdata->flags & IEEE80211_SDATA_PROMISC)
 			local->iff_promiscs--;
-		} else {
-			sdata->promisc = 1;
+		else
 			local->iff_promiscs++;
-		}
+		sdata->flags ^= IEEE80211_SDATA_PROMISC;
 	}
 	if (dev->mc_count != sdata->mc_count) {
 		local->mc_count = local->mc_count - sdata->mc_count +
@@ -761,16 +759,16 @@ void ieee80211_erp_info_change_notify(struct net_device *dev, u8 changes)
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (local->ops->erp_ie_changed)
 		local->ops->erp_ie_changed(local_to_hw(local), changes,
-					   sdata->use_protection,
-					   !sdata->short_preamble);
+			!!(sdata->flags & IEEE80211_SDATA_USE_PROTECTION),
+			!(sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE));
 }
 
 void ieee80211_reset_erp_info(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	sdata->short_preamble = 0;
-	sdata->use_protection = 0;
+	sdata->flags &= ~(IEEE80211_SDATA_USE_PROTECTION |
+			IEEE80211_SDATA_SHORT_PREAMBLE);
 	ieee80211_erp_info_change_notify(dev,
 					 IEEE80211_ERP_CHANGE_PROTECTION |
 					 IEEE80211_ERP_CHANGE_PREAMBLE);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 2c20382..5f65dd5 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -322,14 +322,14 @@ struct ieee80211_sub_if_data {
 	struct ieee80211_local *local;
 
 	int mc_count;
-	unsigned int allmulti:1;
-	unsigned int promisc:1;
-	unsigned int use_protection:1; /* CTS protect ERP frames */
-
+#define IEEE80211_SDATA_ALLMULTI	BIT(0)
+#define IEEE80211_SDATA_PROMISC		BIT(1)
+#define IEEE80211_SDATA_USE_PROTECTION	BIT(2) /* CTS protect ERP frames */
 	/* use short preamble with IEEE 802.11b: this flag is set when the AP
 	 * or beacon generator reports that there are no present stations that
 	 * cannot support short preambles */
-	unsigned int short_preamble:1;
+#define IEEE80211_SDATA_SHORT_PREAMBLE	BIT(3)
+	unsigned int flags;
 
 	struct net_device_stats stats;
 	int drop_unencrypted;
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 6283e83..4af336f 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -2187,8 +2187,12 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 
 	case PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES:
 		if (sdata->type == IEEE80211_IF_TYPE_AP) {
-			sdata->use_protection = !!value;
-			ieee80211_erp_info_change_notify(dev, IEEE80211_ERP_CHANGE_PROTECTION);
+			if (value)
+				sdata->flags |= IEEE80211_SDATA_USE_PROTECTION;
+			else
+				sdata->flags &= ~IEEE80211_SDATA_USE_PROTECTION;
+			ieee80211_erp_info_change_notify(dev,
+					IEEE80211_ERP_CHANGE_PROTECTION);
 		} else {
 			ret = -ENOENT;
 		}
@@ -2196,8 +2200,12 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 
 	case PRISM2_PARAM_PREAMBLE:
 		if (sdata->type != IEEE80211_IF_TYPE_AP) {
-			sdata->short_preamble = !!value;
-			ieee80211_erp_info_change_notify(dev, IEEE80211_ERP_CHANGE_PREAMBLE);
+			if (value)
+				sdata->flags |= IEEE80211_SDATA_SHORT_PREAMBLE;
+			else
+				sdata->flags &= ~IEEE80211_SDATA_SHORT_PREAMBLE;
+			ieee80211_erp_info_change_notify(dev,
+					IEEE80211_ERP_CHANGE_PREAMBLE);
 		} else {
 			ret = -ENOENT;
 		}
@@ -2398,11 +2406,11 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		break;
 
 	case PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES:
-		*param = sdata->use_protection;
+		*param = !!(sdata->flags & IEEE80211_SDATA_USE_PROTECTION);
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
-		*param = sdata->short_preamble;
+		*param = !!(sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE);
 		break;
 
 	case PRISM2_PARAM_STAT_TIME:
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index e6a1e8d..1cdbbd3 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -362,7 +362,7 @@ static void ieee80211_handle_erp_ie(struct net_device *dev, u8 erp_value)
 	int preamble_mode = (erp_value & WLAN_ERP_BARKER_PREAMBLE) != 0;
 	u8 changes = 0;
 
-	if (use_protection != sdata->use_protection) {
+	if (use_protection != !!(sdata->flags & IEEE80211_SDATA_USE_PROTECTION)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: CTS protection %s (BSSID="
 			       MAC_FMT ")\n",
@@ -370,11 +370,14 @@ static void ieee80211_handle_erp_ie(struct net_device *dev, u8 erp_value)
 			       use_protection ? "enabled" : "disabled",
 			       MAC_ARG(ifsta->bssid));
 		}
-		sdata->use_protection = use_protection;
+		if (use_protection)
+			sdata->flags |= IEEE80211_SDATA_USE_PROTECTION;
+		else
+			sdata->flags &= ~IEEE80211_SDATA_USE_PROTECTION;
 		changes |= IEEE80211_ERP_CHANGE_PROTECTION;
 	}
 
-	if (!preamble_mode != sdata->short_preamble) {
+	if (preamble_mode != !(sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: switched to %s barker preamble"
 			       " (BSSID=" MAC_FMT ")\n",
@@ -383,7 +386,10 @@ static void ieee80211_handle_erp_ie(struct net_device *dev, u8 erp_value)
 					"short" : "long",
 			       MAC_ARG(ifsta->bssid));
 		}
-		sdata->short_preamble = !preamble_mode;
+		if (preamble_mode)
+			sdata->flags &= ~IEEE80211_SDATA_SHORT_PREAMBLE;
+		else
+			sdata->flags |= IEEE80211_SDATA_SHORT_PREAMBLE;
 		changes |= IEEE80211_ERP_CHANGE_PREAMBLE;
 	}
 
@@ -3251,8 +3257,9 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 			       "for IBSS beacon\n", dev->name);
 			break;
 		}
-		control.tx_rate = (sdata->short_preamble &&
-				   (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
+		control.tx_rate =
+			((sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE) &&
+			(rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
 			rate->val2 : rate->val;
 		control.antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control.power_level = local->hw.conf.power_level;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 8dd7488..029e3c6 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1405,7 +1405,7 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
 		} else if (!multicast &&
 			   compare_ether_addr(sdata->dev->dev_addr,
 					      hdr->addr1) != 0) {
-			if (!sdata->promisc)
+			if (!(sdata->flags & IEEE80211_SDATA_PROMISC))
 				return 0;
 			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		}
@@ -1420,7 +1420,7 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
 		} else if (!multicast &&
 			   compare_ether_addr(sdata->dev->dev_addr,
 					      hdr->addr1) != 0) {
-			if (!sdata->promisc)
+			if (!(sdata->flags & IEEE80211_SDATA_PROMISC))
 				return 0;
 			rx->flags &= ~IEEE80211_TXRXD_RXRA_MATCH;
 		} else if (!rx->sta)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index bc4a3c7..b9ab284 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -173,7 +173,7 @@ static u16 ieee80211_duration(struct ieee80211_txrx_data *tx, int group_addr,
 	 * to closest integer */
 
 	dur = ieee80211_frame_duration(local, 10, rate, erp,
-				       tx->sdata->short_preamble);
+		       tx->sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE);
 
 	if (next_frag_len) {
 		/* Frame is fragmented: duration increases with time needed to
@@ -181,8 +181,9 @@ static u16 ieee80211_duration(struct ieee80211_txrx_data *tx, int group_addr,
 		dur *= 2; /* ACK + SIFS */
 		/* next fragment */
 		dur += ieee80211_frame_duration(local, next_frag_len,
-						txrate->rate, erp,
-						tx->sdata->short_preamble);
+				txrate->rate, erp,
+				tx->sdata->flags &
+					IEEE80211_SDATA_SHORT_PREAMBLE);
 	}
 
 	return dur;
@@ -614,7 +615,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 	if (!tx->u.tx.rate)
 		return TXRX_DROP;
 	if (tx->u.tx.mode->mode == MODE_IEEE80211G &&
-	    tx->sdata->use_protection &&
+	    (tx->sdata->flags & IEEE80211_SDATA_USE_PROTECTION) &&
 	    (tx->flags & IEEE80211_TXRXD_FRAGMENTED) && extra.nonerp) {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
 		if (extra.probe)
@@ -671,7 +672,7 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	if (mode->mode == MODE_IEEE80211G &&
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
 	    (tx->flags & IEEE80211_TXRXD_TXUNICAST) &&
-	    tx->sdata->use_protection &&
+	    (tx->sdata->flags & IEEE80211_SDATA_USE_PROTECTION) &&
 	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
@@ -680,7 +681,7 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	 * available on the network at the current point in time. */
 	if (((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) &&
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_PREAMBLE2) &&
-	    tx->sdata->short_preamble &&
+	    (tx->sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE) &&
 	    (!tx->sta || (tx->sta->flags & WLAN_STA_SHORT_PREAMBLE))) {
 		tx->u.tx.control->tx_rate = tx->u.tx.rate->val2;
 	}
@@ -1782,8 +1783,9 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw, int if_id,
 			return NULL;
 		}
 
-		control->tx_rate = (sdata->short_preamble &&
-				    (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
+		control->tx_rate =
+			((sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE) &&
+			(rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
 			rate->val2 : rate->val;
 		control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control->power_level = local->hw.conf.power_level;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 091ac0d..07686bd 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -329,7 +329,7 @@ __le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw, int if_id,
 	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
 	erp = ieee80211_is_erp_rate(hw->conf.phymode, rate);
 	dur = ieee80211_frame_duration(local, frame_len, rate,
-				       erp, sdata->short_preamble);
+		       erp, sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE);
 
 	dev_put(bdev);
 	return cpu_to_le16(dur);
@@ -352,7 +352,7 @@ __le16 ieee80211_rts_duration(struct ieee80211_hw *hw, int if_id,
 		return 0;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
-	short_preamble = sdata->short_preamble;
+	short_preamble = sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE;
 
 	rate = frame_txctl->rts_rate;
 	erp = !!(rate->flags & IEEE80211_RATE_ERP);
@@ -388,7 +388,7 @@ __le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw, int if_id,
 		return 0;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
-	short_preamble = sdata->short_preamble;
+	short_preamble = sdata->flags & IEEE80211_SDATA_SHORT_PREAMBLE;
 
 	rate = frame_txctl->rts_rate;
 	erp = !!(rate->flags & IEEE80211_RATE_ERP);
