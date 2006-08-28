From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 3/7] d80211: report supported rates and channels in SIOCGIWRANGE
Date: Mon, 28 Aug 2006 13:47:34 -0700
Message-ID: <44F35666.3070503@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000006060000010008040805"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:10831 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S932083AbWH1UrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:47:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000006060000010008040805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------000006060000010008040805
Content-Type: text/x-patch;
 name="d80211-wrange.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-wrange.patch"


This patch modify d80211 to report more information like supported
rate and channel in SIOCGIWRANGE command.
 
Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..3d8156c 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1566,6 +1566,10 @@ static int ieee80211_ioctl_giwrange(stru
 				 struct iw_point *data, char *extra)
 {
 	struct iw_range *range = (struct iw_range *) extra;
+	int i,j,c,n;
+	int skip = 0;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_hw_modes *bg = NULL;
 
 	data->length = sizeof(struct iw_range);
 	memset(range, 0, sizeof(struct iw_range));
@@ -1581,6 +1585,55 @@ static int ieee80211_ioctl_giwrange(stru
 	range->min_frag = 256;
 	range->max_frag = 2346;
 
+	j = 0;
+	for (i = 0; i < local->num_curr_rates && j < IW_MAX_BITRATES; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (rate->flags & IEEE80211_RATE_SUPPORTED) {
+			range->bitrate[j] = rate->rate * 100000;
+			j++;
+		}
+	}
+	range->num_bitrates = j;
+
+	c = 0;
+	for (i = 0; i < local->hw->num_modes; i++) {
+		struct ieee80211_hw_modes *mode = &local->hw->modes[i];
+
+		for (j = 0; 
+		     j < mode->num_channels && c < IW_MAX_FREQUENCIES; j++) {
+			struct ieee80211_channel *chan = &mode->channels[j];
+
+			/* skip any repeated bg channel */
+			skip = 0;
+			if (bg &&
+			    ((mode->mode == MODE_IEEE80211G) ||
+			    (mode->mode == MODE_IEEE80211B))) {
+				
+				for (n = 0; n < bg->num_channels; n++) {
+					if (bg->channels[0].chan == chan->chan){
+						skip = 1;
+						break;
+					}
+				}
+			}
+
+			if (skip)
+				continue;
+
+			range->freq[c].i = chan->chan;
+			range->freq[c].m = chan->freq * 100000;
+			range->freq[c].e = 1;
+			c++;
+		}
+		if (!bg && ((mode->mode == MODE_IEEE80211G) || 
+		    (mode->mode == MODE_IEEE80211B)))
+			bg = mode;
+
+	}
+	range->num_channels = c;
+	range->num_frequency = c;
+
 	return 0;
 }
 

--------------000006060000010008040805--
