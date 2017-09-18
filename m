From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: remove two unused functions
Date: Mon, 18 Sep 2017 11:05:16 -0700
Message-ID: <20170918180516.22390-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:54357 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753883AbdIRSFf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 14:05:35 -0400
Received: by mail-pg0-f51.google.com with SMTP id c137so552569pga.11
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 11:05:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove tcp_may_send_now and tcp_snd_test that are no longer used

Fixes: 840a3cbe8969 ("tcp: remove forward retransmit feature")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |  1 -
 net/ipv4/tcp_output.c | 34 ----------------------------------
 2 files changed, 35 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ada65e767b28..a25c97f13b62 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -543,7 +543,6 @@ u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now,
 		     int min_tso_segs);
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle);
-bool tcp_may_send_now(struct sock *sk);
 int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs);
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs);
 void tcp_retransmit_timer(struct sock *sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b7661a68d498..b2d5d1c7ec6d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1803,40 +1803,6 @@ static bool tcp_snd_wnd_test(const struct tcp_sock *tp,
 	return !after(end_seq, tcp_wnd_end(tp));
 }
 
-/* This checks if the data bearing packet SKB (usually tcp_send_head(sk))
- * should be put on the wire right now.  If so, it returns the number of
- * packets allowed by the congestion window.
- */
-static unsigned int tcp_snd_test(const struct sock *sk, struct sk_buff *skb,
-				 unsigned int cur_mss, int nonagle)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	unsigned int cwnd_quota;
-
-	tcp_init_tso_segs(skb, cur_mss);
-
-	if (!tcp_nagle_test(tp, skb, cur_mss, nonagle))
-		return 0;
-
-	cwnd_quota = tcp_cwnd_test(tp, skb);
-	if (cwnd_quota && !tcp_snd_wnd_test(tp, skb, cur_mss))
-		cwnd_quota = 0;
-
-	return cwnd_quota;
-}
-
-/* Test if sending is allowed right now. */
-bool tcp_may_send_now(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = tcp_send_head(sk);
-
-	return skb &&
-		tcp_snd_test(sk, skb, tcp_current_mss(sk),
-			     (tcp_skb_is_last(sk, skb) ?
-			      tp->nonagle : TCP_NAGLE_PUSH));
-}
-
 /* Trim TSO SKB to LEN bytes, put the remaining data into a new packet
  * which is put after SKB on the list.  It is very much like
  * tcp_fragment() except that it may make several kinds of assumptions
-- 
2.14.1.690.gbb1197296e-goog
