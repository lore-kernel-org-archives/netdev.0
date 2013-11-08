From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ipv4: fix wildcard search with inet_confirm_addr()
Date: Fri,  8 Nov 2013 15:37:08 +0100
Message-ID: <1383921428-4313-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34193 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab3KHOhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 09:37:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Help of this function says: "in_dev: only on this interface, 0=any interface",
but in fact the code supposes that it will never be NULL.

Note that this function was never called with in_dev == NULL, but it's exported
and may be used by an external module.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

This bug was spotted by code review.

 drivers/net/bonding/bonding.h | 10 +++-------
 include/linux/inetdevice.h    |  3 ++-
 net/ipv4/arp.c                |  3 ++-
 net/ipv4/devinet.c            |  8 ++++----
 4 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 03cf3fd14490..448895e90ccb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -407,15 +407,11 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
 
 static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
 {
-	struct in_device *in_dev;
-	__be32 addr = 0;
+	__be32 addr;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
-
-	if (in_dev)
-		addr = inet_confirm_addr(in_dev, dst, local, RT_SCOPE_HOST);
-
+	addr = inet_confirm_addr(dev_net(dev), __in_dev_get_rcu(dev), dst,
+				 local, RT_SCOPE_HOST);
 	rcu_read_unlock();
 	return addr;
 }
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 79640e015a86..5870f7060917 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -164,7 +164,8 @@ extern int		devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern void		devinet_init(void);
 extern struct in_device	*inetdev_by_index(struct net *, int);
 extern __be32		inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
-extern __be32		inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local, int scope);
+__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
+			 __be32 local, int scope);
 extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix, __be32 mask);
 
 static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7808093cede6..fc5ebc7e1962 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -408,7 +408,8 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 	default:
 		return 0;
 	}
-	return !inet_confirm_addr(in_dev, sip, tip, scope);
+	return !inet_confirm_addr(dev_net(in_dev->dev), in_dev, sip, tip,
+				  scope);
 }
 
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcbd04ae..47cdb035f817 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1236,22 +1236,22 @@ static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
 
 /*
  * Confirm that local IP address exists using wildcards:
+ * - net: netns to check, cannot be NULL
  * - in_dev: only on this interface, 0=any interface
  * - dst: only in the same subnet as dst, 0=any dst
  * - local: address, 0=autoselect the local address
  * - scope: maximum allowed scope value for the local address
  */
-__be32 inet_confirm_addr(struct in_device *in_dev,
+__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev,
 			 __be32 dst, __be32 local, int scope)
 {
 	__be32 addr = 0;
 	struct net_device *dev;
-	struct net *net;
 
 	if (scope != RT_SCOPE_LINK)
-		return confirm_addr_indev(in_dev, dst, local, scope);
+		return in_dev ? confirm_addr_indev(in_dev, dst, local, scope) :
+				0;
 
-	net = dev_net(in_dev->dev);
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
 		in_dev = __in_dev_get_rcu(dev);
-- 
1.8.4.1
