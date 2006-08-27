From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/10] rt2x00: basic rate mask
Date: Sun, 27 Aug 2006 17:39:12 +0200
Message-ID: <200608271739.12704.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46123 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932101AbWH0PjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:20 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091661nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:19 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The enabled rates register apparently only requires the basic rates.
For this we add a define containing the basic rates.
Now we are working on it anyway, also add a OFDM and CCK rate mask,
to clear up some code.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 15:48:21.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:00:34.000000000 +0200
@@ -752,7 +752,12 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set ARCSR1 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 15:48:35.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:00:40.000000000 +0200
@@ -818,7 +818,12 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set ARCSR1 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg[0] = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, ARCSR1, cpu_to_le32(reg[0]));
 
@@ -1740,11 +1745,9 @@
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 15:49:07.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:00:52.000000000 +0200
@@ -652,7 +652,12 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR11 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR11, reg);
 
@@ -1500,11 +1505,9 @@
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 		residual = 0;
 
diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-27 15:45:39.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-27 15:57:39.000000000 +0200
@@ -1008,6 +1008,36 @@
 #define DEV_PLCP	FIELD32(0xff000000)
 
 /*
+ * Bitmask for MASK_RATE
+ */
+#define DEV_RATE_1MB	0x00000001
+#define DEV_RATE_2MB	0x00000002
+#define DEV_RATE_5_5MB	0x00000004
+#define DEV_RATE_11MB	0x00000008
+#define DEV_RATE_6MB	0x00000010
+#define DEV_RATE_9MB	0x00000020
+#define DEV_RATE_12MB	0x00000040
+#define DEV_RATE_18MB	0x00000080
+#define DEV_RATE_24MB	0x00000100
+#define DEV_RATE_36MB	0x00000200
+#define DEV_RATE_48MB	0x00000400
+#define DEV_RATE_54MB	0x00000800
+
+/*
+ * Bitmask groups of bitrates
+ */
+#define DEV_BASIC_RATE \
+	( DEV_RATE_1MB | DEV_RATE_2MB | DEV_RATE_5_5MB | DEV_RATE_11MB | \
+	  DEV_RATE_6MB | DEV_RATE_12MB | DEV_RATE_24MB )
+
+#define DEV_CCK_RATE \
+	( DEV_RATE_1MB | DEV_RATE_2MB | DEV_RATE_5_5MB | DEV_RATE_11MB )
+
+#define DEV_OFDM_RATE \
+	( DEV_RATE_6MB | DEV_RATE_9MB | DEV_RATE_12MB | DEV_RATE_18MB | \
+	  DEV_RATE_24MB | DEV_RATE_36MB | DEV_RATE_48MB | DEV_RATE_54MB )
+
+/*
  * Macro's to set and get specific fields from the device specific val and val2
  * fields inside the ieee80211_rate entry.
  */
diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 15:49:42.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:01:03.000000000 +0200
@@ -1043,7 +1043,12 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR5 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
 
@@ -2187,11 +2192,9 @@
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
diff -rU3 wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 15:50:11.000000000 +0200
+++ wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:01:09.000000000 +0200
@@ -760,7 +760,12 @@
 	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE)
 		? SHORT_PREAMBLE : PREAMBLE;
 
-	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK);
+	/*
+	 * Extract the allowed ratemask from the device specific rate value,
+	 * We need to set TXRX_CSR5 to the basic rate mask so we need to mask
+	 * off the non-basic rates.
+	 */
+	reg = DEVICE_GET_RATE_FIELD(rate, RATEMASK) & DEV_BASIC_RATE;
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR5, cpu_to_le32(reg));
 
@@ -1782,11 +1787,9 @@
 	length = skb->len + 4;
 
 	/*
-	 * Check if we are working with an OFDM rate,
-	 * this can be done by checking if bit 4 or higher
-	 * is set in the ratemask.
+	 * Check if we are working with an OFDM rate.
 	 */
-	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & 0x0ff0) {
+	if (DEVICE_GET_RATE_FIELD(tx_rate, RATEMASK) & DEV_OFDM_RATE) {
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 1);
 
 		/*
