From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked list
Date: Thu, 14 Dec 2006 19:20:11 +0100
Message-ID: <200612141920.11439.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: jbenc-AlSwsSmVLrQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This turns the PHY-modes list into a linked list.
The advantage is that drivers can add modes dynamically, as they probe
them and don't have to settle to a given arraysize at the beginning
of probing.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

--

Note that I will also send fixup patches for all other d80211 drivers,
if no complaints are done against this patch.

Index: bu3sch-wireless-dev/include/net/d80211.h
===================================================================
--- bu3sch-wireless-dev.orig/include/net/d80211.h	2006-12-05 
18:09:34.000000000 +0100
+++ bu3sch-wireless-dev/include/net/d80211.h	2006-12-13 19:40:05.000000000 
+0100
@@ -76,12 +76,14 @@ struct ieee80211_rate {
 		       * optimizing channel utilization estimates */
 };
 
-struct ieee80211_hw_modes {
-	int mode;
-	int num_channels;
-	struct ieee80211_channel *channels;
-	int num_rates;
-        struct ieee80211_rate *rates;
+struct ieee80211_hw_mode {
+	int mode; /* MODE_IEEE80211... */
+	int num_channels; /* Number of channels (below) */
+	struct ieee80211_channel *channels; /* Array of supported channels */
+	int num_rates; /* Number of rates (below) */
+        struct ieee80211_rate *rates; /* Array of supported rates */
+
+	struct list_head list; /* Internal, don't touch */
 };
 
 struct ieee80211_tx_queue_params {
@@ -420,9 +422,7 @@ typedef enum {
 	SET_KEY, DISABLE_KEY, REMOVE_ALL_KEYS,
 } set_key_cmd;
 
-/* This is driver-visible part of the per-hw state the stack keeps.
- * If you change something in here, call ieee80211_update_hw() to
- * notify the stack about the change. */
+/* This is driver-visible part of the per-hw state the stack keeps. */
 struct ieee80211_hw {
 	/* these are assigned by d80211, don't write */
 	int index;
@@ -512,9 +512,6 @@ struct ieee80211_hw {
 	/* This is maximum value for rssi reported by this device */
 	int maxssi;
 
-	int num_modes;
-	struct ieee80211_hw_modes *modes;
-
 	/* Number of available hardware TX queues for data packets.
 	 * WMM requires at least four queues. */
 	int queues;
@@ -750,9 +747,9 @@ static inline char *ieee80211_get_rx_led
 #endif
 }
 
-/* Call this function if you changed the hardware description after
- * ieee80211_register_hw */
-int ieee80211_update_hw(struct ieee80211_hw *hw);
+/* Register a new hardware PHYMODE capability to the stack. */
+int ieee80211_register_hwmode(struct ieee80211_hw *hw,
+			      struct ieee80211_hw_mode *mode);
 
 /* Unregister a hardware device. This function instructs 802.11 code to free
  * allocated resources and unregister netdevices from the kernel. */
Index: bu3sch-wireless-dev/net/d80211/ieee80211.c
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211.c	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211.c	2006-12-13 19:40:05.000000000 
+0100
@@ -1915,7 +1915,8 @@ int ieee80211_if_config_beacon(struct ne
 
 int ieee80211_hw_config(struct ieee80211_local *local)
 {
-	int i, ret = 0;
+	struct ieee80211_hw_mode *mode;
+	int ret = 0;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	printk(KERN_DEBUG "HW CONFIG: channel=%d freq=%d "
@@ -1926,12 +1927,10 @@ int ieee80211_hw_config(struct ieee80211
 	if (local->ops->config)
 		ret = local->ops->config(local_to_hw(local), &local->hw.conf);
 
-	for (i = 0; i < local->hw.num_modes; i++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[i];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		if (mode->mode == local->hw.conf.phymode) {
-			if (local->curr_rates != mode->rates) {
+			if (local->curr_rates != mode->rates)
 				rate_control_clear(local);
-			}
 			local->curr_rates = mode->rates;
 			local->num_curr_rates = mode->num_rates;
 			ieee80211_prepare_rates(local);
@@ -2511,10 +2510,10 @@ ieee80211_rx_h_data(struct ieee80211_txr
 static struct ieee80211_rate *
 ieee80211_get_rate(struct ieee80211_local *local, int phymode, int hw_rate)
 {
-	int m, r;
+	struct ieee80211_hw_mode *mode;
+	int r;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		if (mode->mode != phymode)
 			continue;
 		for (r = 0; r < mode->num_rates; r++) {
@@ -4351,24 +4350,6 @@ void ieee80211_if_mgmt_setup(struct net_
 	dev->destructor = ieee80211_if_free;
 }
 
-static void ieee80211_precalc_modes(struct ieee80211_local *local)
-{
-	struct ieee80211_hw_modes *mode;
-	struct ieee80211_rate *rate;
-	struct ieee80211_hw *hw = &local->hw;
-	int m, r;
-
-	local->hw_modes = 0;
-	for (m = 0; m < hw->num_modes; m++) {
-		mode = &hw->modes[m];
-		local->hw_modes |= 1 << mode->mode;
-		for (r = 0; r < mode->num_rates; r++) {
-			rate = &mode->rates[r];
-			rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
-		}
-	}
-}
-
 int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
 				 const char *name)
 {
@@ -4461,6 +4442,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	local->hw.priv = (char *)mdev->priv +
 			 ((sizeof(struct ieee80211_sub_if_data) +
 			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	local->hw.queues = 1; /* default */
 
 	local->mdev = mdev;
 	local->rx_pre_handlers = ieee80211_rx_pre_handlers;
@@ -4482,6 +4464,8 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 
         init_timer(&local->scan.timer); /* clear it out */
 
+	INIT_LIST_HEAD(&local->modes_list);
+
 	spin_lock_init(&local->sub_if_lock);
 	INIT_LIST_HEAD(&local->sub_if_list);
 
@@ -4546,9 +4530,6 @@ int ieee80211_register_hw(struct ieee802
 
 	local->hw.conf.beacon_int = 1000;
 
-	/* Don't care about the result */
-	ieee80211_update_hw(local_to_hw(local));
-
 	result = sta_info_start(local);
 	if (result < 0)
 		goto fail_sta_info;
@@ -4633,35 +4614,38 @@ fail_sysfs:
 }
 EXPORT_SYMBOL(ieee80211_register_hw);
 
-int ieee80211_update_hw(struct ieee80211_hw *hw)
+int ieee80211_register_hwmode(struct ieee80211_hw *hw,
+			      struct ieee80211_hw_mode *mode)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_rate *rate;
+	int i;
 
-	/* Backwards compatibility for low-level drivers that do not set number
-	 * of TX queues. */
-	if (hw->queues == 0)
-		hw->queues = 1;
-
-	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
-	    !hw->modes->num_channels || !hw->modes->num_rates)
-		return -1;
+	INIT_LIST_HEAD(&mode->list);
+	list_add_tail(&mode->list, &local->modes_list);
 
-	ieee80211_precalc_modes(local);
-	local->hw.conf.phymode = hw->modes[0].mode;
-	local->curr_rates = hw->modes[0].rates;
-	local->num_curr_rates = hw->modes[0].num_rates;
-	ieee80211_prepare_rates(local);
-
-	local->hw.conf.freq = local->hw.modes[0].channels[0].freq;
-	local->hw.conf.channel = local->hw.modes[0].channels[0].chan;
-	local->hw.conf.channel_val = local->hw.modes[0].channels[0].val;
+	local->hw_modes |= (1 << mode->mode);
+	for (i = 0; i < mode->num_rates; i++) {
+		rate = &(mode->rates[i]);
+		rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
+	}
+
+	if (!local->curr_rates) {
+		/* Default to this mode */
+		local->hw.conf.phymode = mode->mode;
+		local->curr_rates = mode->rates;
+		local->num_curr_rates = mode->num_rates;
+		ieee80211_prepare_rates(local);
+		local->hw.conf.freq = mode->channels[0].freq;
+		local->hw.conf.channel = mode->channels[0].chan;
+		local->hw.conf.channel_val = mode->channels[0].val;
+	}
 
 	ieee80211_init_client(local->mdev);
-	/* FIXME: Invoke config to allow driver to set the channel. */
 
 	return 0;
 }
-EXPORT_SYMBOL(ieee80211_update_hw);
+EXPORT_SYMBOL(ieee80211_register_hwmode);
 
 void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 {
Index: bu3sch-wireless-dev/net/d80211/ieee80211_i.h
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211_i.h	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211_i.h	2006-12-13 19:40:05.000000000 
+0100
@@ -181,7 +181,7 @@ struct ieee80211_passive_scan {
 	int channel; /* channel to be scanned */
         int tries;
 
-        int mode_idx;
+	struct ieee80211_hw_mode *mode;
         int chan_idx;
 
 	int freq;
@@ -336,6 +336,9 @@ struct ieee80211_local {
 
 	struct ieee80211_ops *ops;
 
+	/* List of registered struct ieee80211_hw_mode */
+	struct list_head modes_list;
+
 	struct net_device *mdev; /* wmaster# - "master" 802.11 device */
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
@@ -425,7 +428,7 @@ struct ieee80211_local {
         spinlock_t sub_if_lock; /* mutex for STA data structures */
         struct list_head sub_if_list;
 	int sta_scanning;
-	int scan_hw_mode_idx;
+	struct ieee80211_hw_mode *scan_hw_mode;
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
 	unsigned long last_scan_completed;
Index: bu3sch-wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211_ioctl.c	2006-12-13 
19:40:05.000000000 +0100
@@ -120,43 +120,45 @@ static int ieee80211_ioctl_get_hw_featur
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	u8 *pos = param->u.hw_features.data;
 	int left = param_len - (pos - (u8 *) param);
-	int mode, i;
+	int i;
 	struct hostapd_ioctl_hw_modes_hdr *hdr;
 	struct ieee80211_rate_data *rate;
 	struct ieee80211_channel_data *chan;
+	struct ieee80211_hw_mode *mode;
 
 	param->u.hw_features.flags = 0;
 	if (local->hw.flags & IEEE80211_HW_DATA_NULLFUNC_ACK)
 		param->u.hw_features.flags |= HOSTAP_HW_FLAG_NULLFUNC_OK;
 
-	param->u.hw_features.num_modes = local->hw.num_modes;
-	for (mode = 0; mode < local->hw.num_modes; mode++) {
+	param->u.hw_features.num_modes = 0;
+	list_for_each_entry(mode, &local->modes_list, list) {
 		int clen, rlen;
-		struct ieee80211_hw_modes *m = &local->hw.modes[mode];
-		clen = m->num_channels * sizeof(struct ieee80211_channel_data);
-		rlen = m->num_rates * sizeof(struct ieee80211_rate_data);
+
+		param->u.hw_features.num_modes++;
+		clen = mode->num_channels * sizeof(struct ieee80211_channel_data);
+		rlen = mode->num_rates * sizeof(struct ieee80211_rate_data);
 		if (left < sizeof(*hdr) + clen + rlen)
 			return -E2BIG;
 		left -= sizeof(*hdr) + clen + rlen;
 
 		hdr = (struct hostapd_ioctl_hw_modes_hdr *) pos;
-		hdr->mode = m->mode;
-		hdr->num_channels = m->num_channels;
-		hdr->num_rates = m->num_rates;
+		hdr->mode = mode->mode;
+		hdr->num_channels = mode->num_channels;
+		hdr->num_rates = mode->num_rates;
 
 		pos = (u8 *) (hdr + 1);
 		chan = (struct ieee80211_channel_data *) pos;
-		for (i = 0; i < m->num_channels; i++) {
-			chan[i].chan = m->channels[i].chan;
-			chan[i].freq = m->channels[i].freq;
-			chan[i].flag = m->channels[i].flag;
+		for (i = 0; i < mode->num_channels; i++) {
+			chan[i].chan = mode->channels[i].chan;
+			chan[i].freq = mode->channels[i].freq;
+			chan[i].flag = mode->channels[i].flag;
 		}
 		pos += clen;
 
 		rate = (struct ieee80211_rate_data *) pos;
-		for (i = 0; i < m->num_rates; i++) {
-			rate[i].rate = m->rates[i].rate;
-			rate[i].flags = m->rates[i].flags;
+		for (i = 0; i < mode->num_rates; i++) {
+			rate[i].rate = mode->rates[i].rate;
+			rate[i].flags = mode->rates[i].flags;
 		}
 		pos += rlen;
 	}
@@ -198,8 +200,7 @@ static int ieee80211_ioctl_scan(struct n
 		param->u.scan.last_rx = local->scan.rx_packets;
 		local->scan.rx_packets = -1;
 	}
-	param->u.scan.channel = local->hw.modes[local->scan.mode_idx].
-		channels[local->scan.chan_idx].chan;
+	param->u.scan.channel = 
local->scan.mode->channels[local->scan.chan_idx].chan;
 
 	return 0;
 }
@@ -1357,19 +1358,16 @@ static int ieee80211_ioctl_set_channel_f
 					    struct prism2_hostapd_param *param)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_hw_modes *mode = NULL;
+	struct ieee80211_hw_mode *mode;
 	struct ieee80211_channel *chan = NULL;
 	int i;
 
-	for (i = 0; i < local->hw.num_modes; i++) {
-		mode = &local->hw.modes[i];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		if (mode->mode == param->u.set_channel_flag.mode)
-			break;
-		mode = NULL;
+			goto found;
 	}
-
-	if (!mode)
-		return -ENOENT;
+	return -ENOENT;
+found:
 
 	for (i = 0; i < mode->num_channels; i++) {
 		chan = &mode->channels[i];
@@ -1706,10 +1704,10 @@ static void ieee80211_unmask_channel(str
 static int ieee80211_unmask_channels(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	int m, c;
+	struct ieee80211_hw_mode *mode;
+	int c;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		for (c = 0; c < mode->num_channels; c++) {
 			ieee80211_unmask_channel(dev, mode->mode,
 						 &mode->channels[c]);
@@ -1807,7 +1805,8 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			    struct iw_freq *freq, char *extra)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	int m, c, nfreq, set = 0;
+	struct ieee80211_hw_mode *mode;
+	int c, nfreq, set = 0;
 
 	/* freq->e == 0: freq->m = channel; otherwise freq = m * 10^e */
 	if (freq->e == 0)
@@ -1822,8 +1821,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			return -EINVAL;
 	}
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		for (c = 0; c < mode->num_channels; c++) {
 			struct ieee80211_channel *chan = &mode->channels[c];
 			if (chan->flag & IEEE80211_CHAN_W_SCAN &&
@@ -2166,10 +2164,10 @@ static int ieee80211_ioctl_giwretry(stru
 
 static void ieee80211_ioctl_unmask_channels(struct ieee80211_local *local)
 {
-	int m, c;
+	struct ieee80211_hw_mode *mode;
+	int c;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		for (c = 0; c < mode->num_channels; c++) {
 			struct ieee80211_channel *chan = &mode->channels[c];
 			chan->flag |= IEEE80211_CHAN_W_SCAN;
Index: bu3sch-wireless-dev/net/d80211/ieee80211_scan.c
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211_scan.c	2006-12-13 
19:40:05.000000000 +0100
@@ -24,49 +24,49 @@
 #define SCAN_TXRX_THRESHOLD 75
 
 static void get_channel_params(struct ieee80211_local *local, int channel,
-				struct ieee80211_hw_modes **mode,
+				struct ieee80211_hw_mode **mode,
 				struct ieee80211_channel **chan)
 {
-	int m;
+	struct ieee80211_hw_mode *m;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		*mode = &local->hw.modes[m];
-		if ((*mode)->mode == local->hw.conf.phymode)
+	list_for_each_entry(m, &local->modes_list, list) {
+		*mode = m;
+		if (m->mode == local->hw.conf.phymode)
 			break;
 	}
-	local->scan.mode_idx = m;
+	local->scan.mode = m;
 	local->scan.chan_idx = 0;
 	do {
-		*chan = &(*mode)->channels[local->scan.chan_idx];
-		if ((*chan)->chan == channel) {
+		*chan = &m->channels[local->scan.chan_idx];
+		if ((*chan)->chan == channel)
 			return;
-		}
 		local->scan.chan_idx++;
-	} while (local->scan.chan_idx < (*mode)->num_channels);
+	} while (local->scan.chan_idx < m->num_channels);
 	*chan = NULL;
 }
 
 
 static void next_chan_same_mode(struct ieee80211_local *local,
-				struct ieee80211_hw_modes **mode,
+				struct ieee80211_hw_mode **mode,
 				struct ieee80211_channel **chan)
 {
-	int m, prev;
+	struct ieee80211_hw_mode *m;
+	int prev;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		*mode = &local->hw.modes[m];
-		if ((*mode)->mode == local->hw.conf.phymode)
+	list_for_each_entry(m, &local->modes_list, list) {
+		*mode = m;
+		if (m->mode == local->hw.conf.phymode)
 			break;
 	}
-	local->scan.mode_idx = m;
+	local->scan.mode = m;
 
 	/* Select next channel - scan only channels marked with W_SCAN flag */
 	prev = local->scan.chan_idx;
 	do {
 		local->scan.chan_idx++;
-		if (local->scan.chan_idx >= (*mode)->num_channels)
+		if (local->scan.chan_idx >= m->num_channels)
 			local->scan.chan_idx = 0;
-		*chan = &(*mode)->channels[local->scan.chan_idx];
+		*chan = &m->channels[local->scan.chan_idx];
 		if ((*chan)->flag & IEEE80211_CHAN_W_SCAN)
 			break;
 	} while (local->scan.chan_idx != prev);
@@ -74,43 +74,44 @@ static void next_chan_same_mode(struct i
 
 
 static void next_chan_all_modes(struct ieee80211_local *local,
-				struct ieee80211_hw_modes **mode,
+				struct ieee80211_hw_mode **mode,
 				struct ieee80211_channel **chan)
 {
-	int prev, prev_m;
-
-	if (local->scan.mode_idx >= local->hw.num_modes) {
-		local->scan.mode_idx = 0;
-		local->scan.chan_idx = 0;
-	}
+	struct ieee80211_hw_mode *prev_m;
+	int prev;
 
 	/* Select next channel - scan only channels marked with W_SCAN flag */
 	prev = local->scan.chan_idx;
-	prev_m = local->scan.mode_idx;
+	prev_m = local->scan.mode;
 	do {
-		*mode = &local->hw.modes[local->scan.mode_idx];
+		*mode = local->scan.mode;
 		local->scan.chan_idx++;
 		if (local->scan.chan_idx >= (*mode)->num_channels) {
+			struct list_head *next;
+
 			local->scan.chan_idx = 0;
-			local->scan.mode_idx++;
-			if (local->scan.mode_idx >= local->hw.num_modes)
-				local->scan.mode_idx = 0;
-			*mode = &local->hw.modes[local->scan.mode_idx];
+			next = (*mode)->list.next;
+			if (next == &local->modes_list)
+				next = next->next;
+			*mode = list_entry(next,
+					   struct ieee80211_hw_mode,
+					   list);
+			local->scan.mode = *mode;
 		}
 		*chan = &(*mode)->channels[local->scan.chan_idx];
 		if ((*chan)->flag & IEEE80211_CHAN_W_SCAN)
 			break;
 	} while (local->scan.chan_idx != prev ||
-		 local->scan.mode_idx != prev_m);
+		 local->scan.mode != prev_m);
 }
 
 
 static void ieee80211_scan_start(struct ieee80211_local *local,
 				 struct ieee80211_scan_conf *conf)
 {
-	int old_mode_idx = local->scan.mode_idx;
+	struct ieee80211_hw_mode *old_mode = local->scan.mode;
 	int old_chan_idx = local->scan.chan_idx;
-	struct ieee80211_hw_modes *mode = NULL;
+	struct ieee80211_hw_mode *mode = NULL;
 	struct ieee80211_channel *chan = NULL;
 	int ret;
 
@@ -189,7 +190,7 @@ static void ieee80211_scan_start(struct 
 		if (ret == -EAGAIN) {
 			local->scan.timer.expires = jiffies +
 				(local->scan.interval * HZ / 100);
-			local->scan.mode_idx = old_mode_idx;
+			local->scan.mode = old_mode;
 			local->scan.chan_idx = old_chan_idx;
 		} else {
 			printk(KERN_DEBUG "%s: Got unknown error from "
@@ -207,23 +208,17 @@ static void ieee80211_scan_start(struct 
 static void ieee80211_scan_stop(struct ieee80211_local *local,
 				struct ieee80211_scan_conf *conf)
 {
-	struct ieee80211_hw_modes *mode;
+	struct ieee80211_hw_mode *mode;
 	struct ieee80211_channel *chan;
 	int wait;
 
 	if (!local->ops->passive_scan)
 		return;
 
-	if (local->scan.mode_idx >= local->hw.num_modes) {
-		local->scan.mode_idx = 0;
-		local->scan.chan_idx = 0;
-	}
+	mode = local->scan.mode;
 
-	mode = &local->hw.modes[local->scan.mode_idx];
-
-	if (local->scan.chan_idx >= mode->num_channels) {
+	if (local->scan.chan_idx >= mode->num_channels)
 		local->scan.chan_idx = 0;
-	}
 
 	chan = &mode->channels[local->scan.chan_idx];
 
Index: bu3sch-wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211_sta.c	2006-12-13 
19:40:05.000000000 +0100
@@ -1380,6 +1380,7 @@ static void ieee80211_rx_bss_info(struct
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && elems.supp_rates &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0 &&
 	    (sta = sta_info_get(local, mgmt->sa))) {
+	    	struct ieee80211_hw_mode *mode;
 		struct ieee80211_rate *rates;
 		size_t num_rates;
 		u32 supp_rates, prev_rates;
@@ -1389,8 +1390,7 @@ static void ieee80211_rx_bss_info(struct
 		num_rates = local->num_curr_rates;
 		oper_mode = local->sta_scanning ? local->scan_oper_phymode :
 			local->hw.conf.phymode;
-		for (i = 0; i < local->hw.num_modes; i++) {
-			struct ieee80211_hw_modes *mode = &local->hw.modes[i];
+		list_for_each_entry(mode, &local->modes_list, list) {
 			if (oper_mode == mode->mode) {
 				rates = mode->rates;
 				num_rates = mode->num_rates;
@@ -1924,10 +1924,10 @@ static void ieee80211_sta_new_auth(struc
 
 static int ieee80211_ibss_allowed(struct ieee80211_local *local)
 {
-	int m, c;
+	struct ieee80211_hw_mode *mode;
+	int c;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		if (mode->mode != local->hw.conf.phymode)
 			continue;
 		for (c = 0; c < mode->num_channels; c++) {
@@ -2383,10 +2383,10 @@ static int ieee80211_sta_restore_oper_ch
 
 static int ieee80211_active_scan(struct ieee80211_local *local)
 {
-	int m, c;
+	struct ieee80211_hw_mode *mode;
+	int c;
 
-	for (m = 0; m < local->hw.num_modes; m++) {
-		struct ieee80211_hw_modes *mode = &local->hw.modes[m];
+	list_for_each_entry(mode, &local->modes_list, list) {
 		if (mode->mode != local->hw.conf.phymode)
 			continue;
 		for (c = 0; c < mode->num_channels; c++) {
@@ -2433,7 +2433,7 @@ static void ieee80211_sta_scan_work(void
 	struct net_device *dev = ptr;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	struct ieee80211_hw_modes *mode;
+	struct ieee80211_hw_mode *mode;
 	struct ieee80211_channel *chan;
 	int skip;
 	unsigned long next_delay = 0;
@@ -2443,10 +2443,9 @@ static void ieee80211_sta_scan_work(void
 
 	switch (local->scan_state) {
 	case SCAN_SET_CHANNEL:
-		mode = &local->hw.modes[local->scan_hw_mode_idx];
-		if (local->scan_hw_mode_idx >= local->hw.num_modes ||
-		    (local->scan_hw_mode_idx + 1 == local->hw.num_modes &&
-		     local->scan_channel_idx >= mode->num_channels)) {
+		mode = local->scan_hw_mode;
+		if (local->scan_hw_mode->list.next == &local->modes_list &&
+		    local->scan_channel_idx >= mode->num_channels) {
 			if (ieee80211_sta_restore_oper_chan(dev)) {
 				printk(KERN_DEBUG "%s: failed to restore "
 				       "operational channel after scan\n",
@@ -2486,10 +2485,13 @@ static void ieee80211_sta_scan_work(void
 		}
 
 		local->scan_channel_idx++;
-		if (local->scan_channel_idx >=
-		    local->hw.modes[local->scan_hw_mode_idx].num_channels) {
-			local->scan_hw_mode_idx++;
-			local->scan_channel_idx = 0;
+		if (local->scan_channel_idx >= local->scan_hw_mode->num_channels) {
+			if (local->scan_hw_mode->list.next != &local->modes_list) {
+				local->scan_hw_mode = list_entry(local->scan_hw_mode->list.next,
+								 struct ieee80211_hw_mode,
+								 list);
+				local->scan_channel_idx = 0;
+			}
 		}
 
 		if (skip)
@@ -2575,7 +2577,9 @@ int ieee80211_sta_req_scan(struct net_de
 	} else
 		local->scan_ssid_len = 0;
 	local->scan_state = SCAN_SET_CHANNEL;
-	local->scan_hw_mode_idx = 0;
+	local->scan_hw_mode = list_entry(local->modes_list.next,
+					 struct ieee80211_hw_mode,
+					 list);
 	local->scan_channel_idx = 0;
 	INIT_WORK(&local->scan_work, ieee80211_sta_scan_work, dev);
 	schedule_work(&local->scan_work);
Index: bu3sch-wireless-dev/net/d80211/ieee80211_sysfs.c
===================================================================
--- bu3sch-wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-12-05 
18:09:35.000000000 +0100
+++ bu3sch-wireless-dev/net/d80211/ieee80211_sysfs.c	2006-12-13 
19:40:05.000000000 +0100
@@ -189,15 +189,13 @@ __IEEE80211_LOCAL_SHOW(tx_power_reductio
 static ssize_t ieee80211_local_fmt_modes(struct ieee80211_local *local,
 					 char *buf)
 {
-	int i;
-	struct ieee80211_hw_modes *mode;
+	struct ieee80211_hw_mode *mode;
 	char *p = buf;
 
-	/* FIXME: locking against ieee80211_update_hw? */
-	for (i = 0; i < local->hw.num_modes; i++) {
-		mode = &local->hw.modes[i];
+	/* FIXME: Locking? Could register a mode in the meantime. */
+	list_for_each_entry(mode, &local->modes_list, list)
 		p += sprintf(p, "%s\n", ieee80211_mode_str_short(mode->mode));
-	}
+
 	return (p - buf);
 }
 __IEEE80211_LOCAL_SHOW(modes);
