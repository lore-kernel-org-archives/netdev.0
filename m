From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][2/8] add registration functions (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:09:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251609.h8PG9qkT006932@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1448  -> 1.1449 
#	     net/atm/ioctl.c	1.1     -> 1.2    
#	include/linux/atmdev.h	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1449
# [ATM]: [ioctl][2/8] add registration functions (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Thu Sep 25 09:24:09 2003
+++ b/include/linux/atmdev.h	Thu Sep 25 09:24:09 2003
@@ -445,6 +445,28 @@
 
 void vcc_release_async(struct atm_vcc *vcc, int reply);
 
+struct atm_ioctl {
+	struct module *owner;
+	/* A module reference is kept if appropriate over this call.
+	 * Return -ENOIOCTLCMD if you don't handle it. */
+	int (*ioctl)(struct socket *, unsigned int cmd, unsigned long arg);
+	struct list_head list;
+};
+
+/**
+ * register_atm_ioctl - register handler for ioctl operations
+ *
+ * Special (non-device) handlers of ioctl's should
+ * register here. If you're a normal device, you should
+ * set .ioctl in your atmdev_ops instead.
+ */
+void register_atm_ioctl(struct atm_ioctl *);
+
+/**
+ * deregister_atm_ioctl - remove the ioctl handler
+ */
+void deregister_atm_ioctl(struct atm_ioctl *);
+
 #endif /* __KERNEL__ */
 
 #endif
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:24:09 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:24:09 2003
@@ -1,6 +1,7 @@
-/* net/atm/common.c - ATM sockets (common part for PVC and SVC) */
+/* ATM ioctl handling */
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
+/* 2003 John Levon  <levon@movementarian.org> */
 
 
 #include <linux/config.h>
@@ -18,7 +19,7 @@
 #ifdef CONFIG_ATM_CLIP
 #include <net/atmclip.h>	/* for clip_create */
 #endif
-#include "resources.h"		/* atm_find_dev */
+#include "resources.h"
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
@@ -153,11 +154,32 @@
 #endif
 #endif
 
+static DECLARE_MUTEX(ioctl_mutex);
+static LIST_HEAD(ioctl_list);
+
+
+void register_atm_ioctl(struct atm_ioctl *ioctl)
+{
+	down(&ioctl_mutex);
+	list_add_tail(&ioctl->list, &ioctl_list);
+	up(&ioctl_mutex);
+}
+
+void deregister_atm_ioctl(struct atm_ioctl *ioctl)
+{
+	down(&ioctl_mutex);
+	list_del(&ioctl->list);
+	up(&ioctl_mutex);
+}
+
+EXPORT_SYMBOL(register_atm_ioctl);
+EXPORT_SYMBOL(deregister_atm_ioctl);
 
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct atm_vcc *vcc;
 	int error;
+	struct list_head * pos;
 
 	vcc = ATM_SD(sock);
 	switch (cmd) {
@@ -396,6 +418,22 @@
 			break;
 	}
 	error = -ENOIOCTLCMD;
+
+	down(&ioctl_mutex);
+	list_for_each(pos, &ioctl_list) {
+		struct atm_ioctl * ic = list_entry(pos, struct atm_ioctl, list);
+		if (try_module_get(ic->owner)) {
+			error = ic->ioctl(sock, cmd, arg);
+			module_put(ic->owner);
+			if (error != -ENOIOCTLCMD)
+				break;
+		}
+	}
+	up(&ioctl_mutex);
+
+	if (error != -ENOIOCTLCMD)
+		goto done;
+
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
 	down(&pppoatm_ioctl_mutex);
 	if (pppoatm_ioctl_hook)
