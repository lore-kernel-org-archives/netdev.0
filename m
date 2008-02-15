From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: [PATCH 1/3] Support arbitrary initial TCP timestamps
Date: Fri, 15 Feb 2008 09:47:08 -0800
Message-ID: <1203097630-13237-1-git-send-email-ggriffin.kernel@gmail.com>
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:11164 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634AbYBORjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 12:39:23 -0500
Received: by wx-out-0506.google.com with SMTP id h31so727692wxd.4
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 09:39:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the ability to send arbitrary initial tcp timestamps that are not
tied directly to jiffies.  The basic conecpt is every tcp_request_sock and
tcp_sock now has a ts_off offset that represents the difference between
tcp_time_stamp and the timestamp we send and expect to
receive.

This has the advantage of not divulging system information (uptime)
depending on the policy chosen for the initial timestamps.

A policy where ts_off is always set to zero should produce no change in
behavior.  The policy implemented is not intended for real use, but just as
a simple example.  A realistic example would probably be similar to the tcp
init sequence generator.

Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>
---
 include/linux/tcp.h      |    6 ++++++
 include/net/tcp.h        |    2 +-
 net/ipv4/tcp_input.c     |   12 ++++++------
 net/ipv4/tcp_ipv4.c      |    2 +-
 net/ipv4/tcp_minisocks.c |    5 +++--
 net/ipv4/tcp_output.c    |    8 +++++---
 net/ipv6/tcp_ipv6.c      |    2 +-
 7 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 08027f1..68387dc 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -232,6 +232,7 @@ struct tcp_request_sock {
 #endif
 	u32			 	rcv_isn;
 	u32			 	snt_isn;
+	u32				ts_off;
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -311,6 +312,11 @@ struct tcp_sock {
 	struct tcp_options_received rx_opt;
 
 /*
+ * 	offset of transmitted tcp timestamp from jiffies
+ */
+	u32	ts_off;
+
+/*
  *	Slow start and congestion control (see also Nagle, and Karn & Partridge)
  */
  	u32	snd_ssthresh;	/* Slow start size threshold		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..c935de7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -395,7 +395,7 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
-						  int estab);
+						  int estab, u32 tsecr_off);
 
 /*
  *	TCP v4 functions exported for the inet6 API
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..95fa8dc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3264,7 +3264,7 @@ uninteresting_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab)
+		       int estab, u32 tsecr_off)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
@@ -3322,7 +3322,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				     (!estab && sysctl_tcp_timestamps))) {
 					opt_rx->saw_tstamp = 1;
 					opt_rx->rcv_tsval = ntohl(get_unaligned((__be32 *)ptr));
-					opt_rx->rcv_tsecr = ntohl(get_unaligned((__be32 *)(ptr+4)));
+					opt_rx->rcv_tsecr = ntohl(get_unaligned((__be32 *)(ptr+4))) - tsecr_off;
 				}
 				break;
 			case TCPOPT_SACK_PERM:
@@ -3374,11 +3374,11 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 			++ptr;
 			tp->rx_opt.rcv_tsval = ntohl(*ptr);
 			++ptr;
-			tp->rx_opt.rcv_tsecr = ntohl(*ptr);
+			tp->rx_opt.rcv_tsecr = ntohl(*ptr) - tp->ts_off;
 			return 1;
 		}
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1);
+	tcp_parse_options(skb, &tp->rx_opt, 1, tp->ts_off);
 	return 1;
 }
 
@@ -4615,7 +4615,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			++ptr;
 			tp->rx_opt.rcv_tsval = ntohl(*ptr);
 			++ptr;
-			tp->rx_opt.rcv_tsecr = ntohl(*ptr);
+			tp->rx_opt.rcv_tsecr = ntohl(*ptr) - tp->ts_off;
 
 			/* If PAWS failed, check it more carefully in slow path */
 			if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) < 0)
@@ -4824,7 +4824,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
-	tcp_parse_options(skb, &tp->rx_opt, 0);
+	tcp_parse_options(skb, &tp->rx_opt, 0, tp->ts_off);
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 63414ea..267eda9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1295,7 +1295,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = 536;
 	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 	if (want_cookie) {
 		tcp_clear_options(&tmp_opt);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b61b768..648f84e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -102,7 +102,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -442,6 +442,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 			inet_csk_reset_keepalive_timer(newsk,
 						       keepalive_time_when(newtp));
 
+		newtp->ts_off = treq->ts_off;
 		newtp->rx_opt.tstamp_ok = ireq->tstamp_ok;
 		if ((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
 			if (sysctl_tcp_fack)
@@ -502,7 +503,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tcp_parse_options(skb, &tmp_opt, 0, tcp_rsk(req)->ts_off);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ed750f9..81f1383 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -583,7 +583,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 				      (sysctl_flags & SYSCTL_FLAG_SACK),
 				      (sysctl_flags & SYSCTL_FLAG_WSCALE),
 				      tp->rx_opt.rcv_wscale,
-				      tcb->when,
+				      tcb->when + tp->ts_off,
 				      tp->rx_opt.ts_recent,
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -592,7 +592,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 				      NULL);
 	} else {
 		tcp_build_and_update_options((__be32 *)(th + 1),
-					     tp, tcb->when,
+					     tp, tcb->when + tp->ts_off,
 #ifdef CONFIG_TCP_MD5SIG
 					     md5 ? &md5_hash_location :
 #endif
@@ -2227,9 +2227,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rcv_wnd, 65535U));
 
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	tcp_rsk(req)->ts_off = 1000 - TCP_SKB_CB(skb)->when;
 	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
 			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
-			      TCP_SKB_CB(skb)->when,
+			      TCP_SKB_CB(skb)->when + tcp_rsk(req)->ts_off,
 			      req->ts_recent,
 			      (
 #ifdef CONFIG_TCP_MD5SIG
@@ -2335,6 +2336,7 @@ int tcp_connect(struct sock *sk)
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	tp->ts_off = 2000 - TCP_SKB_CB(buff)->when;
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
 	skb_header_release(buff);
 	__tcp_add_write_queue_tail(sk, buff);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 12750f2..896ebd0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1264,7 +1264,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, 0);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
-- 
1.5.4

