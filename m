From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 5/24] RT2x00: Clean up device specific rate value initialization
Date: Wed, 26 Jul 2006 20:24:03 +0200
Message-ID: <200607262024.03461.IvDoorn@gmail.com>
References: <200607261904.48942.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:4101 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751747AbWGZSYT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:24:19 -0400
Received: by nf-out-0910.google.com with SMTP id o25so838937nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:24:18 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261904.48942.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

ieee80211_rate structure should be initialized by device_rate_entry
And the creation of the device specific rate value can be optimized
and made more clearer.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 16:30:58.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 17:01:06.000000000 +0200
@@ -680,10 +680,10 @@
 	u32 value;
 	u32 preamble;
 
-	preamble = DEVICE_RATE_FIELD(rate, PREAMBLE)
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_RATE_FIELD(rate, RATEMASK);
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
 
@@ -699,7 +699,7 @@
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
 	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
 	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
@@ -919,9 +919,9 @@
 	 * Convert length to microseconds.
 	 */
 	residual = get_duration_res(length,
-		DEVICE_RATE_FIELD(control->tx_rate, RATE));
+		DEVICE_GET_RATE_FIELD(control->tx_rate, RATE));
 	length = get_duration(length,
-		DEVICE_RATE_FIELD(control->tx_rate, RATE));
+		DEVICE_GET_RATE_FIELD(control->tx_rate, RATE));
 
 	if (residual)
 		length++;
@@ -939,8 +939,8 @@
 	length_high = 0x8000 | 0x0700 | (length >> 8);
 	length_low = 0x8000 | 0x0800 | (length & 0xff);
 
-	signal = 0x8500 | DEVICE_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x0600 | 0x0004;
@@ -2370,33 +2370,10 @@
 	/*
 	 * Rates initialization.
 	 */
-	rates[0].rate = 10;
-	rates[0].val = DEVICE_RATE_1MB;
-	rates[0].flags = IEEE80211_RATE_CCK;
-	rates[0].val2 = DEVICE_RATE_1MB;
-	rates[0].min_rssi_ack = 0;
-	rates[0].min_rssi_ack_delta = 0;
-
-	rates[1].rate = 20;
-	rates[1].val = DEVICE_RATE_2MB;
-	rates[1].flags = IEEE80211_RATE_CCK_2;
-	rates[1].val2 = DEVICE_RATE_2MB_PREAMBLE;
-	rates[1].min_rssi_ack = 0;
-	rates[1].min_rssi_ack_delta = 0;
-
-	rates[2].rate = 55;
-	rates[2].val = DEVICE_RATE_55MB;
-	rates[2].flags = IEEE80211_RATE_CCK_2;
-	rates[2].val2 = DEVICE_RATE_55MB_PREAMBLE;
-	rates[2].min_rssi_ack = 0;
-	rates[2].min_rssi_ack_delta = 0;
-
-	rates[3].rate = 110;
-	rates[3].val = DEVICE_RATE_11MB;
-	rates[3].flags = IEEE80211_RATE_CCK_2;
-	rates[3].val2 = DEVICE_RATE_11MB_PREAMBLE;
-	rates[3].min_rssi_ack = 0;
-	rates[3].min_rssi_ack_delta = 0;
+	device_rate_entry(&rates[0], 10, 0x001, 0x00, IEEE80211_RATE_CCK);
+	device_rate_entry(&rates[1], 20, 0x003, 0x01, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[2], 55, 0x007, 0x02, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[3], 110, 0x00f, 0x03, IEEE80211_RATE_CCK_2);
 }
 
 static int rt2400pci_init_hw(struct rt2x00_dev *rt2x00dev)
diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 16:31:10.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 17:01:39.000000000 +0200
@@ -725,10 +725,10 @@
 	u32 value;
 	u32 preamble;
 
-	preamble = DEVICE_RATE_FIELD(rate, PREAMBLE)
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_RATE_FIELD(rate, RATEMASK);
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
 
@@ -744,7 +744,7 @@
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
 	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
 	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
@@ -993,7 +993,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -1004,7 +1004,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1018,8 +1018,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x0600 | 0x0004;
@@ -2571,89 +2571,18 @@
 	/*
 	 * Rates initialization.
 	 */
-	rates[0].rate = 10;
-	rates[0].val = DEVICE_RATE_1MB;
-	rates[0].flags = IEEE80211_RATE_CCK;
-	rates[0].val2 = DEVICE_RATE_1MB;
-	rates[0].min_rssi_ack = 0;
-	rates[0].min_rssi_ack_delta = 0;
-
-	rates[1].rate = 20;
-	rates[1].val = DEVICE_RATE_2MB;
-	rates[1].flags = IEEE80211_RATE_CCK_2;
-	rates[1].val2 = DEVICE_RATE_2MB_PREAMBLE;
-	rates[1].min_rssi_ack = 0;
-	rates[1].min_rssi_ack_delta = 0;
-
-	rates[2].rate = 55;
-	rates[2].val = DEVICE_RATE_55MB;
-	rates[2].flags = IEEE80211_RATE_CCK_2;
-	rates[2].val2 = DEVICE_RATE_55MB_PREAMBLE;
-	rates[2].min_rssi_ack = 0;
-	rates[2].min_rssi_ack_delta = 0;
-
-	rates[3].rate = 110;
-	rates[3].val = DEVICE_RATE_11MB;
-	rates[3].flags = IEEE80211_RATE_CCK_2;
-	rates[3].val2 = DEVICE_RATE_11MB_PREAMBLE;
-	rates[3].min_rssi_ack = 0;
-	rates[3].min_rssi_ack_delta = 0;
-
-	rates[4].rate = 60;
-	rates[4].val = DEVICE_RATE_6MB;
-	rates[4].flags = IEEE80211_RATE_OFDM;
-	rates[4].val2 = DEVICE_RATE_6MB;
-	rates[4].min_rssi_ack = 0;
-	rates[4].min_rssi_ack_delta = 0;
-
-	rates[5].rate = 90;
-	rates[5].val = DEVICE_RATE_9MB;
-	rates[5].flags = IEEE80211_RATE_OFDM;
-	rates[5].val2 = DEVICE_RATE_9MB;
-	rates[5].min_rssi_ack = 0;
-	rates[5].min_rssi_ack_delta = 0;
-
-	rates[6].rate = 120;
-	rates[6].val = DEVICE_RATE_12MB;
-	rates[6].flags = IEEE80211_RATE_OFDM;
-	rates[6].val2 = DEVICE_RATE_12MB;
-	rates[6].min_rssi_ack = 0;
-	rates[6].min_rssi_ack_delta = 0;
-
-	rates[7].rate = 180;
-	rates[7].val = DEVICE_RATE_18MB;
-	rates[7].flags = IEEE80211_RATE_OFDM;
-	rates[7].val2 = DEVICE_RATE_18MB;
-	rates[7].min_rssi_ack = 0;
-	rates[7].min_rssi_ack_delta = 0;
-
-	rates[8].rate = 240;
-	rates[8].val = DEVICE_RATE_24MB;
-	rates[8].flags = IEEE80211_RATE_OFDM;
-	rates[8].val2 = DEVICE_RATE_24MB;
-	rates[8].min_rssi_ack = 0;
-	rates[8].min_rssi_ack_delta = 0;
-
-	rates[9].rate = 360;
-	rates[9].val = DEVICE_RATE_36MB;
-	rates[9].flags = IEEE80211_RATE_OFDM;
-	rates[9].val2 = DEVICE_RATE_36MB;
-	rates[9].min_rssi_ack = 0;
-	rates[9].min_rssi_ack_delta = 0;
-
-	rates[10].rate = 480;
-	rates[10].val = DEVICE_RATE_48MB;
-	rates[10].flags = IEEE80211_RATE_OFDM;
-	rates[10].val2 = DEVICE_RATE_48MB;
-	rates[10].min_rssi_ack = 0;
-	rates[10].min_rssi_ack_delta = 0;
-
-	rates[11].rate = 540;
-	rates[11].val = DEVICE_RATE_54MB;
-	rates[11].flags = IEEE80211_RATE_OFDM;
-	rates[11].val2 = DEVICE_RATE_54MB;
-	rates[11].min_rssi_ack = 0;
-	rates[11].min_rssi_ack_delta = 0;
+	device_rate_entry(&rates[0], 10, 0x001, 0x00, IEEE80211_RATE_CCK);
+	device_rate_entry(&rates[1], 20, 0x003, 0x01, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[2], 55, 0x007, 0x02, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[3], 110, 0x00f, 0x03, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[4], 60, 0x01f, 0x0b, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[5], 90, 0x03f, 0x0f, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[6], 120, 0x07f, 0x0a, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[7], 180, 0x0ff, 0x0e, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[8], 240, 0x1ff, 0x09, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[9], 360, 0x3ff, 0x0d, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[10], 480, 0x7ff, 0x08, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[11], 540, 0xfff, 0x0c, IEEE80211_RATE_OFDM);
 }
 
 static int rt2500pci_init_hw(struct rt2x00_dev *rt2x00dev)
diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 16:31:02.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 17:02:01.000000000 +0200
@@ -541,10 +541,10 @@
 	u16 value;
 	u16 preamble;
 
-	preamble = DEVICE_RATE_FIELD(rate, PREAMBLE)
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_RATE_FIELD(rate, RATEMASK);
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR11, reg);
 
@@ -557,7 +557,7 @@
 	rt2x00_register_write(rt2x00dev, TXRX_CSR1, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR10, &reg);
-	if (DEVICE_RATE_FIELD(rate, PREAMBLE))
+	if (DEVICE_GET_RATE_FIELD(rate, PREAMBLE))
 		reg |= 0x0004;
 	else
 		reg &= ~0x0004;
@@ -819,7 +819,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
@@ -830,7 +830,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -844,8 +844,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = DEVICE_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
 		signal |= 0x08;
 
 	service = 0x04;
@@ -2203,89 +2203,18 @@
 	/*
 	 * Rates initialization.
 	 */
-	rates[0].rate = 10;
-	rates[0].val = DEVICE_RATE_1MB;
-	rates[0].flags = IEEE80211_RATE_CCK;
-	rates[0].val2 = DEVICE_RATE_1MB;
-	rates[0].min_rssi_ack = 0;
-	rates[0].min_rssi_ack_delta = 0;
-
-	rates[1].rate = 20;
-	rates[1].val = DEVICE_RATE_2MB;
-	rates[1].flags = IEEE80211_RATE_CCK_2;
-	rates[1].val2 = DEVICE_RATE_2MB_PREAMBLE;
-	rates[1].min_rssi_ack = 0;
-	rates[1].min_rssi_ack_delta = 0;
-
-	rates[2].rate = 55;
-	rates[2].val = DEVICE_RATE_55MB;
-	rates[2].flags = IEEE80211_RATE_CCK_2;
-	rates[2].val2 = DEVICE_RATE_55MB_PREAMBLE;
-	rates[2].min_rssi_ack = 0;
-	rates[2].min_rssi_ack_delta = 0;
-
-	rates[3].rate = 110;
-	rates[3].val = DEVICE_RATE_11MB;
-	rates[3].flags = IEEE80211_RATE_CCK_2;
-	rates[3].val2 = DEVICE_RATE_11MB_PREAMBLE;
-	rates[3].min_rssi_ack = 0;
-	rates[3].min_rssi_ack_delta = 0;
-
-	rates[4].rate = 60;
-	rates[4].val = DEVICE_RATE_6MB;
-	rates[4].flags = IEEE80211_RATE_OFDM;
-	rates[4].val2 = DEVICE_RATE_6MB;
-	rates[4].min_rssi_ack = 0;
-	rates[4].min_rssi_ack_delta = 0;
-
-	rates[5].rate = 90;
-	rates[5].val = DEVICE_RATE_9MB;
-	rates[5].flags = IEEE80211_RATE_OFDM;
-	rates[5].val2 = DEVICE_RATE_9MB;
-	rates[5].min_rssi_ack = 0;
-	rates[5].min_rssi_ack_delta = 0;
-
-	rates[6].rate = 120;
-	rates[6].val = DEVICE_RATE_12MB;
-	rates[6].flags = IEEE80211_RATE_OFDM;
-	rates[6].val2 = DEVICE_RATE_12MB;
-	rates[6].min_rssi_ack = 0;
-	rates[6].min_rssi_ack_delta = 0;
-
-	rates[7].rate = 180;
-	rates[7].val = DEVICE_RATE_18MB;
-	rates[7].flags = IEEE80211_RATE_OFDM;
-	rates[7].val2 = DEVICE_RATE_18MB;
-	rates[7].min_rssi_ack = 0;
-	rates[7].min_rssi_ack_delta = 0;
-
-	rates[8].rate = 240;
-	rates[8].val = DEVICE_RATE_24MB;
-	rates[8].flags = IEEE80211_RATE_OFDM;
-	rates[8].val2 = DEVICE_RATE_24MB;
-	rates[8].min_rssi_ack = 0;
-	rates[8].min_rssi_ack_delta = 0;
-
-	rates[9].rate = 360;
-	rates[9].val = DEVICE_RATE_36MB;
-	rates[9].flags = IEEE80211_RATE_OFDM;
-	rates[9].val2 = DEVICE_RATE_36MB;
-	rates[9].min_rssi_ack = 0;
-	rates[9].min_rssi_ack_delta = 0;
-
-	rates[10].rate = 480;
-	rates[10].val = DEVICE_RATE_48MB;
-	rates[10].flags = IEEE80211_RATE_OFDM;
-	rates[10].val2 = DEVICE_RATE_48MB;
-	rates[10].min_rssi_ack = 0;
-	rates[10].min_rssi_ack_delta = 0;
-
-	rates[11].rate = 540;
-	rates[11].val = DEVICE_RATE_54MB;
-	rates[11].flags = IEEE80211_RATE_OFDM;
-	rates[11].val2 = DEVICE_RATE_54MB;
-	rates[11].min_rssi_ack = 0;
-	rates[11].min_rssi_ack_delta = 0;
+	device_rate_entry(&rates[0], 10, 0x001, 0x00, IEEE80211_RATE_CCK);
+	device_rate_entry(&rates[1], 20, 0x003, 0x01, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[2], 55, 0x007, 0x02, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[3], 110, 0x00f, 0x03, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[4], 60, 0x01f, 0x0b, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[5], 90, 0x03f, 0x0f, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[6], 120, 0x07f, 0x0a, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[7], 180, 0x0ff, 0x0e, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[8], 240, 0x1ff, 0x09, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[9], 360, 0x3ff, 0x0d, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[10], 480, 0x7ff, 0x08, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[11], 540, 0xfff, 0x0c, IEEE80211_RATE_OFDM);
 }
 
 static int rt2500usb_init_hw(struct rt2x00_dev *rt2x00dev)
diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 15:47:08.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 16:59:40.000000000 +0200
@@ -872,37 +872,33 @@
 #define DEV_PLCP	FIELD32(0xff000000)
 
 /*
- * Macro's for creating the device specific rate value.
+ * Macro's to set and get specific fields from the device specific val and val2
+ * fields inside the ieee80211_rate entry.
  */
-#define DEVICE_RATE_VALUE(__rate, __mask, __plcp) \
-	(int) ((((__rate) << DEV_RATE.bit_offset) & DEV_RATE.bit_mask) | \
-	 (((__mask) << DEV_RATEMASK.bit_offset) & DEV_RATEMASK.bit_mask) | \
-	 (((__plcp) << DEV_PLCP.bit_offset) & DEV_PLCP.bit_mask) )
+#define DEVICE_SET_RATE_FIELD(__value, __mask) \
+	(int)( ((__value) << DEV_##__mask.bit_offset) & DEV_##__mask.bit_mask )
 
-#define DEVICE_RATE_PREAMBLE(__value) \
-	(int)( (__value) | (1 << DEV_PREAMBLE.bit_offset) )
+#define DEVICE_GET_RATE_FIELD(__value, __mask) \
+	(int)( ((__value) & DEV_##__mask.bit_mask) >> DEV_##__mask.bit_offset )
 
 /*
- * Macro for reading the device specific rate value.
- */
-#define DEVICE_RATE_FIELD(__value, __mask) \
-	(int)( ((__value) & DEV_##__mask.bit_mask) >> DEV_##__mask.bit_offset)
-
-#define DEVICE_RATE_1MB			DEVICE_RATE_VALUE(10, 0x001, 0x00)
-#define DEVICE_RATE_2MB			DEVICE_RATE_VALUE(20, 0x003, 0x01)
-#define DEVICE_RATE_2MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_2MB)
-#define DEVICE_RATE_55MB		DEVICE_RATE_VALUE(55, 0x007, 0x02)
-#define DEVICE_RATE_55MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_55MB)
-#define DEVICE_RATE_11MB		DEVICE_RATE_VALUE(110, 0x00f, 0x03)
-#define DEVICE_RATE_11MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_11MB)
-#define DEVICE_RATE_6MB			DEVICE_RATE_VALUE(60, 0x01f, 0x0b)
-#define DEVICE_RATE_9MB			DEVICE_RATE_VALUE(90, 0x03f, 0x0f)
-#define DEVICE_RATE_12MB		DEVICE_RATE_VALUE(120, 0x07f, 0x0a)
-#define DEVICE_RATE_18MB		DEVICE_RATE_VALUE(180, 0x0ff, 0x0e)
-#define DEVICE_RATE_24MB		DEVICE_RATE_VALUE(240, 0x1ff, 0x09)
-#define DEVICE_RATE_36MB		DEVICE_RATE_VALUE(360, 0x3ff, 0x0d)
-#define DEVICE_RATE_48MB		DEVICE_RATE_VALUE(480, 0x7ff, 0x08)
-#define DEVICE_RATE_54MB		DEVICE_RATE_VALUE(540, 0xfff, 0x0c)
+ * Initialize a ieee80211_entry by filling in all fields and correctly
+ * construct the device specific val and val2 fields.
+  */
+static inline void device_rate_entry(struct ieee80211_rate *entry,
+	int rate, int mask, int plcp, int flags)
+{
+	entry->rate = rate;
+	entry->val = DEVICE_SET_RATE_FIELD(rate, RATE) |
+		DEVICE_SET_RATE_FIELD(mask, RATEMASK) |
+		DEVICE_SET_RATE_FIELD(plcp, PLCP);
+	entry->flags = flags;
+	entry->val2 = entry->val |
+		DEVICE_SET_RATE_FIELD(entry->flags & IEEE80211_RATE_PREAMBLE2,
+				      PREAMBLE);
+	entry->min_rssi_ack = 0;
+	entry->min_rssi_ack_delta = 0;
+}
 
 /*
  * Duration calculations
diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 16:30:48.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 17:02:10.000000000 +0200
@@ -953,7 +953,7 @@
 	u32 value;
 	u32 preamble;
 
-	preamble = DEVICE_RATE_FIELD(rate, PREAMBLE)
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -1249,7 +1249,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -1260,7 +1260,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1274,8 +1274,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x04;
@@ -3117,89 +3117,18 @@
 	/*
 	 * Rates initialization.
 	 */
-	rates[0].rate = 10;
-	rates[0].val = DEVICE_RATE_1MB;
-	rates[0].flags = IEEE80211_RATE_CCK;
-	rates[0].val2 = DEVICE_RATE_1MB;
-	rates[0].min_rssi_ack = 0;
-	rates[0].min_rssi_ack_delta = 0;
-
-	rates[1].rate = 20;
-	rates[1].val = DEVICE_RATE_2MB;
-	rates[1].flags = IEEE80211_RATE_CCK_2;
-	rates[1].val2 = DEVICE_RATE_2MB_PREAMBLE;
-	rates[1].min_rssi_ack = 0;
-	rates[1].min_rssi_ack_delta = 0;
-
-	rates[2].rate = 55;
-	rates[2].val = DEVICE_RATE_55MB;
-	rates[2].flags = IEEE80211_RATE_CCK_2;
-	rates[2].val2 = DEVICE_RATE_55MB_PREAMBLE;
-	rates[2].min_rssi_ack = 0;
-	rates[2].min_rssi_ack_delta = 0;
-
-	rates[3].rate = 110;
-	rates[3].val = DEVICE_RATE_11MB;
-	rates[3].flags = IEEE80211_RATE_CCK_2;
-	rates[3].val2 = DEVICE_RATE_11MB_PREAMBLE;
-	rates[3].min_rssi_ack = 0;
-	rates[3].min_rssi_ack_delta = 0;
-
-	rates[4].rate = 60;
-	rates[4].val = DEVICE_RATE_6MB;
-	rates[4].flags = IEEE80211_RATE_OFDM;
-	rates[4].val2 = DEVICE_RATE_6MB;
-	rates[4].min_rssi_ack = 0;
-	rates[4].min_rssi_ack_delta = 0;
-
-	rates[5].rate = 90;
-	rates[5].val = DEVICE_RATE_9MB;
-	rates[5].flags = IEEE80211_RATE_OFDM;
-	rates[5].val2 = DEVICE_RATE_9MB;
-	rates[5].min_rssi_ack = 0;
-	rates[5].min_rssi_ack_delta = 0;
-
-	rates[6].rate = 120;
-	rates[6].val = DEVICE_RATE_12MB;
-	rates[6].flags = IEEE80211_RATE_OFDM;
-	rates[6].val2 = DEVICE_RATE_12MB;
-	rates[6].min_rssi_ack = 0;
-	rates[6].min_rssi_ack_delta = 0;
-
-	rates[7].rate = 180;
-	rates[7].val = DEVICE_RATE_18MB;
-	rates[7].flags = IEEE80211_RATE_OFDM;
-	rates[7].val2 = DEVICE_RATE_18MB;
-	rates[7].min_rssi_ack = 0;
-	rates[7].min_rssi_ack_delta = 0;
-
-	rates[8].rate = 240;
-	rates[8].val = DEVICE_RATE_24MB;
-	rates[8].flags = IEEE80211_RATE_OFDM;
-	rates[8].val2 = DEVICE_RATE_24MB;
-	rates[8].min_rssi_ack = 0;
-	rates[8].min_rssi_ack_delta = 0;
-
-	rates[9].rate = 360;
-	rates[9].val = DEVICE_RATE_36MB;
-	rates[9].flags = IEEE80211_RATE_OFDM;
-	rates[9].val2 = DEVICE_RATE_36MB;
-	rates[9].min_rssi_ack = 0;
-	rates[9].min_rssi_ack_delta = 0;
-
-	rates[10].rate = 480;
-	rates[10].val = DEVICE_RATE_48MB;
-	rates[10].flags = IEEE80211_RATE_OFDM;
-	rates[10].val2 = DEVICE_RATE_48MB;
-	rates[10].min_rssi_ack = 0;
-	rates[10].min_rssi_ack_delta = 0;
-
-	rates[11].rate = 540;
-	rates[11].val = DEVICE_RATE_54MB;
-	rates[11].flags = IEEE80211_RATE_OFDM;
-	rates[11].val2 = DEVICE_RATE_54MB;
-	rates[11].min_rssi_ack = 0;
-	rates[11].min_rssi_ack_delta = 0;
+	device_rate_entry(&rates[0], 10, 0x001, 0x00, IEEE80211_RATE_CCK);
+	device_rate_entry(&rates[1], 20, 0x003, 0x01, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[2], 55, 0x007, 0x02, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[3], 110, 0x00f, 0x03, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[4], 60, 0x01f, 0x0b, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[5], 90, 0x03f, 0x0f, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[6], 120, 0x07f, 0x0a, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[7], 180, 0x0ff, 0x0e, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[8], 240, 0x1ff, 0x09, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[9], 360, 0x3ff, 0x0d, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[10], 480, 0x7ff, 0x08, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[11], 540, 0xfff, 0x0c, IEEE80211_RATE_OFDM);
 }
 
 static int rt61pci_init_hw(struct rt2x00_dev *rt2x00dev)
diff -rU3 wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 16:30:55.000000000 +0200
+++ wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 17:02:18.000000000 +0200
@@ -671,7 +671,7 @@
 	u32 value;
 	u32 preamble;
 
-	preamble = DEVICE_RATE_FIELD(rate, PREAMBLE)
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -983,7 +983,7 @@
 	 * this can be done by checking if bit 4 or higher
 	 * is set in the ratemask.
 	 */
-	if (DEVICE_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, RATEMASK) & 0x0ff0) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
@@ -994,7 +994,7 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_RATE_FIELD(control->tx_rate, RATE);
+		rate = DEVICE_GET_RATE_FIELD(control->tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
@@ -1008,8 +1008,8 @@
 		length_low = length & 0xff;
 	}
 
-	signal = 0x8500 | DEVICE_RATE_FIELD(control->tx_rate, PLCP);
-	if (DEVICE_RATE_FIELD(control->tx_rate, PREAMBLE))
+	signal = 0x8500 | DEVICE_GET_RATE_FIELD(control->tx_rate, PLCP);
+	if (DEVICE_GET_RATE_FIELD(control->tx_rate, PREAMBLE))
 		signal |= 0x0008;
 
 	service = 0x04;
@@ -2612,89 +2612,18 @@
 	/*
 	 * Rates initialization.
 	 */
-	rates[0].rate = 10;
-	rates[0].val = DEVICE_RATE_1MB;
-	rates[0].flags = IEEE80211_RATE_CCK;
-	rates[0].val2 = DEVICE_RATE_1MB;
-	rates[0].min_rssi_ack = 0;
-	rates[0].min_rssi_ack_delta = 0;
-
-	rates[1].rate = 20;
-	rates[1].val = DEVICE_RATE_2MB;
-	rates[1].flags = IEEE80211_RATE_CCK_2;
-	rates[1].val2 = DEVICE_RATE_2MB_PREAMBLE;
-	rates[1].min_rssi_ack = 0;
-	rates[1].min_rssi_ack_delta = 0;
-
-	rates[2].rate = 55;
-	rates[2].val = DEVICE_RATE_55MB;
-	rates[2].flags = IEEE80211_RATE_CCK_2;
-	rates[2].val2 = DEVICE_RATE_55MB_PREAMBLE;
-	rates[2].min_rssi_ack = 0;
-	rates[2].min_rssi_ack_delta = 0;
-
-	rates[3].rate = 110;
-	rates[3].val = DEVICE_RATE_11MB;
-	rates[3].flags = IEEE80211_RATE_CCK_2;
-	rates[3].val2 = DEVICE_RATE_11MB_PREAMBLE;
-	rates[3].min_rssi_ack = 0;
-	rates[3].min_rssi_ack_delta = 0;
-
-	rates[4].rate = 60;
-	rates[4].val = DEVICE_RATE_6MB;
-	rates[4].flags = IEEE80211_RATE_OFDM;
-	rates[4].val2 = DEVICE_RATE_6MB;
-	rates[4].min_rssi_ack = 0;
-	rates[4].min_rssi_ack_delta = 0;
-
-	rates[5].rate = 90;
-	rates[5].val = DEVICE_RATE_9MB;
-	rates[5].flags = IEEE80211_RATE_OFDM;
-	rates[5].val2 = DEVICE_RATE_9MB;
-	rates[5].min_rssi_ack = 0;
-	rates[5].min_rssi_ack_delta = 0;
-
-	rates[6].rate = 120;
-	rates[6].val = DEVICE_RATE_12MB;
-	rates[6].flags = IEEE80211_RATE_OFDM;
-	rates[6].val2 = DEVICE_RATE_12MB;
-	rates[6].min_rssi_ack = 0;
-	rates[6].min_rssi_ack_delta = 0;
-
-	rates[7].rate = 180;
-	rates[7].val = DEVICE_RATE_18MB;
-	rates[7].flags = IEEE80211_RATE_OFDM;
-	rates[7].val2 = DEVICE_RATE_18MB;
-	rates[7].min_rssi_ack = 0;
-	rates[7].min_rssi_ack_delta = 0;
-
-	rates[8].rate = 240;
-	rates[8].val = DEVICE_RATE_24MB;
-	rates[8].flags = IEEE80211_RATE_OFDM;
-	rates[8].val2 = DEVICE_RATE_24MB;
-	rates[8].min_rssi_ack = 0;
-	rates[8].min_rssi_ack_delta = 0;
-
-	rates[9].rate = 360;
-	rates[9].val = DEVICE_RATE_36MB;
-	rates[9].flags = IEEE80211_RATE_OFDM;
-	rates[9].val2 = DEVICE_RATE_36MB;
-	rates[9].min_rssi_ack = 0;
-	rates[9].min_rssi_ack_delta = 0;
-
-	rates[10].rate = 480;
-	rates[10].val = DEVICE_RATE_48MB;
-	rates[10].flags = IEEE80211_RATE_OFDM;
-	rates[10].val2 = DEVICE_RATE_48MB;
-	rates[10].min_rssi_ack = 0;
-	rates[10].min_rssi_ack_delta = 0;
-
-	rates[11].rate = 540;
-	rates[11].val = DEVICE_RATE_54MB;
-	rates[11].flags = IEEE80211_RATE_OFDM;
-	rates[11].val2 = DEVICE_RATE_54MB;
-	rates[11].min_rssi_ack = 0;
-	rates[11].min_rssi_ack_delta = 0;
+	device_rate_entry(&rates[0], 10, 0x001, 0x00, IEEE80211_RATE_CCK);
+	device_rate_entry(&rates[1], 20, 0x003, 0x01, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[2], 55, 0x007, 0x02, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[3], 110, 0x00f, 0x03, IEEE80211_RATE_CCK_2);
+	device_rate_entry(&rates[4], 60, 0x01f, 0x0b, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[5], 90, 0x03f, 0x0f, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[6], 120, 0x07f, 0x0a, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[7], 180, 0x0ff, 0x0e, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[8], 240, 0x1ff, 0x09, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[9], 360, 0x3ff, 0x0d, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[10], 480, 0x7ff, 0x08, IEEE80211_RATE_OFDM);
+	device_rate_entry(&rates[11], 540, 0xfff, 0x0c, IEEE80211_RATE_OFDM);
 }
 
 static int rt73usb_init_hw(struct rt2x00_dev *rt2x00dev)
