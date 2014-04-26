From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next 1/4] net: ipv6: Introduce flowi6_init_output.
Date: Sat, 26 Apr 2014 13:48:22 +0900
Message-ID: <1398487705-13430-2-git-send-email-lorenzo@google.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:46548 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaDZEst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:48:49 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so3898695pbc.16
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 21:48:48 -0700 (PDT)
In-Reply-To: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is consistent with IPv4, and is a bit more compact. Also, by
forcing all common flowi6 parameters to be explicitly specified,
it makes it easier to see which parameters are being set and
which are being defaulted to zero. So, for example, no more
forgetting to do "fl6.fl6_mark = sk->sk_mark" and having to fix
it later like in net-next bf439b3.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/flow.h               | 20 ++++++++++++++++++++
 net/ipv6/af_inet6.c              | 12 ++++--------
 net/ipv6/datagram.c              | 11 ++++-------
 net/ipv6/inet6_connection_sock.c | 23 ++++++++---------------
 net/ipv6/syncookies.c            | 12 +++++-------
 net/ipv6/tcp_ipv6.c              | 11 ++++-------
 6 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a15..84044af 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -150,6 +150,26 @@ struct flowidn {
 #define fld_dport		uli.ports.dport
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
+static inline void flowi6_init_output(struct flowi6 *fl6, int oif,
+				      __u32 mark, __u8 proto, __u8 flags,
+				      __be32 flowlabel,
+				      struct in6_addr daddr,
+				      struct in6_addr saddr,
+				      __be16 dport, __be16 sport)
+{
+	fl6->flowi6_oif = oif;
+	fl6->flowi6_iif = 0;
+	fl6->flowi6_mark = mark;
+	fl6->flowi6_proto = proto;
+	fl6->flowi6_flags = flags;
+	fl6->flowi6_secid = 0;
+	fl6->daddr = daddr;
+	fl6->saddr = saddr;
+	fl6->flowlabel = flowlabel;
+	fl6->fl6_dport = dport;
+	fl6->fl6_sport = sport;
+}
+
 struct flowi {
 	union {
 		struct flowi_common	__fl_common;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d935889..f8c11d2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -649,14 +649,10 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		struct flowi6 fl6;
 
 		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_proto = sk->sk_protocol;
-		fl6.daddr = sk->sk_v6_daddr;
-		fl6.saddr = np->saddr;
-		fl6.flowlabel = np->flow_label;
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-		fl6.flowi6_mark = sk->sk_mark;
-		fl6.fl6_dport = inet->inet_dport;
-		fl6.fl6_sport = inet->inet_sport;
+		flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
+				   sk->sk_protocol, 0, np->flow_label,
+				   sk->sk_v6_daddr, np->saddr,
+				   inet->inet_dport, inet->inet_sport);
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c3bf2d2..f15c165 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -154,13 +154,10 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	fl6.flowi6_proto = sk->sk_protocol;
-	fl6.daddr = sk->sk_v6_daddr;
-	fl6.saddr = np->saddr;
-	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_dport = inet->inet_dport;
-	fl6.fl6_sport = inet->inet_sport;
+	flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
+			   sk->sk_protocol, 0, fl6.flowlabel,
+			   sk->sk_v6_daddr, np->saddr,
+			   inet->inet_dport, inet->inet_sport);
 
 	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl6.flowi6_oif = np->mcast_oif;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index d4ade34..47f2272 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -76,14 +76,11 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	struct dst_entry *dst;
 
 	memset(fl6, 0, sizeof(*fl6));
-	fl6->flowi6_proto = IPPROTO_TCP;
-	fl6->daddr = ireq->ir_v6_rmt_addr;
+	flowi6_init_output(fl6, ireq->ir_iif, sk->sk_mark,
+			   IPPROTO_TCP, 0, 0,
+			   ireq->ir_v6_rmt_addr, ireq->ir_v6_loc_addr,
+			   ireq->ir_rmt_port, htons(ireq->ir_num));
 	final_p = fl6_update_dst(fl6, np->opt, &final);
-	fl6->saddr = ireq->ir_v6_loc_addr;
-	fl6->flowi6_oif = ireq->ir_iif;
-	fl6->flowi6_mark = sk->sk_mark;
-	fl6->fl6_dport = ireq->ir_rmt_port;
-	fl6->fl6_sport = htons(ireq->ir_num);
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
 	dst = ip6_dst_lookup_flow(sk, fl6, final_p);
@@ -201,15 +198,11 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	struct dst_entry *dst;
 
 	memset(fl6, 0, sizeof(*fl6));
-	fl6->flowi6_proto = sk->sk_protocol;
-	fl6->daddr = sk->sk_v6_daddr;
-	fl6->saddr = np->saddr;
-	fl6->flowlabel = np->flow_label;
+	flowi6_init_output(fl6, sk->sk_bound_dev_if, sk->sk_mark,
+			   sk->sk_protocol, 0, np->flow_label,
+			   sk->sk_v6_daddr, np->saddr,
+			   inet->inet_dport, inet->inet_sport);
 	IP6_ECN_flow_xmit(sk, fl6->flowlabel);
-	fl6->flowi6_oif = sk->sk_bound_dev_if;
-	fl6->flowi6_mark = sk->sk_mark;
-	fl6->fl6_sport = inet->inet_sport;
-	fl6->fl6_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 
 	final_p = fl6_update_dst(fl6, np->opt, &final);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index bb53a5e7..09bb685 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -237,14 +237,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		struct in6_addr *final_p, final;
 		struct flowi6 fl6;
 		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_proto = IPPROTO_TCP;
-		fl6.daddr = ireq->ir_v6_rmt_addr;
+		flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
+				   IPPROTO_TCP, 0, 0,
+				   ireq->ir_v6_rmt_addr, ireq->ir_v6_loc_addr,
+				   ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
-		fl6.saddr = ireq->ir_v6_loc_addr;
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-		fl6.flowi6_mark = sk->sk_mark;
-		fl6.fl6_dport = ireq->ir_rmt_port;
-		fl6.fl6_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e289830..8f4f68a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -243,13 +243,10 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr))
 		saddr = &sk->sk_v6_rcv_saddr;
 
-	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.daddr = sk->sk_v6_daddr;
-	fl6.saddr = saddr ? *saddr : np->saddr;
-	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_dport = usin->sin6_port;
-	fl6.fl6_sport = inet->inet_sport;
+	flowi6_init_output(&fl6, sk->sk_bound_dev_if, sk->sk_mark,
+			   IPPROTO_TCP, 0, fl6.flowlabel,
+			   sk->sk_v6_daddr, saddr ? *saddr : np->saddr,
+			   usin->sin6_port, inet->inet_sport);
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-- 
1.9.1.423.g4596e3a
