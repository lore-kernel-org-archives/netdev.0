From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 13/15] nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
Date: Sun, 14 Jun 2015 22:13:11 -0500
Message-ID: <1434337993-6248-13-git-send-email-ebiederm@xmission.com>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/sched/act_connmark.c                       |  2 +-
 15 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 095433b8a8b0..b6d2b3e2d8fb 100644
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
index f2f0fa3bb150..1883f686f30b 100644
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
index 80d5554b9a88..23125c3559bf 100644
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
@@ -142,7 +142,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	if (!nf_ct_get_tuplepr(skb,
 			       skb_network_offset(skb) + ip_hdrlen(skb)
 						       + sizeof(struct icmphdr),
-			       PF_INET, &origtuple)) {
+			       PF_INET, net, &origtuple)) {
 		pr_debug("icmp_error_message: failed to get tuple\n");
 		return -NF_ACCEPT;
 	}
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 90388d606483..d13d669daeb5 100644
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
index 13fad8668f83..9e5ab4fc79a4 100644
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
@@ -1011,7 +1013,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
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
index 60865f110309..acd3a7451aad 100644
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
index b45da90fad32..a413a1d8b0dd 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -142,7 +142,7 @@ static inline struct sctp_net *sctp_pernet(struct net *net)
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
index d150f3af4b42..85abe8c54592 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -331,7 +331,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 		zone = nf_ct_zone(ct);
 	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-				    par->family, &tuple)) {
+				      par->family, net, &tuple)) {
 		goto hotdrop;
 	}
 
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 295d14bd6c67..ad4b13a2478e 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -67,7 +67,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-			       proto, &tuple))
+			       proto, ca->net, &tuple))
 		goto out;
 
 	thash = nf_conntrack_find_get(dev_net(skb->dev), ca->zone, &tuple);
-- 
2.2.1

