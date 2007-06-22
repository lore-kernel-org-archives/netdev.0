From: Patrick McHardy <kaber@trash.net>
Subject: [NET 04/05]: dev: secondary unicast address support
Date: Fri, 22 Jun 2007 14:24:12 +0200 (MEST)
Message-ID: <20070622122336.15215.95560.sendpatchset@localhost.localdomain>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbXFVMYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:24:23 -0400
In-Reply-To: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: dev: secondary unicast address support

Add support for configuring secondary unicast addresses on network
devices. To support this devices capable of filtering multiple
unicast addresses need to change their set_multicast_list function
to configure unicast filters as well and assign it to dev->set_rx_mode
instead of dev->set_multicast_list. Other devices are put into promiscous
mode when secondary unicast addresses are present.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 099e4ab74adb9418155132b093533f152a31b583
tree 7c8f52672f7b6e1323a479545225d88a2eb35670
parent 02536a101d6fd8b1924b1e05c44409c7b4568335
author Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 14:13:46 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 14:13:46 +0200

 include/linux/netdevice.h |   12 +++-
 net/core/dev.c            |  144 ++++++++++++++++++++++++++++++++++++++++-----
 net/core/dev_mcast.c      |   37 +-----------
 3 files changed, 139 insertions(+), 54 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b2db124..46585dc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -393,6 +393,9 @@ struct net_device
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
+	struct dev_addr_list	*uc_list;	/* Secondary unicast mac addresses */
+	int			uc_count;	/* Number of installed ucasts	*/
+	int			uc_promisc;
 	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
 	int			promiscuity;
@@ -498,6 +501,8 @@ struct net_device
 						void *saddr,
 						unsigned len);
 	int			(*rebuild_header)(struct sk_buff *skb);
+#define HAVE_SET_RX_MODE
+	void			(*set_rx_mode)(struct net_device *dev);
 #define HAVE_MULTICAST			 
 	void			(*set_multicast_list)(struct net_device *dev);
 #define HAVE_SET_MAC_ADDR  		 
@@ -1004,8 +1009,11 @@ extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
-/* Functions used for multicast support */
-extern void		dev_mc_upload(struct net_device *dev);
+/* Functions used for secondary unicast and multicast support */
+extern void		dev_set_rx_mode(struct net_device *dev);
+extern void		__dev_set_rx_mode(struct net_device *dev);
+extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
+extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern void		dev_mc_discard(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1496715..50a4e1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -942,7 +942,7 @@ int dev_open(struct net_device *dev)
 		/*
 		 *	Initialize multicasting status
 		 */
-		dev_mc_upload(dev);
+		dev_set_rx_mode(dev);
 
 		/*
 		 *	Wakeup transmit queue engine
@@ -2496,17 +2496,7 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	return 0;
 }
 
-/**
- *	dev_set_promiscuity	- update promiscuity count on a device
- *	@dev: device
- *	@inc: modifier
- *
- *	Add or remove promiscuity from a device. While the count in the device
- *	remains above zero the interface remains promiscuous. Once it hits zero
- *	the device reverts back to normal filtering operation. A negative inc
- *	value is used to drop promiscuity on the device.
- */
-void dev_set_promiscuity(struct net_device *dev, int inc)
+static void __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
 
@@ -2515,7 +2505,6 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
 	else
 		dev->flags |= IFF_PROMISC;
 	if (dev->flags != old_flags) {
-		dev_mc_upload(dev);
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
 							       "left");
@@ -2529,6 +2518,25 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
 }
 
 /**
+ *	dev_set_promiscuity	- update promiscuity count on a device
+ *	@dev: device
+ *	@inc: modifier
+ *
+ *	Add or remove promiscuity from a device. While the count in the device
+ *	remains above zero the interface remains promiscuous. Once it hits zero
+ *	the device reverts back to normal filtering operation. A negative inc
+ *	value is used to drop promiscuity on the device.
+ */
+void dev_set_promiscuity(struct net_device *dev, int inc)
+{
+	unsigned short old_flags = dev->flags;
+
+	__dev_set_promiscuity(dev, inc);
+	if (dev->flags != old_flags)
+		dev_set_rx_mode(dev);
+}
+
+/**
  *	dev_set_allmulti	- update allmulti count on a device
  *	@dev: device
  *	@inc: modifier
@@ -2548,7 +2556,48 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 	if ((dev->allmulti += inc) == 0)
 		dev->flags &= ~IFF_ALLMULTI;
 	if (dev->flags ^ old_flags)
-		dev_mc_upload(dev);
+		dev_set_rx_mode(dev);
+}
+
+/*
+ *	Upload unicast and multicast address lists to device and
+ *	configure RX filtering. When the device doesn't support unicast
+ *	filtering it is put in promiscous mode while unicast addresses
+ *	are present.
+ */
+void __dev_set_rx_mode(struct net_device *dev)
+{
+	/* dev_open will call this function so the list will stay sane. */
+	if (!(dev->flags&IFF_UP))
+		return;
+
+	if (!netif_device_present(dev))
+	        return;
+
+	if (dev->set_rx_mode)
+		dev->set_rx_mode(dev);
+	else {
+		/* Unicast addresses changes may only happen under the rtnl,
+		 * therefore calling __dev_set_promiscuity here is safe.
+		 */
+		if (dev->uc_count > 0 && !dev->uc_promisc) {
+			__dev_set_promiscuity(dev, 1);
+			dev->uc_promisc = 1;
+		} else if (dev->uc_count == 0 && dev->uc_promisc) {
+			__dev_set_promiscuity(dev, -1);
+			dev->uc_promisc = 0;
+		}
+
+		if (dev->set_multicast_list)
+			dev->set_multicast_list(dev);
+	}
+}
+
+void dev_set_rx_mode(struct net_device *dev)
+{
+	netif_tx_lock_bh(dev);
+	__dev_set_rx_mode(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 int __dev_addr_delete(struct dev_addr_list **list, void *addr, int alen,
@@ -2620,6 +2669,66 @@ void __dev_addr_discard(struct dev_addr_list **list)
 	}
 }
 
+/**
+ *	dev_unicast_delete	- Release secondary unicast address.
+ *	@dev: device
+ *
+ *	Release reference to a secondary unicast address and remove it
+ *	from the device if the reference count drop to zero.
+ *
+ * 	The caller must hold the rtnl_mutex.
+ */
+int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	netif_tx_lock_bh(dev);
+	err = __dev_addr_delete(&dev->uc_list, addr, alen, 0);
+	if (!err) {
+		dev->uc_count--;
+		__dev_set_rx_mode(dev);
+	}
+	netif_tx_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_unicast_delete);
+
+/**
+ *	dev_unicast_add		- add a secondary unicast address
+ *	@dev: device
+ *
+ *	Add a secondary unicast address to the device or increase
+ *	the reference count if it already exists.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_unicast_add(struct net_device *dev, void *addr, int alen)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	netif_tx_lock_bh(dev);
+	err = __dev_addr_add(&dev->uc_list, addr, alen, 0);
+	if (!err) {
+		dev->uc_count++;
+		__dev_set_rx_mode(dev);
+	}
+	netif_tx_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_unicast_add);
+
+static void dev_unicast_discard(struct net_device *dev)
+{
+	netif_tx_lock_bh(dev);
+	__dev_addr_discard(&dev->uc_list);
+	dev->uc_count = 0;
+	netif_tx_unlock_bh(dev);
+}
+
 unsigned dev_get_flags(const struct net_device *dev)
 {
 	unsigned flags;
@@ -2663,7 +2772,7 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	 *	Load in the correct multicast list now the flags have changed.
 	 */
 
-	dev_mc_upload(dev);
+	dev_set_rx_mode(dev);
 
 	/*
 	 *	Have we downed the interface. We handle IFF_UP ourselves
@@ -2676,7 +2785,7 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 		ret = ((old_flags & IFF_UP) ? dev_close : dev_open)(dev);
 
 		if (!ret)
-			dev_mc_upload(dev);
+			dev_set_rx_mode(dev);
 	}
 
 	if (dev->flags & IFF_UP &&
@@ -3540,8 +3649,9 @@ void unregister_netdevice(struct net_device *dev)
 	raw_notifier_call_chain(&netdev_chain, NETDEV_UNREGISTER, dev);
 
 	/*
-	 *	Flush the multicast chain
+	 *	Flush the unicast and multicast chains
 	 */
+	dev_unicast_discard(dev);
 	dev_mc_discard(dev);
 
 	if (dev->uninit)
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 7029074..5cc9b44 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -64,39 +64,6 @@
  */
 
 /*
- *	Update the multicast list into the physical NIC controller.
- */
-
-static void __dev_mc_upload(struct net_device *dev)
-{
-	/* Don't do anything till we up the interface
-	 * [dev_open will call this function so the list will
-	 * stay sane]
-	 */
-
-	if (!(dev->flags&IFF_UP))
-		return;
-
-	/*
-	 *	Devices with no set multicast or which have been
-	 *	detached don't get set.
-	 */
-
-	if (dev->set_multicast_list == NULL ||
-	    !netif_device_present(dev))
-		return;
-
-	dev->set_multicast_list(dev);
-}
-
-void dev_mc_upload(struct net_device *dev)
-{
-	netif_tx_lock_bh(dev);
-	__dev_mc_upload(dev);
-	netif_tx_unlock_bh(dev);
-}
-
-/*
  *	Delete a device level multicast
  */
 
@@ -114,7 +81,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 		 *	loaded filter is now wrong. Fix it
 		 */
 
-		__dev_mc_upload(dev);
+		__dev_set_rx_mode(dev);
 	}
 	netif_tx_unlock_bh(dev);
 	return err;
@@ -132,7 +99,7 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	err = __dev_addr_add(&dev->mc_list, addr, alen, glbl);
 	if (!err) {
 		dev->mc_count++;
-		__dev_mc_upload(dev);
+		__dev_set_rx_mode(dev);
 	}
 	netif_tx_unlock_bh(dev);
 	return err;
