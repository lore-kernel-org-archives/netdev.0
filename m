From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: netdevice hooks for 2.5.42 (1/7)
Date: Wed, 16 Oct 2002 00:34:31 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160026270.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.orig/include/linux/netdevice.h linux-2.5.42.w1/include/linux/netdevice.h
--- linux-2.5.42.orig/include/linux/netdevice.h	Wed Oct  9 22:39:39 2002
+++ linux-2.5.42.w1/include/linux/netdevice.h	Tue Oct 15 20:19:42 2002
@@ -437,6 +437,7 @@
 	/* this will get initialized at each interface type init routine */
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
+	void			*security;
 };
 
 
diff -urN -X dontdiff linux-2.5.42.orig/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.orig/include/linux/security.h	Sat Oct 12 15:09:43 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 20:19:42 2002
@@ -616,6 +616,20 @@
  *	deallocate security struct for this semaphore
  *	@sma contains the semaphore structure.
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
+ *
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -830,6 +844,8 @@
 	void (*task_kmod_set_label) (void);
 	void (*task_reparent_to_init) (struct task_struct * p);
 
+	void (*netdev_unregister) (struct net_device * dev);
+	
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.orig/net/core/dev.c linux-2.5.42.w1/net/core/dev.c
--- linux-2.5.42.orig/net/core/dev.c	Wed Oct  9 22:39:39 2002
+++ linux-2.5.42.w1/net/core/dev.c	Tue Oct 15 20:19:42 2002
@@ -105,6 +105,7 @@
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/module.h>
+#include <linux/security.h>
 #if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
 #include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
 #include <net/iw_handler.h>
@@ -2592,6 +2593,8 @@
 	free_divert_blk(dev);
 #endif
 
+	security_ops->netdev_unregister(dev);
+
 	if (dev->features & NETIF_F_DYNALLOC) {
 #ifdef NET_REFCNT_DEBUG
 		if (atomic_read(&dev->refcnt) != 1)
diff -urN -X dontdiff linux-2.5.42.orig/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.orig/security/capability.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 20:19:42 2002
@@ -714,6 +714,11 @@
 	return;
 }
 
+static void cap_netdev_unregister (struct net_device *dev)
+{
+	return;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -828,6 +833,8 @@
 	.sem_alloc_security =		cap_sem_alloc_security,
 	.sem_free_security =		cap_sem_free_security,
 
+	.netdev_unregister =		cap_netdev_unregister,
+	
 	.register_security =		cap_register,
 	.unregister_security =		cap_unregister,
 };
diff -urN -X dontdiff linux-2.5.42.orig/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.orig/security/dummy.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 20:19:42 2002
@@ -529,6 +529,11 @@
 	return;
 }
 
+static void dummy_netdev_unregister (struct net_device *dev)
+{
+	return;
+}
+
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -643,6 +648,8 @@
 	.sem_alloc_security =		dummy_sem_alloc_security,
 	.sem_free_security =		dummy_sem_free_security,
 
+	.netdev_unregister =		dummy_netdev_unregister,
+	
 	.register_security =		dummy_register,
 	.unregister_security =		dummy_unregister,
 };
