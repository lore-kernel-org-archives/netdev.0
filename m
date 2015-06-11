From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/5] tcp: tcp_set_skb_tso_segs() no longer need struct sock parameter
Date: Thu, 11 Jun 2015 09:15:17 -0700
Message-ID: <1434039319-31309-4-git-send-email-edumazet@google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36842 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbbFKQPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:48 -0400
Received: by igbpi8 with SMTP id pi8so58604312igb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:47 -0700 (PDT)
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_set_skb_tso_segs() & tcp_init_tso_segs() no longer
use the sock pointer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a51f7aab27d6..d12888581337 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1066,8 +1066,7 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Initialize TSO segments for a packet. */
-static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
-				 unsigned int mss_now)
+static void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_now)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 
@@ -1214,8 +1213,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	old_factor = tcp_skb_pcount(skb);
 
 	/* Fix up tso_factor for both original and new SKB.  */
-	tcp_set_skb_tso_segs(sk, skb, mss_now);
-	tcp_set_skb_tso_segs(sk, buff, mss_now);
+	tcp_set_skb_tso_segs(skb, mss_now);
+	tcp_set_skb_tso_segs(buff, mss_now);
 
 	/* If this packet has been sent out already, we must
 	 * adjust the various packet counters.
@@ -1295,7 +1294,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 
 	/* Any change of skb->len requires recalculation of tso factor. */
 	if (tcp_skb_pcount(skb) > 1)
-		tcp_set_skb_tso_segs(sk, skb, tcp_skb_mss(skb));
+		tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
 
 	return 0;
 }
@@ -1627,13 +1626,12 @@ static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
  * This must be invoked the first time we consider transmitting
  * SKB onto the wire.
  */
-static int tcp_init_tso_segs(const struct sock *sk, struct sk_buff *skb,
-			     unsigned int mss_now)
+static int tcp_init_tso_segs(struct sk_buff *skb, unsigned int mss_now)
 {
 	int tso_segs = tcp_skb_pcount(skb);
 
 	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
-		tcp_set_skb_tso_segs(sk, skb, mss_now);
+		tcp_set_skb_tso_segs(skb, mss_now);
 		tso_segs = tcp_skb_pcount(skb);
 	}
 	return tso_segs;
@@ -1688,7 +1686,7 @@ static unsigned int tcp_snd_test(const struct sock *sk, struct sk_buff *skb,
 	const struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int cwnd_quota;
 
-	tcp_init_tso_segs(sk, skb, cur_mss);
+	tcp_init_tso_segs(skb, cur_mss);
 
 	if (!tcp_nagle_test(tp, skb, cur_mss, nonagle))
 		return 0;
@@ -1757,8 +1755,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	tcp_fragment_tstamp(skb, buff);
 
 	/* Fix up tso_factor for both original and new SKB.  */
-	tcp_set_skb_tso_segs(sk, skb, mss_now);
-	tcp_set_skb_tso_segs(sk, buff, mss_now);
+	tcp_set_skb_tso_segs(skb, mss_now);
+	tcp_set_skb_tso_segs(buff, mss_now);
 
 	/* Link BUFF into the send queue. */
 	__skb_header_release(buff);
@@ -1992,7 +1990,7 @@ static int tcp_mtu_probe(struct sock *sk)
 								 skb->len, 0);
 			} else {
 				__pskb_trim_head(skb, copy);
-				tcp_set_skb_tso_segs(sk, skb, mss_now);
+				tcp_set_skb_tso_segs(skb, mss_now);
 			}
 			TCP_SKB_CB(skb)->seq += copy;
 		}
@@ -2002,7 +2000,7 @@ static int tcp_mtu_probe(struct sock *sk)
 		if (len >= probe_size)
 			break;
 	}
-	tcp_init_tso_segs(sk, nskb, nskb->len);
+	tcp_init_tso_segs(nskb, nskb->len);
 
 	/* We're ready to send.  If this fails, the probe will
 	 * be resegmented into mss-sized pieces by tcp_write_xmit().
@@ -2064,7 +2062,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
-		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
+		tso_segs = tcp_init_tso_segs(skb, mss_now);
 		BUG_ON(!tso_segs);
 
 		if (unlikely(tp->repair) && tp->repair_queue == TCP_SEND_QUEUE) {
@@ -2618,7 +2616,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (unlikely(oldpcount > 1)) {
 			if (skb_unclone(skb, GFP_ATOMIC))
 				return -ENOMEM;
-			tcp_init_tso_segs(sk, skb, cur_mss);
+			tcp_init_tso_segs(skb, cur_mss);
 			tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
 		}
 	}
@@ -3455,7 +3453,7 @@ int tcp_write_wakeup(struct sock *sk, int mib)
 			if (tcp_fragment(sk, skb, seg_size, mss, GFP_ATOMIC))
 				return -1;
 		} else if (!tcp_skb_pcount(skb))
-			tcp_set_skb_tso_segs(sk, skb, mss);
+			tcp_set_skb_tso_segs(skb, mss);
 
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
-- 
2.2.0.rc0.207.ga3a616c
