From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 5/9] bridge: use generic struct in_addr_gen
Date: Mon, 19 Aug 2013 18:14:34 +0800
Message-ID: <1376907278-26377-6-git-send-email-amwang@redhat.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab3HSKPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 06:15:09 -0400
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_mdb.c       |   53 ++++++++++++++++++------------------
 net/bridge/br_multicast.c |   65 +++++++++++++++++++-------------------------
 net/bridge/br_private.h   |    9 +-----
 3 files changed, 57 insertions(+), 70 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index e4d5cd4..55d6b59 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -13,6 +13,29 @@
 
 #include "br_private.h"
 
+static void br_ip_to_entry(struct br_mdb_entry *entry, struct br_ip *ip)
+{
+	if (ip->ip.family == AF_INET) {
+		entry->addr.proto = htons(ETH_P_IP);
+		entry->addr.u.ip4 = ip->ip.in_addr.s_addr;
+	} else {
+		entry->addr.proto = htons(ETH_P_IPV6);
+		entry->addr.u.ip6 = ip->ip.in6_addr;
+	}
+}
+
+static void br_entry_to_ip(struct br_ip *ip, struct br_mdb_entry *entry)
+{
+	__be16 proto = entry->addr.proto;
+	if (proto == htons(ETH_P_IP)) {
+		ip->ip.family = AF_INET;
+		ip->ip.in_addr.s_addr = entry->addr.u.ip4;
+	} else {
+		ip->ip.family = AF_INET6;
+		ip->ip.in6_addr = entry->addr.u.ip6;
+	}
+}
+
 static int br_rports_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			       struct net_device *dev)
 {
@@ -84,13 +107,7 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 					memset(&e, 0, sizeof(e));
 					e.ifindex = port->dev->ifindex;
 					e.state = p->state;
-					if (p->addr.proto == htons(ETH_P_IP))
-						e.addr.u.ip4 = p->addr.u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-					if (p->addr.proto == htons(ETH_P_IPV6))
-						e.addr.u.ip6 = p->addr.u.ip6;
-#endif
-					e.addr.proto = p->addr.proto;
+					br_ip_to_entry(&e, &p->addr);
 					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
 						nla_nest_cancel(skb, nest2);
 						err = -EMSGSIZE;
@@ -234,11 +251,7 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 
 	memset(&entry, 0, sizeof(entry));
 	entry.ifindex = port->dev->ifindex;
-	entry.addr.proto = group->proto;
-	entry.addr.u.ip4 = group->u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	entry.addr.u.ip6 = group->u.ip6;
-#endif
+	br_ip_to_entry(&entry, group);
 	__br_mdb_notify(dev, &entry, type);
 }
 
@@ -369,13 +382,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
-	ip.proto = entry->addr.proto;
-	if (ip.proto == htons(ETH_P_IP))
-		ip.u.ip4 = entry->addr.u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	else
-		ip.u.ip6 = entry->addr.u.ip6;
-#endif
+	br_entry_to_ip(&ip, entry);
 
 	spin_lock_bh(&br->multicast_lock);
 	ret = br_mdb_add_group(br, p, &ip, entry->state);
@@ -418,13 +425,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 	if (timer_pending(&br->multicast_querier_timer))
 		return -EBUSY;
 
-	ip.proto = entry->addr.proto;
-	if (ip.proto == htons(ETH_P_IP))
-		ip.u.ip4 = entry->addr.u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	else
-		ip.u.ip6 = entry->addr.u.ip6;
-#endif
+	br_entry_to_ip(&ip, entry);
 
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 08e576a..6d7c407 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -38,19 +38,9 @@ unsigned int br_mdb_rehash_seq;
 
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
-	if (a->proto != b->proto)
-		return 0;
 	if (a->vid != b->vid)
 		return 0;
-	switch (a->proto) {
-	case htons(ETH_P_IP):
-		return a->u.ip4 == b->u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	case htons(ETH_P_IPV6):
-		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
-#endif
-	}
-	return 0;
+	return in_addr_gen_equal(&a->ip, &b->ip);
 }
 
 static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip,
@@ -72,12 +62,12 @@ static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
 static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 			     struct br_ip *ip)
 {
-	switch (ip->proto) {
+	switch (ip->ip.family) {
 	case htons(ETH_P_IP):
-		return __br_ip4_hash(mdb, ip->u.ip4, ip->vid);
+		return __br_ip4_hash(mdb, ip->ip.in_addr.s_addr, ip->vid);
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return __br_ip6_hash(mdb, &ip->u.ip6, ip->vid);
+		return __br_ip6_hash(mdb, &ip->ip.in6_addr, ip->vid);
 #endif
 	}
 	return 0;
@@ -110,8 +100,8 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 {
 	struct br_ip br_dst;
 
-	br_dst.u.ip4 = dst;
-	br_dst.proto = htons(ETH_P_IP);
+	br_dst.ip.in_addr.s_addr = dst;
+	br_dst.ip.family = AF_INET;
 	br_dst.vid = vid;
 
 	return br_mdb_ip_get(mdb, &br_dst);
@@ -124,8 +114,8 @@ static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 {
 	struct br_ip br_dst;
 
-	br_dst.u.ip6 = *dst;
-	br_dst.proto = htons(ETH_P_IPV6);
+	br_dst.ip.in6_addr = *dst;
+	br_dst.ip.family = AF_INET6;
 	br_dst.vid = vid;
 
 	return br_mdb_ip_get(mdb, &br_dst);
@@ -144,16 +134,17 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	if (BR_INPUT_SKB_CB(skb)->igmp)
 		return NULL;
 
-	ip.proto = skb->protocol;
 	ip.vid = vid;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		ip.u.ip4 = ip_hdr(skb)->daddr;
+		ip.ip.family = AF_INET;
+		ip.ip.in_addr.s_addr = ip_hdr(skb)->daddr;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		ip.u.ip6 = ipv6_hdr(skb)->daddr;
+		ip.ip.family = AF_INET6;
+		ip.ip.in6_addr = ipv6_hdr(skb)->daddr;
 		break;
 #endif
 	default:
@@ -495,12 +486,12 @@ out:
 static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 						struct br_ip *addr)
 {
-	switch (addr->proto) {
-	case htons(ETH_P_IP):
-		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+	switch (addr->ip.family) {
+	case AF_INET:
+		return br_ip4_multicast_alloc_query(br, addr->ip.in_addr.s_addr);
 #if IS_ENABLED(CONFIG_IPV6)
-	case htons(ETH_P_IPV6):
-		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
+	case AF_INET6:
+		return br_ip6_multicast_alloc_query(br, &addr->ip.in6_addr);
 #endif
 	}
 	return NULL;
@@ -708,8 +699,8 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	if (ipv4_is_local_multicast(group))
 		return 0;
 
-	br_group.u.ip4 = group;
-	br_group.proto = htons(ETH_P_IP);
+	br_group.ip.in_addr.s_addr = group;
+	br_group.ip.family = AF_INET;
 	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
@@ -726,8 +717,8 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 	if (!ipv6_is_transient_multicast(group))
 		return 0;
 
-	br_group.u.ip6 = *group;
-	br_group.proto = htons(ETH_P_IPV6);
+	br_group.ip.in6_addr = *group;
+	br_group.ip.family = AF_INET6;
 	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
@@ -799,13 +790,13 @@ static void br_multicast_send_query(struct net_bridge *br,
 	    timer_pending(&br->multicast_querier_timer))
 		return;
 
-	memset(&br_group.u, 0, sizeof(br_group.u));
+	memset(&br_group.ip, 0, sizeof(br_group.ip));
 
-	br_group.proto = htons(ETH_P_IP);
+	br_group.ip.family = AF_INET;
 	__br_multicast_send_query(br, port, &br_group);
 
 #if IS_ENABLED(CONFIG_IPV6)
-	br_group.proto = htons(ETH_P_IPV6);
+	br_group.ip.family = AF_INET6;
 	__br_multicast_send_query(br, port, &br_group);
 #endif
 
@@ -1338,8 +1329,8 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	if (ipv4_is_local_multicast(group))
 		return;
 
-	br_group.u.ip4 = group;
-	br_group.proto = htons(ETH_P_IP);
+	br_group.ip.in_addr.s_addr = group;
+	br_group.ip.family = AF_INET;
 	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
@@ -1356,8 +1347,8 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 	if (!ipv6_is_transient_multicast(group))
 		return;
 
-	br_group.u.ip6 = *group;
-	br_group.proto = htons(ETH_P_IPV6);
+	br_group.ip.in6_addr = *group;
+	br_group.ip.family = AF_INET6;
 	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d41283c..4a5a52a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -19,6 +19,7 @@
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
 #include <linux/if_vlan.h>
+#include <net/inet_addr.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -56,13 +57,7 @@ struct mac_addr
 
 struct br_ip
 {
-	union {
-		__be32	ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-		struct in6_addr ip6;
-#endif
-	} u;
-	__be16		proto;
+	struct in_addr_gen ip;
 	__u16		vid;
 };
 
-- 
1.7.7.6
