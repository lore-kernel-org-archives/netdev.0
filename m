From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 10/14] nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
Date: Fri, 18 Sep 2015 11:05:56 -0500
Message-ID: <1442592360-2575-10-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50623 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbbIRQNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:13:47 -0400
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As gre does not have the srckey in the packet gre_pkt_to_tuple
needs to perform a lookup in it's per network namespace tables.

Pass in the proper network namespace to all pkt_to_tuple
implementations to ensure gre (and any similar protocols) can get this
right.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/nf_conntrack.h           |  3 ++-
 include/net/netfilter/nf_conntrack_core.h      |  1 +
 include/net/netfilter/nf_conntrack_l4proto.h   |  2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  4 ++--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  3 ++-
 net/netfilter/nf_conntrack_core.c              | 10 ++++++----
 net/netfilter/nf_conntrack_proto_dccp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |  2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |  3 +--
 net/netfilter/nf_conntrack_proto_sctp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |  2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |  1 +
 net/netfilter/nf_conntrack_proto_udplite.c     |  1 +
 net/netfilter/xt_connlimit.c                   |  2 +-
 net/openvswitch/conntrack.c                    |  2 +-
 net/sched/act_connmark.c                       |  2 +-
 16 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index e8ad46834df8..d642f68a7c73 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -191,7 +191,8 @@ int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 bool nf_ct_delete(struct nf_conn *ct, u32 pid, int report);
 
 bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
-		       u_int16_t l3num, struct nf_conntrack_tuple *tuple);
+		       u_int16_t l3num, struct net *net,
+		       struct nf_conntrack_tuple *tuple);
 bool nf_ct_invert_tuplepr(struct nf_conntrack_tuple *inverse,
 			  const struct nf_conntrack_tuple *orig);
 
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index c03f9c42b3cd..788ef58a66b9 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -41,6 +41,7 @@ void nf_conntrack_cleanup_end(void);
 
 bool nf_ct_get_tuple(const struct sk_buff *skb, unsigned int nhoff,
 		     unsigned int dataoff, u_int16_t l3num, u_int8_t protonum,
+		     struct net *net,
 		     struct nf_conntrack_tuple *tuple,
 		     const struct nf_conntrack_l3proto *l3proto,
 		     const struct nf_conntrack_l4proto *l4proto);
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 1f7061313d54..956d8a6ac069 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -26,7 +26,7 @@ struct nf_conntrack_l4proto {
 	/* Try to fill in the third arg: dataoff is offset past network protocol
            hdr.  Return true if possible. */
 	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int dataoff,
-			     struct nf_conntrack_tuple *tuple);
+			     struct net *net, struct nf_conntrack_tuple *tuple);
 
 	/* Invert the per-proto part of the tuple: ie. turn xmit into reply.
 	 * Some packets can't be inverted: return 0 in that case.
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index cdde3ec496e9..c567e1b5d799 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -30,7 +30,7 @@ static inline struct nf_icmp_net *icmp_pernet(struct net *net)
 }
 
 static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
-			      struct nf_conntrack_tuple *tuple)
+			      struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	const struct icmphdr *hp;
 	struct icmphdr _hdr;
@@ -144,7 +144,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	if (!nf_ct_get_tuplepr(skb,
 			       skb_network_offset(skb) + ip_hdrlen(skb)
 						       + sizeof(struct icmphdr),
-			       PF_INET, &origtuple)) {
+			       PF_INET, net, &origtuple)) {
 		pr_debug("icmp_error_message: failed to get tuple\n");
 		return -NF_ACCEPT;
 	}
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 0e6fae103d33..d3b797446cea 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -36,6 +36,7 @@ static inline struct nf_icmp_net *icmpv6_pernet(struct net *net)
 
 static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,
+				struct net *net,
 				struct nf_conntrack_tuple *tuple)
 {
 	const struct icmp6hdr *hp;
@@ -159,7 +160,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 			       skb_network_offset(skb)
 				+ sizeof(struct ipv6hdr)
 				+ sizeof(struct icmp6hdr),
-			       PF_INET6, &origtuple)) {
+			       PF_INET6, net, &origtuple)) {
 		pr_debug("icmpv6_error: Can't get tuple\n");
 		return -NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c09d6c7198f6..09d1d19b2ab9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -168,6 +168,7 @@ nf_ct_get_tuple(const struct sk_buff *skb,
 		unsigned int dataoff,
 		u_int16_t l3num,
 		u_int8_t protonum,
+		struct net *net,
 		struct nf_conntrack_tuple *tuple,
 		const struct nf_conntrack_l3proto *l3proto,
 		const struct nf_conntrack_l4proto *l4proto)
@@ -181,12 +182,13 @@ nf_ct_get_tuple(const struct sk_buff *skb,
 	tuple->dst.protonum = protonum;
 	tuple->dst.dir = IP_CT_DIR_ORIGINAL;
 
-	return l4proto->pkt_to_tuple(skb, dataoff, tuple);
+	return l4proto->pkt_to_tuple(skb, dataoff, net, tuple);
 }
 EXPORT_SYMBOL_GPL(nf_ct_get_tuple);
 
 bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
-		       u_int16_t l3num, struct nf_conntrack_tuple *tuple)
+		       u_int16_t l3num,
+		       struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -205,7 +207,7 @@ bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
 
 	l4proto = __nf_ct_l4proto_find(l3num, protonum);
 
-	ret = nf_ct_get_tuple(skb, nhoff, protoff, l3num, protonum, tuple,
+	ret = nf_ct_get_tuple(skb, nhoff, protoff, l3num, protonum, net, tuple,
 			      l3proto, l4proto);
 
 	rcu_read_unlock();
@@ -1029,7 +1031,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	u32 hash;
 
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
-			     dataoff, l3num, protonum, &tuple, l3proto,
+			     dataoff, l3num, protonum, net, &tuple, l3proto,
 			     l4proto)) {
 		pr_debug("resolve_normal_ct: Can't get tuple\n");
 		return NULL;
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 6dd995c7c72b..fce1b1cca32d 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -398,7 +398,7 @@ static inline struct dccp_net *dccp_pernet(struct net *net)
 }
 
 static bool dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
-			      struct nf_conntrack_tuple *tuple)
+			      struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	struct dccp_hdr _hdr, *dh;
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 2281be419a74..86dc752e5349 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -45,7 +45,7 @@ static inline struct nf_generic_net *generic_pernet(struct net *net)
 
 static bool generic_pkt_to_tuple(const struct sk_buff *skb,
 				 unsigned int dataoff,
-				 struct nf_conntrack_tuple *tuple)
+				 struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	tuple->src.u.all = 0;
 	tuple->dst.u.all = 0;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 7648674f29c3..a96451a7af20 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -190,9 +190,8 @@ static bool gre_invert_tuple(struct nf_conntrack_tuple *tuple,
 
 /* gre hdr info to tuple */
 static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
-			     struct nf_conntrack_tuple *tuple)
+			     struct net *net, struct nf_conntrack_tuple *tuple)
 {
-	struct net *net = dev_net(skb->dev ? skb->dev : skb_dst(skb)->dev);
 	const struct gre_hdr_pptp *pgrehdr;
 	struct gre_hdr_pptp _pgrehdr;
 	__be16 srckey;
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 67197731eb68..9578a7c371ef 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -156,7 +156,7 @@ static inline struct sctp_net *sctp_pernet(struct net *net)
 }
 
 static bool sctp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
-			      struct nf_conntrack_tuple *tuple)
+			      struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	const struct sctphdr *hp;
 	struct sctphdr _hdr;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 70383de72054..278f3b9356ef 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -277,7 +277,7 @@ static inline struct nf_tcp_net *tcp_pernet(struct net *net)
 }
 
 static bool tcp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
-			     struct nf_conntrack_tuple *tuple)
+			     struct net *net, struct nf_conntrack_tuple *tuple)
 {
 	const struct tcphdr *hp;
 	struct tcphdr _hdr;
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 6957281ffee5..478f92f834b6 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -38,6 +38,7 @@ static inline struct nf_udp_net *udp_pernet(struct net *net)
 
 static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 			     unsigned int dataoff,
+			     struct net *net,
 			     struct nf_conntrack_tuple *tuple)
 {
 	const struct udphdr *hp;
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index c5903d1649f9..1ac8ee13a873 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -48,6 +48,7 @@ static inline struct udplite_net *udplite_pernet(struct net *net)
 
 static bool udplite_pkt_to_tuple(const struct sk_buff *skb,
 				 unsigned int dataoff,
+				 struct net *net,
 				 struct nf_conntrack_tuple *tuple)
 {
 	const struct udphdr *hp;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 213db252e5be..99bbc829868d 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -332,7 +332,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 		zone = nf_ct_zone(ct);
 	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-				    par->family, &tuple)) {
+				      par->family, net, &tuple)) {
 		goto hotdrop;
 	}
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e8e524ad8a01..aaf5cbd6d9ae 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -345,7 +345,7 @@ ovs_ct_expect_find(struct net *net, const struct nf_conntrack_zone *zone,
 {
 	struct nf_conntrack_tuple tuple;
 
-	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb), proto, &tuple))
+	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb), proto, net, &tuple))
 		return NULL;
 	return __nf_ct_expect_find(net, zone, &tuple);
 }
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 5019a47b9270..bad1f417c9d9 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -68,7 +68,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-			       proto, &tuple))
+			       proto, ca->net, &tuple))
 		goto out;
 
 	zone.id = ca->zone;
-- 
2.2.1
