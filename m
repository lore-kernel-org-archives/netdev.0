From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 10/10] netdev: update comments and explain idempotency and rtnl locking
Date: Mon, 11 Jan 2016 13:17:31 +0100
Message-ID: <1452514651-15445-11-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43732 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932849AbcAKMRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:48 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A19DA20915
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:47 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8a2456498a6c9f..ff8b4795663d33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1006,31 +1006,36 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	not implement this, it is assumed that the hw is not able to have
  *	multiple net devices on single physical port.
  *
+ *	*** Offloading callbacks: ***
+ *
+ *	Notify drivers about a new type of offloading being requested
+ *	or removed from the driver. The type is based on the function
+ *	name, sa_family distinguishes between ipv4 and ipv6 and the
+ *	corresponding port number (for now only being UDP tunnel
+ *	protocol numbers) is signaled down to the driver.
+ *
+ *	Calls into the offloading callback functions are always done
+ *	with rtnl_lock held.
+ *
+ *	Further more, the callbacks can happen multiple times for the
+ *	same primitive to be installed, so it is forbidden to use
+ *	reference counting on the {offload_type, sa_family, port}
+ *	tuple because the driver might see multiple calls to those
+ *	functions for one installed primitive.
+ *
+ *	If the driver wants to get the current ports reprogrammed it
+ *	can simply call netdev_refresh_offloads with rtnl_lock held.
+ *
  * void (*ndo_add_vxlan_port)(struct  net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notiy a driver about the UDP port and socket
- *	address family that vxlan is listnening to. It is called only when
- *	a new port starts listening. The operation is protected by the
- *	vxlan_net->sock_lock.
- *
  * void (*ndo_add_geneve_port)(struct net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
- *	Called by geneve to notify a driver about the UDP port and socket
- *	address family that geneve is listnening to. It is called only when
- *	a new port starts listening. The operation is protected by the
- *	geneve_net->sock_lock.
- *
  * void (*ndo_del_geneve_port)(struct net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
- *	Called by geneve to notify the driver about a UDP port and socket
- *	address family that geneve is not listening to anymore. The operation
- *	is protected by the geneve_net->sock_lock.
- *
  * void (*ndo_del_vxlan_port)(struct  net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notify the driver about a UDP port and socket
- *	address family that vxlan is not listening to anymore. The operation
- *	is protected by the vxlan_net->sock_lock.
+ *
+ *
  *
  * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
  *				 struct net_device *dev)
@@ -2226,6 +2231,7 @@ netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
+/* Obviously the driver needs to hold rtnl_lock while calling this function. */
 static inline void netdev_refresh_offloads(struct net_device *netdev)
 {
 	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
-- 
2.5.0
