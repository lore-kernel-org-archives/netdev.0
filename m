From: Patrick McHardy <kaber@trash.net>
Subject: net 03/04: dev: support deferring device flag change notifications
Date: Fri, 26 Feb 2010 17:34:53 +0100 (MET)
Message-ID: <20100226163453.11434.59019.sendpatchset@x2.localnet>
References: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59366 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325Ab0BZQey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:34:54 -0500
In-Reply-To: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 18c626db4551a23d1f848adafad41e44388b6c2f
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 24 15:51:55 2010 +0100

    net: dev: support deferring device flag change notifications
    
    Split dev_change_flags() into two functions: __dev_change_flags() to
    perform the actual changes and __dev_notify_flags() to invoke netdevice
    notifiers. This will be used by rtnl_link to defer netlink notifications
    until the device has been fully configured.
    
    This changes ordering of some operations, in particular:
    
    - netlink notifications are sent after all changes have been performed.
      As a side effect this surpresses one unnecessary netlink message when
      the IFF_UP and other flags are changed simultaneously.
    
    - The NETDEV_UP/NETDEV_DOWN and NETDEV_CHANGE notifiers are invoked
      after all changes have been performed. Their relative is unchanged.
    
    - net_dmaengine_put() is invoked before the NETDEV_DOWN notifier instead
      of afterwards. This should not make any difference since both RX and TX
      are already shut down at this point.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 19af5fb..bab133d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1587,7 +1587,9 @@ extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
+extern int		__dev_change_flags(struct net_device *, unsigned int flags);
 extern int		dev_change_flags(struct net_device *, unsigned);
+extern void		__dev_notify_flags(struct net_device *, unsigned int old_flags);
 extern int		dev_change_name(struct net_device *, const char *);
 extern int		dev_set_alias(struct net_device *, const char *, size_t);
 extern int		dev_change_net_namespace(struct net_device *,
diff --git a/net/core/dev.c b/net/core/dev.c
index 75332b0..e5972f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1113,19 +1113,7 @@ void dev_load(struct net *net, const char *name)
 }
 EXPORT_SYMBOL(dev_load);
 
-/**
- *	dev_open	- prepare an interface for use.
- *	@dev:	device to open
- *
- *	Takes a device from down to up state. The device's private open
- *	function is invoked and then the multicast lists are loaded. Finally
- *	the device is moved into the up state and a %NETDEV_UP message is
- *	sent to the netdev notifier chain.
- *
- *	Calling this function on an active interface is a nop. On a failure
- *	a negative errno code is returned.
- */
-int dev_open(struct net_device *dev)
+static int __dev_open(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int ret;
@@ -1133,13 +1121,6 @@ int dev_open(struct net_device *dev)
 	ASSERT_RTNL();
 
 	/*
-	 *	Is it already up?
-	 */
-
-	if (dev->flags & IFF_UP)
-		return 0;
-
-	/*
 	 *	Is it even present?
 	 */
 	if (!netif_device_present(dev))
@@ -1187,36 +1168,57 @@ int dev_open(struct net_device *dev)
 		 *	Wakeup transmit queue engine
 		 */
 		dev_activate(dev);
-
-		/*
-		 *	... and announce new interface.
-		 */
-		call_netdevice_notifiers(NETDEV_UP, dev);
 	}
 
 	return ret;
 }
-EXPORT_SYMBOL(dev_open);
 
 /**
- *	dev_close - shutdown an interface.
- *	@dev: device to shutdown
+ *	dev_open	- prepare an interface for use.
+ *	@dev:	device to open
  *
- *	This function moves an active device into down state. A
- *	%NETDEV_GOING_DOWN is sent to the netdev notifier chain. The device
- *	is then deactivated and finally a %NETDEV_DOWN is sent to the notifier
- *	chain.
+ *	Takes a device from down to up state. The device's private open
+ *	function is invoked and then the multicast lists are loaded. Finally
+ *	the device is moved into the up state and a %NETDEV_UP message is
+ *	sent to the netdev notifier chain.
+ *
+ *	Calling this function on an active interface is a nop. On a failure
+ *	a negative errno code is returned.
  */
-int dev_close(struct net_device *dev)
+int dev_open(struct net_device *dev)
+{
+	int ret;
+
+	/*
+	 *	Is it already up?
+	 */
+	if (dev->flags & IFF_UP)
+		return 0;
+
+	/*
+	 *	Open device
+	 */
+	ret = __dev_open(dev);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 *	... and announce new interface.
+	 */
+	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+	call_netdevice_notifiers(NETDEV_UP, dev);
+
+	return ret;
+}
+EXPORT_SYMBOL(dev_open);
+
+static int __dev_close(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-	ASSERT_RTNL();
 
+	ASSERT_RTNL();
 	might_sleep();
 
-	if (!(dev->flags & IFF_UP))
-		return 0;
-
 	/*
 	 *	Tell people we are going down, so that they can
 	 *	prepare to death, when device is still operating.
@@ -1252,14 +1254,34 @@ int dev_close(struct net_device *dev)
 	dev->flags &= ~IFF_UP;
 
 	/*
-	 * Tell people we are down
+	 *	Shutdown NET_DMA
 	 */
-	call_netdevice_notifiers(NETDEV_DOWN, dev);
+	net_dmaengine_put();
+
+	return 0;
+}
+
+/**
+ *	dev_close - shutdown an interface.
+ *	@dev: device to shutdown
+ *
+ *	This function moves an active device into down state. A
+ *	%NETDEV_GOING_DOWN is sent to the netdev notifier chain. The device
+ *	is then deactivated and finally a %NETDEV_DOWN is sent to the notifier
+ *	chain.
+ */
+int dev_close(struct net_device *dev)
+{
+	if (!(dev->flags & IFF_UP))
+		return 0;
+
+	__dev_close(dev);
 
 	/*
-	 *	Shutdown NET_DMA
+	 * Tell people we are down
 	 */
-	net_dmaengine_put();
+	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+	call_netdevice_notifiers(NETDEV_DOWN, dev);
 
 	return 0;
 }
@@ -4299,18 +4321,10 @@ unsigned dev_get_flags(const struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_get_flags);
 
-/**
- *	dev_change_flags - change device settings
- *	@dev: device
- *	@flags: device state flags
- *
- *	Change settings on device based state flags. The flags are
- *	in the userspace exported format.
- */
-int dev_change_flags(struct net_device *dev, unsigned flags)
+int __dev_change_flags(struct net_device *dev, unsigned int flags)
 {
-	int ret, changes;
 	int old_flags = dev->flags;
+	int ret;
 
 	ASSERT_RTNL();
 
@@ -4341,17 +4355,12 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 
 	ret = 0;
 	if ((old_flags ^ flags) & IFF_UP) {	/* Bit is different  ? */
-		ret = ((old_flags & IFF_UP) ? dev_close : dev_open)(dev);
+		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
 
 		if (!ret)
 			dev_set_rx_mode(dev);
 	}
 
-	if (dev->flags & IFF_UP &&
-	    ((old_flags ^ dev->flags) & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
-					  IFF_VOLATILE)))
-		call_netdevice_notifiers(NETDEV_CHANGE, dev);
-
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
 		int inc = (flags & IFF_PROMISC) ? 1 : -1;
 
@@ -4370,11 +4379,47 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 		dev_set_allmulti(dev, inc);
 	}
 
-	/* Exclude state transition flags, already notified */
-	changes = (old_flags ^ dev->flags) & ~(IFF_UP | IFF_RUNNING);
+	return ret;
+}
+
+void __dev_notify_flags(struct net_device *dev, unsigned int old_flags)
+{
+	unsigned int changes = dev->flags ^ old_flags;
+
+	if (changes & IFF_UP) {
+		if (dev->flags & IFF_UP)
+			call_netdevice_notifiers(NETDEV_UP, dev);
+		else
+			call_netdevice_notifiers(NETDEV_DOWN, dev);
+	}
+
+	if (dev->flags & IFF_UP &&
+	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE)))
+		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+}
+
+/**
+ *	dev_change_flags - change device settings
+ *	@dev: device
+ *	@flags: device state flags
+ *
+ *	Change settings on device based state flags. The flags are
+ *	in the userspace exported format.
+ */
+int dev_change_flags(struct net_device *dev, unsigned flags)
+{
+	int ret, changes;
+	int old_flags = dev->flags;
+
+	ret = __dev_change_flags(dev, flags);
+	if (ret < 0)
+		return ret;
+
+	changes = old_flags ^ dev->flags;
 	if (changes)
 		rtmsg_ifinfo(RTM_NEWLINK, dev, changes);
 
+	__dev_notify_flags(dev, old_flags);
 	return ret;
 }
 EXPORT_SYMBOL(dev_change_flags);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 020e43b..c21ec42 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1427,8 +1427,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	switch (event) {
 	case NETDEV_UP:
 	case NETDEV_DOWN:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
-		break;
 	case NETDEV_PRE_UP:
 	case NETDEV_POST_INIT:
 	case NETDEV_REGISTER:
