From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] remove dead exports from net/core/dev.c
Date: Sat, 6 Nov 2004 18:43:07 +0100
Message-ID: <20041106174307.GA19806@lst.de>
References: <20041101114605.GA7507@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20041101114605.GA7507@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 12:46:05PM +0100, Christoph Hellwig wrote:
> this also allows to kill some competely dead code, e.g. many of the
> non-locked __foo routines.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

rediffed against current BK:

--- 1.91/include/linux/netdevice.h	2004-10-26 18:09:33 +02:00
+++ edited/include/linux/netdevice.h	2004-11-06 18:13:34 +01:00
@@ -526,20 +526,13 @@
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
-extern struct net_device *__dev_getfirstbyhwtype(unsigned short type);
 extern struct net_device *dev_getfirstbyhwtype(unsigned short type);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
-extern int		__dev_get(const char *name);
-static inline int __deprecated dev_get(const char *name)
-{
-	return __dev_get(name);
-}
+
 extern struct net_device	*dev_get_by_flags(unsigned short flags,
 						  unsigned short mask);
-extern struct net_device	*__dev_get_by_flags(unsigned short flags,
-						    unsigned short mask);
 extern struct net_device	*dev_get_by_name(const char *name);
 extern struct net_device	*__dev_get_by_name(const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
@@ -553,7 +546,6 @@
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
 extern int		call_netdevice_notifiers(unsigned long val, void *v);
-extern int		dev_new_index(void);
 extern struct net_device	*dev_get_by_index(int ifindex);
 extern struct net_device	*__dev_get_by_index(int ifindex);
 extern int		dev_restart(struct net_device *dev);
--- 1.173/net/core/dev.c	2004-11-04 00:55:02 +01:00
+++ edited/net/core/dev.c	2004-11-06 18:32:30 +01:00
@@ -520,35 +520,6 @@
 	return dev;
 }
 
-/*
-   Return value is changed to int to prevent illegal usage in future.
-   It is still legal to use to check for device existence.
-
-   User should understand, that the result returned by this function
-   is meaningless, if it was not issued under rtnl semaphore.
- */
-
-/**
- *	dev_get	-	test if a device exists
- *	@name:	name to test for
- *
- *	Test if a name exists. Returns true if the name is found. In order
- *	to be sure the name is not allocated or removed during the test the
- *	caller must hold the rtnl semaphore.
- *
- *	This function exists only for back compatibility with older
- *	drivers.
- */
-int __dev_get(const char *name)
-{
-	struct net_device *dev;
-
-	read_lock(&dev_base_lock);
-	dev = __dev_get_by_name(name);
-	read_unlock(&dev_base_lock);
-	return dev != NULL;
-}
-
 /**
  *	__dev_get_by_index - find a device by its ifindex
  *	@ifindex: index of device
@@ -623,26 +594,17 @@
 	return dev;
 }
 
-struct net_device *__dev_getfirstbyhwtype(unsigned short type)
-{
-	struct net_device *dev;
-
-	for (dev = dev_base; dev; dev = dev->next)
-		if (dev->type == type)
-			break;
-	return dev;
-}
-
-EXPORT_SYMBOL(__dev_getfirstbyhwtype);
-
 struct net_device *dev_getfirstbyhwtype(unsigned short type)
 {
 	struct net_device *dev;
 
 	rtnl_lock();
-	dev = __dev_getfirstbyhwtype(type);
-	if (dev)
-		dev_hold(dev);
+	for (dev = dev_base; dev; dev = dev->next) {
+		if (dev->type == type) {
+			dev_hold(dev);
+			break;
+		}
+	}
 	rtnl_unlock();
 	return dev;
 }
@@ -665,32 +627,14 @@
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	dev = __dev_get_by_flags(if_flags, mask);
-	if (dev)
-		dev_hold(dev);
-	read_unlock(&dev_base_lock);
-	return dev;
-}
-
-/**
- *	__dev_get_by_flags - find any device with given flags
- *	@if_flags: IFF_* values
- *	@mask: bitmask of bits in if_flags to check
- *
- *	Search for any interface with the given flags. Returns NULL if a device
- *	is not found or a pointer to the device. The caller must hold either
- *	the RTNL semaphore or @dev_base_lock.
- */
-
-struct net_device *__dev_get_by_flags(unsigned short if_flags, unsigned short mask)
-{
-	struct net_device *dev;
-
 	for (dev = dev_base; dev != NULL; dev = dev->next) {
-		if (((dev->flags ^ if_flags) & mask) == 0)
-			return dev;
+		if (((dev->flags ^ if_flags) & mask) == 0) {
+			dev_hold(dev);
+			break;
+		}
 	}
-	return NULL;
+	read_unlock(&dev_base_lock);
+	return dev;
 }
 
 /**
@@ -2700,7 +2644,7 @@
  *	number.  The caller must hold the rtnl semaphore or the
  *	dev_base_lock to be sure it remains unique.
  */
-int dev_new_index(void)
+static int dev_new_index(void)
 {
 	static int ifindex;
 	for (;;) {
@@ -3240,8 +3184,6 @@
 
 subsys_initcall(net_dev_init);
 
-EXPORT_SYMBOL(__dev_get);
-EXPORT_SYMBOL(__dev_get_by_flags);
 EXPORT_SYMBOL(__dev_get_by_index);
 EXPORT_SYMBOL(__dev_get_by_name);
 EXPORT_SYMBOL(__dev_remove_pack);
@@ -3252,17 +3194,13 @@
 EXPORT_SYMBOL(dev_get_by_flags);
 EXPORT_SYMBOL(dev_get_by_index);
 EXPORT_SYMBOL(dev_get_by_name);
-EXPORT_SYMBOL(dev_getbyhwaddr);
 EXPORT_SYMBOL(dev_ioctl);
-EXPORT_SYMBOL(dev_new_index);
 EXPORT_SYMBOL(dev_open);
 EXPORT_SYMBOL(dev_queue_xmit);
-EXPORT_SYMBOL(dev_queue_xmit_nit);
 EXPORT_SYMBOL(dev_remove_pack);
 EXPORT_SYMBOL(dev_set_allmulti);
 EXPORT_SYMBOL(dev_set_promiscuity);
 EXPORT_SYMBOL(dev_change_flags);
-EXPORT_SYMBOL(dev_change_name);
 EXPORT_SYMBOL(dev_set_mtu);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
