From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2011-01-12
Date: Wed, 12 Jan 2011 13:37:54 -0500
Message-ID: <20110112183754.GC8674@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

This is an initial batch of wireless fixes intended for 2.6.38-rc1.
Highlights include a number of small ath9k fixes, some documentation
fixes from Johannes, and an ssb fix that stops loading b44 inadvertently
when certain b43 devices are present.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5b919f833d9d60588d026ad82d17f17e8872c7a9:

  net: ax25: fix information leak to userland harder (2011-01-12 00:34:49 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54: fix sequence no. accounting off-by-one error

Indan Zupancic (1):
      ipw2200: Check for -1 INTA in tasklet too.

Johannes Berg (5):
      mac80211: add remain-on-channel docs
      mac80211: add missing docs for off-chan TX flag
      cfg80211: add mesh join/leave callback docs
      nl80211: add/fix mesh docs
      mac80211: add doc short section on LED triggers

Michael Buesch (1):
      ssb: Ignore dangling ethernet cores on wireless devices

Stanislaw Gruszka (1):
      hostap_cs: fix sleeping function called from invalid context

Sujith Manoharan (5):
      ath9k_hw: Fix chip test
      ath9k_hw: Fix calibration for AR9287 devices
      ath9k_hw: Fix thermal issue with UB94
      ath9k_hw: Fix RX handling for USB devices
      ath9k_htc: Really fix packet injection

 Documentation/DocBook/80211.tmpl              |   21 +++++++++++---
 drivers/net/wireless/ath/ath9k/ar9002_calib.c |    3 ++
 drivers/net/wireless/ath/ath9k/eeprom_def.c   |    4 +++
 drivers/net/wireless/ath/ath9k/htc.h          |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |   37 +++++++++++++++++-------
 drivers/net/wireless/ath/ath9k/hw.c           |    5 ++-
 drivers/net/wireless/hostap/hostap_cs.c       |   15 ++++------
 drivers/net/wireless/ipw2x00/ipw2200.c        |    7 +++++
 drivers/net/wireless/p54/txrx.c               |    2 +-
 drivers/ssb/scan.c                            |   10 +++++++
 include/linux/nl80211.h                       |   20 ++++++++++---
 include/net/cfg80211.h                        |    2 +
 include/net/mac80211.h                        |   14 +++++++++
 13 files changed, 109 insertions(+), 32 deletions(-)

diff --git a/Documentation/DocBook/80211.tmpl b/Documentation/DocBook/80211.tmpl
index 03641a0..8906648 100644
--- a/Documentation/DocBook/80211.tmpl
+++ b/Documentation/DocBook/80211.tmpl
@@ -268,10 +268,6 @@
 !Finclude/net/mac80211.h ieee80211_ops
 !Finclude/net/mac80211.h ieee80211_alloc_hw
 !Finclude/net/mac80211.h ieee80211_register_hw
-!Finclude/net/mac80211.h ieee80211_get_tx_led_name
-!Finclude/net/mac80211.h ieee80211_get_rx_led_name
-!Finclude/net/mac80211.h ieee80211_get_assoc_led_name
-!Finclude/net/mac80211.h ieee80211_get_radio_led_name
 !Finclude/net/mac80211.h ieee80211_unregister_hw
 !Finclude/net/mac80211.h ieee80211_free_hw
       </chapter>
@@ -382,6 +378,23 @@
         </para>
       </partintro>
 
+      <chapter id="led-support">
+        <title>LED support</title>
+        <para>
+         Mac80211 supports various ways of blinking LEDs. Wherever possible,
+         device LEDs should be exposed as LED class devices and hooked up to
+         the appropriate trigger, which will then be triggered appropriately
+         by mac80211.
+        </para>
+!Finclude/net/mac80211.h ieee80211_get_tx_led_name
+!Finclude/net/mac80211.h ieee80211_get_rx_led_name
+!Finclude/net/mac80211.h ieee80211_get_assoc_led_name
+!Finclude/net/mac80211.h ieee80211_get_radio_led_name
+!Finclude/net/mac80211.h ieee80211_tpt_blink
+!Finclude/net/mac80211.h ieee80211_tpt_led_trigger_flags
+!Finclude/net/mac80211.h ieee80211_create_tpt_led_trigger
+      </chapter>
+
       <chapter id="hardware-crypto-offload">
         <title>Hardware crypto acceleration</title>
 !Pinclude/net/mac80211.h Hardware crypto acceleration
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index 01880aa..ea2e7d7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -954,6 +954,9 @@ static void ar9002_hw_init_cal_settings(struct ath_hw *ah)
 				&adc_dc_cal_multi_sample;
 		}
 		ah->supp_cals = ADC_GAIN_CAL | ADC_DC_CAL | IQ_MISMATCH_CAL;
+
+		if (AR_SREV_9287(ah))
+			ah->supp_cals &= ~ADC_GAIN_CAL;
 	}
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index 088f141..749a936 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -226,6 +226,10 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 	    eep->baseEepHeader.pwdclkind == 0)
 		ah->need_an_top2_fixup = 1;
 
+	if ((common->bus_ops->ath_bus_type == ATH_USB) &&
+	    (AR_SREV_9280(ah)))
+		eep->modalHeader[0].xpaBiasLvl = 0;
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index a099b3e..1ce506f 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -433,6 +433,7 @@ void ath9k_htc_txep(void *priv, struct sk_buff *skb, enum htc_endpoint_id ep_id,
 void ath9k_htc_beaconep(void *drv_priv, struct sk_buff *skb,
 			enum htc_endpoint_id ep_id, bool txok);
 
+int ath9k_htc_update_cap_target(struct ath9k_htc_priv *priv);
 void ath9k_htc_station_work(struct work_struct *work);
 void ath9k_htc_aggr_work(struct work_struct *work);
 void ath9k_ani_work(struct work_struct *work);;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 845b4c9..f4d576b 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -301,6 +301,16 @@ static int ath9k_htc_add_monitor_interface(struct ath9k_htc_priv *priv)
 
 	priv->nstations++;
 
+	/*
+	 * Set chainmask etc. on the target.
+	 */
+	ret = ath9k_htc_update_cap_target(priv);
+	if (ret)
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Failed to update capability in target\n");
+
+	priv->ah->is_monitoring = true;
+
 	return 0;
 
 err_vif:
@@ -328,6 +338,7 @@ static int ath9k_htc_remove_monitor_interface(struct ath9k_htc_priv *priv)
 	}
 
 	priv->nstations--;
+	priv->ah->is_monitoring = false;
 
 	return 0;
 }
@@ -419,7 +430,7 @@ static int ath9k_htc_remove_station(struct ath9k_htc_priv *priv,
 	return 0;
 }
 
-static int ath9k_htc_update_cap_target(struct ath9k_htc_priv *priv)
+int ath9k_htc_update_cap_target(struct ath9k_htc_priv *priv)
 {
 	struct ath9k_htc_cap_target tcap;
 	int ret;
@@ -1186,6 +1197,20 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		}
 	}
 
+	/*
+	 * Monitor interface should be added before
+	 * IEEE80211_CONF_CHANGE_CHANNEL is handled.
+	 */
+	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
+		if (conf->flags & IEEE80211_CONF_MONITOR) {
+			if (ath9k_htc_add_monitor_interface(priv))
+				ath_err(common, "Failed to set monitor mode\n");
+			else
+				ath_dbg(common, ATH_DBG_CONFIG,
+					"HW opmode set to Monitor mode\n");
+		}
+	}
+
 	if (changed & IEEE80211_CONF_CHANGE_CHANNEL) {
 		struct ieee80211_channel *curchan = hw->conf.channel;
 		int pos = curchan->hw_value;
@@ -1221,16 +1246,6 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		ath_update_txpow(priv);
 	}
 
-	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
-		if (conf->flags & IEEE80211_CONF_MONITOR) {
-			if (ath9k_htc_add_monitor_interface(priv))
-				ath_err(common, "Failed to set monitor mode\n");
-			else
-				ath_dbg(common, ATH_DBG_CONFIG,
-					"HW opmode set to Monitor mode\n");
-		}
-	}
-
 	if (changed & IEEE80211_CONF_CHANGE_IDLE) {
 		mutex_lock(&priv->htc_pm_lock);
 		if (!priv->ps_idle) {
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index fde9786..1afb8bb 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -436,9 +436,10 @@ static int ath9k_hw_init_macaddr(struct ath_hw *ah)
 
 static int ath9k_hw_post_init(struct ath_hw *ah)
 {
+	struct ath_common *common = ath9k_hw_common(ah);
 	int ecode;
 
-	if (!AR_SREV_9271(ah)) {
+	if (common->bus_ops->ath_bus_type != ATH_USB) {
 		if (!ath9k_hw_chip_test(ah))
 			return -ENODEV;
 	}
@@ -1213,7 +1214,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	ah->txchainmask = common->tx_chainmask;
 	ah->rxchainmask = common->rx_chainmask;
 
-	if (!ah->chip_fullsleep) {
+	if ((common->bus_ops->ath_bus_type != ATH_USB) && !ah->chip_fullsleep) {
 		ath9k_hw_abortpcurecv(ah);
 		if (!ath9k_hw_stopdmarecv(ah)) {
 			ath_dbg(common, ATH_DBG_XMIT,
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index bd8a413..2176ede 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -518,22 +518,21 @@ static int prism2_config(struct pcmcia_device *link)
 	hw_priv->link = link;
 
 	/*
-	 * Make sure the IRQ handler cannot proceed until at least
-	 * dev->base_addr is initialized.
+	 * We enable IRQ here, but IRQ handler will not proceed
+	 * until dev->base_addr is set below. This protect us from
+	 * receive interrupts when driver is not initialized.
 	 */
-	spin_lock_irqsave(&local->irq_init_lock, flags);
-
 	ret = pcmcia_request_irq(link, prism2_interrupt);
 	if (ret)
-		goto failed_unlock;
+		goto failed;
 
 	ret = pcmcia_enable_device(link);
 	if (ret)
-		goto failed_unlock;
+		goto failed;
 
+	spin_lock_irqsave(&local->irq_init_lock, flags);
 	dev->irq = link->irq;
 	dev->base_addr = link->resource[0]->start;
-
 	spin_unlock_irqrestore(&local->irq_init_lock, flags);
 
 	local->shutdown = 0;
@@ -546,8 +545,6 @@ static int prism2_config(struct pcmcia_device *link)
 
 	return ret;
 
- failed_unlock:
-	spin_unlock_irqrestore(&local->irq_init_lock, flags);
  failed:
 	kfree(hw_priv);
 	prism2_release((u_long)link);
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 8d6ed5f..ae438ed 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -1973,6 +1973,13 @@ static void ipw_irq_tasklet(struct ipw_priv *priv)
 
 	inta = ipw_read32(priv, IPW_INTA_RW);
 	inta_mask = ipw_read32(priv, IPW_INTA_MASK_R);
+
+	if (inta == 0xFFFFFFFF) {
+		/* Hardware disappeared */
+		IPW_WARNING("TASKLET INTA == 0xFFFFFFFF\n");
+		/* Only handle the cached INTA values */
+		inta = 0;
+	}
 	inta &= (IPW_INTA_MASK_ALL & inta_mask);
 
 	/* Add any cached INTA values that need to be handled */
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 76b2318..f618b96 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -618,7 +618,7 @@ static void p54_tx_80211_header(struct p54_common *priv, struct sk_buff *skb,
 	else
 		*burst_possible = false;
 
-	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ)
+	if (!(info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ))
 		*flags |= P54_HDR_FLAG_DATA_OUT_SEQNR;
 
 	if (info->flags & IEEE80211_TX_CTL_PSPOLL_RESPONSE)
diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index 5a0985d..29884c0 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -420,6 +420,16 @@ int ssb_bus_scan(struct ssb_bus *bus,
 			bus->pcicore.dev = dev;
 #endif /* CONFIG_SSB_DRIVER_PCICORE */
 			break;
+		case SSB_DEV_ETHERNET:
+			if (bus->bustype == SSB_BUSTYPE_PCI) {
+				if (bus->host_pci->vendor == PCI_VENDOR_ID_BROADCOM &&
+				    (bus->host_pci->device & 0xFF00) == 0x4300) {
+					/* This is a dangling ethernet core on a
+					 * wireless device. Ignore it. */
+					continue;
+				}
+			}
+			break;
 		default:
 			break;
 		}
diff --git a/include/linux/nl80211.h b/include/linux/nl80211.h
index 2b89b71..821ffb9 100644
--- a/include/linux/nl80211.h
+++ b/include/linux/nl80211.h
@@ -148,6 +148,10 @@
  * @NL80211_CMD_SET_MPATH:  Set mesh path attributes for mesh path to
  * 	destination %NL80211_ATTR_MAC on the interface identified by
  * 	%NL80211_ATTR_IFINDEX.
+ * @NL80211_CMD_NEW_MPATH: Create a new mesh path for the destination given by
+ *	%NL80211_ATTR_MAC via %NL80211_ATTR_MPATH_NEXT_HOP.
+ * @NL80211_CMD_DEL_MPATH: Delete a mesh path to the destination given by
+ *	%NL80211_ATTR_MAC.
  * @NL80211_CMD_NEW_PATH: Add a mesh path with given attributes to the
  *	the interface identified by %NL80211_ATTR_IFINDEX.
  * @NL80211_CMD_DEL_PATH: Remove a mesh path identified by %NL80211_ATTR_MAC
@@ -612,7 +616,7 @@ enum nl80211_commands {
  *	consisting of a nested array.
  *
  * @NL80211_ATTR_MESH_ID: mesh id (1-32 bytes).
- * @NL80211_ATTR_PLINK_ACTION: action to perform on the mesh peer link.
+ * @NL80211_ATTR_STA_PLINK_ACTION: action to perform on the mesh peer link.
  * @NL80211_ATTR_MPATH_NEXT_HOP: MAC address of the next hop for a mesh path.
  * @NL80211_ATTR_MPATH_INFO: information about a mesh_path, part of mesh path
  * 	info given for %NL80211_CMD_GET_MPATH, nested attribute described at
@@ -879,7 +883,9 @@ enum nl80211_commands {
  *	See &enum nl80211_key_default_types.
  *
  * @NL80211_ATTR_MESH_SETUP: Optional mesh setup parameters.  These cannot be
- * changed once the mesh is active.
+ *	changed once the mesh is active.
+ * @NL80211_ATTR_MESH_CONFIG: Mesh configuration parameters, a nested attribute
+ *	containing attributes from &enum nl80211_meshconf_params.
  *
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
@@ -1225,8 +1231,6 @@ enum nl80211_rate_info {
  * @NL80211_STA_INFO_INACTIVE_TIME: time since last activity (u32, msecs)
  * @NL80211_STA_INFO_RX_BYTES: total received bytes (u32, from this station)
  * @NL80211_STA_INFO_TX_BYTES: total transmitted bytes (u32, to this station)
- * @__NL80211_STA_INFO_AFTER_LAST: internal
- * @NL80211_STA_INFO_MAX: highest possible station info attribute
  * @NL80211_STA_INFO_SIGNAL: signal strength of last received PPDU (u8, dBm)
  * @NL80211_STA_INFO_TX_BITRATE: current unicast tx rate, nested attribute
  * 	containing info as possible, see &enum nl80211_sta_info_txrate.
@@ -1236,6 +1240,11 @@ enum nl80211_rate_info {
  * @NL80211_STA_INFO_TX_RETRIES: total retries (u32, to this station)
  * @NL80211_STA_INFO_TX_FAILED: total failed packets (u32, to this station)
  * @NL80211_STA_INFO_SIGNAL_AVG: signal strength average (u8, dBm)
+ * @NL80211_STA_INFO_LLID: the station's mesh LLID
+ * @NL80211_STA_INFO_PLID: the station's mesh PLID
+ * @NL80211_STA_INFO_PLINK_STATE: peer link state for the station
+ * @__NL80211_STA_INFO_AFTER_LAST: internal
+ * @NL80211_STA_INFO_MAX: highest possible station info attribute
  */
 enum nl80211_sta_info {
 	__NL80211_STA_INFO_INVALID,
@@ -1626,7 +1635,7 @@ enum nl80211_mntr_flags {
  * @NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME: The interval of time (in TUs)
  * that it takes for an HWMP information element to propagate across the mesh
  *
- * @NL80211_MESHCONF_ROOTMODE: whether root mode is enabled or not
+ * @NL80211_MESHCONF_HWMP_ROOTMODE: whether root mode is enabled or not
  *
  * @NL80211_MESHCONF_ELEMENT_TTL: specifies the value of TTL field set at a
  * source mesh point for path selection elements.
@@ -1678,6 +1687,7 @@ enum nl80211_meshconf_params {
  * element that vendors will use to identify the path selection methods and
  * metrics in use.
  *
+ * @NL80211_MESH_SETUP_ATTR_MAX: highest possible mesh setup attribute number
  * @__NL80211_MESH_SETUP_ATTR_AFTER_LAST: Internal use
  */
 enum nl80211_mesh_setup_params {
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index bcc9f44..1322695 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1103,6 +1103,8 @@ struct cfg80211_pmksa {
  * @change_mpath: change a given mesh path
  * @get_mpath: get a mesh path for the given parameters
  * @dump_mpath: dump mesh path callback -- resume dump at index @idx
+ * @join_mesh: join the mesh network with the specified parameters
+ * @leave_mesh: leave the current mesh network
  *
  * @get_mesh_config: Get the current mesh configuration
  *
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5b3fd5a..62c0ce2 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -337,6 +337,10 @@ struct ieee80211_bss_conf {
  * @IEEE80211_TX_CTL_LDPC: tells the driver to use LDPC for this frame
  * @IEEE80211_TX_CTL_STBC: Enables Space-Time Block Coding (STBC) for this
  *	frame and selects the maximum number of streams that it can use.
+ * @IEEE80211_TX_CTL_TX_OFFCHAN: Marks this packet to be transmitted on
+ *	the off-channel channel when a remain-on-channel offload is done
+ *	in hardware -- normal packets still flow and are expected to be
+ *	handled properly by the device.
  *
  * Note: If you have to add new flags to the enumeration, then don't
  *	 forget to update %IEEE80211_TX_TEMPORARY_FLAGS when necessary.
@@ -1753,6 +1757,16 @@ enum ieee80211_ampdu_mlme_action {
  *	(also see nl80211.h @NL80211_ATTR_WIPHY_ANTENNA_TX).
  *
  * @get_antenna: Get current antenna configuration from device (tx_ant, rx_ant).
+ *
+ * @remain_on_channel: Starts an off-channel period on the given channel, must
+ *	call back to ieee80211_ready_on_channel() when on that channel. Note
+ *	that normal channel traffic is not stopped as this is intended for hw
+ *	offload. Frames to transmit on the off-channel channel are transmitted
+ *	normally except for the %IEEE80211_TX_CTL_TX_OFFCHAN flag. When the
+ *	duration (which will always be non-zero) expires, the driver must call
+ *	ieee80211_remain_on_channel_expired(). This callback may sleep.
+ * @cancel_remain_on_channel: Requests that an ongoing off-channel period is
+ *	aborted before it expires. This callback may sleep.
  */
 struct ieee80211_ops {
 	int (*tx)(struct ieee80211_hw *hw, struct sk_buff *skb);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
