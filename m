From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] tcp: tso: remove tp->tso_deferred
Date: Thu, 26 Feb 2015 14:10:18 -0800
Message-ID: <1424988620-10781-2-git-send-email-edumazet@google.com>
References: <1424988620-10781-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:45753 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbBZWMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:12:02 -0500
Received: by mail-ob0-f201.google.com with SMTP id wo20so4049957obc.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 14:12:01 -0800 (PST)
In-Reply-To: <1424988620-10781-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TSO relies on ability to defer sending a small amount of packets.
Heuristic is to wait for future ACKS in hope to send more packets at once.
Current algorithm uses a per socket tso_deferred field as a pseudo timer.

This pseudo timer relies on future ACK, but there is no guarantee
we receive them in time.

Fix would be to use a real timer, but cost of such timer is probably too
expensive for typical cases.

This patch changes the logic to test the time of last transmit,
because we should not add bursts of more than 1ms for any given flow.

We've used this patch for about two years at Google, before FQ/pacing
as it would reduce a fair amount of bursts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h   |  1 -
 net/ipv4/tcp_output.c | 14 +++++---------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1a7adb411647..97dbf16f7d9d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -236,7 +236,6 @@ struct tcp_sock {
 	u32	lost_out;	/* Lost packets			*/
 	u32	sacked_out;	/* SACK'd packets			*/
 	u32	fackets_out;	/* FACK'd packets			*/
-	u32	tso_deferred;
 
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a2a796c5536b..cb95c7a9d1e7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1763,9 +1763,10 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	if (icsk->icsk_ca_state != TCP_CA_Open)
 		goto send_now;
 
-	/* Defer for less than two clock ticks. */
-	if (tp->tso_deferred &&
-	    (((u32)jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
+	/* Avoid bursty behavior by allowing defer
+	 * only if the last write was recent.
+	 */
+	if ((s32)(tcp_time_stamp - tp->lsndtime) > 0)
 		goto send_now;
 
 	in_flight = tcp_packets_in_flight(tp);
@@ -1807,11 +1808,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 			goto send_now;
 	}
 
-	/* Ok, it looks like it is advisable to defer.
-	 * Do not rearm the timer if already set to not break TCP ACK clocking.
-	 */
-	if (!tp->tso_deferred)
-		tp->tso_deferred = 1 | (jiffies << 1);
+	/* Ok, it looks like it is advisable to defer. */
 
 	if (cong_win < send_win && cong_win < skb->len)
 		*is_cwnd_limited = true;
@@ -1819,7 +1816,6 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	return true;
 
 send_now:
-	tp->tso_deferred = 0;
 	return false;
 }
 
-- 
2.2.0.rc0.207.ga3a616c
