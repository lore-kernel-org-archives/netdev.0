From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][4/8] use new code for mpoa (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:10:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251610.h8PGAKkT006950@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1450  -> 1.1451 
#	       net/atm/mpc.h	1.2     -> 1.3    
#	     net/atm/ioctl.c	1.3     -> 1.4    
#	       net/atm/mpc.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1451
# [ATM]: [ioctl][4/8] use new code for mpoa (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:24:27 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:24:27 2003
@@ -14,6 +14,7 @@
 #include <linux/atmarp.h>	/* manifest constants */
 #include <linux/sonet.h>	/* for ioctls */
 #include <linux/atmsvc.h>
+#include <linux/atmmpc.h>
 #include <asm/ioctls.h>
 
 #ifdef CONFIG_ATM_CLIP
@@ -54,36 +55,6 @@
 #endif
 #endif
 
-#if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
-#include <linux/atmmpc.h>
-#include "mpc.h"
-struct atm_mpoa_ops *atm_mpoa_ops;
-static DECLARE_MUTEX(atm_mpoa_ops_mutex);
-
-void atm_mpoa_ops_set(struct atm_mpoa_ops *hook)
-{
-	down(&atm_mpoa_ops_mutex);
-	atm_mpoa_ops = hook;
-	up(&atm_mpoa_ops_mutex);
-}
-
-int try_atm_mpoa_ops(void)
-{
-	down(&atm_mpoa_ops_mutex);
-	if (atm_mpoa_ops && try_module_get(atm_mpoa_ops->owner)) {
-		up(&atm_mpoa_ops_mutex);
-		return 1;
-	}
-	up(&atm_mpoa_ops_mutex);
-	return 0;
-}
-#ifdef CONFIG_ATM_MPOA_MODULE
-EXPORT_SYMBOL(atm_mpoa_ops);
-EXPORT_SYMBOL(try_atm_mpoa_ops);
-EXPORT_SYMBOL(atm_mpoa_ops_set);
-#endif
-#endif
-
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
 #include <linux/atm_tcp.h>
 #ifdef CONFIG_ATM_TCP_MODULE
@@ -309,36 +280,6 @@
 				error = -ENOSYS;
 			goto done;
 #endif
-#if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
-		case ATMMPC_CTRL:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-#if defined(CONFIG_ATM_MPOA_MODULE)
-			if (!atm_mpoa_ops)
-                                request_module("mpoa");
-#endif
-			if (try_atm_mpoa_ops()) {
-				error = atm_mpoa_ops->mpoad_attach(vcc, (int) arg);
-				module_put(atm_mpoa_ops->owner);
-				if (error >= 0)
-					sock->state = SS_CONNECTED;
-			} else
-				error = -ENOSYS;
-			goto done;
-		case ATMMPC_DATA:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_mpoa_ops()) {
-				error = atm_mpoa_ops->vcc_attach(vcc, arg);
-				module_put(atm_mpoa_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-#endif
 #if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
 		case SIOCSIFATMTCP:
 			if (!capable(CAP_NET_ADMIN)) {
@@ -385,6 +326,10 @@
 		default:
 			break;
 	}
+
+	if (cmd == ATMMPC_CTRL || cmd == ATMMPC_DATA)
+		request_module("mpoa");
+
 	error = -ENOIOCTLCMD;
 
 	down(&ioctl_mutex);
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Thu Sep 25 09:24:27 2003
+++ b/net/atm/mpc.c	Thu Sep 25 09:24:27 2003
@@ -1361,15 +1361,41 @@
 	mpc_timer_refresh();
 }
 
-static struct atm_mpoa_ops __atm_mpoa_ops = {
-	.mpoad_attach =	atm_mpoa_mpoad_attach,
-	.vcc_attach =	atm_mpoa_vcc_attach,
-	.owner = THIS_MODULE
+static int atm_mpoa_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	int err = 0;
+	struct atm_vcc *vcc = ATM_SD(sock);
+
+	if (cmd != ATMMPC_CTRL && cmd != ATMMPC_DATA)
+		return -ENOIOCTLCMD;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch (cmd) {
+		case ATMMPC_CTRL:
+			err = atm_mpoa_mpoad_attach(vcc, (int)arg);
+			if (err >= 0)
+				sock->state = SS_CONNECTED;
+			break;
+		case ATMMPC_DATA:
+			err = atm_mpoa_vcc_attach(vcc, arg);
+			break;
+		default:
+			break;
+	}
+	return err;
+}
+
+
+static struct atm_ioctl atm_ioctl_ops = {
+	.owner	= THIS_MODULE,
+	.ioctl	= atm_mpoa_ioctl,
 };
 
 static __init int atm_mpoa_init(void)
 {
-	atm_mpoa_ops_set(&__atm_mpoa_ops);
+	register_atm_ioctl(&atm_ioctl_ops);
 
 #ifdef CONFIG_PROC_FS
 	if (mpc_proc_init() != 0)
@@ -1395,7 +1421,7 @@
 
 	del_timer(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
-	atm_mpoa_ops_set(NULL);
+	deregister_atm_ioctl(&atm_ioctl_ops);
 
 	mpc = mpcs;
 	mpcs = NULL;
diff -Nru a/net/atm/mpc.h b/net/atm/mpc.h
--- a/net/atm/mpc.h	Thu Sep 25 09:24:27 2003
+++ b/net/atm/mpc.h	Thu Sep 25 09:24:27 2003
@@ -44,18 +44,6 @@
 };
 
 
-/* Functions to call during ioctl(ATMMPC, ) */
-struct atm_mpoa_ops {
-        int (*mpoad_attach)(struct atm_vcc *vcc, int arg);  /* attach mpoa daemon  */
-        int (*vcc_attach)(struct atm_vcc *vcc, long arg);   /* attach shortcut vcc */
-	struct module *owner;
-};
-
-/* Boot/module initialization function */
-extern struct atm_mpoa_ops *atm_mpoa_ops;
-int try_atm_mpoa_ops(void);
-void atm_mpoa_ops_set(struct atm_mpoa_ops *hook);
-
 /* MPOA QoS operations */
 struct atm_mpoa_qos *atm_mpoa_add_qos(uint32_t dst_ip, struct atm_qos *qos);
 struct atm_mpoa_qos *atm_mpoa_search_qos(uint32_t dst_ip);
