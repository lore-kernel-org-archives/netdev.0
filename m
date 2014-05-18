From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] tty: allow tty drivers to rename their device nodes
Date: Sun, 18 May 2014 23:26:08 +0200
Message-ID: <243519fa733359d22ce008b795f5686411e6038a.1400448372.git.tilman@imap.cc>
References: <cover.1400448368.git.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>, Jiri Slaby <jslaby@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:43908 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbaERWnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2014 18:43:23 -0400
In-Reply-To: <cover.1400448368.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

The device nodes for tty drivers are named using a straightforward
scheme: tty_driver->name with an (increasing) digit appended. But the
capi driver (a part of one of the current ISDN subsystems) requires a
different naming scheme for its "capi_nc" tty_driver:
    /dev/capi/0
    /dev/capi/1
    [...]

So add a devnode() callback to struct tty_driver to allow tty drivers
to use a more elaborate naming scheme. And let tty_devnode(), the
devnode() callback for the "tty" class, call that new callback if a tty
driver uses one. This allows the capi driver to add a callback to
enable its scheme.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/tty/tty_io.c       | 16 ++++++++++++++--
 include/linux/tty_driver.h |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
index 3411071..32d7878 100644
--- a/drivers/tty/tty_io.c
+++ b/drivers/tty/tty_io.c
@@ -3504,12 +3504,24 @@ void __init console_init(void)
 
 static char *tty_devnode(struct device *dev, umode_t *mode)
 {
+	struct tty_driver *driver = NULL;
+	int unused;
+	char *ret = NULL;
+
+	mutex_lock(&tty_mutex);
+	driver = get_tty_driver(dev->devt, &unused);
+	mutex_unlock(&tty_mutex);
+	if (driver && driver->devnode)
+		ret = driver->devnode(dev, mode);
+	if (driver)
+		tty_driver_kref_put(driver);
+
 	if (!mode)
-		return NULL;
+		return ret;
 	if (dev->devt == MKDEV(TTYAUX_MAJOR, 0) ||
 	    dev->devt == MKDEV(TTYAUX_MAJOR, 2))
 		*mode = 0666;
-	return NULL;
+	return ret;
 }
 
 static int __init tty_class_init(void)
diff --git a/include/linux/tty_driver.h b/include/linux/tty_driver.h
index 756a609..91265bf 100644
--- a/include/linux/tty_driver.h
+++ b/include/linux/tty_driver.h
@@ -294,6 +294,7 @@ struct tty_driver {
 	struct module	*owner;
 	const char	*driver_name;
 	const char	*name;
+	char *(*devnode)(struct device *dev, umode_t *mode);
 	int	name_base;	/* offset of printed name */
 	int	major;		/* major device number */
 	int	minor_start;	/* start of minor device number */
-- 
1.9.2.459.g68773ac
