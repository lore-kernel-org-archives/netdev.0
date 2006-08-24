From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/4] Try 3: Add wireless statistics to d80211
Date: Thu, 24 Aug 2006 09:51:01 -0500
Message-ID: <44EDBCD5.2070402@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:224 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932121AbWHXOvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 10:51:05 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies d80211 to add wireless statistics.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

======================================
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 42fdbf7..f696cd1 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -205,6 +205,8 @@ struct ieee80211_rx_status {
          int channel;
          int phymode;
          int ssi;
+	int signal;
+	int noise;
          int antenna;
          int rate;
          int flag;
@@ -499,6 +501,8 @@ struct ieee80211_hw {
          /* This is the time in us to change channels
           */
          int channel_change_time;
+	/* This is maximum value of rssi reported by this device */
+	int maxssi;

  	int num_modes;
  	struct ieee80211_hw_modes *modes;
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e72721f..2549484 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3175,6 +3175,8 @@ ieee80211_rx_h_sta_process(struct ieee80
  	sta->rx_fragments++;
  	sta->rx_bytes += rx->skb->len;
  	sta->last_rssi = rx->u.rx.status->ssi;
+	sta->last_signal = rx->u.rx.status->signal;
+	sta->last_noise = rx->u.rx.status->noise;

  	if (!(rx->fc & IEEE80211_FCTL_MOREFRAGS)) {
  		/* Change STA power saving mode only in the end of a frame
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0d2d79d..1271513 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -336,6 +336,7 @@ struct ieee80211_local {
  	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
  	int open_count;
  	int monitors;
+	struct iw_statistics wstats;
  	struct ieee80211_conf conf;

  	int dev_index;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..e5bd5bf 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1581,6 +1581,16 @@ static int ieee80211_ioctl_giwrange(stru
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

@@ -2996,6 +3006,39 @@ static int ieee80211_ioctl_siwauth(struc
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
+		if (!tmp_level) {       /* get initial values */
+			tmp_level = sta->last_signal;
+			tmp_qual = sta->last_rssi;
+		} else {                        /* smooth results */
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
@@ -3184,6 +3227,7 @@ const struct iw_handler_def ieee80211_iw
  	.standard	= (iw_handler *) ieee80211_handler,
  	.private	= (iw_handler *) ieee80211_private_handler,
  	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
+	.get_wireless_stats = ieee80211_get_wireless_stats,
  };

  /* Wireless handlers for master interface */
diff --git a/net/d80211/ieee80211_sysfs_sta.c b/net/d80211/ieee80211_sysfs_sta.c
index 94c6dd8..dd92b02 100644
--- a/net/d80211/ieee80211_sysfs_sta.c
+++ b/net/d80211/ieee80211_sysfs_sta.c
@@ -72,6 +72,8 @@ STA_ATTR(last_txrate, last_txrate, RATE)
  STA_ATTR(tx_retry_failed, tx_retry_failed, LU);
  STA_ATTR(tx_retry_count, tx_retry_count, LU);
  STA_ATTR(last_rssi, last_rssi, D);
+STA_ATTR(last_signal, last_signal, D);
+STA_ATTR(last_noise, last_noise, D);
  STA_ATTR(channel_use, channel_use, D);
  STA_ATTR(wep_weak_iv_count, wep_weak_iv_count, D);

@@ -175,6 +177,8 @@ static struct attribute *sta_ktype_attrs
  	&sta_attr_tx_retry_failed.attr,
  	&sta_attr_tx_retry_count.attr,
  	&sta_attr_last_rssi.attr,
+	&sta_attr_last_signal.attr,
+	&sta_attr_last_noise.attr,
  	&sta_attr_channel_use.attr,
  	&sta_attr_wep_weak_iv_count.attr,

diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 8d23047..100d039 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -82,6 +82,8 @@ struct sta_info {
  	unsigned long rx_dropped; /* number of dropped MPDUs from this STA */

  	int last_rssi; /* RSSI of last received frame from this STA */
+	int last_signal; /* signal of last received frame from this STA */
+	int last_noise; /* noise of last received frame from this STA */
  	int last_ack_rssi[3]; /* RSSI of last received ACKs from this STA */
  	unsigned long last_ack;
          int channel_use;

