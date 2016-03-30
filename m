From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: remove cwnd moderation after recovery
Date: Tue, 29 Mar 2016 17:15:52 -0700
Message-ID: <1459296952-12214-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34441 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbcC3AQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 20:16:06 -0400
Received: by mail-pf0-f176.google.com with SMTP id x3so27430201pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 17:16:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For non-SACK connections, cwnd is lowered to inflight plus 3 packets
when the recovery ends. This is an optional feature in the NewReno
RFC 2582 to reduce the potential burst when cwnd is "re-opened"
after recovery and inflight is low.

This feature is questionably effective because of PRR: when
the recovery ends (i.e., snd_una == high_seq) NewReno holds the
CA_Recovery state for another round trip to prevent false fast
retransmits. But if the inflight is low, PRR will overwrite the
moderated cwnd in tcp_cwnd_reduction() later.

On the other hand, if the recovery ends because the sender
detects the losses were spurious (e.g., reordering). This feature
unconditionally lowers a reverted cwnd even though nothing
was lost.

By principle loss recovery module should not update cwnd. Further
pacing is much more effective to reduce burst. Hence this patch
removes the cwnd moderation feature.

Signed-off-by: Matt Mathis <mattmathis@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h    | 11 -----------
 net/ipv4/tcp_input.c | 11 -----------
 2 files changed, 22 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b91370f..f8bb4a4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1039,17 +1039,6 @@ static inline __u32 tcp_max_tso_deferred_mss(const struct tcp_sock *tp)
 	return 3;
 }
 
-/* Slow start with delack produces 3 packets of burst, so that
- * it is safe "de facto".  This will be the default - same as
- * the default reordering threshold - but if reordering increases,
- * we must be able to allow cwnd to burst at least this much in order
- * to not pull it back when holes are filled.
- */
-static __inline__ __u32 tcp_max_burst(const struct tcp_sock *tp)
-{
-	return tp->reordering;
-}
-
 /* Returns end sequence number of the receiver's advertised window */
 static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e6e65f7..f87b84a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2252,16 +2252,6 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 	}
 }
 
-/* CWND moderation, preventing bursts due to too big ACKs
- * in dubious situations.
- */
-static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
-{
-	tp->snd_cwnd = min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-}
-
 static bool tcp_tsopt_ecr_before(const struct tcp_sock *tp, u32 when)
 {
 	return tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
@@ -2410,7 +2400,6 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 		/* Hold old state until something *above* high_seq
 		 * is ACKed. For Reno it is MUST to prevent false
 		 * fast retransmits (RFC2582). SACK TCP is safe. */
-		tcp_moderate_cwnd(tp);
 		if (!tcp_any_retrans_done(sk))
 			tp->retrans_stamp = 0;
 		return true;
-- 
2.8.0.rc3.226.g39d4020
