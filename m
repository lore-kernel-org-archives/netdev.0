From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/4] d80211: Add wireless statistics
Date: Thu, 02 Nov 2006 12:45:43 -0600
Message-ID: <454A3CD7.mail4R91A9NUC@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rt2400-devel@lists.sourceforge.net, flamingice@sourmilk.net,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-01.rdc-kc.rr.com ([24.94.166.115]:47865 "EHLO
	ms-smtp-01.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1752028AbWKBSqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 13:46:38 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies d80211 to support wireless statistics.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
---

John,

Please add to wireless-dev.

Larry

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -195,6 +195,8 @@ struct ieee80211_rx_status {
         int channel;
         int phymode;
         int ssi;
+	int signal;
+	int noise;
         int antenna;
         int rate;
         int flag;
@@ -479,6 +481,8 @@ struct ieee80211_hw {
         /* This is the time in us to change channels
          */
         int channel_change_time;
+	/* This is maximum value for rssi reported by this device */
+	int maxssi;
 
 	int num_modes;
 	struct ieee80211_hw_modes *modes;
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3152,6 +3152,8 @@ ieee80211_rx_h_sta_process(struct ieee80
 	sta->rx_fragments++;
 	sta->rx_bytes += rx->skb->len;
 	sta->last_rssi = rx->u.rx.status->ssi;
+	sta->last_signal = rx->u.rx.status->signal;
+	sta->last_noise = rx->u.rx.status->noise;
 
 	if (!(rx->fc & IEEE80211_FCTL_MOREFRAGS)) {
 		/* Change STA power saving mode only in the end of a frame
Index: wireless-dev/net/d80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_i.h
+++ wireless-dev/net/d80211/ieee80211_i.h
@@ -336,6 +336,7 @@ struct ieee80211_local {
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
 	int monitors;
+	struct iw_statistics wstats;
 	struct ieee80211_conf conf;
 
 	int dev_index;
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1586,6 +1586,16 @@ static int ieee80211_ioctl_giwrange(stru
 	range->min_frag = 256;
 	range->max_frag = 2346;
 
+	range->max_qual.qual = 100;
+	range->max_qual.level = 146;  /* set floor at -110 dBm (146 - 256) */
+	range->max_qual.noise = 146;
+	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
+
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 0;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_ALL_UPDATED;
+
 	return 0;
 }
 
@@ -2973,6 +2983,39 @@ static int ieee80211_ioctl_siwauth(struc
 	return ret;
 }
 
+/* Get wireless statistics.  Called by /proc/net/wireless and by SIOCGIWSTATS */
+static struct iw_statistics *ieee80211_get_wireless_stats(struct net_device *net_dev)
+{
+	struct ieee80211_local *local = net_dev->ieee80211_ptr;
+	struct iw_statistics * wstats = &local->wstats;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(net_dev);
+	struct sta_info *sta;
+	static int tmp_level = 0;
+	static int tmp_qual = 0;
+
+	sta = sta_info_get(local, sdata->u.sta.bssid);
+	if (!sta) {
+		wstats->discard.fragment = 0;
+		wstats->discard.misc = 0;
+		wstats->qual.qual = 0;
+		wstats->qual.level = 0;
+		wstats->qual.noise = 0;
+		wstats->qual.updated = IW_QUAL_ALL_INVALID;
+	} else {
+		if (!tmp_level) {	/* get initial values */
+			tmp_level = sta->last_signal;
+			tmp_qual = sta->last_rssi;
+		} else {		/* smooth results */
+			tmp_level = (15 * tmp_level + sta->last_signal)/16;
+			tmp_qual = (15 * tmp_qual + sta->last_rssi)/16;
+		}
+		wstats->qual.level = tmp_level;
+		wstats->qual.qual = 100*tmp_qual/local->hw->maxssi;
+		wstats->qual.noise = sta->last_noise;
+		wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
+	}
+	return wstats;
+}
 
 static int ieee80211_ioctl_giwauth(struct net_device *dev,
 				   struct iw_request_info *info,
@@ -3162,6 +3205,7 @@ const struct iw_handler_def ieee80211_iw
 	.standard	= (iw_handler *) ieee80211_handler,
 	.private	= (iw_handler *) ieee80211_private_handler,
 	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
+	.get_wireless_stats = ieee80211_get_wireless_stats,
 };
 
 /* Wireless handlers for master interface */
Index: wireless-dev/net/d80211/ieee80211_sysfs_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sysfs_sta.c
+++ wireless-dev/net/d80211/ieee80211_sysfs_sta.c
@@ -48,7 +48,7 @@ static ssize_t show_sta_##name(const str
 
 #define __STA_ATTR(name)						\
 static struct sta_attribute sta_attr_##name =				\
-	__ATTR(name, S_IRUSR, show_sta_##name, NULL)
+	__ATTR(name, S_IRUGO, show_sta_##name, NULL)
 
 #define STA_ATTR(name, field, format)					\
 		STA_SHOW_##format(name, field)				\
@@ -72,6 +72,8 @@ STA_ATTR(last_txrate, last_txrate, RATE)
 STA_ATTR(tx_retry_failed, tx_retry_failed, LU);
 STA_ATTR(tx_retry_count, tx_retry_count, LU);
 STA_ATTR(last_rssi, last_rssi, D);
+STA_ATTR(last_signal, last_signal, D);
+STA_ATTR(last_noise, last_noise, D);
 STA_ATTR(channel_use, channel_use, D);
 STA_ATTR(wep_weak_iv_count, wep_weak_iv_count, D);
 
@@ -174,6 +176,8 @@ static struct attribute *sta_ktype_attrs
 	&sta_attr_tx_retry_failed.attr,
 	&sta_attr_tx_retry_count.attr,
 	&sta_attr_last_rssi.attr,
+	&sta_attr_last_signal.attr,
+	&sta_attr_last_noise.attr,
 	&sta_attr_channel_use.attr,
 	&sta_attr_wep_weak_iv_count.attr,
 
Index: wireless-dev/net/d80211/sta_info.h
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.h
+++ wireless-dev/net/d80211/sta_info.h
@@ -82,6 +82,8 @@ struct sta_info {
 	unsigned long rx_dropped; /* number of dropped MPDUs from this STA */
 
 	int last_rssi; /* RSSI of last received frame from this STA */
+	int last_signal; /* signal of last received frame from this STA */
+	int last_noise; /* noise of last received frame from this STA */
 	int last_ack_rssi[3]; /* RSSI of last received ACKs from this STA */
 	unsigned long last_ack;
         int channel_use;
