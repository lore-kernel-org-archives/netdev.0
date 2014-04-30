From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix cwnd limited checking to improve
 congestion control
Date: Wed, 30 Apr 2014 11:58:13 -0700
Message-ID: <1398884293.29914.181.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398874919.29914.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:58393 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758836AbaD3S6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 14:58:16 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so2493403pad.20
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 11:58:15 -0700 (PDT)
In-Reply-To: <1398874919.29914.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yuchung discovered tcp_is_cwnd_limited() was returning false in
slow start phase even if the application filled the socket write queue.

All congestion modules take into account tcp_is_cwnd_limited()
before increasing cwnd, so this behavior limits slow start from
probing the bandwidth at full speed.

The problem is that even if write queue is full (aka we are _not_
application limited), cwnd can be under utilized if TSO should auto
defer or TCP Small queues decided to hold packets.

So the in_flight can be kept to smaller value, and we can get to the
point tcp_is_cwnd_limited() returns false.

With TCP Small Queues and FQ/pacing, this issue is more visible.

We fix this by having tcp_cwnd_validate(), which is supposed to track
such things, take into account unsent_segs, the number of segs that we
are not sending at the moment due to TSO or TSQ, but intend to send
real soon. Then when we are cwnd-limited, remember this fact while we
are processing the window of ACKs that comes back.

For example, suppose we have a brand new connection with cwnd=10; we
are in slow start, and we send a flight of 9 packets. By the time we
have received ACKs for all 9 packets we want our cwnd to be 18.
We implement this by setting tp->lsnd_pending to 9, and
considering ourselves to be cwnd-limited while cwnd is less than
twice tp->lsnd_pending (2*9 -> 18).

This makes tcp_is_cwnd_limited() more understandable, by removing
the GSO/TSO kludge, that tried to work around the issue.

Note the in_flight parameter can be removed in a followup cleanup
patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/linux/tcp.h   |    1 +
 include/net/tcp.h     |   22 +++++++++++++++++++++-
 net/ipv4/tcp_cong.c   |   20 --------------------
 net/ipv4/tcp_output.c |   21 ++++++++++++++-------
 4 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 239946868142..7aacd831280b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -230,6 +230,7 @@ struct tcp_sock {
 	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
+	u32	lsnd_pending;	/* packets inflight or unsent since last xmit */
 	u32	prior_cwnd;	/* Congestion window at start of Recovery. */
 	u32	prr_delivered;	/* Number of newly delivered packets to
 				 * receiver in Recovery. */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 163d2b467d78..a9fe7bc4f4bb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -974,7 +974,27 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 {
 	return tp->snd_una + tp->snd_wnd;
 }
-bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
+
+/* We follow the spirit of RFC2861 to validate cwnd but implement a more
+ * flexible approach. The RFC suggests cwnd should not be raised unless
+ * it was fully used previously. But we allow cwnd to grow as long as the
+ * application has used half the cwnd.
+ * Example :
+ *    cwnd is 10 (IW10), but application sends 9 frames.
+ *    We allow cwnd to reach 18 when all frames are ACKed.
+ * This check is safe because it's as aggressive as slow start which already
+ * risks 100% overshoot. The advantage is that we discourage application to
+ * either send more filler packets or data to artificially blow up the cwnd
+ * usage, and allow application-limited process to probe bw more aggressively.
+ *
+ * TODO: remove in_flight once we can fix all callers, and their callers...
+ */
+static inline bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	return tp->snd_cwnd < 2 * tp->lsnd_pending;
+}
 
 static inline void tcp_check_probe_timer(struct sock *sk)
 {
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 2b9464c93b88..a93b41ba05ff 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -276,26 +276,6 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 	return err;
 }
 
-/* RFC2861 Check whether we are limited by application or congestion window
- * This is the inverse of cwnd check in tcp_tso_should_defer
- */
-bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	u32 left;
-
-	if (in_flight >= tp->snd_cwnd)
-		return true;
-
-	left = tp->snd_cwnd - in_flight;
-	if (sk_can_gso(sk) &&
-	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-	    left < tp->xmit_size_goal_segs)
-		return true;
-	return left <= tcp_max_tso_deferred_mss(tp);
-}
-EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
-
 /* Slow start is used when congestion window is no greater than the slow start
  * threshold. We base on RFC2581 and also handle stretch ACKs properly.
  * We do not implement RFC3465 Appropriate Byte Counting (ABC) per se but
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20847de991ea..f9181a133462 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1402,12 +1402,13 @@ static void tcp_cwnd_application_limited(struct sock *sk)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-/* Congestion window validation. (RFC2861) */
-static void tcp_cwnd_validate(struct sock *sk)
+static void tcp_cwnd_validate(struct sock *sk, u32 unsent_segs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tp->packets_out >= tp->snd_cwnd) {
+	tp->lsnd_pending = tp->packets_out + unsent_segs;
+
+	if (tcp_is_cwnd_limited(sk, 0)) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used = 0;
 		tp->snd_cwnd_stamp = tcp_time_stamp;
@@ -1880,7 +1881,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	unsigned int tso_segs, sent_pkts;
+	unsigned int tso_segs, sent_pkts, unsent_segs = 0;
 	int cwnd_quota;
 	int result;
 
@@ -1924,7 +1925,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		} else {
 			if (!push_one && tcp_tso_should_defer(sk, skb))
-				break;
+				goto compute_unsent_segs;
 		}
 
 		/* TCP Small Queues :
@@ -1949,8 +1950,14 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			 * there is no smp_mb__after_set_bit() yet
 			 */
 			smp_mb__after_clear_bit();
-			if (atomic_read(&sk->sk_wmem_alloc) > limit)
+			if (atomic_read(&sk->sk_wmem_alloc) > limit) {
+				u32 unsent_bytes;
+
+compute_unsent_segs:
+				unsent_bytes = tp->write_seq - tp->snd_nxt;
+				unsent_segs = DIV_ROUND_UP(unsent_bytes, mss_now);
 				break;
+			}
 		}
 
 		limit = mss_now;
@@ -1990,7 +1997,7 @@ repair:
 		/* Send one loss probe per tail loss episode. */
 		if (push_one != 2)
 			tcp_schedule_loss_probe(sk);
-		tcp_cwnd_validate(sk);
+		tcp_cwnd_validate(sk, unsent_segs);
 		return false;
 	}
 	return (push_one == 2) || (!tp->packets_out && tcp_send_head(sk));
