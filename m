From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2.4][ATM] implement br2684_ioctl_hook for br2684
Date: Tue, 16 Sep 2003 08:04:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161204.h8GC4CSa012637@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1133  -> 1.1134 
#	    net/atm/common.h	1.4     -> 1.5    
#	    net/atm/common.c	1.20    -> 1.21   
#	    net/atm/br2684.c	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/14	chas@relax.cmf.nrl.navy.mil	1.1134
# [ATM]: implement br2684_ioctl_hook for br2684
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Sep 15 16:17:30 2003
+++ b/net/atm/br2684.c	Mon Sep 15 16:17:30 2003
@@ -16,9 +16,12 @@
 #include <linux/ip.h>
 #include <asm/uaccess.h>
 #include <net/arp.h>
+#include <linux/atm.h>
+#include <linux/atmdev.h>
 
 #include <linux/atmbr2684.h>
 
+#include "common.h"
 #include "ipcommon.h"
 
 /*
@@ -768,8 +771,6 @@
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
 
-extern int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
@@ -779,14 +780,14 @@
 	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
 		return -ENOMEM;
 	p->proc_fops = &br2684_proc_operations;
-	br2684_ioctl_hook = br2684_ioctl;
+	br2684_ioctl_set(br2684_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED br2684_exit(void)
 {
 	struct br2684_dev *brdev;
-	br2684_ioctl_hook = NULL;
+	br2684_ioctl_set(NULL);
 	remove_proc_entry("br2684", atm_proc_root);
 	while (!list_empty(&br2684_devs)) {
 		brdev = list_entry_brdev(br2684_devs.next);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Sep 15 16:17:30 2003
+++ b/net/atm/common.c	Mon Sep 15 16:17:30 2003
@@ -146,10 +146,19 @@
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-#endif
+static DECLARE_MUTEX(br2684_ioctl_mutex);
+
+static int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+ 
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&br2684_ioctl_mutex);
+	br2684_ioctl_hook = hook;
+	up(&br2684_ioctl_mutex);
+}
 #ifdef CONFIG_ATM_BR2684_MODULE
-EXPORT_SYMBOL(br2684_ioctl_hook);
+EXPORT_SYMBOL(br2684_ioctl_set);
+#endif
 #endif
 
 #include "resources.h"		/* atm_find_dev */
@@ -837,11 +846,12 @@
 		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-	if (br2684_ioctl_hook) {
+	down(&br2684_ioctl_mutex);
+	if (br2684_ioctl_hook)
 		error = br2684_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&br2684_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 
 	error = atm_dev_ioctl(cmd, arg);
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Sep 15 16:17:30 2003
+++ b/net/atm/common.h	Mon Sep 15 16:17:30 2003
@@ -29,6 +29,7 @@
 void atm_shutdown_dev(struct atm_dev *dev);
 
 void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
 
 int atmpvc_init(void);
 void atmpvc_exit(void);
