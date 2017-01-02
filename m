From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH net-next] bridge: multicast to unicast
Date: Mon,  2 Jan 2017 20:32:14 +0100
Message-ID: <20170102193214.31723-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Implements an optional, per bridge port flag and feature to deliver
multicast packets to any host on the according port via unicast
individually. This is done by copying the packet per host and
changing the multicast destination MAC to a unicast one accordingly.

multicast-to-unicast works on top of the multicast snooping feature of
the bridge. Which means unicast copies are only delivered to hosts which
are interested in it and signalized this via IGMP/MLD reports
previously.

This feature is intended for interface types which have a more reliable
and/or efficient way to deliver unicast packets than broadcast ones
(e.g. wifi).

However, it should only be enabled on interfaces where no IGMPv2/MLDv1
report suppression takes place. This feature is disabled by default.

The initial patch and idea is from Felix Fietkau.

Cc: Felix Fietkau <nbd@nbd.name>
Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>

---

This feature is used and enabled by default in OpenWRT and LEDE for AP
interfaces for more than a year now to allow both a more robust multicast
delivery and multicast at higher rates (e.g. multicast streaming).

In OpenWRT/LEDE the IGMP/MLD report suppression issue is overcome by
the network daemon enabling AP isolation and by that separating all STAs.
Delivery of STA-to-STA IP mulitcast is made possible again by
enabling and utilizing the bridge hairpin mode, which considers the
incoming port as a potential outgoing port, too.

Hairpin-mode is performed after multicast snooping, therefore leading to
only deliver reports to STAs running a multicast router.
---
 include/linux/if_bridge.h |  1 +
 net/bridge/br_forward.c   | 44 +++++++++++++++++++++--
 net/bridge/br_mdb.c       |  2 +-
 net/bridge/br_multicast.c | 92 ++++++++++++++++++++++++++++++++++-------------
 net/bridge/br_private.h   |  4 ++-
 net/bridge/br_sysfs_if.c  |  2 ++
 6 files changed, 115 insertions(+), 30 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index c6587c0..f1b0d78 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -46,6 +46,7 @@ struct br_ip_list {
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 #define BR_MCAST_FLOOD		BIT(11)
+#define BR_MULTICAST_TO_UCAST	BIT(12)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 7cb41ae..49d742d 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -174,6 +174,33 @@ static struct net_bridge_port *maybe_deliver(
 	return p;
 }
 
+static struct net_bridge_port *maybe_deliver_addr(
+	struct net_bridge_port *prev, struct net_bridge_port *p,
+	struct sk_buff *skb, const unsigned char *addr,
+	bool local_orig)
+{
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+	const unsigned char *src = eth_hdr(skb)->h_source;
+
+	if (!should_deliver(p, skb))
+		return prev;
+
+	/* Even with hairpin, no soliloquies - prevent breaking IPv6 DAD */
+	if (skb->dev == p->dev && ether_addr_equal(src, addr))
+		return prev;
+
+	skb = skb_copy(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.tx_dropped++;
+		return prev;
+	}
+
+	memcpy(eth_hdr(skb)->h_dest, addr, ETH_ALEN);
+	__br_forward(p, skb, local_orig);
+
+	return prev;
+}
+
 /* called under rcu_read_lock */
 void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	      enum br_pkt_type pkt_type, bool local_rcv, bool local_orig)
@@ -231,6 +258,7 @@ void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 	struct net_bridge_port *prev = NULL;
 	struct net_bridge_port_group *p;
 	struct hlist_node *rp;
+	const unsigned char *addr;
 
 	rp = rcu_dereference(hlist_first_rcu(&br->router_list));
 	p = mdst ? rcu_dereference(mdst->ports) : NULL;
@@ -241,10 +269,20 @@ void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
 			     NULL;
 
-		port = (unsigned long)lport > (unsigned long)rport ?
-		       lport : rport;
+		if ((unsigned long)lport > (unsigned long)rport) {
+			port = lport;
+			addr = p->unicast ? p->eth_addr : NULL;
+		} else {
+			port = rport;
+			addr = NULL;
+		}
+
+		if (addr)
+			prev = maybe_deliver_addr(prev, port, skb, addr,
+						  local_orig);
+		else
+			prev = maybe_deliver(prev, port, skb, local_orig);
 
-		prev = maybe_deliver(prev, port, skb, local_orig);
 		if (IS_ERR(prev))
 			goto out;
 		if (prev == port)
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 7dbc80d..056e6ac 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -531,7 +531,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 			break;
 	}
 
-	p = br_multicast_new_port_group(port, group, *pp, state);
+	p = br_multicast_new_port_group(port, group, *pp, state, NULL);
 	if (unlikely(!p))
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b30e77e..470a2409 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -43,12 +43,14 @@ static void br_multicast_add_router(struct net_bridge *br,
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 __be32 group,
-					 __u16 vid);
+					 __u16 vid,
+					 const unsigned char *src);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 const struct in6_addr *group,
-					 __u16 vid);
+					 __u16 vid, const unsigned char *src);
 #endif
 unsigned int br_mdb_rehash_seq;
 
@@ -711,7 +713,8 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 			struct net_bridge_port *port,
 			struct br_ip *group,
 			struct net_bridge_port_group __rcu *next,
-			unsigned char flags)
+			unsigned char flags,
+			const unsigned char *src)
 {
 	struct net_bridge_port_group *p;
 
@@ -726,12 +729,35 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
+
+	if ((port->flags & BR_MULTICAST_TO_UCAST) && src) {
+		memcpy(p->eth_addr, src, ETH_ALEN);
+		p->unicast = true;
+	}
+
 	return p;
 }
 
+static bool br_port_group_equal(struct net_bridge_port_group *p,
+				struct net_bridge_port *port,
+				const unsigned char *src)
+{
+	if (p->port != port)
+		return false;
+
+	if (!p->unicast)
+		return true;
+
+	if (!src)
+		return false;
+
+	return ether_addr_equal(src, p->eth_addr);
+}
+
 static int br_multicast_add_group(struct net_bridge *br,
 				  struct net_bridge_port *port,
-				  struct br_ip *group)
+				  struct br_ip *group,
+				  const unsigned char *src)
 {
 	struct net_bridge_port_group __rcu **pp;
 	struct net_bridge_port_group *p;
@@ -758,13 +784,13 @@ static int br_multicast_add_group(struct net_bridge *br,
 	for (pp = &mp->ports;
 	     (p = mlock_dereference(*pp, br)) != NULL;
 	     pp = &p->next) {
-		if (p->port == port)
+		if (br_port_group_equal(p, port, src))
 			goto found;
 		if ((unsigned long)p->port < (unsigned long)port)
 			break;
 	}
 
-	p = br_multicast_new_port_group(port, group, *pp, 0);
+	p = br_multicast_new_port_group(port, group, *pp, 0, src);
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
@@ -783,7 +809,8 @@ static int br_multicast_add_group(struct net_bridge *br,
 static int br_ip4_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      __be32 group,
-				      __u16 vid)
+				      __u16 vid,
+				      const unsigned char *src)
 {
 	struct br_ip br_group;
 
@@ -794,14 +821,15 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	br_group.proto = htons(ETH_P_IP);
 	br_group.vid = vid;
 
-	return br_multicast_add_group(br, port, &br_group);
+	return br_multicast_add_group(br, port, &br_group, src);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      const struct in6_addr *group,
-				      __u16 vid)
+				      __u16 vid,
+				      const unsigned char *src)
 {
 	struct br_ip br_group;
 
@@ -812,7 +840,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 	br_group.proto = htons(ETH_P_IPV6);
 	br_group.vid = vid;
 
-	return br_multicast_add_group(br, port, &br_group);
+	return br_multicast_add_group(br, port, &br_group, src);
 }
 #endif
 
@@ -1081,6 +1109,7 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 					 struct sk_buff *skb,
 					 u16 vid)
 {
+	const unsigned char *src;
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
 	int i;
@@ -1121,12 +1150,14 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
+		src = eth_hdr(skb)->h_source;
 		if ((type == IGMPV3_CHANGE_TO_INCLUDE ||
 		     type == IGMPV3_MODE_IS_INCLUDE) &&
 		    ntohs(grec->grec_nsrcs) == 0) {
-			br_ip4_multicast_leave_group(br, port, group, vid);
+			br_ip4_multicast_leave_group(br, port, group, vid, src);
 		} else {
-			err = br_ip4_multicast_add_group(br, port, group, vid);
+			err = br_ip4_multicast_add_group(br, port, group, vid,
+							 src);
 			if (err)
 				break;
 		}
@@ -1141,6 +1172,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 					struct sk_buff *skb,
 					u16 vid)
 {
+	const unsigned char *src = eth_hdr(skb)->h_source;
 	struct icmp6hdr *icmp6h;
 	struct mld2_grec *grec;
 	int i;
@@ -1192,10 +1224,11 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 		     grec->grec_type == MLD2_MODE_IS_INCLUDE) &&
 		    ntohs(*nsrcs) == 0) {
 			br_ip6_multicast_leave_group(br, port, &grec->grec_mca,
-						     vid);
+						     vid, src);
 		} else {
 			err = br_ip6_multicast_add_group(br, port,
-							 &grec->grec_mca, vid);
+							 &grec->grec_mca, vid,
+							 src);
 			if (err)
 				break;
 		}
@@ -1511,7 +1544,8 @@ br_multicast_leave_group(struct net_bridge *br,
 			 struct net_bridge_port *port,
 			 struct br_ip *group,
 			 struct bridge_mcast_other_query *other_query,
-			 struct bridge_mcast_own_query *own_query)
+			 struct bridge_mcast_own_query *own_query,
+			 const unsigned char *src)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -1535,7 +1569,7 @@ br_multicast_leave_group(struct net_bridge *br,
 		for (pp = &mp->ports;
 		     (p = mlock_dereference(*pp, br)) != NULL;
 		     pp = &p->next) {
-			if (p->port != port)
+			if (!br_port_group_equal(p, port, src))
 				continue;
 
 			rcu_assign_pointer(*pp, p->next);
@@ -1566,7 +1600,7 @@ br_multicast_leave_group(struct net_bridge *br,
 		for (p = mlock_dereference(mp->ports, br);
 		     p != NULL;
 		     p = mlock_dereference(p->next, br)) {
-			if (p->port != port)
+			if (!br_port_group_equal(p, port, src))
 				continue;
 
 			if (!hlist_unhashed(&p->mglist) &&
@@ -1617,7 +1651,8 @@ br_multicast_leave_group(struct net_bridge *br,
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 __be32 group,
-					 __u16 vid)
+					 __u16 vid,
+					 const unsigned char *src)
 {
 	struct br_ip br_group;
 	struct bridge_mcast_own_query *own_query;
@@ -1632,14 +1667,15 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group, &br->ip4_other_query,
-				 own_query);
+				 own_query, src);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 const struct in6_addr *group,
-					 __u16 vid)
+					 __u16 vid,
+					 const unsigned char *src)
 {
 	struct br_ip br_group;
 	struct bridge_mcast_own_query *own_query;
@@ -1654,7 +1690,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group, &br->ip6_other_query,
-				 own_query);
+				 own_query, src);
 }
 #endif
 
@@ -1711,6 +1747,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct sk_buff *skb,
 				 u16 vid)
 {
+	const unsigned char *src;
 	struct sk_buff *skb_trimmed = NULL;
 	struct igmphdr *ih;
 	int err;
@@ -1731,13 +1768,14 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	}
 
 	ih = igmp_hdr(skb);
+	src = eth_hdr(skb)->h_source;
 	BR_INPUT_SKB_CB(skb)->igmp = ih->type;
 
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip4_multicast_add_group(br, port, ih->group, vid);
+		err = br_ip4_multicast_add_group(br, port, ih->group, vid, src);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		err = br_ip4_multicast_igmp3_report(br, port, skb_trimmed, vid);
@@ -1746,7 +1784,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group, vid);
+		br_ip4_multicast_leave_group(br, port, ih->group, vid, src);
 		break;
 	}
 
@@ -1765,6 +1803,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct sk_buff *skb,
 				 u16 vid)
 {
+	const unsigned char *src;
 	struct sk_buff *skb_trimmed = NULL;
 	struct mld_msg *mld;
 	int err;
@@ -1785,8 +1824,10 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 
 	switch (mld->mld_type) {
 	case ICMPV6_MGM_REPORT:
+		src = eth_hdr(skb)->h_source;
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca, vid);
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca, vid,
+						 src);
 		break;
 	case ICMPV6_MLD2_REPORT:
 		err = br_ip6_multicast_mld2_report(br, port, skb_trimmed, vid);
@@ -1795,7 +1836,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		err = br_ip6_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_REDUCTION:
-		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid);
+		src = eth_hdr(skb)->h_source;
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid, src);
 		break;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8ce621e..cc55100 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -177,6 +177,8 @@ struct net_bridge_port_group {
 	struct timer_list		timer;
 	struct br_ip			addr;
 	unsigned char			flags;
+	unsigned char			eth_addr[ETH_ALEN];
+	bool				unicast;
 };
 
 struct net_bridge_mdb_entry
@@ -599,7 +601,7 @@ void br_multicast_free_pg(struct rcu_head *head);
 struct net_bridge_port_group *
 br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
 			    struct net_bridge_port_group __rcu *next,
-			    unsigned char flags);
+			    unsigned char flags, const unsigned char *src);
 void br_mdb_init(void);
 void br_mdb_uninit(void);
 void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 8bd5696..1730278 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -188,6 +188,7 @@ static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
 		   store_multicast_router);
 
 BRPORT_ATTR_FLAG(multicast_fast_leave, BR_MULTICAST_FAST_LEAVE);
+BRPORT_ATTR_FLAG(multicast_to_unicast, BR_MULTICAST_TO_UCAST);
 #endif
 
 static const struct brport_attribute *brport_attrs[] = {
@@ -214,6 +215,7 @@ static const struct brport_attribute *brport_attrs[] = {
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
+	&brport_attr_multicast_to_unicast,
 #endif
 	&brport_attr_proxyarp,
 	&brport_attr_proxyarp_wifi,
-- 
2.10.2
