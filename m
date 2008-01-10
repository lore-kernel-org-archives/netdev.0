From: David Miller <davem@davemloft.net>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Thu, 10 Jan 2008 01:16:02 -0800 (PST)
Message-ID: <20080110.011602.74511551.davem@davemloft.net>
References: <20071227173802.6F56.40F06B3A@sm.sony.co.jp>
	<20071227.005725.144782426.davem@davemloft.net>
	<20071227181439.6F59.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51061
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752663AbYAJJQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 04:16:20 -0500
In-Reply-To: <20071227181439.6F59.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Date: Thu, 27 Dec 2007 18:24:40 +0900

> On ppc64 (PS3), IW_EV_LCP_LEN is 8, not 4.
> 
> include/linux/wireless.h:
> 
> #define IW_EV_LCP_LEN   (sizeof(struct iw_event) - sizeof(union iwreq_data))
> 
> where sizeof(struct iw_event) == 24, sizeof(union iwreq_data) == 16 on
> PS3.

Here is a new version of the last patch (#12), it should handle
all of these cases properly now.

Let me know if you spot any more errors.

Thanks!

[WEXT]: Emit event stream entries correctly when compat.

Three major portions to this change:

1) Add IW_EV_COMPAT_LCP_LEN, IW_EV_COMPAT_POINT_OFF,
   and IW_EV_COMPAT_POINT_LEN helper defines.

2) Delete iw_stream_check_add_*(), they are unused.

3) Add iw_request_info argument to iwe_stream_add_*(), and use it to
   size the event and pointer lengths correctly depending upon whether
   IW_REQUEST_FLAG_COMPAT is set or not.

4) The mechanical transformations to the drivers and wireless stack
   bits to get the iw_request_info passed down into the routines
   modified in #3.

With help from Masakazu Mokuno

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/airo.c                |   39 +++++---
 drivers/net/wireless/atmel.c               |   24 ++++-
 drivers/net/wireless/hostap/hostap.h       |    3 +-
 drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
 drivers/net/wireless/hostap/hostap_ioctl.c |   54 ++++++-----
 drivers/net/wireless/libertas/scan.c       |   35 ++++---
 drivers/net/wireless/orinoco.c             |   30 ++++--
 drivers/net/wireless/prism54/isl_ioctl.c   |   45 +++++----
 drivers/net/wireless/wl3501_cs.c           |   10 +-
 drivers/net/wireless/zd1201.c              |   21 +++--
 include/linux/wireless.h                   |   16 +++
 include/net/iw_handler.h                   |  150 ++++++++--------------------
 net/ieee80211/ieee80211_wx.c               |   44 +++++----
 net/mac80211/ieee80211_i.h                 |    5 +-
 net/mac80211/ieee80211_ioctl.c             |    2 +-
 net/mac80211/ieee80211_sta.c               |   59 ++++++-----
 16 files changed, 293 insertions(+), 276 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 074055e..ad4f140 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -7234,6 +7234,7 @@ out:
  * format that the Wireless Tools will understand - Jean II
  */
 static inline char *airo_translate_scan(struct net_device *dev,
+					struct iw_request_info *info,
 					char *current_ev,
 					char *end_buf,
 					BSSListRid *bss)
@@ -7249,7 +7250,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
 
@@ -7259,7 +7261,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.u.data.length = 32;
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, bss->ssid);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -7269,7 +7272,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 	}
 
 	/* Add frequency */
@@ -7280,7 +7284,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	 */
 	iwe.u.freq.m = frequency_list[iwe.u.freq.m - 1] * 100000;
 	iwe.u.freq.e = 1;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_FREQ_LEN);
 
 	/* Add quality statistics */
 	iwe.cmd = IWEVQUAL;
@@ -7298,7 +7303,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 				| IW_QUAL_DBM;
 	}
 	iwe.u.qual.noise = ai->wstats.qual.noise;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -7307,7 +7313,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, bss->ssid);
 
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
@@ -7324,7 +7331,9 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		/* Bit rate given in 500 kb/s units (+ 0x80) */
 		iwe.u.bitrate.value = ((bss->rates[i] & 0x7f) * 500000);
 		/* Add new value to event */
-		current_val = iwe_stream_add_value(current_ev, current_val, end_buf, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, current_ev,
+						   current_val, end_buf,
+						   &iwe, IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any event */
 	if((current_val - current_ev) > IW_EV_LCP_LEN)
@@ -7336,7 +7345,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d", bss->beaconInterval);
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 		kfree(buf);
 	}
 
@@ -7370,8 +7380,10 @@ static inline char *airo_translate_scan(struct net_device *dev,
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
 
@@ -7379,8 +7391,9 @@ static inline char *airo_translate_scan(struct net_device *dev,
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
@@ -7419,7 +7432,7 @@ static int airo_get_scan(struct net_device *dev,
 
 	list_for_each_entry (net, &ai->network_list, list) {
 		/* Translate to WE format this entry */
-		current_ev = airo_translate_scan(dev, current_ev,
+		current_ev = airo_translate_scan(dev, info, current_ev,
 						 extra + dwrq->length,
 						 &net->bss);
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 059ce3f..985068e 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -2320,30 +2320,40 @@ static int atmel_get_scan(struct net_device *dev,
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
@@ -2352,7 +2362,9 @@ static int atmel_get_scan(struct net_device *dev,
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
index 6bbdb76..8131e84 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -2381,7 +2381,8 @@ int prism2_ap_get_sta_qual(local_info_t *local, struct sockaddr addr[],
 
 /* Translate our list of Access Points & Stations to a card independant
  * format that the Wireless Tools will understand - Jean II */
-int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
+int prism2_ap_translate_scan(struct net_device *dev,
+			     struct iw_request_info *info, char *buffer)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -2410,8 +2411,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, sta->addr, ETH_ALEN);
 		iwe.len = IW_EV_ADDR_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_ADDR_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_ADDR_LEN);
 
 		/* Use the mode to indicate if it's a station or
 		 * an Access Point */
@@ -2422,8 +2423,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		else
 			iwe.u.mode = IW_MODE_INFRA;
 		iwe.len = IW_EV_UINT_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 
 		/* Some quality */
 		memset(&iwe, 0, sizeof(iwe));
@@ -2438,8 +2439,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 		iwe.u.qual.noise = HFA384X_LEVEL_TO_dBm(sta->last_rx_silence);
 		iwe.u.qual.updated = sta->last_rx_updated;
 		iwe.len = IW_EV_QUAL_LEN;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_QUAL_LEN);
 
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 		if (sta->ap) {
@@ -2447,8 +2448,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 			iwe.cmd = SIOCGIWESSID;
 			iwe.u.data.length = sta->u.ap.ssid_len;
 			iwe.u.data.flags = 1;
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe,
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe,
 							  sta->u.ap.ssid);
 
 			memset(&iwe, 0, sizeof(iwe));
@@ -2458,10 +2459,9 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
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
@@ -2471,7 +2471,7 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 					* 100000;
 				iwe.u.freq.e = 1;
 				current_ev = iwe_stream_add_event(
-					current_ev, end_buf, &iwe,
+					info, current_ev, end_buf, &iwe,
 					IW_EV_FREQ_LEN);
 			}
 
@@ -2480,8 +2480,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
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
index d8f5efc..5b04054 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1794,6 +1794,7 @@ static int prism2_ioctl_siwscan(struct net_device *dev,
 
 #ifndef PRISM2_NO_STATION_MODES
 static char * __prism2_translate_scan(local_info_t *local,
+				      struct iw_request_info *info,
 				      struct hfa384x_hostscan_result *scan,
 				      struct hostap_bss_info *bss,
 				      char *current_ev, char *end_buf)
@@ -1824,7 +1825,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
 					  IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
@@ -1833,7 +1834,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.length = ssid_len;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, ssid);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWMODE;
@@ -1848,8 +1850,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1865,8 +1867,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 	if (chan > 0) {
 		iwe.u.freq.m = freq_list[chan - 1] * 100000;
 		iwe.u.freq.e = 1;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_FREQ_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_FREQ_LEN);
 	}
 
 	if (scan) {
@@ -1885,8 +1887,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 			| IW_QUAL_NOISE_UPDATED
 			| IW_QUAL_QUAL_INVALID
 			| IW_QUAL_DBM;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_QUAL_LEN);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1896,7 +1898,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf, &iwe, "");
 
 	/* TODO: add SuppRates into BSS table */
 	if (scan) {
@@ -1910,7 +1912,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 			/* Bit rate given in 500 kb/s units (+ 0x80) */
 			iwe.u.bitrate.value = ((pos[i] & 0x7f) * 500000);
 			current_val = iwe_stream_add_value(
-				current_ev, current_val, end_buf, &iwe,
+				info, current_ev, current_val, end_buf, &iwe,
 				IW_EV_PARAM_LEN);
 		}
 		/* Check if we added any event */
@@ -1925,15 +1927,15 @@ static char * __prism2_translate_scan(local_info_t *local,
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
@@ -1941,8 +1943,8 @@ static char * __prism2_translate_scan(local_info_t *local,
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
@@ -1951,16 +1953,16 @@ static char * __prism2_translate_scan(local_info_t *local,
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
@@ -1970,6 +1972,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 /* Translate scan data returned from the card to a card independant
  * format that the Wireless Tools will understand - Jean II */
 static inline int prism2_translate_scan(local_info_t *local,
+					struct iw_request_info *info,
 					char *buffer, int buflen)
 {
 	struct hfa384x_hostscan_result *scan;
@@ -2000,13 +2003,14 @@ static inline int prism2_translate_scan(local_info_t *local,
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
@@ -2024,7 +2028,7 @@ static inline int prism2_translate_scan(local_info_t *local,
 		bss = list_entry(ptr, struct hostap_bss_info, list);
 		if (bss->included)
 			continue;
-		current_ev = __prism2_translate_scan(local, NULL, bss,
+		current_ev = __prism2_translate_scan(local, info, NULL, bss,
 						     current_ev, end_buf);
 		/* Check if there is space for one more entry */
 		if ((end_buf - current_ev) <= IW_EV_ADDR_LEN) {
@@ -2071,7 +2075,7 @@ static inline int prism2_ioctl_giwscan_sta(struct net_device *dev,
 	}
 	local->scan_timestamp = 0;
 
-	res = prism2_translate_scan(local, extra, data->length);
+	res = prism2_translate_scan(local, info, extra, data->length);
 
 	if (res >= 0) {
 		data->length = res;
@@ -2104,7 +2108,7 @@ static int prism2_ioctl_giwscan(struct net_device *dev,
 		 * Jean II */
 
 		/* Translate to WE format */
-		res = prism2_ap_translate_scan(dev, extra);
+		res = prism2_ap_translate_scan(dev, info, extra);
 		if (res >= 0) {
 			printk(KERN_DEBUG "Scan result translation succeeded "
 			       "(length=%d)\n", res);
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index ad1e67d..9dbd932 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -1444,8 +1444,9 @@ out:
 #define MAX_CUSTOM_LEN 64
 
 static inline char *libertas_translate_scan(wlan_private *priv,
-					char *start, char *stop,
-					struct bss_descriptor *bss)
+					    struct iw_request_info *info,
+					    char *start, char *stop,
+					    struct bss_descriptor *bss)
 {
 	wlan_adapter *adapter = priv->adapter;
 	struct chan_freq_power *cfp;
@@ -1470,24 +1471,24 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, &bss->bssid, ETH_ALEN);
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_ADDR_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_ADDR_LEN);
 
 	/* SSID */
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
 	iwe.u.data.length = min((u32) bss->ssid_len, (u32) IW_ESSID_MAX_SIZE);
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
@@ -1523,7 +1524,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		nf = adapter->NF[TYPE_RXPD][TYPE_AVG] / AVG_SCALE;
 		iwe.u.qual.level = CAL_RSSI(snr, nf);
 	}
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_QUAL_LEN);
+	start = iwe_stream_add_event(info, start, stop, &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
 	iwe.cmd = SIOCGIWENCODE;
@@ -1533,7 +1534,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	}
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid);
+	start = iwe_stream_add_point(info, start, stop, &iwe, bss->ssid);
 
 	current_val = start + IW_EV_LCP_LEN;
 
@@ -1545,8 +1546,8 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 	for (j = 0; bss->rates[j] && (j < sizeof(bss->rates)); j++) {
 		/* Bit rate given in 500 kb/s units */
 		iwe.u.bitrate.value = bss->rates[j] * 500000;
-		current_val = iwe_stream_add_value(start, current_val,
-					 stop, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, start, current_val,
+						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	if ((bss->mode == IW_MODE_ADHOC)
 	    && !libertas_ssid_cmp(adapter->curbssparams.ssid,
@@ -1554,8 +1555,8 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 	                          bss->ssid, bss->ssid_len)
 	    && adapter->adhoccreate) {
 		iwe.u.bitrate.value = 22 * 500000;
-		current_val = iwe_stream_add_value(start, current_val,
-					 stop, &iwe, IW_EV_PARAM_LEN);
+		current_val = iwe_stream_add_value(info, start, current_val,
+						   stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	/* Check if we added any event */
 	if((current_val - start) > IW_EV_LCP_LEN)
@@ -1567,7 +1568,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		memcpy(buf, bss->wpa_ie, bss->wpa_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1576,7 +1577,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		memcpy(buf, bss->rsn_ie, bss->rsn_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(info, start, stop, &iwe, buf);
 	}
 
 	if (bss->mesh) {
@@ -1588,7 +1589,8 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		              "mesh-type: olpc");
 		iwe.u.data.length = p - custom;
 		if (iwe.u.data.length)
-			start = iwe_stream_add_point(start, stop, &iwe, custom);
+			start = iwe_stream_add_point(info, start, stop,
+						     &iwe, custom);
 	}
 
 out:
@@ -1650,7 +1652,8 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 		}
 
 		/* Translate to WE format this entry */
-		next_ev = libertas_translate_scan(priv, ev, stop, iter_bss);
+		next_ev = libertas_translate_scan(priv, info, ev, stop,
+						  iter_bss);
 		if (next_ev == NULL)
 			continue;
 		ev = next_ev;
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index ca6c2da..9141b8f 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -3909,6 +3909,7 @@ static int orinoco_ioctl_setscan(struct net_device *dev,
  * format that the Wireless Tools will understand - Jean II
  * Return message length or -errno for fatal errors */
 static inline int orinoco_translate_scan(struct net_device *dev,
+					 struct iw_request_info *info,
 					 char *buffer,
 					 char *scan,
 					 int scan_len)
@@ -3979,7 +3980,8 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 		iwe.cmd = SIOCGIWAP;
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(iwe.u.ap_addr.sa_data, atom->a.bssid, ETH_ALEN);
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_ADDR_LEN);
 
 		/* Other entries will be displayed in the order we give them */
 
@@ -3989,7 +3991,8 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 			iwe.u.data.length = 32;
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, atom->a.essid);
 
 		/* Add mode */
 		iwe.cmd = SIOCGIWMODE;
@@ -3999,7 +4002,9 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 				iwe.u.mode = IW_MODE_MASTER;
 			else
 				iwe.u.mode = IW_MODE_ADHOC;
-			current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
+			current_ev = iwe_stream_add_event(info, current_ev,
+							  end_buf, &iwe,
+							  IW_EV_UINT_LEN);
 		}
 
 		channel = atom->s.channel;
@@ -4008,8 +4013,9 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 			iwe.cmd = SIOCGIWFREQ;
 			iwe.u.freq.m = channel_frequency[channel-1] * 100000;
 			iwe.u.freq.e = 1;
-			current_ev = iwe_stream_add_event(current_ev, end_buf,
-							  &iwe, IW_EV_FREQ_LEN);
+			current_ev = iwe_stream_add_event(info, current_ev,
+							  end_buf, &iwe,
+							  IW_EV_FREQ_LEN);
 		}
 
 		/* Add quality statistics */
@@ -4023,7 +4029,8 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 			iwe.u.qual.qual = iwe.u.qual.level - iwe.u.qual.noise;
 		else
 			iwe.u.qual.qual = 0;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_QUAL_LEN);
 
 		/* Add encryption capability */
 		iwe.cmd = SIOCGIWENCODE;
@@ -4032,7 +4039,8 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
 		iwe.u.data.length = 0;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, atom->a.essid);
 
 		/* Bit rate is not available in Lucent/Agere firmwares */
 		if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
@@ -4055,9 +4063,9 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 					break;
 				/* Bit rate given in 500 kb/s units (+ 0x80) */
 				iwe.u.bitrate.value = ((atom->p.rates[i] & 0x7f) * 500000);
-				current_val = iwe_stream_add_value(current_ev, current_val,
-								   end_buf, &iwe,
-								   IW_EV_PARAM_LEN);
+				current_val = iwe_stream_add_value(
+					info, current_ev, current_val,
+					end_buf, &iwe, IW_EV_PARAM_LEN);
 			}
 			/* Check if we added any event */
 			if ((current_val - current_ev) > IW_EV_LCP_LEN)
@@ -4102,7 +4110,7 @@ static int orinoco_ioctl_getscan(struct net_device *dev,
 		/* We have some results to push back to user space */
 
 		/* Translate to WE format */
-		int ret = orinoco_translate_scan(dev, extra,
+		int ret = orinoco_translate_scan(dev, info, extra,
 						 priv->scan_result,
 						 priv->scan_len);
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 6d80ca4..4dc0b5e 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -572,8 +572,9 @@ prism54_set_scan(struct net_device *dev, struct iw_request_info *info,
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
@@ -585,8 +586,8 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	iwe.cmd = SIOCGIWAP;
-	current_ev =
-	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_ADDR_LEN);
 
 	/* The following entries will be displayed in the same order we give them */
 
@@ -594,7 +595,7 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	iwe.u.data.length = bss->ssid.length;
 	iwe.u.data.flags = 1;
 	iwe.cmd = SIOCGIWESSID;
-	current_ev = iwe_stream_add_point(current_ev, end_buf,
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
 					  &iwe, bss->ssid.octets);
 
 	/* Capabilities */
@@ -611,9 +612,8 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
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
@@ -622,14 +622,15 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
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
@@ -637,16 +638,16 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
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
@@ -663,9 +664,9 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
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
@@ -711,7 +712,7 @@ prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
 
 	/* ok now, scan the list and translate its info */
 	for (i = 0; i < (int) bsslist->nr; i++) {
-		current_ev = prism54_translate_bss(ndev, current_ev,
+		current_ev = prism54_translate_bss(ndev, info, current_ev,
 						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
@@ -2705,6 +2706,7 @@ prism2_ioctl_scan_req(struct net_device *ndev,
                      struct prism2_hostapd_param *param)
 {
 	islpci_private *priv = netdev_priv(ndev);
+	struct iw_request_info info;
 	int i, rvalue;
 	struct obj_bsslist *bsslist;
 	u32 noise = 0;
@@ -2728,9 +2730,12 @@ prism2_ioctl_scan_req(struct net_device *ndev,
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
 
+	info.cmd = PRISM54_HOSTAPD;
+	info.flags = 0;
+
 	/* ok now, scan the list and translate its info */
 	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
-		current_ev = prism54_translate_bss(ndev, current_ev,
+		current_ev = prism54_translate_bss(ndev, current_ev, &info,
 						   extra + IW_SCAN_MAX_DATA,
 						   &(bsslist->bsslist[i]),
 						   noise);
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
index 2088524..bec73df 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1098,6 +1098,22 @@ struct iw_event
 #define IW_EV_POINT_LEN	(IW_EV_LCP_LEN + sizeof(struct iw_point) - \
 			 IW_EV_POINT_OFF)
 
+#if defined(__KERNEL__) && defined(CONFIG_COMPAT)
+struct __compat_iw_event {
+	__u16		len;			/* Real lenght of this stuff */
+	__u16		cmd;			/* Wireless IOCTL */
+	compat_caddr_t	pointer;
+};
+#define IW_EV_COMPAT_LCP_LEN \
+	(sizeof(struct __compat_iw_event) - sizeof(compat_caddr_t))
+#define IW_EV_COMPAT_POINT_OFF (((char *) \
+			  &(((struct compat_iw_point *) NULL)->length)) - \
+			  (char *) NULL)
+#define IW_EV_COMPAT_POINT_LEN	\
+	(IW_EV_COMPAT_LCP_LEN + sizeof(struct compat_iw_point) - \
+	 IW_EV_COMPAT_POINT_OFF)
+#endif
+
 /* Size of the Event prefix when packed in stream */
 #define IW_EV_LCP_PK_LEN	(4)
 /* Size of the various events when packed in stream */
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index c99a8ee..d6f0c51 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -483,19 +483,26 @@ extern void wireless_spy_update(struct net_device *	dev,
  * Wrapper to add an Wireless Event to a stream of events.
  */
 static inline char *
-iwe_stream_add_event(char *	stream,		/* Stream of events */
-		     char *	ends,		/* End of stream */
-		     struct iw_event *iwe,	/* Payload */
-		     int	event_len)	/* Real size of payload */
+iwe_stream_add_event(struct iw_request_info *info, char *stream, char *ends,
+		     struct iw_event *iwe, int event_len)
 {
+	int lcp_len = IW_EV_LCP_LEN;
+
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
+		event_len -= IW_EV_LCP_LEN;
+		event_len += IW_EV_COMPAT_LCP_LEN;
+		lcp_len = IW_EV_COMPAT_LCP_LEN;
+	}
+#endif
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
 		/* Beware of alignement issues on 64 bits */
 		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN,
-		       event_len - IW_EV_LCP_LEN);
+		memcpy(stream + lcp_len,
+		       ((char *) iwe) + lcp_len,
+		       event_len - lcp_len);
 		stream += event_len;
 	}
 	return stream;
@@ -507,104 +514,33 @@ iwe_stream_add_event(char *	stream,		/* Stream of events */
  * stream of events.
  */
 static inline char *
-iwe_stream_add_point(char *	stream,		/* Stream of events */
-		     char *	ends,		/* End of stream */
-		     struct iw_event *iwe,	/* Payload length + flags */
-		     char *	extra)		/* More payload */
+iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
+		     struct iw_event *iwe, char *extra)
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
+	int event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+	int point_len = IW_EV_POINT_LEN;
+	int lcp_len = IW_EV_LCP_LEN;
+	int point_off = IW_EV_POINT_OFF;
+
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
+		event_len = IW_EV_COMPAT_POINT_LEN + iwe->u.data.length;
+		point_len = IW_EV_COMPAT_POINT_LEN;
+		lcp_len = IW_EV_COMPAT_LCP_LEN;
+		point_off = IW_EV_COMPAT_POINT_OFF;
 	}
-	return stream;
-}
-
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
-{
-	/* Don't duplicate LCP */
-	event_len -= IW_EV_LCP_LEN;
+#endif
 
 	/* Check if it's possible */
-	if(likely((value + event_len) < ends)) {
-		/* Add new value */
-		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
-		value += event_len;
-		/* Patch LCP */
-		iwe->len = value - event;
-		memcpy(event, (char *) iwe, IW_EV_LCP_LEN);
-	}
-	return value;
-}
-
-/*------------------------------------------------------------------*/
-/*
- * Wrapper to add an Wireless Event to a stream of events.
- * Same as above, with explicit error check...
- */
-static inline char *
-iwe_stream_check_add_event(char *	stream,		/* Stream of events */
-			   char *	ends,		/* End of stream */
-			   struct iw_event *iwe,	/* Payload */
-			   int		event_len,	/* Size of payload */
-			   int *	perr)		/* Error report */
-{
-	/* Check if it's possible, set error if not */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
-		/* Beware of alignement issues on 64 bits */
 		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN,
-		       event_len - IW_EV_LCP_LEN);
-		stream += event_len;
-	} else
-		*perr = -E2BIG;
-	return stream;
-}
-
-/*------------------------------------------------------------------*/
-/*
- * Wrapper to add an short Wireless Event containing a pointer to a
- * stream of events.
- * Same as above, with explicit error check...
- */
-static inline char *
-iwe_stream_check_add_point(char *	stream,		/* Stream of events */
-			   char *	ends,		/* End of stream */
-			   struct iw_event *iwe,	/* Payload length + flags */
-			   char *	extra,		/* More payload */
-			   int *	perr)		/* Error report */
-{
-	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
-	/* Check if it's possible */
-	if(likely((stream + event_len) < ends)) {
-		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_LCP_LEN,
-		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
+		memcpy(stream + lcp_len,
+		       ((char *) iwe) + lcp_len + point_off,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
+		memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
-	} else
-		*perr = -E2BIG;
+	}
 	return stream;
 }
 
@@ -613,29 +549,29 @@ iwe_stream_check_add_point(char *	stream,		/* Stream of events */
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
+	int lcp_len = IW_EV_LCP_LEN;
+
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT)
+		lcp_len = IW_EV_COMPAT_LCP_LEN;
+#endif
 	/* Don't duplicate LCP */
 	event_len -= IW_EV_LCP_LEN;
 
 	/* Check if it's possible */
 	if(likely((value + event_len) < ends)) {
 		/* Add new value */
-		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
+		memcpy(value, (char *) iwe + lcp_len, event_len);
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
index d309e8f..cba556c 100644
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
@@ -104,7 +108,8 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+	start = iwe_stream_add_point(info, start, stop,
+				     &iwe, network->ssid);
 
 	/* Add basic and extended rates */
 	/* Rate : stuffing multiple values in a single event require a bit
@@ -124,14 +129,16 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
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
 	if((current_val - start) > IW_EV_LCP_LEN)
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
index 72e1c93..b8306aa 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -23,6 +23,7 @@
 #include <linux/spinlock.h>
 #include <linux/etherdevice.h>
 #include <net/wireless.h>
+#include <net/iw_handler.h>
 #include "ieee80211_key.h"
 #include "sta_info.h"
 
@@ -748,7 +749,9 @@ int ieee80211_sta_set_bssid(struct net_device *dev, u8 *bssid);
 int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len);
 void ieee80211_sta_req_auth(struct net_device *dev,
 			    struct ieee80211_if_sta *ifsta);
-int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len);
+int ieee80211_sta_scan_results(struct net_device *dev,
+			       struct iw_request_info *info,
+			       char *buf, size_t len);
 void ieee80211_sta_rx_scan(struct net_device *dev, struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status);
 void ieee80211_rx_bss_list_init(struct net_device *dev);
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 7027eed..0f686f1 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -560,7 +560,7 @@ static int ieee80211_ioctl_giwscan(struct net_device *dev,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	if (local->sta_scanning)
 		return -EAGAIN;
-	res = ieee80211_sta_scan_results(dev, extra, data->length);
+	res = ieee80211_sta_scan_results(dev, info, extra, data->length);
 	if (res >= 0) {
 		data->length = res;
 		return 0;
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index bee8080..b176e13 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2881,6 +2881,7 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 
 static char *
 ieee80211_sta_scan_result(struct net_device *dev,
+			  struct iw_request_info *info,
 			  struct ieee80211_sta_bss *bss,
 			  char *current_ev, char *end_buf)
 {
@@ -2907,15 +2908,15 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_ADDR_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_ADDR_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.length = bss->ssid_len;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-					  bss->ssid);
+	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+					  &iwe, bss->ssid);
 
 	if (bss->capability & (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS)) {
 		memset(&iwe, 0, sizeof(iwe));
@@ -2924,20 +2925,20 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-						  IW_EV_UINT_LEN);
+		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+						  &iwe, IW_EV_UINT_LEN);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = bss->channel;
 	iwe.u.freq.e = 0;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_FREQ_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_FREQ_LEN);
 	iwe.u.freq.m = bss->freq * 100000;
 	iwe.u.freq.e = 1;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_FREQ_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_FREQ_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = IWEVQUAL;
@@ -2945,8 +2946,8 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.u.qual.level = bss->rssi;
 	iwe.u.qual.noise = bss->noise;
 	iwe.u.qual.updated = local->wstats_flags;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_QUAL_LEN);
+	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
+					  &iwe, IW_EV_QUAL_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWENCODE;
@@ -2955,22 +2956,22 @@ ieee80211_sta_scan_result(struct net_device *dev,
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
-						  bss->wpa_ie);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, bss->wpa_ie);
 	}
 
 	if (bss && bss->rsn_ie) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  bss->rsn_ie);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, bss->rsn_ie);
 	}
 
 	if (bss && bss->supp_rates_len > 0) {
@@ -2986,8 +2987,8 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		for (i = 0; i < bss->supp_rates_len; i++) {
 			iwe.u.bitrate.value = ((bss->supp_rates[i] &
 							0x7f) * 500000);
-			p = iwe_stream_add_value(current_ev, p,
-					end_buf, &iwe, IW_EV_PARAM_LEN);
+			p = iwe_stream_add_value(info, current_ev, p, end_buf,
+						 &iwe, IW_EV_PARAM_LEN);
 		}
 		current_ev = p;
 	}
@@ -3000,8 +3001,8 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			iwe.cmd = IWEVCUSTOM;
 			sprintf(buf, "tsf=%016llx", (unsigned long long)(bss->timestamp));
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+			current_ev = iwe_stream_add_point(info, current_ev,
+							  end_buf, &iwe, buf);
 			kfree(buf);
 		}
 	}
@@ -3020,15 +3021,15 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d", bss->beacon_int);
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "capab=0x%04x", bss->capability);
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
+						  &iwe, buf);
 
 		kfree(buf);
 		break;
@@ -3038,7 +3039,9 @@ ieee80211_sta_scan_result(struct net_device *dev,
 }
 
 
-int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
+int ieee80211_sta_scan_results(struct net_device *dev,
+			       struct iw_request_info *info,
+			       char *buf, size_t len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	char *current_ev = buf;
@@ -3051,8 +3054,8 @@ int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
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
-- 
1.5.4.rc2.84.gf85fd

