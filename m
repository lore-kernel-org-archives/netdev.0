From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Added workqueue
Date: Wed, 13 Sep 2006 02:42:12 +0100 (BST)
Message-ID: <20060913014212.8AC8B7B40A0@zog.reactivated.net>
Cc: kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:38297 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030480AbWIMBhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 21:37:24 -0400
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

For housekeeping and watchdog tasks a workqueue is created. The
central workqueue is not used to prevent crashes creates by bugs.
It might be changed, when the housekeeping is stabilized.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |   10 ++++++++++
 zd_usb.h |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -24,6 +24,7 @@
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/usb.h>
+#include <linux/workqueue.h>
 #include <net/ieee80211.h>
 
 #include "zd_def.h"
@@ -1112,12 +1113,20 @@ static struct usb_driver driver = {
 	.disconnect	= disconnect,
 };
 
+struct workqueue_struct *zd_workqueue;
+
 static int __init usb_init(void)
 {
 	int r;
 
 	pr_debug("usb_init()\n");
 
+	zd_workqueue = create_singlethread_workqueue(driver.name);
+	if (zd_workqueue == NULL) {
+		printk(KERN_ERR "%s: couldn't create workqueue\n", driver.name);
+		return -ENOMEM;
+	}
+
 	r = usb_register(&driver);
 	if (r) {
 		printk(KERN_ERR "usb_register() failed. Error number %d\n", r);
@@ -1132,6 +1141,7 @@ static void __exit usb_exit(void)
 {
 	pr_debug("usb_exit()\n");
 	usb_deregister(&driver);
+	destroy_workqueue(zd_workqueue);
 }
 
 module_init(usb_init);
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -238,4 +238,6 @@ int zd_usb_iowrite16v(struct zd_usb *usb
 
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
 
+extern struct workqueue_struct *zd_workqueue;
+
 #endif /* _ZD_USB_H */
