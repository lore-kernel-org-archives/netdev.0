From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 01/02] hso patch to fix a -EIO from opening a hso serial device
Date: Wed, 14 Jan 2009 12:22:31 +0100
Message-ID: <496DCAF7.9080906@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050708050702090508040508"
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Serial <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050708050702090508040508
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi All,
This is an important patch the linux-2.6.29-rc1 driver with itworks much
better than it did.

I'm about 80% sure this patch is correct
but it needs Alan Cox'es blessing as it modifies code he added.

This patch fixes -EIO caused when serial port opened more than once.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-14 11:51:26.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-14 11:57:59.000000000 +0100
@@ -1354,13 +1354,14 @@
 	/* do the actual close */
 	serial->open_count--;
 	kref_put(&serial->parent->ref, hso_serial_ref_free);
+	if (serial->tty == tty)
+		tty_kref_put(tty);
 	if (serial->open_count <= 0) {
 		serial->open_count = 0;
 		spin_lock_irq(&serial->serial_lock);
 		if (serial->tty == tty) {
 			serial->tty->driver_data = NULL;
 			serial->tty = NULL;
-			tty_kref_put(tty);
 		}
 		spin_unlock_irq(&serial->serial_lock);
 		if (!usb_gone)
@@ -1368,7 +1369,6 @@
 		tasklet_kill(&serial->unthrottle_tasklet);
 		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
-
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);
 

-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

--------------050708050702090508040508
Content-Type: text/x-diff;
 name="hso_open_eio_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_open_eio_fix.patch"

This patch fixes -EIO caused when serial port opened more than once.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-14 11:51:26.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-14 11:57:59.000000000 +0100
@@ -1354,13 +1354,14 @@
 	/* do the actual close */
 	serial->open_count--;
 	kref_put(&serial->parent->ref, hso_serial_ref_free);
+	if (serial->tty == tty)
+		tty_kref_put(tty);
 	if (serial->open_count <= 0) {
 		serial->open_count = 0;
 		spin_lock_irq(&serial->serial_lock);
 		if (serial->tty == tty) {
 			serial->tty->driver_data = NULL;
 			serial->tty = NULL;
-			tty_kref_put(tty);
 		}
 		spin_unlock_irq(&serial->serial_lock);
 		if (!usb_gone)
@@ -1368,7 +1369,6 @@
 		tasklet_kill(&serial->unthrottle_tasklet);
 		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
--------------050708050702090508040508--
