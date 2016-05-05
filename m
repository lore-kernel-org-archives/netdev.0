From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 02/13] net: l3mdev: Move get_saddr and rt6_dst
Date: Wed,  4 May 2016 20:33:19 -0700
Message-ID: <1462419210-10463-3-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36165 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbcEEDeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:10 -0400
Received: by mail-pf0-f178.google.com with SMTP id c189so33687391pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:09 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move l3mdev_rt6_dst_by_oif and l3mdev_get_saddr to l3mdev.c. Collapse
l3mdev_get_rt6_dst into l3mdev_rt6_dst_by_oif since it is the only
user and keep the l3mdev_get_rt6_dst name for consistency with other
hooks.

A follow-on patch adds more code to these functions making them long
for inlined functions.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 56 +++-------------------------------------------------
 net/ipv6/route.c     |  2 +-
 net/l3mdev/l3mdev.c  | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 54 deletions(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index c43a9c73de5e..78872bd1dc2c 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -130,52 +130,9 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return rc;
 }
 
-static inline int l3mdev_get_saddr(struct net *net, int ifindex,
-				   struct flowi4 *fl4)
-{
-	struct net_device *dev;
-	int rc = 0;
-
-	if (ifindex) {
-
-		rcu_read_lock();
-
-		dev = dev_get_by_index_rcu(net, ifindex);
-		if (dev && netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_saddr) {
-			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
-		}
-
-		rcu_read_unlock();
-	}
-
-	return rc;
-}
+int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
-static inline struct dst_entry *l3mdev_get_rt6_dst(const struct net_device *dev,
-						   const struct flowi6 *fl6)
-{
-	if (netif_is_l3_master(dev) && dev->l3mdev_ops->l3mdev_get_rt6_dst)
-		return dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
-
-	return NULL;
-}
-
-static inline
-struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
-					const struct flowi6 *fl6)
-{
-	struct dst_entry *dst = NULL;
-	struct net_device *dev;
-
-	dev = dev_get_by_index(net, fl6->flowi6_oif);
-	if (dev) {
-		dst = l3mdev_get_rt6_dst(dev, fl6);
-		dev_put(dev);
-	}
-
-	return dst;
-}
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6);
 
 #else
 
@@ -233,14 +190,7 @@ static inline int l3mdev_get_saddr(struct net *net, int ifindex,
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(const struct net_device *dev,
-				     const struct flowi6 *fl6)
-{
-	return NULL;
-}
-static inline
-struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
-					const struct flowi6 *fl6)
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6)
 {
 	return NULL;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index af46e19205f5..c42fa1deb152 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1190,7 +1190,7 @@ struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
 	struct dst_entry *dst;
 	bool any_src;
 
-	dst = l3mdev_rt6_dst_by_oif(net, fl6);
+	dst = l3mdev_get_rt6_dst(net, fl6);
 	if (dst)
 		return dst;
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index e925037fa0df..0fe4211e646f 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -97,3 +97,58 @@ u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 	return tb_id;
 }
 EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
+
+/**
+ *	l3mdev_get_rt6_dst - IPv6 route lookup based on flow. Returns
+ *			     cached route for L3 master device if relevant
+ *			     to flow
+ *	@net: network namespace for device index lookup
+ *	@fl6: IPv6 flow struct for lookup
+ */
+
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
+				     const struct flowi6 *fl6)
+{
+	struct dst_entry *dst = NULL;
+	struct net_device *dev;
+
+	dev = dev_get_by_index(net, fl6->flowi6_oif);
+	if (dev) {
+		if (netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_rt6_dst)
+			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
+		dev_put(dev);
+	}
+
+	return dst;
+}
+EXPORT_SYMBOL_GPL(l3mdev_get_rt6_dst);
+
+/**
+ *	l3mdev_get_saddr - get source address for a flow based on an interface
+ *			   enslaved to an L3 master device
+ *	@net: network namespace for device index lookup
+ *	@ifindex: Interface index
+ *	@fl4: IPv4 flow struct
+ */
+
+int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
+{
+	struct net_device *dev;
+	int rc = 0;
+
+	if (ifindex) {
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, ifindex);
+		if (dev && netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_saddr) {
+			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
+		}
+
+		rcu_read_unlock();
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(l3mdev_get_saddr);
-- 
2.1.4
