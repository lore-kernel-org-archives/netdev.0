From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][8/8] use new code for atmtcp (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:12:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251612.h8PGC3kT007023@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1454  -> 1.1455 
#	     net/atm/ioctl.c	1.5     -> 1.6    
#	drivers/atm/atmtcp.c	1.19    -> 1.20   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1455
#   [ATM]: [ioctl][8/8] use new code for atmtcp (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Thu Sep 25 09:25:00 2003
+++ b/drivers/atm/atmtcp.c	Thu Sep 25 09:25:00 2003
@@ -431,32 +431,52 @@
 	return 0;
 }
 
+static int atmtcp_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	int err = 0;
+	struct atm_vcc *vcc = ATM_SD(sock);
+
+	if (cmd != SIOCSIFATMTCP && cmd != ATMTCP_CREATE && cmd != ATMTCP_REMOVE)
+		return -ENOIOCTLCMD;
 
-#ifdef MODULE
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
 
-int init_module(void)
+	switch (cmd) {
+		case SIOCSIFATMTCP:
+			err = atmtcp_attach(vcc, (int) arg);
+			if (err >= 0) {
+				sock->state = SS_CONNECTED;
+				__module_get(THIS_MODULE);
+			}
+			break;
+		case ATMTCP_CREATE:
+			err = atmtcp_create_persistent((int) arg);
+			break;
+		case ATMTCP_REMOVE:
+			err = atmtcp_remove_persistent((int) arg);
+			break;
+	}
+	return err;
+}
+
+static struct atm_ioctl atmtcp_ioctl_ops = {
+	.owner 	= THIS_MODULE,
+	.ioctl	= atmtcp_ioctl,
+};
+
+static __init int atmtcp_init(void)
 {
-	atm_tcp_ops.attach = atmtcp_attach;
-	atm_tcp_ops.create_persistent = atmtcp_create_persistent;
-	atm_tcp_ops.remove_persistent = atmtcp_remove_persistent;
+	register_atm_ioctl(&atmtcp_ioctl_ops);
 	return 0;
 }
 
 
-void cleanup_module(void)
+static void __exit atmtcp_exit(void)
 {
-	atm_tcp_ops.attach = NULL;
-	atm_tcp_ops.create_persistent = NULL;
-	atm_tcp_ops.remove_persistent = NULL;
+	deregister_atm_ioctl(&atmtcp_ioctl_ops);
 }
 
 MODULE_LICENSE("GPL");
-#else
-
-struct atm_tcp_ops atm_tcp_ops = {
-	atmtcp_attach,			/* attach */
-	atmtcp_create_persistent,	/* create_persistent */
-	atmtcp_remove_persistent	/* remove_persistent */
-};
-
-#endif
+module_init(atmtcp_init);
+module_exit(atmtcp_exit);
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:25:00 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:25:00 2003
@@ -53,14 +53,6 @@
 #endif
 #endif
 
-#if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
-#include <linux/atm_tcp.h>
-#ifdef CONFIG_ATM_TCP_MODULE
-struct atm_tcp_ops atm_tcp_ops;
-EXPORT_SYMBOL(atm_tcp_ops);
-#endif
-#endif
-
 static DECLARE_MUTEX(ioctl_mutex);
 static LIST_HEAD(ioctl_list);
 
@@ -184,49 +176,6 @@
 				module_put(atm_lane_ops->owner);
 			} else
 				error = -ENOSYS;
-			goto done;
-#endif
-#if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
-		case SIOCSIFATMTCP:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (!atm_tcp_ops.attach) {
-				error = -ENOPKG;
-				goto done;
-			}
-			fops_get(&atm_tcp_ops);
-			error = atm_tcp_ops.attach(vcc, (int) arg);
-			if (error >= 0)
-				sock->state = SS_CONNECTED;
-			else
-				fops_put (&atm_tcp_ops);
-			goto done;
-		case ATMTCP_CREATE:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (!atm_tcp_ops.create_persistent) {
-				error = -ENOPKG;
-				goto done;
-			}
-			error = atm_tcp_ops.create_persistent((int) arg);
-			if (error < 0)
-				fops_put (&atm_tcp_ops);
-			goto done;
-		case ATMTCP_REMOVE:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (!atm_tcp_ops.remove_persistent) {
-				error = -ENOPKG;
-				goto done;
-			}
-			error = atm_tcp_ops.remove_persistent((int) arg);
-			fops_put(&atm_tcp_ops);
 			goto done;
 #endif
 		default:
