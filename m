From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 10/12] net: remove iflink field from struct net_device
Date: Thu,  2 Apr 2015 17:07:09 +0200
Message-ID: <1427987231-3669-11-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56629 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbbDBPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:26 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all users of iflink have the ndo_get_iflink handler available, it's
possible to remove this field.

By default, dev_get_iflink() returns the ifindex of the interface.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netdevice.h |  3 +--
 net/core/dev.c            | 13 ++-----------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 788eb7a622ad..846a1f5bc9db 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1538,7 +1538,7 @@ struct net_device {
 	netdev_features_t	mpls_features;
 
 	int			ifindex;
-	int			iflink;
+	int			group;
 
 	struct net_device_stats	stats;
 
@@ -1741,7 +1741,6 @@ struct net_device {
 #endif
 	struct phy_device *phydev;
 	struct lock_class_key *qdisc_tx_busylock;
-	int group;
 	struct pm_qos_request	pm_qos_req;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index 77172d085760..3be107e0bc93 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -672,7 +672,7 @@ int dev_get_iflink(const struct net_device *dev)
 	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
 		return dev->netdev_ops->ndo_get_iflink(dev);
 
-	return dev->iflink;
+	return dev->ifindex;
 }
 EXPORT_SYMBOL(dev_get_iflink);
 
@@ -6331,8 +6331,6 @@ int register_netdevice(struct net_device *dev)
 	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
 
-	dev->iflink = -1;
-
 	ret = dev_get_valid_name(net, dev, dev->name);
 	if (ret < 0)
 		goto out;
@@ -6362,9 +6360,6 @@ int register_netdevice(struct net_device *dev)
 	else if (__dev_get_by_index(net, dev->ifindex))
 		goto err_uninit;
 
-	if (dev_get_iflink(dev) == -1)
-		dev->iflink = dev->ifindex;
-
 	/* Transfer changeable features to wanted_features and enable
 	 * software offloads (GSO and GRO).
 	 */
@@ -7077,12 +7072,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_net_set(dev, net);
 
 	/* If there is an ifindex conflict assign a new one */
-	if (__dev_get_by_index(net, dev->ifindex)) {
-		int iflink = (dev_get_iflink(dev) == dev->ifindex);
+	if (__dev_get_by_index(net, dev->ifindex))
 		dev->ifindex = dev_new_index(net);
-		if (iflink)
-			dev->iflink = dev->ifindex;
-	}
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
-- 
2.2.2
