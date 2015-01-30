From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 02/11] hso: fix crash when device disappears while serial port is open
Date: Fri, 30 Jan 2015 13:21:54 +0100
Message-ID: <1422620523-15021-3-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-2-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the device disappear, the function hso_disconnect() is called to
perform cleanup. In the cleanup function, hso_free_interface() calls
tty_port_tty_hangup() in view of scheduling a work to hang up the tty if
needed. If the port was not open then hso_serial_ref_free() is called
directly to cleanup everything. Otherwise, hso_serial_ref_free() is called
when the last fd associated to the port is closed.

For each open port, tty_release() will call the close method,
hso_serial_close(), which drops the last kref and call
hso_serial_ref_free() which unregisters, destroys the tty port
and finally frees the structure in which the tty_port structure
is included. Later, in tty_release(), more precisely when release_tty()
is called, the tty_port previously freed is accessed to cancel
the tty buf workqueue and it leads to a crash.

In view of avoiding this crash, we add a cleanup method that is called
at the end of the hangup process and we drop the last kref in this
function when all the ports have been closed, when tty_port is no
more needed and when it is safe to free the structure containing the
tty_port structure.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index cb0bcc1..3a6c630 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1270,7 +1270,6 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 		goto err_out;
 
 	D1("Opening %d", serial->minor);
-	kref_get(&serial->parent->ref);
 
 	/* setup */
 	tty->driver_data = serial;
@@ -1289,7 +1288,8 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 		if (result) {
 			hso_stop_serial_device(serial->parent);
 			serial->port.count--;
-			kref_put(&serial->parent->ref, hso_serial_ref_free);
+		} else {
+			kref_get(&serial->parent->ref);
 		}
 	} else {
 		D1("Port was already open");
@@ -1339,8 +1339,6 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 		usb_autopm_put_interface(serial->parent->interface);
 
 	mutex_unlock(&serial->parent->mutex);
-
-	kref_put(&serial->parent->ref, hso_serial_ref_free);
 }
 
 /* close the requested serial port */
@@ -1391,6 +1389,16 @@ static int hso_serial_write_room(struct tty_struct *tty)
 	return room;
 }
 
+static void hso_serial_cleanup(struct tty_struct *tty)
+{
+	struct hso_serial *serial = tty->driver_data;
+
+	if (!serial)
+		return;
+
+	kref_put(&serial->parent->ref, hso_serial_ref_free);
+}
+
 /* setup the term */
 static void hso_serial_set_termios(struct tty_struct *tty, struct ktermios *old)
 {
@@ -3215,6 +3223,7 @@ static const struct tty_operations hso_serial_ops = {
 	.close = hso_serial_close,
 	.write = hso_serial_write,
 	.write_room = hso_serial_write_room,
+	.cleanup = hso_serial_cleanup,
 	.ioctl = hso_serial_ioctl,
 	.set_termios = hso_serial_set_termios,
 	.chars_in_buffer = hso_serial_chars_in_buffer,
-- 
2.2.0
