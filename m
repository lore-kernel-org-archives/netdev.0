From: Patrick McHardy <kaber@trash.net>
Subject: [NET 01/05]: Add net_device change_rx_mode callback
Date: Thu, 12 Jul 2007 20:13:40 +0200 (MEST)
Message-ID: <20070712181340.13849.14304.sendpatchset@localhost.localdomain>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54180 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbXGLSNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:42 -0400
In-Reply-To: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Add net_device change_rx_mode callback

Currently the set_multicast_list (and set_rx_mode) callbacks are
responsible for configuring the device according to the IFF_PROMISC,
IFF_MULTICAST and IFF_ALLMULTI flags and the mc_list (and uc_list in
case of set_rx_mode).

These callbacks can be invoked from BH context without the rtnl_mutex
by dev_mc_add/dev_mc_delete, which makes reading the device flags and
promiscous/allmulti count racy. For real hardware drivers that just
commit all changes to the hardware this is not a real problem since
the stack guarantees to call them for every change, so at least the
final call will not race and commit the correct configuration to the
hardware.

For software devices that want to synchronize promiscous and multicast
state to an underlying device however this can cause corruption of the
underlying device's flags or promisc/allmulti counts.

When the software device is concurrently put in promiscous or allmulti
mode while set_multicast_list is invoked from bottem half context, the
device might synchronize the change to the underlying device without
holding the rtnl_mutex, which races with concurrent changes to the
underlying device.

Add a dev->change_rx_flags hook that is invoked when any of the flags
that affect rx filtering change (under the rtnl_mutex), which allows
drivers to perform synchronization immediately and only synchronize
the address lists in set_multicast_list/set_rx_mode.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b977db07766ffb261d2c7ebe050cbc3b1d7d281a
tree 1497ca885659afdde8ea81ea7d1534de28a773d3
parent 15028aad00ddf241581fbe74a02ec89cbb28d35d
author Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:53:55 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:53:55 +0200

 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   17 ++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 79cc3da..f193aba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -516,6 +516,9 @@ struct net_device
 						void *saddr,
 						unsigned len);
 	int			(*rebuild_header)(struct sk_buff *skb);
+#define HAVE_CHANGE_RX_FLAGS
+	void			(*change_rx_flags)(struct net_device *dev,
+						   int flags);
 #define HAVE_SET_RX_MODE
 	void			(*set_rx_mode)(struct net_device *dev);
 #define HAVE_MULTICAST			 
diff --git a/net/core/dev.c b/net/core/dev.c
index 4221dcd..cb055e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2507,6 +2507,8 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
 
+	ASSERT_RTNL();
+
 	if ((dev->promiscuity += inc) == 0)
 		dev->flags &= ~IFF_PROMISC;
 	else
@@ -2521,6 +2523,9 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
 			dev->name, (dev->flags & IFF_PROMISC),
 			(old_flags & IFF_PROMISC),
 			audit_get_loginuid(current->audit_context));
+
+		if (dev->change_rx_flags)
+			dev->change_rx_flags(dev, IFF_PROMISC);
 	}
 }
 
@@ -2559,11 +2564,16 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
 
+	ASSERT_RTNL();
+
 	dev->flags |= IFF_ALLMULTI;
 	if ((dev->allmulti += inc) == 0)
 		dev->flags &= ~IFF_ALLMULTI;
-	if (dev->flags ^ old_flags)
+	if (dev->flags ^ old_flags) {
+		if (dev->change_rx_flags)
+			dev->change_rx_flags(dev, IFF_ALLMULTI);
 		dev_set_rx_mode(dev);
+	}
 }
 
 /*
@@ -2764,6 +2774,8 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	int ret, changes;
 	int old_flags = dev->flags;
 
+	ASSERT_RTNL();
+
 	/*
 	 *	Set the flags on our device.
 	 */
@@ -2778,6 +2790,9 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	 *	Load in the correct multicast list now the flags have changed.
 	 */
 
+	if (dev->change_rx_flags && (dev->flags ^ flags) & IFF_MULTICAST)
+		dev->change_rx_flags(dev, IFF_MULTICAST);
+
 	dev_set_rx_mode(dev);
 
 	/*
