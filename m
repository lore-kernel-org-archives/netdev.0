From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Mon, 07 Mar 2011 20:58:15 -0800 (PST)
Message-ID: <20110307.205815.193699096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756012Ab1CHE5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 23:57:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5D27024C089
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2011 20:58:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When doing output route lookups, we have to select the source address
if the user has not specified an explicit one.

First, if the route has an explicit preferred source address
specified, then we use that.

Otherwise we search the route's outgoing interface for a suitable
address.

This search can be precomputed and cached at route insertion time.

The only missing part is that we have to refresh this precomputed
value any time addresses are added or removed from the interface, and
this is accomplished by fib_update_nh_saddrs().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    7 +++++--
 net/ipv4/fib_frontend.c  |    2 ++
 net/ipv4/fib_semantics.c |   31 ++++++++++++++++++++++++-------
 3 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 523a170..0e14083 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -60,6 +60,7 @@ struct fib_nh {
 #endif
 	int			nh_oif;
 	__be32			nh_gw;
+	__be32			nh_saddr;
 };
 
 /*
@@ -139,11 +140,13 @@ struct fib_result_nl {
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
-#define FIB_RES_PREFSRC(res)		((res).fi->fib_prefsrc ? : __fib_res_prefsrc(&res))
+#define FIB_RES_SADDR(res)		(FIB_RES_NH(res).nh_saddr)
 #define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
 #define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
 #define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
 
+#define FIB_RES_PREFSRC(res)		((res).fi->fib_prefsrc ? : FIB_RES_SADDR(res))
+
 struct fib_table {
 	struct hlist_node tb_hlist;
 	u32		tb_id;
@@ -224,8 +227,8 @@ extern void fib_select_default(struct fib_result *res);
 extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
 extern int fib_sync_down_dev(struct net_device *dev, int force);
 extern int fib_sync_down_addr(struct net *net, __be32 local);
+extern void fib_update_nh_saddrs(struct net_device *dev);
 extern int fib_sync_up(struct net_device *dev);
-extern __be32  __fib_res_prefsrc(struct fib_result *res);
 extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
 
 /* Exported by fib_trie.c */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index ad0778a..1d2233c 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -890,10 +890,12 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		fib_sync_up(dev);
 #endif
+		fib_update_nh_saddrs(dev);
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa);
+		fib_update_nh_saddrs(dev);
 		if (ifa->ifa_dev->ifa_list == NULL) {
 			/* Last address was deleted from this interface.
 			 * Disable IP.
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 6349a21..952c737 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -853,6 +853,12 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 				goto err_inval;
 	}
 
+	change_nexthops(fi) {
+		nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
+							nexthop_nh->nh_gw,
+							nexthop_nh->nh_scope);
+	} endfor_nexthops(fi)
+
 link_it:
 	ofi = fib_find_info(fi);
 	if (ofi) {
@@ -898,13 +904,6 @@ failure:
 	return ERR_PTR(err);
 }
 
-/* Find appropriate source address to this destination */
-
-__be32 __fib_res_prefsrc(struct fib_result *res)
-{
-	return inet_select_addr(FIB_RES_DEV(*res), FIB_RES_GW(*res), res->scope);
-}
-
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
@@ -1128,6 +1127,24 @@ out:
 	return;
 }
 
+void fib_update_nh_saddrs(struct net_device *dev)
+{
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct fib_nh *nh;
+	unsigned int hash;
+
+	hash = fib_devindex_hashfn(dev->ifindex);
+	head = &fib_info_devhash[hash];
+	hlist_for_each_entry(nh, node, head, nh_hash) {
+		if (nh->nh_dev != dev)
+			continue;
+		nh->nh_saddr = inet_select_addr(nh->nh_dev,
+						nh->nh_gw,
+						nh->nh_scope);
+	}
+}
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 /*
-- 
1.7.4.1

