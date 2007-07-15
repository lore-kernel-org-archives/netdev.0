From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH v2 1/2] mac80211: improved short preamble handling
Date: Sun, 15 Jul 2007 15:07:39 +0100 (BST)
Message-ID: <20070715140739.C13187B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:34205 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755482AbXGOOHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 10:07:48 -0400
Cc: linux-wireless@vger.kernel.org
Cc: linville@tuxdriver.com
Cc: rt2400-devel@lists.sourceforge.net
Cc: mb@bu3sch.de
Cc: flamingice@sourmilk.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similarly to CTS protection, whether short preambles are used for 802.11b
transmissions should be a per-subif setting, not device global.

For STAs, this patch makes short preamble handling automatic based on the ERP
IE. For APs, hostapd still uses the prism ioctls, but the write ioctl has been
restricted to AP-only subifs.

ieee80211_txrx_data.short_preamble (an unused field) was removed.

Unfortunately, some API changes were required for the following functions:
 - ieee80211_generic_frame_duration
 - ieee80211_rts_duration
 - ieee80211_ctstoself_duration
 - ieee80211_rts_get
 - ieee80211_ctstoself_get
Affected drivers (bcm43xx, rt2x00 and rtl8187) were updated accordingly.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

---
Changes since first submission: added dev_put calls pointed out by Jiri Benc,
updated for new rtl818x driver location

Index: wireless-dev/net/mac80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211.c
+++ wireless-dev/net/mac80211/ieee80211.c
@@ -443,12 +443,6 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 		tx->u.tx.control->rate = tx->u.tx.rate;
 	}
 	tx->u.tx.control->tx_rate = tx->u.tx.rate->val;
-	if ((tx->u.tx.rate->flags & IEEE80211_RATE_PREAMBLE2) &&
-	    tx->local->short_preamble &&
-	    (!tx->sta || (tx->sta->flags & WLAN_STA_SHORT_PREAMBLE))) {
-		tx->u.tx.short_preamble = 1;
-		tx->u.tx.control->tx_rate = tx->u.tx.rate->val2;
-	}
 
 	return TXRX_CONTINUE;
 }
@@ -699,17 +693,24 @@ static int ieee80211_frame_duration(stru
 
 
 /* Exported duration function for driver use */
-__le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw, int if_id,
 					size_t frame_len, int rate)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct net_device *bdev = dev_get_by_index(if_id);
+	struct ieee80211_sub_if_data *sdata;
 	u16 dur;
 	int erp;
 
+	if (unlikely(!bdev))
+		return 0;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
 	erp = ieee80211_is_erp_rate(hw->conf.phymode, rate);
 	dur = ieee80211_frame_duration(local, frame_len, rate,
-				       erp, local->short_preamble);
+				       erp, sdata->short_preamble);
 
+	dev_put(bdev);
 	return cpu_to_le16(dur);
 }
 EXPORT_SYMBOL(ieee80211_generic_frame_duration);
@@ -805,7 +806,7 @@ static u16 ieee80211_duration(struct iee
 	 * to closest integer */
 
 	dur = ieee80211_frame_duration(local, 10, rate, erp,
-				       local->short_preamble);
+				       tx->sdata->short_preamble);
 
 	if (next_frag_len) {
 		/* Frame is fragmented: duration increases with time needed to
@@ -814,7 +815,7 @@ static u16 ieee80211_duration(struct iee
 		/* next fragment */
 		dur += ieee80211_frame_duration(local, next_frag_len,
 						txrate->rate, erp,
-						local->short_preamble);
+						tx->sdata->short_preamble);
 	}
 
 	return dur;
@@ -825,6 +826,7 @@ static ieee80211_txrx_result
 ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
+	u16 fc = le16_to_cpu(hdr->frame_control);
 	u16 dur;
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 	struct ieee80211_hw_mode *mode = tx->u.tx.mode;
@@ -860,6 +862,16 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
+	/* Transmit data frames using short preambles if the driver supports
+	 * short preambles at the selected rate and short preambles are
+	 * available on the network at the current point in time. */
+	if (((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) &&
+	    (tx->u.tx.rate->flags & IEEE80211_RATE_PREAMBLE2) &&
+	    tx->sdata->short_preamble &&
+	    (!tx->sta || (tx->sta->flags & WLAN_STA_SHORT_PREAMBLE))) {
+		tx->u.tx.control->tx_rate = tx->u.tx.rate->val2;
+	}
+
 	/* Setup duration field for the first fragment of the frame. Duration
 	 * for remaining fragments will be updated when they are being sent
 	 * to low-level driver in ieee80211_tx(). */
@@ -1883,7 +1895,7 @@ struct sk_buff * ieee80211_beacon_get(st
 			return NULL;
 		}
 
-		control->tx_rate = (local->short_preamble &&
+		control->tx_rate = (sdata->short_preamble &&
 				    (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
 			rate->val2 : rate->val;
 		control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
@@ -1898,16 +1910,24 @@ struct sk_buff * ieee80211_beacon_get(st
 }
 EXPORT_SYMBOL(ieee80211_beacon_get);
 
-__le16 ieee80211_rts_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_rts_duration(struct ieee80211_hw *hw, int if_id,
 			      size_t frame_len,
 			      const struct ieee80211_tx_control *frame_txctl)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_rate *rate;
-	int short_preamble = local->short_preamble;
+	struct net_device *bdev = dev_get_by_index(if_id);
+	struct ieee80211_sub_if_data *sdata;
+	int short_preamble;
 	int erp;
 	u16 dur;
 
+	if (unlikely(!bdev))
+		return 0;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
+	short_preamble = sdata->short_preamble;
+
 	rate = frame_txctl->rts_rate;
 	erp = !!(rate->flags & IEEE80211_RATE_ERP);
 
@@ -1921,21 +1941,30 @@ __le16 ieee80211_rts_duration(struct iee
 	dur += ieee80211_frame_duration(local, 10, rate->rate,
 					erp, short_preamble);
 
+	dev_put(bdev);
 	return cpu_to_le16(dur);
 }
 EXPORT_SYMBOL(ieee80211_rts_duration);
 
 
-__le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw, int if_id,
 				    size_t frame_len,
 				    const struct ieee80211_tx_control *frame_txctl)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_rate *rate;
-	int short_preamble = local->short_preamble;
+	struct net_device *bdev = dev_get_by_index(if_id);
+	struct ieee80211_sub_if_data *sdata;
+	int short_preamble;
 	int erp;
 	u16 dur;
 
+	if (unlikely(!bdev))
+		return 0;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(bdev);
+	short_preamble = sdata->short_preamble;
+
 	rate = frame_txctl->rts_rate;
 	erp = !!(rate->flags & IEEE80211_RATE_ERP);
 
@@ -1948,11 +1977,12 @@ __le16 ieee80211_ctstoself_duration(stru
 						erp, short_preamble);
 	}
 
+	dev_put(bdev);
 	return cpu_to_le16(dur);
 }
 EXPORT_SYMBOL(ieee80211_ctstoself_duration);
 
-void ieee80211_rts_get(struct ieee80211_hw *hw,
+void ieee80211_rts_get(struct ieee80211_hw *hw, int if_id,
 		       const void *frame, size_t frame_len,
 		       const struct ieee80211_tx_control *frame_txctl,
 		       struct ieee80211_rts *rts)
@@ -1962,13 +1992,13 @@ void ieee80211_rts_get(struct ieee80211_
 
 	fctl = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	rts->frame_control = cpu_to_le16(fctl);
-	rts->duration = ieee80211_rts_duration(hw, frame_len, frame_txctl);
+	rts->duration = ieee80211_rts_duration(hw, if_id, frame_len, frame_txctl);
 	memcpy(rts->ra, hdr->addr1, sizeof(rts->ra));
 	memcpy(rts->ta, hdr->addr2, sizeof(rts->ta));
 }
 EXPORT_SYMBOL(ieee80211_rts_get);
 
-void ieee80211_ctstoself_get(struct ieee80211_hw *hw,
+void ieee80211_ctstoself_get(struct ieee80211_hw *hw, int if_id,
 			     const void *frame, size_t frame_len,
 			     const struct ieee80211_tx_control *frame_txctl,
 			     struct ieee80211_cts *cts)
@@ -1978,7 +2008,8 @@ void ieee80211_ctstoself_get(struct ieee
 
 	fctl = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CTS;
 	cts->frame_control = cpu_to_le16(fctl);
-	cts->duration = ieee80211_ctstoself_duration(hw, frame_len, frame_txctl);
+	cts->duration = ieee80211_ctstoself_duration(hw, if_id, frame_len,
+						     frame_txctl);
 	memcpy(cts->ra, hdr->addr1, sizeof(cts->ra));
 }
 EXPORT_SYMBOL(ieee80211_ctstoself_get);
Index: wireless-dev/net/mac80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_i.h
+++ wireless-dev/net/mac80211/ieee80211_i.h
@@ -132,7 +132,6 @@ struct ieee80211_txrx_data {
 			struct ieee80211_tx_control *control;
 			unsigned int unicast:1;
 			unsigned int ps_buffered:1;
-			unsigned int short_preamble:1;
 			unsigned int probe_last_frag:1;
 			struct ieee80211_hw_mode *mode;
 			struct ieee80211_rate *rate;
@@ -322,6 +321,11 @@ struct ieee80211_sub_if_data {
 	unsigned int promisc:1;
 	unsigned int use_protection:1; /* CTS protect ERP frames */
 
+	/* use short preamble with IEEE 802.11b: this flag is set when the AP
+	 * or beacon generator reports that there are no present stations that
+	 * cannot support short preambles */
+	unsigned int short_preamble:1;
+
 	struct net_device_stats stats;
 	int drop_unencrypted;
 	int eapol; /* 0 = process EAPOL frames as normal data frames,
@@ -516,7 +520,6 @@ struct ieee80211_local {
 	int fragmentation_threshold;
 	int short_retry_limit; /* dot11ShortRetryLimit */
 	int long_retry_limit; /* dot11LongRetryLimit */
-	int short_preamble; /* use short preamble with IEEE 802.11b */
 
 	struct crypto_blkcipher *wep_tx_tfm;
 	struct crypto_blkcipher *wep_rx_tfm;
Index: wireless-dev/net/mac80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_sta.c
+++ wireless-dev/net/mac80211/ieee80211_sta.c
@@ -357,6 +357,7 @@ static void ieee80211_handle_erp_ie(stru
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
 	int use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
+	int preamble_mode = (erp_value & WLAN_ERP_BARKER_PREAMBLE) != 0;
 
 	if (use_protection != sdata->use_protection) {
 		if (net_ratelimit()) {
@@ -368,6 +369,18 @@ static void ieee80211_handle_erp_ie(stru
 		}
 		sdata->use_protection = use_protection;
 	}
+
+	if (!preamble_mode != sdata->short_preamble) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: switched to %s barker preamble"
+			       " (BSSID=" MAC_FMT ")\n",
+			       dev->name,
+			       (preamble_mode == WLAN_ERP_PREAMBLE_SHORT) ?
+					"short" : "long",
+			       MAC_ARG(ifsta->bssid));
+		}
+		sdata->short_preamble = !preamble_mode;
+	}
 }
 
 
@@ -454,6 +467,7 @@ static void ieee80211_set_associated(str
 		ieee80211_sta_send_associnfo(dev, ifsta);
 	} else {
 		netif_carrier_off(dev);
+		sdata->short_preamble = 0;
 		sdata->use_protection = 0;
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
 	}
@@ -3214,7 +3228,7 @@ static int ieee80211_sta_join_ibss(struc
 			       "for IBSS beacon\n", dev->name);
 			break;
 		}
-		control.tx_rate = (local->short_preamble &&
+		control.tx_rate = (sdata->short_preamble &&
 				   (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
 			rate->val2 : rate->val;
 		control.antenna_sel_tx = local->hw.conf.antenna_sel_tx;
Index: wireless-dev/net/mac80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_ioctl.c
+++ wireless-dev/net/mac80211/ieee80211_ioctl.c
@@ -2327,7 +2327,10 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
-		local->short_preamble = value;
+		if (sdata->type != IEEE80211_IF_TYPE_AP)
+			ret = -ENOENT;
+		else
+			sdata->short_preamble = value;
 		break;
 
 	case PRISM2_PARAM_STAT_TIME:
@@ -2557,7 +2560,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
-		*param = local->short_preamble;
+		*param = sdata->short_preamble;
 		break;
 
 	case PRISM2_PARAM_STAT_TIME:
Index: wireless-dev/drivers/net/wireless/mac80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/mac80211/bcm43xx/bcm43xx_xmit.c
+++ wireless-dev/drivers/net/wireless/mac80211/bcm43xx/bcm43xx_xmit.c
@@ -220,6 +220,7 @@ static void generate_txhdr_fw4(struct bc
 	} else {
 		int fbrate_base100kbps = BCM43xx_RATE_TO_BASE100KBPS(rate_fb);
 		txhdr->dur_fb = ieee80211_generic_frame_duration(dev->wl->hw,
+								 dev->wl->if_id,
 								 fragment_len,
 								 fbrate_base100kbps);
 	}
@@ -308,13 +309,13 @@ static void generate_txhdr_fw4(struct bc
 		rts_rate_fb_ofdm = bcm43xx_is_ofdm_rate(rts_rate_fb);
 
 		if (txctl->flags & IEEE80211_TXCTL_USE_CTS_PROTECT) {
-			ieee80211_ctstoself_get(dev->wl->hw,
+			ieee80211_ctstoself_get(dev->wl->hw, dev->wl->if_id,
 						fragment_data, fragment_len, txctl,
 						(struct ieee80211_cts *)(txhdr->rts_frame));
 			mac_ctl |= BCM43xx_TX4_MAC_SENDCTS;
 			len = sizeof(struct ieee80211_cts);
 		} else {
-			ieee80211_rts_get(dev->wl->hw,
+			ieee80211_rts_get(dev->wl->hw, dev->wl->if_id,
 					  fragment_data, fragment_len, txctl,
 					  (struct ieee80211_rts *)(txhdr->rts_frame));
 			mac_ctl |= BCM43xx_TX4_MAC_SENDRTS;
Index: wireless-dev/drivers/net/wireless/rtl8187.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/rtl8187.h
+++ wireless-dev/drivers/net/wireless/rtl8187.h
@@ -67,6 +67,7 @@ struct rtl8187_priv {
 	struct rtl818x_csr *map;
 	void (*rf_init)(struct ieee80211_hw *);
 	int mode;
+	int if_id;
 
 	/* rtl8187 specific */
 	struct ieee80211_channel channels[14];
Index: wireless-dev/drivers/net/wireless/rtl8187_dev.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/rtl8187_dev.c
+++ wireless-dev/drivers/net/wireless/rtl8187_dev.c
@@ -96,7 +96,7 @@ static int rtl8187_tx(struct ieee80211_h
 	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
 		tmp |= RTL8187_TX_FLAG_RTS;
 		hdr->rts_duration =
-			ieee80211_rts_duration(dev, skb->len, control);
+			ieee80211_rts_duration(dev, priv->if_id, skb->len, control);
 	}
 	if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
 		tmp |= RTL8187_TX_FLAG_CTS;
@@ -510,6 +510,8 @@ static int rtl8187_config_interface(stru
 	struct rtl8187_priv *priv = dev->priv;
 	int i;
 
+	priv->if_id = if_id;
+
 	for (i = 0; i < ETH_ALEN; i++)
 		rtl818x_iowrite8(priv, &priv->map->BSSID[i], conf->bssid[i]);
 
Index: wireless-dev/include/net/mac80211.h
===================================================================
--- wireless-dev.orig/include/net/mac80211.h
+++ wireless-dev/include/net/mac80211.h
@@ -837,6 +837,7 @@ struct sk_buff *ieee80211_beacon_get(str
 /**
  * ieee80211_rts_get - RTS frame generation function
  * @hw: pointer obtained from ieee80211_alloc_hw().
+ * @if_id: interface ID from &struct ieee80211_if_init_conf.
  * @frame: pointer to the frame that is going to be protected by the RTS.
  * @frame_len: the frame length (in octets).
  * @frame_txctl: &struct ieee80211_tx_control of the frame.
@@ -847,7 +848,7 @@ struct sk_buff *ieee80211_beacon_get(str
  * the next RTS frame from the 802.11 code. The low-level is responsible
  * for calling this function before and RTS frame is needed.
  */
-void ieee80211_rts_get(struct ieee80211_hw *hw,
+void ieee80211_rts_get(struct ieee80211_hw *hw, int if_id,
 		       const void *frame, size_t frame_len,
 		       const struct ieee80211_tx_control *frame_txctl,
 		       struct ieee80211_rts *rts);
@@ -855,6 +856,7 @@ void ieee80211_rts_get(struct ieee80211_
 /**
  * ieee80211_rts_duration - Get the duration field for an RTS frame
  * @hw: pointer obtained from ieee80211_alloc_hw().
+ * @if_id: interface ID from &struct ieee80211_if_init_conf.
  * @frame_len: the length of the frame that is going to be protected by the RTS.
  * @frame_txctl: &struct ieee80211_tx_control of the frame.
  *
@@ -862,13 +864,14 @@ void ieee80211_rts_get(struct ieee80211_
  * the duration field, the low-level driver uses this function to receive
  * the duration field value in little-endian byteorder.
  */
-__le16 ieee80211_rts_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_rts_duration(struct ieee80211_hw *hw, int if_id,
 			      size_t frame_len,
 			      const struct ieee80211_tx_control *frame_txctl);
 
 /**
  * ieee80211_ctstoself_get - CTS-to-self frame generation function
  * @hw: pointer obtained from ieee80211_alloc_hw().
+ * @if_id: interface ID from &struct ieee80211_if_init_conf.
  * @frame: pointer to the frame that is going to be protected by the CTS-to-self.
  * @frame_len: the frame length (in octets).
  * @frame_txctl: &struct ieee80211_tx_control of the frame.
@@ -879,7 +882,7 @@ __le16 ieee80211_rts_duration(struct iee
  * the next CTS-to-self frame from the 802.11 code. The low-level is responsible
  * for calling this function before and CTS-to-self frame is needed.
  */
-void ieee80211_ctstoself_get(struct ieee80211_hw *hw,
+void ieee80211_ctstoself_get(struct ieee80211_hw *hw, int if_id,
 			     const void *frame, size_t frame_len,
 			     const struct ieee80211_tx_control *frame_txctl,
 			     struct ieee80211_cts *cts);
@@ -887,6 +890,7 @@ void ieee80211_ctstoself_get(struct ieee
 /**
  * ieee80211_ctstoself_duration - Get the duration field for a CTS-to-self frame
  * @hw: pointer obtained from ieee80211_alloc_hw().
+ * @if_id: interface ID from &struct ieee80211_if_init_conf.
  * @frame_len: the length of the frame that is going to be protected by the CTS-to-self.
  * @frame_txctl: &struct ieee80211_tx_control of the frame.
  *
@@ -894,20 +898,21 @@ void ieee80211_ctstoself_get(struct ieee
  * the duration field, the low-level driver uses this function to receive
  * the duration field value in little-endian byteorder.
  */
-__le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw, int if_id,
 				    size_t frame_len,
 				    const struct ieee80211_tx_control *frame_txctl);
 
 /**
  * ieee80211_generic_frame_duration - Calculate the duration field for a frame
  * @hw: pointer obtained from ieee80211_alloc_hw().
+ * @if_id: interface ID from &struct ieee80211_if_init_conf.
  * @frame_len: the length of the frame.
  * @rate: the rate (in 100kbps) at which the frame is going to be transmitted.
  *
  * Calculate the duration field of some generic frame, given its
  * length and transmission rate (in 100kbps).
  */
-__le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw,
+__le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw, int if_id,
 					size_t frame_len,
 					int rate);
 
Index: wireless-dev/drivers/net/wireless/mac80211/rt2x00/rt2x00mac.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/mac80211/rt2x00/rt2x00mac.c
+++ wireless-dev/drivers/net/wireless/mac80211/rt2x00/rt2x00mac.c
@@ -57,11 +57,11 @@ static int rt2x00_tx_rts_cts(struct rt2x
 	skb_put(skb, size);
 
 	if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
-		ieee80211_ctstoself_get(rt2x00dev->hw,
+		ieee80211_ctstoself_get(rt2x00dev->hw, rt2x00dev->interface.if_id,
 			frag_skb->data, frag_skb->len, control,
 			(struct ieee80211_cts*)(skb->data));
 	else
-		ieee80211_rts_get(rt2x00dev->hw,
+		ieee80211_rts_get(rt2x00dev->hw, rt2x00dev->interface.if_id,
 			frag_skb->data, frag_skb->len, control,
 			(struct ieee80211_rts*)(skb->data));
 
