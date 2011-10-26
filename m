From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Wed, 26 Oct 2011 08:42:11 +0200
Message-ID: <1319611331.18883.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40176 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab1JZGmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 02:42:18 -0400
Received: by wwe6 with SMTP id 6so1935257wwe.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 23:42:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 66b13d99d96a (ipv4: tcp: fix TOS value in ACK messages sent from
TIME_WAIT) fixed IPv4 only.

This part is for the IPv6 side.

We alias tw_tclass and tw_tos, if socket family is INET6.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_timewait_sock.h |    1 +
 include/net/ipv6.h               |    3 ++-
 net/ipv4/tcp_minisocks.c         |    1 +
 net/ipv6/inet6_connection_sock.c |    2 +-
 net/ipv6/ip6_output.c            |    7 ++-----
 net/ipv6/tcp_ipv6.c              |   17 +++++++++--------
 6 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 180231c..f91a1fb 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -134,6 +134,7 @@ struct inet_timewait_sock {
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
 };
+#define tw_tclass tw_tos
 
 static inline void inet_twsk_add_node_rcu(struct inet_timewait_sock *tw,
 				      struct hlist_nulls_head *list)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3b5ac1f..a366a8a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -486,7 +486,8 @@ extern int			ip6_rcv_finish(struct sk_buff *skb);
 extern int			ip6_xmit(struct sock *sk,
 					 struct sk_buff *skb,
 					 struct flowi6 *fl6,
-					 struct ipv6_txoptions *opt);
+					 struct ipv6_txoptions *opt,
+					 int tclass);
 
 extern int			ip6_nd_hdr(struct sock *sk,
 					   struct sk_buff *skb,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 85a2fbe..66363b6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -345,6 +345,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			tw6 = inet6_twsk((struct sock *)tw);
 			ipv6_addr_copy(&tw6->tw_v6_daddr, &np->daddr);
 			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
+			tw->tw_tclass = np->tclass;
 			tw->tw_ipv6only = np->ipv6only;
 		}
 #endif
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 2916200..fee46d5 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -248,7 +248,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl6.daddr, &np->daddr);
 
-	res = ip6_xmit(sk, skb, &fl6, np->opt);
+	res = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 	rcu_read_unlock();
 	return res;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1c9bf8b..ff30047 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -180,7 +180,7 @@ int ip6_output(struct sk_buff *skb)
  */
 
 int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
-	     struct ipv6_txoptions *opt)
+	     struct ipv6_txoptions *opt, int tclass)
 {
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -190,7 +190,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	u8  proto = fl6->flowi6_proto;
 	int seg_len = skb->len;
 	int hlimit = -1;
-	int tclass = 0;
 	u32 mtu;
 
 	if (opt) {
@@ -228,10 +227,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	/*
 	 *	Fill in the IPv6 header
 	 */
-	if (np) {
-		tclass = np->tclass;
+	if (np)
 		hlimit = np->hop_limit;
-	}
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c8683fc..10b2b31 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -513,7 +513,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
 		ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
-		err = ip6_xmit(sk, skb, &fl6, opt);
+		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
@@ -979,7 +979,7 @@ static int tcp6_gro_complete(struct sk_buff *skb)
 }
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
-				 u32 ts, struct tcp_md5sig_key *key, int rst)
+				 u32 ts, struct tcp_md5sig_key *key, int rst, u8 tclass)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcphdr *t1;
@@ -1060,7 +1060,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
-		ip6_xmit(ctl_sk, buff, &fl6, NULL);
+		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
 		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 		if (rst)
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
@@ -1093,13 +1093,13 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1);
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1, 0);
 }
 
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_md5sig_key *key, u8 tclass)
 {
-	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0);
+	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0, tclass);
 }
 
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -1109,7 +1109,8 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 
 	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw));
+			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
+			tw->tw_tclass);
 
 	inet_twsk_put(tw);
 }
@@ -1118,7 +1119,7 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
-			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr));
+			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr), 0);
 }
 
 
