From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] tcp: move tcp_openreq_init() to tcp_input.c
Date: Mon, 16 Mar 2015 21:06:19 -0700
Message-ID: <1426565180-26844-6-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:33908 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbCQEG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:58 -0400
Received: by pdev10 with SMTP id v10so12503000pde.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:58 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This big helper is called once from tcp_conn_request(), there is no
point having it in an include. Compiler will inline it anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h    | 25 -------------------------
 net/ipv4/tcp_input.c | 25 +++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2e11e38205c2..9fe1d535cd6c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1137,31 +1137,6 @@ static inline int tcp_full_space(const struct sock *sk)
 	return tcp_win_from_space(sk->sk_rcvbuf);
 }
 
-static inline void tcp_openreq_init(struct request_sock *req,
-				    struct tcp_options_received *rx_opt,
-				    struct sk_buff *skb, struct sock *sk)
-{
-	struct inet_request_sock *ireq = inet_rsk(req);
-
-	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
-	req->cookie_ts = 0;
-	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
-	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
-	tcp_rsk(req)->snt_synack = tcp_time_stamp;
-	tcp_rsk(req)->last_oow_ack_time = 0;
-	req->mss = rx_opt->mss_clamp;
-	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
-	ireq->tstamp_ok = rx_opt->tstamp_ok;
-	ireq->sack_ok = rx_opt->sack_ok;
-	ireq->snd_wscale = rx_opt->snd_wscale;
-	ireq->wscale_ok = rx_opt->wscale_ok;
-	ireq->acked = 0;
-	ireq->ecn_ok = 0;
-	ireq->ir_rmt_port = tcp_hdr(skb)->source;
-	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
-	ireq->ir_mark = inet_request_mark(sk, skb);
-}
-
 extern void tcp_openreq_init_rwin(struct request_sock *req,
 				  struct sock *sk, struct dst_entry *dst);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 717d437b6ce1..10d6bd93f229 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5912,6 +5912,31 @@ static void tcp_ecn_create_request(struct request_sock *req,
 		inet_rsk(req)->ecn_ok = 1;
 }
 
+static void tcp_openreq_init(struct request_sock *req,
+			     const struct tcp_options_received *rx_opt,
+			     struct sk_buff *skb, const struct sock *sk)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+
+	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
+	req->cookie_ts = 0;
+	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
+	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	tcp_rsk(req)->last_oow_ack_time = 0;
+	req->mss = rx_opt->mss_clamp;
+	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
+	ireq->tstamp_ok = rx_opt->tstamp_ok;
+	ireq->sack_ok = rx_opt->sack_ok;
+	ireq->snd_wscale = rx_opt->snd_wscale;
+	ireq->wscale_ok = rx_opt->wscale_ok;
+	ireq->acked = 0;
+	ireq->ecn_ok = 0;
+	ireq->ir_rmt_port = tcp_hdr(skb)->source;
+	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
+	ireq->ir_mark = inet_request_mark(sk, skb);
+}
+
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb)
-- 
2.2.0.rc0.207.ga3a616c
