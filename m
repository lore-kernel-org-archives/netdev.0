From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 1/10] hostap: Clear station statistic on accounting start
Date: Sat, 12 Mar 2005 16:28:58 -0800
Message-ID: <20050313002858.GB8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Added support for larger number of BSSes in scan results by using local BSS
list to fill in APs that are missing from firmware scan results (firmware limit
seemed to be 32 APs at least in some versions); this requires STA firmware
version 1.7.x or newer and WPA enabled.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_80211_rx.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c	2005-03-12 16:10:42.000000000 -0800
@@ -361,14 +361,13 @@
 				 int stype)
 {
 	struct hostap_ieee80211_mgmt *mgmt;
-	int left;
+	int left, chan = 0;
 	u8 *pos;
 	u8 *ssid = NULL, *wpa = NULL, *rsn = NULL;
 	size_t ssid_len = 0, wpa_len = 0, rsn_len = 0;
 	struct hostap_bss_info *bss;
 
-	if (!local->wpa ||
-	    skb->len < IEEE80211_MGMT_HDR_LEN + sizeof(mgmt->u.beacon))
+	if (skb->len < IEEE80211_MGMT_HDR_LEN + sizeof(mgmt->u.beacon))
 		return;
 
 	mgmt = (struct hostap_ieee80211_mgmt *) skb->data;
@@ -395,6 +394,10 @@
 			rsn = pos;
 			rsn_len = pos[1] + 2;
 			break;
+		case WLAN_EID_DS_PARAMS:
+			if (pos[1] >= 1)
+				chan = pos[2];
+			break;
 		}
 		left -= 2 + pos[1];
 		pos += 2 + pos[1];
@@ -425,6 +428,7 @@
 			bss->rsn_ie_len = rsn_len;
 		} else
 			bss->rsn_ie_len = 0;
+		bss->chan = chan;
 	}
 	__hostap_expire_bss(local);
 	spin_unlock(&local->lock);
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-12 16:10:42.000000000 -0800
@@ -1768,7 +1768,7 @@
 				      struct hostap_bss_info *bss, u8 *bssid,
 				      char *current_ev, char *end_buf)
 {
-	int i;
+	int i, chan;
 	struct iw_event iwe;
 	char *current_val;
 	u16 capabilities;
@@ -1814,8 +1814,12 @@
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWMODE;
-	capabilities = le16_to_cpu(hostscan ? hscan->capability :
-				   scan->capability);
+	if (bss) {
+		capabilities = bss->capab_info;
+	} else {
+		capabilities = le16_to_cpu(hostscan ? hscan->capability :
+					   scan->capability);
+	}
 	if (capabilities & (WLAN_CAPABILITY_ESS |
 			    WLAN_CAPABILITY_IBSS)) {
 		if (capabilities & WLAN_CAPABILITY_ESS)
@@ -1829,26 +1833,38 @@
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = freq_list[le16_to_cpu(hostscan ? hscan->chid :
-					     scan->chid) - 1] * 100000;
-	iwe.u.freq.e = 1;
-	iwe.len = IW_EV_FREQ_LEN;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_FREQ_LEN);
-
-	memset(&iwe, 0, sizeof(iwe));
-	iwe.cmd = IWEVQUAL;
-	if (hostscan) {
-		iwe.u.qual.level = le16_to_cpu(hscan->sl);
-		iwe.u.qual.noise = le16_to_cpu(hscan->anl);
+	if (hscan || scan) {
+		chan = hostscan ? hscan->chid : scan->chid;
+	} else if (bss) {
+		chan = bss->chan;
 	} else {
-		iwe.u.qual.level = HFA384X_LEVEL_TO_dBm(le16_to_cpu(scan->sl));
-		iwe.u.qual.noise = HFA384X_LEVEL_TO_dBm(
-			le16_to_cpu(scan->anl));
+		chan = 0;
+	}
+
+	if (chan > 0) {
+		iwe.u.freq.m = freq_list[le16_to_cpu(chan - 1)] * 100000;
+		iwe.u.freq.e = 1;
+		iwe.len = IW_EV_FREQ_LEN;
+		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+						  IW_EV_FREQ_LEN);
+	}
+
+	if (scan || hscan) {
+		memset(&iwe, 0, sizeof(iwe));
+		iwe.cmd = IWEVQUAL;
+		if (hostscan) {
+			iwe.u.qual.level = le16_to_cpu(hscan->sl);
+			iwe.u.qual.noise = le16_to_cpu(hscan->anl);
+		} else {
+			iwe.u.qual.level =
+				HFA384X_LEVEL_TO_dBm(le16_to_cpu(scan->sl));
+			iwe.u.qual.noise =
+				HFA384X_LEVEL_TO_dBm(le16_to_cpu(scan->anl));
+		}
+		iwe.len = IW_EV_QUAL_LEN;
+		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
+						  IW_EV_QUAL_LEN);
 	}
-	iwe.len = IW_EV_QUAL_LEN;
-	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
-					  IW_EV_QUAL_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWENCODE;
@@ -1860,45 +1876,54 @@
 	iwe.len = IW_EV_POINT_LEN + iwe.u.data.length;
 	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, "");
 
-	memset(&iwe, 0, sizeof(iwe));
-	iwe.cmd = SIOCGIWRATE;
-	current_val = current_ev + IW_EV_LCP_LEN;
-	pos = hostscan ? hscan->sup_rates : scan->sup_rates;
-	for (i = 0; i < sizeof(scan->sup_rates); i++) {
-		if (pos[i] == 0)
-			break;
-		/* Bit rate given in 500 kb/s units (+ 0x80) */
-		iwe.u.bitrate.value = ((pos[i] & 0x7f) * 500000);
-		current_val = iwe_stream_add_value(
-			current_ev, current_val, end_buf, &iwe,
-			IW_EV_PARAM_LEN);
-	}
-	/* Check if we added any event */
-	if ((current_val - current_ev) > IW_EV_LCP_LEN)
-		current_ev = current_val;
-
-	memset(&iwe, 0, sizeof(iwe));
-	iwe.cmd = IWEVCUSTOM;
-	sprintf(buf, "bcn_int=%d",
-		le16_to_cpu(hostscan ? hscan->beacon_interval :
-			    scan->beacon_interval));
-	iwe.u.data.length = strlen(buf);
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+	/* TODO: add SuppRates into BSS table */
+	if (scan || hscan) {
+		memset(&iwe, 0, sizeof(iwe));
+		iwe.cmd = SIOCGIWRATE;
+		current_val = current_ev + IW_EV_LCP_LEN;
+		pos = hostscan ? hscan->sup_rates : scan->sup_rates;
+		for (i = 0; i < sizeof(scan->sup_rates); i++) {
+			if (pos[i] == 0)
+				break;
+			/* Bit rate given in 500 kb/s units (+ 0x80) */
+			iwe.u.bitrate.value = ((pos[i] & 0x7f) * 500000);
+			current_val = iwe_stream_add_value(
+				current_ev, current_val, end_buf, &iwe,
+				IW_EV_PARAM_LEN);
+		}
+		/* Check if we added any event */
+		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+			current_ev = current_val;
+	}
 
-	memset(&iwe, 0, sizeof(iwe));
-	iwe.cmd = IWEVCUSTOM;
-	sprintf(buf, "resp_rate=%d", le16_to_cpu(hostscan ? hscan->rate :
-						 scan->rate));
-	iwe.u.data.length = strlen(buf);
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+	/* TODO: add BeaconInt,resp_rate,atim into BSS table */
+	if (scan || hscan) {
+		memset(&iwe, 0, sizeof(iwe));
+		iwe.cmd = IWEVCUSTOM;
+		sprintf(buf, "bcn_int=%d",
+			le16_to_cpu(hostscan ? hscan->beacon_interval :
+				    scan->beacon_interval));
+		iwe.u.data.length = strlen(buf);
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+						  buf);
 
-	if (hostscan && (capabilities & WLAN_CAPABILITY_IBSS)) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
-		sprintf(buf, "atim=%d", le16_to_cpu(hscan->atim));
+		sprintf(buf, "resp_rate=%d", le16_to_cpu(hostscan ?
+							 hscan->rate :
+							 scan->rate));
 		iwe.u.data.length = strlen(buf);
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
 						  buf);
+
+		if (hostscan && (capabilities & WLAN_CAPABILITY_IBSS)) {
+			memset(&iwe, 0, sizeof(iwe));
+			iwe.cmd = IWEVCUSTOM;
+			sprintf(buf, "atim=%d", le16_to_cpu(hscan->atim));
+			iwe.u.data.length = strlen(buf);
+			current_ev = iwe_stream_add_point(current_ev, end_buf,
+							  &iwe, buf);
+		}
 	}
 
 	if (bss && bss->wpa_ie_len > 0 && bss->wpa_ie_len <= MAX_WPA_IE_LEN ) {
@@ -1948,6 +1973,12 @@
 
 	spin_lock_bh(&local->lock);
 
+	list_for_each(ptr, &local->bss_list) {
+		struct hostap_bss_info *bss;
+		bss = list_entry(ptr, struct hostap_bss_info, list);
+		bss->included = 0;
+	}
+
 	hostscan = local->last_scan_type == PRISM2_HOSTSCAN;
 	entries = hostscan ? local->last_hostscan_results_count :
 		local->last_scan_results_count;
@@ -1965,6 +1996,7 @@
 			struct hostap_bss_info *bss;
 			bss = list_entry(ptr, struct hostap_bss_info, list);
 			if (memcmp(bss->bssid, bssid, ETH_ALEN) == 0) {
+				bss->included = 1;
 				current_ev = __prism2_translate_scan(
 					local, scan, hscan, hostscan, bss,
 					bssid, current_ev, end_buf);
@@ -1984,6 +2016,25 @@
 		}
 	}
 
+	/* Prism2 firmware has limits (32 at least in some versions) for number
+	 * of BSSes in scan results. Extend this limit by using local BSS list.
+	 */
+	list_for_each(ptr, &local->bss_list) {
+		struct hostap_bss_info *bss;
+		bss = list_entry(ptr, struct hostap_bss_info, list);
+		if (bss->included)
+			continue;
+		current_ev = __prism2_translate_scan(local, NULL, NULL, 0, bss,
+						     bss->bssid, current_ev,
+						     end_buf);
+		/* Check if there is space for one more entry */
+		if ((end_buf - current_ev) <= IW_EV_ADDR_LEN) {
+			/* Ask user space to try again with a bigger buffer */
+			spin_unlock_bh(&local->lock);
+			return -E2BIG;
+		}
+	}
+
 	spin_unlock_bh(&local->lock);
 
 	return current_ev - buffer;
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:10:42.000000000 -0800
@@ -630,6 +630,8 @@
 	size_t wpa_ie_len;
 	u8 rsn_ie[MAX_WPA_IE_LEN];
 	size_t rsn_ie_len;
+	int chan;
+	int included;
 };
 
 

-- 
Jouni Malinen                                            PGP id EFC895FA
