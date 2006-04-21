From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/17] d80211: rename adm_status to radio_enabled
Date: Fri, 21 Apr 2006 22:11:42 +0200 (CEST)
Message-ID: <20060421201142.95318482C0@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14215 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932416AbWDUULO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:14 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PRISM2_PARAM_ADM_STATUS is not much descriptive name. This patch renames it
to PRISM2_PARAM_RADIO_ENABLED, sets radio_enabled to 1 by default (this is
no problem as radio must not be enabled until at least one network interface
is running) and removes automatic setting of adm_status when interface is in
a STA mode.

Later, PRISM2_PARAM_RADIO_ENABLED value can be removed and radio_enabled set
by SIOCSIWTXPOW handler (ie. by iwconfig txpower off).

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |    6 +++++-
 net/d80211/hostapd_ioctl.h   |    2 +-
 net/d80211/ieee80211.c       |    1 +
 net/d80211/ieee80211_ioctl.c |   11 +++++------
 4 files changed, 12 insertions(+), 8 deletions(-)

16a5dd7f47ba97ad3e19fe19a96a8d483dc29bbf
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 84abd7c..2ec31db 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -237,6 +237,10 @@ struct ieee80211_tx_status {
 };
 
 
+/**
+ * struct ieee80211_conf - configuration of a hardware
+ * @radio_enabled: when zero, driver is required to switch off the radio.
+ */
 struct ieee80211_conf {
 	int channel;			/* IEEE 802.11 channel number */
 	int freq;			/* MHz */
@@ -244,7 +248,7 @@ struct ieee80211_conf {
 
 	int phymode;			/* MODE_IEEE80211A, .. */
         unsigned int regulatory_domain;
-        int adm_status;
+	int radio_enabled;
 
         int beacon_int;
 
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 028caf1..a462688 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -64,7 +64,7 @@ enum {
 	PRISM2_PARAM_TEST_MODE = 1007,
 	PRISM2_PARAM_NEXT_MODE = 1008,
 	PRISM2_PARAM_CLEAR_KEYS = 1009,
-	PRISM2_PARAM_ADM_STATUS = 1010,
+	PRISM2_PARAM_RADIO_ENABLED = 1010,
 	PRISM2_PARAM_ANTENNA_SEL = 1011,
 	PRISM2_PARAM_CALIB_INT = 1012,
         PRISM2_PARAM_ANTENNA_MODE = 1013,
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e6d4342..16a07d0 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4330,6 +4330,7 @@ struct net_device *ieee80211_alloc_hw(si
 	local->short_retry_limit = 7;
 	local->long_retry_limit = 4;
 	local->conf.calib_int = 60;
+	local->conf.radio_enabled = 1;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 00efe47..6279a7a 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1166,11 +1166,11 @@ static int ieee80211_ioctl_set_regulator
 }
 
 
-static int ieee80211_ioctl_set_adm_status(struct net_device *dev,
-					  int val)
+static int ieee80211_ioctl_set_radio_enabled(struct net_device *dev,
+					     int val)
 {
         struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
-        conf->adm_status = val;
+	conf->radio_enabled = val;
         return ieee80211_hw_config(dev);
 }
 
@@ -1580,7 +1580,6 @@ static int ieee80211_init_client(struct 
 	if (ieee80211_regdom == 0x40)
 		channel_range = ieee80211_mkk_channels;
 	ieee80211_unmask_channels(dev);
-	ieee80211_ioctl_set_adm_status(dev, 1);
 	return 0;
 }
 
@@ -2312,8 +2311,8 @@ static int ieee80211_ioctl_prism2_param(
 		ret = ieee80211_ioctl_clear_keys(dev);
 		break;
 
-	case PRISM2_PARAM_ADM_STATUS:
-                ret = ieee80211_ioctl_set_adm_status(dev, value);
+	case PRISM2_PARAM_RADIO_ENABLED:
+		ret = ieee80211_ioctl_set_radio_enabled(dev, value);
 		break;
 
 	case PRISM2_PARAM_ANTENNA_SEL:
-- 
1.3.0

