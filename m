From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next 3/4] net: core: Add the UID to flowi[46]_init_output.
Date: Sat, 26 Apr 2014 13:48:24 +0900
Message-ID: <1398487705-13430-4-git-send-email-lorenzo@google.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:64426 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaDZEsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:48:54 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so3917353pbc.37
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 21:48:54 -0700 (PDT)
In-Reply-To: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/flow.h               |  8 ++++++--
 include/net/ip.h                 |  1 +
 include/net/route.h              |  5 +++--
 net/ipv4/inet_connection_sock.c  |  6 ++++--
 net/ipv4/ip_output.c             |  3 ++-
 net/ipv4/ping.c                  |  3 ++-
 net/ipv4/raw.c                   |  3 ++-
 net/ipv4/route.c                 | 14 ++++++++------
 net/ipv4/syncookies.c            |  3 ++-
 net/ipv4/udp.c                   |  3 ++-
 net/ipv6/af_inet6.c              |  3 ++-
 net/ipv6/datagram.c              |  3 ++-
 net/ipv6/inet6_connection_sock.c |  6 ++++--
 net/ipv6/raw.c                   |  1 +
 net/ipv6/syncookies.c            |  3 ++-
 net/ipv6/tcp_ipv6.c              |  3 ++-
 net/ipv6/udp.c                   |  1 +
 17 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 9828829..da9b806 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -88,7 +88,8 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 				      __u32 mark, __u8 tos, __u8 scope,
 				      __u8 proto, __u8 flags,
 				      __be32 daddr, __be32 saddr,
-				      __be16 dport, __be16 sport)
+				      __be16 dport, __be16 sport,
+				      kuid_t uid)
 {
 	fl4->flowi4_oif = oif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
@@ -98,6 +99,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_proto = proto;
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_secid = 0;
+	fl4->flowi4_uid = uid;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
@@ -159,7 +161,8 @@ static inline void flowi6_init_output(struct flowi6 *fl6, int oif,
 				      __be32 flowlabel,
 				      struct in6_addr daddr,
 				      struct in6_addr saddr,
-				      __be16 dport, __be16 sport)
+				      __be16 dport, __be16 sport,
+				      kuid_t uid)
 {
 	fl6->flowi6_oif = oif;
 	fl6->flowi6_iif = 0;
@@ -167,6 +170,7 @@ static inline void flowi6_init_output(struct flowi6 *fl6, int oif,
 	fl6->flowi6_proto = proto;
 	fl6->flowi6_flags = flags;
 	fl6->flowi6_secid = 0;
+	fl6->flowi6_uid = uid;
 	fl6->daddr = daddr;
 	fl6->saddr = saddr;
 	fl6->flowlabel = flowlabel;
diff --git a/include/net/ip.h b/include/net/ip.h
index 3ec2b0f..0123f78 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -170,6 +170,7 @@ struct ip_reply_arg {
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
 	u8  	    tos;
+	kuid_t	    uid;
 }; 
 
 #define IP_REPLY_ARG_NOSRCCHECK 1
diff --git a/include/net/route.h b/include/net/route.h
index b17cf28..22a231c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -140,7 +140,7 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 	flowi4_init_output(fl4, oif, sk ? sk->sk_mark : 0, tos,
 			   RT_SCOPE_UNIVERSE, proto,
 			   sk ? inet_sk_flowi_flags(sk) : 0,
-			   daddr, saddr, dport, sport);
+			   daddr, saddr, dport, sport, sock_i_uid(sk));
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -249,7 +249,8 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags, dst, src, dport, sport);
+			   protocol, flow_flags, dst, src, dport, sport,
+			   sock_i_uid(sk));
 }
 
 static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0d1e2cb..b184140 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -413,7 +413,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 			   sk->sk_protocol,
 			   flags,
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport,
+			   sock_i_uid(sk));
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -449,7 +450,8 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport,
+			   sock_i_uid(sk));
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1cbeba5..49998a9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1506,7 +1506,8 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
 			   ip_reply_arg_flowi_flags(arg),
 			   daddr, saddr,
-			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
+			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest,
+			   arg->uid);
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8210964..8a912b8 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -778,7 +778,8 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
+			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0,
+			   sock_i_uid(sk));
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a9dbe58..1b56f9a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -577,7 +577,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk) |
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
-			   daddr, saddr, 0, 0);
+			   daddr, saddr, 0, 0,
+			   sock_i_uid(sk));
 
 	if (!inet->hdrincl) {
 		err = raw_probe_proto_opt(&fl4, msg);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index db1e0da..58017b1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -492,7 +492,7 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
-static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
+static void __build_flow_key(struct flowi4 *fl4, struct sock *sk,
 			     const struct iphdr *iph,
 			     int oif, u8 tos,
 			     u8 prot, u32 mark, int flow_flags)
@@ -508,11 +508,12 @@ static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 	flowi4_init_output(fl4, oif, mark, tos,
 			   RT_SCOPE_UNIVERSE, prot,
 			   flow_flags,
-			   iph->daddr, iph->saddr, 0, 0);
+			   iph->daddr, iph->saddr, 0, 0,
+			   sock_i_uid(sk));
 }
 
 static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
-			       const struct sock *sk)
+			       struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	int oif = skb->dev->ifindex;
@@ -523,7 +524,7 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
-static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
+static void build_sk_flow_key(struct flowi4 *fl4, struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	const struct ip_options_rcu *inet_opt;
@@ -537,11 +538,12 @@ static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk),
-			   daddr, inet->inet_saddr, 0, 0);
+			   daddr, inet->inet_saddr, 0, 0,
+			   sock_i_uid(sk));
 	rcu_read_unlock();
 }
 
-static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
+static void ip_rt_build_flow_key(struct flowi4 *fl4, struct sock *sk,
 				 const struct sk_buff *skb)
 {
 	if (skb)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index f2ed13c..fc15bca 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -343,7 +343,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   (opt && opt->srr) ? opt->faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, th->source, th->dest);
+			   ireq->ir_loc_addr, th->source, th->dest,
+			   sock_i_uid(sk));
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..4776196 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -988,7 +988,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   inet_sk_flowi_flags(sk),
-				   faddr, saddr, dport, inet->inet_sport);
+				   faddr, saddr, dport, inet->inet_sport,
+				   sock_i_uid(sk));
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f8c11d2..585859f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -652,7 +652,8 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
 				   sk->sk_protocol, 0, np->flow_label,
 				   sk->sk_v6_daddr, np->saddr,
-				   inet->inet_dport, inet->inet_sport);
+				   inet->inet_dport, inet->inet_sport,
+				   sock_i_uid(sk));
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f15c165..156f1ea 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -157,7 +157,8 @@ ipv4_connected:
 	flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
 			   sk->sk_protocol, 0, fl6.flowlabel,
 			   sk->sk_v6_daddr, np->saddr,
-			   inet->inet_dport, inet->inet_sport);
+			   inet->inet_dport, inet->inet_sport,
+			   sock_i_uid(sk));
 
 	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl6.flowi6_oif = np->mcast_oif;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 47f2272..057ff9d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -79,7 +79,8 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	flowi6_init_output(fl6, ireq->ir_iif, sk->sk_mark,
 			   IPPROTO_TCP, 0, 0,
 			   ireq->ir_v6_rmt_addr, ireq->ir_v6_loc_addr,
-			   ireq->ir_rmt_port, htons(ireq->ir_num));
+			   ireq->ir_rmt_port, htons(ireq->ir_num),
+			   sock_i_uid(sk));
 	final_p = fl6_update_dst(fl6, np->opt, &final);
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
@@ -201,7 +202,8 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	flowi6_init_output(fl6, sk->sk_bound_dev_if, sk->sk_mark,
 			   sk->sk_protocol, 0, np->flow_label,
 			   sk->sk_v6_daddr, np->saddr,
-			   inet->inet_dport, inet->inet_sport);
+			   inet->inet_dport, inet->inet_sport,
+			   sock_i_uid(sk));
 	IP6_ECN_flow_xmit(sk, fl6->flowlabel);
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 1f29996..77f2d1a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -770,6 +770,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	memset(&fl6, 0, sizeof(fl6));
 
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6->flowi6_uid = sock_i_uid(sk);
 
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 09bb685..99f7b1a 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -240,7 +240,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
 				   IPPROTO_TCP, 0, 0,
 				   ireq->ir_v6_rmt_addr, ireq->ir_v6_loc_addr,
-				   ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+				   ireq->ir_rmt_port, inet_sk(sk)->inet_sport,
+				   sock_i_uid(sk));
 
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8f4f68a..a044154 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -246,7 +246,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
 			   IPPROTO_TCP, 0, fl6.flowlabel,
 			   sk->sk_v6_daddr, saddr ? *saddr : np->saddr,
-			   usin->sin6_port, inet->inet_sport);
+			   usin->sin6_port, inet->inet_sport,
+			   sock_i_uid(sk));
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..6838cd1 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1177,6 +1177,7 @@ do_udp_sendmsg:
 		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
 
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6->flowi6_uid = sock_i_uid(sk);
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
-- 
1.9.1.423.g4596e3a
