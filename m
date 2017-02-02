From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add tcp_mss_clamp() helper
Date: Thu, 02 Feb 2017 08:04:56 -0800
Message-ID: <1486051496.13103.48.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34205 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdBBQE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:04:58 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so2178965pgj.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:04:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Small cleanup factorizing code doing the TCP_MAXSEG clamping.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h      |    9 +++++++++
 net/ipv4/tcp_ipv4.c      |    5 +----
 net/ipv4/tcp_minisocks.c |    7 ++-----
 net/ipv4/tcp_output.c    |   14 ++++----------
 net/ipv6/tcp_ipv6.c      |    5 +----
 5 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f88f4649ba6f8a9a19578f55272533a12e5c9680..cfc2d9506ce8077af1ec92eb7086fd52ce4fe1ac 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -445,4 +445,13 @@ static inline void tcp_saved_syn_free(struct tcp_sock *tp)
 
 struct sk_buff *tcp_get_timestamping_opt_stats(const struct sock *sk);
 
+static inline u16 tcp_mss_clamp(const struct tcp_sock *tp, u16 mss)
+{
+	/* We use READ_ONCE() here because socket might not be locked.
+	 * This happens for listeners.
+	 */
+	u16 user_mss = READ_ONCE(tp->rx_opt.user_mss);
+
+	return (user_mss && user_mss < mss) ? user_mss : mss;
+}
 #endif	/* _LINUX_TCP_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8c9e9aa17d660d7e92bdced72ace0c8644621371..8c124d4ef4b72eb18df3fb2515ee141df9a521f3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1324,10 +1324,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	tcp_ca_openreq_child(newsk, dst);
 
 	tcp_sync_mss(newsk, dst_mtu(dst));
-	newtp->advmss = dst_metric_advmss(dst);
-	if (tcp_sk(sk)->rx_opt.user_mss &&
-	    tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
-		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
+	newtp->advmss = tcp_mss_clamp(tcp_sk(sk), dst_metric_advmss(dst));
 
 	tcp_initialize_rcv_mss(newsk);
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index bdb443471c3914cd57c3836c43f73648b452c01e..dff7d2aaf8611e96da094097e1e153541b3e0119 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -360,15 +360,12 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	const struct tcp_sock *tp = tcp_sk(sk_listener);
-	u16 user_mss = READ_ONCE(tp->rx_opt.user_mss);
 	int full_space = tcp_full_space(sk_listener);
-	int mss = dst_metric_advmss(dst);
 	u32 window_clamp;
 	__u8 rcv_wscale;
+	int mss;
 
-	if (user_mss && user_mss < mss)
-		mss = user_mss;
-
+	mss = tcp_mss_clamp(tp, dst_metric_advmss(dst));
 	window_clamp = READ_ONCE(tp->window_clamp);
 	/* Set this up on the first call only */
 	req->rsk_window_clamp = window_clamp ? : dst_metric(dst, RTAX_WINDOW);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7b2d8762f15f6479f5aa956376ebbae594597259..3c1edfbad57e4ca2150da799e83dd268f0f4f2c6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3060,7 +3060,6 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	struct sk_buff *skb;
 	int tcp_header_size;
 	struct tcphdr *th;
-	u16 user_mss;
 	int mss;
 
 	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
@@ -3090,10 +3089,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	}
 	skb_dst_set(skb, dst);
 
-	mss = dst_metric_advmss(dst);
-	user_mss = READ_ONCE(tp->rx_opt.user_mss);
-	if (user_mss && user_mss < mss)
-		mss = user_mss;
+	mss = tcp_mss_clamp(tp, dst_metric_advmss(dst));
 
 	memset(&opts, 0, sizeof(opts));
 #ifdef CONFIG_SYN_COOKIES
@@ -3199,9 +3195,7 @@ static void tcp_connect_init(struct sock *sk)
 
 	if (!tp->window_clamp)
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
-	tp->advmss = dst_metric_advmss(dst);
-	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < tp->advmss)
-		tp->advmss = tp->rx_opt.user_mss;
+	tp->advmss = tcp_mss_clamp(tp, dst_metric_advmss(dst));
 
 	tcp_initialize_rcv_mss(sk);
 
@@ -3278,8 +3272,8 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	 * user-MSS. Reserve maximum option space for middleboxes that add
 	 * private TCP options. The cost is reduced data space in SYN :(
 	 */
-	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < tp->rx_opt.mss_clamp)
-		tp->rx_opt.mss_clamp = tp->rx_opt.user_mss;
+	tp->rx_opt.mss_clamp = tcp_mss_clamp(tp, tp->rx_opt.mss_clamp);
+
 	space = __tcp_mtu_to_mss(sk, inet_csk(sk)->icsk_pmtu_cookie) -
 		MAX_TCP_OPTION_SPACE;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 64834ec5ab730a8d2b1828028432ddf9ac77714c..6b9fc63fd4d23f17a6716b3557098e09f4f1d439 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1147,10 +1147,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	tcp_ca_openreq_child(newsk, dst);
 
 	tcp_sync_mss(newsk, dst_mtu(dst));
-	newtp->advmss = dst_metric_advmss(dst);
-	if (tcp_sk(sk)->rx_opt.user_mss &&
-	    tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
-		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
+	newtp->advmss = tcp_mss_clamp(tcp_sk(sk), dst_metric_advmss(dst));
 
 	tcp_initialize_rcv_mss(newsk);
 
