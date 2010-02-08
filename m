From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 22/41] CAPI: Use dynamic major for NCCI TTYs by default
Date: Mon,  8 Feb 2010 21:12:26 +0100
Message-ID: <cbb968392af0a8f39193c812fc8afba63d79e6f2.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43270 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab0BHUNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:09 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to allocate a fixed major for this TTY, both capifs and udev
make this transparent to the user.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 901b79b..b1de0cb 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -60,10 +60,8 @@ module_param_named(major, capi_major, uint, 0);
 #define CAPINC_NR_PORTS		32
 #define CAPINC_MAX_PORTS	256
 
-static int capi_ttymajor = 191;
 static int capi_ttyminors = CAPINC_NR_PORTS;
 
-module_param_named(ttymajor, capi_ttymajor, uint, 0);
 module_param_named(ttyminors, capi_ttyminors, uint, 0);
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
@@ -301,6 +299,7 @@ static struct capiminor *capiminor_get(unsigned int minor)
 static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 {
 	struct capiminor *mp;
+	dev_t device;
 
 	if (!(cdev->userflags & CAPIFLAG_HIGHJACKING))
 		return;
@@ -311,9 +310,8 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 #ifdef _DEBUG_REFCOUNT
 		printk(KERN_DEBUG "set mp->nccip\n");
 #endif
-		mp->capifs_dentry =
-			capifs_new_ncci(mp->minor,
-					MKDEV(capi_ttymajor, mp->minor));
+		device = MKDEV(capinc_tty_driver->major, mp->minor);
+		mp->capifs_dentry = capifs_new_ncci(mp->minor, device);
 	}
 }
 
@@ -1341,7 +1339,7 @@ static int __init capinc_tty_init(void)
 	drv->owner = THIS_MODULE;
 	drv->driver_name = "capi_nc";
 	drv->name = "capi";
-	drv->major = capi_ttymajor;
+	drv->major = 0;
 	drv->minor_start = 0;
 	drv->type = TTY_DRIVER_TYPE_SERIAL;
 	drv->subtype = SERIAL_TYPE_NORMAL;
-- 
1.6.0.2

