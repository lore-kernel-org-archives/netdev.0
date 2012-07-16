From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 7/7] net-tcp: Fast Open client - cookie-less mode
Date: Mon, 16 Jul 2012 14:16:50 -0700
Message-ID: <1342473410-6265-8-git-send-email-ycheng@google.com>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:59983 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2GPVW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 17:22:59 -0400
Received: by eekb47 with SMTP id b47so4028eek.1
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 14:22:58 -0700 (PDT)
In-Reply-To: <1342473410-6265-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In trusted networks, e.g., intranet, data-center, the client does not
need to use Fast Open cookie to mitigate DoS attacks. In cookie-less
mode, sendmsg() with MSG_FASTOPEN flag will send SYN-data regardless
of cookie availability.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 Documentation/networking/ip-sysctl.txt |    2 ++
 include/linux/tcp.h                    |    1 +
 include/net/tcp.h                      |    1 +
 net/ipv4/tcp_input.c                   |    8 ++++++--
 net/ipv4/tcp_output.c                  |    6 +++++-
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index b3c5225..d67d858 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -476,6 +476,8 @@ tcp_fastopen - INTEGER
 
 	The values (bitmap) are:
 	1: Enables sending data in the opening SYN on the client
+	5: Enables sending data in the opening SYN on the client regardless
+	   of cookie availability.
 
 	Default: 0
 
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1edf96a..9febfb6 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -387,6 +387,7 @@ struct tcp_sock {
 	u8	repair_queue;
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		early_retrans_delayed:1, /* Delayed ER timer installed */
+		syn_data:1,	/* SYN includes data */
 		syn_fastopen:1;	/* SYN includes Fast Open option */
 
 /* RTT measurement */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1b70444..99ec440 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -214,6 +214,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* Bit Flags for sysctl_tcp_fastopen */
 #define	TFO_CLIENT_ENABLE	1
+#define	TFO_CLIENT_NO_COOKIE	4	/* Data in SYN w/o cookie option */
 
 extern struct inet_timewait_death_row tcp_death_row;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index aef8514..5915ac2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5614,7 +5614,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 				    struct tcp_fastopen_cookie *cookie)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *data = tcp_write_queue_head(sk);
+	struct sk_buff *data = tp->syn_data ? tcp_write_queue_head(sk) : NULL;
 	u16 mss = tp->rx_opt.mss_clamp;
 	bool syn_drop;
 
@@ -5636,6 +5636,9 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	syn_drop = (cookie->len <= 0 && data &&
 		    inet_csk(sk)->icsk_retransmits);
 
+	if (!tp->syn_fastopen)  /* Ignore an unsolicited cookie */
+		cookie->len = -1;
+
 	tcp_fastopen_cache_set(sk, &mss, cookie, syn_drop);
 
 	if (data) { /* Retransmit unacked data in SYN */
@@ -5780,7 +5783,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		tcp_finish_connect(sk, skb);
 
-		if (tp->syn_fastopen && tcp_rcv_fastopen_synack(sk, skb, &foc))
+		if ((tp->syn_fastopen || tp->syn_data) &&
+		    tcp_rcv_fastopen_synack(sk, skb, &foc))
 			return -1;
 
 		if (sk->sk_write_pending ||
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c5cfd5e..27a32ac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2864,6 +2864,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	struct sk_buff *syn_data = NULL, *data;
 	unsigned long last_syn_loss = 0;
 
+	tp->rx_opt.mss_clamp = tp->advmss;  /* If MSS is not cached */
 	tcp_fastopen_cache_get(sk, &tp->rx_opt.mss_clamp, &fo->cookie,
 			       &syn_loss, &last_syn_loss);
 	/* Recurring FO SYN losses: revert to regular handshake temporarily */
@@ -2873,7 +2874,9 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 		goto fallback;
 	}
 
-	if (fo->cookie.len <= 0)
+	if (sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE)
+		fo->cookie.len = -1;
+	else if (fo->cookie.len <= 0)
 		goto fallback;
 
 	/* MSS for SYN-data is based on cached MSS and bounded by PMTU and
@@ -2916,6 +2919,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	fo->copied = data->len;
 
 	if (tcp_transmit_skb(sk, syn_data, 0, sk->sk_allocation) == 0) {
+		tp->syn_data = (fo->copied > 0);
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFASTOPENACTIVE);
 		goto done;
 	}
-- 
1.7.7.3
