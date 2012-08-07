From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 34/41] TTY: i4l, add tty install
Date: Tue,  7 Aug 2012 21:47:59 +0200
Message-ID: <1344368886-24033-35-git-send-email-jslaby@suse.cz>
References: <1344368886-24033-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344368886-24033-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This has two outcomes:
* we give the TTY layer a tty_port
* we do not find the info structure every time open is called on that
  tty

The "tty->port = port" assignment is not needed anymore since it
happens in tty_port_install implicitly.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/i4l/isdn_tty.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 576ce4b..b817809 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1486,6 +1486,18 @@ isdn_tty_set_termios(struct tty_struct *tty, struct ktermios *old_termios)
  * ------------------------------------------------------------
  */
 
+static int isdn_tty_install(struct tty_driver *driver, struct tty_struct *tty)
+{
+	modem_info *info = &dev->mdm.info[tty->index];
+
+	if (isdn_tty_paranoia_check(info, tty->name, __func__))
+		return -ENODEV;
+
+	tty->driver_data = info;
+
+	return tty_port_install(&info->port, driver, tty);
+}
+
 /*
  * This routine is called whenever a serial port is opened.  It
  * enables interrupts for a serial port, linking in its async structure into
@@ -1495,22 +1507,16 @@ isdn_tty_set_termios(struct tty_struct *tty, struct ktermios *old_termios)
 static int
 isdn_tty_open(struct tty_struct *tty, struct file *filp)
 {
-	struct tty_port *port;
-	modem_info *info;
+	modem_info *info = tty->driver_data;
+	struct tty_port *port = &info->port;
 	int retval;
 
-	info = &dev->mdm.info[tty->index];
-	if (isdn_tty_paranoia_check(info, tty->name, "isdn_tty_open"))
-		return -ENODEV;
-	port = &info->port;
 #ifdef ISDN_DEBUG_MODEM_OPEN
 	printk(KERN_DEBUG "isdn_tty_open %s, count = %d\n", tty->name,
 	       port->count);
 #endif
 	port->count++;
-	tty->driver_data = info;
 	port->tty = tty;
-	tty->port = port;
 	/*
 	 * Start up serial port
 	 */
@@ -1738,6 +1744,7 @@ modem_write_profile(atemu *m)
 }
 
 static const struct tty_operations modem_ops = {
+	.install = isdn_tty_install,
 	.open = isdn_tty_open,
 	.close = isdn_tty_close,
 	.write = isdn_tty_write,
-- 
1.7.10.4
