From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 8/24] RT2x00: Fix *_set_state() functions
Date: Wed, 26 Jul 2006 20:25:29 +0200
Message-ID: <200607262025.29274.IvDoorn@gmail.com>
References: <200607261905.00813.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:15622 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751751AbWGZSZl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:25:41 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839123nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:25:40 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.00813.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Fix problems with waking up the device at initialization time.
The debug message should be more descriptive of the problem,
when the device fails to wake up.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 18:16:35.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 18:34:06.000000000 +0200
@@ -857,7 +857,9 @@
 		msleep(10);
 	}
 
-	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+	NOTICE("Device failed to enter state %d, "
+		"current device state: bbp %d and rf %d.\n",
+		state, bbp_state, rf_state);
 
 	return -EBUSY;
 }
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 18:16:41.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 18:34:14.000000000 +0200
@@ -930,7 +930,9 @@
 		msleep(10);
 	}
 
-	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+	NOTICE("Device failed to enter state %d, "
+		"current device state: bbp %d and rf %d.\n",
+		state, bbp_state, rf_state);
 
 	return -EBUSY;
 }
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 18:15:52.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 18:36:12.000000000 +0200
@@ -731,6 +731,7 @@
 	enum dev_state state)
 {
 	u16 reg;
+	u16 reg2;
 	unsigned int i;
 	char put_to_sleep;
 	char bbp_state;
@@ -739,11 +740,12 @@
 	put_to_sleep = (state != STATE_AWAKE);
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR17, &reg);
-	rt2x00_set_field16_nb(&reg, MAC_CSR17_SET_STATE, 1);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, put_to_sleep);
 	rt2x00_register_write(rt2x00dev, MAC_CSR17, reg);
+	rt2x00_set_field16_nb(&reg, MAC_CSR17_SET_STATE, 1);
+	rt2x00_register_write(rt2x00dev, MAC_CSR17, reg);
 
 	/*
 	 * Device is not guarenteed to be in the requested state yet.
@@ -751,16 +753,20 @@
 	 * device has entered the correct state.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00_register_read(rt2x00dev, MAC_CSR17, &reg);
-		bbp_state = rt2x00_get_field16_nb(
-			reg, MAC_CSR17_BBP_CURR_STATE);
-		rf_state = rt2x00_get_field16_nb(reg, MAC_CSR17_RF_CURR_STATE);
+		rt2x00_register_read(rt2x00dev, MAC_CSR17, &reg2);
+		bbp_state = rt2x00_get_field16_nb(reg2,
+			MAC_CSR17_BBP_CURR_STATE);
+		rf_state = rt2x00_get_field16_nb(reg2,
+			MAC_CSR17_RF_CURR_STATE);
 		if (bbp_state == state && rf_state == state)
 			return 0;
+		rt2x00_register_write(rt2x00dev, MAC_CSR17, reg);
 		msleep(10);
 	}
 
-	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+	NOTICE("Device failed to enter state %d, "
+		"current device state: bbp %d and rf %d.\n",
+		state, bbp_state, rf_state);
 
 	return -EBUSY;
 }
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 18:16:51.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 19:22:41.000000000 +0200
@@ -1169,19 +1169,33 @@
 	u32 reg;
 	unsigned int i;
 	char put_to_sleep;
+	char current_state;
 
 	put_to_sleep = (state != STATE_AWAKE);
 
-	if (!put_to_sleep)
-		rt2x00_mcu_request(rt2x00dev, MCU_WAKEUP, 0xff, 0x00, 0x00);
-
 	rt2x00_register_read(rt2x00dev, MAC_CSR12, &reg);
 	rt2x00_set_field32(&reg, MAC_CSR12_FORCE_WAKEUP, !put_to_sleep);
 	rt2x00_set_field32(&reg, MAC_CSR12_PUT_TO_SLEEP, put_to_sleep);
 	rt2x00_register_write(rt2x00dev, MAC_CSR12, reg);
 
-	if (put_to_sleep)
+	if (put_to_sleep) {
+		rt2x00_register_write(rt2x00dev,
+			SOFT_RESET_CSR, cpu_to_le32(0x00000005));
+		rt2x00_register_write(rt2x00dev,
+			IO_CNTL_CSR, cpu_to_le32(0x0000001c));
+		rt2x00_register_write(rt2x00dev,
+			PCI_USEC_CSR, cpu_to_le32(0x00000060));
+
 		rt2x00_mcu_request(rt2x00dev, MCU_SLEEP, 0xff, 0x00, 0x00);
+	} else {
+		rt2x00_register_write(rt2x00dev,
+			SOFT_RESET_CSR, cpu_to_le32(0x00000007));
+		rt2x00_register_write(rt2x00dev,
+			IO_CNTL_CSR, cpu_to_le32(0x00000018));
+		rt2x00_register_write(rt2x00dev,
+			PCI_USEC_CSR, cpu_to_le32(0x00000020));
+		rt2x00_mcu_request(rt2x00dev, MCU_WAKEUP, 0xff, 0x00, 0x00);
+	}
 
 	/*
 	 * Device is not guarenteed to be in the requested state yet.
@@ -1190,13 +1204,15 @@
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, MAC_CSR12, &reg);
-		if (rt2x00_get_field32(
-			reg, MAC_CSR12_CURRENT_STATE) == !put_to_sleep)
+		current_state = rt2x00_get_field32(reg,
+			MAC_CSR12_BBP_CURRENT_STATE);
+		if (current_state == !put_to_sleep)
 			return 0;
 		msleep(10);
 	}
 
-	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+	NOTICE("Device failed to enter state %d, "
+		"current device state %d.\n", !put_to_sleep, current_state);
 
 	return -EBUSY;
 }
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 17:16:49.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 18:33:18.000000000 +0200
@@ -311,11 +311,13 @@
  * MAC_CSR12: Manual power control / status register (merge CSR20 & PWRCSR1).
  * CURRENT_STATE: 0:sleep, 1:awake.
  * FORCE_WAKEUP: This has higher priority than PUT_TO_SLEEP.
+ * BBP_CURRENT_STATE: 0: BBP sleep, 1: BBP awake.
  */
 #define MAC_CSR12			0x3030
 #define MAC_CSR12_CURRENT_STATE		FIELD32(0x00000001)
 #define MAC_CSR12_PUT_TO_SLEEP		FIELD32(0x00000002)
 #define MAC_CSR12_FORCE_WAKEUP		FIELD32(0x00000004)
+#define MAC_CSR12_BBP_CURRENT_STATE	FIELD32(0x00000008)
 
 /*
  * MAC_CSR13: GPIO.
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 18:17:01.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 19:23:14.000000000 +0200
@@ -895,6 +895,7 @@
 	u32 reg;
 	unsigned int i;
 	char put_to_sleep;
+	char current_state;
 
 	put_to_sleep = (state != STATE_AWAKE);
 
@@ -920,13 +921,15 @@
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00_register_read(rt2x00dev, MAC_CSR12, &reg);
-		if (rt2x00_get_field32(
-			reg, MAC_CSR12_CURRENT_STATE) == !put_to_sleep)
+		current_state = rt2x00_get_field32(reg,
+			MAC_CSR12_BBP_CURRENT_STATE);
+		if (current_state == !put_to_sleep)
 			return 0;
 		msleep(10);
 	}
 
-	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+	NOTICE("Device failed to enter state %d, "
+		"current device state %d.\n", !put_to_sleep, current_state);
 
 	return -EBUSY;
 }
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-23 17:17:09.000000000 +0200
+++ wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-23 18:33:18.000000000 +0200
@@ -218,11 +218,13 @@
  * MAC_CSR12: Manual power control / status register (merge CSR20 & PWRCSR1).
  * CURRENT_STATE: 0:sleep, 1:awake.
  * FORCE_WAKEUP: This has higher priority than PUT_TO_SLEEP.
+ * BBP_CURRENT_STATE: 0: BBP sleep, 1: BBP awake.
  */
 #define MAC_CSR12			0x3030
 #define MAC_CSR12_CURRENT_STATE		FIELD32(0x00000001)
 #define MAC_CSR12_PUT_TO_SLEEP		FIELD32(0x00000002)
 #define MAC_CSR12_FORCE_WAKEUP		FIELD32(0x00000004)
+#define MAC_CSR12_BBP_CURRENT_STATE	FIELD32(0x00000008)
 
 /*
  * MAC_CSR13: GPIO.
