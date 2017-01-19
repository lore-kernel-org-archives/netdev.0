From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH net-next v4] bridge: multicast to unicast
Date: Thu, 19 Jan 2017 03:45:10 +0100
Message-ID: <20170119024510.3284-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
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

From: Felix Fietkau <nbd@nbd.name>

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

Signed-off-by: Felix Fietkau <nbd@nbd.name>
[linus.luessing@c0d3.blue: various bug + style fixes, commit message]
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

Changes in v4:
* readd "From: Felix Fietkau [...]" (missed it again in v3)

Changes in v3:
* fix an uninitialized variable bug introduced in br_multicast_flood()
  in v2, found by kbuild test bot

Changes in v2:
* netlink support (thanks Nik!)
* fixed switching between multicast_to_unicast on/off
  -> even after toggling an already existing entry would
     stale in its mode and would never be replaced
  -> new extra check in br_port_group_equal)
* reduced checks in br_multicast_flood() from two to one
  to address fast-path concerns (thanks Nik!)
* rev-christmas tree ordering (thanks Nik!)
* removed "net_bridge_port_group::unicast", using
  ::flags instead (thanks Nik!)
* BR_MULTICAST_TO_UCAST -> BR_MULTICAST_TO_UNICAST
  (BR_MULTICAST_FLAST_LEAVE has the same length anyway)
* simplified maybe_deliver_addr()
  (no return, no "prev" paramater -> was a NOP anyway)
* added "From: Felix Fietkau [...]"
* added "Signed-off-by: Felix Fietkau [...]"
---
 include/linux/if_bridge.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_forward.c      | 37 ++++++++++++++++-
 net/bridge/br_mdb.c          |  2 +-
 net/bridge/br_multicast.c    | 96 ++++++++++++++++++++++++++++++++------------
 net/bridge/br_netlink.c      |  5 +++
 net/bridge/br_private.h      |  8 ++--
 net/bridge/br_sysfs_if.c     |  2 +
 8 files changed, 121 insertions(+), 31 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index c6587c0..debc9d5 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -46,6 +46,7 @@ struct br_ip_list {
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 #define BR_MCAST_FLOOD		BIT(11)
+#define BR_MULTICAST_TO_UNICAST	BIT(12)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6b13e59..4e59565 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -321,6 +321,7 @@ enum {
 	IFLA_BRPORT_MULTICAST_ROUTER,
 	IFLA_BRPORT_PAD,
 	IFLA_BRPORT_MCAST_FLOOD,
+	IFLA_BRPORT_MCAST_TO_UCAST,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 7cb41ae..a6c8a27 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -174,6 +174,29 @@ static struct net_bridge_port *maybe_deliver(
 	return p;
 }
 
+static void maybe_deliver_addr(struct net_bridge_port *p, struct sk_buff *skb,
+			       const unsigned char *addr, bool local_orig)
+{
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+	const unsigned char *src = eth_hdr(skb)->h_source;
+
+	if (!should_deliver(p, skb))
+		return;
+
+	/* Even with hairpin, no soliloquies - prevent breaking IPv6 DAD */
+	if (skb->dev == p->dev && ether_addr_equal(src, addr))
+		return;
+
+	skb = skb_copy(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.tx_dropped++;
+		return;
+	}
+
+	memcpy(eth_hdr(skb)->h_dest, addr, ETH_ALEN);
+	__br_forward(p, skb, local_orig);
+}
+
 /* called under rcu_read_lock */
 void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	      enum br_pkt_type pkt_type, bool local_rcv, bool local_orig)
@@ -241,10 +264,20 @@ void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
 			     NULL;
 
-		port = (unsigned long)lport > (unsigned long)rport ?
-		       lport : rport;
+		if ((unsigned long)lport > (unsigned long)rport) {
+			port = lport;
+
+			if (p->flags & MDB_PG_FLAGS_MCAST_TO_UCAST) {
+				maybe_deliver_addr(lport, skb, p->eth_addr,
+						   local_orig);
+				goto delivered;
+			}
+		} else {
+			port = rport;
+		}
 
 		prev = maybe_deliver(prev, port, skb, local_orig);
+delivered:
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
index b30e77e..b127bb7 100644
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
 
@@ -726,12 +729,39 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
+
+	if ((port->flags & BR_MULTICAST_TO_UNICAST) && src) {
+		memcpy(p->eth_addr, src, ETH_ALEN);
+		p->flags |= MDB_PG_FLAGS_MCAST_TO_UCAST;
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
+	if (!(p->flags & MDB_PG_FLAGS_MCAST_TO_UCAST) !=
+	    !(port->flags & BR_MULTICAST_TO_UNICAST))
+		return false;
+
+	if (!(p->flags & MDB_PG_FLAGS_MCAST_TO_UCAST))
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
@@ -758,13 +788,13 @@ static int br_multicast_add_group(struct net_bridge *br,
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
@@ -783,7 +813,8 @@ static int br_multicast_add_group(struct net_bridge *br,
 static int br_ip4_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      __be32 group,
-				      __u16 vid)
+				      __u16 vid,
+				      const unsigned char *src)
 {
 	struct br_ip br_group;
 
@@ -794,14 +825,15 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
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
 
@@ -812,7 +844,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 	br_group.proto = htons(ETH_P_IPV6);
 	br_group.vid = vid;
 
-	return br_multicast_add_group(br, port, &br_group);
+	return br_multicast_add_group(br, port, &br_group, src);
 }
 #endif
 
@@ -1081,6 +1113,7 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 					 struct sk_buff *skb,
 					 u16 vid)
 {
+	const unsigned char *src;
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
 	int i;
@@ -1121,12 +1154,14 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
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
@@ -1141,6 +1176,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 					struct sk_buff *skb,
 					u16 vid)
 {
+	const unsigned char *src = eth_hdr(skb)->h_source;
 	struct icmp6hdr *icmp6h;
 	struct mld2_grec *grec;
 	int i;
@@ -1192,10 +1228,11 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
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
@@ -1511,7 +1548,8 @@ br_multicast_leave_group(struct net_bridge *br,
 			 struct net_bridge_port *port,
 			 struct br_ip *group,
 			 struct bridge_mcast_other_query *other_query,
-			 struct bridge_mcast_own_query *own_query)
+			 struct bridge_mcast_own_query *own_query,
+			 const unsigned char *src)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -1535,7 +1573,7 @@ br_multicast_leave_group(struct net_bridge *br,
 		for (pp = &mp->ports;
 		     (p = mlock_dereference(*pp, br)) != NULL;
 		     pp = &p->next) {
-			if (p->port != port)
+			if (!br_port_group_equal(p, port, src))
 				continue;
 
 			rcu_assign_pointer(*pp, p->next);
@@ -1566,7 +1604,7 @@ br_multicast_leave_group(struct net_bridge *br,
 		for (p = mlock_dereference(mp->ports, br);
 		     p != NULL;
 		     p = mlock_dereference(p->next, br)) {
-			if (p->port != port)
+			if (!br_port_group_equal(p, port, src))
 				continue;
 
 			if (!hlist_unhashed(&p->mglist) &&
@@ -1617,7 +1655,8 @@ br_multicast_leave_group(struct net_bridge *br,
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 __be32 group,
-					 __u16 vid)
+					 __u16 vid,
+					 const unsigned char *src)
 {
 	struct br_ip br_group;
 	struct bridge_mcast_own_query *own_query;
@@ -1632,14 +1671,15 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
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
@@ -1654,7 +1694,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group, &br->ip6_other_query,
-				 own_query);
+				 own_query, src);
 }
 #endif
 
@@ -1712,6 +1752,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 u16 vid)
 {
 	struct sk_buff *skb_trimmed = NULL;
+	const unsigned char *src;
 	struct igmphdr *ih;
 	int err;
 
@@ -1731,13 +1772,14 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
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
@@ -1746,7 +1788,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group, vid);
+		br_ip4_multicast_leave_group(br, port, ih->group, vid, src);
 		break;
 	}
 
@@ -1766,6 +1808,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 u16 vid)
 {
 	struct sk_buff *skb_trimmed = NULL;
+	const unsigned char *src;
 	struct mld_msg *mld;
 	int err;
 
@@ -1785,8 +1828,10 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 
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
@@ -1795,7 +1840,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		err = br_ip6_multicast_query(br, port, skb_trimmed, vid);
 		break;
 	case ICMPV6_MGM_REDUCTION:
-		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid);
+		src = eth_hdr(skb)->h_source;
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid, src);
 		break;
 	}
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 71c7453..6c087cd 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -123,6 +123,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
+		+ nla_total_size(1)	/* IFLA_BRPORT_MCAST_TO_UCAST */
 		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
@@ -173,6 +174,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 		       !!(p->flags & BR_ROOT_BLOCK)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE,
 		       !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_MCAST_TO_UCAST,
+		       !!(p->flags & BR_MULTICAST_TO_UNICAST)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD,
 		       !!(p->flags & BR_FLOOD)) ||
@@ -586,6 +589,7 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_PROXYARP]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROXYARP_WIFI] = { .type = NLA_U8 },
 	[IFLA_BRPORT_MULTICAST_ROUTER] = { .type = NLA_U8 },
+	[IFLA_BRPORT_MCAST_TO_UCAST] = { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -636,6 +640,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
+	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8ce621e..f7db79f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -166,8 +166,9 @@ struct net_bridge_fdb_entry
 	struct rcu_head			rcu;
 };
 
-#define MDB_PG_FLAGS_PERMANENT	BIT(0)
-#define MDB_PG_FLAGS_OFFLOAD	BIT(1)
+#define MDB_PG_FLAGS_PERMANENT		BIT(0)
+#define MDB_PG_FLAGS_OFFLOAD		BIT(1)
+#define MDB_PG_FLAGS_MCAST_TO_UCAST	BIT(2)
 
 struct net_bridge_port_group {
 	struct net_bridge_port		*port;
@@ -177,6 +178,7 @@ struct net_bridge_port_group {
 	struct timer_list		timer;
 	struct br_ip			addr;
 	unsigned char			flags;
+	unsigned char			eth_addr[ETH_ALEN];
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
index 8bd5696..05e8946 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -188,6 +188,7 @@ static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
 		   store_multicast_router);
 
 BRPORT_ATTR_FLAG(multicast_fast_leave, BR_MULTICAST_FAST_LEAVE);
+BRPORT_ATTR_FLAG(multicast_to_unicast, BR_MULTICAST_TO_UNICAST);
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
2.1.4
