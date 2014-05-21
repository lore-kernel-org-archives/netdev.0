From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn/capi: fix (middleware) device nodes
Date: Wed, 21 May 2014 23:39:26 +0200 (CEST)
Message-ID: <64bcfeb7b92c7e34c7b2837f9a646fcef81d1324.1400449372.git.tilman@imap.cc>
References: <cover.1400449368.git.tilman@imap.cc>
Cc: Paul Bolle <pebolle@tiscali.nl>, isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>, Jiri Slaby <jslaby@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:43123 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787AbaEUVm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 17:42:28 -0400
In-Reply-To: <cover.1400449368.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

Since v2.4 the capi driver used the following device nodes if
"middleware" support was enabled:
    /dev/capi20
    /dev/capi/0
    /dev/capi/1
    [...]

/dev/capi20 is a character device node. /dev/capi/0 (and up) are tty
device nodes (with a different major).

This device node (naming) scheme is not documented anywhere, as far as I
know. It was originally provided by the capifs pseudo filesystem (before
udev became available). It is required for example by the pppd
capiplugin. It was supported until a few years ago. But a number of
developments broke it:
- v2.6.6 (May 2004) renamed /dev/capi20 to /dev/capi and removed the
  "/" from the name of capi's tty driver. The explanation of the patch
  that did this included two examples of udev rules "to restore the old
  namespace";
- either udev 154 (May 2010) or udev 179 (January 2012) stopped
  allowing to rename device nodes, and thus the ability to have
  /dev/capi20 appear instead of /dev/capi and /dev/capi/0 (and up)
  instead of /dev/capi0 (and up);
- v3.0 (July 2011) also removed capifs. That disabled another method to
  create the /dev/capi/0 (and up) device nodes.

So now users need to manually tweak their setup (eg, create /dev/capi/
and fill that with symlinks) to get things working. This is all rather
hacky and only discoverable by searching the web. Fix all this by
renaming /dev/capi back to /dev/capi20, and by adding a devnode()
callback to the "capi_nc" tty driver so the tty device nodes appear as
/dev/capi/0 (and up).

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/Kconfig | 2 +-
 drivers/isdn/capi/capi.c  | 8 +++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/Kconfig b/drivers/isdn/capi/Kconfig
index 1d7adff..7641b30 100644
--- a/drivers/isdn/capi/Kconfig
+++ b/drivers/isdn/capi/Kconfig
@@ -9,7 +9,7 @@ config CAPI_TRACE
 	  If unsure, say Y.
 
 config ISDN_CAPI_CAPI20
-	tristate "CAPI2.0 /dev/capi support"
+	tristate "CAPI2.0 /dev/capi20 support"
 	help
 	  This option will provide the CAPI 2.0 interface to userspace
 	  applications via /dev/capi20. Applications should use the
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index ac6f72b..e9afa74 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1250,6 +1250,11 @@ static const struct tty_operations capinc_ops = {
 	.cleanup = capinc_tty_cleanup,
 };
 
+static char *capi_devnode(struct device *dev, umode_t *mode)
+{
+	return kasprintf(GFP_KERNEL, "capi/%u", MINOR(dev->devt));
+}
+
 static int __init capinc_tty_init(void)
 {
 	struct tty_driver *drv;
@@ -1272,6 +1277,7 @@ static int __init capinc_tty_init(void)
 	}
 	drv->driver_name = "capi_nc";
 	drv->name = "capi";
+	drv->devnode = capi_devnode;
 	drv->major = 0;
 	drv->minor_start = 0;
 	drv->type = TTY_DRIVER_TYPE_SERIAL;
@@ -1417,7 +1423,7 @@ static int __init capi_init(void)
 		return PTR_ERR(capi_class);
 	}
 
-	device_create(capi_class, NULL, MKDEV(capi_major, 0), NULL, "capi");
+	device_create(capi_class, NULL, MKDEV(capi_major, 0), NULL, "capi20");
 
 	if (capinc_tty_init() < 0) {
 		device_destroy(capi_class, MKDEV(capi_major, 0));
-- 
1.9.2.459.g68773ac
