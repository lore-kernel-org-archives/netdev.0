From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/25] net: Make flowi ports AF dependent.
Date: Sat, 12 Mar 2011 15:26:35 -0800 (PST)
Message-ID: <20110312.152635.260087519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755551Ab1CLXZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:25:58 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DC33324C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:26:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Create two sets of port member accessors, one set prefixed by fl4_*
and the other prefixed by fl6_*

This will let us to create AF optimal flow instances.

It will work because every context in which we access the ports,
we have to be fully aware of which AF the flowi is anyways.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h                     |   21 ++++++++++-----
 include/net/route.h                    |   43 +++++++++++++++++---------------
 include/net/xfrm.h                     |   18 ++++++------
 net/dccp/ipv4.c                        |    4 +-
 net/dccp/ipv6.c                        |   20 +++++++-------
 net/ipv4/icmp.c                        |    4 +-
 net/ipv4/inet_connection_sock.c        |    4 +-
 net/ipv4/ip_output.c                   |    4 +-
 net/ipv4/netfilter/nf_nat_standalone.c |    4 +-
 net/ipv4/raw.c                         |    4 +-
 net/ipv4/syncookies.c                  |    4 +-
 net/ipv4/udp.c                         |   10 +++---
 net/ipv4/xfrm4_policy.c                |   18 ++++++------
 net/ipv4/xfrm4_state.c                 |    4 +-
 net/ipv6/af_inet6.c                    |    4 +-
 net/ipv6/datagram.c                    |    6 ++--
 net/ipv6/icmp.c                        |   10 +++---
 net/ipv6/inet6_connection_sock.c       |    8 +++---
 net/ipv6/mip6.c                        |    6 ++--
 net/ipv6/netfilter/ip6t_REJECT.c       |    4 +-
 net/ipv6/raw.c                         |    6 ++--
 net/ipv6/syncookies.c                  |    4 +-
 net/ipv6/tcp_ipv6.c                    |   16 ++++++------
 net/ipv6/udp.c                         |   10 +++---
 net/ipv6/xfrm6_policy.c                |   12 ++++----
 net/ipv6/xfrm6_state.c                 |    4 +-
 net/sctp/protocol.c                    |    8 +++---
 net/xfrm/xfrm_policy.c                 |    8 +++---
 28 files changed, 139 insertions(+), 129 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 541ac13..f19f41d 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -89,13 +89,20 @@ struct flowi {
 #define fl4_scope	flowi_scope
 
 	union flowi_uli uli_u;
-#define fl_ip_sport	uli_u.ports.sport
-#define fl_ip_dport	uli_u.ports.dport
-#define fl_icmp_type	uli_u.icmpt.type
-#define fl_icmp_code	uli_u.icmpt.code
-#define fl_ipsec_spi	uli_u.spi
-#define fl_mh_type	uli_u.mht.type
-#define fl_gre_key	uli_u.gre_key
+#define fl4_sport	uli_u.ports.sport
+#define fl4_dport	uli_u.ports.dport
+#define fl4_icmp_type	uli_u.icmpt.type
+#define fl4_icmp_code	uli_u.icmpt.code
+#define fl4_ipsec_spi	uli_u.spi
+#define fl4_mh_type	uli_u.mht.type
+#define fl4_gre_key	uli_u.gre_key
+#define fl6_sport	uli_u.ports.sport
+#define fl6_dport	uli_u.ports.dport
+#define fl6_icmp_type	uli_u.icmpt.type
+#define fl6_icmp_code	uli_u.icmpt.code
+#define fl6_ipsec_spi	uli_u.spi
+#define fl6_mh_type	uli_u.mht.type
+#define fl6_gre_key	uli_u.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
diff --git a/include/net/route.h b/include/net/route.h
index 3d814f8..4c207f9 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -157,8 +157,8 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct sock
 		.fl4_src = saddr,
 		.fl4_tos = tos,
 		.flowi_proto = proto,
-		.fl_ip_dport = dport,
-		.fl_ip_sport = sport,
+		.fl4_dport = dport,
+		.fl4_sport = sport,
 	};
 	if (sk)
 		security_sk_classify_flow(sk, &fl);
@@ -175,7 +175,7 @@ static inline struct rtable *ip_route_output_gre(struct net *net,
 		.fl4_src = saddr,
 		.fl4_tos = tos,
 		.flowi_proto = IPPROTO_GRE,
-		.fl_gre_key = gre_key,
+		.fl4_gre_key = gre_key,
 	};
 	return ip_route_output_key(net, &fl);
 }
@@ -228,14 +228,16 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 					      __be16 sport, __be16 dport,
 					      struct sock *sk, bool can_sleep)
 {
-	struct flowi fl = { .flowi_oif = oif,
-			    .flowi_mark = sk->sk_mark,
-			    .fl4_dst = dst,
-			    .fl4_src = src,
-			    .fl4_tos = tos,
-			    .flowi_proto = protocol,
-			    .fl_ip_sport = sport,
-			    .fl_ip_dport = dport };
+	struct flowi fl = {
+		.flowi_oif = oif,
+		.flowi_mark = sk->sk_mark,
+		.fl4_dst = dst,
+		.fl4_src = src,
+		.fl4_tos = tos,
+		.flowi_proto = protocol,
+		.fl4_sport = sport,
+		.fl4_dport = dport,
+	};
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
 
@@ -264,15 +266,16 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = { .flowi_oif = rt->rt_oif,
-				    .flowi_mark = rt->rt_mark,
-				    .fl4_dst = rt->rt_key_dst,
-				    .fl4_src = rt->rt_key_src,
-				    .fl4_tos = rt->rt_tos,
-				    .flowi_proto = protocol,
-				    .fl_ip_sport = sport,
-				    .fl_ip_dport = dport };
-
+		struct flowi fl = {
+			.flowi_oif = rt->rt_oif,
+			.flowi_mark = rt->rt_mark,
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.flowi_proto = protocol,
+			.fl4_sport = sport,
+			.fl4_dport = dport
+		};
 		if (inet_sk(sk)->transparent)
 			fl.flowi_flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d5a12d1..aa860ad 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -800,7 +800,7 @@ static inline bool addr_match(const void *token1, const void *token2,
 }
 
 static __inline__
-__be16 xfrm_flowi_sport(const struct flowi *fl)
+__be16 xfrm_flowi_sport(const struct flowi *fl, const union flowi_uli *uli)
 {
 	__be16 port;
 	switch(fl->flowi_proto) {
@@ -808,17 +808,17 @@ __be16 xfrm_flowi_sport(const struct flowi *fl)
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
-		port = fl->fl_ip_sport;
+		port = uli->ports.sport;
 		break;
 	case IPPROTO_ICMP:
 	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_type);
+		port = htons(uli->icmpt.type);
 		break;
 	case IPPROTO_MH:
-		port = htons(fl->fl_mh_type);
+		port = htons(uli->mht.type);
 		break;
 	case IPPROTO_GRE:
-		port = htons(ntohl(fl->fl_gre_key) >> 16);
+		port = htons(ntohl(uli->gre_key) >> 16);
 		break;
 	default:
 		port = 0;	/*XXX*/
@@ -827,7 +827,7 @@ __be16 xfrm_flowi_sport(const struct flowi *fl)
 }
 
 static __inline__
-__be16 xfrm_flowi_dport(const struct flowi *fl)
+__be16 xfrm_flowi_dport(const struct flowi *fl, const union flowi_uli *uli)
 {
 	__be16 port;
 	switch(fl->flowi_proto) {
@@ -835,14 +835,14 @@ __be16 xfrm_flowi_dport(const struct flowi *fl)
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
-		port = fl->fl_ip_dport;
+		port = uli->ports.dport;
 		break;
 	case IPPROTO_ICMP:
 	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_code);
+		port = htons(uli->icmpt.code);
 		break;
 	case IPPROTO_GRE:
-		port = htons(ntohl(fl->fl_gre_key) & 0xffff);
+		port = htons(ntohl(uli->gre_key) & 0xffff);
 		break;
 	default:
 		port = 0;	/*XXX*/
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 09a0991..d934b20 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -471,8 +471,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		.fl4_src = ip_hdr(skb)->daddr,
 		.fl4_tos = RT_CONN_FLAGS(sk),
 		.flowi_proto = sk->sk_protocol,
-		.fl_ip_sport = dccp_hdr(skb)->dccph_dport,
-		.fl_ip_dport = dccp_hdr(skb)->dccph_sport,
+		.fl4_sport = dccp_hdr(skb)->dccph_dport,
+		.fl4_dport = dccp_hdr(skb)->dccph_sport,
 	};
 
 	security_skb_classify_flow(skb, &fl);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5209ee7..2b351c6 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -158,8 +158,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.flowi_oif = sk->sk_bound_dev_if;
-			fl.fl_ip_dport = inet->inet_dport;
-			fl.fl_ip_sport = inet->inet_sport;
+			fl.fl6_dport = inet->inet_dport;
+			fl.fl6_sport = inet->inet_sport;
 			security_sk_classify_flow(sk, &fl);
 
 			dst = ip6_dst_lookup_flow(sk, &fl, NULL, false);
@@ -253,8 +253,8 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 	fl.fl6_flowlabel = 0;
 	fl.flowi_oif = ireq6->iif;
-	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-	fl.fl_ip_sport = inet_rsk(req)->loc_port;
+	fl.fl6_dport = inet_rsk(req)->rmt_port;
+	fl.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
@@ -323,8 +323,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	fl.flowi_proto = IPPROTO_DCCP;
 	fl.flowi_oif = inet6_iif(rxskb);
-	fl.fl_ip_dport = dccp_hdr(skb)->dccph_dport;
-	fl.fl_ip_sport = dccp_hdr(skb)->dccph_sport;
+	fl.fl6_dport = dccp_hdr(skb)->dccph_dport;
+	fl.fl6_sport = dccp_hdr(skb)->dccph_sport;
 	security_skb_classify_flow(rxskb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
@@ -535,8 +535,8 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		final_p = fl6_update_dst(&fl, opt, &final);
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.flowi_oif = sk->sk_bound_dev_if;
-		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_rsk(req)->loc_port;
+		fl.fl6_dport = inet_rsk(req)->rmt_port;
+		fl.fl6_sport = inet_rsk(req)->loc_port;
 		security_sk_classify_flow(sk, &fl);
 
 		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
@@ -957,8 +957,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
 	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.fl_ip_dport = usin->sin6_port;
-	fl.fl_ip_sport = inet->inet_sport;
+	fl.fl6_dport = usin->sin6_port;
+	fl.fl6_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, &fl);
 
 	final_p = fl6_update_dst(&fl, np->opt, &final);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3fde7f2..8d09195 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -384,8 +384,8 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 		.fl4_src = saddr,
 		.fl4_tos = RT_TOS(tos),
 		.flowi_proto = IPPROTO_ICMP,
-		.fl_icmp_type = type,
-		.fl_icmp_code = code,
+		.fl4_icmp_type = type,
+		.fl4_icmp_code = code,
 	};
 	struct rtable *rt, *rt2;
 	int err;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 9708170..10a8e95 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -365,8 +365,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 		.fl4_tos = RT_CONN_FLAGS(sk),
 		.flowi_proto = sk->sk_protocol,
 		.flowi_flags = inet_sk_flowi_flags(sk),
-		.fl_ip_sport = inet_sk(sk)->inet_sport,
-		.fl_ip_dport = ireq->rmt_port,
+		.fl4_sport = inet_sk(sk)->inet_sport,
+		.fl4_dport = ireq->rmt_port,
 	};
 	struct net *net = sock_net(sk);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e35ca40..67e5f71 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1479,8 +1479,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 			.fl4_dst = daddr,
 			.fl4_src = rt->rt_spec_dst,
 			.fl4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.fl_ip_sport = tcp_hdr(skb)->dest,
-			.fl_ip_dport = tcp_hdr(skb)->source,
+			.fl4_sport = tcp_hdr(skb)->dest,
+			.fl4_dport = tcp_hdr(skb)->source,
 			.flowi_proto = sk->sk_protocol,
 			.flowi_flags = ip_reply_arg_flowi_flags(arg),
 		};
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 95481fe..1f3c695 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -55,7 +55,7 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl->fl_ip_dport = t->dst.u.tcp.port;
+			fl->fl4_dport = t->dst.u.tcp.port;
 	}
 
 	statusbit ^= IPS_NAT_MASK;
@@ -67,7 +67,7 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl->fl_ip_sport = t->src.u.tcp.port;
+			fl->fl4_sport = t->src.u.tcp.port;
 	}
 }
 #endif
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index b42b7cd..333b826 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -433,8 +433,8 @@ static int raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl->fl_icmp_type, type) ||
-				    get_user(fl->fl_icmp_code, code))
+				if (get_user(fl->fl4_icmp_type, type) ||
+				    get_user(fl->fl4_icmp_code, code))
 					return -EFAULT;
 				probed = 1;
 			}
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 98d47dc..d90529d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -353,8 +353,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			.fl4_tos = RT_CONN_FLAGS(sk),
 			.flowi_proto = IPPROTO_TCP,
 			.flowi_flags = inet_sk_flowi_flags(sk),
-			.fl_ip_sport = th->dest,
-			.fl_ip_dport = th->source,
+			.fl4_sport = th->dest,
+			.fl4_dport = th->source,
 		};
 		security_req_classify_flow(req, &fl);
 		rt = ip_route_output_key(sock_net(sk), &fl);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e10f62e..116e4a8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -778,7 +778,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	if (!skb)
 		goto out;
 
-	err = udp_send_skb(skb, fl->fl4_dst, fl->fl_ip_dport);
+	err = udp_send_skb(skb, fl->fl4_dst, fl->fl4_dport);
 
 out:
 	up->len = 0;
@@ -917,8 +917,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			.flowi_proto = sk->sk_protocol,
 			.flowi_flags = (inet_sk_flowi_flags(sk) |
 				     FLOWI_FLAG_CAN_SLEEP),
-			.fl_ip_sport = inet->inet_sport,
-			.fl_ip_dport = dport,
+			.fl4_sport = inet->inet_sport,
+			.fl4_dport = dport,
 		};
 		struct net *net = sock_net(sk);
 
@@ -973,9 +973,9 @@ back_from_confirm:
 	 *	Now cork the socket to pend data.
 	 */
 	inet->cork.fl.fl4_dst = daddr;
-	inet->cork.fl.fl_ip_dport = dport;
+	inet->cork.fl.fl4_dport = dport;
 	inet->cork.fl.fl4_src = saddr;
-	inet->cork.fl.fl_ip_sport = inet->inet_sport;
+	inet->cork.fl.fl4_sport = inet->inet_sport;
 	up->pending = AF_INET;
 
 do_append_data:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4294f12..b7b0921 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -117,8 +117,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)xprth;
 
-				fl->fl_ip_sport = ports[!!reverse];
-				fl->fl_ip_dport = ports[!reverse];
+				fl->fl4_sport = ports[!!reverse];
+				fl->fl4_dport = ports[!reverse];
 			}
 			break;
 
@@ -126,8 +126,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
 				u8 *icmp = xprth;
 
-				fl->fl_icmp_type = icmp[0];
-				fl->fl_icmp_code = icmp[1];
+				fl->fl4_icmp_type = icmp[0];
+				fl->fl4_icmp_code = icmp[1];
 			}
 			break;
 
@@ -135,7 +135,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be32 *ehdr = (__be32 *)xprth;
 
-				fl->fl_ipsec_spi = ehdr[0];
+				fl->fl4_ipsec_spi = ehdr[0];
 			}
 			break;
 
@@ -143,7 +143,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
 				__be32 *ah_hdr = (__be32*)xprth;
 
-				fl->fl_ipsec_spi = ah_hdr[1];
+				fl->fl4_ipsec_spi = ah_hdr[1];
 			}
 			break;
 
@@ -151,7 +151,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ipcomp_hdr = (__be16 *)xprth;
 
-				fl->fl_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
+				fl->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
 			break;
 
@@ -163,13 +163,13 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 				if (greflags[0] & GRE_KEY) {
 					if (greflags[0] & GRE_CSUM)
 						gre_hdr++;
-					fl->fl_gre_key = gre_hdr[1];
+					fl->fl4_gre_key = gre_hdr[1];
 				}
 			}
 			break;
 
 		default:
-			fl->fl_ipsec_spi = 0;
+			fl->fl4_ipsec_spi = 0;
 			break;
 		}
 	}
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index d231434..663b550 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -25,9 +25,9 @@ __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	sel->daddr.a4 = fl->fl4_dst;
 	sel->saddr.a4 = fl->fl4_src;
-	sel->dport = xfrm_flowi_dport(fl);
+	sel->dport = xfrm_flowi_dport(fl, &fl->uli_u);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl);
+	sel->sport = xfrm_flowi_sport(fl, &fl->uli_u);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET;
 	sel->prefixlen_d = 32;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 35b0be0..923febe 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -661,8 +661,8 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl.fl6_flowlabel = np->flow_label;
 		fl.flowi_oif = sk->sk_bound_dev_if;
 		fl.flowi_mark = sk->sk_mark;
-		fl.fl_ip_dport = inet->inet_dport;
-		fl.fl_ip_sport = inet->inet_sport;
+		fl.fl6_dport = inet->inet_dport;
+		fl.fl6_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, &fl);
 
 		final_p = fl6_update_dst(&fl, np->opt, &final);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 6c24b26..07e03e6 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -151,8 +151,8 @@ ipv4_connected:
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.flowi_mark = sk->sk_mark;
-	fl.fl_ip_dport = inet->inet_dport;
-	fl.fl_ip_sport = inet->inet_sport;
+	fl.fl6_dport = inet->inet_dport;
+	fl.fl6_sport = inet->inet_sport;
 
 	if (!fl.flowi_oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl.flowi_oif = np->mcast_oif;
@@ -261,7 +261,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
 	serr->ee.ee_info = info;
 	serr->ee.ee_data = 0;
 	serr->addr_offset = (u8 *)&iph->daddr - skb_network_header(skb);
-	serr->port = fl->fl_ip_dport;
+	serr->port = fl->fl6_dport;
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
 	skb_reset_transport_header(skb);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9e123e0..52ff7aa 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -448,8 +448,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (saddr)
 		ipv6_addr_copy(&fl.fl6_src, saddr);
 	fl.flowi_oif = iif;
-	fl.fl_icmp_type = type;
-	fl.fl_icmp_code = code;
+	fl.fl6_icmp_type = type;
+	fl.fl6_icmp_code = code;
 	security_skb_classify_flow(skb, &fl);
 
 	sk = icmpv6_xmit_lock(net);
@@ -544,7 +544,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (saddr)
 		ipv6_addr_copy(&fl.fl6_src, saddr);
 	fl.flowi_oif = skb->dev->ifindex;
-	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
+	fl.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	security_skb_classify_flow(skb, &fl);
 
 	sk = icmpv6_xmit_lock(net);
@@ -794,8 +794,8 @@ void icmpv6_flow_init(struct sock *sk, struct flowi *fl,
 	ipv6_addr_copy(&fl->fl6_src, saddr);
 	ipv6_addr_copy(&fl->fl6_dst, daddr);
 	fl->flowi_proto	 	= IPPROTO_ICMPV6;
-	fl->fl_icmp_type	= type;
-	fl->fl_icmp_code	= 0;
+	fl->fl6_icmp_type	= type;
+	fl->fl6_icmp_code	= 0;
 	fl->flowi_oif		= oif;
 	security_sk_classify_flow(sk, fl);
 }
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 673f9bf..1b06a24 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -70,8 +70,8 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.flowi_mark = sk->sk_mark;
-	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-	fl.fl_ip_sport = inet_rsk(req)->loc_port;
+	fl.fl6_dport = inet_rsk(req)->rmt_port;
+	fl.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
 	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
@@ -220,8 +220,8 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.flowi_mark = sk->sk_mark;
-	fl.fl_ip_sport = inet->inet_sport;
-	fl.fl_ip_dport = inet->inet_dport;
+	fl.fl6_sport = inet->inet_sport;
+	fl.fl6_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, &fl);
 
 	final_p = fl6_update_dst(&fl, np->opt, &final);
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index e2f852c..5038e6b 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -215,7 +215,7 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	int err = 0;
 
 	if (unlikely(fl->flowi_proto == IPPROTO_MH &&
-		     fl->fl_mh_type <= IP6_MH_TYPE_MAX))
+		     fl->fl6_mh_type <= IP6_MH_TYPE_MAX))
 		goto out;
 
 	if (likely(opt->dsthao)) {
@@ -241,10 +241,10 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	sel.prefixlen_s = 128;
 	sel.family = AF_INET6;
 	sel.proto = fl->flowi_proto;
-	sel.dport = xfrm_flowi_dport(fl);
+	sel.dport = xfrm_flowi_dport(fl, &fl->uli_u);
 	if (sel.dport)
 		sel.dport_mask = htons(~0);
-	sel.sport = xfrm_flowi_sport(fl);
+	sel.sport = xfrm_flowi_sport(fl, &fl->uli_u);
 	if (sel.sport)
 		sel.sport_mask = htons(~0);
 	sel.ifindex = fl->flowi_oif;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index fd39388..d1e905b 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -93,8 +93,8 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	fl.flowi_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl.fl6_src, &oip6h->daddr);
 	ipv6_addr_copy(&fl.fl6_dst, &oip6h->saddr);
-	fl.fl_ip_sport = otcph.dest;
-	fl.fl_ip_dport = otcph.source;
+	fl.fl6_sport = otcph.dest;
+	fl.fl6_dport = otcph.source;
 	security_skb_classify_flow(oldskb, &fl);
 	dst = ip6_route_output(net, NULL, &fl);
 	if (dst == NULL || dst->error) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 323ad44..d061465 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -694,8 +694,8 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl->fl_icmp_type, type) ||
-				    get_user(fl->fl_icmp_code, code))
+				if (get_user(fl->fl6_icmp_type, type) ||
+				    get_user(fl->fl6_icmp_code, code))
 					return -EFAULT;
 				probed = 1;
 			}
@@ -706,7 +706,7 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 			/* check if type field is readable or not. */
 			if (iov->iov_len > 2 - len) {
 				u8 __user *p = iov->iov_base;
-				if (get_user(fl->fl_mh_type, &p[2 - len]))
+				if (get_user(fl->fl6_mh_type, &p[2 - len]))
 					return -EFAULT;
 				probed = 1;
 			} else
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index ca5255c..5b9eded 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -240,8 +240,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.flowi_oif = sk->sk_bound_dev_if;
 		fl.flowi_mark = sk->sk_mark;
-		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_sk(sk)->inet_sport;
+		fl.fl6_dport = inet_rsk(req)->rmt_port;
+		fl.fl6_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, &fl);
 
 		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a3d1229..c531ad5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -248,8 +248,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		       (saddr ? saddr : &np->saddr));
 	fl.flowi_oif = sk->sk_bound_dev_if;
 	fl.flowi_mark = sk->sk_mark;
-	fl.fl_ip_dport = usin->sin6_port;
-	fl.fl_ip_sport = inet->inet_sport;
+	fl.fl6_dport = usin->sin6_port;
+	fl.fl6_sport = inet->inet_sport;
 
 	final_p = fl6_update_dst(&fl, np->opt, &final);
 
@@ -401,8 +401,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.flowi_oif = sk->sk_bound_dev_if;
 			fl.flowi_mark = sk->sk_mark;
-			fl.fl_ip_dport = inet->inet_dport;
-			fl.fl_ip_sport = inet->inet_sport;
+			fl.fl6_dport = inet->inet_dport;
+			fl.fl6_sport = inet->inet_sport;
 			security_skb_classify_flow(skb, &fl);
 
 			dst = ip6_dst_lookup_flow(sk, &fl, NULL, false);
@@ -493,8 +493,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	fl.fl6_flowlabel = 0;
 	fl.flowi_oif = treq->iif;
 	fl.flowi_mark = sk->sk_mark;
-	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-	fl.fl_ip_sport = inet_rsk(req)->loc_port;
+	fl.fl6_dport = inet_rsk(req)->rmt_port;
+	fl.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
@@ -1057,8 +1057,8 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 
 	fl.flowi_proto = IPPROTO_TCP;
 	fl.flowi_oif = inet6_iif(skb);
-	fl.fl_ip_dport = t1->dest;
-	fl.fl_ip_sport = t1->source;
+	fl.fl6_dport = t1->dest;
+	fl.fl6_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
 
 	/* Pass a socket to ip6_dst_lookup either it is for RST
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 91f8047..dad035f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -899,8 +899,8 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	 * Create a UDP header
 	 */
 	uh = udp_hdr(skb);
-	uh->source = fl->fl_ip_sport;
-	uh->dest = fl->fl_ip_dport;
+	uh->source = fl->fl6_sport;
+	uh->dest = fl->fl6_dport;
 	uh->len = htons(up->len);
 	uh->check = 0;
 
@@ -1036,7 +1036,7 @@ do_udp_sendmsg:
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		fl.fl_ip_dport = sin6->sin6_port;
+		fl.fl6_dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
@@ -1065,7 +1065,7 @@ do_udp_sendmsg:
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		fl.fl_ip_dport = inet->inet_dport;
+		fl.fl6_dport = inet->inet_dport;
 		daddr = &np->daddr;
 		fl.fl6_flowlabel = np->flow_label;
 		connected = 1;
@@ -1112,7 +1112,7 @@ do_udp_sendmsg:
 		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl_ip_sport = inet->inet_sport;
+	fl.fl6_sport = inet->inet_sport;
 
 	final_p = fl6_update_dst(&fl, opt, &final);
 	if (final_p)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d62496c..213c759 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -158,8 +158,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
 				__be16 *ports = (__be16 *)exthdr;
 
-				fl->fl_ip_sport = ports[!!reverse];
-				fl->fl_ip_dport = ports[!reverse];
+				fl->fl6_sport = ports[!!reverse];
+				fl->fl6_dport = ports[!reverse];
 			}
 			fl->flowi_proto = nexthdr;
 			return;
@@ -168,8 +168,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
 				u8 *icmp = (u8 *)exthdr;
 
-				fl->fl_icmp_type = icmp[0];
-				fl->fl_icmp_code = icmp[1];
+				fl->fl6_icmp_type = icmp[0];
+				fl->fl6_icmp_code = icmp[1];
 			}
 			fl->flowi_proto = nexthdr;
 			return;
@@ -180,7 +180,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 				struct ip6_mh *mh;
 				mh = (struct ip6_mh *)exthdr;
 
-				fl->fl_mh_type = mh->ip6mh_type;
+				fl->fl6_mh_type = mh->ip6mh_type;
 			}
 			fl->flowi_proto = nexthdr;
 			return;
@@ -191,7 +191,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_ESP:
 		case IPPROTO_COMP:
 		default:
-			fl->fl_ipsec_spi = 0;
+			fl->fl6_ipsec_spi = 0;
 			fl->flowi_proto = nexthdr;
 			return;
 		}
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 805d0e1..71277ce 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -26,9 +26,9 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	 * to current session. */
 	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl->fl6_dst);
 	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl->fl6_src);
-	sel->dport = xfrm_flowi_dport(fl);
+	sel->dport = xfrm_flowi_dport(fl, &fl->uli_u);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl);
+	sel->sport = xfrm_flowi_sport(fl, &fl->uli_u);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET6;
 	sel->prefixlen_d = 128;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 832665a..b6fa294 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -476,16 +476,16 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 
 	memset(&fl, 0x0, sizeof(struct flowi));
 	fl.fl4_dst  = daddr->v4.sin_addr.s_addr;
-	fl.fl_ip_dport = daddr->v4.sin_port;
+	fl.fl4_dport = daddr->v4.sin_port;
 	fl.flowi_proto = IPPROTO_SCTP;
 	if (asoc) {
 		fl.fl4_tos = RT_CONN_FLAGS(asoc->base.sk);
 		fl.flowi_oif = asoc->base.sk->sk_bound_dev_if;
-		fl.fl_ip_sport = htons(asoc->base.bind_addr.port);
+		fl.fl4_sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
 		fl.fl4_src = saddr->v4.sin_addr.s_addr;
-		fl.fl_ip_sport = saddr->v4.sin_port;
+		fl.fl4_sport = saddr->v4.sin_port;
 	}
 
 	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
@@ -534,7 +534,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		if ((laddr->state == SCTP_ADDR_SRC) &&
 		    (AF_INET == laddr->a.sa.sa_family)) {
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
-			fl.fl_ip_sport = laddr->a.v4.sin_port;
+			fl.fl4_sport = laddr->a.v4.sin_port;
 			rt = ip_route_output_key(&init_net, &fl);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dd6243f..d54b6e7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -61,8 +61,8 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl, &fl->uli_u) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl->uli_u) ^ sel->sport) & sel->sport_mask) &&
 		(fl->flowi_proto == sel->proto || !sel->proto) &&
 		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
@@ -72,8 +72,8 @@ __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl, &fl->uli_u) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl->uli_u) ^ sel->sport) & sel->sport_mask) &&
 		(fl->flowi_proto == sel->proto || !sel->proto) &&
 		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
-- 
1.7.4.1

