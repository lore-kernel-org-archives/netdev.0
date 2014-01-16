From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next] ipv6: tcp: fix flowlabel value in ACK messages send from TIME_WAIT
Date: Thu, 16 Jan 2014 17:21:22 +0100
Message-ID: <1389889282-2562-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57328 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbaAPQVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 11:21:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is following the commit b903d324bee262 (ipv6: tcp: fix TCLASS
value in ACK messages sent from TIME_WAIT).

For the same reason than tclass, we have to store the flow label in the
inet_timewait_sock to provide consistency of flow label on the last ACK.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/inet_timewait_sock.h |  6 +++---
 net/ipv4/tcp_minisocks.c         |  1 +
 net/ipv6/tcp_ipv6.c              | 17 +++++++++++------
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 71c6e26..61474ea 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -133,9 +133,9 @@ struct inet_timewait_sock {
 	/* And these are ours. */
 	unsigned int		tw_ipv6only     : 1,
 				tw_transparent  : 1,
-				tw_pad		: 6,	/* 6 bits hole */
-				tw_tos		: 8,
-				tw_pad2		: 16;	/* 16 bits hole */
+				tw_flowlabel	: 20,
+				tw_pad		: 2,	/* 2 bits hole */
+				tw_tos		: 8;
 	kmemcheck_bitfield_end(flags);
 	u32			tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3aa9e32..7a436c5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -297,6 +297,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			tw->tw_v6_daddr = sk->sk_v6_daddr;
 			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_tclass = np->tclass;
+			tw->tw_flowlabel = np->flow_label >> 12;
 			tw->tw_ipv6only = np->ipv6only;
 		}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f61bedc..c3d1341 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -726,7 +726,8 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 tsval, u32 tsecr,
-				 struct tcp_md5sig_key *key, int rst, u8 tclass)
+				 struct tcp_md5sig_key *key, int rst, u8 tclass,
+				 u32 label)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcphdr *t1;
@@ -788,6 +789,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.daddr = ipv6_hdr(skb)->saddr;
 	fl6.saddr = ipv6_hdr(skb)->daddr;
+	fl6.flowlabel = label;
 
 	buff->ip_summed = CHECKSUM_PARTIAL;
 	buff->csum = 0;
@@ -873,7 +875,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, 0);
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, 0, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 release_sk1:
@@ -886,9 +888,11 @@ release_sk1:
 
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 tsval, u32 tsecr,
-			    struct tcp_md5sig_key *key, u8 tclass)
+			    struct tcp_md5sig_key *key, u8 tclass,
+			    u32 label)
 {
-	tcp_v6_send_response(skb, seq, ack, win, tsval, tsecr, key, 0, tclass);
+	tcp_v6_send_response(skb, seq, ack, win, tsval, tsecr, key, 0, tclass,
+			     label);
 }
 
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -900,7 +904,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcp_time_stamp + tcptw->tw_ts_offset,
 			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
-			tw->tw_tclass);
+			tw->tw_tclass, (tw->tw_flowlabel << 12));
 
 	inet_twsk_put(tw);
 }
@@ -910,7 +914,8 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
 			req->rcv_wnd, tcp_time_stamp, req->ts_recent,
-			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr), 0);
+			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
+			0, 0);
 }
 
 
-- 
1.8.5.2
