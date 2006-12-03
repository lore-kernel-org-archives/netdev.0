From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 08/26] rt2x00: Rssi detection
Date: Sun, 3 Dec 2006 19:19:03 +0100
Message-ID: <200612031919.03866.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:25433 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759973AbWLCSTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:33 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144386nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:33 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly detect the maxssi settings from the EEPROM
where available, and correct the dummy values that
had been added in the initial patch to support
noise and signal measurement.
MAX_RX_SSI is a value that is different on each chipset,
so it should be a driver specific define.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 12:38:28.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 12:46:41.000000000 +0100
@@ -1550,13 +1550,15 @@
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word2, RXD_W2_RSSI);
 
-/* FIXME: The following set of assignments supply additional data for wireless statistics. The
-          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
-          The present code supplies dummy values for these quantities. */
-
-			rt2x00dev->rx_params.noise = -85;   /* FIXME */
-			rt2x00dev->rx_params.signal =
-				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+			/*
+			 * The following set of assignments supply
+			 * additional data for wireless statistics. The
+			 * necessary quantities are (1) the "noise" value
+			 * in dBm, and (2) the "signal" value in dBm.
+			 */
+			rt2x00dev->rx_params.noise = 0;
+			rt2x00dev->rx_params.signal = rt2x00dev->rx_params.ssi
+				- rt2x00dev->hw->maxssi;
 
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-02 23:22:43.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 12:49:55.000000000 +0100
@@ -39,6 +39,11 @@
 #define RF2421				0x0001
 
 /*
+ * Max RSSI value, required for RSSI <-> dBm conversion.
+ */
+#define MAX_RX_SSI			100
+
+/*
  * Register layout information.
  */
 #define CSR_REG_BASE			0x0000
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 12:34:39.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 12:47:36.000000000 +0100
@@ -1707,13 +1707,16 @@
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word2, RXD_W2_RSSI);
 
-/* FIXME: The following set of assignments supply additional data for wireless statistics. The
-          necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
-          The present code supplies dummy values for these quantities. */
-
-			rt2x00dev->rx_params.noise = -85;   /* FIXME */
-			rt2x00dev->rx_params.signal =
-				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+			/*
+			 * The following set of assignments supply
+			 * additional data for wireless statistics. The
+			 * necessary quantities are (1) the "noise" value
+			 * in dBm, and (2) the "signal" value in dBm.
+			 */
+			rt2x00dev->rx_params.noise =
+				rt2x00_get_link_noise(&rt2x00dev->link);
+			rt2x00dev->rx_params.signal = rt2x00dev->rx_params.ssi
+				- rt2x00dev->hw->maxssi;
 
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
@@ -2588,6 +2591,15 @@
 	if (rt2x00_get_field16(eeprom, EEPROM_NIC_DYN_BBP_TUNE))
 		SET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING);
 
+	/*
+	 * Read the RSSI <-> dBm offset information.
+	 */
+	rt2x00_eeprom_read(rt2x00dev, EEPROM_CALIBRATE_OFFSET, &eeprom);
+	rt2x00dev->hw->maxssi =
+		rt2x00_get_field16(eeprom, EEPROM_CALIBRATE_OFFSET_RSSI);
+	if (rt2x00dev->hw->maxssi == 0x00 || rt2x00dev->hw->maxssi == 0xff)
+		rt2x00dev->hw->maxssi = MAX_RX_SSI;
+
 	return 0;
 }
 
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-02 23:22:56.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-03 12:50:28.000000000 +0100
@@ -50,6 +50,11 @@
 #define RT2560_VERSION_D		4
 
 /*
+ * Max RSSI value, required for RSSI <-> dBm conversion.
+ */
+#define MAX_RX_SSI			120
+
+/*
  * Register layout information.
  */
 #define CSR_REG_BASE			0x0000
@@ -1001,6 +1006,12 @@
 #define EEPROM_TXPOWER_2		FIELD16(0xff00)
 
 /*
+ * RSSI <-> dBm offset calibration
+ */
+#define EEPROM_CALIBRATE_OFFSET		0x3e
+#define EEPROM_CALIBRATE_OFFSET_RSSI	FIELD16(0x00ff)
+
+/*
  * DMA descriptor defines.
  */
 #define TXD_DESC_SIZE			( 11 * sizeof(struct data_desc) )
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 12:35:13.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 12:48:18.000000000 +0100
@@ -1657,13 +1657,16 @@
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
-/* FIXME: The following set of assignments supply additional data for wireless statistics. The
-	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
-	  The present code supplies dummy values for these quantities. */
-
-			rt2x00dev->rx_params.noise = -85;   /* FIXME */
-			rt2x00dev->rx_params.signal =
-				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+			/*
+			 * The following set of assignments supply
+			 * additional data for wireless statistics. The
+			 * necessary quantities are (1) the "noise" value
+			 * in dBm, and (2) the "signal" value in dBm.
+			 */
+			rt2x00dev->rx_params.noise =
+				rt2x00_get_link_noise(&rt2x00dev->link);
+			rt2x00dev->rx_params.signal = rt2x00dev->rx_params.ssi
+				- rt2x00dev->hw->maxssi;
 
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
@@ -2397,6 +2400,15 @@
 	if (rt2x00_get_field16(eeprom, EEPROM_NIC_DYN_BBP_TUNE))
 		SET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING);
 
+	/*
+	 * Read the RSSI <-> dBm offset information.
+	 */
+	rt2x00_eeprom_read(rt2x00dev, EEPROM_CALIBRATE_OFFSET, &eeprom);
+	rt2x00dev->hw->maxssi =
+		rt2x00_get_field16(eeprom, EEPROM_CALIBRATE_OFFSET_RSSI);
+	if (rt2x00dev->hw->maxssi == 0x00 || rt2x00dev->hw->maxssi == 0xff)
+		rt2x00dev->hw->maxssi = MAX_RX_SSI;
+
 	return 0;
 }
 
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-02 23:23:08.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 12:51:02.000000000 +0100
@@ -43,6 +43,11 @@
 #define RF5222				0x0010
 
 /*
+ * Max RSSI value, required for RSSI <-> dBm conversion.
+ */
+#define MAX_RX_SSI			120
+
+/*
  * Register layout information.
  */
 #define CSR_REG_BASE			0x0400
@@ -556,6 +561,12 @@
 #define EEPROM_TXPOWER_2		FIELD16(0xff00)
 
 /*
+ * RSSI <-> dBm offset calibration
+ */
+#define EEPROM_CALIBRATE_OFFSET		0x36
+#define EEPROM_CALIBRATE_OFFSET_RSSI	FIELD16(0x00ff)
+
+/*
  * DMA descriptor defines.
  */
 #define TXD_DESC_SIZE			( 5 * sizeof(struct data_desc) )
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 00:03:07.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 12:56:07.000000000 +0100
@@ -851,8 +851,6 @@
 #define CONFIG_DOUBLE_ANTENNA		0x00010000
 #define CONFIG_DISABLE_BBP_TUNING	0x00020000
 
-#define RT2X00_RX_MAX_SSI		100
-
 	/*
 	 * Chipset identification.
 	 */
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 12:35:34.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 12:48:43.000000000 +0100
@@ -2158,13 +2158,16 @@
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
-/* FIXME: The following set of assignments supply additional data for wireless statistics. The
-	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
-	  The present code supplies dummy values for these quantities. */
-
-			rt2x00dev->rx_params.noise = -85;   /* FIXME */
-			rt2x00dev->rx_params.signal =
-				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+			/*
+			 * The following set of assignments supply
+			 * additional data for wireless statistics. The
+			 * necessary quantities are (1) the "noise" value
+			 * in dBm, and (2) the "signal" value in dBm.
+			 */
+			rt2x00dev->rx_params.noise =
+				rt2x00_get_link_noise(&rt2x00dev->link);
+			rt2x00dev->rx_params.signal = rt2x00dev->rx_params.ssi
+				- rt2x00dev->hw->maxssi;
 
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-02 23:23:20.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 12:51:17.000000000 +0100
@@ -43,6 +43,11 @@
 #define RF2529				0x0004
 
 /*
+ * Max RSSI value, required for RSSI <-> dBm conversion.
+ */
+#define MAX_RX_SSI			120
+
+/*
  * Register layout information.
  */
 #define CSR_REG_BASE			0x3000
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 12:35:52.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 12:48:57.000000000 +0100
@@ -1932,13 +1932,16 @@
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
-/* FIXME: The following set of assignments supply additional data for wireless statistics. The
-	  necessary quantities are (1) the "noise" value in dBm, and (2) the "signal" value in dBm.
-	  The present code supplies dummy values for these quantities. */
-
-			rt2x00dev->rx_params.noise = -85;   /* FIXME */
-			rt2x00dev->rx_params.signal =
-				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
+			/*
+			 * The following set of assignments supply
+			 * additional data for wireless statistics. The
+			 * necessary quantities are (1) the "noise" value
+			 * in dBm, and (2) the "signal" value in dBm.
+			 */
+			rt2x00dev->rx_params.noise =
+				rt2x00_get_link_noise(&rt2x00dev->link);
+			rt2x00dev->rx_params.signal = rt2x00dev->rx_params.ssi
+				- rt2x00dev->hw->maxssi;
 
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
diff -rU3 wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-bbp/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-02 23:23:31.000000000 +0100
+++ wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 12:51:34.000000000 +0100
@@ -41,6 +41,11 @@
 #define RF2527				0x0004
 
 /*
+ * Max RSSI value, required for RSSI <-> dBm conversion.
+ */
+#define MAX_RX_SSI			120
+
+/*
  * Register layout information.
  */
 #define CSR_REG_BASE			0x3000
