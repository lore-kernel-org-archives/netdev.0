From: mabbas <mabbas@linux.intel.com>
Subject: [d80211] some issues regarding iwconfig parameters sequence
Date: Wed, 13 Sep 2006 14:00:43 -0700
Message-ID: <4508717B.8060403@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050107050201080101070801"
Cc: jkm@devicescape.com, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:79 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751193AbWIMVCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 17:02:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050107050201080101070801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi
I have some problem connecting if I don't follow some parameters 
sequence in iwconfig command for example if I issues the following
# iwconfig wlan0 essid test  ap xx:xx:xx:xx:xx:xx
#iwconfif wlan0 channel 9

in d80211 if essid and bssid set it will start authentication with 
default channel and authentication will timeout then after the second 
command kicks in to tune to the right channel the retry counter of 
authentication will be at maximum and we wont authenticate, same problem 
exist for IBSS it will start searching but once we call #iwconfif wlan0 
channel 9 this will stop scanning and we stop IBSS searching . I 
attached a patch for workaround this problem. I am not sure this is the 
right way to fix just attached to illustrate the problem.
Mohamed

--------------050107050201080101070801
Content-Type: text/x-patch;
 name="d80211-conn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-conn.patch"


Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 3ffdc5c..9bd385b 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1852,6 +1852,29 @@ static int ieee80211_ioctl_giwmode(struc
 	return 0;
 }
 
+#define IEEE80211_AUTH_TIMEOUT (HZ / 5)
+#define IEEE80211_AUTH_MAX_TRIES 3
+#define IEEE80211_ASSOC_TIMEOUT (HZ / 5)
+#define IEEE80211_ASSOC_MAX_TRIES 3
+
+void ieee80211_reset_tries(struct net_device *dev,
+                           struct ieee80211_if_sta *ifsta,
+			   int was_scanning)
+{
+
+	if ((ifsta->state == IEEE80211_AUTHENTICATE) &&
+	    (ifsta->auth_tries > IEEE80211_AUTH_MAX_TRIES)) {
+		ifsta->auth_tries = 0;
+		ifsta->auth_transaction = -1;
+		mod_timer(&ifsta->timer, jiffies + IEEE80211_AUTH_TIMEOUT);
+	} else if ((ifsta->assoc_tries > IEEE80211_ASSOC_MAX_TRIES) &&
+		   (ifsta->state == IEEE80211_ASSOCIATE)) {
+		ifsta->assoc_tries = 0;
+		mod_timer(&ifsta->timer, jiffies + IEEE80211_ASSOC_TIMEOUT);
+	} if (ifsta->state == IEEE80211_IBSS_SEARCH && was_scanning)
+		mod_timer(&ifsta->timer, jiffies + 2 * HZ);
+	return;
+}
 
 int ieee80211_ioctl_siwfreq(struct net_device *dev,
 			    struct iw_request_info *info,
@@ -1898,8 +1921,23 @@ int ieee80211_ioctl_siwfreq(struct net_d
 	}
 
 	if (set) {
+		struct ieee80211_sub_if_data *sdata;
+		struct ieee80211_if_sta *ifsta;
+		int ret;
+		int was_scanning;
+
+		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+		ifsta = &sdata->u.sta;
+
+		was_scanning = local->sta_scanning;
 		local->sta_scanning = 0; /* Abort possible scan */
-		return ieee80211_hw_config(dev);
+	
+		ret = ieee80211_hw_config(dev);
+
+		if (!ret)
+			ieee80211_reset_tries(dev, ifsta, was_scanning);
+
+		return ret;
 	}
 
 	return -EINVAL;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index e94cb4d..6a3011c 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2346,7 +2346,7 @@ int ieee80211_sta_set_ssid(struct net_de
 		return ieee80211_sta_find_ibss(dev, ifsta);
 	}
 
-	if (ifsta->bssid_set && ifsta->state != IEEE80211_AUTHENTICATE)
+	if (ifsta->bssid_set )
 		ieee80211_sta_new_auth(dev, ifsta);
 
 	return 0;

--------------050107050201080101070801--
