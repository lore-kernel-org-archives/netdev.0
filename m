From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6 2/3 (TAKE 3)] bridge br_multicast: Make functions less ipv4 dependent.
Date: Thu, 8 Apr 2010 14:52:27 +0900
Message-ID: <201004080611.o386BaoY015014@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60037 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab0DHGLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 02:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce struct br_ip{} to store ip address and protocol
and make functions more generic so that we can support
both IPv4 and IPv6 with less pain.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |  197 ++++++++++++++++++++++++++++++++-------------
 net/bridge/br_private.h   |   12 +++-
 2 files changed, 151 insertions(+), 58 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 9f0c4f0..8e98546 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -27,48 +27,86 @@
 
 #include "br_private.h"
 
-static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
+static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
+{
+	if (a->proto != b->proto)
+		return 0;
+	switch (a->proto) {
+	case htons(ETH_P_IP):
+		return a->u.ip4 == b->u.ip4;
+	}
+	return 0;
+}
+
+static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 {
 	return jhash_1word(mdb->secret, (u32)ip) & (mdb->max - 1);
 }
 
+static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
+			     struct br_ip *ip)
+{
+	switch (ip->proto) {
+	case htons(ETH_P_IP):
+		return __br_ip4_hash(mdb, ip->u.ip4);
+	}
+	return 0;
+}
+
 static struct net_bridge_mdb_entry *__br_mdb_ip_get(
-	struct net_bridge_mdb_htable *mdb, __be32 dst, int hash)
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst, int hash)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 
 	hlist_for_each_entry_rcu(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
-		if (dst == mp->addr)
+		if (br_ip_equal(&mp->addr, dst))
 			return mp;
 	}
 
 	return NULL;
 }
 
-static struct net_bridge_mdb_entry *br_mdb_ip_get(
+static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	struct net_bridge_mdb_htable *mdb, __be32 dst)
 {
-	if (!mdb)
-		return NULL;
+	struct br_ip br_dst;
+
+	br_dst.u.ip4 = dst;
+	br_dst.proto = htons(ETH_P_IP);
 
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
+}
+
+static struct net_bridge_mdb_entry *br_mdb_ip_get(
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
+{
 	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
 }
 
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	if (br->multicast_disabled)
+	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct br_ip ip;
+
+	if (!mdb || br->multicast_disabled)
+		return NULL;
+
+	if (BR_INPUT_SKB_CB(skb)->igmp)
 		return NULL;
 
+	ip.proto = skb->protocol;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		if (BR_INPUT_SKB_CB(skb)->igmp)
-			break;
-		return br_mdb_ip_get(br->mdb, ip_hdr(skb)->daddr);
+		ip.u.ip4 = ip_hdr(skb)->daddr;
+		break;
+	default:
+		return NULL;
 	}
 
-	return NULL;
+	return br_mdb_ip_get(mdb, &ip);
 }
 
 static void br_mdb_free(struct rcu_head *head)
@@ -95,7 +133,7 @@ static int br_mdb_copy(struct net_bridge_mdb_htable *new,
 	for (i = 0; i < old->max; i++)
 		hlist_for_each_entry(mp, p, &old->mhash[i], hlist[old->ver])
 			hlist_add_head(&mp->hlist[new->ver],
-				       &new->mhash[br_ip_hash(new, mp->addr)]);
+				       &new->mhash[br_ip_hash(new, &mp->addr)]);
 
 	if (!elasticity)
 		return 0;
@@ -163,7 +201,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group **pp;
 
-	mp = br_mdb_ip_get(mdb, pg->addr);
+	mp = br_mdb_ip_get(mdb, &pg->addr);
 	if (WARN_ON(!mp))
 		return;
 
@@ -249,8 +287,8 @@ out:
 	return 0;
 }
 
-static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
-						__be32 group)
+static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
+						    __be32 group)
 {
 	struct sk_buff *skb;
 	struct igmphdr *ih;
@@ -314,12 +352,22 @@ out:
 	return skb;
 }
 
+static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
+						struct br_ip *addr)
+{
+	switch (addr->proto) {
+	case htons(ETH_P_IP):
+		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+	}
+	return NULL;
+}
+
 static void br_multicast_send_group_query(struct net_bridge_mdb_entry *mp)
 {
 	struct net_bridge *br = mp->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, mp->addr);
+	skb = br_multicast_alloc_query(br, &mp->addr);
 	if (!skb)
 		goto timer;
 
@@ -353,7 +401,7 @@ static void br_multicast_send_port_group_query(struct net_bridge_port_group *pg)
 	struct net_bridge *br = port->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, pg->addr);
+	skb = br_multicast_alloc_query(br, &pg->addr);
 	if (!skb)
 		goto timer;
 
@@ -383,8 +431,8 @@ out:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_get_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group,
-	int hash)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group, int hash)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -396,9 +444,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 
 	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		count++;
-		if (unlikely(group == mp->addr)) {
+		if (unlikely(br_ip_equal(group, &mp->addr)))
 			return mp;
-		}
 	}
 
 	elasticity = 0;
@@ -463,7 +510,8 @@ err:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_new_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -496,7 +544,7 @@ rehash:
 		goto out;
 
 	mp->br = br;
-	mp->addr = group;
+	mp->addr = *group;
 	setup_timer(&mp->timer, br_multicast_group_expired,
 		    (unsigned long)mp);
 	setup_timer(&mp->query_timer, br_multicast_group_query_expired,
@@ -510,7 +558,8 @@ out:
 }
 
 static int br_multicast_add_group(struct net_bridge *br,
-				  struct net_bridge_port *port, __be32 group)
+				  struct net_bridge_port *port,
+				  struct br_ip *group)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -518,9 +567,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	unsigned long now = jiffies;
 	int err;
 
-	if (ipv4_is_local_multicast(group))
-		return 0;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED))
@@ -549,7 +595,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 
-	p->addr = group;
+	p->addr = *group;
 	p->port = port;
 	p->next = *pp;
 	hlist_add_head(&p->mglist, &port->mglist);
@@ -570,6 +616,21 @@ err:
 	return err;
 }
 
+static int br_ip4_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return 0;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -591,19 +652,15 @@ static void br_multicast_local_router_expired(unsigned long data)
 {
 }
 
-static void br_multicast_send_query(struct net_bridge *br,
-				    struct net_bridge_port *port, u32 sent)
+static void __br_multicast_send_query(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      struct br_ip *ip)
 {
-	unsigned long time;
 	struct sk_buff *skb;
 
-	if (!netif_running(br->dev) || br->multicast_disabled ||
-	    timer_pending(&br->multicast_querier_timer))
-		return;
-
-	skb = br_multicast_alloc_query(br, 0);
+	skb = br_multicast_alloc_query(br, ip);
 	if (!skb)
-		goto timer;
+		return;
 
 	if (port) {
 		__skb_push(skb, sizeof(struct ethhdr));
@@ -612,8 +669,23 @@ static void br_multicast_send_query(struct net_bridge *br,
 			dev_queue_xmit);
 	} else
 		netif_rx(skb);
+}
+
+static void br_multicast_send_query(struct net_bridge *br,
+				    struct net_bridge_port *port, u32 sent)
+{
+	unsigned long time;
+	struct br_ip br_group;
+
+	if (!netif_running(br->dev) || br->multicast_disabled ||
+	    timer_pending(&br->multicast_querier_timer))
+		return;
+
+	br_group.u.ip4 = 0;
+	br_group.proto = htons(ETH_P_IP);
+
+	__br_multicast_send_query(br, port, &br_group);
 
-timer:
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
@@ -698,9 +770,9 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 	spin_unlock(&br->multicast_lock);
 }
 
-static int br_multicast_igmp3_report(struct net_bridge *br,
-				     struct net_bridge_port *port,
-				     struct sk_buff *skb)
+static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 struct sk_buff *skb)
 {
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
@@ -745,7 +817,7 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_multicast_add_group(br, port, group);
+		err = br_ip4_multicast_add_group(br, port, group);
 		if (err)
 			break;
 	}
@@ -800,7 +872,7 @@ timer:
 
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
-					__be32 saddr)
+					int saddr)
 {
 	if (saddr)
 		mod_timer(&br->multicast_querier_timer,
@@ -811,9 +883,9 @@ static void br_multicast_query_received(struct net_bridge *br,
 	br_multicast_mark_router(br, port);
 }
 
-static int br_multicast_query(struct net_bridge *br,
-			      struct net_bridge_port *port,
-			      struct sk_buff *skb)
+static int br_ip4_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	struct igmphdr *ih = igmp_hdr(skb);
@@ -831,7 +903,7 @@ static int br_multicast_query(struct net_bridge *br,
 	    (port && port->state == BR_STATE_DISABLED))
 		goto out;
 
-	br_multicast_query_received(br, port, iph->saddr);
+	br_multicast_query_received(br, port, !!iph->saddr);
 
 	group = ih->group;
 
@@ -859,7 +931,7 @@ static int br_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip_get(br->mdb, group);
+	mp = br_mdb_ip4_get(br->mdb, group);
 	if (!mp)
 		goto out;
 
@@ -885,7 +957,7 @@ out:
 
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
-				     __be32 group)
+				     struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -893,9 +965,6 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	unsigned long now;
 	unsigned long time;
 
-	if (ipv4_is_local_multicast(group))
-		return;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED) ||
@@ -946,6 +1015,22 @@ out:
 	spin_unlock(&br->multicast_lock);
 }
 
+static void br_ip4_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+
+
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
@@ -1023,16 +1108,16 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
-		err = br_multicast_add_group(br, port, ih->group);
+		err = br_ip4_multicast_add_group(br, port, ih->group);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err = br_multicast_igmp3_report(br, port, skb2);
+		err = br_ip4_multicast_igmp3_report(br, port, skb2);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err = br_multicast_query(br, port, skb2);
+		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_multicast_leave_group(br, port, ih->group);
+		br_ip4_multicast_leave_group(br, port, ih->group);
 		break;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 791d4ab..b55de82 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -45,6 +45,14 @@ struct mac_addr
 	unsigned char	addr[6];
 };
 
+struct br_ip
+{
+	union {
+		__be32	ip4;
+	} u;
+	__be16		proto;
+};
+
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
@@ -64,7 +72,7 @@ struct net_bridge_port_group {
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 
@@ -77,7 +85,7 @@ struct net_bridge_mdb_entry
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 
-- 
1.5.6.5

