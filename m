From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/25] net: Put flowi_* prefix on AF independent members of
 struct flowi
Date: Sat, 12 Mar 2011 15:25:48 -0800 (PST)
Message-ID: <20110312.152548.59679471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926Ab1CLXZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:25:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F388824C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:25:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I intend to turn struct flowi into a union of AF specific flowi
structs.  There will be a common structure that each variant includes
first, much like struct sock_common.

This is the first step to move in that direction.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c   |    2 +-
 drivers/net/cnic.c               |    2 +-
 include/net/dn_route.h           |    4 +-
 include/net/flow.h               |   22 ++++----
 include/net/route.h              |   36 +++++++-------
 include/net/xfrm.h               |    4 +-
 net/core/fib_rules.c             |    6 +-
 net/dccp/ipv4.c                  |   17 ++++---
 net/dccp/ipv6.c                  |   20 ++++----
 net/decnet/af_decnet.c           |    4 +-
 net/decnet/dn_fib.c              |    4 +-
 net/decnet/dn_nsp_out.c          |    4 +-
 net/decnet/dn_route.c            |   96 ++++++++++++++++++++------------------
 net/ipv4/fib_frontend.c          |   12 ++--
 net/ipv4/fib_semantics.c         |    2 +-
 net/ipv4/fib_trie.c              |    2 +-
 net/ipv4/icmp.c                  |   12 +++--
 net/ipv4/inet_connection_sock.c  |   22 +++++----
 net/ipv4/ip_output.c             |   18 ++++---
 net/ipv4/ipmr.c                  |   12 ++--
 net/ipv4/netfilter.c             |    6 +-
 net/ipv4/raw.c                   |   10 ++--
 net/ipv4/route.c                 |   72 ++++++++++++++--------------
 net/ipv4/syncookies.c            |   20 ++++----
 net/ipv4/udp.c                   |   21 ++++----
 net/ipv4/xfrm4_policy.c          |   10 ++--
 net/ipv4/xfrm4_state.c           |    4 +-
 net/ipv6/af_inet6.c              |    6 +-
 net/ipv6/datagram.c              |   20 ++++----
 net/ipv6/icmp.c                  |   24 +++++-----
 net/ipv6/inet6_connection_sock.c |   12 ++--
 net/ipv6/ip6_flowlabel.c         |    2 +-
 net/ipv6/ip6_output.c            |   10 ++--
 net/ipv6/ip6_tunnel.c            |    8 ++--
 net/ipv6/ip6mr.c                 |   22 ++++----
 net/ipv6/ipv6_sockglue.c         |    4 +-
 net/ipv6/mip6.c                  |    6 +-
 net/ipv6/netfilter.c             |    4 +-
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/raw.c                   |   20 ++++----
 net/ipv6/route.c                 |   20 ++++----
 net/ipv6/syncookies.c            |    6 +-
 net/ipv6/tcp_ipv6.c              |   22 ++++----
 net/ipv6/udp.c                   |   20 ++++----
 net/ipv6/xfrm6_policy.c          |   10 ++--
 net/ipv6/xfrm6_state.c           |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c  |    2 +-
 net/netfilter/xt_TEE.c           |    4 +-
 net/sctp/ipv6.c                  |    8 ++--
 net/sctp/protocol.c              |    4 +-
 net/xfrm/xfrm_policy.c           |   18 ++++----
 net/xfrm/xfrm_state.c            |    2 +-
 security/security.c              |    4 +-
 security/selinux/hooks.c         |    2 +-
 security/selinux/xfrm.c          |    4 +-
 56 files changed, 365 insertions(+), 351 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 1742f72..3c2b309 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -239,7 +239,7 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 	memset(&fl, 0, sizeof fl);
 	ipv6_addr_copy(&fl.fl6_dst, &dst_in->sin6_addr);
 	ipv6_addr_copy(&fl.fl6_src, &src_in->sin6_addr);
-	fl.oif = addr->bound_dev_if;
+	fl.flowi_oif = addr->bound_dev_if;
 
 	dst = ip6_route_output(&init_net, NULL, &fl);
 	if ((ret = dst->error))
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6583295..c8922f6 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3429,7 +3429,7 @@ static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &dst_addr->sin6_addr);
 	if (ipv6_addr_type(&fl.fl6_dst) & IPV6_ADDR_LINKLOCAL)
-		fl.oif = dst_addr->sin6_scope_id;
+		fl.flowi_oif = dst_addr->sin6_scope_id;
 
 	*dst = ip6_route_output(&init_net, NULL, &fl);
 	if (*dst)
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 9b185df..1f59005 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -82,12 +82,12 @@ struct dn_route {
 
 static inline bool dn_is_input_route(struct dn_route *rt)
 {
-	return rt->fl.iif != 0;
+	return rt->fl.flowi_iif != 0;
 }
 
 static inline bool dn_is_output_route(struct dn_route *rt)
 {
-	return rt->fl.iif == 0;
+	return rt->fl.flowi_iif == 0;
 }
 
 extern void dn_route_init(void);
diff --git a/include/net/flow.h b/include/net/flow.h
index a661fd6..8c4dbd0 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -11,17 +11,17 @@
 #include <asm/atomic.h>
 
 struct flowi {
-	int	oif;
-	int	iif;
-	__u32	mark;
-	__u8	tos;
-	__u8	scope;
-	__u8	proto;
-	__u8	flags;
+	int	flowi_oif;
+	int	flowi_iif;
+	__u32	flowi_mark;
+	__u8	flowi_tos;
+	__u8	flowi_scope;
+	__u8	flowi_proto;
+	__u8	flowi_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_PRECOW_METRICS	0x02
 #define FLOWI_FLAG_CAN_SLEEP		0x04
-	__u32	secid;
+	__u32	flowi_secid;
 
 	union {
 		struct {
@@ -49,8 +49,8 @@ struct flowi {
 #define fl6_flowlabel	nl_u.ip6_u.flowlabel
 #define fl4_dst		nl_u.ip4_u.daddr
 #define fl4_src		nl_u.ip4_u.saddr
-#define fl4_tos		tos
-#define fl4_scope	scope
+#define fl4_tos		flowi_tos
+#define fl4_scope	flowi_scope
 
 	union {
 		struct {
@@ -116,7 +116,7 @@ extern atomic_t flow_cache_genid;
 static inline int flow_cache_uli_match(const struct flowi *fl1,
 				       const struct flowi *fl2)
 {
-	return (fl1->proto == fl2->proto &&
+	return (fl1->flowi_proto == fl2->flowi_proto &&
 		!memcmp(&fl1->uli_u, &fl2->uli_u, sizeof(fl1->uli_u)));
 }
 
diff --git a/include/net/route.h b/include/net/route.h
index f140f41..3d814f8 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -136,7 +136,7 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 					     __be32 saddr, u8 tos, int oif)
 {
 	struct flowi fl = {
-		.oif = oif,
+		.flowi_oif = oif,
 		.fl4_dst = daddr,
 		.fl4_src = saddr,
 		.fl4_tos = tos,
@@ -150,13 +150,13 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct sock
 						   __u8 proto, __u8 tos, int oif)
 {
 	struct flowi fl = {
-		.oif = oif,
-		.flags = sk ? inet_sk_flowi_flags(sk) : 0,
-		.mark = sk ? sk->sk_mark : 0,
+		.flowi_oif = oif,
+		.flowi_flags = sk ? inet_sk_flowi_flags(sk) : 0,
+		.flowi_mark = sk ? sk->sk_mark : 0,
 		.fl4_dst = daddr,
 		.fl4_src = saddr,
 		.fl4_tos = tos,
-		.proto = proto,
+		.flowi_proto = proto,
 		.fl_ip_dport = dport,
 		.fl_ip_sport = sport,
 	};
@@ -170,11 +170,11 @@ static inline struct rtable *ip_route_output_gre(struct net *net,
 						 __be32 gre_key, __u8 tos, int oif)
 {
 	struct flowi fl = {
-		.oif = oif,
+		.flowi_oif = oif,
 		.fl4_dst = daddr,
 		.fl4_src = saddr,
 		.fl4_tos = tos,
-		.proto = IPPROTO_GRE,
+		.flowi_proto = IPPROTO_GRE,
 		.fl_gre_key = gre_key,
 	};
 	return ip_route_output_key(net, &fl);
@@ -228,23 +228,23 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 					      __be16 sport, __be16 dport,
 					      struct sock *sk, bool can_sleep)
 {
-	struct flowi fl = { .oif = oif,
-			    .mark = sk->sk_mark,
+	struct flowi fl = { .flowi_oif = oif,
+			    .flowi_mark = sk->sk_mark,
 			    .fl4_dst = dst,
 			    .fl4_src = src,
 			    .fl4_tos = tos,
-			    .proto = protocol,
+			    .flowi_proto = protocol,
 			    .fl_ip_sport = sport,
 			    .fl_ip_dport = dport };
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
 
 	if (inet_sk(sk)->transparent)
-		fl.flags |= FLOWI_FLAG_ANYSRC;
+		fl.flowi_flags |= FLOWI_FLAG_ANYSRC;
 	if (protocol == IPPROTO_TCP)
-		fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
+		fl.flowi_flags |= FLOWI_FLAG_PRECOW_METRICS;
 	if (can_sleep)
-		fl.flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl.flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	if (!dst || !src) {
 		rt = __ip_route_output_key(net, &fl);
@@ -264,19 +264,19 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = { .oif = rt->rt_oif,
-				    .mark = rt->rt_mark,
+		struct flowi fl = { .flowi_oif = rt->rt_oif,
+				    .flowi_mark = rt->rt_mark,
 				    .fl4_dst = rt->rt_key_dst,
 				    .fl4_src = rt->rt_key_src,
 				    .fl4_tos = rt->rt_tos,
-				    .proto = protocol,
+				    .flowi_proto = protocol,
 				    .fl_ip_sport = sport,
 				    .fl_ip_dport = dport };
 
 		if (inet_sk(sk)->transparent)
-			fl.flags |= FLOWI_FLAG_ANYSRC;
+			fl.flowi_flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
-			fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
+			fl.flowi_flags |= FLOWI_FLAG_PRECOW_METRICS;
 		ip_rt_put(rt);
 		security_sk_classify_flow(sk, &fl);
 		return ip_route_output_flow(sock_net(sk), &fl, sk);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d5dcf39..d5a12d1 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -803,7 +803,7 @@ static __inline__
 __be16 xfrm_flowi_sport(const struct flowi *fl)
 {
 	__be16 port;
-	switch(fl->proto) {
+	switch(fl->flowi_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
@@ -830,7 +830,7 @@ static __inline__
 __be16 xfrm_flowi_dport(const struct flowi *fl)
 {
 	__be16 port;
-	switch(fl->proto) {
+	switch(fl->flowi_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index a20e5d3..8248ebb 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -181,13 +181,13 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 {
 	int ret = 0;
 
-	if (rule->iifindex && (rule->iifindex != fl->iif))
+	if (rule->iifindex && (rule->iifindex != fl->flowi_iif))
 		goto out;
 
-	if (rule->oifindex && (rule->oifindex != fl->oif))
+	if (rule->oifindex && (rule->oifindex != fl->flowi_oif))
 		goto out;
 
-	if ((rule->mark ^ fl->mark) & rule->mark_mask)
+	if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
 		goto out;
 
 	ret = ops->match(rule, fl, flags);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7882377..09a0991 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -465,14 +465,15 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
-	struct flowi fl = { .oif = skb_rtable(skb)->rt_iif,
-			    .fl4_dst = ip_hdr(skb)->saddr,
-			    .fl4_src = ip_hdr(skb)->daddr,
-			    .fl4_tos = RT_CONN_FLAGS(sk),
-			    .proto = sk->sk_protocol,
-			    .fl_ip_sport = dccp_hdr(skb)->dccph_dport,
-			    .fl_ip_dport = dccp_hdr(skb)->dccph_sport
-			  };
+	struct flowi fl = {
+		.flowi_oif = skb_rtable(skb)->rt_iif,
+		.fl4_dst = ip_hdr(skb)->saddr,
+		.fl4_src = ip_hdr(skb)->daddr,
+		.fl4_tos = RT_CONN_FLAGS(sk),
+		.flowi_proto = sk->sk_protocol,
+		.fl_ip_sport = dccp_hdr(skb)->dccph_dport,
+		.fl_ip_dport = dccp_hdr(skb)->dccph_sport,
+	};
 
 	security_skb_classify_flow(skb, &fl);
 	rt = ip_route_output_flow(net, &fl, sk);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5efc57f..5209ee7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -154,10 +154,10 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			   for now.
 			 */
 			memset(&fl, 0, sizeof(fl));
-			fl.proto = IPPROTO_DCCP;
+			fl.flowi_proto = IPPROTO_DCCP;
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-			fl.oif = sk->sk_bound_dev_if;
+			fl.flowi_oif = sk->sk_bound_dev_if;
 			fl.fl_ip_dport = inet->inet_dport;
 			fl.fl_ip_sport = inet->inet_sport;
 			security_sk_classify_flow(sk, &fl);
@@ -248,11 +248,11 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	struct dst_entry *dst;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_DCCP;
+	fl.flowi_proto = IPPROTO_DCCP;
 	ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
 	ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 	fl.fl6_flowlabel = 0;
-	fl.oif = ireq6->iif;
+	fl.flowi_oif = ireq6->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
@@ -321,8 +321,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	ipv6_addr_copy(&fl.fl6_dst, &rxip6h->saddr);
 	ipv6_addr_copy(&fl.fl6_src, &rxip6h->daddr);
 
-	fl.proto = IPPROTO_DCCP;
-	fl.oif = inet6_iif(rxskb);
+	fl.flowi_proto = IPPROTO_DCCP;
+	fl.flowi_oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dccp_hdr(skb)->dccph_dport;
 	fl.fl_ip_sport = dccp_hdr(skb)->dccph_sport;
 	security_skb_classify_flow(rxskb, &fl);
@@ -530,11 +530,11 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
-		fl.proto = IPPROTO_DCCP;
+		fl.flowi_proto = IPPROTO_DCCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
 		final_p = fl6_update_dst(&fl, opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
-		fl.oif = sk->sk_bound_dev_if;
+		fl.flowi_oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_rsk(req)->loc_port;
 		security_sk_classify_flow(sk, &fl);
@@ -953,10 +953,10 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!ipv6_addr_any(&np->rcv_saddr))
 		saddr = &np->rcv_saddr;
 
-	fl.proto = IPPROTO_DCCP;
+	fl.flowi_proto = IPPROTO_DCCP;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
-	fl.oif = sk->sk_bound_dev_if;
+	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, &fl);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2af15b1..aafd15a 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -948,11 +948,11 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 
 	err = -EHOSTUNREACH;
 	memset(&fl, 0, sizeof(fl));
-	fl.oif = sk->sk_bound_dev_if;
+	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.fld_dst = dn_saddr2dn(&scp->peer);
 	fl.fld_src = dn_saddr2dn(&scp->addr);
 	dn_sk_ports_copy(&fl, scp);
-	fl.proto = DNPROTO_NSP;
+	fl.flowi_proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, flags) < 0)
 		goto out;
 	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 0ef0a81..4dfffa0 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -223,7 +223,7 @@ static int dn_fib_check_nh(const struct rtmsg *r, struct dn_fib_info *fi, struct
 
 		memset(&fl, 0, sizeof(fl));
 		fl.fld_dst = nh->nh_gw;
-		fl.oif = nh->nh_oif;
+		fl.flowi_oif = nh->nh_oif;
 		fl.fld_scope = r->rtm_scope + 1;
 
 		if (fl.fld_scope < RT_SCOPE_LINK)
@@ -424,7 +424,7 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowi *
 				for_nexthops(fi) {
 					if (nh->nh_flags & RTNH_F_DEAD)
 						continue;
-					if (!fl->oif || fl->oif == nh->nh_oif)
+					if (!fl->flowi_oif || fl->flowi_oif == nh->nh_oif)
 						break;
 				}
 				if (nhsel < fi->fib_nhs) {
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 2ef1152..b3d6674 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -92,11 +92,11 @@ try_again:
 	}
 
 	memset(&fl, 0, sizeof(fl));
-	fl.oif = sk->sk_bound_dev_if;
+	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.fld_src = dn_saddr2dn(&scp->addr);
 	fl.fld_dst = dn_saddr2dn(&scp->peer);
 	dn_sk_ports_copy(&fl, scp);
-	fl.proto = DNPROTO_NSP;
+	fl.flowi_proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, 0) == 0) {
 		dst = sk_dst_get(sk);
 		sk->sk_route_caps = dst->dev->features;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 484fdbf..d74d34b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -286,10 +286,10 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
 	return ((fl1->fld_dst ^ fl2->fld_dst) |
 		(fl1->fld_src ^ fl2->fld_src) |
-		(fl1->mark ^ fl2->mark) |
+		(fl1->flowi_mark ^ fl2->flowi_mark) |
 		(fl1->fld_scope ^ fl2->fld_scope) |
-		(fl1->oif ^ fl2->oif) |
-		(fl1->iif ^ fl2->iif)) == 0;
+		(fl1->flowi_oif ^ fl2->flowi_oif) |
+		(fl1->flowi_iif ^ fl2->flowi_iif)) == 0;
 }
 
 static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
@@ -905,12 +905,14 @@ static inline __le16 dn_fib_rules_map_destination(__le16 daddr, struct dn_fib_re
 
 static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *oldflp, int try_hard)
 {
-	struct flowi fl = { .fld_dst = oldflp->fld_dst,
-			    .fld_src = oldflp->fld_src,
-			    .fld_scope = RT_SCOPE_UNIVERSE,
-			    .mark = oldflp->mark,
-			    .iif = init_net.loopback_dev->ifindex,
-			    .oif = oldflp->oif };
+	struct flowi fl = {
+		.fld_dst = oldflp->fld_dst,
+		.fld_src = oldflp->fld_src,
+		.fld_scope = RT_SCOPE_UNIVERSE,
+		.flowi_mark = oldflp->flowi_mark,
+		.flowi_iif = init_net.loopback_dev->ifindex,
+		.flowi_oif = oldflp->flowi_oif,
+	};
 	struct dn_route *rt = NULL;
 	struct net_device *dev_out = NULL, *dev;
 	struct neighbour *neigh = NULL;
@@ -926,11 +928,11 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 		       "dn_route_output_slow: dst=%04x src=%04x mark=%d"
 		       " iif=%d oif=%d\n", le16_to_cpu(oldflp->fld_dst),
 		       le16_to_cpu(oldflp->fld_src),
-		       oldflp->mark, init_net.loopback_dev->ifindex, oldflp->oif);
+		       oldflp->flowi_mark, init_net.loopback_dev->ifindex, oldflp->flowi_oif);
 
 	/* If we have an output interface, verify its a DECnet device */
-	if (oldflp->oif) {
-		dev_out = dev_get_by_index(&init_net, oldflp->oif);
+	if (oldflp->flowi_oif) {
+		dev_out = dev_get_by_index(&init_net, oldflp->flowi_oif);
 		err = -ENODEV;
 		if (dev_out && dev_out->dn_ptr == NULL) {
 			dev_put(dev_out);
@@ -988,7 +990,7 @@ source_ok:
 			if (!fl.fld_dst)
 				goto out;
 		}
-		fl.oif = init_net.loopback_dev->ifindex;
+		fl.flowi_oif = init_net.loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		goto make_route;
 	}
@@ -998,7 +1000,7 @@ source_ok:
 		       "dn_route_output_slow: initial checks complete."
 		       " dst=%o4x src=%04x oif=%d try_hard=%d\n",
 		       le16_to_cpu(fl.fld_dst), le16_to_cpu(fl.fld_src),
-		       fl.oif, try_hard);
+		       fl.flowi_oif, try_hard);
 
 	/*
 	 * N.B. If the kernel is compiled without router support then
@@ -1023,8 +1025,8 @@ source_ok:
 		if (!try_hard) {
 			neigh = neigh_lookup_nodev(&dn_neigh_table, &init_net, &fl.fld_dst);
 			if (neigh) {
-				if ((oldflp->oif &&
-				    (neigh->dev->ifindex != oldflp->oif)) ||
+				if ((oldflp->flowi_oif &&
+				    (neigh->dev->ifindex != oldflp->flowi_oif)) ||
 				    (oldflp->fld_src &&
 				    (!dn_dev_islocal(neigh->dev,
 						      oldflp->fld_src)))) {
@@ -1078,7 +1080,7 @@ select_source:
 			if (fl.fld_src == 0 && res.type != RTN_LOCAL)
 				goto e_addr;
 		}
-		fl.oif = dev_out->ifindex;
+		fl.flowi_oif = dev_out->ifindex;
 		goto make_route;
 	}
 	free_res = 1;
@@ -1093,14 +1095,14 @@ select_source:
 			dev_put(dev_out);
 		dev_out = init_net.loopback_dev;
 		dev_hold(dev_out);
-		fl.oif = dev_out->ifindex;
+		fl.flowi_oif = dev_out->ifindex;
 		if (res.fi)
 			dn_fib_info_put(res.fi);
 		res.fi = NULL;
 		goto make_route;
 	}
 
-	if (res.fi->fib_nhs > 1 && fl.oif == 0)
+	if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
 		dn_fib_select_multipath(&fl, &res);
 
 	/*
@@ -1115,7 +1117,7 @@ select_source:
 		dev_put(dev_out);
 	dev_out = DN_FIB_RES_DEV(res);
 	dev_hold(dev_out);
-	fl.oif = dev_out->ifindex;
+	fl.flowi_oif = dev_out->ifindex;
 	gateway = DN_FIB_RES_GW(res);
 
 make_route:
@@ -1131,9 +1133,9 @@ make_route:
 
 	rt->fl.fld_src    = oldflp->fld_src;
 	rt->fl.fld_dst    = oldflp->fld_dst;
-	rt->fl.oif        = oldflp->oif;
-	rt->fl.iif        = 0;
-	rt->fl.mark       = oldflp->mark;
+	rt->fl.flowi_oif     = oldflp->flowi_oif;
+	rt->fl.flowi_iif     = 0;
+	rt->fl.flowi_mark    = oldflp->flowi_mark;
 
 	rt->rt_saddr      = fl.fld_src;
 	rt->rt_daddr      = fl.fld_dst;
@@ -1201,9 +1203,9 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *fl
 			rt = rcu_dereference_bh(rt->dst.dn_next)) {
 			if ((flp->fld_dst == rt->fl.fld_dst) &&
 			    (flp->fld_src == rt->fl.fld_src) &&
-			    (flp->mark == rt->fl.mark) &&
+			    (flp->flowi_mark == rt->fl.flowi_mark) &&
 			    dn_is_output_route(rt) &&
-			    (rt->fl.oif == flp->oif)) {
+			    (rt->fl.flowi_oif == flp->flowi_oif)) {
 				dst_use(&rt->dst, jiffies);
 				rcu_read_unlock_bh();
 				*pprt = &rt->dst;
@@ -1221,7 +1223,7 @@ static int dn_route_output_key(struct dst_entry **pprt, struct flowi *flp, int f
 	int err;
 
 	err = __dn_route_output_key(pprt, flp, flags);
-	if (err == 0 && flp->proto) {
+	if (err == 0 && flp->flowi_proto) {
 		*pprt = xfrm_lookup(&init_net, *pprt, flp, NULL, 0);
 		if (IS_ERR(*pprt)) {
 			err = PTR_ERR(*pprt);
@@ -1236,9 +1238,9 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 	int err;
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
-	if (err == 0 && fl->proto) {
+	if (err == 0 && fl->flowi_proto) {
 		if (!(flags & MSG_DONTWAIT))
-			fl->flags |= FLOWI_FLAG_CAN_SLEEP;
+			fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
 		*pprt = xfrm_lookup(&init_net, *pprt, fl, sk, 0);
 		if (IS_ERR(*pprt)) {
 			err = PTR_ERR(*pprt);
@@ -1260,11 +1262,13 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	int flags = 0;
 	__le16 gateway = 0;
 	__le16 local_src = 0;
-	struct flowi fl = { .fld_dst = cb->dst,
-			    .fld_src = cb->src,
-			    .fld_scope = RT_SCOPE_UNIVERSE,
-			    .mark = skb->mark,
-			    .iif = skb->dev->ifindex };
+	struct flowi fl = {
+		.fld_dst = cb->dst,
+		.fld_src = cb->src,
+		.fld_scope = RT_SCOPE_UNIVERSE,
+		.flowi_mark = skb->mark,
+		.flowi_iif = skb->dev->ifindex,
+	};
 	struct dn_fib_res res = { .fi = NULL, .type = RTN_UNREACHABLE };
 	int err = -EINVAL;
 	int free_res = 0;
@@ -1343,7 +1347,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		if (dn_db->parms.forwarding == 0)
 			goto e_inval;
 
-		if (res.fi->fib_nhs > 1 && fl.oif == 0)
+		if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
 			dn_fib_select_multipath(&fl, &res);
 
 		/*
@@ -1408,9 +1412,9 @@ make_route:
 
 	rt->fl.fld_src    = cb->src;
 	rt->fl.fld_dst    = cb->dst;
-	rt->fl.oif        = 0;
-	rt->fl.iif        = in_dev->ifindex;
-	rt->fl.mark       = fl.mark;
+	rt->fl.flowi_oif     = 0;
+	rt->fl.flowi_iif     = in_dev->ifindex;
+	rt->fl.flowi_mark    = fl.flowi_mark;
 
 	rt->dst.flags = DST_HOST;
 	rt->dst.neighbour = neigh;
@@ -1482,9 +1486,9 @@ static int dn_route_input(struct sk_buff *skb)
 	    rt = rcu_dereference(rt->dst.dn_next)) {
 		if ((rt->fl.fld_src == cb->src) &&
 		    (rt->fl.fld_dst == cb->dst) &&
-		    (rt->fl.oif == 0) &&
-		    (rt->fl.mark == skb->mark) &&
-		    (rt->fl.iif == cb->iif)) {
+		    (rt->fl.flowi_oif == 0) &&
+		    (rt->fl.flowi_mark == skb->mark) &&
+		    (rt->fl.flowi_iif == cb->iif)) {
 			dst_use(&rt->dst, jiffies);
 			rcu_read_unlock();
 			skb_dst_set(skb, (struct dst_entry *)rt);
@@ -1541,7 +1545,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 			       rt->dst.error) < 0)
 		goto rtattr_failure;
 	if (dn_is_input_route(rt))
-		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
+		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.flowi_iif);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
@@ -1570,7 +1574,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		return -EINVAL;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = DNPROTO_NSP;
+	fl.flowi_proto = DNPROTO_NSP;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
@@ -1583,11 +1587,11 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	if (rta[RTA_DST-1])
 		memcpy(&fl.fld_dst, RTA_DATA(rta[RTA_DST-1]), 2);
 	if (rta[RTA_IIF-1])
-		memcpy(&fl.iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
+		memcpy(&fl.flowi_iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
 
-	if (fl.iif) {
+	if (fl.flowi_iif) {
 		struct net_device *dev;
-		if ((dev = dev_get_by_index(&init_net, fl.iif)) == NULL) {
+		if ((dev = dev_get_by_index(&init_net, fl.flowi_iif)) == NULL) {
 			kfree_skb(skb);
 			return -ENODEV;
 		}
@@ -1611,7 +1615,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		int oif = 0;
 		if (rta[RTA_OIF - 1])
 			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
-		fl.oif = oif;
+		fl.flowi_oif = oif;
 		err = dn_route_output_key((struct dst_entry **)&rt, &fl, 0);
 	}
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index fe10bcd..7610528 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -200,9 +200,9 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	int ret;
 	struct net *net;
 
-	fl.oif = 0;
-	fl.iif = oif;
-	fl.mark = mark;
+	fl.flowi_oif = 0;
+	fl.flowi_iif = oif;
+	fl.flowi_mark = mark;
 	fl.fl4_dst = src;
 	fl.fl4_src = dst;
 	fl.fl4_tos = tos;
@@ -215,7 +215,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		rpf = IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
 		if (mark && !IN_DEV_SRC_VMARK(in_dev))
-			fl.mark = 0;
+			fl.flowi_mark = 0;
 	}
 
 	if (in_dev == NULL)
@@ -253,7 +253,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		goto last_resort;
 	if (rpf == 1)
 		goto e_rpf;
-	fl.oif = dev->ifindex;
+	fl.flowi_oif = dev->ifindex;
 
 	ret = 0;
 	if (fib_lookup(net, &fl, &res) == 0) {
@@ -797,7 +797,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 
 	struct fib_result       res;
 	struct flowi            fl = {
-		.mark = frn->fl_mark,
+		.flowi_mark = frn->fl_mark,
 		.fl4_dst = frn->fl_addr,
 		.fl4_tos = frn->fl_tos,
 		.fl4_scope = frn->fl_scope,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b5d523b..79179ad 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -563,7 +563,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			struct flowi fl = {
 				.fl4_dst = nh->nh_gw,
 				.fl4_scope = cfg->fc_scope + 1,
-				.oif = nh->nh_oif,
+				.flowi_oif = nh->nh_oif,
 			};
 
 			/* It is not necessary, but requires a bit of thinking */
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index a4109a5..d5ff80e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1379,7 +1379,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 
 				if (nh->nh_flags & RTNH_F_DEAD)
 					continue;
-				if (flp->oif && flp->oif != nh->nh_oif)
+				if (flp->flowi_oif && flp->flowi_oif != nh->nh_oif)
 					continue;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 1771ce6..3fde7f2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -353,10 +353,12 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 			daddr = icmp_param->replyopts.faddr;
 	}
 	{
-		struct flowi fl = { .fl4_dst= daddr,
-				    .fl4_src = rt->rt_spec_dst,
-				    .fl4_tos = RT_TOS(ip_hdr(skb)->tos),
-				    .proto = IPPROTO_ICMP };
+		struct flowi fl = {
+			.fl4_dst = daddr,
+			.fl4_src = rt->rt_spec_dst,
+			.fl4_tos = RT_TOS(ip_hdr(skb)->tos),
+			.flowi_proto = IPPROTO_ICMP,
+		};
 		security_skb_classify_flow(skb, &fl);
 		rt = ip_route_output_key(net, &fl);
 		if (IS_ERR(rt))
@@ -381,7 +383,7 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 			    param->replyopts.faddr : iph->saddr),
 		.fl4_src = saddr,
 		.fl4_tos = RT_TOS(tos),
-		.proto = IPPROTO_ICMP,
+		.flowi_proto = IPPROTO_ICMP,
 		.fl_icmp_type = type,
 		.fl_icmp_code = code,
 	};
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index e4e301a..9708170 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -356,16 +356,18 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options *opt = inet_rsk(req)->opt;
-	struct flowi fl = { .oif = sk->sk_bound_dev_if,
-			    .mark = sk->sk_mark,
-			    .fl4_dst = ((opt && opt->srr) ?
-					  opt->faddr : ireq->rmt_addr),
-			    .fl4_src = ireq->loc_addr,
-			    .fl4_tos = RT_CONN_FLAGS(sk),
-			    .proto = sk->sk_protocol,
-			    .flags = inet_sk_flowi_flags(sk),
-			    .fl_ip_sport = inet_sk(sk)->inet_sport,
-			    .fl_ip_dport = ireq->rmt_port };
+	struct flowi fl = {
+		.flowi_oif = sk->sk_bound_dev_if,
+		.flowi_mark = sk->sk_mark,
+		.fl4_dst = ((opt && opt->srr) ?
+			    opt->faddr : ireq->rmt_addr),
+		.fl4_src = ireq->loc_addr,
+		.fl4_tos = RT_CONN_FLAGS(sk),
+		.flowi_proto = sk->sk_protocol,
+		.flowi_flags = inet_sk_flowi_flags(sk),
+		.fl_ip_sport = inet_sk(sk)->inet_sport,
+		.fl_ip_dport = ireq->rmt_port,
+	};
 	struct net *net = sock_net(sk);
 
 	security_req_classify_flow(req, &fl);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 916152d..e35ca40 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1474,14 +1474,16 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	}
 
 	{
-		struct flowi fl = { .oif = arg->bound_dev_if,
-				    .fl4_dst = daddr,
-				    .fl4_src = rt->rt_spec_dst,
-				    .fl4_tos = RT_TOS(ip_hdr(skb)->tos),
-				    .fl_ip_sport = tcp_hdr(skb)->dest,
-				    .fl_ip_dport = tcp_hdr(skb)->source,
-				    .proto = sk->sk_protocol,
-				    .flags = ip_reply_arg_flowi_flags(arg) };
+		struct flowi fl = {
+			.flowi_oif = arg->bound_dev_if,
+			.fl4_dst = daddr,
+			.fl4_src = rt->rt_spec_dst,
+			.fl4_tos = RT_TOS(ip_hdr(skb)->tos),
+			.fl_ip_sport = tcp_hdr(skb)->dest,
+			.fl_ip_dport = tcp_hdr(skb)->source,
+			.flowi_proto = sk->sk_protocol,
+			.flowi_flags = ip_reply_arg_flowi_flags(arg),
+		};
 		security_skb_classify_flow(skb, &fl);
 		rt = ip_route_output_key(sock_net(sk), &fl);
 		if (IS_ERR(rt))
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 594a300..3b72b0a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -436,9 +436,9 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct mr_table *mrt;
 	struct flowi fl = {
-		.oif		= dev->ifindex,
-		.iif		= skb->skb_iif,
-		.mark		= skb->mark,
+		.flowi_oif	= dev->ifindex,
+		.flowi_iif	= skb->skb_iif,
+		.flowi_mark	= skb->mark,
 	};
 	int err;
 
@@ -1793,9 +1793,9 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct rtable *rt)
 		.fl4_dst = rt->rt_key_dst,
 		.fl4_src = rt->rt_key_src,
 		.fl4_tos = rt->rt_tos,
-		.oif = rt->rt_oif,
-		.iif = rt->rt_iif,
-		.mark = rt->rt_mark,
+		.flowi_oif = rt->rt_oif,
+		.flowi_iif = rt->rt_iif,
+		.flowi_mark = rt->rt_mark,
 	};
 	struct mr_table *mrt;
 	int err;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 67bf709..6f40ba5 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -35,9 +35,9 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		if (type == RTN_LOCAL)
 			fl.fl4_src = iph->saddr;
 		fl.fl4_tos = RT_TOS(iph->tos);
-		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
-		fl.mark = skb->mark;
-		fl.flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
+		fl.flowi_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+		fl.flowi_mark = skb->mark;
+		fl.flowi_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
 		rt = ip_route_output_key(net, &fl);
 		if (IS_ERR(rt))
 			return -1;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 467d570..b42b7cd 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -418,7 +418,7 @@ static int raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 		if (!iov)
 			continue;
 
-		switch (fl->proto) {
+		switch (fl->flowi_proto) {
 		case IPPROTO_ICMP:
 			/* check if one-byte field is readable or not. */
 			if (iov->iov_base && iov->iov_len < 1)
@@ -548,14 +548,14 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	{
-		struct flowi fl = { .oif = ipc.oif,
-				    .mark = sk->sk_mark,
+		struct flowi fl = { .flowi_oif = ipc.oif,
+				    .flowi_mark = sk->sk_mark,
 				    .fl4_dst = daddr,
 				    .fl4_src = saddr,
 				    .fl4_tos = tos,
-				    .proto = inet->hdrincl ? IPPROTO_RAW :
+				    .flowi_proto = inet->hdrincl ? IPPROTO_RAW :
 							     sk->sk_protocol,
-				    .flags = FLOWI_FLAG_CAN_SLEEP,
+				    .flowi_flags = FLOWI_FLAG_CAN_SLEEP,
 		};
 		if (!inet->hdrincl) {
 			err = raw_probe_proto_opt(&fl, msg);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9c17e32..c9aa4f9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1701,9 +1701,9 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 			.fl4_dst = rt->rt_key_dst,
 			.fl4_src = rt->rt_key_src,
 			.fl4_tos = rt->rt_tos,
-			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
+			.flowi_oif = rt->rt_oif,
+			.flowi_iif = rt->rt_iif,
+			.flowi_mark = rt->rt_mark,
 		};
 
 		rcu_read_lock();
@@ -1766,7 +1766,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (oldflp && (oldflp->flags & FLOWI_FLAG_PRECOW_METRICS))
+	if (oldflp && (oldflp->flowi_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
@@ -2057,9 +2057,9 @@ static int ip_mkroute_input(struct sk_buff *skb,
 		return err;
 
 	/* put it into the cache */
-	hash = rt_hash(daddr, saddr, fl->iif,
+	hash = rt_hash(daddr, saddr, fl->flowi_iif,
 		       rt_genid(dev_net(rth->dst.dev)));
-	rth = rt_intern_hash(hash, rth, skb, fl->iif);
+	rth = rt_intern_hash(hash, rth, skb, fl->flowi_iif);
 	if (IS_ERR(rth))
 		return PTR_ERR(rth);
 	return 0;
@@ -2118,9 +2118,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	/*
 	 *	Now we are ready to route packet.
 	 */
-	fl.oif = 0;
-	fl.iif = dev->ifindex;
-	fl.mark = skb->mark;
+	fl.flowi_oif = 0;
+	fl.flowi_iif = dev->ifindex;
+	fl.flowi_mark = skb->mark;
 	fl.fl4_dst = daddr;
 	fl.fl4_src = saddr;
 	fl.fl4_tos = tos;
@@ -2205,8 +2205,8 @@ local_input:
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	rth->rt_type	= res.type;
-	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
-	rth = rt_intern_hash(hash, rth, skb, fl.iif);
+	hash = rt_hash(daddr, saddr, fl.flowi_iif, rt_genid(net));
+	rth = rt_intern_hash(hash, rth, skb, fl.flowi_iif);
 	err = 0;
 	if (IS_ERR(rth))
 		err = PTR_ERR(rth);
@@ -2369,7 +2369,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	} else if (type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
 		if (!ip_check_mc_rcu(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
-				     oldflp->proto))
+				     oldflp->flowi_proto))
 			flags &= ~RTCF_LOCAL;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
@@ -2387,8 +2387,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_key_dst	= oldflp->fl4_dst;
 	rth->rt_tos	= tos;
 	rth->rt_key_src	= oldflp->fl4_src;
-	rth->rt_oif	= oldflp->oif;
-	rth->rt_mark    = oldflp->mark;
+	rth->rt_oif	= oldflp->flowi_oif;
+	rth->rt_mark    = oldflp->flowi_mark;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
 	rth->rt_iif	= 0;
@@ -2452,9 +2452,9 @@ static struct rtable *ip_route_output_slow(struct net *net,
 	res.r		= NULL;
 #endif
 
-	fl.oif = oldflp->oif;
-	fl.iif = net->loopback_dev->ifindex;
-	fl.mark = oldflp->mark;
+	fl.flowi_oif = oldflp->flowi_oif;
+	fl.flowi_iif = net->loopback_dev->ifindex;
+	fl.flowi_mark = oldflp->flowi_mark;
 	fl.fl4_dst = oldflp->fl4_dst;
 	fl.fl4_src = oldflp->fl4_src;
 	fl.fl4_tos = tos & IPTOS_RT_MASK;
@@ -2477,7 +2477,7 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->oif == 0 &&
+		if (oldflp->flowi_oif == 0 &&
 		    (ipv4_is_multicast(oldflp->fl4_dst) ||
 		     ipv4_is_lbcast(oldflp->fl4_dst))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
@@ -2500,11 +2500,11 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			   Luckily, this hack is good workaround.
 			 */
 
-			fl.oif = dev_out->ifindex;
+			fl.flowi_oif = dev_out->ifindex;
 			goto make_route;
 		}
 
-		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
+		if (!(oldflp->flowi_flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 			if (!__ip_dev_find(net, oldflp->fl4_src, false))
 				goto out;
@@ -2512,8 +2512,8 @@ static struct rtable *ip_route_output_slow(struct net *net,
 	}
 
 
-	if (oldflp->oif) {
-		dev_out = dev_get_by_index_rcu(net, oldflp->oif);
+	if (oldflp->flowi_oif) {
+		dev_out = dev_get_by_index_rcu(net, oldflp->flowi_oif);
 		rth = ERR_PTR(-ENODEV);
 		if (dev_out == NULL)
 			goto out;
@@ -2545,7 +2545,7 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		if (!fl.fl4_dst)
 			fl.fl4_dst = fl.fl4_src = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
-		fl.oif = net->loopback_dev->ifindex;
+		fl.flowi_oif = net->loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
@@ -2553,7 +2553,7 @@ static struct rtable *ip_route_output_slow(struct net *net,
 
 	if (fib_lookup(net, &fl, &res)) {
 		res.fi = NULL;
-		if (oldflp->oif) {
+		if (oldflp->flowi_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
@@ -2590,25 +2590,25 @@ static struct rtable *ip_route_output_slow(struct net *net,
 				fl.fl4_src = fl.fl4_dst;
 		}
 		dev_out = net->loopback_dev;
-		fl.oif = dev_out->ifindex;
+		fl.flowi_oif = dev_out->ifindex;
 		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl.oif == 0)
+	if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
 		fib_select_multipath(&res);
 	else
 #endif
-	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.oif)
+	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.flowi_oif)
 		fib_select_default(&res);
 
 	if (!fl.fl4_src)
 		fl.fl4_src = FIB_RES_PREFSRC(res);
 
 	dev_out = FIB_RES_DEV(res);
-	fl.oif = dev_out->ifindex;
+	fl.flowi_oif = dev_out->ifindex;
 
 
 make_route:
@@ -2616,9 +2616,9 @@ make_route:
 	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
-		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
+		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->flowi_oif,
 			       rt_genid(dev_net(dev_out)));
-		rth = rt_intern_hash(hash, rth, NULL, oldflp->oif);
+		rth = rt_intern_hash(hash, rth, NULL, oldflp->flowi_oif);
 	}
 
 out:
@@ -2634,7 +2634,7 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 	if (!rt_caching(net))
 		goto slow_output;
 
-	hash = rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif, rt_genid(net));
+	hash = rt_hash(flp->fl4_dst, flp->fl4_src, flp->flowi_oif, rt_genid(net));
 
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
@@ -2642,8 +2642,8 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 		if (rth->rt_key_dst == flp->fl4_dst &&
 		    rth->rt_key_src == flp->fl4_src &&
 		    rt_is_output_route(rth) &&
-		    rth->rt_oif == flp->oif &&
-		    rth->rt_mark == flp->mark &&
+		    rth->rt_oif == flp->flowi_oif &&
+		    rth->rt_mark == flp->flowi_mark &&
 		    !((rth->rt_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
@@ -2741,7 +2741,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi *flp,
 	if (IS_ERR(rt))
 		return rt;
 
-	if (flp->proto) {
+	if (flp->flowi_proto) {
 		if (!flp->fl4_src)
 			flp->fl4_src = rt->rt_src;
 		if (!flp->fl4_dst)
@@ -2917,8 +2917,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 			.fl4_dst = dst,
 			.fl4_src = src,
 			.fl4_tos = rtm->rtm_tos,
-			.oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
-			.mark = mark,
+			.flowi_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
+			.flowi_mark = mark,
 		};
 		rt = ip_route_output_key(net, &fl);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 0ad6ddf..98d47dc 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -345,15 +345,17 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * no easy way to do this.
 	 */
 	{
-		struct flowi fl = { .mark = sk->sk_mark,
-				    .fl4_dst = ((opt && opt->srr) ?
-						opt->faddr : ireq->rmt_addr),
-				    .fl4_src = ireq->loc_addr,
-				    .fl4_tos = RT_CONN_FLAGS(sk),
-				    .proto = IPPROTO_TCP,
-				    .flags = inet_sk_flowi_flags(sk),
-				    .fl_ip_sport = th->dest,
-				    .fl_ip_dport = th->source };
+		struct flowi fl = {
+			.flowi_mark = sk->sk_mark,
+			.fl4_dst = ((opt && opt->srr) ?
+				    opt->faddr : ireq->rmt_addr),
+			.fl4_src = ireq->loc_addr,
+			.fl4_tos = RT_CONN_FLAGS(sk),
+			.flowi_proto = IPPROTO_TCP,
+			.flowi_flags = inet_sk_flowi_flags(sk),
+			.fl_ip_sport = th->dest,
+			.fl_ip_dport = th->source,
+		};
 		security_req_classify_flow(req, &fl);
 		rt = ip_route_output_key(sock_net(sk), &fl);
 		if (IS_ERR(rt)) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c9a73e5..e10f62e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -908,16 +908,17 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		struct flowi fl = { .oif = ipc.oif,
-				    .mark = sk->sk_mark,
-				    .fl4_dst = faddr,
-				    .fl4_src = saddr,
-				    .fl4_tos = tos,
-				    .proto = sk->sk_protocol,
-				    .flags = (inet_sk_flowi_flags(sk) |
-					      FLOWI_FLAG_CAN_SLEEP),
-				    .fl_ip_sport = inet->inet_sport,
-				    .fl_ip_dport = dport
+		struct flowi fl = {
+			.flowi_oif = ipc.oif,
+			.flowi_mark = sk->sk_mark,
+			.fl4_dst = faddr,
+			.fl4_src = saddr,
+			.fl4_tos = tos,
+			.flowi_proto = sk->sk_protocol,
+			.flowi_flags = (inet_sk_flowi_flags(sk) |
+				     FLOWI_FLAG_CAN_SLEEP),
+			.fl_ip_sport = inet->inet_sport,
+			.fl_ip_dport = dport,
 		};
 		struct net *net = sock_net(sk);
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c70c42e..4294f12 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -73,9 +73,9 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	rt->rt_key_dst = fl->fl4_dst;
 	rt->rt_key_src = fl->fl4_src;
 	rt->rt_tos = fl->fl4_tos;
-	rt->rt_iif = fl->iif;
-	rt->rt_oif = fl->oif;
-	rt->rt_mark = fl->mark;
+	rt->rt_iif = fl->flowi_iif;
+	rt->rt_oif = fl->flowi_oif;
+	rt->rt_mark = fl->flowi_mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
@@ -104,7 +104,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 
 	memset(fl, 0, sizeof(struct flowi));
-	fl->mark = skb->mark;
+	fl->flowi_mark = skb->mark;
 
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
@@ -173,7 +173,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 		}
 	}
-	fl->proto = iph->protocol;
+	fl->flowi_proto = iph->protocol;
 	fl->fl4_dst = reverse ? iph->saddr : iph->daddr;
 	fl->fl4_src = reverse ? iph->daddr : iph->saddr;
 	fl->fl4_tos = iph->tos;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 983eff2..d231434 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -32,8 +32,8 @@ __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	sel->family = AF_INET;
 	sel->prefixlen_d = 32;
 	sel->prefixlen_s = 32;
-	sel->proto = fl->proto;
-	sel->ifindex = fl->oif;
+	sel->proto = fl->flowi_proto;
+	sel->ifindex = fl->flowi_oif;
 }
 
 static void
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a88b2e9..35b0be0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -655,12 +655,12 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		struct flowi fl;
 
 		memset(&fl, 0, sizeof(fl));
-		fl.proto = sk->sk_protocol;
+		fl.flowi_proto = sk->sk_protocol;
 		ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 		fl.fl6_flowlabel = np->flow_label;
-		fl.oif = sk->sk_bound_dev_if;
-		fl.mark = sk->sk_mark;
+		fl.flowi_oif = sk->sk_bound_dev_if;
+		fl.flowi_mark = sk->sk_mark;
 		fl.fl_ip_dport = inet->inet_dport;
 		fl.fl_ip_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index be3a781..6c24b26 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -146,16 +146,16 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	fl.proto = sk->sk_protocol;
+	fl.flowi_proto = sk->sk_protocol;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.oif = sk->sk_bound_dev_if;
-	fl.mark = sk->sk_mark;
+	fl.flowi_oif = sk->sk_bound_dev_if;
+	fl.flowi_mark = sk->sk_mark;
 	fl.fl_ip_dport = inet->inet_dport;
 	fl.fl_ip_sport = inet->inet_sport;
 
-	if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
-		fl.oif = np->mcast_oif;
+	if (!fl.flowi_oif && (addr_type&IPV6_ADDR_MULTICAST))
+		fl.flowi_oif = np->mcast_oif;
 
 	security_sk_classify_flow(sk, &fl);
 
@@ -299,7 +299,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu)
 	mtu_info->ip6m_addr.sin6_family = AF_INET6;
 	mtu_info->ip6m_addr.sin6_port = 0;
 	mtu_info->ip6m_addr.sin6_flowinfo = 0;
-	mtu_info->ip6m_addr.sin6_scope_id = fl->oif;
+	mtu_info->ip6m_addr.sin6_scope_id = fl->flowi_oif;
 	ipv6_addr_copy(&mtu_info->ip6m_addr.sin6_addr, &ipv6_hdr(skb)->daddr);
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
@@ -629,16 +629,16 @@ int datagram_send_ctl(struct net *net,
 			src_info = (struct in6_pktinfo *)CMSG_DATA(cmsg);
 
 			if (src_info->ipi6_ifindex) {
-				if (fl->oif && src_info->ipi6_ifindex != fl->oif)
+				if (fl->flowi_oif && src_info->ipi6_ifindex != fl->flowi_oif)
 					return -EINVAL;
-				fl->oif = src_info->ipi6_ifindex;
+				fl->flowi_oif = src_info->ipi6_ifindex;
 			}
 
 			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
 
 			rcu_read_lock();
-			if (fl->oif) {
-				dev = dev_get_by_index_rcu(net, fl->oif);
+			if (fl->flowi_oif) {
+				dev = dev_get_by_index_rcu(net, fl->flowi_oif);
 				if (!dev) {
 					rcu_read_unlock();
 					return -ENODEV;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 5566595..9e123e0 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -235,7 +235,7 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 					sizeof(struct icmp6hdr), skb->csum);
 		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
 						      &fl->fl6_dst,
-						      len, fl->proto,
+						      len, fl->flowi_proto,
 						      skb->csum);
 	} else {
 		__wsum tmp_csum = 0;
@@ -248,7 +248,7 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 					sizeof(struct icmp6hdr), tmp_csum);
 		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
 						      &fl->fl6_dst,
-						      len, fl->proto,
+						      len, fl->flowi_proto,
 						      tmp_csum);
 	}
 	ip6_push_pending_frames(sk);
@@ -443,11 +443,11 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	mip6_addr_swap(skb);
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_ICMPV6;
+	fl.flowi_proto = IPPROTO_ICMPV6;
 	ipv6_addr_copy(&fl.fl6_dst, &hdr->saddr);
 	if (saddr)
 		ipv6_addr_copy(&fl.fl6_src, saddr);
-	fl.oif = iif;
+	fl.flowi_oif = iif;
 	fl.fl_icmp_type = type;
 	fl.fl_icmp_code = code;
 	security_skb_classify_flow(skb, &fl);
@@ -465,8 +465,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	tmp_hdr.icmp6_cksum = 0;
 	tmp_hdr.icmp6_pointer = htonl(info);
 
-	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.oif = np->mcast_oif;
+	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
+		fl.flowi_oif = np->mcast_oif;
 
 	dst = icmpv6_route_lookup(net, skb, sk, &fl);
 	if (IS_ERR(dst))
@@ -539,11 +539,11 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	tmp_hdr.icmp6_type = ICMPV6_ECHO_REPLY;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_ICMPV6;
+	fl.flowi_proto = IPPROTO_ICMPV6;
 	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
 	if (saddr)
 		ipv6_addr_copy(&fl.fl6_src, saddr);
-	fl.oif = skb->dev->ifindex;
+	fl.flowi_oif = skb->dev->ifindex;
 	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
 	security_skb_classify_flow(skb, &fl);
 
@@ -552,8 +552,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 		return;
 	np = inet6_sk(sk);
 
-	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.oif = np->mcast_oif;
+	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
+		fl.flowi_oif = np->mcast_oif;
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
@@ -793,10 +793,10 @@ void icmpv6_flow_init(struct sock *sk, struct flowi *fl,
 	memset(fl, 0, sizeof(*fl));
 	ipv6_addr_copy(&fl->fl6_src, saddr);
 	ipv6_addr_copy(&fl->fl6_dst, daddr);
-	fl->proto	 	= IPPROTO_ICMPV6;
+	fl->flowi_proto	 	= IPPROTO_ICMPV6;
 	fl->fl_icmp_type	= type;
 	fl->fl_icmp_code	= 0;
-	fl->oif			= oif;
+	fl->flowi_oif		= oif;
 	security_sk_classify_flow(sk, fl);
 }
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index d687e13..673f9bf 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -64,12 +64,12 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	struct flowi fl;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_TCP;
+	fl.flowi_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
 	final_p = fl6_update_dst(&fl, np->opt, &final);
 	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
-	fl.oif = sk->sk_bound_dev_if;
-	fl.mark = sk->sk_mark;
+	fl.flowi_oif = sk->sk_bound_dev_if;
+	fl.flowi_mark = sk->sk_mark;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
@@ -213,13 +213,13 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	struct in6_addr *final_p, final;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = sk->sk_protocol;
+	fl.flowi_proto = sk->sk_protocol;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	fl.oif = sk->sk_bound_dev_if;
-	fl.mark = sk->sk_mark;
+	fl.flowi_oif = sk->sk_bound_dev_if;
+	fl.flowi_mark = sk->sk_mark;
 	fl.fl_ip_sport = inet->inet_sport;
 	fl.fl_ip_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 1365468..c8fa470 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -358,7 +358,7 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 
 		msg.msg_controllen = olen;
 		msg.msg_control = (void*)(fl->opt+1);
-		flowi.oif = 0;
+		flowi.flowi_oif = 0;
 
 		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk,
 					&junk, &junk);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index adaffaf..3d0f2ac 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -182,7 +182,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	struct in6_addr *first_hop = &fl->fl6_dst;
 	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr;
-	u8  proto = fl->proto;
+	u8  proto = fl->flowi_proto;
 	int seg_len = skb->len;
 	int hlimit = -1;
 	int tclass = 0;
@@ -908,7 +908,7 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 #ifdef CONFIG_IPV6_SUBTREES
 	    ip6_rt_check(&rt->rt6i_src, &fl->fl6_src, np->saddr_cache) ||
 #endif
-	    (fl->oif && fl->oif != dst->dev->ifindex)) {
+	    (fl->flowi_oif && fl->flowi_oif != dst->dev->ifindex)) {
 		dst_release(dst);
 		dst = NULL;
 	}
@@ -1026,7 +1026,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (can_sleep)
-		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
 }
@@ -1062,7 +1062,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (can_sleep)
-		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
 }
@@ -1517,7 +1517,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	struct ipv6_txoptions *opt = np->cork.opt;
 	struct rt6_info *rt = (struct rt6_info *)inet->cork.dst;
 	struct flowi *fl = &inet->cork.fl;
-	unsigned char proto = fl->proto;
+	unsigned char proto = fl->flowi_proto;
 	int err = 0;
 
 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f199b84..c3fc824 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -963,7 +963,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 	skb->transport_header = skb->network_header;
 
-	proto = fl->proto;
+	proto = fl->flowi_proto;
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
@@ -1020,7 +1020,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl, &t->fl, sizeof (fl));
-	fl.proto = IPPROTO_IPIP;
+	fl.flowi_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -1070,7 +1070,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl, &t->fl, sizeof (fl));
-	fl.proto = IPPROTO_IPV6;
+	fl.flowi_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
@@ -1149,7 +1149,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	/* Set up flowi template */
 	ipv6_addr_copy(&fl->fl6_src, &p->laddr);
 	ipv6_addr_copy(&fl->fl6_dst, &p->raddr);
-	fl->oif = p->link;
+	fl->flowi_oif = p->link;
 	fl->fl6_flowlabel = 0;
 
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_TCLASS))
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 618f67cc..61a8be3 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -618,8 +618,8 @@ static int pim6_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct mr6_table *mrt;
 	struct flowi fl = {
-		.iif	= skb->dev->ifindex,
-		.mark	= skb->mark,
+		.flowi_iif	= skb->dev->ifindex,
+		.flowi_mark = skb->mark,
 	};
 	int reg_vif_num;
 
@@ -688,9 +688,9 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 	struct net *net = dev_net(dev);
 	struct mr6_table *mrt;
 	struct flowi fl = {
-		.oif		= dev->ifindex,
-		.iif		= skb->skb_iif,
-		.mark		= skb->mark,
+		.flowi_oif		= dev->ifindex,
+		.flowi_iif		= skb->skb_iif,
+		.flowi_mark	= skb->mark,
 	};
 	int err;
 
@@ -1548,9 +1548,9 @@ struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
 {
 	struct mr6_table *mrt;
 	struct flowi fl = {
-		.iif	= skb->skb_iif,
-		.oif	= skb->dev->ifindex,
-		.mark	= skb->mark,
+		.flowi_iif	= skb->skb_iif,
+		.flowi_oif	= skb->dev->ifindex,
+		.flowi_mark= skb->mark,
 	};
 
 	if (ip6mr_fib_lookup(net, &fl, &mrt) < 0)
@@ -1916,7 +1916,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	ipv6h = ipv6_hdr(skb);
 
 	fl = (struct flowi) {
-		.oif = vif->link,
+		.flowi_oif = vif->link,
 		.fl6_dst = ipv6h->daddr,
 	};
 
@@ -2044,8 +2044,8 @@ int ip6_mr_input(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct mr6_table *mrt;
 	struct flowi fl = {
-		.iif	= skb->dev->ifindex,
-		.mark	= skb->mark,
+		.flowi_iif	= skb->dev->ifindex,
+		.flowi_mark= skb->mark,
 	};
 	int err;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d1770e0..1448c50 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -448,8 +448,8 @@ sticky_done:
 		int junk;
 
 		fl.fl6_flowlabel = 0;
-		fl.oif = sk->sk_bound_dev_if;
-		fl.mark = sk->sk_mark;
+		fl.flowi_oif = sk->sk_bound_dev_if;
+		fl.flowi_mark = sk->sk_mark;
 
 		if (optlen == 0)
 			goto update;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index f3e3ca9..e2f852c 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -214,7 +214,7 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	struct timeval stamp;
 	int err = 0;
 
-	if (unlikely(fl->proto == IPPROTO_MH &&
+	if (unlikely(fl->flowi_proto == IPPROTO_MH &&
 		     fl->fl_mh_type <= IP6_MH_TYPE_MAX))
 		goto out;
 
@@ -240,14 +240,14 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	       sizeof(sel.saddr));
 	sel.prefixlen_s = 128;
 	sel.family = AF_INET6;
-	sel.proto = fl->proto;
+	sel.proto = fl->flowi_proto;
 	sel.dport = xfrm_flowi_dport(fl);
 	if (sel.dport)
 		sel.dport_mask = htons(~0);
 	sel.sport = xfrm_flowi_sport(fl);
 	if (sel.sport)
 		sel.sport_mask = htons(~0);
-	sel.ifindex = fl->oif;
+	sel.ifindex = fl->flowi_oif;
 
 	err = km_report(net, IPPROTO_DSTOPTS, &sel,
 			(hao ? (xfrm_address_t *)&hao->addr : NULL));
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 8d74116..d282c62 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -16,8 +16,8 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct dst_entry *dst;
 	struct flowi fl = {
-		.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
-		.mark = skb->mark,
+		.flowi_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
+		.flowi_mark = skb->mark,
 		.fl6_dst = iph->daddr,
 		.fl6_src = iph->saddr,
 	};
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 91f6a61..fd39388 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -90,7 +90,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	}
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_TCP;
+	fl.flowi_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl.fl6_src, &oip6h->daddr);
 	ipv6_addr_copy(&fl.fl6_dst, &oip6h->saddr);
 	fl.fl_ip_sport = otcph.dest;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dc29b07..323ad44 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -588,9 +588,9 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl,
 
 	csum = csum_ipv6_magic(&fl->fl6_src,
 				   &fl->fl6_dst,
-				   total_len, fl->proto, tmp_csum);
+				   total_len, fl->flowi_proto, tmp_csum);
 
-	if (csum == 0 && fl->proto == IPPROTO_UDP)
+	if (csum == 0 && fl->flowi_proto == IPPROTO_UDP)
 		csum = CSUM_MANGLED_0;
 
 	if (skb_store_bits(skb, offset, &csum, 2))
@@ -679,7 +679,7 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 		if (!iov)
 			continue;
 
-		switch (fl->proto) {
+		switch (fl->flowi_proto) {
 		case IPPROTO_ICMPV6:
 			/* check if one-byte field is readable or not. */
 			if (iov->iov_base && iov->iov_len < 1)
@@ -758,7 +758,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	 */
 	memset(&fl, 0, sizeof(fl));
 
-	fl.mark = sk->sk_mark;
+	fl.flowi_mark = sk->sk_mark;
 
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
@@ -800,7 +800,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl.oif = sin6->sin6_scope_id;
+			fl.flowi_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
@@ -810,8 +810,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		fl.fl6_flowlabel = np->flow_label;
 	}
 
-	if (fl.oif == 0)
-		fl.oif = sk->sk_bound_dev_if;
+	if (fl.flowi_oif == 0)
+		fl.flowi_oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -838,7 +838,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.proto = proto;
+	fl.flowi_proto = proto;
 	err = rawv6_probe_proto_opt(&fl, msg);
 	if (err)
 		goto out;
@@ -852,8 +852,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	final_p = fl6_update_dst(&fl, opt, &final);
 
-	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.oif = np->mcast_oif;
+	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
+		fl.flowi_oif = np->mcast_oif;
 	security_sk_classify_flow(sk, &fl);
 
 	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0012760..c3b20d6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -608,7 +608,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->oif, flags);
+	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->flowi_oif, flags);
 	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_use(&rt->dst, jiffies);
@@ -621,7 +621,7 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int strict)
 {
 	struct flowi fl = {
-		.oif = oif,
+		.flowi_oif = oif,
 		.fl6_dst = *daddr,
 	};
 	struct dst_entry *dst;
@@ -825,7 +825,7 @@ out2:
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi *fl, int flags)
 {
-	return ip6_pol_route(net, table, fl->iif, fl, flags);
+	return ip6_pol_route(net, table, fl->flowi_iif, fl, flags);
 }
 
 void ip6_route_input(struct sk_buff *skb)
@@ -834,12 +834,12 @@ void ip6_route_input(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi fl = {
-		.iif = skb->dev->ifindex,
+		.flowi_iif = skb->dev->ifindex,
 		.fl6_dst = iph->daddr,
 		.fl6_src = iph->saddr,
 		.fl6_flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
-		.mark = skb->mark,
-		.proto = iph->nexthdr,
+		.flowi_mark = skb->mark,
+		.flowi_proto = iph->nexthdr,
 	};
 
 	if (rt6_need_strict(&iph->daddr) && skb->dev->type != ARPHRD_PIMREG)
@@ -851,7 +851,7 @@ void ip6_route_input(struct sk_buff *skb)
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi *fl, int flags)
 {
-	return ip6_pol_route(net, table, fl->oif, fl, flags);
+	return ip6_pol_route(net, table, fl->flowi_oif, fl, flags);
 }
 
 struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
@@ -1484,7 +1484,7 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if (fl->oif != rt->rt6i_dev->ifindex)
+		if (fl->flowi_oif != rt->rt6i_dev->ifindex)
 			continue;
 		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;
@@ -1511,7 +1511,7 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 	struct net *net = dev_net(dev);
 	struct ip6rd_flowi rdfl = {
 		.fl = {
-			.oif = dev->ifindex,
+			.flowi_oif = dev->ifindex,
 			.fl6_dst = *dest,
 			.fl6_src = *src,
 		},
@@ -2413,7 +2413,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		iif = nla_get_u32(tb[RTA_IIF]);
 
 	if (tb[RTA_OIF])
-		fl.oif = nla_get_u32(tb[RTA_OIF]);
+		fl.flowi_oif = nla_get_u32(tb[RTA_OIF]);
 
 	if (iif) {
 		struct net_device *dev;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 0b4cf35..ca5255c 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -234,12 +234,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		struct in6_addr *final_p, final;
 		struct flowi fl;
 		memset(&fl, 0, sizeof(fl));
-		fl.proto = IPPROTO_TCP;
+		fl.flowi_proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
 		final_p = fl6_update_dst(&fl, np->opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
-		fl.oif = sk->sk_bound_dev_if;
-		fl.mark = sk->sk_mark;
+		fl.flowi_oif = sk->sk_bound_dev_if;
+		fl.flowi_mark = sk->sk_mark;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, &fl);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e59a31c..a3d1229 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -242,12 +242,12 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!ipv6_addr_any(&np->rcv_saddr))
 		saddr = &np->rcv_saddr;
 
-	fl.proto = IPPROTO_TCP;
+	fl.flowi_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src,
 		       (saddr ? saddr : &np->saddr));
-	fl.oif = sk->sk_bound_dev_if;
-	fl.mark = sk->sk_mark;
+	fl.flowi_oif = sk->sk_bound_dev_if;
+	fl.flowi_mark = sk->sk_mark;
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->inet_sport;
 
@@ -396,11 +396,11 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			   for now.
 			 */
 			memset(&fl, 0, sizeof(fl));
-			fl.proto = IPPROTO_TCP;
+			fl.flowi_proto = IPPROTO_TCP;
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-			fl.oif = sk->sk_bound_dev_if;
-			fl.mark = sk->sk_mark;
+			fl.flowi_oif = sk->sk_bound_dev_if;
+			fl.flowi_mark = sk->sk_mark;
 			fl.fl_ip_dport = inet->inet_dport;
 			fl.fl_ip_sport = inet->inet_sport;
 			security_skb_classify_flow(skb, &fl);
@@ -487,12 +487,12 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	int err;
 
 	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_TCP;
+	fl.flowi_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
 	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 	fl.fl6_flowlabel = 0;
-	fl.oif = treq->iif;
-	fl.mark = sk->sk_mark;
+	fl.flowi_oif = treq->iif;
+	fl.flowi_mark = sk->sk_mark;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
@@ -1055,8 +1055,8 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 
 	__tcp_v6_send_check(buff, &fl.fl6_src, &fl.fl6_dst);
 
-	fl.proto = IPPROTO_TCP;
-	fl.oif = inet6_iif(skb);
+	fl.flowi_proto = IPPROTO_TCP;
+	fl.flowi_oif = inet6_iif(skb);
 	fl.fl_ip_dport = t1->dest;
 	fl.fl_ip_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d86d7f6..91f8047 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -915,7 +915,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	/* add protocol-dependent pseudo-header */
 	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
-				    up->len, fl->proto, csum   );
+				    up->len, fl->flowi_proto, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
@@ -1060,7 +1060,7 @@ do_udp_sendmsg:
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl.oif = sin6->sin6_scope_id;
+			fl.flowi_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
@@ -1071,13 +1071,13 @@ do_udp_sendmsg:
 		connected = 1;
 	}
 
-	if (!fl.oif)
-		fl.oif = sk->sk_bound_dev_if;
+	if (!fl.flowi_oif)
+		fl.flowi_oif = sk->sk_bound_dev_if;
 
-	if (!fl.oif)
-		fl.oif = np->sticky_pktinfo.ipi6_ifindex;
+	if (!fl.flowi_oif)
+		fl.flowi_oif = np->sticky_pktinfo.ipi6_ifindex;
 
-	fl.mark = sk->sk_mark;
+	fl.flowi_mark = sk->sk_mark;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -1105,7 +1105,7 @@ do_udp_sendmsg:
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.proto = sk->sk_protocol;
+	fl.flowi_proto = sk->sk_protocol;
 	if (!ipv6_addr_any(daddr))
 		ipv6_addr_copy(&fl.fl6_dst, daddr);
 	else
@@ -1118,8 +1118,8 @@ do_udp_sendmsg:
 	if (final_p)
 		connected = 0;
 
-	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
-		fl.oif = np->mcast_oif;
+	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
+		fl.flowi_oif = np->mcast_oif;
 		connected = 0;
 	}
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 48ce496..d62496c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -128,7 +128,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
 	memset(fl, 0, sizeof(struct flowi));
-	fl->mark = skb->mark;
+	fl->flowi_mark = skb->mark;
 
 	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
 	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
@@ -161,7 +161,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 				fl->fl_ip_sport = ports[!!reverse];
 				fl->fl_ip_dport = ports[!reverse];
 			}
-			fl->proto = nexthdr;
+			fl->flowi_proto = nexthdr;
 			return;
 
 		case IPPROTO_ICMPV6:
@@ -171,7 +171,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 				fl->fl_icmp_type = icmp[0];
 				fl->fl_icmp_code = icmp[1];
 			}
-			fl->proto = nexthdr;
+			fl->flowi_proto = nexthdr;
 			return;
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
@@ -182,7 +182,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 				fl->fl_mh_type = mh->ip6mh_type;
 			}
-			fl->proto = nexthdr;
+			fl->flowi_proto = nexthdr;
 			return;
 #endif
 
@@ -192,7 +192,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_COMP:
 		default:
 			fl->fl_ipsec_spi = 0;
-			fl->proto = nexthdr;
+			fl->flowi_proto = nexthdr;
 			return;
 		}
 	}
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index a02598e..805d0e1 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -33,8 +33,8 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	sel->family = AF_INET6;
 	sel->prefixlen_d = 128;
 	sel->prefixlen_s = 128;
-	sel->proto = fl->proto;
-	sel->ifindex = fl->oif;
+	sel->proto = fl->flowi_proto;
+	sel->ifindex = fl->flowi_oif;
 }
 
 static void
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d69ec26..d07a32a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -76,7 +76,7 @@ static int __ip_vs_addr_is_local_v6(struct net *net,
 {
 	struct rt6_info *rt;
 	struct flowi fl = {
-		.oif = 0,
+		.flowi_oif = 0,
 		.fl6_dst = *addr,
 		.fl6_src = { .s6_addr32 = {0, 0, 0, 0} },
 	};
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index faf381d..cc8071f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -169,7 +169,7 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 			.fl4_dst = iph->daddr,
 			.fl4_src = iph->saddr,
 			.fl4_tos = RT_TOS(iph->tos),
-			.mark = skb->mark,
+			.flowi_mark = skb->mark,
 		};
 
 		rt = ip_route_output_key(net, &fl);
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 624725b..cb14ae2 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -68,7 +68,7 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	if (info->priv) {
 		if (info->priv->oif == -1)
 			return false;
-		fl.oif = info->priv->oif;
+		fl.flowi_oif = info->priv->oif;
 	}
 	fl.fl4_dst = info->gw.ip;
 	fl.fl4_tos = RT_TOS(iph->tos);
@@ -149,7 +149,7 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	if (info->priv) {
 		if (info->priv->oif == -1)
 			return false;
-		fl.oif = info->priv->oif;
+		fl.flowi_oif = info->priv->oif;
 	}
 	fl.fl6_dst = info->gw.in6;
 	fl.fl6_flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 95e0c8e..8316271 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -205,7 +205,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 
 	memset(&fl, 0, sizeof(fl));
 
-	fl.proto = sk->sk_protocol;
+	fl.flowi_proto = sk->sk_protocol;
 
 	/* Fill in the dest address from the route entry passed with the skb
 	 * and the source address from the transport.
@@ -216,9 +216,9 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	if (ipv6_addr_type(&fl.fl6_src) & IPV6_ADDR_LINKLOCAL)
-		fl.oif = transport->saddr.v6.sin6_scope_id;
+		fl.flowi_oif = transport->saddr.v6.sin6_scope_id;
 	else
-		fl.oif = sk->sk_bound_dev_if;
+		fl.flowi_oif = sk->sk_bound_dev_if;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
@@ -250,7 +250,7 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		fl.oif = daddr->v6.sin6_scope_id;
+		fl.flowi_oif = daddr->v6.sin6_scope_id;
 
 
 	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl.fl6_dst);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4e55e6c..832665a 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -477,10 +477,10 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 	memset(&fl, 0x0, sizeof(struct flowi));
 	fl.fl4_dst  = daddr->v4.sin_addr.s_addr;
 	fl.fl_ip_dport = daddr->v4.sin_port;
-	fl.proto = IPPROTO_SCTP;
+	fl.flowi_proto = IPPROTO_SCTP;
 	if (asoc) {
 		fl.fl4_tos = RT_CONN_FLAGS(asoc->base.sk);
-		fl.oif = asoc->base.sk->sk_bound_dev_if;
+		fl.flowi_oif = asoc->base.sk->sk_bound_dev_if;
 		fl.fl_ip_sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9e4aacd..dd6243f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -63,8 +63,8 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
 		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+		(fl->flowi_proto == sel->proto || !sel->proto) &&
+		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
 
 static inline int
@@ -74,8 +74,8 @@ __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
 		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+		(fl->flowi_proto == sel->proto || !sel->proto) &&
+		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
 
 int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
@@ -876,13 +876,13 @@ static int xfrm_policy_match(const struct xfrm_policy *pol,
 	int match, ret = -ESRCH;
 
 	if (pol->family != family ||
-	    (fl->mark & pol->mark.m) != pol->mark.v ||
+	    (fl->flowi_mark & pol->mark.m) != pol->mark.v ||
 	    pol->type != type)
 		return ret;
 
 	match = xfrm_selector_match(sel, fl, family);
 	if (match)
-		ret = security_xfrm_policy_lookup(pol->security, fl->secid,
+		ret = security_xfrm_policy_lookup(pol->security, fl->flowi_secid,
 						  dir);
 
 	return ret;
@@ -1012,7 +1012,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
 				goto out;
 			}
 			err = security_xfrm_policy_lookup(pol->security,
-						      fl->secid,
+						      fl->flowi_secid,
 						      policy_to_flow_dir(dir));
 			if (!err)
 				xfrm_pol_hold(pol);
@@ -1848,7 +1848,7 @@ restart:
 
 			return make_blackhole(net, family, dst_orig);
 		}
-		if (fl->flags & FLOWI_FLAG_CAN_SLEEP) {
+		if (fl->flowi_flags & FLOWI_FLAG_CAN_SLEEP) {
 			DECLARE_WAITQUEUE(wait, current);
 
 			add_wait_queue(&net->xfrm.km_waitq, &wait);
@@ -1990,7 +1990,7 @@ int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 		return -EAFNOSUPPORT;
 
 	afinfo->decode_session(skb, fl, reverse);
-	err = security_xfrm_decode_session(skb, &fl->secid);
+	err = security_xfrm_decode_session(skb, &fl->flowi_secid);
 	xfrm_policy_put_afinfo(afinfo);
 	return err;
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 81221d9..cd6be49 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -859,7 +859,7 @@ found:
 		xfrm_init_tempstate(x, fl, tmpl, daddr, saddr, family);
 		memcpy(&x->mark, &pol->mark, sizeof(x->mark));
 
-		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
+		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->flowi_secid);
 		if (error) {
 			x->km.state = XFRM_STATE_DEAD;
 			to_put = x;
diff --git a/security/security.c b/security/security.c
index 8ef1f7d..bae843c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1100,7 +1100,7 @@ void security_sk_clone(const struct sock *sk, struct sock *newsk)
 
 void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
 {
-	security_ops->sk_getsecid(sk, &fl->secid);
+	security_ops->sk_getsecid(sk, &fl->flowi_secid);
 }
 EXPORT_SYMBOL(security_sk_classify_flow);
 
@@ -1246,7 +1246,7 @@ int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
 
 void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl)
 {
-	int rc = security_ops->xfrm_decode_session(skb, &fl->secid, 0);
+	int rc = security_ops->xfrm_decode_session(skb, &fl->flowi_secid, 0);
 
 	BUG_ON(rc);
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index cef42f5..c178494 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4306,7 +4306,7 @@ static void selinux_secmark_refcount_dec(void)
 static void selinux_req_classify_flow(const struct request_sock *req,
 				      struct flowi *fl)
 {
-	fl->secid = req->secid;
+	fl->flowi_secid = req->secid;
 }
 
 static int selinux_tun_dev_create(void)
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index c43ab54..510ec2c 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -135,10 +135,10 @@ int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *
 
 	state_sid = x->security->ctx_sid;
 
-	if (fl->secid != state_sid)
+	if (fl->flowi_secid != state_sid)
 		return 0;
 
-	rc = avc_has_perm(fl->secid, state_sid, SECCLASS_ASSOCIATION,
+	rc = avc_has_perm(fl->flowi_secid, state_sid, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__SENDTO,
 			  NULL)? 0:1;
 
-- 
1.7.4.1

