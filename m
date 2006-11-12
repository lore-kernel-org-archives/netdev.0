From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take4 4/5] d80211: remove bitfields from ieee80211_hw
Date: Sun, 12 Nov 2006 09:52:49 -0800
Message-ID: <20061112175249.GE11728@devicescape.com>
References: <20061112175216.027653000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:9942 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751676AbWKLRwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 12:52:50 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="ieee80211_hw_bitfields.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All twelve one-bit bitfields have been subsumed into the new 'flags'
structure member and the new IEEE80211_HW_* definitions. 

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2025,17 +2025,10 @@ static int __devinit adm8211_probe(struc
 
 	hw->version = 2;
 	hw->name = "adm8211";
-	hw->host_gen_beacon = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;	// however, FCS is kept in promisc mode
-	hw->host_broadcast_ps_buffering = 0;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 0;
-	hw->no_tkip_wmm_hwaccel = 1;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 0;
-	hw->fraglist = 0;
+	hw->flags = IEEE80211_HW_WEP_INCLUDE_IV | IEEE80211_HW_NO_TKIP_WMM_HWACCEL;
+	// however, IEEE80211_HW_RX_INCLUDES_FCS in promisc mode
+
 	hw->channel_change_time = 1000;
 
 	hw->num_modes = 1;
Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -439,19 +439,19 @@ struct ieee80211_hw {
 	 * configure the upper layer IEEE 802.11 module to generate beacons.
 	 * The low-level driver can use ieee80211_beacon_get() to fetch the
 	 * next beacon frame. */
-	unsigned int host_gen_beacon:1;
+#define IEEE80211_HW_HOST_GEN_BEACON (1<<0)
 
 	/* The device needs to be supplied with a beacon template only. */
-	unsigned int host_gen_beacon_template:1;
+#define IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE (1<<1)
 
 	/* Some devices handle decryption internally and do not
 	 * indicate whether the frame was encrypted (unencrypted frames
 	 * will be dropped by the hardware, unless specifically allowed
 	 * through) */
-	unsigned int device_hides_wep:1;
+#define IEEE80211_HW_DEVICE_HIDES_WEP (1<<2)
 
 	/* Whether RX frames passed to ieee80211_rx() include FCS in the end */
-	unsigned int rx_includes_fcs:1;
+#define IEEE80211_HW_RX_INCLUDES_FCS (1<<3)
 
 	/* Some wireless LAN chipsets buffer broadcast/multicast frames for
 	 * power saving stations in the hardware/firmware and others rely on
@@ -459,14 +459,15 @@ struct ieee80211_hw {
 	 * configure the IEEE 802.11 upper layer to buffer broadcast/multicast
 	 * frames when there are power saving stations so that low-level driver
 	 * can fetch them with ieee80211_get_buffered_bc(). */
-	unsigned int host_broadcast_ps_buffering:1;
+#define IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING (1<<4)
 
-	unsigned int wep_include_iv:1;
-	unsigned int data_nullfunc_ack:1; /* will data nullfunc frames get proper
-					   * TX status callback */
+#define IEEE80211_HW_WEP_INCLUDE_IV (1<<5)
+
+	/* will data nullfunc frames get proper TX status callback */
+#define IEEE80211_HW_DATA_NULLFUNC_ACK (1<<6)
 
 	/* Force software encryption for TKIP packets if WMM is enabled. */
-	unsigned int no_tkip_wmm_hwaccel:1;
+#define IEEE80211_HW_NO_TKIP_WMM_HWACCEL (1<<7)
 
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets passed up. device_strips_mic must be set
@@ -474,15 +475,17 @@ struct ieee80211_hw {
 	 * be still set in the IEEE 802.11 header with this option unlike with
 	 * the device_hides_wep configuration option.
 	 */
-	unsigned int device_strips_mic:1;
+#define IEEE80211_HW_DEVICE_STRIPS_MIC (1<<8)
 
 	/* Device is capable of performing full monitor mode even during
 	 * normal operation. */
-	unsigned int monitor_during_oper:1;
+#define IEEE80211_HW_MONITOR_DURING_OPER (1<<9)
 
 	/* Set if the low-level driver supports skb fraglist (NETIF_F_FRAGLIST),
 	 * i.e. more than one skb per frame */
-	unsigned int fraglist:1;
+#define IEEE80211_HW_FRAGLIST (1<<10)
+
+	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
 	unsigned int extra_tx_headroom;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3971,9 +3971,10 @@ static int __devinit bcm43xx_init_one(st
 		goto out;
 	ieee->version = IEEE80211_VERSION;
 	ieee->name = KBUILD_MODNAME;
-	ieee->host_gen_beacon_template = 1;
-	ieee->rx_includes_fcs = 0;
-	ieee->monitor_during_oper = 1;
+	ieee->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
+		      IEEE80211_HW_MONITOR_DURING_OPER |
+		      IEEE80211_HW_DEVICE_HIDES_WEP |
+		      IEEE80211_HW_WEP_INCLUDE_IV;
 	ieee->maxssi = BCM43xx_RX_MAX_SSI;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
@@ -3985,12 +3986,10 @@ static int __devinit bcm43xx_init_one(st
 	ieee->config_interface = bcm43xx_config_interface;
 	ieee->set_multicast_list = bcm43xx_set_multicast_list;
 	ieee->set_key = bcm43xx_net_set_key;
-	ieee->device_hides_wep = 1;
 	ieee->get_stats = bcm43xx_net_get_stats;
 	ieee->queues = 1;
 	ieee->get_tx_stats = bcm43xx_net_get_tx_stats;
 	ieee->conf_tx = bcm43xx_net_conf_tx;
-	ieee->wep_include_iv = 1;
 
 	net_dev = ieee80211_alloc_hw(sizeof(*bcm), bcm43xx_netdev_setup);
 	if (!net_dev) {
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -2578,18 +2578,13 @@ static int rt2400pci_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
+ 	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -2732,18 +2732,13 @@ static int rt2500pci_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -3252,18 +3252,13 @@ static int rt61pci_init_hw(struct rt2x00
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -515,7 +515,7 @@ static int wep_encrypt_skb(struct ieee80
 			return -1;
 	} else {
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
-		if (tx->local->hw->wep_include_iv) {
+		if (tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (ieee80211_wep_add_iv(tx->local, skb, tx->key) ==
 			    NULL)
 				return -1;
@@ -951,7 +951,7 @@ ieee80211_tx_h_multicast_ps_buf(struct i
 	/* broadcast/multicast frame */
 	/* If any of the associated stations is in power save mode,
 	 * the frame is buffered to be sent after DTIM beacon frame */
-	if (tx->local->hw->host_broadcast_ps_buffering &&
+	if ((tx->local->hw->flags & IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING) &&
 	    tx->sdata->type != IEEE80211_IF_TYPE_WDS &&
 	    tx->sdata->bss && atomic_read(&tx->sdata->bss->num_sta_ps) &&
 	    !(tx->fc & IEEE80211_FCTL_ORDER)) {
@@ -1896,7 +1896,7 @@ int ieee80211_if_config_beacon(struct ne
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 
-	if (!local->hw->host_gen_beacon_template)
+	if (!(local->hw->flags & IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE))
 		return 0;
 	skb = ieee80211_beacon_get(local->mdev, dev->ifindex, NULL);
 	if (!skb)
@@ -2170,7 +2170,8 @@ static inline void ieee80211_start_soft_
 	struct ieee80211_if_init_conf conf;
 
 	if (local->open_count && local->open_count == local->monitors &&
-	    !local->hw->monitor_during_oper && local->hw->remove_interface) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) &&
+	    local->hw->remove_interface) {
 		conf.if_id = -1;
 		conf.type = IEEE80211_IF_TYPE_MNTR;
 		conf.mac_addr = NULL;
@@ -2185,7 +2186,8 @@ static void ieee80211_start_hard_monitor
 	struct ieee80211_if_init_conf conf;
 
 	if (local->open_count && local->open_count == local->monitors &&
-	    !local->hw->monitor_during_oper && local->hw->add_interface) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) &&
+	    local->hw->add_interface) {
 		conf.if_id = -1;
 		conf.type = IEEE80211_IF_TYPE_MNTR;
 		conf.mac_addr = NULL;
@@ -2216,7 +2218,7 @@ static int ieee80211_open(struct net_dev
 		return -ENOLINK;
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR && local->open_count &&
-	    !local->hw->monitor_during_oper) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER)) {
 		/* run the interface in a "soft monitor" mode */
 		local->monitors++;
 		local->open_count++;
@@ -2280,7 +2282,8 @@ static int ieee80211_stop(struct net_dev
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR &&
-	    local->open_count > 1 && !local->hw->monitor_during_oper) {
+	    local->open_count > 1 &&
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER)) {
 		/* remove "soft monitor" interface */
 		local->open_count--;
 		local->monitors--;
@@ -3035,7 +3038,8 @@ ieee80211_rx_h_check(struct ieee80211_tx
 			rx->sta->last_seq_ctrl[rx->u.rx.queue] = hdr->seq_ctrl;
 	}
 
-	if (rx->local->hw->rx_includes_fcs && rx->skb->len > FCS_LEN)
+	if ((rx->local->hw->flags & IEEE80211_HW_RX_INCLUDES_FCS) &&
+	    rx->skb->len > FCS_LEN)
 		skb_trim(rx->skb, rx->skb->len - FCS_LEN);
 
 	if (unlikely(rx->skb->len < 16)) {
@@ -3095,7 +3099,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		else
 			rx->key = rx->sdata->default_key;
 
-		if (rx->local->hw->wep_include_iv &&
+		if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 		    rx->fc & IEEE80211_FCTL_PROTECTED) {
 			int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 
@@ -3206,7 +3210,7 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
-	if (rx->local->hw->wep_include_iv ||
+	if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) ||
 	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
 		u8 *iv = ieee80211_wep_is_weak_iv(rx->skb, rx->key);
 		if (iv) {
@@ -3222,7 +3226,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_wep_decrypt(struct ieee80211_txrx_data *rx)
 {
 	/* If the device handles decryption totally, skip this test */
-	if (rx->local->hw->device_hides_wep)
+	if (rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP)
 		return TXRX_CONTINUE;
 
 	if ((rx->key && rx->key->alg != ALG_WEP) ||
@@ -3245,7 +3249,7 @@ ieee80211_rx_h_wep_decrypt(struct ieee80
 			       "failed\n", rx->dev->name);
 			return TXRX_DROP;
 		}
-	} else if (rx->local->hw->wep_include_iv) {
+	} else if (rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 		ieee80211_wep_remove_iv(rx->local, rx->skb, rx->key);
 		/* remove ICV */
 		skb_trim(rx->skb, rx->skb->len - 4);
@@ -3290,7 +3294,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_drop_unencrypted(struct ieee80211_txrx_data *rx)
 {
 	/*  If the device handles decryption totally, skip this test */
-	if (rx->local->hw->device_hides_wep)
+	if (rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP)
 		return TXRX_CONTINUE;
 
 	/* Drop unencrypted frames if key is set. */
@@ -3359,7 +3363,7 @@ ieee80211_rx_h_passive_scan(struct ieee8
 			local->scan.rx_beacon++;
 			/* Need to trim FCS here because it is normally
 			 * removed only after this passive scan handler. */
-			if (rx->local->hw->rx_includes_fcs &&
+			if ((rx->local->hw->flags & IEEE80211_HW_RX_INCLUDES_FCS) &&
 			    rx->skb->len > FCS_LEN)
 				skb_trim(rx->skb, rx->skb->len - FCS_LEN);
 
@@ -3452,7 +3456,7 @@ static void ieee80211_rx_michael_mic_rep
 		goto ignore;
 	}
 
-	if (rx->local->hw->wep_include_iv &&
+	if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 	    rx->sdata->type == IEEE80211_IF_TYPE_AP) {
 		int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 		/* AP with Pairwise keys support should never receive Michael
@@ -4499,7 +4503,7 @@ int ieee80211_register_hw(struct net_dev
 	if (result < 0)
 		goto fail_sta_info;
 
-	if (hw->fraglist)
+	if (hw->flags & IEEE80211_HW_FRAGLIST)
 		dev->features |= NETIF_F_FRAGLIST;
 	rtnl_lock();
 	result = dev_alloc_name(dev, dev->name);
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -126,7 +126,7 @@ static int ieee80211_ioctl_get_hw_featur
 	struct ieee80211_channel_data *chan;
 
 	param->u.hw_features.flags = 0;
-	if (local->hw->data_nullfunc_ack)
+	if (local->hw->flags & IEEE80211_HW_DATA_NULLFUNC_ACK)
 		param->u.hw_features.flags |= HOSTAP_HW_FLAG_NULLFUNC_OK;
 
 	param->u.hw_features.num_modes = local->hw->num_modes;
@@ -594,14 +594,15 @@ static int ieee80211_set_encryption(stru
 		try_hwaccel = 0;
 	}
 
-	if (local->hw->device_hides_wep) {
+	if (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP) {
 		/* Software encryption cannot be used with devices that hide
 		 * encryption from the host system, so always try to use
 		 * hardware acceleration with such devices. */
 		try_hwaccel = 1;
 	}
 
-	if (local->hw->no_tkip_wmm_hwaccel && alg == ALG_TKIP) {
+	if ((local->hw->flags & IEEE80211_HW_NO_TKIP_WMM_HWACCEL) &&
+	    alg == ALG_TKIP) {
 		if (sta && (sta->flags & WLAN_STA_WME)) {
 		/* Hardware does not support hwaccel with TKIP when using WMM.
 		 */
@@ -2297,7 +2298,7 @@ static void ieee80211_key_enable_hwaccel
 	u8 addr[ETH_ALEN];
 
 	if (!key || key->alg != ALG_WEP || !key->force_sw_encrypt ||
-	    local->hw->device_hides_wep)
+	    (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP))
 		return;
 
 	memset(addr, 0xff, ETH_ALEN);
@@ -2319,7 +2320,7 @@ static void ieee80211_key_disable_hwacce
 	u8 addr[ETH_ALEN];
 
 	if (!key || key->alg != ALG_WEP || key->force_sw_encrypt ||
-	    local->hw->device_hides_wep)
+	    (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP))
 		return;
 
 	memset(addr, 0xff, ETH_ALEN);
Index: wireless-dev/net/d80211/wpa.c
===================================================================
--- wireless-dev.orig/net/d80211/wpa.c
+++ wireless-dev/net/d80211/wpa.c
@@ -168,8 +168,8 @@ ieee80211_rx_h_michael_mic_verify(struct
 	fc = rx->fc;
 
 	/* If device handles decryption totally, skip this check */
-	if (rx->local->hw->device_hides_wep ||
-	    rx->local->hw->device_strips_mic)
+	if ((rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP) ||
+	    (rx->local->hw->flags & IEEE80211_HW_DEVICE_STRIPS_MIC))
 		return TXRX_CONTINUE;
 
 	if (!rx->key || rx->key->alg != ALG_TKIP ||
@@ -184,7 +184,7 @@ ieee80211_rx_h_michael_mic_verify(struct
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
-		if (rx->local->hw->wep_include_iv) {
+		if (rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (skb->len < MICHAEL_MIC_LEN)
 				return TXRX_DROP;
 		}
@@ -400,7 +400,8 @@ ieee80211_tx_h_tkip_encrypt(struct ieee8
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->local->hw->wep_include_iv && !wpa_test) {
+	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
+	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		return TXRX_CONTINUE;
@@ -478,7 +479,7 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
-		if (!rx->local->hw->wep_include_iv) {
+		if (!(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 			/* Hardware takes care of all processing, including
 			 * replay protection, so no need to continue here. */
 			return TXRX_CONTINUE;
@@ -717,7 +718,7 @@ ieee80211_tx_h_ccmp_encrypt(struct ieee8
 	ieee80211_tx_set_iswep(tx);
 
 	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->local->hw->wep_include_iv) {
+	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
 		 * header or MIC fields */
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
@@ -769,7 +770,7 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !key->force_sw_encrypt && !rx->local->conf.sw_decrypt &&
-	    !rx->local->hw->wep_include_iv)
+	    !(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV))
 		return TXRX_CONTINUE;
 
 	(void) ccmp_hdr2pn(pn, skb->data + hdrlen);
Index: wireless-dev/net/d80211/ieee80211_sysfs.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c
+++ wireless-dev/net/d80211/ieee80211_sysfs.c
@@ -530,9 +530,10 @@ static ssize_t ieee80211_if_fmt_mode(con
 {
 	struct ieee80211_local *local = sdata->local;
 
-	return sprintf(buf, "%s\n", (local->hw->monitor_during_oper ||
-				     local->open_count == local->monitors) ?
-				    "hard" : "soft");
+	return sprintf(buf, "%s\n",
+		       ((local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) ||
+			local->open_count == local->monitors) ?
+		       "hard" : "soft");
 }
 __IEEE80211_IF_SHOW(mode);
 
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -2420,18 +2420,14 @@ static int rt2500usb_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -2793,18 +2793,13 @@ static int rt73usb_init_hw(struct rt2x00
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
Index: wireless-dev/drivers/net/wireless/d80211/p54/prism54common.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/p54/prism54common.c
+++ wireless-dev/drivers/net/wireless/d80211/p54/prism54common.c
@@ -633,17 +633,12 @@ void p54_init_common(struct net_device *
 	priv->modes[0].num_channels = ARRAY_SIZE(p54_channels);
 	priv->modes[0].channels = priv->channels;
 	hw->version = 2;
-	hw->host_gen_beacon = 0;
-	hw->host_gen_beacon_template = 1;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 1;
-	hw->host_broadcast_ps_buffering = 1; /* not sure */
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1; /* TODO: check */
-	hw->no_tkip_wmm_hwaccel = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 0; /* FIXME: check */
-	hw->fraglist = 0;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING | /* not sure */
+		    IEEE80211_HW_RX_INCLUDES_FCS |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK; /* TODO: check */
+		    /* IEEE80211_HW_MONITOR_DURING_OPER FIXME: check */
 	hw->channel_change_time = 1000;	/* TODO: find actual value */
 
 	hw->num_modes = 2;

--
