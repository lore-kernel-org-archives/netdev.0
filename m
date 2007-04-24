From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/9] wext: clean up how wext is called
Date: Tue, 24 Apr 2007 20:07:34 +0200
Message-ID: <20070424180847.533947000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=cleanup-wext-call.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch cleans up the call paths from the core code into wext.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 include/net/iw_handler.h |   11 +----------
 include/net/wext.h       |   24 ++++++++++++++++++++++++
 net/core/dev.c           |   34 ++++------------------------------
 net/wireless/wext.c      |   28 ++++++++++++++++++++++++----
 4 files changed, 53 insertions(+), 44 deletions(-)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6.22/include/net/wext.h	2007-04-24 18:51:23.568804911 +0200
@@ -0,0 +1,24 @@
+#ifndef __NET_WEXT_H
+#define __NET_WEXT_H
+
+/*
+ * wireless extensions interface to the core code
+ */
+
+#ifdef CONFIG_WIRELESS_EXT
+extern int wext_proc_init(void);
+extern int wext_handle_ioctl(struct ifreq *ifr, unsigned int cmd,
+			     void __user *arg);
+#else
+static inline int wext_proc_init()
+{
+	return 0;
+}
+static inline int wext_handle_ioctl(struct ifreq *ifr, unsigned int cmd,
+				    void __user *arg)
+{
+	return -EINVAL;
+}
+#endif
+
+#endif /* __NET_WEXT_H */
--- net-2.6.22.orig/net/core/dev.c	2007-04-24 18:50:45.888804911 +0200
+++ net-2.6.22/net/core/dev.c	2007-04-24 18:51:23.568804911 +0200
@@ -109,7 +109,7 @@
 #include <linux/netpoll.h>
 #include <linux/rcupdate.h>
 #include <linux/delay.h>
-#include <linux/wireless.h>
+#include <net/wext.h>
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
@@ -2348,12 +2348,6 @@ static const struct file_operations ptyp
 };
 
 
-#ifdef CONFIG_WIRELESS_EXT
-extern int wireless_proc_init(void);
-#else
-#define wireless_proc_init() 0
-#endif
-
 static int __init dev_proc_init(void)
 {
 	int rc = -ENOMEM;
@@ -2365,7 +2359,7 @@ static int __init dev_proc_init(void)
 	if (!proc_net_fops_create("ptype", S_IRUGO, &ptype_seq_fops))
 		goto out_dev2;
 
-	if (wireless_proc_init())
+	if (wext_proc_init())
 		goto out_softnet;
 	rc = 0;
 out:
@@ -2923,29 +2917,9 @@ int dev_ioctl(unsigned int cmd, void __u
 					ret = -EFAULT;
 				return ret;
 			}
-#ifdef CONFIG_WIRELESS_EXT
 			/* Take care of Wireless Extensions */
-			if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) {
-				/* If command is `set a parameter', or
-				 * `get the encoding parameters', check if
-				 * the user has the right to do it */
-				if (IW_IS_SET(cmd) || cmd == SIOCGIWENCODE
-				    || cmd == SIOCGIWENCODEEXT) {
-					if (!capable(CAP_NET_ADMIN))
-						return -EPERM;
-				}
-				dev_load(ifr.ifr_name);
-				rtnl_lock();
-				/* Follow me in net/wireless/wext.c */
-				ret = wireless_process_ioctl(&ifr, cmd);
-				rtnl_unlock();
-				if (IW_IS_GET(cmd) &&
-				    copy_to_user(arg, &ifr,
-						 sizeof(struct ifreq)))
-					ret = -EFAULT;
-				return ret;
-			}
-#endif	/* CONFIG_WIRELESS_EXT */
+			if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
+				return wext_handle_ioctl(&ifr, cmd, arg);
 			return -EINVAL;
 	}
 }
--- net-2.6.22.orig/include/net/iw_handler.h	2007-04-24 18:54:01.678804911 +0200
+++ net-2.6.22/include/net/iw_handler.h	2007-04-24 18:56:27.328804911 +0200
@@ -431,16 +431,7 @@ struct iw_public_data {
  * Those may be called only within the kernel.
  */
 
-/* First : function strictly used inside the kernel */
-
-/* Handle /proc/net/wireless, called in net/code/dev.c */
-extern int dev_get_wireless_info(char * buffer, char **start, off_t offset,
-				 int length);
-
-/* Handle IOCTLs, called in net/core/dev.c */
-extern int wireless_process_ioctl(struct ifreq *ifr, unsigned int cmd);
-
-/* Second : functions that may be called by driver modules */
+/* functions that may be called by driver modules */
 
 /* Send a single event to user space */
 extern void wireless_send_event(struct net_device *	dev,
--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 18:51:31.288804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 19:04:20.818804911 +0200
@@ -97,6 +97,7 @@
 #include <linux/wireless.h>		/* Pretty obvious */
 #include <net/iw_handler.h>		/* New driver API */
 #include <net/netlink.h>
+#include <net/wext.h>
 
 #include <asm/uaccess.h>		/* copy_to_user() */
 
@@ -696,7 +697,7 @@ static const struct file_operations wire
 	.release = seq_release,
 };
 
-int __init wireless_proc_init(void)
+int __init wext_proc_init(void)
 {
 	/* Create /proc/net/wireless entry */
 	if (!proc_net_fops_create("wireless", S_IRUGO, &wireless_seq_fops))
@@ -1075,11 +1076,10 @@ static inline int ioctl_private_call(str
 
 /* ---------------------------------------------------------------- */
 /*
- * Main IOCTl dispatcher. Called from the main networking code
- * (dev_ioctl() in net/core/dev.c).
+ * Main IOCTl dispatcher.
  * Check the type of IOCTL and call the appropriate wrapper...
  */
-int wireless_process_ioctl(struct ifreq *ifr, unsigned int cmd)
+static int wireless_process_ioctl(struct ifreq *ifr, unsigned int cmd)
 {
 	struct net_device *dev;
 	iw_handler	handler;
@@ -1143,6 +1143,26 @@ int wireless_process_ioctl(struct ifreq 
 	return -EINVAL;
 }
 
+/* entry point from dev ioctl */
+int wext_handle_ioctl(struct ifreq *ifr, unsigned int cmd,
+		      void __user *arg)
+{
+	int ret;
+
+	/* If command is `set a parameter', or
+	 * `get the encoding parameters', check if
+	 * the user has the right to do it */
+	if (IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	dev_load(ifr->ifr_name);
+	rtnl_lock();
+	ret = wireless_process_ioctl(ifr, cmd);
+	rtnl_unlock();
+	if (IW_IS_GET(cmd) && copy_to_user(arg, ifr, sizeof(struct ifreq)))
+		return -EFAULT;
+	return ret;
+}
 
 /************************* EVENT PROCESSING *************************/
 /*

--
