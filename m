From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 23/24] RT2x00: Fix register initialization
Date: Wed, 26 Jul 2006 19:05:54 +0200
Message-ID: <200607261905.54825.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030334AbWGZRHw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:52 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:51 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Thanks to ethtool a lot of problems with initialization
of the registers has been discovered.
This will correctly initialize all registers.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 12:49:38.000000000 +0200
+++ wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 14:04:13.000000000 +0200
@@ -482,6 +482,8 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
 		return;
 
+	rt2x00_register_write(rt2x00dev, CSR14, 0);
+
 	/*
 	 * Apply hardware packet filter.
 	 */
@@ -513,16 +515,40 @@
 		rt2400pci_config_promisc(rt2x00dev, 1);
 
 	/*
+	 * Enable beacon config
+	 */
+	rt2x00_register_read(rt2x00dev, BCNCSR1, &reg);
+	rt2x00_set_field32(&reg, BCNCSR1_PRELOAD,
+		PREAMBLE + get_duration(IEEE80211_HEADER, 2));
+	rt2x00_register_write(rt2x00dev, BCNCSR1, reg);
+
+	/*
 	 * Enable synchronisation.
 	 */
+	rt2x00_register_read(rt2x00dev, CSR12, &reg);
+	rt2x00_set_field32(&reg, CSR12_BEACON_INTERVAL, 100 * 16);
+	rt2x00_set_field32(&reg, CSR12_CFP_MAX_DURATION, 100 * 16);
+	rt2x00_register_write(rt2x00dev, CSR12, reg);
+
 	rt2x00_register_read(rt2x00dev, CSR14, &reg);
-	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
-	if (type == IEEE80211_IF_TYPE_IBSS)
+	if (type != IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
+		rt2x00_set_field32(&reg, CSR14_TBCN, 1);
+	}
+
+	if (type == IEEE80211_IF_TYPE_IBSS) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
-	else if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_STA) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
-	else
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	} else if (type == IEEE80211_IF_TYPE_AP) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	}
 	rt2x00_register_write(rt2x00dev, CSR14, reg);
 
 	/*
@@ -726,7 +752,7 @@
 
 	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
 
-	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
+	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
@@ -830,8 +856,8 @@
 
 	rt2x00_register_read(rt2x00dev, LEDCSR, &reg);
 
-	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
-	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
+	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 70);
+	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 30);
 
 	if (rt2x00dev->led_mode == LED_MODE_TXRX_ACTIVITY) {
 		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
diff -rU3 wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 12:50:25.000000000 +0200
+++ wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 14:04:55.000000000 +0200
@@ -482,6 +482,8 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
 		return;
 
+	rt2x00_register_write(rt2x00dev, CSR14, 0);
+
 	/*
 	 * Apply hardware packet filter.
 	 */
@@ -516,16 +518,44 @@
 		rt2500pci_config_promisc(rt2x00dev, 1);
 
 	/*
+	 * Enable beacon config
+	 */
+	if (ring) {
+		rt2x00_register_read(rt2x00dev, BCNCSR1, &reg);
+		rt2x00_set_field32(&reg, BCNCSR1_PRELOAD,
+			PREAMBLE + get_duration(IEEE80211_HEADER, 2));
+		rt2x00_set_field32(&reg, BCNCSR1_BEACON_CWMIN,
+			rt2x00dev->ring[RING_BEACON].tx_params.cw_min);
+		rt2x00_register_write(rt2x00dev, BCNCSR1, reg);
+	}
+
+	/*
 	 * Enable synchronisation.
 	 */
+	rt2x00_register_read(rt2x00dev, CSR12, &reg);
+	rt2x00_set_field32(&reg, CSR12_BEACON_INTERVAL, 100 * 16);
+	rt2x00_set_field32(&reg, CSR12_CFPMAX_DURATION, 100 * 16);
+	rt2x00_register_write(rt2x00dev, CSR12, reg);
+
 	rt2x00_register_read(rt2x00dev, CSR14, &reg);
-	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
-	if (type == IEEE80211_IF_TYPE_IBSS)
+	if (type != IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
+		rt2x00_set_field32(&reg, CSR14_TBCN, 1);
+	}
+
+	if (type == IEEE80211_IF_TYPE_IBSS) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
-	else if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_STA) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
-	else
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	} else if (type == IEEE80211_IF_TYPE_AP) {
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_MNTR) {
 		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+		rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	}
 	rt2x00_register_write(rt2x00dev, CSR14, reg);
 
 	/*
@@ -591,8 +621,15 @@
 	 * For RT2525 we should first set the channel to half band higher.
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF2525)) {
+		static const u32 vals[] = {
+			0x00080cbe, 0x00080d02, 0x00080d06, 0x00080d0a,
+			0x00080d0e, 0x00080d12, 0x00080d16, 0x00080d1a,
+			0x00080d1e, 0x00080d22, 0x00080d26, 0x00080d2a,
+			0x00080d2e, 0x00080d3a
+		};
+
 		rt2x00_rf_write(rt2x00dev, rf1);
-		rt2x00_rf_write(rt2x00dev, rf2 + cpu_to_le32(0x00000020));
+		rt2x00_rf_write(rt2x00dev, cpu_to_le32(vals[channel - 1]));
 		rt2x00_rf_write(rt2x00dev, rf3);
 		if (rf4)
 			rt2x00_rf_write(rt2x00dev, rf4);
@@ -609,7 +646,7 @@
 	 */
 	rt2x00_bbp_write(rt2x00dev, 70, (channel == 14) ? 0x4e : 0x46);
 
-	mdelay(1);
+	msleep(1);
 
 	/*
 	 * Switch off tuning bits.
@@ -681,7 +718,7 @@
 	/*
 	 * Clear current config antenna bits.
 	 */
-	reg_rx &= ~0x06;
+	reg_rx &= ~0x03;
 	reg_tx &= ~0x03;
 
 	/*
@@ -692,12 +729,12 @@
 	if (antenna == 0) {
 		/* Diversity. */
 		reg_rx |= 0x02;
-		reg_tx |= 0x01;
+		reg_tx |= 0x02;
 		rt2x00_set_field32(&reg, BBPCSR1_CCK, 2);
 		rt2x00_set_field32(&reg, BBPCSR1_OFDM, 2);
 	} else if (antenna == 1) {
 		/* RX: Antenna B */
-		reg_rx |= 0x04;
+		reg_rx |= 0x02;
 		/* TX: Antenna A */
 		reg_tx |= 0x00;
 		rt2x00_set_field32(&reg, BBPCSR1_CCK, 0);
@@ -783,7 +820,7 @@
 
 	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
 
-	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
+	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
@@ -906,8 +943,8 @@
 
 	rt2x00_register_read(rt2x00dev, LEDCSR, &reg);
 
-	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
-	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
+	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 70);
+	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 30);
 
 	if (rt2x00dev->led_mode == LED_MODE_TXRX_ACTIVITY) {
 		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
diff -rU3 wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 12:50:28.000000000 +0200
+++ wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 13:47:29.000000000 +0200
@@ -332,6 +332,8 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
 		return;
 
+	rt2x00_register_write(rt2x00dev, TXRX_CSR19, 0);
+
 	/*
 	 * Apply hardware packet filter.
 	 */
@@ -363,16 +365,54 @@
 		rt2500usb_config_promisc(rt2x00dev, 1);
 
 	/*
+	 * Enable beacon config
+	 */
+	rt2x00_register_read(rt2x00dev, TXRX_CSR20, &reg);
+	rt2x00_set_field16_nb(&reg, TXRX_CSR20_OFFSET,
+		(PREAMBLE + get_duration(IEEE80211_HEADER, 2)) >> 6);
+	if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field16_nb(&reg, TXRX_CSR20_BCN_EXPECT_WINDOW, 0);
+	else
+		rt2x00_set_field16_nb(&reg, TXRX_CSR20_BCN_EXPECT_WINDOW, 2);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR20, reg);
+
+	/*
 	 * Enable synchronisation.
 	 */
+	rt2x00_register_read(rt2x00dev, TXRX_CSR18, &reg);
+	rt2x00_set_field16_nb(&reg, TXRX_CSR18_OFFSET, 0);
+	rt2x00_set_field16_nb(&reg, TXRX_CSR18_INTERVAL, 100 << 2);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR18, reg);
+
 	rt2x00_register_read(rt2x00dev, TXRX_CSR19, &reg);
-	rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_COUNT, 1);
-	if (type == IEEE80211_IF_TYPE_IBSS)
+	if (type != IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_COUNT, 1);
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TBCN, 1);
+	}
+
+	if (type == IEEE80211_IF_TYPE_IBSS) {
 		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 2);
-	else if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_STA) {
 		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 1);
-	else
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_BEACON_GEN, 0);
+	} else if (type == IEEE80211_IF_TYPE_AP) {
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 0);
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_MNTR) {
 		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 0);
+		rt2x00_set_field16_nb(&reg, TXRX_CSR19_BEACON_GEN, 0);
+	}
+
+	/*
+	 * Beacon generation will fail initially.
+	 * To prevent this we need to register the TXRX_CSR19
+	 * register several times.
+	 */
+	rt2x00_register_write(rt2x00dev, TXRX_CSR19, reg);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR19, 0);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR19, reg);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR19, 0);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR19, reg);
 
 	/*
@@ -450,7 +490,14 @@
 	 * For RT2525E we should first set the channel to half band higher.
 	 */
 	if (rt2x00_rf(&rt2x00dev->chip, RF2525E)) {
-		rt2x00_rf_write(rt2x00dev, rf2 + 0x00000010);
+		static const u32 vals[] = {
+			0x000008aa, 0x000008ae, 0x000008ae, 0x000008b2,
+			0x000008b2, 0x000008b6, 0x000008b6, 0x000008ba,
+			0x000008ba, 0x000008be, 0x000008b7, 0x00000902,
+			0x00000902, 0x00000906
+		};
+
+		rt2x00_rf_write(rt2x00dev, vals[channel - 1]);
 		if (rf4)
 			rt2x00_rf_write(rt2x00dev, rf4);
 	}
@@ -540,9 +587,9 @@
 		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM, 0);
 	} else if (antenna == 2) {
 		/* RX: Antenna A */
-		reg_tx |= 0x02;
-		/* TX: Antenna B */
 		reg_rx |= 0x00;
+		/* TX: Antenna B */
+		reg_tx |= 0x02;
 		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK, 2);
 		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM, 2);
 	}
@@ -737,8 +784,8 @@
 	u16 reg;
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR21, &reg);
-	rt2x00_set_field16_nb(&reg, MAC_CSR21_ON_PERIOD, 30);
-	rt2x00_set_field16_nb(&reg, MAC_CSR21_OFF_PERIOD, 70);
+	rt2x00_set_field16_nb(&reg, MAC_CSR21_ON_PERIOD, 70);
+	rt2x00_set_field16_nb(&reg, MAC_CSR21_OFF_PERIOD, 30);
 	rt2x00_register_write(rt2x00dev, MAC_CSR21, reg);
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR20, &reg);
diff -rU3 wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-26 12:50:33.000000000 +0200
+++ wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-26 13:52:16.000000000 +0200
@@ -183,7 +183,7 @@
 
 rf_write:
 	reg = value;
-	rt2x00_set_field32(&reg, PHY_CSR4_NUMBER_OF_BITS, 20);
+	rt2x00_set_field32(&reg, PHY_CSR4_NUMBER_OF_BITS, 21);
 	rt2x00_set_field32(&reg, PHY_CSR4_IF_SELECT, 0);
 	rt2x00_set_field32(&reg, PHY_CSR4_BUSY, 1);
 
@@ -480,6 +480,7 @@
 	rt2x00_set_field32(&reg[0], MAC_CSR4_BYTE3, *(bssid + 3));
 	rt2x00_set_field32(&reg[1], MAC_CSR5_BYTE4, *(bssid + 4));
 	rt2x00_set_field32(&reg[1], MAC_CSR5_BYTE5, *(bssid + 5));
+	rt2x00_set_field32(&reg[1], MAC_CSR5_BSS_ID_MASK, 3);
 
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR4, &reg[0], sizeof(reg));
 }
@@ -513,6 +514,8 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
 		return;
 
+	rt2x00_register_write(rt2x00dev, TXRX_CSR9, 0);
+
 	/*
 	 * Apply hardware packet filter.
 	 */
@@ -550,13 +553,24 @@
 	 * Enable synchronisation.
 	 */
 	rt2x00_register_read(rt2x00dev, TXRX_CSR9, &reg);
-	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 1);
-	if (type == IEEE80211_IF_TYPE_IBSS)
+	if (type != IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_INTERVAL, 100 * 16);
+		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 1);
+		rt2x00_set_field32(&reg, TXRX_CSR9_TBTT_ENABLE, 1);
+	}
+	if (type == IEEE80211_IF_TYPE_IBSS) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 2);
-	else if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_STA) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 1);
-	else
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	} else if (type == IEEE80211_IF_TYPE_AP) {
+		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 0);
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_MNTR) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 0);
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	}
 	rt2x00_register_write(rt2x00dev, TXRX_CSR9, reg);
 
 	/*
@@ -770,27 +784,27 @@
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 & cpu_to_le32(0x00000040));
+	rt2x00_rf_write(rt2x00dev, rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	udelay(200);
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 | cpu_to_le32(0x00000040));
+	rt2x00_rf_write(rt2x00dev, rf3 | cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	udelay(200);
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 & cpu_to_le32(0x00000040));
+	rt2x00_rf_write(rt2x00dev, rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	rt2x00_bbp_read(rt2x00dev, 3, &reg);
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF2527))
-		reg |= ~0x01;
+		reg &= ~0x01;
 	else
 		reg |= 0x01;
 	rt2x00_bbp_write(rt2x00dev, 3, reg);
@@ -1027,6 +1041,10 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+
+	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
+
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
 		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
@@ -1034,6 +1052,13 @@
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+
+	rt2x00_register_read(rt2x00dev, TXRX_CSR4, &reg);
+	if (preamble == SHORT_PREAMBLE)
+		rt2x00_set_field32(&reg, TXRX_CSR4_AUTORESPOND_PREAMBLE, 1);
+	else
+		rt2x00_set_field32(&reg, TXRX_CSR4_AUTORESPOND_PREAMBLE, 0);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR4, reg);
 }
 
 static void rt61pci_config_phymode(struct rt2x00_dev *rt2x00dev,
@@ -1146,8 +1171,8 @@
 	u8 arg1;
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR14, &reg);
-	rt2x00_set_field32(&reg, MAC_CSR14_ON_PERIOD, 30);
-	rt2x00_set_field32(&reg, MAC_CSR14_OFF_PERIOD, 70);
+	rt2x00_set_field32(&reg, MAC_CSR14_ON_PERIOD, 70);
+	rt2x00_set_field32(&reg, MAC_CSR14_OFF_PERIOD, 30);
 	rt2x00_register_write(rt2x00dev, MAC_CSR14, reg);
 
 	led_reg = rt2x00dev->led_reg;
@@ -2133,6 +2158,7 @@
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_DATABYTE_COUNT, skb->len);
+	rt2x00_set_field32(&txd->word11, TXD_W11_BUFFER_LENGTH0, skb->len);
 
 	if (control->queue == IEEE80211_TX_QUEUE_BEACON)
 		rt2x00_set_field32(&txd->word1,
diff -rU3 wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-26 12:50:39.000000000 +0200
+++ wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-26 13:59:03.000000000 +0200
@@ -301,6 +301,7 @@
 	rt2x00_set_field32(&reg[0], MAC_CSR4_BYTE3, *(bssid + 3));
 	rt2x00_set_field32(&reg[1], MAC_CSR5_BYTE4, *(bssid + 4));
 	rt2x00_set_field32(&reg[1], MAC_CSR5_BYTE5, *(bssid + 5));
+	rt2x00_set_field32(&reg[1], MAC_CSR5_BSS_ID_MASK, 3);
 
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR4, &reg[0], sizeof(reg));
 }
@@ -334,6 +335,8 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
 		return;
 
+	rt2x00_register_write(rt2x00dev, TXRX_CSR9, 0);
+
 	/*
 	 * Apply hardware packet filter.
 	 */
@@ -371,13 +374,25 @@
 	 * Enable synchronisation.
 	 */
 	rt2x00_register_read(rt2x00dev, TXRX_CSR9, &reg);
-	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 1);
-	if (type == IEEE80211_IF_TYPE_IBSS)
+	if (type != IEEE80211_IF_TYPE_MNTR) {
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_INTERVAL, 100 * 16);
+		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 1);
+		rt2x00_set_field32(&reg, TXRX_CSR9_TBTT_ENABLE, 1);
+	}
+
+	if (type == IEEE80211_IF_TYPE_IBSS) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 2);
-	else if (type == IEEE80211_IF_TYPE_STA)
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_STA) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 1);
-	else
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	} else if (type == IEEE80211_IF_TYPE_AP) {
+		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 0);
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 1);
+	} else if (type == IEEE80211_IF_TYPE_MNTR) {
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 0);
+		rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	}
 	rt2x00_register_write(rt2x00dev, TXRX_CSR9, reg);
 
 	/*
@@ -412,76 +427,76 @@
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225)) {
 		if (channel <= 14)
-			rf3 = 0x00068455;
+			rf3 = cpu_to_le32(0x00068455);
 		else if (channel >= 36 && channel <= 48)
-			rf3 = 0x0009be55;
+			rf3 = cpu_to_le32(0x0009be55);
 		else if (channel >= 52 && channel <= 64)
-			rf3 = 0x0009ae55;
+			rf3 = cpu_to_le32(0x0009ae55);
 		else if (channel >= 100 && channel <= 112)
-			rf3 = 0x000bae55;
+			rf3 = cpu_to_le32(0x000bae55);
 		else
-			rf3 = 0x000bbe55;
+			rf3 = cpu_to_le32(0x000bbe55);
 	}
 
 	if (channel < 14) {
 		if (channel & 0x01)
-			rf4 = 0x000fea0b;
+			rf4 = cpu_to_le32(0x000fea0b);
 		else
-			rf4 = 0x000fea1f;
+			rf4 = cpu_to_le32(0x000fea1f);
 	} else if (channel == 14) {
-		rf4 = 0x000fea13;
+		rf4 = cpu_to_le32(0x000fea13);
 	} else {
 		switch (channel) {
 			case 36:
 			case 56:
 			case 116:
 			case 136:
-				rf4 = 0x000fea23;
+				rf4 = cpu_to_le32(0x000fea23);
 				break;
 			case 40:
 			case 60:
 			case 100:
 			case 120:
 			case 140:
-				rf4 = 0x000fea03;
+				rf4 = cpu_to_le32(0x000fea03);
 				break;
 			case 44:
 			case 64:
 			case 104:
 			case 124:
-				rf4 = 0x000fea0b;
+				rf4 = cpu_to_le32(0x000fea0b);
 				break;
 			case 48:
 			case 108:
 			case 128:
-				rf4 = 0x000fea13;
+				rf4 = cpu_to_le32(0x000fea13);
 				break;
 			case 52:
 			case 112:
 			case 132:
-				rf4 = 0x000fea1b;
+				rf4 = cpu_to_le32(0x000fea1b);
 				break;
 			case 149:
-				rf4 = 0x000fea1f;
+				rf4 = cpu_to_le32(0x000fea1f);
 				break;
 			case 153:
-				rf4 = 0x000fea27;
+				rf4 = cpu_to_le32(0x000fea27);
 				break;
 			case 157:
-				rf4 = 0x000fea07;
+				rf4 = cpu_to_le32(0x000fea07);
 				break;
 			case 161:
-				rf4 = 0x000fea0f;
+				rf4 = cpu_to_le32(0x000fea0f);
 				break;
 			case 165:
-				rf4 = 0x000fea17;
+				rf4 = cpu_to_le32(0x000fea17);
 				break;
 		}
 	}
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF2527) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5225))
-		rf4 |= 0x00010000;
+		rf4 |= cpu_to_le32(0x00010000);
 
 	/*
 	 * Set TXpower.
@@ -499,24 +514,24 @@
 	rt2x00_bbp_read(rt2x00dev, 3, &reg);
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF2527))
-		reg |= ~0x01;
+		reg &= ~0x01;
 	else
 		reg |= 0x01;
 	rt2x00_bbp_write(rt2x00dev, 3, reg);
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 & 0x00000040);
+	rt2x00_rf_write(rt2x00dev, rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 | 0x00000040);
+	rt2x00_rf_write(rt2x00dev, rf3 | cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	rt2x00_rf_write(rt2x00dev, rf1);
 	rt2x00_rf_write(rt2x00dev, rf2);
-	rt2x00_rf_write(rt2x00dev, rf3 & 0x00000040);
+	rt2x00_rf_write(rt2x00dev, rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rf4);
 
 	msleep(1);
@@ -743,6 +758,10 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+
+	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
+
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
 		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
@@ -750,6 +769,13 @@
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+
+	rt2x00_register_read(rt2x00dev, TXRX_CSR4, &reg);
+	if (preamble == SHORT_PREAMBLE)
+		rt2x00_set_field32(&reg, TXRX_CSR4_AUTORESPOND_PREAMBLE, 1);
+	else
+		rt2x00_set_field32(&reg, TXRX_CSR4_AUTORESPOND_PREAMBLE, 0);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR4, reg);
 }
 
 static void rt73usb_config_phymode(struct rt2x00_dev *rt2x00dev,
@@ -878,8 +904,8 @@
 	u32 reg;
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR14, &reg);
-	rt2x00_set_field32(&reg, MAC_CSR14_ON_PERIOD, 30);
-	rt2x00_set_field32(&reg, MAC_CSR14_OFF_PERIOD, 70);
+	rt2x00_set_field32(&reg, MAC_CSR14_ON_PERIOD, 70);
+	rt2x00_set_field32(&reg, MAC_CSR14_OFF_PERIOD, 30);
 	rt2x00_register_write(rt2x00dev, MAC_CSR14, reg);
 
 	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_RADIO_STATUS, 1);
@@ -2849,7 +2875,7 @@
 		rf2_base = 0x00004000;
 
 	for (i = 0; i < ARRAY_SIZE(vals); i++)
-		channels[i].val = vals[i] | rf2_base;
+		channels[i].val = cpu_to_le32(vals[i] | rf2_base);
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5226)) {
@@ -2865,7 +2891,7 @@
 		struct ieee80211_channel *chan = channels + 14;
 
 		for (i = 0; i < ARRAY_SIZE(vals); i++)
-			(chan++)->val = vals[i];
+			(chan++)->val = cpu_to_le32(vals[i]);
 	}
 
 	/*
@@ -2904,8 +2930,8 @@
 	 */
 	for (i = 0; i < ARRAY_SIZE(rf); i++) {
 		if (rt2x00_rf(&rt2x00dev->chip, rf[i].chip)) {
-			rt2x00dev->rf1 = rf[i].val[0];
-			rt2x00dev->rf3 = rf[i].val[1];
+			rt2x00dev->rf1 = cpu_to_le32(rf[i].val[0]);
+			rt2x00dev->rf3 = cpu_to_le32(rf[i].val[1]);
 		}
 	}
 }
