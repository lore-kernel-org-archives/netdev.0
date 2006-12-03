From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 15/26] rt2x00: Add SIFS/PIFS/DIFS/EIFS defines
Date: Sun, 3 Dec 2006 19:19:00 +0100
Message-ID: <200612031919.00977.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:57689 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758869AbWLCST2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:28 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144364nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:27 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce new defines for the SIFS, PIFS, EIFS, DIFS,
and make use of it in the drivers.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:03:05.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:10:28.000000000 +0100
@@ -524,24 +524,22 @@
 	int short_slot_time)
 {
 	u32 reg;
-	u32 value;
-
-	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
 	rt2x00_register_read(rt2x00dev, CSR11, &reg);
-	rt2x00_set_field32(&reg, CSR11_SLOT_TIME, short_slot_time);
+	rt2x00_set_field32(&reg, CSR11_SLOT_TIME,
+		short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME);
 	rt2x00_register_write(rt2x00dev, CSR11, reg);
 
 	rt2x00_register_read(rt2x00dev, CSR18, &reg);
 	rt2x00_set_field32(&reg, CSR18_SIFS, SIFS);
-	rt2x00_set_field32(&reg, CSR18_PIFS, SIFS + short_slot_time);
+	rt2x00_set_field32(&reg, CSR18_PIFS,
+		short_slot_time ? SHORT_PIFS :  PIFS);
 	rt2x00_register_write(rt2x00dev, CSR18, reg);
 
 	rt2x00_register_read(rt2x00dev, CSR19, &reg);
-	value = SIFS + (2 * short_slot_time);
-	rt2x00_set_field32(&reg, CSR19_DIFS, value);
-	value = SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
-	rt2x00_set_field32(&reg, CSR19_EIFS, value);
+	rt2x00_set_field32(&reg, CSR19_DIFS,
+		short_slot_time ? SHORT_DIFS : DIFS);
+	rt2x00_set_field32(&reg, CSR19_EIFS, EIFS);
 	rt2x00_register_write(rt2x00dev, CSR19, reg);
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg);
@@ -553,36 +551,26 @@
 static void rt2400pci_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
 {
 	struct ieee80211_conf *conf = &rt2x00dev->hw->conf;
-	u32 reg[4];
+	u32 reg;
 	u32 value;
 	u32 preamble;
 
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	/*
-	 * Extract the allowed ratemask from the device specific rate value,
-	 * We need to set ARCSR1 to the basic rate mask so we need to mask
-	 * off the non-basic rates.
-	 */
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
-
-	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
-
-	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
-	value = SIFS + PLCP
-		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
-			SHORT_SLOT_TIME : SLOT_TIME))
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
-	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
-	value = SIFS + PLCP
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
-	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
-	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
+	rt2x00_register_write(rt2x00dev, ARCSR1, reg);
+
+	rt2x00_register_read(rt2x00dev, TXCSR1, &reg);
+	value = ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+		 SHORT_DIFS :  DIFS) +
+		PLCP + preamble + get_duration(ACK_SIZE, 10);
+	rt2x00_set_field32(&reg, TXCSR1_ACK_TIMEOUT, value);
+	value = SIFS + PLCP + preamble + get_duration(ACK_SIZE, 10);
+	rt2x00_set_field32(&reg, TXCSR1_ACK_CONSUME_TIME, value);
+	rt2x00_register_write(rt2x00dev, TXCSR1, reg);
 
-	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 0x08 : 0x00;
 
 	rt2x00_register_write(rt2x00dev, ARCSR2, 0x00700400 | preamble);
 	rt2x00_register_write(rt2x00dev, ARCSR3, 0x00380401 | preamble);
diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:00:23.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:10:52.000000000 +0100
@@ -590,24 +590,22 @@
 	int short_slot_time)
 {
 	u32 reg;
-	u32 value;
-
-	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
 	rt2x00_register_read(rt2x00dev, CSR11, &reg);
-	rt2x00_set_field32(&reg, CSR11_SLOT_TIME, short_slot_time);
+	rt2x00_set_field32(&reg, CSR11_SLOT_TIME,
+		short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME);
 	rt2x00_register_write(rt2x00dev, CSR11, reg);
 
 	rt2x00_register_read(rt2x00dev, CSR18, &reg);
 	rt2x00_set_field32(&reg, CSR18_SIFS, SIFS);
-	rt2x00_set_field32(&reg, CSR18_PIFS, SIFS + short_slot_time);
+	rt2x00_set_field32(&reg, CSR18_PIFS,
+		short_slot_time ? SHORT_PIFS : PIFS);
 	rt2x00_register_write(rt2x00dev, CSR18, reg);
 
 	rt2x00_register_read(rt2x00dev, CSR19, &reg);
-	value = SIFS + (2 * short_slot_time);
-	rt2x00_set_field32(&reg, CSR19_DIFS, value);
-	value = SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
-	rt2x00_set_field32(&reg, CSR19_EIFS, value);
+	rt2x00_set_field32(&reg, CSR19_DIFS,
+		short_slot_time ? SHORT_DIFS : DIFS);
+	rt2x00_set_field32(&reg, CSR19_EIFS, EIFS);
 	rt2x00_register_write(rt2x00dev, CSR19, reg);
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg);
@@ -619,36 +617,26 @@
 static void rt2500pci_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
 {
 	struct ieee80211_conf *conf = &rt2x00dev->hw->conf;
-	u32 reg[4];
+	u32 reg;
 	u32 value;
 	u32 preamble;
 
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	/*
-	 * Extract the allowed ratemask from the device specific rate value,
-	 * We need to set ARCSR1 to the basic rate mask so we need to mask
-	 * off the non-basic rates.
-	 */
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
-
-	rt2x00_register_write(rt2x00dev, ARCSR1, reg[0]);
-
-	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
-	value = SIFS + PLCP
-		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
-			SHORT_SLOT_TIME : SLOT_TIME))
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
-	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
-	value = SIFS + PLCP
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
-	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
-	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
+	rt2x00_register_write(rt2x00dev, ARCSR1, reg);
+
+	rt2x00_register_read(rt2x00dev, TXCSR1, &reg);
+	value = ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+		 SHORT_DIFS :  DIFS) +
+		PLCP + preamble + get_duration(ACK_SIZE, 10);
+	rt2x00_set_field32(&reg, TXCSR1_ACK_TIMEOUT, value);
+	value = SIFS + PLCP + preamble + get_duration(ACK_SIZE, 10);
+	rt2x00_set_field32(&reg, TXCSR1_ACK_CONSUME_TIME, value);
+	rt2x00_register_write(rt2x00dev, TXCSR1, reg);
 
-	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 0x08 : 0x00;
 
 	rt2x00_register_write(rt2x00dev, ARCSR2, 0x00700400 | preamble);
 	rt2x00_register_write(rt2x00dev, ARCSR3, 0x00380401 | preamble);
diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:00:12.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:11:15.000000000 +0100
@@ -625,11 +625,11 @@
 }
 
 static void rt2500usb_config_duration(struct rt2x00_dev *rt2x00dev,
-	int short_slot_time)
+	unsigned short short_slot_time)
 {
 	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
-	rt2x00_register_write(rt2x00dev, MAC_CSR10, (u16)short_slot_time);
+	rt2x00_register_write(rt2x00dev, MAC_CSR10, short_slot_time);
 }
 
 static void rt2500usb_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
@@ -642,29 +642,22 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	/*
-	 * Extract the allowed ratemask from the device specific rate value,
-	 * We need to set TXRX_CSR11 to the basic rate mask so we need to mask
-	 * off the non-basic rates.
-	 */
 	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR11, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
-	value = SIFS + PLCP
-		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
-			SHORT_SLOT_TIME : SLOT_TIME))
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
+	value = ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+		 SHORT_DIFS :  DIFS) +
+		PLCP + preamble + get_duration(ACK_SIZE, 10);
 	rt2x00_set_field16(&reg, TXRX_CSR1_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR1, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR10, &reg);
-	if (DEVICE_GET_RATE_FIELD(rate, PREAMBLE))
-		reg |= 0x0004;
+	if (preamble == SHORT_PREAMBLE)
+		rt2x00_set_field16(&reg, TXRX_CSR10_AUTORESPOND_PREAMBLE, 1);
 	else
-		reg &= ~0x0004;
+		rt2x00_set_field16(&reg, TXRX_CSR10_AUTORESPOND_PREAMBLE, 0);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR10, reg);
 }
 
diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:55:51.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 14:13:46.000000000 +0100
@@ -107,17 +107,22 @@
 #define CLEAR_FLAGS(__dev)		( (__dev)->flags = 0 )
 
 /*
- * Standard timning and size defines.
+ * Standard timing and size defines.
  */
 #define ACK_SIZE		14
 #define IEEE80211_HEADER	24
 #define PLCP			48
 #define BEACON			100
-#define SIFS			10
 #define PREAMBLE		144
 #define SHORT_PREAMBLE		72
 #define SLOT_TIME		20
 #define SHORT_SLOT_TIME		9
+#define SIFS			10
+#define PIFS			( SIFS + SLOT_TIME )
+#define SHORT_PIFS		( SIFS + SHORT_SLOT_TIME )
+#define DIFS			( PIFS + SLOT_TIME )
+#define SHORT_DIFS		( SHORT_PIFS + SHORT_SLOT_TIME )
+#define EIFS			( SIFS + (8 * (IEEE80211_HEADER + ACK_SIZE)) )
 
 /*
  * IEEE802.11 header defines
diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:00:36.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:11:38.000000000 +0100
@@ -818,7 +818,6 @@
 	int short_slot_time)
 {
 	u32 reg;
-	u32 value;
 
 	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
@@ -829,8 +828,7 @@
 	rt2x00_register_read(rt2x00dev, MAC_CSR8, &reg);
 	rt2x00_set_field32(&reg, MAC_CSR8_SIFS, SIFS);
 	rt2x00_set_field32(&reg, MAC_CSR8_SIFS_AFTER_RX_OFDM, 3);
-	value = SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
-	rt2x00_set_field32(&reg, MAC_CSR8_EIFS, value);
+	rt2x00_set_field32(&reg, MAC_CSR8_EIFS, EIFS);
 	rt2x00_register_write(rt2x00dev, MAC_CSR8, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -862,11 +860,9 @@
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-	value = SIFS + PLCP
-		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
-			SHORT_SLOT_TIME : SLOT_TIME))
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
+	value = ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+		 SHORT_DIFS :  DIFS) +
+		PLCP + preamble + get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
 
diff -rU3 wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-stats/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:00:46.000000000 +0100
+++ wireless-dev-timing/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:11:59.000000000 +0100
@@ -708,7 +708,6 @@
 	int short_slot_time)
 {
 	u32 reg;
-	u32 value;
 
 	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
@@ -719,8 +718,7 @@
 	rt2x00_register_read(rt2x00dev, MAC_CSR8, &reg);
 	rt2x00_set_field32(&reg, MAC_CSR8_SIFS, SIFS);
 	rt2x00_set_field32(&reg, MAC_CSR8_SIFS_AFTER_RX_OFDM, 3);
-	value = SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
-	rt2x00_set_field32(&reg, MAC_CSR8_EIFS, value);
+	rt2x00_set_field32(&reg, MAC_CSR8_EIFS, EIFS);
 	rt2x00_register_write(rt2x00dev, MAC_CSR8, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -742,21 +740,14 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	/*
-	 * Extract the allowed ratemask from the device specific rate value,
-	 * We need to set TXRX_CSR5 to the basic rate mask so we need to mask
-	 * off the non-basic rates.
-	 */
 	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-	value = SIFS + PLCP
-		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
-			SHORT_SLOT_TIME : SLOT_TIME))
-		+ preamble
-		+ get_duration(ACK_SIZE, 10);
+	value = ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+		 SHORT_DIFS :  DIFS) +
+		PLCP + preamble + get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
 
