From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/8] net: ipv4: refactor __ip_route_output_key_hash
Date: Thu, 25 May 2017 10:42:33 -0700
Message-ID: <1495734160-47659-2-git-send-email-roopa@cumulusnetworks.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net, dsahern@gmail.com, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33189 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969985AbdEYRnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:43:05 -0400
Received: by mail-pf0-f182.google.com with SMTP id e193so173725618pfh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 10:43:04 -0700 (PDT)
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>

A later patch wants access to the fib result on an output route lookup
with the rcu lock held. Refactor __ip_route_output_key_hash, pushing
the logic between rcu_read_lock ... rcu_read_unlock into a new helper
with the fib_result as an input arg.

To keep the name length under control remove the leading underscores
from the name and add _rcu to the name of the new helper indicating it
is called with the rcu read lock held.

Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/route.h |  9 ++++++---
 net/ipv4/icmp.c     |  2 +-
 net/ipv4/route.c    | 53 +++++++++++++++++++++++++++++++----------------------
 3 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2cc0e14..89e4028 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -113,13 +113,16 @@ struct rt_cache_stat {
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *flp,
-					  const struct sk_buff *skb);
+struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *flp,
+					const struct sk_buff *skb);
+struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *flp,
+					    struct fib_result *res,
+					    const struct sk_buff *skb);
 
 static inline struct rtable *__ip_route_output_key(struct net *net,
 						   struct flowi4 *flp)
 {
-	return __ip_route_output_key_hash(net, flp, NULL);
+	return ip_route_output_key_hash(net, flp, NULL);
 }
 
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 43318b5..5610971 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -489,7 +489,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_oif = l3mdev_master_ifindex(skb_dst(skb_in)->dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt = __ip_route_output_key_hash(net, fl4, skb_in);
+	rt = ip_route_output_key_hash(net, fl4, skb_in);
 	if (IS_ERR(rt))
 		return rt;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 655d9ee..c9b55cb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2246,29 +2246,40 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					  const struct sk_buff *skb)
+struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
+					const struct sk_buff *skb)
 {
-	struct net_device *dev_out = NULL;
 	__u8 tos = RT_FL_TOS(fl4);
-	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
-	int orig_oif;
-	int err = -ENETUNREACH;
 
 	res.tclassid	= 0;
 	res.fi		= NULL;
 	res.table	= NULL;
 
-	orig_oif = fl4->flowi4_oif;
-
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
 			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rcu_read_lock();
+	rth = ip_route_output_key_hash_rcu(net, fl4, &res, skb);
+	rcu_read_unlock();
+
+	return rth;
+}
+EXPORT_SYMBOL_GPL(ip_route_output_key_hash);
+
+struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
+					    struct fib_result *res,
+					    const struct sk_buff *skb)
+{
+	struct net_device *dev_out = NULL;
+	int orig_oif = fl4->flowi4_oif;
+	unsigned int flags = 0;
+	struct rtable *rth;
+	int err = -ENETUNREACH;
+
 	if (fl4->saddr) {
 		rth = ERR_PTR(-EINVAL);
 		if (ipv4_is_multicast(fl4->saddr) ||
@@ -2354,15 +2365,15 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 			fl4->daddr = fl4->saddr = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = LOOPBACK_IFINDEX;
-		res.type = RTN_LOCAL;
+		res->type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
-	err = fib_lookup(net, fl4, &res, 0);
+	err = fib_lookup(net, fl4, res, 0);
 	if (err) {
-		res.fi = NULL;
-		res.table = NULL;
+		res->fi = NULL;
+		res->table = NULL;
 		if (fl4->flowi4_oif &&
 		    (ipv4_is_multicast(fl4->daddr) ||
 		    !netif_index_is_l3_master(net, fl4->flowi4_oif))) {
@@ -2387,43 +2398,41 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 			if (fl4->saddr == 0)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
-			res.type = RTN_UNICAST;
+			res->type = RTN_UNICAST;
 			goto make_route;
 		}
 		rth = ERR_PTR(err);
 		goto out;
 	}
 
-	if (res.type == RTN_LOCAL) {
+	if (res->type == RTN_LOCAL) {
 		if (!fl4->saddr) {
-			if (res.fi->fib_prefsrc)
-				fl4->saddr = res.fi->fib_prefsrc;
+			if (res->fi->fib_prefsrc)
+				fl4->saddr = res->fi->fib_prefsrc;
 			else
 				fl4->saddr = fl4->daddr;
 		}
 
 		/* L3 master device is the loopback for that domain */
-		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
+		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(*res)) ? :
 			net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
-	fib_select_path(net, &res, fl4, skb);
+	fib_select_path(net, res, fl4, skb);
 
-	dev_out = FIB_RES_DEV(res);
+	dev_out = FIB_RES_DEV(*res);
 	fl4->flowi4_oif = dev_out->ifindex;
 
 
 make_route:
-	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
+	rth = __mkroute_output(res, fl4, orig_oif, dev_out, flags);
 
 out:
-	rcu_read_unlock();
 	return rth;
 }
-EXPORT_SYMBOL_GPL(__ip_route_output_key_hash);
 
 static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
 {
-- 
1.9.1
