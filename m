From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: netdev hooks for 2.5.59 (2/8)
Date: Fri, 31 Jan 2003 09:51:54 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301310948350.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301310942430.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301310942430.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/netdevice.h |    4 ++++
 include/linux/security.h  |   38 +++++++++++++++++++++++++++++++++++---
 net/core/dev.c            |    3 +++
 security/dummy.c          |   12 ++++++++++++
 4 files changed, 54 insertions(+), 3 deletions(-)


diff -urN -X dontdiff linux-2.5.59.w0/include/linux/netdevice.h linux-2.5.59.w1/include/linux/netdevice.h
--- linux-2.5.59.w0/include/linux/netdevice.h	Fri Jan 17 19:46:08 2003
+++ linux-2.5.59.w1/include/linux/netdevice.h	Thu Jan 30 21:23:47 2003
@@ -442,6 +442,10 @@
 
 	/* generic object representation */
 	struct kobject kobj;
+
+#ifdef CONFIG_SECURITY_NETWORK
+	void                    *security;
+#endif
 };
 
 
diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 16 22:51:34 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:26:28 2003
@@ -63,9 +63,6 @@
 /* setfsuid or setfsgid, id0 == fsuid or fsgid */
 #define LSM_SETID_FS	8
 
-
-#ifdef CONFIG_SECURITY
-
 /* forward declares to avoid warnings */
 struct sk_buff;
 struct net_device;
@@ -73,6 +70,9 @@
 struct sched_param;
 struct swap_info_struct;
 
+
+#ifdef CONFIG_SECURITY
+
 /**
  * struct security_operations - main security structure
  *
@@ -586,6 +586,19 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
  *
+ * Security hooks for network devices.
+ * @netdev_unregister:
+ *	Update the module's state when a network device is unregistered,
+ *	deallocating the dev->security field if it was previously allocated.
+ *	@dev contains the network device
+ *
+ * These are the hooks for network device operations.  Since it would be quite
+ * invasive to provide hooks in every location where a network device might be
+ * probed or initialized, there are no separate hooks for allocation or
+ * initialization.  Security modules can allocate and initialize the
+ * dev->security field on the first access to the device, but should be careful
+ * to use nonblocking allocation.
+ *
  * Security hooks affecting all System V IPC operations.
  *
  * @ipc_permission:
@@ -952,6 +965,10 @@
 	                          struct security_operations *ops);
 	int (*unregister_security) (const char *name,
 	                            struct security_operations *ops);
+
+#ifdef CONFIG_SECURITY_NETWORK
+	void (*netdev_unregister) (struct net_device * dev);
+#endif	/* CONFIG_SECURITY_NETWORK */
 };
 
 /* global variables */
@@ -2106,5 +2123,20 @@
 
 #endif	/* CONFIG_SECURITY */
 
+#ifdef CONFIG_SECURITY_NETWORK
+
+static inline void security_netdev_unregister(struct net_device * dev)
+{
+	security_ops->netdev_unregister(dev);
+}
+
+#else	/* CONFIG_SECURITY_NETWORK */
+
+static inline void security_netdev_unregister(struct net_device * dev)
+{
+}
+
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff -urN -X dontdiff linux-2.5.59.w0/net/core/dev.c linux-2.5.59.w1/net/core/dev.c
--- linux-2.5.59.w0/net/core/dev.c	Fri Jan 17 19:46:08 2003
+++ linux-2.5.59.w1/net/core/dev.c	Thu Jan 30 21:23:47 2003
@@ -107,6 +107,7 @@
 #include <linux/kmod.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/security.h>
 #if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
 #include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
 #include <net/iw_handler.h>
@@ -2680,6 +2681,8 @@
 	free_divert_blk(dev);
 #endif
 
+	security_netdev_unregister(dev);
+
 	if (dev->features & NETIF_F_DYNALLOC) {
 #ifdef NET_REFCNT_DEBUG
 		if (atomic_read(&dev->refcnt) != 1)
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 16 22:51:35 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 21:23:47 2003
@@ -597,6 +597,15 @@
 	return 0;
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+
+static void dummy_netdev_unregister (struct net_device *dev)
+{
+	return;
+}
+
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 static int dummy_register_security (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -725,5 +734,8 @@
 	set_to_dummy_if_null(ops, sem_semop);
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
+#ifdef CONFIG_SECURITY_NETWORK
+	set_to_dummy_if_null(ops, netdev_unregister);
+#endif	/* CONFIG_SECURITY_NETWORK */
 }
 
