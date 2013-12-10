From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3] ipv4: fix wildcard search with inet_confirm_addr()
Date: Tue, 10 Dec 2013 15:02:40 +0100
Message-ID: <1386684160-4394-1-git-send-email-nicolas.dichtel@6wind.com>
References: <alpine.LFD.2.03.1311132244001.1712@ssi.bg>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45458 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab3LJOCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 09:02:48 -0500
In-Reply-To: <alpine.LFD.2.03.1311132244001.1712@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Help of this function says: "in_dev: only on this interface, 0=any interface",
but since commit 39a6d0630012 ("[NETNS]: Process inet_confirm_addr in the
correct namespace."), the code supposes that it will never be NULL. This
function is never called with in_dev == NULL, but it's exported and may be used
by an external module.

Because this patch restore the ability to call inet_confirm_addr() with in_dev
== NULL, I partially revert the above commit, as suggested by Julian.

CC: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reviewed-by: Julian Anastasov <ja@ssi.bg>
---

This was spotted by code review.

v3: rebase patch on net-next

v2: fix change in bond_confirm_addr()
    partially revert 39a6d0630012 ("[NETNS]: Process inet_confirm_addr in the
    correct namespace.")
    fix API desc of inet_confirm_addr()

 drivers/net/bonding/bonding.h | 4 ++--
 include/linux/inetdevice.h    | 5 ++---
 net/ipv4/arp.c                | 4 +++-
 net/ipv4/devinet.c            | 9 ++++-----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a9f4f9f4d8ce..a74c92c83ead 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -394,8 +394,8 @@ static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be3
 	in_dev = __in_dev_get_rcu(dev);
 
 	if (in_dev)
-		addr = inet_confirm_addr(in_dev, dst, local, RT_SCOPE_HOST);
-
+		addr = inet_confirm_addr(dev_net(dev), in_dev, dst, local,
+					 RT_SCOPE_HOST);
 	rcu_read_unlock();
 	return addr;
 }
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ae174ca565c9..72edb60e0072 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -164,11 +164,10 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 void devinet_init(void);
 struct in_device *inetdev_by_index(struct net *, int);
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
-__be32 inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local,
-			 int scope);
+__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
+			 __be32 local, int scope);
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 				    __be32 mask);
-
 static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f04185863940..b67cf805910e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -381,6 +381,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 {
+	struct net *net = dev_net(in_dev->dev);
 	int scope;
 
 	switch (IN_DEV_ARP_IGNORE(in_dev)) {
@@ -399,6 +400,7 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 	case 3:	/* Do not reply for scope host addresses */
 		sip = 0;
 		scope = RT_SCOPE_LINK;
+		in_dev = NULL;
 		break;
 	case 4:	/* Reserved */
 	case 5:
@@ -410,7 +412,7 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 	default:
 		return 0;
 	}
-	return !inet_confirm_addr(in_dev, sip, tip, scope);
+	return !inet_confirm_addr(net, in_dev, sip, tip, scope);
 }
 
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 43065be36301..7316ad1dfda5 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1238,22 +1238,21 @@ static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
 
 /*
  * Confirm that local IP address exists using wildcards:
- * - in_dev: only on this interface, 0=any interface
+ * - net: netns to check, cannot be NULL
+ * - in_dev: only on this interface, NULL=any interface
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
 
-	if (scope != RT_SCOPE_LINK)
+	if (in_dev != NULL)
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
-	net = dev_net(in_dev->dev);
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
 		in_dev = __in_dev_get_rcu(dev);
-- 
1.8.4.1
