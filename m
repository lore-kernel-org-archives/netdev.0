From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 3/4] net: shrink struct sock and request_sock by 8 bytes
Date: Thu,  8 Oct 2015 19:33:23 -0700
Message-ID: <1444358004-26483-4-git-send-email-edumazet@google.com>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35623 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756612AbbJICdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:33:39 -0400
Received: by pabve7 with SMTP id ve7so13203261pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:33:37 -0700 (PDT)
In-Reply-To: <1444358004-26483-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One 32bit hole is following skc_refcnt, use it.
skc_incoming_cpu can also be an union for request_sock rcv_wnd.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |  5 ++---
 include/net/sock.h         | 14 +++++++++-----
 net/ipv4/syncookies.c      |  4 ++--
 net/ipv4/tcp_input.c       |  2 +-
 net/ipv4/tcp_ipv4.c        |  2 +-
 net/ipv4/tcp_minisocks.c   | 18 +++++++++---------
 net/ipv4/tcp_output.c      |  2 +-
 net/ipv6/syncookies.c      |  4 ++--
 net/ipv6/tcp_ipv6.c        |  2 +-
 9 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 6b818b77d5e5..2e73748956d5 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -51,15 +51,14 @@ struct request_sock {
 #define rsk_refcnt			__req_common.skc_refcnt
 #define rsk_hash			__req_common.skc_hash
 #define rsk_listener			__req_common.skc_listener
+#define rsk_window_clamp		__req_common.skc_window_clamp
+#define rsk_rcv_wnd			__req_common.skc_rcv_wnd
 
 	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
 	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
 	u8				num_timeout:7; /* number of timeouts */
-	/* The following two fields can be easily recomputed I think -AK */
-	u32				window_clamp; /* window clamp at creation time */
-	u32				rcv_wnd;	  /* rcv_wnd offered first time */
 	u32				ts_recent;
 	struct timer_list		rsk_timer;
 	const struct request_sock_ops	*rsk_ops;
diff --git a/include/net/sock.h b/include/net/sock.h
index a7818104a73f..fce12399fad4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -226,11 +226,18 @@ struct sock_common {
 		struct hlist_nulls_node skc_nulls_node;
 	};
 	int			skc_tx_queue_mapping;
-	int			skc_incoming_cpu;
+	union {
+		int		skc_incoming_cpu;
+		u32		skc_rcv_wnd;
+	};
 
 	atomic_t		skc_refcnt;
 	/* private: */
 	int                     skc_dontcopy_end[0];
+	union {
+		u32		skc_rxhash;
+		u32		skc_window_clamp;
+	};
 	/* public: */
 };
 
@@ -287,7 +294,6 @@ struct cg_proto;
   *	@sk_rcvlowat: %SO_RCVLOWAT setting
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
-  *	@sk_rxhash: flow hash received from netif layer
   *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_timer: sock cleanup timer
@@ -346,6 +352,7 @@ struct sock {
 #define sk_cookie		__sk_common.skc_cookie
 #define sk_incoming_cpu		__sk_common.skc_incoming_cpu
 #define sk_flags		__sk_common.skc_flags
+#define sk_rxhash		__sk_common.skc_rxhash
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
@@ -365,9 +372,6 @@ struct sock {
 	} sk_backlog;
 #define sk_rmem_alloc sk_backlog.rmem_alloc
 	int			sk_forward_alloc;
-#ifdef CONFIG_RPS
-	__u32			sk_rxhash;
-#endif
 
 	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 8113c30ccf96..0769248bc0db 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -381,10 +381,10 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Try to redo what tcp_v4_send_synack did. */
-	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->dst, RTAX_WINDOW);
+	req->rsk_window_clamp = tp->window_clamp ? :dst_metric(&rt->dst, RTAX_WINDOW);
 
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
-				  &req->rcv_wnd, &req->window_clamp,
+				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
 				  dst_metric(&rt->dst, RTAX_INITRWND));
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ddadb318e850..3b35c3f4d268 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6022,7 +6022,7 @@ static void tcp_openreq_init(struct request_sock *req,
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 
-	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
+	req->rsk_rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
 	req->cookie_ts = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 34310748a365..ddb198392c7f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -803,7 +803,7 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 	 */
 	tcp_v4_send_ack(skb, (sk->sk_state == TCP_LISTEN) ?
 			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
-			tcp_rsk(req)->rcv_nxt, req->rcv_wnd,
+			tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
 			tcp_time_stamp,
 			req->ts_recent,
 			0,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 9adf1e2c3170..85272bf50f6e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -381,18 +381,18 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 
 	window_clamp = READ_ONCE(tp->window_clamp);
 	/* Set this up on the first call only */
-	req->window_clamp = window_clamp ? : dst_metric(dst, RTAX_WINDOW);
+	req->rsk_window_clamp = window_clamp ? : dst_metric(dst, RTAX_WINDOW);
 
 	/* limit the window selection if the user enforce a smaller rx buffer */
 	if (sk_listener->sk_userlocks & SOCK_RCVBUF_LOCK &&
-	    (req->window_clamp > full_space || req->window_clamp == 0))
-		req->window_clamp = full_space;
+	    (req->rsk_window_clamp > full_space || req->rsk_window_clamp == 0))
+		req->rsk_window_clamp = full_space;
 
 	/* tcp_full_space because it is guaranteed to be the first packet */
 	tcp_select_initial_window(full_space,
 		mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
-		&req->rcv_wnd,
-		&req->window_clamp,
+		&req->rsk_rcv_wnd,
+		&req->rsk_window_clamp,
 		ireq->wscale_ok,
 		&rcv_wscale,
 		dst_metric(dst, RTAX_INITRWND));
@@ -512,9 +512,9 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 			if (sysctl_tcp_fack)
 				tcp_enable_fack(newtp);
 		}
-		newtp->window_clamp = req->window_clamp;
-		newtp->rcv_ssthresh = req->rcv_wnd;
-		newtp->rcv_wnd = req->rcv_wnd;
+		newtp->window_clamp = req->rsk_window_clamp;
+		newtp->rcv_ssthresh = req->rsk_rcv_wnd;
+		newtp->rcv_wnd = req->rsk_rcv_wnd;
 		newtp->rx_opt.wscale_ok = ireq->wscale_ok;
 		if (newtp->rx_opt.wscale_ok) {
 			newtp->rx_opt.snd_wscale = ireq->snd_wscale;
@@ -707,7 +707,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	/* RFC793: "first check sequence number". */
 
 	if (paws_reject || !tcp_in_window(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
-					  tcp_rsk(req)->rcv_nxt, tcp_rsk(req)->rcv_nxt + req->rcv_wnd)) {
+					  tcp_rsk(req)->rcv_nxt, tcp_rsk(req)->rcv_nxt + req->rsk_rcv_wnd)) {
 		/* Out of window: send ACK and drop. */
 		if (!(flg & TCP_FLAG_RST))
 			req->rsk_ops->send_ack(sk, skb, req);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 55ed3266b05f..6e79fcb0addb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3023,7 +3023,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_nxt);
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
-	th->window = htons(min(req->rcv_wnd, 65535U));
+	th->window = htons(min(req->rsk_rcv_wnd, 65535U));
 	tcp_options_write((__be32 *)(th + 1), NULL, &opts);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index f610b5310b17..bb8f2fa1c7fb 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -235,9 +235,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 			goto out_free;
 	}
 
-	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
+	req->rsk_window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
-				  &req->rcv_wnd, &req->window_clamp,
+				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
 				  dst_metric(dst, RTAX_INITRWND));
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 33334f0c217d..2887c8474b65 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -931,7 +931,7 @@ static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 	 */
 	tcp_v6_send_ack(sk, skb, (sk->sk_state == TCP_LISTEN) ?
 			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
-			tcp_rsk(req)->rcv_nxt, req->rcv_wnd,
+			tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
 			tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
 			0, 0);
-- 
2.6.0.rc2.230.g3dd15c0
