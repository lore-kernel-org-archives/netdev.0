From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/13] net: l3mdev: Propagate route lookup flags for IPv6
Date: Wed,  4 May 2016 20:33:26 -0700
Message-ID: <1462419210-10463-10-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35505 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980AbcEEDeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:19 -0400
Received: by mail-pa0-f54.google.com with SMTP id iv1so31013536pac.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:19 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6f21c96a78b8 ("ipv6: enforce flowi6_oif usage in
ip6_dst_lookup_tail") converted ip6_route_output to ip6_route_output_flags
which takes a flags input parameter. That arg should be passed to
l3mdev_get_rt6_dst for it to use in lookups as well. Needed by the
next patch

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 2 +-
 include/net/l3mdev.h | 9 ++++++---
 net/ipv6/route.c     | 2 +-
 net/l3mdev/l3mdev.c  | 6 ++++--
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7a533607a08c..1389cd6008f7 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -779,7 +779,7 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
-					 const struct flowi6 *fl6)
+					 const struct flowi6 *fl6, int flags)
 {
 	struct rt6_info *rt = NULL;
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 46ac4c69c155..0b38f58b6798 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -36,7 +36,8 @@ struct l3mdev_ops {
 
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
-						 const struct flowi6 *fl6);
+						 const struct flowi6 *fl6,
+						 int flags);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -134,7 +135,8 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 
 int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6);
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6,
+				     int flags);
 
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
@@ -221,7 +223,8 @@ static inline int l3mdev_get_saddr(struct net *net, int ifindex,
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6)
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6,
+				     int flags)
 {
 	return NULL;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c42fa1deb152..c585323503f1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1190,7 +1190,7 @@ struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
 	struct dst_entry *dst;
 	bool any_src;
 
-	dst = l3mdev_get_rt6_dst(net, fl6);
+	dst = l3mdev_get_rt6_dst(net, fl6, flags);
 	if (dst)
 		return dst;
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 0fd8cc1417cd..fbf16c487d8b 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -107,7 +107,8 @@ EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
  */
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
-				     const struct flowi6 *fl6)
+				     const struct flowi6 *fl6,
+				     int flags)
 {
 	struct dst_entry *dst = NULL;
 	struct net_device *dev;
@@ -121,7 +122,8 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
 
 		if (dev && netif_is_l3_master(dev) &&
 		    dev->l3mdev_ops->l3mdev_get_rt6_dst) {
-			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
+			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6,
+								  flags);
 		}
 
 		rcu_read_unlock();
-- 
2.1.4
