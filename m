From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-03-12
Date: Fri, 12 Mar 2010 15:28:48 -0500
Message-ID: <20100312202848.GC17689@tuxdriver.com>
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

Here is a round of fixes intended for 2.6.34.  I don't think there is
anything controversial here -- they are all reasonably small, targeted,
and are fixes to real problems.  I believe they are all well represented
by their changelog entries as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 717ea4b3474852057b1ce2c639ce219f4f8d3a8d:
  Greg Ungerer (1):
        net: add ColdFire support to the smc91x driver

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bruno Randolf (4):
      ath5k: use fixed antenna for tx descriptors
      ath5k: fix TSF reset
      ath5k: fix I/Q calibration (for real)
      ath5k: read eeprom IQ calibration values correctly for G mode

Eric Dumazet (1):
      mac80211: Fix memory leak in ieee80211_if_write()

Helmut Schaa (1):
      rt2x00: remove KSEG1ADDR define from rt2x00soc.h

John W. Linville (1):
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6

Jouni Malinen (1):
      mac80211: Fix sta_mtx unlocking on insert STA failure path

Juuso Oikarinen (1):
      mac80211: Fix (dynamic) power save entry

Reinette Chatre (2):
      iwl3945: fix memory corruption
      Revert "iwlwifi: Send broadcast probe request only when asked to"

Zhu Yi (2):
      libipw: split ieee->networks into small pieces
      ipw2200: use kmalloc for large local variables

 drivers/net/wireless/ath/ath5k/eeprom.c      |    4 +-
 drivers/net/wireless/ath/ath5k/phy.c         |   41 +++++++++++----------
 drivers/net/wireless/ath/ath5k/reg.h         |    1 +
 drivers/net/wireless/ath/ath5k/reset.c       |   22 ++++++-----
 drivers/net/wireless/ipw2x00/ipw2200.c       |   19 +++++++++-
 drivers/net/wireless/ipw2x00/libipw.h        |    2 +-
 drivers/net/wireless/ipw2x00/libipw_module.c |   37 +++++++++----------
 drivers/net/wireless/iwlwifi/iwl-3945.c      |    6 ++--
 drivers/net/wireless/iwlwifi/iwl-agn.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c      |   49 ++++++++-----------------
 drivers/net/wireless/rt2x00/rt2x00soc.h      |    2 -
 net/mac80211/debugfs_netdev.c                |   10 ++++--
 net/mac80211/mlme.c                          |   13 ++++---
 net/mac80211/sta_info.c                      |    1 +
 14 files changed, 107 insertions(+), 102 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 6a3f4da..10b5226 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -429,8 +429,8 @@ static int ath5k_eeprom_read_modes(struct ath5k_hw *ah, u32 *offset,
 			ee->ee_margin_tx_rx[mode] = (val >> 8) & 0x3f;
 
 		AR5K_EEPROM_READ(o++, val);
-		ee->ee_i_cal[mode] = (val >> 8) & 0x3f;
-		ee->ee_q_cal[mode] = (val >> 3) & 0x1f;
+		ee->ee_i_cal[mode] = (val >> 5) & 0x3f;
+		ee->ee_q_cal[mode] = val & 0x1f;
 
 		if (ah->ah_ee_version >= AR5K_EEPROM_VERSION_4_2) {
 			AR5K_EEPROM_READ(o++, val);
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 72474c0..eff3323 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -1386,38 +1386,39 @@ static int ath5k_hw_rf511x_calibrate(struct ath5k_hw *ah,
 		goto done;
 
 	/* Calibration has finished, get the results and re-run */
+
+	/* work around empty results which can apparently happen on 5212 */
 	for (i = 0; i <= 10; i++) {
 		iq_corr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_CORR);
 		i_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_I);
 		q_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_Q);
+		ATH5K_DBG_UNLIMIT(ah->ah_sc, ATH5K_DEBUG_CALIBRATE,
+			"iq_corr:%x i_pwr:%x q_pwr:%x", iq_corr, i_pwr, q_pwr);
+		if (i_pwr && q_pwr)
+			break;
 	}
 
 	i_coffd = ((i_pwr >> 1) + (q_pwr >> 1)) >> 7;
 	q_coffd = q_pwr >> 7;
 
-	/* No correction */
-	if (i_coffd == 0 || q_coffd == 0)
+	/* protect against divide by 0 and loss of sign bits */
+	if (i_coffd == 0 || q_coffd < 2)
 		goto done;
 
-	i_coff = ((-iq_corr) / i_coffd);
-
-	/* Boundary check */
-	if (i_coff > 31)
-		i_coff = 31;
-	if (i_coff < -32)
-		i_coff = -32;
+	i_coff = (-iq_corr) / i_coffd;
+	i_coff = clamp(i_coff, -32, 31); /* signed 6 bit */
 
-	q_coff = (((s32)i_pwr / q_coffd) - 128);
+	q_coff = (i_pwr / q_coffd) - 128;
+	q_coff = clamp(q_coff, -16, 15); /* signed 5 bit */
 
-	/* Boundary check */
-	if (q_coff > 15)
-		q_coff = 15;
-	if (q_coff < -16)
-		q_coff = -16;
+	ATH5K_DBG_UNLIMIT(ah->ah_sc, ATH5K_DEBUG_CALIBRATE,
+			"new I:%d Q:%d (i_coffd:%x q_coffd:%x)",
+			i_coff, q_coff, i_coffd, q_coffd);
 
-	/* Commit new I/Q value */
-	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_ENABLE |
-		((u32)q_coff) | ((u32)i_coff << AR5K_PHY_IQ_CORR_Q_I_COFF_S));
+	/* Commit new I/Q values (set enable bit last to match HAL sources) */
+	AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_Q_I_COFF, i_coff);
+	AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_Q_Q_COFF, q_coff);
+	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_ENABLE);
 
 	/* Re-enable calibration -if we don't we'll commit
 	 * the same values again and again */
@@ -1873,7 +1874,7 @@ ath5k_hw_set_antenna_mode(struct ath5k_hw *ah, u8 ant_mode)
 		break;
 	case AR5K_ANTMODE_FIXED_A:
 		def_ant = 1;
-		tx_ant = 0;
+		tx_ant = 1;
 		use_def_for_tx = true;
 		update_def_on_tx = false;
 		use_def_for_rts = true;
@@ -1882,7 +1883,7 @@ ath5k_hw_set_antenna_mode(struct ath5k_hw *ah, u8 ant_mode)
 		break;
 	case AR5K_ANTMODE_FIXED_B:
 		def_ant = 2;
-		tx_ant = 0;
+		tx_ant = 2;
 		use_def_for_tx = true;
 		update_def_on_tx = false;
 		use_def_for_rts = true;
diff --git a/drivers/net/wireless/ath/ath5k/reg.h b/drivers/net/wireless/ath/ath5k/reg.h
index 4cb9c5d..1464f89 100644
--- a/drivers/net/wireless/ath/ath5k/reg.h
+++ b/drivers/net/wireless/ath/ath5k/reg.h
@@ -2187,6 +2187,7 @@
  */
 #define	AR5K_PHY_IQ			0x9920			/* Register Address */
 #define	AR5K_PHY_IQ_CORR_Q_Q_COFF	0x0000001f	/* Mask for q correction info */
+#define	AR5K_PHY_IQ_CORR_Q_Q_COFF_S	0
 #define	AR5K_PHY_IQ_CORR_Q_I_COFF	0x000007e0	/* Mask for i correction info */
 #define	AR5K_PHY_IQ_CORR_Q_I_COFF_S	5
 #define	AR5K_PHY_IQ_CORR_ENABLE		0x00000800	/* Enable i/q correction */
diff --git a/drivers/net/wireless/ath/ath5k/reset.c b/drivers/net/wireless/ath/ath5k/reset.c
index a35a7db..cbf28e3 100644
--- a/drivers/net/wireless/ath/ath5k/reset.c
+++ b/drivers/net/wireless/ath/ath5k/reset.c
@@ -851,12 +851,15 @@ static void ath5k_hw_commit_eeprom_settings(struct ath5k_hw *ah,
 				AR5K_PHY_OFDM_SELFCORR_CYPWR_THR1,
 				AR5K_INIT_CYCRSSI_THR1);
 
-	/* I/Q correction
-	 * TODO: Per channel i/q infos ? */
-	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ,
-		AR5K_PHY_IQ_CORR_ENABLE |
-		(ee->ee_i_cal[ee_mode] << AR5K_PHY_IQ_CORR_Q_I_COFF_S) |
-		ee->ee_q_cal[ee_mode]);
+	/* I/Q correction (set enable bit last to match HAL sources) */
+	/* TODO: Per channel i/q infos ? */
+	if (ah->ah_ee_version >= AR5K_EEPROM_VERSION_4_0) {
+		AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_Q_I_COFF,
+			    ee->ee_i_cal[ee_mode]);
+		AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_Q_Q_COFF,
+			    ee->ee_q_cal[ee_mode]);
+		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_ENABLE);
+	}
 
 	/* Heavy clipping -disable for now */
 	if (ah->ah_ee_version >= AR5K_EEPROM_VERSION_5_1)
@@ -1379,11 +1382,10 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum nl80211_iftype op_mode,
 		ath5k_hw_set_sleep_clock(ah, true);
 
 	/*
-	 * Disable beacons and reset the register
+	 * Disable beacons and reset the TSF
 	 */
-	AR5K_REG_DISABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE |
-			AR5K_BEACON_RESET_TSF);
-
+	AR5K_REG_DISABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE);
+	ath5k_hw_reset_tsf(ah);
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 63c2a7a..5c7aa1b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3177,14 +3177,27 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 	int total_nr = 0;
 	int i;
 	struct pci_pool *pool;
-	u32 *virts[CB_NUMBER_OF_ELEMENTS_SMALL];
-	dma_addr_t phys[CB_NUMBER_OF_ELEMENTS_SMALL];
+	void **virts;
+	dma_addr_t *phys;
 
 	IPW_DEBUG_TRACE("<< : \n");
 
+	virts = kmalloc(sizeof(void *) * CB_NUMBER_OF_ELEMENTS_SMALL,
+			GFP_KERNEL);
+	if (!virts)
+		return -ENOMEM;
+
+	phys = kmalloc(sizeof(dma_addr_t) * CB_NUMBER_OF_ELEMENTS_SMALL,
+			GFP_KERNEL);
+	if (!phys) {
+		kfree(virts);
+		return -ENOMEM;
+	}
 	pool = pci_pool_create("ipw2200", priv->pci_dev, CB_MAX_LENGTH, 0, 0);
 	if (!pool) {
 		IPW_ERROR("pci_pool_create failed\n");
+		kfree(phys);
+		kfree(virts);
 		return -ENOMEM;
 	}
 
@@ -3254,6 +3267,8 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 		pci_pool_free(pool, virts[i], phys[i]);
 
 	pci_pool_destroy(pool);
+	kfree(phys);
+	kfree(virts);
 
 	return ret;
 }
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index bf45391..a6d5e42 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -797,7 +797,7 @@ struct libipw_device {
 	/* Probe / Beacon management */
 	struct list_head network_free_list;
 	struct list_head network_list;
-	struct libipw_network *networks;
+	struct libipw_network *networks[MAX_NETWORK_COUNT];
 	int scans;
 	int scan_age;
 
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index 1ae0b2b..2fa5586 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -67,16 +67,17 @@ void *libipw_wiphy_privid = &libipw_wiphy_privid;
 
 static int libipw_networks_allocate(struct libipw_device *ieee)
 {
-	if (ieee->networks)
-		return 0;
-
-	ieee->networks =
-	    kzalloc(MAX_NETWORK_COUNT * sizeof(struct libipw_network),
-		    GFP_KERNEL);
-	if (!ieee->networks) {
-		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
-		       ieee->dev->name);
-		return -ENOMEM;
+	int i, j;
+
+	for (i = 0; i < MAX_NETWORK_COUNT; i++) {
+		ieee->networks[i] = kzalloc(sizeof(struct libipw_network),
+					    GFP_KERNEL);
+		if (!ieee->networks[i]) {
+			LIBIPW_ERROR("Out of memory allocating beacons\n");
+			for (j = 0; j < i; j++)
+				kfree(ieee->networks[j]);
+			return -ENOMEM;
+		}
 	}
 
 	return 0;
@@ -97,15 +98,11 @@ static inline void libipw_networks_free(struct libipw_device *ieee)
 {
 	int i;
 
-	if (!ieee->networks)
-		return;
-
-	for (i = 0; i < MAX_NETWORK_COUNT; i++)
-		if (ieee->networks[i].ibss_dfs)
-			kfree(ieee->networks[i].ibss_dfs);
-
-	kfree(ieee->networks);
-	ieee->networks = NULL;
+	for (i = 0; i < MAX_NETWORK_COUNT; i++) {
+		if (ieee->networks[i]->ibss_dfs)
+			kfree(ieee->networks[i]->ibss_dfs);
+		kfree(ieee->networks[i]);
+	}
 }
 
 void libipw_networks_age(struct libipw_device *ieee,
@@ -130,7 +127,7 @@ static void libipw_networks_initialize(struct libipw_device *ieee)
 	INIT_LIST_HEAD(&ieee->network_free_list);
 	INIT_LIST_HEAD(&ieee->network_list);
 	for (i = 0; i < MAX_NETWORK_COUNT; i++)
-		list_add_tail(&ieee->networks[i].list,
+		list_add_tail(&ieee->networks[i]->list,
 			      &ieee->network_free_list);
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 303cc81..e0678d9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -184,7 +184,7 @@ static int iwl3945_hwrate_to_plcp_idx(u8 plcp)
 {
 	int idx;
 
-	for (idx = 0; idx < IWL_RATE_COUNT; idx++)
+	for (idx = 0; idx < IWL_RATE_COUNT_3945; idx++)
 		if (iwl3945_rates[idx].plcp == plcp)
 			return idx;
 	return -1;
@@ -805,7 +805,7 @@ void iwl3945_hw_build_tx_cmd_rate(struct iwl_priv *priv,
 				  int sta_id, int tx_id)
 {
 	u16 hw_value = ieee80211_get_tx_rate(priv->hw, info)->hw_value;
-	u16 rate_index = min(hw_value & 0xffff, IWL_RATE_COUNT - 1);
+	u16 rate_index = min(hw_value & 0xffff, IWL_RATE_COUNT_3945);
 	u16 rate_mask;
 	int rate;
 	u8 rts_retry_limit;
@@ -2146,7 +2146,7 @@ static void iwl3945_hw_reg_init_channel_groups(struct iwl_priv *priv)
 
 		/* fill in channel group's nominal powers for each rate */
 		for (rate_index = 0;
-		     rate_index < IWL_RATE_COUNT; rate_index++, clip_pwrs++) {
+		     rate_index < IWL_RATE_COUNT_3945; rate_index++, clip_pwrs++) {
 			switch (rate_index) {
 			case IWL_RATE_36M_INDEX_TABLE:
 				if (i == 0)	/* B/G */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 47b0214..818367b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2653,7 +2653,7 @@ static int iwl_mac_setup_register(struct iwl_priv *priv)
 	 */
 	hw->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
 
-	hw->wiphy->max_scan_ssids = PROBE_OPTION_MAX + 1;
+	hw->wiphy->max_scan_ssids = PROBE_OPTION_MAX;
 	/* we create the 802.11 header and a zero-length SSID element */
 	hw->wiphy->max_scan_ie_len = IWL_MAX_PROBE_REQUEST - 24 - 2;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index dd9ff2e..bd2f7c4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -638,20 +638,9 @@ u16 iwl_fill_probe_req(struct iwl_priv *priv, struct ieee80211_mgmt *frame,
 	if (left < 0)
 		return 0;
 	*pos++ = WLAN_EID_SSID;
-	if (!priv->is_internal_short_scan &&
-	    priv->scan_request->n_ssids) {
-		struct cfg80211_ssid *ssid =
-			priv->scan_request->ssids;
-
-		/* Broadcast if ssid_len is 0 */
-		*pos++ = ssid->ssid_len;
-		memcpy(pos, ssid->ssid, ssid->ssid_len);
-		pos += ssid->ssid_len;
-		len += 2 + ssid->ssid_len;
-	} else {
-		*pos++ = 0;
-		len += 2;
-	}
+	*pos++ = 0;
+
+	len += 2;
 
 	if (WARN_ON(left < ie_len))
 		return len;
@@ -780,26 +769,20 @@ static void iwl_bg_request_scan(struct work_struct *data)
 	if (priv->is_internal_short_scan) {
 		IWL_DEBUG_SCAN(priv, "Start internal passive scan.\n");
 	} else if (priv->scan_request->n_ssids) {
+		int i, p = 0;
 		IWL_DEBUG_SCAN(priv, "Kicking off active scan\n");
-		/*
-		 * The first SSID to scan is stuffed into the probe request
-		 * template and the remaining ones are handled through the
-		 * direct_scan array.
-		 */
-		if (priv->scan_request->n_ssids > 1) {
-			int i, p = 0;
-			for (i = 1; i < priv->scan_request->n_ssids; i++) {
-				if (!priv->scan_request->ssids[i].ssid_len)
-					continue;
-				scan->direct_scan[p].id = WLAN_EID_SSID;
-				scan->direct_scan[p].len =
-					priv->scan_request->ssids[i].ssid_len;
-				memcpy(scan->direct_scan[p].ssid,
-				       priv->scan_request->ssids[i].ssid,
-				       priv->scan_request->ssids[i].ssid_len);
-				n_probes++;
-				p++;
-			}
+		for (i = 0; i < priv->scan_request->n_ssids; i++) {
+			/* always does wildcard anyway */
+			if (!priv->scan_request->ssids[i].ssid_len)
+				continue;
+			scan->direct_scan[p].id = WLAN_EID_SSID;
+			scan->direct_scan[p].len =
+				priv->scan_request->ssids[i].ssid_len;
+			memcpy(scan->direct_scan[p].ssid,
+			       priv->scan_request->ssids[i].ssid,
+			       priv->scan_request->ssids[i].ssid_len);
+			n_probes++;
+			p++;
 		}
 		is_active = true;
 	} else
diff --git a/drivers/net/wireless/rt2x00/rt2x00soc.h b/drivers/net/wireless/rt2x00/rt2x00soc.h
index 4739edf..474cbfc 100644
--- a/drivers/net/wireless/rt2x00/rt2x00soc.h
+++ b/drivers/net/wireless/rt2x00/rt2x00soc.h
@@ -26,8 +26,6 @@
 #ifndef RT2X00SOC_H
 #define RT2X00SOC_H
 
-#define KSEG1ADDR(__ptr) __ptr
-
 /*
  * SoC driver handlers.
  */
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 9affe2c..b4ddb2f 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -48,20 +48,24 @@ static ssize_t ieee80211_if_write(
 	ssize_t (*write)(struct ieee80211_sub_if_data *, const char *, int))
 {
 	u8 *buf;
-	ssize_t ret = -ENODEV;
+	ssize_t ret;
 
-	buf = kzalloc(count, GFP_KERNEL);
+	buf = kmalloc(count, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
+	ret = -EFAULT;
 	if (copy_from_user(buf, userbuf, count))
-		return -EFAULT;
+		goto freebuf;
 
+	ret = -ENODEV;
 	rtnl_lock();
 	if (sdata->dev->reg_state == NETREG_REGISTERED)
 		ret = (*write)(sdata, buf, count);
 	rtnl_unlock();
 
+freebuf:
+	kfree(buf);
 	return ret;
 }
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 0ab284c..be5f723 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -436,10 +436,12 @@ static void ieee80211_enable_ps(struct ieee80211_local *local,
 		if (local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK)
 			ieee80211_send_nullfunc(local, sdata, 1);
 
-		if (!(local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)) {
-			conf->flags |= IEEE80211_CONF_PS;
-			ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_PS);
-		}
+		if ((local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK) &&
+		    (local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS))
+			return;
+
+		conf->flags |= IEEE80211_CONF_PS;
+		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_PS);
 	}
 }
 
@@ -558,7 +560,8 @@ void ieee80211_dynamic_ps_enable_work(struct work_struct *work)
 	    (!(ifmgd->flags & IEEE80211_STA_NULLFUNC_ACKED)))
 		ieee80211_send_nullfunc(local, sdata, 1);
 
-	if (!(local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS) ||
+	if (!((local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS) &&
+	      (local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK)) ||
 	    (ifmgd->flags & IEEE80211_STA_NULLFUNC_ACKED)) {
 		ifmgd->flags &= ~IEEE80211_STA_NULLFUNC_ACKED;
 		local->hw.conf.flags |= IEEE80211_CONF_PS;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 211c475..56422d8 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -434,6 +434,7 @@ int sta_info_insert_rcu(struct sta_info *sta) __acquires(RCU)
 	/* check if STA exists already */
 	if (sta_info_get_bss(sdata, sta->sta.addr)) {
 		spin_unlock_irqrestore(&local->sta_lock, flags);
+		mutex_unlock(&local->sta_mtx);
 		rcu_read_lock();
 		err = -EEXIST;
 		goto out_free;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
