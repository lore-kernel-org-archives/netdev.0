From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: [PATCH 02/3] d80211:  iwlist scan
Date: Mon, 21 Aug 2006 17:36:16 -0700
Message-ID: <44EA5180.2080701@linux.intel.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net> <44EA501E.4010605@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020501000804050400030100"
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:39202 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751337AbWHVAhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 20:37:18 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44EA501E.4010605@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020501000804050400030100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch enhance iwlist scan to dispaly supported rate with readable 
format. It also add a macro to convert channel to freq value. this macro 
is needed in ieee80211_rx_bss_info. In 3945 we issues a host scan 
command to perform scanning which will cause in setting the freq to the 
wrong value.

--------------020501000804050400030100
Content-Type: text/plain;
 name="d80211-iwlist-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-iwlist-fix.patch"

diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index bdaaf5e..29c40c5 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -442,6 +445,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 #define IEEE80211_SCAN_MATCH_SSID BIT(0)
 #define IEEE80211_SCAN_WPA_ONLY BIT(1)
 #define IEEE80211_SCAN_EXTRA_INFO BIT(2)
+#define IEEE80211_SCAN_SUPP_RATE_INFO BIT(3)
 	int scan_flags;
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 8caf352..1153932 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1329,6 +1329,11 @@ void ieee80211_rx_bss_list_deinit(struct
 	}
 }
 
+/* macro to convert channel to freq value */
+#define ieee80211chan2mhz(x) \
+        (((x) <= 14) ? \
+        (((x) == 14) ? 2484 : ((x) * 5) + 2407) : \
+        ((x) + 1000) * 5)
 
 static void ieee80211_rx_bss_info(struct net_device *dev,
 				  struct ieee80211_mgmt *mgmt,
@@ -1547,18 +1552,7 @@ #endif
 	bss->hw_mode = local->conf.phymode;
 	bss->channel = channel;
 	bss->freq = local->conf.freq;
-	if (channel != local->conf.channel &&
-	    (local->conf.phymode == MODE_IEEE80211G ||
-	     local->conf.phymode == MODE_IEEE80211B) &&
-	    channel >= 1 && channel <= 14) {
-		static const int freq_list[] = {
-			2412, 2417, 2422, 2427, 2432, 2437, 2442,
-			2447, 2452, 2457, 2462, 2467, 2472, 2484
-		};
-		/* IEEE 802.11g/b mode can receive packets from neighboring
-		 * channels, so map the channel into frequency. */
-		bss->freq = freq_list[channel - 1];
-	}
+	bss->freq = ieee80211chan2mhz(channel);
 	bss->timestamp = timestamp;
 	bss->last_update = jiffies;
 	bss->rssi = rx_status->ssi;
@@ -2724,16 +2719,33 @@ ieee80211_sta_scan_result(struct net_dev
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
 						  buf);
 
-		p = buf;
-		p += sprintf(p, "supp_rates=");
-		for (i = 0; i < bss->supp_rates_len; i++)
-			p+= sprintf(p, "%02x", bss->supp_rates[i]);
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
-
+		/* dispaly all support rates in readable format */
+		if ((local->scan_flags & IEEE80211_SCAN_SUPP_RATE_INFO)) {
+        		p = current_ev + IW_EV_LCP_LEN;
+        		iwe.cmd = SIOCGIWRATE;
+        		/* Those two flags are ignored... */
+        		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+                	for (i = 0; i < bss->supp_rates_len; i++) {
+				iwe.u.bitrate.value = ((bss->supp_rates[i] & 
+							      0x7f) * 500000);
+				p = iwe_stream_add_value(current_ev, p, 
+					      end_buf, &iwe, IW_EV_PARAM_LEN);
+			}
+        		/* Check if we added any rate */
+	        	if((p - current_ev) > IW_EV_LCP_LEN)
+                		current_ev = p;
+		} else {
+			p = buf;
+			p += sprintf(p, "supp_rates=");
+			for (i = 0; i < bss->supp_rates_len; i++)
+				p+= sprintf(p, "%02x", bss->supp_rates[i]);
+			memset(&iwe, 0, sizeof(iwe));
+			iwe.cmd = IWEVCUSTOM;
+			iwe.u.data.length = strlen(buf);
+			current_ev = iwe_stream_add_point(current_ev, end_buf, 
+						  &iwe, buf);
+		}
 		kfree(buf);
 		break;
 	} while (0);

--------------020501000804050400030100--
