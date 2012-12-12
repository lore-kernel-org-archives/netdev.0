From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 06/11] bridge: Add vlan id to multicast groups
Date: Wed, 12 Dec 2012 15:01:12 -0500
Message-ID: <1355342477-4971-7-git-send-email-vyasevic@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130Ab2LLUBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 15:01:33 -0500
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vlan_id to multicasts groups so that we know which vlan
each group belongs to and can correctly forward to appropriate vlan.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_multicast.c |   64 +++++++++++++++++++++++++++++++--------------
 net/bridge/br_private.h   |    1 +
 2 files changed, 45 insertions(+), 20 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 68e375a..072aa2d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -51,6 +51,8 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
 		return 0;
+	if (a->vid != b->vid)
+		return 0;
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
@@ -62,16 +64,19 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 	return 0;
 }
 
-static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
+static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip,
+				__u16 vid)
 {
-	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
+	return jhash_2words((__force u32)ip, vid, mdb->secret) & (mdb->max - 1);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
-				const struct in6_addr *ip)
+				const struct in6_addr *ip,
+				__u16 vid)
 {
-	return jhash2((__force u32 *)ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
+	return jhash_2words(ipv6_addr_hash(ip), vid,
+			    mdb->secret) & (mdb->max - 1);
 }
 #endif
 
@@ -80,10 +85,10 @@ static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 {
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
-		return __br_ip4_hash(mdb, ip->u.ip4);
+		return __br_ip4_hash(mdb, ip->u.ip4, ip->vid);
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return __br_ip6_hash(mdb, &ip->u.ip6);
+		return __br_ip6_hash(mdb, &ip->u.ip6, ip->vid);
 #endif
 	}
 	return 0;
@@ -113,24 +118,27 @@ static struct net_bridge_mdb_entry *br_mdb_ip_get(
 }
 
 static struct net_bridge_mdb_entry *br_mdb_ip4_get(
-	struct net_bridge_mdb_htable *mdb, __be32 dst)
+	struct net_bridge_mdb_htable *mdb, __be32 dst, __u16 vid)
 {
 	struct br_ip br_dst;
 
 	br_dst.u.ip4 = dst;
 	br_dst.proto = htons(ETH_P_IP);
+	br_dst.vid = vid;
 
 	return br_mdb_ip_get(mdb, &br_dst);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct net_bridge_mdb_entry *br_mdb_ip6_get(
-	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
+	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst,
+	__u16 vid)
 {
 	struct br_ip br_dst;
 
 	br_dst.u.ip6 = *dst;
 	br_dst.proto = htons(ETH_P_IPV6);
+	br_dst.vid = vid;
 
 	return br_mdb_ip_get(mdb, &br_dst);
 }
@@ -692,7 +700,8 @@ err:
 
 static int br_ip4_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
-				      __be32 group)
+				      __be32 group,
+				      __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -701,6 +710,7 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 
 	br_group.u.ip4 = group;
 	br_group.proto = htons(ETH_P_IP);
+	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
 }
@@ -708,7 +718,8 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
-				      const struct in6_addr *group)
+				      const struct in6_addr *group,
+				      __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -717,6 +728,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 
 	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
+	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
 }
@@ -928,7 +940,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip4_multicast_add_group(br, port, group);
+		err = br_ip4_multicast_add_group(br, port, group,
+						 br_get_vlan(skb));
 		if (err)
 			break;
 	}
@@ -988,7 +1001,8 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
+		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
+						 br_get_vlan(skb));
 		if (!err)
 			break;
 	}
@@ -1106,7 +1120,8 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group,
+			    br_get_vlan(skb));
 	if (!mp)
 		goto out;
 
@@ -1178,7 +1193,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group,
+			    br_get_vlan(skb));
 	if (!mp)
 		goto out;
 
@@ -1283,7 +1299,8 @@ out:
 
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
-					 __be32 group)
+					 __be32 group,
+					 __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -1292,6 +1309,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 
 	br_group.u.ip4 = group;
 	br_group.proto = htons(ETH_P_IP);
+	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
 }
@@ -1299,7 +1317,8 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 #if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
-					 const struct in6_addr *group)
+					 const struct in6_addr *group,
+					 __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -1308,6 +1327,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 
 	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
+	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
 }
@@ -1390,7 +1410,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip4_multicast_add_group(br, port, ih->group);
+		err = br_ip4_multicast_add_group(br, port, ih->group,
+						 br_get_vlan(skb2));
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		err = br_ip4_multicast_igmp3_report(br, port, skb2);
@@ -1399,7 +1420,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group);
+		br_ip4_multicast_leave_group(br, port, ih->group,
+					     br_get_vlan(skb2));
 		break;
 	}
 
@@ -1519,7 +1541,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca,
+						 br_get_vlan(skb2));
 		break;
 	    }
 	case ICMPV6_MLD2_REPORT:
@@ -1536,7 +1559,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 			goto out;
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
-		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca,
+					     br_get_vlan(skb2));
 	    }
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0ba95c2..f9bead9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -63,6 +63,7 @@ struct br_ip
 #endif
 	} u;
 	__be16		proto;
+	__u16		vid;
 };
 
 #define BR_INVALID_VID	(1<<15)
-- 
1.7.7.6
