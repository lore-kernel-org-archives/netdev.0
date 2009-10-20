From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH RFC] Allow tcp_parse_options to consult dst entry
Date: Tue, 20 Oct 2009 17:22:35 +0200
Message-ID: <1256052161-14156-3-git-send-email-gilad@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <1256052161-14156-2-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37448 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZJTPWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:22:40 -0400
In-Reply-To: <1256052161-14156-2-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need tcp_parse_options to be aware of dst_entry to 
take into account per dst_entry TCP options settings

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>

---
 include/net/tcp.h        |    3 ++-
 net/ipv4/syncookies.c    |   27 ++++++++++++++-------------
 net/ipv4/tcp_input.c     |    9 ++++++---
 net/ipv4/tcp_ipv4.c      |   19 ++++++++++---------
 net/ipv4/tcp_minisocks.c |    7 +++++--
 net/ipv6/syncookies.c    |   28 +++++++++++++++-------------
 net/ipv6/tcp_ipv6.c      |    3 ++-
 7 files changed, 54 insertions(+), 42 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..740d09b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -409,7 +409,8 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
-						  int estab);
+						  int estab,
+						  struct dst_entry *dst);
 
 extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a6e0e07..4990dd4 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -276,13 +276,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
-	/* check for timestamp cookie support */
-	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
-
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
-
 	ret = NULL;
 	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
 	if (!req)
@@ -298,12 +291,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->ecn_ok		= 0;
-	ireq->snd_wscale	= tcp_opt.snd_wscale;
-	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
-	ireq->sack_ok		= tcp_opt.sack_ok;
-	ireq->wscale_ok		= tcp_opt.wscale_ok;
-	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
-	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -351,6 +338,20 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, 0, &rt->u.dst);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
+	ireq->snd_wscale        = tcp_opt.snd_wscale;
+	ireq->rcv_wscale        = tcp_opt.rcv_wscale;
+	ireq->sack_ok           = tcp_opt.sack_ok;
+	ireq->wscale_ok         = tcp_opt.wscale_ok;
+	ireq->tstamp_ok         = tcp_opt.saw_tstamp;
+	req->ts_recent          = tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
+
 	/* Try to redo what tcp_v4_send_synack did. */
 	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->u.dst, RTAX_WINDOW);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..d502f49 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3698,12 +3698,14 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab)
+		       int estab,  struct dst_entry *dst)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
 	int length = (th->doff * 4) - sizeof(struct tcphdr);
 
+	BUG_ON(!estab && !dst);
+
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
 
@@ -3820,7 +3822,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1);
+	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
 	return 1;
 }
 
@@ -5364,8 +5366,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	struct dst_entry *dst = __sk_dst_get(sk);
 
-	tcp_parse_options(skb, &tp->rx_opt, 0);
+	tcp_parse_options(skb, &tp->rx_opt, 0, dst);
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..1cb0ec4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1256,11 +1256,18 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
+	ireq = inet_rsk(req);
+	ireq->loc_addr = daddr;
+	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
+	ireq->opt = tcp_v4_save_options(sk, skb);
+
+	dst = inet_csk_route_req(sk, req);
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = 536;
 	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, dst);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1269,14 +1276,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_openreq_init(req, &tmp_opt, skb);
 
-	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
-	ireq->no_srccheck = inet_sk(sk)->transparent;
-	ireq->opt = tcp_v4_save_options(sk, skb);
-
 	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_free;
+		goto drop_and_release;
 
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
@@ -1301,7 +1302,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet_csk_route_req(sk, req)) != NULL &&
+		    dst != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->v4daddr == saddr) {
 			if (get_seconds() < peer->tcp_ts_stamp + TCP_PAWS_MSL &&
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index c49a550..70ff955 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -101,7 +101,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	int paws_reject = 0;
 
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, 1);
+		tcp_parse_options(skb, &tmp_opt, 1, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -499,10 +499,11 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	int paws_reject = 0;
 	struct tcp_options_received tmp_opt;
 	struct sock *child;
+	struct dst_entry *dst = inet_csk_route_req(sk, req);
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tcp_parse_options(skb, &tmp_opt, 0, dst);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
@@ -515,6 +516,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	dst_release(dst);
+
 	/* Check for pure retransmitted SYN. */
 	if (TCP_SKB_CB(skb)->seq == tcp_rsk(req)->rcv_isn &&
 	    flg == TCP_FLAG_SYN &&
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6b6ae91..6ece408 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -184,13 +184,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
-	/* check for timestamp cookie support */
-	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
-
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
-
 	ret = NULL;
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
 	if (!req)
@@ -224,12 +217,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->expires = 0UL;
 	req->retrans = 0;
 	ireq->ecn_ok		= 0;
-	ireq->snd_wscale	= tcp_opt.snd_wscale;
-	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
-	ireq->sack_ok		= tcp_opt.sack_ok;
-	ireq->wscale_ok		= tcp_opt.wscale_ok;
-	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
-	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
 
@@ -264,6 +251,21 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 			goto out_free;
 	}
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, 0, dst);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
+	req->ts_recent          = tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
+
+	ireq->snd_wscale        = tcp_opt.snd_wscale;
+	ireq->rcv_wscale        = tcp_opt.rcv_wscale;
+	ireq->sack_ok           = tcp_opt.sack_ok;
+	ireq->wscale_ok         = tcp_opt.wscale_ok;
+	ireq->tstamp_ok         = tcp_opt.saw_tstamp;
+
 	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 21d100b..2eebab5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1165,6 +1165,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock *req = NULL;
 	__u32 isn = TCP_SKB_CB(skb)->when;
+	struct dst_entry *dst = __sk_dst_get(sk);
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1203,7 +1204,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, 0, dst);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
-- 
1.5.6.3

