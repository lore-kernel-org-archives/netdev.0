From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 07/14] bridge: Add vlan id to multicast groups
Date: Wed,  9 Jan 2013 12:17:54 -0500
Message-ID: <1357751882-8619-8-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932208Ab3AIRSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:17 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
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
index 5391ca4..9c0ac97 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -39,6 +39,8 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
 		return 0;
+	if (a->vid != b->vid)
+		return 0;
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
@@ -50,16 +52,19 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
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
 
@@ -68,10 +73,10 @@ static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
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
@@ -101,24 +106,27 @@ struct net_bridge_mdb_entry *br_mdb_ip_get(struct net_bridge_mdb_htable *mdb,
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
@@ -694,7 +702,8 @@ err:
 
 static int br_ip4_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
-				      __be32 group)
+				      __be32 group,
+				      __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -703,6 +712,7 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 
 	br_group.u.ip4 = group;
 	br_group.proto = htons(ETH_P_IP);
+	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
 }
@@ -710,7 +720,8 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
-				      const struct in6_addr *group)
+				      const struct in6_addr *group,
+				      __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -719,6 +730,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 
 	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
+	br_group.vid = vid;
 
 	return br_multicast_add_group(br, port, &br_group);
 }
@@ -930,7 +942,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip4_multicast_add_group(br, port, group);
+		err = br_ip4_multicast_add_group(br, port, group,
+						 br_get_vlan(skb));
 		if (err)
 			break;
 	}
@@ -990,7 +1003,8 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
+		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
+						 br_get_vlan(skb));
 		if (!err)
 			break;
 	}
@@ -1108,7 +1122,8 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group,
+			    br_get_vlan(skb));
 	if (!mp)
 		goto out;
 
@@ -1180,7 +1195,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group,
+			    br_get_vlan(skb));
 	if (!mp)
 		goto out;
 
@@ -1286,7 +1302,8 @@ out:
 
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
-					 __be32 group)
+					 __be32 group,
+					 __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -1295,6 +1312,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 
 	br_group.u.ip4 = group;
 	br_group.proto = htons(ETH_P_IP);
+	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
 }
@@ -1302,7 +1320,8 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 #if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
-					 const struct in6_addr *group)
+					 const struct in6_addr *group,
+					 __u16 vid)
 {
 	struct br_ip br_group;
 
@@ -1311,6 +1330,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 
 	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
+	br_group.vid = vid;
 
 	br_multicast_leave_group(br, port, &br_group);
 }
@@ -1393,7 +1413,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip4_multicast_add_group(br, port, ih->group);
+		err = br_ip4_multicast_add_group(br, port, ih->group,
+						 br_get_vlan(skb2));
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		err = br_ip4_multicast_igmp3_report(br, port, skb2);
@@ -1402,7 +1423,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group);
+		br_ip4_multicast_leave_group(br, port, ih->group,
+					     br_get_vlan(skb2));
 		break;
 	}
 
@@ -1522,7 +1544,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca,
+						 br_get_vlan(skb2));
 		break;
 	    }
 	case ICMPV6_MLD2_REPORT:
@@ -1539,7 +1562,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 			goto out;
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
-		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca,
+					     br_get_vlan(skb2));
 	    }
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c5aacfc..45e4169 100644
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
