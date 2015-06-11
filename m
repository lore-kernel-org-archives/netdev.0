From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/5] tcp: fill shinfo->gso_type at last moment
Date: Thu, 11 Jun 2015 09:15:16 -0700
Message-ID: <1434039319-31309-3-git-send-email-edumazet@google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38559 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbFKQPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:42 -0400
Received: by igblz2 with SMTP id lz2so8583275igb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:42 -0700 (PDT)
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our goal is to touch skb_shinfo(skb) only when absolutely needed,
to avoid two cache line misses in TCP output path for last skb
that is considered but not sent because of various conditions
(cwnd, tso defer, receiver window, TSQ...)

A packet is GSO only when skb_shinfo(skb)->gso_size is not zero.

We can set skb_shinfo(skb)->gso_type to sk->sk_gso_type even for
non GSO packets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c  | 8 ++------
 net/ipv4/tcp_output.c | 4 +---
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d4f76ab6e136..70a6fa8ecbd3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1316,16 +1316,12 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	 * code can come after this skb later on it's better to keep
 	 * setting gso_size to something.
 	 */
-	if (!skb_shinfo(prev)->gso_size) {
+	if (!skb_shinfo(prev)->gso_size)
 		skb_shinfo(prev)->gso_size = mss;
-		skb_shinfo(prev)->gso_type = sk->sk_gso_type;
-	}
 
 	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
-	if (tcp_skb_pcount(skb) <= 1) {
+	if (tcp_skb_pcount(skb) <= 1)
 		skb_shinfo(skb)->gso_size = 0;
-		skb_shinfo(skb)->gso_type = 0;
-	}
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
 	TCP_SKB_CB(prev)->sacked |= (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index eeb59befaf06..a51f7aab27d6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -412,7 +412,6 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 
 	tcp_skb_pcount_set(skb, 1);
 	shinfo->gso_size = 0;
-	shinfo->gso_type = 0;
 
 	TCP_SKB_CB(skb)->seq = seq;
 	if (flags & (TCPHDR_SYN | TCPHDR_FIN))
@@ -1003,6 +1002,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
+	skb_shinfo(skb)->gso_type = sk->sk_gso_type;
 	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
 		tcp_ecn_send(sk, skb, tcp_header_size);
 
@@ -1080,11 +1080,9 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 		 */
 		tcp_skb_pcount_set(skb, 1);
 		shinfo->gso_size = 0;
-		shinfo->gso_type = 0;
 	} else {
 		tcp_skb_pcount_set(skb, DIV_ROUND_UP(skb->len, mss_now));
 		shinfo->gso_size = mss_now;
-		shinfo->gso_type = sk->sk_gso_type;
 	}
 }
 
-- 
2.2.0.rc0.207.ga3a616c
