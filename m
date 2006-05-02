From: "Jouni Malinen" <jkm@devicescape.com>
Subject: [PATCH wireless-dev] d80211: Add support for user space client MLME
Date: Tue, 2 May 2006 14:18:17 -0700
Message-ID: <20060502211817.GA30842@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-6.dex002.intermedia.net ([64.78.21.22]:10520 "EHLO
	dhost002-6.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964976AbWEBVSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 17:18:22 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a configuration option for disabling client MLME in kernel
code. This is used to enable user space MLME for client mode (e.g.,
with wpa_supplicant). The kernel MLME implementation is unmodified,
but it could be removed or at least made optional in build
configuration in the future.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>


Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
@@ -91,6 +91,7 @@ enum {
 	PRISM2_PARAM_KEY_MGMT = 1040,
 	PRISM2_PARAM_RADAR_DETECT = 1043,
 	PRISM2_PARAM_SPECTRUM_MGMT = 1044,
+	PRISM2_PARAM_USER_SPACE_MLME = 1045,
 	/* NOTE: Please try to coordinate with other active development
 	 * branches before allocating new param numbers so that each new param
 	 * will be unique within all branches and the allocated number will not
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3116,8 +3116,9 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 {
         struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+	if ((sdata->type == IEEE80211_IF_TYPE_STA ||
+	     sdata->type == IEEE80211_IF_TYPE_IBSS) &&
+	    !rx->local->user_space_mlme) {
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1048,10 +1048,14 @@ static int ieee80211_ioctl_scan_req(stru
 				    struct prism2_hostapd_param *param,
 				    int param_len)
 {
+	struct ieee80211_local *local = dev->priv;
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	if (left < len || len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
 
@@ -1076,8 +1080,12 @@ static int ieee80211_ioctl_sta_get_state
 static int ieee80211_ioctl_mlme(struct net_device *dev,
 				struct prism2_hostapd_param *param)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS)
@@ -1136,6 +1144,10 @@ static int ieee80211_ioctl_set_sta_vlan(
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
 	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local = dev->priv;
+
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
@@ -1745,6 +1757,7 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1754,8 +1767,16 @@ static int ieee80211_ioctl_siwessid(stru
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS)
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			if (len > IEEE80211_MAX_SSID_LEN)
+				return -EINVAL;
+			memcpy(sdata->u.sta.ssid, ssid, len);
+			sdata->u.sta.ssid_len = len;
+			return 0;
+		}
 		return ieee80211_sta_set_ssid(dev, ssid, len);
+	}
 
 	if (sdata->type == IEEE80211_IF_TYPE_AP) {
 		memcpy(sdata->u.ap.ssid, ssid, len);
@@ -1804,11 +1825,17 @@ static int ieee80211_ioctl_siwap(struct 
 				 struct iw_request_info *info,
 				 struct sockaddr *ap_addr, char *extra)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
 	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			memcpy(sdata->u.sta.bssid, (u8 *) &ap_addr->sa_data,
+			       ETH_ALEN);
+			return 0;
+		}
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
 	} else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
 		if (memcmp(sdata->u.wds.remote_addr, (u8 *) &ap_addr->sa_data,
@@ -2469,6 +2496,9 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_SPECTRUM_MGMT:
 		local->conf.spect_mgmt = value;
 		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		local->user_space_mlme = value;
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -2651,6 +2681,9 @@ static int ieee80211_ioctl_get_prism2_pa
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
 		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		*param = local->user_space_mlme;
+		break;
 
 	default:
 		ret = -EOPNOTSUPP;
Index: wireless-dev/net/d80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_i.h
+++ wireless-dev/net/d80211/ieee80211_i.h
@@ -502,6 +502,8 @@ struct ieee80211_local {
 
 	unsigned int hw_modes; /* bitfield of allowed hardware modes;
 				* (1 << MODE_*) */
+
+	int user_space_mlme;
 };
 
 
-- 
Jouni Malinen                                            PGP id EFC895FA
