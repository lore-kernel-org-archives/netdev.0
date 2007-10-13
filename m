From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 05/14] Handle TCP SYN+ACK/ACK/RST transparency
Date: Sat, 13 Oct 2007 19:31:33 +0200
Message-ID: <20071013173133.22517.41466.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761434AbXJMSjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:47 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV009G31XMZ930@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:29:47 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
incoming packets. The non-local source address check on output bites
us again, as replies for transparently redirected traffic won't have a
chance to leave the node.

This patch selectively sets the FLOWI_FLAG_ANYSRC flag when doing
the route lookup for those replies. Transparent replies are enabled if
the listening socket has the transparent socket flag set.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/inet_sock.h         |    8 +++++++-
 include/net/ip.h                |    9 +++++++++
 net/ipv4/inet_connection_sock.c |    1 +
 net/ipv4/ip_output.c            |    4 +++-
 net/ipv4/syncookies.c           |    1 +
 net/ipv4/tcp_ipv4.c             |   11 ++++++++---
 6 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e86832d..517efe7 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				no_srccheck: 1;
 	struct ip_options	*opt;
 };
 
@@ -191,4 +192,9 @@ static inline int inet_sk_ehashfn(const struct sock *sk)
 	return inet_ehashfn(laddr, lport, faddr, fport);
 }
 
+static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
+{
+	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/include/net/ip.h b/include/net/ip.h
index 3af3ed9..5ea3813 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -29,6 +29,7 @@
 
 #include <net/inet_sock.h>
 #include <net/snmp.h>
+#include <net/flow.h>
 
 struct sock;
 
@@ -140,12 +141,20 @@ static inline void ip_tr_mc_map(__be32 addr, char *buf)
 
 struct ip_reply_arg {
 	struct kvec iov[1];   
+	int	    flags;
 	__wsum 	    csum;
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
 }; 
 
+#define IP_REPLY_ARG_NOSRCCHECK 1
+
+static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
+{
+	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
+}
+
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len); 
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3cef128..1667cd8 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -335,6 +335,7 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 					.saddr = ireq->loc_addr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			    .proto = sk->sk_protocol,
+			    .flags = inet_sk_flowi_flags(sk),
 			    .uli_u = { .ports =
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 699f067..62b31ae 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -322,6 +322,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 							.saddr = inet->saddr,
 							.tos = RT_CONN_FLAGS(sk) } },
 					    .proto = sk->sk_protocol,
+					    .flags = inet_sk_flowi_flags(sk),
 					    .uli_u = { .ports =
 						       { .sport = inet->sport,
 							 .dport = inet->dport } } };
@@ -1368,7 +1369,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 				    .uli_u = { .ports =
 					       { .sport = tcp_hdr(skb)->dest,
 						 .dport = tcp_hdr(skb)->source } },
-				    .proto = sk->sk_protocol };
+				    .proto = sk->sk_protocol,
+				    .flags = ip_reply_arg_flowi_flags(arg) };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(&rt, &fl))
 			return;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 2da1be0..a0f6fdb 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -260,6 +260,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 						.saddr = ireq->loc_addr,
 						.tos = RT_CONN_FLAGS(sk) } },
 				    .proto = IPPROTO_TCP,
+				    .flags = inet_sk_flowi_flags(sk),
 				    .uli_u = { .ports =
 					       { .sport = th->dest,
 						 .dport = th->source } } };
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 38cf73a..fb471b0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -613,6 +613,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      ip_hdr(skb)->saddr, /* XXX */
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
 
@@ -626,7 +627,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 			    struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 ts)
+			    u32 win, u32 ts, int reply_flags)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -702,6 +703,7 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 					arg.iov[0].iov_len);
 	}
 #endif
+	arg.flags = reply_flags;
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
@@ -721,7 +723,8 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 
 	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent,
+			tw->tw_transparent ? IP_REPLY_ARG_NOSRCCHECK : 0);
 
 	inet_twsk_put(tw);
 }
@@ -731,7 +734,8 @@ static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
 {
 	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
-			req->ts_recent);
+			req->ts_recent,
+			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0);
 }
 
 /*
@@ -1333,6 +1337,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(sk, skb);
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));

