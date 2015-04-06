From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 2/2] tcp: RFC7413 option support for Fast Open client
Date: Mon,  6 Apr 2015 14:37:27 -0700
Message-ID: <1428356247-10262-2-git-send-email-ycheng@google.com>
References: <1428356247-10262-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Daniel Lee <Longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34440 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbbDFVif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:38:35 -0400
Received: by iget9 with SMTP id t9so1596037ige.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 14:38:35 -0700 (PDT)
In-Reply-To: <1428356247-10262-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lee <Longinus00@gmail.com>

Fast Open has been using an experimental option with a magic number
(RFC6994). This patch makes the client by default use the RFC7413
option (34) to get and send Fast Open cookies.  This patch makes
the client solicit cookies from a given server first with the
RFC7413 option. If that fails to elicit a cookie, then it tries
the RFC6994 experimental option. If that also fails, it uses the
RFC7413 option on all subsequent connect attempts.  If the server
returns a Fast Open cookie then the client caches the form of the
option that successfully elicited a cookie, and uses that form on
later connects when it presents that cookie.

The idea is to gradually obsolete the use of experimental options as
the servers and clients upgrade, while keeping the interoperability
meanwhile.

Signed-off-by: Daniel Lee <Longinus00@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h    |  1 +
 include/net/tcp.h      |  3 ++-
 net/ipv4/tcp_input.c   | 29 +++++++++++++++++++----------
 net/ipv4/tcp_metrics.c | 13 +++++++++++--
 net/ipv4/tcp_output.c  |  6 +++++-
 net/ipv4/tcp_timer.c   |  2 +-
 6 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a48d003..0caa3a2 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -189,6 +189,7 @@ struct tcp_sock {
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		syn_data:1,	/* SYN includes data */
 		syn_fastopen:1,	/* SYN includes Fast Open option */
+		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
 		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7292c3c..9598871 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1339,7 +1339,8 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
 			    struct tcp_fastopen_cookie *cookie, int *syn_loss,
 			    unsigned long *last_syn_loss);
 void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
-			    struct tcp_fastopen_cookie *cookie, bool syn_lost);
+			    struct tcp_fastopen_cookie *cookie, bool syn_lost,
+			    u16 try_exp);
 struct tcp_fastopen_request {
 	/* Fast Open cookie. Size 0 means a cookie request */
 	struct tcp_fastopen_cookie	cookie;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 55b0e39..bb81499 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5377,8 +5377,8 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *data = tp->syn_data ? tcp_write_queue_head(sk) : NULL;
-	u16 mss = tp->rx_opt.mss_clamp;
-	bool syn_drop;
+	u16 mss = tp->rx_opt.mss_clamp, try_exp = 0;
+	bool syn_drop = false;
 
 	if (mss == tp->rx_opt.user_mss) {
 		struct tcp_options_received opt;
@@ -5390,16 +5390,25 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 		mss = opt.mss_clamp;
 	}
 
-	if (!tp->syn_fastopen)  /* Ignore an unsolicited cookie */
+	if (!tp->syn_fastopen) {
+		/* Ignore an unsolicited cookie */
 		cookie->len = -1;
+	} else if (tp->total_retrans) {
+		/* SYN timed out and the SYN-ACK neither has a cookie nor
+		 * acknowledges data. Presumably the remote received only
+		 * the retransmitted (regular) SYNs: either the original
+		 * SYN-data or the corresponding SYN-ACK was dropped.
+		 */
+		syn_drop = (cookie->len < 0 && data);
+	} else if (cookie->len < 0 && !tp->syn_data) {
+		/* We requested a cookie but didn't get it. If we did not use
+		 * the (old) exp opt format then try so next time (try_exp=1).
+		 * Otherwise we go back to use the RFC7413 opt (try_exp=2).
+		 */
+		try_exp = tp->syn_fastopen_exp ? 2 : 1;
+	}
 
-	/* The SYN-ACK neither has cookie nor acknowledges the data. Presumably
-	 * the remote receives only the retransmitted (regular) SYNs: either
-	 * the original SYN-data or the corresponding SYN-ACK is lost.
-	 */
-	syn_drop = (cookie->len <= 0 && data && tp->total_retrans);
-
-	tcp_fastopen_cache_set(sk, mss, cookie, syn_drop);
+	tcp_fastopen_cache_set(sk, mss, cookie, syn_drop, try_exp);
 
 	if (data) { /* Retransmit unacked data in SYN */
 		tcp_for_write_queue_from(data, sk) {
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 78ecc4a..a51d63a 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -28,7 +28,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
 
 struct tcp_fastopen_metrics {
 	u16	mss;
-	u16	syn_loss:10;		/* Recurring Fast Open SYN losses */
+	u16	syn_loss:10,		/* Recurring Fast Open SYN losses */
+		try_exp:2;		/* Request w/ exp. option (once) */
 	unsigned long	last_syn_loss;	/* Last Fast Open SYN loss */
 	struct	tcp_fastopen_cookie	cookie;
 };
@@ -131,6 +132,8 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm,
 	if (fastopen_clear) {
 		tm->tcpm_fastopen.mss = 0;
 		tm->tcpm_fastopen.syn_loss = 0;
+		tm->tcpm_fastopen.try_exp = 0;
+		tm->tcpm_fastopen.cookie.exp = false;
 		tm->tcpm_fastopen.cookie.len = 0;
 	}
 }
@@ -713,6 +716,8 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
 			if (tfom->mss)
 				*mss = tfom->mss;
 			*cookie = tfom->cookie;
+			if (cookie->len <= 0 && tfom->try_exp == 1)
+				cookie->exp = true;
 			*syn_loss = tfom->syn_loss;
 			*last_syn_loss = *syn_loss ? tfom->last_syn_loss : 0;
 		} while (read_seqretry(&fastopen_seqlock, seq));
@@ -721,7 +726,8 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
 }
 
 void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
-			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
+			    struct tcp_fastopen_cookie *cookie, bool syn_lost,
+			    u16 try_exp)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_metrics_block *tm;
@@ -738,6 +744,9 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 			tfom->mss = mss;
 		if (cookie && cookie->len > 0)
 			tfom->cookie = *cookie;
+		else if (try_exp > tfom->try_exp &&
+			 tfom->cookie.len <= 0 && !tfom->cookie.exp)
+			tfom->try_exp = try_exp;
 		if (syn_lost) {
 			++tfom->syn_loss;
 			tfom->last_syn_loss = jiffies;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 464bd8c..e662d85 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -592,13 +592,17 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 
 	if (fastopen && fastopen->cookie.len >= 0) {
-		u32 need = TCPOLEN_EXP_FASTOPEN_BASE + fastopen->cookie.len;
+		u32 need = fastopen->cookie.len;
+
+		need += fastopen->cookie.exp ? TCPOLEN_EXP_FASTOPEN_BASE :
+					       TCPOLEN_FASTOPEN_BASE;
 		need = (need + 3) & ~3U;  /* Align to 32 bits */
 		if (remaining >= need) {
 			opts->options |= OPTION_FAST_OPEN_COOKIE;
 			opts->fastopen_cookie = &fastopen->cookie;
 			remaining -= need;
 			tp->syn_fastopen = 1;
+			tp->syn_fastopen_exp = fastopen->cookie.exp ? 1 : 0;
 		}
 	}
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 2568fd2..8c65dc1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -167,7 +167,7 @@ static int tcp_write_timeout(struct sock *sk)
 		if (icsk->icsk_retransmits) {
 			dst_negative_advice(sk);
 			if (tp->syn_fastopen || tp->syn_data)
-				tcp_fastopen_cache_set(sk, 0, NULL, true);
+				tcp_fastopen_cache_set(sk, 0, NULL, true, 0);
 			if (tp->syn_data)
 				NET_INC_STATS_BH(sock_net(sk),
 						 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
-- 
2.2.0.rc0.207.ga3a616c
