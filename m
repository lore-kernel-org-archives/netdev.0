From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [WEXT 12/12]: Emit event stream compat iw_point objects correctly.
Date: Fri, 21 Dec 2007 20:58:08 -0800 (PST)
Message-ID: <20071221.205808.213484078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


[WEXT]: Emit event stream compat iw_point objects correctly.

Three major portions to this change:

1) Add IW_EV_COMPAT_POINT_LEN helper define.

2) Add iw_request_info argument to iwe_stream_add_point() and
   iwe_stream_check_add_point(), and use it to size the event
   and pointer lengths correctly depending upon whether
   IW_REQUEST_FLAG_COMPAT is set or not.

3) The mechanical transformations to the drivers and wireless stack
   bits to get the iw_request_info passed down into the routines
   modified in #2.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/wireless/airo.c                |   16 ++++++++++------
 drivers/net/wireless/atmel.c               |    4 ++--
 drivers/net/wireless/hostap/hostap.h       |    3 ++-
 drivers/net/wireless/hostap/hostap_ap.c    |   13 ++++++++-----
 drivers/net/wireless/hostap/hostap_ioctl.c |   28 ++++++++++++++++------------
 drivers/net/wireless/libertas/scan.c       |   19 +++++++++++--------
 drivers/net/wireless/orinoco.c             |    7 ++++---
 drivers/net/wireless/prism54/isl_ioctl.c   |   20 +++++++++++++-------
 drivers/net/wireless/wl3501_cs.c           |    6 ++++--
 drivers/net/wireless/zd1201.c              |    5 +++--
 include/linux/wireless.h                   |    6 ++++++
 include/net/iw_handler.h                   |   28 ++++++++++++++++++++++++----
 net/ieee80211/ieee80211_wx.c               |   26 +++++++++++++++-----------
 net/mac80211/ieee80211_i.h                 |    5 ++++-
 net/mac80211/ieee80211_ioctl.c             |    2 +-
 net/mac80211/ieee80211_sta.c               |   23 +++++++++++++----------
 16 files changed, 136 insertions(+), 75 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 074055e..ede5e59 100644
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
@@ -7259,7 +7260,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.u.data.length = 32;
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid,
+					  info);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -7307,7 +7309,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid,
+					  info);
 
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
@@ -7336,7 +7339,8 @@ static inline char *airo_translate_scan(struct net_device *dev,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d", bss->beaconInterval);
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+						  buf, info);
 		kfree(buf);
 	}
 
@@ -7371,7 +7375,7 @@ static inline char *airo_translate_scan(struct net_device *dev,
 					iwe.u.data.length = min(info_element->len + 2,
 								  MAX_WPA_IE_LEN);
 					current_ev = iwe_stream_add_point(current_ev, end_buf,
-							&iwe, (char *) info_element);
+									  &iwe, (char *) info_element, info);
 				}
 				break;
 
@@ -7380,7 +7384,7 @@ static inline char *airo_translate_scan(struct net_device *dev,
 				iwe.u.data.length = min(info_element->len + 2,
 							  MAX_WPA_IE_LEN);
 				current_ev = iwe_stream_add_point(current_ev, end_buf,
-						&iwe, (char *) info_element);
+								  &iwe, (char *) info_element, info);
 				break;
 
 			default:
@@ -7419,7 +7423,7 @@ static int airo_get_scan(struct net_device *dev,
 
 	list_for_each_entry (net, &ai->network_list, list) {
 		/* Translate to WE format this entry */
-		current_ev = airo_translate_scan(dev, current_ev,
+		current_ev = airo_translate_scan(dev, info, current_ev,
 						 extra + dwrq->length,
 						 &net->bss);
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 059ce3f..03ab953 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -2327,7 +2327,7 @@ static int atmel_get_scan(struct net_device *dev,
 			iwe.u.data.length = 32;
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, priv->BSSinfo[i].SSID);
+		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, priv->BSSinfo[i].SSID, info);
 
 		iwe.cmd = SIOCGIWMODE;
 		iwe.u.mode = priv->BSSinfo[i].BSStype;
@@ -2352,7 +2352,7 @@ static int atmel_get_scan(struct net_device *dev,
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
 		iwe.u.data.length = 0;
-		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, NULL);
+		current_ev = iwe_stream_add_point(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, NULL, info);
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
index 6bbdb76..8090e87 100644
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
@@ -2449,7 +2450,8 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 			iwe.u.data.flags = 1;
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 							  &iwe,
-							  sta->u.ap.ssid);
+							  sta->u.ap.ssid,
+							  info);
 
 			memset(&iwe, 0, sizeof(iwe));
 			iwe.cmd = SIOCGIWENCODE;
@@ -2460,8 +2462,9 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 				iwe.u.data.flags = IW_ENCODE_DISABLED;
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 							  &iwe,
-							  sta->u.ap.ssid
-							  /* 0 byte memcpy */);
+							  sta->u.ap.ssid,
+							  /* 0 byte memcpy */
+							  info);
 
 			if (sta->u.ap.channel > 0 &&
 			    sta->u.ap.channel <= FREQ_COUNT) {
@@ -2481,7 +2484,7 @@ int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 				sta->listen_interval);
 			iwe.u.data.length = strlen(buf);
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+							  &iwe, buf, info);
 		}
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index d8f5efc..1c18a39 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1794,6 +1794,7 @@ static int prism2_ioctl_siwscan(struct net_device *dev,
 
 #ifndef PRISM2_NO_STATION_MODES
 static char * __prism2_translate_scan(local_info_t *local,
+				      struct iw_request_info *info,
 				      struct hfa384x_hostscan_result *scan,
 				      struct hostap_bss_info *bss,
 				      char *current_ev, char *end_buf)
@@ -1833,7 +1834,8 @@ static char * __prism2_translate_scan(local_info_t *local,
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.length = ssid_len;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, ssid);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, ssid,
+					  info);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWMODE;
@@ -1896,7 +1898,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "", info);
 
 	/* TODO: add SuppRates into BSS table */
 	if (scan) {
@@ -1926,14 +1928,14 @@ static char * __prism2_translate_scan(local_info_t *local,
 		sprintf(buf, "bcn_int=%d", le16_to_cpu(scan->beacon_interval));
 		iwe.u.data.length = strlen(buf);
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+						  buf, info);
 
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "resp_rate=%d", le16_to_cpu(scan->rate));
 		iwe.u.data.length = strlen(buf);
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+						  buf, info);
 
 		if (local->last_scan_type == PRISM2_HOSTSCAN &&
 		    (capabilities & WLAN_CAPABILITY_IBSS)) {
@@ -1942,7 +1944,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 			sprintf(buf, "atim=%d", le16_to_cpu(scan->atim));
 			iwe.u.data.length = strlen(buf);
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+							  &iwe, buf, info);
 		}
 	}
 	kfree(buf);
@@ -1952,7 +1954,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
 		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, bss->wpa_ie);
+			current_ev, end_buf, &iwe, bss->wpa_ie, info);
 	}
 
 	if (bss && bss->rsn_ie_len > 0 && bss->rsn_ie_len <= MAX_WPA_IE_LEN) {
@@ -1960,7 +1962,7 @@ static char * __prism2_translate_scan(local_info_t *local,
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
 		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, bss->rsn_ie);
+			current_ev, end_buf, &iwe, bss->rsn_ie, info);
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
index ad1e67d..214bc96 100644
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
@@ -1476,7 +1477,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
 	iwe.u.data.length = min((u32) bss->ssid_len, (u32) IW_ESSID_MAX_SIZE);
-	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid);
+	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid, info);
 
 	/* Mode */
 	iwe.cmd = SIOCGIWMODE;
@@ -1533,7 +1534,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	}
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid);
+	start = iwe_stream_add_point(start, stop, &iwe, bss->ssid, info);
 
 	current_val = start + IW_EV_LCP_LEN;
 
@@ -1567,7 +1568,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		memcpy(buf, bss->wpa_ie, bss->wpa_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf, info);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1576,7 +1577,7 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		memcpy(buf, bss->rsn_ie, bss->rsn_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf, info);
 	}
 
 	if (bss->mesh) {
@@ -1588,7 +1589,8 @@ static inline char *libertas_translate_scan(wlan_private *priv,
 		              "mesh-type: olpc");
 		iwe.u.data.length = p - custom;
 		if (iwe.u.data.length)
-			start = iwe_stream_add_point(start, stop, &iwe, custom);
+			start = iwe_stream_add_point(start, stop, &iwe, custom,
+						     info);
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
index ca6c2da..a5d8ab4 100644
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
@@ -3989,7 +3990,7 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 			iwe.u.data.length = 32;
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.flags = 1;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid, info);
 
 		/* Add mode */
 		iwe.cmd = SIOCGIWMODE;
@@ -4032,7 +4033,7 @@ static inline int orinoco_translate_scan(struct net_device *dev,
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
 		iwe.u.data.length = 0;
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid, info);
 
 		/* Bit rate is not available in Lucent/Agere firmwares */
 		if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
@@ -4102,7 +4103,7 @@ static int orinoco_ioctl_getscan(struct net_device *dev,
 		/* We have some results to push back to user space */
 
 		/* Translate to WE format */
-		int ret = orinoco_translate_scan(dev, extra,
+		int ret = orinoco_translate_scan(dev, info, extra,
 						 priv->scan_result,
 						 priv->scan_len);
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 6d80ca4..3261bf4 100644
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
@@ -595,7 +596,7 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 	iwe.u.data.flags = 1;
 	iwe.cmd = SIOCGIWESSID;
 	current_ev = iwe_stream_add_point(current_ev, end_buf,
-					  &iwe, bss->ssid.octets);
+					  &iwe, bss->ssid.octets, info);
 
 	/* Capabilities */
 #define CAP_ESS 0x01
@@ -622,7 +623,8 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
 	iwe.cmd = SIOCGIWENCODE;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, NULL,
+					  info);
 
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
 	iwe.u.freq.m = bss->channel;
@@ -646,7 +648,7 @@ prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = min(wpa_ie_len, (size_t)MAX_WPA_IE_LEN);
 		current_ev = iwe_stream_add_point(current_ev, end_buf,
-				&iwe, wpa_ie);
+						  &iwe, wpa_ie, info);
 	}
 	/* Do the bitrates */
 	{
@@ -711,7 +713,7 @@ prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
 
 	/* ok now, scan the list and translate its info */
 	for (i = 0; i < (int) bsslist->nr; i++) {
-		current_ev = prism54_translate_bss(ndev, current_ev,
+		current_ev = prism54_translate_bss(ndev, info, current_ev,
 						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
@@ -2705,6 +2707,7 @@ prism2_ioctl_scan_req(struct net_device *ndev,
                      struct prism2_hostapd_param *param)
 {
 	islpci_private *priv = netdev_priv(ndev);
+	struct iw_request_info info;
 	int i, rvalue;
 	struct obj_bsslist *bsslist;
 	u32 noise = 0;
@@ -2728,9 +2731,12 @@ prism2_ioctl_scan_req(struct net_device *ndev,
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
index 42a36b3..9dbf028 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1633,7 +1633,8 @@ static int wl3501_get_scan(struct net_device *dev, struct iw_request_info *info,
 		current_ev = iwe_stream_add_point(current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe,
-						  this->bss_set[i].ssid.essid);
+						  this->bss_set[i].ssid.essid,
+						  info);
 		iwe.cmd	   = SIOCGIWMODE;
 		iwe.u.mode = this->bss_set[i].bss_type;
 		current_ev = iwe_stream_add_event(current_ev,
@@ -1653,7 +1654,8 @@ static int wl3501_get_scan(struct net_device *dev, struct iw_request_info *info,
 		iwe.u.data.length = 0;
 		current_ev = iwe_stream_add_point(current_ev,
 						  extra + IW_SCAN_MAX_DATA,
-						  &iwe, NULL);
+						  &iwe, NULL,
+						  info);
 	}
 	/* Length of data */
 	wrqu->data.length = (current_ev - extra);
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index d5c0c66..4fd83fd 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1157,7 +1157,8 @@ static int zd1201_get_scan(struct net_device *dev,
 		iwe.cmd = SIOCGIWESSID;
 		iwe.u.data.length = zd->rxdata[i+16];
 		iwe.u.data.flags = 1;
-		cev = iwe_stream_add_point(cev, end_buf, &iwe, zd->rxdata+i+18);
+		cev = iwe_stream_add_point(cev, end_buf, &iwe, zd->rxdata+i+18,
+					   info);
 
 		iwe.cmd = SIOCGIWMODE;
 		if (zd->rxdata[i+14]&0x01)
@@ -1186,7 +1187,7 @@ static int zd1201_get_scan(struct net_device *dev,
 			iwe.u.data.flags = IW_ENCODE_ENABLED;
 		else
 			iwe.u.data.flags = IW_ENCODE_DISABLED;
-		cev = iwe_stream_add_point(cev, end_buf, &iwe, NULL);
+		cev = iwe_stream_add_point(cev, end_buf, &iwe, NULL, info);
 		
 		iwe.cmd = IWEVQUAL;
 		iwe.u.qual.qual = zd->rxdata[i+4];
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 2088524..ff25e06 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1098,6 +1098,12 @@ struct iw_event
 #define IW_EV_POINT_LEN	(IW_EV_LCP_LEN + sizeof(struct iw_point) - \
 			 IW_EV_POINT_OFF)
 
+#if defined(__KERNEL__) && defined(CONFIG_COMPAT)
+#define IW_EV_COMPAT_POINT_LEN	\
+	(IW_EV_LCP_LEN + sizeof(struct compat_iw_point) - \
+	 IW_EV_POINT_OFF)
+#endif
+
 /* Size of the Event prefix when packed in stream */
 #define IW_EV_LCP_PK_LEN	(4)
 /* Size of the various events when packed in stream */
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index c99a8ee..5530e09 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -510,9 +510,19 @@ static inline char *
 iwe_stream_add_point(char *	stream,		/* Stream of events */
 		     char *	ends,		/* End of stream */
 		     struct iw_event *iwe,	/* Payload length + flags */
-		     char *	extra)		/* More payload */
+		     char *	extra,		/* More payload */
+		     struct iw_request_info *info)
 {
 	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+	int	point_len = IW_EV_POINT_LEN;
+
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
+		event_len = IW_EV_COMPAT_POINT_LEN + iwe->u.data.length;
+		point_len = IW_EV_COMPAT_POINT_LEN;
+	}
+#endif
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -520,7 +530,7 @@ iwe_stream_add_point(char *	stream,		/* Stream of events */
 		memcpy(stream + IW_EV_LCP_LEN,
 		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
+		memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
 	}
 	return stream;
@@ -591,9 +601,19 @@ iwe_stream_check_add_point(char *	stream,		/* Stream of events */
 			   char *	ends,		/* End of stream */
 			   struct iw_event *iwe,	/* Payload length + flags */
 			   char *	extra,		/* More payload */
-			   int *	perr)		/* Error report */
+			   int *	perr,		/* Error report */
+			   struct iw_request_info *info)
 {
 	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+	int	point_len = IW_EV_POINT_LEN;
+
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
+		event_len = IW_EV_COMPAT_POINT_LEN + iwe->u.data.length;
+		point_len = IW_EV_COMPAT_POINT_LEN;
+	}
+#endif
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -601,7 +621,7 @@ iwe_stream_check_add_point(char *	stream,		/* Stream of events */
 		memcpy(stream + IW_EV_LCP_LEN,
 		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
+		memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
 	} else
 		*perr = -E2BIG;
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index d309e8f..fc0777c 100644
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
@@ -66,10 +67,12 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	iwe.u.data.flags = 1;
 	if (network->flags & NETWORK_EMPTY_ESSID) {
 		iwe.u.data.length = sizeof("<hidden>");
-		start = iwe_stream_add_point(start, stop, &iwe, "<hidden>");
+		start = iwe_stream_add_point(start, stop, &iwe, "<hidden>",
+					     info);
 	} else {
 		iwe.u.data.length = min(network->ssid_len, (u8) 32);
-		start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+		start = iwe_stream_add_point(start, stop, &iwe, network->ssid,
+					     info);
 	}
 
 	/* Add the protocol name */
@@ -104,7 +107,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+	start = iwe_stream_add_point(start, stop, &iwe, network->ssid, info);
 
 	/* Add basic and extended rates */
 	/* Rate : stuffing multiple values in a single event require a bit
@@ -188,7 +191,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 
 	iwe.u.data.length = p - custom;
 	if (iwe.u.data.length)
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(start, stop, &iwe, custom, info);
 
 	memset(&iwe, 0, sizeof(iwe));
 	if (network->wpa_ie_len) {
@@ -196,7 +199,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		memcpy(buf, network->wpa_ie, network->wpa_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = network->wpa_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf, info);
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -205,7 +208,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		memcpy(buf, network->rsn_ie, network->rsn_ie_len);
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = network->rsn_ie_len;
-		start = iwe_stream_add_point(start, stop, &iwe, buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf, info);
 	}
 
 	/* Add EXTRA: Age to display seconds since last beacon/probe response
@@ -217,7 +220,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 		      jiffies_to_msecs(jiffies - network->last_scanned));
 	iwe.u.data.length = p - custom;
 	if (iwe.u.data.length)
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(start, stop, &iwe, custom, info);
 
 	/* Add spectrum management information */
 	iwe.cmd = -1;
@@ -238,7 +241,7 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 
 	if (iwe.cmd == IWEVCUSTOM) {
 		iwe.u.data.length = p - custom;
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		start = iwe_stream_add_point(start, stop, &iwe, custom, info);
 	}
 
 	return start;
@@ -272,7 +275,8 @@ int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
 
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
index 16afd24..29a059e 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2885,6 +2885,7 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 
 static char *
 ieee80211_sta_scan_result(struct net_device *dev,
+			  struct iw_request_info *info,
 			  struct ieee80211_sta_bss *bss,
 			  char *current_ev, char *end_buf)
 {
@@ -2919,7 +2920,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	iwe.u.data.length = bss->ssid_len;
 	iwe.u.data.flags = 1;
 	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-					  bss->ssid);
+					  bss->ssid, info);
 
 	if (bss->capability & (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS)) {
 		memset(&iwe, 0, sizeof(iwe));
@@ -2959,14 +2960,14 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "", info);
 
 	if (bss && bss->wpa_ie) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->wpa_ie_len;
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  bss->wpa_ie);
+						  bss->wpa_ie, info);
 	}
 
 	if (bss && bss->rsn_ie) {
@@ -2974,7 +2975,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = bss->rsn_ie_len;
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  bss->rsn_ie);
+						  bss->rsn_ie, info);
 	}
 
 	if (bss && bss->supp_rates_len > 0) {
@@ -3005,7 +3006,7 @@ ieee80211_sta_scan_result(struct net_device *dev,
 			sprintf(buf, "tsf=%016llx", (unsigned long long)(bss->timestamp));
 			iwe.u.data.length = strlen(buf);
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
+							  &iwe, buf, info);
 			kfree(buf);
 		}
 	}
@@ -3025,14 +3026,14 @@ ieee80211_sta_scan_result(struct net_device *dev,
 		sprintf(buf, "bcn_int=%d", bss->beacon_int);
 		iwe.u.data.length = strlen(buf);
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+						  buf, info);
 
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "capab=0x%04x", bss->capability);
 		iwe.u.data.length = strlen(buf);
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+						  buf, info);
 
 		kfree(buf);
 		break;
@@ -3042,7 +3043,9 @@ ieee80211_sta_scan_result(struct net_device *dev,
 }
 
 
-int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
+int ieee80211_sta_scan_results(struct net_device *dev,
+			       struct iw_request_info *info,
+			       char *buf, size_t len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	char *current_ev = buf;
@@ -3055,8 +3058,8 @@ int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
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
1.5.4.rc1
