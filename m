From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][7/8] use new code for clip (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:11:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251611.h8PGBbkT007001@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1453  -> 1.1454 
#	     net/atm/ioctl.c	1.4     -> 1.5    
#	 net/atm/protocols.h	1.1     -> 1.2    
#	include/net/atmclip.h	1.3     -> 1.4    
#	      net/atm/clip.c	1.28    -> 1.29   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1454
#   [ATM]: [ioctl][7/8] use new code for clip (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/include/net/atmclip.h b/include/net/atmclip.h
--- a/include/net/atmclip.h	Thu Sep 25 09:24:51 2003
+++ b/include/net/atmclip.h	Thu Sep 25 09:24:51 2003
@@ -56,29 +56,7 @@
 
 
 #ifdef __KERNEL__
-struct atm_clip_ops {
-	int (*clip_create)(int number);
-	int (*clip_mkip)(struct atm_vcc *vcc,int timeout);
-	int (*clip_setentry)(struct atm_vcc *vcc,u32 ip);
-	int (*clip_encap)(struct atm_vcc *vcc,int mode);
-	void (*clip_push)(struct atm_vcc *vcc,struct sk_buff *skb);
-	int (*atm_init_atmarp)(struct atm_vcc *vcc);
-	struct module *owner;
-};
-
-void atm_clip_ops_set(struct atm_clip_ops *);
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-int try_atm_clip_ops(void);
-#else
-static inline int try_atm_clip_ops(void)
-{
-	return 0;
-}
-#endif
-
-
 extern struct neigh_table *clip_tbl_hook;
-extern struct atm_clip_ops *atm_clip_ops;
 #endif
 
 #endif
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Thu Sep 25 09:24:51 2003
+++ b/net/atm/clip.c	Thu Sep 25 09:24:51 2003
@@ -762,14 +762,51 @@
 	return 0;
 }
 
-static struct atm_clip_ops __atm_clip_ops = {
-	.clip_create =		clip_create,
-	.clip_mkip =		clip_mkip,
-	.clip_setentry =	clip_setentry,
-	.clip_encap =		clip_encap,
-	.clip_push =		clip_push,
-	.atm_init_atmarp =	atm_init_atmarp,
-	.owner =		THIS_MODULE
+static int clip_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int err = 0;
+
+	switch (cmd) {
+		case SIOCMKCLIP:
+		case ATMARPD_CTRL:
+		case ATMARP_MKIP:
+		case ATMARP_SETENTRY:
+		case ATMARP_ENCAP:
+			if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
+			break;
+		default:
+			return -ENOIOCTLCMD;
+	}
+
+	switch (cmd) {
+		case SIOCMKCLIP:
+			err = clip_create(arg);
+			break;
+		case ATMARPD_CTRL:
+			err = atm_init_atmarp(vcc);
+			if (!err) {
+				sock->state = SS_CONNECTED;
+				__module_get(THIS_MODULE);
+			}
+			break;
+		case ATMARP_MKIP:
+			err = clip_mkip(vcc ,arg);
+			break;
+		case ATMARP_SETENTRY:
+			err = clip_setentry(vcc, arg);
+			break;
+		case ATMARP_ENCAP:
+			err = clip_encap(vcc, arg);
+			break;
+	}
+	return err;
+}
+
+static struct atm_ioctl clip_ioctl_ops = {
+	.owner 	= THIS_MODULE,
+	.ioctl	= clip_ioctl,
 };
 
 #ifdef CONFIG_PROC_FS
@@ -942,13 +979,10 @@
 	struct seq_file *seq;
 	int rc = -EAGAIN;
 
-	if (!try_atm_clip_ops())
-		goto out;
-
 	state = kmalloc(sizeof(*state), GFP_KERNEL);
 	if (!state) {
 		rc = -ENOMEM;
-		goto out_put;
+		goto out_kfree;
 	}
 
 	rc = seq_open(file, &arp_seq_ops);
@@ -960,8 +994,6 @@
 out:
 	return rc;
 
-out_put:
-	module_put(atm_clip_ops->owner);
 out_kfree:
 	kfree(state);
 	goto out;
@@ -969,7 +1001,6 @@
 
 static int arp_seq_release(struct inode *inode, struct file *file)
 {
-	module_put(atm_clip_ops->owner);
 	return seq_release_private(inode, file);
 }
 
@@ -1004,7 +1035,7 @@
 	skb_queue_head_init(&clip_tbl.proxy_queue);
 
 	clip_tbl_hook = &clip_tbl;
-	atm_clip_ops_set(&__atm_clip_ops);
+	register_atm_ioctl(&clip_ioctl_ops);
 
 	return 0;
 }
@@ -1015,7 +1046,7 @@
 
 	remove_proc_entry("arp", atm_proc_root);
 
-	atm_clip_ops_set(NULL);
+	deregister_atm_ioctl(&clip_ioctl_ops);
 
 	neigh_ifdown(&clip_tbl, NULL);
 	dev = clip_devs;
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:24:51 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:24:51 2003
@@ -15,11 +15,9 @@
 #include <linux/sonet.h>	/* for ioctls */
 #include <linux/atmsvc.h>
 #include <linux/atmmpc.h>
+#include <net/atmclip.h>
 #include <asm/ioctls.h>
 
-#ifdef CONFIG_ATM_CLIP
-#include <net/atmclip.h>	/* for clip_create */
-#endif
 #include "resources.h"
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
@@ -63,36 +61,6 @@
 #endif
 #endif
 
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
 static DECLARE_MUTEX(ioctl_mutex);
 static LIST_HEAD(ioctl_list);
 
@@ -177,68 +145,6 @@
 			if (!error)
 				sock->state = SS_CONNECTED;
 			goto done;
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
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
                 case ATMLEC_CTRL:
                         if (!capable(CAP_NET_ADMIN)) {
@@ -329,6 +235,8 @@
 
 	if (cmd == ATMMPC_CTRL || cmd == ATMMPC_DATA)
 		request_module("mpoa");
+	if (cmd == ATMARPD_CTRL)
+		request_module("clip");
 
 	error = -ENOIOCTLCMD;
 
diff -Nru a/net/atm/protocols.h b/net/atm/protocols.h
--- a/net/atm/protocols.h	Thu Sep 25 09:24:51 2003
+++ b/net/atm/protocols.h	Thu Sep 25 09:24:51 2003
@@ -11,6 +11,5 @@
 int atm_init_aal0(struct atm_vcc *vcc);	/* "raw" AAL0 */
 int atm_init_aal34(struct atm_vcc *vcc);/* "raw" AAL3/4 transport */
 int atm_init_aal5(struct atm_vcc *vcc);	/* "raw" AAL5 transport */
-int atm_init_atmarp(struct atm_vcc *vcc);/* ATM ARP */
 
 #endif
