From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b drivers
Date: Fri, 12 May 2006 16:35:27 -0400
Message-ID: <200605121635.27959.flamingice@sourmilk.net>
References: <200605042232.35446.flamingice@sourmilk.net> <200605101331.39960.flamingice@sourmilk.net> <20060512124703.563dacd6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:36488 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932231AbWELUgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 16:36:11 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060512124703.563dacd6@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 May 2006 06:47, you wrote:
> > It seems like hw_modes is more useful for saying
> > what modes shouldn't be used than saying what modes are supported by the
> > hardware and should be used.
>
> This is exactly the purpose of hw_modes. This also means you don't need
> any validation.
>
Hm, so why not add something that will tell you what modes are supported by 
the hardware?

Only problem with this patch is if the hardware adds any modes after 
registration, they will be disabled initially. Hopefully, no drivers will 
actually need to do that.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ffb7985..e110237 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3999,19 +3999,24 @@ void ieee80211_if_setup(struct net_devic
 }
 
 
-static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
+static void ieee80211_precalc_modes(struct ieee80211_hw *hw,
+				    struct ieee80211_local *local)
 {
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_rate *rate;
 	int m, r;
 
+	local->valid_hw_modes = 0;
 	for (m = 0; m < hw->num_modes; m++) {
 		mode = &hw->modes[m];
+		local->valid_hw_modes |= 1 << mode->mode;
 		for (r = 0; r < mode->num_rates; r++) {
 			rate = &mode->rates[r];
 			rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
 		}
 	}
+
+	local->hw_modes &= local->valid_hw_modes;
 }
 
 
@@ -4257,7 +4262,7 @@ int ieee80211_update_hw(struct net_devic
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
 
-	ieee80211_precalc_rates(hw);
+	ieee80211_precalc_modes(hw, local);
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ee0b399..6f33a75 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -409,7 +409,6 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int scan_oper_antenna_max;
 	u8 scan_ssid[IEEE80211_MAX_SSID_LEN];
 	size_t scan_ssid_len;
-	int scan_skip_11b;
 	struct list_head sta_bss_list;
 	struct ieee80211_sta_bss *sta_bss_hash[STA_HASH_SIZE];
 	spinlock_t sta_bss_lock;
@@ -500,6 +499,8 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int wifi_wme_noack_test;
 	unsigned int wmm_acm; /* bit field of ACM bits (BIT(802.1D tag)) */
 
+	unsigned int valid_hw_modes; /* bitfield of supported hardware modes;
+				      * (1 << MODE_*) */
 	unsigned int hw_modes; /* bitfield of allowed hardware modes;
 				* (1 << MODE_*) */
 };
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 5d31a8f..89db144 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2447,7 +2447,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		local->hw_modes = value;
+		local->hw_modes = value & local->valid_hw_modes;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2720f1d..7955767 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2468,7 +2468,7 @@ static void ieee80211_sta_scan_timer(uns
 		    (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
 		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
-		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
+		     mode->mode == MODE_IEEE80211B))
 			skip = 1;
 
 		if (!skip) {
@@ -2566,7 +2566,6 @@ int ieee80211_sta_req_scan(struct net_de
 		memcpy(local->scan_ssid, ssid, ssid_len);
 	} else
 		local->scan_ssid_len = 0;
-	local->scan_skip_11b = 1; /* FIX: clear this is 11g is not supported */
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;
