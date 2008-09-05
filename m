From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [Fwd: [PATCH] hso.c mutex fixups]
Date: Fri, 05 Sep 2008 10:28:05 +0200
Message-ID: <48C0ED95.6010205@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:48383 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbYIEI2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 04:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff & others,
This patch is against the virgin linux-2.6.27-rc4 hso.c driver
but should apply against 2.6.27-rc5 as well.
I believe it is very well designed but owing to its complexity
it might have bugs.

Enjoy the patch.

A new structure hso_mutex_table had to be declared statically
& used as as hso_device mutex_lock(&serial->parent->mutex) etc
is freed in hso_serial_open & hso_serial_close by kref_put while
the mutex is still in use.
This is a substantial change but should make the driver much stabler.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.27-rc4.patch/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc4.patch.orig/drivers/net/usb/hso.c	2008-08-21 16:22:23.000000000 +0200
+++ linux-2.6.27-rc4.patch/drivers/net/usb/hso.c	2008-08-21 17:16:12.000000000 +0200
@@ -218,6 +218,11 @@
 	int (*write_data) (struct hso_serial *serial);
 };
 
+struct hso_mutex_t {
+	struct mutex mutex;
+	u8 allocated;
+};
+
 struct hso_device {
 	union {
 		struct hso_serial *dev_serial;
@@ -236,7 +241,7 @@
 
 	struct device *dev;
 	struct kref ref;
-	struct mutex mutex;
+	struct hso_mutex_t *mutex;
 };
 
 /* Type of interface */
@@ -350,6 +355,13 @@
 static spinlock_t serial_table_lock;
 static struct ktermios *hso_serial_termios[HSO_SERIAL_TTY_MINORS];
 static struct ktermios *hso_serial_termios_locked[HSO_SERIAL_TTY_MINORS];
+/* hso_mutex_table has to be declared statically as hso_device
+ * is freed in hso_serial_open & hso_serial_close while
+ * the mutex is still in use.
+ */
+#define HSO_NUM_MUTEXES (HSO_SERIAL_TTY_MINORS+HSO_MAX_NET_DEVICES)
+static struct hso_mutex_t hso_mutex_table[HSO_NUM_MUTEXES];
+static spinlock_t hso_mutex_lock;
 
 static const s32 default_port_spec[] = {
 	HSO_INTF_MUX | HSO_PORT_NETWORK,
@@ -574,6 +586,34 @@
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 }
 
+
+static struct hso_mutex_t *hso_get_free_mutex(void)
+{
+	int index;
+	struct hso_mutex_t *curr_hso_mutex;
+
+	spin_lock(&hso_mutex_lock);
+	for (index = 0; index < HSO_NUM_MUTEXES; index++) {
+		curr_hso_mutex = &hso_mutex_table[index];
+			if (!curr_hso_mutex->allocated) {
+				curr_hso_mutex->allocated = 1;
+				spin_unlock(&hso_mutex_lock);
+				return curr_hso_mutex;
+			}
+	}
+	printk(KERN_ERR "BUG %s: no free hso_mutexs devices in table\n"
+	       , __func__);
+	spin_unlock(&hso_mutex_lock);
+	return NULL;
+}
+
+static void hso_free_mutex(struct hso_mutex_t *mutex)
+{
+	spin_lock(&hso_mutex_lock);
+	mutex->allocated = 0;
+	spin_unlock(&hso_mutex_lock);
+}
+
 /* log a meaningful explanation of an USB status */
 static void log_usb_status(int status, const char *function)
 {
@@ -1043,7 +1083,9 @@
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
 	struct hso_serial *serial = get_serial_by_index(tty->index);
-	int result;
+	int result1 = 0, result2 = 0;
+	struct mutex *hso_mutex = NULL;
+	int   refcnt = 1;
 
 	/* sanity check */
 	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
@@ -1052,9 +1094,10 @@
 		return -ENODEV;
 	}
 
-	mutex_lock(&serial->parent->mutex);
-	result = usb_autopm_get_interface(serial->parent->interface);
-	if (result < 0)
+	hso_mutex = &serial->parent->mutex->mutex;
+	mutex_lock(hso_mutex);
+	result1 = usb_autopm_get_interface(serial->parent->interface);
+	if (result1 < 0)
 		goto err_out;
 
 	D1("Opening %d", serial->minor);
@@ -1071,11 +1114,10 @@
 		serial->flags = 0;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
-		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
-		if (result) {
+		result2 = hso_start_serial_device(serial->parent, GFP_KERNEL);
+		if (result2) {
 			hso_stop_serial_device(serial->parent);
 			serial->open_count--;
-			kref_put(&serial->parent->ref, hso_serial_ref_free);
 		}
 	} else {
 		D1("Port was already open");
@@ -1084,11 +1126,16 @@
 	usb_autopm_put_interface(serial->parent->interface);
 
 	/* done */
-	if (result)
+	if (result1)
 		hso_serial_tiocmset(tty, NULL, TIOCM_RTS | TIOCM_DTR, 0);
 err_out:
-	mutex_unlock(&serial->parent->mutex);
-	return result;
+	if (result2)
+		refcnt = kref_put(&serial->parent->ref, hso_serial_ref_free);
+	mutex_unlock(hso_mutex);
+	if (refcnt == 0)
+		hso_free_mutex(container_of(hso_mutex,
+					    struct hso_mutex_t, mutex));
+	return result1 == 0 ? result2 : result1;
 }
 
 /* close the requested serial port */
@@ -1096,19 +1143,20 @@
 {
 	struct hso_serial *serial = tty->driver_data;
 	u8 usb_gone;
+	struct mutex *hso_mutex;
+	int refcnt;
 
 	D1("Closing serial port");
 
-	mutex_lock(&serial->parent->mutex);
 	usb_gone = serial->parent->usb_gone;
-
+	hso_mutex = &serial->parent->mutex->mutex;
+	mutex_lock(hso_mutex);
 	if (!usb_gone)
 		usb_autopm_get_interface(serial->parent->interface);
 
 	/* reset the rts and dtr */
 	/* do the actual close */
 	serial->open_count--;
-	kref_put(&serial->parent->ref, hso_serial_ref_free);
 	if (serial->open_count <= 0) {
 		serial->open_count = 0;
 		if (serial->tty) {
@@ -1120,7 +1168,11 @@
 	}
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);
-	mutex_unlock(&serial->parent->mutex);
+	refcnt = kref_put(&serial->parent->ref, hso_serial_ref_free);
+	mutex_unlock(hso_mutex);
+	if (refcnt == 0)
+		hso_free_mutex(container_of(hso_mutex,
+					    struct hso_mutex_t, mutex));
 }
 
 /* close the requested serial port */
@@ -1931,8 +1983,12 @@
 	hso_dev->usb = interface_to_usbdev(intf);
 	hso_dev->interface = intf;
 	kref_init(&hso_dev->ref);
-	mutex_init(&hso_dev->mutex);
-
+	hso_dev->mutex = hso_get_free_mutex();
+	if (!hso_dev->mutex) {
+		kfree(hso_dev);
+		return NULL;
+	}
+	mutex_init(&hso_dev->mutex->mutex);
 	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
 	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
 
@@ -1978,7 +2034,7 @@
 		unregister_netdev(hso_net->net);
 		free_netdev(hso_net->net);
 	}
-
+	hso_free_mutex(hso_dev->mutex);
 	hso_free_device(hso_dev);
 }
 
@@ -2027,14 +2083,14 @@
 	int enabled = (state == RFKILL_STATE_ON);
 	int rv;
 
-	mutex_lock(&hso_dev->mutex);
+	mutex_lock(&hso_dev->mutex->mutex);
 	if (hso_dev->usb_gone)
 		rv = 0;
 	else
 		rv = usb_control_msg(hso_dev->usb, usb_rcvctrlpipe(hso_dev->usb, 0),
 				       enabled ? 0x82 : 0x81, 0x40, 0, 0, NULL, 0,
 				       USB_CTRL_SET_TIMEOUT);
-	mutex_unlock(&hso_dev->mutex);
+	mutex_unlock(&hso_dev->mutex->mutex);
 	return rv;
 }
 
@@ -2635,6 +2691,8 @@
 {
 	struct hso_serial *hso_dev;
 	int i;
+	struct mutex *hso_mutex = NULL;
+	int    refcnt = 1;
 
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i]
@@ -2642,10 +2700,12 @@
 			hso_dev = dev2ser(serial_table[i]);
 			if (hso_dev->tty)
 				tty_hangup(hso_dev->tty);
-			mutex_lock(&hso_dev->parent->mutex);
+			hso_mutex = &hso_dev->parent->mutex->mutex;
+			mutex_lock(hso_mutex);
 			hso_dev->parent->usb_gone = 1;
-			mutex_unlock(&hso_dev->parent->mutex);
-			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
+			refcnt = kref_put(&serial_table[i]->ref,
+					hso_serial_ref_free);
+			mutex_unlock(hso_mutex);
 		}
 	}
 
@@ -2664,6 +2724,9 @@
 			hso_free_net_device(network_table[i]);
 		}
 	}
+	if (refcnt == 0)
+		hso_free_mutex(container_of(hso_mutex,
+					    struct hso_mutex_t, mutex));
 }
 
 /* Helper functions */
@@ -2761,6 +2824,7 @@
 
 	/* Initialise the serial table semaphore and table */
 	spin_lock_init(&serial_table_lock);
+	spin_lock_init(&hso_mutex_lock);
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++)
 		serial_table[i] = NULL;
 


-- 
best regards,
D.J. Barrow
