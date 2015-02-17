From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2 078/152] Revert "tcp: Apply device TSO segment limit
 earlier"
Date: Tue, 17 Feb 2015 01:46:53 +0000
Message-ID: <lsq.1424137613.827302053@decadent.org.uk>
References: <lsq.1424137613.308090640@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, linux-net-drivers@solarflare.com,
	"Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <lsq.1424137613.308090640@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.2.67-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Ben Hutchings <ben@decadent.org.uk>

This reverts commit 9f871e883277cc22c6217db806376dce52401a31, which
was commit 1485348d2424e1131ea42efc033cbd9366462b01 upstream.

It can cause connections to stall when a PMTU event occurs.  This was
fixed by commit 843925f33fcc ("tcp: Do not apply TSO segment limit to
non-TSO packets") upstream, but that depends on other changes to TSO.

The original issue this fixed was a performance regression for the sfc
driver in extreme cases of TSO (skb with > 100 segments).  This is not
really very important and it seems best to revert it rather than try
to fix it up.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@vger.kernel.org
Cc: linux-net-drivers@solarflare.com
---
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -194,7 +194,6 @@ struct sock_common {
   *	@sk_route_nocaps: forbidden route capabilities (e.g NETIF_F_GSO_MASK)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
   *	@sk_gso_max_size: Maximum GSO segment size to build
-  *	@sk_gso_max_segs: Maximum number of GSO segments
   *	@sk_lingertime: %SO_LINGER l_linger setting
   *	@sk_backlog: always used with the per-socket spinlock held
   *	@sk_callback_lock: used with the callbacks in the end of this struct
@@ -311,7 +310,6 @@ struct sock {
 	int			sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
-	u16			sk_gso_max_segs;
 	int			sk_rcvlowat;
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1311,7 +1311,6 @@ void sk_setup_caps(struct sock *sk, stru
 		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
 			sk->sk_gso_max_size = dst->dev->gso_max_size;
-			sk->sk_gso_max_segs = dst->dev->gso_max_segs;
 		}
 	}
 }
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -738,9 +738,7 @@ static unsigned int tcp_xmit_size_goal(s
 			   old_size_goal + mss_now > xmit_size_goal)) {
 			xmit_size_goal = old_size_goal;
 		} else {
-			tp->xmit_size_goal_segs =
-				min_t(u16, xmit_size_goal / mss_now,
-				      sk->sk_gso_max_segs);
+			tp->xmit_size_goal_segs = xmit_size_goal / mss_now;
 			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
 		}
 	}
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -290,8 +290,7 @@ int tcp_is_cwnd_limited(const struct soc
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-	    left * tp->mss_cache < sk->sk_gso_max_size &&
-	    left < sk->sk_gso_max_segs)
+	    left * tp->mss_cache < sk->sk_gso_max_size)
 		return 1;
 	return left <= tcp_max_burst(tp);
 }
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1320,21 +1320,21 @@ static void tcp_cwnd_validate(struct soc
  * when we would be allowed to send the split-due-to-Nagle skb fully.
  */
 static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_buff *skb,
-					unsigned int mss_now, unsigned int max_segs)
+					unsigned int mss_now, unsigned int cwnd)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	u32 needed, window, max_len;
+	u32 needed, window, cwnd_len;
 
 	window = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
-	max_len = mss_now * max_segs;
+	cwnd_len = mss_now * cwnd;
 
-	if (likely(max_len <= window && skb != tcp_write_queue_tail(sk)))
-		return max_len;
+	if (likely(cwnd_len <= window && skb != tcp_write_queue_tail(sk)))
+		return cwnd_len;
 
 	needed = min(skb->len, window);
 
-	if (max_len <= needed)
-		return max_len;
+	if (cwnd_len <= needed)
+		return cwnd_len;
 
 	return needed - needed % mss_now;
 }
@@ -1562,8 +1562,7 @@ static int tcp_tso_should_defer(struct s
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
-			   sk->sk_gso_max_segs * tp->mss_cache))
+	if (limit >= sk->sk_gso_max_size)
 		goto send_now;
 
 	/* Middle in queue won't get any more data, full sendable already? */
@@ -1792,9 +1791,7 @@ static int tcp_write_xmit(struct sock *s
 		limit = mss_now;
 		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
-						    min_t(unsigned int,
-							  cwnd_quota,
-							  sk->sk_gso_max_segs));
+						    cwnd_quota);
 
 		if (skb->len > limit &&
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
