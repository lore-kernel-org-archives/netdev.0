From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 17/26] rt2x00: Move rt2x00usb_vendor_request out of header
Date: Sun, 3 Dec 2006 19:18:59 +0100
Message-ID: <200612031919.00075.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:25433 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758826AbWLCST3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:29 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144386nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:28 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the rt2x00usb_vendor_request from the rt2x00usb.h
header, and place it into the rt2x00_vendor_request.
This means that the rt2x00_vendor_request function
needs a timeout value especially for commands that
require a lot of time (i.e. Firmware writing).

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:21:53.000000000 +0100
+++ wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:36:31.000000000 +0100
@@ -64,18 +64,31 @@
  * the access attempt is considered to have failed,
  * and we will print an error.
  */
-static void rt2x00_vendor_request(const struct rt2x00_dev *rt2x00dev,
+static int rt2x00_vendor_request(const struct rt2x00_dev *rt2x00dev,
 	const u8 request, const u8 type, const u16 offset,
-	u32 value, void *buffer, const u16 buffer_length)
+	u32 value, void *buffer, const u16 buffer_length, const u16 timeout)
 {
-	int status = rt2x00usb_vendor_request(
-		rt2x00dev, request, type, offset,
-		value, buffer, buffer_length, REGISTER_TIMEOUT);
-
-	if (status < 0)
-		ERROR("vendor request error. Request 0x%02x failed "
-			"for offset 0x%04x with error %d.\n",
-			request, offset, status);
+	struct usb_device *usb_dev = interface_to_usbdev(
+		rt2x00dev_usb(rt2x00dev));
+	int status;
+	unsigned int i;
+
+	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
+		status = usb_control_msg(
+			usb_dev,
+			(type == USB_VENDOR_REQUEST_IN) ?
+				usb_rcvctrlpipe(usb_dev, 0) :
+				usb_sndctrlpipe(usb_dev, 0),
+			request, type, value, offset, buffer, buffer_length,
+			timeout);
+		if (status >= 0)
+			return 0;
+	}
+
+	ERROR("vendor request error. Request 0x%02x failed "
+		"for offset 0x%04x with error %d.\n", request, offset, status);
+
+	return status;
 }
 
 static inline void rt2x00_register_read(
@@ -85,7 +98,7 @@
 	__le16 reg;
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_READ, USB_VENDOR_REQUEST_IN,
-		offset, 0x00, &reg, 2);
+		offset, 0x00, &reg, 2, REGISTER_TIMEOUT);
 	*value = le16_to_cpu(reg);
 }
 
@@ -95,7 +108,7 @@
 {
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_READ, USB_VENDOR_REQUEST_IN,
-		offset, 0x00, value, length);
+		offset, 0x00, value, length, REGISTER_TIMEOUT);
 }
 
 static inline void rt2x00_register_write(
@@ -105,7 +118,7 @@
 	__le16 reg = cpu_to_le16(value);
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_WRITE, USB_VENDOR_REQUEST_OUT,
-		offset, 0x00, &reg, 2);
+		offset, 0x00, &reg, 2, REGISTER_TIMEOUT);
 }
 
 static inline void rt2x00_register_multiwrite(
@@ -114,7 +127,7 @@
 {
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_WRITE, USB_VENDOR_REQUEST_OUT,
-		offset, 0x00, value, length);
+		offset, 0x00, value, length, REGISTER_TIMEOUT);
 }
 
 static u16 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
@@ -1071,9 +1084,11 @@
 		return -EBUSY;
 
 	rt2x00_vendor_request(rt2x00dev, USB_DEVICE_MODE,
-		USB_VENDOR_REQUEST_OUT, 0x00, USB_MODE_TEST, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x0000, USB_MODE_TEST, NULL, 0,
+		REGISTER_TIMEOUT);
 	rt2x00_vendor_request(rt2x00dev, USB_SINGLE_WRITE,
-		USB_VENDOR_REQUEST_OUT, 0x0308, 0xf0, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x0308, 0xf0, NULL, 0,
+		REGISTER_TIMEOUT);
 
 	rt2x00_register_write(rt2x00dev, MAC_CSR13, 0x1111);
 	rt2x00_register_write(rt2x00dev, MAC_CSR14, 0x1e11);
@@ -1392,7 +1407,7 @@
 	rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
 
 	rt2x00_vendor_request(rt2x00dev, USB_RX_CONTROL,
-		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0, REGISTER_TIMEOUT);
 
 	ring = &rt2x00dev->ring[RING_RX];
 	for (i = 0; i < ring->stats.limit; i++)
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	2006-12-03 14:30:31.000000000 +0100
@@ -73,32 +73,4 @@
 #define USB_MODE_FIRMWARE	0x08	/* RT73USB */
 #define USB_MODE_WAKEUP		0x09	/* RT73USB */
 
-/*
- * Vendor request command for sending
- * vendor specific instructions to the device.
- */
-static inline int rt2x00usb_vendor_request(const struct rt2x00_dev *rt2x00dev,
-	const u8 request, const u8 type, const u16 offset,
-	u32 value, void *buffer, const u16 buffer_length, const u16 timeout)
-{
-	struct usb_device *usb_dev = interface_to_usbdev(
-		rt2x00dev_usb(rt2x00dev));
-	int status;
-	unsigned int i;
-
-	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		status = usb_control_msg(
-			usb_dev,
-			(type == USB_VENDOR_REQUEST_IN) ?
-				usb_rcvctrlpipe(usb_dev, 0) :
-				usb_sndctrlpipe(usb_dev, 0),
-			request, type, value, offset, buffer, buffer_length,
-			timeout);
-		if (status >= 0)
-			return 0;
-	}
-
-	return status;
-}
-
 #endif /* RT2X00USB_H */
diff -rU3 wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rts/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:23:22.000000000 +0100
+++ wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:37:02.000000000 +0100
@@ -66,18 +66,31 @@
  * the access attempt is considered to have failed,
  * and we will print an error.
  */
-static void rt2x00_vendor_request(const struct rt2x00_dev *rt2x00dev,
+static int rt2x00_vendor_request(const struct rt2x00_dev *rt2x00dev,
 	const u8 request, const u8 type, const u16 offset,
-	u32 value, void *buffer, const u16 buffer_length)
+	u32 value, void *buffer, const u16 buffer_length, const u16 timeout)
 {
-	int status = rt2x00usb_vendor_request(
-		rt2x00dev, request, type, offset,
-		value, buffer, buffer_length, REGISTER_TIMEOUT);
-
-	if (status < 0)
-		ERROR("vendor request error. Request 0x%02x failed "
-			"for offset 0x%04x with error %d.\n",
-			request, offset, status);
+	struct usb_device *usb_dev = interface_to_usbdev(
+		rt2x00dev_usb(rt2x00dev));
+	int status;
+	unsigned int i;
+
+	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
+		status = usb_control_msg(
+			usb_dev,
+			(type == USB_VENDOR_REQUEST_IN) ?
+				usb_rcvctrlpipe(usb_dev, 0) :
+				usb_sndctrlpipe(usb_dev, 0),
+			request, type, value, offset, buffer, buffer_length,
+			timeout);
+		if (status >= 0)
+			return 0;
+	}
+
+	ERROR("vendor request error. Request 0x%02x failed "
+		"for offset 0x%04x with error %d.\n", request, offset, status);
+
+	return status;
 }
 
 static inline void rt2x00_register_read(
@@ -85,9 +98,9 @@
 	const u16 offset, u32 *value)
 {
 	__le32 reg;
- 	rt2x00_vendor_request(
- 		rt2x00dev, USB_MULTI_READ, USB_VENDOR_REQUEST_IN,
-		offset, 0x00, reg, 4);
+	rt2x00_vendor_request(
+		rt2x00dev, USB_MULTI_READ, USB_VENDOR_REQUEST_IN,
+		offset, 0x00, &reg, 4, REGISTER_TIMEOUT);
 	*value = le32_to_cpu(reg);
 }
 
@@ -97,7 +110,7 @@
 {
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_READ, USB_VENDOR_REQUEST_IN,
-		offset, 0x00, value, length);
+		offset, 0x00, value, length, REGISTER_TIMEOUT);
 }
 
 static inline void rt2x00_register_write(
@@ -107,7 +120,7 @@
 	__le32 reg = cpu_to_le32(value);
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_WRITE, USB_VENDOR_REQUEST_OUT,
-		offset, 0x00, &reg, 4);
+		offset, 0x00, &reg, 4, REGISTER_TIMEOUT);
 }
 
 static inline void rt2x00_register_multiwrite(
@@ -116,7 +129,7 @@
 {
 	rt2x00_vendor_request(
 		rt2x00dev, USB_MULTI_WRITE, USB_VENDOR_REQUEST_OUT,
-		offset, 0x00, value, length);
+		offset, 0x00, value, length, REGISTER_TIMEOUT);
 }
 
 static u32 rt2x00_bbp_check(const struct rt2x00_dev *rt2x00dev)
@@ -923,7 +936,7 @@
 
 	rt2x00_vendor_request(
 		rt2x00dev, USB_LED_CONTROL, USB_VENDOR_REQUEST_OUT,
-		0x00, rt2x00dev->led_reg, NULL, 0);
+		0x00, rt2x00dev->led_reg, NULL, 0, REGISTER_TIMEOUT);
 }
 
 static void rt73usb_disable_led(struct rt2x00_dev *rt2x00dev)
@@ -934,7 +947,7 @@
 
 	rt2x00_vendor_request(
 		rt2x00dev, USB_LED_CONTROL, USB_VENDOR_REQUEST_OUT,
-		0x00, rt2x00dev->led_reg, NULL, 0);
+		0x00, rt2x00dev->led_reg, NULL, 0, REGISTER_TIMEOUT);
 }
 
 static void rt73usb_activity_led(struct rt2x00_dev *rt2x00dev, char rssi)
@@ -959,7 +972,7 @@
 
 	rt2x00_vendor_request(
 		rt2x00dev, USB_LED_CONTROL, USB_VENDOR_REQUEST_OUT,
-		led, rt2x00dev->led_reg, NULL, 0);
+		led, rt2x00dev->led_reg, NULL, 0, REGISTER_TIMEOUT);
 }
 
 /*
@@ -979,7 +992,7 @@
 	if (!put_to_sleep)
 		rt2x00_vendor_request(rt2x00dev,
 			USB_DEVICE_MODE, USB_VENDOR_REQUEST_OUT,
-			0x00, USB_MODE_WAKEUP, NULL, 0);
+			0x00, USB_MODE_WAKEUP, NULL, 0, REGISTER_TIMEOUT);
 
 	rt2x00_register_read(rt2x00dev, MAC_CSR12, &reg);
 	rt2x00_set_field32(&reg, MAC_CSR12_FORCE_WAKEUP, !put_to_sleep);
@@ -989,7 +1002,7 @@
 	if (put_to_sleep)
 		rt2x00_vendor_request(rt2x00dev,
 			USB_DEVICE_MODE, USB_VENDOR_REQUEST_OUT,
-			0x00, USB_MODE_SLEEP, NULL, 0);
+			0x00, USB_MODE_SLEEP, NULL, 0, REGISTER_TIMEOUT);
 
 	/*
 	 * Device is not guarenteed to be in the requested state yet.
@@ -1086,10 +1099,9 @@
 
 	/*
 	 * Send firmware request to device to load firmware,
-	 * use the rt2x00usb_vendor_request() function
-	 * since we need to specify a long timeout time.
+	 * we need to specify a long timeout time.
 	 */
-	status = rt2x00usb_vendor_request(rt2x00dev, USB_DEVICE_MODE,
+	status = rt2x00_vendor_request(rt2x00dev, USB_DEVICE_MODE,
 		USB_VENDOR_REQUEST_OUT, 0x00, USB_MODE_FIRMWARE,
 		NULL, 0, REGISTER_TIMEOUT_FIRMWARE);
 	if (status  < 0) {
@@ -1648,7 +1660,7 @@
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
 
 	rt2x00_vendor_request(rt2x00dev, USB_RX_CONTROL,
-		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0, REGISTER_TIMEOUT);
 
 	ring = &rt2x00dev->ring[RING_RX];
 	for (i = 0; i < ring->stats.limit; i++)
