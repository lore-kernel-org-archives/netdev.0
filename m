From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2.4][ATM] implement pppoatm_ioctl_hook for pppoatm
Date: Tue, 16 Sep 2003 08:03:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161203.h8GC32Sa012616@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1132  -> 1.1133 
#	   net/atm/pppoatm.c	1.5     -> 1.6    
#	    net/atm/common.h	1.3     -> 1.4    
#	    net/atm/common.c	1.19    -> 1.20   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/14	chas@relax.cmf.nrl.navy.mil	1.1133
# pppoatm.c, common.h, common.c:
#   [ATM]: implement pppoatm_ioctl_hook for pppoatm
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Sep 15 16:17:19 2003
+++ b/net/atm/common.c	Mon Sep 15 16:17:19 2003
@@ -130,8 +130,19 @@
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
@@ -816,12 +827,14 @@
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
--- a/net/atm/common.h	Mon Sep 15 16:17:19 2003
+++ b/net/atm/common.h	Mon Sep 15 16:17:19 2003
@@ -28,6 +28,8 @@
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+
 int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Mon Sep 15 16:17:19 2003
+++ b/net/atm/pppoatm.c	Mon Sep 15 16:17:19 2003
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
