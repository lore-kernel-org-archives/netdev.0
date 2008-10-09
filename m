From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH] hso_serial_open hso_serial_close fixups
Date: Thu, 09 Oct 2008 13:22:59 +0200
Message-ID: <48EDE993.10705@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030304010801000509080407"
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:2270 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758399AbYJILXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:23:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030304010801000509080407
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all,
After my discussion with Alan Cox this should make hot disconnection of
the hso device more stable.

Disconnection still sometimes crashes the kernel when a modem port is connected
over ppp because the large patch for the hso mutex stuff hasn't yet been accepted.
i.e. unplugging a modem while using a ppp connection is in use is much more stable for our
internally maintained driver.



Moved serial_open_count in hso_serial_open to
prevent crashes owing to the serial structure being made NULL
when hso_serial_close is called even though hso_serial_open
returned -ENODEV, Alan Cox pointed out this happens,
also put in sanity check in hso_serial_close
to check for a valid serial structure which should prevent
the most reproducable crash in the driver when the hso device
is disconnected while in use.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.27-rc9/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc9.orig/drivers/net/usb/hso.c	2008-10-09 12:40:41.000000000 +0200
+++ linux-2.6.27-rc9/drivers/net/usb/hso.c	2008-10-09 12:46:50.000000000 +0200
@@ -1053,6 +1053,11 @@
 	}
 
 	mutex_lock(&serial->parent->mutex);
+	/* check for port already opened, if not set the termios */
+	/* The serial->open count needs to be here as hso_serial_close
+	 *  will be called even if hso_serial_open returns -ENODEV.
+	 */
+	serial->open_count++;
 	result = usb_autopm_get_interface(serial->parent->interface);
 	if (result < 0)
 		goto err_out;
@@ -1064,8 +1069,6 @@
 	tty->driver_data = serial;
 	serial->tty = tty;
 
-	/* check for port allready opened, if not set the termios */
-	serial->open_count++;
 	if (serial->open_count == 1) {
 		tty->low_latency = 1;
 		serial->flags = 0;
@@ -1098,6 +1101,10 @@
 	u8 usb_gone;
 
 	D1("Closing serial port");
+	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
+		D1("invalid serial structure bailing out. ");
+		return;
+	}
 
 	mutex_lock(&serial->parent->mutex);
 	usb_gone = serial->parent->usb_gone;

-- 
best regards,
D.J. Barrow

--------------030304010801000509080407
Content-Type: text/x-diff;
 name="hso_close_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_close_fix.patch"

Moved serial_open_count in hso_serial_open to
prevent crashes owing to the serial structure being made NULL
when hso_serial_close is called even though hso_serial_open
returned -ENODEV, Alan Cox pointed out this happens,
also put in sanity check in hso_serial_close
to check for a valid serial structure which should prevent
the most reproducable crash in the driver when the hso device
is disconnected while in use.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.27-rc9/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc9.orig/drivers/net/usb/hso.c	2008-10-09 12:40:41.000000000 +0200
+++ linux-2.6.27-rc9/drivers/net/usb/hso.c	2008-10-09 12:46:50.000000000 +0200
@@ -1053,6 +1053,11 @@
 	}
 
 	mutex_lock(&serial->parent->mutex);
+	/* check for port already opened, if not set the termios */
+	/* The serial->open count needs to be here as hso_serial_close
+	 *  will be called even if hso_serial_open returns -ENODEV.
+	 */
+	serial->open_count++;
 	result = usb_autopm_get_interface(serial->parent->interface);
 	if (result < 0)
 		goto err_out;
@@ -1064,8 +1069,6 @@
 	tty->driver_data = serial;
 	serial->tty = tty;
 
-	/* check for port allready opened, if not set the termios */
-	serial->open_count++;
 	if (serial->open_count == 1) {
 		tty->low_latency = 1;
 		serial->flags = 0;
@@ -1098,6 +1101,10 @@
 	u8 usb_gone;
 
 	D1("Closing serial port");
+	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
+		D1("invalid serial structure bailing out. ");
+		return;
+	}
 
 	mutex_lock(&serial->parent->mutex);
 	usb_gone = serial->parent->usb_gone;

--------------030304010801000509080407--
