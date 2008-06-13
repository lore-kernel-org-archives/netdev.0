From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/12]: Proper compat WEXT support.
Date: Thu, 12 Jun 2008 22:53:32 -0700 (PDT)
Message-ID: <20080612.225332.193703791.davem@davemloft.net>
References: <20080603.132755.262737024.davem@davemloft.net>
	<20080604184955.B033.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751535AbYFMFxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 01:53:33 -0400
In-Reply-To: <20080604184955.B033.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Date: Wed, 04 Jun 2008 19:09:06 +0900

> I think the callers of iwe_stream_add_value() need to do some
> preparations before the call if iocompat is needed, like the following.

Masakazu-san, thank you again for your testing and feedback.

Here is a new version of patch 12, which should fix the problems
you reported here.  The idea is simple, all references to
IW_EV_LCP_LEN are replaced with calls to a new inline function
named iwe_stream_lcp_len() which returns the compat value if
necessary.

wext: Emit event stream entries correctly when compat.

Three major portions to this change:

1) Add IW_EV_COMPAT_LCP_LEN, IW_EV_COMPAT_POINT_OFF,
   and IW_EV_COMPAT_POINT_LEN helper defines.

2) Delete iw_stream_check_add_*(), they are unused.

3) Add iw_request_info argument to iwe_stream_add_*(), and use it to
   size the event and pointer lengths correctly depending upon whether
   IW_REQUEST_FLAG_COMPAT is set or not.

4) The mechanical transformations to the drivers and wireless stack
   bits to get the iw_request_info passed down into the routines
   modified in #3.  Also, explicit references to IW_EV_LCP_LEN are
   replaced with iwe_stream_lcp_len(info).

With a lot of help and bug fixes from Masakazu Mokuno.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ps3_gelic_wireless.c           |   30 +++---
 drivers/net/wireless/airo.c                |   43 +++++---
 drivers/net/wireless/atmel.c               |   24 ++++-
 drivers/net/wireless/hostap/hostap.h       |    3 +-
 drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
 drivers/net/wireless/hostap/hostap_ioctl.c |   58 ++++++-----
 drivers/net/wireless/libertas/scan.c       |   36 ++++---
 drivers/net/wireless/orinoco.c             |   23 +++--
 drivers/net/wireless/prism54/isl_ioctl.c   |   49 +++++----
 drivers/net/wireless/rndis_wlan.c          |   31 +++---
 drivers/net/wireless/wl3501_cs.c           |   10 +-
 drivers/net/wireless/zd1201.c              |   21 +++--
 include/linux/wireless.h                   |   15 +++
 include/net/iw_handler.h                   |  149 +++++++++-------------------
 net/ieee80211/ieee80211_wx.c               |   48 +++++----
 net/mac80211/ieee80211_i.h                 |    5 +-
 net/mac80211/mlme.c                        |   45 +++++----
 net/mac80211/wext.c                        |    2 +-
 18 files changed, 323 insertions(+), 301 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 1dae1f2..6e48162 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -553,6 +553,7 @@ static void gelic_wl_parse_ie(u8 *data, size_t len,
  * independent format
  */
 static char *gelic_wl_translate_scan(struct net_device *netdev,
+				     struct iw_request_info *info,
 				     char *ev,
 				     char *stop,
 				     struct gelic_wl_scan_info *network)
@@ -570,26 +571,26 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, &scan->bssid[2], ETH_ALEN);
-	ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_ADDR_LEN);
+	ev = iwe_stream_add_event(info, ev, stop, &iwe, IW_EV_ADDR_LEN);
 
 	/* ESSID */
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
 	iwe.u.data.length = strnlen(scan->essid, 32);
-	ev = iwe_stream_add_point(ev, stop, &iwe, scan->essid);
+	ev = iwe_stream_add_point(info, ev, stop, &iwe, scan->essid);
 
 	/* FREQUENCY */
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = be16_to_cpu(scan->channel);
 	iwe.u.freq.e = 0; /* table value in MHz */
 	iwe.u.freq.i = 0;
-	ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_FREQ_LEN);
+	ev = iwe_stream_add_event(info, ev, stop, &iwe, IW_EV_FREQ_LEN);
 
 	/* RATES */
 	iwe.cmd = SIOCGIWRATE;
 	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
 	/* to stuff multiple values in one event */
-	tmp = ev + IW_EV_LCP_LEN;
+	tmp = ev + iwe_stream_lcp_len(info);
 	/* put them in ascendant order (older is first) */
 	i = 0;
 	j = 0;
@@ -602,16 +603,16 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 		else
 		    rate = scan->rate[i++] & 0x7f;
 		iwe.u.bitrate.value = rate * 500000; /* 500kbps unit */
-		tmp = iwe_stream_add_value(ev, tmp, stop, &iwe,
+		tmp = iwe_stream_add_value(info, ev, tmp, stop, &iwe,
 					   IW_EV_PARAM_LEN);
 	}
 	while (j < network->rate_ext_len) {
 		iwe.u.bitrate.value = (scan->ext_rate[j++] & 0x7f) * 500000;
-		tmp = iwe_stream_add_value(ev, tmp, stop, &iwe,
+		tmp = iwe_stream_add_value(info, ev, tmp, stop, &iwe,
 					   IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any rate */
-	if (IW_EV_LCP_LEN < (tmp - ev))
+	if (iwe_stream_lcp_len(info) < (tmp - ev))
 		ev = tmp;
 
 	/* ENCODE */
@@ -621,7 +622,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	ev = iwe_stream_add_point(ev, stop, &iwe, scan->essid);
+	ev = iwe_stream_add_point(info, ev, stop, &iwe, scan->essid);
 
 	/* MODE */
 	iwe.cmd = SIOCGIWMODE;
@@ -631,7 +632,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_UINT_LEN);
+		ev = iwe_stream_add_event(info, ev, stop, &iwe, IW_EV_UINT_LEN);
 	}
 
 	/* QUAL */
@@ -641,7 +642,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 	iwe.u.qual.level = be16_to_cpu(scan->rssi);
 	iwe.u.qual.qual = be16_to_cpu(scan->rssi);
 	iwe.u.qual.noise = 0;
-	ev  = iwe_stream_add_event(ev, stop, &iwe, IW_EV_QUAL_LEN);
+	ev  = iwe_stream_add_event(info, ev, stop, &iwe, IW_EV_QUAL_LEN);
 
 	/* RSN */
 	memset(&iwe, 0, sizeof(iwe));
@@ -651,7 +652,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 		if (len) {
 			iwe.cmd = IWEVGENIE;
 			iwe.u.data.length = len;
-			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+			ev = iwe_stream_add_point(info, ev, stop, &iwe, buf);
 		}
 	} else {
 		/* this scan info has IE data */
@@ -666,7 +667,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 			memcpy(buf, ie_info.wpa.data, ie_info.wpa.len);
 			iwe.cmd = IWEVGENIE;
 			iwe.u.data.length = ie_info.wpa.len;
-			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+			ev = iwe_stream_add_point(info, ev, stop, &iwe, buf);
 		}
 
 		if (ie_info.rsn.len && (ie_info.rsn.len <= sizeof(buf))) {
@@ -674,7 +675,7 @@ static char *gelic_wl_translate_scan(struct net_device *netdev,
 			memcpy(buf, ie_info.rsn.data, ie_info.rsn.len);
 			iwe.cmd = IWEVGENIE;
 			iwe.u.data.length = ie_info.rsn.len;
-			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+			ev = iwe_stream_add_point(info, ev, stop, &iwe, buf);
 		}
 	}
 
@@ -719,7 +720,8 @@ static int gelic_wl_get_scan(struct net_device *netdev,
 		if (wl->scan_age == 0 ||
 		    time_after(scan_info->last_scanned + wl->scan_age,
 			       this_time))
-			ev = gelic_wl_translate_scan(netdev, ev, stop,
+			ev = gelic_wl_translate_scan(netdev, info,
+						     ev, stop,
 						     scan_info);
 		else
 			pr_debug("%s:entry too old\n", __func__);
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 17ced37..ff4f4fd 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -7165,6 +7165,7 @@ out:
  * format that the Wireless Tools will understand - Jean II
  */
 static inline char *airo_translate_scan(struct net_device *dev,
+					struct iw_request_info *info,
 					char *current_ev,
 					char *end_buf,
 					BSSListRid *bss)
@@ -7181,7 +7182,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
 
@@ -7191,7 +7193,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.u.data.length = 32;
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, bss->ssid);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -7201,7 +7204,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 	}
 
 	/* Add frequency */
@@ -7212,7 +7216,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	 */
 	iwe.u.freq.m = frequency_list[iwe.u.freq.m - 1] * 100000;
 	iwe.u.freq.e = 1;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_FREQ_LEN);
 
 	dBm = le16_to_cpu(bss->dBm);
 
@@ -7232,7 +7237,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 				| IW_QUAL_DBM;
 	}
 	iwe.u.qual.noise = ai->wstats.qual.noise;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -7241,11 +7247,12 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, bss->ssid);
 
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
-	current_val = current_ev + IW_EV_LCP_LEN;
+	current_val = current_ev + iwe_stream_lcp_len(info);
 
 	iwe.cmd = SIOCGIWRATE;
 	/* Those two flags are ignored... */
@@ -7258,10 +7265,12 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		/* Bit rate given in 500 kb/s units (+ 0x80) */
 		iwe.u.bitrate.value = ((bss->rates[i] & 0x7f) * 500000);
 		/* Add new value to event */
-		current_val = iwe_stream_add_value(current_ev, current_val, end_buf, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, current_ev,
+						   current_val, end_buf,
+						   &iwe, IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any event */
-	if((current_val - current_ev) > IW_EV_LCP_LEN)
+	if((current_val - current_ev) > iwe_stream_lcp_len(info))
 		current_ev = current_val;
 
 	/* Beacon interval */
@@ -7270,7 +7279,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d", bss->beaconInterval);
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 		kfree(buf);
 	}
 
@@ -7304,8 +7314,10 @@ static inline char *airo_translate_scan(struct net_device *dev,
 					iwe.cmd = IWEVGENIE;
 					iwe.u.data.length = min(info_element->len + 2,
 								  MAX_WPA_IE_LEN);
-					current_ev = iwe_stream_add_point(current_ev, end_buf,
-							&iwe, (char *) info_element);
+					current_ev = iwe_stream_add_point(
+							info, current_ev,
+							end_buf, &iwe,
+							(char *) info_element);
 				}
 				break;
 
@@ -7313,8 +7325,9 @@ static inline char *airo_translate_scan(struct net_device *dev,
 				iwe.cmd = IWEVGENIE;
 				iwe.u.data.length = min(info_element->len + 2,
 							  MAX_WPA_IE_LEN);
-				current_ev = iwe_stream_add_point(current_ev, end_buf,
-						&iwe, (char *) info_element);
+				current_ev = iwe_stream_add_point(
+					info, current_ev, end_buf,
+					&iwe, (char *) info_element);
 				break;
 
 			default:
@@ -7353,7 +7366,7 @@ static int airo_get_scan(struct net_device *dev,
 
 	list_for_each_entry (net, &ai->network_list, list) {
 		/* Translate to WE format this entry */
-		current_ev = airo_translate_scan(dev, current_ev,
+		current_ev = airo_translate_scan(dev, info, current_ev,
 						 extra + dwrq->length,
 						 &net->bss);
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index f978a9d..51885df 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -2310,30 +2310,40 @@ static int atmel_get_scan(struct net_device *dev,
 		iwe.cmd = SIOCGIWAP;
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, priv->BSSinfo[i].BSSID, 6);
-		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_ADDR_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, IW_EV_ADDR_LEN);
 
 		iwe.u.data.length =  priv->BSSinfo[i].SSIDsize;
 		if (iwe.u.data.length > 32)
 			iwe.u.data.length = 32;
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, priv->BSSinfo[i].SSID);
+		current_ev = iwe_stream_add_point(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, priv->BSSinfo[i].SSID);
 
 		iwe.cmd = SIOCGIWMODE;
 		iwe.u.mode = priv->BSSinfo[i].BSStype;
-		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, IW_EV_UINT_LEN);
 
 		iwe.cmd = SIOCGIWFREQ;
 		iwe.u.freq.m = priv->BSSinfo[i].channel;
 		iwe.u.freq.e = 0;
-		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_FREQ_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, IW_EV_FREQ_LEN);
 
 		/* Add quality statistics */
 		iwe.cmd = IWEVQUAL;
 		iwe.u.qual.level = priv->BSSinfo[i].RSSI;
 		iwe.u.qual.qual  = iwe.u.qual.level;
 		/* iwe.u.qual.noise  = SOMETHING */
-		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA , &iwe, IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, IW_EV_QUAL_LEN);
 
 
 		iwe.cmd = SIOCGIWENCODE;
@@ -2342,7 +2352,9 @@ static int atmel_get_scan(struct net_device *dev,
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
 		iwe.u.data.length = 0;
-		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, NULL);
+		current_ev = iwe_stream_add_point(info, current_ev,
+						  extra + IW_SCAN_MAX_DATA,
+						  &iwe, NULL);
 	}
 
 	/* Length of data */
diff --git a/drivers/net/wireless/hostap/hostap.h b/drivers/net/wireless/hostap/hostap.h
index 547ba84..3a386a6 100644
--- a/drivers/net/wireless/hostap/hostap.h
+++ b/drivers/net/wireless/hostap/hostap.h
@@ -67,7 +67,8 @@ void * ap_crypt_get_ptrs(struct ap_data *ap, u8 *addr, int permanent,
 int prism2_ap_get_sta_qual(local_info_t *local, struct sockaddr addr[],
 			   struct iw_quality qual[], int buf_size,
 			   int aplist);
-int prism2_ap_translate_scan(struct net_device *dev, char *buffer);
+int prism2_ap_translate_scan(struct net_device *dev,
+			     struct iw_request_info *info, char *buffer);
 int prism2_hostapd(struct ap_data *ap, struct prism2_hostapd_param *param);
 
 
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 0acd958..06b23df 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -2420,7 +2420,8 @@ int prism2_ap_get_sta_qual(local_info_t *local, struct sockaddr addr[],
 
 /* Translate our list of Access Points & Stations to a card independant
  * format that the Wireless Tools will understand - Jean II */
-int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
+int prism2_ap_translate_scan(struct net_device *dev,
+			     struct iw_request_info *info, char *buffer)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -2449,8 +2450,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, sta->addr, ETH_ALEN);
 		iwe.len = IW_EV_ADDR_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_ADDR_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_ADDR_LEN);
 
 		/* Use the mode to indicate if it's a station or
 		 * an Access Point */
@@ -2461,8 +2462,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		else
 			iwe.u.mode = IW_MODE_INFRA;
 		iwe.len = IW_EV_UINT_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 
 		/* Some quality */
 		memset(&iwe, 0, sizeof(iwe));
@@ -2477,8 +2478,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		iwe.u.qual.noise = HFA384X_LEVEL_TO_dBm(sta->last_rx_silence);
 		iwe.u.qual.updated = sta->last_rx_updated;
 		iwe.len = IW_EV_QUAL_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_QUAL_LEN);
 
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 		if (sta->ap) {
@@ -2486,8 +2487,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 			iwe.cmd = SIOCGIWESSID;
 			iwe.u.data.length = sta->u.ap.ssid_len;
 			iwe.u.data.flags = 1;
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe,
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe,
 							  sta->u.ap.ssid);
 
 			memset(&iwe, 0, sizeof(iwe));
@@ -2497,10 +2498,9 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 					IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
 			else
 				iwe.u.data.flags = IW_ENCODE_DISABLED;
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe,
-							  sta->u.ap.ssid
-							  /* 0 byte memcpy */);
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe,
+							  sta->u.ap.ssid);
 
 			if (sta->u.ap.channel > 0 &&
 			    sta->u.ap.channel <= FREQ_COUNT) {
@@ -2510,7 +2510,7 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 					* 100000;
 				iwe.u.freq.e = 1;
 				current_ev = iwe_stream_add_event(
-					current_ev, end_buf, &iwe,
+					info, current_ev, end_buf, &iwe,
 					IW_EV_FREQ_LEN);
 			}
 
@@ -2519,8 +2519,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 			sprintf(buf, "beacon_interval=%d",
 				sta->listen_interval);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe, buf);
 		}
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 0ca0bfe..ed52d98 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1793,6 +1793,7 @@ static int prism2_ioctl_siwscan(struct net_device *dev,
 
 #ifndef PRISM2_NO_STATION_MODES
 static char * __prism2_translate_scan(local_info_t *local,
+				      struct iw_request_info *info,
 				      struct hfa384x_hostscan_result *scan,
 				      struct hostap_bss_info *bss,
 				      char *current_ev, char *end_buf)
@@ -1823,7 +1824,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
@@ -1832,7 +1833,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.length = ssid_len;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, ssid);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWMODE;
@@ -1847,8 +1849,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1864,8 +1866,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 	if (chan > 0) {
 		iwe.u.freq.m = freq_list[chan - 1] * 100000;
 		iwe.u.freq.e = 1;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_FREQ_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_FREQ_LEN);
 	}
 
 	if (scan) {
@@ -1884,8 +1886,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 			| IW_QUAL_NOISE_UPDATED
 			| IW_QUAL_QUAL_INVALID
 			| IW_QUAL_DBM;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_QUAL_LEN);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1895,13 +1897,13 @@ static char * __prism2_translate_scan(local_info_t *local,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, "");
 
 	/* TODO: add SuppRates into BSS table */
 	if (scan) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = SIOCGIWRATE;
-		current_val = current_ev + IW_EV_LCP_LEN;
+		current_val = current_ev + iwe_stream_lcp_len(info);
 		pos = scan->sup_rates;
 		for (i = 0; i < sizeof(scan->sup_rates); i++) {
 			if (pos[i] == 0)
@@ -1909,11 +1911,11 @@ static char * __prism2_translate_scan(local_info_t *local,
 			/* Bit rate given in 500 kb/s units (+ 0x80) */
 			iwe.u.bitrate.value = ((pos[i] & 0x7f) * 500000);
 			current_val = iwe_stream_add_value(
-				current_ev, current_val, end_buf, &iwe,
+				info, current_ev, current_val, end_buf, &iwe,
 				IW_EV_PARAM_LEN);
 		}
 		/* Check if we added any event */
-		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+		if ((current_val - current_ev) > iwe_stream_lcp_len(info))
 			current_ev = current_val;
 	}
 
@@ -1924,15 +1926,15 @@ static char * __prism2_translate_scan(local_info_t *local,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d", le16_to_cpu(scan->beacon_interval));
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "resp_rate=%d", le16_to_cpu(scan->rate));
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 
 		if (local->last_scan_type == PRISM2_HOSTSCAN &&
 		    (capabilities & WLAN_CAPABILITY_IBSS)) {
@@ -1940,8 +1942,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 			iwe.cmd = IWEVCUSTOM;
 			sprintf(buf, "atim=%d", le16_to_cpu(scan->atim));
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe, buf);
 		}
 	}
 	kfree(buf);
@@ -1950,16 +1952,16 @@ static char * __prism2_translate_scan(local_info_t *local,
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
-		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, bss->wpa_ie);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, bss->wpa_ie);
 	}
 
 	if (bss && bss->rsn_ie_len > 0 && bss->rsn_ie_len <= MAX_WPA_IE_LEN) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, bss->rsn_ie);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, bss->rsn_ie);
 	}
 
 	return current_ev;
@@ -1969,6 +1971,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 /* Translate scan data returned from the card to a card independant
  * format that the Wireless Tools will understand - Jean II */
 static inline int prism2_translate_scan(local_info_t *local,
+					struct iw_request_info *info,
 					char *buffer, int buflen)
 {
 	struct hfa384x_hostscan_result *scan;
@@ -1999,13 +2002,14 @@ static inline int prism2_translate_scan(local_info_t *local,
 			if (memcmp(bss->bssid, scan->bssid, ETH_ALEN) == 0) {
 				bss->included = 1;
 				current_ev = __prism2_translate_scan(
-					local, scan, bss, current_ev, end_buf);
+					local, info, scan, bss, current_ev,
+					end_buf);
 				found++;
 			}
 		}
 		if (!found) {
 			current_ev = __prism2_translate_scan(
-				local, scan, NULL, current_ev, end_buf);
+				local, info, scan, NULL, current_ev, end_buf);
 		}
 		/* Check if there is space for one more entry */
 		if ((end_buf - current_ev) <= IW_EV_ADDR_LEN) {
@@ -2023,7 +2027,7 @@ static inline int prism2_translate_scan(local_info_t *local,
 		bss = list_entry(ptr, struct hostap_bss_info, list);
 		if (bss->included)
 			continue;
-		current_ev = __prism2_translate_scan(local, NULL, bss,
+		current_ev = __prism2_translate_scan(local, info, NULL, bss,
 						     current_ev, end_buf);
 		/* Check if there is space for one more entry */
 		if ((end_buf - current_ev) <= IW_EV_ADDR_LEN) {
@@ -2070,7 +2074,7 @@ static inline int prism2_ioctl_giwscan_sta(struct net_device *dev,
 	}
 	local->scan_timestamp = 0;
 
-	res = prism2_translate_scan(local, extra, data->length);
+	res = prism2_translate_scan(local, info, extra, data->length);
 
 	if (res >= 0) {
 		data->length = res;
@@ -2103,7 +2107,7 @@ static int prism2_ioctl_giwscan(struct net_device *dev,
 		 * Jean II */
 
 		/* Translate to WE format */
-		res = prism2_ap_translate_scan(dev, extra);
+		res = prism2_ap_translate_scan(dev, info, extra);
 		if (res >= 0) {
 			printk(KERN_DEBUG "Scan result translation succeeded "
 			       "(length=%d)\n", res);
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index d448c97..8e2b719 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -776,8 +776,9 @@ out:
 #define MAX_CUSTOM_LEN 64
 
 static inline char *lbs_translate_scan(struct lbs_private *priv,
-				       char *start, char *stop,
-				       struct bss_descriptor *bss)
+					    struct iw_request_info *info,
+					    char *start, char *stop,
+					    struct bss_descriptor *bss)
 {
 	struct chan_freq_power *cfp;
 	char *current_val;	/* For rates */
@@ -801,24 +802,24 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, &bss->bssid, ETH_ALEN);
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_ADDR_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_ADDR_LEN);
 
 	/* SSID */
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
 	iwe.u.data.length = min((uint32_t) bss->ssid_len, (uint32_t) IW_ESSID_MAX_SIZE);
-	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid);
+	start = iwe_stream_add_point(info, start, stop, &iwe, bss->ssid);
 
 	/* Mode */
 	iwe.cmd = SIOCGIWMODE;
 	iwe.u.mode = bss->mode;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_UINT_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_UINT_LEN);
 
 	/* Frequency */
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = (long)cfp->freq * 100000;
 	iwe.u.freq.e = 1;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_FREQ_LEN);
 
 	/* Add quality statistics */
 	iwe.cmd = IWEVQUAL;
@@ -852,7 +853,7 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 		nf = priv->NF[TYPE_RXPD][TYPE_AVG] / AVG_SCALE;
 		iwe.u.qual.level = CAL_RSSI(snr, nf);
 	}
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_QUAL_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -862,9 +863,9 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	}
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid);
+	start = iwe_stream_add_point(info, start, stop, &iwe, bss->ssid);
 
-	current_val = start + IW_EV_LCP_LEN;
+	current_val = start + iwe_stream_lcp_len(info);
 
 	iwe.cmd = SIOCGIWRATE;
 	iwe.u.bitrate.fixed = 0;
@@ -874,19 +875,19 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 	for (j = 0; bss->rates[j] && (j < sizeof(bss->rates)); j++) {
 		/* Bit rate given in 500 kb/s units */
 		iwe.u.bitrate.value = bss->rates[j] * 500000;
-		current_val = iwe_stream_add_value(start, current_val,
-					 stop, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, start, current_val,
+						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	if ((bss->mode == IW_MODE_ADHOC) && priv->adhoccreate
 	    && !lbs_ssid_cmp(priv->curbssparams.ssid,
 			     priv->curbssparams.ssid_len,
 			     bss->ssid, bss->ssid_len)) {
 		iwe.u.bitrate.value = 22 * 500000;
-		current_val = iwe_stream_add_value(start, current_val,
+		current_val = iwe_stream_add_value(info, start, current_val,
 						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any event */
-	if((current_val - start) > IW_EV_LCP_LEN)
+	if((current_val - start) > iwe_stream_lcp_len(info))
 		start = current_val;
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -895,7 +896,7 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 		memcpy(buf, bss->wpa_ie, bss->wpa_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -904,7 +905,7 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 		memcpy(buf, bss->rsn_ie, bss->rsn_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	if (bss->mesh) {
@@ -915,7 +916,8 @@ static inline char *lbs_translate_scan(struct lbs_private *priv,
 		p += snprintf(p, MAX_CUSTOM_LEN, "mesh-type: olpc");
 		iwe.u.data.length = p - custom;
 		if (iwe.u.data.length)
-			start = iwe_stream_add_point(start, stop, &iwe, custom);
+			start = iwe_stream_add_point(info, start, stop,
+						     &iwe, custom);
 	}
 
 out:
@@ -1036,7 +1038,7 @@ int lbs_get_scan(struct net_device *dev, struct iw_request_info *info,
 		}
 
 		/* Translate to WE format this entry */
-		next_ev = lbs_translate_scan(priv, ev, stop, iter_bss);
+		next_ev = lbs_translate_scan(priv, info, ev, stop, iter_bss);
 		if (next_ev == NULL)
 			continue;
 		ev = next_ev;
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 6d13a0d..0e4feaf 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -4046,6 +4046,7 @@ static int orinoco_ioctl_setscan(struct net_device *dev,
  * format that the Wireless Tools will understand - Jean II
  * Return message length or -errno for fatal errors */
 static inline char *orinoco_translate_scan(struct net_device *dev,
+					   struct iw_request_info *info,
 					   char *current_ev,
 					   char *end_buf,
 					   union hermes_scan_info *bss,
@@ -4062,7 +4063,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->a.bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
 
@@ -4072,7 +4073,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 		iwe.u.data.length = 32;
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->a.essid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, bss->a.essid);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -4082,7 +4083,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
 	}
 
 	channel = bss->s.channel;
@@ -4091,7 +4092,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 		iwe.cmd = SIOCGIWFREQ;
 		iwe.u.freq.m = channel_frequency[channel-1] * 100000;
 		iwe.u.freq.e = 1;
-		current_ev = iwe_stream_add_event(current_ev, end_buf,
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
 						  &iwe, IW_EV_FREQ_LEN);
 	}
 
@@ -4106,7 +4107,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 		iwe.u.qual.qual = iwe.u.qual.level - iwe.u.qual.noise;
 	else
 		iwe.u.qual.qual = 0;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -4115,7 +4116,7 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->a.essid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, bss->a.essid);
 
 	/* Add EXTRA: Age to display seconds since last beacon/probe response
 	 * for given network. */
@@ -4126,11 +4127,11 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 		      jiffies_to_msecs(jiffies - last_scanned));
 	iwe.u.data.length = p - custom;
 	if (iwe.u.data.length)
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, custom);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, custom);
 
 	/* Bit rate is not available in Lucent/Agere firmwares */
 	if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
-		char *current_val = current_ev + IW_EV_LCP_LEN;
+		char *current_val = current_ev + iwe_stream_lcp_len(info);
 		int i;
 		int step;
 
@@ -4149,12 +4150,12 @@ static inline char *orinoco_translate_scan(struct net_device *dev,
 				break;
 			/* Bit rate given in 500 kb/s units (+ 0x80) */
 			iwe.u.bitrate.value = ((bss->p.rates[i] & 0x7f) * 500000);
-			current_val = iwe_stream_add_value(current_ev, current_val,
+			current_val = iwe_stream_add_value(info, current_ev, current_val,
 							   end_buf, &iwe,
 							   IW_EV_PARAM_LEN);
 		}
 		/* Check if we added any event */
-		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+		if ((current_val - current_ev) > iwe_stream_lcp_len(info))
 			current_ev = current_val;
 	}
 
@@ -4190,7 +4191,7 @@ static int orinoco_ioctl_getscan(struct net_device *dev,
 
 	list_for_each_entry(bss, &priv->bss_list, list) {
 		/* Translate to WE format this entry */
-		current_ev = orinoco_translate_scan(dev, current_ev,
+		current_ev = orinoco_translate_scan(dev, info, current_ev,
 						    extra + srq->length,
 						    &bss->bss,
 						    bss->last_scanned);
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 5b375b2..c34790e 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -571,8 +571,9 @@ prism54_set_scan(struct net_device *dev, struct iw_request_info *info,
  */
 
 static char *
-prism54_translate_bss(struct net_device *ndev, char *current_ev,
-		      char *end_buf, struct obj_bss *bss, char noise)
+prism54_translate_bss(struct net_device *ndev, struct iw_request_info *info,
+		      char *current_ev, char *end_buf, struct obj_bss *bss,
+		      char noise)
 {
 	struct iw_event iwe;	/* Temporary buffer */
 	short cap;
@@ -584,8 +585,8 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	iwe.cmd = SIOCGIWAP;
-	current_ev =
-	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_ADDR_LEN);
 
 	/* The following entries will be displayed in the same order we give them */
 
@@ -593,7 +594,7 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	iwe.u.data.length = bss->ssid.length;
 	iwe.u.data.flags = 1;
 	iwe.cmd = SIOCGIWESSID;
-	current_ev = iwe_stream_add_point(current_ev, end_buf,
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 					  &iwe, bss->ssid.octets);
 
 	/* Capabilities */
@@ -610,9 +611,8 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		iwe.u.mode = IW_MODE_ADHOC;
 	iwe.cmd = SIOCGIWMODE;
 	if (iwe.u.mode)
-		current_ev =
-		    iwe_stream_add_event(current_ev, end_buf, &iwe,
-					 IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 
 	/* Encryption capability */
 	if (cap & CAP_CRYPT)
@@ -621,14 +621,15 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
 	iwe.cmd = SIOCGIWENCODE;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, NULL);
 
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
 	iwe.u.freq.m = bss->channel;
 	iwe.u.freq.e = 6;
 	iwe.cmd = SIOCGIWFREQ;
-	current_ev =
-	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_FREQ_LEN);
 
 	/* Add quality statistics */
 	iwe.u.qual.level = bss->rssi;
@@ -636,20 +637,20 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	/* do a simple SNR for quality */
 	iwe.u.qual.qual = bss->rssi - noise;
 	iwe.cmd = IWEVQUAL;
-	current_ev =
-	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_QUAL_LEN);
 
 	/* Add WPA/RSN Information Element, if any */
 	wpa_ie_len = prism54_wpa_bss_ie_get(priv, bss->address, wpa_ie);
 	if (wpa_ie_len > 0) {
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = min(wpa_ie_len, (size_t)MAX_WPA_IE_LEN);
-		current_ev = iwe_stream_add_point(current_ev, end_buf,
-				&iwe, wpa_ie);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, wpa_ie);
 	}
 	/* Do the bitrates */
 	{
-		char *	current_val = current_ev + IW_EV_LCP_LEN;
+		char *	current_val = current_ev + iwe_stream_lcp_len(info);
 		int i;
 		int mask;
 
@@ -662,14 +663,14 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		for(i = 0; i < sizeof(scan_rate_list); i++) {
 			if(bss->rates & mask) {
 				iwe.u.bitrate.value = (scan_rate_list[i] * 500000);
-				current_val = iwe_stream_add_value(current_ev, current_val,
-								   end_buf, &iwe,
-								   IW_EV_PARAM_LEN);
+				current_val = iwe_stream_add_value(
+					info, current_ev, current_val,
+					end_buf, &iwe, IW_EV_PARAM_LEN);
 			}
 			mask <<= 1;
 		}
 		/* Check if we added any event */
-		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+		if ((current_val - current_ev) > iwe_stream_lcp_len(info))
 			current_ev = current_val;
 	}
 
@@ -710,7 +711,7 @@ prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
 
 	/* ok now, scan the list and translate its info */
 	for (i = 0; i < (int) bsslist->nr; i++) {
-		current_ev = prism54_translate_bss(ndev, current_ev,
+		current_ev = prism54_translate_bss(ndev, info, current_ev,
 						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
@@ -2704,6 +2705,7 @@ prism2_ioctl_scan_req(struct net_device *ndev,
                      struct prism2_hostapd_param *param)
 {
 	islpci_private *priv = netdev_priv(ndev);
+	struct iw_request_info info;
 	int i, rvalue;
 	struct obj_bsslist *bsslist;
 	u32 noise = 0;
@@ -2727,9 +2729,12 @@ prism2_ioctl_scan_req(struct net_device *ndev,
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
 
+	info.cmd = PRISM54_HOSTAPD;
+	info.flags = 0;
+
 	/* ok now, scan the list and translate its info */
 	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
-		current_ev = prism54_translate_bss(ndev, current_ev,
+		current_ev = prism54_translate_bss(ndev, &info, current_ev,
 						   extra + IW_SCAN_MAX_DATA,
 						   &(bsslist->bsslist[i]),
 						   noise);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d0b1fb1..5eb67d0 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1603,7 +1603,8 @@ static int rndis_iw_set_scan(struct net_device *dev,
 
 
 static char *rndis_translate_scan(struct net_device *dev,
-    char *cev, char *end_buf, struct ndis_80211_bssid_ex *bssid)
+				  struct iw_request_info *info, char *cev,
+				  char *end_buf, struct ndis_80211_bssid_ex *bssid)
 {
 #ifdef DEBUG
 	struct usbnet *usbdev = dev->priv;
@@ -1622,14 +1623,14 @@ static char *rndis_translate_scan(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bssid->mac, ETH_ALEN);
-	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	cev = iwe_stream_add_event(info, cev, end_buf, &iwe, IW_EV_ADDR_LEN);
 
 	devdbg(usbdev, "SSID(%d) %s", le32_to_cpu(bssid->ssid.length),
 						bssid->ssid.essid);
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.essid.length = le32_to_cpu(bssid->ssid.length);
 	iwe.u.essid.flags = 1;
-	cev = iwe_stream_add_point(cev, end_buf, &iwe, bssid->ssid.essid);
+	cev = iwe_stream_add_point(info, cev, end_buf, &iwe, bssid->ssid.essid);
 
 	devdbg(usbdev, "MODE %d", le32_to_cpu(bssid->net_infra));
 	iwe.cmd = SIOCGIWMODE;
@@ -1645,12 +1646,12 @@ static char *rndis_translate_scan(struct net_device *dev,
 		iwe.u.mode = IW_MODE_AUTO;
 		break;
 	}
-	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_UINT_LEN);
+	cev = iwe_stream_add_event(info, cev, end_buf, &iwe, IW_EV_UINT_LEN);
 
 	devdbg(usbdev, "FREQ %d kHz", le32_to_cpu(bssid->config.ds_config));
 	iwe.cmd = SIOCGIWFREQ;
 	dsconfig_to_freq(le32_to_cpu(bssid->config.ds_config), &iwe.u.freq);
-	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_FREQ_LEN);
+	cev = iwe_stream_add_event(info, cev, end_buf, &iwe, IW_EV_FREQ_LEN);
 
 	devdbg(usbdev, "QUAL %d", le32_to_cpu(bssid->rssi));
 	iwe.cmd = IWEVQUAL;
@@ -1659,7 +1660,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 	iwe.u.qual.updated = IW_QUAL_QUAL_UPDATED
 			| IW_QUAL_LEVEL_UPDATED
 			| IW_QUAL_NOISE_INVALID;
-	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_QUAL_LEN);
+	cev = iwe_stream_add_event(info, cev, end_buf, &iwe, IW_EV_QUAL_LEN);
 
 	devdbg(usbdev, "ENCODE %d", le32_to_cpu(bssid->privacy));
 	iwe.cmd = SIOCGIWENCODE;
@@ -1669,10 +1670,10 @@ static char *rndis_translate_scan(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
 
-	cev = iwe_stream_add_point(cev, end_buf, &iwe, NULL);
+	cev = iwe_stream_add_point(info, cev, end_buf, &iwe, NULL);
 
 	devdbg(usbdev, "RATES:");
-	current_val = cev + IW_EV_LCP_LEN;
+	current_val = cev + iwe_stream_lcp_len(info);
 	iwe.cmd = SIOCGIWRATE;
 	for (i = 0; i < sizeof(bssid->rates); i++) {
 		if (bssid->rates[i] & 0x7f) {
@@ -1680,13 +1681,13 @@ static char *rndis_translate_scan(struct net_device *dev,
 				((bssid->rates[i] & 0x7f) *
 				500000);
 			devdbg(usbdev, " %d", iwe.u.bitrate.value);
-			current_val = iwe_stream_add_value(cev,
+			current_val = iwe_stream_add_value(info, cev,
 				current_val, end_buf, &iwe,
 				IW_EV_PARAM_LEN);
 		}
 	}
 
-	if ((current_val - cev) > IW_EV_LCP_LEN)
+	if ((current_val - cev) > iwe_stream_lcp_len(info))
 		cev = current_val;
 
 	beacon = le32_to_cpu(bssid->config.beacon_period);
@@ -1694,14 +1695,14 @@ static char *rndis_translate_scan(struct net_device *dev,
 	iwe.cmd = IWEVCUSTOM;
 	snprintf(sbuf, sizeof(sbuf), "bcn_int=%d", beacon);
 	iwe.u.data.length = strlen(sbuf);
-	cev = iwe_stream_add_point(cev, end_buf, &iwe, sbuf);
+	cev = iwe_stream_add_point(info, cev, end_buf, &iwe, sbuf);
 
 	atim = le32_to_cpu(bssid->config.atim_window);
 	devdbg(usbdev, "ATIM %d", atim);
 	iwe.cmd = IWEVCUSTOM;
 	snprintf(sbuf, sizeof(sbuf), "atim=%u", atim);
 	iwe.u.data.length = strlen(sbuf);
-	cev = iwe_stream_add_point(cev, end_buf, &iwe, sbuf);
+	cev = iwe_stream_add_point(info, cev, end_buf, &iwe, sbuf);
 
 	ie = (void *)(bssid->ies + sizeof(struct ndis_80211_fixed_ies));
 	ie_len = min(bssid_len - (int)sizeof(*bssid),
@@ -1715,7 +1716,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 					(ie->id == MFIE_TYPE_RSN) ? 2 : 1);
 			iwe.cmd = IWEVGENIE;
 			iwe.u.data.length = min(ie->len + 2, MAX_WPA_IE_LEN);
-			cev = iwe_stream_add_point(cev, end_buf, &iwe,
+			cev = iwe_stream_add_point(info, cev, end_buf, &iwe,
 								(u8 *)ie);
 		}
 
@@ -1758,8 +1759,8 @@ static int rndis_iw_get_scan(struct net_device *dev,
 	devdbg(usbdev, "SIOCGIWSCAN: %d BSSIDs found", count);
 
 	while (count && ((void *)bssid + bssid_len) <= (buf + len)) {
-		cev = rndis_translate_scan(dev, cev, extra + IW_SCAN_MAX_DATA,
-									bssid);
+		cev = rndis_translate_scan(dev, info, cev,
+					   extra + IW_SCAN_MAX_DATA, bssid);
 		bssid = (void *)bssid + bssid_len;
 		bssid_len = le32_to_cpu(bssid->length);
 		count--;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 42a36b3..3771419 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1624,25 +1624,25 @@ static int wl3501_get_scan(struct net_device *dev, struct iw_request_info *info,
 		iwe.cmd			= SIOCGIWAP;
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, this->bss_set[i].bssid, ETH_ALEN);
-		current_ev = iwe_stream_add_event(current_ev,
+		current_ev = iwe_stream_add_event(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe, IW_EV_ADDR_LEN);
 		iwe.cmd		  = SIOCGIWESSID;
 		iwe.u.data.flags  = 1;
 		iwe.u.data.length = this->bss_set[i].ssid.el.len;
-		current_ev = iwe_stream_add_point(current_ev,
+		current_ev = iwe_stream_add_point(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe,
 						  this->bss_set[i].ssid.essid);
 		iwe.cmd	   = SIOCGIWMODE;
 		iwe.u.mode = this->bss_set[i].bss_type;
-		current_ev = iwe_stream_add_event(current_ev,
+		current_ev = iwe_stream_add_event(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe, IW_EV_UINT_LEN);
 		iwe.cmd = SIOCGIWFREQ;
 		iwe.u.freq.m = this->bss_set[i].ds_pset.chan;
 		iwe.u.freq.e = 0;
-		current_ev = iwe_stream_add_event(current_ev,
+		current_ev = iwe_stream_add_event(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe, IW_EV_FREQ_LEN);
 		iwe.cmd = SIOCGIWENCODE;
@@ -1651,7 +1651,7 @@ static int wl3501_get_scan(struct net_device *dev, struct iw_request_info *info,
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
 		iwe.u.data.length = 0;
-		current_ev = iwe_stream_add_point(current_ev,
+		current_ev = iwe_stream_add_point(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe, NULL);
 	}
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index d5c0c66..10c8642 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1152,32 +1152,36 @@ static int zd1201_get_scan(struct net_device *dev,
 		iwe.cmd = SIOCGIWAP;
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, zd->rxdata+i+6, 6);
-		cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_ADDR_LEN);
+		cev = iwe_stream_add_event(info, cev, end_buf,
+					   &iwe, IW_EV_ADDR_LEN);
 
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.length = zd->rxdata[i+16];
 		iwe.u.data.flags = 1;
-		cev = iwe_stream_add_point(cev, end_buf, &iwe, zd->rxdata+i+18);
+		cev = iwe_stream_add_point(info, cev, end_buf,
+					   &iwe, zd->rxdata+i+18);
 
 		iwe.cmd = SIOCGIWMODE;
 		if (zd->rxdata[i+14]&0x01)
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_UINT_LEN);
+		cev = iwe_stream_add_event(info, cev, end_buf,
+					   &iwe, IW_EV_UINT_LEN);
 		
 		iwe.cmd = SIOCGIWFREQ;
 		iwe.u.freq.m = zd->rxdata[i+0];
 		iwe.u.freq.e = 0;
-		cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_FREQ_LEN);
+		cev = iwe_stream_add_event(info, cev, end_buf,
+					   &iwe, IW_EV_FREQ_LEN);
 		
 		iwe.cmd = SIOCGIWRATE;
 		iwe.u.bitrate.fixed = 0;
 		iwe.u.bitrate.disabled = 0;
 		for (j=0; j<10; j++) if (zd->rxdata[i+50+j]) {
 			iwe.u.bitrate.value = (zd->rxdata[i+50+j]&0x7f)*500000;
-			cev=iwe_stream_add_event(cev, end_buf, &iwe,
-			    IW_EV_PARAM_LEN);
+			cev=iwe_stream_add_event(info, cev, end_buf,
+						 &iwe, IW_EV_PARAM_LEN);
 		}
 		
 		iwe.cmd = SIOCGIWENCODE;
@@ -1186,14 +1190,15 @@ static int zd1201_get_scan(struct net_device *dev,
 			iwe.u.data.flags = IW_ENCODE_ENABLED;
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
-		cev = iwe_stream_add_point(cev, end_buf, &iwe, NULL);
+		cev = iwe_stream_add_point(info, cev, end_buf, &iwe, NULL);
 		
 		iwe.cmd = IWEVQUAL;
 		iwe.u.qual.qual = zd->rxdata[i+4];
 		iwe.u.qual.noise= zd->rxdata[i+2]/10-100;
 		iwe.u.qual.level = (256+zd->rxdata[i+4]*100)/255-100;
 		iwe.u.qual.updated = 7;
-		cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_QUAL_LEN);
+		cev = iwe_stream_add_event(info, cev, end_buf,
+					   &iwe, IW_EV_QUAL_LEN);
 	}
 
 	if (!enabled_save)
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index c5606a1..1e68064 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1111,6 +1111,21 @@ struct iw_event
 #define IW_EV_POINT_LEN	(IW_EV_LCP_LEN + sizeof(struct iw_point) - \
 			 IW_EV_POINT_OFF)
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+struct __compat_iw_event {
+	__u16		len;			/* Real length of this stuff */
+	__u16		cmd;			/* Wireless IOCTL */
+	compat_caddr_t	pointer;
+};
+#define IW_EV_COMPAT_LCP_LEN offsetof(struct __compat_iw_event, pointer)
+#define IW_EV_COMPAT_POINT_OFF offsetof(struct compat_iw_point, length)
+#define IW_EV_COMPAT_POINT_LEN	\
+	(IW_EV_COMPAT_LCP_LEN + sizeof(struct compat_iw_point) - \
+	 IW_EV_COMPAT_POINT_OFF)
+#endif
+#endif
+
 /* Size of the Event prefix when packed in stream */
 #define IW_EV_LCP_PK_LEN	(4)
 /* Size of the various events when packed in stream */
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index c99a8ee..51b9a37 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -478,105 +478,58 @@ extern void wireless_spy_update(struct net_device *	dev,
  * Function that are so simple that it's more efficient inlining them
  */
 
-/*------------------------------------------------------------------*/
-/*
- * Wrapper to add an Wireless Event to a stream of events.
- */
-static inline char *
-iwe_stream_add_event(char *	stream,		/* Stream of events */
-		     char *	ends,		/* End of stream */
-		     struct iw_event *iwe,	/* Payload */
-		     int	event_len)	/* Real size of payload */
+static inline int iwe_stream_lcp_len(struct iw_request_info *info)
 {
-	/* Check if it's possible */
-	if(likely((stream + event_len) < ends)) {
-		iwe->len = event_len;
-		/* Beware of alignement issues on 64 bits */
-		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN,
-		       event_len - IW_EV_LCP_LEN);
-		stream += event_len;
-	}
-	return stream;
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT)
+		return IW_EV_COMPAT_LCP_LEN;
+#endif
+	return IW_EV_LCP_LEN;
 }
 
-/*------------------------------------------------------------------*/
-/*
- * Wrapper to add an short Wireless Event containing a pointer to a
- * stream of events.
- */
-static inline char *
-iwe_stream_add_point(char *	stream,		/* Stream of events */
-		     char *	ends,		/* End of stream */
-		     struct iw_event *iwe,	/* Payload length + flags */
-		     char *	extra)		/* More payload */
+static inline int iwe_stream_point_len(struct iw_request_info *info)
 {
-	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
-	/* Check if it's possible */
-	if(likely((stream + event_len) < ends)) {
-		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
-		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
-		stream += event_len;
-	}
-	return stream;
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT)
+		return IW_EV_COMPAT_POINT_LEN;
+#endif
+	return IW_EV_POINT_LEN;
 }
 
-/*------------------------------------------------------------------*/
-/*
- * Wrapper to add a value to a Wireless Event in a stream of events.
- * Be careful, this one is tricky to use properly :
- * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
- */
-static inline char *
-iwe_stream_add_value(char *	event,		/* Event in the stream */
-		     char *	value,		/* Value in event */
-		     char *	ends,		/* End of stream */
-		     struct iw_event *iwe,	/* Payload */
-		     int	event_len)	/* Real size of payload */
+static inline int iwe_stream_event_len_adjust(struct iw_request_info *info,
+					      int event_len)
 {
-	/* Don't duplicate LCP */
-	event_len -= IW_EV_LCP_LEN;
-
-	/* Check if it's possible */
-	if(likely((value + event_len) < ends)) {
-		/* Add new value */
-		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
-		value += event_len;
-		/* Patch LCP */
-		iwe->len = value - event;
-		memcpy(event, (char *) iwe, IW_EV_LCP_LEN);
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
+		event_len -= IW_EV_LCP_LEN;
+		event_len += IW_EV_COMPAT_LCP_LEN;
 	}
-	return value;
+#endif
+
+	return event_len;
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Wrapper to add an Wireless Event to a stream of events.
- * Same as above, with explicit error check...
  */
 static inline char *
-iwe_stream_check_add_event(char *	stream,		/* Stream of events */
-			   char *	ends,		/* End of stream */
-			   struct iw_event *iwe,	/* Payload */
-			   int		event_len,	/* Size of payload */
-			   int *	perr)		/* Error report */
+iwe_stream_add_event(struct iw_request_info *info, char *stream, char *ends,
+		     struct iw_event *iwe, int event_len)
 {
-	/* Check if it's possible, set error if not */
+	int lcp_len = iwe_stream_lcp_len(info);
+
+	event_len = iwe_stream_event_len_adjust(info, event_len);
+
+	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
 		/* Beware of alignement issues on 64 bits */
 		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN,
-		       event_len - IW_EV_LCP_LEN);
+		memcpy(stream + lcp_len, &iwe->u,
+		       event_len - lcp_len);
 		stream += event_len;
-	} else
-		*perr = -E2BIG;
+	}
 	return stream;
 }
 
@@ -584,27 +537,25 @@ iwe_stream_check_add_event(char *	stream,		/* Stream of events */
 /*
  * Wrapper to add an short Wireless Event containing a pointer to a
  * stream of events.
- * Same as above, with explicit error check...
  */
 static inline char *
-iwe_stream_check_add_point(char *	stream,		/* Stream of events */
-			   char *	ends,		/* End of stream */
-			   struct iw_event *iwe,	/* Payload length + flags */
-			   char *	extra,		/* More payload */
-			   int *	perr)		/* Error report */
+iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
+		     struct iw_event *iwe, char *extra)
 {
-	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+	int event_len = iwe_stream_point_len(info) + iwe->u.data.length;
+	int point_len = iwe_stream_point_len(info);
+	int lcp_len   = iwe_stream_lcp_len(info);
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
 		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
+		memcpy(stream + lcp_len,
+		       ((char *) &iwe->u) + IW_EV_POINT_OFF,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
+		memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
-	} else
-		*perr = -E2BIG;
+	}
 	return stream;
 }
 
@@ -613,29 +564,25 @@ iwe_stream_check_add_point(char *	stream,		/* Stream of events */
  * Wrapper to add a value to a Wireless Event in a stream of events.
  * Be careful, this one is tricky to use properly :
  * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
- * Same as above, with explicit error check...
  */
 static inline char *
-iwe_stream_check_add_value(char *	event,		/* Event in the stream */
-			   char *	value,		/* Value in event */
-			   char *	ends,		/* End of stream */
-			   struct iw_event *iwe,	/* Payload */
-			   int		event_len,	/* Size of payload */
-			   int *	perr)		/* Error report */
+iwe_stream_add_value(struct iw_request_info *info, char *event, char *value,
+		     char *ends, struct iw_event *iwe, int event_len)
 {
+	int lcp_len = iwe_stream_lcp_len(info);
+
 	/* Don't duplicate LCP */
 	event_len -= IW_EV_LCP_LEN;
 
 	/* Check if it's possible */
 	if(likely((value + event_len) < ends)) {
 		/* Add new value */
-		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
+		memcpy(value, &iwe->u, event_len);
 		value += event_len;
 		/* Patch LCP */
 		iwe->len = value - event;
-		memcpy(event, (char *) iwe, IW_EV_LCP_LEN);
-	} else
-		*perr = -E2BIG;
+		memcpy(event, (char *) iwe, lcp_len);
+	}
 	return value;
 }
 
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index 822606b..e03d2f0 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -43,8 +43,9 @@ static const char *ieee80211_modes[] = {
 
 #define MAX_CUSTOM_LEN 64
 static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
-					   char *start, char *stop,
-					   struct ieee80211_network *network)
+				      char *start, char *stop,
+				      struct ieee80211_network *network,
+				      struct iw_request_info *info)
 {
 	char custom[MAX_CUSTOM_LEN];
 	char *p;
@@ -57,7 +58,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, network->bssid, ETH_ALEN);
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_ADDR_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_ADDR_LEN);
 
 	/* Remaining entries will be displayed in the order we provide them */
 
@@ -66,17 +67,19 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	iwe.u.data.flags = 1;
 	if (network->flags & NETWORK_EMPTY_ESSID) {
 		iwe.u.data.length = sizeof("<hidden>");
-		start = iwe_stream_add_point(start, stop, &iwe, "<hidden>");
+		start = iwe_stream_add_point(info, start, stop,
+					     &iwe, "<hidden>");
 	} else {
 		iwe.u.data.length = min(network->ssid_len, (u8) 32);
-		start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+		start = iwe_stream_add_point(info, start, stop,
+					     &iwe, network->ssid);
 	}
 
 	/* Add the protocol name */
 	iwe.cmd = SIOCGIWNAME;
 	snprintf(iwe.u.name, IFNAMSIZ, "IEEE 802.11%s",
 		 ieee80211_modes[network->mode]);
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_CHAR_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_CHAR_LEN);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -86,7 +89,8 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
 
-		start = iwe_stream_add_event(start, stop, &iwe, IW_EV_UINT_LEN);
+		start = iwe_stream_add_event(info, start, stop,
+					     &iwe, IW_EV_UINT_LEN);
 	}
 
 	/* Add channel and frequency */
@@ -95,7 +99,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	iwe.u.freq.m = ieee80211_channel_to_freq(ieee, network->channel);
 	iwe.u.freq.e = 6;
 	iwe.u.freq.i = 0;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_FREQ_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -104,12 +108,13 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+	start = iwe_stream_add_point(info, start, stop,
+				     &iwe, network->ssid);
 
 	/* Add basic and extended rates */
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
-	current_val = start + IW_EV_LCP_LEN;
+	current_val = start + iwe_stream_lcp_len(info);
 	iwe.cmd = SIOCGIWRATE;
 	/* Those two flags are ignored... */
 	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
@@ -124,17 +129,19 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		/* Bit rate given in 500 kb/s units (+ 0x80) */
 		iwe.u.bitrate.value = ((rate & 0x7f) * 500000);
 		/* Add new value to event */
-		current_val = iwe_stream_add_value(start, current_val, stop, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, start, current_val,
+						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	for (; j < network->rates_ex_len; j++) {
 		rate = network->rates_ex[j] & 0x7F;
 		/* Bit rate given in 500 kb/s units (+ 0x80) */
 		iwe.u.bitrate.value = ((rate & 0x7f) * 500000);
 		/* Add new value to event */
-		current_val = iwe_stream_add_value(start, current_val, stop, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, start, current_val,
+						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any rate */
-	if((current_val - start) > IW_EV_LCP_LEN)
+	if((current_val - start) > iwe_stream_lcp_len(info))
 		start = current_val;
 
 	/* Add quality statistics */
@@ -181,14 +188,14 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		iwe.u.qual.level = network->stats.signal;
 	}
 
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_QUAL_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_QUAL_LEN);
 
 	iwe.cmd = IWEVCUSTOM;
 	p = custom;
 
 	iwe.u.data.length = p - custom;
 	if (iwe.u.data.length)
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(info, start, stop, &iwe, custom);
 
 	memset(&iwe, 0, sizeof(iwe));
 	if (network->wpa_ie_len) {
@@ -196,7 +203,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		memcpy(buf, network->wpa_ie, network->wpa_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = network->wpa_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -205,7 +212,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		memcpy(buf, network->rsn_ie, network->rsn_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = network->rsn_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	/* Add EXTRA: Age to display seconds since last beacon/probe response
@@ -217,7 +224,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		      jiffies_to_msecs(jiffies - network->last_scanned));
 	iwe.u.data.length = p - custom;
 	if (iwe.u.data.length)
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(info, start, stop, &iwe, custom);
 
 	/* Add spectrum management information */
 	iwe.cmd = -1;
@@ -238,7 +245,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 
 	if (iwe.cmd == IWEVCUSTOM) {
 		iwe.u.data.length = p - custom;
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(info, start, stop, &iwe, custom);
 	}
 
 	return start;
@@ -272,7 +279,8 @@ int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
 
 		if (ieee->scan_age == 0 ||
 		    time_after(network->last_scanned + ieee->scan_age, jiffies))
-			ev = ieee80211_translate_scan(ieee, ev, stop, network);
+			ev = ieee80211_translate_scan(ieee, ev, stop, network,
+						      info);
 		else
 			IEEE80211_DEBUG_SCAN("Not showing network '%s ("
 					     "%s)' due to age (%dms).\n",
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ed0d9b3..627911a 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -23,6 +23,7 @@
 #include <linux/spinlock.h>
 #include <linux/etherdevice.h>
 #include <net/wireless.h>
+#include <net/iw_handler.h>
 #include "key.h"
 #include "sta_info.h"
 
@@ -908,7 +909,9 @@ int ieee80211_sta_set_bssid(struct net_device *dev, u8 *bssid);
 int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len);
 void ieee80211_sta_req_auth(struct net_device *dev,
 			    struct ieee80211_if_sta *ifsta);
-int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len);
+int ieee80211_sta_scan_results(struct net_device *dev,
+			       struct iw_request_info *info,
+			       char *buf, size_t len);
 ieee80211_rx_result ieee80211_sta_rx_scan(
 	struct net_device *dev, struct sk_buff *skb,
 	struct ieee80211_rx_status *rx_status);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 3f7f92a..aeafc55 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -4038,6 +4038,7 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 
 static char *
 ieee80211_sta_scan_result(struct net_device *dev,
+			  struct iw_request_info *info,
 			  struct ieee80211_sta_bss *bss,
 			  char *current_ev, char *end_buf)
 {
@@ -4052,7 +4053,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_ADDR_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -4060,12 +4061,12 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	if (bss_mesh_cfg(bss)) {
 		iwe.u.data.length = bss_mesh_id_len(bss);
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe,
 						  bss_mesh_id(bss));
 	} else {
 		iwe.u.data.length = bss->ssid_len;
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe,
 						  bss->ssid);
 	}
 
@@ -4079,7 +4080,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 						  IW_EV_UINT_LEN);
 	}
 
@@ -4087,14 +4088,14 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = bss->freq;
 	iwe.u.freq.e = 6;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_FREQ_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = ieee80211_frequency_to_channel(bss->freq);
 	iwe.u.freq.e = 0;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_FREQ_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -4103,7 +4104,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.u.qual.level = bss->signal;
 	iwe.u.qual.noise = bss->noise;
 	iwe.u.qual.updated = local->wstats_flags;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_QUAL_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -4113,13 +4114,13 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, "");
 
 	if (bss && bss->wpa_ie) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe,
 						  bss->wpa_ie);
 	}
 
@@ -4127,13 +4128,13 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe,
 						  bss->rsn_ie);
 	}
 
 	if (bss && bss->supp_rates_len > 0) {
 		/* display all supported rates in readable format */
-		char *p = current_ev + IW_EV_LCP_LEN;
+		char *p = current_ev + iwe_stream_lcp_len(info);
 		int i;
 
 		memset(&iwe, 0, sizeof(iwe));
@@ -4144,7 +4145,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		for (i = 0; i < bss->supp_rates_len; i++) {
 			iwe.u.bitrate.value = ((bss->supp_rates[i] &
 							0x7f) * 500000);
-			p = iwe_stream_add_value(current_ev, p,
+			p = iwe_stream_add_value(info, current_ev, p,
 					end_buf, &iwe, IW_EV_PARAM_LEN);
 		}
 		current_ev = p;
@@ -4158,7 +4159,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			iwe.cmd = IWEVCUSTOM;
 			sprintf(buf, "tsf=%016llx", (unsigned long long)(bss->timestamp));
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			kfree(buf);
 		}
@@ -4173,31 +4174,31 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			iwe.cmd = IWEVCUSTOM;
 			sprintf(buf, "Mesh network (version %d)", cfg[0]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			sprintf(buf, "Path Selection Protocol ID: "
 				"0x%02X%02X%02X%02X", cfg[1], cfg[2], cfg[3],
 							cfg[4]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			sprintf(buf, "Path Selection Metric ID: "
 				"0x%02X%02X%02X%02X", cfg[5], cfg[6], cfg[7],
 							cfg[8]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			sprintf(buf, "Congestion Control Mode ID: "
 				"0x%02X%02X%02X%02X", cfg[9], cfg[10],
 							cfg[11], cfg[12]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			sprintf(buf, "Channel Precedence: "
 				"0x%02X%02X%02X%02X", cfg[13], cfg[14],
 							cfg[15], cfg[16]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
+			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 							  &iwe, buf);
 			kfree(buf);
 		}
@@ -4207,7 +4208,9 @@ ieee80211_sta_scan_result(struct net_device *dev,
 }
 
 
-int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
+int ieee80211_sta_scan_results(struct net_device *dev,
+			       struct iw_request_info *info,
+			       char *buf, size_t len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	char *current_ev = buf;
@@ -4220,8 +4223,8 @@ int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
 			spin_unlock_bh(&local->sta_bss_lock);
 			return -E2BIG;
 		}
-		current_ev = ieee80211_sta_scan_result(dev, bss, current_ev,
-						       end_buf);
+		current_ev = ieee80211_sta_scan_result(dev, info, bss,
+						       current_ev, end_buf);
 	}
 	spin_unlock_bh(&local->sta_bss_lock);
 	return current_ev - buf;
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index c2e2378..72eaf65 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -554,7 +554,7 @@ static int ieee80211_ioctl_giwscan(struct net_device *dev,
 	if (local->sta_sw_scanning || local->sta_hw_scanning)
 		return -EAGAIN;
 
-	res = ieee80211_sta_scan_results(dev, extra, data->length);
+	res = ieee80211_sta_scan_results(dev, info, extra, data->length);
 	if (res >= 0) {
 		data->length = res;
 		return 0;
-- 
1.5.5.1.308.g1fbb5

