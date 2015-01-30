From: Fan Du <fan.du@intel.com>
Subject: [PATCH] net: restore lro after device leave forwarding state
Date: Fri, 30 Jan 2015 07:33:29 -0500
Message-ID: <1422621209-23222-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29749 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbbA3Ekv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 23:40:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Either detaching a device from bridge or switching a device
out of FORWARDING state, the original lro feature should
possibly be enabled for good reason, e.g. hw feature like
receive side coalescing could come into play.

BEFORE:
echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k ens806f0 | grep large
large-receive-offload: off

echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k ens806f0 | grep large
large-receive-offload: off

AFTER:
echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k ens806f0 | grep large
large-receive-offload: off

echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k ens806f0 | grep large
large-receive-offload: on

Signed-off-by: Fan Du <fan.du@intel.com>
Fixes: 0187bdfb0567 ("net: Disable LRO on devices that are forwarding")
---
 include/linux/netdevice.h |  1 +
 net/bridge/br_if.c        |  1 +
 net/core/dev.c            | 24 ++++++++++++++++++++++++
 net/ipv4/devinet.c        |  4 ++++
 net/ipv6/addrconf.c       |  2 ++
 5 files changed, 32 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426..904b1a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2153,6 +2153,7 @@ int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
 void dev_disable_lro(struct net_device *dev);
+void dev_enable_lro(struct net_device *dev);
 int dev_loopback_xmit(struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 81e49fb..4236f3a 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -565,6 +565,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
 
 	netdev_update_features(br->dev);
+	dev_enable_lro(dev);
 
 	return 0;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e325ad..938d7f6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1451,6 +1451,30 @@ void dev_disable_lro(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_disable_lro);
 
+/**
+ *	dev_enable_lro - enable Large Receive Offload on a device
+ *	@dev: device
+ *
+ *	Enable Large Receive Offload (LRO) on a net device.  Must be
+ *	called under RTNL. This is needed if device is not attached
+ *	to a bridge, or user change the forwarding state.
+ */
+void dev_enable_lro(struct net_device *dev)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	dev->wanted_features |= NETIF_F_LRO;
+	netdev_update_features(dev);
+
+	if (unlikely(!(dev->features & NETIF_F_LRO)))
+		netdev_WARN(dev, "failed to enable LRO!\n");
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter)
+		dev_enable_lro(lower_dev);
+}
+EXPORT_SYMBOL(dev_enable_lro);
+
 static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
 				   struct net_device *dev)
 {
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 214882e..3307196 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1956,6 +1956,8 @@ static void inet_forward_change(struct net *net)
 		struct in_device *in_dev;
 		if (on)
 			dev_disable_lro(dev);
+		else
+			dev_enable_lro(dev);
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev) {
@@ -2047,6 +2049,8 @@ static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 					container_of(cnf, struct in_device, cnf);
 				if (*valp)
 					dev_disable_lro(idev->dev);
+				else
+					dev_enable_lro(idev->dev);
 				inet_netconf_notify_devconf(net,
 							    NETCONFA_FORWARDING,
 							    idev->dev->ifindex,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbe..4c3b54c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -669,6 +669,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 	dev = idev->dev;
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
+	else
+		dev_enable_lro(dev);
 	if (dev->flags & IFF_MULTICAST) {
 		if (idev->cnf.forwarding) {
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
-- 
1.8.3.1
