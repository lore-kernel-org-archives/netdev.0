From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/25] ipv4: Use flowi4 in public route lookup interfaces.
Date: Sat, 12 Mar 2011 15:27:53 -0800 (PST)
Message-ID: <20110312.152753.245396977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756024Ab1CLX1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:27:15 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8813B24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:27:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h             |  118 +++++++++++++++++++-------------------
 net/dccp/ipv4.c                 |   20 +++---
 net/ipv4/icmp.c                 |   59 ++++++++++---------
 net/ipv4/inet_connection_sock.c |   26 ++++----
 net/ipv4/ip_output.c            |   22 ++++----
 net/ipv4/netfilter.c            |   26 ++++----
 net/ipv4/raw.c                  |   32 ++++++-----
 net/ipv4/route.c                |   36 ++++++------
 net/ipv4/syncookies.c           |   24 ++++----
 net/ipv4/udp.c                  |   26 ++++----
 net/ipv4/xfrm4_policy.c         |   10 ++--
 net/netfilter/ipvs/ip_vs_xmit.c |   12 ++--
 net/netfilter/xt_TEE.c          |   14 ++--
 net/sctp/protocol.c             |   30 +++++-----
 14 files changed, 231 insertions(+), 224 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 4c207f9..80b0353 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -122,12 +122,12 @@ extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
-extern struct rtable *__ip_route_output_key(struct net *, const struct flowi *flp);
-extern struct rtable *ip_route_output_flow(struct net *, struct flowi *flp,
+extern struct rtable *__ip_route_output_key(struct net *, const struct flowi4 *flp);
+extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
 extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
 
-static inline struct rtable *ip_route_output_key(struct net *net, struct flowi *flp)
+static inline struct rtable *ip_route_output_key(struct net *net, struct flowi4 *flp)
 {
 	return ip_route_output_flow(net, flp, NULL);
 }
@@ -135,13 +135,13 @@ static inline struct rtable *ip_route_output_key(struct net *net, struct flowi *
 static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 					     __be32 saddr, u8 tos, int oif)
 {
-	struct flowi fl = {
-		.flowi_oif = oif,
-		.fl4_dst = daddr,
-		.fl4_src = saddr,
-		.fl4_tos = tos,
+	struct flowi4 fl4 = {
+		.flowi4_oif = oif,
+		.daddr = daddr,
+		.saddr = saddr,
+		.flowi4_tos = tos,
 	};
-	return ip_route_output_key(net, &fl);
+	return ip_route_output_key(net, &fl4);
 }
 
 static inline struct rtable *ip_route_output_ports(struct net *net, struct sock *sk,
@@ -149,35 +149,35 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct sock
 						   __be16 dport, __be16 sport,
 						   __u8 proto, __u8 tos, int oif)
 {
-	struct flowi fl = {
-		.flowi_oif = oif,
-		.flowi_flags = sk ? inet_sk_flowi_flags(sk) : 0,
-		.flowi_mark = sk ? sk->sk_mark : 0,
-		.fl4_dst = daddr,
-		.fl4_src = saddr,
-		.fl4_tos = tos,
-		.flowi_proto = proto,
-		.fl4_dport = dport,
-		.fl4_sport = sport,
+	struct flowi4 fl4 = {
+		.flowi4_oif = oif,
+		.flowi4_flags = sk ? inet_sk_flowi_flags(sk) : 0,
+		.flowi4_mark = sk ? sk->sk_mark : 0,
+		.daddr = daddr,
+		.saddr = saddr,
+		.flowi4_tos = tos,
+		.flowi4_proto = proto,
+		.uli.ports.dport = dport,
+		.uli.ports.sport = sport,
 	};
 	if (sk)
-		security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(net, &fl, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+	return ip_route_output_flow(net, &fl4, sk);
 }
 
 static inline struct rtable *ip_route_output_gre(struct net *net,
 						 __be32 daddr, __be32 saddr,
 						 __be32 gre_key, __u8 tos, int oif)
 {
-	struct flowi fl = {
-		.flowi_oif = oif,
-		.fl4_dst = daddr,
-		.fl4_src = saddr,
-		.fl4_tos = tos,
-		.flowi_proto = IPPROTO_GRE,
-		.fl4_gre_key = gre_key,
+	struct flowi4 fl4 = {
+		.flowi4_oif = oif,
+		.daddr = daddr,
+		.saddr = saddr,
+		.flowi4_tos = tos,
+		.flowi4_proto = IPPROTO_GRE,
+		.uli.gre_key = gre_key,
 	};
-	return ip_route_output_key(net, &fl);
+	return ip_route_output_key(net, &fl4);
 }
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
@@ -228,36 +228,36 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 					      __be16 sport, __be16 dport,
 					      struct sock *sk, bool can_sleep)
 {
-	struct flowi fl = {
-		.flowi_oif = oif,
-		.flowi_mark = sk->sk_mark,
-		.fl4_dst = dst,
-		.fl4_src = src,
-		.fl4_tos = tos,
-		.flowi_proto = protocol,
-		.fl4_sport = sport,
-		.fl4_dport = dport,
+	struct flowi4 fl4 = {
+		.flowi4_oif = oif,
+		.flowi4_mark = sk->sk_mark,
+		.daddr = dst,
+		.saddr = src,
+		.flowi4_tos = tos,
+		.flowi4_proto = protocol,
+		.uli.ports.sport = sport,
+		.uli.ports.dport = dport,
 	};
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
 
 	if (inet_sk(sk)->transparent)
-		fl.flowi_flags |= FLOWI_FLAG_ANYSRC;
+		fl4.flowi4_flags |= FLOWI_FLAG_ANYSRC;
 	if (protocol == IPPROTO_TCP)
-		fl.flowi_flags |= FLOWI_FLAG_PRECOW_METRICS;
+		fl4.flowi4_flags |= FLOWI_FLAG_PRECOW_METRICS;
 	if (can_sleep)
-		fl.flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl4.flowi4_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	if (!dst || !src) {
-		rt = __ip_route_output_key(net, &fl);
+		rt = __ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt))
 			return rt;
-		fl.fl4_dst = rt->rt_dst;
-		fl.fl4_src = rt->rt_src;
+		fl4.daddr = rt->rt_dst;
+		fl4.saddr = rt->rt_src;
 		ip_rt_put(rt);
 	}
-	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(net, &fl, sk);
+	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+	return ip_route_output_flow(net, &fl4, sk);
 }
 
 static inline struct rtable *ip_route_newports(struct rtable *rt,
@@ -266,23 +266,23 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = {
-			.flowi_oif = rt->rt_oif,
-			.flowi_mark = rt->rt_mark,
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
-			.flowi_proto = protocol,
-			.fl4_sport = sport,
-			.fl4_dport = dport
+		struct flowi4 fl4 = {
+			.flowi4_oif = rt->rt_oif,
+			.flowi4_mark = rt->rt_mark,
+			.daddr = rt->rt_key_dst,
+			.saddr = rt->rt_key_src,
+			.flowi4_tos = rt->rt_tos,
+			.flowi4_proto = protocol,
+			.uli.ports.sport = sport,
+			.uli.ports.dport = dport
 		};
 		if (inet_sk(sk)->transparent)
-			fl.flowi_flags |= FLOWI_FLAG_ANYSRC;
+			fl4.flowi4_flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
-			fl.flowi_flags |= FLOWI_FLAG_PRECOW_METRICS;
+			fl4.flowi4_flags |= FLOWI_FLAG_PRECOW_METRICS;
 		ip_rt_put(rt);
-		security_sk_classify_flow(sk, &fl);
-		return ip_route_output_flow(sock_net(sk), &fl, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+		return ip_route_output_flow(sock_net(sk), &fl4, sk);
 	}
 	return rt;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d934b20..be98470 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -465,18 +465,18 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
-	struct flowi fl = {
-		.flowi_oif = skb_rtable(skb)->rt_iif,
-		.fl4_dst = ip_hdr(skb)->saddr,
-		.fl4_src = ip_hdr(skb)->daddr,
-		.fl4_tos = RT_CONN_FLAGS(sk),
-		.flowi_proto = sk->sk_protocol,
-		.fl4_sport = dccp_hdr(skb)->dccph_dport,
-		.fl4_dport = dccp_hdr(skb)->dccph_sport,
+	struct flowi4 fl4 = {
+		.flowi4_oif = skb_rtable(skb)->rt_iif,
+		.daddr = ip_hdr(skb)->saddr,
+		.saddr = ip_hdr(skb)->daddr,
+		.flowi4_tos = RT_CONN_FLAGS(sk),
+		.flowi4_proto = sk->sk_protocol,
+		.uli.ports.sport = dccp_hdr(skb)->dccph_dport,
+		.uli.ports.dport = dccp_hdr(skb)->dccph_sport,
 	};
 
-	security_skb_classify_flow(skb, &fl);
-	rt = ip_route_output_flow(net, &fl, sk);
+	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt)) {
 		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 8d09195..8eca3c2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -353,14 +353,14 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 			daddr = icmp_param->replyopts.faddr;
 	}
 	{
-		struct flowi fl = {
-			.fl4_dst = daddr,
-			.fl4_src = rt->rt_spec_dst,
-			.fl4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.flowi_proto = IPPROTO_ICMP,
+		struct flowi4 fl4 = {
+			.daddr = daddr,
+			.saddr = rt->rt_spec_dst,
+			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
+			.flowi4_proto = IPPROTO_ICMP,
 		};
-		security_skb_classify_flow(skb, &fl);
-		rt = ip_route_output_key(net, &fl);
+		security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt))
 			goto out_unlock;
 	}
@@ -378,30 +378,31 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 					int type, int code,
 					struct icmp_bxm *param)
 {
-	struct flowi fl = {
-		.fl4_dst = (param->replyopts.srr ?
-			    param->replyopts.faddr : iph->saddr),
-		.fl4_src = saddr,
-		.fl4_tos = RT_TOS(tos),
-		.flowi_proto = IPPROTO_ICMP,
-		.fl4_icmp_type = type,
-		.fl4_icmp_code = code,
+	struct flowi4 fl4 = {
+		.daddr = (param->replyopts.srr ?
+			  param->replyopts.faddr : iph->saddr),
+		.saddr = saddr,
+		.flowi4_tos = RT_TOS(tos),
+		.flowi4_proto = IPPROTO_ICMP,
+		.uli.icmpt.type = type,
+		.uli.icmpt.code = code,
 	};
 	struct rtable *rt, *rt2;
 	int err;
 
-	security_skb_classify_flow(skb_in, &fl);
-	rt = __ip_route_output_key(net, &fl);
+	security_skb_classify_flow(skb_in, flowi4_to_flowi(&fl4));
+	rt = __ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		return rt;
 
 	/* No need to clone since we're just using its address. */
 	rt2 = rt;
 
-	if (!fl.fl4_src)
-		fl.fl4_src = rt->rt_src;
+	if (!fl4.saddr)
+		fl4.saddr = rt->rt_src;
 
-	rt = (struct rtable *) xfrm_lookup(net, &rt->dst, &fl, NULL, 0);
+	rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
+					   flowi4_to_flowi(&fl4), NULL, 0);
 	if (!IS_ERR(rt)) {
 		if (rt != rt2)
 			return rt;
@@ -410,27 +411,27 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	} else
 		return rt;
 
-	err = xfrm_decode_session_reverse(skb_in, &fl, AF_INET);
+	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(&fl4), AF_INET);
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL) {
-		rt2 = __ip_route_output_key(net, &fl);
+	if (inet_addr_type(net, fl4.saddr) == RTN_LOCAL) {
+		rt2 = __ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
 	} else {
-		struct flowi fl2 = {};
+		struct flowi4 fl4_2 = {};
 		unsigned long orefdst;
 
-		fl2.fl4_dst = fl.fl4_src;
-		rt2 = ip_route_output_key(net, &fl2);
+		fl4_2.daddr = fl4.saddr;
+		rt2 = ip_route_output_key(net, &fl4_2);
 		if (IS_ERR(rt2)) {
 			err = PTR_ERR(rt2);
 			goto relookup_failed;
 		}
 		/* Ugh! */
 		orefdst = skb_in->_skb_refdst; /* save old refdst */
-		err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
+		err = ip_route_input(skb_in, fl4.daddr, fl4.saddr,
 				     RT_TOS(tos), rt2->dst.dev);
 
 		dst_release(&rt2->dst);
@@ -441,7 +442,9 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	if (err)
 		goto relookup_failed;
 
-	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst, &fl, NULL, XFRM_LOOKUP_ICMP);
+	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
+					    flowi4_to_flowi(&fl4), NULL,
+					    XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(rt2)) {
 		dst_release(&rt->dst);
 		rt = rt2;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 10a8e95..beecc12 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -356,22 +356,22 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options *opt = inet_rsk(req)->opt;
-	struct flowi fl = {
-		.flowi_oif = sk->sk_bound_dev_if,
-		.flowi_mark = sk->sk_mark,
-		.fl4_dst = ((opt && opt->srr) ?
-			    opt->faddr : ireq->rmt_addr),
-		.fl4_src = ireq->loc_addr,
-		.fl4_tos = RT_CONN_FLAGS(sk),
-		.flowi_proto = sk->sk_protocol,
-		.flowi_flags = inet_sk_flowi_flags(sk),
-		.fl4_sport = inet_sk(sk)->inet_sport,
-		.fl4_dport = ireq->rmt_port,
+	struct flowi4 fl4 = {
+		.flowi4_oif = sk->sk_bound_dev_if,
+		.flowi4_mark = sk->sk_mark,
+		.daddr = ((opt && opt->srr) ?
+			  opt->faddr : ireq->rmt_addr),
+		.saddr = ireq->loc_addr,
+		.flowi4_tos = RT_CONN_FLAGS(sk),
+		.flowi4_proto = sk->sk_protocol,
+		.flowi4_flags = inet_sk_flowi_flags(sk),
+		.uli.ports.sport = inet_sk(sk)->inet_sport,
+		.uli.ports.dport = ireq->rmt_port,
 	};
 	struct net *net = sock_net(sk);
 
-	security_req_classify_flow(req, &fl);
-	rt = ip_route_output_flow(net, &fl, sk);
+	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 67e5f71..2b9cc40 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1474,18 +1474,18 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	}
 
 	{
-		struct flowi fl = {
-			.flowi_oif = arg->bound_dev_if,
-			.fl4_dst = daddr,
-			.fl4_src = rt->rt_spec_dst,
-			.fl4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.fl4_sport = tcp_hdr(skb)->dest,
-			.fl4_dport = tcp_hdr(skb)->source,
-			.flowi_proto = sk->sk_protocol,
-			.flowi_flags = ip_reply_arg_flowi_flags(arg),
+		struct flowi4 fl4 = {
+			.flowi4_oif = arg->bound_dev_if,
+			.daddr = daddr,
+			.saddr = rt->rt_spec_dst,
+			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
+			.uli.ports.sport = tcp_hdr(skb)->dest,
+			.uli.ports.dport = tcp_hdr(skb)->source,
+			.flowi4_proto = sk->sk_protocol,
+			.flowi4_flags = ip_reply_arg_flowi_flags(arg),
 		};
-		security_skb_classify_flow(skb, &fl);
-		rt = ip_route_output_key(sock_net(sk), &fl);
+		security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_key(sock_net(sk), &fl4);
 		if (IS_ERR(rt))
 			return;
 	}
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 6f40ba5..f3c0b54 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -16,7 +16,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
-	struct flowi fl = {};
+	struct flowi4 fl4 = {};
 	unsigned long orefdst;
 	unsigned int hh_len;
 	unsigned int type;
@@ -31,14 +31,14 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
 	 */
 	if (addr_type == RTN_LOCAL) {
-		fl.fl4_dst = iph->daddr;
+		fl4.daddr = iph->daddr;
 		if (type == RTN_LOCAL)
-			fl.fl4_src = iph->saddr;
-		fl.fl4_tos = RT_TOS(iph->tos);
-		fl.flowi_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
-		fl.flowi_mark = skb->mark;
-		fl.flowi_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
-		rt = ip_route_output_key(net, &fl);
+			fl4.saddr = iph->saddr;
+		fl4.flowi4_tos = RT_TOS(iph->tos);
+		fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+		fl4.flowi4_mark = skb->mark;
+		fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
+		rt = ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt))
 			return -1;
 
@@ -48,8 +48,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
-		fl.fl4_dst = iph->saddr;
-		rt = ip_route_output_key(net, &fl);
+		fl4.daddr = iph->saddr;
+		rt = ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt))
 			return -1;
 
@@ -68,10 +68,10 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 
 #ifdef CONFIG_XFRM
 	if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(skb, &fl, AF_INET) == 0) {
+	    xfrm_decode_session(skb, flowi4_to_flowi(&fl4), AF_INET) == 0) {
 		struct dst_entry *dst = skb_dst(skb);
 		skb_dst_set(skb, NULL);
-		dst = xfrm_lookup(net, dst, &fl, skb->sk, 0);
+		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
 		if (IS_ERR(dst))
 			return -1;
 		skb_dst_set(skb, dst);
@@ -223,7 +223,7 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 
 static int nf_ip_route(struct dst_entry **dst, struct flowi *fl)
 {
-	struct rtable *rt = ip_route_output_key(&init_net, fl);
+	struct rtable *rt = ip_route_output_key(&init_net, &fl->u.ip4);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 	*dst = &rt->dst;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 333b826..452e178 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -402,7 +402,7 @@ error:
 	return err;
 }
 
-static int raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+static int raw_probe_proto_opt(struct flowi4 *fl4, struct msghdr *msg)
 {
 	struct iovec *iov;
 	u8 __user *type = NULL;
@@ -418,7 +418,7 @@ static int raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 		if (!iov)
 			continue;
 
-		switch (fl->flowi_proto) {
+		switch (fl4->flowi4_proto) {
 		case IPPROTO_ICMP:
 			/* check if one-byte field is readable or not. */
 			if (iov->iov_base && iov->iov_len < 1)
@@ -433,8 +433,8 @@ static int raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl->fl4_icmp_type, type) ||
-				    get_user(fl->fl4_icmp_code, code))
+				if (get_user(fl4->uli.icmpt.type, type) ||
+				    get_user(fl4->uli.icmpt.code, code))
 					return -EFAULT;
 				probed = 1;
 			}
@@ -548,23 +548,25 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	{
-		struct flowi fl = { .flowi_oif = ipc.oif,
-				    .flowi_mark = sk->sk_mark,
-				    .fl4_dst = daddr,
-				    .fl4_src = saddr,
-				    .fl4_tos = tos,
-				    .flowi_proto = inet->hdrincl ? IPPROTO_RAW :
-							     sk->sk_protocol,
-				    .flowi_flags = FLOWI_FLAG_CAN_SLEEP,
+		struct flowi4 fl4 = {
+			.flowi4_oif = ipc.oif,
+			.flowi4_mark = sk->sk_mark,
+			.daddr = daddr,
+			.saddr = saddr,
+			.flowi4_tos = tos,
+			.flowi4_proto = (inet->hdrincl ?
+					 IPPROTO_RAW :
+					 sk->sk_protocol),
+			.flowi4_flags = FLOWI_FLAG_CAN_SLEEP,
 		};
 		if (!inet->hdrincl) {
-			err = raw_probe_proto_opt(&fl, msg);
+			err = raw_probe_proto_opt(&fl4, msg);
 			if (err)
 				goto done;
 		}
 
-		security_sk_classify_flow(sk, &fl);
-		rt = ip_route_output_flow(sock_net(sk), &fl, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			goto done;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9e938f9..5655095 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2626,7 +2626,7 @@ out:
 	return rth;
 }
 
-struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
+struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *flp4)
 {
 	struct rtable *rth;
 	unsigned int hash;
@@ -2634,17 +2634,17 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 	if (!rt_caching(net))
 		goto slow_output;
 
-	hash = rt_hash(flp->fl4_dst, flp->fl4_src, flp->flowi_oif, rt_genid(net));
+	hash = rt_hash(flp4->daddr, flp4->saddr, flp4->flowi4_oif, rt_genid(net));
 
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
 		rth = rcu_dereference_bh(rth->dst.rt_next)) {
-		if (rth->rt_key_dst == flp->fl4_dst &&
-		    rth->rt_key_src == flp->fl4_src &&
+		if (rth->rt_key_dst == flp4->daddr &&
+		    rth->rt_key_src == flp4->saddr &&
 		    rt_is_output_route(rth) &&
-		    rth->rt_oif == flp->flowi_oif &&
-		    rth->rt_mark == flp->flowi_mark &&
-		    !((rth->rt_tos ^ flp->fl4_tos) &
+		    rth->rt_oif == flp4->flowi4_oif &&
+		    rth->rt_mark == flp4->flowi4_mark &&
+		    !((rth->rt_tos ^ flp4->flowi4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
@@ -2658,7 +2658,7 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 	rcu_read_unlock_bh();
 
 slow_output:
-	return ip_route_output_slow(net, &flp->u.ip4);
+	return ip_route_output_slow(net, flp4);
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
@@ -2733,20 +2733,22 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	return rt ? &rt->dst : ERR_PTR(-ENOMEM);
 }
 
-struct rtable *ip_route_output_flow(struct net *net, struct flowi *flp,
+struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 				    struct sock *sk)
 {
-	struct rtable *rt = __ip_route_output_key(net, flp);
+	struct rtable *rt = __ip_route_output_key(net, flp4);
 
 	if (IS_ERR(rt))
 		return rt;
 
-	if (flp->flowi_proto) {
-		if (!flp->fl4_src)
-			flp->fl4_src = rt->rt_src;
-		if (!flp->fl4_dst)
-			flp->fl4_dst = rt->rt_dst;
-		rt = (struct rtable *) xfrm_lookup(net, &rt->dst, flp, sk, 0);
+	if (flp4->flowi4_proto) {
+		if (!flp4->saddr)
+			flp4->saddr = rt->rt_src;
+		if (!flp4->daddr)
+			flp4->daddr = rt->rt_dst;
+		rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
+						   flowi4_to_flowi(flp4),
+						   sk, 0);
 	}
 
 	return rt;
@@ -2920,7 +2922,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 			.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
 			.flowi4_mark = mark,
 		};
-		rt = ip_route_output_key(net, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_key(net, &fl4);
 
 		err = 0;
 		if (IS_ERR(rt))
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d90529d..e3b5b75 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -345,19 +345,19 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * no easy way to do this.
 	 */
 	{
-		struct flowi fl = {
-			.flowi_mark = sk->sk_mark,
-			.fl4_dst = ((opt && opt->srr) ?
-				    opt->faddr : ireq->rmt_addr),
-			.fl4_src = ireq->loc_addr,
-			.fl4_tos = RT_CONN_FLAGS(sk),
-			.flowi_proto = IPPROTO_TCP,
-			.flowi_flags = inet_sk_flowi_flags(sk),
-			.fl4_sport = th->dest,
-			.fl4_dport = th->source,
+		struct flowi4 fl4 = {
+			.flowi4_mark = sk->sk_mark,
+			.daddr = ((opt && opt->srr) ?
+				  opt->faddr : ireq->rmt_addr),
+			.saddr = ireq->loc_addr,
+			.flowi4_tos = RT_CONN_FLAGS(sk),
+			.flowi4_proto = IPPROTO_TCP,
+			.flowi4_flags = inet_sk_flowi_flags(sk),
+			.uli.ports.sport = th->dest,
+			.uli.ports.dport = th->source,
 		};
-		security_req_classify_flow(req, &fl);
-		rt = ip_route_output_key(sock_net(sk), &fl);
+		security_req_classify_flow(req, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_key(sock_net(sk), &fl4);
 		if (IS_ERR(rt)) {
 			reqsk_free(req);
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 116e4a8..25c0807 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -908,22 +908,22 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		struct flowi fl = {
-			.flowi_oif = ipc.oif,
-			.flowi_mark = sk->sk_mark,
-			.fl4_dst = faddr,
-			.fl4_src = saddr,
-			.fl4_tos = tos,
-			.flowi_proto = sk->sk_protocol,
-			.flowi_flags = (inet_sk_flowi_flags(sk) |
-				     FLOWI_FLAG_CAN_SLEEP),
-			.fl4_sport = inet->inet_sport,
-			.fl4_dport = dport,
+		struct flowi4 fl4 = {
+			.flowi4_oif = ipc.oif,
+			.flowi4_mark = sk->sk_mark,
+			.daddr = faddr,
+			.saddr = saddr,
+			.flowi4_tos = tos,
+			.flowi4_proto = sk->sk_protocol,
+			.flowi4_flags = (inet_sk_flowi_flags(sk) |
+					 FLOWI_FLAG_CAN_SLEEP),
+			.uli.ports.sport = inet->inet_sport,
+			.uli.ports.dport = dport,
 		};
 		struct net *net = sock_net(sk);
 
-		security_sk_classify_flow(sk, &fl);
-		rt = ip_route_output_flow(net, &fl, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+		rt = ip_route_output_flow(net, &fl4, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			rt = NULL;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b7b0921..b111f468 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -22,16 +22,16 @@ static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
 {
-	struct flowi fl = {
-		.fl4_dst = daddr->a4,
-		.fl4_tos = tos,
+	struct flowi4 fl4 = {
+		.daddr = daddr->a4,
+		.flowi4_tos = tos,
 	};
 	struct rtable *rt;
 
 	if (saddr)
-		fl.fl4_src = saddr->a4;
+		fl4.saddr = saddr->a4;
 
-	rt = __ip_route_output_key(net, &fl);
+	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt))
 		return &rt->dst;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index cc8071f..7dc00e3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -165,14 +165,14 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 			return 0;
 		refdst_drop(orefdst);
 	} else {
-		struct flowi fl = {
-			.fl4_dst = iph->daddr,
-			.fl4_src = iph->saddr,
-			.fl4_tos = RT_TOS(iph->tos),
-			.flowi_mark = skb->mark,
+		struct flowi4 fl4 = {
+			.daddr = iph->daddr,
+			.saddr = iph->saddr,
+			.flowi4_tos = RT_TOS(iph->tos),
+			.flowi4_mark = skb->mark,
 		};
 
-		rt = ip_route_output_key(net, &fl);
+		rt = ip_route_output_key(net, &fl4);
 		if (IS_ERR(rt))
 			return 0;
 		if (!(rt->rt_flags & RTCF_LOCAL)) {
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index cb14ae2..d8c00f9 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -62,18 +62,18 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct net *net = pick_net(skb);
 	struct rtable *rt;
-	struct flowi fl;
+	struct flowi4 fl4;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl4, 0, sizeof(fl4));
 	if (info->priv) {
 		if (info->priv->oif == -1)
 			return false;
-		fl.flowi_oif = info->priv->oif;
+		fl4.flowi4_oif = info->priv->oif;
 	}
-	fl.fl4_dst = info->gw.ip;
-	fl.fl4_tos = RT_TOS(iph->tos);
-	fl.fl4_scope = RT_SCOPE_UNIVERSE;
-	rt = ip_route_output_key(net, &fl);
+	fl4.daddr = info->gw.ip;
+	fl4.flowi4_tos = RT_TOS(iph->tos);
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		return false;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index b6fa294..31c0456 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -468,30 +468,30 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *saddr)
 {
 	struct rtable *rt;
-	struct flowi fl;
+	struct flowi4 fl4;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	struct dst_entry *dst = NULL;
 	union sctp_addr dst_saddr;
 
-	memset(&fl, 0x0, sizeof(struct flowi));
-	fl.fl4_dst  = daddr->v4.sin_addr.s_addr;
-	fl.fl4_dport = daddr->v4.sin_port;
-	fl.flowi_proto = IPPROTO_SCTP;
+	memset(&fl4, 0x0, sizeof(struct flowi4));
+	fl4.daddr  = daddr->v4.sin_addr.s_addr;
+	fl4.uli.ports.dport = daddr->v4.sin_port;
+	fl4.flowi4_proto = IPPROTO_SCTP;
 	if (asoc) {
-		fl.fl4_tos = RT_CONN_FLAGS(asoc->base.sk);
-		fl.flowi_oif = asoc->base.sk->sk_bound_dev_if;
-		fl.fl4_sport = htons(asoc->base.bind_addr.port);
+		fl4.flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
+		fl4.flowi4_oif = asoc->base.sk->sk_bound_dev_if;
+		fl4.uli.ports.sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
-		fl.fl4_src = saddr->v4.sin_addr.s_addr;
-		fl.fl4_sport = saddr->v4.sin_port;
+		fl4.saddr = saddr->v4.sin_addr.s_addr;
+		fl4.uli.ports.sport = saddr->v4.sin_port;
 	}
 
 	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
-			  __func__, &fl.fl4_dst, &fl.fl4_src);
+			  __func__, &fl4.daddr, &fl4.saddr);
 
-	rt = ip_route_output_key(&init_net, &fl);
+	rt = ip_route_output_key(&init_net, &fl4);
 	if (!IS_ERR(rt))
 		dst = &rt->dst;
 
@@ -533,9 +533,9 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 			continue;
 		if ((laddr->state == SCTP_ADDR_SRC) &&
 		    (AF_INET == laddr->a.sa.sa_family)) {
-			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
-			fl.fl4_sport = laddr->a.v4.sin_port;
-			rt = ip_route_output_key(&init_net, &fl);
+			fl4.saddr = laddr->a.v4.sin_addr.s_addr;
+			fl4.uli.ports.sport = laddr->a.v4.sin_port;
+			rt = ip_route_output_key(&init_net, &fl4);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
 				goto out_unlock;
-- 
1.7.4.1

