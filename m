From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take4 5/5] d80211: remove bitfields from ieee80211_conf
Date: Sun, 12 Nov 2006 09:52:53 -0800
Message-ID: <20061112175253.GF11728@devicescape.com>
References: <20061112175216.027653000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:13014 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751695AbWKLRwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 12:52:54 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="ieee80211_conf_bitfields.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All four one-bit bitfields have been subsumed into the new 'flags'
structure member and the new IEEE80211_CONF_* definitions. 

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -242,12 +242,12 @@ struct ieee80211_conf {
 
         int beacon_int;
 
-	/* Bitfields, grouped together */
-
-	unsigned int sw_encrypt:1;
-	unsigned int sw_decrypt:1;
-	unsigned int short_slot_time:1;	/* use IEEE 802.11g Short Slot Time */
-	unsigned int ssid_hidden:1;	/* do not broadcast the ssid */
+#define IEEE80211_CONF_SW_ENCRYPT	(1<<0)
+#define IEEE80211_CONF_SW_DECRYPT	(1<<1)
+#define IEEE80211_CONF_SHORT_SLOT_TIME	(1<<2) /* use IEEE 802.11g Short Slot
+						* Time */
+#define IEEE80211_CONF_SSID_HIDDEN	(1<<3) /* do not broadcast the ssid */
+	u32 flags;			/* configuration flags defined above */
 
         u8 power_level;			/* transmit power limit for current
 					 * regulatory domain; in dBm */
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3562,9 +3562,9 @@ static int bcm43xx_net_config(struct net
 		bcm43xx_radio_selectchannel(bcm, conf->channel_val, 0);
 
 	/* Enable/Disable ShortSlot timing. */
-	if (conf->short_slot_time != bcm->short_slot) {
+	if (!!(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) != bcm->short_slot) {
 		assert(phy->type == BCM43xx_PHYTYPE_G);
-		if (conf->short_slot_time)
+		if (conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME)
 			bcm43xx_short_slot_timing_enable(bcm);
 		else
 			bcm43xx_short_slot_timing_disable(bcm);
@@ -3577,7 +3577,7 @@ static int bcm43xx_net_config(struct net
 	}
 
 	/* Hide/Show the SSID (AP mode only). */
-	if (conf->ssid_hidden) {
+	if (conf->flags & IEEE80211_CONF_SSID_HIDDEN) {
 		bcm43xx_write32(bcm->wlcore, BCM43xx_MMIO_STATUS_BITFIELD,
 				bcm43xx_read32(bcm->wlcore, BCM43xx_MMIO_STATUS_BITFIELD)
 				| BCM43xx_SBF_NO_SSID_BCAST);
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -742,7 +742,8 @@ static void rt2400pci_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
@@ -2088,7 +2089,8 @@ static int rt2400pci_config(struct net_d
 		conf->channel_val, conf->channel, conf->freq);
 	rt2400pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2400pci_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2400pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2400pci_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2400pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -808,7 +808,8 @@ static void rt2500pci_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
@@ -2238,7 +2239,8 @@ static int rt2500pci_config(struct net_d
 		conf->power_level);
 	rt2500pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2500pci_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2500pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2500pci_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2500pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1033,7 +1033,8 @@ static void rt61pci_config_rate(struct r
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
@@ -2713,7 +2714,8 @@ static int rt61pci_config(struct net_dev
 		conf->power_level);
 	rt61pci_config_txpower(rt2x00dev, conf->power_level);
 	rt61pci_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
-	rt61pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt61pci_config_duration(rt2x00dev,
+				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt61pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -510,7 +510,8 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 static int wep_encrypt_skb(struct ieee80211_txrx_data *tx, struct sk_buff *skb)
 {
-	if (tx->key->force_sw_encrypt || tx->local->conf.sw_encrypt) {
+	if (tx->key->force_sw_encrypt ||
+	    (tx->local->conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
 		if (ieee80211_wep_encrypt(tx->local, skb, tx->key))
 			return -1;
 	} else {
@@ -3211,7 +3212,8 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
 	if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) ||
-	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
+	    rx->key->force_sw_encrypt ||
+	    (rx->local->conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
 		u8 *iv = ieee80211_wep_is_weak_iv(rx->skb, rx->key);
 		if (iv) {
 			rx->sta->wep_weak_iv_count++;
@@ -3243,7 +3245,8 @@ ieee80211_rx_h_wep_decrypt(struct ieee80
 	}
 
 	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED) ||
-	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
+	    rx->key->force_sw_encrypt ||
+	    (rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		if (ieee80211_wep_decrypt(rx->local, rx->skb, rx->key)) {
 			printk(KERN_DEBUG "%s: RX WEP frame, decrypt "
 			       "failed\n", rx->dev->name);
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -492,7 +492,8 @@ int ieee80211_set_hw_encryption(struct n
 		key->force_sw_encrypt = 1;
 
 	if (key && local->hw->set_key &&
-	    (!local->conf.sw_encrypt || !local->conf.sw_decrypt) &&
+	    (!(local->conf.flags & IEEE80211_CONF_SW_ENCRYPT) ||
+	     !(local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) &&
 	    (keyconf = ieee80211_key_data2conf(local, key)) != NULL) {
 		if (local->hw->set_key(dev, SET_KEY, addr,
 				       keyconf, sta ? sta->aid : 0)) {
@@ -2432,7 +2433,10 @@ static int ieee80211_ioctl_prism2_param(
                 local->stat_time = value;
                 break;
 	case PRISM2_PARAM_SHORT_SLOT_TIME:
-		local->conf.short_slot_time = value;
+		if (value)
+			local->conf.flags |= IEEE80211_CONF_SHORT_SLOT_TIME;
+		else
+			local->conf.flags &= ~IEEE80211_CONF_SHORT_SLOT_TIME;
 		if (ieee80211_hw_config(dev))
 			ret = -EINVAL;
 		break;
@@ -2479,8 +2483,10 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_BROADCAST_SSID:
 		if ((value < 0) || (value > 1))
 			ret = -EINVAL;
+		else if (value)
+			local->conf.flags |= IEEE80211_CONF_SSID_HIDDEN;
 		else
-			local->conf.ssid_hidden = value;
+			local->conf.flags &= ~IEEE80211_CONF_SSID_HIDDEN;
 		break;
 
 	case PRISM2_PARAM_STA_ANTENNA_SEL:
@@ -2658,7 +2664,7 @@ static int ieee80211_ioctl_get_prism2_pa
                 *param = local->stat_time;
                 break;
 	case PRISM2_PARAM_SHORT_SLOT_TIME:
-		*param = local->conf.short_slot_time;
+		*param = !!(local->conf.flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 		break;
 
 	case PRISM2_PARAM_NEXT_MODE:
@@ -2678,7 +2684,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_BROADCAST_SSID:
-		*param = local->conf.ssid_hidden;
+		*param = !!(local->conf.flags & IEEE80211_CONF_SSID_HIDDEN);
 		break;
 
 	case PRISM2_PARAM_STA_ANTENNA_SEL:
Index: wireless-dev/net/d80211/wpa.c
===================================================================
--- wireless-dev.orig/net/d80211/wpa.c
+++ wireless-dev/net/d80211/wpa.c
@@ -103,7 +103,8 @@ ieee80211_tx_h_michael_mic_add(struct ie
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !tx->fragmented && !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
@@ -183,7 +184,8 @@ ieee80211_rx_h_michael_mic_verify(struct
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
+	    !rx->key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		if (rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (skb->len < MICHAEL_MIC_LEN)
 				return TXRX_DROP;
@@ -290,7 +292,8 @@ static int tkip_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt)
+	tailneed = (!tx->key->force_sw_encrypt &&
+		    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT))
 		? 0 : TKIP_ICV_LEN;
 	if ((skb_headroom(skb) < TKIP_IV_LEN ||
 	     skb_tailroom(skb) < tailneed)) {
@@ -323,7 +326,8 @@ iv_inc:
 skip_iv_inc:
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	    && !tx->wpa_test
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
@@ -399,7 +403,8 @@ ieee80211_tx_h_tkip_encrypt(struct ieee8
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
@@ -478,7 +483,8 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
+	    !rx->key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		if (!(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 			/* Hardware takes care of all processing, including
 			 * replay protection, so no need to continue here. */
@@ -622,7 +628,8 @@ static int ccmp_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!key->force_sw_encrypt && !tx->local->conf.sw_decrypt)
+	tailneed = (!key->force_sw_encrypt &&
+		    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT))
 		? 0 : CCMP_MIC_LEN;
 
 	if ((skb_headroom(skb) < CCMP_HDR_LEN ||
@@ -663,7 +670,8 @@ skip_pn_inc:
 
 	ccmp_pn2hdr(pos, pn, key->keyidx);
 
-	if (!key->force_sw_encrypt && !tx->local->conf.sw_decrypt) {
+	if (!key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		/* hwaccel - with preallocated room for CCMP header */
 		tx->u.tx.control->key_idx = key->hw_key_idx;
 		return 0;
@@ -717,7 +725,8 @@ ieee80211_tx_h_ccmp_encrypt(struct ieee8
 	tx->u.tx.control->iv_len = CCMP_HDR_LEN;
 	ieee80211_tx_set_iswep(tx);
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
 		 * header or MIC fields */
@@ -769,7 +778,8 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 		return TXRX_DROP;
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !key->force_sw_encrypt && !rx->local->conf.sw_decrypt &&
+	    !key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV))
 		return TXRX_CONTINUE;
 
@@ -790,7 +800,8 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 	}
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
+	    !key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		/* hwaccel has already decrypted frame and verified MIC */
 	} else {
 		u8 *scratch, *b_0, *aad;
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -657,7 +657,8 @@ static void rt2500usb_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field16_nb(&reg, TXRX_CSR1_ACK_TIMEOUT, value);
@@ -1971,7 +1972,8 @@ static int rt2500usb_config(struct net_d
 		conf->power_level);
 	rt2500usb_config_txpower(rt2x00dev, conf->power_level);
 	rt2500usb_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2500usb_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2500usb_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2500usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -771,7 +771,8 @@ static void rt73usb_config_rate(struct r
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
@@ -2260,7 +2261,8 @@ static int rt73usb_config(struct net_dev
 		conf->power_level);
 	rt73usb_config_txpower(rt2x00dev, conf->power_level);
 	rt73usb_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
-	rt73usb_config_duration(rt2x00dev, conf->short_slot_time);
+	rt73usb_config_duration(rt2x00dev,
+				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt73usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*

--
