From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 10/11] net: l3mdev: remove get_rtable method
Date: Sat, 10 Sep 2016 12:10:01 -0700
Message-ID: <1473534602-23602-11-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34723 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbcIJTLe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:34 -0400
Received: by mail-pf0-f174.google.com with SMTP id p64so39774868pfb.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:34 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 21 ---------------------
 include/net/l3mdev.h | 21 ---------------------
 2 files changed, 42 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 3a34f547c578..ccce59fbb2b3 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -843,26 +843,6 @@ static u32 vrf_fib_table(const struct net_device *dev)
 	return vrf->tb_id;
 }
 
-static struct rtable *vrf_get_rtable(const struct net_device *dev,
-				     const struct flowi4 *fl4)
-{
-	struct rtable *rth = NULL;
-
-	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-		struct net_vrf *vrf = netdev_priv(dev);
-
-		rcu_read_lock();
-
-		rth = rcu_dereference(vrf->rth);
-		if (likely(rth))
-			dst_hold(&rth->dst);
-
-		rcu_read_unlock();
-	}
-
-	return rth;
-}
-
 static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return 0;
@@ -1088,7 +1068,6 @@ static struct dst_entry *vrf_link_scope_lookup(const struct net_device *dev,
 
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
-	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index a586035c97cb..3832099289c5 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -23,8 +23,6 @@
  *
  * @l3mdev_l3_out:    Hook in L3 output path
  *
- * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
- *
  * @l3mdev_link_scope_lookup: IPv6 lookup for linklocal and mcast destinations
  */
 
@@ -36,10 +34,6 @@ struct l3mdev_ops {
 					  struct sock *sk, struct sk_buff *skb,
 					  u16 proto);
 
-	/* IPv4 ops */
-	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
-					     const struct flowi4 *fl4);
-
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_link_scope_lookup)(const struct net_device *dev,
 						 struct flowi6 *fl6);
@@ -120,15 +114,6 @@ static inline u32 l3mdev_fib_table(const struct net_device *dev)
 	return tb_id;
 }
 
-static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
-					       const struct flowi4 *fl4)
-{
-	if (netif_is_l3_master(dev) && dev->l3mdev_ops->l3mdev_get_rtable)
-		return dev->l3mdev_ops->l3mdev_get_rtable(dev, fl4);
-
-	return NULL;
-}
-
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	struct net_device *dev;
@@ -241,12 +226,6 @@ static inline u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 	return 0;
 }
 
-static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
-					       const struct flowi4 *fl4)
-{
-	return NULL;
-}
-
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	return false;
-- 
2.1.4
