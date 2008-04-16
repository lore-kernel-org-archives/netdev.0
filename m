From: Oliver Neukum <oliver@neukum.org>
Subject: remove special ioctl from hso driver, replace by rfkill
Date: Wed, 16 Apr 2008 14:28:17 +0200
Message-ID: <200804161428.18066.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42768 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbYDPMX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 08:23:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

could you test this patch?
It does away with the one off serial ioctl replacing it with a standard
mechanism.

	Regards
		Oliver

---

--- linux-2.6.25-hso/drivers/net/usb/hso.c.alt2	2008-04-16 07:24:18.000000000 +0200
+++ linux-2.6.25-hso/drivers/net/usb/hso.c	2008-04-16 14:01:22.000000000 +0200
@@ -57,6 +58,7 @@
 #include <linux/tty_driver.h>
 #include <linux/tty_flip.h>
 #include <linux/kmod.h>
+#include <linux/rfkill.h>
 #include <linux/ip.h>
 #include <linux/proc_fs.h>
 #include <linux/uaccess.h>
@@ -102,7 +104,6 @@
 #define HSO_SERIAL_FLAG_THROTTLED	0
 #define HSO_SERIAL_FLAG_TX_SENT		1
 #define HSO_SERIAL_FLAG_RX_SENT		2
-#define HSO_SERIAL_USB_GONE		3
 
 #define HSO_SERIAL_MAGIC		0x48534f31
 
@@ -241,11 +242,13 @@ struct hso_device {
 
 	u8 is_active;
 	u8 suspend_disabled;
+	u8 usb_gone;
 	struct work_struct async_get_intf;
 	struct work_struct async_put_intf;
 
 	struct usb_device *usb;
 	struct usb_interface *interface;
+	struct rfkill *rfkill;
 
 	struct device *dev;
 	struct kref ref;                                                       */
@@ -1238,7 +1216,7 @@ static void hso_serial_close(struct tty_
 	}
 
 	mutex_lock(&serial->parent->mutex);
-	usb_gone = test_bit(HSO_SERIAL_USB_GONE, &serial->flags);
+	usb_gone = serial->parent->usb_gone;
 
 	if (!usb_gone)
 		usb_autopm_get_interface(serial->parent->interface);
@@ -1407,43 +1385,6 @@ static int hso_serial_tiocmset(struct tt
 			       USB_CTRL_SET_TIMEOUT);
 }
 
-/* Toggles radio on or off ( used by ioctl ) */
-static int hso_set_radio(struct hso_device *hso_dev, int enabled)
-{
-	if (!hso_dev)
-		return -ENODEV;
-
-	return usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
-			       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
-			       USB_CTRL_SET_TIMEOUT);
-}
-
-/* ioctl not supported */
-static int hso_serial_ioctl(struct tty_struct *tty, struct file *file,
-			    unsigned int cmd, unsigned long arg)
-{
-	struct hso_serial *serial = get_serial_by_tty(tty);
-	int ret = 0;
-	D4("IOCTL cmd: %d, arg: %ld", cmd, arg);
-
-	if (!serial)
-		return -ENODEV;
-
-	switch (cmd) {
-	case SIOCSETRADIO:
-		if (arg)
-			hso_set_radio(serial->parent, 1);
-		else
-			hso_set_radio(serial->parent, 0);
-		ret = 0;
-		break;
-	default:
-		ret = -ENOIOCTLCMD;
-		break;
-	}
-	return ret;
-}
-
 /* starts a transmit */
 static void hso_kick_transmit(struct hso_serial *serial)
 {
@@ -1871,7 +1812,6 @@ static struct tty_operations hso_serial_
 	.close = hso_serial_close,
 	.write = hso_serial_write,
 	.write_room = hso_serial_write_room,
-	.ioctl = hso_serial_ioctl,
 	.set_termios = hso_serial_set_termios,
 	.chars_in_buffer = hso_serial_chars_in_buffer,
 	.tiocmget = hso_serial_tiocmget,
@@ -2669,12 +2610,30 @@ static int hso_get_config_data(struct us
 	return result;
 }
 
+static int hso_radio_toggle(void *data, enum rfkill_state state)
+{
+	struct hso_device *hso_dev = data;
+	int enabled = (state == RFKILL_STATE_ON);
+	int rv;
+
+	mutex_lock(&hso_dev->mutex);
+	if (hso_dev->usb_gone)
+		rv = 0;
+	else
+		rv = usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
+				       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
+				       USB_CTRL_SET_TIMEOUT);
+	mutex_unlock(&hso_dev->mutex);
+	return rv;
+}
+
 /* called once for each interface upon device insertion */
 static int hso_probe(struct usb_interface *interface,
 		     const struct usb_device_id *id)
 {
 	int mux, i, if_num, port_spec;
 	unsigned char port_mask;
+	char *rfkn;
 	struct hso_device *hso_dev = NULL;
 	struct hso_shared_int *shared_int = NULL;
 	struct hso_device *tmp_dev = NULL;
@@ -2747,6 +2706,27 @@ static int hso_probe(struct usb_interfac
 		goto exit;
 	}
 
+	hso_dev->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
+				RFKILL_TYPE_WLAN);
+	if (!hso_dev->rfkill)
+		goto exit;
+	rfkn = kzalloc(20, GFP_KERNEL);
+	if (!rfkn) {
+		rfkill_free(hso_dev->rfkill);
+		goto exit;
+	}
+	snprintf(rfkn, 20, "hso-%d", if_num);
+	hso_dev->rfkill->name = rfkn;
+	hso_dev->rfkill->state = RFKILL_STATE_ON;
+	hso_dev->rfkill->data = hso_dev;
+	hso_dev->rfkill->toggle_radio = hso_radio_toggle;
+	if (rfkill_register(hso_dev->rfkill) < 0) {
+		kfree(rfkn);
+		hso_dev->rfkill->name = NULL;
+		rfkill_free(hso_dev->rfkill);
+		goto exit;
+	}
+
 	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
 
 	/* save our data pointer in this device */
@@ -2768,8 +2748,16 @@ exit:
 /* device removed, cleaning up */
 static void hso_disconnect(struct usb_interface *interface)
 {
+	struct hso_device *hso_dev = usb_get_intfdata(interface);
+
 	hso_free_interface(interface);
 
+	if (hso_dev) {
+		cancel_work_sync(&hso_dev->async_put_intf);
+		cancel_work_sync(&hso_dev->async_get_intf);
+		rfkill_unregister(hso_dev->rfkill);
+	}
+
 	/* remove reference of our private data */
 	usb_set_intfdata(interface, NULL);
 
@@ -2909,7 +2897,7 @@ static void hso_free_interface(struct us
 			if (hso_dev->tty)
 				tty_hangup(hso_dev->tty);
 			mutex_lock(&hso_dev->parent->mutex);
-			set_bit(HSO_SERIAL_USB_GONE, &hso_dev->flags);
+			hso_dev->parent->usb_gone = 1;
 			mutex_unlock(&hso_dev->parent->mutex);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
 		}
