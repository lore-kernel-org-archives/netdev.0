From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net 3/3] tcp: Apply device TSO segment limit earlier
Date: Tue, 31 Jul 2012 03:11:42 +0100
Message-ID: <1343700702.2667.79.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37278 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751847Ab2GaCLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 22:11:46 -0400
In-Reply-To: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cache the device gso_max_segs in sock::sk_gso_max_segs and use it to
limit the size of TSO skbs.  This avoids the need to fall back to
software GSO for local TCP senders.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is similar to v1 patch 1, but using the device's gso_max_segs
instead of a constant.  It also covers a couple of additional cases
where sk_gso_max_size is currently used.  It improves performance in the
case that the limit is reached, but this may not be worth doing if
legitimate peers don't cause us to hit that limit.

Ben.

 include/net/sock.h    |    2 ++
 net/core/sock.c       |    1 +
 net/ipv4/tcp.c        |    4 +++-
 net/ipv4/tcp_cong.c   |    3 ++-
 net/ipv4/tcp_output.c |   21 ++++++++++++---------
 5 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e067f8c..25a823a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -218,6 +218,7 @@ struct cg_proto;
   *	@sk_route_nocaps: forbidden route capabilities (e.g NETIF_F_GSO_MASK)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
   *	@sk_gso_max_size: Maximum GSO segment size to build
+  *	@sk_gso_max_segs: Maximum number of GSO segments
   *	@sk_lingertime: %SO_LINGER l_linger setting
   *	@sk_backlog: always used with the per-socket spinlock held
   *	@sk_callback_lock: used with the callbacks in the end of this struct
@@ -338,6 +339,7 @@ struct sock {
 	netdev_features_t	sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
+	u16			sk_gso_max_segs;
 	int			sk_rcvlowat;
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
diff --git a/net/core/sock.c b/net/core/sock.c
index 2676a88..34cc7bb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1403,6 +1403,7 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
 			sk->sk_gso_max_size = dst->dev->gso_max_size;
+			sk->sk_gso_max_segs = dst->dev->gso_max_segs;
 		}
 	}
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e7e6eea..2109ff4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -811,7 +811,9 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 			   old_size_goal + mss_now > xmit_size_goal)) {
 			xmit_size_goal = old_size_goal;
 		} else {
-			tp->xmit_size_goal_segs = xmit_size_goal / mss_now;
+			tp->xmit_size_goal_segs =
+				min_t(u16, xmit_size_goal / mss_now,
+				      sk->sk_gso_max_segs);
 			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
 		}
 	}
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 4d4db16..1432cdb 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -291,7 +291,8 @@ bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-	    left * tp->mss_cache < sk->sk_gso_max_size)
+	    left * tp->mss_cache < sk->sk_gso_max_size &&
+	    left < sk->sk_gso_max_segs)
 		return true;
 	return left <= tcp_max_tso_deferred_mss(tp);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 33cd065..0c9db8f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1522,21 +1522,21 @@ static void tcp_cwnd_validate(struct sock *sk)
  * when we would be allowed to send the split-due-to-Nagle skb fully.
  */
 static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_buff *skb,
-					unsigned int mss_now, unsigned int cwnd)
+					unsigned int mss_now, unsigned int max_segs)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	u32 needed, window, cwnd_len;
+	u32 needed, window, max_len;
 
 	window = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
-	cwnd_len = mss_now * cwnd;
+	max_len = mss_now * max_segs;
 
-	if (likely(cwnd_len <= window && skb != tcp_write_queue_tail(sk)))
-		return cwnd_len;
+	if (likely(max_len <= window && skb != tcp_write_queue_tail(sk)))
+		return max_len;
 
 	needed = min(skb->len, window);
 
-	if (cwnd_len <= needed)
-		return cwnd_len;
+	if (max_len <= needed)
+		return max_len;
 
 	return needed - needed % mss_now;
 }
@@ -1765,7 +1765,8 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= sk->sk_gso_max_size)
+	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
+			   sk->sk_gso_max_segs * tp->mss_cache))
 		goto send_now;
 
 	/* Middle in queue won't get any more data, full sendable already? */
@@ -1999,7 +2000,9 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		limit = mss_now;
 		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
-						    cwnd_quota);
+						    min_t(unsigned int,
+							  cwnd_quota,
+							  sk->sk_gso_max_segs));
 
 		if (skb->len > limit &&
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
