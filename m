From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b drivers
Date: Mon, 15 May 2006 13:19:23 -0400
Message-ID: <200605151319.23246.flamingice@sourmilk.net>
References: <200605042232.35446.flamingice@sourmilk.net> <200605121635.27959.flamingice@sourmilk.net> <20060515133725.3df090af@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:61368 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S965071AbWEORpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 13:45:23 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060515133725.3df090af@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 May 2006 07:37, Jiri Benc wrote:
> This issue can be easily solved by not masking hw_modes by
> valid_hw_modes in ieee80211_ioctl_prism2_param and
> ieee80211_precalc_modes. Just check (hw_modes & valid_hw_modes) instead
> of hw_modes in ieee80211_sta_scan_timer.
>
> And yes, hw_modes is a confusing name. It should be named
> hw_modes_mask_disabled_by_user or so. Maybe at least some better comment
> about this in ieee80211_i.h won't be a bad idea.
>
Okay, how about this? Instead of adding valid_hw_modes, I added enabled_modes, 
and replaced all instances of local->hw_modes with local->enabled_modes. 
local->hw_modes now really means what modes are supported by the hardware.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ffb7985..135db24 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3999,14 +3999,17 @@ void ieee80211_if_setup(struct net_devic
 }
 
 
-static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
+static void ieee80211_precalc_modes(struct ieee80211_hw *hw,
+				    struct ieee80211_local *local)
 {
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_rate *rate;
 	int m, r;
 
+	local->hw_modes = 0;
 	for (m = 0; m < hw->num_modes; m++) {
 		mode = &hw->modes[m];
+		local->hw_modes |= 1 << mode->mode;
 		for (r = 0; r < mode->num_rates; r++) {
 			rate = &mode->rates[r];
 			rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
@@ -4087,7 +4090,7 @@ struct net_device *ieee80211_alloc_hw(si
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
         local->scan.in_scan = 0;
-	local->hw_modes = (unsigned int) -1;
+	local->enabled_modes = (unsigned int) -1;
 
         init_timer(&local->scan.timer); /* clear it out */
 
@@ -4257,7 +4260,7 @@ int ieee80211_update_hw(struct net_devic
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
 
-	ieee80211_precalc_rates(hw);
+	ieee80211_precalc_modes(hw, local);
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ee0b399..595f6b1 100644
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
@@ -500,7 +499,9 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int wifi_wme_noack_test;
 	unsigned int wmm_acm; /* bit field of ACM bits (BIT(802.1D tag)) */
 
-	unsigned int hw_modes; /* bitfield of allowed hardware modes;
+	unsigned int enabled_modes; /* bitfield of allowed modes;
+				      * (1 << MODE_*) */
+	unsigned int hw_modes; /* bitfield of supported hardware modes;
 				* (1 << MODE_*) */
 };
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 5d31a8f..04df0a9 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1699,7 +1699,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			if (chan->flag & IEEE80211_CHAN_W_SCAN &&
 			    ((freq->e == 0 && chan->chan == freq->m) ||
 			     (freq->e > 0 && nfreq == chan->freq)) &&
-			    (local->hw_modes & (1 << mode->mode))) {
+			    (local->enabled_modes & (1 << mode->mode))) {
 				/* Use next_mode as the mode preference to
 				 * resolve non-unique channel numbers. */
 				if (set && mode->mode != local->next_mode)
@@ -2447,7 +2447,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		local->hw_modes = value;
+		local->enabled_modes = value;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -2620,7 +2620,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		*param = local->hw_modes;
+		*param = local->enabled_modes;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2720f1d..af58013 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2462,13 +2462,13 @@ static void ieee80211_sta_scan_timer(uns
 			}
 			return;
 		}
-		skip = !(local->hw_modes & (1 << mode->mode));
+		skip = !(local->enabled_modes & (1 << mode->mode));
 		chan = &mode->channels[local->scan_channel_idx];
 		if (!(chan->flag & IEEE80211_CHAN_W_SCAN) ||
 		    (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
-		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
-		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
+		    (local->hw_modes & local->enabled_modes &
+		     (1 << MODE_IEEE80211G) && mode->mode == MODE_IEEE80211B))
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
@@ -2592,7 +2591,7 @@ ieee80211_sta_scan_result(struct net_dev
 		       bss->last_update + IEEE80211_SCAN_RESULT_EXPIRE))
 		return current_ev;
 
-	if (!(local->hw_modes & (1 << bss->hw_mode)))
+	if (!(local->enabled_modes & (1 << bss->hw_mode)))
 		return current_ev;
 
 	if (local->scan_flags & IEEE80211_SCAN_WPA_ONLY &&
