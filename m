From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 08/13] Handle TCP SYN+ACK/ACK/RST transparency
Date: Mon, 05 Mar 2007 16:46:11 +0100
Message-ID: <20070305154611.3471.7456.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:4854 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933549AbXCEPqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:13 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 5D90F294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:12 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
incoming packets. The non-local source address check on output bites
us again, as replies for transparently redirected traffic won't have a
chance to leave the node.

This patch selectively sets the FLOWI_FLAG_TRANSPARENT flag when doing
the route lookup for those replies. Transparent replies are enabled if
the listening socket has the transparent socket flag set.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/ip.h                |    3 +++
 include/net/request_sock.h      |    3 ++-
 net/ipv4/inet_connection_sock.c |    2 ++
 net/ipv4/ip_output.c            |    6 +++++-
 net/ipv4/syncookies.c           |    2 ++
 net/ipv4/tcp_ipv4.c             |   16 ++++++++++------
 net/ipv4/tcp_minisocks.c        |    3 ++-
 7 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index e79c3e3..8b71991 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -133,8 +133,11 @@ static inline void ip_tr_mc_map(__be32 addr, char *buf)
 	buf[5]=0x00;
 }
 
+#define IP_REPLY_ARG_NOSRCCHECK 1
+
 struct ip_reply_arg {
 	struct kvec iov[1];   
+	int	    flags;
 	__wsum 	    csum;
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 7aed02c..b9c8974 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -34,7 +34,8 @@ struct request_sock_ops {
 				       struct request_sock *req,
 				       struct dst_entry *dst);
 	void		(*send_ack)(struct sk_buff *skb,
-				    struct request_sock *req);
+				    struct request_sock *req,
+				    int reply_flags);
 	void		(*send_reset)(struct sock *sk,
 				      struct sk_buff *skb);
 	void		(*destructor)(struct request_sock *req);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 83ad972..90459a1 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -323,6 +323,8 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 					.saddr = ireq->loc_addr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			    .proto = sk->sk_protocol,
+			    .flags = inet_sk(sk)->transparent ?
+					FLOWI_FLAG_TRANSPARENT : 0,
 			    .uli_u = { .ports =
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d096332..7af25d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -312,6 +312,8 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 							.saddr = inet->saddr,
 							.tos = RT_CONN_FLAGS(sk) } },
 					    .proto = sk->sk_protocol,
+					    .flags = inet->transparent ?
+							 FLOWI_FLAG_TRANSPARENT : 0,
 					    .uli_u = { .ports =
 						       { .sport = inet->sport,
 							 .dport = inet->dport } } };
@@ -1357,7 +1359,9 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } },
-				    .proto = sk->sk_protocol };
+				    .proto = sk->sk_protocol,
+				    .flags = (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ?
+						FLOWI_FLAG_TRANSPARENT : 0 };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(&rt, &fl))
 			return;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 431c81d..08d8920 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -261,6 +261,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 						.saddr = ireq->loc_addr,
 						.tos = RT_CONN_FLAGS(sk) } },
 				    .proto = IPPROTO_TCP,
+				    .flags = inet_sk(sk)->transparent ?
+						FLOWI_FLAG_TRANSPARENT : 0,
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } } };
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 536db7b..9374c5b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -607,6 +607,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      skb->nh.iph->saddr, /* XXX */
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
 
@@ -620,7 +621,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 			    struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 ts)
+			    u32 win, u32 ts, int reply_flags)
 {
 	struct tcphdr *th = skb->h.th;
 	struct {
@@ -700,30 +701,32 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 				      skb->nh.iph->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	arg.flags = reply_flags;
 
 	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 }
 
-static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
+static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb, int reply_flags)
 {
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
 	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent, reply_flags);
 
 	inet_twsk_put(tw);
 }
 
 static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
-				  struct request_sock *req)
+				  struct request_sock *req,
+				  int reply_flags)
 {
 	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
-			req->ts_recent);
+			req->ts_recent, reply_flags);
 }
 
 /*
@@ -1743,7 +1746,8 @@ do_time_wait:
 		/* Fall through to ACK */
 	}
 	case TCP_TW_ACK:
-		tcp_v4_timewait_ack(sk, skb);
+		tcp_v4_timewait_ack(sk, skb, inet_twsk(sk)->tw_transparent ?
+				    IP_REPLY_ARG_NOSRCCHECK : 0);
 		break;
 	case TCP_TW_RST:
 		goto no_tcp_socket;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6b5c64f..c63c25b 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -605,7 +605,8 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 					  tcp_rsk(req)->rcv_isn + 1, tcp_rsk(req)->rcv_isn + 1 + req->rcv_wnd)) {
 		/* Out of window: send ACK and drop. */
 		if (!(flg & TCP_FLAG_RST))
-			req->rsk_ops->send_ack(skb, req);
+			req->rsk_ops->send_ack(skb, req, inet_sk(sk)->transparent ?
+					       IP_REPLY_ARG_NOSRCCHECK : 0);
 		if (paws_reject)
 			NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
 		return NULL;

