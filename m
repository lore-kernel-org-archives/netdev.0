From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] deprecate dev_get
Date: Mon, 15 Sep 2003 17:12:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915171230.68c08e26.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The interface dev_get has past it's usefulness.  I sent out patches
that remove the two other uses left of it in the 2.6 tree.

This marks it as deprecated because there still may be out of tree
drivers that use it.

diff -urN -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-net/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-09-05 09:36:05.000000000 -0700
+++ linux-2.5-net/include/linux/netdevice.h	2003-09-12 12:22:57.000000000 -0700
@@ -502,7 +502,11 @@
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
-extern int		dev_get(const char *name);
+extern int		__dev_get(const char *name);
+static inline int __deprecated dev_get(const char *name)
+{
+	return __dev_get(name);
+}
 extern struct net_device	*dev_get_by_flags(unsigned short flags,
 						  unsigned short mask);
 extern struct net_device	*__dev_get_by_flags(unsigned short flags,
diff -urN -X dontdiff linux-2.5/net/core/dev.c linux-2.5-net/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-09-12 11:44:40.000000000 -0700
+++ linux-2.5-net/net/core/dev.c	2003-09-12 12:38:48.000000000 -0700
@@ -470,10 +470,10 @@
  *	to be sure the name is not allocated or removed during the test the
  *	caller must hold the rtnl semaphore.
  *
- *	This function primarily exists for back compatibility with older
+ *	This function exists only for back compatibility with older
  *	drivers.
  */
-int dev_get(const char *name)
+int __dev_get(const char *name)
 {
 	struct net_device *dev;
 
@@ -698,7 +698,13 @@
 
 void dev_load(const char *name)
 {
-	if (!dev_get(name) && capable(CAP_SYS_MODULE))
+	struct net_device *dev;  
+
+	read_lock(&dev_base_lock);
+	dev = __dev_get_by_name(name);
+	read_unlock(&dev_base_lock);
+
+	if (dev && capable(CAP_SYS_MODULE))
 		request_module("%s", name);
 }
 
diff -urN -X dontdiff linux-2.5/net/netsyms.c linux-2.5-net/net/netsyms.c
--- linux-2.5/net/netsyms.c	2003-09-02 08:48:11.000000000 -0700
+++ linux-2.5-net/net/netsyms.c	2003-09-12 17:24:11.000000000 -0700
@@ -511,7 +511,7 @@
 EXPORT_SYMBOL(dev_add_pack);
 EXPORT_SYMBOL(dev_remove_pack);
 EXPORT_SYMBOL(__dev_remove_pack);
-EXPORT_SYMBOL(dev_get);
+EXPORT_SYMBOL(__dev_get);
 EXPORT_SYMBOL(dev_alloc);
 EXPORT_SYMBOL(dev_alloc_name);
 EXPORT_SYMBOL(__netdev_watchdog_up);
