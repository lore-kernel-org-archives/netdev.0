From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/4] net: Add IPv6 support to l3mdev
Date: Wed,  7 Oct 2015 09:50:37 -0700
Message-ID: <1444236640-2410-2-git-send-email-dsa@cumulusnetworks.com>
References: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34401 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbbJGQut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:50:49 -0400
Received: by padhy16 with SMTP id hy16so26348568pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:50:48 -0700 (PDT)
In-Reply-To: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add operations to retrieve cached IPv6 dst entry from l3mdev device
and lookup IPv6 source address.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 44a19a171104..f3c5e18b3170 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -19,14 +19,22 @@
  * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
  *
  * @l3mdev_get_saddr: Get source address for a flow
+ *
+ * @l3mdev_get_rt6_dst: Get cached IPv6 rt6_info (dst_entry) for device
  */
 
 struct l3mdev_ops {
 	u32		(*l3mdev_fib_table)(const struct net_device *dev);
+
+	/* IPv4 ops */
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
 					     const struct flowi4 *fl4);
 	void		(*l3mdev_get_saddr)(struct net_device *dev,
 					    struct flowi4 *fl4);
+
+	/* IPv6 ops */
+	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
+						 const struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -123,6 +131,32 @@ static inline void l3mdev_get_saddr(struct net *net, int ifindex,
 	}
 }
 
+static inline struct dst_entry *l3mdev_get_rt6_dst(const struct net_device *dev,
+						   const struct flowi6 *fl6)
+{
+	if (netif_is_l3_master(dev) && dev->l3mdev_ops->l3mdev_get_rt6_dst)
+		return dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
+
+	return NULL;
+}
+
+static inline
+struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
+					const struct flowi6 *fl6)
+{
+	struct dst_entry *dst = NULL;
+	struct net_device *dev;
+
+	dev = dev_get_by_index(net, fl6->flowi6_oif);
+	if (dev) {
+		if (netif_is_l3_master(dev))
+			dst = l3mdev_get_rt6_dst(dev, fl6);
+		dev_put(dev);
+	}
+
+	return dst;
+}
+
 #else
 
 static inline int l3mdev_master_ifindex_rcu(struct net_device *dev)
@@ -171,6 +205,19 @@ static inline void l3mdev_get_saddr(struct net *net, int ifindex,
 				    struct flowi4 *fl4)
 {
 }
+
+static inline
+struct dst_entry *l3mdev_get_rt6_dst(const struct net_device *dev,
+				     const struct flowi6 *fl6)
+{
+	return NULL;
+}
+static inline
+struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
+					const struct flowi6 *fl6)
+{
+	return NULL;
+}
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
-- 
1.9.1
