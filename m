From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v4 net-next 11/16] tcp: export tcp_tso_autosize() and parameterize minimum number of TSO segments
Date: Mon, 19 Sep 2016 23:39:18 -0400
Message-ID: <1474342763-16715-12-git-send-email-ncardwell@google.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36142 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbcITDjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:39:46 -0400
Received: by mail-qk0-f174.google.com with SMTP id z190so4288899qkc.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 20:39:45 -0700 (PDT)
In-Reply-To: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow congestion control modules to use the default TSO auto-sizing
algorithm as one of the ingredients in their own decision about TSO sizing:

1) Export tcp_tso_autosize() so that CC modules can use it.

2) Change tcp_tso_autosize() to allow callers to specify a minimum
   number of segments per TSO skb, in case the congestion control
   module has a different notion of the best floor for TSO skbs for
   the connection right now. For very low-rate paths or policed
   connections it can be appropriate to use smaller TSO skbs.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_output.c | 9 ++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f8f581f..3492041 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -533,6 +533,8 @@ __u32 cookie_v6_init_sequence(const struct sk_buff *skb, __u16 *mss);
 #endif
 /* tcp_output.c */
 
+u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now,
+		     int min_tso_segs);
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle);
 bool tcp_may_send_now(struct sock *sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0137956..0bf3d48 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1549,7 +1549,8 @@ static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
 /* Return how many segs we'd like on a TSO packet,
  * to send one TSO packet per ms
  */
-static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
+u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now,
+		     int min_tso_segs)
 {
 	u32 bytes, segs;
 
@@ -1561,10 +1562,11 @@ static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
 	 * This preserves ACK clocking and is consistent
 	 * with tcp_tso_should_defer() heuristic.
 	 */
-	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+	segs = max_t(u32, bytes / mss_now, min_tso_segs);
 
 	return min_t(u32, segs, sk->sk_gso_max_segs);
 }
+EXPORT_SYMBOL(tcp_tso_autosize);
 
 /* Return the number of segments we want in the skb we are transmitting.
  * See if congestion control module wants to decide; otherwise, autosize.
@@ -1574,7 +1576,8 @@ static u32 tcp_tso_segs(struct sock *sk, unsigned int mss_now)
 	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	u32 tso_segs = ca_ops->tso_segs_goal ? ca_ops->tso_segs_goal(sk) : 0;
 
-	return tso_segs ? : tcp_tso_autosize(sk, mss_now);
+	return tso_segs ? :
+		tcp_tso_autosize(sk, mss_now, sysctl_tcp_min_tso_segs);
 }
 
 /* Returns the portion of skb which can be sent right away */
-- 
2.8.0.rc3.226.g39d4020
