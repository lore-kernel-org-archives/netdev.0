From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 14/24] RT2x00: Check if read eeprom words are valid
Date: Wed, 26 Jul 2006 20:28:45 +0200
Message-ID: <200607262028.45332.IvDoorn@gmail.com>
References: <200607261905.28121.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161009AbWGZS26 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:28:58 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:28:57 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.28121.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Make checks if the EEPROM data read is valid,
if it is not, use the default values.
Also fix the endian issue when reading the PCI_CONFIG_HEADER.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 23:04:25.000000000 +0200
+++ wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 23:19:17.000000000 +0200
@@ -2914,6 +2914,7 @@
 	u32 reg;
 	u16 value;
 	u16 eeprom;
+	u16 device;
 
 	/*
 	 * 1 - Detect EEPROM width.
@@ -2934,12 +2935,11 @@
 	 * To determine the RT chip we have to read the
 	 * PCI header of the device.
 	 */
-	pci_read_config_dword(rt2x00dev_pci(rt2x00dev),
-		PCI_CONFIG_HEADER, &reg);
-	reg = rt2x00_get_field32(reg, PCI_CONFIG_HEADER_DEVICE);
+	pci_read_config_word(
+		rt2x00dev_pci(rt2x00dev), PCI_CONFIG_HEADER_DEVICE, &device);
 
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, (u16)reg, value);
+	rt2x00_set_chip(&rt2x00dev->chip, device, value);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF5225) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF5325) &&
@@ -2985,6 +2985,8 @@
 	 * 8 - Read external LNA informations.
 	 */
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &eeprom);
+	if (eeprom == 0xffff)
+		eeprom = 0;
 	if (rt2x00_get_field16(eeprom, EEPROM_NIC_EXTERNAL_LNA_A))
 		SET_FLAG(rt2x00dev, CONFIG_EXTERNAL_LNA_A);
 	if (rt2x00_get_field16(eeprom, EEPROM_NIC_EXTERNAL_LNA_BG))
@@ -2994,58 +2996,35 @@
 	 * 9 - Store led settings, for correct led behaviour.
 	 */
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_LED, &eeprom);
-	if (eeprom == 0xffff) {
-		rt2x00dev->led_mode = LED_MODE_DEFAULT;
 
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_LED_MODE, LED_MODE_DEFAULT);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_0, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_1, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_2, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_3, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_4, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_ACT, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_BG, 1);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_A, 1);
-	} else {
+	/*
+	 * If the eeprom value is invalid,
+	 * switch to default led mode.
+	 */
+	if (eeprom == 0xffff)
+		rt2x00dev->led_mode = LED_MODE_DEFAULT;
+	else
 		rt2x00dev->led_mode = rt2x00_get_field16(eeprom,
 			EEPROM_LED_LED_MODE);
 
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_LED_MODE, rt2x00dev->led_mode);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_0, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_0));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_1, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_1));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_2, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_2));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_3, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_3));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_4, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_4));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_ACT, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_ACT));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_BG, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_RDY_G));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_A, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_RDY_A));
-	}
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_LED_MODE,
+		rt2x00dev->led_mode);
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_0,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_0));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_1,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_1));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_2,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_2));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_3,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_3));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_4,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_4));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_ACT,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_ACT));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_READY_BG,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_RDY_G));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_READY_A,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_RDY_A));
 
 	/*
 	 * 10 - Detect if this device has an hardware controlled radio.
diff -rU3 wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 19:33:56.000000000 +0200
+++ wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 23:21:39.000000000 +0200
@@ -57,9 +57,8 @@
 /*
  * PCI Configuration Header
  */
-#define PCI_CONFIG_HEADER		0x0000
-#define PCI_CONFIG_HEADER_VENDOR	FIELD32(0x0000ffff)
-#define PCI_CONFIG_HEADER_DEVICE	FIELD32(0xffff0000)
+#define PCI_CONFIG_HEADER_VENDOR	0x0000
+#define PCI_CONFIG_HEADER_DEVICE	0x0002
 
 /*
  * HOST_CMD_CSR: For HOST to interrupt embedded processor
diff -rU3 wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 23:04:31.000000000 +0200
+++ wireless-dev-eeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 23:17:42.000000000 +0200
@@ -2475,6 +2475,8 @@
 	 * 7 - Read external LNA informations.
 	 */
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &eeprom);
+	if (eeprom == 0xffff)
+		eeprom = 0;
 	if (rt2x00_get_field16(eeprom, EEPROM_NIC_EXTERNAL_LNA))
 		SET_FLAG(rt2x00dev, CONFIG_EXTERNAL_LNA);
 
@@ -2482,58 +2484,36 @@
 	 * 8 - Store led settings, for correct led behaviour.
 	 */
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_LED, &eeprom);
+
+	/*
+	 * If the eeprom value is invalid,
+	 * switch to default led mode, and clear all bits.
+	 */
 	if (eeprom == 0xffff) {
 		rt2x00dev->led_mode = LED_MODE_DEFAULT;
-
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_LED_MODE, LED_MODE_DEFAULT);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_0, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_1, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_2, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_3, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_4, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_ACT, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_BG, 0);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_A, 0);
-	} else {
+		eeprom = 0x0000;
+	} else
 		rt2x00dev->led_mode = rt2x00_get_field16(eeprom,
 			EEPROM_LED_LED_MODE);
 
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_LED_MODE, rt2x00dev->led_mode);
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_0, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_0));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_1, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_1));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_2, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_2));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_3, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_3));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_GPIO_4, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_GPIO_4));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_ACT, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_ACT));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_BG, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_RDY_G));
-		rt2x00_set_field16(&rt2x00dev->led_reg,
-			MCU_LEDCS_POLARITY_READY_A, rt2x00_get_field16(eeprom,
-			EEPROM_LED_POLARITY_RDY_A));
-	}
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_LED_MODE,
+		rt2x00dev->led_mode);
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_0,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_0));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_1,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_1));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_2,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_2));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_3,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_3));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_GPIO_4,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_GPIO_4));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_ACT,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_ACT));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_READY_BG,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_RDY_G));
+	rt2x00_set_field16(&rt2x00dev->led_reg, MCU_LEDCS_POLARITY_READY_A,
+		rt2x00_get_field16(eeprom, EEPROM_LED_POLARITY_RDY_A));
 
 	/*
 	 * 9 - Read BBP data from EEPROM and store in private structure.
