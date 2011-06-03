From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-06-03
Date: Fri, 3 Jun 2011 15:52:54 -0400
Message-ID: <20110603195254.GF2509@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a batch of fixes intended for 3.0 -- I guess I'll need to
rename my tree eventually... :-)

Included are a libertas fix to ensure proper sequence number assignment
on transmitted frames, an ath9k fix that propogates an earlier fix to a
few more places,  a fix for a cfg80211 regression caused by some mesh
code changes, a locking fix for the bluetooth l2cap code, a zd1211rw
regression fix, a collection of small fixes for wl12xx, an iwl4965
fix for a bad temperature check, an a device ID-related fix for iwlagn.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9a2e0fb0893ddf595d0a372e681f5b98017c6d90:

  tg3: Fix tg3_skb_error_unmap() (2011-06-03 00:01:30 -0700)

are available in the git repository at:
  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git for-davem

Daniel Drake (1):
      libertas: Set command sequence number later to ensure consistency

Daniel Halperin (1):
      ath9k: fix two more bugs in tx power

Eliad Peller (1):
      cfg80211: don't drop p2p probe responses

Johannes Berg (1):
      bluetooth l2cap: fix locking in l2cap_global_chan_by_psm

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Jussi Kivilinna (1):
      zd1211rw: fix to work on OHCI

Luciano Coelho (4):
      wl12xx: fix passive and radar channel generation for scheduled scan
      wl12xx: fix DFS channels handling in scheduled scan
      wl12xx: add separate config value for DFS dwell time on sched scan
      wl12xx: fix oops in sched_scan when forcing a passive scan

Stanislaw Gruszka (1):
      iwl4965: correctly validate temperature value

Wey-Yi Guy (1):
      iwlagn: fix incorrect PCI subsystem id for 6150 devices

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   10 ++++-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   10 ++++-
 drivers/net/wireless/iwlegacy/iwl-4965.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   28 ++++++++----
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h         |    1 +
 drivers/net/wireless/libertas/cmd.c            |    6 +-
 drivers/net/wireless/wl12xx/conf.h             |    3 +
 drivers/net/wireless/wl12xx/main.c             |    1 +
 drivers/net/wireless/wl12xx/scan.c             |   49 +++++++++++++++-------
 drivers/net/wireless/wl12xx/scan.h             |    3 +
 drivers/net/wireless/zd1211rw/zd_usb.c         |   53 +++++++++++++++++++-----
 include/linux/ieee80211.h                      |    8 +++-
 net/bluetooth/l2cap_core.c                     |    2 +-
 net/wireless/scan.c                            |   43 +++++++++++--------
 15 files changed, 155 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 0ca7635..ff8150e 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -4645,10 +4645,16 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 	case 1:
 		break;
 	case 2:
-		scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_TWO_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	case 3:
-		scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_THREE_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 7856f0d..343fc9f 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -524,10 +524,16 @@ static void ath9k_hw_set_ar9287_power_per_rate_table(struct ath_hw *ah,
 	case 1:
 		break;
 	case 2:
-		scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_TWO_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	case 3:
-		scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_THREE_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	}
 	scaledPower = max((u16)0, scaledPower);
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965.c b/drivers/net/wireless/iwlegacy/iwl-4965.c
index f5433c7..f9db25b 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965.c
@@ -1543,7 +1543,7 @@ static void iwl4965_temperature_calib(struct iwl_priv *priv)
 	s32 temp;
 
 	temp = iwl4965_hw_get_temperature(priv);
-	if (temp < 0)
+	if (IWL_TX_POWER_TEMPERATURE_OUT_OF_RANGE(temp))
 		return;
 
 	if (priv->temperature != temp) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index f8c710d..fda6fe0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -603,19 +603,27 @@ struct iwl_cfg iwl6050_2abg_cfg = {
 	IWL_DEVICE_6050,
 };
 
+#define IWL_DEVICE_6150						\
+	.fw_name_pre = IWL6050_FW_PRE,				\
+	.ucode_api_max = IWL6050_UCODE_API_MAX,			\
+	.ucode_api_min = IWL6050_UCODE_API_MIN,			\
+	.ops = &iwl6150_ops,					\
+	.eeprom_ver = EEPROM_6150_EEPROM_VERSION,		\
+	.eeprom_calib_ver = EEPROM_6150_TX_POWER_VERSION,	\
+	.base_params = &iwl6050_base_params,			\
+	.need_dc_calib = true,					\
+	.led_mode = IWL_LED_BLINK,				\
+	.internal_wimax_coex = true
+
 struct iwl_cfg iwl6150_bgn_cfg = {
 	.name = "Intel(R) Centrino(R) Wireless-N + WiMAX 6150 BGN",
-	.fw_name_pre = IWL6050_FW_PRE,
-	.ucode_api_max = IWL6050_UCODE_API_MAX,
-	.ucode_api_min = IWL6050_UCODE_API_MIN,
-	.eeprom_ver = EEPROM_6150_EEPROM_VERSION,
-	.eeprom_calib_ver = EEPROM_6150_TX_POWER_VERSION,
-	.ops = &iwl6150_ops,
-	.base_params = &iwl6050_base_params,
+	IWL_DEVICE_6150,
 	.ht_params = &iwl6000_ht_params,
-	.need_dc_calib = true,
-	.led_mode = IWL_LED_RF_STATE,
-	.internal_wimax_coex = true,
+};
+
+struct iwl_cfg iwl6150_bg_cfg = {
+	.name = "Intel(R) Centrino(R) Wireless-N + WiMAX 6150 BG",
+	IWL_DEVICE_6150,
 };
 
 struct iwl_cfg iwl6000_3agn_cfg = {
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 11c6c11..a662adc 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3831,11 +3831,11 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) = {
 
 /* 6150 WiFi/WiMax Series */
 	{IWL_PCI_DEVICE(0x0885, 0x1305, iwl6150_bgn_cfg)},
-	{IWL_PCI_DEVICE(0x0885, 0x1306, iwl6150_bgn_cfg)},
+	{IWL_PCI_DEVICE(0x0885, 0x1307, iwl6150_bg_cfg)},
 	{IWL_PCI_DEVICE(0x0885, 0x1325, iwl6150_bgn_cfg)},
-	{IWL_PCI_DEVICE(0x0885, 0x1326, iwl6150_bgn_cfg)},
+	{IWL_PCI_DEVICE(0x0885, 0x1327, iwl6150_bg_cfg)},
 	{IWL_PCI_DEVICE(0x0886, 0x1315, iwl6150_bgn_cfg)},
-	{IWL_PCI_DEVICE(0x0886, 0x1316, iwl6150_bgn_cfg)},
+	{IWL_PCI_DEVICE(0x0886, 0x1317, iwl6150_bg_cfg)},
 
 /* 1000 Series WiFi */
 	{IWL_PCI_DEVICE(0x0083, 0x1205, iwl1000_bgn_cfg)},
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.h b/drivers/net/wireless/iwlwifi/iwl-agn.h
index 2495fe7..d171684 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -89,6 +89,7 @@ extern struct iwl_cfg iwl6000_3agn_cfg;
 extern struct iwl_cfg iwl6050_2agn_cfg;
 extern struct iwl_cfg iwl6050_2abg_cfg;
 extern struct iwl_cfg iwl6150_bgn_cfg;
+extern struct iwl_cfg iwl6150_bg_cfg;
 extern struct iwl_cfg iwl1000_bgn_cfg;
 extern struct iwl_cfg iwl1000_bg_cfg;
 extern struct iwl_cfg iwl100_bgn_cfg;
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 84566db..71c8f3f 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -994,6 +994,8 @@ static void lbs_submit_command(struct lbs_private *priv,
 	cmd = cmdnode->cmdbuf;
 
 	spin_lock_irqsave(&priv->driver_lock, flags);
+	priv->seqnum++;
+	cmd->seqnum = cpu_to_le16(priv->seqnum);
 	priv->cur_cmd = cmdnode;
 	spin_unlock_irqrestore(&priv->driver_lock, flags);
 
@@ -1621,11 +1623,9 @@ struct cmd_ctrl_node *__lbs_cmd_async(struct lbs_private *priv,
 	/* Copy the incoming command to the buffer */
 	memcpy(cmdnode->cmdbuf, in_cmd, in_cmd_size);
 
-	/* Set sequence number, clean result, move to buffer */
-	priv->seqnum++;
+	/* Set command, clean result, move to buffer */
 	cmdnode->cmdbuf->command = cpu_to_le16(command);
 	cmdnode->cmdbuf->size    = cpu_to_le16(in_cmd_size);
-	cmdnode->cmdbuf->seqnum  = cpu_to_le16(priv->seqnum);
 	cmdnode->cmdbuf->result  = 0;
 
 	lbs_deb_host("PREP_CMD: command 0x%04x\n", command);
diff --git a/drivers/net/wireless/wl12xx/conf.h b/drivers/net/wireless/wl12xx/conf.h
index 1ab6c86..c83fefb 100644
--- a/drivers/net/wireless/wl12xx/conf.h
+++ b/drivers/net/wireless/wl12xx/conf.h
@@ -1157,6 +1157,9 @@ struct conf_sched_scan_settings {
 	/* time to wait on the channel for passive scans (in TUs) */
 	u32 dwell_time_passive;
 
+	/* time to wait on the channel for DFS scans (in TUs) */
+	u32 dwell_time_dfs;
+
 	/* number of probe requests to send on each channel in active scans */
 	u8 num_probe_reqs;
 
diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index bc00e52..e6497dc 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -311,6 +311,7 @@ static struct conf_drv_settings default_conf = {
 		.min_dwell_time_active = 8,
 		.max_dwell_time_active = 30,
 		.dwell_time_passive    = 100,
+		.dwell_time_dfs        = 150,
 		.num_probe_reqs        = 2,
 		.rssi_threshold        = -90,
 		.snr_threshold         = 0,
diff --git a/drivers/net/wireless/wl12xx/scan.c b/drivers/net/wireless/wl12xx/scan.c
index f37e5a3..56f76ab 100644
--- a/drivers/net/wireless/wl12xx/scan.c
+++ b/drivers/net/wireless/wl12xx/scan.c
@@ -331,16 +331,22 @@ wl1271_scan_get_sched_scan_channels(struct wl1271 *wl,
 	struct conf_sched_scan_settings *c = &wl->conf.sched_scan;
 	int i, j;
 	u32 flags;
+	bool force_passive = !req->n_ssids;
 
 	for (i = 0, j = start;
 	     i < req->n_channels && j < MAX_CHANNELS_ALL_BANDS;
 	     i++) {
 		flags = req->channels[i]->flags;
 
-		if (!(flags & IEEE80211_CHAN_DISABLED) &&
-		    ((flags & IEEE80211_CHAN_PASSIVE_SCAN) == passive) &&
-		    ((flags & IEEE80211_CHAN_RADAR) == radar) &&
-		    (req->channels[i]->band == band)) {
+		if (force_passive)
+			flags |= IEEE80211_CHAN_PASSIVE_SCAN;
+
+		if ((req->channels[i]->band == band) &&
+		    !(flags & IEEE80211_CHAN_DISABLED) &&
+		    (!!(flags & IEEE80211_CHAN_RADAR) == radar) &&
+		    /* if radar is set, we ignore the passive flag */
+		    (radar ||
+		     !!(flags & IEEE80211_CHAN_PASSIVE_SCAN) == passive)) {
 			wl1271_debug(DEBUG_SCAN, "band %d, center_freq %d ",
 				     req->channels[i]->band,
 				     req->channels[i]->center_freq);
@@ -350,7 +356,12 @@ wl1271_scan_get_sched_scan_channels(struct wl1271 *wl,
 			wl1271_debug(DEBUG_SCAN, "max_power %d",
 				     req->channels[i]->max_power);
 
-			if (flags & IEEE80211_CHAN_PASSIVE_SCAN) {
+			if (flags & IEEE80211_CHAN_RADAR) {
+				channels[j].flags |= SCAN_CHANNEL_FLAGS_DFS;
+				channels[j].passive_duration =
+					cpu_to_le16(c->dwell_time_dfs);
+			}
+			else if (flags & IEEE80211_CHAN_PASSIVE_SCAN) {
 				channels[j].passive_duration =
 					cpu_to_le16(c->dwell_time_passive);
 			} else {
@@ -359,7 +370,7 @@ wl1271_scan_get_sched_scan_channels(struct wl1271 *wl,
 				channels[j].max_duration =
 					cpu_to_le16(c->max_dwell_time_active);
 			}
-			channels[j].tx_power_att = req->channels[j]->max_power;
+			channels[j].tx_power_att = req->channels[i]->max_power;
 			channels[j].channel = req->channels[i]->hw_value;
 
 			j++;
@@ -386,7 +397,11 @@ wl1271_scan_sched_scan_channels(struct wl1271 *wl,
 		wl1271_scan_get_sched_scan_channels(wl, req, cfg->channels,
 						    IEEE80211_BAND_2GHZ,
 						    false, false, idx);
-	idx += cfg->active[0];
+	/*
+	 * 5GHz channels always start at position 14, not immediately
+	 * after the last 2.4GHz channel
+	 */
+	idx = 14;
 
 	cfg->passive[1] =
 		wl1271_scan_get_sched_scan_channels(wl, req, cfg->channels,
@@ -394,22 +409,23 @@ wl1271_scan_sched_scan_channels(struct wl1271 *wl,
 						    false, true, idx);
 	idx += cfg->passive[1];
 
-	cfg->active[1] =
+	cfg->dfs =
 		wl1271_scan_get_sched_scan_channels(wl, req, cfg->channels,
 						    IEEE80211_BAND_5GHZ,
-						    false, false, 14);
-	idx += cfg->active[1];
+						    true, true, idx);
+	idx += cfg->dfs;
 
-	cfg->dfs =
+	cfg->active[1] =
 		wl1271_scan_get_sched_scan_channels(wl, req, cfg->channels,
 						    IEEE80211_BAND_5GHZ,
-						    true, false, idx);
-	idx += cfg->dfs;
+						    false, false, idx);
+	idx += cfg->active[1];
 
 	wl1271_debug(DEBUG_SCAN, "    2.4GHz: active %d passive %d",
 		     cfg->active[0], cfg->passive[0]);
 	wl1271_debug(DEBUG_SCAN, "    5GHz: active %d passive %d",
 		     cfg->active[1], cfg->passive[1]);
+	wl1271_debug(DEBUG_SCAN, "    DFS: %d", cfg->dfs);
 
 	return idx;
 }
@@ -421,6 +437,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	struct wl1271_cmd_sched_scan_config *cfg = NULL;
 	struct conf_sched_scan_settings *c = &wl->conf.sched_scan;
 	int i, total_channels, ret;
+	bool force_passive = !req->n_ssids;
 
 	wl1271_debug(DEBUG_CMD, "cmd sched_scan scan config");
 
@@ -444,7 +461,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	for (i = 0; i < SCAN_MAX_CYCLE_INTERVALS; i++)
 		cfg->intervals[i] = cpu_to_le32(req->interval);
 
-	if (req->ssids[0].ssid_len && req->ssids[0].ssid) {
+	if (!force_passive && req->ssids[0].ssid_len && req->ssids[0].ssid) {
 		cfg->filter_type = SCAN_SSID_FILTER_SPECIFIC;
 		cfg->ssid_len = req->ssids[0].ssid_len;
 		memcpy(cfg->ssid, req->ssids[0].ssid,
@@ -461,7 +478,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 		goto out;
 	}
 
-	if (cfg->active[0]) {
+	if (!force_passive && cfg->active[0]) {
 		ret = wl1271_cmd_build_probe_req(wl, req->ssids[0].ssid,
 						 req->ssids[0].ssid_len,
 						 ies->ie[IEEE80211_BAND_2GHZ],
@@ -473,7 +490,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 		}
 	}
 
-	if (cfg->active[1]) {
+	if (!force_passive && cfg->active[1]) {
 		ret = wl1271_cmd_build_probe_req(wl,  req->ssids[0].ssid,
 						 req->ssids[0].ssid_len,
 						 ies->ie[IEEE80211_BAND_5GHZ],
diff --git a/drivers/net/wireless/wl12xx/scan.h b/drivers/net/wireless/wl12xx/scan.h
index c833195..a0b6c5d 100644
--- a/drivers/net/wireless/wl12xx/scan.h
+++ b/drivers/net/wireless/wl12xx/scan.h
@@ -137,6 +137,9 @@ enum {
 	SCAN_BSS_TYPE_ANY,
 };
 
+#define SCAN_CHANNEL_FLAGS_DFS		BIT(0)
+#define SCAN_CHANNEL_FLAGS_DFS_ENABLED	BIT(1)
+
 struct conn_scan_ch_params {
 	__le16 min_duration;
 	__le16 max_duration;
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 0e81994..631194d 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1533,6 +1533,31 @@ static void __exit usb_exit(void)
 module_init(usb_init);
 module_exit(usb_exit);
 
+static int zd_ep_regs_out_msg(struct usb_device *udev, void *data, int len,
+			      int *actual_length, int timeout)
+{
+	/* In USB 2.0 mode EP_REGS_OUT endpoint is interrupt type. However in
+	 * USB 1.1 mode endpoint is bulk. Select correct type URB by endpoint
+	 * descriptor.
+	 */
+	struct usb_host_endpoint *ep;
+	unsigned int pipe;
+
+	pipe = usb_sndintpipe(udev, EP_REGS_OUT);
+	ep = usb_pipe_endpoint(udev, pipe);
+	if (!ep)
+		return -EINVAL;
+
+	if (usb_endpoint_xfer_int(&ep->desc)) {
+		return usb_interrupt_msg(udev, pipe, data, len,
+					 actual_length, timeout);
+	} else {
+		pipe = usb_sndbulkpipe(udev, EP_REGS_OUT);
+		return usb_bulk_msg(udev, pipe, data, len, actual_length,
+				    timeout);
+	}
+}
+
 static int usb_int_regs_length(unsigned int count)
 {
 	return sizeof(struct usb_int_regs) + count * sizeof(struct reg_data);
@@ -1648,15 +1673,14 @@ int zd_usb_ioread16v(struct zd_usb *usb, u16 *values,
 
 	udev = zd_usb_to_usbdev(usb);
 	prepare_read_regs_int(usb);
-	r = usb_interrupt_msg(udev, usb_sndintpipe(udev, EP_REGS_OUT),
-			      req, req_len, &actual_req_len, 50 /* ms */);
+	r = zd_ep_regs_out_msg(udev, req, req_len, &actual_req_len, 50 /*ms*/);
 	if (r) {
 		dev_dbg_f(zd_usb_dev(usb),
-			"error in usb_interrupt_msg(). Error number %d\n", r);
+			"error in zd_ep_regs_out_msg(). Error number %d\n", r);
 		goto error;
 	}
 	if (req_len != actual_req_len) {
-		dev_dbg_f(zd_usb_dev(usb), "error in usb_interrupt_msg()\n"
+		dev_dbg_f(zd_usb_dev(usb), "error in zd_ep_regs_out_msg()\n"
 			" req_len %d != actual_req_len %d\n",
 			req_len, actual_req_len);
 		r = -EIO;
@@ -1818,9 +1842,17 @@ int zd_usb_iowrite16v_async(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 		rw->value = cpu_to_le16(ioreqs[i].value);
 	}
 
-	usb_fill_int_urb(urb, udev, usb_sndintpipe(udev, EP_REGS_OUT),
-			 req, req_len, iowrite16v_urb_complete, usb,
-			 ep->desc.bInterval);
+	/* In USB 2.0 mode endpoint is interrupt type. However in USB 1.1 mode
+	 * endpoint is bulk. Select correct type URB by endpoint descriptor.
+	 */
+	if (usb_endpoint_xfer_int(&ep->desc))
+		usb_fill_int_urb(urb, udev, usb_sndintpipe(udev, EP_REGS_OUT),
+				 req, req_len, iowrite16v_urb_complete, usb,
+				 ep->desc.bInterval);
+	else
+		usb_fill_bulk_urb(urb, udev, usb_sndbulkpipe(udev, EP_REGS_OUT),
+				  req, req_len, iowrite16v_urb_complete, usb);
+
 	urb->transfer_flags |= URB_FREE_BUFFER;
 
 	/* Submit previous URB */
@@ -1924,15 +1956,14 @@ int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits)
 	}
 
 	udev = zd_usb_to_usbdev(usb);
-	r = usb_interrupt_msg(udev, usb_sndintpipe(udev, EP_REGS_OUT),
-			      req, req_len, &actual_req_len, 50 /* ms */);
+	r = zd_ep_regs_out_msg(udev, req, req_len, &actual_req_len, 50 /*ms*/);
 	if (r) {
 		dev_dbg_f(zd_usb_dev(usb),
-			"error in usb_interrupt_msg(). Error number %d\n", r);
+			"error in zd_ep_regs_out_msg(). Error number %d\n", r);
 		goto out;
 	}
 	if (req_len != actual_req_len) {
-		dev_dbg_f(zd_usb_dev(usb), "error in usb_interrupt_msg()"
+		dev_dbg_f(zd_usb_dev(usb), "error in zd_ep_regs_out_msg()"
 			" req_len %d != actual_req_len %d\n",
 			req_len, actual_req_len);
 		r = -EIO;
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index b2eee58..bf56b6f 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -1003,8 +1003,12 @@ struct ieee80211_ht_info {
 #define WLAN_CAPABILITY_ESS		(1<<0)
 #define WLAN_CAPABILITY_IBSS		(1<<1)
 
-/* A mesh STA sets the ESS and IBSS capability bits to zero */
-#define WLAN_CAPABILITY_IS_MBSS(cap)	\
+/*
+ * A mesh STA sets the ESS and IBSS capability bits to zero.
+ * however, this holds true for p2p probe responses (in the p2p_find
+ * phase) as well.
+ */
+#define WLAN_CAPABILITY_IS_STA_BSS(cap)	\
 	(!((cap) & (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS)))
 
 #define WLAN_CAPABILITY_CF_POLLABLE	(1<<2)
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a86f9ba..e64a1c2 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -906,7 +906,7 @@ static struct l2cap_chan *l2cap_global_chan_by_psm(int state, __le16 psm, bdaddr
 		if (c->psm == psm) {
 			/* Exact match. */
 			if (!bacmp(&bt_sk(sk)->src, src)) {
-				read_unlock_bh(&chan_list_lock);
+				read_unlock(&chan_list_lock);
 				return c;
 			}
 
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 73a441d..7a6c676 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -267,13 +267,35 @@ static bool is_bss(struct cfg80211_bss *a,
 	return memcmp(ssidie + 2, ssid, ssid_len) == 0;
 }
 
+static bool is_mesh_bss(struct cfg80211_bss *a)
+{
+	const u8 *ie;
+
+	if (!WLAN_CAPABILITY_IS_STA_BSS(a->capability))
+		return false;
+
+	ie = cfg80211_find_ie(WLAN_EID_MESH_ID,
+			      a->information_elements,
+			      a->len_information_elements);
+	if (!ie)
+		return false;
+
+	ie = cfg80211_find_ie(WLAN_EID_MESH_CONFIG,
+			      a->information_elements,
+			      a->len_information_elements);
+	if (!ie)
+		return false;
+
+	return true;
+}
+
 static bool is_mesh(struct cfg80211_bss *a,
 		    const u8 *meshid, size_t meshidlen,
 		    const u8 *meshcfg)
 {
 	const u8 *ie;
 
-	if (!WLAN_CAPABILITY_IS_MBSS(a->capability))
+	if (!WLAN_CAPABILITY_IS_STA_BSS(a->capability))
 		return false;
 
 	ie = cfg80211_find_ie(WLAN_EID_MESH_ID,
@@ -311,7 +333,7 @@ static int cmp_bss(struct cfg80211_bss *a,
 	if (a->channel != b->channel)
 		return b->channel->center_freq - a->channel->center_freq;
 
-	if (WLAN_CAPABILITY_IS_MBSS(a->capability | b->capability)) {
+	if (is_mesh_bss(a) && is_mesh_bss(b)) {
 		r = cmp_ies(WLAN_EID_MESH_ID,
 			    a->information_elements,
 			    a->len_information_elements,
@@ -457,7 +479,6 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 		    struct cfg80211_internal_bss *res)
 {
 	struct cfg80211_internal_bss *found = NULL;
-	const u8 *meshid, *meshcfg;
 
 	/*
 	 * The reference to "res" is donated to this function.
@@ -470,22 +491,6 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 
 	res->ts = jiffies;
 
-	if (WLAN_CAPABILITY_IS_MBSS(res->pub.capability)) {
-		/* must be mesh, verify */
-		meshid = cfg80211_find_ie(WLAN_EID_MESH_ID,
-					  res->pub.information_elements,
-					  res->pub.len_information_elements);
-		meshcfg = cfg80211_find_ie(WLAN_EID_MESH_CONFIG,
-					   res->pub.information_elements,
-					   res->pub.len_information_elements);
-		if (!meshid || !meshcfg ||
-		    meshcfg[1] != sizeof(struct ieee80211_meshconf_ie)) {
-			/* bogus mesh */
-			kref_put(&res->ref, bss_release);
-			return NULL;
-		}
-	}
-
 	spin_lock_bh(&dev->bss_lock);
 
 	found = rb_find_bss(dev, res);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
