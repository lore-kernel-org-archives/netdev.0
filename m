From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] rt2x00: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 20:42:20 +0100
Message-ID: <200612152042.21076.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47990
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbWLOTmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:42:44 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation for the d80211 hwmode API change.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-15 19:43:14.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-15 19:46:23.000000000 +0100
@@ -590,8 +590,8 @@ static void rt2400pci_config_phymode(str
 	if (rt2x00dev->rx_params.phymode == phymode)
 		return;
 
-	rate = &rt2x00dev->hw->modes[0].rates[
-		rt2x00dev->hw->modes[0].num_rates - 1];
+	rate = &rt2x00dev->hwmodes[0].rates[
+		rt2x00dev->hwmodes[0].num_rates - 1];
 
 	rt2400pci_config_rate(rt2x00dev, rate->val2);
 
@@ -1140,9 +1140,9 @@ static int rt2400pci_init_channel_time(s
 	 */
 	jiffies_start = jiffies;
 	rt2400pci_config_channel(rt2x00dev,
-		rt2x00dev->hw->modes[0].channels[0].val,
-		rt2x00dev->hw->modes[0].channels[0].chan,
-		rt2x00dev->hw->modes[0].channels[0].freq);
+		rt2x00dev->hwmodes[0].channels[0].val,
+		rt2x00dev->hwmodes[0].channels[0].chan,
+		rt2x00dev->hwmodes[0].channels[0].freq);
 	jiffies_end = jiffies;
 
 	rt2x00dev->hw->channel_change_time =
@@ -1562,7 +1562,7 @@ static void rt2400pci_rxdone(void *data)
 				size);
 
 			rt2x00dev->rx_params.rate = device_signal_to_rate(
-				&rt2x00dev->hw->modes[0],
+				&rt2x00dev->hwmodes[0],
 				rt2x00_get_field32(word2, RXD_W2_SIGNAL),
 				0);
 
@@ -2579,47 +2579,43 @@ static void rt2400pci_init_hw_rates(stru
 
 static int rt2400pci_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_hw *hw = rt2x00dev->hw;
-
 	/*
 	 * RT2400 only supports 802.11b.
 	 * Allocate memory for 14 OFDM channels and 4 CCK rates.
 	 */
-	hw->num_modes = 1;
-	hw->modes =
-		kzalloc(sizeof(struct ieee80211_hw_modes), GFP_KERNEL);
-	if (!hw->modes)
+	rt2x00dev->hwmodes =
+		kzalloc(sizeof(struct ieee80211_hw_mode), GFP_KERNEL);
+	if (!rt2x00dev->hwmodes)
 		goto exit;
 
-	hw->modes->num_channels = 14;
-	hw->modes->channels =
+	rt2x00dev->hwmodes[0].num_channels = 14;
+	rt2x00dev->hwmodes[0].channels =
 		kzalloc(sizeof(struct ieee80211_channel) * 14, GFP_KERNEL);
-	if (!hw->modes->channels)
+	if (!rt2x00dev->hwmodes[0].channels)
 		goto exit_free_modes;
 
-	hw->modes->num_rates = 4;
-	hw->modes->rates =
+	rt2x00dev->hwmodes[0].num_rates = 4;
+	rt2x00dev->hwmodes[0].rates =
 		kzalloc(sizeof(struct ieee80211_rate) * 4, GFP_KERNEL);
-	if (!hw->modes->rates)
+	if (!rt2x00dev->hwmodes[0].rates)
 		goto exit_free_channels;
 
 	/*
 	 * Initialize modes.
 	 */
-	hw->modes->mode = MODE_IEEE80211B;
+	rt2x00dev->hwmodes[0].mode = MODE_IEEE80211B;
 
-	rt2400pci_init_hw_channels(rt2x00dev, hw->modes->channels);
-	rt2400pci_init_hw_rates(rt2x00dev, hw->modes->rates);
+	rt2400pci_init_hw_channels(rt2x00dev, rt2x00dev->hwmodes[0].channels);
+	rt2400pci_init_hw_rates(rt2x00dev, rt2x00dev->hwmodes[0].rates);
 
-	return ieee80211_update_hw(hw);
+	return 0;
 
 exit_free_channels:
-	kfree(hw->modes->channels);
-	hw->modes->channels = NULL;
+	kfree(rt2x00dev->hwmodes[0].channels);
+	rt2x00dev->hwmodes[0].channels = NULL;
 
 exit_free_modes:
-	kfree(hw->modes);
-	hw->modes = NULL;
+	kfree(rt2x00dev->hwmodes);
 
 exit:
 	ERROR("Allocation ieee80211 modes failed.\n");
@@ -2628,6 +2624,7 @@ exit:
 
 static int rt2400pci_init_hw(struct rt2x00_dev *rt2x00dev)
 {
+	int err;
 	int status;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
@@ -2661,6 +2658,11 @@ static int rt2400pci_init_hw(struct rt2x
 
 	if (ieee80211_register_hw(rt2x00dev->hw))
 		return -EIO;
+	err = ieee80211_register_hwmode(rt2x00dev->hw, &rt2x00dev->hwmodes[0]);
+	if (err) {
+		ieee80211_unregister_hw(rt2x00dev->hw);
+		return err;
+	}
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
 
@@ -2699,11 +2701,10 @@ static void rt2400pci_free_dev(struct rt
 	/*
 	 * Free ieee80211_hw memory.
 	 */
-	if (likely(rt2x00dev->hw->modes)) {
-		kfree(rt2x00dev->hw->modes->channels);
-		kfree(rt2x00dev->hw->modes->rates);
-		kfree(rt2x00dev->hw->modes);
-		rt2x00dev->hw->modes = NULL;
+	if (likely(rt2x00dev->hwmodes)) {
+		kfree(rt2x00dev->hwmodes[0].channels);
+		kfree(rt2x00dev->hwmodes[0].rates);
+		kfree(rt2x00dev->hwmodes);
 	}
 }
 
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2x00.h
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-15 19:43:02.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-15 19:46:23.000000000 +0100
@@ -903,6 +903,7 @@ struct rt2x00_dev {
 	 * IEEE80211 control structure.
 	 */
 	struct ieee80211_hw *hw;
+	struct ieee80211_hw_mode *hwmodes;
 
 	/*
 	 * Device flags.
@@ -1161,7 +1162,7 @@ static inline void device_rate_entry(str
 	entry->min_rssi_ack_delta = 0;
 }
 
-static inline int device_signal_to_rate(struct ieee80211_hw_modes *mode,
+static inline int device_signal_to_rate(struct ieee80211_hw_mode *mode,
 	u8 signal, u8 ofdm)
 {
 	unsigned int i;
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-15 19:43:14.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-15 19:58:03.000000000 +0100
@@ -658,14 +658,14 @@ static void rt2500pci_config_phymode(str
 
 	if (phymode == MODE_IEEE80211A &&
 	    rt2x00_rf(&rt2x00dev->chip, RF5222))
-		rate = &rt2x00dev->hw->modes[2].rates[
-			rt2x00dev->hw->modes[2].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[2].rates[
+			rt2x00dev->hwmodes[2].num_rates - 1];
 	else if (phymode == MODE_IEEE80211B)
-		rate = &rt2x00dev->hw->modes[1].rates[
-			rt2x00dev->hw->modes[1].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[1].rates[
+			rt2x00dev->hwmodes[1].num_rates - 1];
 	else
-		rate = &rt2x00dev->hw->modes[0].rates[
-			rt2x00dev->hw->modes[0].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[0].rates[
+			rt2x00dev->hwmodes[0].num_rates - 1];
 
 	rt2500pci_config_rate(rt2x00dev, rate->val2);
 
@@ -1265,10 +1265,10 @@ static int rt2500pci_init_channel_time(s
 	 */
 	jiffies_start = jiffies;
 	rt2500pci_config_channel(rt2x00dev,
-		rt2x00dev->hw->modes[0].channels[0].val,
-		rt2x00dev->hw->modes[0].channels[0].chan,
-		rt2x00dev->hw->modes[0].channels[0].freq,
-		rt2x00dev->hw->modes[0].channels[0].power_level);
+		rt2x00dev->hwmodes[0].channels[0].val,
+		rt2x00dev->hwmodes[0].channels[0].chan,
+		rt2x00dev->hwmodes[0].channels[0].freq,
+		rt2x00dev->hwmodes[0].channels[0].power_level);
 	jiffies_end = jiffies;
 
 	rt2x00dev->hw->channel_change_time =
@@ -1720,7 +1720,7 @@ static void rt2500pci_rxdone(void *data)
 				size);
 
 			rt2x00dev->rx_params.rate = device_signal_to_rate(
-				&rt2x00dev->hw->modes[0],
+				&rt2x00dev->hwmodes[0],
 				rt2x00_get_field32(word2, RXD_W2_SIGNAL),
 				rt2x00_get_field32(word0, RXD_W0_OFDM));
 
@@ -2842,7 +2842,6 @@ static void rt2500pci_init_hw_rates(stru
 
 static int rt2500pci_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_hw *hw = rt2x00dev->hw;
 	int num_modes;
 	int num_channels;
 
@@ -2860,23 +2859,22 @@ static int rt2500pci_init_hw_modes(struc
 		num_channels = 37;
 	}
 
-	hw->num_modes = num_modes;
-	hw->modes =
-		kzalloc((sizeof(struct ieee80211_hw_modes) * num_modes),
+	rt2x00dev->hwmodes =
+		kzalloc((sizeof(struct ieee80211_hw_mode) * num_modes),
 		GFP_KERNEL);
-	if (!hw->modes)
+	if (!rt2x00dev->hwmodes)
 		goto exit;
 
-	hw->modes->channels =
+	rt2x00dev->hwmodes[0].channels =
 		kzalloc((sizeof(struct ieee80211_channel) * num_channels),
 		GFP_KERNEL);
-	if (!hw->modes->channels)
+	if (!rt2x00dev->hwmodes[0].channels)
 		goto exit_free_modes;
 
-	hw->modes->rates =
+	rt2x00dev->hwmodes[0].rates =
 		kzalloc((sizeof(struct ieee80211_rate) * 12),
 		GFP_KERNEL);
-	if (!hw->modes->rates)
+	if (!rt2x00dev->hwmodes[0].rates)
 		goto exit_free_channels;
 
 	/*
@@ -2884,20 +2882,20 @@ static int rt2500pci_init_hw_modes(struc
 	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
-	hw->modes[0].mode = MODE_IEEE80211G;
-	hw->modes[0].num_channels = 14;
-	hw->modes[0].num_rates = 12;
+	rt2x00dev->hwmodes[0].mode = MODE_IEEE80211G;
+	rt2x00dev->hwmodes[0].num_channels = 14;
+	rt2x00dev->hwmodes[0].num_rates = 12;
 
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
-	hw->modes[1].mode = MODE_IEEE80211B;
-	hw->modes[1].num_channels = 14;
-	hw->modes[1].num_rates = 4;
-	hw->modes[1].channels = hw->modes[0].channels;
-	hw->modes[1].rates = hw->modes[0].rates;
+	rt2x00dev->hwmodes[1].mode = MODE_IEEE80211B;
+	rt2x00dev->hwmodes[1].num_channels = 14;
+	rt2x00dev->hwmodes[1].num_rates = 4;
+	rt2x00dev->hwmodes[1].channels = rt2x00dev->hwmodes[0].channels;
+	rt2x00dev->hwmodes[1].rates = rt2x00dev->hwmodes[0].rates;
 
 	/*
 	 * Intitialize 802.11a
@@ -2905,25 +2903,25 @@ static int rt2500pci_init_hw_modes(struc
 	 * Channels: OFDM, UNII, HiperLAN2.
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF5222)) {
-		hw->modes[2].mode = MODE_IEEE80211A;
-		hw->modes[2].num_channels = 37;
-		hw->modes[2].num_rates = 8;
-		hw->modes[2].channels = &hw->modes[0].channels[14];
-		hw->modes[2].rates = &hw->modes[0].rates[4];
+		rt2x00dev->hwmodes[2].mode = MODE_IEEE80211A;
+		rt2x00dev->hwmodes[2].num_channels = 37;
+		rt2x00dev->hwmodes[2].num_rates = 8;
+		rt2x00dev->hwmodes[2].channels = &rt2x00dev->hwmodes[0].channels[14];
+		rt2x00dev->hwmodes[2].rates = &rt2x00dev->hwmodes[0].rates[4];
 	}
 
-	rt2500pci_init_hw_channels(rt2x00dev, hw->modes[0].channels);
-	rt2500pci_init_hw_rates(rt2x00dev, hw->modes[0].rates);
+	rt2500pci_init_hw_channels(rt2x00dev, rt2x00dev->hwmodes[0].channels);
+	rt2500pci_init_hw_rates(rt2x00dev, rt2x00dev->hwmodes[0].rates);
 
-	return ieee80211_update_hw(hw);
+	return num_modes;
 
 exit_free_channels:
-	kfree(hw->modes->channels);
-	hw->modes->channels = NULL;
+	kfree(rt2x00dev->hwmodes[0].channels);
+	rt2x00dev->hwmodes[0].channels = NULL;
 
 exit_free_modes:
-	kfree(hw->modes);
-	hw->modes = NULL;
+	kfree(rt2x00dev->hwmodes);
+	rt2x00dev->hwmodes = NULL;
 
 exit:
 	ERROR("Allocation ieee80211 modes failed.\n");
@@ -2933,6 +2931,7 @@ exit:
 static int rt2500pci_init_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int status;
+	int i, num_modes;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
 		return 0;
@@ -2959,12 +2958,20 @@ static int rt2500pci_init_hw(struct rt2x
 	rt2x00dev->hw->maxssi = MAX_RX_SSI;
 	rt2x00dev->hw->queues = RING_NUM_TX;
 
-	status = rt2500pci_init_hw_modes(rt2x00dev);
-	if (status)
-		return status;
+	num_modes = rt2500pci_init_hw_modes(rt2x00dev);
+	if (num_modes <= 0)
+		return num_modes;
 
 	if (ieee80211_register_hw(rt2x00dev->hw))
 		return -EIO;
+	for (i = 0; i < num_modes; i++) {
+		status = ieee80211_register_hwmode(rt2x00dev->hw,
+						   &rt2x00dev->hwmodes[i]);
+		if (status) {
+			ieee80211_unregister_hw(rt2x00dev->hw);
+			return status;
+		}
+	}
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
 
@@ -3003,11 +3010,11 @@ static void rt2500pci_free_dev(struct rt
 	/*
 	 * Free ieee80211_hw memory.
 	 */
-	if (likely(rt2x00dev->hw->modes)) {
-		kfree(rt2x00dev->hw->modes->channels);
-		kfree(rt2x00dev->hw->modes->rates);
-		kfree(rt2x00dev->hw->modes);
-		rt2x00dev->hw->modes = NULL;
+	if (likely(rt2x00dev->hwmodes)) {
+		kfree(rt2x00dev->hwmodes[0].channels);
+		kfree(rt2x00dev->hwmodes[0].rates);
+		kfree(rt2x00dev->hwmodes);
+		rt2x00dev->hwmodes = NULL;
 	}
 }
 
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-15 19:43:14.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-15 20:16:12.000000000 +0100
@@ -690,14 +690,14 @@ static void rt2500usb_config_phymode(str
 
 	if (phymode == MODE_IEEE80211A &&
 	    rt2x00_rf(&rt2x00dev->chip, RF5222))
-		rate = &rt2x00dev->hw->modes[2].rates[
-			rt2x00dev->hw->modes[2].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[2].rates[
+			rt2x00dev->hwmodes[2].num_rates - 1];
 	else if (phymode == MODE_IEEE80211B)
-		rate = &rt2x00dev->hw->modes[1].rates[
-			rt2x00dev->hw->modes[1].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[1].rates[
+			rt2x00dev->hwmodes[1].num_rates - 1];
 	else
-		rate = &rt2x00dev->hw->modes[0].rates[
-			rt2x00dev->hw->modes[0].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[0].rates[
+			rt2x00dev->hwmodes[0].num_rates - 1];
 
 	rt2500usb_config_rate(rt2x00dev, rate->val2);
 
@@ -1237,10 +1237,10 @@ static int rt2500usb_init_channel_time(s
 	 */
 	jiffies_start = jiffies;
 	rt2500usb_config_channel(rt2x00dev,
-		rt2x00dev->hw->modes[0].channels[0].val,
-		rt2x00dev->hw->modes[0].channels[0].chan,
-		rt2x00dev->hw->modes[0].channels[0].freq,
-		rt2x00dev->hw->modes[0].channels[0].power_level);
+		rt2x00dev->hwmodes[0].channels[0].val,
+		rt2x00dev->hwmodes[0].channels[0].chan,
+		rt2x00dev->hwmodes[0].channels[0].freq,
+		rt2x00dev->hwmodes[0].channels[0].power_level);
 	jiffies_end = jiffies;
 
 	rt2x00dev->hw->channel_change_time =
@@ -1701,7 +1701,7 @@ static void rt2500usb_rxdone(void *data)
 				rt2x00_rxdata_addr(entry), size);
 
 			rt2x00dev->rx_params.rate = device_signal_to_rate(
-				&rt2x00dev->hw->modes[0],
+				&rt2x00dev->hwmodes[0],
 				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
 				rt2x00_get_field32(word0, RXD_W0_OFDM));
 
@@ -2685,7 +2685,6 @@ static void rt2500usb_init_hw_rates(stru
 
 static int rt2500usb_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_hw *hw = rt2x00dev->hw;
 	int num_modes;
 	int num_channels;
 
@@ -2703,23 +2702,22 @@ static int rt2500usb_init_hw_modes(struc
 		num_channels = 37;
 	}
 
-	hw->num_modes = num_modes;
-	hw->modes =
-		kzalloc((sizeof(struct ieee80211_hw_modes) * num_modes),
+	rt2x00dev->hwmodes =
+		kzalloc((sizeof(struct ieee80211_hw_mode) * num_modes),
 		GFP_KERNEL);
-	if (!hw->modes)
+	if (!rt2x00dev->hwmodes)
 		goto exit;
 
-	hw->modes->channels =
+	rt2x00dev->hwmodes[0].channels =
 		kzalloc((sizeof(struct ieee80211_channel) * num_channels),
 		GFP_KERNEL);
-	if (!hw->modes->channels)
+	if (!rt2x00dev->hwmodes[0].channels)
 		goto exit_free_modes;
 
-	hw->modes->rates =
+	rt2x00dev->hwmodes[0].rates =
 		kzalloc((sizeof(struct ieee80211_rate) * 12),
 		GFP_KERNEL);
-	if (!hw->modes->rates)
+	if (!rt2x00dev->hwmodes[0].rates)
 		goto exit_free_channels;
 
 	/*
@@ -2727,20 +2725,20 @@ static int rt2500usb_init_hw_modes(struc
 	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
-	hw->modes[0].mode = MODE_IEEE80211G;
-	hw->modes[0].num_channels = 14;
-	hw->modes[0].num_rates = 12;
+	rt2x00dev->hwmodes[0].mode = MODE_IEEE80211G;
+	rt2x00dev->hwmodes[0].num_channels = 14;
+	rt2x00dev->hwmodes[0].num_rates = 12;
 
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
-	hw->modes[1].mode = MODE_IEEE80211B;
-	hw->modes[1].num_channels = 14;
-	hw->modes[1].num_rates = 4;
-	hw->modes[1].channels = hw->modes[0].channels;
-	hw->modes[1].rates = hw->modes[0].rates;
+	rt2x00dev->hwmodes[1].mode = MODE_IEEE80211B;
+	rt2x00dev->hwmodes[1].num_channels = 14;
+	rt2x00dev->hwmodes[1].num_rates = 4;
+	rt2x00dev->hwmodes[1].channels = rt2x00dev->hwmodes[0].channels;
+	rt2x00dev->hwmodes[1].rates = rt2x00dev->hwmodes[0].rates;
 
 	/*
 	 * Intitialize 802.11a
@@ -2748,25 +2746,25 @@ static int rt2500usb_init_hw_modes(struc
 	 * Channels: OFDM, UNII, HiperLAN2.
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF5222)) {
-		hw->modes[2].mode = MODE_IEEE80211A;
-		hw->modes[2].num_channels = 37;
-		hw->modes[2].num_rates = 8;
-		hw->modes[2].channels = &hw->modes[0].channels[14];
-		hw->modes[2].rates = &hw->modes[0].rates[4];
+		rt2x00dev->hwmodes[2].mode = MODE_IEEE80211A;
+		rt2x00dev->hwmodes[2].num_channels = 37;
+		rt2x00dev->hwmodes[2].num_rates = 8;
+		rt2x00dev->hwmodes[2].channels = &rt2x00dev->hwmodes[0].channels[14];
+		rt2x00dev->hwmodes[2].rates = &rt2x00dev->hwmodes[0].rates[4];
 	}
 
-	rt2500usb_init_hw_channels(rt2x00dev, hw->modes[0].channels);
-	rt2500usb_init_hw_rates(rt2x00dev, hw->modes[0].rates);
+	rt2500usb_init_hw_channels(rt2x00dev, rt2x00dev->hwmodes[0].channels);
+	rt2500usb_init_hw_rates(rt2x00dev, rt2x00dev->hwmodes[0].rates);
 
-	return ieee80211_update_hw(hw);
+	return num_modes;
 
 exit_free_channels:
-	kfree(hw->modes->channels);
-	hw->modes->channels = NULL;
+	kfree(rt2x00dev->hwmodes[0].channels);
+	rt2x00dev->hwmodes[0].channels = NULL;
 
 exit_free_modes:
-	kfree(hw->modes);
-	hw->modes = NULL;
+	kfree(rt2x00dev->hwmodes);
+	rt2x00dev->hwmodes = NULL;
 
 exit:
 	ERROR("Allocation ieee80211 modes failed.\n");
@@ -2776,6 +2774,7 @@ exit:
 static int rt2500usb_init_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int status;
+	int i, num_modes;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
 		return 0;
@@ -2802,12 +2801,20 @@ static int rt2500usb_init_hw(struct rt2x
 	rt2x00dev->hw->maxssi = MAX_RX_SSI;
 	rt2x00dev->hw->queues = RING_NUM_TX;
 
-	status = rt2500usb_init_hw_modes(rt2x00dev);
-	if (status)
-		return status;
+	num_modes = rt2500usb_init_hw_modes(rt2x00dev);
+	if (num_modes <= 0)
+		return num_modes;
 
 	if (ieee80211_register_hw(rt2x00dev->hw))
 		return -EIO;
+	for (i = 0; i < num_modes; i++) {
+		status = ieee80211_register_hwmode(rt2x00dev->hw,
+						   &rt2x00dev->hwmodes[i]);
+		if (status) {
+			ieee80211_unregister_hw(rt2x00dev->hw);
+			return status;
+		}
+	}
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
 
@@ -2838,11 +2845,11 @@ static void rt2500usb_free_dev(struct rt
 	/*
 	 * Free ieee80211_hw memory.
 	 */
-	if (likely(rt2x00dev->hw->modes)) {
-		kfree(rt2x00dev->hw->modes->channels);
-		kfree(rt2x00dev->hw->modes->rates);
-		kfree(rt2x00dev->hw->modes);
-		rt2x00dev->hw->modes = NULL;
+	if (likely(rt2x00dev->hwmodes)) {
+		kfree(rt2x00dev->hwmodes[0].channels);
+		kfree(rt2x00dev->hwmodes[0].rates);
+		kfree(rt2x00dev->hwmodes);
+		rt2x00dev->hwmodes = NULL;
 	}
 }
 
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-15 19:44:13.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-15 20:08:17.000000000 +0100
@@ -890,14 +890,14 @@ static void rt61pci_config_phymode(struc
 	if (phymode == MODE_IEEE80211A &&
 	    (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5325)))
-		rate = &rt2x00dev->hw->modes[2].rates[
-			rt2x00dev->hw->modes[2].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[2].rates[
+			rt2x00dev->hwmodes[2].num_rates - 1];
 	else if (phymode == MODE_IEEE80211B)
-		rate = &rt2x00dev->hw->modes[1].rates[
-			rt2x00dev->hw->modes[1].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[1].rates[
+			rt2x00dev->hwmodes[1].num_rates - 1];
 	else
-		rate = &rt2x00dev->hw->modes[0].rates[
-			rt2x00dev->hw->modes[0].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[0].rates[
+			rt2x00dev->hwmodes[0].num_rates - 1];
 
 	rt61pci_config_rate(rt2x00dev, rate->val2);
 
@@ -1701,10 +1701,10 @@ static int rt61pci_init_channel_time(str
 	 */
 	jiffies_start = jiffies;
 	rt61pci_config_channel(rt2x00dev,
-		rt2x00dev->hw->modes[0].channels[0].val,
-		rt2x00dev->hw->modes[0].channels[0].chan,
-		rt2x00dev->hw->modes[0].channels[0].freq,
-		rt2x00dev->hw->modes[0].channels[0].power_level);
+		rt2x00dev->hwmodes[0].channels[0].val,
+		rt2x00dev->hwmodes[0].channels[0].chan,
+		rt2x00dev->hwmodes[0].channels[0].freq,
+		rt2x00dev->hwmodes[0].channels[0].power_level);
 	jiffies_end = jiffies;
 
 	rt2x00dev->hw->channel_change_time =
@@ -2190,7 +2190,7 @@ static void rt61pci_rxdone(void *data)
 				size);
 
 			rt2x00dev->rx_params.rate = device_signal_to_rate(
-				&rt2x00dev->hw->modes[0],
+				&rt2x00dev->hwmodes[0],
 				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
 				rt2x00_get_field32(word0, RXD_W0_OFDM));
 
@@ -3369,7 +3369,6 @@ static void rt61pci_init_hw_rates(struct
 
 static int rt61pci_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_hw *hw = rt2x00dev->hw;
 	int num_modes;
 	int num_channels;
 
@@ -3388,23 +3387,22 @@ static int rt61pci_init_hw_modes(struct 
 		num_channels = 38;
 	}
 
-	hw->num_modes = num_modes;
-	hw->modes =
-		kzalloc((sizeof(struct ieee80211_hw_modes) * num_modes),
+	rt2x00dev->hwmodes =
+		kzalloc((sizeof(struct ieee80211_hw_mode) * num_modes),
 		GFP_KERNEL);
-	if (!hw->modes)
+	if (!rt2x00dev->hwmodes)
 		goto exit;
 
-	hw->modes->channels =
+	rt2x00dev->hwmodes[0].channels =
 		kzalloc((sizeof(struct ieee80211_channel) * num_channels),
 		GFP_KERNEL);
-	if (!hw->modes->channels)
+	if (!rt2x00dev->hwmodes[0].channels)
 		goto exit_free_modes;
 
-	hw->modes->rates =
+	rt2x00dev->hwmodes[0].rates =
 		kzalloc((sizeof(struct ieee80211_rate) * 12),
 		GFP_KERNEL);
-	if (!hw->modes->rates)
+	if (!rt2x00dev->hwmodes[0].rates)
 		goto exit_free_channels;
 
 	/*
@@ -3412,20 +3410,20 @@ static int rt61pci_init_hw_modes(struct 
 	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
-	hw->modes[0].mode = MODE_IEEE80211G;
-	hw->modes[0].num_channels = 14;
-	hw->modes[0].num_rates = 12;
+	rt2x00dev->hwmodes[0].mode = MODE_IEEE80211G;
+	rt2x00dev->hwmodes[0].num_channels = 14;
+	rt2x00dev->hwmodes[0].num_rates = 12;
 
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
-	hw->modes[1].mode = MODE_IEEE80211B;
-	hw->modes[1].num_channels = 14;
-	hw->modes[1].num_rates = 4;
-	hw->modes[1].channels = hw->modes[0].channels;
-	hw->modes[1].rates = hw->modes[0].rates;
+	rt2x00dev->hwmodes[1].mode = MODE_IEEE80211B;
+	rt2x00dev->hwmodes[1].num_channels = 14;
+	rt2x00dev->hwmodes[1].num_rates = 4;
+	rt2x00dev->hwmodes[1].channels = rt2x00dev->hwmodes[0].channels;
+	rt2x00dev->hwmodes[1].rates = rt2x00dev->hwmodes[0].rates;
 
 	/*
 	 * Intitialize 802.11a
@@ -3434,25 +3432,25 @@ static int rt61pci_init_hw_modes(struct 
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5325)) {
-		hw->modes[2].mode = MODE_IEEE80211A;
-		hw->modes[2].num_channels = 38;
-		hw->modes[2].num_rates = 8;
-		hw->modes[2].channels = &hw->modes[0].channels[14];
-		hw->modes[2].rates = &hw->modes[0].rates[4];
+		rt2x00dev->hwmodes[2].mode = MODE_IEEE80211A;
+		rt2x00dev->hwmodes[2].num_channels = 38;
+		rt2x00dev->hwmodes[2].num_rates = 8;
+		rt2x00dev->hwmodes[2].channels = &rt2x00dev->hwmodes[0].channels[14];
+		rt2x00dev->hwmodes[2].rates = &rt2x00dev->hwmodes[0].rates[4];
 	}
 
-	rt61pci_init_hw_channels(rt2x00dev, hw->modes[0].channels);
-	rt61pci_init_hw_rates(rt2x00dev, hw->modes[0].rates);
+	rt61pci_init_hw_channels(rt2x00dev, rt2x00dev->hwmodes[0].channels);
+	rt61pci_init_hw_rates(rt2x00dev, rt2x00dev->hwmodes[0].rates);
 
-	return ieee80211_update_hw(hw);
+	return num_modes;
 
 exit_free_channels:
-	kfree(hw->modes->channels);
-	hw->modes->channels = NULL;
+	kfree(rt2x00dev->hwmodes[0].channels);
+	rt2x00dev->hwmodes[0].channels = NULL;
 
 exit_free_modes:
-	kfree(hw->modes);
-	hw->modes = NULL;
+	kfree(rt2x00dev->hwmodes);
+	rt2x00dev->hwmodes = NULL;
 
 exit:
 	ERROR("Allocation ieee80211 modes failed.\n");
@@ -3462,6 +3460,7 @@ exit:
 static int rt61pci_init_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int status;
+	int i, num_modes;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
 		return 0;
@@ -3488,12 +3487,20 @@ static int rt61pci_init_hw(struct rt2x00
 	rt2x00dev->hw->maxssi = MAX_RX_SSI;
 	rt2x00dev->hw->queues = RING_NUM_TX;
 
-	status = rt61pci_init_hw_modes(rt2x00dev);
-	if (status)
-		return status;
+	num_modes = rt61pci_init_hw_modes(rt2x00dev);
+	if (num_modes <= 0)
+		return num_modes;
 
 	if (ieee80211_register_hw(rt2x00dev->hw))
 		return -EIO;
+	for (i = 0; i < num_modes; i++) {
+		status = ieee80211_register_hwmode(rt2x00dev->hw,
+						   &rt2x00dev->hwmodes[i]);
+		if (status) {
+			ieee80211_unregister_hw(rt2x00dev->hw);
+			return status;
+		}
+	}
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
 
@@ -3532,11 +3539,11 @@ static void rt61pci_free_dev(struct rt2x
 	/*
 	 * Free ieee80211_hw memory.
 	 */
-	if (likely(rt2x00dev->hw->modes)) {
-		kfree(rt2x00dev->hw->modes->channels);
-		kfree(rt2x00dev->hw->modes->rates);
-		kfree(rt2x00dev->hw->modes);
-		rt2x00dev->hw->modes = NULL;
+	if (likely(rt2x00dev->hwmodes)) {
+		kfree(rt2x00dev->hwmodes[0].channels);
+		kfree(rt2x00dev->hwmodes[0].rates);
+		kfree(rt2x00dev->hwmodes);
+		rt2x00dev->hwmodes = NULL;
 	}
 }
 
Index: jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-15 19:46:11.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-15 20:25:07.000000000 +0100
@@ -788,14 +788,14 @@ static void rt73usb_config_phymode(struc
 	if (phymode == MODE_IEEE80211A &&
 	    (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5226)))
-		rate = &rt2x00dev->hw->modes[2].rates[
-			rt2x00dev->hw->modes[2].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[2].rates[
+			rt2x00dev->hwmodes[2].num_rates - 1];
 	else if (phymode == MODE_IEEE80211B)
-		rate = &rt2x00dev->hw->modes[1].rates[
-			rt2x00dev->hw->modes[1].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[1].rates[
+			rt2x00dev->hwmodes[1].num_rates - 1];
 	else
-		rate = &rt2x00dev->hw->modes[0].rates[
-			rt2x00dev->hw->modes[0].num_rates - 1];
+		rate = &rt2x00dev->hwmodes[0].rates[
+			rt2x00dev->hwmodes[0].num_rates - 1];
 
 	rt73usb_config_rate(rt2x00dev, rate->val2);
 
@@ -1485,10 +1485,10 @@ static int rt73usb_init_channel_time(str
 	 */
 	jiffies_start = jiffies;
 	rt73usb_config_channel(rt2x00dev,
-		rt2x00dev->hw->modes[0].channels[0].val,
-		rt2x00dev->hw->modes[0].channels[0].chan,
-		rt2x00dev->hw->modes[0].channels[0].freq,
-		rt2x00dev->hw->modes[0].channels[0].power_level);
+		rt2x00dev->hwmodes[0].channels[0].val,
+		rt2x00dev->hwmodes[0].channels[0].chan,
+		rt2x00dev->hwmodes[0].channels[0].freq,
+		rt2x00dev->hwmodes[0].channels[0].power_level);
 	jiffies_end = jiffies;
 
 	rt2x00dev->hw->channel_change_time =
@@ -1978,7 +1978,7 @@ static void rt73usb_rxdone(void *data)
 				rt2x00_data_addr(entry), size);
 
 			rt2x00dev->rx_params.rate = device_signal_to_rate(
-				&rt2x00dev->hw->modes[0],
+				&rt2x00dev->hwmodes[0],
 				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
 				rt2x00_get_field32(word0, RXD_W0_OFDM));
 
@@ -3025,7 +3025,6 @@ static void rt73usb_init_hw_rates(struct
 
 static int rt73usb_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_hw *hw = rt2x00dev->hw;
 	int num_modes;
 	int num_channels;
 
@@ -3044,23 +3043,22 @@ static int rt73usb_init_hw_modes(struct 
 		num_channels = 38;
 	}
 
-	hw->num_modes = num_modes;
-	hw->modes =
-		kzalloc((sizeof(struct ieee80211_hw_modes) * num_modes),
+	rt2x00dev->hwmodes =
+		kzalloc((sizeof(struct ieee80211_hw_mode) * num_modes),
 		GFP_KERNEL);
-	if (!hw->modes)
+	if (!rt2x00dev->hwmodes)
 		goto exit;
 
-	hw->modes->channels =
+	rt2x00dev->hwmodes[0].channels =
 		kzalloc((sizeof(struct ieee80211_channel) * num_channels),
 		GFP_KERNEL);
-	if (!hw->modes->channels)
+	if (!rt2x00dev->hwmodes[0].channels)
 		goto exit_free_modes;
 
-	hw->modes->rates =
+	rt2x00dev->hwmodes[0].rates =
 		kzalloc((sizeof(struct ieee80211_rate) * 12),
 		GFP_KERNEL);
-	if (!hw->modes->rates)
+	if (!rt2x00dev->hwmodes[0].rates)
 		goto exit_free_channels;
 
 	/*
@@ -3068,20 +3066,20 @@ static int rt73usb_init_hw_modes(struct 
 	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
-	hw->modes[0].mode = MODE_IEEE80211G;
-	hw->modes[0].num_channels = 14;
-	hw->modes[0].num_rates = 12;
+	rt2x00dev->hwmodes[0].mode = MODE_IEEE80211G;
+	rt2x00dev->hwmodes[0].num_channels = 14;
+	rt2x00dev->hwmodes[0].num_rates = 12;
 
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
-	hw->modes[1].mode = MODE_IEEE80211B;
-	hw->modes[1].num_channels = 14;
-	hw->modes[1].num_rates = 4;
-	hw->modes[1].channels = hw->modes[0].channels;
-	hw->modes[1].rates = hw->modes[0].rates;
+	rt2x00dev->hwmodes[1].mode = MODE_IEEE80211B;
+	rt2x00dev->hwmodes[1].num_channels = 14;
+	rt2x00dev->hwmodes[1].num_rates = 4;
+	rt2x00dev->hwmodes[1].channels = rt2x00dev->hwmodes[0].channels;
+	rt2x00dev->hwmodes[1].rates = rt2x00dev->hwmodes[0].rates;
 
 	/*
 	 * Intitialize 802.11a
@@ -3090,25 +3088,25 @@ static int rt73usb_init_hw_modes(struct 
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5226)) {
-		hw->modes[2].mode = MODE_IEEE80211A;
-		hw->modes[2].num_channels = 38;
-		hw->modes[2].num_rates = 8;
-		hw->modes[2].channels = &hw->modes[0].channels[14];
-		hw->modes[2].rates = &hw->modes[0].rates[4];
+		rt2x00dev->hwmodes[2].mode = MODE_IEEE80211A;
+		rt2x00dev->hwmodes[2].num_channels = 38;
+		rt2x00dev->hwmodes[2].num_rates = 8;
+		rt2x00dev->hwmodes[2].channels = &rt2x00dev->hwmodes[0].channels[14];
+		rt2x00dev->hwmodes[2].rates = &rt2x00dev->hwmodes[0].rates[4];
 	}
 
-	rt73usb_init_hw_channels(rt2x00dev, hw->modes[0].channels);
-	rt73usb_init_hw_rates(rt2x00dev, hw->modes[0].rates);
+	rt73usb_init_hw_channels(rt2x00dev, rt2x00dev->hwmodes[0].channels);
+	rt73usb_init_hw_rates(rt2x00dev, rt2x00dev->hwmodes[0].rates);
 
-	return ieee80211_update_hw(hw);
+	return num_modes;
 
 exit_free_channels:
-	kfree(hw->modes->channels);
-	hw->modes->channels = NULL;
+	kfree(rt2x00dev->hwmodes[0].channels);
+	rt2x00dev->hwmodes[0].channels = NULL;
 
 exit_free_modes:
-	kfree(hw->modes);
-	hw->modes = NULL;
+	kfree(rt2x00dev->hwmodes);
+	rt2x00dev->hwmodes = NULL;
 
 exit:
 	ERROR("Allocation ieee80211 modes failed.\n");
@@ -3118,6 +3116,7 @@ exit:
 static int rt73usb_init_hw(struct rt2x00_dev *rt2x00dev)
 {
 	int status;
+	int i, num_modes;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
 		return 0;
@@ -3144,12 +3143,20 @@ static int rt73usb_init_hw(struct rt2x00
 	rt2x00dev->hw->maxssi = MAX_RX_SSI;
 	rt2x00dev->hw->queues = RING_NUM_TX;
 
-	status = rt73usb_init_hw_modes(rt2x00dev);
-	if (status)
-		return status;
+	num_modes = rt73usb_init_hw_modes(rt2x00dev);
+	if (num_modes <= 0)
+		return num_modes;
 
 	if (ieee80211_register_hw(rt2x00dev->hw))
 		return -EIO;
+	for (i = 0; i < num_modes; i++) {
+		status = ieee80211_register_hwmode(rt2x00dev->hw,
+						   &rt2x00dev->hwmodes[i]);
+		if (status) {
+			ieee80211_unregister_hw(rt2x00dev->hw);
+			return status;
+		}
+	}
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
 
@@ -3180,11 +3187,11 @@ static void rt73usb_free_dev(struct rt2x
 	/*
 	 * Free ieee80211_hw memory.
 	 */
-	if (likely(rt2x00dev->hw->modes)) {
-		kfree(rt2x00dev->hw->modes->channels);
-		kfree(rt2x00dev->hw->modes->rates);
-		kfree(rt2x00dev->hw->modes);
-		rt2x00dev->hw->modes = NULL;
+	if (likely(rt2x00dev->hwmodes)) {
+		kfree(rt2x00dev->hwmodes[0].channels);
+		kfree(rt2x00dev->hwmodes[0].rates);
+		kfree(rt2x00dev->hwmodes);
+		rt2x00dev->hwmodes = NULL;
 	}
 }
 

-- 
Greetings Michael.
