From: David Miller <davem@davemloft.net>
Subject: [PATCH 22/25] net: Put fl4_* macros to struct flowi4 and use them
 again.
Date: Sat, 12 Mar 2011 15:30:30 -0800 (PST)
Message-ID: <20110312.153030.258112884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756279Ab1CLX3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:29:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7CF8324C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:30:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h                     |   18 +++++++-----------
 include/net/route.h                    |   14 +++++++-------
 net/dccp/ipv4.c                        |    4 ++--
 net/ipv4/icmp.c                        |    4 ++--
 net/ipv4/inet_connection_sock.c        |    4 ++--
 net/ipv4/ip_output.c                   |    4 ++--
 net/ipv4/netfilter/nf_nat_standalone.c |    4 ++--
 net/ipv4/raw.c                         |    4 ++--
 net/ipv4/syncookies.c                  |    4 ++--
 net/ipv4/udp.c                         |   10 +++++-----
 net/ipv4/xfrm4_policy.c                |   18 +++++++++---------
 net/sctp/protocol.c                    |    8 ++++----
 12 files changed, 46 insertions(+), 50 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8d5b402..44bd376 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -61,6 +61,13 @@ struct flowi4 {
 	__be32			daddr;
 	__be32			saddr;
 	union flowi_uli		uli;
+#define fl4_sport		uli.ports.sport
+#define fl4_dport		uli.ports.dport
+#define fl4_icmp_type		uli.icmpt.type
+#define fl4_icmp_code		uli.icmpt.code
+#define fl4_ipsec_spi		uli.spi
+#define fl4_mh_type		uli.mht.type
+#define fl4_gre_key		uli.gre_key
 };
 
 struct flowi6 {
@@ -101,8 +108,6 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
-#define fl4_tos		flowi_tos
-#define fl4_scope	flowi_scope
 #define fld_scope	flowi_scope
 
 #define fld_dst		u.dn.daddr
@@ -110,15 +115,6 @@ struct flowi {
 #define fl6_dst		u.ip6.daddr
 #define fl6_src		u.ip6.saddr
 #define fl6_flowlabel	u.ip6.flowlabel
-#define fl4_dst		u.ip4.daddr
-#define fl4_src		u.ip4.saddr
-#define fl4_sport	u.ip4.uli.ports.sport
-#define fl4_dport	u.ip4.uli.ports.dport
-#define fl4_icmp_type	u.ip4.uli.icmpt.type
-#define fl4_icmp_code	u.ip4.uli.icmpt.code
-#define fl4_ipsec_spi	u.ip4.uli.spi
-#define fl4_mh_type	u.ip4.uli.mht.type
-#define fl4_gre_key	u.ip4.uli.gre_key
 #define fl6_sport	u.ip6.uli.ports.sport
 #define fl6_dport	u.ip6.uli.ports.dport
 #define fl6_icmp_type	u.ip6.uli.icmpt.type
diff --git a/include/net/route.h b/include/net/route.h
index 80b0353..30d6cae 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -157,8 +157,8 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct sock
 		.saddr = saddr,
 		.flowi4_tos = tos,
 		.flowi4_proto = proto,
-		.uli.ports.dport = dport,
-		.uli.ports.sport = sport,
+		.fl4_dport = dport,
+		.fl4_sport = sport,
 	};
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
@@ -175,7 +175,7 @@ static inline struct rtable *ip_route_output_gre(struct net *net,
 		.saddr = saddr,
 		.flowi4_tos = tos,
 		.flowi4_proto = IPPROTO_GRE,
-		.uli.gre_key = gre_key,
+		.fl4_gre_key = gre_key,
 	};
 	return ip_route_output_key(net, &fl4);
 }
@@ -235,8 +235,8 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 		.saddr = src,
 		.flowi4_tos = tos,
 		.flowi4_proto = protocol,
-		.uli.ports.sport = sport,
-		.uli.ports.dport = dport,
+		.fl4_sport = sport,
+		.fl4_dport = dport,
 	};
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
@@ -273,8 +273,8 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 			.saddr = rt->rt_key_src,
 			.flowi4_tos = rt->rt_tos,
 			.flowi4_proto = protocol,
-			.uli.ports.sport = sport,
-			.uli.ports.dport = dport
+			.fl4_sport = sport,
+			.fl4_dport = dport
 		};
 		if (inet_sk(sk)->transparent)
 			fl4.flowi4_flags |= FLOWI_FLAG_ANYSRC;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index be98470..ae451c6 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -471,8 +471,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		.saddr = ip_hdr(skb)->daddr,
 		.flowi4_tos = RT_CONN_FLAGS(sk),
 		.flowi4_proto = sk->sk_protocol,
-		.uli.ports.sport = dccp_hdr(skb)->dccph_dport,
-		.uli.ports.dport = dccp_hdr(skb)->dccph_sport,
+		.fl4_sport = dccp_hdr(skb)->dccph_dport,
+		.fl4_dport = dccp_hdr(skb)->dccph_sport,
 	};
 
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 8eca3c2..a91dc16 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -384,8 +384,8 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 		.saddr = saddr,
 		.flowi4_tos = RT_TOS(tos),
 		.flowi4_proto = IPPROTO_ICMP,
-		.uli.icmpt.type = type,
-		.uli.icmpt.code = code,
+		.fl4_icmp_type = type,
+		.fl4_icmp_code = code,
 	};
 	struct rtable *rt, *rt2;
 	int err;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index beecc12..6c0b7f4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -365,8 +365,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 		.flowi4_tos = RT_CONN_FLAGS(sk),
 		.flowi4_proto = sk->sk_protocol,
 		.flowi4_flags = inet_sk_flowi_flags(sk),
-		.uli.ports.sport = inet_sk(sk)->inet_sport,
-		.uli.ports.dport = ireq->rmt_port,
+		.fl4_sport = inet_sk(sk)->inet_sport,
+		.fl4_dport = ireq->rmt_port,
 	};
 	struct net *net = sock_net(sk);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2b9cc40..67f241b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1479,8 +1479,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 			.daddr = daddr,
 			.saddr = rt->rt_spec_dst,
 			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.uli.ports.sport = tcp_hdr(skb)->dest,
-			.uli.ports.dport = tcp_hdr(skb)->source,
+			.fl4_sport = tcp_hdr(skb)->dest,
+			.fl4_dport = tcp_hdr(skb)->source,
 			.flowi4_proto = sk->sk_protocol,
 			.flowi4_flags = ip_reply_arg_flowi_flags(arg),
 		};
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 963320b..7317bdf 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -56,7 +56,7 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl4->uli.ports.dport = t->dst.u.tcp.port;
+			fl4->fl4_dport = t->dst.u.tcp.port;
 	}
 
 	statusbit ^= IPS_NAT_MASK;
@@ -68,7 +68,7 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl4->uli.ports.sport = t->src.u.tcp.port;
+			fl4->fl4_sport = t->src.u.tcp.port;
 	}
 }
 #endif
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 452e178..e837ffd 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -433,8 +433,8 @@ static int raw_probe_proto_opt(struct flowi4 *fl4, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl4->uli.icmpt.type, type) ||
-				    get_user(fl4->uli.icmpt.code, code))
+				if (get_user(fl4->fl4_icmp_type, type) ||
+				    get_user(fl4->fl4_icmp_code, code))
 					return -EFAULT;
 				probed = 1;
 			}
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index e3b5b75..8b44c6d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -353,8 +353,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			.flowi4_tos = RT_CONN_FLAGS(sk),
 			.flowi4_proto = IPPROTO_TCP,
 			.flowi4_flags = inet_sk_flowi_flags(sk),
-			.uli.ports.sport = th->dest,
-			.uli.ports.dport = th->source,
+			.fl4_sport = th->dest,
+			.fl4_dport = th->source,
 		};
 		security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 		rt = ip_route_output_key(sock_net(sk), &fl4);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 91cba3c..588f47a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -778,7 +778,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	if (!skb)
 		goto out;
 
-	err = udp_send_skb(skb, fl4->daddr, fl4->uli.ports.dport);
+	err = udp_send_skb(skb, fl4->daddr, fl4->fl4_dport);
 
 out:
 	up->len = 0;
@@ -918,8 +918,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			.flowi4_proto = sk->sk_protocol,
 			.flowi4_flags = (inet_sk_flowi_flags(sk) |
 					 FLOWI_FLAG_CAN_SLEEP),
-			.uli.ports.sport = inet->inet_sport,
-			.uli.ports.dport = dport,
+			.fl4_sport = inet->inet_sport,
+			.fl4_dport = dport,
 		};
 		struct net *net = sock_net(sk);
 
@@ -976,8 +976,8 @@ back_from_confirm:
 	fl4 = &inet->cork.fl.u.ip4;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
-	fl4->uli.ports.dport = dport;
-	fl4->uli.ports.sport = inet->inet_sport;
+	fl4->fl4_dport = dport;
+	fl4->fl4_sport = inet->inet_sport;
 	up->pending = AF_INET;
 
 do_append_data:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 30b312c..13e0e7f 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -119,8 +119,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)xprth;
 
-				fl4->uli.ports.sport = ports[!!reverse];
-				fl4->uli.ports.dport = ports[!reverse];
+				fl4->fl4_sport = ports[!!reverse];
+				fl4->fl4_dport = ports[!reverse];
 			}
 			break;
 
@@ -128,8 +128,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
 				u8 *icmp = xprth;
 
-				fl4->uli.icmpt.type = icmp[0];
-				fl4->uli.icmpt.code = icmp[1];
+				fl4->fl4_icmp_type = icmp[0];
+				fl4->fl4_icmp_code = icmp[1];
 			}
 			break;
 
@@ -137,7 +137,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be32 *ehdr = (__be32 *)xprth;
 
-				fl4->uli.spi = ehdr[0];
+				fl4->fl4_ipsec_spi = ehdr[0];
 			}
 			break;
 
@@ -145,7 +145,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
 				__be32 *ah_hdr = (__be32*)xprth;
 
-				fl4->uli.spi = ah_hdr[1];
+				fl4->fl4_ipsec_spi = ah_hdr[1];
 			}
 			break;
 
@@ -153,7 +153,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ipcomp_hdr = (__be16 *)xprth;
 
-				fl4->uli.spi = htonl(ntohs(ipcomp_hdr[1]));
+				fl4->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
 			break;
 
@@ -165,13 +165,13 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 				if (greflags[0] & GRE_KEY) {
 					if (greflags[0] & GRE_CSUM)
 						gre_hdr++;
-					fl4->uli.gre_key = gre_hdr[1];
+					fl4->fl4_gre_key = gre_hdr[1];
 				}
 			}
 			break;
 
 		default:
-			fl4->uli.spi = 0;
+			fl4->fl4_ipsec_spi = 0;
 			break;
 		}
 	}
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 31c0456..152976e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -476,16 +476,16 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 
 	memset(&fl4, 0x0, sizeof(struct flowi4));
 	fl4.daddr  = daddr->v4.sin_addr.s_addr;
-	fl4.uli.ports.dport = daddr->v4.sin_port;
+	fl4.fl4_dport = daddr->v4.sin_port;
 	fl4.flowi4_proto = IPPROTO_SCTP;
 	if (asoc) {
 		fl4.flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
 		fl4.flowi4_oif = asoc->base.sk->sk_bound_dev_if;
-		fl4.uli.ports.sport = htons(asoc->base.bind_addr.port);
+		fl4.fl4_sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
 		fl4.saddr = saddr->v4.sin_addr.s_addr;
-		fl4.uli.ports.sport = saddr->v4.sin_port;
+		fl4.fl4_sport = saddr->v4.sin_port;
 	}
 
 	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
@@ -534,7 +534,7 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		if ((laddr->state == SCTP_ADDR_SRC) &&
 		    (AF_INET == laddr->a.sa.sa_family)) {
 			fl4.saddr = laddr->a.v4.sin_addr.s_addr;
-			fl4.uli.ports.sport = laddr->a.v4.sin_port;
+			fl4.fl4_sport = laddr->a.v4.sin_port;
 			rt = ip_route_output_key(&init_net, &fl4);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
-- 
1.7.4.1

