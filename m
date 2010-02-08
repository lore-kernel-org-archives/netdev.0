From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 05/41] CAPI: Reduce chattiness during module loading/removal
Date: Mon,  8 Feb 2010 21:12:09 +0100
Message-ID: <261287d4d2c8baf12debe95f0f8d6069fa11d70f.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index dc5ac52..3b07797 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -45,8 +45,6 @@
 
 #include "capifs.h"
 
-static char *revision = "$Revision: 1.1.2.7 $";
-
 MODULE_DESCRIPTION("CAPI4Linux: Userspace /dev/capi20 interface");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
@@ -1489,21 +1487,11 @@ static void __exit proc_exit(void)
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
 		printk(KERN_ERR "capi20: unable to get major %d\n", capi_major);
@@ -1537,8 +1525,8 @@ static int __init capi_init(void)
 #else
         compileinfo = " (no middleware)";
 #endif
-	printk(KERN_NOTICE "capi20: Rev %s: started up with major %d%s\n",
-				rev, capi_major, compileinfo);
+	printk(KERN_NOTICE "CAPI 2.0 started up with major %d%s\n",
+	       capi_major, compileinfo);
 
 	return 0;
 }
@@ -1554,7 +1542,6 @@ static void __exit capi_exit(void)
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 	capinc_tty_exit();
 #endif
-	printk(KERN_NOTICE "capi: Rev %s: unloaded\n", rev);
 }
 
 module_init(capi_init);
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index bb45015..7d8899a 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -35,7 +35,6 @@
 #include <linux/isdn/capicmd.h>
 #include "capidrv.h"
 
-static char *revision = "$Revision: 1.1.2.2 $";
 static int debugmode = 0;
 
 MODULE_DESCRIPTION("CAPI4Linux: Interface to ISDN4Linux");
@@ -2266,19 +2265,9 @@ static void __exit proc_exit(void)
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
@@ -2306,29 +2295,14 @@ static int __init capidrv_init(void)
 	}
 	proc_init();
 
-	printk(KERN_NOTICE "capidrv: Rev %s: loaded\n", rev);
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
-	printk(KERN_NOTICE "capidrv: Rev%s: unloaded\n", rev);
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
-		printk(KERN_NOTICE "capifs: Rev %s\n", rev);
-	return err;
+	return register_filesystem(&capifs_fs_type);
 }
 
 static void __exit capifs_exit(void)
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index b0bacf3..ef564ee 100644
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
@@ -1165,25 +1161,12 @@ EXPORT_SYMBOL(capi20_set_callback);
 
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
-        printk(KERN_NOTICE "CAPI Subsystem Rev %s\n", rev);
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
