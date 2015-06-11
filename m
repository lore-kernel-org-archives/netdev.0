From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/5] tcp: fill shinfo->gso_size at last moment
Date: Thu, 11 Jun 2015 09:15:18 -0700
Message-ID: <1434039319-31309-5-git-send-email-edumazet@google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33266 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbbFKQPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:54 -0400
Received: by igbpi8 with SMTP id pi8so57217905igb.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:52 -0700 (PDT)
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location") we stored
gso_segs in a temporary cache hot location.

This patch does the same for gso_size.

This allows to save 2 cache line misses in tcp xmit path for
the last packet that is considered but not sent because of
various conditions (cwnd, tso defer, receiver window, TSQ...)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 13 ++++++++-----
 net/ipv4/tcp_input.c  |  8 ++++----
 net/ipv4/tcp_output.c | 12 ++++--------
 3 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 978cebedd3fc..950cfecaad3c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -730,11 +730,14 @@ struct tcp_skb_cb {
 		/* Note : tcp_tw_isn is used in input path only
 		 *	  (isn chosen by tcp_timewait_state_process())
 		 *
-		 * 	  tcp_gso_segs is used in write queue only,
-		 *	  cf tcp_skb_pcount()
+		 * 	  tcp_gso_segs/size are used in write queue only,
+		 *	  cf tcp_skb_pcount()/tcp_skb_mss()
 		 */
 		__u32		tcp_tw_isn;
-		__u32		tcp_gso_segs;
+		struct {
+			u16	tcp_gso_segs;
+			u16	tcp_gso_size;
+		};
 	};
 	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
 
@@ -790,10 +793,10 @@ static inline void tcp_skb_pcount_add(struct sk_buff *skb, int segs)
 	TCP_SKB_CB(skb)->tcp_gso_segs += segs;
 }
 
-/* This is valid iff tcp_skb_pcount() > 1. */
+/* This is valid iff skb is in write queue and tcp_skb_pcount() > 1. */
 static inline int tcp_skb_mss(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->gso_size;
+	return TCP_SKB_CB(skb)->tcp_gso_size;
 }
 
 /* Events passed to congestion control interface */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 70a6fa8ecbd3..684f095d196e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1316,12 +1316,12 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	 * code can come after this skb later on it's better to keep
 	 * setting gso_size to something.
 	 */
-	if (!skb_shinfo(prev)->gso_size)
-		skb_shinfo(prev)->gso_size = mss;
+	if (!TCP_SKB_CB(prev)->tcp_gso_size)
+		TCP_SKB_CB(prev)->tcp_gso_size = mss;
 
 	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
 	if (tcp_skb_pcount(skb) <= 1)
-		skb_shinfo(skb)->gso_size = 0;
+		TCP_SKB_CB(skb)->tcp_gso_size = 0;
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
 	TCP_SKB_CB(prev)->sacked |= (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS);
@@ -2248,7 +2248,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 			    (oldcnt >= packets))
 				break;
 
-			mss = skb_shinfo(skb)->gso_size;
+			mss = tcp_skb_mss(skb);
 			err = tcp_fragment(sk, skb, (packets - oldcnt) * mss,
 					   mss, GFP_ATOMIC);
 			if (err < 0)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d12888581337..787f57ff87c4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -402,8 +402,6 @@ static void tcp_ecn_send(struct sock *sk, struct sk_buff *skb,
  */
 static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 {
-	struct skb_shared_info *shinfo = skb_shinfo(skb);
-
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	skb->csum = 0;
 
@@ -411,7 +409,6 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	tcp_skb_pcount_set(skb, 1);
-	shinfo->gso_size = 0;
 
 	TCP_SKB_CB(skb)->seq = seq;
 	if (flags & (TCPHDR_SYN | TCPHDR_FIN))
@@ -1028,8 +1025,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 			      tcp_skb_pcount(skb));
 
 	tp->segs_out += tcp_skb_pcount(skb);
-	/* OK, its time to fill skb_shinfo(skb)->gso_segs */
+	/* OK, its time to fill skb_shinfo(skb)->gso_{segs|size} */
 	skb_shinfo(skb)->gso_segs = tcp_skb_pcount(skb);
+	skb_shinfo(skb)->gso_size = tcp_skb_mss(skb);
 
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
@@ -1068,8 +1066,6 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 /* Initialize TSO segments for a packet. */
 static void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_now)
 {
-	struct skb_shared_info *shinfo = skb_shinfo(skb);
-
 	/* Make sure we own this skb before messing gso_size/gso_segs */
 	WARN_ON_ONCE(skb_cloned(skb));
 
@@ -1078,10 +1074,10 @@ static void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_now)
 		 * non-TSO case.
 		 */
 		tcp_skb_pcount_set(skb, 1);
-		shinfo->gso_size = 0;
+		TCP_SKB_CB(skb)->tcp_gso_size = 0;
 	} else {
 		tcp_skb_pcount_set(skb, DIV_ROUND_UP(skb->len, mss_now));
-		shinfo->gso_size = mss_now;
+		TCP_SKB_CB(skb)->tcp_gso_size = mss_now;
 	}
 }
 
-- 
2.2.0.rc0.207.ga3a616c
