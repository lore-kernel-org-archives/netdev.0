From: Hollis Blanchard <hollisb@us.ibm.com>
Subject: [PATCH 2 of 2] netconsole: add write-only tty driver
Date: Thu, 27 Nov 2008 15:11:02 -0600
Message-ID: <1a5d52ff499998079f4b.1227820262@localhost.localdomain>
References: <patchbomb.1227820260@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fall-curlleaf.atl.sa.earthlink.net ([207.69.195.105]:49254 "EHLO
	fall-curlleaf.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752938AbYK0VWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 16:22:25 -0500
In-Reply-To: <patchbomb.1227820260@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows userspace to output to netconsole via the /dev/console device,
which is very useful to see initscript output, for example. There is only one
netconsole TTY device, and TTY output goes to all receivers specified for
console output.

Input via /dev/console is still not implemented, however.

Signed-off-by: Hollis Blanchard <hollisb@us.ibm.com>

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -43,6 +43,7 @@
 #include <linux/netpoll.h>
 #include <linux/inet.h>
 #include <linux/configfs.h>
+#include <linux/tty.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -98,6 +99,8 @@ struct netconsole_target {
 	int			enabled;
 	struct netpoll		np;
 };
+
+static struct tty_driver *netconsole_tty_driver;
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 
@@ -728,15 +731,74 @@ static void netconsole_write_msg(const c
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
 
+static int netconsole_tty_open(struct tty_struct *tty, struct file *filp)
+{
+	return 0;
+}
+
+static void netconsole_tty_close(struct tty_struct *tty, struct file *filp)
+{
+}
+
+static int netconsole_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
+{
+	netconsole_write_msg(buf, count);
+	return count;
+}
+
+static int netconsole_tty_write_room(struct tty_struct *tty)
+{
+	return MAX_PRINT_CHUNK;
+}
+
+static const struct tty_operations netconsole_tty_ops = {
+	.open = netconsole_tty_open,
+	.close = netconsole_tty_close,
+	.write = netconsole_tty_write,
+	.write_room = netconsole_tty_write_room,
+};
+
+static int __init netconsole_tty_init(void)
+{
+	netconsole_tty_driver = alloc_tty_driver(1);
+	if (!netconsole_tty_driver)
+		return -ENOMEM;
+
+	netconsole_tty_driver->owner = THIS_MODULE;
+	netconsole_tty_driver->driver_name = "netcon";
+	netconsole_tty_driver->name = "netcon";
+	netconsole_tty_driver->minor_start = 0;
+	netconsole_tty_driver->type = TTY_DRIVER_TYPE_SYSTEM;
+	netconsole_tty_driver->init_termios = tty_std_termios;
+	netconsole_tty_driver->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL;
+	netconsole_tty_driver->init_termios.c_ispeed = 9600;
+	netconsole_tty_driver->init_termios.c_ospeed = 9600;
+	netconsole_tty_driver->flags = TTY_DRIVER_REAL_RAW;
+	tty_set_operations(netconsole_tty_driver, &netconsole_tty_ops);
+
+	if (tty_register_driver(netconsole_tty_driver))
+		printk(KERN_ERR "Couldn't register netconsole tty driver\n");
+
+	return 0;
+}
+device_initcall(netconsole_tty_init);
+
 static void netconsole_console_write(struct console *con, const char *msg, unsigned int len)
 {
 	netconsole_write_msg(msg, len);
+}
+
+static struct tty_driver *netconsole_console_device(struct console *console, int *index)
+{
+	*index = console->index;
+	return netconsole_tty_driver;
 }
 
 static struct console netconsole = {
 	.name	= "netcon",
 	.flags	= CON_ENABLED,
 	.write	= netconsole_console_write,
+	.device = netconsole_console_device,
 };
 
 static int __init init_netconsole(void)
