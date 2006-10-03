From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 2/5] d80211: remove unused xr structure members, interface, etc.
Date: Tue, 3 Oct 2006 11:12:18 -0700
Message-ID: <20061003181218.GB19403@devicescape.com>
References: <20061003181118.537800000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Elliot Schwartz <elliot.schwartz@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-2.dex002.intermedia.net ([64.78.21.14]:65217 "EHLO
	dhost002-2.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750895AbWJCSMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:12:19 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="xr-removal.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elliot Schwartz <elliot.schwartz@devicescape.com> 

This is all unused.

Signed-off-by: Elliot Schwartz <elliot.schwartz@devicescape.com> 

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -82,7 +82,6 @@ struct ieee80211_hw_modes {
 	struct ieee80211_channel *channels;
 	int num_rates;
         struct ieee80211_rate *rates;
-	int xr_end; /* only used with Atheros XR */
 };
 
 struct ieee80211_tx_queue_params {
@@ -166,8 +165,6 @@ struct ieee80211_tx_control {
 					    * transmission */
 	unsigned int fast_frame:1;
 
-	unsigned int atheros_xr:1; /* only used with Atheros XR */
-
         unsigned int power_level:8; /* per-packet transmit power level, in dBm
 				     */
 	unsigned int antenna_sel:4; /* 0 = default/diversity,
@@ -193,7 +190,6 @@ struct ieee80211_tx_control {
 
 #define RX_FLAG_MMIC_ERROR       0x1
 #define RX_FLAG_DECRYPTED        0x2
-#define RX_FLAG_XR_DOUBLE_CHIRP  0x4
 
 /* Receive status. The low-level driver should provide this information
  * (the subset supported by hardware) to the 802.11 code with each received
@@ -276,8 +272,6 @@ struct ieee80211_conf {
 	int atheros_super_ag_turbo_g;
 	int atheros_super_ag_turbo_prime;
 
-	int atheros_xr;
-
 	/* Following five fields are used for IEEE 802.11H */
 	unsigned int radar_detect;
 	unsigned int spect_mgmt;
@@ -679,9 +673,6 @@ struct ieee80211_hw {
 	 * needed only for IBSS mode and the result of this function is used to
 	 * determine whether to reply to Probe Requests. */
 	int (*tx_last_beacon)(struct net_device *dev);
-
-	/* Optional handler for XR-in-use notification. */
-	int (*atheros_xr_in_use)(struct net_device *dev, int in_use);
 };
 
 /* Allocate a new hardware device. This must be called once for each
Index: wireless-dev/include/net/d80211_mgmt.h
===================================================================
--- wireless-dev.orig/include/net/d80211_mgmt.h
+++ wireless-dev/include/net/d80211_mgmt.h
@@ -220,8 +220,4 @@ enum ieee80211_eid {
 	WLAN_EID_QOS_PARAMETER = 222
 };
 
-
-
-#define ATHEROS_INFO_USEXR BIT(3)
-
 #endif /* D802_11_MGMT_H */
Index: wireless-dev/include/net/d80211_shared.h
===================================================================
--- wireless-dev.orig/include/net/d80211_shared.h
+++ wireless-dev/include/net/d80211_shared.h
@@ -21,8 +21,7 @@ enum {
 	MODE_ATHEROS_TURBOG = 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
 	MODE_ATHEROS_PRIME = 5 /* Atheros Dynamic Turbo mode */,
 	MODE_ATHEROS_PRIMEG = 6 /* Atheros Dynamic Turbo mode G */,
-	MODE_ATHEROS_XR = 7 /* Atheros XR mode  */,
-	NUM_IEEE80211_MODES = 8
+	NUM_IEEE80211_MODES = 7
 };
 
 #define IEEE80211_CHAN_W_SCAN 0x00000001
@@ -40,7 +39,6 @@ enum {
 #define IEEE80211_RATE_CCK 0x00000040
 #define IEEE80211_RATE_TURBO 0x00000080
 #define IEEE80211_RATE_MANDATORY 0x00000100
-#define IEEE80211_RATE_XR 0x00000200
 
 #define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMBLE2)
 #define IEEE80211_RATE_MODULATION(f) \
Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
@@ -186,7 +186,6 @@ struct prism2_hostapd_param {
 			 * IEEE80211_ATHEROS_SUPER_AG
 			 */
 			u8 atheros_super_ag;
-			u8 atheros_xr_mode;
 			u8 wds_flags;
 #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u8 enc_flags;
Index: wireless-dev/net/d80211/ieee80211_sysfs_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sysfs_sta.c
+++ wireless-dev/net/d80211/ieee80211_sysfs_sta.c
@@ -77,7 +77,7 @@ STA_ATTR(wep_weak_iv_count, wep_weak_iv_
 
 static ssize_t show_sta_flags(const struct sta_info *sta, char *buf)
 {
-	return sprintf(buf, "%s%s%s%s%s%s%s%s%s%s",
+	return sprintf(buf, "%s%s%s%s%s%s%s%s%s",
 		       sta->flags & WLAN_STA_AUTH ? "AUTH\n" : "",
 		       sta->flags & WLAN_STA_ASSOC ? "ASSOC\n" : "",
 		       sta->flags & WLAN_STA_PS ? "PS\n" : "",
@@ -87,8 +87,7 @@ static ssize_t show_sta_flags(const stru
 		       sta->flags & WLAN_STA_SHORT_PREAMBLE ?
 		       "SHORT PREAMBLE\n" : "",
 		       sta->flags & WLAN_STA_WME ? "WME\n" : "",
-		       sta->flags & WLAN_STA_WDS ? "WDS\n" : "",
-		       sta->flags & WLAN_STA_XR ? "XR\n" : "");
+		       sta->flags & WLAN_STA_WDS ? "WDS\n" : "");
 }
 __STA_ATTR(flags);
 
Index: wireless-dev/net/d80211/sta_info.h
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.h
+++ wireless-dev/net/d80211/sta_info.h
@@ -26,7 +26,6 @@
 				    */
 #define WLAN_STA_SHORT_PREAMBLE BIT(7)
 #define WLAN_STA_WME BIT(9)
-#define WLAN_STA_XR BIT(26)
 #define WLAN_STA_WDS BIT(27)
 
 

--
