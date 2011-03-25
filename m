From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Invalidate nexthop cache nh_saddr more correctly.
Date: Thu, 24 Mar 2011 18:14:15 -0700 (PDT)
Message-ID: <20110324.181415.149842651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932206Ab1CYBNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 21:13:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Any operation that:

1) Brings up an interface
2) Adds an IP address to an interface
3) Deletes an IP address from an interface

can potentially invalidate the nh_saddr value, requiring
it to be recomputed.

Perform the recomputation lazily using a generation ID.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |   12 ++++++++++--
 include/net/netns/ipv4.h |    1 +
 net/ipv4/fib_frontend.c  |   11 +++++++----
 net/ipv4/fib_semantics.c |   32 +++++++++++---------------------
 net/ipv4/route.c         |    6 ++++--
 5 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a1a8580..cd92b92 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -62,6 +62,7 @@ struct fib_nh {
 	int			nh_oif;
 	__be32			nh_gw;
 	__be32			nh_saddr;
+	int			nh_saddr_genid;
 };
 
 /*
@@ -141,12 +142,19 @@ struct fib_result_nl {
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
-#define FIB_RES_SADDR(res)		(FIB_RES_NH(res).nh_saddr)
+extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
+
+#define FIB_RES_SADDR(net, res)				\
+	((FIB_RES_NH(res).nh_saddr_genid ==		\
+	  atomic_read(&(net)->ipv4.dev_addr_genid)) ?	\
+	 FIB_RES_NH(res).nh_saddr :			\
+	 fib_info_update_nh_saddr((net), &FIB_RES_NH(res)))
 #define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
 #define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
 #define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
 
-#define FIB_RES_PREFSRC(res)		((res).fi->fib_prefsrc ? : FIB_RES_SADDR(res))
+#define FIB_RES_PREFSRC(net, res)	((res).fi->fib_prefsrc ? : \
+					 FIB_RES_SADDR(net, res))
 
 struct fib_table {
 	struct hlist_node tb_hlist;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e2e2ef5..542195d 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -55,6 +55,7 @@ struct netns_ipv4 {
 	int current_rt_cache_rebuild_count;
 
 	atomic_t rt_genid;
+	atomic_t dev_addr_genid;
 
 #ifdef CONFIG_IP_MROUTE
 #ifndef CONFIG_IP_MROUTE_MULTIPLE_TABLES
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 02c3ba6..f116ce8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -228,7 +228,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		if (res.type != RTN_LOCAL || !accept_local)
 			goto e_inval;
 	}
-	*spec_dst = FIB_RES_PREFSRC(res);
+	*spec_dst = FIB_RES_PREFSRC(net, res);
 	fib_combine_itag(itag, &res);
 	dev_match = false;
 
@@ -258,7 +258,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	ret = 0;
 	if (fib_lookup(net, &fl4, &res) == 0) {
 		if (res.type == RTN_UNICAST) {
-			*spec_dst = FIB_RES_PREFSRC(res);
+			*spec_dst = FIB_RES_PREFSRC(net, res);
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
 		}
 	}
@@ -960,6 +960,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct net_device *dev = ifa->ifa_dev->dev;
+	struct net *net = dev_net(dev);
 
 	switch (event) {
 	case NETDEV_UP:
@@ -967,12 +968,12 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		fib_sync_up(dev);
 #endif
-		fib_update_nh_saddrs(dev);
+		atomic_inc(&net->ipv4.dev_addr_genid);
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa, NULL);
-		fib_update_nh_saddrs(dev);
+		atomic_inc(&net->ipv4.dev_addr_genid);
 		if (ifa->ifa_dev->ifa_list == NULL) {
 			/* Last address was deleted from this interface.
 			 * Disable IP.
@@ -990,6 +991,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 {
 	struct net_device *dev = ptr;
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
+	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2, -1);
@@ -1007,6 +1009,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		fib_sync_up(dev);
 #endif
+		atomic_inc(&net->ipv4.dev_addr_genid);
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 75b9fb5..2d4bebc 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -695,6 +695,16 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 	fib_info_hash_free(old_laddrhash, bytes);
 }
 
+__be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
+{
+	nh->nh_saddr = inet_select_addr(nh->nh_dev,
+					nh->nh_gw,
+					nh->nh_cfg_scope);
+	nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid);
+
+	return nh->nh_saddr;
+}
+
 struct fib_info *fib_create_info(struct fib_config *cfg)
 {
 	int err;
@@ -855,9 +865,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 	change_nexthops(fi) {
 		nexthop_nh->nh_cfg_scope = cfg->fc_scope;
-		nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
-							nexthop_nh->nh_gw,
-							nexthop_nh->nh_cfg_scope);
+		fib_info_update_nh_saddr(net, nexthop_nh);
 	} endfor_nexthops(fi)
 
 link_it:
@@ -1128,24 +1136,6 @@ out:
 	return;
 }
 
-void fib_update_nh_saddrs(struct net_device *dev)
-{
-	struct hlist_head *head;
-	struct hlist_node *node;
-	struct fib_nh *nh;
-	unsigned int hash;
-
-	hash = fib_devindex_hashfn(dev->ifindex);
-	head = &fib_info_devhash[hash];
-	hlist_for_each_entry(nh, node, head, nh_hash) {
-		if (nh->nh_dev != dev)
-			continue;
-		nh->nh_saddr = inet_select_addr(nh->nh_dev,
-						nh->nh_gw,
-						nh->nh_cfg_scope);
-	}
-}
-
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 /*
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 34921b0..4b0c811 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1718,7 +1718,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 
 		rcu_read_lock();
 		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
-			src = FIB_RES_PREFSRC(res);
+			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
 		else
 			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
 					RT_SCOPE_UNIVERSE);
@@ -2615,7 +2615,7 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		fib_select_default(&res);
 
 	if (!fl4.saddr)
-		fl4.saddr = FIB_RES_PREFSRC(res);
+		fl4.saddr = FIB_RES_PREFSRC(net, res);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4.flowi4_oif = dev_out->ifindex;
@@ -3219,6 +3219,8 @@ static __net_init int rt_genid_init(struct net *net)
 {
 	get_random_bytes(&net->ipv4.rt_genid,
 			 sizeof(net->ipv4.rt_genid));
+	get_random_bytes(&net->ipv4.dev_addr_genid,
+			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
 }
 
-- 
1.7.4.1

