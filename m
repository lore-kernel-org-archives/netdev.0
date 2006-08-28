From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 7/7] d80211: getting wrong freq value if we did hardware scan
Date: Mon, 28 Aug 2006 13:57:28 -0700
Message-ID: <44F358B8.60700@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000509030509060109040701"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:51462 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S932113AbWH1U5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:57:10 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000509030509060109040701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In this patch  we search all A-BAND available channels to get the  right 
frequency value. this might not be the right thing to do in beacon 
parsing. Another approach is to have a static array of  the maximum 
A-BAND channel number then we can map from channel to frequency fast. we 
can set the values of this array at run time.  

--------------000509030509060109040701
Content-Type: text/x-patch;
 name="d80211-iwlist-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-iwlist-fix.patch"


This patch modify d80211 to fix getting wrong frequency value 
for scan implemented in hardware. With harware scan we might get
beacon of a network that is on different channel that in 
local->conf.channel causing set freq to wrong value.
 
Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..374193e 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1543,8 +1543,6 @@ #endif
 	bss->channel = channel;
 	bss->freq = local->conf.freq;
 	if (channel != local->conf.channel &&
-	    (local->conf.phymode == MODE_IEEE80211G ||
-	     local->conf.phymode == MODE_IEEE80211B) &&
 	    channel >= 1 && channel <= 14) {
 		static const int freq_list[] = {
 			2412, 2417, 2422, 2427, 2432, 2437, 2442,
@@ -1553,6 +1551,32 @@ #endif
 		/* IEEE 802.11g/b mode can receive packets from neighboring
 		 * channels, so map the channel into frequency. */
 		bss->freq = freq_list[channel - 1];
+
+		if (bss->hw_mode != MODE_IEEE80211G &&
+		    bss->hw_mode != MODE_IEEE80211B) 
+			bss->hw_mode = MODE_IEEE80211G;
+
+	} else if (channel != local->conf.channel ) {
+		int j, i; 
+		int b_found = 0;
+
+		/* not a bg channel search in other mode */
+		for (i = 0; i < local->hw->num_modes; i++) {
+			struct ieee80211_hw_modes *mode = &local->hw->modes[i];
+
+			if ((mode->mode != MODE_IEEE80211G) &&
+			    (mode->mode != MODE_IEEE80211B)){
+				for (j = 0; mode->num_channels; j++)
+				if (mode->channels[j].chan == channel) {
+					bss->freq = mode->channels[j].freq;
+					b_found = 1;
+					bss->hw_mode = mode->mode;
+					break;
+				}
+			}
+			if (b_found)
+				break;
+		}
 	}
 	bss->timestamp = timestamp;
 	bss->last_update = jiffies;

--------------000509030509060109040701--
