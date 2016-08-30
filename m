From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 08/12] net: ipv6: Remove l3mdev_get_saddr6
Date: Tue, 30 Aug 2016 10:34:13 -0700
Message-ID: <1472578457-26722-9-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33840 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932944AbcH3Rec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:32 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so10021931pfb.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:31 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer needed

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c     | 41 -----------------------------------------
 include/net/l3mdev.h  | 11 -----------
 net/ipv6/ip6_output.c |  9 +--------
 net/l3mdev/l3mdev.c   | 24 ------------------------
 4 files changed, 1 insertion(+), 84 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index ec65bf2afcb2..cc18319b4b0d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -909,46 +909,6 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 
 	return dst;
 }
-
-/* called under rcu_read_lock */
-static int vrf_get_saddr6(struct net_device *dev, const struct sock *sk,
-			  struct flowi6 *fl6)
-{
-	struct net *net = dev_net(dev);
-	struct dst_entry *dst;
-	struct rt6_info *rt;
-	int err;
-
-	if (rt6_need_strict(&fl6->daddr)) {
-		rt = vrf_ip6_route_lookup(net, dev, fl6, fl6->flowi6_oif,
-					  RT6_LOOKUP_F_IFACE);
-		if (unlikely(!rt))
-			return 0;
-
-		dst = &rt->dst;
-	} else {
-		__u8 flags = fl6->flowi6_flags;
-
-		fl6->flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
-		fl6->flowi6_flags |= FLOWI_FLAG_SKIP_NH_OIF;
-
-		dst = ip6_route_output(net, sk, fl6);
-		rt = (struct rt6_info *)dst;
-
-		fl6->flowi6_flags = flags;
-	}
-
-	err = dst->error;
-	if (!err) {
-		err = ip6_route_get_saddr(net, rt, &fl6->daddr,
-					  sk ? inet6_sk(sk)->srcprefs : 0,
-					  &fl6->saddr);
-	}
-
-	dst_release(dst);
-
-	return err;
-}
 #endif
 
 static const struct l3mdev_ops vrf_l3mdev_ops = {
@@ -958,7 +918,6 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
-	.l3mdev_get_saddr6	= vrf_get_saddr6,
 #endif
 };
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 8085be19a767..391c46130ef6 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -43,9 +43,6 @@ struct l3mdev_ops {
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
 						 struct flowi6 *fl6);
-	int		   (*l3mdev_get_saddr6)(struct net_device *dev,
-						const struct sock *sk,
-						struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -172,8 +169,6 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 }
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
-int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
-		      struct flowi6 *fl6);
 
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
@@ -291,12 +286,6 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
 	return NULL;
 }
 
-static inline int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
-				    struct flowi6 *fl6)
-{
-	return 0;
-}
-
 static inline
 struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84d1b3feaf2e..2d067b0c2f10 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -918,13 +918,6 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	int err;
 	int flags = 0;
 
-	if (ipv6_addr_any(&fl6->saddr) && fl6->flowi6_oif &&
-	    (!*dst || !(*dst)->error)) {
-		err = l3mdev_get_saddr6(net, sk, fl6);
-		if (err)
-			goto out_err;
-	}
-
 	/* The correct way to handle this would be to do
 	 * ip6_route_get_saddr, and then ip6_route_output; however,
 	 * the route-specific preferred source forces the
@@ -1016,7 +1009,7 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 out_err_release:
 	dst_release(*dst);
 	*dst = NULL;
-out_err:
+
 	if (err == -ENETUNREACH)
 		IP6_INC_STATS(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	return err;
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index b30034efccff..998e4dc2e6f9 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -131,30 +131,6 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
 }
 EXPORT_SYMBOL_GPL(l3mdev_get_rt6_dst);
 
-int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
-		      struct flowi6 *fl6)
-{
-	struct net_device *dev;
-	int rc = 0;
-
-	if (fl6->flowi6_oif) {
-		rcu_read_lock();
-
-		dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
-		if (dev && netif_is_l3_slave(dev))
-			dev = netdev_master_upper_dev_get_rcu(dev);
-
-		if (dev && netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_saddr6)
-			rc = dev->l3mdev_ops->l3mdev_get_saddr6(dev, sk, fl6);
-
-		rcu_read_unlock();
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL_GPL(l3mdev_get_saddr6);
-
 /**
  *	l3mdev_fib_rule_match - Determine if flowi references an
  *				L3 master device
-- 
2.1.4
