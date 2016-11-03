From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v2 3/3] net: inet: Support UID-based routing in IP protocols.
Date: Fri,  4 Nov 2016 02:23:43 +0900
Message-ID: <1478193823-60516-4-git-send-email-lorenzo@google.com>
References: <1478193823-60516-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36265 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932872AbcKCRYC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:24:02 -0400
Received: by mail-pf0-f173.google.com with SMTP id 189so35013073pfz.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:24:02 -0700 (PDT)
In-Reply-To: <1478193823-60516-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use the UID in routing lookups made by protocol connect() and
  sendmsg() functions.
- Make sure that routing lookups triggered by incoming packets
  (e.g., Path MTU discovery) take the UID of the socket into
  account.
- For packets not associated with a userspace socket, (e.g., ping
  replies) use UID 0 inside the user namespace corresponding to
  the network namespace the socket belongs to. This allows
  all namespaces to apply routing and iptables rules to
  kernel-originated traffic in that namespaces by matching UID 0.
  This is better than using the UID of the kernel socket that is
  sending the traffic, because the UID of kernel sockets created
  at namespace creation time (e.g., the per-processor ICMP and
  TCP sockets) is the UID of the user that created the socket,
  which might not be mapped in the namespace.

Tested: compiles allnoconfig, allyesconfig, allmodconfig
Tested: https://android-review.googlesource.com/253302
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/flow.h               |  4 +++-
 include/net/ip.h                 |  1 +
 include/net/ip6_route.h          |  5 +++--
 include/net/route.h              |  5 +++--
 net/ipv4/icmp.c                  |  2 ++
 net/ipv4/inet_connection_sock.c  |  4 ++--
 net/ipv4/ip_output.c             |  3 ++-
 net/ipv4/ping.c                  |  3 ++-
 net/ipv4/raw.c                   |  2 +-
 net/ipv4/route.c                 | 26 +++++++++++++++-----------
 net/ipv4/syncookies.c            |  2 +-
 net/ipv4/tcp_ipv4.c              |  9 ++++++---
 net/ipv4/udp.c                   |  3 ++-
 net/ipv6/af_inet6.c              |  1 +
 net/ipv6/ah6.c                   |  5 +++--
 net/ipv6/datagram.c              |  1 +
 net/ipv6/esp6.c                  |  5 +++--
 net/ipv6/icmp.c                  |  7 +++++--
 net/ipv6/inet6_connection_sock.c |  2 ++
 net/ipv6/ip6_gre.c               |  4 ++++
 net/ipv6/ip6_tunnel.c            |  4 ++++
 net/ipv6/ip6_vti.c               |  5 +++--
 net/ipv6/ipcomp6.c               |  5 +++--
 net/ipv6/netfilter.c             |  1 +
 net/ipv6/ping.c                  |  1 +
 net/ipv6/raw.c                   |  1 +
 net/ipv6/route.c                 | 13 +++++++++----
 net/ipv6/syncookies.c            |  1 +
 net/ipv6/tcp_ipv6.c              |  2 ++
 net/ipv6/udp.c                   |  1 +
 net/l2tp/l2tp_ip6.c              |  1 +
 31 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 51373f3..6bbbca8 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -96,7 +96,8 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 				      __u32 mark, __u8 tos, __u8 scope,
 				      __u8 proto, __u8 flags,
 				      __be32 daddr, __be32 saddr,
-				      __be16 dport, __be16 sport)
+				      __be16 dport, __be16 sport,
+				      kuid_t uid)
 {
 	fl4->flowi4_oif = oif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
@@ -107,6 +108,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_secid = 0;
 	fl4->flowi4_tun_key.tun_id = 0;
+	fl4->flowi4_uid = uid;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
diff --git a/include/net/ip.h b/include/net/ip.h
index 5413883..55cdaac 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -179,6 +179,7 @@ struct ip_reply_arg {
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
 	u8  	    tos;
+	kuid_t	    uid;
 }; 
 
 #define IP_REPLY_ARG_NOSRCCHECK 1
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f83e78d..9dc2c18 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -140,9 +140,10 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  const struct in6_addr *gwaddr);
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu, int oif,
-		     u32 mark);
+		     u32 mark, kuid_t uid);
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu);
-void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark,
+		  kuid_t uid);
 void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 			    u32 mark);
 void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
diff --git a/include/net/route.h b/include/net/route.h
index 0429d47..c0874c8 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -153,7 +153,7 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 	flowi4_init_output(fl4, oif, sk ? sk->sk_mark : 0, tos,
 			   RT_SCOPE_UNIVERSE, proto,
 			   sk ? inet_sk_flowi_flags(sk) : 0,
-			   daddr, saddr, dport, sport);
+			   daddr, saddr, dport, sport, sock_net_uid(net, sk));
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -269,7 +269,8 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags, dst, src, dport, sport);
+			   protocol, flow_flags, dst, src, dport, sport,
+			   sk->sk_uid);
 }
 
 static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 38abe70..53a890b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -425,6 +425,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	fl4.flowi4_mark = mark;
+	fl4.flowi4_uid = sock_net_uid(net, NULL);
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
 	fl4.flowi4_oif = l3mdev_master_ifindex(skb->dev);
@@ -473,6 +474,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 		      param->replyopts.opt.opt.faddr : iph->saddr);
 	fl4->saddr = saddr;
 	fl4->flowi4_mark = mark;
+	fl4->flowi4_uid = sock_net_uid(net, NULL);
 	fl4->flowi4_tos = RT_TOS(tos);
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 61a9dee..d5d3ead 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -415,7 +415,7 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, ireq->ir_rmt_port,
-			   htons(ireq->ir_num));
+			   htons(ireq->ir_num), sk->sk_uid);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -452,7 +452,7 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, ireq->ir_rmt_port,
-			   htons(ireq->ir_num));
+			   htons(ireq->ir_num), sk->sk_uid);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 03e7f73..37dfacd3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1587,7 +1587,8 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
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
index 205e200..d11129f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -789,7 +789,8 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
+			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0,
+			   sk->sk_uid);
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6a0bd68..838ea5e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -606,7 +606,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk) |
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
-			   daddr, saddr, 0, 0);
+			   daddr, saddr, 0, 0, sk->sk_uid);
 
 	if (!inet->hdrincl) {
 		rfv.msg = msg;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92e59a6..2355883 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -507,7 +507,8 @@ void __ip_select_ident(struct net *net, struct iphdr *iph, int segs)
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
-static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
+static void __build_flow_key(const struct net *net, struct flowi4 *fl4,
+			     const struct sock *sk,
 			     const struct iphdr *iph,
 			     int oif, u8 tos,
 			     u8 prot, u32 mark, int flow_flags)
@@ -523,7 +524,8 @@ static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 	flowi4_init_output(fl4, oif, mark, tos,
 			   RT_SCOPE_UNIVERSE, prot,
 			   flow_flags,
-			   iph->daddr, iph->saddr, 0, 0);
+			   iph->daddr, iph->saddr, 0, 0,
+			   sock_net_uid(net, sk));
 }
 
 static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
@@ -535,7 +537,7 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
 
-	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(sock_net(sk), fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
 static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
@@ -552,7 +554,7 @@ static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk),
-			   daddr, inet->inet_saddr, 0, 0);
+			   daddr, inet->inet_saddr, 0, 0, sk->sk_uid);
 	rcu_read_unlock();
 }
 
@@ -800,7 +802,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 
 	rt = (struct rtable *) dst;
 
-	__build_flow_key(&fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(sock_net(sk), &fl4, sk, iph, oif, tos, prot, mark, 0);
 	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
@@ -1018,7 +1020,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 	if (!mark)
 		mark = IP4_REPLY_MARK(net, skb->mark);
 
-	__build_flow_key(&fl4, NULL, iph, oif,
+	__build_flow_key(net, &fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1034,7 +1036,7 @@ static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct flowi4 fl4;
 	struct rtable *rt;
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	__build_flow_key(sock_net(sk), &fl4, sk, iph, 0, 0, 0, 0, 0);
 
 	if (!fl4.flowi4_mark)
 		fl4.flowi4_mark = IP4_REPLY_MARK(sock_net(sk), skb->mark);
@@ -1053,6 +1055,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct rtable *rt;
 	struct dst_entry *odst = NULL;
 	bool new = false;
+	struct net *net = sock_net(sk);
 
 	bh_lock_sock(sk);
 
@@ -1066,7 +1069,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		goto out;
 	}
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	__build_flow_key(net, &fl4, sk, iph, 0, 0, 0, 0, 0);
 
 	rt = (struct rtable *)odst;
 	if (odst->obsolete && !odst->ops->check(odst, 0)) {
@@ -1106,7 +1109,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 	struct flowi4 fl4;
 	struct rtable *rt;
 
-	__build_flow_key(&fl4, NULL, iph, oif,
+	__build_flow_key(net, &fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1121,9 +1124,10 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
+	struct net *net = sock_net(sk);
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
-	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	__build_flow_key(net, &fl4, sk, iph, 0, 0, 0, 0, 0);
+	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index e3c4043..0dc6286 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -372,7 +372,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, th->source, th->dest);
+			   ireq->ir_loc_addr, th->source, th->dest, sk->sk_uid);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b9b82826..6491b7c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -691,6 +691,7 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		     offsetof(struct inet_timewait_sock, tw_bound_dev_if));
 
 	arg.tos = ip_hdr(skb)->tos;
+	arg.uid = sock_net_uid(net, sk && sk_fullsock(sk) ? sk : NULL);
 	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
@@ -711,7 +712,7 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct net *net,
+static void tcp_v4_send_ack(const struct sock *sk,
 			    struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 tsval, u32 tsecr, int oif,
 			    struct tcp_md5sig_key *key,
@@ -726,6 +727,7 @@ static void tcp_v4_send_ack(struct net *net,
 #endif
 			];
 	} rep;
+	struct net *net = sock_net(sk);
 	struct ip_reply_arg arg;
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
@@ -775,6 +777,7 @@ static void tcp_v4_send_ack(struct net *net,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
+	arg.uid = sock_net_uid(net, sk_fullsock(sk) ? sk : NULL);
 	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
@@ -790,7 +793,7 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(sock_net(sk), skb,
+	tcp_v4_send_ack(sk, skb,
 			tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcp_time_stamp + tcptw->tw_ts_offset,
@@ -818,7 +821,7 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 	 * exception of <SYN> segments, MUST be right-shifted by
 	 * Rcv.Wind.Shift bits:
 	 */
-	tcp_v4_send_ack(sock_net(sk), skb, seq,
+	tcp_v4_send_ack(sk, skb, seq,
 			tcp_rsk(req)->rcv_nxt,
 			req->rsk_rcv_wnd >> inet_rsk(req)->rcv_wscale,
 			tcp_time_stamp,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 195992e..a32a890 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1019,7 +1019,8 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   flow_flags,
-				   faddr, saddr, dport, inet->inet_sport);
+				   faddr, saddr, dport, inet->inet_sport,
+				   sk->sk_uid);
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 46ad699..c86911b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -678,6 +678,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl6.flowi6_mark = sk->sk_mark;
 		fl6.fl6_dport = inet->inet_dport;
 		fl6.fl6_sport = inet->inet_sport;
+		fl6.flowi6_uid = sk->sk_uid;
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		rcu_read_lock();
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 0630a4d5..189eb10 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -662,9 +662,10 @@ static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return 0;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0,
+			     sock_net_uid(net, NULL));
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(skb, net, info, 0, 0, sock_net_uid(net, NULL));
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 37874e2..6d8a66a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -54,6 +54,7 @@ static void ip6_datagram_flow_key_init(struct flowi6 *fl6, struct sock *sk)
 	fl6->fl6_dport = inet->inet_dport;
 	fl6->fl6_sport = inet->inet_sport;
 	fl6->flowlabel = np->flow_label;
+	fl6->flowi6_uid = sk->sk_uid;
 
 	if (!fl6->flowi6_oif)
 		fl6->flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 060a60b..218f0cb 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -474,9 +474,10 @@ static int esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return 0;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0,
+			     sock_net_uid(net, NULL));
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(skb, net, info, 0, 0, sock_net_uid(net, NULL));
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index bd59c34..ab249fe 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -92,9 +92,10 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct net *net = dev_net(skb->dev);
 
 	if (type == ICMPV6_PKT_TOOBIG)
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(skb, net, info, 0, 0, sock_net_uid(net, NULL));
 	else if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0,
+			     sock_net_uid(net, NULL));
 
 	if (!(type & ICMPV6_INFOMSG_MASK))
 		if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
@@ -484,6 +485,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	fl6.flowi6_oif = iif;
 	fl6.fl6_icmp_type = type;
 	fl6.fl6_icmp_code = code;
+	fl6.flowi6_uid = sock_net_uid(net, NULL);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
@@ -658,6 +660,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.flowi6_oif = skb->dev->ifindex;
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	fl6.flowi6_mark = mark;
+	fl6.flowi6_uid = sock_net_uid(net, NULL);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 532c3ef..1c86c47 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -88,6 +88,7 @@ struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 	fl6->flowi6_mark = ireq->ir_mark;
 	fl6->fl6_dport = ireq->ir_rmt_port;
 	fl6->fl6_sport = htons(ireq->ir_num);
+	fl6->flowi6_uid = sk->sk_uid;
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
 	dst = ip6_dst_lookup_flow(sk, fl6, final_p);
@@ -136,6 +137,7 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	fl6->flowi6_mark = sk->sk_mark;
 	fl6->fl6_sport = inet->inet_sport;
 	fl6->fl6_dport = inet->inet_dport;
+	fl6->flowi6_uid = sk->sk_uid;
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 
 	rcu_read_lock();
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index d7d6d3a..710bc79 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -548,6 +548,8 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
+	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
+
 	err = gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM));
 	if (err)
 		return -1;
@@ -602,6 +604,8 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
+	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
+
 	if (gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM)))
 		return -1;
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 03e050d..bfa889c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1240,6 +1240,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 			fl6.flowi6_mark = skb->mark;
 	}
 
+	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
+
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
 
@@ -1318,6 +1320,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 			fl6.flowi6_mark = skb->mark;
 	}
 
+	fl6.flowi6_uid = sock_net_uid(dev_net(dev), NULL);
+
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 35c5b2d..af3f0e0 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -608,9 +608,10 @@ static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return 0;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0,
+			     sock_net_uid(net, NULL));
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(skb, net, info, 0, 0, sock_net_uid(net, NULL));
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 1b9316e..54d165b 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -74,9 +74,10 @@ static int ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return 0;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0,
+			     sock_net_uid(net, NULL));
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(skb, net, info, 0, 0, sock_net_uid(net, NULL));
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index d11c468..39970e2 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -26,6 +26,7 @@ int ip6_route_me_harder(struct net *net, struct sk_buff *skb)
 	struct flowi6 fl6 = {
 		.flowi6_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
 		.flowi6_mark = skb->mark,
+		.flowi6_uid = sock_net_uid(net, skb->sk),
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 	};
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 66e2d9d..e1f8b34 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -113,6 +113,7 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	fl6.daddr = *daddr;
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_uid = sk->sk_uid;
 	fl6.fl6_icmp_type = user_icmph.icmp6_type;
 	fl6.fl6_icmp_code = user_icmph.icmp6_code;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 610e093..291ebc2 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -776,6 +776,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	memset(&fl6, 0, sizeof(fl6));
 
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_uid = sk->sk_uid;
 
 	ipc6.hlimit = -1;
 	ipc6.tclass = -1;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fdb9c87..6aa014e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1405,7 +1405,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 }
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
-		     int oif, u32 mark)
+		     int oif, u32 mark, kuid_t uid)
 {
 	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
 	struct dst_entry *dst;
@@ -1417,6 +1417,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
+	fl6.flowi6_uid = uid;
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
@@ -1430,7 +1431,7 @@ void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 	struct dst_entry *dst;
 
 	ip6_update_pmtu(skb, sock_net(sk), mtu,
-			sk->sk_bound_dev_if, sk->sk_mark);
+			sk->sk_bound_dev_if, sk->sk_mark, sk->sk_uid);
 
 	dst = __sk_dst_get(sk);
 	if (!dst || !dst->obsolete ||
@@ -1522,7 +1523,8 @@ static struct dst_entry *ip6_route_redirect(struct net *net,
 				flags, __ip6_route_redirect);
 }
 
-void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark,
+		  kuid_t uid)
 {
 	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
 	struct dst_entry *dst;
@@ -1535,6 +1537,7 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
+	fl6.flowi6_uid = uid;
 
 	dst = ip6_route_redirect(net, &fl6, &ipv6_hdr(skb)->saddr);
 	rt6_do_redirect(dst, NULL, skb);
@@ -1556,6 +1559,7 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	fl6.flowi6_mark = mark;
 	fl6.daddr = msg->dest;
 	fl6.saddr = iph->daddr;
+	fl6.flowi6_uid = sock_net_uid(net, NULL);
 
 	dst = ip6_route_redirect(net, &fl6, &iph->saddr);
 	rt6_do_redirect(dst, NULL, skb);
@@ -1564,7 +1568,8 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 
 void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
 {
-	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
+	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark,
+		     sk->sk_uid);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_redirect);
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 59c4839..97830a6 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -227,6 +227,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl6.flowi6_mark = ireq->ir_mark;
 		fl6.fl6_dport = ireq->ir_rmt_port;
 		fl6.fl6_sport = inet_sk(sk)->inet_sport;
+		fl6.flowi6_uid = sk->sk_uid;
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5a27ab4..aece1b1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -233,6 +233,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_dport = usin->sin6_port;
 	fl6.fl6_sport = inet->inet_sport;
+	fl6.flowi6_uid = sk->sk_uid;
 
 	opt = rcu_dereference_protected(np->opt, lockdep_sock_is_held(sk));
 	final_p = fl6_update_dst(&fl6, opt, &final);
@@ -824,6 +825,7 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
 	fl6.fl6_dport = t1->dest;
 	fl6.fl6_sport = t1->source;
+	fl6.flowi6_uid = sock_net_uid(net, sk && sk_fullsock(sk) ? sk : NULL);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	/* Pass a socket to ip6_dst_lookup either it is for RST
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bb..9103c5c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1138,6 +1138,7 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
 
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_uid = sk->sk_uid;
 	sockc.tsflags = sk->sk_tsflags;
 
 	if (msg->msg_controllen) {
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index ad3468c..1cea54f 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -519,6 +519,7 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	memset(&fl6, 0, sizeof(fl6));
 
 	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_uid = sk->sk_uid;
 
 	ipc6.hlimit = -1;
 	ipc6.tclass = -1;
-- 
2.8.0.rc3.226.g39d4020
