From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 1/3] ipv4: make flow functions more grepable by removing flowi4_init_output
Date: Mon, 13 Jun 2016 22:47:36 +0200
Message-ID: <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Cc: ja@ssi.bg, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56328 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161183AbcFMUrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:47:49 -0400
In-Reply-To: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional changes.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/flow.h              | 21 ---------------------
 include/net/route.h             | 33 +++++++++++++++++++++++++++------
 net/ipv4/inet_connection_sock.c | 41 +++++++++++++++++++++++++++++------------
 net/ipv4/ip_output.c            | 21 ++++++++++++++-------
 net/ipv4/ping.c                 | 16 +++++++++++++---
 net/ipv4/raw.c                  | 20 ++++++++++++++------
 net/ipv4/route.c                | 38 +++++++++++++++++++++++++++++---------
 net/ipv4/syncookies.c           | 19 ++++++++++++++-----
 net/ipv4/udp.c                  | 17 +++++++++++++----
 9 files changed, 153 insertions(+), 73 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index d47ef4bb5423a3..2c8e95b987c98c 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -90,27 +90,6 @@ struct flowi4 {
 #define fl4_gre_key		uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
-static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
-				      __u32 mark, __u8 tos, __u8 scope,
-				      __u8 proto, __u8 flags,
-				      __be32 daddr, __be32 saddr,
-				      __be16 dport, __be16 sport)
-{
-	fl4->flowi4_oif = oif;
-	fl4->flowi4_iif = LOOPBACK_IFINDEX;
-	fl4->flowi4_mark = mark;
-	fl4->flowi4_tos = tos;
-	fl4->flowi4_scope = scope;
-	fl4->flowi4_proto = proto;
-	fl4->flowi4_flags = flags;
-	fl4->flowi4_secid = 0;
-	fl4->flowi4_tun_key.tun_id = 0;
-	fl4->daddr = daddr;
-	fl4->saddr = saddr;
-	fl4->fl4_dport = dport;
-	fl4->fl4_sport = sport;
-}
-
 /* Reset some input parameters after previous lookup */
 static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
 					__be32 daddr, __be32 saddr)
diff --git a/include/net/route.h b/include/net/route.h
index ad777d79af9458..61164593d41ecf 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -151,10 +151,20 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 						   __be16 dport, __be16 sport,
 						   __u8 proto, __u8 tos, int oif)
 {
-	flowi4_init_output(fl4, oif, sk ? sk->sk_mark : 0, tos,
-			   RT_SCOPE_UNIVERSE, proto,
-			   sk ? inet_sk_flowi_flags(sk) : 0,
-			   daddr, saddr, dport, sport);
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = sk ? sk->sk_mark : 0;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = proto;
+	fl4->flowi4_flags = sk ? inet_sk_flowi_flags(sk) : 0;
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+	fl4->fl4_dport = dport;
+	fl4->fl4_sport = sport;
+
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -269,8 +279,19 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags, dst, src, dport, sport);
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = sk->sk_mark;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = protocol;
+	fl4->flowi4_flags = flow_flags;
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = dst;
+	fl4->saddr = src;
+	fl4->fl4_dport = dport;
+	fl4->fl4_sport = sport;
 }
 
 static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index fa8c39804bdbae..f84b851e050534 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -410,12 +410,20 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 	struct ip_options_rcu *opt = ireq->opt;
 	struct rtable *rt;
 
-	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
-			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
-			   sk->sk_protocol, inet_sk_flowi_flags(sk),
-			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port,
-			   htons(ireq->ir_num));
+	fl4->flowi4_oif = ireq->ir_iif;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = ireq->ir_mark;
+	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = sk->sk_protocol;
+	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr;
+	fl4->saddr = ireq->ir_loc_addr;
+	fl4->fl4_dport = ireq->ir_rmt_port;
+	fl4->fl4_sport = htons(ireq->ir_num);
+
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -447,12 +455,21 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
 
 	rcu_read_lock();
 	opt = rcu_dereference(newinet->inet_opt);
-	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
-			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
-			   sk->sk_protocol, inet_sk_flowi_flags(sk),
-			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port,
-			   htons(ireq->ir_num));
+
+	fl4->flowi4_oif = ireq->ir_iif;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = ireq->ir_mark;
+	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = sk->sk_protocol;
+	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr;
+	fl4->saddr = ireq->ir_loc_addr;
+	fl4->fl4_dport = ireq->ir_rmt_port;
+	fl4->fl4_sport = htons(ireq->ir_num);
+
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cbac493c913ac3..90076310888d7f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1567,13 +1567,20 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
 		oif = skb->skb_iif;
 
-	flowi4_init_output(&fl4, oif,
-			   IP4_REPLY_MARK(net, skb->mark),
-			   RT_TOS(arg->tos),
-			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
-			   ip_reply_arg_flowi_flags(arg),
-			   daddr, saddr,
-			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
+	fl4.flowi4_oif = oif;
+	fl4.flowi4_iif = LOOPBACK_IFINDEX;
+	fl4.flowi4_mark = IP4_REPLY_MARK(net, skb->mark);
+	fl4.flowi4_tos = RT_TOS(arg->tos);
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_proto = ip_hdr(skb)->protocol;
+	fl4.flowi4_flags = ip_reply_arg_flowi_flags(arg);
+	fl4.flowi4_secid = 0;
+	fl4.flowi4_tun_key.tun_id = 0;
+	fl4.daddr = daddr;
+	fl4.saddr = saddr;
+	fl4.fl4_dport = tcp_hdr(skb)->source;
+	fl4.fl4_sport = tcp_hdr(skb)->dest;
+
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 66ddcb60519a16..dc6a42d1136752 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -792,9 +792,19 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
-	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
-			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
+	fl4.flowi4_oif = ipc.oif;
+	fl4.flowi4_iif = LOOPBACK_IFINDEX;
+	fl4.flowi4_mark = sk->sk_mark;
+	fl4.flowi4_tos = tos;
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_proto = sk->sk_protocol;
+	fl4.flowi4_flags = inet_sk_flowi_flags(sk);
+	fl4.flowi4_secid = 0;
+	fl4.flowi4_tun_key.tun_id = 0;
+	fl4.daddr = faddr;
+	fl4.saddr = saddr;
+	fl4.fl4_dport = 0;
+	fl4.fl4_sport = 0;
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 438f50c1a6765c..50057df31fc9da 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -599,12 +599,20 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
-	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
-			   RT_SCOPE_UNIVERSE,
-			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			   inet_sk_flowi_flags(sk) |
-			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
-			   daddr, saddr, 0, 0);
+	fl4.flowi4_oif = ipc.oif;
+	fl4.flowi4_iif = LOOPBACK_IFINDEX;
+	fl4.flowi4_mark = sk->sk_mark;
+	fl4.flowi4_tos = tos;
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_proto = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
+	fl4.flowi4_flags = inet_sk_flowi_flags(sk) |
+			    inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0;
+	fl4.flowi4_secid = 0;
+	fl4.flowi4_tun_key.tun_id = 0;
+	fl4.daddr = daddr;
+	fl4.saddr = saddr;
+	fl4.fl4_dport = 0;
+	fl4.fl4_sport = 0;
 
 	if (!saddr && ipc.oif) {
 		err = l3mdev_get_saddr(net, ipc.oif, &fl4);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a1f2830d811025..e8f499d224ec2a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -514,10 +514,20 @@ static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		tos = RT_CONN_FLAGS(sk);
 		prot = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
 	}
-	flowi4_init_output(fl4, oif, mark, tos,
-			   RT_SCOPE_UNIVERSE, prot,
-			   flow_flags,
-			   iph->daddr, iph->saddr, 0, 0);
+
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = mark;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = prot;
+	fl4->flowi4_flags = flow_flags;
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = iph->daddr;
+	fl4->saddr = iph->saddr;
+	fl4->fl4_dport = 0;
+	fl4->fl4_sport = 0;
 }
 
 static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
@@ -542,11 +552,21 @@ static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 	inet_opt = rcu_dereference(inet->inet_opt);
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
-			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
-			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			   inet_sk_flowi_flags(sk),
-			   daddr, inet->inet_saddr, 0, 0);
+
+	fl4->flowi4_oif = sk->sk_bound_dev_if;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_mark = sk->sk_mark;
+	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
+	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_proto = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
+	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
+	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->daddr = daddr;
+	fl4->saddr = inet->inet_saddr;
+	fl4->fl4_dport = 0;
+	fl4->fl4_sport = 0;
+
 	rcu_read_unlock();
 }
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index e3c4043c27de28..d5eedcae69f188 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -368,11 +368,20 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	flowi4_init_output(&fl4, ireq->ir_iif, ireq->ir_mark,
-			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
-			   inet_sk_flowi_flags(sk),
-			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, th->source, th->dest);
+	fl4.flowi4_oif = ireq->ir_iif;
+	fl4.flowi4_iif = LOOPBACK_IFINDEX;
+	fl4.flowi4_mark = ireq->ir_mark;
+	fl4.flowi4_tos = RT_CONN_FLAGS(sk);
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_proto = IPPROTO_TCP;
+	fl4.flowi4_flags = inet_sk_flowi_flags(sk);
+	fl4.flowi4_secid = 0;
+	fl4.flowi4_tun_key.tun_id = 0;
+	fl4.daddr = opt->srr ? opt->faddr : ireq->ir_rmt_addr;
+	fl4.saddr = ireq->ir_loc_addr;
+	fl4.fl4_dport = th->source;
+	fl4.fl4_sport = th->dest;
+
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ff31d97d48586..2d3de2565e13bf 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1056,10 +1056,19 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 		fl4 = &fl4_stack;
 
-		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
-				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-				   flow_flags,
-				   faddr, saddr, dport, inet->inet_sport);
+		fl4->flowi4_oif = ipc.oif;
+		fl4->flowi4_iif = LOOPBACK_IFINDEX;
+		fl4->flowi4_mark = sk->sk_mark;
+		fl4->flowi4_tos = tos;
+		fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+		fl4->flowi4_proto = sk->sk_protocol;
+		fl4->flowi4_flags = flow_flags;
+		fl4->flowi4_secid = 0;
+		fl4->flowi4_tun_key.tun_id = 0;
+		fl4->daddr = faddr;
+		fl4->saddr = saddr;
+		fl4->fl4_dport = dport;
+		fl4->fl4_sport = inet->inet_sport;
 
 		if (!saddr && ipc.oif) {
 			err = l3mdev_get_saddr(net, ipc.oif, fl4);
-- 
2.5.5
