From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 13/24] RT2x00: Allow link tuning while scanning
Date: Wed, 26 Jul 2006 20:28:26 +0200
Message-ID: <200607262028.27016.IvDoorn@gmail.com>
References: <200607261905.23860.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751758AbWGZS2j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:28:39 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:28:38 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.23860.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

rt2x00 does not know when we are scanning,
unless passive_scan() is being used.
For consistent behaviour we should not block
tuning while scanning.
We should however not tune the connection when
it has been disabled in the hardware.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 22:41:58.000000000 +0200
+++ wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 22:59:00.000000000 +0200
@@ -811,9 +811,10 @@
 	u8 reg_r17;
 
 	/*
-	 * Don't perform any tuning during scan.
+	 * Don't perform any tuning when it is disabled
+	 * in the EEPROM.
 	 */
-	if (rt2x00dev->scan)
+	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING))
 		return;
 
 	rt2x00_register_read(rt2x00dev, CSR0, &reg);
@@ -2488,7 +2489,16 @@
 		SET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON);
 
 	/*
-	 * 7 - Read BBP data from EEPROM and store in private structure.
+	 * 7 - Check if the BBP tuning should be enabled.
+	 */
+	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &eeprom);
+	if (eeprom == 0xffff)
+		eeprom = 0;
+	if (rt2x00_get_field16(eeprom, EEPROM_NIC_DYN_BBP_TUNE))
+		SET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING);
+
+	/*
+	 * 8 - Read BBP data from EEPROM and store in private structure.
 	 */
 	rt2x00dev->eeprom = kzalloc(EEPROM_BBP_SIZE * sizeof(u16), GFP_KERNEL);
 	if (!rt2x00dev->eeprom)
diff -rU3 wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 22:42:03.000000000 +0200
+++ wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 23:00:43.000000000 +0200
@@ -617,15 +617,16 @@
  */
 static void rt2500usb_link_tuner(struct rt2x00_dev *rt2x00dev, char rssi)
 {
-	u16  reg;
+	u16 reg;
 	u8 reg_r17;
 	u8 up_bound;
 	u8 low_bound;
 
 	/*
-	 * Don't perform any tuning during scan.
+	 * Don't perform any tuning when it is disabled
+	 * in the EEPROM.
 	 */
-	if (rt2x00dev->scan)
+	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING))
 		return;
 
 	low_bound = 0x32;
@@ -2105,7 +2106,16 @@
 				EEPROM_ANTENNA_LED_MODE);
 
 	/*
-	 * 5 - Read BBP data from EEPROM and store in private structure.
+	 * 5 - Check if the BBP tuning should be disabled.
+	 */
+	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &eeprom);
+	if (eeprom == 0xffff)
+		eeprom = 0;
+	if (rt2x00_get_field16(eeprom, EEPROM_NIC_DYN_BBP_TUNE))
+		SET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING);
+
+	/*
+	 * 6 - Read BBP data from EEPROM and store in private structure.
 	 */
 	rt2x00dev->eeprom = kzalloc(EEPROM_BBP_SIZE * sizeof(u16), GFP_KERNEL);
 	if (!rt2x00dev->eeprom)
diff -rU3 wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 22:42:09.000000000 +0200
+++ wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 23:04:25.000000000 +0200
@@ -1043,12 +1043,6 @@
 	u8 up_bound;
 	u8 low_bound;
 
-	/*
-	 * Don't perform any tuning during scan.
-	 */
-	if (rt2x00dev->scan)
-		return;
-
 	if (rt2x00dev->rx_params.phymode == MODE_IEEE80211A) {
 		up_bound = 0x48;
 		low_bound = 0x28;
diff -rU3 wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 22:47:41.000000000 +0200
+++ wireless-dev-tuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 23:04:31.000000000 +0200
@@ -757,12 +757,6 @@
 	u8 up_bound;
 	u8 low_bound;
 
-	/*
-	 * Don't perform any tuning during scan.
-	 */
-	if (rt2x00dev->scan)
-		return;
-
 	if (rt2x00dev->rx_params.phymode == MODE_IEEE80211A) {
 		up_bound = 0x48;
 		low_bound = 0x28;
