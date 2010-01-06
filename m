From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 05/31] CAPI: Reduce chattiness during module loading/removal
Date: Wed, 6 Jan 2010 11:47:28 +0100
Message-ID: <40a6a307e28e1a7df7e63cef5243df9cc690010c.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:37869 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412Ab0AVXTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:19:19 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CVS revisions dumped by all CAPI modules are meaningless today. And
that some CAPI module is loaded or removed does not necessarily deserve
a message. Just keep the message of the central module, capi.ko, drop
the rest.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c    |   19 +++----------------
 drivers/isdn/capi/capidrv.c |   26 --------------------------
 drivers/isdn/capi/capifs.c  |   20 +-------------------
 drivers/isdn/capi/kcapi.c   |   27 +++++----------------------
 4 files changed, 9 insertions(+), 83 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 58504ef..c456f61 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -44,8 +44,6 @@
 
 #include "capifs.h"
 
-static char *revision = "$Revision: 1.1.2.7 $";
-
 MODULE_DESCRIPTION("CAPI4Linux: Userspace /dev/capi20 interface");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
@@ -1518,21 +1516,11 @@ static void __exit proc_exit(void)
 /* -------- init function and module interface ---------------------- */
 
 
-static char rev[32];
-
 static int __init capi_init(void)
 {
-	char *p;
-	char *compileinfo;
+	const char *compileinfo;
 	int major_ret;
 
-	if ((p = strchr(revision, ':')) != NULL && p[1]) {
-		strlcpy(rev, p + 2, sizeof(rev));
-		if ((p = strchr(rev, '$')) != NULL && p > rev)
-		   *(p-1) = 0;
-	} else
-		strcpy(rev, "1.0");
-
 	major_ret = register_chrdev(capi_major, "capi20", &capi_fops);
 	if (major_ret < 0) {
 		printk(KERN_ERR "capi20: unable to get major %dn", capi_major);
@@ -1566,8 +1554,8 @@ static int __init capi_init(void)
 #else
         compileinfo = " (no middleware)";
 #endif
-	printk(KERN_NOTICE "capi20: Rev %s: started up with major %d%sn",
-				rev, capi_major, compileinfo);
+	printk(KERN_NOTICE "CAPI 2.0 started up with major %d%sn",
+	       capi_major, compileinfo);
 
 	return 0;
 }
@@ -1583,7 +1571,6 @@ static void __exit capi_exit(void)
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 	capinc_tty_exit();
 #endif
-	printk(KERN_NOTICE "capi: Rev %s: unloadedn", rev);
 }
 
 module_init(capi_init);
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 66b7d7a..52118a9 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -34,7 +34,6 @@
 #include <linux/isdn/capicmd.h>
 #include "capidrv.h"
 
-static char *revision = "$Revision: 1.1.2.2 $";
 static int debugmode = 0;
 
 MODULE_DESCRIPTION("CAPI4Linux: Interface to ISDN4Linux");
@@ -2287,19 +2286,9 @@ static void __exit proc_exit(void)
 static int __init capidrv_init(void)
 {
 	capi_profile profile;
-	char rev[32];
-	char *p;
 	u32 ncontr, contr;
 	u16 errcode;
 
-	if ((p = strchr(revision, ':')) != NULL && p[1]) {
-		strncpy(rev, p + 2, sizeof(rev));
-		rev[sizeof(rev)-1] = 0;
-		if ((p = strchr(rev, '$')) != NULL && p > rev)
-		   *(p-1) = 0;
-	} else
-		strcpy(rev, "1.0");
-
 	global.ap.rparam.level3cnt = -2;  /* number of bchannels twice */
 	global.ap.rparam.datablkcnt = 16;
 	global.ap.rparam.datablklen = 2048;
@@ -2327,29 +2316,14 @@ static int __init capidrv_init(void)
 	}
 	proc_init();
 
-	printk(KERN_NOTICE "capidrv: Rev %s: loadedn", rev);
 	return 0;
 }
 
 static void __exit capidrv_exit(void)
 {
-	char rev[32];
-	char *p;
-
-	if ((p = strchr(revision, ':')) != NULL) {
-		strncpy(rev, p + 1, sizeof(rev));
-		rev[sizeof(rev)-1] = 0;
-		if ((p = strchr(rev, '$')) != NULL)
-			*p = 0;
-	} else {
-		strcpy(rev, " ??? ");
-	}
-
 	capi20_release(&global.ap);
 
 	proc_exit();
-
-	printk(KERN_NOTICE "capidrv: Rev%s: unloadedn", rev);
 }
 
 module_init(capidrv_init);
diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 51c01ef..8596bd1 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -25,10 +25,6 @@ MODULE_LICENSE("GPL");
 
 /* ------------------------------------------------------------------ */
 
-static char *revision = "$Revision: 1.1.2.3 $";
-
-/* ------------------------------------------------------------------ */
-
 #define CAPIFS_SUPER_MAGIC (('C'<<8)|'N')
 
 static struct vfsmount *capifs_mnt;
@@ -227,21 +223,7 @@ void capifs_free_ncci(struct dentry *dentry)
 
 static int __init capifs_init(void)
 {
-	char rev[32];
-	char *p;
-	int err;
-
-	if ((p = strchr(revision, ':')) != NULL && p[1]) {
-		strlcpy(rev, p + 2, sizeof(rev));
-		if ((p = strchr(rev, '$')) != NULL && p > rev)
-		   *(p-1) = 0;
-	} else
-		strcpy(rev, "1.0");
-
-	err = register_filesystem(&capifs_fs_type);
-	if (!err)
-		printk(KERN_NOTICE "capifs: Rev %sn", rev);
-	return err;
+	return register_filesystem(&capifs_fs_type);
 }
 
 static void __exit capifs_exit(void)
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index dc506ab..4a75234 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -35,10 +35,6 @@
 #endif
 #include <linux/mutex.h>
 
-static char *revision = "$Revision: 1.1.2.8 $";
-
-/* ------------------------------------------------------------- */
-
 static int showcapimsgs = 0;
 
 MODULE_DESCRIPTION("CAPI4Linux: kernel CAPI layer");
@@ -1171,25 +1167,12 @@ EXPORT_SYMBOL(capi20_set_callback);
 
 static int __init kcapi_init(void)
 {
-	char *p;
-	char rev[32];
-	int ret;
-
-	ret = cdebug_init();
-	if (ret)
-		return ret;
-        kcapi_proc_init();
+	int err;
 
-	if ((p = strchr(revision, ':')) != NULL && p[1]) {
-		strlcpy(rev, p + 2, sizeof(rev));
-		if ((p = strchr(rev, '$')) != NULL && p > rev)
-		   *(p-1) = 0;
-	} else
-		strcpy(rev, "1.0");
-
-        printk(KERN_NOTICE "CAPI Subsystem Rev %sn", rev);
-
-	return 0;
+	err = cdebug_init();
+	if (!err)
+		kcapi_proc_init();
+	return err;
 }
 
 static void __exit kcapi_exit(void)
-- 
1.6.0.2

