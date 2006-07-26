From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 18/24] RT2x00: Make suspend and resume handlers work correctly
Date: Wed, 26 Jul 2006 19:05:43 +0200
Message-ID: <200607261905.43426.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030308AbWGZRHo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:44 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:43 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Fix suspend and resume handlers,
they should no longer use net_dev->open()
and net_dev->stop() since that delivers the wrong behaviour.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-25 20:21:44.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-25 23:27:17.000000000 +0200
@@ -2885,15 +2885,9 @@
 	NOTICE("Going to sleep.\n");
 
 	/*
-	 * If radio was enabled, stop radio and
-	 * set the resume flag to the radio will be enabled
-	 * when resuming.
-	 */
-	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		if (net_dev->stop(net_dev))
-			return -EBUSY;
-		SET_FLAG(rt2x00dev, RADIO_RESUME);
-	}
+	 * Disable the radio.
+	 */
+	rt2400pci_disable_radio(rt2x00dev);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -2902,11 +2896,16 @@
 		return -EBUSY;
 
 	/*
-	 * Uninitialize hardware.
+	 * Uninitialize device.
 	 */
 	rt2400pci_uninitialize(rt2x00dev);
 
 	/*
+	 * Uninitialize hardware.
+	 */
+	rt2400pci_free_dev(net_dev);
+
+	/*
 	 * Disable PCI.
 	 */
 	pci_save_state(pci_dev);
@@ -2934,28 +2933,15 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2400pci_initialize(rt2x00dev)) {
-		ERROR("Failed to initialize device.\n");
+	if (rt2400pci_alloc_dev(pci_dev, net_dev)) {
+		ERROR("Failed to allocate device.\n");
 		return -ENOMEM;
 	}
 
 	/*
-	 * Set device mode to awake.
+	 * Set device mode to awake for power management.
 	 */
-	if (rt2400pci_set_state(rt2x00dev, STATE_AWAKE))
-		return -EBUSY;
-
-	/*
-	 * Only enable radio when it was enabled
-	 * when we suspended.
-	 */
-	if (GET_FLAG(rt2x00dev, RADIO_RESUME)) {
-		if (net_dev->open(net_dev))
-			return -EBUSY;
-		CLEAR_FLAG(rt2x00dev, RADIO_RESUME);
-	}
-
-	return 0;
+	return rt2400pci_set_state(rt2x00dev, STATE_AWAKE);
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-25 20:21:45.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-25 23:27:54.000000000 +0200
@@ -3156,15 +3156,9 @@
 	NOTICE("Going to sleep.\n");
 
 	/*
-	 * If radio was enabled, stop radio and
-	 * set the resume flag to the radio will be enabled
-	 * when resuming.
-	 */
-	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		if (net_dev->stop(net_dev))
-			return -EBUSY;
-		SET_FLAG(rt2x00dev, RADIO_RESUME);
-	}
+	 * Disable the radio.
+	 */
+	rt2500pci_disable_radio(rt2x00dev);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3173,11 +3167,16 @@
 		return -EBUSY;
 
 	/*
-	 * Uninitialize hardware.
+	 * Uninitialize device.
 	 */
 	rt2500pci_uninitialize(rt2x00dev);
 
 	/*
+	 * Uninitialize hardware.
+	 */
+	rt2500pci_free_dev(net_dev);
+
+	/*
 	 * Disable PCI.
 	 */
 	pci_save_state(pci_dev);
@@ -3205,28 +3204,15 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500pci_initialize(rt2x00dev)) {
-		ERROR("Failed to initialize device.\n");
+	if (rt2500pci_alloc_dev(pci_dev, net_dev)) {
+		ERROR("Failed to allocate device.\n");
 		return -ENOMEM;
 	}
 
 	/*
-	 * Set device mode to awake.
+	 * Set device mode to awake for power management.
 	 */
-	if (rt2500pci_set_state(rt2x00dev, STATE_AWAKE))
-		return -EBUSY;
-
-	/*
-	 * Only enable radio when it was enabled
-	 * when we suspended.
-	 */
-	if (GET_FLAG(rt2x00dev, RADIO_RESUME)) {
-		if (net_dev->open(net_dev))
-			return -EBUSY;
-		CLEAR_FLAG(rt2x00dev, RADIO_RESUME);
-	}
-
-	return 0;
+	return rt2500pci_set_state(rt2x00dev, STATE_AWAKE);
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-25 20:21:43.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-25 23:28:54.000000000 +0200
@@ -2752,15 +2752,9 @@
 	NOTICE("Going to sleep.\n");
 
 	/*
-	 * If radio was enabled, stop radio and
-	 * set the resume flag to the radio will be enabled
-	 * when resuming.
-	 */
-	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		if (net_dev->stop(net_dev))
-			return -EBUSY;
-		SET_FLAG(rt2x00dev, RADIO_RESUME);
-	}
+	 * Disable the radio.
+	 */
+	rt2500usb_disable_radio(rt2x00dev);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -2769,11 +2763,16 @@
 		return -EBUSY;
 
 	/*
-	 * Uninitialize hardware.
+	 * Uninitialize device.
 	 */
 	rt2500usb_uninitialize(rt2x00dev);
 
 	/*
+	 * Uninitialize hardware.
+	 */
+	rt2500usb_free_dev(net_dev);
+
+	/*
 	 * Decrease usbdev refcount.
 	 */
 	usb_put_dev(interface_to_usbdev(usb_intf));
@@ -2796,28 +2795,15 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500usb_initializert2x00dev)) {
-		ERROR("Failed to initialize device.\n");
+	if (rt2500usb_alloc_dev(usb_intf, net_dev)) {
+		ERROR("Failed to allocate device.\n");
 		return -ENOMEM;
 	}
 
 	/*
-	 * Set device mode to awake.
+	 * Set device mode to awake for power management.
 	 */
-	if (rt2500usb_set_state(rt2x00dev, STATE_AWAKE))
-		return -EBUSY;
-
-	/*
-	 * Only enable radio when it was enabled
-	 * when we suspended.
-	 */
-	if (GET_FLAG(rt2x00dev, RADIO_RESUME)) {
-		if (net_dev->open(net_dev))
-			return -EBUSY;
-		CLEAR_FLAG(rt2x00dev, RADIO_RESUME);
-	}
-
-	return 0;
+	return rt2500usb_set_state(rt2x00dev, STATE_AWAKE);
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-25 
10:15:58.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-25 23:31:10.000000000 +0200
@@ -769,7 +769,6 @@
 #define CONFIG_EXTERNAL_LNA_BG		0x00008000
 #define CONFIG_DOUBLE_ANTENNA		0x00010000
 #define CONFIG_DISABLE_BBP_TUNING	0x00020000
-#define RADIO_RESUME			0x00040000
 
 	/*
 	 * Chipset identification.
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-25 
20:21:46.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-25 23:29:39.000000000 +0200
@@ -3733,15 +3733,9 @@
 	NOTICE("Going to sleep.\n");
 
 	/*
-	 * If radio was enabled, stop radio and
-	 * set the resume flag to the radio will be enabled
-	 * when resuming.
-	 */
-	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		if (net_dev->stop(net_dev))
-			return -EBUSY;
-		SET_FLAG(rt2x00dev, RADIO_RESUME);
-	}
+	 * Disable the radio.
+	 */
+	rt61pci_disable_radio(rt2x00dev);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3750,11 +3744,16 @@
 		return -EBUSY;
 
 	/*
-	 * Uninitialize hardware.
+	 * Uninitialize device.
 	 */
 	rt61pci_uninitialize(rt2x00dev);
 
 	/*
+	 * Uninitialize hardware.
+	 */
+	rt61pci_free_dev(net_dev);
+
+	/*
 	 * Disable PCI.
 	 */
 	pci_save_state(pci_dev);
@@ -3782,28 +3781,15 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt61pci_initialize(rt2x00dev)) {
-		ERROR("Failed to initialize device.\n");
+	if (rt61pci_alloc_dev(pci_dev, net_dev)) {
+		ERROR("Failed to allocate device.\n");
 		return -ENOMEM;
 	}
 
 	/*
-	 * Set device mode to awake.
+	 * Set device mode to awake for power management.
 	 */
-	if (rt61pci_set_state(rt2x00dev, STATE_AWAKE))
-		return -EBUSY;
-
-	/*
-	 * Only enable radio when it was enabled
-	 * when we suspended.
-	 */
-	if (GET_FLAG(rt2x00dev, RADIO_RESUME)) {
-		if (net_dev->open(net_dev))
-			return -EBUSY;
-		CLEAR_FLAG(rt2x00dev, RADIO_RESUME);
-	}
-
-	return 0;
+	return rt61pci_set_state(rt2x00dev, STATE_AWAKE);
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-25 
20:21:44.000000000 +0200
+++ wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-25 23:30:19.000000000 +0200
@@ -3149,15 +3149,9 @@
 	NOTICE("Going to sleep.\n");
 
 	/*
-	 * If radio was enabled, stop radio and
-	 * set the resume flag to the radio will be enabled
-	 * when resuming.
-	 */
-	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		if (net_dev->stop(net_dev))
-			return -EBUSY;
-		SET_FLAG(rt2x00dev, RADIO_RESUME);
-	}
+	 * Disable the radio.
+	 */
+	rt73usb_disable_radio(rt2x00dev);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3166,9 +3160,14 @@
 		return -EBUSY;
 
 	/*
+	 * Uninitialize device.
+	 */
+	rt73usb_uninitialize(rt2x00dev);
+
+	/*
 	 * Uninitialize hardware.
 	 */
-	rt73usb_uninitialize(net_dev);
+	rt73usb_free_dev(net_dev);
 
 	/*
 	 * Decrease usbdev refcount.
@@ -3193,28 +3192,15 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt73usb_initialize(rt2x00dev)) {
-		ERROR("Failed to initialize device.\n");
+	if (rt73usb_alloc_dev(usb_intf, net_dev)) {
+		ERROR("Failed to allocate device.\n");
 		return -ENOMEM;
 	}
 
 	/*
-	 * Set device mode to awake.
-	 */
-	if (rt73usb_set_state(rt2x00dev, STATE_AWAKE))
-		return -EBUSY;
-
-	/*
-	 * Only enable radio when it was enabled
-	 * when we suspended.
+	 * Set device mode to awake for power management.
 	 */
-	if (GET_FLAG(rt2x00dev, RADIO_RESUME)) {
-		if (net_dev->open(net_dev))
-			return -EBUSY;
-		CLEAR_FLAG(rt2x00dev, RADIO_RESUME);
-	}
-
-	return 0;
+	return rt73usb_set_state(rt2x00dev, STATE_AWAKE);
 }
 #endif /* CONFIG_PM */
 
