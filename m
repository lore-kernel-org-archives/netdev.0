From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 1/4] l3mdev: ipv6 support
Date: Mon, 21 Sep 2015 16:32:55 -0700
Message-ID: <1442878378-13322-2-git-send-email-dsa@cumulusnetworks.com>
References: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33187 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536AbbIUXdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:33:15 -0400
Received: by pacex6 with SMTP id ex6so129824343pac.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 16:33:15 -0700 (PDT)
In-Reply-To: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add lookup of cached IPv6 route to l3mdev operations.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 8befd629f8ac..2ee593662ef4 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -19,12 +19,16 @@
  * @l3mdev_fib_table: Get FIB table id to use for lookups
  *
  * @l3dev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
+ *
+ * @l3dev_rt6_dst:    Get cached IPv6 rt6_info (dst_entry) for device
  */
 
 struct l3mdev_ops {
 	u32		(*l3mdev_fib_table)(const struct net_device *dev);
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
 					     const struct flowi4 *fl4);
+	struct dst_entry * (*l3mdev_rt6_dst)(const struct net_device *dev,
+					     const struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -84,6 +88,33 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
 	return NULL;
 }
 
+/* netif_is_l3_master already checked by caller */
+static inline struct dst_entry *l3mdev_rt6_dst(const struct net_device *dev,
+					       const struct flowi6 *fl6)
+{
+	if (dev->l3mdev_ops->l3mdev_rt6_dst)
+		return dev->l3mdev_ops->l3mdev_rt6_dst(dev, fl6);
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
+			dst = l3mdev_rt6_dst(dev, fl6);
+		dev_put(dev);
+	}
+
+	return dst;
+}
+
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	struct net_device *dev;
@@ -141,6 +172,18 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
 {
 	return NULL;
 }
+static inline
+struct dst_entry *l3mdev_rt6_dst(const struct net_device *dev,
+				 const struct flowi6 *fl6)
+{
+	return NULL;
+}
+static inline
+struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
+					const struct flowi6 *fl6)
+{
+	return NULL;
+}
 
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
-- 
1.9.1
