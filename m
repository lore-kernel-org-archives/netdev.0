From: Patrick McHardy <kaber@trash.net>
Subject: net 02/04: rtnetlink: handle rtnl_link netlink notifications manually
Date: Fri, 26 Feb 2010 17:34:51 +0100 (MET)
Message-ID: <20100226163451.11434.92305.sendpatchset@x2.localnet>
References: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59364 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965054Ab0BZQew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:34:52 -0500
In-Reply-To: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d1a41c4805fd5850156668114d42d7a51964926a
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 24 13:52:52 2010 +0100

    net: rtnetlink: handle rtnl_link netlink notifications manually
    
    In order to support specifying device flags during device creation,
    we must be able to roll back device registration in case setting the
    flags fails without sending any notifications related to the device
    to userspace.
    
    This patch changes rollback_registered_many() and register_netdevice()
    to manually send netlink notifications for devices not handled by
    rtnl_link and allows to defer notifications for devices handled by
    rtnl_link until setup is complete.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 682d025..19af5fb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -924,7 +924,12 @@ struct net_device {
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
 	       NETREG_RELEASED,		/* called free_netdev */
 	       NETREG_DUMMY,		/* dummy device for NAPI poll */
-	} reg_state;
+	} reg_state:16;
+
+	enum {
+		RTNL_LINK_INITIALIZED,
+		RTNL_LINK_INITIALIZING,
+	} rtnl_link_state:16;
 
 	/* Called from unregister, can be used to call free_netdev */
 	void (*destructor)(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index eb7f1a4..75332b0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4865,6 +4865,10 @@ static void rollback_registered_many(struct list_head *head)
 		*/
 		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 
+		if (!dev->rtnl_link_ops ||
+		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
+			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+
 		/*
 		 *	Flush the unicast and multicast chains
 		 */
@@ -5091,7 +5095,9 @@ int register_netdevice(struct net_device *dev)
 	 *	Prevent userspace races by waiting until the network
 	 *	device is fully setup before sending notifications.
 	 */
-	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+	if (!dev->rtnl_link_ops ||
+	    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
+		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
 
 out:
 	return ret;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b7c7dfd..020e43b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1425,9 +1425,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	struct net_device *dev = ptr;
 
 	switch (event) {
-	case NETDEV_UNREGISTER:
-		rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
-		break;
 	case NETDEV_UP:
 	case NETDEV_DOWN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
@@ -1437,6 +1434,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
 	case NETDEV_GOING_DOWN:
+	case NETDEV_UNREGISTER:
 	case NETDEV_UNREGISTER_BATCH:
 		break;
 	default:
