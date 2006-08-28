From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
 and SIOCGIWPOWER
Date: Mon, 28 Aug 2006 13:45:18 -0700
Message-ID: <44F355DE.3000206@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000402030408030408060108"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:17483 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751505AbWH1UpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:45:01 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000402030408030408060108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------000402030408030408060108
Content-Type: text/x-patch;
 name="d80211-wpower.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-wpower.patch"


This patch modify d80211 to add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
and SIOCGIWPOWER. This is not a complete soluation but add the hook for
them.

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 42fdbf7..bc5eb87 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -259,6 +259,7 @@ struct ieee80211_conf {
         u8 antenna_max;			/* maximum antenna gain */
 	short tx_power_reduction; /* in 0.1 dBm */
 
+	u8 power_management_enable;     /* flag to enable/disable power management*/
 	int antenna_sel;		/* default antenna conf:
 					 *	0 = default/diversity,
 			  		 *	1 = Ant0,
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e72721f..05419d5 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4357,6 +4357,7 @@ struct net_device *ieee80211_alloc_hw(si
 	local->long_retry_limit = 4;
 	local->conf.calib_int = 60;
 	local->conf.radio_enabled = 1;
+	local->conf.power_management_enable = 0;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..d05e159 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2086,6 +2086,87 @@ static int ieee80211_ioctl_giwfrag(struc
 	return 0;
 }
 
+static int ieee80211_ioctl_giwtxpow(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, 
+				    char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	wrqu->txpower.flags = IW_TXPOW_DBM;
+	wrqu->txpower.fixed = 1;
+	wrqu->txpower.disabled = (conf->radio_enabled) ? 0 : 1;
+	wrqu->txpower.value = conf->power_level;
+	return 0;
+}
+
+
+static int ieee80211_ioctl_siwtxpow(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, 
+				    char *extra)
+{
+	int rc = 0;
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	if (wrqu->txpower.flags != IW_TXPOW_DBM)
+		rc = -EINVAL;
+	else
+		conf->power_level = wrqu->txpower.value;
+
+
+	ieee80211_ioctl_set_radio_enabled(dev, !wrqu->txpower.disabled);
+	return rc;
+}
+
+static int ieee80211_ioctl_siwpower(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, 
+				    char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	if (wrqu->power.disabled) {
+		conf->power_management_enable = 0;
+		if (ieee80211_hw_config(dev))
+			return -EINVAL;
+		return 0;
+	}
+
+	if (wrqu->power.flags & IW_POWER_TYPE)
+		return -EINVAL;
+
+	switch (wrqu->power.flags & IW_POWER_MODE) {
+	case IW_POWER_ON:       /* If not specified */
+	case IW_POWER_MODE:     /* If set all mask */
+	case IW_POWER_ALL_R:    /* If explicitely state all */
+		break;
+	default:                /* Otherwise we don't support it */
+		return -EINVAL;
+	}
+
+	conf->power_management_enable = 1;
+
+	if (ieee80211_hw_config(dev))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int ieee80211_ioctl_giwpower(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, 
+				    char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	if (!conf->power_management_enable)
+		wrqu->power.disabled = 1;
+	else
+		wrqu->power.disabled = 0;
+	return 0;
+}
+
 
 static int ieee80211_ioctl_siwretry(struct net_device *dev,
 				    struct iw_request_info *info,
@@ -3148,14 +3229,14 @@ static const iw_handler ieee80211_handle
 	(iw_handler) ieee80211_ioctl_giwrts,		/* SIOCGIWRTS */
 	(iw_handler) ieee80211_ioctl_siwfrag,		/* SIOCSIWFRAG */
 	(iw_handler) ieee80211_ioctl_giwfrag,		/* SIOCGIWFRAG */
-	(iw_handler) NULL,				/* SIOCSIWTXPOW */
-	(iw_handler) NULL,				/* SIOCGIWTXPOW */
+	(iw_handler) ieee80211_ioctl_siwtxpow,		/* SIOCSIWTXPOW */
+	(iw_handler) ieee80211_ioctl_giwtxpow,		/* SIOCGIWTXPOW */
 	(iw_handler) ieee80211_ioctl_siwretry,		/* SIOCSIWRETRY */
 	(iw_handler) ieee80211_ioctl_giwretry,		/* SIOCGIWRETRY */
 	(iw_handler) ieee80211_ioctl_siwencode,		/* SIOCSIWENCODE */
 	(iw_handler) ieee80211_ioctl_giwencode,		/* SIOCGIWENCODE */
-	(iw_handler) NULL,				/* SIOCSIWPOWER */
-	(iw_handler) NULL,				/* SIOCGIWPOWER */
+	(iw_handler) ieee80211_ioctl_siwpower,		/* SIOCSIWPOWER */
+	(iw_handler) ieee80211_ioctl_giwpower,		/* SIOCGIWPOWER */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) ieee80211_ioctl_siwgenie,		/* SIOCSIWGENIE */

--------------000402030408030408060108--
