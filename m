From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] cleanup pppoatm and br2684 modules
Date: Mon, 14 Jul 2003 17:06:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307142108.h6EL8fsG021288@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this should be applied to the latest 2.5 sources...

[atm]: cleanup pppoatm_ioctl_hook

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1362  -> 1.1363 
#	   net/atm/pppoatm.c	1.7     -> 1.8    
#	    net/atm/common.h	1.13    -> 1.14   
#	    net/atm/common.c	1.38    -> 1.39   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/21	chas@relax.cmf.nrl.navy.mil	1.1363
# pppoatm.c, common.h, common.c:
#   cleanup pppoatm_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 09:45:58 2003
+++ b/net/atm/common.c	Mon Jun 23 09:45:58 2003
@@ -129,8 +129,19 @@
 #endif
 
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-EXPORT_SYMBOL(pppoatm_ioctl_hook);
+static DECLARE_MUTEX(pppoatm_ioctl_mutex);
+
+static int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&pppoatm_ioctl_mutex);
+	pppoatm_ioctl_hook = hook;
+	up(&pppoatm_ioctl_mutex);
+}
+#ifdef CONFIG_PPPOATM_MODULE
+EXPORT_SYMBOL(pppoatm_ioctl_set);
+#endif
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
@@ -865,12 +876,14 @@
 		default:
 			break;
 	}
+	error = -ENOIOCTLCMD;
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-	if (pppoatm_ioctl_hook) {
+	down(&pppoatm_ioctl_mutex);
+	if (pppoatm_ioctl_hook)
 		error = pppoatm_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&pppoatm_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
 	if (br2684_ioctl_hook) {
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 23 09:45:58 2003
+++ b/net/atm/common.h	Mon Jun 23 09:45:58 2003
@@ -26,6 +26,8 @@
 
 void atm_shutdown_dev(struct atm_dev *dev);
 
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+
 int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Mon Jun 23 09:45:58 2003
+++ b/net/atm/pppoatm.c	Mon Jun 23 09:45:58 2003
@@ -44,6 +44,8 @@
 #include <linux/ppp_channel.h>
 #include <linux/atmppp.h>
 
+#include "common.h"
+
 #if 0
 #define DPRINTK(format, args...) \
 	printk(KERN_DEBUG "pppoatm: " format, ##args)
@@ -344,17 +346,15 @@
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
-extern int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 static int __init UNUSED pppoatm_init(void)
 {
-	pppoatm_ioctl_hook = pppoatm_ioctl;
+	pppoatm_ioctl_set(pppoatm_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED pppoatm_exit(void)
 {
-	pppoatm_ioctl_hook = NULL;
+	pppoatm_ioctl_set(NULL);
 }
 
 module_init(pppoatm_init);



[atm]: cleanup br2684_ioctl_hook

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1363  -> 1.1364 
#	    net/atm/br2684.c	1.3     -> 1.4    
#	    net/atm/common.h	1.14    -> 1.15   
#	    net/atm/common.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/21	chas@relax.cmf.nrl.navy.mil	1.1364
# common.h, common.c, br2684.c:
#   cleanup br2684_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Jun 23 09:45:37 2003
+++ b/net/atm/br2684.c	Mon Jun 23 09:45:37 2003
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
--- a/net/atm/common.c	Mon Jun 23 09:45:37 2003
+++ b/net/atm/common.c	Mon Jun 23 09:45:37 2003
@@ -145,9 +145,18 @@
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
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
 #endif
 #endif
 
@@ -886,11 +895,12 @@
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
--- a/net/atm/common.h	Mon Jun 23 09:45:37 2003
+++ b/net/atm/common.h	Mon Jun 23 09:45:37 2003
@@ -27,6 +27,7 @@
 void atm_shutdown_dev(struct atm_dev *dev);
 
 void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
 
 int atmpvc_init(void);
 void atmpvc_exit(void);
