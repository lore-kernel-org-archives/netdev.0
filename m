From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: use new ioctl code for lane [3/3]
Date: Thu, 25 Sep 2003 12:14:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251614.h8PGEYkT007098@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1457  -> 1.1458 
#	       net/atm/lec.h	1.6     -> 1.7    
#	       net/atm/lec.c	1.40    -> 1.41   
#	     net/atm/ioctl.c	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/25	chas@relax.cmf.nrl.navy.mil	1.1458
# [ATM]: use new ioctl code for lane [3/3]
# --------------------------------------------
#
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:28:46 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:28:46 2003
@@ -16,42 +16,12 @@
 #include <linux/atmsvc.h>
 #include <linux/atmmpc.h>
 #include <net/atmclip.h>
+#include <linux/atmlec.h>
 #include <asm/ioctls.h>
 
 #include "resources.h"
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
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
 
 static DECLARE_MUTEX(ioctl_mutex);
 static LIST_HEAD(ioctl_list);
@@ -137,47 +107,6 @@
 			if (!error)
 				sock->state = SS_CONNECTED;
 			goto done;
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
 		default:
 			break;
 	}
@@ -186,6 +115,8 @@
 		request_module("mpoa");
 	if (cmd == ATMARPD_CTRL)
 		request_module("clip");
+	if (cmd == ATMLEC_CTRL)
+		request_module("lec");
 
 	error = -ENOIOCTLCMD;
 
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Thu Sep 25 09:28:46 2003
+++ b/net/atm/lec.c	Thu Sep 25 09:28:46 2003
@@ -835,16 +835,6 @@
         return i;
 }
 
-static struct atm_lane_ops __atm_lane_ops = 
-{
-	.lecd_attach =	lecd_attach,
-	.mcast_attach =	lec_mcast_attach,
-	.vcc_attach = 	lec_vcc_attach,
-	.get_lec = 	get_dev_lec,
-	.owner = 	THIS_MODULE
-};
-
-
 #ifdef CONFIG_PROC_FS
 static char* lec_arp_get_status_string(unsigned char status)
 {
@@ -1092,6 +1082,44 @@
 };
 #endif
 
+static int lane_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int err = 0;
+	
+	switch (cmd) {
+		case ATMLEC_CTRL: 
+		case ATMLEC_MCAST:
+		case ATMLEC_DATA:
+			if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
+			break;
+		default:
+			return -ENOIOCTLCMD;
+	}
+
+	switch (cmd) {
+		case ATMLEC_CTRL:
+			err = lecd_attach(vcc, (int) arg);
+			if (err >= 0)
+				sock->state = SS_CONNECTED;
+			break;
+		case ATMLEC_MCAST:
+			err = lec_mcast_attach(vcc, (int) arg);
+			break;
+		case ATMLEC_DATA:
+			err = lec_vcc_attach(vcc, (void *) arg);
+			break;
+	}
+
+	return err;
+}
+
+static struct atm_ioctl lane_ioctl_ops = {
+	.owner  = THIS_MODULE,
+	.ioctl  = lane_ioctl,
+};
+
 static int __init lane_module_init(void)
 {
 #ifdef CONFIG_PROC_FS
@@ -1102,7 +1130,7 @@
 		p->proc_fops = &lec_seq_fops;
 #endif
 
-        atm_lane_ops_set(&__atm_lane_ops);
+	register_atm_ioctl(&lane_ioctl_ops);
         printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
         return 0;
 }
@@ -1114,7 +1142,7 @@
 
 	remove_proc_entry("lec", atm_proc_root);
 
-        atm_lane_ops_set(NULL);
+	deregister_atm_ioctl(&lane_ioctl_ops);
 
         for (i = 0; i < MAX_LEC_ITF; i++) {
                 if (dev_lec[i] != NULL) {
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	Thu Sep 25 09:28:46 2003
+++ b/net/atm/lec.h	Thu Sep 25 09:28:46 2003
@@ -60,14 +60,6 @@
                                     u8 *tlvs, u32 sizeoftlvs);
 };
 
-struct atm_lane_ops {
-        int (*lecd_attach)(struct atm_vcc *vcc, int arg);
-        int (*mcast_attach)(struct atm_vcc *vcc, int arg);
-        int (*vcc_attach)(struct atm_vcc *vcc, void *arg);
-        struct net_device * (*get_lec)(int itf);
-        struct module *owner;
-};
-
 /*
  * ATM LAN Emulation supports both LLC & Dix Ethernet EtherType
  * frames. 
@@ -156,10 +148,6 @@
                  atmlec_msg_type type, unsigned char *mac_addr,
                  unsigned char *atm_addr, struct sk_buff *data);
 void lec_push(struct atm_vcc *vcc, struct sk_buff *skb);
-
-extern struct atm_lane_ops *atm_lane_ops;
-void atm_lane_ops_set(struct atm_lane_ops *hook);
-int try_atm_lane_ops(void);
 
 #endif /* _LEC_H_ */
 
