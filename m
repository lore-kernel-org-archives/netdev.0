From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:09:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251609.h8PG9bkT006926@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1447  -> 1.1448 
#	    net/atm/Makefile	1.11    -> 1.12   
#	    net/atm/common.c	1.53    -> 1.54   
#	               (new)	        -> 1.1     net/atm/ioctl.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1448
# [ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/Makefile b/net/atm/Makefile
--- a/net/atm/Makefile	Thu Sep 25 09:24:00 2003
+++ b/net/atm/Makefile	Thu Sep 25 09:24:00 2003
@@ -2,7 +2,7 @@
 # Makefile for the ATM Protocol Families.
 #
 
-atm-y		:= addr.o pvc.o signaling.o svc.o common.o atm_misc.o raw.o resources.o
+atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
 obj-$(CONFIG_ATM) += atm.o
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Sep 25 09:24:00 2003
+++ b/net/atm/common.c	Thu Sep 25 09:24:00 2003
@@ -9,9 +9,6 @@
 #include <linux/net.h>		/* struct socket, struct proto_ops */
 #include <linux/atm.h>		/* ATM stuff */
 #include <linux/atmdev.h>
-#include <linux/atmclip.h>	/* CLIP_*ENCAP */
-#include <linux/atmarp.h>	/* manifest constants */
-#include <linux/sonet.h>	/* for ioctls */
 #include <linux/socket.h>	/* SOL_SOCKET */
 #include <linux/errno.h>	/* error codes */
 #include <linux/capability.h>
@@ -26,147 +23,12 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 #include <asm/poll.h>
-#include <asm/ioctls.h>
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-#include <linux/atmlec.h>
-#include "lec.h"
-#include "lec_arpc.h"
-struct atm_lane_ops *atm_lane_ops;
-static DECLARE_MUTEX(atm_lane_ops_mutex);
-
-void atm_lane_ops_set(struct atm_lane_ops *hook)
-{
-	down(&atm_lane_ops_mutex);
-	atm_lane_ops = hook;
-	up(&atm_lane_ops_mutex);
-}
-
-int try_atm_lane_ops(void)
-{
-	down(&atm_lane_ops_mutex);
-	if (atm_lane_ops && try_module_get(atm_lane_ops->owner)) {
-		up(&atm_lane_ops_mutex);
-		return 1;
-	}
-	up(&atm_lane_ops_mutex);
-	return 0;
-}
-
-#if defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_ATM_MPOA_MODULE)
-EXPORT_SYMBOL(atm_lane_ops);
-EXPORT_SYMBOL(try_atm_lane_ops);
-EXPORT_SYMBOL(atm_lane_ops_set);
-#endif
-#endif
-
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
-#if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
-#include <linux/atm_tcp.h>
-#ifdef CONFIG_ATM_TCP_MODULE
-struct atm_tcp_ops atm_tcp_ops;
-EXPORT_SYMBOL(atm_tcp_ops);
-#endif
-#endif
-
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-#include <net/atmclip.h>
-struct atm_clip_ops *atm_clip_ops;
-static DECLARE_MUTEX(atm_clip_ops_mutex);
-
-void atm_clip_ops_set(struct atm_clip_ops *hook)
-{
-	down(&atm_clip_ops_mutex);
-	atm_clip_ops = hook;
-	up(&atm_clip_ops_mutex);
-}
-
-int try_atm_clip_ops(void)
-{
-	down(&atm_clip_ops_mutex);
-	if (atm_clip_ops && try_module_get(atm_clip_ops->owner)) {
-		up(&atm_clip_ops_mutex);
-		return 1;
-	}
-	up(&atm_clip_ops_mutex);
-	return 0;
-}
-
-#ifdef CONFIG_ATM_CLIP_MODULE
-EXPORT_SYMBOL(atm_clip_ops);
-EXPORT_SYMBOL(try_atm_clip_ops);
-EXPORT_SYMBOL(atm_clip_ops_set);
-#endif
-#endif
-
-#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-static DECLARE_MUTEX(pppoatm_ioctl_mutex);
-
-static int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
-void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
-{
-	down(&pppoatm_ioctl_mutex);
-	pppoatm_ioctl_hook = hook;
-	up(&pppoatm_ioctl_mutex);
-}
-#ifdef CONFIG_PPPOATM_MODULE
-EXPORT_SYMBOL(pppoatm_ioctl_set);
-#endif
-#endif
-
-#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-static DECLARE_MUTEX(br2684_ioctl_mutex);
-
-static int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
-void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
-{
-	down(&br2684_ioctl_mutex);
-	br2684_ioctl_hook = hook;
-	up(&br2684_ioctl_mutex);
-}
-#ifdef CONFIG_ATM_BR2684_MODULE
-EXPORT_SYMBOL(br2684_ioctl_set);
-#endif
-#endif
 
 #include "resources.h"		/* atm_find_dev */
 #include "common.h"		/* prototypes */
 #include "protocols.h"		/* atm_init_<transport> */
 #include "addr.h"		/* address registry */
-#ifdef CONFIG_ATM_CLIP
-#include <net/atmclip.h>	/* for clip_create */
-#endif
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
 
@@ -760,272 +622,6 @@
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 
 	return mask;
-}
-
-
-int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
-{
-	struct atm_vcc *vcc;
-	int error;
-
-	vcc = ATM_SD(sock);
-	switch (cmd) {
-		case SIOCOUTQ:
-			if (sock->state != SS_CONNECTED ||
-			    !test_bit(ATM_VF_READY, &vcc->flags)) {
-				error =  -EINVAL;
-				goto done;
-			}
-			error = put_user(vcc->sk->sk_sndbuf -
-					 atomic_read(&vcc->sk->sk_wmem_alloc),
-					 (int *) arg) ? -EFAULT : 0;
-			goto done;
-		case SIOCINQ:
-			{
-				struct sk_buff *skb;
-
-				if (sock->state != SS_CONNECTED) {
-					error = -EINVAL;
-					goto done;
-				}
-				skb = skb_peek(&vcc->sk->sk_receive_queue);
-				error = put_user(skb ? skb->len : 0,
-					 	 (int *) arg) ? -EFAULT : 0;
-				goto done;
-			}
-		case SIOCGSTAMP: /* borrowed from IP */
-			if (!vcc->sk->sk_stamp.tv_sec) {
-				error = -ENOENT;
-				goto done;
-			}
-			error = copy_to_user((void *)arg, &vcc->sk->sk_stamp,
-					     sizeof(struct timeval)) ? -EFAULT : 0;
-			goto done;
-		case ATM_SETSC:
-			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
-			error = 0;
-			goto done;
-		case ATMSIGD_CTRL:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			/*
-			 * The user/kernel protocol for exchanging signalling
-			 * info uses kernel pointers as opaque references,
-			 * so the holder of the file descriptor can scribble
-			 * on the kernel... so we should make sure that we
-			 * have the same privledges that /proc/kcore needs
-			 */
-			if (!capable(CAP_SYS_RAWIO)) {
-				error = -EPERM;
-				goto done;
-			}
-			error = sigd_attach(vcc);
-			if (!error)
-				sock->state = SS_CONNECTED;
-			goto done;
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-		case SIOCMKCLIP:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_clip_ops()) {
-				error = atm_clip_ops->clip_create(arg);
-				module_put(atm_clip_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-		case ATMARPD_CTRL:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-#if defined(CONFIG_ATM_CLIP_MODULE)
-			if (!atm_clip_ops)
-				request_module("clip");
-#endif
-			if (try_atm_clip_ops()) {
-				error = atm_clip_ops->atm_init_atmarp(vcc);
-				if (!error)
-					sock->state = SS_CONNECTED;
-			} else
-				error = -ENOSYS;
-			goto done;
-		case ATMARP_MKIP:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_clip_ops()) {
-				error = atm_clip_ops->clip_mkip(vcc, arg);
-				module_put(atm_clip_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-		case ATMARP_SETENTRY:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_clip_ops()) {
-				error = atm_clip_ops->clip_setentry(vcc, arg);
-				module_put(atm_clip_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-		case ATMARP_ENCAP:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_clip_ops()) {
-				error = atm_clip_ops->clip_encap(vcc, arg);
-				module_put(atm_clip_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-#endif
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-                case ATMLEC_CTRL:
-                        if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-#if defined(CONFIG_ATM_LANE_MODULE)
-                        if (!atm_lane_ops)
-				request_module("lec");
-#endif
-			if (try_atm_lane_ops()) {
-				error = atm_lane_ops->lecd_attach(vcc, (int) arg);
-				module_put(atm_lane_ops->owner);
-				if (error >= 0)
-					sock->state = SS_CONNECTED;
-			} else
-				error = -ENOSYS;
-			goto done;
-                case ATMLEC_MCAST:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_lane_ops()) {
-				error = atm_lane_ops->mcast_attach(vcc, (int) arg);
-				module_put(atm_lane_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-                case ATMLEC_DATA:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			if (try_atm_lane_ops()) {
-				error = atm_lane_ops->vcc_attach(vcc, (void *) arg);
-				module_put(atm_lane_ops->owner);
-			} else
-				error = -ENOSYS;
-			goto done;
-#endif
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
-			goto done;
-#endif
-		default:
-			break;
-	}
-	error = -ENOIOCTLCMD;
-#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-	down(&pppoatm_ioctl_mutex);
-	if (pppoatm_ioctl_hook)
-		error = pppoatm_ioctl_hook(vcc, cmd, arg);
-	up(&pppoatm_ioctl_mutex);
-	if (error != -ENOIOCTLCMD)
-		goto done;
-#endif
-#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-	down(&br2684_ioctl_mutex);
-	if (br2684_ioctl_hook)
-		error = br2684_ioctl_hook(vcc, cmd, arg);
-	up(&br2684_ioctl_mutex);
-	if (error != -ENOIOCTLCMD)
-		goto done;
-#endif
-
-	error = atm_dev_ioctl(cmd, arg);
-
-done:
-	return error;
 }
 
 
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/net/atm/ioctl.c	Thu Sep 25 09:24:00 2003
@@ -0,0 +1,420 @@
+/* net/atm/common.c - ATM sockets (common part for PVC and SVC) */
+
+/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
+
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/net.h>		/* struct socket, struct proto_ops */
+#include <linux/atm.h>		/* ATM stuff */
+#include <linux/atmdev.h>
+#include <linux/atmclip.h>	/* CLIP_*ENCAP */
+#include <linux/atmarp.h>	/* manifest constants */
+#include <linux/sonet.h>	/* for ioctls */
+#include <linux/atmsvc.h>
+#include <asm/ioctls.h>
+
+#ifdef CONFIG_ATM_CLIP
+#include <net/atmclip.h>	/* for clip_create */
+#endif
+#include "resources.h"		/* atm_find_dev */
+#include "signaling.h"		/* for WAITING and sigd_attach */
+
+#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#include <linux/atmlec.h>
+#include "lec.h"
+#include "lec_arpc.h"
+struct atm_lane_ops *atm_lane_ops;
+static DECLARE_MUTEX(atm_lane_ops_mutex);
+
+void atm_lane_ops_set(struct atm_lane_ops *hook)
+{
+	down(&atm_lane_ops_mutex);
+	atm_lane_ops = hook;
+	up(&atm_lane_ops_mutex);
+}
+
+int try_atm_lane_ops(void)
+{
+	down(&atm_lane_ops_mutex);
+	if (atm_lane_ops && try_module_get(atm_lane_ops->owner)) {
+		up(&atm_lane_ops_mutex);
+		return 1;
+	}
+	up(&atm_lane_ops_mutex);
+	return 0;
+}
+
+#if defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_ATM_MPOA_MODULE)
+EXPORT_SYMBOL(atm_lane_ops);
+EXPORT_SYMBOL(try_atm_lane_ops);
+EXPORT_SYMBOL(atm_lane_ops_set);
+#endif
+#endif
+
+#if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
+#include <linux/atmmpc.h>
+#include "mpc.h"
+struct atm_mpoa_ops *atm_mpoa_ops;
+static DECLARE_MUTEX(atm_mpoa_ops_mutex);
+
+void atm_mpoa_ops_set(struct atm_mpoa_ops *hook)
+{
+	down(&atm_mpoa_ops_mutex);
+	atm_mpoa_ops = hook;
+	up(&atm_mpoa_ops_mutex);
+}
+
+int try_atm_mpoa_ops(void)
+{
+	down(&atm_mpoa_ops_mutex);
+	if (atm_mpoa_ops && try_module_get(atm_mpoa_ops->owner)) {
+		up(&atm_mpoa_ops_mutex);
+		return 1;
+	}
+	up(&atm_mpoa_ops_mutex);
+	return 0;
+}
+#ifdef CONFIG_ATM_MPOA_MODULE
+EXPORT_SYMBOL(atm_mpoa_ops);
+EXPORT_SYMBOL(try_atm_mpoa_ops);
+EXPORT_SYMBOL(atm_mpoa_ops_set);
+#endif
+#endif
+
+#if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
+#include <linux/atm_tcp.h>
+#ifdef CONFIG_ATM_TCP_MODULE
+struct atm_tcp_ops atm_tcp_ops;
+EXPORT_SYMBOL(atm_tcp_ops);
+#endif
+#endif
+
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+#include <net/atmclip.h>
+struct atm_clip_ops *atm_clip_ops;
+static DECLARE_MUTEX(atm_clip_ops_mutex);
+
+void atm_clip_ops_set(struct atm_clip_ops *hook)
+{
+	down(&atm_clip_ops_mutex);
+	atm_clip_ops = hook;
+	up(&atm_clip_ops_mutex);
+}
+
+int try_atm_clip_ops(void)
+{
+	down(&atm_clip_ops_mutex);
+	if (atm_clip_ops && try_module_get(atm_clip_ops->owner)) {
+		up(&atm_clip_ops_mutex);
+		return 1;
+	}
+	up(&atm_clip_ops_mutex);
+	return 0;
+}
+
+#ifdef CONFIG_ATM_CLIP_MODULE
+EXPORT_SYMBOL(atm_clip_ops);
+EXPORT_SYMBOL(try_atm_clip_ops);
+EXPORT_SYMBOL(atm_clip_ops_set);
+#endif
+#endif
+
+#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
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
+#endif
+
+#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
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
+#ifdef CONFIG_ATM_BR2684_MODULE
+EXPORT_SYMBOL(br2684_ioctl_set);
+#endif
+#endif
+
+
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct atm_vcc *vcc;
+	int error;
+
+	vcc = ATM_SD(sock);
+	switch (cmd) {
+		case SIOCOUTQ:
+			if (sock->state != SS_CONNECTED ||
+			    !test_bit(ATM_VF_READY, &vcc->flags)) {
+				error =  -EINVAL;
+				goto done;
+			}
+			error = put_user(vcc->sk->sk_sndbuf -
+					 atomic_read(&vcc->sk->sk_wmem_alloc),
+					 (int *) arg) ? -EFAULT : 0;
+			goto done;
+		case SIOCINQ:
+			{
+				struct sk_buff *skb;
+
+				if (sock->state != SS_CONNECTED) {
+					error = -EINVAL;
+					goto done;
+				}
+				skb = skb_peek(&vcc->sk->sk_receive_queue);
+				error = put_user(skb ? skb->len : 0,
+					 	 (int *) arg) ? -EFAULT : 0;
+				goto done;
+			}
+		case SIOCGSTAMP: /* borrowed from IP */
+			if (!vcc->sk->sk_stamp.tv_sec) {
+				error = -ENOENT;
+				goto done;
+			}
+			error = copy_to_user((void *)arg, &vcc->sk->sk_stamp,
+					     sizeof(struct timeval)) ? -EFAULT : 0;
+			goto done;
+		case ATM_SETSC:
+			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
+			error = 0;
+			goto done;
+		case ATMSIGD_CTRL:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			/*
+			 * The user/kernel protocol for exchanging signalling
+			 * info uses kernel pointers as opaque references,
+			 * so the holder of the file descriptor can scribble
+			 * on the kernel... so we should make sure that we
+			 * have the same privledges that /proc/kcore needs
+			 */
+			if (!capable(CAP_SYS_RAWIO)) {
+				error = -EPERM;
+				goto done;
+			}
+			error = sigd_attach(vcc);
+			if (!error)
+				sock->state = SS_CONNECTED;
+			goto done;
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+		case SIOCMKCLIP:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_clip_ops()) {
+				error = atm_clip_ops->clip_create(arg);
+				module_put(atm_clip_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+		case ATMARPD_CTRL:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+#if defined(CONFIG_ATM_CLIP_MODULE)
+			if (!atm_clip_ops)
+				request_module("clip");
+#endif
+			if (try_atm_clip_ops()) {
+				error = atm_clip_ops->atm_init_atmarp(vcc);
+				if (!error)
+					sock->state = SS_CONNECTED;
+			} else
+				error = -ENOSYS;
+			goto done;
+		case ATMARP_MKIP:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_clip_ops()) {
+				error = atm_clip_ops->clip_mkip(vcc, arg);
+				module_put(atm_clip_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+		case ATMARP_SETENTRY:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_clip_ops()) {
+				error = atm_clip_ops->clip_setentry(vcc, arg);
+				module_put(atm_clip_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+		case ATMARP_ENCAP:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_clip_ops()) {
+				error = atm_clip_ops->clip_encap(vcc, arg);
+				module_put(atm_clip_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+#endif
+#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+                case ATMLEC_CTRL:
+                        if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+#if defined(CONFIG_ATM_LANE_MODULE)
+                        if (!atm_lane_ops)
+				request_module("lec");
+#endif
+			if (try_atm_lane_ops()) {
+				error = atm_lane_ops->lecd_attach(vcc, (int) arg);
+				module_put(atm_lane_ops->owner);
+				if (error >= 0)
+					sock->state = SS_CONNECTED;
+			} else
+				error = -ENOSYS;
+			goto done;
+                case ATMLEC_MCAST:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_lane_ops()) {
+				error = atm_lane_ops->mcast_attach(vcc, (int) arg);
+				module_put(atm_lane_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+                case ATMLEC_DATA:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_lane_ops()) {
+				error = atm_lane_ops->vcc_attach(vcc, (void *) arg);
+				module_put(atm_lane_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+#endif
+#if defined(CONFIG_ATM_MPOA) || defined(CONFIG_ATM_MPOA_MODULE)
+		case ATMMPC_CTRL:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+#if defined(CONFIG_ATM_MPOA_MODULE)
+			if (!atm_mpoa_ops)
+                                request_module("mpoa");
+#endif
+			if (try_atm_mpoa_ops()) {
+				error = atm_mpoa_ops->mpoad_attach(vcc, (int) arg);
+				module_put(atm_mpoa_ops->owner);
+				if (error >= 0)
+					sock->state = SS_CONNECTED;
+			} else
+				error = -ENOSYS;
+			goto done;
+		case ATMMPC_DATA:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (try_atm_mpoa_ops()) {
+				error = atm_mpoa_ops->vcc_attach(vcc, arg);
+				module_put(atm_mpoa_ops->owner);
+			} else
+				error = -ENOSYS;
+			goto done;
+#endif
+#if defined(CONFIG_ATM_TCP) || defined(CONFIG_ATM_TCP_MODULE)
+		case SIOCSIFATMTCP:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (!atm_tcp_ops.attach) {
+				error = -ENOPKG;
+				goto done;
+			}
+			fops_get(&atm_tcp_ops);
+			error = atm_tcp_ops.attach(vcc, (int) arg);
+			if (error >= 0)
+				sock->state = SS_CONNECTED;
+			else
+				fops_put (&atm_tcp_ops);
+			goto done;
+		case ATMTCP_CREATE:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (!atm_tcp_ops.create_persistent) {
+				error = -ENOPKG;
+				goto done;
+			}
+			error = atm_tcp_ops.create_persistent((int) arg);
+			if (error < 0)
+				fops_put (&atm_tcp_ops);
+			goto done;
+		case ATMTCP_REMOVE:
+			if (!capable(CAP_NET_ADMIN)) {
+				error = -EPERM;
+				goto done;
+			}
+			if (!atm_tcp_ops.remove_persistent) {
+				error = -ENOPKG;
+				goto done;
+			}
+			error = atm_tcp_ops.remove_persistent((int) arg);
+			fops_put(&atm_tcp_ops);
+			goto done;
+#endif
+		default:
+			break;
+	}
+	error = -ENOIOCTLCMD;
+#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
+	down(&pppoatm_ioctl_mutex);
+	if (pppoatm_ioctl_hook)
+		error = pppoatm_ioctl_hook(vcc, cmd, arg);
+	up(&pppoatm_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
+#endif
+#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
+	down(&br2684_ioctl_mutex);
+	if (br2684_ioctl_hook)
+		error = br2684_ioctl_hook(vcc, cmd, arg);
+	up(&br2684_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
+#endif
+
+	error = atm_dev_ioctl(cmd, arg);
+
+done:
+	return error;
+}
