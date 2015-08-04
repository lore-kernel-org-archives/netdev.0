From: Richard Laing <richard.laing@alliedtelesis.co.nz>
Subject: [PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue,  4 Aug 2015 13:28:47 +1200
Message-ID: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Cc: jmorris@namei.org,
	Richard Laing <richard.laing@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:34323 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbHDB3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 21:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable flow-based ECMP.

Currently if equal-cost multipath is enabled the kernel chooses between
equal cost paths for each matching packet, essentially packets are
round-robined between the routes. This means that packets from a single
flow can traverse different routes. If one of the routes experiences
congestion this can result in delayed or out of order packets arriving
at the destination.

This patch allows packets to be routed based on their flow - packets
in the same flow will always use the same route. This prevents out of
order packets. There are other issues with round-robin based ECMP routing
related to variable path MTU handling and debugging. The default
behaviour is changed by this patch to enable flow based ECMP routing
rather than the previous round-robin routing. The behaviour can be
changed using a new sysctl option /net/ipv4/route/flow_based_ecmp.

See RFC2991 for more details on the problems associated with packet
based ECMP routing.

This patch relies on the skb hash value to select between routes. The
selection uses a hash-threshold algorithm (see RFC2992).

Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
---

 include/net/flow.h       |    8 ++++++++
 include/net/ip_fib.h     |    4 ++++
 include/net/route.h      |    2 ++
 net/ipv4/fib_semantics.c |   30 ++++++++++++++++++++++++++++++
 net/ipv4/route.c         |   19 +++++++++++++++----
 5 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a15..b0a2524 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -79,6 +79,8 @@ struct flowi4 {
 #define fl4_ipsec_spi		uli.spi
 #define fl4_mh_type		uli.mht.type
 #define fl4_gre_key		uli.gre_key
+
+	__u32	flowi4_hash;
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
@@ -99,6 +101,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
 	fl4->fl4_sport = sport;
+	fl4->flowi4_hash = 0;
 }
 
 /* Reset some input parameters after previous lookup */
@@ -182,6 +185,11 @@ static inline struct flowi *flowidn_to_flowi(struct flowidn *fldn)
 	return container_of(fldn, struct flowi, u.dn);
 }
 
+static inline void flowi4_set_flow_hash(struct flowi4 *fl, __u32 hash)
+{
+	fl->flowi4_hash = hash;
+}
+
 typedef unsigned long flow_compare_t;
 
 static inline size_t flow_key_size(u16 family)
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5fa643b..7db9f72 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -117,6 +117,8 @@ struct fib_info {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_power;
 #endif
+	/* Cache the number of live nexthops for flow based ECMP calculation. */
+	int			live_nexthops;
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
@@ -310,6 +312,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 void fib_select_multipath(struct fib_result *res);
+void fib_select_multipath_for_flow(struct fib_result *res,
+				   const struct flowi4 *fl4);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03..a00e606 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -252,6 +252,8 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
+
+	flowi4_set_flow_hash(fl4, sk->sk_txhash);
 }
 
 static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3a06586..0a56ad3 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -981,6 +981,7 @@ link_it:
 		head = &fib_info_devhash[hash];
 		hlist_add_head(&nexthop_nh->nh_hash, head);
 	} endfor_nexthops(fi)
+	fi->live_nexthops = fi->fib_nhs;
 	spin_unlock_bh(&fib_info_lock);
 	return fi;
 
@@ -1196,6 +1197,7 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 			}
 			ret++;
 		}
+		fi->live_nexthops = fi->fib_nhs - dead;
 	}
 
 	return ret;
@@ -1331,6 +1333,7 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
 		if (alive > 0) {
 			fi->fib_flags &= ~nh_flags;
 			ret++;
+			fi->live_nexthops = alive;
 		}
 	}
 
@@ -1397,4 +1400,31 @@ void fib_select_multipath(struct fib_result *res)
 	res->nh_sel = 0;
 	spin_unlock_bh(&fib_multipath_lock);
 }
+
+void fib_select_multipath_for_flow(struct fib_result *res,
+				   const struct flowi4 *fl4)
+{
+	struct fib_info *fi = res->fi;
+	int multipath_entry;
+	int region_size;
+
+	if (fl4->flowi4_hash) {
+		/* Hash-threshold algorithm, see RFC2992. */
+		region_size = U32_MAX / fi->live_nexthops;
+		multipath_entry = fl4->flowi4_hash / region_size;
+
+		spin_lock_bh(&fib_multipath_lock);
+		for_nexthops(fi) {
+			if (!(nh->nh_flags & RTNH_F_DEAD)) {
+				res->nh_sel = nhsel;
+				if (multipath_entry == 0)
+					break;
+				multipath_entry--;
+			}
+		} endfor_nexthops(fi);
+		spin_unlock_bh(&fib_multipath_lock);
+	} else {
+		fib_select_multipath(res);
+	}
+}
 #endif
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e681b85..a9ac9ff 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -124,6 +124,7 @@ static int ip_rt_error_burst __read_mostly	= 5 * HZ;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
+static int ip_rt_flow_based_ecmp __read_mostly	= 1;
 
 /*
  *	Interface to generic destination cache.
@@ -1633,13 +1634,20 @@ out:
 
 static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
-			    const struct flowi4 *fl4,
+			    struct flowi4 *fl4,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->fi && res->fi->fib_nhs > 1)
-		fib_select_multipath(res);
+	if (res->fi && res->fi->fib_nhs > 1) {
+		if (ip_rt_flow_based_ecmp) {
+			if (skb)
+				flowi4_set_flow_hash(fl4, skb_get_hash(skb));
+			fib_select_multipath_for_flow(res, fl4);
+		} else {
+			fib_select_multipath(res);
+		}
+	}
 #endif
 
 	/* create a routing cache entry */
@@ -2170,7 +2178,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
-		fib_select_multipath(&res);
+		if (ip_rt_flow_based_ecmp)
+			fib_select_multipath_for_flow(&res, fl4);
+		else
+			fib_select_multipath(&res);
 	else
 #endif
 	if (!res.prefixlen &&
